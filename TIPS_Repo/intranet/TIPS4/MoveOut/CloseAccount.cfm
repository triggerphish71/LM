<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/CloseAccount.cfm                                                       |
|----------------------------------------------------------------------------------------------|
| 													                                           |
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
| mlaw       | 08/07/2006 | Create an initial CloseAccount page                  	           |
|MLAW		 | 10/12/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
|MStriegel   | 11/08/2017 | autorelease=1 convert to use component added with nolock           |
|MStriegel   | 04/25/2018 | Replaced Session.qSelectedHouse.IhouseID and url.id with db results|
----------------------------------------------------------------------------------------------->

<!--- 08/04/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<CFTRANSACTION>
<!--- ==============================================================================
Retrieve the Tenants Information
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT * 
	FROM Tenant T WITH (NOLOCK)
	JOIN TenantState TS WITH (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID and ts.dtRowDeleted is null
	WHERE T.iTenant_ID = #url.ID#
</CFQUERY>
<!--- mstriegel 04/25/2018 --->
<!--- ==============================================================================
Retrieve InvoiceMaster ID For the Move out Invoice
=============================================================================== --->
<CFQUERY NAME="MoveOutInvoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	InvoiceMaster IM WITH (NOLOCK)
	JOIN	InvoiceDetail INV WITH (NOLOCK)	ON	(IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
	WHERE	INV.iTenant_ID = #Tenant.iTenant_ID#
	AND		IM.bMoveOutInvoice IS NOT NULL AND IM.dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve the total of transactions for the moveout invoice
=============================================================================== --->
<CFQUERY NAME="MoveOutTotal" DATASOURCE="#APPLICATION.datasource#">
	SELECT	SUM(mAmount * iQuantity) as Total
	FROM	InvoiceDetail WITH (NOLOCK)
	WHERE	dtRowDeleted IS NULL
	AND		iInvoiceMaster_ID = #MoveOutInvoice.iInvoiceMaster_ID#
	AND		iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Update the Invoice Master Record as Finalized Ended
=============================================================================== --->
<CFQUERY NAME="MoveOutFinal" DATASOURCE="#APPLICATION.datasource#">
	UPDATE	InvoiceMaster
	SET		bFinalized = 1,
			mInvoiceTotal = #MoveOutTotal.Total#,
			dtAcctStamp = '#SESSION.AcctStamp#',
			dtInvoiceEnd = GetDate(),
			dtRowStart = GetDate(),
			iRowStartUser_ID = #SESSION.USERID#
	WHERE	iInvoiceMaster_ID = #MoveOutInvoice.iInvoiceMaster_ID#
	AND		dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Update the Tenant State to AcctClosed Status
=============================================================================== --->
<CFQUERY NAME = "AcctClosed" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		iTenantStateCode_ID = 4, iRowStartUser_ID = #SESSION.UserID#, dtRowStart = getDate()
	WHERE	iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Write Activity in the ActivityLog
=============================================================================== --->
<CFQUERY NAME="RecordActivity" DATASOURCE="#APPLICATION.datasource#">
	INSERT INTO ActivityLog
		( iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints, dtAcctStamp, iRowStartUser_ID, dtRowStart )
		VALUES
		( 5, #CreateODBCDateTime(Tenant.dtChargeThrough)#, #Tenant.iTenant_ID#, #Tenant.iHouse_ID#, #Tenant.iAptAddress_ID#,
			#Tenant.iSPoints#, '#SESSION.AcctStamp#', #SESSION.UserID#, getDate()
		)
</CFQUERY>

<!--- ==============================================================================
Write Activity in the ActivityLog
=============================================================================== --->
<CFQUERY NAME="qDeleteMonthlyDetails" DATASOURCE="#APPLICATION.datasource#">
	update invoicedetail
	set dtrowdeleted=getdate(),irowdeleteduser_id='3025',crowdeleteduser_id='sys_acctclose'
	from invoicedetail inv WITH (NOLOCK)
	join invoicemaster im WITH (NOLOCK) on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.cappliestoacctperiod >= '#MoveOutInvoice.cAppliesToAcctPeriod#'
	and im.dtrowdeleted is null and im.bfinalized is null
	where inv.itenant_id = #Tenant.iTenant_ID#
	and inv.iinvoicemaster_id <> #MoveOutInvoice.iInvoiceMaster_ID#
</CFQUERY>

</CFTRANSACTION>

<CFIF Tenant.ihouse_id NEQ 200>
	<!--- ==============================================================================
	Generate MoveIn Solomon Batch
	=============================================================================== --->
	<cfset argsCollection = {iHouseID=#trim(tenant.iHouse_id)#,period="",invoice=#trim(moveOutInvoice.iInvoiceNumber)#,batchType="Moveout",tenantID=#tenant.iTenant_id#}>
	<cfset qAutoImport = session.oExport2Solomon.sp_ExportInv2Solomon(argumentCollection=argsCollection)>
</CFIF>
<!--- ==============================================================================
Relocate page to Main menu
=============================================================================== --->
<CFIF SESSION.USERID IS 3025 AND 1 EQ 0>
	<CFIF ShowBtn>
		<A HREF = "../MainMenu.cfm">CONTINUE...</A> <CFABORT>
	<CFELSE>
		<A HREF = "../census/FinalizeMoveOut.cfm">CONTINUE...</A> <CFABORT>
	</CFIF>
<CFELSE>
	<CFIF ShowBtn>
		<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="../census/FinalizeMoveOut.cfm?TenantID=#Tenant.itenant_ID#" ADDTOKEN="No">
	</CFIF>
</CFIF>
