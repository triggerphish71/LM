<cfset Page = "Create House Visit">

<!--- HEAD --->
<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<cfheader name='expires' value='#Now()#'> 
			<cfheader name='pragma' value='no-cache'>
			<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
			<link rel="stylesheet" href="CSS/datePicker.css" type="text/css">
			<!--- jQuery --->
			<script type="text/javascript" src="ScriptFiles/jquery-1.3.2.js"></script>
			<!--- required plugins --->
			<script type="text/javascript" src="ScriptFiles/date.js"></script>
			<script type="text/javascript" src="ScriptFiles/jquery.bgiframe.js"></script>
			<!--- jquery.datePicker.js --->
			<script type="text/javascript" src="ScriptFiles/jquery.datePicker.js"></script>
			<script type="text/javascript" language="javascript">
				// Set the Date Picker's Format 'Month/Day/Year'.  example: 04/31/2009
				Date.format = 'mm/dd/yyyy';
				// Instantiate the Date Picker object and set the minimum Date to 2008.
				$(function()
				{
					$('##txtEntryDate').datePicker().val('#DateFormat(Now(), "mm/dd/yyyy")#').trigger('change');
					$('##txtEntryDate').datePicker({startDate:'#DateFormat(DateAdd("d", -5, Now()), "mm/dd/yyyy")#', endDate: '#DateFormat(Now(), "mm/dd/yyyy")#'});
				});
			</script>
			<title>
				Online FTA- #page#
			</title>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

			
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
	
			<cfinclude template="Common/DateToUse.cfm">
			<cfinclude template="ScriptFiles/FTACommonScript.cfm">
			
			<style type="text/css">

				a.dp-choose-date {
					float: left;
					width: 16px;
					height: 16px;
					padding: 0;
					margin: 3px 1px 0;
					display: block;
					text-indent: -2000px;
					overflow: hidden;
					background: url(Images/Calendar.png) no-repeat; 
				}
				a.dp-choose-date.dp-disabled {
					background-position: 0 -20px;
					cursor: default;
				}

				input.dp-applied {
					width: 130px;
					float: left;
				}
			</style>
		</head>
</cfoutput>

<!--- BODY --->
<cfoutput>
	<body>
		<cfinclude template="DisplayFiles/Header.cfm">
		<form id="frmCreateHouseVisitEntry" method="post" action="CreateHouseVisitEntry_Action.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
			<CFLDAP ACTION="query" NAME="getUserADInfo" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="sAMAccountName,Title,DisplayName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))" USERNAME="ldap" PASSWORD="paulLDAP939">		
			
			<!--- COLORS --->
			<cfset groupColor = "cdcdcd">
			<cfset freezeColor = "f5f5f5">
			<cfset toolbarColor = "d6d6ab">
			<!--- VIEWS - View All | View Users with Edit Last | Edit/New ---->
			<cfset userId = getUserADInfo.sAMAccountName>
			<cfset userFullName = getUserADInfo.DisplayName>
			<cfset userRole = getUserADInfo.Title>
			<!--- Get the House Visit Role record. --->
			<cfset dsRoles = helperObj.FetchHouseVisitRoles()>
			<cfset dsAuthentication = helperObj.FetchHouseVisitAuthentication()>
			<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>
			<cfset dsUserRole = helperObj.FetchHouseVisitRoleByTitle(dsRoles, dsAuthentication, userRole)>
			
			<a style="padding-bottom: 5px;" href="HouseVisits.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
				<font size=-1>
					Return to House Visits Page
				</font>
			</a>
			<p><font size=-3></p>
			<table cellspacing="0" cellpadding="0" border="1px" align="left" id="tblHouseVisitsHeader" style="padding: 3px;">
				<tr>
					<td colspan="2" align="middle" bgcolor="#groupColor#" style="font-family: Tahoma; font-weight: bold;">
						<font size=-1>
							Create New House Visit
						</font>
					</td>
				</tr>
				<tr>
					<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
						<label for="txtEntryDate">
							<font size=-1>
								Date:
							</font>
						</label>
					</td>
					<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
						<input type="text" name="txtEntryDate" readonly="yes" id="txtEntryDate" class="date-pick" style="text-align: left;" value="#DateFormat(Now(), 'mm/dd/yyyy')#" />
					</td>
				</tr>
				<tr>
					<input type="hidden" id="hdnIsSuperUser" name="hdnIsSuperUser" value="<cfif dsUserRole.bIsSuperUser eq true>True<cfelse>False</cfif>">
					<cfif dsUserRole.bIsSuperUser eq true>
						<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
							<label for="ddlEntryUserRole">
								<font size=-1>
									Role:
								</font>
							</label>
						</td>
						<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
							<select name="ddlEntryUserRole" onchange="doSelAll(this)" style="color: black; background-color: white; width: 150px;">
								
								<cfloop query="dsRoles">	
									<cfif helperObj.IsQuestionRole(dsQuestionRoles, dsRoles.iRoleId) Or dsUserRole.iRoleId eq dsRoles.iRoleId>
										<option value="#dsRoles.iRoleId#"<cfif dsUserRole.iRoleId eq dsRoles.iRoleId> SELECTED</cfif>>
											#dsRoles.cRoleName#
										</option>
									</cfif>
								</cfloop>
							</select>			
						</td>
					<cfelse>
						<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
							<label for="txtEntryUserRole">
								<font size=-1>
									Role:
								</font>
							</label>
						</td>
						<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
							<input type="text" id="txtEntryUserRole" name="txtEntryUserRole" readonly="true" style="background-color: #freezeColor#; width: 148px;" value="#userRole#" />
						</td>
					</cfif>
				</tr>
				<tr>
					<td align="left" colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" width="60px">
						<label for="txtEntryUserFullName">
							<font size=-1>
								Name:
							</font>
						</label>
					</td>
					<td align="left" colspan="1"  bgcolor="#freezeColor#" width="150px">
						<input type="text" id="txtEntryUserFullName" name="txtEntryUserFullName" readonly="true" style="background-color: #freezeColor#; width: 148px;" value="#userFullName#" />
						<input type="hidden" id="hdnEntryUserId" name="hdnEntryUserId" value="#userId#" />
					</td>
				</tr>
				<tr>
					<td align="right" colspan="2" bgcolor="#toolbarColor#">
						<input type="button" value="Cancel" style="width: 70px; margin-right: 22px;" onClick="window.location='HouseVisits.cfm?NumberOfMonths=<cfif isDefined("url.NumberOfMonths")>#url.NumberOfMonths#<cfelse>3</cfif>&Role=<cfif isDefined("url.Role")>#url.Role#<cfelse>0</cfif>&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#'" />
						<input type="submit" value="Create" style="width: 120px;" />
					</td>
				</tr>
			</table>
		</form>
	</body>
</cfoutput>

<!--- FOOTER --->
<cfoutput>
	</html>
</cfoutput>	