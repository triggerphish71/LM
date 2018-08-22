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
 			<cfset dsGroups = helperObj.qryHouseVisitIIGroupsFields(GroupID)>
 			<cfset dsQuestions = helperObj.FetchHouseVisitIIExtractQuestion(questionid)> 
	<body>
			<cfset groupColor = "cdcdcd">
			<cfset freezeColor = "f5f5f5">
			<cfset toolbarColor = "d6d6ab">		
			<cfinclude template="DisplayFiles/Header.cfm">		
			<form method="post" action="HouseVisitII_EditQuestion_action.cfm" id="idHouseVisitsEditQuestion" name="HouseVisitsEditQuestion">
		<cfoutput>
			<table>
				<tr>
					<td colspan = "2" align="center">#dsGroups.cTextHeader#</td>
				</tr>
				<cfloop  query="dsQuestions">
					<tr bgcolor="#groupColor#">
						<td>Question ID</td>
						<td><input type="text" name="IQUESTIONID"   value="#IQUESTIONID#" readonly="true" size="5"/>Reference Only</td> 
					</tr>
					<tr>
						<td>Group ID:</td>
						<td><input type="text" name="iGroupID"   value="#iGroupID#" readonly="true"  size="5"/>Reference Only</td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Sort (Display) Order:</td>
						<td><input type="text" name="iSortOrder"   value="#iSortOrder#" size="5" /></td>
					</tr>
					<tr>
						<td>Start Date:</td>
						<td><input type="text" name="cIncludeDate"   value="#cIncludeDate#" /></td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Name ID:</td>
						<td><input type="text" name="cIDName"   value="#cIDName#" /></td>
					</tr>
 
					<tr bgcolor="#groupColor#">
						<TD>Column Size:</TD>
						<td><input type="text" name="cColSize"   value="#cColSize#"  size="5"/></td>
					</tr>
					<tr>
						<td>OnChange Edit</td>
						<td><input type="text" name="cOnChange"   value="#cOnChange#" /></td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Row Size</td>
						<td><input type="text" name="cRowSize"   value="#cRowSize#" /></td>
					</tr>
					<tr>
						<td>Read Only</td>	
						<td><input type="text" name="readonly"   value="#readonly#" /></td> 
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Drop Down</td>	
						<td><input type="text" name="dropdown"   value="#dropdown#" /></td>
					</tr>
					<tr>	
						<td>Post Title</td>
						<td><input type="text" name="posttitle"   value="#posttitle#" /></td>
					</tr>
					<tr bgcolor="#groupColor#">	
						<td>Default</td>
						<td><input type="text" name="defaultvalue"   value="#defaultvalue#" /></td>
					</tr>	 
					<tr>
						<td>Question</td>	
						<td><input type="text" name="cQuestion"   value="#cQuestion#"  size="75"/></td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Delete this Question</td>
						<td><input type="checkbox" name="DelGroup"  value="delgroup" size="1" value="Y" /></td>
					</tr> 
 					<tr   bgcolor="#toolbarColor#">
						<td colspan="2" align="center"><input name="Submit"  type="submit" value="Submit"/></td>
					</tr>			 
				</cfloop>
			</table>
 
			</form>
		</cfoutput>
	</body>
</html>
