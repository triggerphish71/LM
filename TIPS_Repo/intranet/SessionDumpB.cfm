<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
	<cfoutput>
  <br />HouseAccessListP: <cfdump var="#SESSION.HouseAccessList#" label="SESSION.HouseAccessListP">  	<cfset u='ldap'>
	<cfset p='paulLDAP939'>	
<br />
 
       <CFQUERY NAME="qUser_id"  DATASOURCE="DMS">
          SELECT * from Users where username ='tdufour'
       </CFQUERY>
	 <br /><cfdump var="#qUser_id#"   label="qUser_id"><br />
	
	 
<CFQUERY NAME="qUserHouses"  DATASOURCE="#APPLICATION.datasource#">
    SELECT HouseLog.bIsPDClosed, House.iHouse_ID, House.cName AS HouseName ,House.cNumber ,House.cCity ,House.cStateCode,iPDUser_ID
				,OpsArea.cName AS OpsAreaName ,Region.cName AS RegionName ,HouseLog.dtCurrentTipsMonth
    FROM House
	INNER JOIN  OpsArea	ON  OpsArea.iOpsArea_ID = House.iOpsArea_ID and opsarea.dtrowdeleted is null
	INNER JOIN  Region	ON  Region.iRegion_ID = OpsArea.iRegion_ID and region.dtrowdeleted is null
	JOIN HouseLog ON House.iHouse_ID = HouseLog.iHouse_ID
 
		WHERE House.dtRowDeleted IS NULL
		<!---   AND (#SESSION.AccessRights# = #qUser_id.employeeid#) --->	 
 </CFQUERY>
	 <br /><cfdump var="#qUserHouses#"   label="qUserHouses"><br />	 
	<CFLDAP ACTION="query" NAME="GroupSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,cn,dn,company,member,memberof,physicalDeliveryOfficeName,Description,organization,userPrincipalName" 
		SERVER="CORPDC01" 
		PORT="389"  
		FILTER="sAMAccountName=tdufour" 
		USERNAME="#u#" 
		PASSWORD="#p#">
	<cfdump var="#GroupSearch#" label="GroupSearch">
	
	<cfquery name="useraccount"  datasource="DOCLINKALC">
			SELECT *
			<!--- * --	cUserName, cRole --->
			FROM
				krishna.DOCLINKALC.dbo.vw_UserAccountDetails
			WHERE
				cUserName like '%tdufour%' 
			<!--- 	AND 				(cRole IN ('RD','RDO','OPS','RDSM')); --->	
	</cfquery>
 	<cfdump var="#useraccount#" label="DOCLINKALC_useraccount">
	
	<cfquery name="qryFTA" datasource="FTA">
		select * from maple.FTA.dbo.UserAccountAccess where cUserName = 'tdufour'
	</cfquery>
	<cfdump var="#qryFTA#" label="qryFTA">
		
	<CFLDAP ACTION="query" NAME="UserSearch" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="givenName,sn,displayName,company,cn,dn,member,memberof,physicalDeliveryOfficeName,Description" 
		SERVER="CORPDC01" 
		PORT="389"  
		FILTER="sAMAccountName=tdufour" 
		USERNAME="#u#" 
		PASSWORD="#p#">
	<cfdump var="#UserSearch#" label="UserSearch">

	<cfldap action="query" name="getUserADInfoFTA" start="DC=alcco,DC=com" scope="subtree" 
		attributes="sAMAccountName,Title,DisplayName" 
		filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=tdufour))"
		server="#ADserver#" 
		port="389" 
		username="ldap"
		password="paulLDAP939">
	<cfdump var="#getUserADInfoFTA#" label="getUserADInfoFTA">				
				
	<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" 
		ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" 
		SERVER="CORPDC01" 
		PORT="389"  
		FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=tdufour))" 
		USERNAME="ldap" 
		PASSWORD="paulLDAP939">
	<cfdump var="#FindSubAccount#" label="FindSubAccount">
	
	<CFLDAP ACTION="query" NAME="FindSubAccountB" START="DC=alcco,DC=com" 
		SCOPE="subtree" 
		ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" 
		SERVER="#ADserver#" 
		PORT="389"  
		FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) (userPrincipalName=tdufour@alcco.com))" 
		USERNAME="ldap" 
		PASSWORD="paulLDAP939">	
	<cfdump var="#FindSubAccountB#" label="FindSubAccountB">
	
	<cfif GroupSearch.memberof contains ("_ALC Corporate Office")>
		<cfset level = "Corporate">
	<cfelseif GroupSearch.memberof contains ("DVP") 
		or GroupSearch.memberof contains ("DDHR") 
		or GroupSearch.memberof contains ("RDSM") 
		or GroupSearch.memberof contains ("Div Vice President") 
		or GroupSearch.memberof contains ("Human Resources")>
		<cfset level="Division">
	<cfelseif GroupSearch.memberof contains ("RDO") 
			or GroupSearch.memberof contains ("RDSM") 
			or GroupSearch.memberof contains ("RDQCS") 
			or GroupSearch.memberof contains ("OPS")>
		<cfset level="Region">
	<cfelse> 
		<cfset level="House">
	</cfif>
	<cfdump var="#level#" label="level">
<!--- 		<CFSET altGroupList= REReplaceNoCase(userSearch.MemberOf, ",DC=alcco,DC=Com,|,DC=alcco,DC=Com", "**", "all")>
			<cfdump var="#altGroupList#" label="altGroupList">

				<CFSET HouseList=''>
			<CFLOOP INDEX=T LIST="#SESSION.GROUPLIST#">
				<CFIF FindNoCase('Senior', T, 1) GT 0> 
				<!--- <CFSET SESSION.Permissions.Senior=1> ---> <B>SESSION.Permissions.Senior: #T#</B><BR> 
				</CFIF>
				<CFIF FindNoCase('Apps', T, 1) GT 0> <!--- <CFSET SESSION.Permissions.Apps=1> ---> <B>SESSION.Permissions.Apps: #T#</B><BR> </CFIF>
				<CFIF FindNoCase('VP', T, 1) GT 0> <!--- <CFSET SESSION.Permissions.VP=1>  ---><B>SESSION.Permissions.VP: #T#</B><BR> </CFIF>

				<CFIF FindNoCase('RDO', T, 1) GT 0 OR FindNoCase('RDOs', T, 1) GT 0 OR FindNoCase('Ops Specialist', T, 1)>
					<!--- <CFSET SESSION.Permissions.RDOs=1>  ---><B>SESSION.Permissions.RDOs: #T#</B><BR>
					<CFLOOP INDEX=D LIST='#DivisionList#'>
						<CFIF FindNoCase(D,T,1) GT 0> 
						<!--- <CFSET SESSION.Division=trim(D)> --->RDO, RDOs Ops Specialist<B>SESSION.Division: #T#</B><BR>
						</CFIF>
					</CFLOOP>
				</CFIF>

				<CFIF FindNoCase('HouseAdministrator', T, 1) GT 0> 
					<!--- <CFSET SESSION.HouseAdmin=1>
					<CFSET SESSION.Permissions.HouseAdmin=1> --->
					<B>SESSION.HouseAdmin: #T#</B><BR> 
				</CFIF>

				<CFIF FindNoCase('P&C Directors', T, 1) GT 0>
					<!--- <CFSET SESSION.Permissions.PCDirectors=1> ---><B>#T#</B><BR>
					<CFLOOP INDEX=D LIST='#DivisionList#'>
						<CFIF FindNoCase(D,T,1) GT 0> <!--- <CFSET SESSION.Division=trim(D)> ---><B>#T#</B><BR></CFIF>
					</CFLOOP>
				</CFIF>
			</CFLOOP>
			<br />session<cfdump var="#session#" label="session">
			<br />HouseListA<cfdump var="#HouseList#" label="HouseListA">
			<CFLOOP INDEX=T LIST="#SESSION.GROUPLIST#">
				<CFIF (FindNoCase(' houses', T, 1) GT 0) AND ((isDefined("SESSION.Permissions.RDOs") AND SESSION.Permissions.RDOs EQ 1) OR (isDefined("SESSION.Permissions.PCDirectors") AND SESSION.Permissions.PCDirectors EQ 1))>
					<CFSET tmpHouseList=#SESSION.GROUPLIST#>
					<CFLOOP INDEX=X LIST="#SESSION.GROUPLIST#">
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
			<br />HouseListB<cfdump var="#HouseList#" label="HouseList">
			
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
				<CFIF IsDefined("HouseList")> <br />HouseListC<cfdump var="#HouseList#" label="HouseListC"></CFIF>
			<br />SESSION.HouseAccessListD: ( #isBlank(SESSION.HouseAccessList,'no houses')# )<BR>
			SESSION.GroupList: { #isBlank(SESSION.GroupList,'No grouplist')# } <BR>
				
				<br /><cfdump var="#SESSION.AD#" label="SESSION.AD"	>			
				
<br />ApplicationList
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


<cfdump var="#qUserHouses#" label="qUserHouses">
 --->	
<!--- <CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,userPrincipalName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#) )" USERNAME="ldap" PASSWORD="paulLDAP939">
<cfdump var="#FindSubAccount#" label="rclemensFindSubAccount"> --->
	</cfoutput><!--- (userPrincipalName= sfarmer@alcco.com) --->
</body>
</html>
