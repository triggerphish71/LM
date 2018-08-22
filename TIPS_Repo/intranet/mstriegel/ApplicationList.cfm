<!----------------------------------------------------------------------------------------------
| ApplicationList.cfm                                                                          |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES - None                                                                     |
|----------------------------------------------------------------------------------------------|
| Called By: 		LoginIndex.cfm															   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|Paul Buendia| 06/18/2002 | Original Authorship                                                |
| MLAW       | 09/09/2005 | Restict the LOC & R&B Rate Increase Link to AR Admin Only          |
| ranklam    | 05/25/2006 | Added userid cookie for integration of .NET applications.          |
| MLAW       | 06/23/2006 | Added houseid cookie for integration of .NET applications.         |
|		     |            | Comment out alc/ranklam                                            |
| MLAW       | 09/13/2006 | add QCCI Link                                                      |
| ranklam    | 10/15/2006 | Removed spaces from ldap query.                                    |
|ranklam     | 01/31/2006 | add omniweb Link                                                   |
|ranklam     | 06/08/2006 | changed assessment tool link                                       |
| mlaw       | 06/15/2007 | Replace mprodoehl to jwilliams                                     |
| mlaw       | 10/31/2007 | Replace JLangford to alavalley                                     |
| mlaw       | 11/13/2007 | Add Process Invoice File link (AR admin only)                      |
|dburmeister | 08/20/2009 | Added RDWDLogging links                                            |
|dburmeister | 08/21/2009 | Added Survey links                                                 |
|dburmeister | 12/07/2009 | Added permissions to the Survey Links			                   |
|dburmeister | 05/14/2010 | Removed RDWDLogging Application link and edited report link        |
|cebbott     | 11/23/2010 | Page rewrite                                                       |
|mdvortsen	 | 01/08/2013 | Rename link name for Scorecard                                     |
|wthom  	 | 05/02/2013 | QCCI Report URL updated for new DEV environment                    |
|gthota  	 | 05/17/2013 | updating AD and TIP account application links                      |
|gthota  	 | 10/09/2013 | updating AD account user login application links                   |
|sfarmer  	 | 02/11/2014 | 113031 - FTA temporarily turned off                                |
|sfarmer  	 | 02/25/2014 | 113458 - QCCI changed to QCI  (menu name only)                     |
|sfarmer  	 | 06/23/2014 | 116056 - Update links to STAR to allow Greater Wisconsin region    |
|            |            | houses to use STAR8 while remaining house use original STAR        |
| sfarmer    | 10/08/2014 | added houses from opsarea (regions) DFW, West Texas, South Carolina|
|            |            | & New Jersey  to STAR8                                             |
|sfarmer     | 10/22/2014 | added E.Wa, ID, OR regions                                         |
|sfarmer     | 10/29/2014 | added regions Nothern Ohio & Southern Ohio                         |
|Sfarmer     | 11/06/2014 | All houses now point to http://enstarapp01/Star8/ Star8.5          |
|            |            | cleaned up references to GTHOTA and other x-employees              |
|Sfarmer     |01/08/2016  |Removed access to "Invoices Generator" and dropped                  |
|            |            |"Collection Report"                                                 | 
|            |            |from the house log-in portion of the application list               |
| sfarmer    | 05/12/2016 | removed rdWdLoggingValid, Employee Training, AlarmContacts         | 
----------------------------------------------------------------------------------------------->
MStriegel Test




<!---<cfdump var="#session#">--->
<cfset session.groupid = session.groupid & ',240'>
<!--- call the webservice with this persons username to determin if they have omniweb access --->
<!---<cftry>
<cfinvoke webservice="http://maple.alcco.com/OmniwebServices/ActiveDirectoryRoleService.asmx?WSDL" method="userHasRights" returnvariable="canViewOmniweb">
	<cfinvokeargument name="iUserName" value="#session.username#">
	<cfset reason="Webservice">
</cfinvoke>
<cfcatch>
	<cfset reason = "error">
	<cfset canViewOmniweb = false>
</cfcatch>
</cftry>--->

<!--- <cfset rdWdLoggingValid = true>
<cftry>
	<cfif isDefined("session.username")>
		<cfquery name="adQueryResult" datasource="RdWdLogging">
			EXECUTE sel_Access '#session.username#';
		</cfquery>	
	<cfelse>
		<cfset rdWdLoggingValid = false>
	</cfif>
<cfcatch>
	<cfset rdWdLoggingValid = false>
</cfcatch>
</cftry> --->

<cfset SurveyValid = true>
<cftry>
	<cfif isDefined("session.username")>
		<cfquery name="adQueryResult2" datasource="Survey">
			EXECUTE sel_Access '#session.username#';
		</cfquery>	
	<cfelse>
		<cfset SurveyValid = false>
	</cfif>
<cfcatch>
	<cfset SurveyValid = false>
</cfcatch>
</cftry>

<cfset invoiceApprovalProcess = false>
<cfset isCorpDoclinkUser = false>
<cfset isRegionalDoclinkUser = false>
<cftry>
	<cfif isDefined("session.username")>
		<cfquery name="regionalInvoiceApprovalProcess" datasource="DOCLINKALC">
			SELECT 
				cUserName
			FROM
				vw_UserAccountDetails
			WHERE
				cUserName = '#session.username#' AND 
				(cRole IN ('RD','RDO','OPS'));
		</cfquery>	
		<cfquery name="corpInvoiceApprovalProcess" datasource="DOCLINKALC">		
			SELECT 
				cUserName
			FROM
				vw_UserAccountDetails
			WHERE
				cUserName = '#session.username#' AND 
				((cRole = 'DVP') OR
				(cRole IN ('AP Specialist','AP Supervisor', 'Field Auditor', 'Help Desk')));
		</cfquery>			
					
		<cfif regionalInvoiceApprovalProcess.RecordCount is not "0">
			<cfset invoiceApprovalProcess = true>
			<cfset isRegionalDoclinkUser = true>
		<cfelseif corpInvoiceApprovalProcess.RecordCount is not "0">
			<cfset invoiceApprovalProcess = true>
			<cfset isCorpDoclinkUser = true>
		</cfif>	
	</cfif>		
	<cfcatch><!--- do nothing ---> </cfcatch>
</cftry>

<title>Enlivant Application List</title>
<cfoutput>

<!--- Include Stylesheet for list --->
<link rel="StyleSheet" type="text/css" href="http://#server_name#/Intranet/TIPS4/Shared/Style2.css">

<!--- new link for user administration --->
<cfif (isDefined("session.username") and session.username eq "vcpi")
	or ( isDefined("session.codeblock") and ( listfindnocase(session.codeblock,13,",") neq 0))>
	<style>
		.usermang {
		border: 1px solid black; padding: 2px 5px 2px 5px;
		font: 10pt ma; text-decoration:none; background-color: ##eaeaea;
		}
	</style>
	<a href="http://#server_name#/intranet/admin/index2.cfm?id=13"class="usermang">User Management</a>
	<br><br>
</cfif>
</cfoutput>

<cfif (not isDefined("url.ADSI")) and (not isDefined("session.userid") or not isDefined("session.UserName") )>
	<cfscript>
		if (isDefined("session.application") and session.application eq 'TIPS4') { structdelete(session,"application"); }
	</cfscript>
	<cfoutput>
		<cflocation url="http://#server_name#/intranet/LoginIndex.cfm?List=1">
	</cfoutput>
</cfif>

<cftry>
	<cfset u='DEVTIPS'>
	<cfset p='!A7eburUDETu'>		
	<cfoutput>
		<CFLDAP ACTION="query" NAME="GroupSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description" 
		SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=#TRIM(Session.UserName)#" USERNAME="#u#" PASSWORD="#p#">
	</cfoutput>
	<cfif isDefined("Auth_User")>
		<cfif FindNoCase('Ops Managers',GroupSearch.memberof) neq 0>
			<cfset VerifyOps = 'YES'>
		<cfelse>
			<cfset VerifyOps = 'NO'>
		</cfif>
	</cfif>

	<cfif FindNoCase('VP Division Operations',GroupSearch.memberof) neq 0>
		<cfset VerifyVPOPS = 'YES'>
	<cfelse>
		<cfset VerifyVPOPS = 'NO'>
	</cfif>

	<cfif FindNoCase('Accounting',GroupSearch.memberof) neq 0>
		<cfset VerifyAccounting = 'YES'>
	<cfelse>
		<cfset VerifyAccounting = 'NO'>
	</cfif>

	<cfif FindNoCase('Senior Leadership',GroupSearch.memberof) neq 0>
		<cfset VerifySeniorManagement = 'YES'>
	<cfelse>
		<cfset VerifySeniorManagement = 'NO'>
	</cfif>
	
	<cfcatch type="any"><!--- Ignore for now if the username does not equal the nt username ---></cfcatch>
</cftry>

<cfoutput>
<cfif isDefined("session.FullName")>
	<table cellpadding=3 style="width: 400;">
		<tr><td>#Session.FullName#</td><td><a href='http://#server_name#/intranet/logout.cfm'>Logout</a> </td></tr>
	</table>
</cfif>
</cfoutput>

<table cellpadding=3 style="width: 400;">
	<tr><th colspan="100%">Enlivant Applications List</TH></tr>
	<!--- Line added by Jaime Cruz 8/23/2008 as a way to let users know when TIPS is undergoing maintenance.  
	<tr><td align="center"><strong>TIPS AND SOLOMON WILL BE OFFLINE STARTING AT 8:00PM</strong></TD></tr>--->
	<cfif ( isDefined("session.userid") and trim(session.userid) NEQ '')
	and (not isDefined("session.AD") or ( (ListFindNoCase(session.Grouplist,'Accounting',",") gt 1 
	or ListFindNoCase(session.Grouplist,'Actg',",") gt 1) and
	ListFindNoCase(session.Grouplist,'Actg',",") eq 0))>

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

<!--- ==============================================================================
Retrieve UserID 
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
<!---<cfdump var="#getuserids#">--->
<CFIF NOT IsDefined("SESSION.UserId") OR SESSION.USERID EQ ''>
	<CFSET SESSION.UserId = getuserids.loginid>
</CFIF>

<!--- =============================================================================================
Select all of the houses for this user.
============================================================================================== --->
<CFQUERY NAME="qUserHouses"  DATASOURCE="#APPLICATION.datasource#">
    SELECT HouseLog.bIsPDClosed, House.iHouse_ID, House.cName AS HouseName ,House.cNumber ,House.cCity ,House.cStateCode
				,OpsArea.cName AS OpsAreaName ,Region.cName AS RegionName ,HouseLog.dtCurrentTipsMonth
    FROM House
	INNER JOIN  OpsArea	ON  OpsArea.iOpsArea_ID = House.iOpsArea_ID and opsarea.dtrowdeleted is null
	INNER JOIN  Region	ON  Region.iRegion_ID = OpsArea.iRegion_ID and region.dtrowdeleted is null
	JOIN HouseLog ON House.iHouse_ID = HouseLog.iHouse_ID

	<CFIF SESSION.UserID GT 1800 AND SESSION.UserID LTE 3000>
		WHERE House.cNumber = #SESSION.UserID#

	<CFELSEIF IsDefined("SESSION.AccessRights") AND SESSION.AccessRights NEQ "" > 
		WHERE House.dtRowDeleted IS NULL
		  AND (#SESSION.AccessRights# = #SESSION.USERID#)
		
	<CFELSE>
		WHERE
			<CFIF (IsDefined("SESSION.AD") AND SESSION.AD EQ 1
					AND (IsDefined("SESSION.GroupList")
					AND (findnocase("resource",SESSION.GroupList,1) GT 0
					OR findnocase("payroll",SESSION.GroupList,1) GT 0
					OR findnocase("apps",SESSION.GroupList,1) GT 0
					OR findnocase("Culture",SESSION.GroupList,1) GT 0)))>
				House.cNumber is not null
			<CFELSE>
				<CFIF IsDefined("SESSION.HouseAccessList") AND trim(SESSION.HouseAccessList) NEQ ''>
					<cfif SESSION.USERID is 3271 OR SESSION.USERID is 3167 OR SESSION.username eq 'stevea'>
						1=1
					<cfelse>
						House.ihouse_id IN (#isBlank(SESSION.HouseAccessList,0)#)
					</cfif>
				<CFELSE>
					House.cNumber IN (#isBlank(valuelist(getuserids.userid),0)#)
				</CFIF>
			</CFIF>
		AND House.dtRowDeleted IS NULL
	</CFIF>
	<CFIF isDefined("SESSION.Application") AND SESSION.Application EQ 'InquiryTracking' OR IsDefined("url.app") AND url.app EQ 'InquiryTracking'>
	 OR House.iHouse_id = 200
	</CFIF>
	ORDER BY House.cName
</CFQUERY>



<!--- Set HouseID list for the 
 Report --->
<CFSET SESSION.HouseAccessList=ValueList(qUserHouses.iHouse_ID)>

	

<script>
function showalert()
	 { alert('THE APPLICATION YOU REQUESTED IS CURRENTLY OFFLINE FOR MAINTENANCE. PLEASE TRY AGAIN AFTER RECEIVING NOTICE FROM IT DEPARTMENT THAT THE APPLICATION IS BACK ONLINE. THANK YOU FOR YOUR PATIENCE.'); }
</script>
	<tr>
		<td colspan="100%">
			<dd><li>
				<cfoutput>
					<a href="http://#server_name#/intranet/TIPS4/Index.cfm?app=AssessmentReview" target="_blank">Assessment Review</a>
				</cfoutput>
			</li>
		</td>
	</tr>
	<cfif session.userid IS "3944" 
	or session.userid IS "1551" 
	or session.userid IS "3935" 
	or session.userid is "3940" 
	or session.userid IS "3025" 
	or session.userid IS "36" 
	or session.userid IS "3329">
		<!--- <a href="javascript:showalert();"> --->
	<tr><td colspan="100%"><dd><li><a href="/intranet/TIPS4/tenant/incidententry.cfm" target="new">Incident Entry</a></li></dd></td></tr>
	</cfif>
<!--- 	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
		<tr>
			<td colspan="100%">
				<dd><li>
					<a href="InvoicesGenerator/Index.cfm" target="_blank">Process Invoices file</a>
				</li></dd>
			</td>
		</tr>
		<tr>
			<td colspan="100%">
				<dd><li>
					<a href="CollectionsGenerator/dsp_Menu.cfm" target="_blank">Process Collection Letters</a>
				</li></dd>
			</td>
		</tr>
	</cfif>  --->

   <tr>
		<td colspan="100%">
			<dd><li>
				<a href="http://endevstar01/star8/home/">STAR (Sales Tracking and Reporting)</a>
                              
			</li></dd>
		</td>
	</tr>
   
	<tr>
		<td colspan="100%">
			<dd><li>
				<a href="TIPS4/Index.cfm?app=TIPS4"> TIPS 4 (Tenant Invoice Profile System)</a>
			</li></dd>
		</td>
	</tr>
	<cfoutput>
	<!--- QCCI --->
		<form action="http://hood.alcco.com/redirect2/" method="post" name="QCCIForm">
			<tr>
				<td COLSPAN=100% NOWRAP><dd><li>
					<input type="hidden" name="userId" value="#session.userId#">
					<input type="hidden" name="houseId" value="#SESSION.HouseAccessList#">
					<a href="javascript:document.QCCIForm.submit()">QCI Report </a>
				</td>
			</tr>
		</form>
   </cfoutput>		
	
<!---	<cfoutput>

 	<cfset emplaccess="xxxxxx">
	<cfif ListFindNoCase("#emplaccess#", session.USERNAME, ",") gt 0>
		<cfset Session.Emplapp=1>
		<tr>
			<td colspan="100%">
				<dd>
				<li>
					<a href="http://#server_name#/intranet/employeetraining/index.cfm" target="_blank">Employee Training</a>
				</li>
				</dd>
			</td>
		</tr>
	</cfif>
	</cfoutput> --->
</cfif>


	<!--- asessmenttool access --->
	<cfquery name="qtoolaccess" datasource="TIPS4">
	select userid from assesstoolaccess where dtrowdeleted is null
	</cfquery>
	<cfset toollist=valuelist(qtoolaccess.userid)>
	<cfif (isDefined("session.userid") and listfindnocase(toollist,session.userid,",") gt 0)
	or (isDefined("VerifySeniorManagement") and YesNoFormat(VerifySeniorManagement) eq 'Yes')
	or (isDefined("VerifyMIS") and YesNoFormat(VerifyMIS) eq 'Yes')
	or (isDefined("VerifyVPOPS") and YesNoFormat(VerifyVPOPS) eq 'Yes')>
		<tr>
			<td colspan=100>
				<dd><li>
					<cfoutput>
					  <A href="http://#server_name#/intranet/AssessmentTool_v2/index.cfm" target="_aTool">Assessment Tool</a>
					</cfoutput>
				</li></dd>
			</td>
		</tr>
	</cfif>
	
<!--- LOGIN WITH DOMAIN ID TO GET THESE LINKS --->
   
	<cfparam name="Session.EID" default="">
	<cfparam name="Session.AD"  default="">
	
	<cfif Session.EID NEQ '' and session.AD eq 1>
	
<!--- ==============================================================================
Retrieve UserID 
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

<CFIF NOT IsDefined("SESSION.UserId") OR SESSION.USERID EQ ''>
	<CFSET SESSION.UserId = getuserids.loginid>
</CFIF>

          	
	<cfif Session.FullName eq 'Farmer Steve'  or Session.FullName eq 'Tim Bates' or Session.FullName eq 'Sue Martin'>
		<!--- <a href="javascript:showalert();"> --->
	<tr><td colspan="100%"><dd><li><a href="/intranet/TIPS4/tenant/incidententry.cfm" target="new">Incident Entry</a></li></dd></td></tr>
	</cfif>
	
	<tr>
		<td colspan="100%">
			<dd><li>
				<cfoutput>
					<a href="http://#server_name#/intranet/TIPS4/Index.cfm?app=AssessmentReview" target="_blank">Assessment Review</a>
				</cfoutput>
			</li>
		</td>
	</tr>

	<cfquery name="qtoolaccess" datasource="TIPS4">
	select userid from assesstoolaccess where dtrowdeleted is null
	</cfquery>
      <CFQUERY NAME="qUser_id"  DATASOURCE="DMS">
          SELECT * from Users where username ='#session.username#'
       </CFQUERY>
	  <!--- getuserids.loginid was #qUser_id.employeeid#  sf 07-23-2015--->
<CFQUERY NAME="qUserHouses"  DATASOURCE="#APPLICATION.datasource#">
    SELECT HouseLog.bIsPDClosed, House.iHouse_ID, House.cName AS HouseName ,House.cNumber ,House.cCity ,House.cStateCode
				,OpsArea.cName AS OpsAreaName ,Region.cName AS RegionName ,HouseLog.dtCurrentTipsMonth
    FROM House
	INNER JOIN  OpsArea	ON  OpsArea.iOpsArea_ID = House.iOpsArea_ID and opsarea.dtrowdeleted is null
	INNER JOIN  Region	ON  Region.iRegion_ID = OpsArea.iRegion_ID and region.dtrowdeleted is null
	JOIN HouseLog ON House.iHouse_ID = HouseLog.iHouse_ID

	<CFIF qUser_id.employeeid GT 1800 AND qUser_id.employeeid LTE 3000>
		WHERE House.cNumber = #getuserids.loginid#  

	<CFELSEIF IsDefined("SESSION.AccessRights") AND SESSION.AccessRights NEQ "" > 
		WHERE House.dtRowDeleted IS NULL
		  AND (#SESSION.AccessRights# = #getuserids.loginid#)
		
	<CFELSE>
		WHERE
			<CFIF (IsDefined("SESSION.AD") AND SESSION.AD EQ 1
					AND (IsDefined("SESSION.GroupList")
					AND (findnocase("resource",SESSION.GroupList,1) GT 0
					OR findnocase("payroll",SESSION.GroupList,1) GT 0
					OR findnocase("apps",SESSION.GroupList,1) GT 0
					OR findnocase("Culture",SESSION.GroupList,1) GT 0)))>
				House.cNumber is not null
			<CFELSE>
				<CFIF IsDefined("SESSION.HouseAccessList") AND trim(SESSION.HouseAccessList) NEQ ''>
					<cfif SESSION.USERID is 3271 OR SESSION.USERID is 3167 OR SESSION.username eq 'stevea'>
						1=1
					<cfelse>
						House.ihouse_id IN (#isBlank(SESSION.HouseAccessList,0)#)
					</cfif>
				<CFELSE>
					House.cNumber IN (#isBlank(valuelist(getuserids.userid),0)#)
				</CFIF>
			</CFIF>
		AND House.dtRowDeleted IS NULL
	</CFIF>
	<CFIF isDefined("SESSION.Application") AND SESSION.Application EQ 'InquiryTracking' OR IsDefined("url.app") AND url.app EQ 'InquiryTracking'>
	 OR House.iHouse_id = 200
	</CFIF>
	ORDER BY House.cName
</CFQUERY>
<CFSET SESSION.HouseAccessList=ValueList(qUserHouses.iHouse_ID)>
	<cfset toollist=valuelist(qtoolaccess.userid)>
	<cfif (isDefined("session.userid") and listfindnocase(toollist,session.userid,",") gt 0)
	or (isDefined("VerifySeniorManagement") and YesNoFormat(VerifySeniorManagement) eq 'Yes')
	or (isDefined("VerifyMIS") and YesNoFormat(VerifyMIS) eq 'Yes')
	or (isDefined("VerifyVPOPS") and YesNoFormat(VerifyVPOPS) eq 'Yes')>
		<tr>
			<td colspan=100>
				<dd><li>
					<cfoutput>
					<A href="http://#server_name#/intranet/AssessmentTool_v2/index.cfm" target="_aTool">Assessment Tool</a>
					</cfoutput>
				</li></dd>
			</td>
		</tr>
	</cfif>
	<cfif   session.username is "lsimms" or session.username is "swelker" >
			<tr>
				<td colspan="100%" nowrap>
					<dd><li>
						<A href="/intranet/doclink/nationalvendoradmin.cfm" target="new">Doclink National Vendor Administration</a>
					</li></dd>
				</td>
			</tr>
			<tr>
				<td colspan="100%" nowrap>
					<dd><li>
						<A href="/intranet/doclink/HouseAPAdmin.cfm" target="new">Doclink House vs. AP Rep Administration</a>
					</li></dd>
				</td>
			</tr>
		</cfif>
	 <cfif session.GroupList contains "DDHR" or session.username is "dgabriel" or findnocase("IT",session.GroupList) or session.username is "aknuth">
			<tr>
				<td colspan="100%" nowrap>
					<dd><li>
						<A href="http://dbprod02.alcco.com/ReportServer/Pages/ReportViewer.aspx?%2fTimeCard%2fEmployee+Acknowledgement&rs%3aCommand=Render&rc%3aParameters=Expanded">Employee Acknowledgement Document</a>
					</li></dd>
				</td>
			</tr>
		</cfif>

		<cfif findnocase("Legal",session.GroupList)  or findnocase("IT",session.GroupList) or  findnocase("DDHR",session.GroupList)>
			<tr>
				<td colspan="100%" nowrap>
					<dd><li>
				<A href="http://dbprod02.alcco.com/ReportServer/Pages/ReportViewer.aspx?%2fTimeCard%2feTime&rs:Command=Render">eTime Report</a>
					</li></dd>
				</td>
			</tr>
		</cfif>

	
    <cfif session.GroupList contains "RDO" or session.GroupList contains "DVP">
			<tr>

				<td colspan="100%" nowrap>
					<dd><li>
						<A href="/intranet/doclink/newvendorApproval.cfm" target="new">New Vendor Approval Administration</a>
					</li></dd>
				</td>
			</tr>
		</cfif> 
		<cfif session.GroupList contains "Accounting - Managers" or session.GroupList contains "Purchasing" 
		or session.username is "lsimms" or session.username is "jwilliams" or session.username is "chanelwilson"
		 or findnocase("IT",session.GroupList)>
			<tr>
				<td colspan="100%" nowrap>
					<dd>
					<li>
						<A href="/intranet/doclink/newvendorApproval.cfm?NVAadmin=Yes" target="new">New Vendor Approval Administration</a>
					</li>
					</dd>
				</td>
			</tr>
		</cfif>
		

		<cfif invoiceApprovalProcess eq true >
			<tr>
				<td COLSPAN=100% NOWRAP>
					<dd>
						<li>
						<cfoutput>	
					<a href="http://vmmapledev/DoclinkDotNet/Default.aspx?UserName=#SESSION.UserName#" target="_blank" >Invoice Approval Process</a>
						</cfoutput>
						</li>
					</dd>
				</td>
			</tr>			
		</cfif>

		<!--- <cfif session.username is "gthota" OR session.username is "gjaszewski" OR session.username is "tbates">--->
                  <tr>
			<td colspan="100%" nowrap>
				<dd>
				<li>
				<!---	<A href="http://vmappprod01dev3/intranet/fta/default.cfm" target="new">Online FTA</a> --->
                 <A href="/intranet/fta/default.cfm" target="new">Online FTA</a>
				</li>
				</dd>
			</td>
		</tr> 
             <!---   </cfif>--->
		<!---<cfif canViewOmniweb>
			<tr>
				<td colspan="100%" nowrap>
					<dd>
						<li>
							<A href="http://maple.alcco.com/OmniwebAdLogin/OmniwebLogin.aspx">Omniweb Login</a>
						</li>
					</dd>
				</td>
			</tr>
		</cfif>	--->
		
		
	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
		<tr>
			<td colspan="100%">
				<dd>
				<li>
					<a href="InvoicesGenerator/Index.cfm" target="_blank">Process Invoices file</a>
				</li>
				</dd>
			</td>
		</tr>
	</cfif> 

<!--- 		<cfif rdWdLoggingValid eq true>
			<cfloop query="adQueryResult">
				<cfif adQueryResult.n_AccessTo eq "Report">
					<tr>
					<td COLSPAN=100% NOWRAP>
					<dd>
						<li>
						<cfoutput>	
							<a href="http://maple/RdWdLogging/Report?userId=#SESSION.UserName#" target="_blank" >RD/WD Log in/out Report</a>
						</cfoutput>
						</li>
					</dd>
					</td>
					</tr>
				</cfif>
			</cfloop>
		</cfif> --->
		<!--- (Alarm Contact Info) if user is Administrator, Ops Spec, RDO, Property Mgr, Laurie Wiles --->
<!--- 		<cfif  isdefined("session.EID") and session.EID is not "" and isdefined("session.grouplist") and isdefined("session.ADdescription")
		and (session.ADdescription contains "Administrator" OR session.ADdescription contains "RDO" OR session.ADdescription 
		contains "Operations Spec"
		OR session.ADdescription contains "Property Manager" OR  session.grouplist contains "IT" or session.username contains "SBarrett")>
			<tr>
				<td COLSPAN=100% NOWRAP>
					<dd><li>
						<A href="/intranet/AlarmContacts/AlarmContact.cfm">
						Residence Alarm Contact Info</A> (due April 15th)
					</li></dd>
				</td>
			</tr>
		</cfif> --->

		  <cfif SurveyValid eq true> 
			 <cfloop query="adQueryResult2">
				<cfif adQueryResult2.n_AccessTo eq "Application"> 
					<tr>
						<td COLSPAN=100% NOWRAP>
						<dd>
							<li>
							<cfoutput>	
			<a href="http://hood/Scorecard/Default.aspx?UserName=#SESSION.UserName#" target="_blank">Resident Care and Quality Services Scorecard</a>
							</cfoutput>
							</li>
						</dd>
						</td>
					</tr>
			 	</cfif>
			</cfloop>  
		  </cfif> 
	   <tr>
			<td colspan="100%" nowrap>
				<dd><li>  
                 <a href="http://mserver01/intranet/doclink/doclinksearch.cfm" target="new">Search DocLink</a>
					<!---<a href="/intranet/doclink/doclinksearch.cfm" target="new">Search DocLink</a> --->
				</li></dd>
			</td>
		</tr>
 
		<tr>
			<td colspan="100%">
				<dd><li>
					<a href="http://endevstar01/star8/home/">STAR (Sales Tracking and Reporting)</a>
				</li></dd>
			</td>
		</tr>
    	  
		<tr>
			<td colspan="100%">
<!--- 				<cfif (ListFindNoCase(session.Grouplist,'HouseAdministrator',",")) gt 1>
				<cfelse> Removed this per Tim Bates 11/11/2015--->
					<dd><li>
						<a href="TIPS4/Index.cfm?app=TIPS4"> TIPS 4 (Tenant Invoice Profile System)</a>
						</li>
					</dd>
	<!--- 			</cfif> --->
			</td>		
		</tr>
        <CFQUERY NAME="qUser_id"  DATASOURCE="DMS">
          SELECT * from Users where username ='#session.username#'
       </CFQUERY>
	<cfoutput>
	
<!---  	<cfif #session.username# is 'sbackstrom'>
		<form action="http://Maple.alcco.com/ALCQCCI/default.aspx" method="post" name="QCCIForm2">
			<tr>
				<td COLSPAN=100% NOWRAP><dd><li>
					<input type="text" name="userId" value="#qUser_id.employeeid#">
					<input type="text" name="houseId" value="#SESSION.HouseAccessList#">
					<a href="javascript:document.QCCIForm2.submit()">QCI Report </a>
				</td>
			</tr>
		</form>	
	</cfif>  --->
	<!--- QCCI --->
		<form action="http://hood.alcco.com/redirect2/" method="post" name="QCCIForm">
			<tr>
				<td COLSPAN=100% NOWRAP><dd><li>
					<input type="hidden" name="userId" value="#getuserids.loginid#">
					<input type="hidden" name="houseId" value="#SESSION.HouseAccessList#">
					<a href="javascript:document.QCCIForm.submit()">QCI Report </a>
				</td>
			</tr>
		</form>
	
<!--- WAR REPORT 
		<form action="http://maple.alcco.com/ALCWAR/default.aspx" method="post" name="warForm">
			<tr>
				<td COLSPAN=100% NOWRAP><dd><li>
					<input type="hidden" name="userId" value="#qUser_id.employeeid#">
					<input type="hidden" name="houseId" value="#SESSION.HouseAccessList#">
					<a href="javascript:document.warForm.submit()">WAR Report</a>
				</td>
			</tr>
		</form>  
deactivated 08-22-2013 sdf --->
   </cfoutput>		
	
		<cfif session.AD eq 1 and session.AD eq 1 and 
		(isDefined("session.Grouplist") and (ListFindNoCase(session.Grouplist,'Accounting',",") eq 0 or ListFindNoCase(session.Grouplist,'MIS',",") NEQ 0))>

			<cfif session.username is "xxxxxx"  >
				<tr>
					<td colspan="100%" nowrap>
						<dd><li>
							<A href="/intranet/fta/GLcodeAdmin.cfm" target="new">FTA GL Code to Expense Category Administration</a>
						</li></dd>
					</td>
				</tr>
			</cfif>		
		</cfif>		
	</cfif>

<!--- 	<cfif (isDefined("session.AD") and session.AD eq 1)>
		<tr>
			<td style="font-style:italic"><font color="red">**If you are looking for TIPS Applications only, Please login using your intranet password rather than your network password.</font></td>
		</tr>
	</cfif>	 --->
</table>
<cfif (FindNoCase('MSIE 6.0', HTTP_USER_AGENT, 1) eq 0)> 
<cfloop index="I" from="1" to="30" step="1"><BR></cfloop></cfif>
<cfinclude template='Footer.cfm'>