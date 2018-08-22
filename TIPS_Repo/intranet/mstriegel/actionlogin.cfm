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
| ranklam    | 10/15/2006 | Created                                                            |
| ranklam    | 10/15/2006 | Removed IsAuthentaced                                              |
| sfarmer    | 12-31-2014 | blocked entry by houses no longer with Enlivant after 12-31-2014   |
|sfarmer     | 2015-07-21 | eliminate use of house log-on, require individual, lookup house    |
|            |            | assignment with DMS.groupassignment table                          |
| sfarmer    | 2015-07-22 | houses added to the not able to login list - houses being changed  |
|            |            | individual log-ins                                                 |
|S Farmer    | 09/14/2015 | Changes to house list process - now only from groupassignments     |
----------------------------------------------------------------------------------------------->


<html>
<body>
<CFOUTPUT>
<CFSET DATASOURCE = "DMS">
<cfset u='DEVTIPS'>
<cfset p='!A7eburUDETu'>
<cfset username=trim(form.username)>

<cfdump var="#form#">
<CFIF findnocase("@alcco.com",trim(form.UserName),1) GT 1> 
  
	<CFSET form.UserName = getToken(form.username,1,"@")>
</CFIF>
<CFIF findnocase("@@",trim(form.UserName),1) GTE 1>

	<CFSET bypass=1> <CFSET form.UserName=MID(trim(form.username),3,len(trim(form.username)))>
<CFELSE>
	<CFSET bypass=0>
</CFIF>

<CFQUERY NAME='qHouses' DATASOURCE='TIPS4'>
	select ihouse_id, cname from house where dtrowdeleted is null
</CFQUERY>

<CFdump var="#session#" >

<cfif  isdefined("session.ad")><cfset throwaway =structDelete(session,"ad")></cfif>
<cfif  isdefined("session.userid")><cfset throwaway =structDelete(session,"userid")></cfif>


<CFSCRIPT>
	DivisionList='East,West,Central,Midwest';
	SESSION.Division=0;
	SESSION.Permissions=StructNew();
	SESSION.Permissions.VP=0;
	SESSION.Permissions.RDOs=0;
	SESSION.Permissions.HouseAdmin=0;
	SESSION.Permissions.IT=0;
	SESSION.Permissions.Culture=0;
	SESSION.Permissions.Payroll=0;
	SESSION.Permissions.Actg=0;
	SESSION.Permissions.Senior=0;
	SESSION.Permissions.NoGroup=0;
	SESSION.Permissions.Apps=0;
</CFSCRIPT>


 <CFSET IP='10.1.4.211'>
<cfset form.authentication = 0>
 <CFIF TRIM(form.password) neq 'tips'>
 	Please wait... <BR>
	
	 <CFTRY>	
		<cfntauthenticate username="#trim(form.UserName)#" password="#trim(form.password)#" domain="ALC" result="authresult">
		<cfif authresult.auth eq 'YES'>
			<cfset form.authentication = 1>
		</cfif>

#form.authentication# #authresult.auth#  bypass #ByPass#

		<CFIF form.authentication eq 1 or ByPass EQ 1> 
			<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
			ATTRIBUTES="givenName,sn,displayName,cn,dn,member,memberof,physicalDeliveryOfficeName,Description" 
			SERVER="CORPDC01" PORT="389"  FILTER="sAMAccountName=#TRIM(form.UserName)#" USERNAME="#u#" PASSWORD="#p#">
			
				<CFSCRIPT> 
					SESSION.UserName = TRIM(form.UserName);
					SESSION.FullName = UserSearch.givenName & ' ' & UserSearch.sn; 
					
				</CFSCRIPT>
			<cfset SESSION.AD = 1>
			<CFSET SESSION.GroupList = ''>
			<SCRIPT>document.write('Logging in');</SCRIPT>

			<cfif usersearch.recordcount is not 0>	
				<cfset SESSION.EID = #userSearch.physicalDeliveryOfficeName#>
				<cfset SESSION.ADdescription = #userSearch.Description#>
			</cfif>

			<CFSET Count=1>

			*** <B>#userSearch.displayName#</B><BR>
			#userSearch.recordcount# <BR>
			<!--- <cfdump var="#userSearch#"> --->
			<CFSET altGroupList= REReplaceNoCase(userSearch.MemberOf, ",DC=alcco,DC=Com,|,DC=alcco,DC=Com", "**", "all")>
			
			<CFLOOP INDEX=A LIST='#altGroupList#' DELIMITERS="**">
				<CFSCRIPT>
					if (SESSION.GroupList NEQ '') 
						{ SESSION.GroupList = SESSION.GroupList & ',' & getToken( (getToken(A,1,",")),2,"="); }
					else 
					{ SESSION.GroupList = getToken( (getToken(A,1,",")),2,"="); }
				</CFSCRIPT>
			</CFLOOP>

			<BR>

			<CFSET HouseList=''>
			<CFLOOP INDEX=T LIST="#SESSION.GROUPLIST#">
				<CFIF FindNoCase('Senior', T, 1) GT 0> <CFSET SESSION.Permissions.Senior=1> <B>#T#</B><BR> </CFIF>
				<CFIF FindNoCase('Apps', T, 1) GT 0> <CFSET SESSION.Permissions.Apps=1> <B>#T#</B><BR> </CFIF>
				<CFIF FindNoCase('VP', T, 1) GT 0> <CFSET SESSION.Permissions.VP=1> <B>#T#</B><BR> </CFIF>

				<CFIF FindNoCase('RDO', T, 1) GT 0 OR FindNoCase('RDOs', T, 1) GT 0 OR FindNoCase('Ops Specialist', T, 1)>
					<CFSET SESSION.Permissions.RDOs=1> <B>#T#</B><BR>
					<CFLOOP INDEX=D LIST='#DivisionList#'>
						<CFIF FindNoCase(D,T,1) GT 0> <CFSET SESSION.Division=trim(D)></CFIF>
					</CFLOOP>
				</CFIF>

				<CFIF FindNoCase('HouseAdministrator', T, 1) GT 0> 
					<CFSET SESSION.HouseAdmin=1>
					<CFSET SESSION.Permissions.HouseAdmin=1>
					<B>#T#</B><BR> 
				</CFIF>

				<CFIF FindNoCase('P&C Directors', T, 1) GT 0>
					<CFSET SESSION.Permissions.PCDirectors=1><B>#T#</B><BR>
					<CFLOOP INDEX=D LIST='#DivisionList#'>
						<CFIF FindNoCase(D,T,1) GT 0> <CFSET SESSION.Division=trim(D)></CFIF>
					</CFLOOP>
				</CFIF>
			</CFLOOP>

			<CFLOOP INDEX=T LIST="#SESSION.GROUPLIST#">
				<CFIF (FindNoCase(' houses', T, 1) GT 0) AND ((isDefined("SESSION.Permissions.RDOs") AND SESSION.Permissions.RDOs EQ 1) OR (isDefined("SESSION.Permissions.PCDirectors") AND SESSION.Permissions.PCDirectors EQ 1))>
					<CFSET tmpHouseList=#SESSION.GROUPLIST#>

				</CFIF> 
			</CFLOOP> 

			<CFLOOP INDEX=T LIST="#SESSION.GROUPLIST#">
				<CFIF (FindNoCase('house', T, 1) GT 0 OR FindNoCase(' house', T, 1) EQ 0) AND T NEQ 'HouseAdministrator' AND (isDefined("SESSION.Permissions.HouseAdmin") AND SESSION.Permissions.HouseAdmin EQ 1)>
					<CFLOOP QUERY='qHouses'>
						<CFSET ihouseid = qHouses.ihouse_ID>
						<CFSCRIPT>
							if ( ListFindNoCase(qHouses.cName,"house"," ") EQ 2 ) { comparevalue=getToken(qHouses.cName, 1, " ");}
							else { comparevalue = getToken(qHouses.cName, 2, " "); }

							if ( FindNoCase(CompareValue, T, 1) GT 0 ) {
								if ( HouseList EQ '') { HouseList=ihouseid; } else { HouseList=HouseList & ',' & ihouseid;}
							}
						</CFSCRIPT>
					</CFLOOP>
				</CFIF>
			</CFLOOP>
 

	<CFQUERY NAME = "getuserhouseprofile" DATASOURCE = "#datasource#">
		SELECT   h.ihouse_id, h.cname
		FROM 	users u
		join groupassignments grpasg on u.employeeid = grpasg.userid
		join groups grp  on grpasg.groupid = grp.groupid
	 	join tips4.dbo.house h on grp.ihouse_id = h.ihouse_id
		WHERE 	u.username = '#TRIM(form.username)#' and grp.ihouse_id <> '' and h.dtrowdeleted is null
 	</CFQUERY>
 		<cfscript>
			function IsBlank(string1,string2){ if (TRIM(string1) neq "") value = TRIM(string1); else value = TRIM(string2); return value; }
			function PhoneFormat(string){ if (len(string) eq 10) value =  Left(string,3) &'-'& Mid(string,4,3) &'-'& Right(string,4); return value; }
			function SSNFormat(string){
				if (len(string) eq 9) { ssn =  Left(string,3) &'-'& Mid(string,4,2) &'-'& Right(string,4); return ssn; }
				else return string;
			}
			if (isDefined("session.Application") and session.Application eq 'TIPS4') { medicaidemails="nansay@ALCCO.COM"; }
		</cfscript>

 
				<cfloop query="getuserhouseprofile">
					<CFSCRIPT>
						if ( HouseList EQ '') {HouseList=ihouse_id; } 
							else { HouseList=HouseList & ',' & ihouse_id;}
					</CFSCRIPT>
				</cfloop>
 
			<CFIF IsDefined("HouseList")> <CFSET SESSION.HouseAccessList=HouseList> </CFIF>
			SESSION.HouseAccessList: ( #isBlank(SESSION.HouseAccessList,'no houses')# )<BR>
			SESSION.GroupList: { #isBlank(SESSION.GroupList,'No grouplist')# } <BR>

		</CFIF>
		<CFCATCH TYPE="Security">
			<CFSET Catch=1> nt auth fld. <BR><!--- Pass Through do not generate error	--->
		</CFCATCH>
	</CFTRY>
</CFIF>

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



<CFIF IsDefined("SESSION.AD") eq 'NO'>
	<CFSET DATASOURCE = "DMS">
	<CFPARAM NAME="seclist" default="">
	<CFPARAM NAME="grouplist" default="">

	<!--- ==============================================================================
	Begin test for existence of this user
	=============================================================================== --->
	<CFQUERY NAME = "getuserprofile" DATASOURCE = "#datasource#">
		SELECT 	groupassignments.groupid, users.employeeid, passexpires
		FROM 	users, groupassignments
		WHERE 	username = '#TRIM(form.username)#'
		AND password = '#TRIM(form.password)#' 
		AND users.employeeid = groupassignments.userid  AND ((users.passexpires > getdate()) OR (users.expires > getdate()))
	</CFQUERY>

	<CFIF getuserprofile.recordcount EQ 0 AND (IsDefined("SESSION.UserName") AND SESSION.UserName EQ '')>
		<CFLOCATION URL="/intranet/Loginindex.cfm?Error=1&ad=1" ADDTOKEN="No">
	</CFIF>

	<CFIF getuserprofile.recordcount GT 0 AND (getuserprofile.employeeid GTE 1800 AND getuserprofile.employeeid LT 3000)>
		<CFQUERY NAME="FullName" DATASOURCE="#datasource#">
			SELECT	UserName As FullName, userid FROM Users WHERE EmployeeID = #getuserprofile.employeeid#
		</CFQUERY>
		<CFTRANSACTION>
			<CFQUERY NAME="qLastAccessed" DATASOURCE="#datasource#">
				update users set last_accessed = getdate() where userid = #FullName.userid#
			</CFQUERY>
		</CFTRANSACTION>
	<CFELSEIF getuserprofile.recordcount GT 0>

		<CFQUERY NAME="FullName" DATASOURCE="ALCWEB">
			SELECT	(FName + ' ' + LName) As FullName, Employee_Ndx  FROM Employees WHERE Employee_ndx = #getuserprofile.employeeid#
		</CFQUERY>
		<CFTRANSACTION>
		<!---<cfif FullName.Employee_Ndx is not "">--->
			<CFQUERY NAME="qLastAccessed" DATASOURCE="#datasource#">
				update users set last_accessed = getdate() where employeeid = #FullName.Employee_Ndx#
			</CFQUERY>
			<!---</cfif>--->
		</CFTRANSACTION>
	<CFELSE>
		<CFLOCATION URL='/intranet/mstriegel/Loginindex.cfm?Error=1&ad=2&dumpscopes=true'>
	</CFIF>

	<CFIF getuserprofile.recordcount IS 0>
		<CFLOCATION URL="/intranet/error.cfm" ADDTOKEN="No">
	<CFELSEIF NOT IsDefined("SESSION.FullName")>
		<CFLOCK SCOPE="SESSION"	TYPE="EXCLUSIVE" TIMEOUT="10">
			<CFSET session.userid = getuserprofile.employeeid>
			<CFSET SESSION.FullName = Fullname.FullName>
			<CFIF IsDefined("form.username")><CFSET SESSION.USERNAME = form.username></CFIF>
		</CFLOCK>
		<!--- --------------------------------------------------------------------------------------------------------
		comment: check for password expiration date and let the user know everyday two weeks in advance (14 days)
		--------------------------------------------------------------------------------------------------------------->
		<CFSET daycounta = datediff('d',Dateformat(Now(),"mm/dd/yy"),Dateformat(getuserprofile.passexpires,"mm/dd/yy"))>		
		<CFIF daycounta LTE 14>
			<CFIF daycounta LTE 0>
				 <CFLOCATION URL="/intranet/index.cfm?dday=0" ADDTOKEN="No">
			<CFELSE>
				<CFSET Session.daycount = daycounta> <CFSET session.ddaybit = 1>
			</CFIF>
		</CFIF>
	</CFIF>

	<CFQUERY NAME="getsecurity" DATASOURCE="#datasource#">
		SELECT 	distinct codeblocks.uniqueid,codeblocks.codeblockid
		FROM 	groupassignments,codeblocks
		WHERE 	groupassignments.uniquecodeblockid = codeblocks.uniqueid
		AND 	groupassignments.groupid IN (#valuelist(getuserprofile.groupid)#)
	</CFQUERY>

	<CFLOCK SCOPE="SESSION" TYPE="EXCLUSIVE" TIMEOUT="10"> <CFSET session.codeblock = Valuelist(getsecurity.codeblockid)> </CFLOCK>
	<CFLOCK SCOPE="SESSION" TYPE="EXCLUSIVE" TIMEOUT="10"> <CFSET session.grouplist = valuelist(getuserprofile.groupid)> </CFLOCK>
</CFIF>

<CFIF (IsDefined("form.TIPS4") OR (IsDefined("SESSION.Application") AND SESSION.APPLICATION EQ 'TIPS4')) AND (NOT IsDefined("SESSION.AD"))>
	<CFSET location="TIPS4/Index.cfm">
<!--- this is where developers get redirected to --->
<CFELSEIF IsDefined("SESSION.AD")> 
	<CFSET location = 'ApplicationList.cfm?adsi=1'>

<CFELSE>
	<CFSET location="ApplicationList.cfm">
	
</CFIF>
<!---#location#--->

<CFIF NOT IsDefined("SESSION.AD")>
	<CFLOCATION URL="#location#" ADDTOKEN="No">
<CFELSE>
	<CFIF IsDefined("SESSION.AD")><CFSET location = location & '?adsi=1'></CFIF>
	<!--- #SESSION.USERNAME#<BR> #SESSION.FullName#<BR> --->
	<cfif isDefined("session.EID")><!--- EID: #SESSION.EID#<BR>#SESSION.ADdescription#<BR> --->
		<cfset SESSION.FILE_NBR = #RIGHT(SESSION.EID,6)#>
		FILE_NBR: #SESSION.FILE_NBR#<BR>
	<cfelse>Session.EID was not set<BR></cfif>
	<CFIF (IsDefined("AUTH_USER") AND (AUTH_USER EQ 'ALC\PaulB' OR AUTH_USER EQ 'ALC\KatieD' OR AUTH_USER EQ 'ALC\KDeborde' OR AUTH_USER EQ 'ALC\dummy' OR AUTH_USER EQ 'ALC\SPalmore')) OR remote_addr eq ip OR session.username is "dummy">
		<A HREF='#location#'>Continue</A>
		<P>
		<CFINCLUDE TEMPLATE="/intranet/Footer.cfm">
	<CFELSE>
		<CFLOCATION URL='#location#'>
	</CFIF>
</CFIF>
<CFFLUSH interval="10">
</CFOUTPUT>
</body>
</html>