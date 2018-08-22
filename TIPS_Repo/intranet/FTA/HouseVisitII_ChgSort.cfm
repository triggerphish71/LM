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
			<script language="javascript">
			function editthis(thisid){
			
			window.open("HouseVistII_EditGroup.cfm?GroupID=thisid.value")

			}
			</script>

						
		</head>
		</cfoutput>
 			<cfset dsGroups = helperObj.FetchHouseVisitGroupsIIRpt()>
		<body>
			<cfset groupColor = "cdcdcd">
			<cfset freezeColor = "f5f5f5">
			<cfset toolbarColor = "d6d6ab">		
			<cfinclude template="DisplayFiles/Header.cfm">		
			<form method="post" action="HouseVisitII_ChgSort_action.cfm" id="idHouseVisitsChgSort" name="HouseVisitsChgSort">
			<cfoutput>
				<table width="75%">	
					<tr>
						<td colspan="8" align="center">House Visit Question Groups</td>
					</tr>	
 	
					<tr>
						<td colspan="8" align="left">Changing the Sort Order changes the Display Order.</td>
					</tr>										
 
					<tr>
						<td>Group ID</td>					
						<td>Group Name</td>
						<td>Completion Time</td>
						<td>Sort Order</td>
						<td>Header Text</td>
						<td>Index Max </td>
						<td>Index Name</td>
						<td>Add Rows</td>
						<td>Add Row Name</td>
					</tr>	
					 
				<cfloop query="dsGroups">
 

					<tr class="#IIf(CurrentRow Mod 2, DE('rowOdd'), DE('rowEven'))#" onmouseover="this.className='rowHighlight'" <cfif CurrentRow Mod 2>onmouseout="this.className='rowOdd'"<cfelse>onmouseout="this.className='rowEven'"</cfif> >
 						 
						<td><input type="text" name="groupId" value="#iGroupid#" readonly="true"  size="5"/></td>
						<td>#cGroupName#</td>
						<td>#iGroupCompletionTime#</td>
						<td><input type="text" name="sortorder#iGroupid#" value="#iSortOrder#"  size="5"/></td>
						<td>#cTextHeader#</td>
 						<td>#IndexMax#</td>
						<td>#IndexName#</td>
						<td>#AddRows#</td>
						<td>#addrowname#</td> 
					</tr> 

				</cfloop>	
 					<tr   bgcolor="#toolbarColor#">
						<td colspan="2" align="center"><input name="Submit"  type="submit" value="Submit"/></td>
					</tr>
				</table>
			</cfoutput>
 
			</form>
		</body>
</html>