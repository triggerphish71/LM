<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 01/10/2006 | added flowerbox, changed the queries that sum the itotalhours to   |
|            |            | divide by 1 if no total is found.                                  |
| ranklam    | 01/31/2006 | changed the old comshare queries to the new versions by adding     |
|            |            | includes.                                                          |
| ranklam    | 02/07/2006 | for the new houses the ihouse_id DOES NOT MATCH the comshare       |
|            |            | unit_id.  The unit_id of the new houses is the last 3 digits of    |
|            |            | the subaccount number.                                             |
| ranklam    | 02/09/2006 | major re-write													   |
| mlaw       | 07/26/2007 | Use Active Directory to get Administrator's name                   |
----------------------------------------------------------------------------------------------->


<!--- For Testing ONLY - Remove the FTSds Set block after testing. --->
	<cfset FTAds = "FTA_TEST">
<!--- ------------------------------------------------------------ --->

<!--- create some params for this page so we dont have to use a bunch of isdefined statements --->
<cfparam name="iHouse_Id" default="0">
<cfparam name="session.eid" default="A8W999999">
<cfparam name="EHSIFacilityID" default="0">
<cfparam name="debug" default="false">
<cfparam name="session.username" default="bkubly">
<cfparam name="session.developers" default="">
<cfparam name="datetouse" default="#NOW()#">
<cfparam name="SubAccountNumber" default="0">

<cfparam name="session.ADDescription" default="IT - Application Developer">

<cfif debug>
	<cfdump var="#session#">
	<cfdump var="#application#">
</cfif>

<!--- eid presnet in session but empty, user not set up in ad properly --->
<cfif session.eid eq "">
	<center><H3><font color="red" face="arial">You do not have a EID set up in Active Directory and cannot access this application.<BR>
	If you need access to the Online FTA, please contact the Help Desk and have them enter your EID in your network account.
	</font></H3></center>
	<cfabort>
<!--- session.eid = 0, this page created it, they are not logged in --->
<cfelseif session.eid eq 0>
	<center><H3><font color="red" face="arial">You must be logged in with your network name and password to access the Online FTA.<BR>
	<A href="/intranet/loginindex.cfm">Please try again</A>
	</font></H3></center>
	<cfabort>
<!--- they are logged in with an ad eid set up --->
<cfelse>
	<!--- no house id was passed into this page --->
	<cfif iHouse_ID eq 0>
		<!--- get subaccount from AD --->
		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">

		<cfset SubAccountNumber = #FindSubAccount.company#>

		<cfset useHouseId = false>

		<cfinclude template="QueryFiles\qry_getSubAccount.cfm">

		<cfset EHSIFacilityID = #trim(getSubAccount.EHSIFacilityID)#>
	<cfelse>
		<!--- iHouse_ID is defined, so this is an AP person coming in pretending to be a house --->
		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,Name" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">

		<cfinclude template="QueryFiles\qry_getSubAccount.cfm">

		<cfset SubAccountNumber = trim(getSubAccount.cGLsubaccount)>
		<cfset EHSIFacilityID = trim(getSubAccount.EHSIFacilityID)>
	</cfif>

	<!--- if session.eid is not temp (what does that mean) or there was no subaccount found in the lookup --->
	<cfif SESSION.EID neq "temp" AND (FindSubAccount.recordcount eq 0 OR FindSubAccount.company is "")>
		<center><H3><font color="red" face="arial">Sorry, your Active Directory Account has not yet been set up with a SubAccount.  Please contact IT.</font></H3></center>
		<cfabort>
	</cfif>
</cfif>

<!--- user is not a RDO (they do not have RDO in their ad dscription --->
<cfif find("RDO", session.ADdescription) neq 0>

	<cfset RDOposition = Find("RDO",SESSION.ADdescription)>

	<cfset endposition = rdoposition + 5>

	<cfset regionname = removechars(SESSION.ADdescription,1,endposition)>

	<cfquery name="findOpsAreaID" datasource="prodTips4">
		select
			 iOpsArea_ID
			,cName
		from
			OpsArea
		where
			dtRowDeleted IS NULL
		and
			cName = '#Trim(RegionName)#'
	</cfquery>

	<cfif findOpsAreaID.recordcount gt 0>
		<cfset RDOrestrict = findOpsAreaID.iOpsArea_ID>
	</cfif>
</cfif>

<cfset showHouseSelect = false>

<cfif FindSubAccount.company is 0>
	<cfquery name="getHouses" datasource="#application.datasource#">
		select
			 cName
			,iHouse_ID AS GetHousesId
		from
			HOUSE
		where
			dtRowDeleted IS NULL
		<cfif isDefined("RDOrestrict")>
		and
			iOpsArea_ID = #RDOrestrict#
		</cfif>
		order by
			cName
	</cfquery>

	<cfset showHouseSelect = true>

<cfelse>
	<cfset SubAccountNumber = FindSubAccount.company>
</cfif>

<cfif ihouse_id neq 0 OR SubAccountNumber neq 0>
	<!--- add house_id here --->
	<cfquery name="LookUpSubAcct" datasource="#application.datasource#">
		select
			 cName
			,iHouse_ID
		from
			House
		where
			cGLSubAccount = '#SubAccountNumber#'
	</cfquery>

	<!--- rsa - 2/7/06 - check for the subaccount (see flowerbox)--->
	<cfquery name="CheckSubAccount" datasource="#ComshareDS#">
		select top 1
			YEAR_ID
		from
			ALC.FINLOC_BASE
		where
			year_id= 2006
		and
			unit_id= #lookupsubacct.ihouse_id#
	</cfquery>

	<!--- rsa - 2/7/06 - get house id as subaccount if no records are found for checksubaccount (see flowerbox) --->
	<cfquery name="GetHouseInfo" datasource="#application.datasource#">
		select
			 H.cNumber
			,H.cPhoneNumber1
			,H.cStateCode
			,R.cName
			<cfif checksubaccount.recordcount lt 1>
			,RIGHT(cGLSubAccount,3) AS unitId
			,iHouse_id
			<cfelse>
			,H.iHouse_ID
			,H.iHouse_ID AS unitId
			</cfif>
			,H.cSLevelTypeSet
			,H.EHSIFacilityID
		from
			House H
		inner join
			OpsArea O ON H.iOpsArea_ID = O.iOpsArea_ID
		inner join
			Region R on O.iRegion_ID = R.iRegion_ID
		 where
		 	H.cName = '#Trim(LookUpSubAcct.cName)#'
	</cfquery>

	<cfset houseId = GetHouseInfo.iHouse_id>
	<cfset unitId = GetHouseInfo.unitId>

	<cfset HouseNumber = #trim(EHSIFacilityID)#>

	<cfoutput>
		<CFLDAP ACTION="query" NAME="FindAdmin" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="displayname,physicalDeliveryOfficeName,dn,Description,mail" SERVER="#ADserver#" PORT="389" FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(objectClass=user)(Description=#Trim(LookUpSubAcct.cName)# - Administrator))" USERNAME="ldap" PASSWORD="paulLDAP939">
		<cfset AdminName = #FindAdmin.displayname#>
	</cfoutput>
	
	<!--- MLAW Comment this piece  07/26/2007            --->
	<!--- this is new Oracle EV3 query to get Admin name 
	<cfquery name="GetAdminFromEV3" datasource="prod3">
		SELECT
		RTRIM(PD.FIRST_NAME) || ' ' || RTRIM(PD.LAST_NAME)		cName,
		PD.ORIG_HIRE_DT						dtOrigHire,
		PD.EMAIL_ADDRESS						cEmail,
		J.EFFDT							dtPositionHire
		FROM  PS_JOB             J,
		      PS_PERSONAL_DATA   PD
		WHERE J.EFFDT  = (SELECT MAX(EFFDT)
		                    FROM PS_JOB
		                   WHERE EMPLID       = J.EMPLID
		                     AND EMPL_RCD_NBR = J.EMPL_RCD_NBR
		                     AND EFFDT <= TO_DATE('#DAteFormat(NOW(),'MM-DD-YYYY')#', 'MM-DD-YYYY'))
		AND   J.EFFSEQ = (SELECT MAX(EFFSEQ)
		                    FROM PS_JOB
		                   WHERE EMPLID       = J.EMPLID
		                     AND EMPL_RCD_NBR = J.EMPL_RCD_NBR
		                     AND EFFDT        = J.EFFDT)
		AND   J.LOCATION    = '#GetHouseInfo.EHSIFacilityID#'
		AND   J.EMPL_STATUS = 'A'
		AND   J.JOBCODE     = 'A000'
		AND   PD.EMPLID     = J.EMPLID
	</cfquery>--->

	<!---  --->
	<cfif DatePart("m",datetouse) eq DatePart("m",NOW())>
		<cfset currentMonth = true>
	<cfelse>
		<cfset currentMonth = false>
	</cfif>

	<cfset monthforqueries = #DateFormat(datetouse,'mmm')#>
	<cfset yearforqueries = #DateFormat(datetouse,'yyyy')#>

	<cfset firstdayofdatetouse = "#DateFormat(datetouse,'mm')#/01/#DateFormat(datetouse,'yyyy')# 00:00:00">

	<cfif currentMonth>
		<cfset lastdayofdatetouse = "#DateFormat(Now(), 'M/D/YYYY')#">
		<!--- if this is the first day of the NOW month, then use TODAY as the lastdayofdatetouse, otherwise, use yesterday --->
		<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse, 'M/D/YYYY')#">

		<cfif DatePart('d',NOW()) is "1">
			<cfset lastdayofdatetouse = "#DateFormat(NOW(),'M/D/YYYY')#">
		<cfelse><!--- use yesterday --->
			<cfset lastdayofdatetouse = "#DateAdd('d',-1,lastdayofdatetouse)#">
			<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse,'M/D/YYYY')#">
		</cfif>
	<cfelse>
		<cfset daysinmonth2 = #DaysInMonth(datetouse)#>
		<cfset lastdayofdatetouse = "#DatePart('m',datetouse)#/#DaysInMonth2#/#DatePart('yyyy',datetouse)#">
	</cfif>

	<cfquery name="getHouseAcuity" datasource="prodtips4">
		select
			 sum(iSPoints) as TheSum
			,count(iResidentOccupancy_ID) as TheCount
		from
			ResidentOccupancy
		where
			dtOccupancy = #DateAdd('d',-1,DateFormat(NOW(),'M/D/YY'))#
		and
			iHouse_ID = #GetHouseInfo.iHouse_ID#
		and
			cType = 'B'
		and
			dtRowDeleted IS NULL
	</cfquery>

	<cfif getHouseAcuity.TheCount neq 0>
		<cfset acuity = #getHouseAcuity.TheSum#/#GetHouseAcuity.TheCount#>
		<cfquery name="getLevelforAcuity" datasource="prodtips4">
			select
				cDescription
			from
				sleveltype
			where
				csleveltypeset = '#getHouseInfo.cSLevelTypeSet#'
			and
				iSpointsmin <= #acuity#
			and
				iSpointsMax >= #acuity#
		</cfquery>
	</cfif>

	<cfinclude template="ActionFiles\act_GetBudgetedResidentDays.cfm">

	<!--- rsa - 1/31/06 - replaced this with the new comshare query --->
	<cfinclude template="QueryFiles\qry_GetBudgetedOccupiedUnits.cfm">
	<!--- keep the variable name --->
	<cfset getOccUnits = GetBudgetedOccupiedUnits>
	<cfset getOccUnitsMonth = "getOccUnits.#monthforqueries#">

	<cfset dim = daysinmonth(datetouse)>

	<cfinclude template="QueryFiles\qry_GetBudgetedHouseRevenue.cfm">
	<cfset getBudgHouseRev = GetBudgetedHouseRevenue>

	<cfset getBudgHouseRevMonth = "getBudgHouseRev.#monthforqueries#">

	<!--- get ave. actual wage rates per hour for all categories for this month (get from table instead of realtime so page loads faster) --->
	<cfinclude template="QueryFiles\qry_GetAverageHoursByCategory.cfm">

	<cfset getAvgHoursCategory = GetAverageHoursByCategory>

	<!--- if the above returns no records (say the auto process didn't run correctly), then try for the previous day --->
	<cfif getAvgHoursCategory.recordcount is "0" and DatePart('d',datetouse) is not "1">
		<cfset lastdayofdatetouse = DateAdd('d',-1,lastdayofdatetouse)>
		<cfset lastdayofdatetouse = DateFormat(lastdayofdatetouse,'M/D/YYYY')>

		<cfinclude template="QueryFiles\qry_GetAverageHoursByCategory.cfm">

		<cfset getAvgHoursCategory = GetAverageHoursByCategory>
	</cfif>

	<cfinclude template="QueryFiles\qry_GetRCBWR.cfm">

	<cfset getRCBWRmonth = "getRCBWR.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetRCPRCD.cfm">

	<cfinclude template="QueryFiles\qry_GetAverageHoursForResidentCare.cfm">
	<cfset getAveHoursCategoryRC = GetAverageHoursForResidentCare>

	<cfinclude template="QueryFiles\qry_GetHousekeepingPRCD.cfm">

	<cfinclude template="QueryFiles\qry_getHousekeepingBWR.cfm">
	<cfset getHousekeepingBWRMonth = "getHousekeepingBWR.#monthforqueries#">

	<!--- get just housekeeping hours --->
	<cfinclude template="QueryFiles\qry_GetTotalHousekeepingHours.cfm">
	<cfset getiTotalHoursHK = GetTotalHousekeepingHours>

	<cfif getiTotalHoursHK.recordcount gt 0 AND getiTotalHoursHK.Avg_Rate neq 0>
		<cfinclude template="QueryFiles\qry_GetAverageHousekeepingHours.cfm">
		<cfset getAveHoursCategoryHK = GetAverageHouseKeepingHours>
	</cfif>

	<cfinclude template="QueryFiles\qry_GetLPNPRCD.cfm">

	<cfinclude template="QueryFiles\qry_GetLPNBWR.cfm">
	<cfset getLPNBWRMonth = "getLPNBWR.#monthforqueries#">

	<!--- get just lpn hours --->
	<cfinclude template="QueryFiles\qry_GetLPNTotalHours.cfm">
	<cfset getiTotalHoursLPN = GetLPNTotalHours>


	<cfif getiTotalHoursLPN.recordcount is not "" AND getiTotalHoursLPN.Avg_Rate neq 0>
		<cfinclude template="QueryFiles\qry_GetAverageLPNHours.cfm">
		<cfset getAveHoursCategoryLPN = GetAverageLPNHours>
	</cfif>

	<cfinclude template="QueryFiles\qry_GetNursingHPM.cfm">

	<cfinclude template="QueryFiles\qry_GetNursingBWR.cfm">
	<cfset getNursingBWRQuery = "getNursingBWR.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetAverageNursingHours.cfm">
	<cfset getAveHoursNursing = GetAverageNursingHours>

	<cfinclude template="QueryFiles\qry_GetActivitiesPRCD.cfm">

	<cfinclude template="QueryFiles\qry_GetActivitiesBWR.cfm">
	<cfset getActivitiesBWRMonth = "getActivitiesBWR.#monthforqueries#">

	<!--- rsa - chagned to divied by 1 if no total hours were found --->
	<cfinclude template="QueryFiles\qry_GetAverageActivitiesHours.cfm">
	<cfset getAveHoursCategoryActivities = GetAverageActivitiesHours>

	<cfinclude template="QueryFiles\qry_GetMaintenancePRCD.cfm">

	<cfinclude template="QueryFiles\qry_GetMaintenanceBWR.cfm">
	<cfset getMaintenanceBWRMonth = "getMaintenanceBWR.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetTotalMaintenanceHours.cfm">

	<!--- rsa - chagned to divied by 1 if no total hours were found --->
	<cfif GetTotalMaintenanceHours.iTotalHours neq 0>
		<cfinclude template="QueryFiles\qry_GetAverageMaintenanceHours.cfm">
		<cfset getAveHoursCategoryMaintenance = GetAverageMaintenanceHours>
	</cfif>

	<cfinclude template="QueryFiles\qry_GetKitchenPRCD.cfm">

	<cfinclude template="QueryFiles\qry_GetKitchenBWR.cfm">
	<cfset getKitchenBWRMonth = "getKitchenBWR.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetTotalKitchenHours.cfm">

	<cfif GetTotalKitchenHours.iTotalHours neq 0>
		<cfinclude template="QueryFiles\qry_GetAverageKitchenHours.cfm">
		<!--- rsa - chagned to divied by 1 if no total hours were found --->
		<cfset getAveHoursCategoryKitchen = GetAverageKitchenHours>
	</cfif>

	<cfinclude template="QueryFiles\qry_GetMAHPM.cfm">

	<cfinclude template="QueryFiles\qry_GetMABWR.cfm">
	<cfset getMABWRMonth = "getMABWR.#monthforqueries#">

	<!--- get just MA hours --->
	<cfinclude template="QueryFiles\qry_GetTotalMAHours.cfm">

	<cfif GetTotalMAHours.iTotalHours neq 0>
		<cfinclude template="QueryFiles\qry_GetAverageMAHours.cfm">
		<cfset getAveHoursMA = GetAverageMAHours>
	</cfif>

	<cfinclude template="QueryFiles\qry_GetTrainingBDM.cfm">
	<cfset getTrainingBDMMMonth = "getTrainingBDM.#monthforqueries#">

	<!--- rsa - 1/31/06 - changed to use new comshare query include --->
	<cfinclude template="QueryFiles\qry_GetBudgetedFoodExpense.cfm">
	<!--- keep the query name the same --->
	<cfset getFoodPRD = GetBudgetedFoodExpense>

	<cfset getFoodPRDMonth = "getFoodPRD.#monthforqueries#">

	<!--- rsa - 1/31/06 - changed to use new comshare query include --->
	<cfinclude template="QueryFiles\qry_GetBudgetedKitchenSupplies.cfm">
	<!--- keep the query name the same --->

	<!---
	<cfset getSuppliesPRD = GetBudgetedKitchenSupplies>
	<cfset getSuppliesPRDMonth = "getSuppliesPRD.#monthforqueries#"> ]
	--->

	<cfset getSuppliesPRDMonth = GetBudgetedKitchenSupplies.P0>

	<cfinclude template="QueryFiles\qry_GetResidentCare.cfm">
	<cfset getResidentCareMonth = "getResidentCare.#monthforqueries#">

	<!--- rsa - 1/31/06 - changed to use new comshare query include --->
	<cfinclude template="QueryFiles\qry_GetBudgetedKitchenOther.cfm">
	<!--- keep the query name the same --->
	<cfset getOtherKitchen = GetBudgetedKitchenOther>

	<cfset getOtherKitchenMonth = "getOtherKitchen.#monthforqueries#">
	<cfinclude template="QueryFiles\qry_GetMaintenance.cfm">

	<cfset getMaintenanceMonth = "getMaintenance.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetHousekeeping.cfm">
	<cfset getHousekeepingMonth = "getHousekeeping.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetActivities.cfm">
	<cfset getActivitiesMonth = "getActivities.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetProperty.cfm">
	<cfset getPropertyMonth = "getProperty.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetOtherRevenue.cfm">
	<cfset getOtherRev = GetOtherRevenue>
	<cfset getOtherRevMonth = "getOtherRev.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetUtilities.cfm">
	<cfset getUtilitiesMonth = "getUtilities.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetAdvertising.cfm">
	<cfset getAdvertisingMonth = "getAdvertising.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetAdministrative.cfm">
	<cfset getAdministrativeMonth = "getAdministrative.#monthforqueries#">

	<!--- rsa - 1/31/06 - changed to use new comshare query include --->
	<cfinclude template="QueryFiles\qry_GetPettyCash.cfm">
	<!--- keep the query name the same --->
	<cfset getPettyCash = GetPettyCash>
	<cfset getPettyCashMonth = "getPettyCash.#monthforqueries#">

	<cfinclude template="QueryFiles\qry_GetOther.cfm">
	<cfset getOtherMonth = "getOther.#monthforqueries#">
</cfif><!--- end ihouse_id = 0 --->


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- Budget Sheet</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK REL=StyleSheet TYPE="Text/css"  HREF="fta.css">

<cfinclude template="ScriptFiles\js_CommonFunctions.cfm">

</head>

<body>

<font face="arial">

<cfif showHouseSelect>
	<form name="selectHouse">
	<table>
		<tr>
			<td style="background-color:#ffffff">View FTA for House:</td>
			<td style="background-color:#ffffff">
				<select name="iHouse_ID" onchange="doSel(this)">
					<option value=""></option>
					<cfoutput query="getHouses">
						<option value="location.href='default.cfm?iHouse_ID=#GetHousesId#'"<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId)> SELECTED</cfif>>#cName#</option>
					</cfoutput>
				</select>
			</td>
		</tr>
	</table>
	</form>
	<HR align=left size=2 width=580 color="##0066CC">
</cfif>

<cfif iHouse_id neq 0 OR SubAccountNumber neq 0>
	<Font face="arial">

	<cfoutput>
	<h3>Online FTA- <font color="##C88A5B">Budget Sheet-</font> <font color="##0066CC">#LookUpSubAcct.cName#-</font> <Font color="##7F7E7E">#DateFormat(datetouse,'mmmm yyyy')#</Font></h3>

	<cfset Page="setupsheet">

	<cfinclude template="DisplayFiles\dsp_MonthSelect.cfm">

	<form name="FTA" action="submitFTA.cfm">

	<table border=1 cellpadding=1 cellspacing=0>
		<tr>
			<td colspan=4 class="mainareaheader">#LookUpSubAcct.cName# #DateFormat(datetouse,'mmmm yyyy')#</td>
		</tr>
		<tr>
			<td class="mainarea">Sub Account:</td><td class="generalleft">#SubAccountNumber#</td><td class="mainarea">State:</td><td class="generalleft">#GetHouseInfo.cSTATEcode#</td>
		</tr>
		<tr>
			<td class="mainarea">Phone Number:</td><td class="generalleft"><cfset pn = #insert('-',gethouseinfo.cPhoneNumber1,6)#><cfset pn = #insert('-',pn,3)#>#pn#</td><TD class="mainarea">Administrator Name:</TD><td class="generalleft"><cfif #AdminName# is ""><i>(No current Admin assigned in System)</i><cfelse>#AdminName#</cfif></td>
		</tr>
		<tr>
			<td class="mainarea">House Acuity (from TIPS):</td>
			<td class="generalleft">
				<cfif getHouseAcuity.TheCount neq 0>
					#NumberFormat(acuity,'__.__')# <font size=-1>(Level #getLevelforAcuity.cDescription#)</font>
				<cfelse>
					N/A
				</cfif>
			</td>
			<td class="mainarea">Division:</td>
			<td class="generalleft">#GetHouseInfo.cName#</td>
		</tr>
		<tr>
			<td class="mainarea">Budgeted Occupied Units<BR>for the Current Month:</td>
			<td class="generalleft">#NumberFormat(Evaluate(getOccUnitsMonth),'__._')#</td>
			<td class="mainarea">Number of Days in Month:</td>
			<td class="generalleft">#dim#</td>
		</tr>
		<tr>
			<td class="mainarea">Budgeted House Revenue:</td>
			<td class="generalleft">#DollarFormat(Evaluate(getBudgHouseRevMonth))#</td>
		</tr>
	</table>
	<p>

	<cfif getAvgHoursCategory.recordcount eq 0 and DatePart('d',datetouse) neq "1">
		<font color="red" face="arial" size=-1>No recent data was found for Actual Wage Rates for this house.  The nightly process may have not run correctly.  Please contact the Help Desk.</font><p>
	<cfelseif getAvgHoursCategory.recordcount eq 0 and DatePart('d',datetouse) eq "1">
		<font color="red" face="arial" size=-1>Since it is the first of the current month and calculations for each day run nightly at midnight, no actual wages have yet been determined for this month.</font><p>
	</cfif>

	<table border=0 cellpadding=0 cellspacing=0><td valign=top class="white">
		<tr>
			<td>
				<table border=1 cellpadding=1 cellspacing=0>
					<tr>
						<td class="white"></td>
						<td colspan=5 align=center class="mainareaheader">Budgeted Hours per Resident Day/Per Day<BR>#DateFormat(firstdayofdatetouse,'MM/DD/YYYY')# - #DateFormat(lastdayofdatetouse,'MM/DD/YYYY')#</td>
					</tr>
					<tr>
						<td class="white"></td>
						<td class="mainarea"></td>
						<td class="mainarea">Budget Hours<BR>per Resident Day</td>
						<td class="mainarea">Budgeted Wage<BR>Rates per Hour</td>
						<td class="mainarea">Ave. Actual Regular Wage<BR>Rates per Hour</td>
						<td class="mainarea">Wage Rate<BR>Variance</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Resident Care</td>
						<td>&##160;</td>
						<td>#DecimalFormat(getRCPRCD.P0)#</td>
						<td>#DecimalFormat(evaluate(getRCBWRmonth))#</td>
						<td>
							<!--- housekeeping wage rates per hour --->
							<cfif getAveHoursCategoryRC.AR is not ''>
								#DecimalFormat(getAveHoursCategoryRC.AR)#
								<cfset RCh = "#getAveHoursCategoryRC.AR#">
							<cfelse>
								0.00
								<cfset RC = "0">
								<cfset RCh = "0">
							</cfif>
						</td>
						<!--- get variance --->
						<td class="variance">
							<cfif isDefined("RC")>
								#DecimalFormat(evaluate(getRCBWRMonth))#
							<cfelse>
								<cfset varianceRC = #DecimalFormat(evaluate(getRCBWRMonth))# - #RCh#>
								<cfif VarianceRC LT 0>
									<font color="red">
								</cfif>
								#NumberFormat(varianceRC,'(999.99)')#
							</cfif>
						</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Licensed Nursing</td>
						<td>&##160;</td>
						<td>#DecimalFormat(getLPNPRCD.P0)#</td>
						<td>#DecimalFormat(evaluate(getLPNBWRMonth))#</td>
						<td>
							<!--- Average LPN rates per h ours --->
							<cfif isDefined("getAveHoursCategoryLPN") AND getAveHoursCategoryLPN.Avg_rate is not ''>
								#DecimalFormat(getAveHoursCategoryLPN.avg_rate)#
								<cfset LPNh = #getAveHoursCategoryLPN.avg_rate#>
							<cfelse>
								0.00
								<cfset LPN= "0">
								<cfset LPNh= "0">
							</cfif>
						</td>
						<td class="variance">
							<cfif isDefined("LPN")>
								#DecimalFormat(evaluate(getLPNBWRMonth))#
							<cfelse>
								<cfset varianceLPN = #DecimalFormat(evaluate(getLPNBWRMonth))# - #LPNh#>
								<cfif VarianceLPN LT 0>
									<font color="red">
								</cfif>
									#NumberFormat(varianceLPN,'(999.99)')#
								</cfif>
						</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Housekeeping</td>
						<td>&##160;</td>
						<td>#DecimalFormat(getHousekeepingPRCD.P0)#</td>
						<td>#DecimalFormat(evaluate(getHousekeepingBWRMonth))#</td>
						<td>
							<cfif isDefined("getAveHoursCategoryHK") AND getAveHoursCategoryHK.Avg_rate is not ''>
								#DecimalFormat(getAveHoursCategoryHK.avg_rate)#
								<cfset HKh = "#getAveHoursCategoryHK.avg_rate#">
							<cfelse>
								0.00
								<cfset HK = "0">
								<cfset HKh = "0">
							</cfif>
						</td>
						<!--- get variance --->
						<td class="variance">
							<cfif isDefined("HK")>
								#DecimalFormat(evaluate(getHousekeepingBWRMonth))#
							<cfelse>
								<cfset varianceHK = #DecimalFormat(evaluate(getHousekeepingBWRMonth))# - #HKh#>
								<cfif VarianceHK LT 0>
									<font color="red">
								</cfif>
								#NumberFormat(varianceHK,'(999.99)')#
							</cfif>
						</td>
					</tr>

					<tr>
						<td class="white">&##160;</td>
						<td class="mainarea" align=center>Hours<BR>per Month</td>
						<td class="mainarea" align=center>Budgeted Hours<BR>per Day</td>
						<td class="mainarea">Budgeted Wage<BR>Rates per Hour</td>
						<td class="mainarea">Ave. Actual Wage<BR>Rates per Hour</td>
						<td class="mainarea">Wage Rate<BR>Variance</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Life Enrichment</td>
						<td>&##160;</td>
						<td>#DecimalFormat(getActivitiesPRCD.P0)#</td>
						<td>#DecimalFormat(evaluate(getActivitiesBWRMonth))#</td>
						<td>
							<!--- average life enrichment hours --->
							<cfif getAveHoursCategoryActivities.Avg_rate is not ''>
								#DecimalFormat(getAveHoursCategoryActivities.avg_rate)#
								<cfset Acth = "#getAveHoursCategoryActivities.avg_rate#">
							<cfelse>
								0.00
								<cfset Act = "0">
								<cfset Acth = "0">
							</cfif>
						</td>
						<td class="variance">
							<cfif isDefined("Act")>
								#DecimalFormat(evaluate(getActivitiesBWRMonth))#
							<cfelse>
								<cfset varianceAct = #DecimalFormat(evaluate(getActivitiesBWRMonth))# - #Acth#>
								<cfif Varianceact LT 0>
									<font color="red">
								</cfif>
								#NumberFormat(varianceAct,'(999.99)')#
							</cfif>
						</td>
					</tr>
					<tr>
						<td align=right class="mainarea">QMA</td>
						<td>&##160;</td>
						<td>
							<!---  --->
							<cfif getNursingHPM.recordcount is not 0>
								#DecimalFormat(getNursingHPM.P0)#
							<cfelse>
								N/A
							</cfif>
						</td>
						<td>#DecimalFormat(evaluate(getNursingBWRQuery))#</td>
						<td>
							<cfif getAveHoursNursing.Avg_rate is not ''>
								#DecimalFormat(getAveHoursNursing.avg_rate)#<cfset Nursingh = #getAveHoursNursing.avg_rate#>
							<cfelse>
								0.00
								<cfset Nursing= "0">
								<cfset Nursingh= "0">
							</cfif>
						</td>
						<td class="variance">
							<cfif isDefined("Nursing")>
								#DecimalFormat(evaluate(getNursingBWRQuery))#
							<cfelse>
								<cfset varianceNursing = #DecimalFormat(evaluate(getNursingBWRQuery))# - #Nursingh#>
								<cfif VarianceNursing LT 0>
									<font color="red">
								</cfif>
								#NumberFormat(varianceNursing,'(999.99)')#
							</cfif>
						</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Maintenance</td>
						<td>&##160;</td>
						<td>#DecimalFormat(getMaintenancePRCD.P0)#</td>
						<td>#DecimalFormat(evaluate(getMaintenanceBWRMonth))#</td>
						<td>
							<!--- average maintenance hours --->
							<cfif isDefined("getAveHoursCategoryMaintenance") and getAveHoursCategoryMaintenance.Avg_rate is not ''>
								#DecimalFormat(getAveHoursCategoryMaintenance.avg_rate)#
								<cfset Mainth = "#getAveHoursCategoryMaintenance.avg_rate#">
							<cfelse>
								0.00
								<cfset Maint = "0">
								<cfset Mainth = "0">
							</cfif>
						</td>
						<td class="variance">
							<cfif isDefined("Maint")>
								#DecimalFormat(evaluate(getMaintenanceBWRMonth))#
							<cfelse>
								<cfset varianceMaint = #DecimalFormat(evaluate(getMaintenanceBWRMonth))# - #Mainth#>
								<cfif VarianceMaint LT 0>
									<font color="red">
								</cfif>
								#NumberFormat(varianceMaint,'(999.99)')#
							</cfif>
						</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Kitchen Services</td>
						<td>&##160;</td>
						<td>#DecimalFormat(getKitchenPRCD.P0)#</td>
						<td>#DecimalFormat(evaluate(getKitchenBWRMonth))#</td>
						<td>
							<!--- average kitchen hours query --->
							<cfif isDefined("getAveHoursCategoryKitchen") and getAveHoursCategoryKitchen.Avg_rate is not ''>
								#DecimalFormat(getAveHoursCategoryKitchen.avg_rate)#
								<cfset Kitchnh = "#getAveHoursCategoryKitchen.avg_rate#">
							<cfelse>
								0.00
								<cfset Kitchn = "0">
								<cfset Kitchnh = "0">
							</cfif>
						</td>
						<td class="variance">
							<cfif isDefined("Kitchn")>
								#DecimalFormat(evaluate(getKitchenBWRMonth))#
							<cfelse>
							<cfset varianceKitchen = #DecimalFormat(evaluate(getKitchenBWRMonth))# - #kitchnh#>
								<cfif VarianceKitchen LT 0>
									<font color="red">
								</cfif>
								#NumberFormat(varianceKitchen,'(999.99)')#

							</cfif>
						</td>
					</tr>
					<tr>
						<td align=right class="mainarea">MA/AA</td>
						<td>
							<cfif getMAHPM.P0 is not "">
								#DecimalFormat(getMAHPM.P0*dim)#
							<cfelse>
								N/A
							</cfif>
						</td>
						<td>
							<cfif getMAHPM.P0 is not "">
								#DecimalFormat(getMAHPM.P0)#
							<cfelse>
								N/A
							</cfif>
						</td>
						<td>#DecimalFormat(evaluate(getMABWRMonth))#</td>
						<td>
							<cfif isDefined("getAveHoursMA") and getAveHoursMA.Avg_rate is not ''>
								#DecimalFormat(getAveHoursMA.AVG_RATE)#
								<cfset HoursMAAA = #getAveHoursMA.AVG_RATE#>
							<cfelse>
								0.00
								<cfset MA = "0">
								<cfset HoursMAAA = "0">
							</cfif>
						</td>
						<td class="variance">
							<cfif isDefined("MA")>
								#DecimalFormat(evaluate(getMABWRMonth))#
							<cfelse>
								<cfset varianceMA = #DecimalFormat(evaluate(getMABWRMonth))# - #HoursMAAA#>
								<cfif VarianceMA LT 0>
										<font color="red">
								</cfif>
								#NumberFormat(varianceMA,'(999.99)')#
							</cfif>
						</td>
					</tr>
					<tr>
						<td class="white">&##160;</td>
						<td class="mainarea"></td>
						<td align=right class="mainarea">Budgeted $<BR>per Month</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Training</td>
						<td>&##160;</td>
						<td>#DecimalFormat(evaluate(getTrainingBDMMMonth))#</td>
					</tr>
				</table>
			</td>
			<td valign=top class="white">&##160; &##160;</td>
			<td valign=top class="white">
				<table border=1 cellpadding=1 cellspacing=0>
					<tr>
						<td align=right class="mainareaheader" colspan=2>Budgeted Food Expense</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Budgeted Food Expense<BR>per Resident Day</td>
						<td>#DecimalFormat(evaluate(getFoodPRDMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Budgeted Kitchen Supplies<BR>per Resident Day</td>
						<td>#DecimalFormat(getSuppliesPRDMonth)#</td>
					</tr>
					<tr>
						<td align=right class="mainareaheader" colspan=2>Budgeted Expense for the Current Month</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Resident Care</td>
						<td>#DecimalFormat(evaluate(getResidentCareMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Other Kitchen</td>
						<td>#DecimalFormat(evaluate(getOtherKitchenMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Maintenance</td>
						<td>#DecimalFormat(evaluate(getMaintenanceMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Housekeeping</td>
						<td>#DecimalFormat(evaluate(getHousekeepingMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Activities</td>
						<td>#DecimalFormat(evaluate(getActivitiesMonth))#</td>
					</tr>
					<!--- <tr>
						<td align=right class="mainarea">Property and Equipment</td>
						<td><!--- #DecimalFormat(evaluate(monthforquery2))# --->??</td>
					</tr> --->
					<tr>
						<td align=right class="mainarea">Other Revenue</td>
						<td>#DecimalFormat(evaluate(getOtherRevMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Utilities</td>
						<td>#DecimalFormat(evaluate(getUtilitiesMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Advertising</td>
						<td>#DecimalFormat(evaluate(getAdvertisingMonth))#</td>
					</tr>
					<tr>
						<td align=right class="mainarea">Administrative</td>
						<td>#DecimalFormat(evaluate(getAdministrativeMonth))#</td>
					</tr>
					<!--- <tr>
						<td align=right class="mainarea">Petty Cash</td>
						<td>#DecimalFormat(evaluate(getPettyCashMonth))#</td>
					</tr> --->
					<!--- <tr>
						<td align=right class="mainarea">Other</td>
						<td><!--- #DecimalFormat(evaluate(getOtherMonth))# --->??</td>
					</tr> --->
				</table>
			</tr>
		</td>
	</table>
		<p>
	[ <A HREF="/intranet/fta/labortracking.cfm?subAccount=#SubAccountNumber#&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#">Labor Tracking Report</A> | <A HREF="/intranet/fta/monthlyinvoices.cfm?iHouse_ID=#GetHouseInfo.iHouse_ID#&DateToUse=#DateToUse#">Monthly Invoices</A> | <A HREF="expensespenddown.cfm?subAccount=#SubAccountNumber#&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#">Expense Spend-down</A> | <A HREF="housereport.cfm?subAccount=#SubAccountNumber#&workingmonth=#firstdayofdatetouse#">House Report</A> ]
	<p>

	<cfif listfind(session.developers,session.username) neq 0>
		Hours per category:<BR>
		<cfdump var="#getAvgHoursCategory#">
		<p>
		<cfif isDefined("categoryquery")>
			Category Query:<BR>
			<cfdump var="#categoryquery#">
		</cfif>
	</cfif>
	</cfoutput>
	</form>
</cfif><!--- end houseid neq 0 --->
</body>
</html>
