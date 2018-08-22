<style type="text/css" media="all">

{
	border: #C0C0C0 inset 1px;
	font: 10pt Courier New, Courier, mono;
	padding: 1px;
	color: #550000;
	background: #FDFBEB;
}
</style>

<cfparam name="Division_ID" default="">
<cfparam name="Region_ID" default=""> 

<cfset RegionID = 0>
<cfset ccllcAccess = 0>
<cfset level = "House">
<cfset rollup= 0> <!--- rollup=0 (House); rollup=1 (consolidated); rollup=2 (division); rollup=3 (region) --->

	<!---<cfif Session.GroupList contains ("AG-FTA-SC")> ---> <!---"_ALC Corporate Office" group replaces this- changed 10/29 Mamta Shah---> <!--- _Enlivant Chicago HQ --->
	<cfif Session.GroupList contains ("FTA")>
		<cfset level = "Corporate">
	<cfelseif Session.GroupList contains ("DVP") or Session.GroupList contains ("DDHR") or Session.GroupList contains ("RDSM") or Session.GroupList contains ("Div Vice President") or Session.GroupList contains ("Human Resources")>
		<cfset level="Division">
	<cfelseif Session.GroupList contains ("RDO") or Session.GroupList contains ("RDSM") or Session.GroupList contains ("RDQCS") or Session.GroupList contains ("OPS") or Session.GroupList contains ("RDQCM")>
		<cfset level="Region">
	<cfelse> <cfset level="House">
	</cfif>

<cfif isdefined("url.Division_ID") and url.Division_ID is not "">
      <cfset DivisionID = url.Division_ID>
</cfif>

<cfif isdefined("url.Region_ID") and url.Region_ID is not "">
      <cfset RegionID = url.Region_ID>
</cfif>

<cfif isdefined("url.rollup") and url.rollup is not "">
      <cfset urlrollup = url.rollup>
<cfelse><cfset urlrollup = 0>
</cfif>


<cfif FindSubAccount.company is 0>
		
	<cfldap action="query" name="getUserADInfo" start="DC=alcco,DC=com" scope="subtree" attributes="sAMAccountName,Title,DisplayName" 
		filter="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))"
		server="#ADserver#" port="389" username="DEVTIPS" password="!A7eburUDETu">

	<!--- User Info --->
	<cfset userId = getUserADInfo.sAMAccountName>
	<cfset userFullName = getUserADInfo.DisplayName>
	<cfset userRole = getUserADInfo.Title>

	<cfquery name="dsGetUserInfo" datasource="#application.datasource#">
		SELECT [cFullName]
			  ,[cUserName]
			  ,[cEmail]
			  ,[cRole]
			  ,[cScope]
			  ,[bCCLLCAccess]
		  FROM [FTA].[dbo].[UserAccountAccess]
		  WHERE [cUserName] = '#session.userName#'
	</cfquery>	


	<cfquery name="dsGetCCLLCAccess" datasource="#application.datasource#">
		SELECT [cFullName]
			  ,[cUserName]
			  ,[cEmail]
			  ,[cRole]
			  ,[cScope]
			  ,[bCCLLCAccess]
		  FROM [FTA].[dbo].[UserAccountAccess]
		  WHERE [cUserName] = '#session.userName#'
	</cfquery>	

	
	<!--- Fetch all of the ccllc Houses. --->
<!---	<cfquery name="dsGetCCLLCHouses" datasource="#TimeCard#">
		select 'CCLLC - ' + cName as cName
			   ,iHouse_Id as GetHousesId
			   ,cGLsubaccount 
		from fta.dbo.CCLLCHouse h
		inner join Timecard.dbo.tbl_OrgLevels o on o.i_OrgLevel3Code = h.iOrgLevel3Code
		order by cName
	</cfquery>  --->
	
	<!--- Fetch all of the divisions. --->
	<cfquery name="dsGetDivisions" datasource="#application.datasource#">
		select cName as Division, iRegion_ID as DivisionID from fta.dbo.vw_Region where iRegion_ID <> 12 order by cName
	</cfquery>


	<cfif level is "Division">
		<cfloop query="dsGetDivisions">
			<cfif Session.GroupList contains ("_#dsGetDivisions.Division#") or Session.ADDescription contains ("#dsGetDivisions.Division#")>
				<cfset DivisionID = #dsGetDivisions.DivisionID#>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
	

	<!--- Fetch all of the regions. --->
	<cfquery name="dsGetRegions" datasource="#application.datasource#">
		select r.cName as Region, r.iOPSArea_ID as RegionID, d.cName as Division 
		from fta.dbo.vw_OpsArea r
		join fta.dbo.vw_Region d on d.iRegion_ID = r.iRegion_ID
		where r.iOPSArea_ID not in (32,27,28) order by r.cName
	</cfquery>
	
	<cfif level is "Region">
		<cfloop query="dsGetRegions"><!---<cfdump var="#dsGetRegions.Region#"><cfdump var="#dsGetRegions.Division#">--->
			<cfif Session.ADDescription contains ("#dsGetRegions.Region#") and Session.GroupList contains ("#dsGetRegions.Division#")>
				<cfset RegionID = #dsGetRegions.RegionID#>
				<cfbreak>
			</cfif>
		</cfloop>
	</cfif>
		
	<!--- Show the Houses Drop-down List. --->
	<cfset showHouseSelect = true>

<cfelse>

	<!--- Set the Sub Account Number to the House passed-in from the Apps Menu. --->
	<cfset SubAccountNumber = FindSubAccount.company>
	
	<!--- Do NOT Show the Houses Drop-down List. --->
	<cfset showHouseSelect = false>
	<cfset level = "House">
		
</cfif>

<cfset divid = 0>
<cfset regid = 0>
<cfset divselected = 0>
<cfset regselected = 0>


<cfif FindSubAccount.company is 0>
	<cfoutput query="dsGetCCLLCAccess">
		<cfif bCCLLCAccess is 1>
			<cfset ccllcAccess = 1>
		<cfelse>
			<cfset ccllcAccess = 0>
		</cfif>
	</cfoutput>
</cfif>
<!--- Check if the Houses Drop-down List should be displayed. --->


	<cfif showHouseSelect>
		<!--- Display the Houses Drop-down List here. --->
		<form name="frmHouseSelect">
			<table>
				<tr>
					
					<td style="background-color:#ffffff">View FTA for:</td>
					<td style="background-color:#ffffff">
				<cfset expense = #cgi.SCRIPT_NAME# >
	            <cfif 15 neq  #find("SpendDown_Admin",expense)#>
						<cfif level is "Corporate">	
							<select name="Division_ID" onchange="doSel(this)"
							style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">						
								<option value="" > </option>
								
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the regions. --->
									<cfquery name="dsGetDivision" datasource="#application.datasource#">
										select cName as Division, iRegion_ID as DivisionID from fta.dbo.vw_Region where iRegion_ID = 12
									</cfquery>
								</cfif>
								<cfoutput query="dsGetDivision">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=1&Division_ID=#DivisionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (Division_ID eq 12) and (urlrollup eq 1)> 
											SELECTED
										</cfif>>
										ALC Consolidated
									</option>
								</cfoutput>
															
								<option value=""></option>
								<cfoutput query="dsGetDivisions">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=2&Division_ID=#DivisionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (Division_ID eq DivisionID)> 
											SELECTED
										</cfif>>
										Divisional Rollup #Division#
									</option>
								</cfoutput>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the regions. --->
									<cfquery name="dsGetRegions" datasource="#application.datasource#">
										select cName as Region, iOPSArea_ID as RegionID from fta.dbo.vw_OpsArea where iOPSArea_ID not in (32,27,28) order by cName
									</cfquery>
								</cfif>
								<option value=""></option>	
								<cfoutput query="dsGetRegions">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=3&Division_ID=#divid#&Region_ID=#RegionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (Region_ID eq RegionID)> 
											SELECTED
										</cfif>>
										Regional Rollup #Region#
									</option>
								</cfoutput>
								<option value=""></option>		
								<cfif ccllcAccess is 1>
						<!---  ganga Thota 07/25/2017  - commented out for new timecard database not available 
									<cfoutput query="dsGetCCLLCHouses">
										<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=1&rollup=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
											<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 1)> 
												SELECTED
											</cfif>>
											#cName#
										</option>
									</cfoutput>   --->
								</cfif>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the enabled Houses. --->
									<cfquery name="dsGetHouses" datasource="#application.datasource#">
										SELECT
											cName,
											iHouse_ID AS GetHousesId,
											cGLSubAccount
										FROM dbo.House
										<!---inner join TimeCard.timecard.dbo.tbl_OrgLevels o on o.i_OrgLevel3Code = substring(cGLsubaccount, 7,9) --->
										WHERE dtRowDeleted IS NULL AND bIsSandbox = 0 
										<cfif isDefined("RDOrestrict")>
										AND iOpsArea_ID = #RDOrestrict#
										</cfif>
										ORDER BY
											cName;
									</cfquery>
								</cfif>
		
								<cfoutput query="dsGetHouses">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 0)> 
											SELECTED
										</cfif>>
										#cName#
									</option>
								</cfoutput>
							</select>
						</cfif>	
						
						<cfif level is "Division">
							<select name="Division_ID" onchange="doSel(this)"
							style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">						
								<option value=""></option>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the regions. --->
									<cfquery name="dsGetDivision" datasource="#application.datasource#">
										select cName as Division, iRegion_ID as DivisionID from fta.dbo.vw_Region where iRegion_ID = #DivisionID# and iRegion_ID <> 12
									</cfquery>
								</cfif>
								<cfoutput query="dsGetDivision">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=2&Division_ID=#DivisionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (Division_ID eq DivisionID)> 
											SELECTED
										</cfif>>
										Divisional Rollup #Division#
									</option>
								</cfoutput>
								<option value=""></option>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the regions. --->
									<cfquery name="dsGetRegions" datasource="#application.datasource#">
										select cName as Region, iOPSArea_ID as RegionID from fta.dbo.vw_OpsArea where iRegion_ID = #dsGetDivision.DivisionID#
										and iOPSArea_ID not in (32,27,28)
										order by cName
									</cfquery>
								</cfif>
								<cfoutput query="dsGetRegions">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=3&Division_ID=#divid#&Region_ID=#RegionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (Region_ID eq RegionID)> 
											SELECTED
										</cfif>>
										Regional Rollup #Region#
									</option>
								</cfoutput>
								<option value=""></option>		
								<cfif ccllcAccess is 1>
									<cfoutput query="dsGetCCLLCHouses">
										<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=1&rollup=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
											<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 1)> 
												SELECTED
											</cfif>>
											#cName#
										</option>
									</cfoutput>
								</cfif>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the enabled Houses. --->
									<cfquery name="dsGetHouses" datasource="#application.datasource#">
										SELECT	h.cName,
												h.iHouse_ID AS GetHousesId,
												h.cGLSubAccount
										FROM dbo.House h
										--inner join TimeCard.timecard.dbo.tbl_OrgLevels o on o.i_OrgLevel3Code = substring(h.cGLsubaccount, 7,9)
										inner join fta.dbo.vw_OpsArea ops on h.iOpsArea_ID = ops.iOpsArea_ID
										WHERE h.dtRowDeleted IS NULL AND h.bIsSandbox = 0 
										AND ops.iRegion_ID = #dsGetDivision.DivisionID#
										ORDER BY h.cName;
									</cfquery>
								</cfif>
		
								<cfoutput query="dsGetHouses">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 0)> 
											SELECTED
										</cfif>>
										#cName#
									</option>
								</cfoutput>
							</select>
						</cfif>	
						
						<cfif level is "Region">
							<select name="Region_ID" onchange="doSel(this)"
							style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">						
								<option value=""></option>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the regions. --->
									<cfquery name="dsGetRegion" datasource="#application.datasource#">
										<!---select distinct substring(n_orgLevel2,7,len(n_orgLevel2)) as Region, i_OrgLevel2Code as RegionID from timecard.dbo.tbl_OrgLevels--->
										select cName as Region, iOPSArea_ID as RegionID from fta.dbo.vw_OpsArea where iOPSArea_ID not in (32,27,28)    <!--- and iOPSArea_ID = #RegionID#--->
									</cfquery>
								</cfif>
								<cfoutput query="dsGetRegion">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=3&Division_ID=#divid#&Region_ID=#RegionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (Region_ID eq RegionID)> 
											SELECTED
										</cfif>>
										Regional Rollup #Region#
									</option>
								</cfoutput>
								<option value=""></option>		
								<cfif ccllcAccess is 1>
									<cfoutput query="dsGetCCLLCHouses">
										<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=1&rollup=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
											<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 1)> 
												SELECTED
											</cfif>>
											#cName#
										</option>
									</cfoutput>
								</cfif>
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the enabled Houses. --->
									<cfquery name="dsGetHouses" datasource="#application.datasource#">
										SELECT	cName,
												iHouse_ID AS GetHousesId,
												cGLSubAccount
										FROM dbo.House
									<!---	inner join TimeCard.timecard.dbo.tbl_OrgLevels o on o.i_OrgLevel3Code = substring(cGLsubaccount, 7,9) --and o.i_OrgLevel2Code = #regid#  --->
										WHERE dtRowDeleted IS NULL AND bIsSandbox = 0 
										<Cfif #RegionID# GT 0>
										  AND iOpsArea_ID = #RegionID#
										<cfelse> 
										<!---   AND iHouse_ID = #GetHousesId#---> 
										</cfif>
										ORDER BY cName;
									</cfquery>
								</cfif>
		
								<cfoutput query="dsGetHouses">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&rollup=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 0)> 
											SELECTED
										</cfif>>
										#cName#
									</option>
								</cfoutput>
							</select>
						</cfif>	
	                 <cfif level is "House">
							<cfif FindSubAccount.company is 0>							
								<!--- Fetch all of the enabled Houses. --->
								<cfquery name="dsGetHouses" datasource="#application.datasource#">
									SELECT
										cName,
										iHouse_ID AS GetHousesId,
										cGLSubAccount
									FROM
										dbo.House
									WHERE
										dtRowDeleted IS NULL AND
										bIsSandbox = 0
									<cfif isDefined("RDOrestrict")>
									AND iOpsArea_ID = #RDOrestrict#
									</cfif>
									ORDER BY
										cName;
								</cfquery>
								
								<!--- Show the Houses Drop-down List. --->
								<cfset showHouseSelect = true>						
							<cfelse>						
								<!--- Set the Sub Account Number to the House passed-in from the Apps Menu. --->
								<cfset SubAccountNumber = FindSubAccount.company>							
								<!--- Do NOT Show the Houses Drop-down List. --->
								<cfset showHouseSelect = false>
									
							</cfif>
							
							<!--- Check if the Houses Drop-down List should be displayed. --->
							<cfif showHouseSelect>													
									<table>
										<tr>
											<td style="background-color:#ffffff">
												<select name="iHouse_ID" onchange="doSel(this)"
												style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">						
													<option value=""></option>
													<cfoutput query="dsGetHouses">
														<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")> NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
															<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId)> 
																SELECTED
															</cfif>>
															#cName#
														</option>
													</cfoutput>
												</select>
											</td>
										</tr>
									</table>						
							</cfif>
						</cfif>
	<cfelse> 

	     
							<cfif FindSubAccount.company is 0>							
								<!--- Fetch all of the enabled Houses. --->
								<cfquery name="dsGetHouses" datasource="#application.datasource#">
									SELECT
										cName,
										iHouse_ID AS GetHousesId,
										cGLSubAccount
									FROM
										dbo.House
									WHERE
										dtRowDeleted IS NULL AND
										bIsSandbox = 0
									<cfif isDefined("RDOrestrict")>
									AND iOpsArea_ID = #RDOrestrict#
									</cfif>
									ORDER BY
										cName;
								</cfquery>
								
								 <!---Show the Houses Drop-down List.---> 
								<cfset showHouseSelect = true>						
							<cfelse>						
								 Set the Sub Account Number to the House passed-in from the Apps Menu. 
								<cfset SubAccountNumber = FindSubAccount.company>							
								 Do NOT Show the Houses Drop-down List. 
								<cfset showHouseSelect = false>
									
							</cfif>
							
							 <!---Check if the Houses Drop-down List should be displayed.---> 
							<cfif showHouseSelect>													
									<table>
										<tr>
											<td style="background-color:#ffffff">
												<select name="iHouse_ID" onchange="doSel(this)"
												style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">						
													<option value=""></option>
													<cfoutput query="dsGetHouses">
														<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
															<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId)> 
																SELECTED
															</cfif>>
															#cName#
														</option>
													</cfoutput>
												</select>
											</td>
										</tr>
									</table>						
							</cfif>
			</cfif> 		
					</td>
				</tr>
			</table>
		</form>
		<HR align=left size=2 width=580 color="##0066CC">
	</cfif>	


					<!---<select name="Division_ID" onchange="doSel(this)"
					style="border: ##C0C0C0 inset 1px; font: 10pt Courier New, Courier, mono; padding: 1px; color: ##550000; background: ##FDFBEB;">						
						<option value=""></option>
						
						<cfoutput query="dsGetDivisions">
							<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>Division_ID=#DivisionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
								<cfset divselected = 0>
								<cfif (Division_ID eq DivisionID)> 
									SELECTED
									<cfset divid = DivisionID>
									<cfset divselected = 1>
								<cfelse> <cfset divselected = 0>
								</cfif>>
								Divisional Rollup #Division#
							</option>
						</cfoutput>
						
						<cfif divselected is 1>
							<cfif FindSubAccount.company is 0>
									<!--- Fetch all of the regions. --->
								<cfquery name="dsGetRegions" datasource="#application.datasource#">
									select distinct substring(n_orgLevel2,7,len(n_orgLevel2)) as Region, i_OrgLevel2Code as RegionID from timecard.dbo.tbl_OrgLevels
									where i_OrgLevel1Code = #divid#
								</cfquery>
							</cfif> 
							<option value=""></option>		
							<cfoutput query="dsGetRegions">
								<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>Division_ID=#divid#&Region_ID=#RegionID#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
									<cfif (Region_ID eq RegionID)> 
										SELECTED
										<cfset regid = RegionID>
										<cfset regselected = 1>
									<cfelse> <cfset regselected = 0>
									</cfif>>
									Regional Rollup #Region#
								</option>
							</cfoutput>
							
							<cfif regselected is 1>
								<cfif ccllcAccess is 1>
									<cfoutput query="dsGetCCLLCHouses">
										<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=1&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
											<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 1)> 
												SELECTED
											</cfif>>
											#cName#
										</option>
									</cfoutput>
								</cfif>
								<option value=""></option>										
								<cfif FindSubAccount.company is 0>
										<!--- Fetch all of the enabled Houses. --->
									<cfquery name="dsGetHouses" datasource="#application.datasource#">
										SELECT
											cName,
											iHouse_ID AS GetHousesId,
											cGLSubAccount
										FROM dbo.House
										inner join timecard.dbo.tbl_OrgLevels o on o.i_OrgLevel3Code = substring(cGLsubaccount, 7,9)
										WHERE dtRowDeleted IS NULL AND bIsSandbox = 0 and o.i_OrgLevel2Code = #regid#
										<cfif isDefined("RDOrestrict")>
										AND iOpsArea_ID = #RDOrestrict#
										</cfif>
										ORDER BY
											cName;
									</cfquery>
								</cfif>
		
								<cfoutput query="dsGetHouses">
									<option value="location.href='#cgi.SCRIPT_NAME#?Role=<cfif IsDefined('url.Role')>#url.Role#&<cfelse>0&</cfif><cfif isDefined("url.NumberOfMonths")>NumberOfMonths=#url.NumberOfMonths#&<cfelse>NumberOfMonths=3&</cfif>ccllcHouse=0&iHouse_ID=#GetHousesId#&SubAccount=#cGLSubAccount#<cfif dateToUse Is Not "">&DateToUse=#DateFormat(dateToUse, "mmmm yyyy")#</cfif>'"
										<cfif (iHouse_ID neq 0) and (iHouse_ID eq GetHousesId) and (ccllcHouse eq 0)> 
											SELECTED
										</cfif>>
										#cName#
									</option>
								</cfoutput>
							</cfif>
						</cfif>
						
					</select>--->
