<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Registration/MoveOutAddendum.cfm                                               |
|----------------------------------------------------------------------------------------------|
| Alter finalized Moved Out (MO) data separate from the MO Invoice                             |
| Called by: 		Registration.cfm														   |
| Calls/Submits:	MoveOutAddendumAction.cfm												   |
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
|Paul Buendia| 02/07/2002 | Original Authorship                 	      					   |
|MLAW        | 08/07/2006 | Create a flower box                                                |
|MLAW		 | 08/07/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                 |
|gthota     | 2017-10-25 | 'move out date' alert massage commented  of date select more than 30 days                 |
----------------------------------------------------------------------------------------------->

<!--- 08/07/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<!--- ==============================================================================
Include intranet Header
=============================================================================== --->
<CFIF ShowBtn>
	<CFINCLUDE TEMPLATE="../../Header.cfm">
</CFIF>

<!--- ==============================================================================
Include Application JScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<CFSET Month=#DateFormat(now(),"mm")#>
<CFSET Day=#DateFormat(now(),"dd")#>
<CFSET Year=#DateFormat(now(),"yyyy")#>

<!--- ==============================================================================
Retrieve Tenant Information
=============================================================================== --->
<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	(T.cFirstName + ' ' + T.cLastName) as FullName
	,TS.dtMoveIn,ts.dtrenteffective,ts.dtchargethrough, ts.dtmoveout, T.cSolomonKey
	,TS.iResidencyType_ID, T.iTenant_ID, ts.dtmoveoutprojecteddate,dtNoticeDate, t.ihouse_id,
	ts.iAptAddress_ID,ts.ispoints, ts.islpoints
	FROM 	TENANT T
	JOIN TENANTSTATE TS ON TS.iTenant_ID = T.iTenant_ID
	WHERE	T.iTenant_ID = #ID#
	AND		T.dtRowDeleted IS NULL  AND TS.dtRowDeleted IS NULL
</CFQUERY>
<cfoutput>	<cfif qtenant.iresidencytype_id is 3>
		<cflocation url="../Tenant/RespiteMoveOutCorrection.cfm?tenantID=#qtenant.itenant_id#">
	</cfif></cfoutput>
<!--- ==============================================================================
Retrieve Any Addendums for this tenant
=============================================================================== --->
<CFQUERY NAME="qAddendumHistory" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	AddendumLog AL
	JOIN	AddendumType ADT ON (ADT.iAddendumType_ID = AL.iAddendumType_ID AND ADT.dtRowDeleted IS NULL)
	WHERE	AL.dtRowDeleted IS NULL
	AND		AL.iTenant_ID = #qTenant.iTenant_ID#
	ORDER BY AL.dtRowStart desc
</CFQUERY>

<cfquery name="qusercodeblock" DATASOURCE="#APPLICATION.datasource#">
  		select 	groupassignments.groupid, users.employeeid, passexpires, groups.groupname
		from 	dms.dbo.users,dms.dbo.groupassignments, dms.dbo.groups
		where	users.employeeid = groupassignments.userid 
		and groups.groupid = groupassignments.groupid
			and users.employeeid =  #session.userid#
			order by groupassignments.groupid
</cfquery>

<script  language="javascript">
function verifyDates(){    
var MoveInMgr = document.getElementById("MvInMgr_ID").value; 
var	phyMovOutDt = document.getElementById("moveoutdt").value;
var mvy = phyMovOutDt.substring(6,10);
var mvm = phyMovOutDt.substring(0,2);
var mvd = phyMovOutDt.substring(3,5);
var phyMovOutDtStr = mvy+mvm+mvd;  
// alert('moveout : ' + phyMovOutDtStr);
 
var pchgthruDt =  document.getElementById("chgthroughdt").value;
var pmy = pchgthruDt.substring(6,10);
var pmm = pchgthruDt.substring(0,2);
var pmd = pchgthruDt.substring(3,5);
var pchgthruDtStr = pmy+pmm+pmd; 

var NoticeDt =  document.getElementById("noticedt_id").value;
var nty = NoticeDt.substring(6,10);
var ntm = NoticeDt.substring(0,2);
var ntd = NoticeDt.substring(3,5);
var NoticeDtStr = nty+ntm+ntd; 
 
 // alert('Charge thru : ' +pchgthruDtStr);
var currmoveindt = document.getElementById("currmovindate_id").value;
var currdtmoveout = document.getElementById("currdtmoveout_id").value;
var currdtchargethrough = document.getElementById("currdtchargethrough_id").value;
var curreffdt = document.getElementById("curreffdate_id").value;
var commentchk = document.getElementById("cComments").value;

var currChgThruDt = document.getElementById("currdtchargethrough_id").value;
var currChgThruYr = currChgThruDt.substring(0,4);
var currChgThruMo = currChgThruDt.substring(4,6);
var currChgThruDy = currChgThruDt.substring(6);
var CurrChargeThroughDate = currChgThruYr + '-' + currChgThruMo + '-' + currChgThruDy;

var currMoveOutDt = document.getElementById("currdtmoveout_id").value;
var currMoveOutYr = currMoveOutDt.substring(0,4);
var currMoveOutMo = currMoveOutDt.substring(4,6);
var currMoveOutDy = currMoveOutDt.substring(6);
var CurrMoveOutDate = currMoveOutYr + '-' + currMoveOutMo + '-' + currMoveOutDy;

var currNoticedt = document.getElementById("dtCurrNoticeDate_id").value;
var currNoticeYr = currNoticedt.substring(0,4);
var currNoticeMo = currNoticedt.substring(4,6);
var currNoticeDy = currNoticedt.substring(6);
var CurrNoticeDate = currNoticeYr + '-' + currNoticeMo + '-' + currNoticeDy;

if (phyMovOutDtStr !== '')
	{phyMoveOutDiff = ( Math.floor((Date.UTC(currMoveOutYr, currMoveOutMo, currMoveOutDy) -
	 Date.UTC(mvy,mvm, mvd) ) /(1000 * 60 * 60 * 24)));
	 phyMoveOutDiff = Math.abs(phyMoveOutDiff);}
else
	{var phyMoveOutDiff = 0;}

if (pchgthruDtStr !== '')
	{finMoveOutdiff = ( Math.floor((Date.UTC(currChgThruYr, currChgThruMo, currChgThruDy) -
	 Date.UTC(pmy,pmm, pmd) ) /(1000 * 60 * 60 * 24)));
		 finMoveOutdiff = Math.abs(finMoveOutdiff);	 }
else
	{var finMoveOutdiff = 0;}
	
if (NoticeDtStr !== '')
	{finNoticediff = ( Math.floor((Date.UTC(currNoticeYr, currNoticeMo, currNoticeDy) -
	 Date.UTC(nty,ntm, ntd) ) /(1000 * 60 * 60 * 24)));
		 finNoticediff = Math.abs(finNoticediff);	 }
else
	{var finNoticediff = 0;} 
	
if (phyMovOutDtStr == ''  && pchgthruDtStr == '' && NoticeDtStr == '')
	{alert ('No date changes were entered');
	return false;}
<!--- gthota 10/25/2017  - commented because AR admin access not setup properly  --->		
//else if ((phyMoveOutDiff > 30) && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make adjustments greater than 30 days');
//	return false;}
//else if ((finMoveOutdiff > 30)  && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make adjustments greater than 30 days');
//	return false;}	
//else if ((finNoticediff > 30)  && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make adjustments greater than 30 days');
//	return false;}		
<!--- gthota 10/25/2017  - commented END code    --->

else if ((phyMovOutDtStr !== '') && (mvm == '00') || (mvd == '00'))
{alert ('Please fix Physical Move Out date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ( (phyMovOutDtStr !== '') &&(mvy < '2000') || (mvy > '2025'))
{alert ('Please fix Physical Move Out date \n The year value is out of range \n or improper format');
	return false;}	
 if ((pchgthruDtStr !== '') &&(pmm == '00') || (pmd == '00'))
{alert ('Please fix Financial Move Out date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ((pchgthruDtStr !== '') &&(pmy < '2000') || (pmy > '2025'))
{alert ('Please fix Financial Move Out date \n The year value is out of range \n or improper format');
	return false;}	
else if (commentchk == ''){
	alert('Comments Are Required: \n Please enter who requested the change and why');
	document.getElementById("comments_ID").focus();	
	return false;}	
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr !== '') && (phyMovOutDtStr> pchgthruDtStr) )
	{alert('The Physical Move Out Date entered CANNOT BE AFTER the Financial Move Out Date');
	return false;}	
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr == '') && (phyMovOutDtStr > currdtchargethrough) )
	{alert('The Physical Move Out Date entered CANNOT BE AFTER the current Financial Move Out Date');
	return false;}	
else if ((phyMovOutDtStr == '' )&& (pchgthruDtStr !== '') && (pchgthruDtStr <  currdtmoveout))
	{alert('Financial Move Out Date CANNOT be changed to a date before current Physical Move Out date');
	return false;}	
else if ((phyMovOutDtStr !== '') && (phyMovOutDtStr < curreffdt ))
	{alert(	'Physical Move Out Date Cannot be before Physical Move In Date or Financial Possession Date ' );
	return false;}	
else if ((pchgthruDtStr !== '') && (pchgthruDtStr < curreffdt ))
	{alert(	'Financial Move Out ' +   'Cannot be before Physical Move In Date ' );
	return false;}	

else if ((NoticeDtStr !== '') && (phyMovOutDtStr == '' ) && (NoticeDtStr > currdtmoveout ))
	{alert(	'Move Out Notice Date Cannot be greater than Physical Move Out Date ' );
	return false;}	
else if ((NoticeDtStr !== '') && (phyMovOutDtStr !== '' ) && (NoticeDtStr > phyMovOutDtStr ))
	{alert(	'Move Out Notice Date Cannot be greater than Physical Move Out Date ' );
	return false;}	
else if ((NoticeDtStr !== '') && (pchgthruDtStr == '' ) && (NoticeDtStr > currdtchargethrough ))
	{alert(	'Move Out Notice Date Cannot be greater than Financial Move Out Date ' );
	return false;}	
else if ((NoticeDtStr !== '') && (pchgthruDtStr !== '' ) && (NoticeDtStr > pchgthruDtStr ))
	{alert(	'Move Out Notice Date Cannot be greater than Financial Move Out Date ' );
	return false;}	
else if ((NoticeDtStr !== '')  && (NoticeDtStr < currmoveindt ))
	{alert(	'Move Out Notice Date Cannot be Before Physical Move In Date ' );
	return false;}	
else if ((NoticeDtStr !== '')  && (NoticeDtStr < curreffdt ))
	{alert(	'Move Out Notice Date Cannot be BEfore Financial Move In Date ' );
	return false;}	
	
//else if ((pchgthruDt !== '') && (currmoveindt > pchgthruDt ))
//	{alert(	'Financial Move Out Date: ' +
//	 + pchgthruDt.substring(0,4) + '-'
//	 + pchgthruDt.substring(4,6) + '-'
//	 + pchgthruDt.substring(6,8) 	 
//	  )
//	  'Cannot be before Move In Date (' 
//	 + currmoveindt.substring(0,4) + '-'
//	 + currmoveindt.substring(4,6) + '-'
//	 + currmoveindt.substring(6,8) 
//		  'or Financial Possession Date (' 
//	 + curreffdt.substring(0,4) + '-'
//	 + curreffdt.substring(4,6) + '-'
//	 + curreffdt.substring(6,8) 
//	return false;}		
else if (commentchk == ''){
	alert('Comments Are Required: \n Please enter who requested the change and why');
	return false;}
}

	</script> 
<SCRIPT>	

		function showmoveout(string){
			if (string.checked == true){ 
				document.getElementById("moveout_id1").style.display='none';
				document.getElementById("moveout_id2").style.display='block';		
				document.getElementById("moveoutdt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showmoveout2(string){
			if (string.checked == true){ 
				document.getElementById("moveout_id1").style.display='block';
				document.getElementById("moveout_id2").style.display='none';	
				document.getElementById("moveoutdt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}

		function showChgThrough(string){
			if (string.checked == true){ 
				document.getElementById("chgthrough_id1").style.display='none';
				document.getElementById("chgthrough_id2").style.display='block';		
				document.getElementById("chgthroughdt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showChgThrough2(string){
			if (string.checked == true){ 
				document.getElementById("chgthrough_id1").style.display='block';
				document.getElementById("chgthrough_id2").style.display='none';	
				document.getElementById("chgthroughdt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}
	//dtNoticeDate
		function showNotice(string){
			if (string.checked == true){ 
				document.getElementById("noticedt_id1").style.display='none';
				document.getElementById("noticedt_id2").style.display='block';		
				document.getElementById("noticedt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showNotice2(string){
			if (string.checked == true){ 
				document.getElementById("noticedt_id1").style.display='block';
				document.getElementById("noticedt_id2").style.display='none';	
				document.getElementById("noticedt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}	
//	dtNoticeDate							
		function showcomments(string){
			if (string == 1){
			if (document.getElementById("SaveID").style.display !== 'block'){
			document.getElementById("SaveID").style.display='block';
				o="Required: Please enter the name of the person requesting the date change and the reason for the date change<br> Comments: <TEXTAREA COLS='50' ROWS=3 NAME='cComments' ID='comments_ID'></TEXTAREA>";
			//	o="<INPUT TYPE='submit' NAME='Save' VALUE='Save' STYLE='color:red; text-align:center;'>";
				//o+="<INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick=location.href='MoveInAddendum.cfm?ID=#url.ID#'>";
				document.all['comments'].innerHTML=o;
			}}
			else {document.getElementById("SaveID").style.display='none';}
			// { document.all['comments'].innerHTML=''; string.checked = false; }
		}
	</SCRIPT>
<cfoutput>
	<h1 class="PageTitle"> Tips 4 - Move Out Dates Edit </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
<!--- <cfdump var="#qtenant#">
<cfdump var="#qAddendumHistory#"> --->
	<FORM NAME="MoveOutAddendum" ACTION="MoveOutAddendumAction.cfm?ShowBtn=#ShowBtn#" METHOD="POST"
		 onsubmit="return verifyDates();" >
	
	<!--- ==============================================================================
	Set Addendum Type to 2 (HardCoded to MoveOut)
	The Addendum Type Table should remain a reference table and static
	=============================================================================== --->
	<INPUT TYPE="hidden" NAME="iAddendumType_ID" VALUE="2">
 	<INPUT TYPE="hidden" NAME="iTenant_ID" VALUE="#qTenant.iTenant_ID#">
	<input type="hidden" name="dtchargethrough" id="currdtchargethrough_id" 
		value="#dateformat(qtenant.dtchargethrough,'yyyymmdd')#" />
	<input type="hidden" name="dtmoveout" id="currdtmoveout_id" 
		value="#dateformat(qtenant.dtmoveout,'yyyymmdd')#" />	
	<input type="hidden" name="curreffdate" id="curreffdate_id" 
		value="#dateformat(qtenant.dtrenteffective,'yyyymmdd')#" /> 
	<input type="hidden" name="currmovindate" id="currmovindate_id" 
		value="#dateformat(qtenant.dtmovein,'yyyymmdd')#" />
	<input type="hidden" name="ihouse_id" id="ihouse_id" 
		value="#qTenant.ihouse_id#" />
	<input type="hidden" name="iAptAddress_ID" id="iAptAddress_ID" value="#qTenant.iAptAddress_ID#" />
	<input type="hidden" name="iSPoints" id="iSPoints" value="#qTenant.iSPoints#" />	
	<input type="hidden" name="iSLPoints" id="iSLPoints" value="#qTenant.iSLPoints#" />		 
<CFIF ((ListFindNoCase(qusercodeblock.groupid,285) GT 0) and (session.username is 'jgedelman'))>
	<input  type="hidden" name="MvInMgr" id="MvInMgr_ID" value="Y" />
<cfelse>
	<input  type="hidden" name="MvInMgr" id="MvInMgr_ID" value="N" />	
</cfif>	 	
	<input type="hidden" name="dtCurrNoticeDate" id="dtCurrNoticeDate_id" 
		value="#dateformat(qtenant.dtNoticeDate,'yyyymmdd')#" />
		<TABLE>
			<TR>
				<TH COLSPAN="100%" STYLE="text-align: center;">
					Move Out Dates Adjustments - Addendum
				</TH>
			</TR>
			<TR>
				<TD nowrap="nowrap" colspan="4" STYLE="text-align:center; font-weight:bold;">
				Tenant Information<br />#qTenant.FullName# (#qTenant.cSolomonKey#)</TD>
			</TR>
			<tr>
				<td>&nbsp;</td>
				<td  style="text-align:center;">Financial Possession Date</td>
				<td  style="text-align:center;">Physical Move In Date</td>
				<td>&nbsp;</td>				
			</tr>			
			<tr>
				<td>&nbsp;</td>
 				<td colspan="1" style="text-align:center; color: ##FF0000">
					 #dateformat(qtenant.dtrenteffective,'mm/dd/yyyy')#</td>	
 				<td colspan="1" style="text-align:center; color: ##FF0000">
					 #dateformat(qtenant.dtmovein,'mm/dd/yyyy')#</td>
				<td>&nbsp;</td>					 					 		
			</tr>	
 <!---  --->
 			<TR  id="noticedt_id1"  style="display:block; background-color:##FFFF80">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Move Out Notice Date:<br /> #DateFormat(qTenant.dtnoticedate,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showNotice(this);">
				</td>
			</TR>	
			<TR  id="noticedt_id2"  style="display:none; background-color:##FFFF80">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Move Out Notice Date:<br /> #DateFormat(qTenant.dtnoticedate,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Move Out Notice Date:<br />
					<INPUT TYPE='Text' NAME='noticedt' VALUE='' SIZE='10' id='noticedt_id' onKeyUp='Dates(this);'> 
				</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showNotice2(this);"></td>
			</TR>
 <!---  ---> 		
			<TR  id="moveout_id1"  style="display:block; background-color:##FFFF80">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Physical Move Out Date:<br /> #DateFormat(qTenant.dtmoveout,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showmoveout(this);">
				</td>
			</TR>	
			<TR  id="moveout_id2"  style="display:none; background-color:##FFFF80">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Physical Move Out Date:<br /> #DateFormat(qTenant.dtmoveout,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Physical Move Out Date:<br />
					<INPUT TYPE='Text' NAME='moveoutdt' 
					VALUE='' SIZE='10' id='moveoutdt' onKeyUp='Dates(this);'> 
				</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showmoveout2(this);"></td>
			</TR>			
			<TR  id="chgthrough_id1"  style="display:block; background-color:##FFFF61">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Financial Move Out Date:<br /> #DateFormat(qTenant.dtChargeThrough,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showChgThrough(this);">
				</td>
			</TR>
			<TR  id="chgthrough_id2"  style="display:none; background-color:##FFFF61">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Financial Move Out Date:<br /> #DateFormat(qTenant.dtChargeThrough,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Financial Move Out Date:<br />
					<INPUT TYPE='Text' NAME='chgthroughdt' 
					VALUE='' SIZE='10' id='chgthroughdt' onKeyUp='Dates(this);'>
				</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showChgThrough2(this);"></td>
			</TR>	
			<TR><TD COLSPAN=100% STYLE="text-align:center; font-weight:bold; color:##FF0000"><DIV ID="comments"></DIV></TD></TR>			
			<tr id="SaveID" style="display:none">
				<td>&nbsp;</td>
				<td><INPUT TYPE='submit' NAME='Save' VALUE='Save' 
				STYLE='color:red; text-align:center;'></td>
				<td><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel/Reset' 
				onClick=location.href='MoveOutAddendum.cfm?ID=#url.ID#'></td>
				<td>&nbsp;</td>
			</tr> 
		</TABLE> 
	</FORM>
	
  	<CFIF qAddendumHistory.RecordCount GT 0>
		<TABLE>
			<TR>
				<TH>Addendum<br /> Number</TH>
				<TH>Change<br /> Date</TH>
				<TH>From<br /> Date</TH>
				<TH>To<br /> Date</TH>
				<TH>Comments</TH>
			</TR>			
		
			<CFLOOP QUERY="qAddendumHistory">
<!--- 			<cfset fromchgStrg = find('changed from:',qAddendumHistory.cComments)>
			<cfset fromstrg = mid(qAddendumHistory.cComments,(fromchgStrg+13) ,10)>
			
			<cfset tochgStrg = find('to:',qAddendumHistory.cComments)>	
			<cfset tostrg = mid(qAddendumHistory.cComments,(tochgStrg+4) ,10)>	 --->
				<TR>
					<TD>#cAddendumNumber#</TD>
					<TD STYLE="text-align: center;">#DateFormat(dtAddendum,'mm/dd/yyyy')#</TD>
					<TD STYLE="text-align: center;">#dateformat(dtChangeFrom,'mm/dd/yyyy')#</TD>
					<TD STYLE="text-align: center;">#dateformat(dtChangeTo,'mm/dd/yyyy')#</TD>				
					<TD>#cComments#</TD>
				</TR>
			</CFLOOP>
 		</TABLE>
	</CFIF> 

<!--- 	<BR>
	<CFIF IsDefined("url.mosummary") AND url.mosummary EQ 1>
		<A HREF="../MoveOut/MoveOutFormSummary.cfm?ID=#qTenant.iTenant_ID#&ShowBtn=#ShowBtn#" STYLE="font-size: 18;">Exit To Move Out Summary Screen</A>
	<CFELSE>
		<CFIF ShowBtn>
			<A HREF="Registration.cfm?PreviousTenants=Checked" STYLE="font-size: 18;">Exit and Return to Registration Screen.</A>
		<CFELSE>
			<A HREF="../census/FinalizeMoveOut.cfm" STYLE="font-size: 18;">EXIT</A>
		</CFIF>
	</CFIF> --->

</CFOUTPUT>

<!--- ==============================================================================
Include intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">