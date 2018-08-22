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
				<cfset roleFilter = #url.Role#>
			<cfelse>
				<cfset roleFilter = 0>
			</cfif>
			<cfinclude template="Common/DateToUse.cfm">

			<cfif isDefined("url.FromDateToUse")>
				<cfset fromDateToUse = #url.FromDateToUse#>
			<cfelse>
				<cfset fromDateToUse = #DateAdd("m", -3, dateToUse)#>
			</cfif>
			
			<cfif isDefined("url.Role")>
				<cfset roleFilter = #url.Role#>
			<cfelse>
				<cfset roleFilter = 0>
			</cfif>


			<cfset dsGroups = helperObj.FetchHouseVisitGroups()>
			<cfset dsQuestions = helperObj.FetchHouseVisitQuestions()>
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
			 		return (410 + (200 * #dsEntries.RecordCount#));
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
	<cfset userRole = getUserADInfo.Title>
	
	<cfset userRoleId = helperObj.FetchHouseVisitRoleIdByTitle(dsRoles, dsAuthentication, userRole)>	
	<cfif userRoleId gt 0>
		<cfset dsUserRole = helperObj.FetchHouseVisitRoleByTitle(dsRoles, dsAuthentication, userRole)>		
		
		<cfset isQuestionRole = helperObj.isQuestionRole(dsQuestionRoles, dsUserRole.iRoleId)>			
		<cfif isQuestionRole eq true>
			<cfset blankRoleCodeParameter = dsUserRole.cRoleCode>
		<cfelse>
			<cfset blankRoleCodeParameter = "*">
		</cfif>
		
		<cfset blankHouseVisitReport = "http://maple/ReportServer?%2fFTA%2fBlankHouseVisit&Role=#blankRoleCodeParameter#&rs%3aCommand=Render&rs%3aFormat=PDF">
	</cfif>
		
	<table style="margin-bottom: 8px; width: <cfif userRoleId gt 0>675px<cfelse>250px</cfif>;" border="0px" cellpadding="0" cellspacing="0">
		<tr>		
			<td align="left" style="width: 250px;" valign="bottom">
				<font size=-1>
					Limit Entries by Role:
				</font>
				<select name="roles" onchange="doSelAll(this)"
					style="border: ##C0C0C0 inset 0px; font: 10pt Courier New, Courier, mono; padding: 0px; color: ##550000; background: ##FDFBEB;">
								
					<option value="location.href='http://#cgi.SERVER_NAME#/#cgi.SCRIPT_NAME#?Role=0&NumberOfMonths=#numberOfMonths#&<cfif isDefined("iHouse_ID")>iHouse_ID=#iHouse_ID#&</cfif><cfif isDefined("subaccount")>subaccount=#subaccount#&</cfif>DateToUse=#dateToUse#'"<cfif roleFilter eq 0> SELECTED</cfif>>All</option>
					
					<cfloop query="dsRoles">
						<option value="location.href='http://#cgi.SERVER_NAME#/#cgi.SCRIPT_NAME#?Role=#dsRoles.iRoleId#&NumberOfMonths=#numberOfMonths#&<cfif isDefined("iHouse_ID")>iHouse_ID=#iHouse_ID#&</cfif><cfif isDefined("subaccount")>subaccount=#subaccount#&</cfif>DateToUse=#dateToUse#'"<cfif roleFilter eq dsRoles.iRoleId> SELECTED</cfif>>#dsRoles.cRoleName#</option>
					</cfloop>
				</select>
			</td>	
			<cfif userRoleId gt 0>
				<td align="left" valign="bottom">
					<a title="Click to start filling out a new House Visit Report" href="CreateHouseVisitEntry.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
						<font size=-1>
							Create New House Visit Entry
						</font>
					</a>
				</td>
				<td align="left" valign="bottom" style="width: 210px;">
					<label title="Opens a (PDF) Blank House Visit Report in a new Window" onclick="window.open('#blankHouseVisitReport#');" style="cursor: hand;">
						<font size=-1 color="blue" style="text-decoration: underline;">
							Open Blank House Visit Report
						</font>
						<img src="images/Pdf.bmp" />
					</label>
				</td>
			</cfif>
			</tr>
		</table>
	<cfif dsEntries.RecordCount gt 0>
		<div id="tbl-container" style="border-top-style: solid; border-top-width: 1px; border-top-color: gray;border-right-style: solid; border-right-width: 1px; border-right-color: gray;">
			<table id="tbl" cellspacing="0" cellpadding="1" border="1px">
				<thead>
					<!--- Display the House Visit Dates --->
					<tr>
						<th class="locked" align="right" colspan="4" bgcolor="#freezeColor#" style="font-family: Verdana;">
							<font size=-1>
								Date Visited:&##160;
							</font>
						</th>
						<cfloop query="dsEntries">
							<cfset closed = dsEntries.dtClosed>
							
							<th align="left" style="width: 200px" bgcolor="#freezeColor#">
								<table border="0px" cellpadding="0" cellspacing="0" style="width: 100%; height: 100%">
									<tr>
										<td align="left" bgcolor="#freezeColor#" style="font-weight: bold; width: 50%;">
											<font size=-1>
												#DateFormat(dsEntries.dtHouseVisit, "mm/dd/yyyy")#
											</font>
										</td>
										<cfscript>
											// Declare the IsClosed variable.
											isClosed = true;
											// Check if the dtClosed field has a value.
											if (closed eq "") 
											{
												// Disable the IsClosed variable, so the link can be added.
												isClosed = false;
											}
											else
											{
												// Check if the dtClosed Date is greater than the current date and time.
												if (closed gt Now())
												{
													// The Close date is in the future, so disable the isClosed variable.
													isClosed = false;
												}
											}
										</cfscript>
										<cfif isClosed eq false And dsEntries.iRole eq userRoleId>
											<td align="left" style="width: 50%;">
												<font size=-1>
													<a title="Click to Edit this House Visit Report" href="EditHouseVisitEntry.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&Save=No&EntryId=#dsEntries.iEntryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
														Edit Entry
													</a>
												</font>
											</td>
										<cfelseif isClosed eq false And isDefined("dsUserRole")>
											<cfif dsUserRole.bIsSuperUser eq true>
												<td align="left" style="width: 50%;">
													<font size=-1>
														<a title="Click to Edit this House Visit Report" href="EditHouseVisitEntry.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&Save=No&EntryId=#dsEntries.iEntryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
															Edit Entry
														</a>
													</font>
												</td>
											</cfif>
										</cfif>
									</tr>
								</table>
							</th>
						</cfloop>
					</tr>
					<!--- Display the Role of the User that created the House Visit entry. --->
					<tr>
						<th class="locked" align="right" colspan="4" bgcolor="#freezeColor#" style="font-family: Verdana;">
							<font size=-1>
								User Role:&##160;
							</font>
						</th>
						<cfloop query="dsEntries">
							<th align="left" bgcolor="#freezeColor#">
								<table border="0px" cellpadding="0" cellspacing="0" style="width: 100%; height: 100%">
									<tr>
										<td align="left" style="width: 75px;">
											<font size=-1>
												#helperObj.FetchHouseVisitRoleName(dsRoles, dsEntries.iRole)#
											</font>
										</td>
										<!--- Determine the role code parameter. --->
										<cfset isQuestionRole = helperObj.isQuestionRole(dsQuestionRoles, dsEntries.iRole)>
										<cfset dsCurrentEntryRole = helperObj.FetchHouseVisitRole(dsRoles, dsEntries.iRole)>
										<cfif isQuestionRole eq true>
											<cfset roleCodeParameter = dsCurrentEntryRole.cRoleCode>
										<cfelse>
											<cfset roleCodeParameter = "*">
										</cfif>
										<!--- Build the Uri Query to generate the PDF Report. --->
										<cfset houseVisitPdfReportUri = "http://maple/ReportServer?%2fFTA%2fHouseVisit&Role=#roleCodeParameter#&EntryId=#dsEntries.iEntryId#&rs%3aCommand=Render&rs%3aFormat=PDF">
										<td align="right">
											<table border="0px" cellpadding="0" cellspacing="0" style="width: 100%; height: 100%; padding-right: 3px;">
												<tr>
													<td align="right">
														<font size=-1>
															<a title="Opens a new window with the House Visit Report in PDF Format." href="#houseVisitPdfReportUri#" onclick="window.open('#houseVisitPdfReportUri#'); return (false);" >
																Export to Print
															</a>
														</font>
													</td>
													<td align="right" style="width: 18px;">
														<img title="Opens a new window with the House Visit Report in PDF Format." src="images/PDF_bgLightGray.bmp" width="16px" height="16px" 
															onclick="window.open('#houseVisitPdfReportUri#');" style="cursor: hand;">
													</td>
												</tr>
											</table>
										</td>
									</tr>
								</table>
							</th>
						</cfloop>
					</tr>
					<!--- Display the Entry Header Columns and the name of the people who filled in the House Entries. --->
					<tr>
						<th class="locked" align="middle" bgcolor="#freezeColor#" style="width: 36px;">
							<font size=-1>
								Nbr
							</font>
						</th>
						<th class="locked" align="middle" bgcolor="#freezeColor#" style="width: 40px;">
							<font size=-1>
								Who
							</font>
						</th>
						<th class="locked" align="middle" bgcolor="#freezeColor#" style="width: 36px;">
							<font size=-1>
								Frq
							</font>
						</th>
						<th class="locked" align="middle" bgcolor="#freezeColor#" style="width: 298px;">
							<font size=-1>
								Questions
							</font>
						</th>
						<cfloop query="dsEntries">
							<th align="left" bgcolor="#freezeColor#" style="font-weight: bold; width: 200px;">
								<font size=-1>
									#dsEntries.cUserDisplayName#
								</font>
							</th>
						</cfloop>
					</tr>
				</thead>
				<cfloop query="dsGroups">
					<tr>
						<td class="locked" colspan="1" align="middle" bgcolor="#groupColor#" style="font-weight: bold; font-family: verdana;">
							<font size=2>
								#dsGroups.iSortOrder# 
							</font>
						</td>
						<td class="locked" colspan=3 align="middle" bgcolor="#groupColor#" style="font-weight: bold; font-family: verdana;">
							<font size=2>
								#dsGroups.cGroupName# 
								<cfif dsGroups.iGroupCompletionTime gt 0>
									(#dsGroups.iGroupCompletionTime# min)
								</cfif>
							</font>
						</td>
						<td colspan="#dsEntries.RecordCount#" bgcolor="#groupColor#">
							<font size=-1>
								&##160;
							</font>
						</td>
					</tr>
					<cfset dsGroupQuestions = helperObj.FetchHouseVisitGroupQuestions(dsQuestions, dsGroups.iGroupId)>
					<cfloop query="dsGroupQuestions">
						<tr>
							<td valign="top" class="locked" align="middle" bgcolor="#freezeColor#" style="height: 100px; padding: 3px;">
								<font size=-1>
									#dsGroups.iSortOrder[dsGroups.CurrentRow]#-#dsGroupQuestions.iSortOrder#
								</font>
							</td>
							<td valign="top" class="locked" style="padding: 3px;" align="left" bgcolor="#freezeColor#">
								<font size=-1>
									#helperObj.FetchHouseVisitQuestionRoleGroupString(dsQuestionRoles, dsRoles, dsGroupQuestions.iQuestionId)#
								</font>
							</td>
							<td valign="top" class="locked" align="middle" style="padding: 3px;" bgcolor="#freezeColor#">
								<font size=-1>
									#dsGroupQuestions.cFrequency#
								</font>
							</td>
							<td valign="top" class="locked" align="left" bgcolor="#freezeColor#" valign="center" style="font-family: tahoma; font-size: 14px; padding: 3px;">
								#dsGroupQuestions.cQuestion#
							</td>
							<cfloop query="dsEntries">
								<td valign="top" align="left">
									<font size=-1>
										<div style="padding: 3px; scrollbar-base-color: #freezeColor#;overflow-x: auto; overflow-y: auto; white-space: normal; height: 100px; width: 200px;">
											#helperObj.FetchHouseVisitAnswer(dsAnswers, dsEntries.iEntryId[dsEntries.CurrentRow], dsGroupQuestions.iQuestionId[dsGroupQuestions.CurrentRow])#	
										</div>
									</font>
								</td>
							</cfloop>
						</tr>
					</cfloop>
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
</cfoutput>		
<cfoutput>
			</form>
			<script language="javascript" type="text/javascript">
				document.getElementById("tbl-container").style.display = 'none';
				document.getElementById("tbl-container").style.display = 'block';
			</script>
		</body>
	</html>
</cfoutput>