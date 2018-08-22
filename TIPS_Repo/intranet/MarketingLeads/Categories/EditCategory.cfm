

<CFOUTPUT>
<CFSET DSN='LeadTracking'>

<!--- ==============================================================================
Insert new status record
=============================================================================== --->
<CFQUERY NAME="qCategory" DATASOURCE="#DSN#">
	UPDATE	Categories
	SET		cDescription = '#form.cDescription#',
			cRowStartUser_ID = '#SESSION.UserName#',
			dtRowStart = getdate()
	WHERE	iCategory_ID = #form.iCategory_ID#
</CFQUERY>

<CFIF Remote_Addr EQ '10.1.0.201'>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#HTTP.REFERER#">
</CFIF>
</CFOUTPUT>
