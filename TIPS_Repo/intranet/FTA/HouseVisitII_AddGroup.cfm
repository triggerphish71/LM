


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
		</head>
		</cfoutput>
		<body>
			<cfset groupColor = "cdcdcd">
			<cfset freezeColor = "f5f5f5">
			<cfset toolbarColor = "d6d6ab">		
			<cfinclude template="DisplayFiles/Header.cfm">		
			<form method="post" action="HouseVisitII_AddGroup_action.cfm" id="idHouseVisitsAddGroup" name="HouseVisitsAddGroup">
			<cfoutput>
				<table width="75%">
					<tr>
						<td colspan="2"><hr/></td>
					</tr>	
					<tr>
						<td colspan="2" align="center">Create New House Visit Question Group</td>
					</tr>
					<tr>
						<td colspan="2">Enter values to create a new base level question</td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Group Name<br/> NO Spaces or special characters.</td>
						<td><input type="text" name="groupname"   size="30"/></td>
					</tr>
					<tr>
						<td>Completion Time</td>
						<td><input type="text" name="compltime"   size="5"/></td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td colspan="2">Sort Order<br/> The sort order will be entered as the last item, to rearrange the list use the Sort Order Edit Page. </td>
					</tr>
					<tr>
						<td>Header Text<br/> (What is displayed on the screen and reports)</td>
						<td><input type="text" name="headtext"   size="30"/></td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Index Max <br/>(How many entries for the base display.)</td>
						<td><input type="text" name="indexmax"   size="5" value="1"/> </td>
					</tr>
					<tr>
						<td>Index Name<br/> (An abbreviated name of the question, no spaces or special characters.)</td>
						<td><input type="text" name="indexname"   size="25"/></td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Add Rows<br/> (Can the user select to enter additional rows? This is entries beyond the Index Max above.)</td>
						<td><select name="addrows">
								<option value="N" selected="selected">No</option>
								<option value="Y">Yes</option>
							</select>
						</td>
					</tr>
					<tr   bgcolor="#toolbarColor#">
						<td colspan="2" align="center"><input name="Submit"  type="submit" value="Submit"/></td>
					</tr>
				</table>
			</cfoutput>
 
			</form>
		</body>
</html>
