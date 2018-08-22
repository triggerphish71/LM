


<CFTRANSACTION>
	<!--- ==============================================================================
	Flag chosen OPS Area as Deleted
	=============================================================================== --->
	<CFQUERY NAME = "DeleteOPSArea" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	OPSAREA
		SET		iRowDeletedUser_ID	= #SESSION.UserID#,
				dtRowDeleted		= GETDATE()
		WHERE	iOpsArea_ID			= #url.typeID#
	</CFQUERY>
</CFTRANSACTION>


<CFLOCATION URL="OPSAreas.cfm" ADDTOKEN="No">
