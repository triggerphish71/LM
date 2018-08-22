<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInvoiceFinalize.cfm                                |
|----------------------------------------------------------------------------------------------|
| Finalize Invoice for a Respite Resident                                        |
| Called by: 		RespiteInvoice.cfm						  	                                   |
| Calls/Submits:	                                              |
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
|R Schuette  | 07/02/2010 | Prj 25575 - Original Authorship                                    |
|Sfarmer     | 07/14/2014 | added "rw." to sp_exportInv2solomon                                |
|M Striegel  | 11/10/2017 | added autorelese=0 and converted to calling component add with     |
|                           nolocks                                                            |
| mstriegel  | 04/25/2018 | Replaced session.qSelectedHouse.iHouse_id with tenant.iHouse_id    |
----------------------------------------------------------------------------------------------->
<!--- code from MO form and other places for use if MANUAL FINALIZATION is to be done. --->


<CFTRANSACTION>
	<!--- ==============================================================================
Retrieve the INVOICE Information 
=============================================================================== --->
<CFQUERY NAME="Invoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT cSolomonKey, dtInvoiceEnd, iInvoiceMaster_ID, iInvoiceNumber
	FROM InvoiceMaster IM WITH (NOLOCK)
	WHERE IM.iInvoiceMaster_ID = #url.INVMSTRID#
</CFQUERY>
<cfset SolID = Invoice.cSolomonKey>
<!--- ==============================================================================
Retrieve the Tenants Information - if needed
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT t.iTenant_ID ,t.iHouse_id
	FROM Tenant T WITH (NOLOCK)
	JOIN TenantState TS WITH (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID and ts.dtRowDeleted is null
	WHERE T.cSolomonKey = #Invoice.cSolomonKey#
</CFQUERY>
<!--- Update tenant pojected MO date to new finalized invoice end date --->
<CFQUERY Name="UpdatePMODate" DAtasource="#APPLICATION.datasource#">
	Update Tenantstate
	set dtMoveOutProjectedDate = (select convert(varchar(10),'#Invoice.dtInvoiceEnd#',110))
	where Tenantstate.iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Retrieve the total of transactions for the moveout invoice
=============================================================================== --->
<CFQUERY NAME="Total" DATASOURCE="#APPLICATION.datasource#">
	SELECT	isnull(SUM(mAmount * iQuantity),0.00) as Total
	FROM	InvoiceDetail WITH (NOLOCK)
	WHERE	dtRowDeleted IS NULL
	AND		iInvoiceMaster_ID = #Invoice.iInvoiceMaster_ID#
	AND		iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<cfset INVTotal = Total.Total>
<!--- ==============================================================================
Update the Invoice Master Record as Finalized Ended
=============================================================================== --->
<CFQUERY NAME="FinalizeRespiteInvoice" DATASOURCE="#APPLICATION.datasource#">
	UPDATE	InvoiceMaster
	SET		bFinalized = 1,
			mInvoiceTotal = #INVTotal#,
			dtAcctStamp = '#SESSION.AcctStamp#',
			dtRowStart = GetDate(),
			iRowStartUser_ID = #SESSION.USERID#
	WHERE	iInvoiceMaster_ID = #Invoice.iInvoiceMaster_ID#
	AND		dtRowDeleted IS NULL
</CFQUERY>

</CFTRANSACTION>

<CFIF SESSION.qSelectedHouse.ihouse_id NEQ 200>
<!--- ==============================================================================
Generate MoveIn Solomon Batch
=============================================================================== --->
<!--- mstriegel:01/18/2018 --->
<!--- mstriegel:04/25/2018 --->
<cfset argsCollection = {iHouseID=#trim(Tenant.iHouse_ID)#,period="",invoice=#trim(invoice.iInvoiceNumber)#,batchType="Respite",tenantID=Tenant.iTenant_ID}>
<!--- end mstriegel 04/25/2018 --->
<cfset qAutoImport =session.oExport2Solomon.sp_ExportInv2Solomon(argumentCollection=argsCollection)> 
<!---
<CFTRY>	
<!---	<cfoutput>
	HouseID: #trim(SESSION.qSelectedHouse.ihouse_id)#</br>
	NULL</br>
	InvoiceNumber: #trim(Invoice.iInvoiceNumber)#
	</cfoutput>--->
<CFQUERY NAME='qAutoImport' DATASOURCE='#APPLICATION.datasource#'>
	Declare @Status int 
	exec rw.sp_ExportInv2Solomon  #trim(SESSION.qSelectedHouse.ihouse_id)#, NULL, '#trim(Invoice.iInvoiceNumber)#', @Status OUTPUT
	Select @Status
</CFQUERY>
<CFCATCH type="Any">
	<CFSCRIPT>
		message='';
		if (IsDefined("cfcatch.message") and trim(cfcatch.message) NEQ '') { message = message & "catch_message = #cfcatch.message#<BR>"; }
		if (IsDefined("cfcatch.detail") and trim(cfcatch.detail) NEQ '') { message = message & "<BR>catch_detail = #cfcatch.detail#<BR>"; }
		if (IsDefined("Error.Diagnostics") and trim(Error.Diagnostics) NEQ '') { message = message & "<BR>error_diagnostics = #Error.Diagnostics#<BR>"; }
		if (isDefined("cfcatch.queryError") and trim(cfcatch.queryError) NEQ '') { message = message & "<BR>cfcatch_queryerror = #cfcatch.queryError#<BR>"; }
	</CFSCRIPT>
	<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="CFDevelopers@alcco.com" SUBJECT="Respite Invoice To Solomon Fail"> #message# </CFMAIL>
	</CFCATCH>
</CFTRY> 
--->
<!--- end mstriegel:01/18/2018 --->
</CFIF>

<cfoutput>
<form name="return2page" action="RespiteInvoice.cfm?SolID=#SolID#" method="POST" >
<!--- use javascript to submit and post form back to getdetailspage --->
<script type='text/javascript'>document.return2page.submit();</script>
</form>  
</cfoutput>
