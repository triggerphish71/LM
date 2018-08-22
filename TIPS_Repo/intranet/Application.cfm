 <!---------------------------------------------------------------------------------------------
| DESCRIPTION:                                                                                 |
|----------------------------------------------------------------------------------------------|
| Application.cfm                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|											                                                   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| MLAW       | 09/12/2005 | Set session.groupid                                                |
| MLAW       | 11/02/2005 | Set HouseApprw datasource                                          |
| mlaw       | 04/27/2006 | Update Medicaid email list                                         |
| mlaw       | 08/29/2006 | Update Medicaid email list                                         |
| ranklam    | 11/02/2006 | added session developer variables.                                 |
| mlaw       | 06/12/2007 | Remove old ALC emails                                              |
| mlaw       | 06/27/2007 | Add Rosemary and Carolyn emails                                    |
| mlaw       | 11/16/2007 | Change ADServer from cottonwood to CORPDC01                        |
| ranklam    | 01/07/2008 | Added *DBServer variables to this file in case we need to move     |
|                         | apps to different db servers again.                                |
| ranklam    | 02/19/2008 | Added jamie and satya to session.developer variables.              |
| sfarmer    | 05/12/2016 | Removed reference to <cfset CRserver = "pine">                     |
| mstriegel  | 11/10/2017 | Add call to create the storedProc object and set it to session scope|
| mstriegel  | 01/12/2018 | Added session object for recurring charge project                  |
! mstriegel  | 02/22/2018 | Changed the session.tempDocPath                                    |
----------------------------------------------------------------------------------------------->
<cfoutput>
<cfif server_name neq 'CF01' and server_name neq 'CF01.ALCCO.COM'>
	<i style='color: Red; font-weight: bold; font-size: small;'>#UCASE(SERVER_NAME)#</I><br/>
</cfif>
</cfoutput>

<!--- ranklam - added these variables to point to db servers --->
<cfset Application.AlcWebDBServer = "bigMuddy">
<!--- <cfset Application.CensusDBServer = "WALNUT"> --->
<cfset Application.DmsDBServer = "bigMuddy">
<cfset Application.FTADBServer = "bigMuddy">
<cfset Application.HOUSES_APPDBServer = "krishna">
<!--- <cfset Application.LeadTrackingDBServer = "WALNUT"> --->  
<!--- 42593 rts 10/22/2009 RateIncreaseDBServer to DBPROD01 from WALNUT --->
<cfset Application.RateIncreaseDBServer = "bigMuddy">
<cfset Application.TIPS4DBServer = "bigMuddy">
<cfset Application.FileServer = "FS01">
<cfset Application.TimeCardDBServer = "vm08db08dev"><!--- 2/27/2013-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->

<cfif server_name is "littlemuddy">
	<Cfset DocLinkDBServer = "krishna">
	<Cfset HRizonDBServer = "ALDER">
	<cfset SolomonDBServer = "krishna">
	<cfset TipsDBServer = "bigMuddy">
	<cfset ADserver = "CORPDC01">
	<cfset SolomonCorpDS = "Solomon-Corp">
	<cfset SolomonHousesDS = "Solomon-Houses">
	<cfset ComshareDS = "ELMALC">
	<cfset DLtifLocation = "FS01">
	<cfset doclinkALCds = "DoclinkALC">
	<cfset FTAds = "FTA">
	<cfset doclinkProd = "doclink2">
	<cfset DoclinkServer = "Shaggy">
	<cfset HouseApprw = "HOUSES_APP">
	<cfset FileServer = "FS01">
	<cfset TimeCard = "TimeCard"> <!--- 2/27/2013-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->
<cfelseif server_name is "CF01.ALCCO.COM">
<!--- 	<Cfset FocalReviewDBServer = "WALNUT"> --->
	<Cfset DocLinkDBServer = "DBPROD02">
	<Cfset HRizonDBServer = "ALDER">
	<cfset SolomonDBServer = "DBPROD02">
	<cfset TipsDBServer = "DBPROD01">
	<cfset ADserver = "CORPDC01">
<!--- 	<cfset CRserver = "pine"> --->
	<cfset SolomonCorpDS = "Solomon-Corp">
	<cfset SolomonHousesDS = "Solomon-Houses">
	<cfset ComshareDS = "ELMALC">
	<cfset DLtifLocation = "FS01">
	<cfset doclinkALCds = "DoclinkALC">
	<cfset FTAds = "FTA">
	<cfset doclinkProd = "doclink2">
	<cfset DoclinkServer = "DBPROD02">
	<cfset HouseApprw = "HOUSES_APP">
	<cfset FileServer = "FS01">
	<cfset TimeCard = "TimeCard"> <!--- 2/27/2013-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->

</cfif>


<cfif 1 eq 0>
<center>
<table style="width:80%;border:2px outset #ebebeb; padding: 0px 0px 0px 0px;">
	<tr>
	<td style="padding: 10px 20px 10px 20px; background-color:#ebebeb;">
	<b style="font:10pt tahoma;color:#006699;">
		<div style="font-size: medium; text-align:center;">
		The IT department will be performing emergency maintenance of our services
		</div>
		<hr style="height:1px; color: #006699;" />
		All Intranet applications, including TIPS, Focal Review, Inquiry Tracking, Doclink, etc.
		will be unavailable starting 4p Central Time. Services are expected to be available
		again tomorrow morning.
		This maintenance does not affect your ability to use email or access network files.
	</b>
	</td>
	</tr>
</table>
</center>
<CFABORT>
</cfif>


<!--- CHECK FOR CONNECTIVITY --->
<cftry>
<cfquery name="qdbtest" datasource="Tips4">
	select getdate()
</cfquery>
<cfcatch type="database">
	<center>
	<table style="width:80%;border:2px outset #ebebeb; padding: 0px 0px 0px 0px;">
		<tr>
		<td style="padding: 10px 20px 10px 20px; background-color:#ebebeb;">
		<b style="font:10pt tahoma;color:#006699;">
			<div style="font-size: medium; text-align:center;">
			We are currently experiencing database connectivity issues.
			</div>
			<hr style="height:1px; color: #006699;" />
			We hope to have the issue resolved as soon as possible.
			Please feel free to retry your request later.
		</b>
		</td>
		</tr>
	</table>
	</center>
	<cfabort>
</cfcatch>
</cftry>
<!--- <NOSCRIPT>
	<center style="color:red;font-size:medium;background:yellow;">
		Active Scripting is currently disabled on your browser.<br/>
		This site requires that Active Scripting is enabled to function properly.<br/>
		Please enable Active Scripting on your browser or call the Help Desk for assistance.<br/>
	</center>
</NOSCRIPT> --->

<cftry>
<cfset dbg='start of cftry'>
<cfif isDefined("remote_addr") and (FindNoCase("10.",remote_addr,1) eq 0 and FindNoCase("172.",remote_addr,1) eq 0)>
	<cfset dbg='external'>
	<!--- Sent Email if the Remote Address is Somthing other than "10." ie. NON-ALC to="jcruz@alcco.com"--->
	<cfmail to="CFDevelopers@alcco.com" from="TIPS4-Violation@alcco.com" SUBJECT="Illegal entry attempted" type="HTML">
		IP:	#Remote_Addr# has tried to enter TIPS4 external to ALC or Without proper login.<br/>
		ReferencePage: #HTTP.Referer#<br/>
		User: #Auth_User#
	</cfmail>
	<CFABORT SHOWERROR="You have attempted to enter to this site without proper permissions.">
<cfelseif FindNoCase("10.",remote_addr,1) GT 0 and 0 eq 1>
	<!--- Otherwise send them to the SharePoint Portal --->
	<cfoutput><cflocation url="http://#SERVER_NAME#/ALC/"></cfoutput>
</cfif>
<cfset dbg='end of external'>

<cfset dbg='start of intranet application'>
<!--- Set Application for Intranet (Pre-SharePoint) --->
<cfapplication name="intranet" clientmanagement="Yes" SESSIONMANAGEMENT="Yes" SETCLIENTCOOKIES="Yes"
	SESSIONtimeout = "#CreateTimeSpan(1,0,0,0)#" applicationtimeout = "#CreateTimeSpan(1,10,0,0)#">
<cfset dbg='appset'>

<!--- Set session variables for developers --->
<cflock scope="session" timeout="10">
	<cfset session.developers = "ALC Application Developers">
	<cfset session.developerEmailList = "CFDevelopers@alcco.com">
</cflock>

<cftry>
	<!--- Query for Acct Period Stamp --->
	<cfquery name="AcctStamp" datasource="SOLOMON-HOUSES" DBtype="ODBC" CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
		select cast(Right(CurrPerNbr,2) + '/01/' + LEFT(CurrPerNbr,4) as datetime) as CurrPerNbr from	ARSETUP (NOLOCK)
	</cfquery>

	<!--- Set Session Variable for AcctStamp from SOLOMON Set	Session Acct Period for Application --->
	<cfset session.AcctStamp = AcctStamp.CurrPerNbr>
	<cfset session.AcctPeriod = YEAR(AcctStamp.CurrPerNbr) & Dateformat(AcctStamp.CurrPerNbr,"mm")>
	<cfset dbg='acctstmp'>
	<cfcatch type="Any">
		<cfoutput>
			<center>
				<B style="color: blue; font-size: 20;">We are currently experiencing server problems.<br/> Please try back later. Thank you, ALC IT Department</B><br/>
				<input class="BlendedButton" type="Button" name="Continue" value="Click Here to Continue" onClick="location.href='../MainMenu.cfm'">
			</center>
		</cfoutput>
		<CFABORT>
	</cfcatch>
</cftry>

<!--- Check for Application Variables if not set then Set Application variables --->
<cfif not isDefined("application.DataSource") or (isDefined("application.DataSource") and application.DataSource eq 'DFWTIPS')>
	<cflock scope="Application" type="Exclusive" timeout="180">
		<cfset application.DataSource="Tips4">
		<cfquery name="qSysDefaults"  datasource="#application.DataSource#">
            select cMaxEndDate, cCurrentAcctPeriod from SysDefaults
        </cfquery>
		<cfset  application.MaxEndDate = CreateODBCDateTime(Trim(qSysDefaults.cMaxEndDate))>
    </cflock>
	<cfset dbg='appsetvar'>
</cfif>

<cfif isDefined("session.codeblock") IS "false">
	<cfquery name="getuserprofile" datasource="DMS">
		select 	groupassignments.groupid, users.employeeid, passexpires
		from 	users,groupassignments
		where	users.employeeid = groupassignments.userid
		<cfif isDefined("session.userid") and session.userid neq ''>
			and users.employeeid='#session.userid#'
		<cfelse>
			and users.employeeid='2000'
		</cfif>
		and 	((users.passexpires > '#dateformat(Now())#') or (users.expires > '#dateformat(Now())#'))
	</cfquery>

	<cfif valuelist(getuserprofile.groupid) is not "">
		<cfquery name="getsecurity" datasource="DMS">
			select	distinct codeblocks.uniqueid, codeblocks.codeblockid
			from 	groupassignments, codeblocks
			where 	groupassignments.uniquecodeblockid = codeblocks.uniqueid
			and 	groupassignments.groupid IN (#valuelist(getuserprofile.groupid)#)
		</cfquery>

		<cflock scope="SESSION" type="EXCLUSIVE" timeout="10">
			<cfset session.codeblock = Valuelist(getsecurity.codeblockid)>
		</cflock>
	</cfif>

	<!---
		kept conditional incase need to disable quickly
		In intranet not logged in and not login page
	--->
	<cfif FindNoCase("intranet",getTemplatePath(),1) GT 0 and (NOT isDefined("session.UserID") and FindNoCase("loginindex",getTemplatePath(),1) eq 0)>

		<cflocation url="http://#SERVER_NAME#/intranet/Loginindex.cfm" addtoken="no">
	</cfif>

	<cfif FindNoCase("login",getTemplatePath(),1) is 0 and not isDefined("session.UserID")>
		<cfif FindNoCase("index",getTemplatePath(),1) is 0 or FindNoCase("index2",getTemplatePath(),1) GT 0>
			<cfif FindNoCase("error",getTemplatePath(),1) is 0>
				<SCRIPT language="JavaScript1.2" type="text/javascript">
					alert("Your Intranet session has timed out. Log in to continue....");
					document.location = '/intranet/loginindex.cfm';
				</SCRIPT>
			</cfif>
		</cfif>
	</cfif>
	<cfset dbg='security'>
<cfelse>
	<!--- Added by Katie on 7/22/04: re-run codeblock part of above query so that people coming in from Network Apps can receive the proper codeblocks --->
	<cfquery name="getuserprofile" datasource="DMS">
		select 	groupassignments.groupid, users.employeeid, passexpires
		from 	users,groupassignments
		where	users.employeeid = groupassignments.userid
		<cfif isDefined("session.userid") and session.userid neq ''>
			and users.employeeid='#session.userid#'
		<cfelse>
			and users.employeeid='2000'
		</cfif>
		and 	((users.passexpires > '#dateformat(Now())#') or (users.expires > '#dateformat(Now())#'))
	</cfquery>

	<cfif valuelist(getuserprofile.groupid) is not "">
		<cfquery name="getsecurity" datasource="DMS">
			select	distinct codeblocks.uniqueid, codeblocks.codeblockid
			from 	groupassignments, codeblocks
			where 	groupassignments.uniquecodeblockid = codeblocks.uniqueid
			and 	groupassignments.groupid IN (#valuelist(getuserprofile.groupid)#)
		</cfquery>

		<cflock scope="SESSION" type="EXCLUSIVE" timeout="10">
			<cfset session.codeblock = Valuelist(getsecurity.codeblockid)>
			<!--- MLAW 09/12/2005 Set session.groupid --->
			<CFSET SESSION.groupid = Valuelist(getuserprofile.groupid)>
		</cflock>
	</cfif>

</cfif>

<cfparam name="datasourcecensus" default="Census">

<!--- comment: ddaybit is a session variable used in the countdown in days untill the user's password expires.--->
<cfparam name="session.ddaybit" default="0">

<!--- comment: for checking to see when the users password expires. actionlogin.cfm does the date check at log in time.--->
<cfif isDefined("session.daycount")>
	<cfif session.daycount GT 0>
		<cfif session.ddaybit is 1>
			<script language="JavaScript1.2" type="text/javascript">
			<!--
				alert("Your password will expire in " + '<cfoutput>#session.daycount#</cfoutput>' + " days. Please click on the Change Password link in the page header and change your password.");
			//-->
			</script>
			<cfset session.ddaybit = 2><!--- comment: we don't need the system reminding the user that their password expires every time they click on a link. This does it onece per login.--->
		</cfif>
	</cfif>

</cfif>

<cfif isDefined("url.dday")>
	<script language="JavaScript1.2" type="text/javascript">
		<!--
		alert("Your password has expired. Please call the helpdesk to get your password reinstated.");
		//-->
	</script>
</cfif>

<!--- For TIPS Security (Primarily TIPS 3) --->
<cfif FindNoCase("TIPS",getTemplatePath(),1) GT 0 and (isDefined("variables.Tenant") and isDefined("url.House"))>
	<cfif isDefined("Cookie.HouseNumber")> <cfset variables.HouseNumber = #Cookie.HouseNumber#> <cfelse> <cfset variables.HouseNumber = 1800> </cfif>
	<!--- if a url is passed, use it instead of cookie --->
	<cfif isDefined("url.House")>
 		<cfset variables.House = #url.House#>
		<cfcookie name="HouseNumber" value="#url.House#" EXPIRES="10">
		<!--- reset cookie --->
	<cfelse>
		<cfset variables.House = #variables.HouseNumber# >
	</cfif>

	<!--- Get house name using the variable house cachedwithin="#CreateTimeSpan(0,0,30,0)#" nHouse,
	HouseName, nUnitsTotal --->
	<cfquery name="GetHouse" datasource="Census">
		select * from Houses where nHouse=#variables.House# ORDER BY HouseName
	</cfquery>

	<!--- Display house addtress --->
	<cfquery name="GetAddress" datasource="Census" CACHEDWITHIN = "#CreateTimeSpan(2,0,0,0)#">
		select * from HouseAddresses where nHouse = #variables.House#
	</cfquery>

	<!--- Process the house X tenant if defined at this point --->
	<cfif isDefined("url.Tenant")> <cfset Variables.Tenant = url.Tenant>
	<cfelseif isDefined("form.Tenant") > <cfset Variables.Tenant = form.Tenant>
	<cfelse> <cfset Variables.Tenant = 0> </cfif>

	<cfquery name="getTenant" datasource="Census">
	select * from Tenants where cTenantID='#variables.Tenant#'
	</cfquery>
	<cfset session.DEBUG = "No">
</cfif>


<!---mstriege1: 02/22/2018  create doc path for .xls files   --->
	<cfset session.tempDocPath="">
	<cfloop list="#getTempDirectory()#" index="itm" delimiters="\">
		<cfif itm IS NOT "Catalina">
			<cfset session.tempDocPath = ListAppend(session.tempDocPath,itm,"\")>
		<cfelse>
			<cfbreak>
		</cfif>
	</cfloop>
	<!--- end mstriegel --->
	<!--- mstriege1: 01/18/2018 create objects --->
	<cfif !isDefined("session.oExport2Solomon")>
		<cfset session.oExport2Solomon = createobject("component","TIPS4.CFC.components.export2Solomon")>	
	</cfif>
	<cfif !isDefined("session.oUtilityServices")>
		<cfset session.oUtilityServices = createObject("component","intranet.TIPS4.CFC.utils.utilityServices")>
	</cfif>
	<cfif !isDefined("session.oSolomonServices")>
		<cfset session.oSolomonServices = createObject("component","intranet.TIPS4.CFC.Components.SolomonServices")>	
	</cfif>

		<cfset session.oRelocateServices = createObject("component","intranet.TIPS4.CFC.Components.Relocate.RelocateServices")>


	<!--- end: mstriegel 01/18/2018 --->
	<!--- mstriegel 01/12/2018 --->
	<cfif !isDefined("session.oChargeServices")>
		<cfset session.oChargeServices = CreateObject("component","intranet.TIPS4.CFC.components.ChargeServices")>
	</cfif>
	<!--- end mstriegel --->

	<!--- mstriegel 08162018 --->
	<cfif !isDefined("session.oApprovalServices")>
		<cfset session.oApprovalServices = CreateObject("component","intranet.TIPS4.CFC.components.admin.ApprovalServices")>
	</cfif>
	<!--- end mstriegel 08162018 --->
	<!---
	<!--- Ganga: 04/30 create objects --->
	<cfset oMoveOutUpdate = createobject('component',"intranet.TIPS4.CFC.components.MoveOut.MoveoutUpdate")>	--->

<CFOUTPUT>
<SCRIPT>
	<!--
	var debug = true;
	function right(e) {
	 <CFIF Isdefined("SESSION.USERID") AND (SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146 OR SESSION.USERID EQ 3271)>	
		//alert(window.event.keyCode);
		if (window.event.keyCode == 192){ adminwin = window.open("http://#SERVER_NAME#/intranet/TIPS4/Developer.cfm",'AdminMenu',"width=840,height=420,toolbar=Yes,resizable=Yes,scrollbars=Yes"); adminwin.moveTo(0,0);}	
		if (window.event.keyCode == 8 && !document.forms[0]){ return false; }
	</CFIF>
		if (window.event.keyCode == 106) { arperson = window.open("http://#SERVER_NAME#/intranet/TIPS4/HouseInfo.cfm",'arperson',"height=420,width=800,toolbar=Yes,resizable=Yes,scrollbars=Yes");} 	  
	    <CFIF Isdefined("SESSION.USERID") AND (SESSION.USERID NEQ 3025 AND SESSION.USERID NEQ 3146)>
		if (navigator.appName == 'Netscape' && (e.which == 3 || e.which == 2)) return false;
		else if (navigator.appName == 'Microsoft Internet Explorer' && (event.button == 2 || event.button == 3)) { alert('Assisted Living Concepts Intranet'); return false; }
	 	</CFIF>
	  return true;
	}
	document.onmousedown=right; document.onkeydown=right;
	function adjustIFrameSize(iframeWindow) {
	  if (iframeWindow.document.height) { var iframeElement = parent.document.getElementById(iframeWindow.name);
	    iframeElement.style.height = iframeWindow.document.height + 'px'; 
		iframeElement.style.width = iframeWindow.document.width + 'px';
	  }
	  else if (document.all) {
	    var iframeElement = parent.document.all[iframeWindow.name];
	    if (iframeWindow.document.compatMode && iframeWindow.document.compatMode != 'BackCompat') 
	    { iframeElement.style.height = iframeWindow.document.documentElement.scrollHeight + 5 + 'px';
	      iframeElement.style.width = iframeWindow.document.documentElement.scrollWidth + 5 + 'px';}
		else { iframeElement.style.height = iframeWindow.document.body.scrollHeight + 5 + 'px';
	      iframeElement.style.width = iframeWindow.document.body.scrollWidth + 5 + 'px';}
	  }
	  /*iframeElement.focus();*/ parent.scrollTo(0,0);
	}	
	//-->
</SCRIPT>	
</CFOUTPUT>

<cfcatch type="Any">
	<cfoutput>
	<center>
		<B style="color: blue; font-size: 20;">
			This request to the server has timed out.<br/> Please, try this process again at a later time.<br/> Thank you,<br/>  ALC IT Department<br/>
		</B><br/>
	</center>
	</cfoutput>

	<cfif remote_addr eq '10.1.0.222' or remote_addr eq '10.1.4.218'>
		<cfmail to="CFDevelopers@alcco.com" from="TIPS4-Application.cfm@alcco.com"  SUBJECT="Developer Application Catch Detected" type="HTML">
			Error in Application.cfm Detected.<br/>Error page Thrown. debug == (<cfif isDefined("dbg")>#dbg#</cfif>)
			<cfif isDefined("remote_addr")>#remote_addr#<br/></cfif>
			<cfif isDefined("session.FULLNAME")>#session.FULLNAME#<br/></cfif>
			<cfif isDefined("PATH_TRANSLATED")>#PATH_TRANSLATED#<br/></cfif>
			<cfif isDefined("Error.Diagnostics")>#Error.Diagnostics#<br/></cfif>
			<cfif isDefined("cfcatch")><cfdump var="#cfcatch#"><br/></cfif>
		</cfmail>
	<cfelse>
		<cfmail to="CFDevelopers@alcco.com" from="TIPS4-Application.cfm@alcco.com"  SUBJECT="Application Catch Detected" type="HTML">
			Error in Application.cfm Detected.<br/>Error page Thrown. debug == (<cfif isDefined("dbg")>#dbg#</cfif>)<br/>
			<cfif isDefined("cfcatch")><cfdump var="#cfcatch#"></cfif>
			<cfif isDefined("remote_addr")>#remote_addr#<br/></cfif>
			<cfif isDefined("auth_user")>Authenticated user = #auth_user#<br/></cfif>
			<cfif isDefined("session.UserName")>username = #session.UserName#<br/></cfif>
			<cfif isDefined("session.FULLNAME")>fullname = #session.FULLNAME#<br/></cfif>
			<cfif isDefined("PATH_TRANSLATED")>#PATH_TRANSLATED#<br/></cfif>
			<cfif isDefined("Error.Diagnostics")>#Error.Diagnostics#<br/></cfif>
			<cfif isDefined("cfcatch.message")>#cfcatch.message#<br/></cfif>
		</cfmail>
	</cfif>

	<CFABORT>
</cfcatch>

</cftry>

<cfscript>
	function IsBlank(string1,string2){ if (TRIM(string1) neq "") value = TRIM(string1); else value = TRIM(string2); return value; }
	function PhoneFormat(string){ if (len(string) eq 10) value =  Left(string,3) &'-'& Mid(string,4,3) &'-'& Right(string,4); return value; }
	function SSNFormat(string){
		if (len(string) eq 9) { ssn =  Left(string,3) &'-'& Mid(string,4,2) &'-'& Right(string,4); return ssn; }
		else return string;
	}
	if (isDefined("session.Application") and session.Application eq 'TIPS4') { medicaidemails="nansay@ALCCO.COM"; }
	//ldp='ldap'; ldpass='paulLDAP939';
</cfscript>

<cfset center='text-align:center;'>
<cfset right='text-align:right;'>
<cfset bold='font-weight:bold;'>
<cfset Gainsboro='background:gainsboro;'>

<cfif remote_addr neq '10.1.4.218' and (FindNoCase('#SERVER_NAME#',HTTP.REFERER,1) eq 0 and (NOT isDefined("session.UserName")))
	and Not isDefined("url.ctch")
	and (	(not isDefined("session.USERID")
	or not isDefined("session.qSelectedHouse.ihouse_id") or not isDefined("session.UserName")
	or session.UserID eq '' or session.UserName eq "")
	)>
	<cfoutput><cflocation url="http://#SERVER_NAME#/intranet/Loginindex.cfm?ctch=1"></cfoutput>
</cfif>

<cfif isDefined("session.application") and session.application eq 'TIPS4'
	and isDefined("session.TIPSMonth")>
	<cfquery name='qTIPSMonth' datasource='#application.datasource#'>
		select dtCurrentTipsMonth from houselog with (NOLOCK) where dtrowdeleted is null and ihouse_id = #session.qSelectedHouse.iHouse_ID#
	</cfquery>
	<cfif session.TIPSMonth neq qTipsMonth.dtCurrentTipsMonth>
		<cfset Session.TIPSMonth = qTipsMonth.dtCurrentTipsMonth>
		<cflocation url="http://#server_name#/intranet/tips4/MainMenu.cfm" addtoken="yes">
	</cfif>
</cfif>
<!--- Ganga - Added CFC session variable --->

	<!---<cfif not isdefined("session.oMoveOutUpdate")> 
		<cfset session.oMoveOutUpdate = createobject('component',"intranet.TIPS4.CFC.components.MoveOut.MoveoutUpdate")>	

	 </cfif> --->
	
<!---
<head>
<meta http-equiv="Expires" content="Mon, December 31, 2001">
<meta http-equiv="PRAGMA" content="NO-CACHE">
<meta http-equiv="Cache-Control" content="NO-CACHE">
</head>
<html>
<body>
<span id='applicationstart' style="position: absolute; top:0; left:0;"><a name="@start"></a></span>
<iframe src="" name="floaterwindow" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" ID="floater" style="position: absolute; top:0; left:0; width:0px; heigth:0px;" border=0>Inside the iFrame on Application.cfm</iframe>--->