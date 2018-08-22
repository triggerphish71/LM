<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Census.cfm                                                                                   |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 05/02/2006 | Added Flowerbox                                                      |
| mlaw       | 01/23/2007 | exclude Move-In Tenants after census date                            |
| mlaw       | 03/05/2007 | Modify query checkdailycensustrack, checkdailycensus                 |
| sfarmer    | 03/10/2014 | Removed ts.dtMoveIn <= '#CompareDate#' due to use of future move-ins |
| Mshah      | 03/29/2017 | Added Edit census                                                    |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                  |
| gthota     | 2017-09-05 | Relocated residents census report                       |
------------------------------------------------------------------------------------------------->
<cfif NOT isDefined("session.UserID")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<!--- Display the page title. --->
<!---<h1 class="PageTitle"> Tips 4 - Census </h1>--->

<table style="border:none;">
<tr>
<td>
<h1 class="PageTitle"> Tips 4 - Census </h1>

</td>

<td colspan="2">
Tips for Census Validation- Select here:&nbsp;&nbsp; <a href="Tips for TIPS- Census Validation.pdf" target="new"> <img src="../../images/Move-In-Help.jpg" width="25" height="25"/> <a/>
</td>
</tr>
</table>

<!--- Include the page for house header --->
<cfinclude template="../Shared/HouseHeader.cfm">

<!--- Set Previous Date --->
<cfset BeginDate = #DateFormat(dateadd("d", -1, now()), "mm/dd/yyyy")#>  <!--- ganga -1  --->

<!--- Set visiable link --->
<cfset validate_process = 'true'>
<cfset approve_process = 'true'>
<cfparam name="ApprovalFlag" default="true">

<!--- check to see if there is any daily census record in the system --->
<!--- Set Census_Date, NewCensus_Date, Report_Date --->
<cfquery name="checkdailycensustrack" datasource="#application.datasource#">
	select 
		Top 1 
		max(Census_Date) as Census_Date
		, Census_Date + 1 as NewCensus_Date
		, Census_Date + 2 as Report_Date
	from 
		dailycensustrack dct
	join 
		tenant t
		on t.itenant_ID = dct.itenant_ID
	join
		tenantstate ts
		on ts.itenant_ID = t.itenant_ID
	where 
		ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	  and
	  	ts.itenantstatecode_id = 2
	  and
	  	t.dtrowdeleted is NULL
	  and
	  	ts.dtrowdeleted is NULL
	  and
	    dct.dtrowdeleted is NULL	
	group by 
       Census_Date + 1
      ,Census_Date + 2
	order by
		census_date desc
</cfquery>	
<cfset lc = #checkdailycensustrack.recordcount#>

<!--- check to see if there is any approval census record in the system --->
<!--- Set Census_Date, Approve_Date --->
<cfquery name="checkdailycensus" datasource="#application.datasource#">
	select 
		Top 1 
		max(Census_Date) as Census_Date
		, Census_Date + 1 as Approve_Date
	from 
		dailycensus dc
	where 
		ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	  and
	    dtrowdeleted is NULL	
	group by 
       Census_Date + 1
	order by
		census_date desc
</cfquery>	

<!--- gthota  code start  --->
<!--- check to see if there is any daily census record in the system --->
<!--- Set Census_Date, NewCensus_Date, Report_Date --->
<cfquery name="checkdailycensustrack_rl" datasource="#application.datasource#">
	select 
		Top 1 
		max(Census_Date) as Census_Date
		, Census_Date + 1 as NewCensus_Date
		, Census_Date + 2 as Report_Date
	from 
		dailycensustrack_rl dct
	join tenant t	on t.itenant_ID = dct.itenant_ID
	join tenantstate ts 	on ts.itenant_ID = t.itenant_ID
	where 
		dct.rl_tohouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	 
	  and	  	t.dtrowdeleted is NULL
	  and	  	ts.dtrowdeleted is NULL
	  and	    dct.dtrowdeleted is NULL	
	group by 
       Census_Date + 1      ,Census_Date + 2
	order by
		census_date desc
</cfquery>	
<cfset lc = #checkdailycensustrack_rl.recordcount#>

<cfquery name="checkdailycensus_RL" datasource="#application.datasource#">
	select 
		Top 1 
		max(Census_Date) as Census_Date
		, Census_Date + 1 as Approve_Date
	from 
		dailycensus_RL dc
	where 
		RL_ToHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	  and
	    dtrowdeleted is NULL	
	group by 
       Census_Date + 1
	order by
		census_date desc
</cfquery>	
<!---
<cfset approve_process_rl = 'true'>
<cfif checkdailycensus_RL.recordcount GT 0> 
<cfset approve_process_rl = 'false'>
</cfif>  --->

<!--- if there is no daily census record then set Comparedate = yesterday & reportdate = today --->
<!--- or #SESSION.qSelectedHouse.iHouse_ID# is 134 for when Hillside gets behind --->
 <cfif #checkdailycensustrack.recordcount# eq 0 >
	<!--- then use current day to set variables for CompareDate, ReportDate --->
  	<cfset CompareDate = #DateFormat(dateadd("d", -1, now()), "mm/dd/yyyy")#>
  	<cfset ReportDate = #DateFormat(Now(),'mm/dd/yyyy')#>
<cfelse>
	<!--- if there is no approval record then set Comparedate = checkdailycensustrack.Census_Date &	reportdate = checkdailycensustrack.Report_Dat --->
	<cfif #checkdailycensus.recordcount# eq 0>
		<!--- then use checkdailycensustrack.census_date, checkdailycensustrack.report_date to set variables for CompareDate, ReportDate --->
		<cfset CompareDate = #DateFormat(checkdailycensustrack.Census_Date,'mm/dd/yyyy')#>
		<cfset ReportDate = #DateFormat(checkdailycensustrack.Report_Date,'mm/dd/yyyy')#>
	<cfelse>
		<!-- else use the BeginDate(today - 1) to compare with dailycensus.census_date --->
		<cfif BeginDate neq #checkdailycensustrack.Census_Date#>
			<!--- then use dailycensus.newcensus_date, dailycensus.report_date to set variables for CompareDate, ReportDate --->
			<cfset CompareDate = #DateFormat(checkdailycensustrack.NewCensus_Date,'mm/dd/yyyy')#>
			<cfset ReportDate = #DateFormat(checkdailycensustrack.Report_Date,'mm/dd/yyyy')#>
		<cfelse>
			<!--- else use the (today - 1) and today to set variables for CompareDate, ReportDate --->
			<cfset CompareDate = #BeginDate#>
			<cfset ReportDate = #DateFormat(Now(),'mm/dd/yyyy')#>
		</cfif>
	</cfif>
</cfif> 
<!---   <cfif session.username is 'sfarmer'>
<cfoutput>,#checkdailycensus.recordcount#,<cfdump label="CompareDate" var="#CompareDate#"></cfoutput>
</cfif>   --->
<!--- Get all the Permenant leave tenants but have not entered in TIPS system --->
<cfquery name="getpermtenants" datasource="#application.datasource#">
	select 
		dtMoveOut, t.itenant_ID, t.cfirstname, t.clastname
	from
		dailycensustrack d
	join tenant t
		on t.itenant_ID = d.itenant_ID
	join 
		tenantstate ts
	 	on ts.itenant_ID = t.itenant_ID
	join
		leavestatus ls
		on ls.ileavestatus_ID = d.ileavestatus_ID
	join
		leavestatusmaster lsm
		on lsm.ileavetype_ID = ls.ileavetype_ID
	where 
		t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	and
		ts.itenantstatecode_id not in (3,4)
	and 
		t.dtrowdeleted is NULL
	and
		ts.dtrowdeleted is NULL
	and
		d.census_date = '#checkdailycensustrack.Census_Date#'
	and
		d.currentstatusinbedatmidnight = 'N'
	and
		lsm.ileavetype_ID = 2
</cfquery>	

<cfif #getpermtenants.recordcount# gt 0>
	<table>
		<cfloop query="getpermtenants">
			<tr>
				<td>
					Incomplete MoveOut Tenant:
					<font color="#990066">
						<cfoutput>
							#cfirstname# #clastname#  
						</cfoutput>
					</font>
				</td>
			</tr>
		</cfloop>
		<!---
		<cfset approve_process = 'true'>
		<cfset validate_process = 'true'>
		<cfset ApprovalFlag = "true"> 
		--->
	</table>
</cfif>

<!--- gthota code for rl tenants approval process  --->
<!--- Get all the Permenant leave tenants but have not entered in TIPS system --->
<cfquery name="getpermtenants_rl" datasource="#application.datasource#">
	select 
		d.itenant_ID, t.cfirstname, t.clastname
	from
		dailycensustrack_RL d
	join tenant t		on t.itenant_ID = d.itenant_ID
	join	leavestatus ls	on ls.ileavestatus_ID = d.ileavestatus_ID
	join	leavestatusmaster lsm	on lsm.ileavetype_ID = ls.ileavetype_ID
	where 
		d.rl_tohouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	
	and 		d.dtrowdeleted is NULL	
	and		d.census_date = '#checkdailycensustrack.Census_Date#'
	and		d.currentstatusinbedatmidnight = 'N'	
</cfquery>	

<cfset approve_process_rl = 'false'>
<cfif getpermtenants_rl.recordcount GT 0>
<cfset approve_process_rl = 'true'>
<cfset ApprovalFlag = "true"> 
</cfif>


<!--- gthota code end here.  --->  

<!--- get all the permanent leave tenants but they did not finish the MoveOut --->
<cfquery name="getpermleavetenants" datasource="#application.datasource#">
	select 
		dtMoveOut, t.itenant_ID, t.cfirstname, t.clastname
	from
		tenant t
	join 
		tenantstate ts
	 	on ts.itenant_ID = t.itenant_ID
	where 
		t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	and
		ts.itenantstatecode_id not in (3,4)
	and
		ts.dtMoveOut <> ''
	and 
		t.dtrowdeleted is NULL
	and
		ts.dtrowdeleted is NULL
</cfquery>	
<cfif #getpermleavetenants.recordcount# gt 0 and #checkdailycensustrack.recordcount# gt 0>
	<table>
	<tr>	
		<cfloop query="getpermleavetenants">
			<!--- IF The MoveOut date is greater than Validate Census Date then set this tenant to be in house --->
			<cfif CompareDate LTE dtMoveOut>
				<tr>
					<td>
						Reminder: <font color="#990066"><cfoutput>#cfirstname# #clastname#</cfoutput></font>'s Expected Physical Move Out date is <font color="#990066"><cfoutput>#DateFormat(dtMoveOut,'mm/dd/yyyy')#</cfoutput></font>.						
					</td>
				</tr>
				<cfquery name="DeleteCensusTrack" datasource="#application.datasource#">
					delete from DailyCensusTrack
					where 
						itenant_ID = #itenant_ID#
					and 
						census_date = '#checkdailycensustrack.Census_Date#'
				</cfquery>			  
				<cfquery name="insertDailyCensusTrack" datasource="#application.datasource#">		
					insert into DailyCensusTrack 
					(
						iTenant_ID
						, iLeaveStatus_ID
						, Census_Date
						, DischargeDate
						, CurrentStatusinBedAtMidnight
						, TempStatusOutDate
						, iRowStartUser_ID
						, dtRowStart
						, cRowStartUser_ID
					)
					values 
					(
						#itenant_ID#
						, 0
						, '#checkdailycensustrack.Census_Date#'
						, '#dtMoveOut#' 
						, 'Y'
						, ''				
						, #SESSION.UserID#
						, getdate()
						, 'Census'
					)			
				</cfquery>				
			<cfelse>
			<!--- else display the Pending MoveOut Tenants--->
				<tr>
					<td>
						<font color="#990066"><cfoutput>#cfirstname# #clastname#</cfoutput></font>'s Physical Move Out date is past due.
					</td>
				</tr>
				<cfquery name="DeleteCensusTrack" datasource="#application.datasource#">
					delete from DailyCensusTrack
					where 
						itenant_ID = #itenant_ID#
					and 
						census_date = '#checkdailycensustrack.Census_Date#'
				</cfquery>			  
				<cfquery name="insertDailyCensusTrack" datasource="#application.datasource#">		
					insert into DailyCensusTrack 
					(
						iTenant_ID
						, iLeaveStatus_ID
						, Census_Date
						, DischargeDate
						, CurrentStatusinBedAtMidnight
						, TempStatusOutDate
						, iRowStartUser_ID
						, dtRowStart
						, cRowStartUser_ID
					)
					values 
					(
						#itenant_ID#
						, 0
						, '#checkdailycensustrack.Census_Date#'
						, '#dtMoveOut#' 
						, 'Y'
						, ''				
						, #SESSION.UserID#
						, getdate()
						, 'Census'
					)			
				</cfquery>	
			</cfif>
		</cfloop>
	</tr>
	</table>
</cfif>

<!--- get all the potential leave tenants but they did not start any MoveOut --->
<cfquery name="getpotentialleavetenants" datasource="#application.datasource#">
	select 
		dischargeDate
		, t.cfirstname
		, t.clastname 
	from 
		dailycensustrack d
	join tenant t
	on t.itenant_ID = d.itenant_ID
	where 
		t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		and Census_Date = '#checkdailycensustrack.Census_Date#'
		and (d.DischargeDate <> '' and d.DischargeDate < '#checkdailycensustrack.Census_Date#')
		and d.itenant_ID not in 
		(
			select 
				t.itenant_ID
			from
				tenant t
			join 
				tenantstate ts
			 	on ts.itenant_ID = t.itenant_ID
			where 
				t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and
				ts.itenantstatecode_id not in (3,4)
			and
				ts.dtMoveOut <> ''
			and 
				t.dtrowdeleted is NULL
			and
				ts.dtrowdeleted is NULL
		)
</cfquery>
<cfif #getpotentialleavetenants.recordcount# gt 0>
	<table>
		<tr>	
			<cfloop query="getpotentialleavetenants">
			<tr>
				<td>
					<font color="#990066"><cfoutput>#cfirstname# #clastname#</cfoutput></font>'s estimated Expected Physical Move Out date is past due.
				</td>
			</tr>
			</cfloop>
		</tr>
	</table>
</cfif>

<!--- if there is no approval record and no daily census record, then users can only do validate daily census --->
<cfif (#checkdailycensustrack.recordcount# eq 0) and (#checkdailycensus.recordcount# eq 0)>
	<table>
		<td>
			<font color = red>
			<b>Please process the Validate Daily Census screen. </b>
			</font>
		</td>
	</table>
  	<cfset approve_process = 'false'>
	<cfset validate_process = 'true'>
	<cfset ApprovalFlag = "false">
<cfelse>
	<!--- Daily Census completed message --->
	<cfif #checkdailycensustrack.Census_Date# eq #checkdailycensus.Census_Date#>
		<table>		
			<td>
				<font color = red>
					<b>Daily Census is completed for <cfoutput> #DateFormat(checkdailycensus.Census_Date,'mm/dd/yyyy')#</cfoutput> </b>
				</font>
			</td>
		</table>
       	<cfset approve_process = 'false'>
		<cfset ApprovalFlag = "false">
	</cfif>
</cfif>

<!--- Gthota - code for approval process 09/07/2017  --->
<!--- get all the potential leave tenants but they did not start any MoveOut --->
<cfquery name="getpotentialleavetenants_rl" datasource="#application.datasource#">
	select 
		dischargeDate
		, t.cfirstname
		, t.clastname 
	from 
		dailycensustrack_RL d
	join tenant t	on t.itenant_ID = d.itenant_ID
	where 
		d.rl_tohouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		and Census_Date = '#checkdailycensustrack_rl.Census_Date#'
		and (d.DischargeDate <> '' and d.DischargeDate < '#checkdailycensustrack_rl.Census_Date#')
		
</cfquery>
<cfif #getpotentialleavetenants_rl.recordcount# gt 0>
	<table>
		<tr>	
			<cfloop query="getpotentialleavetenants_rl">
			<tr>
				<td>
					<font color="#990066"><cfoutput>Relocated resident #cfirstname# #clastname#</cfoutput></font>'s estimated Expected Physical Move Out date is past due.
				</td>
			</tr>
			</cfloop>
		</tr>
	</table>
</cfif>

<!--- gthota - approval process end  --->

<!--- checkmissingdailycensustrack --->
<cfif #checkdailycensustrack.recordcount# gt 0>
	<cfquery name="checkmissingdailycensustrack" datasource="#application.datasource#">
		select 
			dct.itenant_ID 
		from 
			dailycensustrack dct
		 join
		 	tenant t
			on t.itenant_ID = dct.itenant_ID
		where 
			t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		and
			census_date = '#CompareDate#'
	</cfquery>
	<cfif #checkmissingdailycensustrack.recordcount# gt 0>
		<cfquery name="getmissingdailycensustrack" datasource="#application.datasource#">
			select t.cFirstName, t.cLastName 
			from 
				tenant t
			join
				tenantstate ts
				on ts.itenant_ID = t.itenant_ID
			where 
				t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and 
				ts.itenantstatecode_id = 2
			and 
				t.dtrowdeleted is NULL
			and 
				t.itenant_ID not in 
				(
				select 
					dct.itenant_ID 
				from 
					dailycensustrack dct
				join
				 	tenant t
					on t.itenant_ID = dct.itenant_ID
				where 
					t.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
				and
					census_date = '#CompareDate#'
			)
		</cfquery>
		<cfif #getmissingdailycensustrack.recordcount# gt 0>
			<table>
				<td>
					<font color = red>
					<b>Validate Daily Census is not completed, please re-validate it.
						
					</b>
					</font>
				</td>
			</table>
			<cfset approve_process = 'false'>
			<cfset ApprovalFlag = "false">
		</cfif>
	</cfif>
</cfif>

<!--- if there is no approval census record --->
<cfif #checkdailycensus.recordcount# eq 0>
	<!--- if there is daily census record --->
	<cfif #checkdailycensustrack.recordcount# gt 0>
		<!--- set Census Approval Date to be same as daily census date --->
		<cfset censusapprovedate = #DateFormat(checkdailycensustrack.Census_Date,'mm/dd/yyyy')#>
	<cfelse>
		<!--- else set Census Approval Date to be Compare Date --->
	    <cfset censusapprovedate = #CompareDate#>
	</cfif>
<cfelse>
	<!--- if there is an approval census record --->
	<!--- use the BeginDate(today - 1) to compare with dailycensus.census_date --->
	<cfif BeginDate neq #checkdailycensus.Census_Date#>
		<!--- set census approval date to be same as daily census approve date (censusdate + 1) --->
	   	<cfset censusapprovedate = #DateFormat(checkdailycensus.Approve_Date,'mm/dd/yyyy')#>
	<cfelse>
		<!--- else set census approval date to be same as BeginDate(today - 1) --->
		<cfset censusapprovedate = #BeginDate#>
	</cfif>
	<!--- if CompareDate - Census Approval Date > 0 --->
	<cfif (#CompareDate# - #censusapprovedate#) gt 0>
		<cfif ApprovalFlag >
			<table>
				<td>
					<font color = red>
					<b>Please process the Daily Census Approval. </b>
					</font>
				</td>
			</table>
		</cfif>
		<!--- Validate Daily Census Approval date will stay the same --->
		<cfset CompareDate = #censusapprovedate#>
	</cfif>
</cfif>


<cfoutput>

<table>
	<tr>
		<!--- MLAW added DailyCensusReport 05/02/2006 --->
		<form name="DailyCensusReport" action="../census/DailyCensusReport.cfm" method="POST">									
			<td style="width: 25%;">
				Daily Census Report
			</td>
		  	<td style="width: 50%;" colspan=2>
				<input type="TEXT" name="dtCompare" value="#ReportDate#">&nbsp;&nbsp;
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
		</form>
	</tr>
	<tr>
		<cfif #validate_process# eq 'true'>
			<!--- MLAW added ValidateDailyCensus 05/02/2006 --->
			<form name="ValidateDailyCensus" action="../census/ValidateDailyCensus.cfm" method="POST">									
				<td style="width: 25%;">
					Validate Daily Census
				</td>
				<td style="width: 50%;" colspan=2>
					<input name="dtCompare" type="text" value="#CompareDate#" readonly="true">&nbsp;&nbsp;
					<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
				</td>
			</form>
		</cfif>
	</tr>	
	<tr>
		<cfif #approve_process# eq 'true'>
			<!--- MLAW added Daily Census Approve/Disapprove to approve or disapprove tenants in a house 05/02/2006 --->
			<form name="HouseApproveDisapprove" action="../census/HouseApproveDisapprove.cfm" method="POST">									
				<td style="width: 25%;">
					Daily Census Approval
				</td>
				<td style="width: 50%;" colspan=2>
					<input name="dtCompare" type="text" value="#censusapprovedate#" readonly="true">&nbsp;&nbsp;
					<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height:20px; width: 30px;" onClick="submit(); return false;">
				</td>
			</form>
		</cfif>
	</tr>
	<tr>
		<form name="MonthlyCensusReport" action="../census/MonthlyCensusReport.cfm" method="POST">									
			<td style="width: 25%;">
				Monthly Census Report
			</td>
			<td style="width: 50%;" colspan=2>
				<input type="TEXT" name="dtCompare" value="#DateFormat(Now(),'yyyymm')#">&nbsp;&nbsp;
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
		</form>
	</tr>	
<!---Mshah added--->
<script>
function validate(){
	//alert('test')
	var x = document.EditDailyCensus.prompt0.value;
	var y = document.EditDailyCensus.prompt1.value;
	 //alert (y);
	//alert (x);
	if (x=='ALL')
		{ alert('Select Resident to edit census');
		
		}
	if (y=='')
	{ alert('Select month to edit census');
	
	}
	
	}
  

</script>
<!---<cfdump var="#session#"> add for ED.RDO and CSM--->
<!---<cfoutput>userishouse #Find('house',session.username)#</cfoutput>--->
<!---<cfif (ListContains(session.grouplist,'Accounting') gt 0) or (ListContains(session.groupList,'192') gt 0)> add more groups--->
<!--- Restrict the access to house account --->
<cfif(#Find('house',session.username)# eq 0) >
	<tr>
	<form name="EditDailyCensus" action="../census/residentEditCensus.cfm" method="POST">									
		<td style="width: 25%;">
			Edit Daily Census
		</td>
		<td style="width: 25%;">
			
			<cfquery name="Tenants" datasource="#application.datasource#">
				select *, (T.cLastName + ', ' + T.cFirstName) as FullName,rt.cdescription 
				from Tenant T (nolock)
				join TenantState TS (nolock)	ON T.iTenant_ID = TS.iTenant_ID
				join residencytype rt on ts.iresidencytype_ID=rt.iresidencytype_ID
				where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID =2
				order by cLastName
			</cfquery>
			
			<select name="prompt0">
				<option value="ALL"> Select Residents </option>
				<cfloop query="Tenants">
					<option value="#Tenants.itenant_ID#">#Tenants.FullName# (#Tenants.cdescription#) </option>
				</cfloop>
			</select>
		</td>
	<!---<cfoutput> day now-#Day(Now())# Last month #DateFormat(dateadd('m',-1,Now()),'mm/dd/yyyy')#</cfoutput>--->
	
		<td style="width: 50%;" colspan=2>
		   	<select name="prompt1" name="dtCompare" value="#DateFormat(Now(),'mmm-yyyy')#">  
		   			<option value=""> Select Month</option>
		   			<option value="#DateFormat(Now(),'mm/dd/yyyy')#"> #DateFormat(Now(),'mmm - yyyy')# </option>
		   			
		   		<cfif (ListContains(session.groupid,'285') gt 0)>  <!---IT an AR has previous 3 month access --->
		   				<option value="#DateFormat(dateadd('m',-1,Now()),'mm/dd/yyyy')#"> #DateFormat(dateadd('m',-1,Now()),'mmm - yyyy')# </option>
		   		        <option value="#DateFormat(dateadd('m',-2,Now()),'mm/dd/yyyy')#"> #DateFormat(dateadd('m',-2,Now()),'mmm - yyyy')# </option>
		   		 <cfelse>
			   			<cfif #Day(Now())# LTE 2 >
			   				<option value="#DateFormat(dateadd('m',-1,Now()),'mm/dd/yyyy')#"> #DateFormat(dateadd('m',-1,Now()),'mmm - yyyy')# </option>
			   			</cfif> 
			   	  </cfif>
		   	</select>&nbsp;&nbsp;
			<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onfocus = "validate();" onClick=" submit(); return false;">
		</td>
	</form>
	</tr>
</cfif>
<!---Mshah --->
</table>

<table> <tr>&nbsp;</tr></table>
<!--- if there is no approval record and no daily census record, then users can only do validate daily census --->
<cfif (#checkdailycensustrack_RL.recordcount# eq 0) and (#checkdailycensus_RL.recordcount# eq 0)>
	<table>
		<td>
			<font color = red>
			<b>Please process the Validate Daily Census screen. </b>
			</font>
		</td>
	</table>
  	<cfset approve_process = 'false'>
	<cfset validate_process = 'true'>
	<cfset ApprovalFlag = "false">
<cfelse>
	<!--- Daily Census completed message --->
	<cfif #checkdailycensustrack_rl.Census_Date# eq #checkdailycensus_rl.Census_Date#>
		<table>		
			<td>
				<font color = red>
					<b>Relocated Residents Daily Census is completed for <cfoutput> #DateFormat(checkdailycensus_rl.Census_Date,'mm/dd/yyyy')#</cfoutput> </b>
				</font>
			</td>
		</table>
       	<cfset approve_process_rl = 'false'>
		<cfset ApprovalFlag = "false">
	</cfif>
</cfif>
<!--- Ganga Thota addede code for tranfer residents only  --->
<cfquery name="checkhouse" datasource="#application.datasource#">
	select * from [dbo].[RL_RES_STG]	WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID# and active = 'Y'
</cfquery>	



 <CFIF #checkhouse.ToHouseID# EQ #SESSION.qSelectedHouse.iHouse_ID# >  
<table> <tr>&nbsp;</tr></table>
<font color = red>Relocated Residents from Other Community :</font>

<table>
	<tr>
		<!--- MLAW added DailyCensusReport 05/02/2006 --->
		<form name="DailyCensusReport" action="../census/DailyCensusReport_RL.cfm" method="POST">									
			<td style="width: 25%;">
				Daily Census Report
			</td>
		  	<td style="width: 50%;" colspan=2>
				<input type="TEXT" name="dtCompare" value="#ReportDate#">&nbsp;&nbsp;
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
		</form>
	</tr>
	<tr>
		<cfif #validate_process# eq 'true'>
			<!--- MLAW added ValidateDailyCensus 05/02/2006 --->
			<form name="ValidateDailyCensus" action="../census/ValidateDailyCensus_RL.cfm" method="POST">									
				<td style="width: 25%;">
					Validate Daily Census
				</td>
				<td style="width: 50%;" colspan=2>
					<input name="dtCompare" type="text" value="#CompareDate#" readonly="true">&nbsp;&nbsp;
					<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
				</td>
			</form>
		</cfif>
	</tr>	 
	<tr>
		
		 <cfif #approve_process_rl# eq 'true'> 
			<!--- MLAW added Daily Census Approve/Disapprove to approve or disapprove tenants in a house 05/02/2006 --->
			<form name="HouseApproveDisapprove" action="../census/HouseApproveDisapprove_RL.cfm" method="POST">									
				<td style="width: 25%;">
					Daily Census Approval
				</td>
				<td style="width: 50%;" colspan=2>
				  <input name="ihouseid" type="hidden" value ="checkhouse.FromHouseID">
					<input name="dtCompare" type="text" value="#censusapprovedate#" readonly="true">&nbsp;&nbsp;
					<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height:20px; width: 30px;" onClick="submit(); return false;">
				</td>
			</form>
		</cfif>
	</tr>
	<cfif session.username is 'gthota'>
	<tr>
		<form name="MonthlyCensusReport" action="../census/MonthlyCensusReport_RL.cfm" method="POST">									
			<td style="width: 25%;">
				Monthly Census Report
			</td>
			<td style="width: 50%;" colspan=2>
				<input type="TEXT" name="dtCompare" value="#DateFormat(Now(),'yyyymm')#">&nbsp;&nbsp;
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
		</form>
	</tr>
	</cfif>	
</table>
 </CFIF> 

</cfoutput>


<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">