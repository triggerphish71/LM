<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfset SurveyValid = true>
<cftry>
	<cfif isDefined("session.username")>
		<cfquery name="adQueryResult2" datasource="Survey">
			EXECUTE sel_Access 'SLingo';
		</cfquery>	
	<cfelse>
		<cfset SurveyValid = false>
	</cfif>
<cfcatch>
	<cfset SurveyValid = false>
</cfcatch>
</cftry>
		<cfoutput>
		<cfdump var="#adQueryResult2#" label="adQueryResult2">
	SurveyValid:: #SurveyValid#	
		</cfoutput>
<body>
</body>
</html>
