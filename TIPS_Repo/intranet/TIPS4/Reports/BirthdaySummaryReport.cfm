<!--- 
01/14/2016  |S Farmer     |         |  Replaced crystal report with Coldfusion CFDocument-PDF |
 --->
<CFOUTPUT> 
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	
	
<cflocation url="ResidentBirthdaySummaryA.cfm?prompt0=#housedata.cnumber#"	>
 
</CFOUTPUT>