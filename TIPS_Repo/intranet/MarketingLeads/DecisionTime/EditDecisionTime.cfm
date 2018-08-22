

<CFOUTPUT>
<CFSET DSN='LeadTracking'>

<!--- ==============================================================================
Insert new status record
=============================================================================== --->
<CFQUERY NAME="qEditDecisionTime" DATASOURCE="#DSN#">
	UPDATE	DecisionTime
	SET		cDescription = '#form.cDescription#',
			cRowStartUser_ID = '#SESSION.UserName#',
			dtRowStart = getdate()
	WHERE	iDecisionTime_ID = #form.iDecisionTime_ID#
</CFQUERY>

<CFIF Remote_Addr EQ '10.1.0.201'>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#HTTP.REFERER#">
</CFIF>
</CFOUTPUT>
