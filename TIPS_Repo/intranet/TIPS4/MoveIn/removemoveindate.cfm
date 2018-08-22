
<CFOUTPUT>

<CFTRANSACTION>
<CFQUERY NAME="qRemoveMIDate" DATASOURCE="#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		dtMoveIn = NULL	,dtRentEffective=NULL ,dtRowStart = getdate() ,iRowStartUser_ID = #SESSION.USERID#
	WHERE	iTenant_ID = #ID#
</CFQUERY>
</CFTRANSACTION>
<BR>
<CFIF IsDefined("AUTH_USER") AND Auth_user EQ "ALC\Paulb">
	<A HREF="../Registration/Registration.cfm">Continue</A>
<CFELSE>
	<CFLOCATION URL="../Registration/Registration.cfm">
</CFIF>
</CFOUTPUT>