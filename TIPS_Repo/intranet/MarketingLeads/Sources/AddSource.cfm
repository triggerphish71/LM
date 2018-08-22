
<CFOUTPUT>
	<CFSET DSN='LeadTracking'>
	<CFLOOP INDEX="fields" LIST="#form.fieldnames#">#fields# == #Evaluate(fields)#<BR></CFLOOP>
	
	<CFQUERY NAME="qInsert" DATASOURCE="#DSN#">
		INSERT INTO Sources
			(	iGroup_ID
				,cDescription
				,cRowStartUser_ID
				,dtRowStart
			)VALUES(
				#form.iGroup_ID# 
				,'#TRIM(form.cDescription)#'
				,'#TRIM(SESSION.userName)#'
				,getdate()
			)
	</CFQUERY>
</CFOUTPUT>