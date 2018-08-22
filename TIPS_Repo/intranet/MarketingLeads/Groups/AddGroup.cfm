

<CFOUTPUT>
<CFSET DSN='LeadTracking'>
<CFLOOP INDEX=fields LIST="#form.fieldnames#">#fields# == #Evaluate(fields)#<BR></CFLOOP>
<CFTRANSACTION>
	<!--- ==============================================================================
	Insert new Group into Database
	=============================================================================== --->
	<CFQUERY NAME="qAddGroup" DATASOURCE="#DSN#">
		INSERT INTO Groups
			(	iCategory_ID, 
				iHouse_ID, 
				cDescription, 
				cRowStartUser_ID, 
				dtRowStart
			)VALUES(
				#form.iCategory_ID#,
				200,
<!--- ==============================================================================
				#SESSION.qSelectedHouse.iHouse_ID#,
=============================================================================== --->
				'#TRIM(form.cDescription)#',
				'#SESSION.UserName#',
				getdate()
			)
	</CFQUERY>
</CFTRANSACTION>
<CFIF Remote_Addr EQ '10.1.0.201'><A HREF="#HTTP.REFERER#">Continue</A><CFELSE><CFLOCATION URL="#HTTP.REFERER#"></CFIF>
</CFOUTPUT>