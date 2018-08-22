<!----------------------------------------------------------------------------------------------
| DESCRIPTION:  ApplicationList.cfm                                                            |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		LoginIndex.cfm															   |
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
|dburmeister | 12/07/2009 | Added permissions to the Survey Links							   |
|dburmeister | 05/14/2010 | Removed RDWDLogging Application link and edited report link        |
| mdvortsen	 | 01/29/2013 | Canged link name for Scorecard app                                 |
| gthota     | 05/15/2013 | Cleaning application list ex-employee i's and emails               |
|wthom  	 | 08/08/2013 | Sonia Chambers granted access to Handbook Ack report               |
----------------------------------------------------------------------------------------------->

<!--- call the webservice with this persons username to determin if they have omniweb access --->
<cftry>
<cfinvoke webservice="http://maple.alcco.com/OmniwebServices/ActiveDirectoryRoleService.asmx?WSDL" method="userHasRights" returnvariable="canViewOmniweb">
	<cfinvokeargument name="iUserName" value="#session.username#">
	<cfset reason="Webservice">
</cfinvoke>
<cfcatch>
	<cfset reason = "error">
	<cfset canViewOmniweb = false>
</cfcatch>
</cftry>

<cfset rdWdLoggingValid = true>
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
</cftry>

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
				*
			FROM
				vw_UserAccountDetails
			WHERE
				cUserName = '#session.username#' AND 
				(cRole IN ('RD','RDO','OPS'));
		</cfquery>	
		<cfquery name="corpInvoiceApprovalProcess" datasource="DOCLINKALC">		
			SELECT 
				*
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
		<cfelse>
			<cfset invoiceApprovalProcess = false>
			<cfset isCorpDoclinkUser = false>
			<cfset isRegionalDoclinkUser = false>		
		</cfif>
	<cfelse>
		<cfset invoiceApprovalProcess = false>
		<cfset isCorpDoclinkUser = false>
		<cfset isRegionalDoclinkUser = false>			
	</cfif>
<cfcatch>
	<cfset invoiceApprovalProcess = false>
	<cfset isCorpDoclinkUser = false>
	<cfset isRegionalDoclinkUser = false>		
</cfcatch>
</cftry>

<title>ALC Application List</title>
<cfoutput>

<!--- Include Stylesheet for list --->
<link rel="StyleSheet" type="text/css" href="http://#server_name#/Intranet/TIPS4/Shared/Style2.css">


<!--- new link for user administration --->
<cfif (isDefined("session.username") and session.username eq "vcpi")
	or ( isDefined("session.codeblock")
				and ( listfindnocase(session.codeblock,13,",") neq 0)
	)>
	<style>
		.usermang {
		border: 1px solid black; padding: 2px 5px 2px 5px;
		font: 10pt ma; text-decoration:none; background-color: ##eaeaea;
		}
	</style>
	<a href="http://#server_name#/intranet/admin/index2.cfm?id=13"
	class="usermang">
	User Management
	</a>
	<br><br>
</cfif>


<!--- ==============================================================================
1) TIPS4 open to all users
2) Key Initiatives RESTRICTED FROM property managers
3) Assessment Review OPEN To NT QA Group and NT Accounting Group and House Logins
	CHANGED TO OPEN TO ALL EDIT ONLY For QA
=============================================================================== --->

<!--- if session.subFile_NBR is still open from FocalReview app, delete it --->
<cfif isdefined("session.subFile_NBR")> <cfset structdelete(session,"subFile_NBR")> </cfif>

<cfif (not isDefined("url.ADSI")) and (not isDefined("session.userid") or not isDefined("session.UserName") )>
	<cfscript>
		if (isDefined("session.application") and session.application eq 'TIPS4') { structdelete(session,"application"); }
	</cfscript>
	<cflocation url="http://#server_name#/intranet/LoginIndex.cfm?List=1">
</cfif>
<cfset AllowedUsers='3094,3086,3166,3025,36,3146,2,3147'>
<cfset Property='Ray Bowen, John Elf, Bob Roberts, Jon Mitchell, Larry Larson, Jim Brown, Greg Johnson'>

<cftry>

	<cfif isDefined("Auth_User")>
		<cfset NTUserName=ListGetAt(Auth_User, 2, "\")>
		<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#NTUserName#" group="Ops Managers" return="VerifyOps">
	</cfif>

	<!--- Check to see if this user's permissions within windows DC groups group --->
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="VP Division Operations" return="VerifyVPOPS">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="QI and Clinical Services" return="VerifyQA">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="Accounting" return="VerifyAccounting">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="Ops Managers" return="VerifyOpsManagers">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="East Division - Sales" return="VerifyEastSales">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="Central Division - Sales" return="VerifyCentralSales">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="West Division - Sales" return="VerifyWestSales">
	<cf_adsi task="VerifyGroupMembership" domain="ALC" user="#session.UserName#" group="Senior Leadership" return="VerifySeniorManagement">
	<cfcatch type="any"><!--- Ignore for now if the username does not equal the nt username ---></cfcatch>
</cftry>

<cfif isDefined("session.FullName")>
	<table cellpadding=3 style="width: 400;">
		<tr><td>#Session.FullName#</td><td><a href='http://#server_name#/intranet/logout.cfm'>Logout</a> </td></tr>
	</table>
</cfif>
<table cellpadding=3 style="width: 400;">
	<tr><th colspan="100%">ALC Applications List</TH></tr>
	<!--- Line added by Jaime Cruz 8/23/2008 as a way to let users know when TIPS is undergoing maintenance.  
	<tr><td align="center"><strong>TIPS AND SOLOMON WILL BE OFFLINE STARTING AT 8:00PM</strong></TD></tr>--->
	<cfif ( isDefined("session.userid") and trim(session.userid) NEQ '')
	and (not isDefined("session.AD") or ( (ListFindNoCase(session.Grouplist,'Accounting',",") gt 1 or ListFindNoCase(session.Grouplist,'Actg',",") gt 1) and ListFindNoCase(session.Grouplist,'Actg',",") eq 0)
	)>


<!--- MLAW 06/16/2006 To get the house_id for the login user --->
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

	<!--- EXCEPTION FOR Bill McCarty TO SEE NE/IA OR House.ihouse_id IN (33,27,177,123,148,113,49) --->
	<CFELSEIF SESSION.USERID EQ 3021>
		WHERE House.dtRowDeleted IS NULL AND (House.cStateCode IN ('NE','IA'))

	<!--- EXCEPTION FOR Carrie Parker TO SEE AZ --->
	<CFELSEIF SESSION.USERID EQ 3151>
		WHERE House.dtRowDeleted IS NULL AND House.cStateCode IN ('AZ')

	<!--- EXCEPTION FOR LINDA CLARKE TO SEE IN/MI  ADDED Darlene Wedge to same Permissions
		added Sara Kimball (04.05.04)--->
	<CFELSEIF SESSION.USERID EQ 3218 OR SESSION.USERID EQ 3231 OR SESSION.USERID EQ 3149 OR SESSION.USERID EQ 3320>
		WHERE House.dtRowDeleted IS NULL AND House.cStateCode IN ('IN','MI')

	<!--- EXCEPTION FOR Mary Pattie West AVP (assisted VP does not have a place in db structure) --->
	<CFELSEIF SESSION.USERID EQ '3273'>
		WHERE (Region.iregion_id = 1) AND House.dtRowDeleted IS NULL

	<CFELSEIF IsDefined("SESSION.AccessRights") AND SESSION.AccessRights NEQ "" AND (SESSION.USERID NEQ 3025 AND SESSION.USERID NEQ 3271)>
		WHERE House.dtRowDeleted IS NULL
		  AND (#SESSION.AccessRights# = #SESSION.USERID#

  	<cfif isDefined("getuserids.userid") and getuserids.recordcount gt 0 and session.userid eq 3273>
			<!--- For Mary Pattie --->
			OR House.cNumber IN (#isBlank(valuelist(getuserids.userid),0)#)
		</cfif>
		)
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
					<cfif SESSION.USERID is 3271 OR SESSION.USERID is 3167 >
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

<!--- Set HouseID list for the WAR Report --->
<CFSET SESSION.HouseAccessList=ValueList(qUserHouses.iHouse_ID)>

<!--- WAR REPORT --->
<!--- <cfif AUTH_USER eq "ALC\ranklam"> --->
		<form action="http://maple.alcco.com/ALCWAR/default.aspx" method="post" name="warForm">
		<tr><td><dd><li><a href="PaymentProcess/Index.cfm">Payment Process</a></td></tr>
		<tr><td COLSPAN=100% NOWRAP><dd><li>
		<input type="hidden" name="userId" value="#session.userId#">
		<input type="hidden" name="houseId" value="#SESSION.HouseAccessList#">
		<a href="javascript:document.warForm.submit()">
		WAR Report</a>

		</td>
		</tr>
		</form>
<!--- </cfif> --->
<!--- QCCI --->
		<form action="http://maple.alcco.com/ALCQCCI/default.aspx" method="post" name="QCCIForm">
		<tr><td COLSPAN=100% NOWRAP><dd><li>
		<input type="hidden" name="userId" value="#session.userId#">
		<input type="hidden" name="houseId" value="#SESSION.HouseAccessList#">
		<a href="javascript:document.QCCIForm.submit()">
			QCCI Report
		</a>
		</td>
		</tr>
		</form>
<!--- Added by Jaime Cruz 8/23/2008 to open alert window when Tips link is clicked. This is to be used whenever we need to take TIPS down for maintenance to prevent users from accessing tips. --->
<script>
function showalert()
	 { alert('THE APPLICATION YOU REQUESTED IS CURRENTLY OFFLINE FOR MAINTENANCE. PLEASE TRY AGAIN AFTER RECEIVING NOTICE FROM IT DEPARTMENT THAT THE APPLICATION IS BACK ONLINE. THANK YOU FOR YOUR PATIENCE.'); }
</script>
		<!--- Restore this link after maintenance is complete. <a href="javascript:showalert();"> OR <a href="TIPS4/Index.cfm?app=TIPS4">    Place the javascript:showalert link here after maintenance is complete. --->
	<!--- <cfif Session.FullName eq 'Jaime Cruz' or Session.FullName eq 'Gwendolyn Morgan'> --->
		<tr><td colspan="100%"><dd>
        <li><a href="http://appprod01/star/dashboard/" target="_blank">STAR (Sales Tracking and Reporting)</a></li>
      </dd></td></tr>
	<!--- </cfif> --->	
	<!--- <a href="TIPS4/Index.cfm?app=TIPS4"> --->
	<!--- <cfif Session.FullName eq 'Robert Schuette'><!--- or Session.FullName eq 'Gwendolyn Morgan'> ---> --->
		<tr><td colspan="100%"><dd><li><a href="TIPS4/Index.cfm?app=TIPS4"> TIPS 4 (Tenant Invoice Profile System)</a></li></dd></td></tr>
<!--- 	<cfelse>
	<tr><td colspan="100%"><dd><li><a href="javascript:showalert();"> TIPS 4 (Tenant Invoice Profile System)</a></li></dd></td></tr>
	</cfif> --->
	<!---  MLAW 09/13/2005 Rate Increase is only visible to Group 240 - AR Admin --->
<cfif findnocase("IT",session.GroupList)><!--- RTS added temp per Laurie 10/28/08  --->
<!---	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0>
      <tr><td colspan="100%"><dd>
        <li><a href="RateIncrease/add_loc.cfm" target="_blank"> AR House Admin. (LOC & R&B)</a></li>
      </dd></td></tr>
	</cfif>--->
</cfif>
	<!--- display link for Incident Entry if Nicole, Katie, Jay, Paul or STeve A or Christine --->
	<!---<cfif session.userid IS "3270" or session.userid IS "3271" or session.userid is "3334" or session.userid IS "3025" or session.userid IS "36" or session.userid IS "3329">--->
		<!--- <a href="javascript:showalert();"> --->
	<cfif Session.FullName eq 'Steve Farmer' or Session.FullName eq 'Ganga Thota' or Session.FullName eq 'Guy Jaszewski' or Session.FullName eq 'Tim Bates' or Session.FullName eq 'Sue Martin'>
	<tr><td colspan="100%"><dd><li><a href="/intranet/TIPS4/tenant/incidententry.cfm" target="new">Incident Entry</a></li></dd></td></tr>
	</cfif>
<!--- <a href="javascript:showalert();"> --->
	<cfif ListFindNoCase(session.CodeBlock, 33, ",") gt 0 or (isDefined("VerifyAccounting") and YesNoFormat(VerifyAccounting) eq 'Yes') or (isDefined("VerifyOps") and YesNoFormat(VerifyOps) eq 'Yes') or (session.Userid is "3304")>
		<!---<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/documentimaging/docsearch.cfm">Document Imaging</a></li></dd></td></tr>--->
		<cfif (isDefined("session.UserName") and session.userName eq 'KennethD' or session.userName eq 'PaulB')
			or (isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock, 13, ",") gt 0)>
				<!--- <a href="javascript:showalert();" > --->
			<tr><td><dd><li><a href='http://#server_name#/intranet/admin/index2.cfm?id=33&sessionid=#session.UserId#'style='font-weight:bold;' TARGET="_blank" ><b>Document Imaging Indexing</b></a></li></dd></td></tr>
		</cfif>
	</cfif>

<!---	<cfset PettyCheckList = 'SteveA,GloryC,PaulB,AllissaY,JCollins'>
	<cfif  FindNoCase(session.UserName, PettyCheckList, 1) gt 0 and isDefined("session.userid") or (isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock, 33, ",") gt 0)>
		<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/PettyChecks/CheckPetty.cfm?app=PettyChecks&UID=#session.UserID#">Petty Checks</a></li></dd></td></tr>
	</cfif>--->

<!---	<cfscript>
		if (1 eq 1) { location="http://#server_name#/intranet/CapitalExpenditure/index.cfm"; }
		else { location="http://#server_name#/intranet/TIPS4/Index.cfm?app=capex"; }
	</cfscript>

		<tr><td colspan="100%"><dd><li><a href="#location#"> Capital Expediture Request</a></li></dd></td></tr>--->

	<!---
	<cfif FindNoCase(session.FULLNAME, Property, 1) eq 0>
		<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/TIPS4/Index.cfm?app=keyinitiatives">Key Initiatives 2002 </a></li></dd></td></tr>
	</cfif>
	--->

	<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/TIPS4/Index.cfm?app=AssessmentReview" target="_blank">Assessment Review</a></li></td></tr>

	<cfset emplaccess="paulb,stephend,katied,jmoore">
	<!---
	<cfset emplaccess="stevea,paulb,stephend,sandrap,gloryc,klewis,lindam,stevek,stevenv,bobe,dwudtke,mark,teresa,matthewt,shareec">
	,Cascade House,Baily House,Granville House
		or (isDefined("VerifyVPOPS") and YesNoFormat(VerifyVPOPS) eq 'Yes')
		or (isDefined("VerifySeniorManagement") and YesNoFormat(VerifySeniorManagement) eq 'Yes')
	--->
<!---	<cfif ListFindNoCase("#emplaccess#", session.USERNAME, ",") gt 0>
		<cfset Session.Emplapp=1>
		<!--- <tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/TIPS4/Index.cfm?app=EmployeeTraining">Employee Training</a></li></dd></td></tr> --->
		<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/employeetraining/index.cfm" target="_blank">Employee Training</a></li></dd></td></tr>
	</cfif>--->

<cfset InquiryList="paulb,stephend,katied,steveV,teresa,lindam,judyr,carolew,jouellette,lwiles,ADashiell,GinaP,LHumphrey,paris oaks house,wren house,Plano Lodge,katy house,wheeler house,bradfield house">
	<cfif session.userid GTE 1800 and session.userid lte 2000>
		<cfquery name="qHouseData" datasource="#application.datasource#">
			select cNumber from house where dtrowdeleted is null and cnumber = '#session.userid#' and cStateCode='SC'
		</cfquery>
		<cfset SouthCarolinaAccess=0>
		<cfif trim(qHouseData.cNumber) eq trim(session.userid)><cfset SouthCarolinaAccess=1></cfif>
	</cfif>
	<cfif not isdefined("southcarolinaaccess")><cfset SouthCarolinaAccess = 0></cfif>

<!---	<cfif ListFindNoCase(InquiryList, session.USERNAME, ",") gt 0
		or (isDefined("VerifyOpsManagers") and YesNoFormat(VerifyOpsManagers) eq 'Yes')
		or (isDefined("VerifyWestSales") and YesNoFormat(VerifyWestSales) eq 'Yes')
		or (isDefined("VerifyCentralSales") and YesNoFormat(VerifyCentralSales) eq 'Yes')
		or (isDefined("VerifyEastSales") and YesNoFormat(VerifyEastSales) eq 'Yes')
		or (isDefined("VerifySeniorManagement") and YesNoFormat(VerifySeniorManagement) eq 'Yes')
		or (isDefined("session.userid") and (session.userid eq 1965 or session.userid eq 1922))
		or (FindNoCase("House",session.UserName,1) gt 0 and (isDefined("session.userid") and (session.userid GTE 1800 or session.userid lte 2000)) )
		or (SouthCarolinaAccess eq 1)
		or (1 eq 1)
		>
		<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/TIPS4/Index.cfm?app=InquiryTracking" target="_blank">Inquiry Tracking</a></li></dd></td></tr>
	</cfif>--->

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
	<tr><td colspan=100><dd><li><A href="http://#server_name#/intranet/AssessmentTool_v2/index.cfm" target="_aTool">Assessment Tool</a></li></dd></td></tr>
	</cfif>

	<!--- MLAW 09/28/2007 It is only visible to Group 240 - AR Admin --->
	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
		  <tr><td colspan="100%"><dd>
			<li><a href="InvoicesGenerator/Index.cfm" target="_blank">Process Invoices file</a></li>
		  </dd></td></tr>
	</cfif>

	<!--- MLAW 12/21/2007 It is only visible to Group 240 - AR Admin --->
	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
      <tr><td colspan="100%"><dd>
        <li><a href="CollectionsGenerator/dsp_Menu.cfm" target="_blank">Process Collection Letters</a></li>
      </dd></td></tr>
	</cfif>
	<!---<cfif Session.FullName eq 'Jaime Cruz' or Session.FullName eq 'Robert Schuette'>--->
	<cfif Session.FullName eq 'Steve Farmer' or Session.FullName eq 'Ganga Thota' or Session.FullName eq 'Guy Jaszewski' or Session.FullName eq 'Tim Bates'>
		<tr><td colspan="100%"><dd>
        <li><a href="TIPS4/NewTenantImport/import.cfm" target="_blank">New Resident Import</a></li>
      </dd></td></tr>
	</cfif>
	
	
	<!---
	<cfset AssessmentToolList='stevea,gloryc,paulb,kdeborde,sdavison,stevenv,lindam,label,bobe,teresa,cbarnes,scummings,matthewt,mark,dwudtke,lwiles,billm,zetatest house'>
	<cfif ListFindNoCase(AssessmentToolList, session.USERNAME, ",") gt 0
		or (isDefined("VerifySeniorManagement") and YesNoFormat(VerifySeniorManagement) eq 'Yes')
		or (isDefined("VerifyOpsManagers") and YesNoFormat(VerifyOpsManagers) eq 'Yes')>
		<tr><td colspan="100%"><dd><li><a href="http://#server_name#/intranet/assessmenttool/Index.cfm?app=AssessmentTool" target="_blank">Assessment Tool</a></li></dd></td></tr>
	</cfif>
	--->

	<cfset focalaccess=0>
	<cfif isDefined("session.EID") and session.EID is not "">

	<!--- display link for Project Request Admin if Steve A or Glory --->
	<!--- <cfif findnocase("IT",session.GroupList)>
	<!---<cfif (session.EID IS "A8W018047" or session.EID IS "A8W018551")> --->
	<tr><td colspan="100%"><dd><li><A href="/intranet/IT_ProjectRequest/ProjectRequest_View_Admin.cfm" target="new">IT Project List (Admin)</a></li></dd></td></tr>
	</cfif> --->

	<cfif isDefined("session.FocalManagerEIDs")><!--- <cfif auth_user is "ALC\Kdeborde"><tr><td colspan="100%">#session.FocalManagerEIDs#</td></tr></cfif>--->
		<cfloop INDEX=L LIST='#session.FocalManagerEIDs#' DELIMITERS="_"> <!--- list item: #L#<BR>   --->
			<cfif findnocase(L,session.EID,1)><cfset focalaccess=1></cfif><!--- session.eid: #session.eid#<BR> --->
			<!--- focalaccess: #focalaccess#<p> --->
		</cfloop>
<!--- 		<cfloop INDEX=L LIST='#session.FocalManagers#' DELIMITERS="_"> list item: #L#<BR>
			<cfset lastname= GetToken(L,1,",")> ln: #lastname#<BR>
			<cfset firstname= GetToken(L,2,",")> fn: #firstname#<BR>
			<cfset firstnamepos = Find(" ",firstname,1)>firstnamepos: #firstnamepos#
			<cfif firstnamepos gt 0><cfset num=firstnamepos-1><cfelse><Cfset num=20></cfif><BR>
			<cfset firstname = #LEFT(firstname,num)#> fn: #firstname#<BR>
			<cfset middlename= GetToken(L,2," ")>mn: #middlename#<BR>fullname: #session.fullname#<BR>
			<cfif findNoCase("-",lastname,1) gt 0>
				<cfset last1= GetToken(lastname,1,"-")>
				<cfset last2= GetToken(lastname,2,"-")>
				<cfif (findnocase(last1,session.fullname,1) gt 0 or findnocase(last2,session.fullname,1) gt 0) and findnocase(firstname,session.fullname,1) gt 0><cfset focalaccess=1></cfif>
			<cfelse>
				<cfif findnocase(lastname,session.fullname,1) gt 0 and findnocase(firstname,session.fullname,1) gt 0><cfset focalaccess=1></cfif>
			</cfif>focalaccess: #focalaccess#<p>
		</cfloop> --->
	</cfif>

	<cfif session.GroupList contains "DDHR" or session.username is "aknuth" or session.username is "dgabriel" or session.username is "schambers" or findnocase("IT",session.GroupList) or findnocase("Legal",session.GroupList)> 
           <tr>
              <td colspan="100%" nowrap>
                <dd><li>
                     <A href="http://dbprod02.alcco.com/ReportServer/Pages/ReportViewer.aspx?%2fTimeCard%2fEmployee+Acknowledgement">Employee Acknowledgement Document</a>
                 </li></dd>
               </td>
            </tr>
    </cfif>

	<cfif findnocase("Legal",session.GroupList) or findnocase("DDHR",session.GroupList) or findnocase("IT",session.GroupList) or session.username is "snatarajan">
			<tr>
				<td colspan="100%" nowrap>
					<dd><li>
						<A href="http://dbprod02.alcco.com/ReportServer/Pages/ReportViewer.aspx?%2fTimeCard%2feTime&rs:Command=Render">eTime Report</a>
					</li></dd>
				</td>
			</tr>
		</cfif>

	<!--- <cfif ((focalaccess eq 1 or ( (remote_addr eq '10.1.0.201' or remote_addr eq '10.1.0.211' or remote_addr eq '10.1.4.218' or session.username is "bbowen") and  isDefined("session.AD"))))> --->
<!---	<cfif AUTH_USER is "ALC\KDeborde">
		<cfset FocalLocation = 'Tips4/Index.cfm?app=CorporateFocalReview'>
		<tr><td colspan="100%"><dd><li><a href="#focallocation#" target="new">Corporate Level Focal Review</a></li></dd></td></tr>
	</cfif>--->
	<cfif ((isDefined("session.AD") and session.AD eq 1) and (isDefined("session.Grouplist") and (ListFindNoCase(session.Grouplist,'Accounting',",") eq 0 or ListFindNoCase(session.Grouplist,'MIS',",") NEQ 0)))>
		<cfscript>
			if (isDefined("session.AD") and session.AD eq 1){ FocalLocation = 'Tips4/Index.cfm?app=FocalReview target=_blank'; }
			else { FocalLocation = 'http://#server_name#/intranet/loginindex.cfm?focal=1 target=_blank'; }
		</cfscript>
		<!--- <dd><li>Facility Focal Review is locked down for upload.</li></dd> --->
		<!--- Admin in AD must be member of "HouseAdministrator" group in order to see the below link (in order to have a value in Session.HouseAccessList) --->
		<!--- <cfif session.HouseAccessList is not "" or session.GroupList contains "RDO" or session.grouplist contains "Regional VP" or session.grouplist contains "Senior Leadership" or (session.username is "kdeborde" or session.username is "bbowen")>---><!---<cfif session.username is "kdeborde" or session.username is "JanF"><tr><td colspan="100%" nowrap><dd><li><a href="#focallocation#" target="new">House Level Focal Review</a></li></dd></td></tr></cfif>--->
		<cfif isdefined("session.EID") and session.EID is not "">
			<!--- run AD query to get list of all House Administrators and all AP people and all RDO's and all VPs (and Steve A, me, Kenneth, Paul, Glory --->
			<cfldap action="query" name="FindAccessDocLinkInvoices" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,dn,Description" SERVER="#ADserver#" PORT="389" FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(objectClass=user)(|(Description=*RDO*)(Description=*Administrator)(Description=*VP*)(Description=* MA)(Description=*AA*)(Description=*Ops Specialist*)(Description=*Operations Specialist*)(Description=*IT Support*)(Description=*IT Applications*)(Description=* AP *))(!(Description=*Mailbox*)))" USERNAME="ldap" PASSWORD="paulLDAP939">
			<cfset doclinkinvoiceslist = #ValueList(FindAccessDocLinkInvoices.physicaldeliveryofficename)#>
			<cfset doclinkinvoiceslist = #listappend(doclinkinvoiceslist,'A8W018047,A8W037939,A8W035439,A8W021114,A8W018551')#>
<!---	Remmed by cebbott for 66886		
			<!--- also only display self and leadership evals if the user is found in the BOSS table --->
			<cfquery name="FindUserInBossTable" datasource="FocalReview">
				select * from Boss_Table2004 where EID = '#session.EID#' and iYear = 2005
			</cfquery>

			<!--- <tr><td colspan="100%" nowrap><dd><li>Self Evaluation & Leadership Review (Coming This Afternoon if applicable for you) </li></dd></td></tr> --->
			<cfif FindUserInBossTable.recordcount is not 0 AND LEFT(Session.EID,3) is not "EXT">

			<!--- <cfif (session.username is "bbowen")> --->
				<!--- <tr><td colspan="100%" nowrap><dd><li><a href="/intranet/focalreview/createselfevaluation.cfm" target="new">Self Evaluation</a> </li></dd></td></tr> --->
				<!--- <cfif session.EID is not "A8W031776">
					<tr><td colspan="100%" nowrap><dd><li><a href="/intranet/focalreview/createleadershipreview.cfm" target="new">Leadership Review</a> </li></dd></td></tr>
				</cfif> --->
			</cfif>
Remmed by cebbott for 66886	--->
			<tr><td colspan="100%" nowrap><dd><li><a href="/intranet/doclink/doclinksearch.cfm" target="new"> <!--- <a href="javascript:showalert();"> --->Search DocLink</a></li></dd></td></tr>
			<!--- if user is Benny or Alis or me or glory or Storm or Jennifer L., show this link --->
			<cfif Session.UserName is "jwilliams" or Session.username is "lsimms">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/nationalvendoradmin.cfm" target="new">Doclink National Vendor Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is Alis or me or Storm or Jennifer L., show this link --->
			<cfif Session.username is "jwilliams">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/HouseAPAdmin.cfm" target="new">Doclink House vs. AP Rep Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is AP, show this link --->
			<cfif Session.Grouplist contains "Accounts Payable">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/probleminvoice.cfm" target="new">Submit Problem Invoice Reasons</a></li></dd></td></tr>
			</cfif>
			<!--- if user is a DVP, show this link --->
			<cfif session.GroupList contains "DVP">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/newvendorApproval.cfm" target="new">New Vendor Approval Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is in Purchasing, show this link --->
			<cfif session.GroupList contains "Accounting - Managers" or session.GroupList contains "Purchasing" or session.username is "jwilliams" or session.username is "wthom">>
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/newvendorApproval.cfm?NVAadmin=Yes" target="new">New Vendor Approval Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is an administrator, MA, RDO, VP, AA, Ops Specialist, IT Support or in AP, show this link --->
			<cfif ListFindNoCase(doclinkinvoiceslist,session.EID) is not 0 And isRegionalDoclinkUser eq false>
				<!--- <tr><td colspan="100%" nowrap><dd><li> <A href="/intranet/doclink/readscans.cfm" target="new">Key-In Invoices</a></li></dd></td></tr> --->
				<!--- <tr><td colspan="100%" nowrap><dd><li><A href="/intranet/fta/invoiceentry.cfm" target="new">View Monthly Invoices for Excel FTA</a></li></dd></td></tr> --->
			</cfif>
			<!--- if user is a VP, RDO or in Senior Leadership, show link --->
			<!--- <cfif session.grouplist contains "Senior Leadership" or session.ADdescription contains "VP" or session.ADdescription contains "RDO" or session.ADdescription contains "Operations Specialist" or find("IT",session.GroupList) is not "0"> --->
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/fta/default.cfm" target="new">Online FTA</a></li></dd></td></tr>
			<!--- </cfif> --->

			<!-- if user is Cindy Roy, Anthony Ferreri, Mike Petrick, Inna Yufa and Nancy Kehl , show link --->
			<cfif session.username is "dvanzee" or session.username is "iyufa" or session.username is "dvaladez" or session.username is "aferreri" or session.username is "nkehl" or session.username is "mchrisian" or session.username is "kschlei">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/fta/GLcodeAdmin.cfm" target="new">FTA GL Code to Expense Category Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is RDO, RSD, Regional VP, Wally or Tracy or Ray or Davison or Noel or Katie D., show link --->
		<cfif findnocase("IT",session.GroupList)><!--- RTS added temp per Laurie 10/28/08  --->
	<!---		<cfif session.grouplist contains "Regional VP" or SEssion.Username is "wlevonowich" or Session.username is "tshilling" or session.username is "rschweer" or session.username is "ncook" or session.ADdescription contains "RDO" or session.grouplist contains "RSD">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/rateincrease/default.cfm" target="new">2006 New Move-In Rate Increase Worksheet</a></li></dd></td></tr>
			</cfif>--->

			<!--- if user is Regional VP or Steve A or me, show link --->
<!---			<cfif session.username is "kdeborde" > 
				<tr><td COLSPAN=100% NOWRAP><dd><li><A href="/intranet/rateincrease/residentrateincrease.cfm">2005 Private Resident Rate Increases</A></li></dd></td></tr>
			</cfif>--->
		</cfif>
			<!--- if user Admin or above, or ops specialist, or IT, but not Nurse show this link --->
			<cfif isdefined("session.EID") and session.EID is not "">
				<CFLDAP ACTION="query" name="FindAccessCareerLadder" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,dn,Description" SERVER="#ADserver#" PORT="389" FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(objectClass=user)(|(Description=*RDO*)(Description=*Administrator)(Description=*VP*)(Description=*Ops Specialist*)(Description=*IT Support*))(!(Description=*Mailbox*)))" USERNAME="ldap" PASSWORD="paulLDAP939">
				<cfset CareerLadderList = #ValueList(FindAccessCareerLadder.physicaldeliveryofficename)#>
				<cfset CareerLadderList = #listappend(CareerLadderList,'A8W035223')#><!--- add Katrina --->
				<!---<cfif FindNoCase(session.EID,CareerLadderList)>
					<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/careerladder/test.cfm">Career Ladder</a></li></dd></td></tr>
				</cfif>--->
			</cfif>
			<!--- ranklam - added on 11/17/2005--->
			<!--- rschuette 10/27/2009 added security --->
<!---			<cfif findnocase("_ALC IT",session.GroupList)>
			<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/RateIncrease/index.cfm" target="_blank">Rate Increase Application</a></li></dd></td></tr>
			</cfif>--->
			<!--------------------------------------------------------------------------------------------------------------
			*         ranklam - added on 02/08/2007 - canviewomniweb is set by a webservice at the top of this page        *
			--------------------------------------------------------------------------------------------------------------->
			<cfif canViewOmniweb>
				<tr><td colspan="100%" nowrap><dd><li><A href="http://maple.alcco.com/OmniwebAdLogin/OmniwebLogin.aspx">Omniweb Login</a></li></dd></td></tr>
			</cfif>
			<!--- (Alarm Contact Info) if user is Administrator, Ops Spec, RDO, Property Mgr, Laurie Wiles --->
			<cfif  isdefined("session.EID") and session.EID is not "" and isdefined("session.grouplist") and isdefined("session.ADdescription")
			and (session.ADdescription contains "Administrator" OR session.ADdescription contains "RDO" OR session.ADdescription contains "Operations Spec"
			OR session.ADdescription contains "Property Manager" OR  session.grouplist contains "IT")>
				<tr><td COLSPAN=100% NOWRAP><dd>
				  <li><A href="/intranet/AlarmContacts/AlarmContact.cfm">Residence Alarm Contact Info</A> (due April 15th) </li>
				</dd></td></tr>
			</cfif>
			<cfif invoiceApprovalProcess eq true>
				<tr><td COLSPAN=100% NOWRAP><dd>
				  	<li>	
						<a href="http://maple/DoclinkDotNet/InvoiceMgt.aspx?UserName=#SESSION.UserName#" target="_blank" >
					  		Invoice Approval Process
						</a>
					</li>
				</dd></td></tr>			
			</cfif>
			<cfif rdWdLoggingValid eq true>
				<cfloop query="adQueryResult">
					<cfif adQueryResult.n_AccessTo eq "Report">
						<tr><td COLSPAN=100% NOWRAP><dd>
						  	<li>	
								<a href="http://maple/RdWdLogging/Report?userId=#SESSION.UserName#" target="_blank" >
							  		RD/WD Log in/out Report
								</a>
							</li>
						</dd></td></tr>
					</cfif>
				</cfloop>
			</cfif>
			<cfif SurveyValid eq true>
				<cfloop query="adQueryResult2">
					<cfif adQueryResult2.n_AccessTo eq "Application">
						<tr><td COLSPAN=100% NOWRAP><dd>
			 				<li>	
								<a href="http://maple/survey/Default.aspx?UserName=#SESSION.UserName#" target="_blank" >
				  					Resident Care and Quality Services Scorecard 
								</a>
							</li>
						</dd></td></tr>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
	<cfelseif (isDefined("session.AD") and session.AD eq 1)>
		<cfif isdefined("session.EID") and session.EID is not "">
			<!--- run AD query to get list of all House Administrators and all AP people and all RDO's and all VPs (and Steve A, me, Kenneth, Paul, Glory --->
			<CFLDAP ACTION="query" name="FindAccessDocLinkInvoices" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,dn,Description" SERVER="#ADserver#" PORT="389" FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(objectClass=user)(|(Description=*RDO*)(Description=*Administrator)(Description=*VP*)(Description=* MA)(Description=*AA*)(Description=*Ops Specialist*)(Description=*Operations Specialist*)(Description=*IT Support*)(Description=*IT Applications*)(Description=* AP *))(!(Description=*Mailbox*)))" USERNAME="ldap" PASSWORD="paulLDAP939">
			<cfset doclinkinvoiceslist = #ValueList(FindAccessDocLinkInvoices.physicaldeliveryofficename)#>
			<cfset doclinkinvoiceslist = #listappend(doclinkinvoiceslist,'A8W018047,A8W037939,A8W035439,A8W021114,A8W018551')#>
			<!--- also only display self and leadership evals if the user is found in the BOSS table --->
			<!--- <cfquery name="FindUserInBossTable" datasource="FocalReview">
				select * from Boss_Table2004 where EID = '#session.EID#' and iYear = 2005
			</cfquery>
			<cfif FindUserInBossTable.recordcount is not 0>
				<tr><td colspan="100%" nowrap><dd><li><a href="/intranet/focalreview/createselfevaluation.cfm" target="new">Self Evaluation</a></li></dd></td></tr>
				<cfif session.EID is not "A8W031776">
					<tr><td colspan="100%" nowrap><dd><li><a href="/intranet/focalreview/createleadershipreview.cfm" target="new">Leadership Review</a></li></dd></td></tr>
				</cfif>
			</cfif> --->
			<tr><td colspan="100%" nowrap><dd><li> <a href="/intranet/doclink/doclinksearch.cfm" target="new"> <!--- <a href="javascript:showalert();"> --->Search DocLink</a></li></dd></td></tr>
			<!--- if user is Benny or Alis or me or Storm or Jennifer L., show this link --->
			<cfif Session.username is "jwilliams" or Session.username is "lsimms">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/nationalvendoradmin.cfm" target="new">Doclink National Vendor Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is Alis or me or Storm or Jennifer L., show this link --->
			<cfif Session.username is "jwilliams">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/HouseAPAdmin.cfm" target="new">Doclink House vs. AP Rep Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is AP, show this link --->
			<cfif Session.Grouplist contains "Accounts Payable">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/probleminvoice.cfm" target="new">Submit Problem Invoice Reasons</a></li></dd></td></tr>
			</cfif>
			<!--- if user is a DVP, show this link --->
			<cfif session.GroupList contains "DVP">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/newvendorApproval.cfm" target="new">New Vendor Approval Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is in Purchasing, show this link --->
			<cfif session.GroupList contains "Accounting - Managers" or session.GroupList contains "Purchasing">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/newvendorApproval.cfm?NVAadmin=Yes" target="new">New Vendor Approval Administration</a></li></dd></td></tr>
			</cfif>
			<!--- if user is an administrator, MA, RDO, VP, AA, Ops Specialist, IT Support or in AP, show this link --->
			<cfif ListFindNoCase(doclinkinvoiceslist,session.EID) is not 0>
				<!--- <tr><td colspan="100%" nowrap><dd><li><A href="/intranet/doclink/readscans.cfm" target="new">Key-In Invoices</a></li></dd></td></tr> --->
				<!--- <tr><td colspan="100%" nowrap><dd><li><A href="/intranet/fta/invoiceentry.cfm" target="new">View Monthly Invoices for Excel FTA</a></li></dd></td></tr> --->
			</cfif>
			<!--- if user is a VP, RDO or in Senior Leadership, show link --->
			<!--- <cfif session.grouplist contains "Senior Leadership" or session.ADdescription contains "VP" or session.ADdescription contains "RDO" or session.ADdescription contains "Operations Specialist" or find("IT",session.GroupList) is not "0"> --->
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/fta/default.cfm" target="new">Online FTA</a></li></dd></td></tr>
			<!--- </cfif> --->

			<!--- if user is RDO, RSD, Regional VP, Wally or Tracy or Ray or Davison or me, show link --->
		<cfif findnocase("IT",session.GroupList)><!--- RTS added temp per Laurie 10/28/08  --->
	<!---		<cfif session.grouplist contains "Regional VP" or SEssion.Username is "wlevonowich" or Session.username is "tshilling" or session.username is "rschweer" or session.username is "ncook" or session.ADdescription contains "RDO" or session.grouplist contains "RSD">
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/rateincrease/default.cfm" target="new">2006 New Move-In Rate Increase Worksheet</a></li></dd></td></tr>
			</cfif>--->

			<!--- if user is Regional VP or Steve A or me, show link --->
<!---			<cfif session.username is "kdeborde" > 
				<tr><td COLSPAN=100% NOWRAP><dd><li><A href="/intranet/rateincrease/residentrateincrease.cfm">2005 Private Resident Rate Increases</A></li></dd></td></tr>
			</cfif>--->
		</cfif>
			<!--- if user Admin or above, or ops specialist, or IT, but not Nurse show this link --->
			<cfif isdefined("session.EID") and session.EID is not "">
				<CFLDAP ACTION="query" name="FindAccessCareerLadder" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,dn,Description" SERVER="#ADserver#" PORT="389" FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(objectClass=user)(|(Description=*RDO*)(Description=*Administrator)(Description=*VP*)(Description=*Ops Specialist*)(Description=*IT Support*))(!(Description=*Mailbox*)))" USERNAME="ldap" PASSWORD="paulLDAP939">
				<cfset CareerLadderList = #ValueList(FindAccessCareerLadder.physicaldeliveryofficename)#>
				<cfset CareerLadderList = #listappend(CareerLadderList,'A8W035223')#><!--- add Katrina --->
<!---				<cfif FindNoCase(session.EID,CareerLadderList)>
					<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/careerladder/test.cfm">Career Ladder</a></li></dd></td></tr>
				</cfif>--->
				<!--- ranklam - added on 11/17/2005 --->
<!---			<cfif findnocase("_ALC IT",session.GroupList) > <!--- RTS added temp per Laurie 10/28/08  --->
				<tr><td colspan="100%" nowrap><dd><li><A href="/intranet/RateIncrease/index.cfm">Rate Increase</a></li></dd></td></tr>
			</cfif>--->
				<!--------------------------------------------------------------------------------------------------------------
				*         ranklam - added on 02/08/2007 - canviewomniweb is set by a webservice at the top of this page        *
				--------------------------------------------------------------------------------------------------------------->
				<cfif canViewOmniweb>
					<tr><td colspan="100%" nowrap><dd><li><A href="http://maple.alcco.com/OmniwebAdLogin/OmniwebLogin.aspx">Omniweb Login</a></li></dd></td></tr>
				</cfif>
			</cfif>

			<!--- (Alarm Contact Info) if user is Administrator, Ops Spec, RDO, Property Mgr, Laurie Wiles --->
			<cfif  isdefined("session.EID") and session.EID is not "" and isdefined("session.grouplist") and isdefined("session.ADdescription")
				and (session.ADdescription contains "Administrator" OR session.ADdescription contains "RDO" OR session.ADdescription contains "Operations Spec"
				OR session.ADdescription contains "Property Manager" OR  session.grouplist contains "IT")>
					<tr><td COLSPAN=100% NOWRAP><dd>
					  <li><A href="/intranet/AlarmContacts/AlarmContact.cfm">Residence Alarm Contact Info</A> (due April 15th) </li>
					</dd></td></tr>
			</cfif>
			<cfif invoiceApprovalProcess eq true>
				<tr><td COLSPAN=100% NOWRAP><dd>
				  	<li>	
						<a href="http://maple/DoclinkDotNet/InvoiceMgt.aspx?UserName=#SESSION.UserName#" target="_blank" >
					  		Invoice Approval Process
						</a>
					</li>
				</dd></td></tr>			
			</cfif>
			<cfif rdWdLoggingValid eq true>
				<cfloop query="adQueryResult">
					<cfif adQueryResult.n_AccessTo eq "Report">
						<tr><td COLSPAN=100% NOWRAP><dd>
						  	<li>	
								<a href="http://maple/RdWdLogging/Report?userId=#SESSION.UserName#" target="_blank" >
							  		RD/WD Log in/out Report
								</a>
							</li>
						</dd></td></tr>
					</cfif>
				</cfloop>
			</cfif>
			<cfif SurveyValid eq true>
				<cfloop query="adQueryResult2">
					<cfif adQueryResult2.n_AccessTo eq "Application">
						<tr><td COLSPAN=100% NOWRAP><dd>
			 				<li>	
								<a href="http://maple/survey/Default.aspx?UserName=#SESSION.UserName#" target="_blank" >
				  					Automated Quality and Clinical Services Scorecard 
								</a>
							</li>
						</dd></td></tr>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<tr><td>If you are looking for TIPS please login using your intranet password rather than your network password.</td></tr>
	</cfif>
</cfif>
	<!--- <tr><td><dd><li><a href="http://#server_name#/intranet/AssessmentTool/index.cfm">Assessment Tool</a></li></dd></td></tr> --->
</table>
<cfif (FindNoCase('MSIE 6.0', HTTP_USER_AGENT, 1) eq 0)> <cfloop index="I" from="1" to="30" step="1"><BR></cfloop> </cfif>

<cfinclude template='Footer.cfm'>
</cfoutput>