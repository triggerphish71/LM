<!---
function - Display late fee for all houses 
Mshah - 02/07/2017
Script is written to get all the tenant who has late fee and credit balance in SL is equal to the amount of late fee total.
They can be paid all at once before starting the monthly close cycle.
--->

<!---<cfdump var="#form#">
<cfdump var="#Session#">--->


<!---<cfquery name="DeleteReportLateFeePaidAllHouse" datasource="#APPLICATION.DataSource#" result="ReportLateFeePaidAllHouse">
	Update ReportLateFeePaidAllHouse
	set dtrowdeleted = getdate()
	,dtrowdeleteduser_ID= #SESSION.UserID#
</cfquery>--->

<CFOUTPUT>
<CFSET rowlist=''>
<CFLOOP INDEX=A LIST='#form.fieldnames#'>
	<CFSCRIPT>
		if (findnocase("row_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
	</CFSCRIPT>
</CFLOOP>
#rowlist# ,findnocase #findnocase("row_",A,1)#, A #A# ,form.fieldnames #form.fieldnames#<BR>


	<CFLOOP INDEX=B LIST='#rowlist#'>
	 <cftransaction>
		<CFLOOP INDEX=C LIST='#form.fieldnames#'>
			<CFIF(gettoken(C,2,"_") eq B)> 
			loop 1  c #C# b #B#, test #form.fieldnames# </br>
				
				<CFIF(gettoken(C,1,"_") eq 'ITenantID')>
					   loop 2  c #C# b #B#, test #form.fieldnames# </br>
					   
					    #isblank(evaluate("itenantID_" & B),'NULL')# </br>
					    #isblank(evaluate("solomonkey_" & B),'NULL')# </br>
					    
					    <cfset tenantID= #isblank(evaluate("itenantID_" & B),'NULL')#>
					    <cfset solomonkey = #isblank(evaluate("solomonkey_" & B),'NULL')#>
						<cfset SLbalance = #isblank(evaluate("Slbalance_" & B),'NULL')#>
						 	  <!---get iInvoiceLatefee_ID--->  
							    <CFQUERY  NAME="GetLateFeeinfoMatch" DATASOURCE="#APPLICATION.DataSource#">
										SELECT  
											*
										FROM 
											TenantLateFee
										WHERE 
											iTenant_id = #tenantID#
										    and dtrowdeleted is null
										    AND (bPaid is null or bPaid = 0)
											AND (bAdjustmentDelete is Null or bAdjustmentDelete = 0)
										
								</CFQUERY>
								<cfdump var="#GetLateFeeinfoMatch#">
										
								<!---get InvoicemasterID--->
								<cfset TIPSPeriod = Year(#Session.Tipsmonth#) & DateFormat(#Session.Tipsmonth#,"mm")>
							    <cfquery  name="getInvoicematerinfo" datasource="#APPLICATION.DataSource#">
									select * from InvoiceMaster
									where cSolomonKey = '#solomonkey#'
									and bMoveInInvoice is null and bMoveOutInvoice is null and bFinalized is null and dtRowDeleted is null
									and cAppliesToAcctPeriod = '#TIPSPeriod#'
								</cfquery>
								<cfdump var="#getInvoicematerinfo#">	
								<cfif getInvoicematerinfo.recordcount eq 0>
								<cfoutput> Please uncheck #solomonkey# and run again </cfoutput>
								</cfif>
								<cfif getInvoicematerinfo.RecordCount GT 1>
									<cfoutput>There are more than one Invoice which are not finalized. The Late fee cannot be tied to more than one invoice at a time. Please contact the IT Support for further Assistance.</cfoutput>
									<cfabort showError = "There are more than one Invoice which are not finalized. The Late fee cannot be tied to more than one invoice at a time. Please contact the IT Support for further Assistance.">
								</cfif>	
								
								
								<cfif getInvoicematerinfo.RecordCount NEQ 0>
								<!--- First update the TenantLateFee for that particular iinvoicelatefee_id as paid --->
								<cfquery name="UpdatePaidlatefee" DATASOURCE = "#APPLICATION.datasource#" result="UpdatePaidlatefee" >
									 Update TenantLateFee
									 set bPaid = 1,
										iRowStartUser_ID = #SESSION.UserID#,
										iRowPaidUser = #SESSION.UserID#,
										dtLateFeePaid = GetDate()
									where 
									     iTenant_id = #tenantID#
									     and dtrowdeleted is null
										 AND (bPaid is null or bPaid = 0)
										 AND (bAdjustmentDelete is Null or bAdjustmentDelete = 0)
										
								</cfquery> 
								<cfdump var="#UpdatePaidlatefee#">
								</cfif>
								
								<cfloop query="GetLateFeeinfoMatch"> 
								<!---loop over the query as there are more late fee record and we want one record ij invoicedetail for each corresponding late fee record--->
								
								<!---Insert new records into invoicedetail table when the charge has been marked as paid --->
								
										<cfif (GetLateFeeinfoMatch.RecordCount NEQ 0) and (getInvoicematerinfo.RecordCount NEQ 0)>
										<cfquery  name="InsertPaidLateFeeinInvoiceDetail" datasource="#APPLICATION.DataSource#" result="InsertPaidLateFeeinInvoiceDetail">
											insert into InvoiceDetail 
														(iInvoiceMaster_ID
														, iTenant_ID
														, iChargeType_ID
														, cAppliesToAcctPeriod
														, dtTransaction
														, iQuantity
														, cDescription
														, mAmount
														, dtRowStart 
														, iRowStartUser_ID
														, bNoInvoiceDisplay	)
											   Values 	( #getInvoicematerinfo.iInvoiceMaster_Id#
									        			 ,#tenantID#
									        			 ,#GetLateFeeinfoMatch.iChargeType_ID#
														 ,#GetLateFeeinfoMatch.cAppliesToAcctPeriod#	
														 , getDate()
														 , 1
														 , 'Late Fee Payment'
														 ,#GetLateFeeinfoMatch.mLateFeeAmount#	
														 , getDate()
														 , #SESSION.UserID#
														 , 1
														)
										</cfquery>  
										<cfdump var="#InsertPaidLateFeeinInvoiceDetail#">
										</cfif>
										
										<!--- Get the Invoicedetail_Id which has been inserted just now in the invoicedetailm table for the late fee --->
										<cfquery name="GetCurrentInvoiceDetailIDForLateFee" datasource="#APPLICATION.DataSource#">
											SELECT  top 1 * 
											FROM InvoiceDetail
											WHERE iInvoiceMaster_Id = #getInvoicematerinfo.iInvoiceMaster_Id#
											and cAppliesToAcctPeriod = #GetLateFeeinfoMatch.cAppliesToAcctPeriod#	
											and iChargeType_ID = #GetLateFeeinfoMatch.iChargeType_ID#
											and iQuantity = 1
											and mAmount = #GetLateFeeinfoMatch.mLateFeeAmount#	
											and cDescription = 'Late Fee Payment'
											and iTenant_Id = #tenantID#
											and dtrowdeleted is null
											order by iinvoicedetail_id desc
										</cfquery>
											<cfdump var="#GetCurrentInvoiceDetailIDForLateFee#">
										
										<!--- update the TenantlateFee with the invoicemaster_Id and invoicedetail_Id --->
										<cfquery name="updateTenantLateFeewithInvoicemasterId" datasource="#APPLICATION.DataSource#" result="updateTenantLateFeewithInvoicemasterId">
											Update TenantLateFee
											 set iInvoiceMaster_Id = #getInvoicematerinfo.iInvoiceMaster_Id#
											   , iInvoiceDetail_ID = #GetCurrentInvoiceDetailIDForLateFee.iInvoiceDetail_ID#
											   ,iInvoiceNumber = '#getInvoicematerinfo.iInvoiceNumber#'
											 where iInvoicelatefee_ID = #GetLateFeeinfoMatch.iinvoicelatefee_id# and bPaid = 1
										</cfquery>
											<cfdump var="#updateTenantLateFeewithInvoicemasterId#">
										
										<!---Table populate for reporting purpose--->
										<cfquery name="PopulateReportLateFeePaidAllHouse" datasource="#APPLICATION.DataSource#" result="PopulateReportLateFeePaidAllHouse">
											INSERT INTO [dbo].[ReportLateFeePaidAllHouse]
											           ([itenant_ID]
											           ,[iInvoicelatefee_ID]
											           ,[ApprovalPeriod]
											           ,[Acctperiod]
													   ,[SLbalance]
											           ,[dtrowstart]
											           ,[dtrowstartuser_ID]
											           )
											     VALUES
											           (#tenantID#
											        	,#GetLateFeeinfoMatch.iinvoicelatefee_id#
											        	,#getInvoicematerinfo.cappliestoacctperiod#
											        	,#GetLateFeeinfoMatch.cAppliesToAcctPeriod#
														,#SLbalance#
											           ,getdate()
											           ,#SESSION.UserID#
											           )
										</cfquery>
										<cfdump var="#PopulateReportLateFeePaidAllHouse#">
									
									</cfloop>		
											
					 </cfif>
						
			</cfif>
         </cfloop>
      
     	 </cftransaction>
			
    </cfloop>
  </cfoutput>
  
  <!--- ==============================================================================
	Relocate the page to original screen
	=============================================================================== --->
<CFLOCATION URL="DisplayLateFeeAllhouses.cfm">
	
  