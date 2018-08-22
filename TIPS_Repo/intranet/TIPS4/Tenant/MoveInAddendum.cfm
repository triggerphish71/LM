<!--- *******************************************************************************
Name:			MoveInAddendum.cfm
Process:		Alter finalized Moved In (MI) data separate from the MI Invoice

Called by: 		Registration.cfm
Calls/Submits:	MoveInAddendumAction.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            02/07/2002      Original Authorship
Steven Farmer           09/05/2017      Revised to allow AR to change dtmovein and dtrenteffective
GThota                  10/25/2017      Commented out alert message for addendum date more than 30 days.
******************************************************************************** --->


<CFINCLUDE TEMPLATE="../../Header.cfm">
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<CFSET Month=#DateFormat(now(),"mm")#>
<CFSET Day=#DateFormat(now(),"dd")#>
<CFSET Year=#DateFormat(now(),"yyyy")#>

<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	(T.cFirstName + ' ' + T.cLastName) as FullName
	,TS.dtMoveIn,ts.dtrenteffective,ts.dtchargethrough, ts.dtmoveout
	,T.cSolomonKey, TS.iResidencyType_ID, T.iTenant_ID
	,iSPoints, iAptAddress_ID, iHouse_ID,iSLPoints, ts.dtmoveoutprojecteddate
	,ts.dtNoticeDate
	FROM 	TENANT T
	JOIN TENANTSTATE TS ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
	WHERE	T.iTenant_ID = #url.ID#
	AND		T.dtRowDeleted IS NULL
</CFQUERY>

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
 
<CFOUTPUT>
	<SCRIPT>	
		function showrenteff(string){
			if (string.checked == true){ 
				document.getElementById("renteff_id1").style.display='none';
				document.getElementById("renteff_id2").style.display='block';
				document.getElementById("renteffdt").focus();						
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showrenteff2(string){
			if (string.checked == true){ 
				document.getElementById("renteff_id1").style.display='block';
				document.getElementById("renteff_id2").style.display='none';
				document.getElementById("renteffdt").value = '';		
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}	
		
		function showmovein(string){
			if (string.checked == true){ 
				document.getElementById("movein_id1").style.display='none';
				document.getElementById("movein_id2").style.display='block';		
				document.getElementById("moveindt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showmovein2(string){
			if (string.checked == true){ 
				document.getElementById("movein_id1").style.display='block';
				document.getElementById("movein_id2").style.display='none';	
				document.getElementById("moveindt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}	
		function showProjDt(string){
			if (string.checked == true){ 
				document.getElementById("ProjDt_id1").style.display='none';
				document.getElementById("ProjDt_id2").style.display='block';		
				document.getElementById("ProjDt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showProjDt2(string){
			if (string.checked == true){ 
				document.getElementById("ProjDt_id2").style.display='block';
				document.getElementById("ProjDt_id2").style.display='none';	
				document.getElementById("ProjDt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}					
		
		function showcomments(string){
			if (string == 1){document.getElementById("SaveID").style.display='block';
			 	o="Required: Please enter the name of the person requesting the date change and the reason for the date change<br> Comments: <TEXTAREA COLS='50' ROWS=3 NAME='cComments' ID='comments_ID'></TEXTAREA>";
			//	o="<INPUT TYPE='submit' NAME='Save' VALUE='Save' STYLE='color:red; text-align:center;'>";
				//o+="<INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick=location.href='MoveInAddendum.cfm?ID=#url.ID#'>";
			 	document.all['comments'].innerHTML=o;
			}
			else {document.getElementById("SaveID").style.display='none';}
			// { document.all['comments'].innerHTML=''; string.checked = false; }
		}
	</SCRIPT>
</CFOUTPUT>

<script  language="javascript">
   
function verifyDates(){
var residenttype = document.getElementById("Residencytype_ID").value;
var	phyMovInDt = document.getElementById("moveindt").value;
var mvy = phyMovInDt.substring(6,10);
var mvm = phyMovInDt.substring(0,2);
var mvd = phyMovInDt.substring(3,5);
var phyMovInDtStr = mvy+mvm+mvd;  
 var phyMoveInDate = mvy + '-' + mvm + '-' + mvd;
var rentEffDt =  document.getElementById("renteffdt").value;
var rey = rentEffDt.substring(6,10);
var rem = rentEffDt.substring(0,2);
var red = rentEffDt.substring(3,5);
var rentEffDtStr = rey+rem+red;  
var rentEffectiveDate = rey + '-' + rem + '-' + red; 

var ProjMoveOutDt =  document.getElementById("ProjDt_ID").value;
var pmy = ProjMoveOutDt.substring(6,10);
var pmm = ProjMoveOutDt.substring(0,2);
var pmd = ProjMoveOutDt.substring(3,5);
var ProjDtStr = pmy+pmm+pmd;  
var ProjMoveOutDate = pmy + '-' + pmm + '-' + pmd; 

var currNoticedt = document.getElementById("dtNoticeDate_id").value;
var currNoticeYr = currNoticedt.substring(0,4);
var currNoticeMo = currNoticedt.substring(4,6);
var currNoticeDy = currNoticedt.substring(6);
var CurrNoticeDate = currNoticeYr + '-' + currNoticeMo + '-' + currNoticeDy;

var currmoveindt = document.getElementById("currmovindate_id").value;
var currmovinyr = currmoveindt.substring(0,4);
var currmovinmo = currmoveindt.substring(4,6);
var currmovindy = currmoveindt.substring(6);
var CurrMoveInDate = currmovinyr + '-' + currmovinmo + '-' + currmovindy;
 //alert(currmoveindt + ' ' + CurrMoveInDate);
var moveoutdt = document.getElementById("dtmoveout_id").value;

var curreffdt = document.getElementById("curreffdate_id").value;
var curreffectiveyr = curreffdt.substring(0,4);
var curreffectivemo = curreffdt.substring(4,6);
var curreffectivedy = curreffdt.substring(6);
var CurrEffectiveDate = curreffectiveyr + '-' + curreffectivemo + '-' + curreffectivedy;

var currProjMvOutdt = document.getElementById("currProjMoveOutdate_id").value;
var currProjMvOutyr = currProjMvOutdt.substring(0,4);
var currProjMvOutmo = currProjMvOutdt.substring(4,6);
var currProjMvOutdy = currProjMvOutdt.substring(6);
var currProjMvOutDate = currProjMvOutyr + '-' + currProjMvOutmo + '-' + currProjMvOutdy;

 var currNoticedt = document.getElementById("dtNoticeDate_id").value; 
 if (currNoticedt !==''){
 	var currNoticeyr = currNoticedt.substring(0,4);
	var currNoticemo = currNoticedt.substring(4,6);
	var currNoticedy = currNoticedt.substring(6);
	var currNoticeDate = currNoticeyr + '-' + currNoticemo + '-' + currNoticedy;}

 var currMoveOutdt = document.getElementById("dtmoveout_id").value;	
 if (currMoveOutdt !== ''){
	var currMoveOuttyr = currMoveOutdt.substring(0,4);
	var currMoveOutmo = currMoveOutdt.substring(4,6);
	var currMoveOutdy = currMoveOutdt.substring(6);
	var currMoveOutDate = currMoveOuttyr + '-' + currMoveOutmo + '-' + currMoveOutdy;}

var currChgThrudt = document.getElementById("dtchargethrough_id").value;
if (currChgThrudt !== ''){
	var currChgThruyr = currChgThrudt.substring(0,4);
	var currChgThrumo = currChgThrudt.substring(4,6);
	var currChgThrudy = currChgThrudt.substring(6);
	var currChgThruDate = currChgThruyr + '-' + currChgThrumo + '-' + currChgThrudy;}



var commentchk = document.getElementById("cComments").value;

if (phyMovInDtStr !== '')
	//{var phymoveindiff = dateDiffInDays(phyMoveInDate ,CurrMoveInDate);}
	{phymoveindiff = ( Math.floor((Date.UTC(currmovinyr, currmovinmo, currmovindy) -
	 Date.UTC(mvy,mvm, mvd) ) /(1000 * 60 * 60 * 24)));
	 phymoveindiff = Math.abs(phymoveindiff);}
else
	{var phymoveindiff = 0;}

if (rentEffDtStr !== '')
	{effmoveindiff = ( Math.floor((Date.UTC(curreffectiveyr, curreffectivemo, curreffectivedy) -
	 Date.UTC(rey,rem, red) ) /(1000 * 60 * 60 * 24)));
		 effmoveindiff = Math.abs(effmoveindiff); }
else
	{var effmoveindiff = 0;	}
	
if (ProjDtStr !== '')
	{projMvOutdiff = ( Math.floor((Date.UTC(currProjMvOutyr, currProjMvOutmo, currProjMvOutdy) -
	 Date.UTC(pmy,pmm, pmd) ) /(1000 * 60 * 60 * 24)));
		 projMvOutdiff = Math.abs(projMvOutdiff); }
else
	{var projMvOutdiff = 0;} 
 
 
var MoveInMgr = document.getElementById("MvInMgr_ID").value;

//alert(' newphymvin ' + phyMovInDt + ' '  +  phyMovInDtStr + ' ' + '\n newrenteff ' +  rentEffDt + ' ' + rentEffDtStr + '\n cmvin ' +  currmoveindt + '\n curreff ' + curreffdt + ' :: '+ document.getElementById("curreffdate_id").value + '\n mvout ' + moveoutdt);
//alert(phymoveindiff + ' ' + effmoveindiff + ' ' + phyMovInDtStr + ' ' +currmoveindt );
if (phyMovInDtStr == '' && rentEffDtStr == '' && ProjDtStr == '')
	{alert ('No date changes were entered');
	return false;}
<!--- gthota 10/25/2017  - commented because AR admin access not setup properly    --->	
//else if ((phymoveindiff > 30) && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make adjustments greater than 30 days');
//	return false;}
//else if ((effmoveindiff > 30)  && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make adjustments greater than 30 days' );
//	return false;}	
//else if ((projMvOutdiff > 30)  && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make adjustments greater than 30 days' );
//	return false;}	
<!--- gthota 10/25/2017  - commented END code    --->	

else if ((phyMovInDtStr !== '') && (mvm == '00') || (mvd == '00'))
{alert ('Please fix Physical Move In date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ( (phyMovInDtStr !== '') &&(mvy < '2000') || (mvy > '2025'))
{alert ('Please fix Physical Move In date ' + phyMovInDtStr + ' \n The year value is out of range \n or improper format');
	return false;}	
	
 if ((rentEffDtStr !== '') &&(rem == '00') || (red == '00'))
	{alert ('Please fix Financial Possession date ' + rentEffDtStr + ' \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ((rentEffDtStr !== '') &&(rey < '2000') || (rey > '2025'))
	{alert ('Please fix Financial Possession date ' + rentEffDtStr + ' \n The year value is out of range \n or improper format');	
	return false;}		
	
else if (commentchk == ''){
	alert('Comments Are Required: \n Please enter who requested the change and why');
	document.getElementById("comments_ID").focus();
	return false;}	
else if ((phyMovInDtStr !== '' )&& (rentEffDtStr !== '') && (rentEffDtStr <= phyMovInDtStr) && (commentchk !=='') && (rentEffDtStr < currProjMvOutdt)  && (phyMovInDtStr < currProjMvOutdt))
	{return true;}
else if ((rentEffDtStr !== '' ) && (phyMovInDtStr !== '' )&&(moveoutdt == '' ) && (rentEffDtStr > phyMovInDtStr) )
	{alert('Financial Possession Date CANNOT be After Move In Date');
	return false;}

else if ((phyMovInDtStr !== '' ) && (rentEffDtStr == '' ) && (curreffdt > phyMovInDtStr) )
	{alert('Move In Date ( '
	 + phyMovInDtStr.substring(0,4) + '-'
	 + phyMovInDtStr.substring(4,6) + '-'
	 + phyMovInDtStr.substring(6,8)   + ') CANNOT be BEFORE Financial Possession Date');
	return false;}
	
else if ((rentEffDtStr !== '' ) && (ProjDtStr !== '') && (rentEffDtStr > ProjDtStr) && (residenttype == 3) )
	{alert('Financial Possession Date CANNOT be After Projected Move Out Date');
	return false;}
		
else if ((rentEffDtStr !== '' ) && (ProjDtStr == '')  && (rentEffDtStr > currProjMvOutdt) && (residenttype == 3) )
	{alert('Financial Possession Date CANNOT be After Projected Move Out Date');
	return false;}	

else if ((phyMovInDtStr !== '' ) && (ProjDtStr !== '') && (phyMovInDtStr > ProjDtStr) && (residenttype == 3) )
	{alert('Physical Move In Date CANNOT be After Projected Move Out Date');
	return false;}
		
else if ((phyMovInDtStr !== '' ) && (ProjDtStr == '')  && (phyMovInDtStr > currProjMvOutdt) && (residenttype == 3) )
	{alert('Physical Move In Date CANNOT be After Projected Move Out Date');
	return false;}	

else if ((ProjDtStr !== '' ) && (phyMovInDtStr == '')  && (ProjDtStr < currmoveindt)  && (residenttype == 3))
	{alert('Projected Move Out Date CANNOT be before Physical Move In date');
	return false;}
else if ((ProjDtStr !== '' ) && (phyMovInDtStr !== '')  && (ProjDtStr < phyMovInDtStr) && (residenttype == 3) )
	{alert('Projected Move Out Date CANNOT be before Physical Move In date');
	return false;}
else if ((ProjDtStr !== '' ) && (rentEffDtStr == '')  && (ProjDtStr < rentEffDtStr) && (residenttype == 3) )
	{alert('Projected Move Out Date CANNOT be before Financial Possession Move In date');
	return false;}
else if ((ProjDtStr !== '' ) && (phyMovInDtStr !== '')  && (ProjDtStr < curreffdt)  && (residenttype == 3))
	{alert('Projected Move Out Date CANNOT be before Financial Possession Move In date');
	return false;}	
	
else if ((moveoutdt !== '') && (phyMovInDtStr > moveoutdt ))
	{alert('Move In Date (' + 
	 + phyMovInDtStr.substring(0,4) + '-'
	 + phyMovInDtStr.substring(4,6) + '-'
	 + phyMovInDtStr.substring(6,8) 	
	 + ') CANNOT be After Move Out Date: ' +
	 + moveoutdt.substring(0,4) + '-'
	 + moveoutdt.substring(4,6) + '-'
	 + moveoutdt.substring(6,8) 	 
	  );
	return false;}	
	
else if ((rentEffDtStr == '') && (phyMovInDtStr !== '') && ( phyMovInDtStr < curreffdt))
		{alert('Move In Date CANNOT be changed to a date less then Financial Possession date.');
		return false;}

else if ((phyMovInDtStr !== '') &&  (phyMovInDtStr < rentEffDtStr))
		{alert ('Physical Move In Date Must be Equal or Greater Than Financial Possession Date');
		return false;}
else if ((phyMovInDtStr == '') && (currmoveindt < rentEffDtStr))
		{alert ('Financial Possession Date must be less then or equal to Physical Move In Date');
		return false;}
		
else if ((ProjDtStr !== '' ) && (currChgThrudt !== '')  && (ProjDtStr > currChgThrudt) )
	{alert('Projected Move Out Date Must be Equal To or Before Financial Move Out date');
	return false;}		
  
else if ((ProjDtStr !== '' ) && (currMoveOutdt !== '')  && (ProjDtStr > currMoveOutdt) )
	{alert('Projected Move Out Date Muse be Equal To or Before Physical Move Out date');
	return false;}	
		
}
</script>
	<h1 class="PageTitle"> Tips 4 - Move In Dates Edit </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
<CFOUTPUT>
	<BR><BR>
	<A HREF="TenantEdit.cfm?ID=#url.ID#" STYLE="font-size: 18;">Exit and Return to Tenant Edit Screen.</A>
	<FORM NAME="MoveInAddendum" ACTION="MoveInAddendumAction.cfm" METHOD="POST" onsubmit="return verifyDates();">
	<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#qTenant.iTenant_ID#">
	<input type="hidden" name="dtchargethrough" id="dtchargethrough_id" 
		value="#dateformat(qtenant.dtchargethrough,'yyyymmdd')#" />
	<input type="hidden" name="dtmoveout" id="dtmoveout_id" 
		value="#dateformat(qtenant.dtmoveout,'yyyymmdd')#" />	
	<input type="hidden" name="curreffdate" id="curreffdate_id"   
		value="#dateformat(qtenant.dtrenteffective,'yyyymmdd')#" /> 
	<input type="hidden" name="currmovindate" id="currmovindate_id" 
		value="#dateformat(qtenant.dtmovein,'yyyymmdd')#" />
	<input type="hidden" name="dtNoticeDate" id="dtNoticeDate_id" 
		value="#dateformat(qtenant.dtNoticeDate,'yyyymmdd')#" />		
	<input type="hidden" name="currProjMoveOutdate" id="currProjMoveOutdate_id" 
		value="#dateformat(qtenant.dtmoveoutprojecteddate,'yyyymmdd')#" />		
	<input type="hidden" name="iSPoints" id="iSPoints" 
		value="#qtenant.iSPoints#" />	
	<input type="hidden" name="iHouse_ID" id="iHouse_ID" 
		value="#qtenant.iHouse_ID#" />	
	<input type="hidden" name="iAptAddress_ID" id="iAptAddress_ID" 
		value="#qtenant.iAptAddress_ID#" />		
	<input type="hidden" name="iSLPoints" id="iSLPoints" 
		value="#qtenant.iSLPoints#" />				
	<input type="hidden" name="ResidencyType" id="Residencytype_ID" value="#qtenant.iResidencyType_ID#" />		
	<!--- ==============================================================================
	Set Addendum Type to 2 (HardCoded to MoveIn)
	The Addendum Type Table should remain a reference table and static
	=============================================================================== --->
	<INPUT TYPE="Hidden" NAME="iAddendumType_ID" VALUE="1">
	
<CFIF ((ListFindNoCase(qusercodeblock.groupid,285) GT 0) and (session.username is 'jgedelman'))>
	<input  type="hidden" name="MvInMgr" id="MvInMgr_ID" value="Y" />
<cfelse>
	<input  type="hidden" name="MvInMgr" id="MvInMgr_ID" value="N" />	
</cfif>
	
		<TABLE STYLE="text-align: center;">
			<TR><TH COLSPAN="100%">Move In Dates Adjustments - Addendum</TH></TR>
			<TR>
				<TD nowrap="nowrap" colspan="4" STYLE="width: 25%; font-weight:bold">
				Tenant Information<br />#qTenant.FullName# (#qTenant.cSolomonKey#)</TD>
			</TR>
			<cfif #qtenant.dtmoveout# is not ''>
				<tr>
					<td colspan="4" style="text-align:center; color: ##FF0000">
					This Resident is moved out. Move Out Date: #dateformat(qtenant.dtmoveout,'mm/dd/yyyy')#<br />
					Move In Dates cannot be after the Move Out date.</td>
				</tr>
				<tr>
					<td>Move Out Notice Date: <br />#DateFormat(qtenant.dtNoticeDate,'mm/dd/yyyy')#</td>
					<td colspan="2" nowrap="nowrap">Physical Move Out: <br />#DateFormat(qtenant.dtmoveout,'mm/dd/yyyy')#</td>
					<td>Financial Move Out Date: <br />#DateFormat(qtenant.dtchargethrough,'mm/dd/yyyy')#  </td>
				</tr>
			</cfif>
			<TR  id="movein_id1"  style="display:block; background-color:##FFFF80">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Physical Move In Date:<br /> #DateFormat(qTenant.dtMoveIn,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showmovein(this);">
				</td>
			</TR>
			<TR  id="movein_id2"  style="display:none; background-color:##FFFF80">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Physical Move In Date:<br /> #DateFormat(qTenant.dtMoveIn,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Physical Move In Date:<br />
					<INPUT TYPE='Text' NAME='phydate' 
					VALUE='' SIZE='10' id='moveindt' onKeyUp='Dates(this);'>
				</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showmovein2(this);"></td>
			</TR>			
	
			<TR id="renteff_id1"  style="display:block; background-color: ##80FFFF">
				<td nowrap="nowrap" style="font-weight:bold; text-align:center">
					Financial Possession Date:<br /> #DateFormat(qTenant.dtRentEffective,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">Click to Change:
					<INPUT TYPE="Checkbox" NAME="changedate" onClick="showrenteff(this);"></td>
			</TR>
			<TR id="renteff_id2"  style="display:none; background-color:  ##80FFFF">
				<td nowrap="nowrap" style="font-weight:bold; text-align:center">Financial Possession Date:<br /> #DateFormat(qTenant.dtRentEffective,"mm/dd/yyyy")#</TD>
				
				<TD style="text-align:center; font-weight:bold">Enter New Financial Possession Date:<br />
					<INPUT TYPE='Text' NAME='RentEffDt' 
						VALUE='' SIZE='10' id='renteffdt' onKeyUp='Dates(this);'>
				</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:	<INPUT TYPE="Checkbox" NAME="changedate" onClick="showrenteff2(this);">
				</td>
			</TR>		
			<cfif qtenant.iResidencyType_ID is 3>
				<tr id="ProjDt_id1"  style="display:block; background-color: ##FFFF80">
					<td nowrap="nowrap" style="font-weight:bold; text-align:center">
						Projected Move Out Date: <br />#dateformat(qtenant.dtmoveoutprojecteddate,'mm/dd/yyyy')#</td>
					<TD>&nbsp;</TD>
					<TD>&nbsp;</TD>
					<TD nowrap="nowrap" style="font-weight:bold; text-align:right">Click to Change:
						<INPUT TYPE="Checkbox" NAME="changedate" onClick="showProjDt(this);"></td>				
				</tr>
				<TR id="ProjDt_id2"  style="display:none; background-color:  ##FFFF80">
					<td nowrap="nowrap" style="font-weight:bold; text-align:center">
					Projected Move Out Date:<br /> #DateFormat(qTenant.dtmoveoutprojecteddate,"mm/dd/yyyy")#</TD>
					
					<TD style="text-align:center; font-weight:bold">Enter New Projected Move Out Date:<br />
						<INPUT TYPE='Text' NAME='ProjDt' 
							VALUE='' SIZE='10' id='ProjDt_ID' onKeyUp='Dates(this);'>
					</TD>
					<TD>&nbsp;</TD>
					<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
						Do Not Change:	<INPUT TYPE="Checkbox" NAME="changeProjdate" onClick="showProjDt2(this);">
					</td>
				</TR>	
			<cfelse>	
				<INPUT TYPE='hidden' NAME='ProjDt' VALUE='' SIZE='10' id='ProjDt_ID'>		
			</cfif>			
			<TR>
				<TD COLSPAN=100% STYLE="text-align:Center; font-weight:bold; color:##FF0000"><DIV ID="comments"></DIV></TD>
			</TR>
			<tr id="SaveID" style="display:none">
				<td>&nbsp;</td>
				<td><INPUT TYPE='submit' NAME='Save' VALUE='Save' 
				STYLE='color:red; text-align:center;'></td>
				<td><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel/Reset' 
				onClick=location.href='MoveInAddendum.cfm?ID=#url.ID#'></td>
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
			<cfset fromchgStrg = find('changed from:',qAddendumHistory.cComments)>
			<cfset fromstrg = mid(qAddendumHistory.cComments,(fromchgStrg+13) ,10)>
			
			<cfset tochgStrg = find('to:',qAddendumHistory.cComments)>	
			<cfset tostrg = mid(qAddendumHistory.cComments,(tochgStrg+4) ,10)>					
				<TR>
					<TD>#qAddendumHistory.cAddendumNumber#</TD>
					<TD STYLE="text-align: right;">#DateFormat(qAddendumHistory.dtAddendum,'mm/dd/yyyy')#</TD>
					<TD STYLE="text-align: right;">#dateformat(dtChangeFrom,'mm/dd/yyyy')#</TD>
					<TD STYLE="text-align: right;">#dateformat(dtChangeTo,'mm/dd/yyyy')#</TD>
					<TD>#qAddendumHistory.cComments#</TD>
				</TR>
			</CFLOOP>
		</TABLE>
	</CFIF>

	<BR>
	<A HREF="TenantEdit.cfm?ID=#url.ID#" STYLE="font-size: 18;">Exit and Return to Tenant Edit Screen.</A>

</CFOUTPUT>

<CFINCLUDE TEMPLATE="../../footer.cfm">