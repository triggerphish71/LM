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

<cfif now() gt '2014-12-31 23:59:00'>
	<cfif username is "BEARDSLEY HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "CALDWELL HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "CHESTNUT HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "HOMESTEAD HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "JEWEL HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "MADISON HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "MAHONEY HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "MAURICE HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "REED HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "RIVER BEND HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "RUTHERFORD HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "SAUNDERS HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "SENECA HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "ALPINE HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "ANGELINA HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "ARBOR HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "HARRISON HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "LAKELAND HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "NECHES HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "OAKWOOD HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
<!--- These houses added 2015-07-22 as they will now use individual (personal) log-ins --->
	<cfif username is "Baker Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Baker House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Granville Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Granville House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Lindsay Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Lindsay House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Somers Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Mey House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Summit Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Post House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Woodbourne Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Statesman Woods">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "STATESMAN WOODS">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Chapin House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Goldfinch House">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
<!--- added 07-23-2015 --->
	<cfif username is "BROOK GARDENS">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Brook Gardens Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "LAKE VIEW ESTATES">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Lake View Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "CEDAR GARDENS">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "McKinney Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "TAMARACK PLACE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Menomonee Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "North Woods Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "NORTH WOODS">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Oak Creek Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "CREST HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	
	<cfif username is "Oak Gardens Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "OAK GARDENS">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	
	<cfif username is "River Woods Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "RIVER WOOD ESTATES">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Terrace Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "TERRACE ESTATES">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "Willowpark Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "WILLOWPARK RESIDENCE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
	<cfif username is "Wissota Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "WISSOTA SPRINGS">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "COUNTRY VILLA">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "CRYSTAL HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>	
	<cfif username is "KARR HOUSE">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>
	<cfif username is "Riverside Place">
		<CFLOCATION URL='/intranet/Loginindex.cfm'>
	</cfif>		
</cfif>
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
		<CFLOCATION URL='/intranet/Loginindex.cfm?Error=1&ad=2'>
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