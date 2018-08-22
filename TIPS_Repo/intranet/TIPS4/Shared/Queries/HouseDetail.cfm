<!--- 
 |S Farmer    | 09/08/2014 | 116824             | Allow all houses edit BSF and Community Fee Rates |
 --->
<cfquery  name="HouseInfo" DATASOURCE = "#APPLICATION.datasource#">  
	SELECT     H.iHouse_ID
	, H.cName as 'HouseName'
	, HL.dtCurrentTipsMonth
	,H.cNumber as 'HouseNumber'
	,H.cSLevelTypeSet
	,H.cGLsubaccount
	,H.iBondHouse
	,H.bBondHouseType
	,H.iPeriod_ID
	,H.iHouseLateFee_ID
	,OPSA.iOpsArea_ID as 'RegionID'
	,OPSA.cname as 'Region'
	,REG.iRegion_ID as 'DivisionID'
	,REG.cName as 'DivisionName'

FROM         House H INNER JOIN
                      HouseLog HL ON H.iHouse_ID = HL.iHouse_ID
                join dbo.OpsArea OPSA on h.iOpsArea_ID = OPSA.iOpsArea_ID
                join dbo.Region REG on OPSA.iRegion_ID = REG.iRegion_ID
WHERE     (H.iHouse_ID = #session.qSelectedHouse.iHouse_ID#)
</cfquery>
<cfset thisHouseTipsMonth = dateformat(HouseInfo.dtCurrentTipsMonth, 'mmmm, yyyy')>

<!--- <cfoutput>#thisHouseTipsMonth#</cfoutput> --->
