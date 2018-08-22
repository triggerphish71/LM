<!----------------------------------------------------------------------------------------------
| DESCRIPTION   /Index.cfm                                                                     |
|----------------------------------------------------------------------------------------------|
|  Allow the user to select a house.  If the user only has access to one house it is           |
|  automatically selected, and they are sent to MainMenu.cfm via a CFLOCATION tag.             |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name   URL.SelectedHouse_ID - House.aHouse_ID value of the house the user selected.|
|----------------------------------------------------------------------------------------------|
| INCLUDES                                     												   |
| Calls MainMenu.cfm                                                                           |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|------------|------------|--------------------------------------------------------------------------------------|
| S. Knox    | 03/20/2001 | Original Authorship                                                                  |
| mlaw       | 11/11/2005 | Edit house Range                                                                     |
|Ssathya     | 11/14/2008 |Modified the query so that it pulls data from the TenantMissingItems                  |
|                          Table. So that the missing items displays on the page.Project 30178                   |
|Rschuette   | 2/9/2009   |Added code for Project 26955 for bond house display indicators                        |
|Sathya      | 09/15/2010 | Project 60038 Changed the join to tenantmissingitems to left join in the query       |
|Sfarmer     | 02/11/2013 | Project 98888/98152 added sort to MissingItems column, descending                    |
|sfarmer      |08/21/2015  |<cfelseif IsDefined("qryHouseList.ihouse_id") and qryHouseList.ihouse_id is not null>|
| changed to <cfelseif IsDefined("qryHouseList.ihouse_id") and qryHouseList.ihouse_id is not ''>           |
| S Farmer   | 2015-09-14 | Revised house access method to use only DMA.dbo.groupassignment                |
|            |            | see also actionlogin.cfm  
|Mshah       |2016-08-15  | added companyID for company project                                             |                                             |				
----------------------------------------------------------------------------------------------------------->


<SCRIPT>
	// initialize variables
	timerrunning = false; lookup = '';
	// set function to HTML target submit according to keys pressed
	function timedone(){
		for (i=0;(i<=document.anchors.length-1);i++){ 
			tmp = document.anchors[i].name.substring(0,lookup.length).toUpperCase(); keys = lookup.toUpperCase(); 
			if (tmp == keys){ hashkey = "#" + document.anchors[i].name; location.hash = hashkey; break; } 
		} lookup = '';
	}
	// actual function to all on page
	function HashKeyPress(){ 
		if(timerrunning){ clearTimeout(searchtimer); }
		lookup = lookup + String.fromCharCode(window.event.keyCode); timerrunning = true; searchtimer = setTimeout("timedone()",200);
	}
</SCRIPT>

<CFIF ((NOT isDefined("SESSION.userid") OR isNumeric(SESSION.userid) eq 'NO') AND NOT isDefined("SESSION.AD"))>
	<CFLOCATION URL="../Loginindex.cfm?notfromportal=1" ADDTOKEN="No">
</CFIF>

<!---  Send users to login page if the have NOT logged in or if shortcut was used ---->
<CFIF (FindNoCase("Portal",HTTP.REFERER,1) GT 0 AND NOT IsDefined("SESSION.USERID") AND NOT isDefined("SESSION.AD"))>
	<CFLOCATION URL="../Loginindex.cfm?notfromportal=1" ADDTOKEN="No">
<CFELSEIF (NOT IsDefined("SESSION.UserName"))>
	<CFLOCATION URL="../Loginindex.cfm?nousername=1" ADDTOKEN="No">
</CFIF>

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../header.cfm">

<!--- ==============================================================================
Include Javascript files
=============================================================================== --->
<CFINCLUDE TEMPLATE="Shared/JavaScript/ResrictInput.cfm">
<!--- <cfinclude template="Shared/JavaScript/PageTimer.js">  --->
<!--- ==============================================================================
If we there is no login information send user to the login page
=============================================================================== --->
<CFIF (NOT IsDefined("session.grouplist") AND NOT isDefined("SESSION.userid")) AND (isDefined("SESSION.AD") AND SESSION.AD EQ 1)> 
	<CFLOCATION URL="../Loginindex.cfm?session_ad_defined=1" ADDTOKEN="No"> 
</CFIF>

<!--- =============================================================================
Retrieve the current date for processing time
============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT  getDate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- ==============================================================================
Retrieve list of iVPUsers_ID
=============================================================================== --->
<CFQUERY NAME="qVP" DATASOURCE="#APPLICATION.datasource#">
	SELECT iVPUser_ID FROM Region R WHERE R.dtRowDeleted IS NULL
</CFQUERY>
<CFSET VPs=ValueList(qVP.iVPUser_ID)>

<!--- ==============================================================================
Retrieve list of RDO Users_ID
=============================================================================== --->
<CFQUERY NAME="qRDO" DATASOURCE="#APPLICATION.datasource#">
	SELECT iDirectorUser_ID FROM OPSAREA WHERE dtRowDeleted IS NULL
	AND 1 <= (select count(ihouse_id) from house where dtrowdeleted is null and iopsarea_id = opsarea.iopsarea_id)
</CFQUERY>
<CFSET RDOs=ValueList(qRDO.iDirectorUser_ID)>

<!--- ==============================================================================
Retrieve list of iVPUsers_ID
=============================================================================== --->
<CFQUERY NAME="qPD" DATASOURCE="#APPLICATION.datasource#">
	SELECT	iPDUser_ID, iAcctUser_ID FROM House	WHERE dtRowDeleted IS NULL
</CFQUERY>
<CFSET PDs=ValueList(qPD.iPDUser_ID)>

<CFSCRIPT>
	/* Set session variables according to accessrights and prior queries */
	if (IsDefined("SESSION.USERID") AND ListFindNoCase(VPs, SESSION.USERID, ",") GT 0) { SESSION.AccessRights= 'iVPUser_ID'; }
	else if (IsDefined("SESSION.USERID") AND ListFindNoCase(RDOs, SESSION.USERID, ",") GT 0) { SESSION.AccessRights= 'iDirectorUser_ID'; }
	else if (IsDefined("SESSION.USERID") AND ListFindNoCase(PDs, SESSION.USERID, ",") GT 0) { SESSION.AccessRights= 'iPDUser_ID'; }
</CFSCRIPT>

<CFSCRIPT>
	//set sql filters
	if (IsDefined("SESSION.USERID") AND SESSION.USERID NEQ '') { getuserfilter="gax.userid =" & SESSION.UserID; }
	else { getuserfilter="(u.username='#SESSION.UserName#' OR u.username = '" & SESSION.fullname & "')"; }
</CFSCRIPT>

<!--- ==============================================================================
Retrieve UserID from Tables on Aspen
=============================================================================== --->
<CFQUERY NAME="getuserids" DATASOURCE="DMS">
	SELECT gax.groupid, u.employeeid as userid, u.employeeid as loginid
	FROM groupassignments gax	
	JOIN groups g on g.groupid = gax.groupid
	JOIN users u on u.username = g.groupname
	WHERE 	<CFIF IsDefined("SESSION.USERID") AND SESSION.USERID NEQ ''>
				gax.userid = #SESSION.UserID#
			<CFELSE>
				(u.username='#SESSION.UserName#' OR u.username='#SESSION.fullname#')
			</CFIF>
	AND gax.uniquecodeblockid is null AND gax.userid is not null
</CFQUERY>
<CFIF getuserids.recordcount eq 0>
	<!--- Query for userids --->
	<CFQUERY NAME="getuserids" DATASOURCE="DMS">
		SELECT gaw.userid, gax.groupid, u.employeeid as loginid
		FROM groupassignments gax	
		JOIN groupassignments gaw ON gax.groupid = gaw.groupid
		JOIN users u on u.employeeid = gax.userid
		WHERE 	<CFIF IsDefined("SESSION.USERID") AND SESSION.USERID NEQ ''>
					gax.userid = #SESSION.UserID#
				<CFELSE>
					(u.username='#SESSION.UserName#' OR u.username='#SESSION.fullname#')
				</CFIF>
		AND gax.uniquecodeblockid is null AND gaw.userid between 1800 and 3000 AND gaw.userid is not null
	</CFQUERY>
</CFIF>
 
<CFIF  IsDefined("SESSION.UserId") and SESSION.USERID EQ ''> 
	<CFSET SESSION.UserId = getuserids.loginid> 
</CFIF>

	<cfquery  name="qryHouseList"  DATASOURCE="DMS">
		SELECT   h.ihouse_id 
		FROM 	users u
		join groupassignments grpasg on u.employeeid = grpasg.userid
		join groups grp  on grpasg.groupid = grp.groupid
	 	join tips4.dbo.house h on grp.ihouse_id = h.ihouse_id
		WHERE u.employeeid = #SESSION.UserID# and grp.ihouse_id <> '' and h.dtrowdeleted is null
	</cfquery>

<CFSCRIPT>
	//set sort order
	if (NOT IsDefined("URL.SelectedSortOrder") ) { orderby="House.cName"; }
	//Mshah added here
    else if (URL.SelectedSortOrder EQ "Company") { orderby="House.cCompanyID,Region.cName, OpsArea.cName, House.cStateCode, House.cCity"; }
	else if (URL.SelectedSortOrder EQ "Region") { orderby="Region.cName, OpsArea.cName, House.cStateCode, House.cCity"; }
	else if (URL.SelectedSortOrder EQ "OpsArea") { orderby="OpsArea.cName, House.cStateCode, House.cCity"; }
	else if (URL.SelectedSortOrder EQ "State") { orderby="House.cStateCode, House.cCity"; }
	else if (URL.SelectedSortOrder EQ "Number") { orderby="House.cNumber"; }
	else if (URL.SelectedSortOrder EQ "Name") { orderby="House.cName"; }
	else if (URL.SelectedSortOrder EQ "City") { orderby="House.cCity"; }
	else if (URL.SelectedSortOrder EQ "Month"){ orderby=" HouseLog.dtCurrentTipsMonth desc"; }
	else if (URL.SelectedSortOrder EQ "PDClosed") { orderby="HouseLog.bisPDClosed desc"; }
	//medicaid project Mamta
	else if (URL.SelectedSortOrder EQ "Medicaid") { orderby="House.bIsMedicaid desc,House.cName"; }
    //memorycare project Mamta
	else if (URL.SelectedSortOrder EQ "MemoryCare") { orderby="House.bIsMemoryCare desc,House.cName"; }
	//Proj 26955 2-9-2009 Rschuette Bond ordering 
	else if (URL.SelectedSortOrder EQ "Bond") { orderby="House.iBondHouse desc,House.cName"; }
	else if (URL.SelectedSortOrder EQ "Missing") { orderby="TenantWithMissingItems desc,House.cName"; }	
</CFSCRIPT>

<!--- =============================================================================================
Select all of the houses for this user.
============================================================================================== --->
<CFQUERY NAME="qUserHouses"  DATASOURCE="#APPLICATION.datasource#"> 
    SELECT HouseLog.bIsPDClosed, House.iHouse_ID, House.cName AS HouseName ,House.cNumber ,House.cCity ,House.cStateCode
				,OpsArea.cName AS OpsAreaName ,Region.cName AS RegionName ,HouseLog.dtCurrentTipsMonth,
				<!---mamta added for medicaid & memorycare project--->
				House.bIsMedicaid,House.bIsMemoryCare
				<!--- Project 30178 modification ssathya added this --->
				, TenantMissingItems.TenantWithMissingItems
				<!--- Proj 26955 RTS 2/9/2009  For Bond indication --->
				,House.iBondHouse
				<!---Mshah added company project--->
				,House.cCompanyID
	FROM House
	INNER JOIN  OpsArea	ON  OpsArea.iOpsArea_ID = House.iOpsArea_ID and opsarea.dtrowdeleted is null
	INNER JOIN  Region	ON  Region.iRegion_ID = OpsArea.iRegion_ID and region.dtrowdeleted is null
	JOIN HouseLog ON House.iHouse_ID = HouseLog.iHouse_ID
	<!--- Project 30178 modification 11/14/2008 ssathya added this code --->
	<!--- 09/15/2010 Project 60038 Sathya commented and rewrote it--->
	<!--- JOIN TenantMissingItems ON TenantMissingItems.iHouse_id = House.iHouse_id --->
	LEFT JOIN TenantMissingItems ON TenantMissingItems.iHouse_id = House.iHouse_id
	<!--- End of the Project 60038 --->	
	<CFIF SESSION.UserID GT 1800 AND SESSION.UserID LTE 3000>
		WHERE House.cNumber = #SESSION.UserID#
		
	<!--- EXCEPTION FOR Bill McCarty TO SEE NE/IA OR House.ihouse_id IN (33,27,177,123,148,113,49) --->
<!--- 	<CFELSEIF SESSION.USERID EQ 3021>
		WHERE House.dtRowDeleted IS NULL AND (House.cStateCode IN ('NE','IA')) --->
		
<!--- 	<!--- EXCEPTION FOR Carrie Parker TO SEE AZ --->
	<CFELSEIF SESSION.USERID EQ 3151>
		WHERE House.dtRowDeleted IS NULL AND House.cStateCode IN ('AZ') --->

	<!--- EXCEPTION FOR LINDA CLARKE TO SEE IN/MI  ADDED Darlene Wedge to same Permissions 
		added Sara Kimball (04.05.04)--->
<!--- 	<CFELSEIF SESSION.USERID EQ 3218 OR SESSION.USERID EQ 3231 OR SESSION.USERID EQ 3149 OR SESSION.USERID EQ 3320>
		WHERE House.dtRowDeleted IS NULL AND House.cStateCode IN ('IN','MI') --->
	
<!--- 	<CFELSEIF SESSION.USERID EQ 3943 >	<!--- added for marty clark to view indiana houses in addition to her region 12-29-2014 sdf --->
		WHERE House.dtRowDeleted IS NULL AND House.iopsarea_id = 48 or house.ihouse_id in (110, 26, 50)	 --->

<!--- 	<CFELSEIF SESSION.USERID EQ 4189 >	<!--- added for Kristen Kerns to view additional houses 12-29-2014 sdf --->
		WHERE House.dtRowDeleted IS NULL AND   house.ihouse_id in (16,17,18,20,21,22,23,24,25,26,27,28,30,31,32,33,34,35,36,43,44,45,46,
47,48,49,50,54,55,56,57,58,59,60,61,62,64,65,66,67,68,69,70,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,
94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,125,126,127,128,130,131,
132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,150,151,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,
168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,
204,205,206,207,208,210,211,212,213,215,216,217,218,219,220,221,223,237,238,239,240,241,242,243,244,245) --->	
		
		
	<!--- EXCEPTION FOR MATTHEW THORNTON TO SEE S. CAROLINA HOUSES
	<CFELSEIF SESSION.USERID EQ 3178>
		WHERE (iDirectorUser_ID = 3163 OR iDirectorUser_ID = 3178) AND House.dtRowDeleted IS NULL
  --->
	
<!--- 	<!--- EXCEPTION FOR Mary Pattie West AVP (assisted VP does not have a place in db structure) --->
	<CFELSEIF SESSION.USERID EQ '3273'>
		WHERE (Region.iregion_id = 1) AND House.dtRowDeleted IS NULL --->
		
<!--- ==============================================================================
	HARD CODED FOR JUDY BENFIELD SINCE SHE IS AN RDO WHO "NEEDS" ACCESS TO 
	PAULA HEDRICKS HOUSES AS WELL AS CAROL SARTINS HOUSES BUT ONLY IN CLEBURN AND LEVELLAND
	<CFELSEIF SESSION.USERID EQ 3013>
		WHERE House.iHouse_id IN (47,199,83,20,37,188,111,91,67,62,35,22,85)
=============================================================================== --->
		
<!--- 	<CFELSEIF IsDefined("SESSION.AccessRights") AND SESSION.AccessRights NEQ "" AND (SESSION.USERID NEQ 3025 AND SESSION.USERID NEQ 3271)>
		WHERE House.dtRowDeleted IS NULL AND (#SESSION.AccessRights# = #SESSION.USERID#
		
  	<cfif isDefined("getuserids.userid") and getuserids.recordcount gt 0 and session.userid eq 3273>
			<!--- For Mary Pattie --->
			OR House.cNumber IN (#isBlank(valuelist(getuserids.userid),0)#)
		</cfif>
		) --->
	<CFELSE>	
		WHERE	
			<CFIF (IsDefined("SESSION.AD") AND SESSION.AD EQ 1 
					AND (IsDefined("SESSION.GroupList") 
					AND (findnocase("resource",SESSION.GroupList,1) GT 0 
					OR findnocase("payroll",SESSION.GroupList,1) GT 0
					OR findnocase("apps",SESSION.GroupList,1) GT 0
					OR findnocase("Culture",SESSION.GroupList,1) GT 0)))>
				House.cNumber is not null
	<!--- 		<CFELSE>	
				<CFIF IsDefined("SESSION.HouseAccessList") AND trim(SESSION.HouseAccessList) NEQ ''>
					<cfif SESSION.USERID is 3271 OR SESSION.USERID is 3167 
							OR SESSION.username eq 'stevea'>
						1=1
					<cfelse>
						House.ihouse_id IN (#isBlank(SESSION.HouseAccessList,0)#) 
					</cfif>
				<cfelseif --->
			<cfelseif  IsDefined("qryHouseList.ihouse_id") and qryHouseList.ihouse_id is not ''>
					  House.ihouse_id IN (#isBlank(valuelist(qryHouseList.ihouse_id),0)#)
			<CFELSE>
					House.cNumber IN (#isBlank(valuelist(getuserids.userid),0)#) 
				<!--- </CFIF> --->
			</CFIF>
		AND House.dtRowDeleted IS NULL
	</CFIF>
	<CFIF isDefined("SESSION.Application") AND SESSION.Application EQ 'InquiryTracking' OR IsDefined("url.app") AND url.app EQ 'InquiryTracking'>
	 OR House.iHouse_id = 200
	</CFIF>
	ORDER BY #orderby#
</CFQUERY>

<CFQUERY NAME='qClosedHouses' DBTYPE='QUERY'>
	select * from qUserHouses where bIsPDClosed = 1
</CFQUERY>

<CFSCRIPT>
	if (isDefined("qClosedHouses.recordcount") AND qClosedHouses.recordcount gt 0 ) { acctclose=1; } else { acctclose=0; }
</CFSCRIPT>

<CFOUTPUT>
<TITLE> TIPS4 - Select House </TITLE>
<BODY onKeyPress="HashKeyPress();">

<CFIF IsDefined ("URL.UrlStatusMessage") AND Len(URL.UrlStatusMessage) GT 0>
    <DIV CLASS="UrlStatusMessage"> #URL.UrlStatusMessage# </DIV>
</CFIF>

<!--- ==============================================================================
Include File to specify Session.Application location areas
=============================================================================== --->
<CFINCLUDE TEMPLATE="Inc_LocationArea.cfm">

<CFIF (IsDefined("url.app") AND url.app EQ 'InquiryTracking') OR (IsDefined("SESSION.Application") AND SESSION.Application EQ 'InquiryTracking')
	OR (IsDefined("url.app") AND url.app EQ 'CorporateFocalReview') OR (IsDefined("SESSION.Application") AND SESSION.Application EQ 'CorporateFocalReview')>
	<CFQUERY NAME='qUserHouses' DBTYPE='QUERY'>
		select * from quserhouses <CFIF (IsDefined("url.app") AND url.app NEQ 'InquiryTracking') OR (isDefined("SESSION.Application") AND SESSION.Application neq 'InquiryTracking')>where ihouse_id <> 200</CFIF>
	</CFQUERY>
	<CFSET tmpInquiry=1>
	<CFSET SESSION.HouseAccessList=ValueList(qUserHouses.iHouse_ID)>
</CFIF>

<CFIF ((IsDefined("SESSION.AccessRights") AND SESSION.AccessRights EQ 'iVPUser_ID' OR (SESSION.USERID EQ 3146 OR SESSION.USERID EQ 16 OR SESSION.USERID EQ 3184 OR SESSION.USERID EQ 3055)) AND SESSION.Application EQ 'CapitalExpenditure')>
	<CFLOCATION URL="../CapitalExpenditure/CapitalExpenditure.cfm?DivisionView=1" ADDTOKEN="yes">
</CFIF>

<CFIF IsDefined("SESSION.APPLICATION") AND SESSION.APPLICATION NEQ "">
	<H1 CLASS="PageTitle"> #SESSION.Application# - Select House </H1>
<CFELSE>
	<H1 CLASS="PageTitle"> <I>TIPS4 - Select House</I> </H1>
</CFIF>

<CFIF IsDefined("SESSION.APPLICATION") AND SESSION.APPLICATION EQ "TIPS4" AND (IsDefined("session.codeblock") AND listfindNocase(session.codeblock,23) GTE 1)>
    <CFSCRIPT>
		delorderby="HouseName";
		//set sort order for deleted houses
	 	if (NOT IsDefined("URL.SelectedSortOrder")) { delorderby="HouseName"; }
		/*mshah added here*/
	 	else if (URL.SelectedSortOrder EQ "Company") { delorderby="Rvh.cCompanyID,Division, Region, RVH.cStateCode, RVH.cCity"; }
		else if (URL.SelectedSortOrder EQ "Region") { delorderby="Division, Region, RVH.cStateCode, RVH.cCity"; }
		else if (URL.SelectedSortOrder EQ "OpsArea") { delorderby="Region, RVH.cStateCode, RVH.cCity";}    
		else if (URL.SelectedSortOrder EQ "State") { delorderby="RVH.cStateCode, RVH.cCity"; }
		else if (URL.SelectedSortOrder EQ "Number") { delorderby="cNumber"; }
		else if (URL.SelectedSortOrder EQ "Name") { delorderby="HouseName"; }
		else if (URL.SelectedSortOrder EQ "City") { delorderby="RVH.cCity"; }
		else if (URL.SelectedSortOrder EQ "deleted") { delorderby="mindtRowDeleted desc"; }
	</CFSCRIPT>
	<CFQUERY NAME="qDeletedHouses" DATASOURCE="#APPLICATION.datasource#">
		SELECT distinct RVH.iHouse_ID, RVH.cName as HouseName, RVH.cStateCode, RVH.cCity, RVH.cNumber, RVH.iOPSArea_ID, OA.cName as Region, R.iRegion_ID, R.cName as Division, RVH.dtRowDeleted as MindtRowDeleted
		,RVH.cCompanyID <!---Mshah added--->
		FROM <!---rw.vw_house_history RVH MShah commented VW and added house table ---> House rvh
		JOIN OpsArea OA ON (OA.iOpsArea_ID = RVH.iOpsArea_ID)
		JOIN Region R ON (R.iRegion_ID = OA.iRegion_ID)
		WHERE RVH.dtRowDeleted IS NOT NULL
		AND	RVH.iAcctUser_ID IS NOT NULL 
		<!---MShah added this--->
		and RVH.ihouse_ID <> 200  		
		or RVH.assetclass is null
		<!---GROUP BY RVH.iHouse_ID, RVH.cName, RVH.cStateCode, RVH.cCity, RVH.iOPSArea_ID, RVH.cNumber, OA.cName, R.iRegion_ID, R.cName, RVH.cCompanyID <!---Mshah added--->
		commented this as dont need group by now as records are coming from house table--->
		order by #delorderby#			
	</CFQUERY>
	<SCRIPT>
		o="";
		o+="<TABLE><TR>";
		<!---Mshah added company project--->
		o+="<TH> <A HREF='?SelectedSortOrder=Company&del=1' STYLE='color: white;'> Company </A></TH>";
		o+="<TH> <A HREF='?SelectedSortOrder=Region&del=1' STYLE='color: white;'> Division </A></TH>";
		o+="<TH> <A HREF='?SelectedSortOrder=Name&del=1' STYLE='color: white;'> House Name </A></TH>";
		o+="<TH> <A HREF='?SelectedSortOrder=OpsArea&del=1' STYLE='color: white;'> Region </A></TH>";
		o+="<TH> <A HREF='?SelectedSortOrder=State&del=1' STYLE='color: white;'> State </A></TH>";
		o+="<TH> <A HREF='?SelectedSortOrder=City&del=1' STYLE='color: white;'> City </A> </TH>";
		o+="<TH> <A HREF='?SelectedSortOrder=deleted&del=1' STYLE='color: white;'> Date Deleted </A> </TH></TR>";
		<CFLOOP QUERY='qDeletedHouses'>
		o+="<TR><TD> #qDeletedHouses.cCompanyID# </TD>";
		o+="<TD> #qDeletedHouses.Division# </TD>";
		o+="<TD> <A HREF='Reports/Menu.cfm?DeletediHouse_ID=#qDeletedHouses.iHouse_ID#'>#qDeletedHouses.HouseName#</A></TD>";
		o+="<TD> #qDeletedHouses.Region# </TD>";
		o+="<TD> #qDeletedHouses.cStateCode# </TD>";
		o+="<TD> #qDeletedHouses.cCity# </TD>";
		o+="<TD> #qDeletedHouses.MindtRowDeleted#</TD></TR>";
		</CFLOOP>
		o+="</TABLE>";	
		function showdeletedhouses() { 
			document.all['deletedhouses'].style.display="inline"; document.all['deletedhouses'].innerHTML=o; document.all['tipstable'].style.visibility="hidden";
		}
	</SCRIPT>
</CFIF>

<CFIF IsDefined("SESSION.APPLICATION")>
	<CFIF SESSION.APPLICATION EQ 'CapitalExpenditure' AND (SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146 OR SESSION.USERID EQ 36 OR SESSION.USERID EQ 3066 OR SESSION.USERID EQ 3229 OR SESSION.USERID EQ 3271)>
	<CFSET Center='text-align:center;'>
		<TABLE STYLE="border: 1px solid navy;" CELLPADDING=3 CELLSPACING=0>
			<TR><TH COLSPAN=100% STYLE="background: navy; font-size: 18;"><B>Capital Expenditure Administration (For Administrative Use Only)</B></TH></TR>
			<TR>
				<TD STYLE="#center# font-size: 16;"><A HREF="../CapitalExpenditure/ExpenditurePeriod/CapExPeriod.cfm">Expenditure Periods</A></TD>
				<TD STYLE="#center# font-size: 16;"><A HREF="../CapitalExpenditure/ExpenditureType/CapExType.cfm">Expenditure Types</A></TD>
				<TD STYLE="#center# font-size: 16;"><A HREF="../CapitalExpenditure/ExpenditureReason/CapExReason.cfm">Expenditure Reasons</A></TD>
				<TD STYLE="#center# font-size: 16;"><A HREF="../CapitalExpenditure/Priority/CapExPriority.cfm">Expenditure Priority</A></TD>
			</TR>
		</TABLE>
		<BR>
	</CFIF>
</CFIF>

</CFOUTPUT>

<CFIF SESSION.Application EQ 'TIPS4' AND (IsDefined("session.codeblock") AND listfindNocase(session.codeblock,23) GTE 1)>
	<FORM ACTION="Admin/RDOClose.cfm?RequestTimeout=3600" METHOD="post">
	<TABLE>
		<TR>
			<TD><A HREF="" STYLE="font-size:16;" onClick="showdeletedhouses(); return false;">[Show Deleted Houses]</A></TD>
			<TD STYLE="text-align:right"><A HREF="" STYLE="font-size:16;" onClick="document.all['deletedhouses'].style.display='none'; document.all['tipstable'].style.visibility='visible'; return false;">[Current House List Houses]</A></TD>
		</TR>
	</TABLE>
	<SPAN ID='deletedhouses'></SPAN> <SPAN ID='tipstable'>
	<CFIF IsDefined("url.del")><SCRIPT>showdeletedhouses();</SCRIPT></CFIF>
</CFIF>
<CFIF NOT IsDefined("SelectedSortOrder") OR SelectedSortOrder EQ "NAME"> 
	<B STYLE="font-size: 18;">Press the First Letter of the House Name to go to that letter</B>
</CFIF>
<TABLE>
<CFIF SESSION.Application EQ 'TIPS4' AND acctclose gt 0>
<TR><TD colspan="2" style="text-align:left;"> <cfif #SESSION.UserName# EQ "sfarmer" OR #SESSION.UserName# EQ "tbates" >	 <!--- Ganga Added 01/15/2013   Tim request to bring all active tenant report--->
				<A HREF="../TIPS4/House_Report/Report_Info.cfm"><font color="red" size="3"> House Assessment Tool Report</font></a><font color="red" size="1"> &nbsp;**New </font>			
	      </cfif> </TD>       <!--- END --->
	<TD COLSPAN=100 STYLE='text-align:center;'><INPUT TYPE='submit' Name='closehouses' VALUE='Close Selected Houses'></TD></TR>
	<!---<TR><TD COLSPAN=100 STYLE='text-align:center;'><INPUT TYPE='submit' Name='closehouses' VALUE='Close Selected Houses'></TD></TR>--->  <!--- Ganga Commented out  03/06/2013--->
</CFIF>
    <TR>
		<!---Mshah added company project--->
		<TH> <A HREF="?SelectedSortOrder=Company" STYLE="color: white;" onMouseOver="hoverdesc('Sort By Company');" onMouseOut="resetdesc();"> Company </A></TH>
        <TH> <A HREF="?SelectedSortOrder=Region" STYLE="color: white;" onMouseOver="hoverdesc('Sort By Division');" onMouseOut="resetdesc();"> Division </A></TH>
        <TH STYLE="text-align:center"> <A HREF="?SelectedSortOrder=Name" STYLE="color: white;" onMouseOver="hoverdesc('Sort By House Name');" onMouseOut="resetdesc();"> Name </A></TH>
		<!---mamta added medicaid project--->
		<TH STYLE="text-align:center"><a href="?SelectedSortOrder=Medicaid" style="color:white;" onMouseOver="hoverdesc('Sort by House Medicaid Status')" onMouseOut="resetdesc();">Medicaid</A>&nbsp;&nbsp;</TH>
        <!---mamta added memory care project--->
		<TH STYLE="text-align:center"><a href="?SelectedSortOrder=MemoryCare" style="color:white;" onMouseOver="hoverdesc('Sort by House MemoryCare Status')" onMouseOut="resetdesc();">Memory Care</A>&nbsp;&nbsp;</TH>
        <!--- Proj 26955 RTS 2/9/2009  For Bond indication --->
    	<TH nowrap STYLE="text-align:center"><a href="?SelectedSortOrder=Bond" style="color:white;" onmouseover="hoverdesc('Sort by House Bond Status')" onmouseout="resetdesc();"><u>Bond House</u></TH>
        <TH> <A HREF="?SelectedSortOrder=OpsArea" STYLE="color: white;" onMouseOver="hoverdesc('Sort By Region');" onMouseOut="resetdesc();"> Region </A></TH>
        <TH> <A HREF="?SelectedSortOrder=State" STYLE="color: white;" onMouseOver="hoverdesc('Sort By State');" onMouseOut="resetdesc();"> State </A></TH>
        <TH> <A HREF="?SelectedSortOrder=City" STYLE="color: white;" onMouseOver="hoverdesc('Sort By City');" onMouseOut="resetdesc();"> City </A> </TH>
        <TH NOWRAP>
			<CFIF SESSION.APPLICATION EQ 'TIPS4'>
				<A HREF="?SelectedSortOrder=Month" STYLE="color: white;" onMouseOver="hoverdesc('Sort By House Month');" onMouseOut="resetdesc();"> Tips Month</A> 
			<CFELSEIF SESSION.APPLICATION EQ 'AssessmentReview'>
				Last Entry
			</CFIF>
		</TH>
		<CFIF (IsDefined("session.codeblock") AND listfindNocase(session.codeblock,23) GTE 1) and SESSION.APPLICATION EQ 'TIPS4' AND acctclose gt 0>
			<TH> <A HREF="?SelectedSortOrder=PDClosed" STYLE="color: white;" onMouseOver="hoverdesc('Sort By Admin Close');" onMouseOut="resetdesc();"> Accounting Close </A> </TH>		
		</CFIF>		
		<!--- Project 20125 Modification. 06/24/08 ssathya adding the missing items list  98152 - 02-11-2013 Sfarmer, made the column sortable--->
		 <th nowrap><A HREF="?SelectedSortOrder=Missing" STYLE="color: white;" onMouseOver="hoverdesc('Sort By Missing Items');" onMouseOut="resetdesc();">Missing Items</A></th> 
		 <!--- <th nowrap><u>Missing Items</u> --->
		</th> 
    </TR>
    <CFOUTPUT QUERY="qUserHouses">
	
	<!--- *******************************************************************************
	Assessment Review LOOKUP
	If the SESSION.Application is Assessment Review Lookup the last entered period for 
	each house
	
				SELECT distinct top 1 AP.cDescription, AP.dtStartRange
			FROM AssessmentMaster AM
			JOIN AssessmentDetail AD ON AD.iAssessmentMaster_ID = AM.iAssessmentMaster_ID and AD.dtrowdeleted IS NULL
			AND AM.dtRowDeleted IS NULL AND AM.iHouse_ID = #qUserHouses.iHouse_ID#
			JOIN AssessmentPeriod AP ON (AM.iAssessmentPeriod_ID = AP.iAssessmentPeriod_ID AND AP.dtRowDeleted IS NULL)
			ORDER BY AP.dtStartRange desc
	******************************************************************************** --->
	<CFIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'AssessmentReview'>
		<CFQUERY NAME='qLastPeriod' DATASOURCE='#APPLICATION.datasource#'>
			SELECT distinct am.ihouse_id, ap.cdescription
			FROM AssessmentMaster AM
			JOIN AssessmentDetail AD ON AD.iAssessmentMaster_ID = AM.iAssessmentMaster_ID and AD.dtrowdeleted IS NULL
			JOIN AssessmentPeriod AP ON (AM.iAssessmentPeriod_ID = AP.iAssessmentPeriod_ID AND AP.dtRowDeleted IS NULL)
			WHERE ap.dtstartrange = (
							select max(dtstartrange) 
							from assessmentmaster iam
							join assessmentperiod iap on iap.iassessmentperiod_id = iam.iassessmentperiod_id
								and iam.dtrowdeleted is null
								and iap.dtrowdeleted is null
								and ihouse_id = am.ihouse_id
							)
			and am.ihouse_id = #qUserHouses.iHouse_ID#
		</CFQUERY>
	</CFIF>
        <cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
			<!---Mshah added company project--->
			 <TD CLASS="Color">   #qUserHouses.cCompanyID#    </TD>	
            <TD CLASS="Color">   #qUserHouses.RegionName#    </TD>			
			<TD CLASS="Color" NOWRAP STYLE="text-align: left;">
				<A NAME="#UCASE(TRIM(LEFT(qUserHouses.HouseName,4)))#"></A>
				<CFSCRIPT>
					if (LocationArea NEQ "") { thislocation=locationarea; } else {thislocation="MainMenu.cfm"; }
				</CFSCRIPT>
				<A HREF="#thislocation#?SelectedHouse_ID=#qUserHouses.iHouse_ID#">
					#qUserHouses.HouseName#
					<CFIF IsDefined("SESSION.UserID") AND SESSION.UserID EQ 3025 OR SESSION.UserID EQ 3146 OR SESSION.USERID EQ 3271>
						<B STYLE="font-size: 11;">|#qUserHouses.cNumber# : #qUserHouses.iHouse_ID#|</B>
					</CFIF>						
				</A>
			</TD>
			<!---medicaid project -mamta added--->
			<cfif #qUserHouses.bIsMedicaid# eq 1>
				<td CLASS="Color" NOWRAP STYLE="text-align: left;">Medicaid</td>
            <cfelse>
				<td CLASS="Color" NOWRAP></td>
			</cfif>
			<!---MemoryCare project -mamta added--->
			<cfif #qUserHouses.bIsMemoryCare# eq 1>
				<td CLASS="Color" NOWRAP STYLE="text-align: left;">Memory Care</td>
			<cfelse>
				<td CLASS="Color" NOWRAP></td>
			</cfif>
			<!--- Proj 26955 RTS 2/9/2009  For Bond indication --->
			<cfif #qUserHouses.iBondHouse# eq 1>
				<td CLASS="Color" NOWRAP>Bond</td>
			<cfelse>
				<td CLASS="Color" NOWRAP></td>
			</cfif>
			<TD CLASS="Color" NOWRAP> #qUserHouses.OpsAreaName# </TD>
			<TD CLASS="Color" STYLE="text-align: center;"> #qUserHouses.cStateCode# </TD>
			<TD CLASS="Color"> #qUserHouses.cCity# </TD>
			<TD CLASS="Color" NOWRAP STYLE="text-align: center;"> 
				<CFIF SESSION.APPLICATION EQ 'TIPS4'>
					<CFIF ListFindNoCase(SESSION.CodeBlock,23,",") EQ 0>
						#DateFormat(qUserHouses.dtCurrentTipsMonth,"mm/yyyy")#
					<CFELSE>
						<CFIF Day(TimeStamp) LT 20 OR (DateFormat(qUserHouses.dtCurrentTipsMonth,"yyyymm") EQ DateFormat(DateAdd("m",2,TimeStamp),"yyyymm"))>
							#DateFormat(qUserHouses.dtCurrentTipsMonth,"mm/yyyy")#
						<CFELSE>
							<EM STYLE='color:navy;'>#DateFormat(qUserHouses.dtCurrentTipsMonth,"mm/yyyy")#</EM>
						</CFIF>
					</CFIF>
					<CFIF qUserHouses.bIsPDclosed GT 0><BR><FONT STYLE="font-size: xx-small;">Admin. Closed</FONT></CFIF>
				<CFELSEIF SESSION.APPLICATION EQ 'AssessmentReview'>
					<CFIF qLastPeriod.cDescription NEQ ''>#qLastPeriod.cDescription#</CFIF>
				</CFIF>			
			</TD>
			<CFIF SESSION.APPLICATION EQ 'TIPS4' and quserhouses.bIsPDclosed gt 0 and (IsDefined("session.codeblock") AND listfindNocase(session.codeblock,23) GTE 1)>
				<CFIF SESSION.APPLICATION EQ 'TIPS4' and quserhouses.bIsPDclosed gt 0>

					<TD STYLE='text-align:center;'> <INPUT TYPE='checkbox' NAME='close_#quserhouses.ihouse_id#' VALUE='1'></TD>
				<CFELSE>
					<TD>&nbsp;</TD>
				</CFIF>
			<CFELSEIF (SESSION.APPLICATION EQ 'TIPS4') AND acctclose gt 0>
				<TD>&nbsp;</TD>
			</CFIF>
			
		<!--- Project 20125 modification. 06/24/08 ssathya to see if the count of missing tenant in the main page--->
<!--- Project 30178 modification ssathya commented this --->
	<!--- 	<cfquery name="MissingItemsDetails" datasource="#application.datasource#">
		select * from TenantmissingItems where ihouse_id =  #qUserHouses.iHouse_ID#
	</cfquery> 
	<cfif MissingItemsDetails.totaltenantInHouse neq '0'>--->
		
		<cfif qUserHouses.TenantWithMissingItems neq '0'>
	<td style="text-align: center;"> <a href="Tenant/MissingTenantItems.cfm?HouseID=#qUserHouses.iHouse_ID#" >#qUserHouses.TenantWithMissingItems#   
		   </td>
		  <!---mamta added to make table equal---> 
		 <cfelse><td style="text-align: center;">    
		  </cfif>
        </cf_ctTR>
</CFOUTPUT>
<CFIF SESSION.Application EQ 'TIPS4' AND acctclose gt 0>
	<TR><TD COLSPAN=100 STYLE='text-align:center;'><INPUT TYPE='submit' Name='closehouses' VALUE='Close Selected Houses'></TD></TR>
</CFIF>
</TABLE>
<CFIF SESSION.Application EQ 'TIPS4'></SPAN></FORM></CFIF>

<CFIF ListFindNoCase(valueList(qUserHouses.iHouse_ID),200,",") EQ 0 AND qUserHouses.recordCount LT 2 AND SESSION.Application EQ 'TIPS4'>
	<CFLOCATION URL = "MainMenu.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1">
<CFELSEIF ListFindNoCase(valueList(qUserHouses.iHouse_ID),200,",") EQ 1 AND qUserHouses.recordCount LTE 2 AND SESSION.Application EQ 'InquiryTracking'>
	<CFLOCATION URL='../MarketingLeads/Leads.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#' addtoken="yes">
</CFIF>

<CFOUTPUT>
	<CFIF qUserHouses.RecordCount EQ 1 OR (isDefined("tmpInquiry") AND tmpInquiry NEQ 1) OR (SESSION.Application eq 'CorporateFocalReview')> 
		<CFIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'CapitalExpenditure'>
			<!--- maybe should add something here to not auto redirect to SelectedHouse_ID so admin user can go back to main list of houses --->
			<Cfif isDefined("url.ListAll")>
				<!--- Try NO relocation: <CFLOCATION URL="Index.cfm?app=capex" ADDTOKEN="No"> --->
			<cfelse>
				<CFLOCATION URL="../CapitalExpenditure/CapitalExpenditure.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1" ADDTOKEN="No">
			</Cfif>
		<CFELSEIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'KeyInitiatives'>
			<CFLOCATION URL="../KeyInitiatives/KeyInitiatives.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1" ADDTOKEN="No">
		<CFELSEIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'AssessmentReview'>
			<CFLOCATION URL="../AssessmentReview/AssessmentReview.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1" ADDTOKEN="No">
		<CFELSEIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'EmployeeTraining'>
			<CFLOCATION URL="../EmployeeTraining/EmployeeTraining.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1" ADDTOKEN="No">
		<CFELSEIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'FocalReview'>
			<CFLOCATION URL="../FocalReview/Facility/FacilityReview.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1" ADDTOKEN="yes">	
		<CFELSEIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'CorporateFocalReview'>
			<CFLOCATION URL="../FocalReview/Company/CorporateReview.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1" ADDTOKEN="no">	
		<CFELSEIF IsDefined("SESSION.Application") AND SESSION.Application EQ 'TIPS4' AND qUserHouses.recordcount LTE 2>
			<CFLOCATION URL = "MainMenu.cfm?SelectedHouse_ID=#qUserHouses.iHouse_ID#&lim=1"> 
		</CFIF>
	</CFIF>
</CFOUTPUT>
<!---  <cfdump var="#session#">  --->
<!--- ==============================================================================
Include the intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Footer.cfm">
