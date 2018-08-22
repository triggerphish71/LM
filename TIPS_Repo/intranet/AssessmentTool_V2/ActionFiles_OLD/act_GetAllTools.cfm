<cfscript>
	AssessmentTool = CreateObject("Component","Components_OLD.AssessmentTool");
	AssessmentToolArray = AssessmentTool.GetAllTools(application.datasource);
</cfscript>