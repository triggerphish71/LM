<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- Labor Tracking Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<font color="red" fac="arial"><B><center>Because of the server moves, the Labor Tracking sheet is down.  This will be back up and running Tuesday April 26th.</center></B></font><cfabort>
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
		<option value="location.href='labortracking.cfm?iHouse_ID=#iHouse_ID#'"<cfif (isDefined("url.iHouse_ID") and url.iHouse_ID is "#getHouses.iHouse_ID#")> SELECTED</cfif>>#cName#</option>
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
	select iOpsArea_ID, cName, cGLsubaccount, iHouse_ID from House
	 where cGLSubAccount = '#SubAccountNumber#'
</cfquery>

<cfif isDefined("url.datetoUse") and url.datetouse is not #DateFormat(NOW(),'mmmm yyyy')#>
	<!--- use the month/year given --->
	<cfset currentmonth = "#DateFormat(datetouse,'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',datetouse)#">
	<cfset currenty = "#DatePart('yyyy',datetouse)#">
	<cfset monthforqueries = #DateFormat(currentm,'mmm')#>
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
<cfelse>
	<!--- use this month --->
	<cfset currentmonth = "#DateFormat(NOW(),'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',NOW())#">
	<cfset currentd = "#DatePart('d',NOW())#">
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
		<cfelse><!--- use yesterday --->
			<cfset lastdayofdatetouse = "#DateAdd('d',-1,lastdayofdatetouse)#">
			<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse,'M/D/YYYY')#">
		</cfif>
	</cfif>
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,NOW())#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(NOW(),'M/D/YYYY')#">
	<cfset datetouse = "#DateFormat(NOW(),'mmmm yyyy')#">
</cfif>

<body>
<cfoutput>
<font face="arial">
<h3>Online FTA- <font color="##C88A5B">Labor Tracking Report-</font> <font color="##0066CC">#Lookupsubacct.cName#-</font> <Font color="##7F7E7E">#DateFormat(currentfullmonthnotime,'mmmm yyyy')#</font></h3>

<form method="post" action="labortracking.cfm">

<cfset Page="labortracking">
<Table border=0 cellpadding=0 cellspacing=0>
<td>
<cfinclude template="menu.cfm">
</td>
<td>&##160; <font size=-1><A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A>
<p><BR>
&##160; Month to View: <cfset x = DateFormat(NOW(),'mmmm yyyy')>
<cfset y = "November 2004"><select name="datetouse" onchange="doSel(this)"><option value=""></option><cfloop condition="#DateCompare(x,y,'m')# GTE 0"><option value="location.href='labortracking.cfm?iHouse_ID=#LookUpSubAcct.iHouse_ID#&DateToUse=#DateFormat(x,'mmmm yyyy')#'"<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> SELECTED</cfif>>#DateFormat(x,'mmmm yyyy')#</option><cfset x = #DateAdd('m',-1,x)#></cfloop></select> <font size=-1 color="red"><B>*Data is only valid through March 21st due to database changes*</B></font>
</td>
</Table>

<p>
<!--- <font size=-1>Click on a Day to view Hour Details for that Day</font><BR> --->

<!--- <cfquery name="droptmp" datasource="adpeet">
drop table ##employeesBreakdown
</cfquery> 
<cfquery name="droptmp2" datasource="adpeet">
drop table ##employees2breakdown
</cfquery> --->

<cfquery name="checkiftmptableexists" datasource="willowtempdb">
select * from SYSOBJECTS where NAME LIKE '%##employeesBreakdown%'
</cfquery>

<cfif checkiftmptableexists.recordcount is not "0">
	<cfquery name="droptmp" datasource="adpeet">
	drop table #checkiftmptableexists.name#
	</cfquery> 
</cfif>

<cfquery name="checkiftmptable2exists" datasource="willowtempdb">
select * from SYSOBJECTS where NAME LIKE '%##employees2Breakdown%'
</cfquery>

<cfif checkiftmptable2exists.recordcount is not "0">
	<cfquery name="droptmp2" datasource="adpeet">
	drop table #checkiftmptable2exists.name#
	</cfquery>
</cfif>

<!--- get just salaried hours from HRizon  ********NOTE 3/29/05: Can't I just make this pull from AveHourlyWageRates?? --->
<cfstoredproc procedure="dbo.sp_PS_JOB_PIT_SALARIED_Test" datasource="PROD" RETURNCODE="YES" debug="Yes">
	<cfprocparam type="IN" value="#Right(LookUpSubAcct.cGLsubaccount,3)#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_CHAR">
	<cfprocparam type="IN" value="#lastdayofDateToUse#" DBVARNAME="@PointInTime" cfsqltype="CF_SQL_VARCHAR">
	<cfprocresult NAME="getSalaried" resultset="1">
</cfstoredproc>

<cfif getSalaried.recordcount is not "0">
	<!--- there are salaried hours, figure out which positions are salaried and for hour many hours --->	
	<cfset QueryForSalaried = #QueryNew("RowNum,Title,Hours,PersonNum,Location,HomeDept")#>
	<cfset rownumber = 1>
	<cfloop query ="getSalaried">
		<cfset SalariedHoursPerDay = #getSalaried.AL_Std_hours# / 14>
		<cfset addrow = #QueryAddRow(QueryForSalaried,1)#>
		<cfset adddataTotal = #querysetcell(QueryForSalaried,"RowNum",rownumber)#>
		<cfset adddataTotal = #querysetcell(QueryForSalaried,"Title",getSalaried.descrlong)#>
		<cfset adddataTotal = #querysetcell(QueryForSalaried,"Hours",SalariedHoursPerDay)#>
		<cfset adddataTotal = #querysetcell(QueryForSalaried,"PersonNum",trim(getSalaried.PersonNum))#>
		<cfset adddataTotal = #querysetcell(QueryForSalaried,"Location",trim(getSalaried.LOCATION))#>
		<cfset adddataTotal = #querysetcell(QueryForSalaried,"HomeDept",trim(getSalaried.HOME_DEPARTMENT))#>
		<cfset rownumber = #rownumber# + 1>
	</cfloop>
	
	<cfset LocationList = #ValueList(QueryForSalaried.LOCATION)#>
	<cfset PersonNumList = #ValueList(QueryForSalaried.PersonNum)#>
	<!--- <cfset LocationList = #ListQualify(LocationList,"'")#> --->

	<!--- then figure out if this house is allocated in HRizon or not by checking a nightly run table that contains allocations --->
	<Cfquery name="SearchAllocations" datasource="#FTAds#">
		select * from Allocations where vcLocation IN (#LocationList#)
	</Cfquery>
	
	<!--- if a matching LOCATION is found, start looop to get all allocation % and HomeDept --->
	<cfif SearchAllocations.Recordcount is not "0">
		<cfloop query="SearchAllocations">
			<cfif #PersonNumList# contains "#SearchAllocations.vcPersonNum#">
				<Cfquery name="findRowToUpdate" dbtype="query">
					Select * from QueryForSalaried where PersonNum = '#SearchAllocations.vcPersonNum#'
				</Cfquery>
				<cfset rowNUM = #findRowToUpdate.RowNum#>
				<Cfif SearchAllocations.vcHome_Department is "#findRowToUpdate.HomeDept#">
					<!--- find home allocation and apply --->
					<cfset HomePercentage = 100 - (#SearchAllocations.decDept_2_pct# + #SearchAllocations.decDept_3_pct# + #SearchAllocations.decDept_4_pct# + #SearchAllocations.decDept_5_pct# + #SearchAllocations.decDept_6_pct# + #SearchAllocations.decDept_7_pct# + #SearchAllocations.decDept_8_pct#)>
					<cfset NewHomeHours = #findRowToUpdate.Hours# * (#HomePercentage# / 100)>
					<!--- update the row --->
					<cfset editdata = #querysetcell(QueryForSalaried,"Hours",NewHomeHours,rowNUM)#>
					<!--- add row(s) for 2nd-8th HomeDept allocation(s) if same location --->
					<cfloop from="2" to="8" index="d">
						<cfset columnDept = "vcDept_"&#d#>
						<cfset columnDeptforquery = "SearchAllocations.#columnDept#">
						<cfset Deptvalue = #Evaluate(columnDeptforquery)#>
						<cfif Deptvalue is not "">
							<cfset DeptLocation = #RemoveChars(Deptvalue,1,2)#>
							<cfset DeptLocation = #REmoveChars(DeptLocation,4,1)#>
							<cfset DeptCategory = #REmoveChars(DeptValue,1,5)#>
							<cfif DeptCategory is "0"><cfset DeptDescription = "Assistant Administrator">
								<cfelseif DeptCategory is "1"><cfset DeptDescription = "Administrator">
								<cfelseif DeptCategory is "2"><cfset DeptDescription = "PSA">
								<cfelseif DeptCategory is "3"><cfset DeptDescription = "Maintenance">
								<cfelseif DeptCategory is "4"><cfset DeptDescription = "Cook">
								<cfelseif DeptCategory is "5"><cfset DeptDescription = "Houskeeper">
								<cfelseif DeptCategory is "6"><cfset DeptDescription = "RN Consultant">
								<cfelseif DeptCategory is "7"><cfset DeptDescription = "Activity Services Coordinator">
								<cfelseif DeptCategory is "8"><cfset DeptDescription = "Community Sales Coordinator">
								<cfelseif DeptCategory is "9"><cfset DeptDescription = "LPN-LVN">
								<cfelseif DeptCategory is "A"><cfset DeptDescription = "Corporate">
							</cfif>
							<cfif DeptLocation is "#SearchAllocations.vcLocation#">
								<cfset columnDeptPct = "decDept_"&#d#&"_pct">
								<cfset columnDeptPctforquery = "SearchAllocations.#columnDeptPct#">
								<cfset DeptPctvalue = #Evaluate(columnDeptPctforquery)#>
								<cfset DeptHours = #findRowToUpdate.Hours# * (#DeptPctvalue# / 100)>
								
								<cfset addrow = #QueryAddRow(QueryForSalaried,1)#>
								<cfset adddataTotal = #querysetcell(QueryForSalaried,"Title",DeptDescription)#>
								<cfset adddataTotal = #querysetcell(QueryForSalaried,"Hours",DeptHours)#>
								<cfset adddataTotal = #querysetcell(QueryForSalaried,"PersonNum",findRowToUpdate.PersonNum)#>
								<cfset adddataTotal = #querysetcell(QueryForSalaried,"Location",findRowToUpdate.LOCATION)#>
								<cfset adddataTotal = #querysetcell(QueryForSalaried,"HomeDept",Deptvalue)#>
							</cfif>
						</cfif>
					</cfloop>
				</Cfif>
			</cfif>
		</cfloop>
	</cfif>
</cfif>

<!--- If new PersonNum and HomeDept are found in the Allocations table, INSERT the getSalaried Query with new hours and person info --->
<cfquery name="LookThruAllocations" datasource="#ftads#">
	select iStd_Hours, vcHome_department, vcLocation, vcPersonNum, vcHouse, vcDescrShort, vcFullName, vcPayGroup, vcFile_nbr, dtEffdt,
				substring(vcDept_2,3,3) as D2, substring(vcDept_2,6,1) as D2title, decDept_2_pct, 
				substring(vcDept_3,3,3) as D3, substring(vcDept_3,6,1) as D3title, decDept_3_pct, 
				substring(vcDept_4,3,3) as D4, substring(vcDept_4,6,1) as D4title, decDept_4_pct, 
				substring(vcDept_5,3,3) as D5, substring(vcDept_5,6,1) as D5title, decDept_5_pct, 
				substring(vcDept_6,3,3) as D6, substring(vcDept_6,6,1) as D6title, decDept_6_pct, 
				substring(vcDept_7,3,3) as D7, substring(vcDept_7,6,1) as D7title, decDept_7_pct, 
				substring(vcDept_8,3,3) as D8, substring(vcDept_8,6,1) as D8title, decDept_8_pct 
				from Allocations where vcLocation <> '#Right(LookUpSubAcct.cGLsubaccount,3)#'
</cfquery>
<cfloop query="LookThruAllocations">
	<cfloop from="2" to="8" index="d">
		<cfset columnDept = "D"&#d#>
		<cfset columnDeptforquery = "LookThruAllocations.#columnDept#">
		<cfset Deptvalue = #Evaluate(columnDeptforquery)#>
		<cfset columnTitle = "D"&#d#&"title">
		<cfset columnTitleforquery = "LookThruAllocations.#columnTitle#">
		<cfset Titlevalue = #Evaluate(columnTitleforquery)#>
		<cfset columnPct = "decDept_"&#d#&"_pct">
		<cfset columnPctforquery = "LookThruAllocations.#columnPct#">
		<cfset Pctvalue = #Evaluate(columnPctforquery)#>
		<cfif #Deptvalue# is '#Right(LookUpSubAcct.cGLsubaccount,3)#'>
			<!--- insert new row for this person whose home department is not this house --->
			<cfif #Titlevalue# is "0"><cfset DeptDescription = "Assistant Administrator">
				<cfelseif #Titlevalue# is "1"><cfset DeptDescription = "Administrator">
				<cfelseif #Titlevalue# is "2"><cfset DeptDescription = "PSA">
				<cfelseif #Titlevalue# is "3"><cfset DeptDescription = "Maintenance">
				<cfelseif #Titlevalue# is "4"><cfset DeptDescription = "Cook">
				<cfelseif #Titlevalue# is "5"><cfset DeptDescription = "Houskeeper">
				<cfelseif #Titlevalue# is "6"><cfset DeptDescription = "RN Consultant">
				<cfelseif #Titlevalue# is "7"><cfset DeptDescription = "Activity Services Coordinator">
				<cfelseif #Titlevalue# is "8"><cfset DeptDescription = "Community Sales Coordinator">
				<cfelseif #Titlevalue# is "9"><cfset DeptDescription = "LPN-LVN">
				<cfelseif #Titlevalue# is "A"><cfset DeptDescription = "Corporate">
			</cfif>
			<cfset DeptHours = #LookThruAllocations.iStd_hours# / 14>
			<cfset DeptHours = #DeptHours# * (#Pctvalue# / 100)>
			<cfif getSalaried.recordcount is not "0">
				<cfset addrow = #QueryAddRow(QueryForSalaried,1)#>
				<cfset adddataTotal = #querysetcell(QueryForSalaried,"Title",DeptDescription)#>
				<cfset adddataTotal = #querysetcell(QueryForSalaried,"Hours",DeptHours)#>
				<cfset adddataTotal = #querysetcell(QueryForSalaried,"PersonNum",LookThruAllocations.vcPersonNum)#>
				<cfset adddataTotal = #querysetcell(QueryForSalaried,"Location",LookThruAllocations.vcLOCATION)#>
				<cfset adddataTotal = #querysetcell(QueryForSalaried,"HomeDept",LookThruAllocations.vcHome_Department)#>
			</cfif>
		</cfif>
	</cfloop>
</cfloop>

<!--- pull hours worked for this House for this month from E-Time into a TEMP table. 
	CATEGORY is MA - AA, Kitchen, Nurse Consultant, Resident Care, Maintenance, Administrator, Housekeeping, Activities, etc. --->
<cfquery name="breakdown" datasource="adpeet">
SELECT  VP_ALLTOTALS.PERSONFULLNAME, 
	VP_ALLTOTALS.WFCLABORLEVELDSC6 as CATEGORY, 
	sum(VP_ALLTOTALS.WFCTIMEINSECONDS) as SECONDS, 
	VP_ALLTOTALS.PERSONNUM, 
	VP_ALLTOTALS.PAYCODENAME,
	VP_ALLTOTALS.APPLYDATE
 into	##employeesBreakdown
FROM	VP_ALLTOTALS WITH (NOLOCK)  
WHERE	VP_ALLTOTALS.APPLYDATE between '#currentfullmonthNoTime#' and '#today#'
AND  	VP_ALLTOTALS.WFCLABORLEVELNAME5  = '#Right(LookUpSubAcct.cGLsubaccount,3)#'
AND  	((VP_ALLTOTALS.WFCTIMEINSECONDS <> 0 AND VP_ALLTOTALS.PAYCODENAME IN ('Travel Time', 'Regular', 'Overtime', 'OnCall Hrs Wked' , 'Holiday Worked','Reg Hrs - Prior Period'))
OR  	(VP_ALLTOTALS.PAYCODENAME = '$OnCall Bonus' AND VP_ALLTOTALS.WFCMONEYAMOUNT <> 0))
GROUP BY VP_ALLTOTALS.PERSONFULLNAME, VP_ALLTOTALS.WFCLABORLEVELDSC6, VP_ALLTOTALS.PERSONNUM, VP_ALLTOTALS.PAYCODENAME, VP_ALLTOTALS.APPLYDATE
ORDER BY VP_ALLTOTALS.PERSONFULLNAME ASC
</cfquery>

<cfquery name="getColumns" datasource="#ftads#">
	select * from LaborCategory ORDER BY iOrder
</cfquery>
<cfset CategoryList = #ValueList(getColumns.vcLaborCategory)#>
<cfset CategoryList = #ListAppend(CategoryList,"Administrators")#>
	
<!--- set all training, PTO and Other hours into another temp table --->
<cfquery name="breakdown2" datasource="adpeet">
		SELECT  VP_ALLTOTALS.PERSONFULLNAME, 
		VP_ALLTOTALS.WFCLABORLEVELDSC6 as CATEGORY, 
		sum(VP_ALLTOTALS.WFCTIMEINSECONDS) as SECONDS, 
		VP_ALLTOTALS.PERSONNUM, 
		VP_ALLTOTALS.PAYCODENAME,
		VP_ALLTOTALS.APPLYDATE
		into	##employees2breakdown
	FROM	VP_ALLTOTALS WITH (NOLOCK)  
	WHERE	VP_ALLTOTALS.APPLYDATE between '#currentfullmonthNoTime#' and '#today#'
	AND  	VP_ALLTOTALS.WFCLABORLEVELNAME5  = '#Right(LookUpSubAcct.cGLsubaccount,3)#'
	AND VP_ALLTOTALS.PAYCODENAME NOT IN ('All Hours and Earnings','All Hours Applied','Leave PayCodes')
AND  	
(
(VP_ALLTOTALS.WFCTIMEINSECONDS <> 0 AND VP_ALLTOTALS.PAYCODENAME = 'PTO')
 OR
 (VP_ALLTOTALS.WFCLABORLEVELDSC6 NOT IN (#ListQualify(CategoryList,"'")#))
OR
(VP_ALLTOTALS.WFCTIMEINSECONDS <> 0 AND VP_ALLTOTALS.PAYCODENAME = 'Training')
)
	GROUP BY VP_ALLTOTALS.PERSONFULLNAME, VP_ALLTOTALS.WFCLABORLEVELDSC6, VP_ALLTOTALS.PERSONNUM, VP_ALLTOTALS.PAYCODENAME, VP_ALLTOTALS.APPLYDATE
	ORDER BY VP_ALLTOTALS.PERSONFULLNAME ASC
</cfquery>

<cfquery name="breakdown2select" datasource="adpeet">
	select * from ##employees2breakdown
</cfquery>


<cfquery name="getRCPRCD" datasource="#ComshareDS#">
select P0
from ALC.FINLOC_BASE
where
year_id=	#currenty# 		and
Line_id=	80000117 	and
unit_id=	#LookupSubAcct.iHouse_ID#		and
ver_id=		1		and
Cust1_id=	0		and
Cust2_id=	0		and
Cust3_id=	80000004	and
Cust4_id=	0
</cfquery>
<cfset RCHPRCD = #getRCPRCD.P0#>

<!--- calculate actual daily occupancy for each day of this month so far --->
<cfset MTDoccupancy = 0><cfset MTDoccupancyR = 0>
<cfloop from=1 to="#currentd#" index="dayx">
	<Cfset todaysdate = "#currentm#/#dayx#/#currenty#">
	<cfquery name="getoccupancy" datasource="prodtips4">
		select iUnitsOccupied, iTenants from HouseOccupancy where dtOccupancy = '#todaysdate#' and cType = 'B' and iHouse_ID = #lookupsubacct.iHouse_ID# 
	</cfquery>
	<cfif getoccupancy.recordcount is not "0">
		<cfset MTDoccupancy = #getOccupancy.iUnitsOccupied# + #MTDoccupancy#>
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
		<cfset MTDoccupancy = #getOccupancy.iUnitsOccupied# + #MTDoccupancy#>
	</cfif>
</cfloop>

<cfset budgetcellcolor = "##ffff99">
<cfset dailybudgetcellcolor = "##DADADA">
<cfset dailybudgetcellcolor = "##ffff99">

<table border=1 cellpadding=1 cellspacing=0>
<tr>
<th colspan=2 bgcolor="##0066CC">&##160;</th>
<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
	<th bgcolor="##0066CC" colspan=3><font size=-1 color="white">
	<cfelse>
	<th bgcolor="##0066CC"><font size=-1 color="white">
	</cfif>
	#vcDisplayName# Hours</th>
</cfloop>
	<th bgcolor="##0066CC"><font size=-1 color="white">Training Dollars</th>
	<th bgcolor="##0066CC"><font size=-1 color="white">PTO Hours</th>
	<th bgcolor="##0066CC"><font size=-1 color="white">Other Hours</th>
	<th bgcolor="##0066CC"><font size=-1 color="white">Total</th>
	<th bgcolor="##0066CC"><font size=-2 color="white">Daily Hours Variance</th>
</tr>
<tr>
<th colspan=2 bgcolor="##0066CC">&##160;</th>
<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<td><font size=-1>Regular</td><td><font size=-1>Overtime</td><td><font size=-1>Other</td>
	<cfelse>
		<td><font size=-1>&##160;</td>
	</cfif>
</cfloop>
<td>&##160;</td>
<td>&##160;</td>
<td>&##160;</td>
<td>&##160;</td>
<td>&##160;</td>
</tr>

<!--- display category budget totals --->
<tr>
<td rowspan=2 align=right bgcolor="#dailybudgetcellcolor#"><font size=-2>Resident Care Hours<BR>Daily Budget</td>
<td bgcolor="#budgetcellcolor#" align=right><font size=-1>MTD Budget</td>

<cfset QueryForCategoryHPRCD = #QueryNew("Category,Hours")#>

<cfset budgettotal = 0>
<cfset daytotalaccrue = 0>
<cfset DailyBudgetDayAccrueVarianceTotal = 0>

<cfloop query="getColumns">
	<td align=right bgcolor="#budgetcellcolor#">
	<cfif vcComshareLine_ID is 0><font size=-1>0.00
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
			Cust3_id=	#getColumns.vcComshareLine_ID#	and
			Cust4_id=	0		
		</cfquery>
		<cfset categoryforquery2 = "#getCategoryBudget.P0#">
		<cfset addrowTota = #QueryAddRow(QueryForCategoryHPRCD,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryHPRCD,"Category",getColumns.vcLaborCategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryHPRCD,"Hours",categoryforquery2)#>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Housekeeping">
			<!-- these are hours per resident care day categories --->
			<cfif categoryforquery2 is ""><cfset categoryforquery2 ="0"></cfif>
			<cfset MTDCategoryBudgetHours = #MTDoccupancy# * #categoryforquery2#>
			<font size=-1>#DecimalFormat(MTDCategoryBudgetHours)#
		<cfelse>
			<!--- these are hours per day categories --->
			<cfif categoryforquery2 is ""><cfset categoryforquery2 ="0"></cfif>
			<cfset MTDCategoryBudgetHours = #currentD# * #categoryforquery2#>
			<font size=-1>#DecimalFormat(MTDCategoryBudgetHours)#
		</cfif>
		<cfset budgettotal = #budgettotal# + #MTDCategoryBudgetHours#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Regular")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",MTDCategoryBudgetHours)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>
	</td>
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<!--- overtime --->
		<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.00</font></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Overtime")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		<!--- other --->
		<td align=right bgcolor="#budgetcellcolor#"><font size=-1>0.00</font></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getColumns.vcLaborCategory&"Other")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>
</cfloop>

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
<TD align=right bgcolor="#budgetcellcolor#"><font size=-1>#decimalformat(evaluate(training))#</font></TD>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","TrainingRegular")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",evaluate(training))#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		
<!--- PTO --->
<TD align=right bgcolor="#budgetcellcolor#"><font size=-1>0.00</font></TD>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","PTORegular")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
		
<!--- Other --->
<!--- <cfquery name="getCSDBudget" datasource="#ComshareDS#">
	select P0
	from ALC.FINLOC_BASE
	where
	year_id=	#currenty# 		and
	Line_id=	80000117 	and
	unit_id=	#LookupSubAcct.iHouse_ID#		and
	ver_id=		1		and
	Cust1_id=	0		and
	Cust2_id=	0		and
	Cust3_id=	80000010	and
	Cust4_id=	0		
</cfquery>

<cfif getCSDBudget.recordcount is not "0" and getCSDbudget.P0 is not ""><cfset csdbudget = "#getCSDBudget.P0#"><cfelse> ---><cfset csdbudget = "0"><!--- </cfif> --->
<TD align=right bgcolor="#budgetcellcolor#"><font size=-1>0.00</font></TD>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","OtherRegular")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",csdbudget)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>		
		
<!--- budgeted total hours --->
<TD align=right bgcolor="#budgetcellcolor#"><font size=-1>#decimalformat(budgettotal)#</font></TD>
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",budgettotal)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	
<td align=center><font size=-2>&##160;</font></td>
</tr>
<tr>
<cfset colspannumber = #getColumns.recordcount# + 2>
<td align=center><font size=-1>DAY</td>
<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<td colspan=3 align=center><font size=-2>ACTUAL HOURS WORKED</td>
	<cfelse>
		<td colspan=1 align=center><font size=-1>&##160;</td>
	</cfif>
</cfloop>
<td>&##160;</td><td>&##160;</td><td>&##160;</td><td>&##160;</td><td>&##160;</td>
</tr>

<cfset variancecellcolor = "##ccffff">
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
	<cfquery name="getoccupancy" datasource="prodtips4">
		select iUnitsOccupied, iTenants from HouseOccupancy where dtOccupancy = '#todaysdate#' and cType = 'B' and iHouse_ID = #lookupsubacct.iHouse_ID# 
	</cfquery>
	<!--- find Resident Day Months (daily occupancy for each day in month) --->
	<cfif getoccupancy.recordcount is not "0">
		<cfset RCHDailyBudget = #getoccupancy.iUnitsOccupied# * #RCHPRCD#>
		<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #RCHDailyBudget#>
	</cfif>
	<tr>
	<!--- get today's occupancy and multiply it by the budgeted food expense per resident day --->
	<td align=right bgcolor="#dailybudgetcellcolor#"><font size=-1><cfif isdefined("RCHDailyBudget")>#DecimalFormat(RCHDailyBudget)#<cfelse>N/A</cfif></td>
	<td align=center><font size=-1>#dayx#
	
	<!--- loop through labor categories --->
	<Cfloop query="getColumns">
		<cfquery name="findabc" dbtype="query">select Hours from QueryForCategoryHPRCD where Category = '#vcLaborCategory#'</cfquery>
		<cfif vcLaborCategory is "Housekeeping" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN">
			<!--- take daily occupancy * hours per resident care day --->
			<cfif findabc.recordcount is "0" or findabc.Hours is ""><cfset findabcHours ="0"><cfelse><cfset findabchours = #findabc.Hours#></cfif>
			<cfif getoccupancy.recordcount is not "0">
				<cfset CategoryHDailyBudget = #getoccupancy.iUnitsOccupied# * #findabchours#>
				<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #CategoryHDailyBudget#>
			</cfif>
		<cfelse>
			<cfif findabc.recordcount is "0" or findabc.Hours is ""><cfset findabcHours ="0"><cfelse><cfset findabchours = #findabc.Hours#></cfif>
			<cfset CategoryHDailyBudget = #findabcHours#>
			<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #CategoryHDailyBudget#>
		</cfif>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<cfquery name="findDayLaborCategoryRegular" datasource="adpeet">
				select sum(cast(seconds as float))/3600 as Hours from ##employeesBreakdown where ApplyDate = '#theAMdateforQuery#' and Category='#getColumns.vcLaborCategory#' and PayCodeName = 'Regular'
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
						select title, sum(hours) as TotalJobHours from QueryForSalaried where Title like '%#salarytitletouse#%' group by title
					</cfquery><!--- <cfdump var="#CheckSalariedForNursing#"> --->
					<cfif CheckSalariedForJob.recordcount is "0" OR CheckSalariedForJob.TotalJobHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForJob.TotalJobHours)#"></cfif>
					<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			<!--- </cfif> --->
			<td align=right>
			<cfset TotalAmountDayCategory = 0>
			<cfif findDayLaborCategoryRegular.recordcount is not "0" OR isDefined("CheckSalariedforJob")>
				<font size=-1>#DecimalFormat(HoursToAdd)#</td>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>
		
			<cfquery name="findDayLaborCategoryOvertime" datasource="adpeet">
				select sum(cast(seconds as float))/3600 as Hours from ##employeesBreakdown where ApplyDate = '#theAMdateforQuery#' and Category='#getColumns.vcLaborCategory#' and PayCodeName = 'Overtime'
			</cfquery> 
			<td align=right>
			<cfset TotalAmountDayCategory = 0>
			<cfif findDayLaborCategoryOvertime.recordcount is not "0">
				<font size=-1>#DecimalFormat(findDayLaborCategoryOvertime.Hours)# <cfif findDayLaborCategoryOvertime.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategoryOvertime.Hours#></cfif></td>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Overtime")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>

			<cfquery name="findDayLaborCategoryOther" datasource="adpeet">
				select sum(cast(seconds as float))/3600 as Hours from ##employeesBreakdown where ApplyDate = '#theAMdateforQuery#' and Category='#getColumns.vcLaborCategory#' and PayCodeName <> 'Overtime' and PayCodeName <> 'Regular'
			</cfquery> 
			<td align=right>
			<cfset TotalAmountDayCategory = 0>
			<cfif findDayLaborCategoryOther.recordcount is not "0">
				<font size=-1>#DecimalFormat(findDayLaborCategoryOther.Hours)#<cfif findDayLaborCategoryOther.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategoryOther.Hours#></cfif></td>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Other")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>
		<Cfelse>
		<!--- just the total for category, no matter the subcategory --->
			<cfquery name="findDayLaborCategory" datasource="adpeet">
				select sum(cast(seconds as float))/3600 as Hours from ##employeesBreakdown where ApplyDate = '#theAMdateforQuery#' and Category='#getColumns.vcLaborCategory#' 
			</cfquery> 
			<cfif findDayLaborCategory.Hours is ""><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findDayLaborCategory.Hours#></cfif>
			<!--- if labor category is Administrator or MA - AA, could be salaried hours, so check QueryForSalaried query --->
			<cfif vcLaborCategory is "Administrator">
				<cfif isDefined("QueryForSalaried")><!-- note: this isn't working right for paris oaks --->
					<cfquery name="CheckSalariedForAdmin" dbtype="query">
						select title, sum(hours) as TotalAdminHours from QueryForSalaried where (Title like 'Administrator%' OR Title like '%Regional Dir Operations%') group by title
					</cfquery><!--- <cfdump var="#CheckSalariedForAdmin#"> --->
					<cfif CheckSalariedForAdmin.recordcount is "0" OR CheckSalariedForAdmin.TotalAdminHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForAdmin.TotalAdminHours)#"></cfif>
					<cfset HoursToAdd = #hourstoadd# + #hourstoaddsalaried#>
				</cfif>
			</cfif>
			<cfif vcLaborCategory is "MA - AA">
				<cfif isDefined("QueryforSalaried")>
				<cfquery name="CheckSalariedForMAAA" dbtype="query">
					select title, sum(hours) as TotalMAAAHours from QueryForSalaried where (Title like 'Assistant Administrator%' OR Title like 'Management Assistant%') group by title
				</cfquery><!--- <cfdump var="#CheckSalariedForMAAA#"> --->
				<cfif CheckSalariedForMAAA.recordcount is "0" OR CheckSalariedForMAAA.TotalMAAAHours is ""><cfset HoursToAddSalaried = "0"><cfelse><cfset HoursToAddSalaried = "#DecimalFormat(CheckSalariedForMAAA.TotalMAAAHours)#"></cfif>
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
				<font size=-1>#DecimalFormat(HoursToAdd)#</td>
				<cfset daytotal = #daytotal# + #HoursToAdd#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
			</cfif>
		</cfif>
	</Cfloop>
	
	<!--- training --->
	<cfquery name="findTrainingHours" datasource="adpeet">
		Select sum(cast(seconds as float))/3600 as Hours from ##employees2breakdown where PayCodeName = 'Training' and ApplyDate = '#theAMdateforQuery#'
	</cfquery> 
	<td align=right bgcolor="##CCCC99"><font size=-1>#DecimalFormat(findTrainingHours.Hours)#</td>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category","TrainingRegular")#>
				<cfif findTrainingHours.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findTrainingHours.Hours#></cfif>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
	<!--- PTO --->
	<cfquery name="findPTOHours" datasource="adpeet">
		Select sum(cast(seconds as float))/3600 as Hours from ##employees2breakdown where PayCodeName = 'PTO' and ApplyDate = '#theAMdateforQuery#'
	</cfquery> 
	<td align=right><font size=-1>#DecimalFormat(findPTOHours.Hours)#</td>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category","PTORegular")#>
				<cfif findPTOHours.Hours is ''><Cfset HoursToAdd = "0"><cfelse><cfset HoursToAdd = #findPTOHours.Hours#></cfif>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#>
	<!--- other hours --->
	<cfquery name="findOtherHours" datasource="adpeet">
		Select sum(cast(seconds as float))/3600 as Hours from ##employees2breakdown where Category NOT IN (#ListQualify(CategoryList,"'")#) and ApplyDate = '#theAMdateforQuery#' and Category not like 'Community Sales%'
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
	<!--- <cfquery name="findOtherHoursCategories" datasource="adpeet">
		Select category from ##employees2breakdown where Category NOT IN (#ListQualify(CategoryList,"'")#) and ApplyDate = '#theAMdateforQuery#'
	</cfquery> --->
	<td align=right><font size=-1>#DecimalFormat(HoursToAdd)#<!--- <cfif isDefined("findOtherHoursCategories")><BR><cfloop query="FindOtherHoursCategories"><font size=-2>#findOtherHoursCategories.CATEGORY#, </font></cfloop></cfif> ---></td>
	<cfset daytotal = #daytotal# + #HoursToAdd#>
	<cfset CategoryHDailyBudget = #HoursToAdd#>
	<cfset DailyBudgetDayAccrue = #DailyBudgetDayAccrue# + #CategoryHDailyBudget#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category","OtherRegular")#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",HoursToAdd)#> 
	<!--- Full Day's total --->
	<td align=right><font size=-1><strong>#DecimalFormat(daytotal)#</strong></td>
	<cfset DayTotalAccrue = #DayTotalAccrue# + #daytotal#>
	<cfset DailyBudgetDayAccrueVariance = #Evaluate(DailyBudgetDayAccrue - DayTotal)#>
	<td align=right bgcolor="#variancecellcolor#"><font size=-1><cfif DailyBudgetDayAccrueVariance LT 0><font color="red"></cfif><strong>#DecimalFormat(DailyBudgetDayAccrueVariance)#</strong></td></font>
	<cfset DailyBudgetDayAccrueVarianceTotal = DailyBudgetDayAccrueVarianceTotal + DailyBudgetDayAccrueVariance>
	</tr>
</cfloop>

<!--- month-to-date totals --->
<tr>
<cfset totalcellcolor="##9CCDCD">
<td align=right bgcolor="#totalcellcolor#"><font size=-1><strong>&##160;</strong></td>
<td align=right bgcolor="#totalcellcolor#"><font size=-1><strong>Total</strong></td>
<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
		<td align=right bgcolor="#totalcellcolor#">
		<!--- <cfquery name="GetCategoryTotalRegular" datasource="adpeet">
			select Sum(Seconds)/3600 as TotalAmount from ##employeesBreakdown where Category = '#trim(getColumns.vcLaborCategory)#' and PayCodeName = 'Regular'
		</cfquery> --->
		<cfquery name="GetCategoryTotalRegular" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = '#trim(getColumns.vcLaborCategory)#Regular' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotalRegular.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalRegular.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
			
		<td align=right bgcolor="#totalcellcolor#">
		<!--- <cfquery name="GetCategoryTotalOvertime" datasource="adpeet">
			select Sum(Seconds)/3600 as TotalAmount from ##employeesBreakdown where Category = '#trim(getColumns.vcLaborCategory)#' and PayCodeName = 'Overtime'
		</cfquery> --->
		<cfquery name="GetCategoryTotalOvertime" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = '#trim(getColumns.vcLaborCategory)#Overtime' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotalOvertime.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Overtime")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalOvertime.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
			
		<td align=right bgcolor="#totalcellcolor#">
		<!--- <cfquery name="GetCategoryTotalOther" datasource="adpeet">
			select Sum(Seconds)/3600 as TotalAmount from ##employeesBreakdown where Category = '#trim(getColumns.vcLaborCategory)#' and PayCodeName = 'Other'
		</cfquery> --->
		<cfquery name="GetCategoryTotalOther" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = '#trim(getColumns.vcLaborCategory)#Other' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotalOther.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Other")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalOther.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
			
	<Cfelse>
		<td align=right bgcolor="#totalcellcolor#">
		<!--- <cfquery name="GetCategoryTotal" datasource="adpeet">
			select Sum(Seconds)/3600 as TotalAmount from ##employeesBreakdown where Category = '#trim(getColumns.vcLaborCategory)#'
		</cfquery> --->
		<cfquery name="GetCategoryTotal" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = '#trim(getColumns.vcLaborCategory)#Regular' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotal.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcLaborCategory)&"Regular")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotal.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
	</cfif>
</cfloop>
	<!--- training day total --->
		<td align=right bgcolor="#totalcellcolor#">
		<cfquery name="GetCategoryTotalTraining" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = 'TrainingRegular' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotalTraining.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","TrainingRegular")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalTraining.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
	<!--- PTO day total --->
		<td align=right bgcolor="#totalcellcolor#">
		<cfquery name="GetCategoryTotalPTO" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = 'PTORegular' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotalPTO.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","PTORegular")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalPTO.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
	<!--- Other day total --->
		<td align=right bgcolor="#totalcellcolor#">
		<cfquery name="GetCategoryTotalOther" dbtype="query">
			select Sum(Amount) as TotalAmount from queryforCategoryTotals where Category = 'OtherRegular' Group by Category
		</cfquery>
		<font size=-1><strong>#DecimalFormat(GetCategoryTotalOther.TotalAmount)#</strong></td>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","OtherRegular")#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotalOther.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
				
<!--- the actual daily total of all categories so far this month --->
<td align=right bgcolor="#totalcellcolor#"><B><font size=-1>#DecimalFormat(DayTotalAccrue)#</font></B></td>
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",DayTotalAccrue)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
<td align=right bgcolor="#totalcellcolor#"><B><font size=-1><cfif DailyBudgetDayAccrueVarianceTotal LT "0"><font color="red"></cfif>#DecimalFormat(DailyBudgetDayAccrueVarianceTotal)#</font></B></td>
</tr>


<!--- <tr>
<cfset colspannumber2 = #getColumns.recordcount# + 15>
<td colspan=#colspannumber2#>&##160;</td>
</tr> --->
<tr>
<!--- MTD Variance --->
<TD colspan=2 align=right bgcolor="#variancecellcolor#"><font size=-1><b>MTD Variance</b></font></TD>
<cfloop query="getColumns">
	<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
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
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
		</td>
		
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Overtime' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Overtime' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
		</td>
		
		<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Other' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcLaborCategory)#Other' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is ""><cfset BA = 0><Cfelse><cfset BA = #GetCategoryGrandTotalBudget.BudgetAmount#></cfif>
		<cfif GetCategoryGrandTotalActual.ActualAmount is ""><cfset AA = 0><Cfelse><cfset AA = #GetCategoryGrandTotalActual.ActualAmount#></cfif>
		<cfset variance = BA - AA>
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
		</td>
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
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
		</td>
	</cfif>
</cfloop>
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
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
		</td>
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
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
		</td>
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
		<font size=-1><strong><cfif variance LT 0><font color="red"></cfif>#DecimalFormat(variance)#</strong>
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
	<font size=-1><strong><cfif varianceTotal LT 0><font color="red"></cfif>#DecimalFormat(varianceTotal)#</strong>
</td>
<td>&##160;</td>
</tr>

<!--- get the 85% efficiency information and calcuate it based off of average occupancy and average points for this month-to-date --->
<cfif getoccupancy.recordcount is not "0">
	<cfset numberofaveresidents = "Residents#AveMTDoccupancyR#">
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
<td colspan=2 align=right><font size=-2>85% Efficiency:</td><td colspan=17 align=left><font size=-2 color="red">can't calculate 85% Efficiency without acuity available</td>
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
	
<!--- only show the below rows if actual average hourly wage rates exist in the AveHourlyWageRates table --->
<Cfquery name="FindAveHourlyWageRates" datasource="#ftads#">
	select * from AveHourlyWageRates where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#RIGHT(LookUpSubAcct.cGLsubaccount,3)#' and dtRowDeleted IS NULL 
</Cfquery>

<!--- if the above returns no records (say the auto process didn't run correctly), then try for the previous day --->
<cfif FindAveHourlyWageRates.recordcount is "0" and DatePart('d',datetouse) is not "1">
	<cfset lastdayofdatetouse = #DateAdd('d',-1,lastdayofdatetouse)#>
	<cfset lastdayofdatetouse = #DateFormat(lastdayofdatetouse,'M/D/YYYY')#>
	<Cfquery name="FindAveHourlyWageRates" datasource="#ftads#">
		select * from AveHourlyWageRates where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#RIGHT(LookUpSubAcct.cGLsubaccount,3)#' and dtRowDeleted IS NULL 
	</Cfquery>
</cfif>
<cfif FindAveHourlyWageRates.recordcount is not "0">
	<tr>
	<td colspan=2 align=right><font size=-2>Actual Average Hourly Wage Rate</td>
	<cfloop query="getColumns">
		<Cfquery name="getAveHourlyWageRates" datasource="#ftads#">
			select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / case when sum(iTotalHours) <> 0 then sum(iTotalHours) else 999999999 end as mAvg_rate
			from AveHourlyWageRates 
			where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#Right(LookUpSubAcct.cGLsubaccount,3)#' 
			and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = '#getColumns.vcLaborCategory#'
		</Cfquery>
		<cfif vcLaborCategory is "Resident Care" or vcLaborCategory is "Nurse Consultant" or vcLaborCategory is "LPN - LVN" or vcLaborCategory is "Kitchen">
			<td colspan=3 align=center><font size=-1>
			<Cfif getAveHourlyWageRates.recordcount is not "0" OR getAveHourlyWageRates.mAvg_rate is not "">
				#dollarformat(getAveHourlyWageRates.mAvg_rate)#
			<cfelse>
				$0.00
			</Cfif>
			</td>
		<cfelse>
			<td align=right><font size=-1>
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
	<td colspan=2 align=right bgcolor="#budgetcellcolor#"><font size=-2>MTD- Budgeted Salary</td>
	<cfloop query="getColumns">
		<cfquery name="getBudgetedHoursOccupancy" dbtype="query">
		select category, amount, budgetoractual from QueryForCategoryGrandTotal where category = '#getColumns.vcLaborCategory#Regular' and budgetoractual = 'Budget'
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
		Cust3_id=  #getColumns.vcComshareline_ID#	and
		Cust4_id=	0
		</cfquery>
		<cfset monthforquery2 = "getBWR.#monthforqueries#">
		<cfif getBudgetedHoursOccupancy.recordcount is "0"><cfset BugHourOccAmount = 0><cfelse><cfset BugHourOccAMount = #getBudgetedHoursOccupancy.amount#></cfif>
		<cfset bwrcategory = #DecimalFormat(evaluate(monthforquery2))#>
		<cfset salarycategory = #bwrcategory# * #BugHourOccAMount#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",vcLaborCategory&"Salary")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",salarycategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	
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
	<Tr>
	<td colspan=2 align=right bgcolor="#totalcellcolor#"><font size=-2><strong>MTD- Actual Salary</strong></td>
	<cfloop query="getColumns">
		<cfquery name="getActualHoursOccupancy" dbtype="query">
			select * from QueryForCategoryGrandTotal where budgetoractual = 'Actual' and Category = '#getColumns.vcLaborCategory#Regular'
		</cfquery>
		<Cfquery name="getAveHourlyWageRatesForSalary" datasource="#ftads#">
			select sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / case when sum(iTotalHours) <> 0 then sum(iTotalHours) else 999999999 end as mAvg_rate
			from AveHourlyWageRates 
			where dtThrough = '#lastdayofdatetouse#' and vcHouseNumber = '#Right(LookUpSubAcct.cGLsubaccount,3)#' 
			and dtRowDeleted IS NULL and vcPayCodeName is not NULL and vcCategory = '#getColumns.vcLaborCategory#'
		</Cfquery>
		<Cfif getAveHourlyWageRatesForSalary.mAvg_Rate is not ""><cfset ActualHoursOcc = #getAveHourlyWageRatesForSalary.mAvg_rate#><cfelse><cfset ActualHoursOcc = "0"></cfif>
		<Cfset ActualHoursOcc = #ActualHoursOcc# * #getActualHoursOccupancy.Amount#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",vcLaborCategory&"Salary")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",ActualHoursOcc)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
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
	<!--- variance of salary --->
	<tr>
	<td align=right bgcolor="#variancecellcolor#" colspan=2><font size=-2>Salary Variance</td>
		<cfloop query="getColumns">
			<cfquery name="GetCategorySalaryBudget" dbtype="query">
				select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = '#vclaborCategory#Salary' and BudgetOrActual = 'Budget'
			</cfquery>
			<cfquery name="GetCategorySalaryActual" dbtype="query">
				select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = '#vclaborCategory#Salary' and BudgetOrActual = 'Actual'
			</cfquery>
			<cfif GetCategorySalaryBudget.BudgetAmount is ""><cfset BAs = 0><Cfelse><cfset BAs = #GetCategorySalaryBudget.BudgetAmount#></cfif>
			<cfif GetCategorySalaryActual.ActualAmount is ""><cfset AAs = 0><Cfelse><cfset AAs = #GetCategorySalaryActual.ActualAmount#></cfif>
			<cfset variancesalary = BAs - AAs>
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
	<cfset colspannumber2 = #getColumns.recordcount# + 15>
	<td colspan=#colspannumber2# align=center><!--- <font size=-1><i>Since it is the first of the current month and calculations for each day run nightly at midnight, no actual wages have yet been determined for this month.</i></font> ---><font color="red" face="arial" size=-1>No recent data was found for Actual Wage Rates for this house.  This is because of the Extendicare/ALC database changes, this should be fixed in early April.  Stay tuned.<!--- The nightly process may have not run correctly.  Please contact the Help Desk. ---></font></td>
</cfif>

</table>
<font size=-2 face="arial">*See Resident Care Hours</font>

<font face="arial">
<p>
[ <A HREF="/intranet/fta/monthlyinvoices.cfm?iHouse_ID=#lookupSubAcct.iHouse_ID#&DateToUse=#DateToUse#">Monthly Invoices</A> | <A HREF="/intranet/fta/expensespenddown.cfm?subAccount=#SubAccountNumber#&DateToUse=#DateToUse#">Expense Spend-down</A> | <A HREF="/intranet/FTA/housereport.cfm?subAccount=#SubAccountNumber#&workingmonth=#currentfullmonthnotime#">House Report</A> | <A HREF="/intranet/FTA/default.cfm?iHouse_ID=#lookupSubAcct.iHouse_ID#&monthtouse=#DateFormat(currentfullmonthnotime,'mmmm yyyy')#">Budget Sheet</A> ]


<cfquery name="droptmp" datasource="adpeet">
drop table ##employeesBreakdown
</cfquery>
<cfquery name="droptmp2" datasource="adpeet">
drop table ##employees2breakdown
</cfquery>

<cfif session.username is "kdeborde">
<p>

<cfif isDefined("QueryForSalaried")>
<cfif isDefined("FindRowToUpdate.PersonNum")>
Allocated Person: #findrowtoupdate.PersonNum#<BR></cfif>
QueryForSalaried:<BR>
<cfdump var="#QueryForSalaried#"><BR></cfif>
Breakdown2:<BR>
<cfdump var="#breakdown2select#"><BR>
QueryForCategoryTotals:<BR>
<cfdump var="#queryforCategoryTotals#"><BR>
QueryForCategoryGrandTotal:<BR>
<cfdump var="#QueryForCategoryGrandTotal#">
</cfif>

</cfoutput>
</body>
</html>
