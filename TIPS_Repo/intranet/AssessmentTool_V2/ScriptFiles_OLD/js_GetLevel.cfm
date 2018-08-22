<cfoutput>
<script language="javascript">
	//first create an array to hold the differnet assessment tools
	var AllLevelsForTool = new Array(#Arraylen(AssessmentToolArray)#);
	
	<!--- loop through the assessment tools --->
	<cfloop from="1" to="#Arraylen(AssessmentToolArray)#" index="i">
		<cfset LevelArray = AssessmentToolArray[i].GetLevelTypesAsStruct()>
		AllLevelsForTool[#i - 1#] = new Array(#ArrayLen(LevelArray)#);
		<cfloop from="1" to="#ArrayLen(LevelArray)#" index="x">
			AllLevelsForTool[#i - 1#][#x - 1#] = new Array(5);
			AllLevelsForTool[#i - 1#][#x - 1#][0] = '#LevelArray[x].assessmentTool#';
			AllLevelsForTool[#i - 1#][#x - 1#][1] = '#LevelArray[x].LevelType#';
			AllLevelsForTool[#i - 1#][#x - 1#][2] = #LevelArray[x].pointsMin#;
			AllLevelsForTool[#i - 1#][#x - 1#][3] = #LevelArray[x].pointsMax#;
			AllLevelsForTool[#i - 1#][#x - 1#][4] = '#LevelArray[x].description#';
		</cfloop>
	</cfloop>
	
	function GetLevel(points,tool)
	{
		//looop through the tools and look for a match
		for(i = 0;i < AllLevelsForTool.length; i++)
		{	
			//tools match get the levels for it
			if(AllLevelsForTool[i][0][0] == tool)
			{
				for(x = 0; x < AllLevelsForTool[i].length; x++)
				{
					//check that the points match
					if(points >= AllLevelsForTool[i][x][2] && points <= AllLevelsForTool[i][x][3])
					{
						return AllLevelsForTool[i][x][4];
					}
				}
				break;
			}	
		}
	}
</script>
</cfoutput>