

<CFOUTPUT>
<CFSET DSN='LeadTracking'>

<CFQUERY NAME="qDeleteGroup" DATASOURCE="#DSN#">
	UPDATE	Groups
	SET		cRowDeletedUser_ID = '#SESSION.UserName#'
			,dtRowDeleted = getdate()
	WHERE	iGroup_ID = #url.id#
</CFQUERY>

</CFOUTPUT>

<CFIF Remote_Addr EQ '10.1.0.201'><A HREF="Groups.cfm">Continue</A><CFELSE><CFLOCATION URL="Groups.cfm"></CFIF>