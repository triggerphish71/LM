<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 08/13/2007 | Created                                                            |
| ranklam    | 08/13/2007 | Change linke to new assessment tool.                               |
| jcruz		 | 03/07/2008 | Change links to the new assessment tool so they do not start a new |
|            |            | Assessment making user locate person on inquiry list.			   |
| jcruz		 | 03/18/2009 | Modified Registered query to include residents moved via the STAR  |
|			 |			  | Application.													   |
-----------------------------------------------------------------------------------------------|
| Sfarmer    | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking    |
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates           |
|            |            | allow adjustment of rates by all regions                           |
|S Farmer    | 09/08/2014 | 116824 - Allow all houses edit BSF and Community Fee Rates         |
|S Farmer    | 03/08/2016 | change deleted and previous tenant links to be accessible by AR/IT |
|            |            | only                                                               |
| M Shah     | 06/30/2016 | Added traiing document link Moveinhelp pdf                         |
----------------------------------------------------------------------------------------------->
<cfif isDefined("form.previoustenants")>
<cfset form.previoustenants=1>
<!---  <cfoutput>form.previoustenants: #form.previoustenants#</cfoutput>  --->
</cfif>

<!--- Include intranet Header --->
<cfinclude template="../../header.cfm">

<cfif isDefined("form.Deleted")>
 
	<!--- Query for   applicants --->
	<cfquery NAME="registered" DATASOURCE="#APPLICATION.datasource#">
	select t.*, TC.cDescription, ts.iTenantStateCode_ID, ts.dtMoveOut, ts.iResidencyType_ID, ts.dtMoveIn, rt.cDescription Residency
		, (select count(distinct iassessmenttoolmaster_id) from assessmenttoolmaster am
		join assessmenttool ast on ast.iassessmenttool_id = am.iassessmenttool_id and ast.dtrowdeleted is null 
<!--- 		left	  join #Application.LeadTrackingDBServer#.LeadTracking.dbo.resident r on r.iresident_id = am.iresident_id and r.dtrowdeleted is null
 where am.dtrowdeleted is null  and (am.itenant_id = t.itenant_id or am.iresident_id = r.iresident_id) and am.bfinalized is not null 
 --->
 	where am.dtrowdeleted is null  and am.itenant_id = t.itenant_id  and am.bfinalized is not null 
		and am.bbillingactive = 1) toolcount
	from tenant t 
		join tenantstate ts on t.iTenant_ID = ts.iTenant_ID
	  <!--- and	t.dtRowDeleted is not null --->
	   and ts.dtRowDeleted is not null  
		and t.bIsMedicaid is null
		and	t.bIsMisc is null and t.bIsDayRespite is null and ts.iTenantStateCode_ID = 1
	left	join RESIDENCYTYPE RT on ts.iResidencyType_ID = Rt.iResidencyType_ID
		join TenantStateCodes TC on ts.iTenantStateCode_ID = TC.iTenantStateCode_ID
	where t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>

<cfelse>
 
	<cfscript>
		if (isDefined("form.DayRespite") and isDefined("form.PreviousTenants") ) 
			{ filter="and (TS.iResidencyType_ID = 4 or ts.iTenantStateCode_ID = 4)"; }
		else if (isDefined("form.PreviousTenants") or (isDefined("url.PreviousTenants") 
			and url.PreviousTenants eq 'Checked') and NOT isDefined("form.DayRespite") ) 
			{ filter="and ts.iTenantStateCode_ID = 4"; }
		else if (isDefined("form.DayRespite") and NOT isDefined("form.PreviousTenants") )
			{ filter="and (TS.iResidencyType_ID = 4 and t.iHouse_ID =" &  SESSION.qSelectedHouse.iHouse_ID & ")"; }
		else { filter="and ts.iTenantStateCode_ID = 1";	}
		
		if (NOT isDefined("url.SortOrder") ) { sort="order by t.dtRowStart DESC"; }
		else if (URL.SortOrder eq "TenantID") { sort="order by t.cSolomonKey"; }
		else if (URL.SortOrder eq "Name") { sort="order by t.cLastName"; }
		else if (URL.SortOrder eq "Status") { sort="order by ts.iTenantStateCode_ID"; }
		else if (URL.SortOrder eq "MoveIn") { sort="order by ts.dtMoveIn"; }
		else { sort="order by t.dtRowStart DESC"; }
	</cfscript>
	<cfquery name="qHouse" datasource="#APPLICATION.DataSource#">
	select iOpsArea_ID from House H (NOLOCK)
	join  HouseLog HL (NOLOCK) ON (H.iHouse_ID = HL.iHouse_ID AND HL.dtRowDeleted IS NULL 
	AND H.dtRowDeleted IS NULL)
	where H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>
<!--- Query for Applicants Modified 03/21/09 by Jaime Cruz as part of Project 18506 --->
	<cfquery name="registered" datasource="#APPLICATION.datasource#">
	select t.itenant_id ,t.csolomonkey ,t.cfirstname ,t.clastname ,t.dtrowdeleted ,t.BAPPFEEPAID
		,TC.cDescription ,TS.iTenantStateCode_ID ,TS.dtMoveOut ,TS.iResidencyType_ID 
		,TS.dtMoveIn ,RT.cDescription as Residency, 0 as iResident_ID
		, (select count(distinct iassessmenttoolmaster_id) from assessmenttoolmaster am
		where am.dtrowdeleted is null and am.itenant_id = t.itenant_id 
		and am.bbillingactive = 1) toolcount
	from tenant t
	join tenantstate ts on (t.iTenant_ID = ts.iTenant_ID and ts.dtRowDeleted is null)
	join residencytype RT on (TS.iResidencyType_ID = rt.iResidencyType_ID and rt.dtRowDeleted is null)
	join TenantStateCodes TC on (TS.iTenantStateCode_ID = TC.iTenantStateCode_ID 
	and TC.dtRowDeleted is null)
	where t.dtRowDeleted is null and t.bIsMedicaid is null and t.bIsMisc is null
	and t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	#filter# 
	
	<cfif isDefined("sort")>#sort#</cfif>
	</cfquery>
</cfif>

<!--- retrieve access right for assess tool --->
<cfinclude template="../../AssessmentTool/toolaccess.cfm">

<cfscript>
	// dayrespite chosen
	if (isDefined("form.dayrespite") or isDefined("Url.DayRespite") and Url.DayRespite eq "Checked")
	 { DR = "Checked"; }
	else { DR = "UnChecked"; }
	
	// previous residents chosen
	if (isDefined("form.previoustenants") or isDefined("Url.PreviousTenants") and Url.PreviousTenants eq "Checked") {
		PT = "Checked"; }
	else { PT = "UnChecked"; }
	
	// deleted residents chosen
	if (isDefined("form.Deleted") or isDefined("Url.Deleted") and Url.Deleted eq "Checked") { DL = "Checked"; }
	else { DL = "UnChecked"; }
</cfscript>

<script>
	function assessredirect(str) {
		if ( confirm("An assessment needs to be completed and activated for this resident before the move in may be started.\rWould you like to do this now?") == true) {
		loc="../../AssessmentTool_V2/index.cfm?fuse=assessmentMain"; self.location.href=loc;
		}
		//else if (confirm("Continue the move in process?") == true) { loc="../MoveIn/MoveInForm.CFM?ID="+str; self.location.href=loc; }
	}
</script>
<!---<script>
	function showHelp(){
 		window.open("../MoveIn/TIPS-Move-In-Process.pdf");
	}
</script> mshah commented to change the link --->
 
<header>
<title>	TIPS 4 - Register Applicant</title>
<cfif isDefined("form.previoustenants")>
<link rel="stylesheet" type="text/css" href="../Shared/Style3.css">
<style>
body{background:transparent; font-size:x-small; }
.househeader { font-size: small; }
.pagetitle { font-size: small; }
</style>
</cfif>
</header>
<!--- Display the page title. --->
<table style="border:none;">
<tr>
<td>
<h1 class="PageTitle"> Tips 4 - Registered Applicants </h1>

</td>

<td colspan="2">
Need help with a Move In? Select here:&nbsp;&nbsp; <a href="HelpwithMoveInProcess.pdf" target="new"> <img src="../../images/Move-In-Help.jpg" width="25" height="25"/> <a/>
</td>
</tr>
</table>

<cfinclude template="../Shared/HouseHeader.cfm">
<br>
 

<cfform action="registration.cfm" method="post"> 
<cfoutput>
 
	<table class="noborder">
 
		<cfif isDefined("form.previoustenants")>
		<tr><td class="topleftcap" colspan="50%"></td><td class="toprightcap"></td></tr>
		</cfif>	
		<cfif not isDefined("url.previoustenants")>
			<tr>
			<cfif NOT isDefined("form.Deleted")>
				<td class="hlinks" style="background: ##eaeaea;"> 
					<input type="checkbox" name="DayRespite" value="" 
					onClick="submit();" #variables.DR#> 
					Show Day Respite 
				</td>
				<!--- <cfif (ListFindNoCase(SESSION.CodeBlock,25) GT 0) > --->				
					<td class="hlinks" style="background: ##eaeaea;"> 
						<input type="checkbox" name="previoustenants" value="" 
						onClick="submit();"	#variables.PT#>
						Show Previous Tenants 
					</td>
				<!--- </cfif> --->
			</cfif>			
			<cfif  (ListFindNoCase(SESSION.CodeBlock,25) GT 0)>
				<TD class="hlinks" style="background: ##eaeaea;"> 
				<input type="checkbox" name="Deleted" value="" onClick="submit();" #variables.DL#>	
				Show Deleted Applicants
				</td>		
		</cfif>
			</tr>	
			<tr>
				<td colspan="4" class="Required" STYLE="font-size: small; Background: white;"> 
				Please, Click on the Tenant's name to begin the Move In process.
				</td>
			</tr>
		</cfif>
		<!---	<tr>
				<td colspan="4">
				Need help with a Move In? Select here: &nbsp;&nbsp;
				<img src="../../images/Move-In-Help.jpg" width="25" height="25" 
						onclick="showHelp();" />
				</td>
			</tr> mshah commented this to create new link --->		
		
	</table>

<table>
<cfif IsDefined("form.previoustenants") and form.previoustenants is 1>
	<tr>
		<th style="color: Blue;">Edit</th>
		<th style="color: Blue;">Care</th>
		<th style="color: Blue;">Resident</th>
		<th style="color: Blue;">ResidentID</th>
		<th style="color: Blue;">Status</th>
		<th style="color: Blue;"> Moved Out </th>		
		<th style="color: Blue;">App Fee</th>
		<th style="color: Blue;">Move-In</th>
		<th>&nbsp;</th>
	</tr>
	<cfelse>
	<tr>
		<th>Edit</th>
		<th>Care</th>
		<th><a href="?SortOrder=Name&dayrespite=#Dr#&previoustenants=#PT#" style="color: White;">
		 Resident </a></th>
		<th><a href="?SortOrder=TenantID&previoustenants=#PT#&dayrespite=#Dr#" style="color: White;">
		 ResidentID </a></th>
		<th><a href="?SortOrder=Status&previoustenants=#PT#&dayrespite=#Dr#" style="color: White;">
		 Status </a></th>
		<cfif isDefined("form.PreviousTenants") or (isDefined("url.PreviousTenants") 
			and url.PreviousTenants eq 'Checked')>
			<th> Moved Out </th>		
		</cfif>
		<th><a href="?SortOrder=fee&previoustenants=#PT#&dayrespite=#Dr#" style="color: White;">
		App Fee</a>
		</th>
		<th><a href="?SortOrder=MoveIn&previoustenants=#PT#&dayrespite=#Dr#" style="color: White;">
		Move-In</a> 
		</th>
		<th> Delete </th>
	</tr>
	</cfif>
</cfoutput>

<cfoutput query = "Registered">	
	<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
		<cfscript>
			if (Registered.dtMoveIn NEQ '') { proposed="style='color: blue;' 
			onMouseOver=this.style.color='white'; onMouseOut=this.style.color='blue';"; } 
			else { proposed=""; }
		</cfscript>
			
		<td>
			<a href="../Tenant/TenantEdit.cfm?ID=#registered.iTenant_ID#">[Edit]</a>&nbsp;&nbsp;
		</TD>
		<cfif listfindnocase(toollist,session.qselectedhouse.cnumber,",") gt 0>	
			<td><a href="../../AssessmentTool_v2/index.cfm?fuse=assessmentMain">
				<img src="assess.gif" border="0" align="top" 
				onMouseOver="src='o_assess.gif'" onMouseOut="src='assess.gif'"></a>
			</td>
		</cfif>
 
			<td class="Name">
 				<cfif Registered.toolcount eq 0>
					<a onclick="assessredirect(#registered.itenant_id#)"> 
					<u> #registered.cLastName#, #registered.cFirstName#</u></a>
 
				<cfelseif IsDefined("form.previoustenants") and form.previoustenants is 1 
					and(ListFindNoCase(SESSION.CodeBlock,25) GT 0)>
						<a href="../MoveIn/MoveInForm.CFM?ID=#registered.iTenant_ID#"  #proposed#>
						 #registered.cLastName#, #registered.cFirstName#</a>
				<cfelseif IsDefined("form.previoustenants") and form.previoustenants is 1 >
					#registered.cLastName#, #registered.cFirstName#					
				<cfelse>
					  <a href="../MoveIn/MoveInForm.CFM?ID=#registered.iTenant_ID#"  #proposed#>
						 #registered.cLastName#, #registered.cFirstName#</a>  
  				
				</cfif>
			</td>
 
		<td> #registered.cSolomonKey# </td>
		<td>	
			<cfif Registered.iTenantStateCode_ID eq 4> 
				#registered.cDescription# 
			<cfelseif Registered.iTenantStateCode_ID eq 1>	
				#registered.cDescription# 
			</cfif>
		</td>
		<cfif isDefined("form.PreviousTenants") or (isDefined("url.PreviousTenants") 
			and url.PreviousTenants eq 'Checked')>
			<td nowrap>
			<a href="../MoveOut/MoveOutFormSummary.cfm?ID=#Registered.iTenant_ID#">
			 #DateFormat(Registered.dtMoveOut, "mm/dd/yyyy")# </a>
				<br/>
			 <cfif (ListContains(session.groupid,'285') gt 0)>
				<input type="Button" name="Addendum" value="Addendum" 
				style="width: 60px; font-size: xx-small; color: blue;" 
				onClick="location.href='MoveOutAddendum.cfm?ID=#Registered.iTenant_ID#'">
			 </cfif>	
			</td>		
		</cfif>
		<td><cfif Registered.bAppFeePaid GT 0> Charged </cfif></td>
		<td>#DateFormat(Registered.dtMoveIn, "mm/dd/yyyy")#</td>
		<td style="text-align: center;">
		<cfif Registered.dtMoveOut eq "" and Registered.iTenantStateCode_ID eq 1 
			and Registered.dtRowDeleted eq "">
			<input type="Button" name="Delete" value="Delete Now" 
			style="width:'70px'; height:'20px'; font-size: xx-small; color: red;" 
			onClick="location.href='DeleteTenant.cfm?ID=#Registered.iTenant_ID#'">
		<cfelseif (ListFindNoCase(SESSION.CodeBlock,25) GT 0) >	
				<input type="Button" name="UnDelete" value="UnDelete" 
				style="width:'70px'; height:'20px'; font-size: xx-small; color: blue;" 
				onClick="location.href='UnDeleteTenant.cfm?ID=#Registered.iTenant_ID#'">	
		</cfif>
		</td>
	</cf_cttr>
</cfoutput>
	<cfif isDefined("form.previoustenants")>
	<tr><td class="bottomleftcap" colspan="4"></td><td class="bottomrightcap" colspan="5"></td></tr>
	</cfif>
</table>

</cfform>
  <!--- <cfdump var="#session#"> --->  
<!--- Include Intranet Footer --->
<cfinclude template="../../footer.cfm"> 