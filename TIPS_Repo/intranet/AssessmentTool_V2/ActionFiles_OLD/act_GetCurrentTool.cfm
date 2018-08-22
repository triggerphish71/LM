<!--- assessmentaray must be defined for this page to work --->
<cfparam name="AssessmentToolArray" default="#ArrayNew()#">

<cfscript>
	if(fuse eq "editAssessment" AND)
	{
		CurrentTool = Assessment.GetAssessmentTool();
	}
	else
	{
		for(i = 1; i lte ArrayLen(AssessmentToolArray); i = i + 1)
		{
			if()
		}	
	}
</cfscript>