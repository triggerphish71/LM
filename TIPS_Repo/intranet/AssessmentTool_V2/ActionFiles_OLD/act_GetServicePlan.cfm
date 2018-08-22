<cfparam name="assessmentId" default="0">
<cfscript>
	ServicePlan = CreateObject("Component","Components_OLD.ServicePlan");
	ServicePlan.Init(assessmentId,application.datasource);
	
</cfscript>