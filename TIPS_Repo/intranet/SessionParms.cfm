<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfoutput>
<cfset u='ldap'>
<cfset p='paulLDAP939'>	
<CFSET DATASOURCE = "DMS">

 <CFQUERY NAME='qHouses' DATASOURCE='TIPS4'>
	select ihouse_id, cname from house where dtrowdeleted is null
</CFQUERY>
<!--- <cfdump var="#qHouses#" label="qHouses"> --->
  <cfset this.username = 'sfarmer'>
  <cfset this.userid = 3863>  
<cfset DivisionList='East,West,Central,Midwest'>
<cfset this.userid=""> 
<cfset this.GroupList = ''>
<cfset this.Permissions.VP = ''>
<cfset this.Permissions.Apps = ''>
<cfset this.Permissions.Senior = ''>
<cfset this.Permissions.RDOs = ''> 
<cfset this.HouseAdmin  = ''>
<cfset this.Division= ''>
<cfset this.Permissions.HouseAdmin = ''>
<cfset this.Permissions.PCDirectors = ''>
<cfset this.Division= ''>
<cfset this.HouseAdmin= ''>
<cfset this.houseaccesslist = ''>
<cfset this.eid = ''>

 	<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,company,member,memberof,physicalDeliveryOfficeName,Description,organization,userPrincipalName,eid" 
		SERVER="CORPDC01" 
		PORT="389"  
		FILTER="sAMAccountName=#this.username#"  
		USERNAME="#u#" 
		PASSWORD="#p#">

	<br />UserSearch<cfdump var="#UserSearch#" label="UserSearch"><br />
	
	<CFSET altGroupList= 
	REReplaceNoCase(userSearch.MemberOf, ",DC=alcco,DC=Com,|,DC=alcco,DC=Com", "**", "all")>
	
	<cfoutput><cfdump var="#altGroupList#" label="altGroupList"></cfoutput><br />
	<CFQUERY NAME = "getuserprofile" DATASOURCE = "#datasource#">
		SELECT 	groupassignments.groupid, users.employeeid, passexpires
		FROM 	users, groupassignments
		WHERE 	username = '#this.username#' and groupassignments.userid =  users.employeeid 
 	<!--- 	AND password = '#TRIM(form.password)#'  --->
		AND users.employeeid = groupassignments.userid  AND ((users.passexpires > getdate()) OR (users.expires > getdate()))
	</CFQUERY>
	<cfdump var="#getuserprofile#" label="getuserprofile"><br />
	<cfset this.userid = 	getuserprofile.employeeid>		
			<CFLOOP INDEX=A LIST='#altGroupList#' DELIMITERS="**">
				<CFSCRIPT>
					if (this.GroupList NEQ '') 
						{ this.GroupList = this.GroupList & ',' & getToken( (getToken(A,1,",")),2,"="); }
					else 
					{ this.GroupList = getToken( (getToken(A,1,",")),2,"="); }
				</CFSCRIPT>
			</CFLOOP>	
			<br />this.GroupList
	<cfdump var="#this.GroupList#" label="this.GroupList"><br />
<!---  --->
			<CFSET HouseList=''>
			<CFLOOP INDEX=T LIST="#this.GroupList#">
				<CFIF FindNoCase('Senior', T, 1) GT 0> 
					<CFSET this.Permissions.Senior=1> <B>#T#</B><BR>
				</CFIF>
				<CFIF FindNoCase('Apps', T, 1) GT 0> 
					<CFSET this.Permissions.Apps=1> <B>#T#</B><BR> 
				</CFIF>
				<CFIF FindNoCase('VP', T, 1) GT 0> 
					<CFSET this.Permissions.VP=1> <B>#T#</B><BR> 
				</CFIF>

				<CFIF FindNoCase('RDO', T, 1) GT 0 OR FindNoCase('RDOs', T, 1) GT 0 OR FindNoCase('Ops Specialist', T, 1)>
					<CFSET this.Permissions.RDOs=1> <BR><B>#T#</B><BR>
					<CFLOOP INDEX=D LIST='#DivisionList#'>
						<CFIF FindNoCase(D,T,1) GT 0> <CFSET this.Division=trim(D)></CFIF>
					</CFLOOP>
				</CFIF>

				<CFIF FindNoCase('HouseAdministrator', T, 1) GT 0> 
					<CFSET this.HouseAdmin=1>
					<CFSET this.Permissions.HouseAdmin=1>
					<B>#T#</B><BR> 
				</CFIF>

				<CFIF FindNoCase('P&C Directors', T, 1) GT 0>
					<CFSET this.Permissions.PCDirectors=1><B>#T#</B><BR>
					<CFLOOP INDEX=D LIST='#DivisionList#'>
						<CFIF FindNoCase(D,T,1) GT 0> <CFSET this.Division=trim(D)></CFIF>
					</CFLOOP>
				</CFIF>
			</CFLOOP>

			<CFLOOP INDEX=T LIST="#this.GroupList#">
				<CFIF (FindNoCase(' houses', T, 1) GT 0) AND ((isDefined("this.Permissions.RDOs") AND this.Permissions.RDOs EQ 1) OR (isDefined("this.Permissions.PCDirectors") AND this.Permissions.PCDirectors EQ 1))>
				
					<CFSET tmpHouseList=#this.GroupList#>
					<CFLOOP INDEX=X LIST="#this.GroupList#">
						<CFIF FindNoCase("House",X,1) GT 0>
							#X#<BR>
							<CFLOOP QUERY='qHouses'>
								<CFSET ihouseid = qHouses.ihouse_ID>
								<CFSCRIPT>
									if ( ListFindNoCase(qHouses.cName,"house"," ") EQ 2 ) 
										{ comparevalue = getToken(qHouses.cName, 1, " ");} 
									else 
										{ comparevalue = getToken(qHouses.cName, 2, " "); }
									
									if ( FindNoCase(CompareValue, X, 1) GT 0 ) 
										{ if ( HouseList EQ '') 
											{ HouseList=ihouseid; } 
										else 
											{ HouseList=HouseList & ',' & ihouseid;} }
								</CFSCRIPT>
							</CFLOOP>
						</CFIF>
					</CFLOOP>
				</CFIF>
			</CFLOOP>

			<CFLOOP INDEX=T LIST="#this.GroupList#">
				<CFIF (FindNoCase('house', T, 1) GT 0 OR FindNoCase(' house', T, 1) EQ 0) AND T NEQ 'HouseAdministrator' AND (isDefined("this.Permissions.HouseAdmin") AND this.Permissions.HouseAdmin EQ 1)>
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
		WHERE 	u.username = '#this.username#' and grp.ihouse_id <> ''
 	</CFQUERY>

 
				<cfloop query="getuserhouseprofile">
					<CFSCRIPT>
						if ( HouseList EQ '') {HouseList=ihouse_id; } 
							else { HouseList=HouseList & ',' & ihouse_id;}
					</CFSCRIPT>
				</cfloop>
			<CFIF IsDefined("HouseList")> <CFSET this.HouseAccessList=HouseList> </CFIF>
			this.HouseAccessList: ( #isBlank(this.HouseAccessList,'no houses')# )<BR>
			this.GroupList: { #isBlank(this.GroupList,'No grouplist')# } <BR>

	 


<!---  --->
	<cfquery name="useraccount"  datasource="DOCLINKALC">
			SELECT *
			FROM
				dbprod02.DOCLINKALC.dbo.vw_UserAccountDetails
			WHERE
				cUserName like '%#this.username#%' 
	</cfquery>
 	<cfdump var="#useraccount#" label="DOCLINKALC_useraccount"><br />
	
	<cfquery name="qryFTA" datasource="tips4">
		select * from maple.FTA.dbo.UserAccountAccess where cUserName = '#this.username#'
	</cfquery>
	<cfdump var="#qryFTA#" label="qryFTA"><br />
	

	<CFLDAP ACTION="query" NAME="FindSubAccountFTAC" START="DC=alcco,DC=com" 
		SCOPE="subtree" 
		ATTRIBUTES="sAMAccountName,Title,DisplayName,physicalDeliveryOfficeName,company,userPrincipalName" 
		SERVER="#ADserver#" 
		PORT="389"  
		FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com) (sAMAccountName=#this.username#))" 
		USERNAME="ldap" 
		PASSWORD="paulLDAP939">	
	<cfdump var="#FindSubAccountFTAC#" label="FindSubAccountFTAC">	
 
	<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" 
	ATTRIBUTES="sAMAccountName,Title,DisplayName,physicalDeliveryOfficeName,company,userPrincipalName" 
	SERVER="#ADserver#" 
	PORT="389"  
	FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(userPrincipalName=#this.username#@alcco.com))" 
	USERNAME="ldap" 
	PASSWORD="paulLDAP939"> 
	<cfdump var="#FindSubAccount#" label="FindSubAccount">	<br />
		
	<cfif UserSearch.memberof contains ("_ALC Corporate Office")>
		<cfset level = "Corporate">
	<cfelseif UserSearch.memberof contains ("DVP") 
		or UserSearch.memberof contains ("DDHR") 
		or UserSearch.memberof contains ("RDSM") 
		or UserSearch.memberof contains ("Div Vice President") 
		or UserSearch.memberof contains ("Human Resources")>
		<cfset level="Division">
	<cfelseif UserSearch.memberof contains ("RDO") 
			or UserSearch.memberof contains ("RDSM") 
			or UserSearch.memberof contains ("RDQCS") 
			or UserSearch.memberof contains ("OPS")>
		<cfset level="Region">
	<cfelse> 
		<cfset level="House">
	</cfif>
		<cfquery name="getuserprofile" datasource="DMS">
		select 	groupassignments.groupid, users.employeeid, passexpires, groups.groupname
		from 	users,groupassignments, groups
		where	users.employeeid = groupassignments.userid 
		and groups.groupid = groupassignments.groupid
<!--- 		<cfif isDefined("this.userid") and this.userid neq ''> --->
			and users.employeeid ='#this.userid#'
<!--- 		<cfelse>
			and users.employeeid ='2000'
		</cfif>
		and 	((users.passexpires > '#dateformat(Now())#') or (users.expires > '#dateformat(Now())#')) --->
	</cfquery>
	<CFQUERY NAME="getsecurity" DATASOURCE="tips4">
		SELECT 	distinct codeblocks.uniqueid,codeblocks.codeblockid
		FROM 	dms.dbo.groupassignments,dms.dbo.codeblocks
		WHERE 	groupassignments.uniquecodeblockid = codeblocks.uniqueid
		AND 	groupassignments.groupid IN  (#isBlank(valuelist(getuserprofile.groupid),0)#) 
	</CFQUERY> 

	<CFLOCK SCOPE="SESSION" TYPE="EXCLUSIVE" TIMEOUT="10"> 
		<CFSET this.codeblock = Valuelist(getsecurity.codeblockid)> 
	</CFLOCK>
	
	<CFLOCK SCOPE="SESSION" TYPE="EXCLUSIVE" TIMEOUT="10"> 
		<CFSET this.GroupList = valuelist(getuserprofile.groupid)> 
	</CFLOCK>
 <cfinvoke webservice="http://maple.alcco.com/OmniwebServices/ActiveDirectoryRoleService.asmx?WSDL" method="userHasRights" returnvariable="canViewOmniweb">
	<cfinvokeargument name="iUserName" value="#this.username#">
	<cfset reason="Webservice">
</cfinvoke>
<!--- Webservice: #Webservice#<br /> --->
	getsecurity: <cfdump  var="#getsecurity#" label="getsecurity"><br />
	getuserprofile:	<cfdump var="#getuserprofile#" label="getuserprofile"><br />
	
session parms ==>	<cfdump var="#session#" label="session"> <br />	
	<cfdump var="#level#" label="level"><br />
	

username #this.username# <br />
userid  #this.userid#<br /> 
GroupList #this.GroupList# <br />
VP #this.Permissions.VP# <br />
Apps #this.Permissions.Apps#<br />
Senior #this.Permissions.Senior#<br />
RDOs  #this.Permissions.RDOs#<br /> 
HouseAdmin  #this.HouseAdmin#<br />
Division #this.Division#<br />
HouseAdmin #this.Permissions.HouseAdmin#<br />
PCDirectors  #this.Permissions.PCDirectors #<br />
Division  #this.Division#<br />
houseaccesslist #this.houseaccesslist#<br />
eid  #this.eid# <br /> 
<cfif listfindNocase(session.codeblock,21) gte 1>session.codeblock,21 gte 1</cfif><br />
<cfif listfindNocase(session.codeblock,23) eq 0> session.codeblock,23 eq 0</cfif><br />
>
</cfoutput>
<body>
</body>
</html>
