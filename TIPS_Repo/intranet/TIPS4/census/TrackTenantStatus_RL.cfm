<!----------------------------------------------------------------------------------------------
| DESCRIPTION - TrackTenantStatus.cfm                                                          |
|----------------------------------------------------------------------------------------------|
| Records all the Leave Tenants 						                                       |
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
| Called by TrackDailyCensus_RL.cfm															   |     
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Gthota     | 09/06/2017 | Created initial page for relocation residents in TIPS              |
----------------------------------------------------------------------------------------------->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Track Tenant Census</title>

<script language="javascript">
/*
Auto center window script- Eric King (http://redrival.com/eak/index.shtml)
Permission granted to Dynamic Drive to feature script in archive
For full source, usage terms, and 100's more DHTML scripts, visit http://dynamicdrive.com
*/
	var win = null;
	function NewWindow(mypage,myname,w,h,scroll)
	{
		LeftPosition = (screen.width) ? (screen.width-w)/2 : 0;
		TopPosition = (screen.height) ? (screen.height-h)/2 : 0;
		settings =
		'height='+h+',width='+w+',top='+TopPosition+',left='+LeftPosition+',scrollbars='+scroll+',resizable'
		win = window.open(mypage,myname,settings)
	}
	
	function msg()
	{
		alert("Please initiate or process a move out from the TIPS main screen.");
		return false;
	}
</script>


</head>

<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<body>
<cfset OK2GO = "Y">
<cfset relocate_screen = "N">
<cfset moveout_screen = "N">
<cfset TenantArray = ArrayNew(1)>

<cfquery name="checkhouse" datasource="#application.datasource#">
	select * from [dbo].[RL_RES_STG] WHERE ToHouseID = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>

<p>
<cfloop list="#iTenant_ID#" index="loopvar">
	<cfset TenantStruct = StructNew()>
	<cfset TenantStruct.tenantId = "">
	<cfset TenantStruct.FullName = "">
	<cfset TenantStruct.DischargeGiven = "N">
	<cfset TenantStruct.Status = "">
	<cfset TenantStruct.DateMoveOut = "">
	<cfset TenantStruct.Place = "">
	<cfset TenantStruct.ReturnDate = "">
	<cfset TenantStruct.Relocate = "">
	<cfset TenantStruct.RelocateTenant ="">
	<cfset TenantStruct.MoveOutTenant ="">
		
	<cfset TenantStruct.tenantId = loopvar>
	<cfset TenantStruct.FullName = form["FullName_#loopVar#"]>
	
	<cfif isdefined("form.Date_#loopVar#")>
		<cfset TenantStruct.DateMoveOut = form["Date_#loopVar#"]>
		<cfset TenantStruct.DischargeGiven = "Y">
	</cfif>
	<cfif isdefined("form.Status_#loopvar#")>
		<cfset TenantStruct.Status = form["Status_#loopvar#"]>
	</cfif>

	<cfif isdefined("form.Place_#loopvar#")>
		<cfset TenantStruct.Place = form["Place_#loopvar#"]>
	</cfif>
	<cfif isdefined("form.ReturnDate_#loopvar#")>
		<cfset TenantStruct.ReturnDate = form["ReturnDate_#loopvar#"]>
	</cfif>
<!--- 	<cfif form["Status_#loopvar#"] eq 2>
	    <cfset TenantStruct.ReturnDate = "">
		<cfset TenantStruct.MoveOutTenant = loopvar>
		<cfset moveout_screen = "Y">
	</cfif> --->
	<cfif isdefined("form.relocate_#loopvar#")>
		<cfset TenantStruct.Relocate = form["relocate_#loopvar#"]>
		<cfset TenantStruct.RelocateTenant = loopvar>
		<cfset relocate_screen = "Y">
	<cfelse>
		<cfif form["Status_#loopvar#"] eq 2>
			<cfset TenantStruct.ReturnDate = "">
			<cfset TenantStruct.MoveOutTenant = loopvar>
			<cfset moveout_screen = "Y">
		</cfif>
	</cfif>
	<!--- 
	<cfset TenantStruct.DischargeGiven = form["ND_#loopvar#"]> 
 	<cfset TenantStruct.DateMoveOut = form["Date_#loopVar#"]>
	--->
	<cfset temp = ArrayAppend(TenantArray,TenantStruct)>
 
</cfloop>
<!---
 <cfdump var="#form#">
<cfdump var="#TenantArray#"> 
--->

<!--- If there is any relocate tenant then show the frame --->


<!--- <cfelseif relocate_screen eq "n" or url.Process eq "1"> --->
	<cfloop from="1" to="#ArrayLen(TenantArray)#" index="i">
	<cfoutput>
		<!--- get leave status description --->
		<cfquery name="GetLeaveStatus" datasource="#application.datasource#">
			select 
				cLeaveStatus
			from 
				LeaveStatus 
			where 
				iLeaveStatus_ID = #TenantArray[i].Place#
			and
				dtrowdeleted is NULL
		</cfquery>

		<!--- Check to see if there are records in the system already --->
		<cfquery name="CheckCensusTrack" datasource="#application.datasource#">	
			select * 
			from 
				DailyCensusTrack_RL d
			where
				d.itenant_ID = #TenantArray[i].tenantId#
			  and
				d.census_date = '#CompareDate#'
			  and
				dtrowdeleted is NULL	
		</cfquery>
		<!--- if there are records, then delete the old records --->
		<cfif CheckCensusTrack.Recordcount gt 0>
		   <cfquery name="DeleteCensusTrack" datasource="#application.datasource#">
			   delete from DailyCensusTrack_RL
			   where 
					itenant_ID = #TenantArray[i].tenantId#
				 and 
					census_date = '#CompareDate#'
			</cfquery>
		</cfif>

		<cfif #TenantArray[i].RelocateTenant# eq ''>
		 <!---  CurrentStatusInBedAtMidnight = N: #TenantArray[i].tenantId#  
		 insert all the 'N' into DailyCensusTrack table <br  />   --->
			<cfquery name="TenantTempStatus" datasource="#application.datasource#">		
				insert into DailyCensusTrack_RL 
					(
					 RL_FromHouse_ID
				    , RL_ToHouse_ID
					 , iTenant_ID
					, iLeaveStatus_ID
					, Census_Date
					, CurrentStatusinBedAtMidnight
					, TempWhere
					, TempStatusOutDate
					, TempStatusInDate
					, NoticeofDischarge
					, DischargeDate
					, iRowStartUser_ID
					, dtRowStart
					, cRowStartUser_ID
					)
				values 
				(
					#checkhouse.FromHouseID#
				    ,#SESSION.qSelectedHouse.iHouse_ID#
					,#TenantArray[i].tenantId#
					, #TenantArray[i].Place#
					, '#CompareDate#'
					, 'N'
					, '#GetLeaveStatus.cLeaveStatus#'
					, '#CompareDate#'
					, '#TenantArray[i].ReturnDate#'
					, '#TenantArray[i].DischargeGiven#'
					, '#TenantArray[i].DateMoveOut#' 
					, #SESSION.UserID#
					, getdate()
					, 'TrackTenantCensus'
				)		
			</cfquery>
		<cfelse>
			<!---  CurrentStatusInBedAtMidnight = Y: #TenantArray[i].tenantId#  
		   insert all the Relocate Tenants into DailyCensusTrack table with CurrentStatusInBedAtMidnight = 'Y'  <br />  --->
			<cfquery name="TenantTempStatus" datasource="#application.datasource#">		
				insert into DailyCensusTrack_RL 
				(
					RL_FromHouse_ID
				    , RL_ToHouse_ID
					,  iTenant_ID
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
					#checkhouse.FromHouseID#
				    ,#SESSION.qSelectedHouse.iHouse_ID#
					,#TenantArray[i].tenantId#
					, 0
					, '#CompareDate#'
					, '#TenantArray[i].DateMoveOut#'
					, 'Y'
					, ''
					, #SESSION.UserID#
					, getdate()
					, 'TrackDailyCensus'
				)	
			</cfquery>
		</cfif>
<p>

		<cfif OK2GO IS "Y">
			<table align="center">
				<tr align="center">
					<td>
						<b>Please process the Daily Census Approval.</b>
					</td>
				</tr>
			</table>
			<table align="center">
				<tr align="center">
					<!--- <td><INPUT TYPE="button" VALUE="Go Back" OnClick="JavaScript:history.go(-1)"></td> --->
					<td><INPUT TYPE="button" VALUE="Continue" OnClick="window.location.href='Census.cfm';"></td>
				</tr>
			</table>
			<cfset OK2GO = "N">
		</cfif>		
	</cfoutput>
	</cfloop>
<!--- </cfif> --->


</body>
</html>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">
