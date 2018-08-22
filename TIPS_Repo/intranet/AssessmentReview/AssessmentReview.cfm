<!----------------------------------------------------------------------------------------------
| DESCRIPTION:                                                                                 |
|----------------------------------------------------------------------------------------------|
| AssessmentReview.cfm                                                                         |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|											                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 10/16/2006 | line 135 query of query referenced '' for a int so I changed it to |
|            |            | is not null.                                                       |
| ranklam    | 10/16/2006 | line 457 query of query referenced '' for a int so I changed it to |
|            |            | is not null.                                                       |
----------------------------------------------------------------------------------------------->

<!--- Stablish style sheet for this application --->
<cfoutput>
<link rel="StyleSheet" type="text/css"  href="../TIPS4/Shared/Style2.css">
<style>TD {border: none; vertical-align: top;}</style>
</cfoutput>

<script>
function deleteentry(str){  a=confirm('Are you sure you would like to delete this record?');
if (a == true) { location.href='assessmentreviewdelete.cfm?did='+str; return true; }
else { return false; }
}
</script>

<cfscript>
DSN="TIPS4"; small="width:1%;"; topborder="border-top: 1px solid ##ccccff;";
bottomborder="border-bottom: solid transparent 1px;'; rightborder = 'border-right: 1px solid navy;";
if (IsDefined("url.period")) { form.period = url.period; }
</cfscript>

<!--- Retrieve All employee information --->
<cfquery name='qEmployees' datasource='ALCWEB' CACHEDWITHIN="#CreateTimeSpan(0, 0, 2, 0)#">
select * from Employees
</cfquery>

<!--- Retrieve Deparment for this user --->
<cfquery name='qDept' dbtype='Query'>
select nDepartmentNumber from qEmployees where Employee_Ndx = #SESSION.USERID#
</cfquery>

<!--- Retrieve All user information --->
<cfquery name='qUsers' datasource='DMS' CACHEDWITHIN="#CreateTimeSpan(0, 0, 2, 0)#">
select lower(username) as Username, employeeid from Users order by UserName
</cfquery>

<cftry>
	<!--- Check to see if this user is in the QA group. QI and Clinical Services --->
	<CF_ADSI TASK="VerifyGroupMembership" DOMAIN="ALC" USER="#SESSION.UserName#" GROUP="QI & Clinical" RETURN="VerifyQA">
	<cfcatch type="ANY">
		<cfif NOT IsDefined("url.period") and 1 EQ 0><!--- Send notification of user is not in NT Groups --->
			<cfmail to="#session.developerEmailList#" from="TIPS4-Violation@alcco.com" subject="Username not in Domain" type="HTML">
				Remote Address: #REMOTE_ADDR#<BR>ReferencePage: #HTTP.Referer#<BR>User: #SESSION.USERNAME#
			</cfmail>
			<cfset SESSION.emaildebug=1>
		</cfif>
	</cfcatch>
</cftry>

<!--- Create variable to tell if the page data is editable for this user --->
<cfscript>
	if (qDept.nDepartmentNumber EQ 5
			OR (IsDefined("VerifyQA") and FindNocase('Yes',VerifyQA) GT 0)
			OR (IsDefined("SESSION.USERNAME") and SESSION.USERNAME EQ 'PaulB'
			OR SESSION.USERNAME EQ 'BOBE' OR SESSION.USERNAME EQ 'LeslieH')){
	Editable=1;} else { Editable=0;
	}
</cfscript>

<!--- Retrieve Chosen House information --->
<cfquery name="qHouse" datasource="TIPS4" CACHEDWITHIN="#CreateTimeSpan(0, 0, 2, 0)#">
select iHouse_ID, cName from House where dtRowDeleted is null and iHouse_ID = <cfif IsDefined("url.SelectedHouse_ID")>#url.SelectedHouse_ID#<cfelse>#SESSION.qSelectedHouse.iHouse_ID#</cfif>
</cfquery>

<cfscript>	if (IsDefined("url.SelectedHouse_ID")){SESSION.qSelectedHouse = qHouse;} </cfscript>

<!--- Retrieve periods for this application --->
<cfquery name='qPeriods' datasource="#DSN#" CACHEDWITHIN="#CreateTimeSpan(0, 0, 2, 0)#">
select * from AssessmentPeriod where dtRowDeleted is null and dtStartRange <= GetDate()	ORDER BY dtStartRange desc
</cfquery>

<cfquery name='timestamp' datasource='#DSN#'>
select getdate() as time
</cfquery>
<cfset CompareDate=timestamp.time>

<cfif isDefined("form.period")>
<cfquery name='qThisPeriod' datasource="#DSN#">
select dtStartrange, dtEndRange from AssessmentPeriod where dtRowDeleted is null and iAssessmentPeriod_ID = #trim(form.period)# ORDER BY dtStartRange desc
</cfquery>
<cfset CompareDate=qThisPeriod.dtEndRange>
</cfif>

<!--- ==============================================================================
Retrieve apartment list and tenant list
CACHEDWITHIN="#CreateTimeSpan(0, 0, 2, 0)#"
=============================================================================== --->
<cfquery name='qTenants' datasource="#DSN#">
<cfif NOT isDefined("form.period") OR (timestamp.time LTE qThisPeriod.dtEndRange and timestamp.time GTE qThisPeriod.dtStartRange)>
	select	distinct isNuLL(T.cFirstName,'') as cFirstName ,isNuLL(T.cLastName,'') as cLastName ,isNuLL(RT.cDescription,'') as residency
		,isNuLL(AD.cAptNumber,'') as cAptNumber ,TS.dtMoveIn ,isNuLL(TS.iSPoints,'') as iSPoints ,isNuLL(SLT.cDescription,'') as level
		,T.iTenant_ID ,T.cSLevelTypeSet
	from	AptAddress AD
	left outer join	TenantState TS ON (TS.iAptAddress_ID = AD.iAptAddress_ID and TS.dtRowDeleted is null and TS.iTenantStateCode_ID = 2)
	left outer join	Tenant T ON (TS.iTenant_ID = T.iTenant_ID and T.dtRowDeleted is null)
	join House H ON (AD.iHouse_ID = H.iHouse_ID and H.dtRowDeleted is null)
	left outer join ResidencyType RT ON (RT.iResidencyType_ID = TS.iResidencyType_ID and RT.dtRowDeleted is null)
	left outer join SLevelType SLT ON ( SLT.cSLevelTypeSet = T.cSLevelTypeSet and SLT.dtRowDeleted is null and TS.iSPoints <= SLT.iSPointsMax and TS.iSPoints >= iSPointsMin )
	where	AD.dtRowDeleted is null
	and	AD.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY cAptNumber
<cfelse>
	select	distinct isNuLL(TH.cFirstName,'') as cFirstName ,isNuLL(TH.cLastName,'') as cLastName
		,isNuLL(RT.cDescription,'') as residency
		,isNuLL(AD.cAptNumber,'') as cAptNumber
		,TH.dtMoveIn ,isNuLL(TH.iSPoints,'') as iSPoints
		,isNuLL(SLT.cDescription,'') as level
		,TH.iTenant_ID ,TH.cSLevelTypeSet
	from	AptAddress AD
	left outer join	rw.vw_tenant_history_with_state th on th.iaptAddress_id = ad.iaptaddress_id
		and itenantstatecode_id = 2 and statedtrowdeleted is null
		and '#CompareDate#' between statedtrowstart and isnull(statedtrowend,getdate())
		and '#CompareDate#' between tendtrowstart and isnull(tendtrowend,getdate())
	join House H ON (AD.iHouse_ID = H.iHouse_ID and H.dtRowDeleted is null)
	left outer join ResidencyType RT ON (RT.iResidencyType_ID = TH.iResidencyType_ID and RT.dtRowDeleted is null)
	left outer join SLevelType SLT ON ( SLT.cSLevelTypeSet = TH.cSLevelTypeSet and SLT.dtRowDeleted is null and TH.iSPoints <= SLT.iSPointsMax and TH.iSPoints >= iSPointsMin )
	where	AD.dtRowDeleted is null
	and	AD.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY cAptNumber
</cfif>
</cfquery>

<!--- create array of residents to find history--->
<cfquery name="qlistfilter" dbtype="query">
	select
		itenant_id
	from
		qtenants
	where
		itenant_id IS NOT NULL
</cfquery>

<cfset tenantlist=quotedvaluelist(qlistfilter.itenant_id)>

<!---
<cfloop query='qTenants'>
<cfscript>
if (len(trim(qTenants.iTenant_ID)) GT 0){ if (qTenants.CurrentRow EQ 1 OR NOT IsDefined("TenantList")){ TenantList = qTenants.iTenant_ID;}
else{ TenantList = TenantList & ',' & qTenants.iTenant_ID; } }
</cfscript>
</cfloop>
--->

<cfif isdefined("tenantlist") and len(tenantlist) gt 0>
	<!---
	<cfquery name="qDetailHistory" datasource="#DSN#">
	select top 500 * from rw.vw_AssessmentDetail_History where iTenant_ID IN (#TenantList#)
	</cfquery>
	--->

	<CFQUERY NAME="qDetailHistory" DATASOURCE="#DSN#">
	select top 500 *
	from rw.vw_AssessmentDetail_History ah
	join assessmentmaster am on am.iassessmentmaster_id = ah.iassessmentmaster_id
	and am.dtrowdeleted is null
	join assessmentperiod ap on ap.iAssessmentPeriod_ID = am.iAssessmentPeriod_ID
	and ap.dtrowdeleted is null
	where iTenant_ID IN (#preservesinglequotes(TenantList)#)
	<CFIF IsDefined("form.Period") and form.period NEQ ''> and AM.iAssessmentPeriod_ID = #form.period# <CFELSE> and AM.iAssessmentPeriod_ID = #qPeriods.iAssessmentPeriod_ID# </CFIF>
	</CFQUERY>

	<cfquery name='qLevelHistory' datasource='#DSN#'>
		select 
			* 
		from
			rw.vw_ServiceLevel_History 
		where 
			dtRowDeleted is null
	</cfquery>
</cfif>

<!--- Retrieve Assessment History for this house --->
<cfquery name='qHistoryUpper' datasource='#DSN#'>
select AD.* ,AM.cComments as headercomments ,isNull(AD.iIndicatedPoints,0) as iIndicatedPoints ,AM.iAssessmentPeriod_ID
from AssessmentMaster AM
left join AssessmentDetail AD ON (AM.iAssessmentMaster_ID = AD.iAssessmentMaster_ID and AD.dtRowDeleted is null)
where AM.dtRowDeleted is null and AM.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
<cfif IsDefined("form.Period") and form.period NEQ ''> and AM.iAssessmentPeriod_ID = #form.period# <cfelse> and AM.iAssessmentPeriod_ID = #qPeriods.iAssessmentPeriod_ID# </cfif>
</cfquery>

<!--- Retrieve last time header comments were changed --->
<cfquery name='qLastHeaderChange' datasource='#DSN#'>
Declare @currentcomments varchar(1000)

select 	@currentcomments = IsNull(cComments,0)
from AssessmentMaster AM
where AM.dtRowDeleted is null
and	AM.iAssessmentPeriod_ID = <cfif IsDefined("form.Period") and form.period NEQ ''> #form.period# <cfelse> #qPeriods.iAssessmentPeriod_ID# </cfif>
and	AM.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#

select max(dtrowstart) as changedDate, cRowStartUser_ID
from P_AssessmentMaster PAM
where PAM.dtRowDeleted is null
and PAM.iAssessmentPeriod_ID = <cfif IsDefined("form.Period") and form.period NEQ ''> #form.period# <cfelse> #qPeriods.iAssessmentPeriod_ID# </cfif>
and PAM.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
and IsNull(PAM.cComments,0) <> @currentcomments
Group BY cRowStartUser_ID
</cfquery>

<cfscript> if (qHistoryUpper.RecordCount GT 0) { headercomments=qHistoryUpper.headercomments;}  else { headercomments='';}</cfscript>

<!--- Import JavaScript Functions <cfinclude template="../TIPS4/Shared/JavaScript/ResrictInput.cfm"> --->
<script language="JavaScript" type="text/javascript" src="../TIPS4/Shared/JavaScript/global.js"></script>

<script>
	function periodselect(){
	<cfif Editable EQ 1>
		if (changesmade > 0){
			if (confirm('Changing periods will discard any changes if you have not saved. \r Are you sure you would like to change periods?')){
				document.forms[0].action = 'AssessmentReview.cfm'; document.forms[0].submit();
			}
			else {
				for (i=0;i<=(document.forms[0].Period.length-1);i++){
				<cfif IsDefined("form.period")> if (document.forms[0].Period[i].value == <cfoutput>#form.period#</cfoutput>){document.forms[0].Period[i].selected = true; }</cfif>
				} return false;
			}
		}
		else{ document.forms[0].action = 'AssessmentReview.cfm'; document.forms[0].submit(); }
	<cfelse> document.forms[0].action = 'AssessmentReview.cfm'; document.forms[0].submit(); </cfif>
	}
	function lencheck(obj){
		if(obj.value.length >=1000){ obj.focus(); alert('Comments are limited to 1000 characters. \r You are currently using ' + obj.value.length + ' characters.' ); adjustcom(obj); obj.value = obj.value.substring(0,999); }
	}
	function adjustcom(obj) {
		if (obj.value.length >= 40 && obj.value.length/40 > 3){ obj.rows=(obj.value.length/40)+1;}
		if (obj.value.length !== '') { obj.style.background='lightyellow'; }
	}
	function outcom(obj){ obj.cols=40; obj.rows=3; obj.style.background='transparent';}
	function checkchanges(){ if(changesmade == 0){ alert('No Changes Detected'); return false; } else{ return true;} }
	function cancelform(){ if(changesmade == 0){ alert('No Changes Detected'); return false; } else{ location.href='AssessmentReview.cfm'; } }
</script>

<cfoutput>

<form action="AssessmentReviewUpdate.cfm" method="POST">
<b style="font-size: 16;">#session.fullname#</b>
<table class="noborder" cellpadding="3" cellspacing="0">
	<tr>
		<td class='noborder' style="background:white;"><b><A name=start href="../TIPS4/Index.cfm">#qHouse.cName#</A></b></td>
		<td class='noborder' style="background:white;text-align:center;"><A href="../logout.cfm"><b>Click Here to Log Out</b></A></td>
		<td class='noborder' style="background:white;text-align:right;">
			<b>Select Period:</b>
			<select name="Period" onChange="periodselect();">
				<cfloop query='qPeriods'><cfif IsDefined("form.period") and form.period EQ qPeriods.iAssessmentPeriod_ID> <cfset selectED="selectED"> <cfelse> <cfset selectED=""> </cfif>
					<option value="#qPeriods.iAssessmentPeriod_ID#" #selectED#> #qPeriods.cDescription# </option>
				</cfloop>
			</select>
		</td>
	</tr>
</table>
<table cellpadding="3" cellspacing="0" style="border: 1px solid black;">
	<cfif IsDefined("form.period")> <cfset periodID = form.period> <cfelse> <cfset periodID = qPeriods.iAssessmentPeriod_ID> </cfif>
	<tr>
		<td colspan=100% style='#center#'>
		<table class='noborder' style='width: 99%;'>
			<tr>
			<td colspan="3"><input type="submit" name="Save" value="Save" style="width: 100px; color: navy;" onClick="return checkchanges();"></td>
			<td colspan="5" style="text-align:center;"><A style="font-size:x-small;" href="AssessmentSummaryReport.cfm?houseID=#SESSION.qSelectedHouse.iHouse_ID#&periodID=#periodID#"><strong>Print Assessment Report</strong></A></td>
			<td style="text-align:right;"><input type="button" name="Cancel" value="Cancel" style="width: 100px; color: navy;" onClick="cancelform();"></td>
			</tr>
		</table>
		</td>
	</tr>
	<tr>
		<th>Name</th>
		<th>Apt##</th>
		<th><A onMouseOver="hoverdesc('Move In Date')" onMouseOut="resetdesc()">MI</A></th>
		<th>Residency</th>
		<th onMouseOver="hoverdesc('Service Set');" onMouseOut="resetdesc();">Set</th>
		<th onMouseOver="hoverdesc('Current Points');" onMouseOut="resetdesc();">Points</th>
		<th onMouseOver="hoverdesc('Current Level');" onMouseOut="resetdesc();">Level</th>
		<th onMouseOver="hoverdesc('Indicated Points');" onMouseOut="resetdesc();">*Points</th>
		<th style="width:1%;" onMouseOver="hoverdesc('Indicated Level');" onMouseOut="resetdesc();">*Level</th>
	</tr>

	<cfloop query='qTenants'>
		<!--- Retrieve Assessment History for this tenant --->
		<cfif qTenants.iTenant_ID NEQ ''>
			<cfscript>
			if (IsDefined("form.Period") and form.period NEQ '') { periodid = form.period; }
			else { periodid = qPeriods.iAssessmentPeriod_ID; }
			</cfscript>
			<cfquery name='qHistory' dbtype='Query'>
			select * from qHistoryUpper where iAssessmentPeriod_ID = #periodid# and iTenant_ID = #qTenants.iTenant_ID#
			</cfquery>
		</cfif>

		<cfif (IsDefined("qHistory.RecordCount") and qHistory.RecordCount GT 0) and qTenants.iTenant_ID NEQ "">
			<cfscript>	IP = qHistory.iIndicatedPoints; Comments = '#trim(qHistory.cComments)#'; RDOComments = trim(qHistory.cRDOComments); </cfscript>

			<!--- Retrieve Last record for user entered points or comments change --->
			<cfquery name='qRecordChange' dbtype='query'>
			select cRowStartUser_ID, dtRowStart from qDetailHistory
			where iTenant_ID = #qTenants.iTenant_ID#
			and (iIndicatedPoints = #qHistory.iIndicatedPoints#
			and cComments = '#qHistory.cComments#')
			<cfif trim(qHistory.cComments) neq ''>ORDER BY dtRowStart desc<cfelse>ORDER BY dtRowStart asc</cfif>
			</cfquery>
			<cfquery name='qUserCom' dbtype='QUERY'> select employeeid from qUsers where username = '#trim(LCase(qRecordChange.cRowStartUser_ID))#' </cfquery>

			<cfif qUserCom.employeeid GTE 1800 and qUserCom.employeeid LTE 2000>
				<cfset tmpFullName = '#trim(LCase(qRecordChange.cRowStartUser_ID))#'>
			<cfelse>
				<cfquery name='qUserNames' dbtype='QUERY'> select (FName + ' ' + LName) as fullname from qEmployees where employee_ndx = #IsBlank(qUserCom.employeeid,0)# </cfquery>
				<cfset tmpFullName = qUserNames.FullName>
			</cfif>
			<cfquery name='qLevel' dbtype="query">
				select 
					* 
				from 
					qLevelHistory
				where 
					cSLevelTypeSet = '#qTenants.cSLevelTypeSet#'
				and 
					(iSPointsMin <= #qHistory.iIndicatedPoints# 
						and 
					iSPointsMax >= #qHistory.iIndicatedPoints#)
				and
					<cfif qHistory.dtRowStart NEQ ''>
						'#qHistory.dtRowStart#'
					<cfelse>
						getdate()
					</cfif>
						between dtRowStart and dtrowend
			</cfquery>

			<!---
			select * from rw.vw_ServiceLevel_History
			where dtRowDeleted is null
			and cSLevelTypeSet = '#qTenants.cSLevelTypeSet#'
			and (iSPointsMin <= #qHistory.iIndicatedPoints# and iSPointsMax >= #qHistory.iIndicatedPoints#)
			and <cfif qHistory.dtRowStart NEQ ''> '#qHistory.dtRowStart#' <cfelse> getdate() </cfif>between dtRowStart and isNull(dtRowEnd,getdate())
			--->
			<cfscript> User = IsBlank(tmpFullName,''); dtEntered = qRecordChange.dtRowStart; IL=qLevel.cDescription; </cfscript>
		<cfelse>
			<cfscript> IP=''; IL=''; Comments=''; RDOComments=''; User = ''; dtEntered = ''; </cfscript>
		</cfif>

		<cfif qTenants.iTenant_ID NEQ '.' and qTenants.iTenant_ID NEQ ''>
			<!--- Retrieve Service Level List --->
			<cfquery name='qSLevelList' datasource='#DSN#'>
				select cDescription, iSPointsMin, iSPointsMax
				from rw.vw_ServiceLevel_History
				where dtRowDeleted is null and cSLevelTypeSet = '#qTenants.cSLevelTypeSet#'
				and <cfif qHistory.dtRowStart NEQ ''> '#qHistory.dtRowStart#' <cfelse> getdate() </cfif>between dtRowStart and isNull(dtRowEnd,getdate())
			</cfquery>

			<!--- Retrieve Service Level List --->
			<cfquery name='qSLevelLimits' datasource='#DSN#'>
			select Min(iSPointsMin) as min, Max(iSPointsMax) as max
			from rw.vw_ServiceLevel_History
			where dtRowDeleted is null and cSLevelTypeSet = '#qTenants.cSLevelTypeSet#'
			</cfquery>

			<script>
			function IndicatedLevel#qTenants.iTenant_ID#(obj){ o='';
				for (i=2;i<=obj.name.length;i++){ o+=obj.name.charAt(i); }
				<cfloop query="qSLevelList">
					<cfif qSLevelList.CurrentRow EQ 1>
						if (obj.value !== '' && (obj.value >= #qSLevelList.iSPointsMin# && obj.value <= #qSLevelList.iSPointsMax#)){
					<cfelse>
						else if (obj.value !== '' && (obj.value >= #qSLevelList.iSPointsMin# && obj.value <= #qSLevelList.iSPointsMax#)){
					</cfif>
					var test = 'document.forms[0].IL' + o; var il = eval(test); il.value = #qSLevelList.cDescription#;}
				</cfloop>
					else if (obj.value == '') { var test = 'document.forms[0].IL' + o; var il = eval(test); il.value = ''; }
					else if (obj.value < #qSLevelList.iSPointsMin# || obj.value > #qSLevelList.iSPointsMax#) {
						alert("The entered points are out of the house's service level range. \r The valid range for this house is #qSLevelLimits.min# to #qSLevelLimits.max#"); obj.value = '#qSLevelLimits.max#';
						var test = 'document.forms[0].IL' + o; var il = eval(test); il.value = ''; obj.focus();
					}
				}
			</script>
		</cfif>

		<tr style="background:##eaeaea;">
			<td nowrap style="#topborder# color:blue;">#qTenants.cFirstName# #qTenants.cLastName#</td>
			<td style="#center# #topborder#">#qTenants.cAptNumber#</td>
			<td style="#center# #topborder#">#IsBlank(DateFormat(qTenants.dtMoveIn,'mm/dd/yy'),'')#</td>
			<td style="#center# #topborder#">#qTenants.residency#</td>
			<td style="#center# #topborder#">#IsBlank(qTenants.cSLevelTypeSet,'')#</td>
			<td style="#center# #topborder#"><cfif qTenants.iTenant_ID NEQ "" and qTenants.iSPoints NEQ "">#qTenants.iSPoints#</cfif></td>
			<td style="#center# #topborder#">#qTenants.Level#</td>
			<td style="#center# #topborder#">
				<cfif qTenants.iTenant_ID NEQ "" and Editable EQ 1>
					<input type="Text" size="1" name="IP#qTenants.iTenant_ID#" value="#trim(IP)#" style="text-align:center;height:20px;font-size:xx-small;" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="IndicatedLevel#qTenants.iTenant_ID#(this); this.style.background='white';" onFocus="this.style.background='lightyellow';">
				<cfelseif qTenants.iTenant_ID NEQ "" OR Editable EQ 0>
					#IP# <input type="hidden" name="IP#qTenants.iTenant_ID#" value="#IP#">
				</cfif>
			</td>
			<td style="#center# #topborder#">
				<cfif qTenants.iTenant_ID NEQ "" and Editable EQ 1>
					<input type="Text" size="4" name="IL#qTenants.iTenant_ID#" value="#IL#" style="background:transparent;border:none;text-align:center;" READONLY>
				<cfelseif qTenants.iTenant_ID NEQ "" and Editable EQ 0> #IL# </cfif>
			</td>
		</tr>
		<cfif qTenants.iTenant_ID NEQ "">
			<tr><td colspan="100%">
				<table class="noborder" style="#center# width:100%;">
				<tr>
				<cfscript>
					if (User NEQ '' and qTenants.iTenant_ID NEQ ""){ text1="Entered by:"; text2="#User# #DateFormat(dtEntered,"mm/dd/yy")# #TimeFormat(dtEntered,"h:mmtt")# PST"; }
					else {text1=''; text2=''; }
				</cfscript>
				<td style="text-align:left;font-size:x-small;width:50%;border-bottom: 1px dashed ##eaeaea;">
					<em><u>Nurse Comments:</u></em><br/>
					<cfif qTenants.iTenant_ID NEQ "" and Editable EQ 1>
						<textarea cols="40" rows="3" name="cComments#qTenants.iTenant_ID#" maxlength="1000" style="font-size:x-small;" onKeyDown='adjustcom(this);' onKeyUp='lencheck(this);' onBlur="outcom(this);">#trim(Comments)#</textarea>
					<cfelseif qTenants.iTenant_ID NEQ "" and Editable EQ 0>
						<cfif Len(HTMLEditFormat(Comments)) GT 0>#HTMLEditFormat(Comments)#<cfelse>&nbsp;</cfif>
						<input type="hidden" name="cComments#qTenants.iTenant_ID#" size=40 value="#trim(Comments)#">
					</cfif>
					<cfif qHistory.recordcount gt 0><a href="javascript:deleteentry('#qhistory.iassessmentdetail_id#');" style="color:red;background:yellow;font-size:xx-small;"><u>[delete this entry]</u></a></cfif>
					<cfif trim(text2) neq ""><div><a style='font-size:xx-small;'>#text1# #IsBlank(text2,'')#</a></div></cfif>
				</td>
				<td style="text-align: left; vertical-align:top; width:50%;border-bottom: 1px dashed ##eaeaea;">
					<!--- Retrieve last user to change RDO Comments --->
					<cfscript>
					 if (trim(qHistory.cRDOComments) NEQ '') { RDOComments=trim(qHistory.cRDOComments); } else { RDOComments=''; }
					</cfscript>
					<cfquery name="qRDOCommentsChange" dbtype="QUERY">
						select 
							* 
						from 
							qDetailHistory 
						where 
							iTenant_ID = #qTenants.iTenant_ID#
						and 
							cRDOComments = '#RDOComments#'
						<cfif qHistory.RecordCount GT 0>
						and ((iIndicatedPoints <> #qHistory.iIndicatedPoints# 
								and 
							 cComments = '#qHistory.cComments#')
						or 
							(iIndicatedPoints = #qHistory.iIndicatedPoints# 
								and 
							cComments <> '#qHistory.cComments#')
						or (iIndicatedPoints = #qHistory.iIndicatedPoints# 
								and 
							cComments = '#qHistory.cComments#' 
								and 
							dtRowEnd IS NULL))
						</cfif>
						ORDER BY 
							dtRowStart
					</cfquery>

					<cfif qRDOCommentsChange.RecordCount GT 0>
						<!--- Retreive Full Name from previous Query --->
						<cfquery name="qUserID" dbtype="Query"> select employeeid from qUsers where username = '#trim(LCase(qRDOCommentsChange.cRowStartUser_ID))#' </cfquery>
						<cfscript> if (qUserID.employeeid NEQ ''){ userid=qUserID.employeeid; } else { userid=0; } </cfscript>
						<cfquery name="qUserNamesRDO" dbtype="Query"> select	(FName + ' ' + LName) as fullname from qEmployees where	employee_ndx = #userid# </cfquery>
						<cfset RDOUser = qUserNamesRDO.fullname>
					<cfelse>
						<cfset RDOUser = ''>
					</cfif>
					<EM><U>Operations Comments:</U></EM><BR>
					<cfif Editable EQ 0>
						<textarea COLS="40" ROWS="3" maxlength="1000" name="cRDOComments#qTenants.iTenant_ID#" style="font-size:x-small" onKeyDown='adjustcom(this);' onKeyUp='lencheck(this);' onBlur='outcom(this);'>#trim(RDOComments)#</textarea>
					<cfelse>
						#HTMLEditFormat(RDOComments)#<BR>
						<input type='hidden' name="cRDOComments#qTenants.iTenant_ID#" value='#trim(RDOComments)#'>
					</cfif>
					<BR>
					<cfif trim(RDOComments) NEQ "" and RDOUser NEQ ""><A style='font-size:x-small;'>Entered by: <BR>#RDOUser# #DateFormat(qRDOCommentsChange.dtRowStart,"mm/dd/yy")# #TimeFormat(qRDOCommentsChange.dtRowStart,"h:mmtt")# PST</A></cfif>
				</td>
				<cfif Editable EQ 0><input type="hidden" name="RDOCommentsOnly" value="1"></cfif>
		</tr></table>
		</cfif>
	</cfloop>
	<tr>
		<td colspan="8">
			<strong>Exit Attendees & Comments</strong><br/>
			<cfif Editable EQ 0> #headerComments# <cfelse>
				<textarea cols="60" rows="3" maxlength="1000" name="HeaderComments" onKeyDown='adjustcom(this);' onKeyUp='lencheck(this);' onBlur='outcom(this);'>#headerComments#</textarea>
			</cfif>
		</td>
	</tr>
	<tr style="background:##eaeaea;">
		<td colspan="4"><input type="submit" name="Save" value="Save" style="width:100px; color:navy;" onClick="return checkchanges();"></td>
		<td colspan="5" style="text-align:right;"><input type="button" name="Cancel" value="Cancel" style="width: 100px; color: navy;" onClick="cancelform();"></td>
	</tr>
</table>
</form>
</cfoutput>
<script>
	changesmade=0;
	//set default values
	n=new Array(); v=new Array();
	for (i=0;i<=document.forms[0].elements.length-1;i++){ n[i] = document.forms[0].elements[i].name; v[i] = document.forms[0].elements[i].value;}
	function detectchanges(){
		changesmade=0;
		for (t=0;t<=document.forms[0].elements.length-1;t++){ if (n[t] == document.forms[0].elements[t].name && v[t] !== document.forms[0].elements[t].value) { changesmade = changesmade + 1; } }
		if (changesmade > 10) { statmess=changesmade + ' changes detected. Please save your work.'; }
		else { statmess=changesmade + ' changes detected since last save.'; }
		window.status=statmess;
		setTimeout("detectchanges()",200);
	}
	detectchanges();
</script>
<cfinclude template="../footer.cfm">
