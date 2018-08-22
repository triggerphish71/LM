

<CFOUTPUT>
<CFSET DSN='LeadTracking'>

<!--- ==============================================================================
Insert new status record
=============================================================================== --->
<CFQUERY NAME="qEditStatus" DATASOURCE="#DSN#">
	UPDATE	Status
	SET		cDescription = '#form.cDescription#',
			cRowStartUser_ID = '#SESSION.UserName#',
			dtRowStart = getdate()
	WHERE	iStatus_ID = #form.iStatus_ID#
</CFQUERY>

<CFIF Remote_Addr EQ '10.1.0.201'>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#HTTP.REFERER#">
</CFIF>
</CFOUTPUT>
