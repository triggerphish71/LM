<cfcomponent>
	<cffunction name="BackupFiles" access="public" returntype="string" output="true">
		<cfargument name="FiletoCheck" type="string" required="yes">
		<cfargument name="FileDirectory" type="string" required="yes">
		
		<cfset fileBackupDirectory = FileDirectory & "\Backup">
		
		<cfdirectory directory="#fileDirectory#\" action="list" name="qInvoiceDetails" filter="#FiletoCheck#">
		<CFIF qInvoiceDetails.RecordCount GT 0>
			<cffile action="move" destination="#fileBackupDirectory#\" source="#fileDirectory#\#FiletoCheck#">

			<cfset TodaysVersion = dateformat(now(),"MM-DD-YY") & "_v">
			<!--- See how many files exists for todays date only--->
			<cfdirectory directory="#fileBackupDirectory#\" action="list" name="qBackupInvoiceDetails" filter="#TodaysVersion#*#FiletoCheck#">

			<cfset newName = fileBackupDirectory & "\" & dateformat(now(),"MM-DD-YY")& "_v" & (qBackupInvoiceDetails.RecordCount) & FiletoCheck>
			<cffile action="rename" source="#fileBackupDirectory#\#FiletoCheck#" destination="#newName#">
		</CFIF>			
	</cffunction>
</cfcomponent>