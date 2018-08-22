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
		
 			<cfset dsGroups = helperObj.qryHouseVisitIIGroupsFields(#GroupID#)>
		</cfoutput>
		<body>
			<cfset groupColor = "cdcdcd">
			<cfset freezeColor = "f5f5f5">
			<cfset toolbarColor = "d6d6ab">		
			<cfinclude template="DisplayFiles/Header.cfm">		
			<form method="post" action="HouseVisitII_AddQuestion_action.cfm" id="idHouseVisitsAddGroup" name="HouseVisitsAddGroup">
			<cfoutput>
			<table width="80%">
				<tr>
					<td  align="center" colspan = "2">Group: #dsGroups.cTextHeader#</td>
				</tr>
					 <input type="hidden" name="iGroupID"   value="#GroupID#" /> 
					<tr>
						<td>Question:</td>	
						<td> <textarea name="cQuestion" cols="80" rows="2"></textarea>  The Question to be answered.</td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Sort (Display) Order:</td>
						<td><!--- <input type="text" name="iSortOrder"     size="5" /> ---> Order of appearance within the group. <br />The next sort number will be assigned.<br/>To reorder the sort (appearance) order use the sort screen.<br/>For items to appear on the same line, i.e. First/Last Name use the same sort value. </td>
					</tr>
					<tr>
						<td>Include Date:</td>
						<td><select name="cIncludeDate">
								<option value="N" selected="selected">No</option>
								<option value="Y">Yes</option>
							</select> Does the Question need the date picker?</td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Name ID:</td>
						<td><input type="text" name="cIDName"   size="25"   /> The Field ID Name, no spaces, special characters. </td>
					</tr>
					<tr bgcolor="#groupColor#">
						<TD>Yes/No:</TD>
						<td><input type="checkbox" name="yesno"   value="Y"    size="5"/> Is this a "Yes/No" answer question. Check Box if "yes"</td>
					</tr>					
					<tr bgcolor="#groupColor#">
						<TD>Column Size:</TD>
						<td><input type="text" name="cColSize"   value="35"   size="5"/> Length of the input field, default is 35. Yes/No and Date fields will be adjusted accordingly.</td>
					</tr>
					<tr>
						<td>OnChange Edit:</td>
						<td><select name="cOnChange">
								<option value="N" selected="selected">No</option>
								<option value="Y">Yes</option>
							</select> Will the question be using a JavaScript?</td>
					</tr>
<!--- 					<tr>
						<td>First/Last Name Fields:</td>
						<td><select name="Firstlastname">
								<option value="N" selected="selected">No</option>
								<option value="Y">Yes</option>
							</select>  </td>
					</tr> --->

					<tr bgcolor="#groupColor#">
						<td>Row Size:</td>
						<td><input type="text" name="cRowSize"   value="0"  size="5"  /> If field will be a textarea, enter number of rows.</td>
					</tr>
					<tr>
						<td>Read Only:</td>	
						<td><select name="readonly">
								<option value="N" selected="selected">No</option>
								<option value="Y">Yes</option>
							</select> Will the question be Read Only?</td>
					</tr>
					<tr bgcolor="#groupColor#">
						<td>Drop Down:</td>	
						<td><select name="dropdown">
								<option value="N" selected="selected">No</option>
								<option value="Y">Yes</option>
							</select> Will a drop down list be created for this item?</td>
					</tr>
					<tr>	
						<td>Post Title:</td>
						<td><input type="text" name="posttitle"     /> A suffix added to the display.</td>
					</tr>
					<tr bgcolor="#groupColor#">	
						<td>Default:</td>
						<td><input type="text" name="defaultvalue"    /> Is there to be a default value.</td>
					</tr>	 

			 
 					<tr   bgcolor="#toolbarColor#">
						<td colspan="2" align="center"><input name="Submit"  type="submit" value="Submit"/></td>
					</tr>				 
			</table>
			</cfoutput>
 
			</form>
		</body>
</html>
