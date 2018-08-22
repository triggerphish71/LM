<!----------------------------------------------------------------------------------------------
| DESCRIPTION - This page is created so that it adjustment delete the tenant late fee to the   |
|                invoicedetail table                                                           |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
| Called by: 		MoveOutFormSummary.cfm, 			                    				   |
| Calls/Submits:	                                                                           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|Sathya      | 04/27/2010 | Created this file for Project 20933                                |
|---------------------------------------------------------------------------------------------->

<!--- See if the required variables  exisits if not throw an error --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	 
	 <cfif NOT isDefined("URL.ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Tenant Id not found">
	</cfif>
	 <cfif NOT isDefined("URL.detail")>
	   <!--- throw the error --->
	   <cfthrow message = "Late fee ID not found.">
	</cfif>
	 <cfif NOT isDefined("URL.invoicemaster")>
	   <!--- throw the error --->
	   <cfthrow message = "Invoice Master id not found.">
	</cfif>
	
<cfcatch type = "application">
  <cfoutput>
    <p>#cfcatch.message#</p>
	<br></br>
	<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
 </cfoutput>
	<CFABORT>
</cfcatch>
</cftry>
<!--- 04/26/2010 sathya added this for project 20933 --->
<cfoutput>
the Tenant_Id: #URL.ID#
<br>
invoicedetail_Id: #URL.detail#

<br>invoicemaster_id: #URL.invoicemaster#					

</cfoutput>

	<!--- ==============================================================================
	Retrieve Move Out Invoice Information 
	=============================================================================== --->
	<cfquery name="moveoutinvoice" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	distinct IM.cComments as InvoiceComments, IM.iInvoiceMaster_ID, IM.dtInvoiceEnd, IM.dtInvoiceStart,
					IM.iInvoiceNumber, mLastInvoiceTotal as PastDue, IM.cAppliesToAcctPeriod
			FROM	InvoiceMaster IM
			LEFT OUTER JOIN	InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
			where IM.iInvoiceMaster_Id = #URL.invoicemaster#
			and INV.iTenant_ID = #URL.ID# and bMoveOutInvoice IS NOT NULL and IM.dtRowDeleted IS NULL
			order by im.cappliestoacctperiod desc, im.dtinvoiceend desc
	</cfquery>
	<!--- Check if this invoicemaster_id and Tenant_Id is valid --->
	<cfif moveoutinvoice.RecordCount eq 0>
		<cfabort showError = "The Late fee cannot be tied the invoice at a time. There is no move out invoice to attach the late fee. Please contact the IT Support for further Assistance.">
	</cfif>
	
<cftransaction>
	<cftry>
		<!--- update the adjustmentdelete as its been negotiated, its not an actual delete, --->
		<!---  Adjustment delete means that two record of credit and debit will be created in the invoicedetail table and will be sent over to solomon later--->
		<cfquery name="UpdateDeletelatefee" DATASOURCE = "#APPLICATION.datasource#">
			 Update TenantLateFee
			 set bAdjustmentDelete = 1,
				 iRowEndUser_ID = #SESSION.UserID#,
				 iRowDeleteAdjustmentUser = #SESSION.UserID#,
				 dtLateFeeDelete = GetDate(),
				 cReasonForDelete = 'Late fee Negotiated'
			where 
			    iInvoiceLateFee_Id = #URL.detail#
				and
			    iTenant_id = #URL.ID#
		</cfquery> 
		
		<!--- Get the LateFee information which is adjusted in the before query  for the particular ID --->
		<cfquery name="gettenantlatefeeinfo" DATASOURCE="#APPLICATION.DataSource#" >
			SELECT *
			FROM 
			TenantLateFee
			where iInvoicelatefee_ID = #URL.detail# 
			and iTenant_id = #URL.ID#
			and bAdjustmentDelete = 1
			and dtrowdeleted is null
		</cfquery>
		
	
	<cfif (gettenantlatefeeinfo.RecordCount NEQ 0)>
		<!--- Save the Debit Amount in a variable so that it will be used further --->
		<cfset LateFeeDebit = -gettenantlatefeeinfo.mLateFeeAmount>
		<!--- Insert new records into invoicedetail table as a credit --->
		<cfquery  name="InsertPaidLateFeeinInvoiceDetail" datasource="#APPLICATION.DataSource#">
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
						, bNoInvoiceDisplay)
			Values 		( #URL.invoicemaster#
	        			 ,#URL.ID#
	        			 ,#gettenantlatefeeinfo.iChargeType_ID#
						 ,#gettenantlatefeeinfo.cAppliesToAcctPeriod#	
						 , getDate()
						 , 1
						 , 'Pending Late Fee Payment'
						 ,#gettenantlatefeeinfo.mLateFeeAmount#	
						 , getDate()
						 , #SESSION.UserID#
						 , 1)
			</cfquery>  
				<!--- Get the Invoicedetail_Id which has been inserted just now in the invoicedetailm table for the late fee --->
		<cfquery name="GetCurrentInvoiceDetailIDForLateFee" datasource="#APPLICATION.DataSource#">
			SELECT top 1 * 
			FROM InvoiceDetail
			WHERE iInvoiceMaster_Id = #URL.invoicemaster#
			and cAppliesToAcctPeriod = #gettenantlatefeeinfo.cAppliesToAcctPeriod#	
			and iChargeType_ID = #gettenantlatefeeinfo.iChargeType_ID#
			and iQuantity = 1
			and mAmount = #gettenantlatefeeinfo.mLateFeeAmount#	
			and cDescription = 'Pending Late Fee Payment'
			and iTenant_Id = #URL.ID#
			and dtrowdeleted is null
			order by iinvoicedetail_id desc
		</cfquery>	
		
		<!--- update the existing late fee record in the TenantlateFee with the invoicemaster_Id and invoicedetail_Id --->
		<cfquery name="updateTenantLateFeewithInvoicemasterId" datasource="#APPLICATION.DataSource#">
			Update TenantLateFee
			  set iInvoiceMaster_Id = #URL.invoicemaster#
			    , iInvoiceDetail_ID = #GetCurrentInvoiceDetailIDForLateFee.iInvoiceDetail_ID#
			    ,iInvoiceNumber = '#moveoutinvoice.iInvoiceNumber#'
			where iInvoicelatefee_ID = #URL.detail# 
			and bAdjustmentDelete = 1 
			and iTenant_id = #URL.ID#
		</cfquery>
		<!--- Insert another record for the debit transaction of the late fee in the invoice detail table --->
		<cfquery name="insertdebitinvoicedetail" datasource="#APPLICATION.DataSource#">
			insert into InvoiceDetail 
						(iInvoiceMaster_ID
						, iTenant_ID
						, iChargeType_ID
						, cAppliesToAcctPeriod
						, dtTransaction
						, iQuantity
						, cDescription
						, cComments
						, mAmount
						, dtRowStart 
						, iRowStartUser_ID)
		     VALUES  (	#URL.invoicemaster#
	        			 ,#URL.ID#
	        			 ,#gettenantlatefeeinfo.iChargeType_ID#
						 ,#gettenantlatefeeinfo.cAppliesToAcctPeriod#	
						 , getDate()
						 , 1
						 , 'Pending Late Fee Payment'
						 , 'Late fee Negotiated'
						 ,#LateFeeDebit#	
						 , getDate()
						 , #SESSION.UserID#)
		</cfquery>
		
	</cfif>
	
	
	<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
				 <cfabort showerror="An error has occured when trying to delete the Charge.">
		</cfcatch>
	</cftry>
</cftransaction> 

<!--- <cfoutput>
<a href="MoveOutFormSummary.cfm?ID=#URL.ID#"><p>click here to go back move out form summary.</p></a>
</cfoutput> --->

<!--- Relocate to Move out form summary to get back to the house close --->
 <CFLOCATION URL="MoveOutFormSummary.cfm?ID=#URL.ID#" ADDTOKEN="No">