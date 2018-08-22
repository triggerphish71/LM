

<CFOUTPUT>
<CFSET DSN='LeadTracking'>
<CFLOOP INDEX=fields LIST="#form.fieldnames#">#fields# == #Evaluate(fields)#<BR></CFLOOP>
<CFTRANSACTION>
	<!--- ==============================================================================
	Insert new Group into Database
	=============================================================================== --->
	<CFQUERY NAME="qEditGroup" DATASOURCE="#DSN#">
		UPDATE	Groups
		SET		cDescription = '#TRIM(form.cDescription)#'
				,iHouse_ID = 200
				,iCategory_ID = #form.iCategory_ID#
				,cRowStartUser_ID = '#SESSION.UserName#'
				,dtRowStart = getdate()
		WHERE	iGroup_ID = #form.iGroup_ID#
	</CFQUERY>
</CFTRANSACTION>
<CFIF Remote_Addr EQ '10.1.0.201'><A HREF="#HTTP.REFERER#">Continue</A><CFELSE><CFLOCATION URL="#HTTP.REFERER#"></CFIF>
</CFOUTPUT>