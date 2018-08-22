<!---   -------------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking          |
| gthota   | 1/10/2014  |Proj. 112995 Added new printassessment code for 2012 assessment report     |
---------------------------------------------------------------------------------------------------->

<cfoutput>
<cfscript>	
//	Assessment.Activate(DateFormat(session.tipsmonth,"mm/dd/yyyy"),url.billingActiveDate,session.userId,session.username,'Solomon-Houses',session.leadtrackdsn);
	Assessment.Activate(DateFormat(session.tipsmonth,"mm/dd/yyyy"),url.billingActiveDate,session.userId,session.username,'Solomon-Houses');

</cfscript>

<cfset theUrl = "http://#cgi.SERVER_NAME#/intranet/tips4/Charges/ChargesDetail.cfm?ID=#Assessment.GetTenant().GetId()#" & "##@start">
<cfset printUrl = "http://#cgi.SERVER_NAME#/intranet/AssessmentTool_V2/index.cfm?fuse=printAssessmentnew&assessmentId=#assessment.GetId()#">
<script language="javascript">
	window.open('#theUrl#','_blank');
	window.open('#printUrl#','_blank');
</script>
</cfoutput>