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
| Called by TrackDailyCensus.cfm															   |     
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| fzahir     | 02/03/2006 | Check Tenant Status and make appropriate changes.                  |
| mlaw       | 07/06/2006 | Add Comments                                                       |
| RSchuette	 | 03/17/2010 | 51267 - Took away MO ability from this screen.					   |
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
<!--- <cfdump var="#form#">
<cfdump var="#TenantArray#"> --->
<!--- If there is any relocate tenant then show the frame --->
<cfif relocate_screen eq "y">
	<b>Relocate Tenants:</b> 
	<table>
		<cfloop from="1" to="#ArrayLen(TenantArray)#" index="i">
			<cfif #TenantArray[i].RelocateTenant# neq ''>
				<tr>
					<td>
				    	Tenant Name
				  	</td>
				  	<td>
				   		Apt
				  	</td>
				</tr>
				<tr bgcolor="#CCCCCC">
					<td>
						<a href="../census/RelocateTenant.cfm?TenantID=<cfoutput>#TenantArray[i].RelocateTenant#</cfoutput>" target="subframe" >
							<cfoutput>
								#TenantArray[i].RelocateTenant# - #TenantArray[i].FullName#
							</cfoutput>
						</a>
					</td>		
					<td>
						<cfquery name="GetAptNbr" datasource="#application.datasource#">	
							select 
								aa.cAptNumber 
							from 
									tenantstate ts
							join 
								aptaddress aa
								on aa.iaptaddress_Id = ts.iaptaddress_ID 
							where 
								ts.itenant_ID = #TenantArray[i].RelocateTenant#
						</cfquery>
						
						<a href="../census/RelocateTenant.cfm?TenantID=<cfoutput>#TenantArray[i].RelocateTenant#</cfoutput>" target="subframe" >
							<cfoutput>
								#GetAptNbr.cAptNumber #
							</cfoutput>
						</a>
					</td>
				</tr>
			</cfif>
		</cfloop>
	</table>
	<p>
	<IFRAME src="../census/FinalizeRelocate.cfm" name="subframe" width="800" height="500" scrolling="Auto" frameborder="1">
		If you can see this, your browser doesn't 
		understand IFRAME.  Please contact your Accounting Representative a.s.a.p.
	</IFRAME>
</cfif>
<P>
<!--- If there is any MoveOut tenant then show the frame --->
<cfif moveout_screen eq "y">
	<b>MoveOut Tenants:</b> 
	<table>
		<tr>
			<td>
				Tenant Name
			</td>
			<td>
				Apt
			</td>
			<td>
				Type
			</td>
			<td>
				Pay Type
			</td>
			<td>
				SPts.
			</td>
			<td>
				Move In
			</td>
			<td>
				Move Out
			</td>				
		</tr>
		<cfloop from="1" to="#ArrayLen(TenantArray)#" index="i">
			<cfif #TenantArray[i].MoveOutTenant# neq ''>

				<tr bgcolor="#CCCCCC">
					<td>
						<!--- <a href="../census/RelocateTenant.cfm?TenantID=<cfoutput>#TenantArray[i].MoveOutTenant#</cfoutput>" target="subframe" > --->
							<cfoutput>
								#TenantArray[i].MoveOutTenant# - #TenantArray[i].FullName#
							</cfoutput>
						<!--- </a> --->
					</td>		
					<cfquery name="qResidentTenants" datasource="#application.datasource#">
						select 
							CASE LEN(ad.cAptNumber) 
							WHEN 1 THEN ('00' + ad.cAptNumber)
							WHEN 2 THEN ('0' + ad.cAptNumber) 
							ELSE ad.cAptNumber
							END as cAptNumber,
							apt.cDescription as cAptType ,
							t.iTenant_ID , 
							--t.cSolomonKey ,
							t.cFirstName ,
							t.cLastName ,
							rt.cDescription as Residency ,
							ts.dtMoveIn ,
							ts.dtMoveOut ,
							ts.iSPoints 
							--st.cDescription as Level ,
							--ts.iproductline_id , 
							--pl.iproductline_id aptproductline
						from 
							AptAddress AD (nolock)
						left join 
							houseproductline hpl (nolock) 
							on hpl.ihouseproductline_id = ad.ihouseproductline_id 
							and hpl.dtrowdeleted is null
						left join 
							productline pl (nolock) 
							on pl.iproductline_id = hpl.iproductline_id 
							and pl.dtrowdeleted is null
						left join	
							TenantState ts (nolock) 
							on ad.iAptAddress_ID = ts.iAptAddress_ID 
							and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID = 2 and ts.dtRowDeleted is null)		
						left outer join	
							AptType APT	(nolock) 
							on (apt.iAptType_ID = ad.iAptType_ID 
							and apt.dtRowDeleted is null)
						left join 
							Tenant t (nolock) 
							on (t.iTenant_ID = ts.iTenant_ID)
						left join	
							ResidencyType RT (nolock) 
							on (rt.iResidencyType_ID = ts.iResidencyType_ID)
						left join SLevelType ST	(nolock) 
							on (t.cSlevelTypeSet = st.cSlevelTypeSet 
							and ts.iSPoints <= iSPointsMax 
							and ts.iSPoints >= iSPointsMin)
						where	
							ad.dtRowDeleted is null	
							and ad.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
							and t.itenant_ID = #TenantArray[i].MoveOutTenant#	
							and t.dtRowDeleted is null
							and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID IN (2))
					</cfquery> 		
					<td>
						<cfoutput>
							#qResidentTenants.cAptNumber#
						</cfoutput>
					</td>
					<td>
						<cfoutput>
							#qResidentTenants.cAptType#
						</cfoutput>
					</td>
					<td>
						<cfoutput>
							#qResidentTenants.Residency#
						</cfoutput>
					</td>
					<td>
						<cfoutput>
							#qResidentTenants.iSPoints#
						</cfoutput>
					</td>
					<td>
						<cfoutput>
							#DATEFORMAT(qResidentTenants.dtMoveIn, "mm/dd/yyyy")#
						</cfoutput>
					</td>
																	
					<cfif qResidentTenants.dtMoveOut neq "">
						<td style="text-align: center;">
							<!--- 51267 - 3/17/2010 - RTS - MO to be done from tips main screen --->
							<!--- <input class="MoveOutButton" type="button" name="Pending" VALUE="Pending" style="color: blue;" onClick="subframe2.location='../MoveOut/MoveOutForm.cfm?ID=<cfoutput>#qResidentTenants.iTenant_ID#</cfoutput>&edit=1&ShowBtn=false'"> --->
							<input class="MoveOutButton" type="button" name="Pending" VALUE="Pending" style="color: blue;" onMouseOver="return msg();">
							<!--- end 51267 --->
						</td>
					<cfelseif qResidentTenants.iTenant_ID neq "">
						<td style="text-align: center;">
							<cfif (isDefined("AUTH_USER")) and 1 eq 0> 
								<cfset molocation='../MoveOut/MoveOutForm2.cfm?ShowBtn=false'> 
							<cfelse> 
								<cfset molocation='../MoveOut/MoveOutForm.cfm?ShowBtn=false'> 
							</cfif>
							<!--- 51267 - 3/17/2010 - RTS - MO to be done from tips main screen --->
							<!--- <input class="MoveOutButton" type="button" name="MoveOut" VALUE="MoveOut" onClick="subframe2.location='<cfoutput>#molocation#</cfoutput>&ID=<cfoutput>#qResidentTenants.iTenant_ID#</cfoutput>'"> --->
							<input class="MoveOutButton" type="button" name="MoveOut" VALUE="MoveOut" onMouseOver="return msg();">
							<!--- end 51267 --->
						</td>
					<cfelse>
						<td style="text-align: center;">
							<input name="MoveOut" type="button" class="MoveOutButton" value="GONE" />
						</td>
					</cfif>
				</tr>
			</cfif>
		</cfloop>
	</table>
	<p>
	<IFRAME src="../census/FinalizeMoveOut.cfm" name="subframe2" width="800" height="500" scrolling="Auto" frameborder="1">
		If you can see this, your browser doesn't 
		understand IFRAME.  Please contact your Accounting Representative a.s.a.p.
	</IFRAME>
</cfif>

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
				DailyCensusTrack d
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
			   delete from DailyCensusTrack
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
				insert into DailyCensusTrack 
					(
					  iTenant_ID
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
					#TenantArray[i].tenantId#
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
					#TenantArray[i].tenantId#
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
