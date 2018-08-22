<!--- *******************************************************************************
Name:			RepsiteMoveOtCorrection.cfm
Process:		Correct Respite Move Out Dates

Called by: 		mainmenu.cfm
Calls/Submits:	RepsiteMoveOutCorrectionAction.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Steven Farmer           09/05/2017      Created to allow AR to change respite move out dates
******************************************************************************** --->
<cfparam name="TenantID" default="">

<CFINCLUDE TEMPLATE="../../Header.cfm">
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<CFSET Month=#DateFormat(now(),"mm")#>
<CFSET Day=#DateFormat(now(),"dd")#>
<CFSET Year=#DateFormat(now(),"yyyy")#>

<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	(T.cFirstName + ' ' + T.cLastName) as FullName
	,TS.dtMoveIn,ts.dtrenteffective,ts.dtchargethrough, ts.dtmoveout, T.cSolomonKey
	,TS.iResidencyType_ID, T.iTenant_ID, ts.dtmoveoutprojecteddate,dtNoticeDate
		,iSPoints, iAptAddress_ID, iHouse_ID,iSLPoints
	FROM 	TENANT T
	JOIN TENANTSTATE TS ON TS.iTenant_ID = T.iTenant_ID
	WHERE	T.iTenant_ID = #TenantID#
	AND		T.dtRowDeleted IS NULL  AND TS.dtRowDeleted IS NULL
</CFQUERY>
<!--- <cfdump var="#qTenant#"> --->

<CFQUERY NAME="qAddendumHistory" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	AddendumLog AL
	JOIN	AddendumType ADT ON (ADT.iAddendumType_ID = AL.iAddendumType_ID AND ADT.dtRowDeleted IS NULL)
	WHERE	AL.dtRowDeleted IS NULL
		AND		AL.iTenant_ID = #qTenant.iTenant_ID#
	ORDER BY AL.dtRowStart desc
</CFQUERY>
<!--- <cfdump var="#qAddendumHistory#"> --->

<cfquery name="qusercodeblock" DATASOURCE="#APPLICATION.datasource#">
  		select 	groupassignments.groupid, users.employeeid, passexpires, groups.groupname
		from 	dms.dbo.users,dms.dbo.groupassignments, dms.dbo.groups
		where	users.employeeid = groupassignments.userid 
		and groups.groupid = groupassignments.groupid
			and users.employeeid =  #session.userid#
			order by groupassignments.groupid
</cfquery>

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
		
		function showprojmoveout(string){
			if (string.checked == true){ 
				document.getElementById("projmoveout_id1").style.display='none';
				document.getElementById("projmoveout_id2").style.display='block';		
				document.getElementById("projmoveoutdt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showprojmoveout2(string){
			if (string.checked == true){ 
				document.getElementById("projmoveout_id1").style.display='block';
				document.getElementById("projmoveout_id2").style.display='none';	
				document.getElementById("projmoveoutdt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}	
		
		function shownoticemoveout(string){
			if (string.checked == true){ 
				document.getElementById("noticeout_id1").style.display='none';
				document.getElementById("noticeout_id2").style.display='block';		
				document.getElementById("noticeoutdt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function shownoticemoveout2(string){
			if (string.checked == true){ 
				document.getElementById("noticeout_id1").style.display='block';
				document.getElementById("noticeout_id2").style.display='none';	
				document.getElementById("noticeoutdt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}			
 
		function showresetall(string){
			if (string.checked == true){ 
				document.getElementById("resetall_id1").style.display='none';
				document.getElementById("resetall_id2").style.display='block';		
				//document.getElementById("noticeoutdt").focus();
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
		function showresetall2(string){
			if (string.checked == true){ 
				document.getElementById("resetall_id1").style.display='block';
				document.getElementById("resetall_id2").style.display='none';	
			//	document.getElementById("noticeoutdt").value = '';	
				showcomments(1);
			}
			else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
		}		
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
								
		function showcomments(string){
			if (string == 1){
			document.getElementById("commentsID").style.display='block';
			document.getElementById("SaveID").style.display='block';
	 //			o="Required: Please enter the name of the person requesting the date change and the reason for the date change<br> Comments: <TEXTAREA COLS='50' ROWS=3 NAME='cComments'></TEXTAREA>";
		//	 	o="<INPUT TYPE='submit' NAME='Save' VALUE='Save' STYLE='color:red; text-align:center;'>";
			//	 o+="<INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick=location.href='MoveInAddendum.cfm?ID=#url.ID#'>";
 				//document.all['comments'].innerHTML=o;
			}
			else {document.getElementById("commentsID").style.display='none';
			document.getElementById("SaveID").style.display='none';
			}
			//  { document.all['comments'].innerHTML=''; string.checked = false; }
		}
	</SCRIPT>
	<script language="javascript">
	function chkReset(){
//	if (MoveInAddendum.resetall.checked)
//{alert('yes');}
//else
//{alert('no');
//var resetallyes = 'Yes';
//}
//	if (confirm("Are you sure you want to reset all move out dates?") ) {
 //   if (confirm("Resident will be reset to move in status. \n Enter Reason why Resident Move Out Dates are being reset in// \'Comments\' section. \n Click \'Save\' to continue") ) {
 //      return true;}
//	    else {
 //       alert('Resident will not be reset to Move In status');
//		return false;    }
//	} 
//else {
 //   return false;}
	}
	</script>
<script  language="javascript">
function verifyDates(){    
//Physical Move  Out Date
var	phyMovOutDt = document.getElementById("moveoutdt").value;
var mvy = phyMovOutDt.substring(6,10);
var mvm = phyMovOutDt.substring(0,2);
var mvd = phyMovOutDt.substring(3,5);
var phyMovOutDtStr = mvy+mvm+mvd;  

 //Projected Move Out Date
var projmovoutDt =  document.getElementById("projmoveoutdt").value;
var rey = projmovoutDt.substring(6,10);
var rem = projmovoutDt.substring(0,2);
var red = projmovoutDt.substring(3,5);
var projmovoutDtStr = rey+rem+red;  
// Move Out Notice Date
var	noticeMovOutDt = document.getElementById("noticeoutdt").value;
var nmy = noticeMovOutDt.substring(6,10);
var nmm = noticeMovOutDt.substring(0,2);
var nmd = noticeMovOutDt.substring(3,5);
var noticeMovOutDtStr = nmy+nmm+nmd;  
//Charge Through- Financial Move Out Date;
var pchgthruDt =  document.getElementById("chgthroughdt").value;
var pmy = pchgthruDt.substring(6,10);
var pmm = pchgthruDt.substring(0,2);
var pmd = pchgthruDt.substring(3,5);
var pchgthruDtStr = pmy+pmm+pmd; 
//  alert (phyMovOutDtStr + ' ' + projmovoutDtStr + ' ' + noticeMovOutDtStr + ' ' + pchgthruDtStr);
var currmoveindt = document.getElementById("currmovindate_id").value;
var currdtmoveout = document.getElementById("currdtmoveout_id").value;
var currdtchargethrough = document.getElementById("currdtchargethrough_id").value;
var currdtProjected = document.getElementById("dtMoveOutProjectedDate_id").value;
var curreffdt = document.getElementById("curreffdate_id").value;
 
if (document.getElementById("MvInMgr_ID").value == 'Y')
	{var MoveInMgr = 'Y';}
else
	{var MoveInMgr = 'N';}
var commentchk = document.getElementById("cComments").value;
//if (MoveInAddendum.resetall.checked) 
//{//alert('yes');
// var resetallyes = 'Yes';
//}
//else
//{//alert('No');
// var resetallyes = 'No';
//}
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

var currProjMoveOutDt = document.getElementById("dtMoveOutProjectedDate_id").value;
var currProjMoveOutYr = currProjMoveOutDt.substring(0,4);
var currProjMoveOutMo = currProjMoveOutDt.substring(4,6);
var currProjMoveOutDy = currProjMoveOutDt.substring(6);
var CurrProjMoveOutDate = currProjMoveOutYr + '-' + currProjMoveOutMo + '-' + currProjMoveOutDy;

var currNoticedt = document.getElementById("dtNoticeDate_id").value;
var currNoticeYr = currNoticedt.substring(0,4);
var currNoticeMo = currNoticedt.substring(4,6);
var currNoticeDy = currNoticedt.substring(6);
var CurrNoticeDate = currNoticeYr + '-' + currNoticeMo + '-' + currNoticeDy;
  
if (phyMovOutDtStr !== '')
	{phyMoveOutDiff = ( Math.floor((Date.UTC(currMoveOutYr, currMoveOutMo, currMoveOutDy) -
	 Date.UTC(mvy,mvm, mvd) ) /(1000 * 60 * 60 * 24)));
	 phyMoveOutDiff = Math.abs(phyMoveOutDiff);
}
else
	{var phyMoveOutDiff = 0;}

if (pchgthruDtStr !== '')
	{finMoveOutdiff = ( Math.floor((Date.UTC(currChgThruYr, currChgThruMo, currChgThruDy) -
	 Date.UTC(pmy,pmm, pmd) ) /(1000 * 60 * 60 * 24)));
	 finMoveOutdiff = Math.abs(finMoveOutdiff);
	 }
else
	{var finMoveOutdiff = 0;} 

if (projmovoutDtStr !== '')
	{projMoveOutdiff = ( Math.floor((Date.UTC(currProjMoveOutYr, currProjMoveOutMo, currProjMoveOutDy) -
	 Date.UTC(rey,rem, red) ) /(1000 * 60 * 60 * 24)));
	 projMoveOutdiff = Math.abs(projMoveOutdiff);
	 }
else
	{var projMoveOutdiff = 0;} 	
	
if (noticeMovOutDtStr !== '')
	{NoticeMoveOutdiff = ( Math.floor((Date.UTC(currNoticeYr, currNoticeMo, currNoticeDy) -
	 Date.UTC(nmy,nmm, nmd) ) /(1000 * 60 * 60 * 24)));
	 NoticeMoveOutdiff = Math.abs(NoticeMoveOutdiff);
//	 alert('NoticeMoveOutdiff: ' + NoticeMoveOutdiff);
	 }
else
	{var NoticeMoveOutdiff = 0;} 		
<!---  alert(' phyMovOutDtStr: ' + phyMovOutDtStr 
 + '\n  projmovoutDtStr: '  +  projmovoutDtStr 
 + '\n  noticeMovOutDtStr: ' + noticeMovOutDtStr  
 + '\n pchgthruDtStr: ' +  pchgthruDtStr 
 + '\n currmoveindt: ' + currmoveindt + ' :: '
 + '\n currdtmoveout: ' + currdtmoveout 
 + '\n currdtchargethrough: ' + currdtchargethrough
 + '\n curreffdt: ' + curreffdt
 + '\n currdtProjected: '+ currdtProjected ); --->

 if (phyMovOutDtStr == '' && projmovoutDtStr == '' && noticeMovOutDtStr == '' && pchgthruDtStr == '' )
 	{alert ('No date changes were entered');
	return false;}
<!--- gthota 10/25/2017  - commented because AR admin access not setup properly  --->	
//else if ((NoticeMoveOutdiff > 30) && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make Move Out Notice adjustments greater than 30 days');
//	return false;}
//else if ((projMoveOutdiff > 30)  && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make Projected Move Out adjustments greater than 30 days');
//	return false;}	
//else if ((finMoveOutdiff > 30) && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make Financial Move Out adjustments greater than 30 days');
//	return false;}
//else if ((phyMoveOutDiff > 30)  && (MoveInMgr !== 'Y'))
//	{alert('Only the AR Manager can make Physical Move Out Date adjustments greater than 30 days');
//	return false;}	
<!--- gthota 10/25/2017  - commented END code    --->
		
else if ((phyMovOutDtStr !== '') && (mvm == '00') || (mvd == '00'))
{alert ('Please fix Physical Move Out date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ( (phyMovOutDtStr !== '') &&(mvy < '2000') || (mvy > '2025'))
{alert ('Please fix Physical Move Out date \n The year value is out of range \n or improper format');
	return false;}	

else if ((pchgthruDtStr !== '') &&(pmm == '00') || (pmd == '00'))
{alert ('Please fix Financial Move Out date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ((pchgthruDtStr !== '') &&(pmy < '2000') || (pmy > '2025'))
{alert ('Please fix Financial Move Out date \n The year value is out of range \n or improper format');
	return false;}		
	
else if ((noticeMovOutDtStr !== '') &&(nmm == '00') || (nmd == '00'))
{alert ('Please fix Move Out Notice date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ((noticeMovOutDtStr !== '') &&(nmy < '2000') || (nmy > '2025'))
{alert ('Please fix Move Out Notice date \n The year value is out of range \n or improper format');
	return false;}
	
else if ((projmovoutDtStr  !== '') &&(rem == '00') || (red == '00'))
{alert ('Please fix Projected Move Out date \n The Month or Day value cannot be \'00\' ');
	return false;}
else if  ((projmovoutDtStr !== '') &&(rey < '2000') || (rey > '2025'))
{alert ('Please fix Projected Move Out date \n The year value is out of range \n or improper format');
	return false;}		
	
else if (commentchk == '')
	{alert('Comments Are Required: \n Please enter who requested the change and why');
		document.getElementById("comments_ID").focus();
		return false;}	 
else if ((phyMovOutDtStr !== '' ) &&(pchgthruDtStr == '' ) && (curreffdt > phyMovOutDtStr) )
	{alert('Physical Move Out Date CANNOT be before Move In or Financial Possession Dates');
	return false;}
else if ((pchgthruDtStr !== '' )  && (curreffdt > pchgthruDtStr) )
	{alert('Financial Move Out Date CANNOT be before Move In or Financial Possession Dates');
	return false;}
else if ((noticeMovOutDtStr !== '' )  && (curreffdt > noticeMovOutDtStr) )
	{alert('Move Out Notice Date CANNOT be before Move In or Financial Possession Dates');
	return false;}
else if ((projmovoutDtStr !== '' )  && (curreffdt > projmovoutDtStr) )
	{alert('Projected Move Out Date CANNOT be before Physical Move In or Financial Possession Dates');
	return false;}	
else if ((projmovoutDtStr !== '' )  && (phyMovOutDtStr !== '' )  && (projmovoutDtStr > phyMovOutDtStr) )
	{alert('Projected Move Out Date MUST be before Physical Move Out or Financial Move Out Dates');
	return false;}	
else if ((projmovoutDtStr !== '' )  && (pchgthruDtStr !== '' )  && (projmovoutDtStr > pchgthruDtStr) )
	{alert('Projected Move Out Date MUST be before Physical Move Out or Financial Move Out Dates');
	return false;}	
	
else if ((phyMovOutDtStr !== '' ) && (noticeMovOutDtStr == '')  && (currNoticedt > phyMovOutDtStr) )
	{alert('Physical Move Out Date MUST be Greater or Same as Move Out Notice Date');
	return false;}		
else if ((pchgthruDtStr !== '' ) && (noticeMovOutDtStr == '')  && (currNoticedt > pchgthruDtStr) )
	{alert('Financial Move Out Date MUST be Greater or Same as Move Out Notice Date');
	return false;}		
	
else if ((projmovoutDtStr !== '' ) && (noticeMovOutDtStr == '')  && (currNoticedt < projmovoutDtStr) )
	{alert('Projected Move Out Date MUST be before or Same as Move Out Notice Date');
	return false;}		
else if ((projmovoutDtStr !== '' )    && (currdtmoveout < projmovoutDtStr) )
	{alert('Projected Move Out Date CANNOT be Greater Than Physical Move Out Date');
	return false;}	
else if ((projmovoutDtStr !== '' )    && (currdtchargethrough < projmovoutDtStr) )
	{alert('Projected Move Out Date CANNOT be Greater Than Financial Move Out Date');
	return false;}			 
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr !== '')   && (pchgthruDtStr < phyMovOutDtStr) )
	{alert('Physical Move Out Change Date MUST be less than or equal to Financial Move Out Change Date');
	return false;}	
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr == '')   && (currdtchargethrough < phyMovOutDtStr) )
	{alert('Physical Move Out Date MUST be less than or equal to Financial Move Out Date');
	return false;}			 
	
else if ((phyMovOutDtStr !== '' ) && (projmovoutDtStr !== '')    && (phyMovOutDtStr < projmovoutDtStr) ) 
	{alert('Projected Move Out Date MUST be before or Same as Physical Move Out');
	return false;}
			
else if ((pchgthruDtStr !== '' ) && (projmovoutDtStr !== '')   && (pchgthruDtStr < projmovoutDtStr) )
	{alert('Projected Move Out Date MUST be before or Same as Financial Move Out Dates');
	return false;}	
else if ((phyMovOutDtStr !== '' ) && (projmovoutDtStr == '')    && (phyMovOutDtStr < currdtProjected) ) 
	{alert('Projected Move Out Date MUST be before or Same as Physical Move Out');
	return false;}
			
else if ((pchgthruDtStr !== '' ) && (projmovoutDtStr == '')   && (pchgthruDtStr < currdtProjected) )
	{alert('Projected Move Out Date MUST be before or Same as Financial Move Out Dates');
	return false;}	
else if ((noticeMovOutDtStr !== '' ) && (projmovoutDtStr !== '')   && (noticeMovOutDtStr > projmovoutDtStr) )
	{alert('Move Out Notice Date CANNOT be before Projected Move Out Date');
	return false;}				
else if ((noticeMovOutDtStr !== '' ) && (projmovoutDtStr == '')   && (noticeMovOutDtStr > currdtProjected) )
	{alert('Move Out Notice Date CANNOT be before current Projected Move Out Date');
	return false;}
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr == '' ) && (phyMovOutDtStr > currdtchargethrough))
	{alert('Physical Move Out Date CANNOT be AFTER Financial Move Out Date');
	return false;}	
else if ((pchgthruDtStr !== '' ) && (phyMovOutDtStr == '' ) && (pchgthruDtStr < currdtmoveout))
	{alert('Financial Move Out Date cannot be before Physical Move Out Date');
	return false;}	
else if ((noticeMovOutDtStr !== '' )  && (pchgthruDtStr == '' )  && (noticeMovOutDtStr > currdtchargethrough) )
	{alert('Move Out Notice Date CANNOT BE Greater Than Physical Move Out or Financial Move Out Dates');
	return false;}	
else if ((noticeMovOutDtStr !== '' )  && (phyMovOutDtStr == '' )  && (noticeMovOutDtStr > currdtmoveout) )
	{alert('Move Out Notice Date CANNOT BE Greater Than Physical Move Out or Financial Move Out Dates');
	return false;}		
else if ((noticeMovOutDtStr !== '') && (currmoveindt > noticeMovOutDtStr ))
	{alert(	'Move Out Notice Date Cannot be before Move In Date or Financial Possession Date');
	return false;}	
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr !== '') && (phyMovOutDtStr> pchgthruDtStr) )
	{alert('Move Out Date CANNOT be After Changed Financial Move Out Date');
	return false;}	
else if ((phyMovOutDtStr !== '' ) && (pchgthruDtStr == '') && (phyMovOutDtStr > currdtchargethrough) )
	{alert('Move Out Date CANNOT be AFTER Existing Financial Move Out Date');
	return false;}	
else if ((phyMovOutDtStr !== '') && (currmoveindt > phyMovOutDtStr ))
	{alert(	'Move Out Date Cannot be before Move In Date or Financial Possession Date'  );
	return false;}	

else if ((projmovoutDtStr !== '') && (currmoveindt > projmovoutDtStr ))
	{alert(	'Projected Move Out Date Cannot be before Move In Date or Financial Possession Date');  
	return false;}
else if ((pchgthruDtStr !== '') && (currmoveindt > pchgthruDtStr ))
	{alert(	'Financial Move Out Date Cannot be before Move In Date or Financial Possession Date');  
	return false;}	

}
</script>	
<body>
	<h1 class="PageTitle"> Tips 4 - Respite Move Out Dates Edit </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
<CFOUTPUT>
<!--- 	<BR><BR>
	<A HREF="TenantEdit.cfm?ID=#url.ID#" STYLE="font-size: 18;">Exit and Return to Tenant Edit Screen.</A> --->
	<FORM NAME="MoveInAddendum" ACTION="RespiteMoveOutCorrectionAction.cfm" METHOD="POST"  onSubmit="return verifyDates();" >
 	<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#qTenant.iTenant_ID#">
	<input type="hidden" name="dtNoticeDate" id="dtNoticeDate_id" 
		value="#dateformat(qtenant.dtNoticeDate,'yyyymmdd')#" />


	<input type="hidden" name="dtchargethrough" id="currdtchargethrough_id" 
		value="#dateformat(qtenant.dtchargethrough,'yyyymmdd')#" />

	<input type="hidden" name="dtmoveout" id="currdtmoveout_id" 
		value="#dateformat(qtenant.dtmoveout,'yyyymmdd')#" />	

	<input type="hidden" name="dtMoveOutProjectedDate" id="dtMoveOutProjectedDate_id" 
		value="#dateformat(qtenant.dtMoveOutProjectedDate,'yyyymmdd')#" />		

	<input type="hidden" name="curreffdate" id="curreffdate_id" 
		value="#dateformat(qtenant.dtrenteffective,'yyyymmdd')#" /> 

	<input type="hidden" name="currmovindate" id="currmovindate_id" 
		value="#dateformat(qtenant.dtmovein,'yyyymmdd')#" /> 	
	<input type="hidden" name="iSPoints" id="iSPoints" 
		value="#qtenant.iSPoints#" />	
	<input type="hidden" name="iHouse_ID" id="iHouse_ID" 
		value="#qtenant.iHouse_ID#" />	
	<input type="hidden" name="iAptAddress_ID" id="iAptAddress_ID" 
		value="#qtenant.iAptAddress_ID#" />		
	<input type="hidden" name="iSLPoints" id="iSLPoints" 
		value="#qtenant.iSLPoints#" />		
	<CFIF ((ListFindNoCase(qusercodeblock.groupid,285) GT 0) and (session.username is 'jgedelman'))>
		<input  type="hidden" name="MvInMgr" id="MvInMgr_ID" value="Y" />
	<cfelse>
		<input  type="hidden" name="MvInMgr" id="MvInMgr_ID" value="N" />	
	</cfif>			
	<!--- ==============================================================================
	Set Addendum Type to 2 (HardCoded to MoveIn)
	The Addendum Type Table should remain a reference table and static
	=============================================================================== --->
	<INPUT TYPE="Hidden" NAME="iAddendumType_ID" VALUE="2">
	
		<TABLE >
			<TR>
				<TH COLSPAN="100%" STYLE="text-align: center;">
					Respite Move Out Dates Adjustments - Addendum
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
			<tr>
				<td style="text-align:center;">Projected Move Out Date</td>
				<td style="text-align:center;">Move Out Notice Date</td>
				<td style="text-align:center;">Physical Move Out Date</td>
				<td style="text-align:center;">Financial Move Out Date</td>
			</tr>
			<tr>
			  		<td colspan="1" style="text-align:center; color: ##FF0000">
					 #dateformat(qtenant.dtmoveoutprojecteddate,'mm/dd/yyyy')#</td>	
				  	<td colspan="1" style="text-align:center; color: ##FF0000">
					 #dateformat(qtenant.dtNoticeDate,'mm/dd/yyyy')#</td> 
 					<td colspan="1" style="text-align:center; color: ##FF0000">
					 #dateformat(qtenant.dtmoveout,'mm/dd/yyyy')#</td>
					<td colspan="1" style="text-align:center; color: ##FF0000">
					#dateformat(qtenant.dtChargeThrough,'mm/dd/yyyy')#</td>
			</tr>
			<input type="hidden" NAME='projmoveoutdt' VALUE='' id='projmoveoutdt'>
<!--- 			<TR  id="projmoveout_id1"  style="display:block; background-color:##FFFF61">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Projected Move Out Date:<br /> #DateFormat(qTenant.dtmoveoutprojecteddate,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showprojmoveout(this);">
				</td>
			</TR>
			<TR  id="projmoveout_id2"  style="display:none; background-color:##FFFF61">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Projected Move Out Date:<br /> #DateFormat(qTenant.dtmoveoutprojecteddate,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Projected Move Out Date:<br />
					<INPUT TYPE='Text' NAME='projmoveoutdt' 
					VALUE='' SIZE='10' id='projmoveoutdt' onKeyUp='Dates(this);'>
				</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showprojmoveout2(this);"></td>
			</TR> --->
			<TR  id="noticeout_id1"  style="display:block; background-color:##FFFF40">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Move Out Notice Date:<br /> #DateFormat(qTenant.dtnoticedate,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="shownoticemoveout(this);">
				</td>
			</TR>
			<TR  id="noticeout_id2"  style="display:none; background-color:##FFFF40">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Move Out Notice Date:<br /> #DateFormat(qTenant.dtnoticedate,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Move Out Notice Date:<br />
					<INPUT TYPE='Text' NAME='noticeoutdt' 
					VALUE='' SIZE='10' id='noticeoutdt' onKeyUp='Dates(this);'>
				</TD>
				<TD>&nbsp;</TD>
				<!--- <TD>Reset Notice Move Out to Blank:<br>
					<input type="checkbox" name="resetNoticeMoveout" value="Y" id="resetNoticeMoveOut_id"></TD> --->
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="shownoticemoveout2(this);"></td>
			</TR>

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
				<!--- <TD>Reset Physical Move Out to Blank:<br> 
					<input type="checkbox" name="resetphysicalMoveout" value="Y" id="resetPhysicalMoveOut_id"></TD> --->
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showmoveout2(this);"></td>
			</TR>
			
			<TR  id="chgthrough_id1"  style="display:block; background-color:##FFFF60">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Financial Move Out Date:<br /> #DateFormat(qTenant.dtChargeThrough,"mm/dd/yyyy")#
				</TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Click to Change:<INPUT TYPE="Checkbox" NAME="changedate" onClick="showChgThrough(this);">
				</td>
			</TR>
			<TR  id="chgthrough_id2"  style="display:none; background-color:##FFFF60">
				<TD nowrap="nowrap" style="font-weight:bold; text-align:center">
					Financial Move Out Date:<br /> #DateFormat(qTenant.dtChargeThrough,"mm/dd/yyyy")#
				</TD>
				<TD style="text-align:center; font-weight:bold">
					Enter New Financial Move Out Date:<br />
					<INPUT TYPE='Text' NAME='chgthroughdt' 
					VALUE='' SIZE='10' id='chgthroughdt' onKeyUp='Dates(this);'>
				</TD>
				<TD>&nbsp;</TD>
				
				<!--- <TD>Reset Financial Move Out to Blank:<br>
					<input type="checkbox" name="resetchargethrough" value="Y" id="resetchargethru_id"></TD> --->
				<TD nowrap="nowrap" style="font-weight:bold; text-align:right">
					Do Not Change:<INPUT TYPE="Checkbox" NAME="changedate" 
						onClick="showChgThrough2(this);"></td>
			</TR>	
				
 			<TR  id="commentsID" style="display:none">
				<TD COLSPAN=100% STYLE="text-align:center; font-weight:bold; color:##FF0000">
				<!--- 	<DIV ID="comments"></DIV> --->
Required: Please enter the name of the person requesting the date change and the reason for the date change<br> Comments: <TEXTAREA COLS='50' ROWS=3 NAME='cComments' id="comments_ID"></TEXTAREA>				
				</TD>
			</TR> 			
			<tr id="SaveID" style="display:none">
				<td>&nbsp;</td>
				<td><INPUT TYPE='submit' NAME='Save' VALUE='Save' 
				STYLE='color:red; text-align:center;'></td>
				<td><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel/Reset' 
				onClick=location.href='RespiteMoveOutCorrection.cfm?tenantid=#url.tenantID#'></td>
				<td>&nbsp;</td>
			</tr>			
					
</TABLE>
<!--- <CFIF qAddendumHistory.RecordCount GT 0> --->
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
					<TD>#qAddendumHistory.cAddendumNumber#</TD>
					<TD STYLE="text-align: center;">#DateFormat(dtAddendum,'mm/dd/yyyy')#</TD>
					<TD STYLE="text-align: center;">#dateformat(dtChangeFrom,'mm/dd/yyyy')#</TD>
					<TD STYLE="text-align: center;">#dateformat(dtChangeTo,'mm/dd/yyyy')#</TD>						
					<TD>#qAddendumHistory.cComments#</TD>
				</TR>
			</CFLOOP>
 				
		</TABLE>
<!--- 	</CFIF> --->
</FORM>
<CFINCLUDE TEMPLATE="../../footer.cfm">
</CFOUTPUT>
</body>
</html>
