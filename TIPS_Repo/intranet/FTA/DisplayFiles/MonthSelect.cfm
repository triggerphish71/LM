<!--------------------------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                                        |
|------------|------------|------------------------------------------------------------------------------------|
| mstriegel  | 02/05/2018 | Added logic so the month to view does not show a dropdown on the excel report      |
|                           And Network ALC Apps and Logout do not display on Excel report                     |
--------------------------------------------------------------------------------------------------------------->


<cfoutput>
<table border=0 cellpadding=0 cellspacing=0 style="<cfif Page eq "Dashboard" Or Page eq "House Visit">width: 1007px;<cfelse>width: 660px;</cfif>">
	<tr>
		<td class="white" style="width: 360px;">
			<cfinclude template="Menu.cfm">
		</td>
		<td align="left" class="whiteleft" style="width: 250px;">
			&##160; 
			<font size=-1>
				<!--- mstriegel 02/06/18 --->
			<cfif FindNoCase("excel",page) EQ 0>	
				<A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">
					Network ALC Apps
				</A> 
				| 
				<A HREF="/intranet/logout.cfm">
					Logout
				</A>
			</cfif>
			<!--- mend mstriegel` --->
			<p>
			<BR>

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

		<cfif isDefined("url.ccllcHouse")>
			<cfset ccllcHouse = #url.ccllcHouse#>
		<cfelse>
			<cfset ccllcHouse = 0>
		</cfif>

		<cfif isDefined("url.iHouse_ID")>
			<cfset houseId = #url.iHouse_ID#>
		</cfif>
		
		<cfif isDefined("url.rollup")>
			<cfset rollup = #url.rollup#>
		</cfif>

		<cfif isdefined("url.Division_ID") and url.Division_ID is not "">
			  <cfset DivisionID = #trim(url.Division_ID)#>
		<cfelse> <cfset DivisionID = "">
		</cfif>
		
		<cfif isdefined("url.Region_ID") and url.Region_ID is not "">
			  <cfset RegionID = #trim(url.Region_ID)#>
		<cfelse> <cfset RegionID = "">
		</cfif>

<!--- Initialize the Color fields. --->
<cfset headerCellColor = "##0066CC">
<cfset budgetcellcolor = "##ffff99">
<cfset secondaryCellColor = "f4f4f4">

			<cfif Page neq "Edit House Visit" And Page neq "Create House Visit" AND FindNoCase("Excel",page) EQ 0>
				&##160; Month to View: 
				<cfset date = DateAdd('d', -1, Now())>
			
				<select name="datetouse" onchange="doSel(this)"
						style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">
										<option value=""></option>
						<cfloop condition="date gte '01/01/2006'">
							<option value="location.href='http://#cgi.SERVER_NAME#/#cgi.SCRIPT_NAME#?Role=#roleFilter#&NumberOfMonths=#numberOfMonths#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#&iHouse_ID=#houseId#&<cfif isDefined("subaccount")>subaccount=#trim(subaccount)#&</cfif>DateToUse=#DateFormat(date,'mmmm yyyy')#'"<cfif isDefined("datetouse") and datetouse is DateFormat(date,'mmmm yyyy')> SELECTED</cfif>>#DateFormat(date,'mmmm yyyy')#</option>
							<cfset date = DateAdd('m',-1,date)>
						</cfloop>
				</select>
				<cfset themonth = month(datetouse)>
				<cfset themonth = monthAsString(themonth)>
			<!--- mstriegel 02/02/2018 --->
			<cfelseif FindNoCase("excel",page) NEQ 0>
				<h4>Month to View: <cfoutput>#url.datetouse#</cfoutput></h4>
			<!--- end mstriegel --->
			</cfif>
		</td>
		<cfif rollup is 0>
		<cfif Page eq "House Visit">
			<td align="left" valign="bottom" style="padding-bottom: 2px;" class="whiteleft">
				<cfparam name="numberOfMonths" type="Numeric" default="3">
				<font size=-1>
					&##160; Previous Months to View:
				</font>
				<select name="numberOfMonths" onchange="doSelAll(this)"
						style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">
						<cfloop from="0" to="12" index="monthIndex">
							<option value="location.href='http://#cgi.SERVER_NAME#/#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#<cfelse>0</cfif>&NumberOfMonths=#monthIndex#&ccllcHouse=#ccllcHouse#&<cfif isDefined("iHouse_ID")>iHouse_ID=#iHouse_ID#&</cfif><cfif isDefined("subaccount")>subaccount=#subaccount#&</cfif>DateToUse=#dateToUse#'"<cfif isDefined("numberOfMonths") and numberOfMonths is monthIndex> SELECTED</cfif>><cfif monthIndex neq 1>#monthIndex# Months<cfelse>#monthIndex# Month</cfif></option>
						</cfloop>
				</select>
			</td>
		</cfif>
		<cfif Page eq "Dashboard">
			<cfldap action="query" name="getUserADInfo" start="DC=alcco,DC=com" scope="subtree" attributes="sAMAccountName,Title,DisplayName" 
				filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))"
				server="#ADserver#" port="389" username="DEVTIPS" password="!A7eburUDETu">
			<!--- Fetch the roles and entry query objects. --->
			<cfset dsRoles = helperObj.FetchHouseVisitRoles()>

			<!--- User Info --->
			<cfset userId = getUserADInfo.sAMAccountName>
			<cfset userFullName = getUserADInfo.DisplayName>
			<cfset userRole = getUserADInfo.Title>
			<cfset userRoleId = helperObj.FetchHouseVisitRoleIdByName(dsRoles, userRole)>
			
			<td align="right" valign="bottom">
				<div id="divNewestHouseVisitEntry" style="width: 360px;">
					<!---<table id="tblNewestHouseVisitEntry" style="width: 100%;" cellspacing="0" cellpadding="1" border="1px">
						<tr>
							<td colspan="3" align="middle" style="font-weight: bold" bgcolor="#headerCellColor#">
								<font size=-1 color="White">
									Last House Visit Entry by Position
								</font>
							</td>
						</tr>
						<tr>
							<td colspan="1" style="width: 70px; font-family: verdana; font-weight: bold;" bgcolor="#budgetCellColor#" align="middle">
								<font size=-1>
									Date	
								</font>
							</td>
							<td colspan="1" style="font-family: verdana; font-weight: bold;" bgcolor="#budgetCellColor#" align="middle">
								<font size=-1>
									Name
								</font>
							</td>
							<td colspan="1" style="width: 70px; font-family: verdana; font-weight: bold;" bgcolor="#budgetCellColor#" align="middle">
								<font size=-1>
									Role
								</font>
							</td>
						</tr>
						<cfscript>
							// Create the dsMostRecentEntries Query Object.
							dsMostRecentEntries = QueryNew("dtHouseVisit,cUserDisplayName,cRoleName");
							// Loop through all of the Roles.
							for (index = 1; index lte dsRoles.RecordCount; index = index + 1)
							{
								// Try to get the most recent Entry for the current Role.
								dsEntry = helperObj.FetchNewestHouseVisitEntryII(houseId, dsRoles["iRoleId"][index]);
								// Check if there was an Entry for the current Role.
								if (dsEntry.RecordCount gt 0)
								{
									// Add a new Row to the dsMostRecentEntries Query Object.
									newRow = QueryAddRow(dsMostRecentEntries);
									// Insert a new row into the dsMostRecentEntries Query Object.
									QuerySetCell(dsMostRecentEntries, "dtHouseVisit", dsEntry.dtHouseVisit );
									QuerySetCell(dsMostRecentEntries, "cUserDisplayName", dsEntry.cUserDisplayName );
									QuerySetCell(dsMostRecentEntries, "cRoleName", helperObj.FetchHouseVisitRoleName(dsRoles, dsEntry.iRole));
								}
							}
						</cfscript>
						<cfquery name="dsMostRecentEntriesSorted" dbtype="query">
							SELECT
								dtHouseVisit,
								cUserDisplayName,
								cRoleName
							FROM
								dsMostRecentEntries
							ORDER BY
								dtHouseVisit DESC;
						</cfquery>
						<cfif dsMostRecentEntriesSorted.RecordCount gt 0>
							<cfloop query="dsMostRecentEntriesSorted">
								<tr>
									<td colspan="1" bgcolor="#secondaryCellColor#" align="middle">
										<font size=-1>
											#DateFormat(dsMostRecentEntriesSorted.dtHouseVisit, "mm/dd/yyyy")#
										</font>
									</td>
									<td colspan="1" bgcolor="#secondaryCellColor#" align="middle">
										<font size=-1>
											#dsMostRecentEntriesSorted.cUserDisplayName#
										</font>
									</td>
									<td colspan="1" bgcolor="#secondaryCellColor#" align="middle">
										<font size=-1>
											#dsMostRecentEntriesSorted.cRoleName#
										</font>
									</td>
								</tr>
							</cfloop>
						<cfelse>
							<tr>
								<td colspan="3" bgcolor="#secondaryCellColor#" align="middle">
									<font size=-1>
										There are No Entries for this House
									</font>
								</td>
							</tr>
						</cfif>
					</table>--->
				</div>
			</td>
		</cfif>
		</cfif>
	</tr>
</table>
</cfoutput>