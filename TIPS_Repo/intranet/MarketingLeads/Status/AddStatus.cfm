

<CFOUTPUT>
<CFSET DSN='LeadTracking'>

<!--- ==============================================================================
Insert new status record
=============================================================================== --->
<CFQUERY NAME="qInsertStatus" DATASOURCE="#DSN#">
	INSERT INTO Status	( cDescription, cRowStartUser_ID, dtRowStart )VALUES( '#form.cDescription#', '#SESSION.UserName#', GetDate() )
</CFQUERY>

<CFIF Remote_Addr EQ '10.1.0.201'>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#HTTP.REFERER#">
</CFIF>
</CFOUTPUT>
