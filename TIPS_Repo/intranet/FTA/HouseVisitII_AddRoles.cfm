	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	
	<html xmlns="http://www.w3.org/1999/xhtml">
		<cfset Page = "House Visit">
		<cfoutput>
		<head>
			<title>
				Online FTA- #page#
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			<link rel="Stylesheet" href="CSS/Dashboard.css" type="text/css">
			<link rel="stylesheet" href="CSS/HouseVisits.css" type="text/css"> 
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>			
			<cfldap action="query" name="getUserADInfo" start="DC=alcco,DC=com" scope="subtree" attributes="sAMAccountName,Title,DisplayName" 
				filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))"
				server="#ADserver#" port="389" username="ldap" password="paulLDAP939">		
			<style>
				tr.rowOdd {background-color: ##FFFFFF;}
				tr.rowEven {background-color: ##E7E7E7;}
				tr.rowHighlight {background-color: ##FFFF99;}
			</style>
 
		</head>
		</cfoutput>
 		<cfset dsRoles = helperObj.FetchHouseVisitRolesChg()>
		<cfset dsGroups = helperObj.qryHouseVisitIIGroupsFields(#url.groupid#)>
	<body>
		<cfset groupColor = "cdcdcd">
		<cfset freezeColor = "f5f5f5">
		<cfset toolbarColor = "d6d6ab">		
		<cfinclude template="DisplayFiles/Header.cfm">		
		<form method="post" action="HouseVisitII_AddRoles_action.cfm" id="idHouseVisitsAddGroup" name="HouseVisitsAddGroup">
			<table width="60%">
				<cfoutput>
					<input type="hidden" name="groupid" value="#url.groupid#" />
					<tr bgcolor="#groupColor#">
						<td colspan="3">Group: #dsGroups.cTextHeader#</td>
					</tr>
					<tr>
						<td colspan="3" align="center">Select Which Roles Will Use This Question</td>
					</tr>

					<tr>
						<cfloop query="dsRoles">
						<td>#cRoleName#<input type="checkbox" name="roletype" value="#iRoleID#" /></td>
						</cfloop>
					</tr>
					<tr   bgcolor="#toolbarColor#">
						<td colspan="3" align="center"><input name="Submit"  type="submit" value="Submit"/></td>
					</tr>				
				</cfoutput>
			</table>
		</form>
	</body>
</html>
