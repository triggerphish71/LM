<cfscript>
	AssessmentTool = CreateObject("Component","Components.AssessmentTool");
	AssessmentToolArray = AssessmentTool.GetAllTools(application.datasource);
</cfscript>  