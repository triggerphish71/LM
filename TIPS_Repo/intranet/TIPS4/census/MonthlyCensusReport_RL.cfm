<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| To create Daily Census Report for each house                                                 |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES: sp_monthlycensusreport                                                    |
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
| gthota     | 09/09/2017 | Created for relocation residents                             |
----------------------------------------------------------------------------------------------->

<!--- <CFOUTPUT>
	<CFIF NOT IsDefined("SESSION.USERID")><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"></CFIF>
	<CENTER><B STYLE="font-size: 30;"> Please wait while the report is loading.... </B></CENTER>
</CFOUTPUT>

<SCRIPT>report = window.open("loading.htm","MonthlyCensusReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>
 --->
 <cfquery name="checkhouse" DATASOURCE="#APPLICATION.datasource#">
	select * from [dbo].[RL_RES_STG]	WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>	
 
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	  AND	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
</CFQUERY>
	
<CFOUTPUT>
	<cfset prompt0 =#HouseData.iHouse_ID#>
	<cfset prompt1 =#form.dtCompare#>
	<cflocation url="CensusMonthlyReport_RL.cfm?prompt0=#prompt0#&prompt1=#prompt1#">
</CFOUTPUT>
