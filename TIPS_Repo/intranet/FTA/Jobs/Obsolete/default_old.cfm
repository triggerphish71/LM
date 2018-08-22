<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- Budget Sheet</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<LINK REL=StyleSheet TYPE="Text/css"  HREF="fta.css">

<SCRIPT language="javascript">
<!--
function displayWindow(url, width, height) {
        var Win = window.open(url,"displayWindow",'width=' + width +
',height=' + height + ',resizable=1,scrollbars=yes,menubar=yes' );
}
//-->
				
 function doSel(obj)
 {
     for (i = 1; i < obj.length; i++)
        if (obj[i].selected == true)
           eval(obj[i].value);
}
</SCRIPT>

</head>

<body>

<cfif "1" is "0"><center><font color="red" size=+1><B>Sorry, the Online FTA is down because Comshare had to be taken down for Maintenance.<BR>
We are hoping everything will be back up and running by 6pm CST.<BR>Thank you for your patience.</B></font><p>
[ <A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Back to Network ALC Apps</A> ]</center><cfabort></cfif>

<cfif isDefined("session.EID") and Session.EID is not "">
	<!--- You are logged into the network as <cfoutput>#SESSION.EID#</cfoutput><BR> --->
	<!--- get jobcode --->
	<!--- <cfquery name="getJobCode" datasource="PROD">
	select J.PAYGROUP+J.FILE_NBR as EID, JC.DESCR
	FROM PS_JOB J
	INNER JOIN PS_JOBCODE_TBL JC ON J.JOBCODE = JC.JOBCODE
	WHERE J.PAYGROUP+J.FILE_NBR = '#SESSION.EID#'
	</cfquery>  --->
	
	<!--- get subaccount from AD --->
<cfif not isDefined("url.iHouse_ID")>
	<!--- get admin's subaccount from AD --->
	<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
	<cfset SubAccountNumber = #FindSubAccount.company#>
<cfelse>
	<form name="whatever">
	<!--- url.iHouse_ID is defined, so this is an AP person coming in pretending to be a house --->
	<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,Name" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
	<!--- <strong><font face="arial">Welcome, AP Administrator, <cfoutput>#FindSubAccount.Name#</cfoutput>! </font></strong> --->
	<cfquery name="getSubAccount" datasource="TIPS4">
	select cGLsubaccount from HOUSE where dtRowDeleted IS NULL and iHouse_ID = #url.iHouse_ID#
	</cfquery>
	<cfset SubAccountNumber = #trim(getSubAccount.cGLsubaccount)#>	
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

<!--- &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160;<img src="header.jpg"><BR> --->

<Cfif session.ADdescription contains "RDO">
	<cfset RDOposition = #Find("RDO",SESSION.ADdescription)#>
	<cfset endposition = rdoposition + 5>
	<cfset regionname = #removechars(SESSION.ADdescription,1,endposition)#>
	<cfquery name="findOpsAreaID" datasource="prodTips4">
		select iOpsArea_ID, cName from OpsArea where dtRowDeleted IS NULL and cName = '#Trim(RegionName)#'
	</cfquery>
	<cfif findOpsAreaID.recordcount is not "0">
		<cfset RDOrestrict = #findOpsAreaID.iOpsArea_ID#>
	</cfif>
</Cfif>

<cfif FindSubAccount.company is 0><!--- <cfset SubAccountNumber = "010315176"> --->
	<cfquery name="getHouses" datasource="TIPS4">
	select cName, iHouse_ID from HOUSE where dtRowDeleted IS NULL 
	<Cfif isDefined("RDOrestrict")>and iOpsArea_ID = #RDOrestrict#</Cfif>
	order by cName
	</cfquery>
	
	
View FTA for House: 
	<cfoutput>
		<select name="iHouse_ID" onchange="doSel(this)">
		<option value=""></option>
		<cfloop query="getHouses">
		<option value="location.href='default.cfm?iHouse_ID=#iHouse_ID#'"<cfif (isDefined("url.iHouse_ID") and url.iHouse_ID is "#getHouses.iHouse_ID#")> SELECTED</cfif>>#cName#</option>
		</cfloop>
		</select><HR align=left size=2 width=580 color="##0066CC">
		</form>
	</cfoutput>
	<cfif not isdefined("url.iHouse_ID")><cfabort></cfif>
<cfelse>
	<cfset SubAccountNumber = #FindSubAccount.company#>
</cfif>

<cfquery name="LookUpSubAcct" datasource="TIPS4">
	select cName from House where cGLSubAccount = '#SubAccountNumber#'
</cfquery>

<cfquery name="GetHouseInfo" datasource="TIPS4">
	select H.cNumber, H.cPhoneNumber1, H.cStateCode, R.cName , H.iHouse_ID, H.cSLevelTypeSet
	from House H
	inner join OpsArea O ON H.iOpsArea_ID = O.iOpsArea_ID
	inner join Region R on O.iRegion_ID = R.iRegion_ID
	 where H.cName = '#Trim(LookUpSubAcct.cName)#'
</cfquery>

<cfset HouseNumber = #right(subaccountnumber,3)#>

 	<cfstoredproc procedure="dbo.sp_GetEmployeeByTitle" datasource="PROD" RETURNCODE="YES" debug="Yes">
	<cfprocresult NAME="AdminName" resultset="1">
		<cfprocparam type="IN" value="Admnstor" DBVARNAME="@Title" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="IN" value="#GetHouseInfo.cNumber#" DBVARNAME="@Location" cfsqltype="CF_SQL_CHAR">
		<cfprocparam type="IN" value="#NOW()#" DBVARNAME="@dtEffective" cfsqltype="CF_SQL_TIMESTAMP">
		<cfprocparam type="OUT" variable="cAdministratorName" DBVARNAME="@cName" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="OUT" variable="OrigHire" DBVARNAME="@dtOrigHire" cfsqltype="CF_SQL_TIMESTAMP">
		<cfprocparam type="OUT" variable="Email" DBVARNAME="@cEmail" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="OUT" variable="PositionHire" DBVARNAME="@dtPositionHire" cfsqltype="CF_SQL_TIMESTAMP">
	</cfstoredproc> 
	
	<!--- this one will pull no Admin name if one is not currently active, but takes 3 seconds longer than above query that pulls last active admin name --->
	<!--- <cfstoredproc procedure="dbo.sp_GetEmployeeByTitlePIT" datasource="PROD" RETURNCODE="YES" debug="Yes">
	<cfprocresult NAME="AdminName" resultset="1">
		<cfprocparam type="IN" value="Admnstor" DBVARNAME="@Title" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="IN" value="#GetHouseInfo.cNumber#" DBVARNAME="@Location" cfsqltype="CF_SQL_CHAR">
		<cfprocparam type="IN" value="#NOW()#" DBVARNAME="@dtEffective" cfsqltype="CF_SQL_TIMESTAMP">
		<cfprocparam type="OUT" variable="cAdministratorName" DBVARNAME="@cName" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="OUT" variable="OrigHire" DBVARNAME="@dtOrigHire" cfsqltype="CF_SQL_TIMESTAMP">
		<cfprocparam type="OUT" variable="Email" DBVARNAME="@cEmail" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="OUT" variable="PositionHire" DBVARNAME="@dtPositionHire" cfsqltype="CF_SQL_TIMESTAMP">
		<cfprocparam type="OUT" variable="EnteredDate" DBVARNAME="@dtEntered" cfsqltype="CF_SQL_TIMESTAMP">
	</cfstoredproc> --->
	
<cfif not isDefined("url.datetouse")><cfset monthnowmonth = "Yes"></cfif>	
<cfif isDefined("url.datetouse") and DateFormat(datetouse,'m/yyyy') is DateFormat(NOW(),'m/yyyy')><cfset monthnowmonth = "Yes"></cfif>
<cfparam name="datetouse" default="#NOW()#">
<cfset monthforqueries = #DateFormat(datetouse,'mmm')#>
<cfset yearforqueries = #DateFormat(datetouse,'yyyy')#>
<cfset firstdayofdatetouse = "#DateFormat(datetouse,'mm')#/01/#DateFormat(datetouse,'yyyy')# 00:00:00">
<cfif isDefined("monthnowmonth")>
	<cfset lastdayofdatetouse = "#DateFormat(Now(), 'M/D/YYYY')#">
	<!--- if this is the first day of the NOW month, then use TODAY as the lastdayofdatetouse, otherwise, use yesterday --->
	<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse, 'M/D/YYYY')#">
		
	<cfif DatePart('d',NOW()) is "1">
		<cfset lastdayofdatetouse = "#DateFormat(NOW(),'M/D/YYYY')#">
	<cfelse><!--- use yesterday --->
		<cfset lastdayofdatetouse = "#DateAdd('d',-1,lastdayofdatetouse)#">
		<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse,'M/D/YYYY')#">
	</cfif>
	<!--- <cfif DatePart('d',firstdayofdatetouse) is "1"><cfset firstdayofdatetouse = #DateFormat(lastdayofdatetouse, 'M/D/YYYY')#></cfif> --->
<cfelse>
	<cfset daysinmonth2 = #DaysInMonth(datetouse)#>
	<cfset lastdayofdatetouse = "#DatePart('m',datetouse)#/#DaysInMonth2#/#DatePart('yyyy',datetouse)#">
</cfif>

<Font face="arial">

<cfoutput>
<h3>Online FTA- <font color="##C88A5B">Budget Sheet-</font> <font color="##0066CC">#LookUpSubAcct.cName#-</font> <Font color="##7F7E7E">#DateFormat(datetouse,'mmmm yyyy')#</Font></h3>

<cfset Page="setupsheet">
<Table border=0 cellpadding=0 cellspacing=0>
<td class="white">
<cfinclude template="menu.cfm">
</td>
<td align=left class="whiteleft">&##160; <font size=-1><A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A>
<p><BR>
&##160; Month to View: 
<cfset x = DateFormat(NOW(),'mmmm yyyy')>
<cfset y = "November 2004">
<select name="datetouse" onchange="doSel(this)"><option value=""></option><cfloop condition="#DateCompare(x,y,'m')# GTE 0"><option value="location.href='default.cfm?<cfif isDefined("url.iHouse_ID")>iHouse_ID=#url.iHouse_ID#&</cfif>DateToUse=#DateFormat(x,'mmmm yyyy')#'"<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> SELECTED</cfif>>#DateFormat(x,'mmmm yyyy')#</option><cfset x = #DateAdd('m',-1,x)#></cfloop></select>
<cfset themonth = #month(datetouse)#><cfset themonth = monthAsString(#themonth#)><!--- #themonth# #yearforqueries# ---> <font size=-1 color="red"><B>*Data is only valid through March 21st due to database changes*</B></font>
</td>
</Table>

<form name="FTA" action="submitFTA.cfm">

<table border=1 cellpadding=1 cellspacing=0>
<tr>
<td colspan=4 class="mainareaheader">#LookUpSubAcct.cName# #DateFormat(datetouse,'mmmm yyyy')#</td>
</tr>
<tr>
<td class="mainarea">Sub Account:</td><td class="generalleft">#SubAccountNumber#</td><td class="mainarea">State:</td><td class="generalleft">#GetHouseInfo.cSTATEcode#</td>
</tr>
<tr>
<td class="mainarea">Phone Number:</td><td class="generalleft"><cfset pn = #insert('-',gethouseinfo.cPhoneNumber1,6)#><cfset pn = #insert('-',pn,3)#>#pn#</td><TD class="mainarea">Administrator Name:</TD><td class="generalleft"><cfif cAdministratorName is ""><i>(No current Admin assigned in System)</i><cfelse>#cAdministratorName#</cfif></td>
</tr>
<tr>

<cfquery name="getHouseAcuity" datasource="prodtips4">
	select sum(iSPoints) as TheSum, count(iResidentOccupancy_ID) as TheCount
	from ResidentOccupancy 
	where  dtOccupancy = #DateAdd('d',-1,DateFormat(NOW(),'M/D/YY'))#
	and iHouse_ID = #GetHouseInfo.iHouse_ID#
	and cType = 'B'
	and dtRowDeleted IS NULL
</cfquery>
<cfif getHouseAcuity.TheCount is not "0">
	<cfset acuity = #getHouseAcuity.TheSum#/#GetHouseAcuity.TheCount#>
	<cfquery name="getLevelforAcuity" datasource="prodtips4">
		select cDescription from sleveltype where csleveltypeset = '#getHouseInfo.cSLevelTypeSet#' and iSpointsmin <= #acuity# AND iSpointsMax >= #acuity#
	</cfquery>
</cfif>

<td class="mainarea">House Acuity (from TIPS):</td><td class="generalleft"><cfif getHouseAcuity.TheCount is not "0">#NumberFormat(acuity,'__.__')# <font size=-1>(Level #getLevelforAcuity.cDescription#)</font><cfelse>N/A</cfif></td>
<td class="mainarea">Division:</td><td class="generalleft">#GetHouseInfo.cName#</td>
</tr>
<tr>
<td class="mainarea">Budgeted Occupied Units<BR>for the Current Month:</td><td class="generalleft">
<cfquery name="getOccUnits" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where year_id=	#yearforqueries# and Line_id=80000061 and unit_id= #GetHouseInfo.iHouse_ID# and ver_id=	1 and
Cust1_id=	0  and Cust2_id=	0 and Cust3_id=	80000024 and Cust4_id=	0
</cfquery>
<cfset monthforquery = "getOccUnits.#monthforqueries#">
#NumberFormat(Evaluate(monthforquery),'__._')#</td><td class="mainarea">Number of Days in Month:</td><td class="generalleft"><cfset dim = #daysinmonth(datetouse)#>#dim#</td>

</tr>
<tr>
<td class="mainarea">Budgeted House Revenue:</td><td class="generalleft">
<cfquery name="getBudgHouseRev" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=    #yearforqueries# 		and
Line_id=	80000015 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0	and
Cust4_id=	0
</cfquery>
<cfset monthforquery = "getBudgHouseRev.#monthforqueries#">
#DollarFormat(Evaluate(monthforquery))#
</td>
</tr>

</table>
<p>

<!--- get ave. actual wage rates per hour for all categories for this month (get from table instead of realtime so page loads faster) --->
<Cfquery name="getAvgHoursCategory" datasource="#ftads#">
	select * from AveHourlyWageRates where dtThrough = '#lastdayofdatetouse#' <!--- vcMonthYear = '#Dateformat(datetouse,'mmmm YYYY')#' ---> and vcHouseNumber = '#RIGHT(SubAccountNumber,3)#' and dtRowDeleted IS NULL 
</Cfquery>

<!--- if the above returns no records (say the auto process didn't run correctly), then try for the previous day --->
<cfif getAvgHoursCategory.recordcount is "0" and DatePart('d',datetouse) is not "1">
	<cfset lastdayofdatetouse = #DateAdd('d',-1,lastdayofdatetouse)#>
	<cfset lastdayofdatetouse = #DateFormat(lastdayofdatetouse,'M/D/YYYY')#>
	<Cfquery name="getAvgHoursCategory" datasource="#ftads#">
		select * from AveHourlyWageRates where dtThrough = '#lastdayofdatetouse#' <!--- vcMonthYear = '#Dateformat(datetouse,'mmmm YYYY')#' ---> and vcHouseNumber = '#RIGHT(SubAccountNumber,3)#' and dtRowDeleted IS NULL 
	</Cfquery>
</cfif>

<cfif getAvgHoursCategory.recordcount is "0" and DatePart('d',datetouse) is not "1">
	<font color="red" face="arial" size=-1>No recent data was found for Actual Wage Rates for this house.  This is because of the Extendicare/ALC database changes, this should be fixed in early April.  Stay tuned.<!--- The nightly process may have not run correctly.  Please contact the Help Desk. ---></font><p>
<cfelseif getAvgHoursCategory.recordcount is "0" and DatePart('d',datetouse) is "1"> 
	<font color="red" face="arial" size=-1>Since it is the first of the current month and calculations for each day run nightly at midnight, no actual wages have yet been determined for this month.<BR>
	OR it may be that this month's data has been lost.  IT is working on the problem.  Please stay tuned.</font><p>
</cfif>

<table border=0 cellpadding=0 cellspacing=0><td valign=top class="white">
<table border=1 cellpadding=1 cellspacing=0>
<tr>
<td class="white"></td><td colspan=5 align=center class="mainareaheader">Budgeted Hours per Resident Day/Per Day<BR>#DateFormat(firstdayofdatetouse,'MM/DD/YYYY')# - #DateFormat(lastdayofdatetouse,'MM/DD/YYYY')#</td>
</tr>
<tr>
<td class="white"></td><td class="mainarea"></td><td class="mainarea">Hours per<BR>Resident Care Day</td><td class="mainarea">Budgeted Wage<BR>Rates per Hour</td><td class="mainarea">Ave. Actual Wage<BR>Rates per Hour</td><td class="mainarea">Wage Rate<BR>Variance</td>
</tr>
<tr>
<td align=right class="mainarea">Resident Care</td>
<td>&##160;</td>
<cfquery name="getRCPRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000004	and
Cust4_id=	0
</cfquery>
<td>#DecimalFormat(getRCPRCD.P0)#</td>

<td>
<cfquery name="getRCBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000004	and
Cust4_id=	0
</cfquery>
<cfset monthforquery2 = "getRCBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- this gets rates per person per category and hours worked this month --->
<!--- <cfloop query="getHoursRC">
	<cfoutput>#getHoursRC.PERSONNUM# #getHoursRC.HOURLY_RaTe# #getHoursRC.subtotal_rate#</cfoutput><BR>
</cfloop> --->

<!--- this gets ave total hours per category for this month --->
<!---  <cfset CategoryQuery = QueryNew("category, paycodename, totalhours, avg_rate")>
<cfloop query="getAvgHoursCategory">
			<!--- make some rows in the query --->
			<cfset newRow  = #QueryAddRow(CategoryQuery)#>
			<!--- set the cells in the query --->
			<cfset temp = QuerySetCell(CategoryQuery, "category", "#getAvgHoursCategory.vccategory#")>
			<cfset temp = QuerySetCell(CategoryQuery, "paycodename", "#getAvgHoursCategory.vcPayCodeName#")>
			<cfset temp = QuerySetCell(CategoryQuery, "totalhours", "#getAvgHoursCategory.iTotalHours#")>
			<cfset temp = QuerySetCell(CategoryQuery, "avg_rate", "#getAvgHoursCategory.mavg_rate#")>
	<!--- <cfoutput>#getAvgHoursCategory.category# #getAvgHoursCategory.avg_rate# </cfoutput><BR> --->
</cfloop>  --->

<!--- put the getAveHoursCategory into its own query so I can do a query of a query to obtain just resident care hours --->
<!--- <cfquery name="getAveHoursCategoryRC" dbtype="query">
select sum(case when PayCodeName = 'Overtime' then ((Avg_rate*TotalHours) * 1.5) else (Avg_rate*TotalHours) end) / sum(TotalHours) as AR
	from CategoryQuery 
	where CATEGORY = 'Resident Care'
</cfquery> --->
<cfquery name="getAveHoursCategoryRC" datasource="#ftads#">
select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as AR
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Resident Care'
</cfquery>

<cfif getAveHoursCategoryRC.AR is not ''>
#DecimalFormat(getAveHoursCategoryRC.AR)#<cfset RCh = "#getAveHoursCategoryRC.AR#">
<cfelse>
0.00<cfset RC = "0"><cfset RCh = "0">
</cfif>
</td>

<!--- get variance --->
<td class="variance">
<cfif isDefined("RC")>#DecimalFormat(evaluate(monthforquery2))#<cfelse>
<cfset varianceRC = #DecimalFormat(evaluate(monthforquery2))# - #RCh#><Cfif VarianceRC LT 0><font color="red"></Cfif>#NumberFormat(varianceRC,'(_.__)')#
</cfif>
</td>
</tr>

<tr>
<td align=right class="mainarea">Housekeeping</td>
<td>&##160;</td>
<cfquery name="getHousekeepingPRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000008	and
Cust4_id=	0
</cfquery>
<td>#DecimalFormat(getHousekeepingPRCD.P0)#</td>

<td>
<cfquery name="getHousekeepingBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000008	and
Cust4_id=	0	
</cfquery>
<cfset monthforquery2 = "getHousekeepingBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- get just housekeeping hours --->
<!--- <cfquery name="getAveHoursCategoryHK" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'Housekeeping'
</cfquery> --->

<cfquery name="getiTotalHoursHK" datasource="#ftads#">
select sum(iTotalHours) as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Housekeeping'
</cfquery>

<cfif getiTotalHoursHK.recordcount is not "" AND getiTotalHoursHK.Avg_Rate is not "0">
	<cfquery name="getAveHoursCategoryHK" datasource="#ftads#">
	select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
	from AveHourlyWageRates 
	where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
	and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Housekeeping'
	</cfquery>
</cfif>

<cfif isDefined("getAveHoursCategoryHK") AND getAveHoursCategoryHK.Avg_rate is not ''>
#DecimalFormat(getAveHoursCategoryHK.avg_rate)#<cfset HKh = "#getAveHoursCategoryHK.avg_rate#">
<cfelse>
0.00<cfset HK = "0"><cfset HKh = "0">
</cfif>
</td>

<!--- get variance --->
<td class="variance">
 <Cfif isDefined("HK")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceHK = #DecimalFormat(evaluate(monthforquery2))# - #HKh#><Cfif VarianceHK LT 0><font color="red"></Cfif>#NumberFormat(varianceHK,'(_.__)')#
</Cfif>
</td>
</tr>

<tr>
<td align=right class="mainarea">LPN</td>
<td>&##160;</td>
<cfquery name="getLPNPRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000028	and
Cust4_id=	0
</cfquery>
<td>#DecimalFormat(getLPNPRCD.P0)#</td>

<td>
<cfquery name="getLPNBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000028	and
Cust4_id=	0	
</cfquery>
<cfset monthforquery2 = "getLPNBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- get just lpn hours --->
<!--- <cfquery name="getAveHoursCategoryLPN" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'LPN'
</cfquery> --->
<cfquery name="getiTotalHoursLPN" datasource="#ftads#">
select sum(iTotalHours) as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'LPN - LVN'
</cfquery>

<cfif getiTotalHoursLPN.recordcount is not "" AND getiTotalHoursLPN.Avg_Rate is not "0">
	<cfquery name="getAveHoursCategoryLPN" datasource="#ftads#">
	select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
	from AveHourlyWageRates 
	where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
	and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'LPN - LVN'
	</cfquery>
</cfif>

<cfif isDefined("getAveHoursCategoryLPN") AND getAveHoursCategoryLPN.Avg_rate is not ''>
#DecimalFormat(getAveHoursCategoryLPN.avg_rate)#<cfset LPNh = #getAveHoursCategoryLPN.avg_rate#>
<cfelse>
0.00<cfset LPN= "0"><cfset LPNh= "0">
</cfif>
</td>

<!--- get variance --->
<td class="variance">
<Cfif isDefined("LPN")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceLPN = #DecimalFormat(evaluate(monthforquery2))# - #LPNh#><Cfif VarianceLPN LT 0><font color="red"></Cfif>#NumberFormat(varianceLPN,'(_.__)')#
</cfif>
</td>
</tr>

<tr>
<!--- get just salaried hours (now this is going into the AveHourlyWageRates table, so can pull from there to speed page load) --->

<!--- <cfstoredproc procedure="dbo.sp_PS_JOB_PIT_SALARIED" datasource="PROD" RETURNCODE="YES" debug="Yes">
	<cfprocparam type="IN" value="#HouseNumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_CHAR">
	<cfprocparam type="IN" value="#lastdayofdatetouse#" DBVARNAME="@PointInTime" cfsqltype="CF_SQL_VARCHAR">
	<cfprocresult NAME="getSalaried" resultset="1">
</cfstoredproc> --->

<!--- this gets rates and standard hours per person for Salaried positions for this month --->
<!--- <cfloop query="getSalaried">
	<cfoutput>#getSalaried.File_NBR# #getSalaried.hourly_rt# #getSalaried.al_std_hours#</cfoutput><BR>
</cfloop> --->

<!--- <cfset SalariedQuery = QueryNew("hours, hourly_rt, home_department")>
<cfloop query="getSalaried">
			<!--- make some rows in the query --->
			<cfset newRow  = #QueryAddRow(SalariedQuery)#>
			<!--- set the cells in the query --->
			<cfset temp = QuerySetCell(SalariedQuery, "hours", "#getSalaried.al_std_hours#")>
			<cfset temp = QuerySetCell(SalariedQuery, "hourly_rt", "#getSalaried.hourly_rt#")>
			<cfset temp = QuerySetCell(SalariedQuery, "home_department", "#right(getSalaried.home_department,1)#")>
</cfloop> --->

<td align=right class="mainarea">RN/Nursing Care</td>
<td>
<cfquery name="getNursingHPM" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000005	and
Cust4_id=	0	
</cfquery>&##160;
<!--- <cfif getNursingHPM.recordcount is not 0>#DecimalFormat(getNursingHPM.P0*dim)#<cfelse>N/A</cfif> --->
</td>
<td>
<cfif getNursingHPM.recordcount is not 0>#DecimalFormat(getNursingHPM.P0)#<cfelse>N/A</cfif>
</td>
<td>
<cfquery name="getNursingBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000005	and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getNursingBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- get just nursing hours --->
<!--- <cfquery name="getAveHoursNursing" dbtype="query">
	select hourly_rt as hourlyrate from SalariedQuery where Home_Department = '6'
</cfquery> --->
<!--- <cfquery name="getAveHoursNursing" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'Nurse Consultant'
</cfquery> --->
<cfquery name="getAveHoursNursing" datasource="#ftads#">
select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / case when sum(iTotalHours) <> 0 then sum(iTotalHours) else 999999999 end as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Nurse Consultant'
</cfquery>

<cfif getAveHoursNursing.Avg_rate is not ''>
#DecimalFormat(getAveHoursNursing.avg_rate)#<cfset Nursingh = #getAveHoursNursing.avg_rate#>
<cfelse>
0.00<cfset Nursing= "0"><cfset Nursingh= "0">
</cfif>
<!--- <cfif getAveHoursNursing.recordcount is "1">
<cfset HoursNursing = #getAveHoursNursing.AVG_RATE#>
#DecimalFormat(HoursNursing)#
<cfelseif getAveHoursnursing.recordcount GT 1>
<!--- <cfquery name="getAveHoursNursing2" dbtype="query">
	select sum(hourly_rt) as hourlyrate, Home_Department from SalariedQuery where Home_Department = '6' group by Home_Department
</cfquery> --->
<cfquery name="getAveHoursNursing2" dbtype="query">
	select sum(AVG_RATE) as hourlyrate from CategoryQuery where CATEGORY = 'Nurse Consultant' group by CATEGORY
</cfquery>
<cfset HoursNursing = #getAveHoursNursing2.hourlyrate# / #getAveHoursnursing.recordcount#>
#DecimalFormat(HoursNursing)#
<cfelseif getAveHoursNursing.recordcount LT 1>
0.00<cfset Nursing = "0"><cfset HoursNursing = "0">
</cfif> --->
</td>

<!--- get variance --->
<td class="variance">
<Cfif isDefined("Nursing")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceNursing = #DecimalFormat(evaluate(monthforquery2))# - #Nursingh#><Cfif VarianceNursing LT 0><font color="red"></Cfif>#NumberFormat(varianceNursing,'(_.__)')#
</cfif>
</td>
</tr>

<tr>
<td class="white">&##160;</td><td class="mainarea" align=center>Hours<BR>per Month</td><td class="mainarea" align=center>Budgeted Hours<BR>per Day</td><td class="mainarea">Budgeted Wage<BR>Rates per Hour</td><td class="mainarea">Ave. Actual Wage<BR>Rates per Hour</td><td class="mainarea">Wage Rate<BR>Variance</td>
</tr>
<tr>
<td align=right class="mainarea">Life Enrichment</td>
<td>&##160;</td>
<cfquery name="getActivitiesPRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000009	and
Cust4_id=	0
</cfquery>
<td>#DecimalFormat(getActivitiesPRCD.P0)#</td>

<td>
<cfquery name="getActivitiesBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000009	and
Cust4_id=	0
</cfquery>
<cfset monthforquery2 = "getActivitiesBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- put the getAveHoursCategory into its own query so I can do a query of a query to obtain just resident care hours --->
<!--- <cfquery name="getAveHoursCategoryActivities" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'Activities'
</cfquery> --->
<cfquery name="getAveHoursCategoryActivities" datasource="#ftads#">
select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Activities'
</cfquery>
<cfif getAveHoursCategoryActivities.Avg_rate is not ''>
#DecimalFormat(getAveHoursCategoryActivities.avg_rate)#<cfset Acth = "#getAveHoursCategoryActivities.avg_rate#">
<cfelse>
0.00<cfset Act = "0"><cfset Acth = "0">
</cfif>
</td>

<!--- get variance --->
<td class="variance">
<cfif isDefined("Act")>#DecimalFormat(evaluate(monthforquery2))#<cfelse>
<cfset varianceAct = #DecimalFormat(evaluate(monthforquery2))# - #Acth#><Cfif Varianceact LT 0><font color="red"></Cfif>#NumberFormat(varianceAct,'(_.__)')#
</cfif>
</td>
</tr>

<tr>
<td align=right class="mainarea">Maintenance</td>
<td>&##160;</td>
<cfquery name="getMaintenancePRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000006	and
Cust4_id=	0
</cfquery>
<td>#DecimalFormat(getMaintenancePRCD.P0)#</td>

<td>
<cfquery name="getMaintenanceBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000006	and
Cust4_id=	0	
</cfquery>
<cfset monthforquery2 = "getMaintenanceBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- get just maintenance hours --->
<!--- <cfquery name="getAveHoursCategoryMaintenance" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'Maintenance'
</cfquery> --->
<cfquery name="testmaint" datasource="#ftads#">select iTotalHours from AveHourlyWageRates where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Maintenance'</cfquery>
<cfif testmaint.iTotalHours is not "0">
	<cfquery name="getAveHoursCategoryMaintenance" datasource="#ftads#">
	select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
	from AveHourlyWageRates 
	where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
	and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Maintenance'
	</cfquery>
</cfif>
<cfif isDefined("getAveHoursCategoryMaintenance") and getAveHoursCategoryMaintenance.Avg_rate is not ''>
	#DecimalFormat(getAveHoursCategoryMaintenance.avg_rate)#<cfset Mainth = "#getAveHoursCategoryMaintenance.avg_rate#">
<cfelse>
	0.00<cfset Maint = "0"><cfset Mainth = "0">
</cfif>

</td>

<!--- get variance --->
<td class="variance">
<Cfif isDefined("Maint")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceMaint = #DecimalFormat(evaluate(monthforquery2))# - #Mainth#><Cfif VarianceMaint LT 0><font color="red"></Cfif>#NumberFormat(varianceMaint,'(_.__)')#
</cfif>
</td>
</tr>


<tr>

<td align=right class="mainarea">Kitchen Services</td>
<td>&##160;</td>
<cfquery name="getKitchenPRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000007	and
Cust4_id=	0
</cfquery>
<td>#DecimalFormat(getKitchenPRCD.P0)#</td>

<td>
<cfquery name="getKitchenBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000007	and
Cust4_id=	0	
</cfquery>
<cfset monthforquery2 = "getKitchenBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- get just kitchen hours --->
<!--- <cfquery name="getAveHoursCategoryKitchen" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'Kitchen'
</cfquery> --->
<cfquery name="getAveHoursCategoryKitchen" datasource="#ftads#">
select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Kitchen'
</cfquery>
<cfif getAveHoursCategoryKitchen.Avg_rate is not ''>
#DecimalFormat(getAveHoursCategoryKitchen.avg_rate)#<cfset Kitchnh = "#getAveHoursCategoryKitchen.avg_rate#">
<cfelse>
0.00<cfset Kitchn = "0"><cfset Kitchnh = "0">
</cfif>
</td>

<!--- get variance --->
<td class="variance">
<Cfif isDefined("Kitchn")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceKitchen = #DecimalFormat(evaluate(monthforquery2))# - #kitchnh#><Cfif VarianceKitchen LT 0><font color="red"></Cfif>#NumberFormat(varianceKitchen,'(_.__)')#
</cfif>
</td>

</tr>

<!--- <tr>
<td class="white"></td><td class="mainarea">Hours<BR>per Month</td><td class="mainarea">Hours Per Day</td><td class="mainarea">Budgeted Wage<BR>Rates per Hour</td><td class="mainarea">Ave. Actual Wage<BR>Rates per Hour</td><td class="mainarea">Wage Rate<BR>Variance</td>
</tr> --->
<tr>
<td align=right class="mainarea">Administrator</td>
<td>
<cfquery name="getAdminHPM" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000002	and
Cust4_id=	0	
</cfquery>
#DecimalFormat(getAdminHPM.P0*dim)#
</td>
<td>
#DecimalFormat(getAdminHPM.P0)#
</td>
<td>
<cfquery name="getAdminBWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000002	and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getAdminBWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>

<!--- <!--- put the getAvgHoursSalaried into its own query so I can do a query of a query to obtain just Administrator hours --->
<cfquery name="getAveHoursAdministrator" dbtype="query">
	select * from SalariedQuery where Home_Department = '1'
</cfquery> --->
<!--- <cfquery name="getAveHoursAdministrator" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'Administrator'
</cfquery> --->
<cfquery name="getAveHoursAdministrator" datasource="#ftads#">
select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'Administrator'
</cfquery>
<cfif getAveHoursAdministrator.Avg_rate is not ''>
#DecimalFormat(getAveHoursAdministrator.AVG_RATE)#<cfset Administratorh = "#getAveHoursAdministrator.AVG_RATE#">
<cfelse>
0.00<cfset Administrator = "0"><cfset Administratorh = "0">
</cfif>
</td>

<!--- get variance --->
<td class="variance">
<Cfif isDefined("Administrator")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceAdmin = #DecimalFormat(evaluate(monthforquery2))# - #Administratorh#><Cfif VarianceAdmin LT 0><font color="red"></Cfif>#NumberFormat(varianceAdmin,'(_.__)')#
</cfif>
</td>
</tr>


<tr>
<td align=right class="mainarea">MA/AA</td>
<td>
<cfquery name="getMAHPM" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000117 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000003	and
Cust4_id=	0	
</cfquery>
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
<td>
<cfquery name="getMABWR" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000097 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000003	and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getMABWR.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>

<td>
<!--- get just MA hours --->
<!--- <cfquery name="getAveHoursMA" dbtype="query">
	select AVG_RATE from CategoryQuery where CATEGORY = 'MA - AA'
</cfquery> --->
<cfquery name="getAveHoursMA" datasource="#ftads#">
select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
from AveHourlyWageRates 
where vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' and vcHouseNumber = '#HouseNumber#' 
and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = 'MA - AA'
</cfquery>
<cfif getAveHoursMA.Avg_rate is not ''>
#DecimalFormat(getAveHoursMA.AVG_RATE)#<cfset HoursMAAA = #getAveHoursMA.AVG_RATE#>
<cfelse>
0.00<cfset MA = "0"><cfset HoursMAAA = "0">
</cfif>
<!---<cfif getAveHoursMA.recordcount is "1">
<cfset HoursMAAA = #getAveHoursMA.AVG_RATE#>
#DecimalFormat(HoursMAAA)#
<cfelseif getAveHoursMA.recordcount GT 1>
 <cfquery name="getAveHoursMA2" dbtype="query">
	select sum(hourly_rt) as hourlyrate, Home_Department from SalariedQuery where Home_Department = '0' group by Home_Department
</cfquery>
<cfquery name="getAveHoursMA2" dbtype="query">
	select sum(AVG_RATE) as hourlyrate from CategoryQuery where CATEGORY = 'MA - AA' group by CATEGORY
</cfquery>
<cfset HoursMAAA = #getAveHoursMA2.hourlyrate# / #getAveHoursMA.recordcount#>
#DecimalFormat(HoursMAAA)#
<cfelseif getAveHoursMA.recordcount LT 1>
0.00<cfset MA = "0"><cfset HoursMAAA = "0">
</cfif>--->
</td>

<!--- get variance --->
<td class="variance">
<Cfif isDefined("MA")>#DecimalFormat(evaluate(monthforquery2))#
<cfelse>
<cfset varianceMA = #DecimalFormat(evaluate(monthforquery2))# - #HoursMAAA#><Cfif VarianceMA LT 0><font color="red"></Cfif>#NumberFormat(varianceMA,'(_.__)')#
</cfif>
</td>

</tr>
<tr>
<td class="white">&##160;</td><td class="mainarea"></td><td align=right class="mainarea">Budgeted $<BR>per Month</td>
</tr>
<tr>
<td align=right class="mainarea">Training/Meeting</td><td>&##160;</td>
<td>
<cfquery name="getTrainingBDM" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	4075 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getTrainingBDM.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
</table>
</td>
<p>

<Td valign=top class="white">&##160; &##160; </td>
<Td valign=top class="white">
<BR>
<table border=1 cellpadding=1 cellspacing=0>
<tr>
<td align=right class="mainarea">Budgeted Food Expense<BR>per Resident Day</td>
<td>
<cfquery name="getFoodPRD" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000269 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getFoodPRD.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Budgeted Kitchen Supplies<BR>per Resident Day</td>
<td>
<cfquery name="getSuppliesPRD" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000115 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000061		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getSuppliesPRD.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainareaheader" colspan=2>Budgeted Expense for the Current Month</td>
</tr>
<tr>
<td align=right class="mainarea">Resident Care</td>
<td>
<cfquery name="getResidentCare" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000017 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getResidentCare.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Other Kitchen</td>
<td>
<cfquery name="getOtherKitchen" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	4399 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getOtherKitchen.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Maintenance</td>
<td>
<cfquery name="getMaintenance" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000018 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getMaintenance.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>

<tr>
<td align=right class="mainarea">Housekeeping</td>
<td>
<cfquery name="getHousekeeping" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000029  	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getHousekeeping.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Activities</td>
<td>
<cfquery name="getActivities" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000020 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getActivities.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Property and Equipment</td>
<td>
<cfquery name="getProperty" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000011 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getProperty.#monthforqueries#">
<!--- #DecimalFormat(evaluate(monthforquery2))# --->??
</td>
</tr>
<tr>
<td align=right class="mainarea">Other Revenue</td>
<td>
<cfquery name="getOtherRev" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000011 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getOtherRev.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Utilities</td>
<td>
<cfquery name="getUtilities" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000021 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getUtilities.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Advertising</td>
<td>
<cfquery name="getAdvertising" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000024 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getAdvertising.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Administrative</td>
<td>
<cfquery name="getAdministrative" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000025 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getAdministrative.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Petty Cash</td>
<td>
<cfquery name="getPettyCash" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id= 80000027 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getPettyCash.#monthforqueries#">
#DecimalFormat(evaluate(monthforquery2))#
</td>
</tr>
<tr>
<td align=right class="mainarea">Other</td>
<td>
<cfquery name="getOther" datasource="#ComshareDS#">
select *
from ALC.FINLOC_BASE
where
year_id=	#yearforqueries# 		and
Line_id=	80000018 	and
unit_id=	#GetHouseInfo.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	0		and
Cust4_id=	0		
</cfquery>
<cfset monthforquery2 = "getOther.#monthforqueries#">
<!--- #DecimalFormat(evaluate(monthforquery2))# --->??
</td>
</tr>
</table>
</td></table>

<p>
[ <A HREF="/intranet/fta/labortracking.cfm?subAccount=#SubAccountNumber#&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#">Labor Tracking Report</A> | <A HREF="/intranet/fta/monthlyinvoices.cfm?iHouse_ID=#GetHouseInfo.iHouse_ID#&DateToUse=#DateToUse#">Monthly Invoices</A> | <A HREF="expensespenddown.cfm?subAccount=#SubAccountNumber#&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#">Expense Spend-down</A> | <A HREF="housereport.cfm?subAccount=#SubAccountNumber#&workingmonth=#firstdayofdatetouse#">House Report</A> ]
<p>

<cfif session.username is "kdeborde" or session.username is "laurav">
Hours per category:<BR>
<cfdump var="#getAvgHoursCategory#">
<p>
<cfif isDefined("categoryquery")>
Category Query:<BR>
<cfdump var="#categoryquery#"></cfif>
<!--- Actual Hours per person:<BR>
<cfdump var="#getHours#">
<p>
Salaried Hours:<BR>
<cfdump var="#getSalaried#"> --->
</cfif>

</cfoutput>

</form>
</body>
</html>
