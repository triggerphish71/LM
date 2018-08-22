<cfoutput>
<cfscript>	
	Assessment.Activate(DateFormat(session.tipsmonth,"mm/dd/yyyy"),url.billingActiveDate,session.userId,session.username,'Solomon-Houses',session.leadtrackdsn);
</cfscript>

<cfset theUrl = "http://#cgi.SERVER_NAME#/intranet/tips4/Charges/ChargesDetail.cfm?ID=#Assessment.GetTenant().GetId()#" & "##@start">
<cfset printUrl = "http://#cgi.SERVER_NAME#/intranet/AssessmentTool_V2/index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#">
<script language="javascript">
	window.open('#theUrl#','_self');
	window.open('#printUrl#','_blank');
</script>
</cfoutput>