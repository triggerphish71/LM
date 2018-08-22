
<cfset Page = "House Visit">

<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	
	<html>
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
			
			<!--- Instantiate the Helper object. --->
			<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
			<cfif isDefined("url.iHouse_ID")>
				<cfset houseId = #url.iHouse_ID#>
			</cfif>
			
			<cfif isDefined("url.SubAccount")>
				<cfset subAccount = #url.SubAccount#>
							
				<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
				<cfset unitId = #dsHouseInfo.unitId#>
				<cfset houseId = #dsHouseInfo.iHouse_ID#>
				<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
			</cfif>
			
			<cfif isDefined("url.NumberOfMonths")>
				<cfset numberOfMonths = #url.NumberOfMonths#>
			<cfelse>
				<cfset numberOfMonths = 3>
			</cfif>
			
			<cfif isDefined("url.Role")>
				<cfset roleFilter = #trim(url.Role)#>
			<cfelse>
				<cfset roleFilter = 0>
			</cfif>
			<cfinclude template="Common/DateToUse.cfm">

			<cfif isDefined("url.FromDateToUse")>
				<cfset fromDateToUse = #url.FromDateToUse#>
			<cfelse>
				<cfset fromDateToUse = #DateAdd("m", -3, dateToUse)#>
			</cfif>
			


			<cfset RoleCodeO = "O">
			<cfset RoleCodeS = "S">
			<cfset RoleCodeC = "C">						
<!--- 			<cfset dsGroups = helperObj.FetchHouseVisitGroups()> --->
			<cfset dsGroupsO = helperObj.FetchHouseVisitGroupsHouseII(houseId,RoleCodeO, DateAdd("m", -numberOfMonths, currentFullMonth), DateAdd("d", 1, workingFullMonthEnd))>
			<cfset dsGroupsS = helperObj.FetchHouseVisitGroupsHouseII(houseId,RoleCodeS, DateAdd("m", -numberOfMonths, currentFullMonth), DateAdd("d", 1, workingFullMonthEnd))>
			<cfset dsGroupsC = helperObj.FetchHouseVisitGroupsHouseII(houseId,RoleCodeC, DateAdd("m", -numberOfMonths, currentFullMonth), DateAdd("d", 1, workingFullMonthEnd))>			 
<!--- 			<cfset dsQuestions = helperObj.FetchHouseVisitQuestions()> --->
			<cfset dsRoles = helperObj.FetchHouseVisitRoles()>
			<cfset dsAuthentication = helperObj.FetchHouseVisitAuthentication()>
			<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>		
			<!--- Check if the current day is the first and if the previous month was selected. --->
			<cfif (DateFormat(Now(), "dd") eq "1" Or DateFormat(Now(), "dd") eq "01") And DateFormat(currentFullMonth, "mm") eq DateFormat(DateAdd("m", -1, Now()), "mm")>	
				<cfif roleFilter neq 0 And helperObj.IsValidRole(dsRoles, roleFilter)>
					<cfset dsEntries = helperObj.FetchHouseVisitEntriesInRangeByRole(houseId, DateAdd("m", -numberOfMonths, currentFullMonth), DateAdd("d", 1, workingFullMonthEnd), roleFilter)>
				<cfelse>
					<cfset dsEntries = helperObj.FetchHouseVisitEntriesInRange(houseId, DateAdd("m", -numberOfMonths, currentFullMonth), DateAdd("d", 1, workingFullMonthEnd))>
				</cfif>					
			<cfelse>
				<cfif roleFilter neq 0 And helperObj.IsValidRole(dsRoles, roleFilter)>
					<cfset dsEntries = helperObj.FetchHouseVisitEntriesInRangeByRole(houseId, DateAdd("m", -numberOfMonths, currentFullMonth), workingFullMonthEnd, roleFilter)>
				<cfelse>
					<cfset dsEntries = helperObj.FetchHouseVisitEntriesInRange(houseId, DateAdd("m", -numberOfMonths, currentFullMonth), workingFullMonthEnd)>
				</cfif>			
			</cfif>
			
			<cfset dsAnswers = helperObj.FetchHouseVisitAnswersRaw(houseId)>
			
	
			<SCRIPT language="javascript">
				var minTableHeight = 510;
				var overrideTableHeight = false;
				var tableHeightPct = 100;
			
				var aw = screen.availWidth;
				var ah = screen.availHeight;
				window.moveTo(0, 0);
				window.resizeTo(aw, ah);
			        
			 	function doSel(obj)
			 	{
			 	    for (i = 1; i < obj.length; i++)
			   	    	if (obj[i].selected == true)	
			           		eval(obj[i].value);
			 	}
				function doSelAll(obj)
				{
					for (i = 0; i < obj.length; i++)
					{
						if (obj[i].selected == true)
						{
							eval(obj[i].value);
						}
					}
				}
				
			 	function getReportTableWidth()
			 	{
			// 		return (410 + (200 * #dsEntries.RecordCount#));
			return (300 );
			 	}
			 	function getReportContainerWidth()
			 	{
			 		var containerWidth = screen.availWidth - 90;
			 		var tableWidth = getReportTableWidth() + 17;
			 		if (tableWidth < containerWidth)
			 		{
			 			return (tableWidth);
			 		}
			 		else
			 		{
			 			return (containerWidth);
			 		}
			 	}
			 	function getFooterTop()
				{
					if (document.getElementById("tbl-container").scrollWidth > document.getElementById("tbl-container").offsetWidth)
						return (document.getElementById("tbl-container").scrollTop + document.getElementById("tbl-container").offsetHeight - document.getElementById("tbl-container").scrollHeight - 16);
					else
						return (document.getElementById("tbl-container").scrollTop + document.getElementById("tbl-container").offsetHeight - document.getElementById("tbl-container").scrollHeight);			
				}
				function getReportTableHeight()
				{
					var tableHeight = screen.availHeight - 240;
					
					if (overrideTableHeight == false)
					{
						if (tableHeight > minTableHeight)
						{
							return (tableHeight);
						}
						else 
						{
							return (minTableHeight);
						}
					}
					else
					{
						return (minTableHeight);
					}
				}
				function getReportTablePct()
				{
					return ((tableHeightPct) + "%");
				}
			</SCRIPT>
		</head>
	<body>
		<form method="post" action="HouseVisits.cfm">
			<cfinclude template="DisplayFiles/Header.cfm">
			<br />
			
</cfoutput>

<cfoutput>
	<cfldap action="query" name="getUserADInfo" start="DC=alcco,DC=com" scope="subtree" attributes="sAMAccountName,Title,DisplayName" 
		filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))"
		server="#ADserver#" port="389" username="ldap" password="paulLDAP939">

	<!--- COLORS --->
	<cfset groupColor = "cdcdcd">
	<cfset freezeColor = "f5f5f5">
	
	<!--- User Info --->
	<cfset userId = getUserADInfo.sAMAccountName> 
	<cfset userFullName = getUserADInfo.DisplayName>
<!---    	<cfif userId is "sfarmer">
		<cfset userRoleName = "RDSM">	
		<cfset userRoleId = 1>
	<cfelse>  ---> 	 	
		<cfset userRoleName = getUserADInfo.Title>
		<cfset userRoleId = helperObj.FetchHouseVisitRoleIdByTitle(dsRoles, dsAuthentication, userRoleName)>
	    <!---  </cfif>  --->  
<!--- 	<br/>#userRole#: #getUserADInfo.Title#   userFullName: #getUserADInfo.DisplayName# userId: #getUserADInfo.sAMAccountName#<br/> --->	
  
	
	<cfif userRoleId gt 0>
		<cfset dsUserRole = helperObj.FetchHouseVisitRoleByTitle(dsRoles, dsAuthentication, userRoleName)>		
		
		<cfset isQuestionRole = helperObj.isQuestionRole(dsQuestionRoles, dsUserRole.iRoleId)>			
		<cfif isQuestionRole eq true>
			<cfset blankRoleCodeParameter = dsUserRole.cRoleCode>
		<cfelse>
			<cfset blankRoleCodeParameter = "*">
		</cfif>
		
<!--- 		<cfset blankHouseVisitReport = "http://maple/ReportServer?%2fFTA%2fBlankHouseVisit&Role=#blankRoleCodeParameter#&rs%3aCommand=Render&rs%3aFormat=PDF">  --->	
 		<cfset blankHouseVisitReport = "BlankHouseVisit.cfm">

 </cfif>
		
	<table style="margin-bottom: 8px; width: <cfif userRoleId gt 0>675px<cfelse>250px</cfif>;" border="0px" cellpadding="0" cellspacing="0" >
		<tr>		
			<td align="left" style="width: 250px;" valign="bottom"> &nbsp;
<!--- 				<font size=-1>
					Limit Entries by Role:
				</font>
				<select name="roles" onChange="doSelAll(this)"
					style="border: ##C0C0C0 inset 0px; font: 10pt Courier New, Courier, mono; padding: 0px; color: ##550000; background: ##FDFBEB;">
								
					<option value="location.href='http://#cgi.SERVER_NAME#/#cgi.SCRIPT_NAME#?Role=0&NumberOfMonths=#numberOfMonths#&<cfif isDefined("iHouse_ID")>iHouse_ID=#iHouse_ID#&</cfif><cfif isDefined("subaccount")>subaccount=#subaccount#&</cfif>DateToUse=#dateToUse#'"<cfif roleFilter eq 0> SELECTED</cfif>>All</option>
					
					<cfloop query="dsRoles">
						<option value="location.href='http://#cgi.SERVER_NAME#/#cgi.SCRIPT_NAME#?Role=#dsRoles.iRoleId#&NumberOfMonths=#numberOfMonths#&<cfif isDefined("iHouse_ID")>iHouse_ID=#iHouse_ID#&</cfif><cfif isDefined("subaccount")>subaccount=#subaccount#&</cfif>DateToUse=#dateToUse#'"<cfif roleFilter eq dsRoles.iRoleId> SELECTED</cfif>>#dsRoles.cRoleName#</option>
					</cfloop>
				</select> --->
			</td>	
			  <cfif userRoleId gt 0>  
				<td align="left" valign="bottom">
					<a title="Click to start filling out a new House Visit Report" href="HouseVisitII.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#&EntryuserRole=#userRoleName#&userRoleId=#userRoleId#&userRole=#userRoleName#">
						 Create New House Visit Entry<br/>
					</a>
				</td>
				<td align="left" valign="bottom" style="width: 210px;">
				<!--- 		<label title="Opens a Blank House Visit Report in a new Window" onClick="window.open('#blankHouseVisitReport#');" style="cursor: hand;">
						<font size=-1 color="blue" style="text-decoration: underline;">
							Open Blank House Visit Report
						</font>
					<img src="images/Pdf.bmp" /> --->
					<a title="Open a Blank House Visit Report in a new Window" href="BlankHouseVisit.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#&EntryuserRole=#userRoleName#&userRoleId=#userRoleId#&role=#url.role#&userRole=#userRoleName#&NumberOfMonths=#numberOfMonths#"">
						 Open a Blank House Visit Report<br/>
					</a>
					</label>
				</td>

			  </cfif> 
			</tr>
		</table>

	<table width="90%">
		<tr valign="top">
			<td>
				<table >
					<tr>
						<td style="text-align:center">Operations House Visit Entry<br/>(Select date to view Report)</td>
					</tr>
					<tr valign="top"><td>
						<cfif dsGroupsO.RecordCount gt 0>
							<div  id="tbl-container"  style="border-top-style: solid; border-top-width: 1px; border-top-color: gray;border-right-style: solid; border-right-width: 1px; border-right-color: gray; border-left-style: solid; border-left-width: 2px; border-left-color: gray;">
								<table     cellspacing="0" cellpadding="1" border="1px">
									<cfloop query="dsGroupsO">
										<tr>
											<td>#cUserDisplayName# #cRoleName# <a href="HouseVisitViewEntry.cfm?iHouse_ID=#url.iHouse_ID#&iEntryId=#iEntryId#&IENTRYUSERID=#userId#&EntryuserFullName=#userFullName#&EntryuserRole=#userRoleName#&hdnrolename=#cRoleName#&userRoleId=#userRoleId#&role=#url.role#&subAccount=#url.SubAccount#&NumberOfMonths=#numberOfMonths#&DateToUse=#datetouse#"> #dateformat(dtCreated, "mm/dd/yyyy")#</a></td>
										</tr>
									</cfloop>	
								</table>
							</div>	
						<cfelse>
							<br />
							<font size=-1 style="font-family: verdana;">
								<strong>
								There are No House Visit Entries to Display.
								</strong>
							</font>
						</cfif>
					</td></tr>	
				</table>	
			</td>		
			<td>
				<table>
					<tr>
						<td  style="text-align:center">Sales House Visit Entry<br/>(Select date to view Report)</td>
					</tr>
					<tr valign="top"><td>
						<cfif dsGroupsS.RecordCount gt 0>
							<div  id="tbl-container"  style="border-top-style: solid; border-top-width: 1px; border-top-color: gray;border-right-style: solid; border-right-width: 1px; border-right-color: gray;
					border-left-style: solid; border-left-width: 2px; border-left-color: gray;">
								<table   cellspacing="0" cellpadding="1" border="1px">
									<cfloop query="dsGroupsS">
										<tr>
											<td>#cUserDisplayName# #cRoleName# <a href="HouseVisitViewEntry.cfm?iHouse_ID=#url.iHouse_ID#&iEntryId=#iEntryId#&IENTRYUSERID=#userId#&EntryuserFullName=#userFullName#&EntryuserRole=#userRoleName#&hdnrolename=#cRoleName#&userRoleId=#userRoleId#&role=#url.role#&subAccount=#url.SubAccount#&NumberOfMonths=#numberOfMonths#&DateToUse=#datetouse#"> #dateformat(dtCreated, "mm/dd/yyyy")#</a></td>
										</tr>
									</cfloop>	
								</table>
							</div>	
						<cfelse>
							<br />
							<font size=-1 style="font-family: verdana;">
								<strong>
								There are No House Visit Entries to Display.
								</strong>
							</font>
						</cfif>
					</td></tr>	
				</table>	
			</td>
			<td>
				<table>
					<tr>
						<td style="text-align:center">Clinical House Visit Entry<br/>(Select date to view Report)</td>
					</tr>
					<tr valign="top"><td>
						<cfif dsGroupsC.RecordCount gt 0>
							<div  id="tbl-container" style="border-top-style: solid; border-top-width: 1px; border-top-color: gray;border-right-style: solid; border-right-width: 1px; border-right-color: gray; border-left-style: solid; border-left-width: 2px; border-left-color: gray;">
								<table    cellspacing="0" cellpadding="1" border="1px">
									<cfloop query="dsGroupsC">
										<tr>
											<td>#cUserDisplayName# #cRoleName# <a href="HouseVisitViewEntry.cfm?iHouse_ID=#url.iHouse_ID#&iEntryId=#iEntryId#&IENTRYUSERID=#userId#&EntryuserFullName=#userFullName#&EntryuserRole=#userRoleName#&hdnrolename=#cRoleName#&userRoleId=#userRoleId#&role=#url.role#&subAccount=#url.SubAccount#&NumberOfMonths=#numberOfMonths#&DateToUse=#datetouse#"> #dateformat(dtCreated, "mm/dd/yyyy")#</a></td>
										</tr>
									</cfloop>	
								</table>
							</div>	
						<cfelse>
							<br />
							<font size=-1 style="font-family: verdana;">
								<strong>
								There are No House Visit Entries to Display.
								</strong>
							</font>
						</cfif>
					</td></tr>	
				</table>	
			</td>		
		</tr>
	</table>
<!--- <cfdump var="#SESSION#"> --->
</cfoutput>		
 
			</form>
			<script language="javascript" type="text/javascript">
				document.getElementById("tbl-container").style.display = 'none';
				document.getElementById("tbl-container").style.display = 'block';
			</script>
		</body>
	</html>
 