

<CFTRANSACTION>

	<CFQUERY NAME = "DeleteStateCode" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	TenantStateCodes
		SET		iRowDeletedUser_ID 	= #SESSION.UserID#,
				dtRowDeleted		= GETDATE()
		WHERE	iTenantStateCode_ID = #url.typeID#
	</CFQUERY>
	
</CFTRANSACTION>

<CFLOCATION URL = "TenantStateCodes.cfm">