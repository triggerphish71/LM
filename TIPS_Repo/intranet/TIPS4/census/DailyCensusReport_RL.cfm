<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| To create Daily Census Report for each house                                                 |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| gthota     | 09/06/2017 | To generate Daily Census Report for each House of relocated tenants          |
----------------------------------------------------------------------------------------------->
 
 <CFOUTPUT>
 <cfquery name="checkhouse" DATASOURCE="#APPLICATION.datasource#">
	select * from [dbo].[RL_RES_STG]	WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>	

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	(OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN	Region R	ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	iHouse_ID = #checkhouse.FromHouseID#	
	AND		H.dtRowDeleted IS NULL
	AND		H.bisSandbox = 0
</CFQUERY>



	
	<cfdump var="#checkhouse#">
	<cfset prompt0 = #HouseData.iHouse_ID#>
	<cfset prompt1 = #form.dtcompare#>
	#prompt0#   /   #prompt1# 
	
	<cflocation url="CensusDailyReport_RL.cfm?prompt0=#prompt0#&prompt1=#prompt1#">
</CFOUTPUT>
 


 
	

