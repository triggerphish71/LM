<cfquery name="getRegions" datasource="Tips4">
SELECT     iOpsArea_ID, cName
FROM         OpsArea
WHERE     (dtRowDeleted IS NULL) and iOpsArea_ID <> 6
ORDER BY cName
</cfquery>

<cfloop query="getRegions">

	<cfloop from=1 to=16 index="loopcount">
	<cfquery name="insertOpsAreaQuestion" datasource="#FTAds#">
		insert into FTARegionQuestions
		(iOpsArea_ID, iOrder, iFTAQuestion_ID, dtEffectiveStart) 
		VALUES 
		(#getRegions.iOpsArea_ID#, #loopcount#, #loopcount#, '11/1/2004')
	</cfquery>
	</cfloop>
</cfloop>

DONE