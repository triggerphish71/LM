<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to update when the Pursue Late fee is Clicked in the            |
|                  MoveOutFormSummary.cfm                                                      |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
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
| Sathya  	 |08/11/10    | Created this page as part of project 20933-Part C Late Fees        |
|                         | In Development 1699 chargetype is hardcoded for the pursue late fee|
|                         | purpose. check in Production and replace the 1699 ChargeType_ID    |
|                         |                                                                    |
----------------------------------------------------------------------------------------------->


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
	<cfif not isDefined("URL.invoiceamount")>
		<cfthrow message = "Pursue amount not found.">
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
		
		<!--- Update as Pursue and create a record in the invoicedetail table and will be sent over to solomon later upon account close--->
		<cfquery name="UpdatePursuelatefee" DATASOURCE = "#APPLICATION.datasource#">
			 Update TenantLateFee
			 set bPursueLateFee = 1
				 ,iRowEndUser_ID = #SESSION.UserID#
				 ,mPursuedAmount = #URL.invoiceamount#
			where 
			    iInvoiceLateFee_Id = #URL.detail#
				and
			    iTenant_id = #URL.ID#
		</cfquery> 
		<!--- Get the LateFee information which is adjusted in the before query  for the particular ID --->
		<cfquery name="gettenantlatefeeinfo" DATASOURCE="#APPLICATION.DataSource#" >
			SELECT cAppliesToAcctPeriod
			FROM 
			TenantLateFee
			where iInvoicelatefee_ID = #URL.detail# 
			and iTenant_id = #URL.ID#
			and dtrowdeleted is null
		</cfquery>
		<!--- Pursue Credit Amount to be inserted in the invoicedetail table--->
		<cfset LateFeeCredit = URL.invoiceamount>
		<!--- insert the amount in the invoicedetail table --->
		<cfquery  name="GetChargeTypeID" datasource="#APPLICATION.DataSource#">
			select ichargeType_ID from TIPS4.dbo.Chargetype
			where cdescription = 'Allowance for Late Fee Recovery'
		</cfquery>

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
	        			 ,#GetChargeTypeID.ichargeType_ID#
						 ,'#gettenantlatefeeinfo.cAppliesToAcctPeriod#'	
						 , getDate()
						 , 1
						 , 'Allowance for Late Fee Recovery'
						 ,#LateFeeCredit#	
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
			and iChargeType_ID = #GetChargeTypeID.ichargeType_ID#
			and iQuantity = 1
			and mAmount = #LateFeeCredit#
			and cDescription = 'Allowance for Late Fee Recovery'
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
			and bPursueLateFee = 1 
			and iTenant_id = #URL.ID#
		</cfquery>
	
	<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
				 <cfabort showerror="An error has occured when trying to Pursue the Charge.">
		</cfcatch>
	</cftry>
</cftransaction> 

<!--- Relocate to Move out form summary  --->
 <CFLOCATION URL="MoveOutFormSummary.cfm?ID=#URL.ID#" ADDTOKEN="No">
