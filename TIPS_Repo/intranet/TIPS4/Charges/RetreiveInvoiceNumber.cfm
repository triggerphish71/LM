

<!--- ==============================================================================
Retreive TimeStamp
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- ==============================================================================
Check for a usable Invoice
=============================================================================== --->
<!--- 25575 - Respite - RTS - 6/2/10 - Added tenantstate --->
<CFQUERY NAME = "TenantInfo" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	t.*
			,ts.iResidencyType_ID
	FROM	Tenant t
	Join	TenantState ts on (ts.iTenant_ID = t.iTenant_ID) 
	WHERE	t.iTenant_ID = #url.ID#
</CFQUERY>
<!--- end 25575 --->

<CFTRANSACTION>
<!--- 25575 - Respite - RTS - 6/2/10 - Need a new query for respites to get the latest invoicenumber --->
<cfif TenantInfo.iResidencyType_ID eq 3>
	<CFQUERY NAME = "InvoiceCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	max(IM.iInvoiceMaster_ID)
		FROM	INVOICEMASTER IM
		JOIN	Tenant T ON (T.cSolomonKey = IM.cSolomonKey AND IM.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #url.ID# 
		AND		IM.bMoveInInvoice 	IS NULL
		AND		IM.bFinalized 		IS NULL
		AND		IM.dtRowDeleted 	is null
	</CFQUERY>
<cfelse>
	<CFQUERY NAME = "InvoiceCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*
		FROM	INVOICEMASTER IM
		JOIN	Tenant T ON (T.cSolomonKey = IM.cSolomonKey AND IM.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #url.ID# 
		AND		bMoveInInvoice 	IS NULL
		AND		bFinalized 		IS NULL
	</CFQUERY>
</cfif>
<!--- end 25575 --->
<CFIF InvoiceCheck.RecordCount IS 0 AND TenantInfo.iResidencyType_ID neq 3>

	<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	iNextInvoice
		FROM	HouseNumberControl
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<CFSET InvoiceNumber = SESSION.HouseNumber & GetNextInvoice.iNextInvoice>
	
	<CFQUERY NAME = "NewInvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO InvoiceMaster
		(	iInvoiceNumber
			,cSolomonKey
			,bMoveInInvoice
			,bMoveOutInvoice
			,bFinalized
			,cAppliesToAcctPeriod
			,cComments
			,dtAcctStamp
			,dtInvoiceStart
			,iRowStartUser_ID
			,dtRowStart
		)VALUES(
			'#Variables.InvoiceNumber#',
			'#TenantInfo.cSolomonKey#', 
			NULL,
			NULL,
			NULL,
			#DateFormat(SESSION.TIPSMonth,"yyyymm")#,
			NULL,
			#CreateODBCDateTime(SESSION.AcctStamp)#,
			#TimeStamp#,
			#SESSION.UserID#,
			#TimeStamp#
		)
	</CFQUERY>
	
	<CFSET NextInvoice = GetNextInvoice.iNextInvoice + 1>
	
	<CFQUERY NAME = "UpdateHouseControlNumber" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextInvoice = #Variables.NextInvoice#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>	
</CFIF>

</CFTRANSACTION>