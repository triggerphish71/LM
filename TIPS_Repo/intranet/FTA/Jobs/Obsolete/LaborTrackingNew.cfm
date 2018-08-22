<!--- 
	CFML: 	LaborTracking.cfm
	DATE: 	02/03/2009
	AUTHOR: Bob Kubly - Application Developer II
	DESC:	The Labor Tracking Page displays both Budget and Actual Hours data 
			for a number of Positions, including Resident Care, LPN, QMA,
			Kitchen Services, Training, etc...). 
			
	VERSION HISTORY
	--------------------------------------------------------------------------------------
	Ver:	1
	Author:	Bob Kubly - Application Developer II
	Desc:	Rewriting the entire Labor Tracking Page, because the Code was not written
			using ALC Standards and the Logically Structure is poor.
			
	Ver:	2
	Author:	
	Desc:	
	
	Ver:	3
	Author:	
	Desc:	
--->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<HTML>
	<HEAD>
		<LINK rel="stylesheet" href="LaborTracking.css" type="text/css">
		<LINK rel="stylesheet" href="LaborTrackingPrint.css" type="text/css" media="print">

		<TITLE>
			Online FTA- Labor Tracking Report
		</TITLE>
		
		<META http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<CFSCRIPT>
				function initializeDateVariables(iDateToUse)
				{
					currentMonth = DateFormat(iDateToUse, "MM/YYYY");
					currentM = DatePart('m', iDateToUse);
					currentY = DatePart('yyyy', iDateToUse);
					
					currentMY = currentM + "/" + currentY;
					
					currentDIM = DaysInMonth(currentMY);
					currentD = DaysInMonth(currentMY);
					
					currentFullMonth = currentM + "/01/" + currentY + " 12:00:00 AM";
					
				}
		</CFSCRIPT>


<cfif isDefined("url.datetoUse") and url.datetouse is not #DateFormat(NOW(),'mmmm yyyy')#>
	<!--- use the month/year given --->
	<cfset currentmonth = "#DateFormat(datetouse,'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',datetouse)#">
	<cfset currenty = "#DatePart('yyyy',datetouse)#">

	<cfset currentmy = "#currentm#/#currenty#">
	<cfset currentdim = "#DaysInMonth(currentmy)#">
	<cfset currentd = "#DaysInMonth(currentmy)#">
	<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
	<cfset currentfullmonthNoTime = "#currentm#/01/#currenty#">
	<cfset lastdayofDateToUse = "#currentm#/#currentd#/#currenty#">
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,currentfullmonthNoTime)#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(currentfullmonthNoTime,'M/D/YYYY')#">
	<!--- ??? --->
	<cfset today = "#currentm#/#currentdim#/#currenty#">
	<cfset datetouse = "#DateFormat(currentfullmonthNoTime,'mmmm yyyy')#">
	
	<cfset monthforqueries = #DateFormat(today,'mmm')#>
<cfelse>
	<!--- use this month --->
	<cfset currentmonth = "#DateFormat(NOW(),'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',NOW())#">
	<cfset currentd = "#DatePart('d',NOW())#">
	<!--- as of 10/13/2005 make current day equal to yesterday, so current day does not show up on FTA --->
	<Cfif currentd is not "1">
		<cfset currentd = currentd - 1>
	<cfelse>
		<!--- if current day is first of month, must show last month's FTA --->
		<cfset minusonemonth = #DateAdd('m',-1,currentmonth)#>
		<cfset minusonemonth = #DateFormat(minusonemonth,'mmmm yyyy')#>
		<cfoutput>
			<cflocation url="expensespenddown.cfm?subaccount=#SubAccountNumber#&iHouse_ID=#url.iHouse_ID#&DatetoUse=#minusonemonth#">
		</cfoutput>
	</Cfif>
	<cfset currenty = "#DatePart('yyyy',NOW())#">
	<cfset monthforqueries = #DateFormat(currentm,'mmm')#>
	<cfset currentmy = "#currentm#/#currenty#">
	<cfset currentdim = "#DaysInMonth(currentmy)#">
	<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
	<cfset currentfullmonthNoTime = "#currentm#/01/#currenty#">
	<cfset lastdayofDateToUse = "#currentm#/#currentd#/#currenty#">
	<!--- if this is the first day of the NOW month, then use TODAY as the lastdayofdatetouse, otherwise, use yesterday --->
	<cfif isDefined("url.datetouse") and DateFormat(datetouse,'m/yyyy') is DateFormat(NOW(),'m/yyyy')><cfset monthnowmonth = "Yes"></cfif>
	<cfif not isDefined("url.datetouse")><cfset monthnowmonth = "Yes"></cfif>
	<cfif isDefined("monthnowmonth")>
		<cfif DatePart('d',NOW()) is "1">
			<cfset lastdayofdatetouse = "#DateFormat(NOW(),'M/D/YYYY')#">
		<cfelse>
			<!--- use yesterday --->
			<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse,'M/D/YYYY')#">
		</cfif>
	</cfif>
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,NOW())#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(NOW(),'M/D/YYYY')#">
	<cfset datetouse = "#DateFormat(NOW(),'mmmm yyyy')#">
	
	<cfset monthforqueries = #DateFormat(today,'mmm')#>
</cfif>
<cfoutput>
<SCRIPT language="javascript">
	var minTableHeight = 510;
	var overrideTableHeight = false;
	var tableHeightPct = 100;
	if (#currentd# < 12)
	{
		overrideTableHeight = true;
		minTableHeight = (#currentd# * 22) + 224;
		tableHeightPct = (tableHeightPct - 12) + #currentd#;
	}

	var aw = screen.availWidth;
	var ah = screen.availHeight;
	window.moveTo(0, 0);
	window.resizeTo(aw, ah);
        
 	function doSel(obj)
 	{
 	    for (i = 1; i < obj.length; i++)
   	    	if (obj[i].selected == true)
           		eval(obj[i].value);
 	}
 	function getFooterTop()
	{
		if (document.getElementById("tbl-container").scrollWidth > document.getElementById("tbl-container").offsetWidth)
			return (document.getElementById("tbl-container").scrollTop + document.getElementById("tbl-container").offsetHeight - document.getElementById("tbl-container").scrollHeight - 16);
		else
			return (document.getElementById("tbl-container").scrollTop + document.getElementById("tbl-container").offsetHeight - document.getElementById("tbl-container").scrollHeight);			
	}
	function getReportTableHeight()
	{
		var tableHeight = screen.availHeight - 240;
		
		if (overrideTableHeight == false)
		{
			if (tableHeight > minTableHeight)
			{
				return (tableHeight);
			}
			else 
			{
				return (minTableHeight);
			}
		}
		else
		{
			return (minTableHeight);
		}
	}
	function getReportTablePct()
	{
		return ((tableHeightPct) + "%");
	}
</SCRIPT>
</cfoutput>
</head>

<!--- For Testing ONLY - Remove the FTSds Set block after testing. --->
	<cfset FTAds = "FTA_TEST">
<!--- ------------------------------------------------------------ --->
<cffunction name="getTrainingHoursForMonth" access="public" displayname="getTrainingHoursForMonth"
			description="Returns the available Training Hours for the entire Month."
			returnType="Numeric">
<cfargument name="iBudgetDollars" type="Numeric">
<cfargument name="iHouseId" type="Numeric">
<cfargument name="iYear" type="Numeric">
<cfargument name="iMonthName" type="String">

	<!--- Fetch the Budget Wage Rates. --->
	<cfquery name="dsGetKitchenBWR" datasource="#ComshareDS#">
		SELECT 
			*
		FROM 
			ALC.FINLOC_BASE
		WHERE
			year_id = #iYear# AND
			Line_id = 80000097 AND
			unit_id = #iHouseId# AND
			ver_id = 1 AND
			Cust1_id = 0 AND
			Cust2_id = 0 AND
			Cust3_id = 80000007 AND
			Cust4_id = 0	
	</cfquery>
	<cfquery name="dsGetRCBWR" datasource="#ComshareDS#">
		SELECT 
			*
		FROM 
			ALC.FINLOC_BASE
		WHERE
			year_id = #iYear# AND
			Line_id = 80000097 AND
			unit_id = #iHouseId# AND
			ver_id = 1 AND
			Cust1_id = 0 AND
			Cust2_id = 0 AND
			Cust3_id = 80000004 AND
			Cust4_id = 0
	</cfquery>
	
	<cfset kitchenBWRMonth = "dsGetKitchenBWR.#iMonthName#">
	<cfset residentCareBWRMonth = "dsGetRCBWR.#iMonthName#">
	
	<!--- Instantiate the Budget Wage Rates. --->
	<cfset residentCareBWR = #evaluate(residentCareBWRMonth)#>
	<cfset kitchenBWR = #evaluate(kitchenBWRMonth)#>
	
	<cfscript>
		// Instantiate the Percentage Constants.
		residentCarePct = 0.86;
		kitchenPct = 0.14;
		// Set the availabe Resident Care Hours from the Budget Dollars.
		residentCareHours = ((iBudgetDollars * residentCarePct) / residentCareBWR);
		// Set the available Kitchen Hours from the Budget Dollars.
		kitchenHours = ((iBudgetDollars * kitchenPct) / kitchenBWR);
		
		// Set the total available training hours for the Month for both Resident Care and Kitchen.
		availableTrainingHoursMTD = (residentCareHours + kitchenHours);

		// Return the available Training Hours per Day.
		return (availableTrainingHoursMTD);
		
	</cfscript>	
</cffunction>

<cffunction name="getTrainingHoursPD" access="public" displayname="getTrainingHoursPD"
			description="Returns the available Training Hours on a Per Day basis (average)."
			returnType="Numeric">
<cfargument name="iBudgetDollars" type="Numeric">
<cfargument name="iDayMTD" type="Numeric">
<cfargument name="iHouseId" type="Numeric">
<cfargument name="iYear" type="Numeric">
<cfargument name="iMonthName" type="String">	
	<cfscript>
		
		// Get the Available Training Hours for the entire Month.
		pdAvailableTrainingHoursMTD = getTrainingHoursForMonth(iBudgetDollars, iHouseId, iYear, iMonthName);
		// Set the available Training Hours Per Day.
		pdAvailableTrainingHoursPD = (pdAvailableTrainingHoursMTD / iDayMTD);
		
		// Return the available Training Hours per Day.
		return (pdAvailableTrainingHoursPD);
		
	</cfscript>	
</cffunction>

<!--- Fetch the current user's custom settings and add the user if he/she does NOT exists with default settings.' --->
<cfset freezeBottom = "0">
<cfif isDefined("session.EID") and Session.EID is not "">	
	<!--- get subaccount from AD --->
	<cfif not isDefined("url.iHouse_ID")>
		<!--- get admin's subaccount from AD --->
		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
		<cfset SubAccountNumber = #FindSubAccount.company#>
		<cfquery name="getSubAccount" datasource="TIPS4">
			SELECT 
				cGLsubaccount, 
				EHSIFacilityID 
			FROM 
				HOUSE 
			WHERE 
				dtRowDeleted IS NULL AND 
				cGLSubAccount = '#SubAccountNumber#'
		</cfquery>
		<cfset EHSIFacilityID = #trim(getSubAccount.EHSIFacilityID)#>	
		<cfset HouseNumber = #trim(getSubAccount.EHSIFacilityID)#>	
	<cfelse>
		<form name="whatever">
		<!--- url.iHouse_ID is defined, so this is an AP person coming in pretending to be a house --->
		<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,Name" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
		<!--- <strong><font face="arial">Welcome, AP Administrator, <cfoutput>#FindSubAccount.Name#</cfoutput>! </font></strong> --->
		<cfquery name="getSubAccount" datasource="TIPS4">
			SELECT 
				cGLsubaccount, 
				EHSIFacilityID
			FROM 
				HOUSE 
			WHERE 
				dtRowDeleted IS NULL AND 
				iHouse_ID = #url.iHouse_ID#
		</cfquery>
		<cfset SubAccountNumber = #trim(getSubAccount.cGLsubaccount)#>	
		<cfset HouseNumber = #trim(getSubAccount.EHSIFacilityID)#>	
	</cfif>

	<cfif (FindSubAccount.recordcount is 0 AND #SESSION.EID# is not "temp") OR (FindSubAccount.company is "" AND #SESSION.EID# is not "temp")>
		<center><H3><font color="red" face="arial">Sorry, your Active Directory Account has not yet been set up with a SubAccount.  Please contact IT.
		</font></H3></center>
		<cfabort>
	</cfif>
<cfelseif isDefined("session.EID") and Session.EID is "">
	<center><H3><font color="red" face="arial">You do not have a EID set up in Active Directory and cannot access this application.<BR>
	If you need access to the Online FTA, please contact the Help Desk and have them enter your EID in your network account.
	</font></H3></center>
	<cfabort>
<cfelse>
	<center><H3><font color="red" face="arial">You must be logged in with your network name and password to access the Online FTA.<BR>
	<A href="/intranet/loginindex.cfm">Please try again</A>
	</font></H3></center>
	<cfabort>
</cfif>

<font face="arial">

<Cfif session.ADdescription contains "RDO">
	<cfset RDOposition = #Find("RDO",SESSION.ADdescription)#>
	<cfset endposition = rdoposition + 5>
	<cfset regionname = #removechars(SESSION.ADdescription,1,endposition)#>
	<cfquery name="findOpsAreaID" datasource="prodTips4">
		SELECT 
			iOpsArea_ID, 
			cName
		FROM
			OpsArea
		WHERE
			dtRowDeleted IS NULL AND
			cName = '#Trim(RegionName)#'
	</cfquery>
	<cfif findOpsAreaID.recordcount is not "0">
		<cfset RDOrestrict = #findOpsAreaID.iOpsArea_ID#>
	</cfif>
</Cfif>
<div id="dvHouseHeader">
<cfif FindSubAccount.company is 0>
	<cfquery name="getHouses" datasource="TIPS4">
		SELECT
			cName,
			iHouse_ID
		FROM
			HOUSE
		WHERE
			dtRowDeleted IS NULL 
		<Cfif isDefined("RDOrestrict")>
			AND iOpsArea_ID = #RDOrestrict#
		</Cfif>
		ORDER BY
			cName
	</cfquery>
	View FTA for House: 
	<cfoutput>
		<select name="iHouse_ID" onchange="doSel(this)">
		<option value=""></option>
		<cfloop query="getHouses">
			<option value="location.href='labortracking.cfm?iHouse_ID=#iHouse_ID#'"
					<cfif (isDefined("url.iHouse_ID") AND url.iHouse_ID IS "#getHouses.iHouse_ID#")>
						 SELECTED
					</cfif>>
					#cName#
			</option>
		</cfloop>
		</select><HR align=left size=2 width=580 color="##0066CC">
		</form>
	</cfoutput>
	<cfif not isdefined("url.iHouse_ID")><cfabort></cfif>
<cfelse>
	<cfset SubAccountNumber = #FindSubAccount.company#>
</cfif>

<!--- based on House Name, get the Ops Area they're in --->
<cfquery name="LookUpSubAcct" datasource="TIPS4">
	SELECT
		iOpsArea_ID,
		cName,
		cGLsubaccount,
		iHouse_ID
	FROM
		House
	WHERE
		cGLSubAccount = '#SubAccountNumber#'
</cfquery>

</div>
<body>
	

<cfoutput>
<font face="arial">
<h3>Online FTA- <font color="##C88A5B">Labor Tracking Report-</font> <font color="##0066CC">#Lookupsubacct.cName#-</font> <Font color="##7F7E7E">#DateFormat(currentfullmonthnotime,'mmmm yyyy')#</font></h3>

<form method="post" action="labortracking.cfm">

<cfset Page="labortracking">
<Table id="tblMenu" border=0 cellpadding=0 cellspacing=0>
	<td>
		<cfinclude template="menu.cfm">
	</td>
	<td>&##160; <font size=-1><A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A>
		<p><BR>
		&##160; Month to View: <cfset x = DateFormat(NOW(),'mmmm yyyy')>
		<cfset y = "November 2004">
		<select name="datetouse" onchange="doSel(this)">
			<option value="">
			</option>
			<cfloop condition="#DateCompare(x,y,'m')# GTE 0">
				<option value="location.href='labortracking.cfm?iHouse_ID=#LookUpSubAcct.iHouse_ID#&DateToUse=#DateFormat(x,'mmmm yyyy')#'"
						<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> 
						SELECTED
						</cfif>>
					#DateFormat(x,'mmmm yyyy')#
				</option>
				<cfset x = #DateAdd('m',-1,x)#>
			</cfloop>
		</select>
	</td>
</Table>
<p>

<cfquery name="checkiftmptableexists" datasource="willowtempdb">
	SELECT 
		* 
	FROM
		SYSOBJECTS
	WHERE
		NAME LIKE '%##employeesBreakdown%'
</cfquery>

<cfif checkiftmptableexists.recordcount is not "0">
	<!--- rsa - wrapped in try/catch to avaoid error being thrown --->
	<cftry>
		<cfquery name="droptmp" datasource="adpeet">
			DROP TABLE 
				#checkiftmptableexists.name#
		</cfquery> 
	<cfcatch>
		<cfset errorMessage = cfcatch.Message>
	</cfcatch>
	</cftry>
</cfif>

<cfquery name="checkiftmptable2exists" datasource="willowtempdb">
	SELECT
		* 
	FROM
		SYSOBJECTS
	WHERE
		NAME LIKE '%##employees2Breakdown%'
</cfquery>

<cfif checkiftmptable2exists.recordcount is not "0">
	<cftry>
		<cfquery name="droptmp2" datasource="adpeet">
		DROP TABLE
			#checkiftmptable2exists.name#
		</cfquery>
	<cfcatch>
		<cfset errorMessage = cfcatch.Message>
	</cfcatch>
	</cftry>
</cfif>

<!--- rsa - 1/21/2006 - need to check for employeesbreakdown before inserting into it--->	
<cftry>
	<cfquery name="CheckForTable" datasource="adpeet">
		SELECT 
			TOP 1 * 
		FROM 
			##employeesBreakdown
	</cfquery>
	<cfif CheckForTable.RecordCount gt 0>
		<cfquery name="DropTempTable" datasource="adpeet">
			DROP TABLE
				##employeesBreakdown
		</cfquery>
	</cfif>
<cfcatch>
	<cfset errorMessage = "Table doesn't exist">
</cfcatch>
</cftry>
	
<cfquery name="breakdown" datasource="adpeet">
	SELECT  
		VP_ALLTOTALS.PERSONFULLNAME, 
		VP_ALLTOTALS.WFCLABORLEVELDSC6 as CATEGORY, 
		VP_ALLTOTALS.WFCLABORLEVELNAME6 as DEPT_NUM, 
		sum(VP_ALLTOTALS.WFCTIMEINSECONDS) as SECONDS, 
		VP_ALLTOTALS.PERSONNUM, 
		VP_ALLTOTALS.PAYCODENAME,
		VP_ALLTOTALS.APPLYDATE
 	INTO
		##employeesBreakdown
	FROM	
		VP_ALLTOTALS WITH (NOLOCK)  
	WHERE	
		VP_ALLTOTALS.APPLYDATE between '#currentfullmonthNoTime#' and '#lastdayofdatetouse#' AND
		VP_ALLTOTALS.WFCLABORLEVELNAME5  = '#getSubAccount.EHSIFacilityID#' AND  	
		((VP_ALLTOTALS.WFCTIMEINSECONDS <> 0 AND VP_ALLTOTALS.PAYCODENAME IN ('Travel Time', 'Regular', 'Overtime', 'OnCall Hrs Wked' , 'Holiday Worked','Reg Hrs - Prior Period')) OR  	
		(VP_ALLTOTALS.PAYCODENAME = '$OnCall Bonus' AND VP_ALLTOTALS.WFCMONEYAMOUNT <> 0)) AND 
		VP_ALLTOTALS.WFCLABORLEVELNAME6 <> '41002' <!--- wellndess director exclude --->
	GROUP BY 
		VP_ALLTOTALS.PERSONFULLNAME, 
		VP_ALLTOTALS.WFCLABORLEVELDSC6, 
		VP_ALLTOTALS.WFCLABORLEVELNAME6, 
		VP_ALLTOTALS.PERSONNUM, 
		VP_ALLTOTALS.PAYCODENAME, 
		VP_ALLTOTALS.APPLYDATE
	ORDER BY 
		VP_ALLTOTALS.PERSONFULLNAME ASC
</cfquery>

<cfquery name="getColumns" datasource="#ftads#">
	SELECT
		* 
	FROM
		LaborCategory
	WHERE 
		vcRowDeleted is null 
	ORDER BY 
		iOrder
</cfquery>
<cfset CategoryList = #ValueList(getColumns.vcLaborCategory)#>
<cfset CategoryList = #ListAppend(CategoryList,"Administrators")#>
<cfset Dept_Num_List_All = "41015,41016,41017,41018,41019,41075,41009,41011,41070,41013,41020,41022,41023,41024,41027,41034,41040,41041,41035,41036,41037,41038,41078,41030,41031,41032,41033,41003,41050,41051,41007,41042">

<!--- set all training, PTO and Other hours into another temp table --->
<cfquery name="breakdown2" datasource="adpeet">
	SELECT  
		VP_ALLTOTALS.PERSONFULLNAME, 
		VP_ALLTOTALS.WFCLABORLEVELDSC6 as CATEGORY, 
		VP_ALLTOTALS.WFCLABORLEVELNAME6 as DEPT_NUM, 
		sum(VP_ALLTOTALS.WFCTIMEINSECONDS) as SECONDS, 
		VP_ALLTOTALS.PERSONNUM, 
		VP_ALLTOTALS.PAYCODENAME,
		VP_ALLTOTALS.APPLYDATE
	INTO	
		##employees2breakdown
	FROM	
		VP_ALLTOTALS WITH (NOLOCK)  
	WHERE	
		VP_ALLTOTALS.APPLYDATE between '#currentfullmonthNoTime#' and '#lastdayofdatetouse#'<!--- 10/14/05: changed from #TODAY#, because doing one day old ---> AND  	
		VP_ALLTOTALS.WFCLABORLEVELNAME5  = '#getSubAccount.EHSIFacilityID#' AND 
		VP_ALLTOTALS.WFCLABORLEVELNAME6 <> '41002' <!--- wellndess director exclude ---> AND 
		VP_ALLTOTALS.PAYCODENAME NOT IN ('All Hours and Earnings','All Hours Applied','Leave PayCodes') AND  	
		((VP_ALLTOTALS.WFCTIMEINSECONDS <> 0 AND VP_ALLTOTALS.PAYCODENAME = 'PTO') OR
 		(VP_ALLTOTALS.WFCLABORLEVELNAME6 NOT IN (#ListQualify(Dept_Num_List_All,"'")#)) OR
		(VP_ALLTOTALS.WFCTIMEINSECONDS <> 0 AND VP_ALLTOTALS.PAYCODENAME = 'Training'))
	GROUP BY 
		VP_ALLTOTALS.PERSONFULLNAME, VP_ALLTOTALS.WFCLABORLEVELDSC6, VP_ALLTOTALS.WFCLABORLEVELNAME6, VP_ALLTOTALS.PERSONNUM, VP_ALLTOTALS.PAYCODENAME, VP_ALLTOTALS.APPLYDATE
	ORDER BY 
		VP_ALLTOTALS.PERSONFULLNAME ASC
</cfquery>


<cfquery name="breakdown2select" datasource="adpeet">
	select 
		* 
	from 
		##employees2breakdown
</cfquery>

<cfquery name="getRCPRCD" datasource="#ComshareDS#">
	select 
		P0
	from 
		ALC.FINLOC_BASE
	where
		year_id=	#currenty# 	and
		Line_id=	80000117 	and
		unit_id=	#LookupSubAcct.iHouse_ID#	and
		ver_id=		1			and
		Cust1_id=	0			and
		Cust2_id=	0			and
		Cust3_id=	80000004	and
		Cust4_id=	0
</cfquery>
<!--- RESIDENT CARE HOURS PER RESIDENT CARE DAYS --->
<cfset RCHPRCD = #getRCPRCD.P0#>

<!--- calculate actual daily occupancy for each day of this month so far --->
<cfset MTDoccupancy = 0><cfset MTDoccupancyR = 0>
<cfloop from=1 to="#currentd#" index="dayx">
	<Cfset todaysdate = "#currentm#/#dayx#/#currenty#">
	<cfquery name="getoccupancy" datasource="prodtips4">
		Select 
			iUnitsOccupied, 
			iTenants 
		From 
			HouseOccupancy 
		Where 
			dtOccupancy = '#todaysdate#' And 
			cType = 'B' And 
			iHouse_ID = #lookupsubacct.iHouse_ID# 
	</cfquery>
	<cfif getoccupancy.recordcount is not "0">
		<!--- Report based on tenant NOT units for PRD. Leaving var name the same.  01/27/2009 --->
		<!--- cfset MTDoccupancy = #getOccupancy.iUnitsOccupied# + #MTDoccupancy#--->
		<cfset MTDoccupancy = #getOccupancy.iTenants# + #MTDoccupancy#>
		<cfset MTDoccupancyR = #getOccupancy.iTenants# + #MTDoccupancyR#>
	</cfif>
</cfloop>

<cfif getoccupancy.recordcount is not "0">
	<cfset AveMTDoccupancyR = #MTDoccupancyR# / #currentd#>
	<cfset AveMTDoccupancyR = #round(AveMTDoccupancyR)#>
</cfif>

<!--- set up QueryNew for totalling Category totals and finding variance --->
<cfset QueryForCategoryTotals = #QueryNew("Day,Category,Amount")#>
<cfset QueryForCategoryGrandTotal = #QueryNew("Category,Amount,BudgetOrActual")#>

<!--- calculate actual daily occupancy for each day of this month so far --->
<cfset MTDoccupancy = 0>
<cfloop from=1 to="#currentd#" index="dayx">
	<Cfset todaysdate = "#currentm#/#dayx#/#currenty#">
	<cfquery name="getoccupancy" datasource="prodtips4">
		select iUnitsOccupied, iTenants from HouseOccupancy where dtOccupancy = '#todaysdate#' and cType = 'B' and iHouse_ID = #lookupsubacct.iHouse_ID# 
	</cfquery>
	<cfif getoccupancy.recordcount is not "0">
		<!--- Report based on tenants NOT units for PRD. Leaving var name the same.  01/27/2009 --->
		<!--- cfset MTDoccupancy = #getOccupancy.iUnitsOccupied# + #MTDoccupancy#--->
		<cfset MTDoccupancy = #getOccupancy.iTenants# + #MTDoccupancy#>
	</cfif>
</cfloop>

<cfset budgetcellcolor = "##ffff99">
<cfset dailybudgetcellcolor = "##DADADA">
<cfset dailybudgetcellcolor = "##ffff99">

<!--- Display the Freeze Pane Links --->


<div id="tbl-container">
<table id="tbl" cellspacing="0" cellpadding="1" border="1px">

<thead>
<tr>
<th class="locked" colspan=1 bgcolor="##0066CC">&##160;</th>
<cfloop query="getColumns">
	<!--- The Nursing Sub-Total columns will be placed before kitchen services. --->
	<cfif vcLaborCategory is "Kitchen">
		<th bgcolor="##0066CC" colspan=3><font size=-1 color="white">Nursing Totals</th>	
	</cfif>
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">	
			<th bgcolor="##0066CC" colspan=3>
		<cfelse>
			<th bgcolor="##0066CC" colspan=2>
		</cfif>
		<font size=-1 color="white">
	<cfelse>
		<th bgcolor="##0066CC"><font size=-1 color="white">
	</cfif>
	#vcDisplayName# Hours</th>
</cfloop>
<!--- Rearranged the order of these columns to match the NewDepartmentRollsToCategory spreadsheet. --->
<th bgcolor="##0066CC"><font size=-1 color="white">Other Hours</th>
<th bgcolor="##0066CC"><font size=-1 color="white">Training Hours</th>
<th bgcolor="##0066CC"><font size=-1 color="white">Total</th>
<th bgcolor="##0066CC"><font size=-2 color="white">Daily Hours Variance</th>
<th bgcolor="##0066CC"><font size=-1 color="white">PTO Hours</th>
</tr>
<!--- calculate category budget totals --->

<!--- BEGIN COLUMN BUDGET PROCESSING --->
<cfset QueryForCategoryHPRCD = #QueryNew("Category,Hours")#>

<cfset budgettotal = 0>
<cfset daytotalaccrue = 0>
<cfset DailyBudgetDayAccrueVarianceTotal = 0>

<!--- Used to accumulate the Nursing Budgets. --->
<cfset budgetNursingTotal = 0>

<cfloop query="getColumns">

	<cfif vcComshareLine_ID is 0>
		<font size=-1>0.0
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	<cfelse>
		<cfquery name="getCategoryBudget" datasource="#ComshareDS#">
			select P0
			from ALC.FINLOC_BASE
			where
			year_id=	#currenty# 		and
			Line_id=	80000117 	and
			unit_id=	#LookupSubAcct.iHouse_ID#		and
			ver_id=		1		and
			Cust1_id=	0		and
			Cust2_id=	0		and
			<!--- 12/22/08 bkubly - Replaced the equals sign with IN to support multiple Comshare numbers. --->
			Cust3_id IN  (#getColumns.vcComshareLine_ID#)	and 
			Cust4_id=	0		
		</cfquery>
		
		<cfset categoryforquery2 = "#getCategoryBudget.P0#">
		<cfset addrowTota = #QueryAddRow(QueryForCategoryHPRCD,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryHPRCD,"Category",getColumns.vcLaborCategory)#>
		
		<cfif categoryforquery2 eq "">
			<cfset categoryforquery2 = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryHPRCD,"Hours",categoryforquery2)#>

		<cfquery name="getCategoryAccumulator4Total" datasource="#ftaDS#">
				SELECT TOP 1
					bIsPD,
					bIsPRD
				FROM
					HouseBudgetAccumulator
				WHERE
					iHouseId = #LookupSubAcct.iHouse_ID# AND
					vcComshareLine_ID = '#getColumns.vcComshareLine_ID#'
		</cfquery>
		
		<cfif getCategoryAccumulator4Total.RecordCount is not "0">
			<cfif getCategoryAccumulator4Total.bIsPRD EQ True>
				<!-- these are hours per resident care day categories --->
				<cfif categoryforquery2 is ""><cfset categoryforquery2 ="0"></cfif>
				<cfset MTDCategoryBudgetHours = #MTDoccupancy# * #categoryforquery2#>

				<!--- Add the current Per Resident Day Nursing total to the budget nursing total if the category is Nursing. --->
				<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "LPN - LVN">
					<cfset budgetNursingTotal = #budgetNursingTotal# + #MTDCategoryBudgetHours#>
				</cfif>
			<cfelse>
				<!--- these are hours per day categories --->
				<cfif categoryforquery2 is ""><cfset categoryforquery2 ="0"></cfif>
				<cfset MTDCategoryBudgetHours = #currentD# * #categoryforquery2#>

				<!--- Add the current (Hours) Per Day Nursing total to the budget nursing total if the category is Nursing. --->
				<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
					<cfset budgetNursingTotal = #budgetNursingTotal# + #MTDCategoryBudgetHours#>
				</cfif>
			</cfif>
		</cfif>

		<cfset budgettotal = #budgettotal# + #MTDCategoryBudgetHours#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Regular")#>
		
		<cfif MTDCategoryBudgetHours eq "">
			<cfset MTDCategoryBudgetHours = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",MTDCategoryBudgetHours)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>

	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<!--- overtime --->
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Overtime")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<!--- other --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Other")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		</cfif>
	</cfif>
</cfloop>
<!--- OTHER --->
<cfset csdbudget = "0">

		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","OtherRegular")#>
		
		<cfif csdbudget eq "">
			<cfset csdbudget = 0>
		</cfif>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",csdbudget)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>		
<!--- TRAINING --->
<cfquery name="getTrainingBDM" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#currenty# 		and
Line_id=	4075 	and
unit_id=	#LookupSubAcct.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>


<cfset training = "getTrainingBDM.#monthforqueries#">

<cfset trainingBudgetHoursForMonth = #getTrainingHoursForMonth(evaluate(training), LookupSubAcct.iHouse_ID, currenty, monthforqueries)#>
<cfset trainingBudgetHoursPD = #trainingBudgetHoursForMonth# / #currentdim#>
<cfset trainingBudgetHoursMTD = #trainingBudgetHoursPD# * #currentd#>

<cfset training = #trainingBudgetHoursMTD#>

		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","TrainingRegular")#>
		
		<cfif evaluate(training) eq "">
			<cfset training = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",evaluate(training))#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
				
		<cfset budgetTotal = #budgetTotal# + #training#>
<!--- TOTAL | ##budgeted total hours --->
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
	
	<cfif budgettotal eq "">
		<cfset budgettotal = 0>
	</cfif>
	<cfset dailyBudgetTotal = #budgetTotal# / #currentd#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",budgettotal)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
<!--- VARIANCE --->

<!--- PTO --->
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","PTORegular")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>

<tr>
<cfset colspannumber = #getColumns.recordcount# + 2>
<th class="locked" bgcolor="f4f4f4" align=center>&##160;</th>
<cfloop query="getColumns">
	<!--- Add the Nursing Sub-Total Column Headers. --->
	<cfif vcLaborCategory is "Kitchen">
		<th bgcolor="f4f4f4" colspan=3 align=center><font size=-2>SUB-TOTALS</font></th>
	</cfif>
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<th bgcolor="f4f4f4" colspan=3 align=center>
		<cfelse>
			<th bgcolor="f4f4f4" colspan=2 align=center>
		</cfif>
		<font size=-2>HOURS WORKED</font></th>
	<cfelse>
		<th colspan=1 bgcolor="f4f4f4" align=center><font size=-1>&##160;</font></th>
	</cfif>
</cfloop>
<th bgcolor="f4f4f4">&##160;</th><th bgcolor="f4f4f4">&##160;</th><th bgcolor="f4f4f4">&##160;</th><th bgcolor="f4f4f4">&##160;</th><th bgcolor="f4f4f4">&##160;</th>
</tr>

<tr>
<th class="locked" bgcolor="f4f4f4" align=center><font size=-1>DAY</th>
<cfloop query="getColumns">
	<!--- The Nursing Sub-Total columns will be placed before kitchen services. --->
	<!--- Add the Nursing Sub-Total Column Headers. --->
	<cfif vcLaborCategory is "Kitchen">
		<th colspan=1 bgcolor="#budgetcellcolor#"><font size=-1>Budget</font></th>
		<th colspan=1 bgcolor="f4f4f4"><font size=-1>Actual</font></th>
		<th colspan=1 bgcolor="f4f4f4"><font size=-1>Variance</font></th>		
	</cfif>
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<th bgcolor="f4f4f4"><font size=-1>Regular</th><th bgcolor="f4f4f4"><font size=-1>Overtime</th>
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<th bgcolor="f4f4f4"><font size=-1>Other</th>
		</cfif>
	<cfelse>
		<th bgcolor="f4f4f4"><font size=-1>&##160;</th>
	</cfif>
</cfloop>
<th bgcolor="f4f4f4">&##160;</th>
<th bgcolor="f4f4f4">&##160;</th>
<th bgcolor="f4f4f4">&##160;</th>
<th bgcolor="f4f4f4">&##160;</th>
<th bgcolor="f4f4f4">&##160;</th>
</tr>
</thead>
<!--- SHOW DETAILS - ALL DAYS UP TO THE CURRENT DAY OR THE END OF THE MONTH --->
<cfset variancecellcolor = "##ccffff">

<tbody>
<!--- loop through all days up through today --->
<cfloop from=1 to="#currentd#" index="dayx">
	<cfset DailyBudgetDayAccrue = 0>
	<!--- find todays's occupancy and calculate RDM based off of that --->
	<cfset theAMdateforQuery = "#currentm#/#dayx#/#currenty#">
	<cfset onedaylater = "#DateAdd('d',1,theAMdateforQuery)#">
	<cfset onedaylater = "#DateFormat(onedaylater,'M/D/YYYY')#">
	<cfset onedaylater = "#onedaylater# 12:00:00AM">
	<cfset daytotal = 0>
	<!--- <cfset thePMdateforQuery = "#currentm#/#dayx#/#currenty# 12:59:59PM"> --->
	<Cfset todaysdate = "#currentm#/#dayx#/#currenty#">
	<!--- Fetch the Occupancy Data for Per Resident Day Calculations --->
	<cfquery name="getoccupancy" datasource="prodtips4">
		SELECT 
			iUnitsOccupied, 
			iTenants 
		FROM 
			HouseOccupancy 
		WHERE 
			dtOccupancy = '#todaysdate#' AND 
			cType = 'B' AND 
			iHouse_ID = #lookupsubacct.iHouse_ID# 
	</cfquery>
	<!--- find Resident Day Months (daily occupancy for each day in month) --->
	<cfif getoccupancy.recordcount is not "0">
		<!--- rsa - 1/17/06 - changed logic to only do math if values are numeric --->
		<cfif isNumeric(getoccupancy.iTenants) AND isNumeric(RCHPRCD)>
			<cfset RCHDailyBudget = #getoccupancy.iTenants# * #RCHPRCD#>
		<cfelse>
			<cfset RCHDailyBudget = 0>
		</cfif>
		<!--- rsa - 1/17/06 - changed logic to only do math if values are numeric --->
		<cfif IsNumeric(DailyBudgetDayAccrue) AND IsNumeric(RCHDailyBudget)>
			<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #RCHDailyBudget#>
		<cfelse>
			<cfset DailyBudgetDayAccrue = 0>
		</cfif>
	</cfif>
	<!--- Update the Nursing Daily Budger Accumulator. 
	<cfset nursingDailyBudgetTotal = #nursingDailyBudgetTotal# + #RCHDailyBudget#> --->
	
	<tr>
	<!--- get today's occupancy and multiply it by the budgeted food expense per resident day --->
	<td class="locked" bgcolor="f4f4f4" align=center><font size=-1>#dayx#
	
	<!--- Stores the total number of hours worked for all Nursing categories, which includes Regular, Overtime, and Other. --->
	<cfset nursingTotalHours = 0>
	<!--- Accumulates the current days budget for all Nursing Categories. --->
	<cfset nursingBudgetTotalHours = 0>	
	
	<!--- loop through labor categories --->
	<Cfloop query="getColumns">
		<!--- 4/19/05: Set Dept_Num's (41000) to equivilate to vcLaborCategory (Administrator) --->
		<cfif vcLaborCategory is "Administrator"><cfset Dept_Num_List = "41000">
		<cfelseif vcLaborCategory is "MA - AA"><cfset Dept_Num_List = "41003,41050,41051">
		<cfelseif vcLaborCategory is "Nurse Consultant"><cfset Dept_Num_List = "41013">
		<cfelseif vcLaborCategory is "LPN - LVN"><cfset Dept_Num_List = "41009,41011,41070">
		<cfelseif vcLaborCategory is "Resident Care"><cfset Dept_Num_List = "41012,41015,41016,41017,41018,41019,41075">
		<cfelseif vcLaborCategory is "Kitchen"><cfset Dept_Num_List = "41020,41022,41023,41024,41027">
		<cfelseif vcLaborCategory is "Maintenance"><cfset Dept_Num_List = "41030,41031,41032,41033">
		<cfelseif vcLaborCategory is "Housekeeping"><cfset Dept_Num_List = "41035,41036,41037,41038,41078">
		<cfelseif vcLaborCategory is "Activities"><cfset Dept_Num_List = "41034,41040,41041">
		</cfif> 
		<!--- Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">			
			<cfquery name="getCategoryBudget4Day" datasource="#ComshareDS#">
				select P0
				from ALC.FINLOC_BASE
				where
				year_id=	#currenty# 		and
				Line_id=	80000117 	and
				unit_id=	#LookupSubAcct.iHouse_ID#		and
				ver_id=		1		and
				Cust1_id=	0		and
				Cust2_id=	0		and
				<!--- 12/22/08 bkubly - Replaced the equals sign with IN to support multiple Comshare numbers. --->
				Cust3_id IN  (#getColumns.vcComshareLine_ID#)	and 
				Cust4_id=	0		
			</cfquery>
			<cfquery name="getCategoryAccumulator" datasource="#ftaDS#">
					SELECT TOP 1
						bIsPD,
						bIsPRD
					FROM
						HouseBudgetAccumulator
					WHERE
						iHouseId = #LookupSubAcct.iHouse_ID# AND
						vcComshareLine_ID = '#getColumns.vcComshareLine_ID#'
			</cfquery>
			
			<cfset currentCategoryDailyBudget = 0>
			
			<cfif getCategoryBudget4Day.RecordCount is not "0">
				<cfset currentCategoryDailyBudget = #getCategoryBudget4Day.P0#>
			</cfif>
			
			<cfif getCategoryAccumulator.RecordCount is not "0">
				<cfif getCategoryAccumulator.bIsPRD EQ True>
					<cfset currentCategoryDailyBudget = #currentCategoryDailyBudget# * #getOccupancy.iTenants#>
				</cfif>
			</cfif>
			
			<cfset nursingBudgetTotalHours = #nursingBudgetTotalHours# + #currentCategoryDailyBudget#>
		</cfif>
		<!--- Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
		<cfif vcLaborCategory is "Kitchen">
			<cfset nursingDailyVariance = #nursingBudgetTotalHours# - #nursingTotalHours#>
			<td align=right bgcolor="#budgetcellcolor#"><font size=-1>#NumberFormat(nursingBudgetTotalHours, "0.00")#</font></td>
			<td align=right><font size=-1>#NumberFormat(nursingTotalHours, "0.0")#</font></td>
			<td align=right><cfif nursingDailyVariance LT 0><font size=-1 color="red"><cfelse><font size=-1></cfif>
			#NumberFormat(nursingDailyVariance, "0.00")#</font></td>			
		</cfif>
		
		<cfquery name="findabc" dbtype="query">select Hours from QueryForCategoryHPRCD where Category = '#vcLaborCategory#'</cfquery>
		
		<cfif vcLaborCategory is "Housekeeping" or vcLaborCategory is "LPN - LVN">
			<!--- take daily occupancy * hours per resident care day --->
			<cfif findabc.recordcount is "0" or findabc.Hours is ""><cfset findabcHours ="0"><cfelse><cfset findabchours = #findabc.Hours#></cfif>
			<cfif getoccupancy.recordcount is not "0">
				<cfset CategoryHDailyBudget = #getoccupancy.iTenants# * #findabchours#>
				<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #CategoryHDailyBudget#>
			</cfif>
		<cfelse>
			<cfif findabc.recordcount is "0" or findabc.Hours is ""><cfset findabcHours ="0"><cfelse><cfset findabchours = #findabc.Hours#></cfif>
			<cfset CategoryHDailyBudget = #findabcHours#>
			<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #CategoryHDailyBudget#>
		</cfif>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<cfquery name="findDayLaborCategoryRegular" datasource="adpeet">
				Select 
					Sum(Cast(seconds As Float))/3600 As Hours 
				From 
					##employeesBreakdown 
				Where 
					ApplyDate = '#theAMdateforQuery#' And 
					Dept_Num In (#ListQualify(Dept_Num_List,"'")#) And 
					PayCodeName In ('Regular', 'Holiday Worked'
					<cfif vcLaborCategory is 'Kitchen'>
						,'Travel Time', 'OnCall Hrs Wked','Reg Hrs - Prior Period', '$OnCall Bonus'
					</cfif>)
			</cfquery> 
			<cfif findDayLaborCategoryRegular.Hours is "" OR findDayLaborCategoryRegular.recordcount is "0"><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategoryRegular.Hours#></cfif>
			<!--- if labor category is Nurse Consultant, could be salaried hours, so check QueryForSalaried query --->
			<!--- added by Katie on 1/28/05: Now all labor categories could have salaried allocation hours, so check QueryForSalaried for ALL --->
				<cfif vcLaborCategory is "Nurse Consultant">
					<cfset salarytitletouse = "RN Consultant">
				<cfelseif vcLaborCategory is "Resident Care">
					<cfset salarytitletouse = "PSA">
				<cfelseif vcLaborCategory is "LPN - LVN">
					<cfset salarytitletouse = "LPN-LVN">
				<cfelseif vcLaborCategory is "Kitchen">
					<cfset salarytitletouse = "Cook">
				</cfif>
			<!--- <cfif vcLaborCategory is "Nurse Consultant"> --->
				<cfif isDefined("QueryForSalaried")>
					<cfquery name="CheckSalariedForJob" dbtype="query">
						select 
							title, sum(hours) as TotalJobHours 
						from 
							QueryForSalaried 
						where 
							Title like '%#salarytitletouse#%' 
						group by 
							title
					</cfquery><!--- <cfdump var="#CheckSalariedForNursing#"> --->
					<cfif CheckSalariedForJob.recordcount is "0" OR CheckSalariedForJob.TotalJobHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#NumberFormat(CheckSalariedForJob.TotalJobHours, "0.0")#"></cfif>
					<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			<!--- </cfif> --->
			<td align=right>
			<cfset TotalAmountDayCategory = 0>
			<cfif findDayLaborCategoryRegular.recordcount is not "0" OR isDefined("CheckSalariedforJob")>
				<font size=-1>#NumberFormat(HoursToAdd, "0.0")#</td>
				<!--- Update the Nursing Total Hours Accumulator. --->
				<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
					<cfset nursingTotalHours = #nursingTotalHours# + #HoursToAdd#>
				</cfif>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>
		
			<cfquery name="findDayLaborCategoryOvertime" datasource="adpeet">
				Select 
					Sum(Cast(seconds As Float))/3600 As Hours 
				From 
					##employeesBreakdown 
				Where 
					ApplyDate = '#theAMdateforQuery#' And 
					Dept_Num In (#ListQualify(Dept_Num_List,"'")#) And 
					PayCodeName = 'Overtime';
			</cfquery> 
			<td align=right>
			<cfset TotalAmountDayCategory = 0>
			<cfif findDayLaborCategoryOvertime.recordcount is not "0">
				<font size=-1>#NumberFormat(findDayLaborCategoryOvertime.Hours, "0.0")# <cfif findDayLaborCategoryOvertime.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategoryOvertime.Hours#></cfif></td>
				<!--- Update the Nursing Total Hours Accumulator. --->
				<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
					<cfset nursingTotalHours = #nursingTotalHours# + #HoursToAdd#>
				</cfif>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Overtime")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>
			<!--- Kitchen Services does NOT report the "Other" column. --->
			<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
				<cfquery name="findDayLaborCategoryOther" datasource="adpeet">
					Select 
						Sum(Cast(seconds As Float))/3600 As Hours 
					From 
						##employeesBreakdown 
					Where 
						ApplyDate = '#theAMdateforQuery#' And 
						Dept_Num In (#ListQualify(Dept_Num_List,"'")#) And 
						PayCodeName In ('Travel Time', 'OnCall Hrs Wked','Reg Hrs - Prior Period')
						<!--- PayCodeName <> 'Overtime' and PayCodeName <> 'Regular' --->
				</cfquery> 
				<td align=right>
				<cfset TotalAmountDayCategory = 0>
				<cfif findDayLaborCategoryOther.recordcount is not "0">
					<font size=-1>#NumberFormat(findDayLaborCategoryOther.Hours, "0.0")#<cfif findDayLaborCategoryOther.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategoryOther.Hours#></cfif></td>
					<!--- Update the Nursing Total Hours Accumulator. --->
					<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
						<cfset nursingTotalHours = #nursingTotalHours# + #HoursToAdd#>
					</cfif>
					<cfset daytotal = #daytotal# + #HoursToAdd#>
					<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Other")#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
				</cfif>
			</cfif>
		<Cfelse>
		<!--- just the total for category, no matter the subcategory --->
			<cfquery name="findDayLaborCategory" datasource="adpeet">
				select sum(cast(seconds as float))/3600 as Hours from ##employeesBreakdown where ApplyDate = '#theAMdateforQuery#' and Dept_Num IN (#ListQualify(Dept_Num_List,"'")#) 
			</cfquery> 
			<cfif findDayLaborCategory.Hours is ""><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategory.Hours#></cfif>
			<!--- if labor category is Administrator or MA - AA, could be salaried hours, so check QueryForSalaried query --->
			<cfif vcLaborCategory is "Administrator">
				<cfif isDefined("QueryForSalaried")><!-- note: this isn't working right for paris oaks --->
					<cfquery name="CheckSalariedForAdmin" dbtype="query">
						select title, sum(hours) as TotalAdminHours from QueryForSalaried where (Title like 'Administrator%' OR Title like '%Regional Dir Operations%') group by title
					</cfquery><!--- <cfdump var="#CheckSalariedForAdmin#"> --->
					<cfif CheckSalariedForAdmin.recordcount is "0" OR CheckSalariedForAdmin.TotalAdminHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#NumberFormat(CheckSalariedForAdmin.TotalAdminHours, '0.0')#"></cfif>
					<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			</cfif>
			<cfif vcLaborCategory is "MA - AA">
				<cfif isDefined("QueryforSalaried")>
				<cfquery name="CheckSalariedForMAAA" dbtype="query">
					select 
						title, 
						sum(hours) as TotalMAAAHours 
					from 
						Qu
							q1eryForSalaried 
					where (Title like 'Assistant Administrator%' OR Title like 'Management Assistant%') group by title
				</cfquery><!--- <cfdump var="#CheckSalariedForMAAA#"> ---> 
				<cfif CheckSalariedForMAAA.recordcount is "0" OR CheckSalariedForMAAA.TotalMAAAHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#NumberFormat(CheckSalariedForMAAA.TotalMAAAHours, '0.0')#"></cfif>
				<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			</cfif>
			<cfif vcLaborCategory is "Activities">                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
				<cfif isDefined("QueryforSalaried")>
				<cfquery name="CheckSalariedForActivities" dbtype="query">
					select title, sum(hours) as TotalActivitiesHours from QueryForSalaried where (Title like '%Activity Services Coordinator%') group by title
				</cfquery><!--- <cfdump var="#CheckSalariedForActivities#"> --->
				<cfif CheckSalariedForActivities.recordcount is "0" OR CheckSalariedForActivities.TotalActivitiesHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForActivities.TotalActivitiesHours)#"></cfif>
				<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			</cfif>
			<cfif vcLaborCategory is "Housekeeping">
				<cfif isDefined("QueryforSalaried")>
				<cfquery name="CheckSalariedForHK" dbtype="query">
					select title, sum(hours) as TotalHKHours from QueryForSalaried where (Title like '%Houskeeping%') group by title
				</cfquery><!--- <cfdump var="#CheckSalariedForHK#"> --->
				<cfif CheckSalariedForHK.recordcount is "0" OR CheckSalariedForHK.TotalHKHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForHK.TotalHKHours)#"></cfif>
				<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			</cfif>
			<cfif vcLaborCategory is "Maintenance">
				<cfif isDefined("QueryforSalaried")>
				<cfquery name="CheckSalariedForMaint" dbtype="query">
					select title, sum(hours) as TotalMaintHours from QueryForSalaried where (Title like '%Maintenance%') group by title
				</cfquery><!--- <cfdump var="#CheckSalariedForMaint#"> --->
				<cfif CheckSalariedForMaint.recordcount is "0" OR CheckSalariedForMaint.TotalMaintHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForMaint.TotalMaintHours)#"></cfif>
				<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			</cfif>
			<td align=right>
			<cfset TotalAmountDayCategory = 0>
			<cfif findDayLaborCategory.recordcount is not "0" OR isDefined("CheckSalariedForAdmin") OR isDefined("CheckSalariedForMAAA")>
				<font size=-1>#NumberFormat(HoursToAdd, "0.0")#</td>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>
		</cfif>
	</Cfloop>
	<!--- other hours --->
	<cfquery name="findOtherHours" datasource="adpeet">
		Select sum(cast(seconds as float))/3600 as Hours from ##employees2breakdown where <!--- Category NOT IN (#ListQualify(CategoryList,"'")#) ---> Dept_Num NOT IN (#ListQualify(Dept_Num_List_All,"'")#) and ApplyDate = '#theAMdateforQuery#' and Dept_Num <> '41001' and Dept_Num IN ('41007','41042')<!--- community sales ---> and paycodename = 'Worked Hours'
	</cfquery> 
	<cfif findOtherHours.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findOtherHours.Hours#></cfif>
	<!--- Could also be salaried hours, so check QueryForSalaried query (Admin-Memory Care, etc.) --->
	<cfif isDefined("QueryForSalaried")>
		<cfquery name="CheckSalariedForOther" dbtype="query">
			select title, sum(hours) as TotalOtherHours from QueryForSalaried where Title not like '%RN Consultant%' and title not like '%Administrator%' and title not like '%Management Assistant%' and title not like '%Assistant Administrator%' group by title
		</cfquery>
		<cfif CheckSalariedForOther.recordcount is "0" OR CheckSalariedForOther.TotalOtherHours is "">
			<cfset HoursToAddSalaried = "0">
		<cfelse>
			<cfloop query="checksalariedforother">
				<cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForOther.TotalOtherHours)#">
				<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
			</cfloop>
		</cfif>
	</cfif>

	<td align=right><font size=-1>#NumberFormat(HoursToAdd, "0.0")#<!--- <cfif isDefined("findOtherHoursCategories")><BR><cfloop query="FindOtherHoursCategories"><font size=-2>#findOtherHoursCategories.CATEGORY#, </font></cfloop></cfif> ---></td>
	<cfset daytotal = #daytotal# + #HoursToAdd#>
	<cfset CategoryHDailyBudget = #HoursToAdd#>
	<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #CategoryHDailyBudget#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category","OtherRegular")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#> 	
	<!--- training --->
	<cfquery name="findTrainingHours" datasource="adpeet">
		Select sum(cast(seconds as float))/3600 as Hours from ##employees2breakdown where PayCodeName = 'Training' and ApplyDate = '#theAMdateforQuery#'
	</cfquery> 
	<td align=right><font size=-1>#NumberFormat(findTrainingHours.Hours, "0.0")#</td>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category","TrainingRegular")#>
				<cfif findTrainingHours.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findTrainingHours.Hours#></cfif>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
	<!--- Full Day's total --->
	<td align=right><font size=-1><strong>#NumberFormat(daytotal, "0.0")#</strong></td>
	<cfset DayTotalAccrue = #DayTotalAccrue# + #daytotal#>
	<cfset DailyBudgetDayAccrueVariance = #Evaluate(dailyBudgetTotal - DayTotal)#>
	<!--- DAILY VARIANCE --->
	<td align=right bgcolor="#variancecellcolor#"><font size=-1><cfif DailyBudgetDayAccrueVariance LT 0><font color="red"></cfif><strong>#NumberFormat(DailyBudgetDayAccrueVariance, "0.0")#</strong></td></font>
	<cfset DailyBudgetDayAccrueVarianceTotal = DailyBudgetDayAccrueVarianceTotal + DailyBudgetDayAccrueVariance>
	<!--- PTO --->
	<cfquery name="findPTOHours" datasource="adpeet">
		Select sum(cast(seconds as float))/3600 as Hours from ##employees2breakdown where PayCodeName = 'PTO' and ApplyDate = '#theAMdateforQuery#'
	</cfquery> 
	<td align=right><font size=-1>#NumberFormat(findPTOHours.Hours, "0.0")#</td>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category","PTORegular")#>
				<cfif findPTOHours.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findPTOHours.Hours#></cfif>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
	<!--- END PTO --->	
	</tr>
</cfloop>

<!--- month-to-date totals --->
<tfoot>
	<tr>
<cfset totalcellcolor="##9CCDCD">
<td class="locked" align=right bgcolor="#totalcellcolor#"><font size=-1><strong>Total</strong></td>

<!--- Accumulates the nursing MTD actual totals. --->
<cfset nursingMtdActualTotal = 0>

<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<!--- Check if the current Category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
		<cfif vcLaborCategory is "Kitchen">
			<cfset nursingMtdVariance = #budgetNursingTotal# - #nursingMtdActualTotal#>
			<td bgcolor="#totalcellcolor#" align=right><font size=-1><strong>#NumberFormat(budgetNursingTotal, "0.0")#</strong></font></td>
			<td bgcolor="#totalcellcolor#" align=right><font size=-1><strong>#NumberFormat(nursingMtdActualTotal, "0.0")#</strong></font></td>
			<td bgcolor="#totalcellcolor#" align=right><cfif nursingMtdVariance LT 0><font size=-1 color="red"><cfelse><font size=-1></cfif><strong>#NumberFormat(nursingMtdVariance, "0.0")#</strong></font></td>
		</cfif>
		
		<td align=right bgcolor="#totalcellcolor#">

		<cfquery name="GetCategoryTotalRegular" dbtype="query">
			Select 
				Sum(Amount) As TotalAmount 
			From 
				queryforCategoryTotals 
			Where 
				Category = '#trim(getColumns.vcLaborCategory)#Regular' 
			Group By 
				Category
		</cfquery>
		<font size=-1><strong>#NumberFormat(GetCategoryTotalRegular.TotalAmount, "0.0")#</strong></td>
		<!--- Update the Nursing MTD Actual Total Accumulator, if the current Category is NOT Kitchen. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<cfset nursingMtdActualTotal = #nursingMtdActualTotal# + #GetCategoryTotalRegular.TotalAmount#>
		</cfif>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
			
		<cfif GetCategoryTotalRegular.TotalAmount eq "">
			<cfset GetCategoryTotalRegular.TotalAmount = 0>
		</cfif>
			
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalRegular.TotalAmount)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
			
		<td align=right bgcolor="#totalcellcolor#">

		<cfquery name="GetCategoryTotalOvertime" dbtype="query">
			Select 
				Sum(Amount) As TotalAmount 
			From 
				queryforCategoryTotals 
			Where 
				Category = '#trim(getColumns.vcLaborCategory)#Overtime' 
			Group By 
				Category
		</cfquery>
		<font size=-1><strong>#NumberFormat(GetCategoryTotalOvertime.TotalAmount,"0.0")#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Overtime")#>
			
			<cfif GetCategoryTotalOvertime.TotalAmount eq "">
				<cfset GetCategoryTotalOvertime.TotalAmount = 0>
			</cfif>
			<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
				<cfset nursingMtdActualTotal = #nursingMtdActualTotal# + #GetCategoryTotalOvertime.TotalAmount#>
			</cfif>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalOvertime.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<td align=right bgcolor="#totalcellcolor#">
			<cfquery name="GetCategoryTotalOther" dbtype="query">
				Select 
					Sum(Amount) As TotalAmount 
				From 
					queryforCategoryTotals 
				Where 
					Category = '#trim(getColumns.vcLaborCategory)#Other' 
				Group By 
					Category
			</cfquery>
			<font size=-1><strong>#NumberFormat(GetCategoryTotalOther.TotalAmount, "0.0")#</strong></td>
			<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Other")#>
			
			<cfif GetCategoryTotalOther.TotalAmount eq "">
				<cfset GetCategoryTotalOther.TotalAmount = 0>
			</cfif>
			<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
				<cfset nursingMtdActualTotal = #nursingMtdActualTotal# + #GetCategoryTotalOther.TotalAmount#>
			</cfif>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalOther.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
		</cfif>
	<Cfelse>
		<td align=right bgcolor="#totalcellcolor#">

		<cfquery name="GetCategoryTotal" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = '#trim(getColumns.vcLaborCategory)#Regular' Group by Category
		</cfquery>
		<font size=-1><strong>#NumberFormat(GetCategoryTotal.TotalAmount, "0.0")#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
			
			<cfif GetCategoryTotal.TotalAmount eq "">
				<cfset GetCategoryTotal.TotalAmount = 0>
			</cfif>
			
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotal.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
	</cfif>
</cfloop>

	<!--- Other day total --->
		<td align=right bgcolor="#totalcellcolor#">
		<cfquery name="GetCategoryTotalOther" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = 'OtherRegular' Group by Category
		</cfquery>
		<font size=-1><strong>#NumberFormat(GetCategoryTotalOther.TotalAmount, "0.0")#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","OtherRegular")#>
			
			<cfif GetCategoryTotalOther.TotalAmount eq "">
				<cfset GetCategoryTotalOther.TotalAmount = 0>
			</cfif>
			
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalOther.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
				
	<!--- training day total --->
		<td align=right bgcolor="#totalcellcolor#">
		<cfquery name="GetCategoryTotalTraining" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = 'TrainingRegular' Group by Category
		</cfquery>
		<font size=-1><strong>#NumberFormat(GetCategoryTotalTraining.TotalAmount, "0.0")#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","TrainingRegular")#>
			
			<cfif GetCategoryTotalTraining.TotalAmount eq "">
				<cfset GetCategoryTotalTraining.TotalAmount = 0>
			</cfif>
			
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalTraining.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>

<!--- the actual daily total of all categories so far this month --->
<td align=right bgcolor="#totalcellcolor#"><B><font size=-1>#NumberFormat(DayTotalAccrue, "0.0")#</font></B></td>
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
	
	<cfif DayTotalAccrue eq "">
		<cfset DayTotalAccrue = 0>
	</cfif>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",DayTotalAccrue)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
	
	<!--- Daily Hours Variance --->
	<td align=right bgcolor="#totalcellcolor#"><B><font size=-1><cfif DailyBudgetDayAccrueVarianceTotal LT "0"><font color="red"></cfif>#NumberFormat(DailyBudgetDayAccrueVarianceTotal, "0.0")#</font></B></td>
	
	<!--- PTO day total --->
		<td align=right bgcolor="#totalcellcolor#">
		<cfquery name="GetCategoryTotalPTO" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = 'PTORegular' Group by Category
		</cfquery>
		<font size=-1><strong>#NumberFormat(GetCategoryTotalPTO.TotalAmount, "0.0")#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","PTORegular")#>
			
			<cfif GetCategoryTotalPTO.TotalAmount eq "">
				<cfset GetCategoryTotalPTO.TotalAmount = 0>
			</cfif>
			
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalPTO.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>

</tr>
<!--- display category budget totals --->
<tr>
<td class="locked" bgcolor="#budgetcellcolor#" align=right><font size=-1>MTD Budget</td>

<!--- BEGIN COLUMN BUDGET PROCESSING --->
<cfset QueryForCategoryHPRCD = #QueryNew("Category,Hours")#>

<cfset budgettotal = 0>
<cfset daytotalaccrue = 0>
<cfset DailyBudgetDayAccrueVarianceTotal = 0>

<!--- Used to accumulate the Nursing Budgets. --->
<cfset budgetNursingTotal = 0>

<cfloop query="getColumns">
	<!--- The Nursing Sub-Total columns will be placed before kitchen services. --->
	<cfif vcLaborCategory is "Kitchen">
		<td align=right bgcolor="#budgetcellcolor#"><font size=-1>#NumberFormat(budgetNursingTotal, "0.0")#</font></td>
		<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.0</font></td>
		<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.0</font></td>
	</cfif>	
	<td align=right bgcolor="#budgetcellcolor#">
	<cfif vcComshareLine_ID is 0>
		<font size=-1>0.0
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	<cfelse>
		<cfquery name="getCategoryBudget" datasource="#ComshareDS#">
			select P0
			from ALC.FINLOC_BASE
			where
			year_id=	#currenty# 		and
			Line_id=	80000117 	and
			unit_id=	#LookupSubAcct.iHouse_ID#		and
			ver_id=		1		and
			Cust1_id=	0		and
			Cust2_id=	0		and
			<!--- 12/22/08 bkubly - Replaced the equals sign with IN to support multiple Comshare numbers. --->
			Cust3_id IN  (#getColumns.vcComshareLine_ID#)	and 
			Cust4_id=	0		
		</cfquery>
		
		<cfset categoryforquery2 = "#getCategoryBudget.P0#">
		<cfset addrowTota = #QueryAddRow(QueryForCategoryHPRCD,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryHPRCD,"Category",getColumns.vcLaborCategory)#>
		
		<cfif categoryforquery2 eq "">
			<cfset categoryforquery2 = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryHPRCD,"Hours",categoryforquery2)#>

		<cfquery name="getCategoryAccumulator4Total" datasource="#ftaDS#">
				SELECT TOP 1
					bIsPD,
					bIsPRD
				FROM
					HouseBudgetAccumulator
				WHERE
					iHouseId = #LookupSubAcct.iHouse_ID# AND
					vcComshareLine_ID = '#getColumns.vcComshareLine_ID#'
		</cfquery>
		
		<cfif getCategoryAccumulator4Total.RecordCount is not "0">
			<cfif getCategoryAccumulator4Total.bIsPRD EQ True>
				<!-- these are hours per resident care day categories --->
				<cfif categoryforquery2 is ""><cfset categoryforquery2 ="0"></cfif>
				<cfset MTDCategoryBudgetHours = #MTDoccupancy# * #categoryforquery2#>
				<font size=-1>#NumberFormat(MTDCategoryBudgetHours, "0.0")#
				<!--- Add the current Per Resident Day Nursing total to the budget nursing total if the category is Nursing. --->
				<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "LPN - LVN">
					<cfset budgetNursingTotal = #budgetNursingTotal# + #MTDCategoryBudgetHours#>
				</cfif>
			<cfelse>
				<!--- these are hours per day categories --->
				<cfif categoryforquery2 is ""><cfset categoryforquery2 ="0"></cfif>
				<cfset MTDCategoryBudgetHours = #currentD# * #categoryforquery2#>
				<font size=-1>#NumberFormat(MTDCategoryBudgetHours, "0.0")#
				<!--- Add the current (Hours) Per Day Nursing total to the budget nursing total if the category is Nursing. --->
				<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
					<cfset budgetNursingTotal = #budgetNursingTotal# + #MTDCategoryBudgetHours#>
				</cfif>
			</cfif>
		</cfif>

		<cfset budgettotal = #budgettotal# + #MTDCategoryBudgetHours#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Regular")#>
		
		<cfif MTDCategoryBudgetHours eq "">
			<cfset MTDCategoryBudgetHours = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",MTDCategoryBudgetHours)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>
	</td>
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<!--- overtime --->
		<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.0</font></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Overtime")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<!--- other --->
			<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.0</font></td>
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Other")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		</cfif>
	</cfif>
</cfloop>
<!--- OTHER --->
<cfset csdbudget = "0">
<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.0</font></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","OtherRegular")#>
		
		<cfif csdbudget eq "">
			<cfset csdbudget = 0>
		</cfif>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",csdbudget)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>		
<!--- TRAINING --->
<cfquery name="getTrainingBDM" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#currenty# 		and
Line_id=	4075 	and
unit_id=	#LookupSubAcct.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset training = "getTrainingBDM.#monthforqueries#">


<cfset trainingBudgetHoursForMonth = #getTrainingHoursForMonth(evaluate(training), LookupSubAcct.iHouse_ID, currenty, monthforqueries)#>
<cfset trainingBudgetHoursPD = #trainingBudgetHoursForMonth# / #currentdim#>
<cfset trainingBudgetHoursMTD = #trainingBudgetHoursPD# * #currentd#>

<cfset training = #trainingBudgetHoursMTD#>

<td align=right bgcolor="#budgetcellcolor#"><font size=-1>#NumberFormat(evaluate(training), "0.0")#</font></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","TrainingRegular")#>
		
		<cfif evaluate(training) eq "">
			<cfset training = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",evaluate(training))#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		
		<cfset budgetTotal = #budgetTotal# + #training#>
<!--- TOTAL | ##budgeted total hours --->
<td align=right bgcolor="#budgetcellcolor#"><font size=-1>#NumberFormat(budgettotal, "0.0")#</font></td>
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
	
	<cfif budgettotal eq "">
		<cfset budgettotal = 0>
	</cfif>
	
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",budgettotal)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
<!--- VARIANCE --->
<td bgcolor="f4f4f4" align=center><font size=-2>&##160;</font></td>
<!--- PTO --->
<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.0</font></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","PTORegular")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
</tr>

<tr>
<!--- MTD Variance --->
<TD class="locked" colspan=1 align=right bgcolor="#variancecellcolor#"><font size=-1><b>MTD Variance</b></font></TD>
<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		
		<!--- Check if the current Category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
		<cfif vcLaborCategory is "Kitchen">
			<cfset nursingMtdVariance = #budgetNursingTotal# - #nursingMtdActualTotal#>
			<td colspan=3 align=center bgcolor="#variancecellcolor#"><cfif nursingMtdVariance LT 0><font size=-1 color="red"><cfelse><font size=-1></cfif><strong>
				#NumberFormat(nursingMtdVariance, "0.0")#</strong></font></td>
		</cfif>
		
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			Select 
				Amount As BudgetAmount 
			From 
				QueryForCategoryGrandTotal 
			Where 
				Category = '#trim(getColumns.vcLaborCategory)#Regular' And 
				BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			Select 
				Amount As ActualAmount 
			From 
				QueryForCategoryGrandTotal 
			Where 
				Category = '#trim(getColumns.vcLaborCategory)#Regular' And 
				BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
		</td>
		
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			Select 
				Amount As BudgetAmount 
			From 
				QueryForCategoryGrandTotal 
			Where 
				Category = '#trim(getColumns.vcLaborCategory)#Overtime' And 
				BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			Select 
				Amount As ActualAmount 
			From 
				QueryForCategoryGrandTotal 
			Where 
				Category = '#trim(getColumns.vcLaborCategory)#Overtime' And 
				BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
		</td>
		<!--- Kitchen Services does NOT report "Other" Hours. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<td align=right bgcolor="#variancecellcolor#">
			<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
				Select 
					Amount As BudgetAmount 
				From 
					QueryForCategoryGrandTotal 
				Where 
					Category = '#trim(getColumns.vcLaborCategory)#Other' And 
					BudgetOrActual = 'Budget'
			</cfquery>
			<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
				select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Other' and BudgetOrActual = 'Actual'
			</cfquery>
			<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
			<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
			<cfset variance = BA - AA>
			<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
			</td>
		</cfif>
	<cfelse>
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Regular' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Regular' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
		</td>
	</cfif>
</cfloop>
	<!--- Other variance --->
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = 'OtherRegular' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = 'OtherRegular' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
		</td>
	<!--- training variance --->
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = 'TrainingRegular' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = 'TrainingRegular' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
		</td>

<!--- grand total variance --->
<td align=right bgcolor="#variancecellcolor#">
	<cfquery name="GetCategoryGrandTotalBudgetTotal" dbtype="query">
		select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = 'Total' and BudgetOrActual = 'Budget'
	</cfquery>
	<cfquery name="GetCategoryGrandTotalActualTotal" dbtype="query">
		select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = 'Total' and BudgetOrActual = 'Actual'
	</cfquery>
	<cfset varianceTotal = GetCategoryGrandTotalBudgetTotal.BudgetAmount - GetCategoryGrandTotalActualTotal.ActualAmount>
	<font size=-1><strong><cfif varianceTotal LT 0><font color="red"></cfif>#NumberFormat(varianceTotal, "0.0")#</strong>
</td>
<td bgcolor="f4f4f4">&##160;</td>
	<!--- PTO variance --->
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = 'PTORegular' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = 'PTORegular' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#NumberFormat(variance, "0.0")#</strong>
		</td>
</tr>

<!-- WALLY WANTED THIS COMMENTED OUT TEMPORARILY - DO NOT DELETE!
<!--- get the 85% efficiency information and calcuate it based off of average occupancy and average points for this month-to-date --->
<cfif getoccupancy.recordcount is not "0">
	<cfset numberofaveresidents = "Residents#AveMTDoccupancyR#">
	
	<!--- rsa - there are errors being generated because the numberofaveresidents in some houses is greater
           than 60.  The StaffingGuidePositionResidents table only goes to 60.  I'll do some rounding.  This
		 is a temporary fix until we expand the staffingguidepositionresidents table  --->
	<cfif numberofaveresidents gt 60>
		<cfset numberofaveresidents = 60>
	</cfif>		        
	
	<cfquery name="getHouseAcuity" datasource="prodtips4">
		select sum(iSPoints) as TheSum, count(iResidentOccupancy_ID) as TheCount
		from ResidentOccupancy 
		where  dtOccupancy between '#currentfullmonthnotime#' and '#lastdayofdatetouse#'
		and iHouse_ID = #LookupSubAcct.iHouse_ID#
		and cType = 'B'
		and dtRowDeleted IS NULL
	</cfquery>
	<cfset avepoints = #getHouseAcuity.TheSum#/#GetHouseAcuity.TheCount#>
	<cfset avepoints = #round(avepoints)#>
	<tr>
	<td colspan=2 align=right><font size=-2>85% Efficiency (avepoints: #avepoints# averesidents: #AveMTDoccupancyR#)</td>
	<cfif #AveMTDoccupancyR# LT 20>
	<Td colspan=17><font size=-1 color="red">Sorry, the 85% Efficency Matrix only works if you have an average of 20 or more residents for the month.</font></Td>
	<cfelse>
	<cfloop query="getColumns">
		<!--- this is bi-weekly, so have to take the final number and divide by 14 then multiply times days in month to get actual hours --->
		            
		<cfif vcLaborCategory is "Administrator" or vcLaborCategory is "MA - AA" or vcLaborCategory is "Maintenance" or vcLaborCategory is "Kitchen" or vcLaborCategory is "Activities" or vcLaborCategory is "Nurse Consultant">
			<Cfquery name="FindEfficiency" datasource="#ftads#">
				select vcPosition, #numberofaveresidents# as ResColumn from StaffingGuidePositionResidents where iMinAvePoints IS NULL and vcPosition = '#vcLaborCategory#'
			</Cfquery>
			<Cfif FindEfficiency.recordcount is not "0">
				<cfset dailyefficiencyFixed = (#FindEfficiency.ResColumn#/14) * #currentd#>
			</Cfif>
			<cfset fixedorvar = "white">
		<cfelse>
			<Cfquery name="FindEfficiency" datasource="#ftads#">
				select vcPosition, #numberofaveresidents# as ResColumn from StaffingGuidePositionResidents where iMinAvePoints <= #avepoints# and iMaxAvePoints >= #avepoints#
			</Cfquery>
			<Cfif FindEfficiency.recordcount is not "0">
				<cfset dailyefficiencyFixed = (#FindEfficiency.ResColumn#/14) * #currentd#>
			</Cfif>
			<cfset fixedorvar = "##FFE8FF">
		</cfif>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<td colspan=3 align=center><font size=-1>
			<Cfif FindEfficiency.recordcount is not "0">
				<cfif vcLaborCategory is not "LPN - LVN">#decimalformat(dailyefficiencyFixed)#
					<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",vcLaborCategory&"Efficiency")#>
					
					<cfif dailyefficiencyFixed eq "">
						<cfset dailyefficiencyFixed = 0>
					</cfif>
					
					<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",dailyefficiencyFixed)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
				<cfelse>&##160;
				</cfif>
			<cfelse>
				0.00
			</Cfif>
			</td>
		<cfelse>
			<td align=right><font size=-1>
			<Cfif FindEfficiency.recordcount is not "0">
				<cfif vcLaborCategory is not "Housekeeping">#decimalformat(dailyefficiencyFixed)#
					<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",vcLaborCategory&"Efficiency")#>
					
					<cfif dailyefficiencyFixed eq "">
							<cfset dailyefficiencyFixed = 0>
					</cfif>
					
					<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",dailyefficiencyFixed)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
				<cfelse>*
				</cfif>
			<cfelse>
				0.00
			</Cfif>
			</td>
		</cfif>
	</cfloop>
	</cfif>
	</tr>
<cfelse>
<TR>
<td colspan=2 align=right><font size=-2>85% Efficiency:</td><td colspan=16 align=left><font size=-2 color="red">can't calculate 85% Efficiency without acuity available</td>
</TR>
</cfif>

<!--- variance of 85% Efficiency --->
<tr>
<td align=right bgcolor="#variancecellcolor#" colspan=2><font size=-2>85% Efficiency Variance</td>
	<cfloop query="getColumns">
		<cfquery name="GetCategoryEfficiencyActual" dbtype="query">
			select Amount as EfficiencyAmount from QueryForCategoryGrandTotal where Category = '#vclaborCategory#Efficiency' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfquery name="GetCategoryActualTotal" dbtype="query">
			select Amount from QueryForCategoryGrandTotal where (Category = '#vclaborCategory#Regular' OR Category = '#vclaborcategory#Overtime' OR category = '#vcLaborCategory#Other') and BudgetOrActual = 'Actual'
		</cfquery>
		<cfset actualamounttotal = 0>
		<cfloop query="GetCategoryActualTotal">
			<CFset ActualAmountTotal = #actualamounttotal# + #GetCategoryActualTotal.Amount#>
		</cfloop>
		<cfif GetCategoryEfficiencyActual.EfficiencyAmount is ""><cfset BAe = 0><Cfelse><cfset BAe = #GetCategoryEfficiencyActual.EfficiencyAmount#></cfif>
		<cfif ActualAmountTotal is "0"><cfset AAe = 0><Cfelse><cfset AAe = #ActualAmountTotal#></cfif>
		<cfset varianceEfficiency = BAe - AAe>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<td colspan=3 align=center bgcolor="#variancecellcolor#"><font size=-1>
			<cfif vcLaborCategory is not "LPN - LVN">
			<strong><cfif varianceEfficiency LT 0><font color="red"></cfif>#DecimalFormat(varianceEfficiency)#</strong>
			<cfelse>&##160;
			</cfif>
			</td>
		<cfelse>
			<td align=right bgcolor="#variancecellcolor#"><font size=-1>
			<cfif vcLaborCategory is not "Housekeeping">
			<strong><cfif varianceEfficiency LT 0><font color="red"></cfif>#dollarformat(varianceEfficiency)#</strong>
			<cfelse>&##160;
			</cfif>
			</td>
		</cfif>
	</cfloop>
</tr>
-->	
<!--- only show the below rows if actual average hourly wage rates exist in the AveHourlyWageRates table --->

<Cfquery name="FindAveHourlyWageRates" datasource="#ftads#">
	select * from AveHourlyWageRates where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#HouseNumber#' and dtRowDeleted IS NULL and (1 = 2)
</Cfquery>

<!--- if the above returns no records (say the auto process didn't run correctly), then try for the previous day --->
<cfif FindAveHourlyWageRates.recordcount is "0" and DatePart('d',datetouse) is not "1">
	<cfset lastdayofdatetouse = #DateAdd('d',-1,lastdayofdatetouse)#>
	<cfset lastdayofdatetouse = #DateFormat(lastdayofdatetouse,'M/D/YYYY')#>
	<Cfquery name="FindAveHourlyWageRates" datasource="#ftads#">
		select * from AveHourlyWageRates where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#HouseNumber#' and dtRowDeleted IS NULL 
	</Cfquery>
</cfif>
<cfif FindAveHourlyWageRates.recordcount is not "0">
	
	<tr>
	<td class="locked" bgcolor="f4f4f4" colspan=1 align=right><font size=-2>Actual Average Hourly Wage Rate</td>
	<cfloop query="getColumns">
		<Cfquery name="getAveHourlyWageRates" datasource="#ftads#">
			SELECT 
				SUM(Case When vcPayCodeName = 'Overtime' Then 
					((mAvg_rate*iTotalHours) * 1.5) 
				Else 
					(mAvg_rate*iTotalHours) 
				End) / 
						Case When Sum(iTotalHours) <> 0 Then 
							Sum(iTotalHours) 
						Else 
							999999999 
						End AS mAvg_rate
			FROM 
				AveHourlyWageRates 
			where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#HouseNumber#' 
			and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = '#getColumns.vcLaborCategory#'
		</Cfquery>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			
			<!--- Check if the labor category is Kitchen and insert 3 blank columns for the Nurse sub-total columns before Kitchen. --->
			<cfif vcLaborCategory is "Kitchen">
				<td colspan=3 align=center bgcolor="f4f4f4"><font size=-1>N/A</font></td>
			</cfif>
			
			<td colspan=3 align=center bgcolor="f4f4f4"><font size=-1>
			<Cfif getAveHourlyWageRates.recordcount is not "0" OR getAveHourlyWageRates.mAvg_rate is not "">
				#dollarformat(getAveHourlyWageRates.mAvg_rate)#
			<cfelse>
				$0.00
			</Cfif>
			</td>
		<cfelse>
			<td align=right bgcolor="f4f4f4"><font size=-1>
			<Cfif  getAveHourlyWageRates.recordcount is not "0" OR getAveHourlyWageRates.mAvg_rate is not "">
				#dollarformat(getAveHourlyWageRates.mAvg_rate)#
			<cfelse>
				$0.00
			</Cfif>
			</td>
		</cfif>
	</cfloop>
	</tr>
	
	
	<tr>
		
	<!--- Stores the accumulated MTD Budgeted Salary for Nursing. --->
	<cfset nursingMtdBudgetedSalaryTotal = 0>
	
	<td class="locked" colspan=1 align=right bgcolor="#budgetcellcolor#"><font size=-2>MTD- Budgeted Salary</td>
	<cfloop query="getColumns">
		<cfquery name="getBudgetedHoursOccupancy" dbtype="query">
			select 
				category, 
				amount, 
				budgetoractual 
			from 
				QueryForCategoryGrandTotal 
			where 
				category = '#getColumns.vcLaborCategory#Regular' and 
				budgetoractual = 'Budget'
		</cfquery>
		<cfquery name="getBWR" datasource="#ComshareDS#">
		select *
		from ALC.FINLOC_BASE
		where
		year_id=	#currenty# 		and
		Line_id=	80000097 	and
		unit_id=	#LookupSubAcct.iHouse_ID#		and
		ver_id=		1		and
		Cust1_id=	0		and
		Cust2_id=	0		and
		<!--- 12/22/08 bkubly - Replaced the equals sign with IN to support multiple Comshare numbers. --->
		<!--- Cust3_id IN  (#Replace(getColumns.vcComshareLine_ID, ",", "','", "All")#)	and --->
		Cust3_id IN  (#getColumns.vcComshareLine_ID#)	and 
		Cust4_id=	0
		</cfquery>
		<cfset monthforquery2 = "getBWR.#monthforqueries#">
		<cfif getBudgetedHoursOccupancy.recordcount is "0"><cfset BugHourOccAmount = 0><cfelse><cfset BugHourOccAMount = #getBudgetedHoursOccupancy.amount#></cfif>
		<cfset bwrcategory = #DecimalFormat(evaluate(monthforquery2))#>
		<cfset salarycategory = #bwrcategory# * #BugHourOccAMount#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",vcLaborCategory&"Salary")#>
		
		<cfif salarycategory eq "">
			<cfset salarycategory = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",salarycategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	
		<!--- Check if the current Category is Nursing (or NOT Kitchen) and add the mtd salary total to the nursing sub-total accumulator. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<cfset nursingMtdBudgetedSalaryTotal = #nursingMtdBudgetedSalaryTotal# + #salarycategory#>
		<cfelseif vcLaborCategory is "Kitchen">
			<!--- Add the Nursing Sub-Total's Accumulator to the Table. --->
			<td colspan=3 align=center bgcolor="#budgetcellcolor#"><font size=-1>
				#dollarformat(nursingMtdBudgetedSalaryTotal)#
			</font></td>
		</cfif>
		
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<td colspan=3 align=center bgcolor="#budgetcellcolor#"><font size=-1>
				#dollarformat(salarycategory)#
			</td>
		<cfelse>
			<td align=right bgcolor="#budgetcellcolor#"><font size=-1>
				#dollarformat(salarycategory)#
			</td>
		</cfif>
	</cfloop>
	</tr>
	
		
	<!--- Stores the accumulated MTD Actual Salary for Nursing. --->
	<cfset nursingMtdActualSalaryTotal = 0>
	
	<Tr>
	<td class="locked" colspan=1 align=right bgcolor="#totalcellcolor#"><font size=-2><strong>MTD- Actual Salary</strong></td>
	<cfloop query="getColumns">
		<cfquery name="getActualHoursOccupancy" dbtype="query">
			select * from QueryForCategoryGrandTotal where budgetoractual = 'Actual' and Category = '#getColumns.vcLaborCategory#Regular'
		</cfquery>
		<Cfquery name="getAveHourlyWageRatesForSalary" datasource="#ftads#">
			select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / case when sum(iTotalHours) <> 0 then sum(iTotalHours) else 999999999 end as mAvg_rate
			from AveHourlyWageRates 
			where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#HouseNumber#' 
			and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = '#getColumns.vcLaborCategory#'
		</Cfquery>
		<Cfif getAveHourlyWageRatesForSalary.mAvg_Rate is not ""><cfset ActualHoursOcc = #getAveHourlyWageRatesForSalary.mAvg_rate#><cfelse><cfset ActualHoursOcc = "0"></cfif>
		<Cfset ActualHoursOcc = #ActualHoursOcc# * #getActualHoursOccupancy.Amount#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",vcLaborCategory&"Salary")#>
		
		<cfif ActualHoursOcc eq "">
			<cfset ActualHoursOcc = 0>
		</cfif>
		
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",ActualHoursOcc)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
		
		<!--- Check if the current Category is Nursing (or NOT Kitchen) and add the mtd salary total to the nursing sub-total accumulator. --->
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<cfset nursingMtdActualSalaryTotal = #nursingMtdActualSalaryTotal# + #ActualHoursOcc#>
		<cfelseif vcLaborCategory is "Kitchen">
			<!--- Add the Nursing Sub-Total's Accumulator to the Table. --->
			<td colspan=3 align=center bgcolor="#budgetcellcolor#"><font size=-1>
				#dollarformat(nursingMtdActualSalaryTotal)#
			</font></td>
		</cfif>
		
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<td colspan=3 align=center bgcolor="#totalcellcolor#"><font size=-1>
				<strong>#dollarformat(ActualHoursOcc)#</strong>
			</td>
		<cfelse>
			<td align=right bgcolor="#totalcellcolor#"><font size=-1>
				<strong>#dollarformat(ActualHoursOcc)#</strong>
			</td>
		</cfif>
	</cfloop>
	</Tr>
	
	<!--- Stores the accumulated MTD Actual Salary Variance for Nursing. --->
	<cfset nursingMtdActualSalaryVarianceTotal = 0>
	
	<!--- variance of salary --->
	<tr>
	<td class="locked" align=right bgcolor="#variancecellcolor#" colspan=1><font size=-2>Salary Variance</td>
		<cfloop query="getColumns"> 
			<cfquery name="GetCategorySalaryBudget" dbtype="query">
				SELECT 
					Amount AS BudgetAmount 
				FROM 
					QueryForCategoryGrandTotal 
				WHERE 
					Category = '#vclaborCategory#Salary' AND 
					BudgetOrActual = 'Budget'
			</cfquery>
			<cfquery name="GetCategorySalaryActual" dbtype="query">
				SELECT 	
					Amount AS ActualAmount 
				FROM 
					QueryForCategoryGrandTotal 
				WHERE Category = '#vclaborCategory#Salary' AND 
				BudgetOrActual = 'Actual'
			</cfquery>
			<cfif GetCategorySalaryBudget.BudgetAmount is ""><cfset BAs = 0><Cfelse><cfset BAs = #GetCategorySalaryBudget.BudgetAmount#></cfif>
			<cfif GetCategorySalaryActual.ActualAmount is ""><cfset AAs = 0><Cfelse><cfset AAs = #GetCategorySalaryActual.ActualAmount#></cfif>
			<cfset variancesalary = BAs - AAs>
			
			<!--- Check if the current Category is Nursing (or NOT Kitchen) and add the mtd salary total variance to the nursing sub-total accumulator. --->
			<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
				<cfset nursingMtdActualSalaryVarianceTotal = #nursingMtdActualSalaryVarianceTotal# + #variancesalary#>
			<cfelseif vcLaborCategory is "Kitchen">
				<!--- Add the Nursing variance Sub-Total's Accumulator to the Table. --->
				<td colspan=3 align=center bgcolor="#budgetcellcolor#"><font size=-1>
					<strong><cfif variancesalary LT 0><font color="red"></cfif>#dollarformat(nursingMtdActualSalaryVarianceTotal)#</strong>
				</td>
			</cfif>
			
			<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<td colspan=3 align=center bgcolor="#variancecellcolor#"><font size=-1>
			<strong><cfif variancesalary LT 0><font color="red"></cfif>#dollarformat(variancesalary)#</strong>
			</td>
			<cfelse>
			<td align=right bgcolor="#variancecellcolor#"><font size=-1>
			<strong><cfif variancesalary LT 0><font color="red"></cfif>#dollarformat(variancesalary)#</strong>
			</td>
			</cfif>
		</cfloop>
	</tr>
<cfelse>
	<cfset colspannumber2 = #getColumns.recordcount# + 14>
	<!--- <td colspan=#colspannumber2# align=center></font></td> --->
</cfif>
</tfoot>
</tbody>
</table>
</div>
<div id="dvFooterMenu">
<font size=-2 face="arial">*See Resident Care Hours</font>

<font face="arial">
<p>
[ <A HREF="/intranet/fta/monthlyinvoices.cfm?iHouse_ID=#lookupSubAcct.iHouse_ID#&DateToUse=#DateToUse#">Monthly Invoices</A> | <A HREF="/intranet/fta/expensespenddown.cfm?subAccount=#SubAccountNumber#&DateToUse=#DateToUse#">Expense Spend-down</A> | <A HREF="/intranet/FTA/housereport.cfm?subAccount=#SubAccountNumber#&workingmonth=#currentfullmonthnotime#">House Report</A> | <A HREF="/intranet/FTA/default.cfm?iHouse_ID=#lookupSubAcct.iHouse_ID#&monthtouse=#DateFormat(currentfullmonthnotime,'mmmm yyyy')#">Budget Sheet</A> ]
</div>

<cftry>
	<cfquery name="droptmp" datasource="adpeet">
		drop table ##employeesBreakdown
	</cfquery>
	<cfquery name="droptmp2" datasource="adpeet">
		drop table ##employees2breakdown
	</cfquery>
<cfcatch>
	<cfset errormessage = cfcatch.Message>
</cfcatch>
</cftry>

<cfif session.username is "kdeborde" or session.username is "dummy">
<p>

<cfif isDefined("QueryForSalaried")>
<cfif isDefined("FindRowToUpdate.PersonNum")>
Allocated Person: #findrowtoupdate.PersonNum#<BR></cfif>
QueryForSalaried:<BR>
<cfdump var="#QueryForSalaried#"><BR></cfif>
Breakdown (reg E-Time hours):<BR>
<cfdump var="#breakdownselect#"><BR>
Breakdown2 (Training, PTO, Other E-Time hours):<BR>
<cfdump var="#breakdown2select#"><BR>
QueryForCategoryTotals:<BR>
<cfdump var="#queryforCategoryTotals#"><BR>
QueryForCategoryGrandTotal:<BR>
<cfdump var="#QueryForCategoryGrandTotal#">
</cfif>

</cfoutput>
</body>
</html>