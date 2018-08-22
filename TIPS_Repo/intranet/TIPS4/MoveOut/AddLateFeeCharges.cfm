<!----------------------------------------------------------------------------------------------
| DESCRIPTION - This page is created so that it adds the tenant late fee to the invoicedetail  |
|                table                                                                         |
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
<cfoutput>
the Tenant_Id: #URL.ID#
<br>
invoicedetail_Id: #URL.detail#
<br>invoicemaster_id: #URL.invoicemaster#
<br>session userid:  #SESSION.UserID#
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
		
	<!--- Get the information if the late fee had a partial payment --->
	<cfquery name="getTenantLateFeeRecords" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * 
				FROM TenantLateFee ltf
				join Tenant t 
				on t.iTenant_id = ltf.iTenant_id
				WHERE t.iTenant_id =#url.ID#
				AND ltf.iInvoiceLateFee_Id = #URL.detail#
				AND ltf.dtrowdeleted is null
				AND t.dtrowdeleted is null
				AND (ltf.bPaid is null or ltf.bPaid = 0)
				AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0)
				
	</cfquery>
	<cfquery name="getPartialPayment" datasource="#APPLICATION.datasource#">
		select   tla.iInvoiceLateFee_ID , sum(mLateFeePartialPayment) as LateFeePayment
		from TenantLateFeeAdjustmentDetail tla
		join invoicedetail ind
		on tla.iinvoicedetail_id = ind.iinvoicedetail_id
		where tla.iInvoiceLateFee_ID in ( SELECT ltf.iInvoiceLateFee_ID 
										FROM TenantLateFee ltf
										join Tenant t 
										on t.iTenant_id = ltf.iTenant_id
										WHERE t.iTenant_id =#url.ID#
										AND ltf.dtrowdeleted is null
										AND t.dtrowdeleted is null
										AND (ltf.bPaid is null or ltf.bPaid = 0)
										AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0))
		and tla.dtrowdeleted is null
		and ind.dtrowdeleted is null
		Group by  iInvoiceLateFee_ID
	</cfquery>
	
	<!--- If the URL is passing no amount information then that means there was no partial payment at all --->
	<cfif getTenantLateFeeRecords.bPartialPaid eq 1>
		<cfquery name="getPaidLateFeeAmount" dbtype="query">
			Select LateFeePayment from getPartialPayment where iInvoiceLateFee_ID = #getTenantLateFeeRecords.iInvoiceLateFee_ID#
		</cfquery>
		<cfif getPaidLateFeeAmount.recordcount gt 0>
			<cfif NOT isDefined("URL.invoicepartialamount")>
		 		<cfoutput>
				The remaining balance late fee not found to update in the invoice.	  
					  	<br></br>
						<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
				 </cfoutput>
				 <cfabort showerror="An error has occured when trying to Add the Charge.">
			</cfif>
		</cfif>
	</cfif>
	
	
	<!---Update the tenantlatefee record as paid when the charge is added to invoicedetail table  --->
	<cfquery name="UpdatePaidlatefee" DATASOURCE = "#APPLICATION.datasource#">
					 Update TenantLateFee
					 set bPaid = 1,
						iRowStartUser_ID = #SESSION.UserID#,
						iRowPaidUser = #SESSION.UserID#,
						dtLateFeePaid = GetDate()
					where   iInvoiceLateFee_Id = #URL.detail#
					and  iTenant_id = #URL.ID#
	</cfquery> 
	
	
	
	<!--- Get the LateFee information which is paid for the particular ID --->
		<cfquery name="gettenantlatefeeinfo" DATASOURCE="#APPLICATION.DataSource#" >
			SELECT *
			FROM 
			TenantLateFee
			where iInvoicelatefee_ID = #URL.detail# 
			and iTenant_id = #URL.ID#
			  and bPaid = 1
			  and dtrowdeleted is null
		</cfquery>
		
		
	
	
<!--- Insert new records into invoicedetail table when the charge has been marked as paid --->
<cfif (gettenantlatefeeinfo.RecordCount NEQ 0)>
<!--- Handle for partial payments --->
	<cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount gt 0)>
			<!--- If the late fee has a partial payment before then the remaining balance needs to be updated in the invoicedetail table --->
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
							 , 'Partial Payment for Late Fee'
							 ,#URL.invoicepartialamount#	
							 , getDate()
							 , #SESSION.UserID#
							 , 1)
			</cfquery>  
			
			<!--- Get the Invoicedetail_Id which has been inserted just now in the invoicedetailm table for the late fee --->
		<cfquery name="GetCurrentInvoiceDetailIDForLateFee" datasource="#APPLICATION.DataSource#">
			SELECT  top 1 * 
			FROM InvoiceDetail
			WHERE iInvoiceMaster_Id = #URL.invoicemaster#
			and cAppliesToAcctPeriod = #gettenantlatefeeinfo.cAppliesToAcctPeriod#	
			and iChargeType_ID = #gettenantlatefeeinfo.iChargeType_ID#
			and iQuantity = 1
			and mAmount = #URL.invoicepartialamount#
			and cDescription = 'Partial Payment for Late Fee'
			and iTenant_Id = #URL.ID#
			and dtrowdeleted is null
			order by iinvoicedetail_id desc
		</cfquery>
			<!--- insert a new record for the partial payment in the TenantLateFeeAdjustmentDetail table --->
		<cfquery name="insertPartialPayment" DATASOURCE = "#APPLICATION.datasource#">
		insert into TenantLateFeeAdjustmentDetail
             (
				iInvoiceLateFee_ID,
				cSolomonKey,
				iTenant_id,
				cFirstName,
				cLastName,
				mActualLateFee,
				mLateFeePartialPayment,
				bPaid,
				iInvoiceNumber,
				iInvoiceMaster_ID,
				iInvoiceDetail_ID,
				cAppliesToAcctPeriod,
				iChargeType_ID,
				cGLAccount,
				iHouse_ID,
				cHouseName,
				iRegion_id,
				cDivision,
				iOpsArea_ID,
				cRegion,
				dtLateFeeStart,
				dtLateFeePaid,
				iRowStartUser_ID,
				dtRowStart
				 )
		Values 	( 
		          #URL.detail# 
				  ,'#gettenantlatefeeinfo.cSolomonKey#'
				  ,#URL.ID#
				  ,'#gettenantlatefeeinfo.cFirstName#'
				  ,'#gettenantlatefeeinfo.cLastName#'
				  ,#gettenantlatefeeinfo.mLateFeeAmount#
				  ,#URL.invoicepartialamount#
				  , 1
				  ,'#moveoutinvoice.iInvoiceNumber#'
				  ,#URL.invoicemaster#
				  ,#GetCurrentInvoiceDetailIDForLateFee.iInvoiceDetail_ID#
				  ,'#gettenantlatefeeinfo.cAppliesToAcctPeriod#'
				  ,#gettenantlatefeeinfo.iChargeType_ID#
				  ,'#gettenantlatefeeinfo.cGLAccount#'
				  ,#gettenantlatefeeinfo.iHouse_ID#
				  ,'#gettenantlatefeeinfo.cHouseName#'
				  ,#gettenantlatefeeinfo.iRegion_id#
				  ,'#gettenantlatefeeinfo.cDivision#'
				  ,#gettenantlatefeeinfo.iOpsArea_ID#
				  ,'#gettenantlatefeeinfo.cRegion#'
				  ,getDate()
				  ,getDate()
				  ,#SESSION.UserID#
				  ,getdate()
			  )
		</cfquery>	
				
				
		<!--- update the TenantlateFee with the invoicemaster_Id and invoicedetail_Id --->
		<cfquery name="updateTenantLateFeewithInvoicemasterId" datasource="#APPLICATION.DataSource#">
			Update TenantLateFee
			 set iInvoiceMaster_Id = #URL.invoicemaster#
			    , iInvoiceDetail_ID = #GetCurrentInvoiceDetailIDForLateFee.iInvoiceDetail_ID#
			    ,iInvoiceNumber = '#moveoutinvoice.iInvoiceNumber#'
			where iInvoicelatefee_ID = #URL.detail# and bPaid = 1 and iTenant_id = #URL.ID#
		</cfquery>

	<cfelse>
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
							 , 'Late Fee Payment'
							 ,#gettenantlatefeeinfo.mLateFeeAmount#	
							 , getDate()
							 , #SESSION.UserID#
							 , 1)
			</cfquery>  
			
			<!--- Get the Invoicedetail_Id which has been inserted just now in the invoicedetailm table for the late fee --->
		<cfquery name="GetCurrentInvoiceDetailIDForLateFee2" datasource="#APPLICATION.DataSource#">
			SELECT  top 1 * 
			FROM InvoiceDetail
			WHERE iInvoiceMaster_Id = #URL.invoicemaster#
			and cAppliesToAcctPeriod = #gettenantlatefeeinfo.cAppliesToAcctPeriod#	
			and iChargeType_ID = #gettenantlatefeeinfo.iChargeType_ID#
			and iQuantity = 1
			and mAmount = #gettenantlatefeeinfo.mLateFeeAmount#	
			and cDescription = 'Late Fee Payment'
			and iTenant_Id = #URL.ID#
			and dtrowdeleted is null
			order by iinvoicedetail_id desc
		</cfquery>
				
		<!--- update the TenantlateFee with the invoicemaster_Id and invoicedetail_Id --->
		<cfquery name="updateTenantLateFeewithInvoicemasterId" datasource="#APPLICATION.DataSource#">
			Update TenantLateFee
			 set iInvoiceMaster_Id = #URL.invoicemaster#
			    , iInvoiceDetail_ID = #GetCurrentInvoiceDetailIDForLateFee2.iInvoiceDetail_ID#
			    ,iInvoiceNumber = '#moveoutinvoice.iInvoiceNumber#'
			where iInvoicelatefee_ID = #URL.detail# and bPaid = 1 and iTenant_id = #URL.ID#
		</cfquery>
		</cfif>
	</cfif>
	
	
	
	<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
				 <cfabort showerror="An error has occured when trying to Add the Charge.">
		</cfcatch>
	</cftry>
</cftransaction> 
<!--- <cfoutput>
<a href="MoveOutFormSummary.cfm?ID=#URL.ID#"><p>click here to go back move out form summary.</p></a>
</cfoutput> --->

<!--- Relocate to Move out form summary to get back to the house close --->
 <CFLOCATION URL="MoveOutFormSummary.cfm?ID=#URL.ID#" ADDTOKEN="No">

<!--- 04/26/2010 sathya added this for project 20933 --->
<!--- <cfoutput>
the Tenant_Id: #URL.ID#
<br>
invoicedetail_Id: #URL.detail#
<br>invoicemaster_id: #URL.invoicemaster#
</cfoutput> --->
	
