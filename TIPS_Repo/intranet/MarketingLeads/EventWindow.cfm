<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| EventWindow.cfm							                                                   |
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
| mlaw       | 10/16/2006 | Fix the code for the coldfusion upgrade                            |
|----------------------------------------------------------------------------------------------|
|ssanipina   | 05/07/2008 | Remove the option of linking resident                              |
|----------------------------------------------------------------------------------------------|
| jcruz		 | 09/27/2008 | Modified file to restrict when the Move In Status is shown. This   |
|							ensure that residents only get placed in move-in status after they |
|							have been in the Committed Status. PROJECT 12392				   |
----------------------------------------------------------------------------------------------->
<cfoutput>
<link rel='stylesheet' type='text/css' href='http://#server_name#/intranet/tips4/shared/style3.css'>
<cfset DSN='LeadTracking'>
<cfset tipsDSN='TIPS4'>

<!--- <cfinclude template="../Tips4/Shared/JavaScript/ResrictInput.cfm"> --->
<cfinclude template='../TIPS4/Shared/Queries/Residency.cfm'>
<cfinclude template='../TIPS4/Shared/Queries/SolomonKeyList.cfm'>
<cfinclude template='../TIPS4/Shared/Queries/TenantInformation.cfm'>
<cfinclude template='../TIPS4/Shared/Queries/StateCodes.cfm'>

<!--- MLAW 10/16/06 Remove DATASOURCE="SolomonKeyList" --->
<!--- retrieve valid residents --->
<cfquery name="qActiveTenants" DBTYPE="query">
select cSolomonKey, cFirstName, cLastName, iTenantStateCode_ID	from SolomonKeyList where iTenantStateCode_ID < 3
</cfquery>

<!--- Query for resident information --->
<cfquery name='qResident' DATASOURCE='#DSN#'>
select	r.cFirstName ,r.cLastName ,r.iResident_ID , (r.cLastName + ', '+ r.cFirstName) as FullName
		,r.cAddressLine1 ,r.cCity ,r.cStateCode, r.cZipCode, rs.itenant_id, rs.iStatus_ID
from Resident r
join residentstate rs on rs.iresident_id = r.iresident_id and rs.dtrowdeleted is null
where r.dtRowDeleted is null and r.iResident_ID = #id#
</cfquery>

<!--- check for active assessment --->
<cfquery name="qAssessment" datasource="#dsn#">
select am.iassessmenttoolmaster_id, am.bFinalized
from residentstate rs
join #application.tips4dbserver#.TIPS4.dbo.assessmenttoolmaster am on am.iresident_id = rs.iresident_id and am.dtrowdeleted is null
and am.bbillingactive is not null
where rs.iresident_id = #trim(qresident.iresident_id)#
</cfquery>

<cfset dtmovein=now()>
<cfif qResident.itenant_id neq "">
	<cfquery name="TenantInfo" datasource="#tipsDSN#">
	select * from tenant t join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
	and t.dtrowdeleted is null
	where t.itenant_id = #qresident.itenant_id#
	</cfquery>
	<cfset dtmovein=tenantinfo.dtmovein>
</cfif>

<!--- retrieve house product line info --->
<cfquery name="qproductline" datasource="#tipsDSN#">
select pl.iproductline_id, pl.cdescription
from houseproductline hpl
join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>

<!-- retrieve residency types --->
<cfquery name="residency" datasource="#tipsDSN#">
select rt.iresidencytype_id ,rt.cdescription ,pl.iproductline_id ,plrt.iproductlineresidencytype_id
from houseproductline hpl
join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
join ProductLineResidencyType plrt on plrt.iproductline_id = pl.iproductline_id and plrt.dtrowdeleted is null
join residencytype rt on rt.iresidencytype_id = plrt.iresidencytype_id and rt.dtrowdeleted is null
where hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>

<!--- Query for Status Information --->
<!--- Add condition here to test for a finalized assessment before showing the Move In option --->
<!--- Modified by Jaime Cruz as part of PROJECT 12392. Move-in option only shown when resident is in status 7 and an assessment has been finalized. --->
<cfif qResident.iStatus_ID EQ 7>
	<cfif qAssessment.bfinalized EQ '' Or qAssessment.bfinalized neq 1 >
<cfquery name='qStatus' DATASOURCE='#DSN#'>
		select cDescription, iStatus_ID from Status where dtRowDeleted is null and iStatus_ID In (2,3,4,5,7)
		order by iSortOrder		
		</cfquery>
	<cfelse>
		<cfquery name='qStatus' DATASOURCE='#DSN#'>
select cDescription, iStatus_ID from Status where dtRowDeleted is null and cDescription <> 'New'
		order by iSortOrder
		</cfquery>
	</cfif>
<cfelse>
	<cfquery name='qStatus' DATASOURCE='#DSN#'>
	select cDescription, iStatus_ID from Status where dtRowDeleted is null and iStatus_ID In (2,3,4,5,7)
order by iSortOrder
</cfquery>
</cfif>
<!--- End of PROJECT 12392 Modifications --->

<!--- Query for Actions Information --->
<cfquery name='qActions' DATASOURCE='#DSN#'>
select cDescription, iActionType_ID from ActionType where dtRowDeleted is null order by iActionType_ID
</cfquery>

<!--- Query for Move out reasons used for lost prospects--->
<cfquery name="qReasons" DATASOURCE="TIPS4">
select imovereasontype_id, cdescription from movereasontype where dtrowdeleted is null order by cdescription
</cfquery>

<!--- import global jsfunctions --->
<script language="JavaScript" type="text/javascript" src="../TIPS4/Shared/JavaScript/global.js"></script>
<!--- import global calendar script --->
<script language="JavaScript" type="text/javascript" src="../global/Calendar/ts_picker2.js"></script>
<script language="JavaScript" src="../../cfide/scripts/wddx.js" type="text/javascript"></script>
<script>
<cfwddx action="cfml2js" input="#qproductline#" toplevelvariable="jsProductline">
<cfwddx action="cfml2js" input="#Residency#" toplevelvariable="jsResidency">
	function initial() {
		df0=document.forms[0];
		//set default values
		n = new Array(); v = new Array();
		for (i=0;i<=document.forms[0].elements.length-1;i++){ n[i] = document.forms[0].elements[i].name; v[i] = document.forms[0].elements[i].value;}
		setTimeout("resizewindow()",500); detectchanges();
	}
	function detectchanges(){
		changesmade=0;
		for (t=0;t<=document.forms[0].elements.length-1;t++){ if (n[t] == document.forms[0].elements[t].name && v[t] !== document.forms[0].elements[t].value) { changesmade = changesmade + 1; } }
		setTimeout("detectchanges()",100);
	}
	function resizewindow(){
		if (screen.availHeight >= document.all['eventtable'].clientHeight) {
			self.resizeTo(document.all['eventtable'].clientWidth + 60,document.all['eventtable'].clientHeight + 100);
		}
	}
	function required(obj) {
		obj=document.forms[0].iStatus_ID; rq='', need=0;
		if (obj.value == 6) {
			obj=document.forms[0]; fn=obj.all['cFirstName']; ln=obj.all['cLastName'];
			ad=obj.all['cAddressLine1']; cy=obj.all['cCity']; zp=obj.all['cZipCode'];
			rq=new Array(fn,ln,ad,cy,zp); need=0;
		}
		else if (obj.value == 5) {
			obj=document.forms[0]; rs=obj.all['reason']; ds=obj.all['cdestination'];
			rq=new Array(rs,ds); need=0;
		}
		for (a=0;a<=rq.length-1;a++) { if (rq[a].value.length == 0) { rq[a].style.background='yellow'; need+=1; } else { rq[a].style.background='white';} }
		if (need > 0) { alert('Fields in yellow are required');  return false; }
	}
	bUsed = 0; //initialize flag to see if form is un use & set close flag to false
	// timer focus on child window to ensure user processing
	function top(string){
		// set timer to bring child window to front if placed in back... used to ensure user processing.
		if (string == 1){ alert('You have started a new event that has not been saved. \r Please finish or cancel this event before continuing.'); }
		if (this.closed == false) {
			try { opener.bwinevent = true; opener.disablelinks(); } catch (exception) { /*none*/ }
			self.focus(); focustimer=setTimeout('top(0)',90000);
		}
		else { opener.bwinevent = false; opener.disablelinks();} }

	// function that determines if any form fields are in use
	function inUse(string){
		if (bUsed !== 1){ clearTimeout(focustimer); if(string = 1){ bUsed=1; focustimer=setTimeout('top(1)',300000); } else { bUsed=0; top(); } }
	}

	// if child window is closed set bit in parent for this child window to false and allow link clicks
	window.onunload=function(){try {opener.bwinevent = false; opener.disablelinks();} catch (exception) { /**/ }; }
	top(); // initialize timer
	window.onfocus=function(){ clearTimeout(focustimer); top();} // on each focus reset timer

	function eventclose(){
		if (document.forms[0].cShortDescription.value.length > 0 || document.forms[0].cLongDescription.value.length > 0 || document.forms[0].cComments.value.length > 0 || changesmade > 0) {
			if (confirm('You have not saved this information.\rAll changes will be lost.\rAre you sure?')){ opener.bwinevent=false; self.close(); }
		}
		else{ self.close(); }
	}
	function validatesubmit(){
		//if(document.forms[0].cShortDescription.value.length < 4 || document.forms[0].cLongDescription.value.length < 4){
		//alert(checkboxcount);
		if (checkboxcount <= 0) { alert('Please choose a check box to indicate what type of activity was done.'); return false; }
		if(document.forms[0].cShortDescription.value.length < 4){
			alert('The event descriptions must be alteast 5 characters long'); return false;
		}
		else { document.forms[0].submit(); return true; } //alert('else');
	}
	checkboxcount=0; //initialize
	function detailcheckboxcheck(){
		checkboxcount=0; //reset counter
		bx=document.getElementsByTagName("INPUT");
		for (a=0;a<=bx.length-1;a++) {
			if (bx[a].type == 'checkbox' && bx[a].name.indexOf("checkbox_") == 0 && bx[a].checked == true) { checkboxcount+=1; }
		}
	}

	function proj(obj) {
		if (obj.checked == true) { df0.dtmovein.disabled=true; df0.dtmovein.style.background='##eaeaea'; }
		else { df0.dtmovein.disabled=false; df0.dtmovein.style.background='white'; }
	}

	function status(obj){
		document.all['lost'].style.display='none';
		thisdisplay=document.all['requiredinformation'].style.display;
		if (obj.value == 6) {
		if (#qAssessment.recordcount# == 0) {
			alert('An assessment must be completed for this inquiry\rbefore the move in may be processed');
			obj.options[0].selected = true;
			return false;
		}
		thisdisplay='none';
		document.all['requiredinformation'].style.display = "inline";
		cm="<table style='background:##eaeaea;'>";
		cm+="<tr><td>FirstName</td>";
		cm+="<td><input type='text' name='cFirstName' SIZE=25 MaxLength=25 value='#jsstringformat(trim(qResident.cFirstName))#' onFocus=" + "''" + "javascript: cfirstname='#trim(jsstringformat(qResident.cFirstName))#'" + "''" + " onChange='detectchanges(cfirstname,this);'></td>";
		cm+="<td>LastName</td><td><input type='text' name='cLastName' SIZE=25 MaxLength=25 value='#jsstringformat(trim(qResident.cLastName))#' onFocus=" + "''" + "javascript: clastname='#jsstringformat(trim(qResident.clastname))#'" + "''" + " onChange='detectchanges(clastname,this);'></td></tr>";
		cm+="<tr><td>AddressLine1</td><td><input type='text' name='cAddressLine1' SIZE=25 MaxLength=50 value='#TRIM(qResident.cAddressLine1)#'></td><td>City</td><td><input type='text' name='cCity' value='#TRIM(qResident.cCity)#'></td></tr>";
		cm+="<tr><td>State</td><td>";
		cm+="<select name='cStateCode' onKeyDown='backhandler();'><option value=''> Select State </option>";
		cm+="<cfloop Query='StateCodes'><CFIF qResident.cStateCode EQ StateCodes.cStateCode><cfset Sel='selected'><cfelse><cfset Sel=''></CFIF><option value='#cStateCode#' #sel#> #trim(cStateCode)# - #trim(cStateName)# </option></cfloop>";
		cm+="</select></td>";
		cm+="<td>Zip</td><td><input type='text' name='cZipCode' value='#jsstringformat(trim(qResident.cZipCode))#'></td></tr>";
		cm+="<tr><td>Email</td><td><input type='TEXT' name='cEmail' value='' SIZE='40' maxlength='70'></td></tr>";

		<cfif qresident.itenant_id eq "">
			cm+="<tr><td colspan='2' style='width:50%;'>Account Type:</td>";
			cm+="<td colspan='2'><li>";
			cm+="<select name='cSolomonKey' onBlur='required(document.forms[0].iStatus_id);' onKeyDown='backhandler();'>";
			cm+="<option value=''> Create individual account </option>";
			<!--- Ssathya 05/07/08 Remove the option of linking resident as stated in the ticket# 22,292  --->
			<!--- cm+="<cfloop query='qActiveTenants'><option value='#qActiveTenants.cSolomonKey#'> Link to #jsstringformat((qActiveTenants.cLastName))#, #jsstringformat(trim(qActiveTenants.cFirstName))# (#qActiveTenants.cSolomonKey#)</option></cfloop>";
			 --->cm+="</select></li></td></tr>";
		<cfelse>
			cm+="<tr><td colspan='2'>Solomonkey</td><td colspan='2'>#tenantinfo.csolomonkey#</td></tr>";
		</cfif>

		<!---
		/*
		cm+="<tr><td colspan='2' style='width:50%;'>If this person will share a billing statement with another resident please select that person from the following list:</td>";
		cm+="<td colspan='2'><li>";
		cm+="<select name='cSolomonKey' onBlur='required(document.forms[0].iStatus_id);' onKeyDown='backhandler();'>";
		cm+="<option value=''> Create individual account </option>";
		cm+="<cfloop query='qActiveTenants'><option value='#qActiveTenants.cSolomonKey#'> Link to #jsstringformat(trim(qActiveTenants.cLastName))#, #jsstringformat(trim(qActiveTenants.cFirstName))# (#qActiveTenants.cSolomonKey#)</option></cfloop>";
		cm+="</select></LI></td></tr>";
		*/
		--->

		cm+="<tr><td colspan='2'>Will you be collecting an application fee before they officially move in?</td><td colspan='2'><LI><input name='bApplicationFee' TYPE='checkbox' value=1> (if yes check this box)</LI></td></tr>";

		cm+="<tr><td colspan='2'>What product line will be used?</td><td><li><select id='iproductline_id' name='iproductline_id' onChange='genRes(this)'>";
		<cfloop query="qproductline">
		cm+="<option value='#qproductline.iproductline_id#'>#qproductline.cDescription#</option>";
		</cfloop>
		cm+="</select></li></td><td colspan='2'></td></tr>";

		cm+="<tr><td colspan='2'>What is the payment type for this resident?</td>";
		cm+="<td colspan='2'><li><select name='iResidencyType_ID' onKeyDown='backhandler();'>";
		cm+="<cfloop query='Residency'><option value='#Residency.iResidencyType_ID#'>#Residency.cDescription#</option></cfloop>";
		cm+="</select></LI></td></tr>";
		cm+="<tr><td colspan='2'>Does this resident help satisfy a bond requirement?</td><td colspan='2'><LI><input type='checkbox' name='Bond' value=''> (if yes check this box)</LI></td></tr>";
		cm+="</table>";
		document.all['requiredinformation'].innerHTML=cm; resizewindow();
		genRes( prodsel=document.getElementById("iproductline_id") );
		}
		else if (obj.value == 5) {
			document.all['requiredinformation'].style.display='none';
			document.all['lost'].style.display='inline';
			lt="<table><TR style='color: red; font-weight:bold;'><td>What was the reason the prospective resident was lost? <select name='reason' onblur='required(document.forms[0].iStatus_id);'>";
			lt+="<cfloop query="qReasons"><option value='#qReasons.imovereasontype_id#'>#qReasons.cDescription#</option></cfloop>";
			lt+="</select></td><td>Where did they decide to go? <input type='text' Name='cdestination' value='' onblur='required(document.forms[0].iStatus_id);'></td></tr></table>";
			document.all['lost'].innerHTML=lt;
		}
		else if (obj.value == 7) {
		document.all['requiredinformation'].style.display='inline';
		document.all['lost'].style.display='none';
		cmt="<table style='background:##eaeaea;'>";
		cmt+="<tr><td>FirstName</td>";
		cmt+="<td><input type='text' name='cFirstName' SIZE=25 MaxLength=25 value='#jsstringformat(trim(qResident.cFirstName))#' onFocus=" + "''" + "javascript: cfirstname='#trim(jsstringformat(qResident.cFirstName))#'" + "''" + " onChange='detectchanges(cfirstname,this);'></td>";
		cmt+="<td>LastName</td><td><input type='text' name='cLastName' SIZE=25 MaxLength=25 value='#jsstringformat(trim(qResident.cLastName))#' onFocus=" + "''" + "javascript: clastname='#jsstringformat(trim(qResident.clastname))#'" + "''" + " onChange='detectchanges(clastname,this);'></td></tr>";
		cmt+="<tr><td>AddressLine1</td><td><input type='text' name='cAddressLine1' SIZE=25 MaxLength=50 value='#TRIM(qResident.cAddressLine1)#'></td><td>City</td><td><input type='text' name='cCity' value='#TRIM(qResident.cCity)#'></td></tr>";
		cmt+="<tr><td>State</td><td>";
		cmt+="<select name='cStateCode' onKeyDown='backhandler();'><option value=''> Select State </option>";
		cmt+="<cfloop Query='StateCodes'><CFIF qResident.cStateCode EQ StateCodes.cStateCode><cfset Sel='selected'><cfelse><cfset Sel=''></CFIF><option value='#cStateCode#' #sel#> #trim(cStateCode)# - #trim(cStateName)# </option></cfloop>";
		cmt+="</select></td>";
		cmt+="<td>Zip</td><td><input type='text' name='cZipCode' value='#jsstringformat(trim(qResident.cZipCode))#'></td></tr>";
		cmt+="<tr><td>Email</td><td><input type='TEXT' name='cEmail' value='' SIZE='40' maxlength='70'></td></tr>";
		<cfif qresident.itenant_id eq "">
			cmt+="<tr><td colspan='2' style='width:50%;'>Account Type:</td>";
			cmt+="<td colspan='2'><li>";
			cmt+="<select name='cSolomonKey' onBlur='required(document.forms[0].iStatus_id);' onKeyDown='backhandler();'>";
			cmt+="<option value=''> Create individual account </option>";
			<!--- 05/07/08 Ssathya removed the option of linking resident reference ticket# 22,292 --->
			<!--- cmt+="<cfloop query='qActiveTenants'><option value='#qActiveTenants.cSolomonKey#'> Link to #jsstringformat((qActiveTenants.cLastName))#, #jsstringformat(trim(qActiveTenants.cFirstName))# (#qActiveTenants.cSolomonKey#)</option></cfloop>";
			 --->cmt+="</select></li></td></tr>";
		<cfelse>
			cmt+="<tr><td colspan='2'>Solomonkey</td><td colspan='2'>#tenantinfo.csolomonkey#</td></tr>";
		</cfif>

		cmt+="<tr><td colspan='2'>What product line will be used?</td><td><li><select id='iproductline_id' name='iproductline_id' onChange='genRes(this)'>";
		<cfloop query="qproductline">
		cmt+="<option value='#qproductline.iproductline_id#'>#qproductline.cDescription#</option>";
		</cfloop>
		cmt+="</select></li></td><td colspan='2'></td></tr>";

		cmt+="<tr><td colspan='2'>What is the payment type for this resident?</td>";
		cmt+="<td colspan='2'><li><select name='iResidencyType_ID' onKeyDown='backhandler();'>";
		cmt+="<cfloop query='Residency'><option value='#Residency.iResidencyType_ID#'>#Residency.cDescription#</option></cfloop>";
		cmt+="</select></li></td></tr>";
		cmt+="<tr><td colspan='2'><b style='color:blue;'>Is there a projected move in date?</td>";
		cmt+="<td colspan='2'><img src='../global/Calendar/calendar.gif' alt='Calendar image' name='Calendar' width='16' height='15' onClick='show_calendar2(\"document.forms[0].dtmovein\",df0.dtmovein.value)'>";
		cmt+=" <input type='text' name='dtmovein' value='#trim(dateformat(isBlank(dtmovein,now()),"mm/dd/yyyy"))#' size='10' onBlur='Dates(this);'>";
		cmt+="&nbsp;&nbsp;&nbsp;<span style='border:1px solid ##006699;padding: 0px 5px 0px 5px;color:##006699;'>Projected date is not known <input type='checkbox' name='noprojection' value='' onClick='proj(this)'></span>";
		cmt+="</td></tr></table><br>";
		document.all['requiredinformation'].innerHTML=cmt;
		<cfif isDefined("tenantinfo.iresidencytype_id") and tenantinfo.iresidencytype_id neq ''>
			df0.iResidencyType_ID.value=#tenantinfo.iresidencytype_id#;
		</cfif>
		genRes( prodsel=document.getElementById("iproductline_id") );
		}
		else { document.all['requiredinformation'].style.display='none'; document.all['lost'].style.display='none'; }
		resizewindow();
	}
	function adjustcom(obj,orig) { carriagecount=0;
		for (a=0;a<=obj.value.length-1;a++){ if (obj.value.charCodeAt(a) == '13') { carriagecount+=1; }  }
		if ( carriagecount !== 0 || (obj.value.length >= obj.cols && obj.value.length/obj.cols > 1 && obj.rows <= 7) ){
			obj.rows=((obj.value.length/obj.cols)+1.5)+carriagecount;
			if (document.body.offsetHeight + 150 < screen.availHeight) { resizewindow(); }
		}
		if (obj.value.length !== '') { obj.style.background='lightyellow'; }
		if (obj.value.length == '') { obj.cols=orig; obj.rows=1; obj.style.background='white'; }
	}
	function resetcom(obj,orig){ /*obj.cols=orig; obj.rows=1;*/
		obj.style.background='white'; resizewindow();
	}
	function genRes(obj) {
		targopt=document.getElementsByName("iResidencyType_ID")[0];
		targopt.options.length=0;
		for (i=0;i<=jsResidency['iproductlineresidencytype_id'].length-1;i++){
			if (obj.value == jsResidency['iproductline_id'][i]) {
				targopt.options.length += 1;
				targopt.options[targopt.options.length-1].value=jsResidency['iresidencytype_id'][i];
				targopt.options[targopt.options.length-1].text=jsResidency['cdescription'][i];
			}
		}
	}
	window.onload=initial;
</script>

<style>
td{ vertical-align: top; } textarea { font-size:x-small; }
</style>
<form action='EventSave.cfm' method='POST'>
<input type='hidden' name='iResident_ID' value='#qResident.iResident_ID#'>
<table ID='eventtable' valign="middle" style='text-align:center;border:none;border-left:1px solid ##ccccff;border-right:1px solid ##ccccff;'>
<tr><th class="topleftcap"></th><th colspan=100 class="toprightcap"></th></tr>
<tr>
	<th colspan='2' style="text-align:left;"><dd>New Event for #qResident.FullName#</dd></th>
	<th colspan='2' nowrap>
		<!--- <input type=button name="Save" value="Save" onclick='return required(document.forms[0].iStatus_id); validatesubmit();'> --->
		<input type="button" name="Save" value="Save" onClick='return validatesubmit();'>
		&nbsp;<input type='button' name='Cancel' value='Cancel' style='color:red;' onClick='eventclose();'></th>
</tr>
<tr><td colspan=100%><span id='requiredinformation'></span></td>
</tr>
<tr><td>Short Description</td><td>Detailed Explanation</td><td colspan='2'>Status</td></tr>
<tr>
	<td><input type='text' name='cShortDescription' value="Action on #dateformat(now(),'mm/dd/yyyy')#" onkeyup="this.value=LettersNumbers(this.value);" onFocus='inUse(1);' onBlur='inUse(0);'></td>
	<td><textarea name='cLongDescription' cols="40" rows="1" onkeyup="adjustcom(this,40);" onFocus='inUse(1);' onBlur='resetcom(this,40); inUse(0);'></textarea></td>
	<td colspan='2'>
		<select name='iStatus_ID' onChange='status(this)' onFocus='inUse(1);' onBlur='inUse(0);'>
		<cfloop query='qStatus'><option value='#qStatus.iStatus_ID#'>#qStatus.cDescription#</option></cfloop>
		</select>
	</td>
</tr>
<tr><td colspan=100% style='text-align:center;'>
	<table style='width:95%;border:1px solid ##eaeaea;'>
		<tr><th colspan=100% style="text-align:left;"><dd>Actions Performed:</dd></th></tr>
		<tr><td style="#center#"><b>Action</b></td><td><b>Comments</b></td></tr>
		<cfloop query='qActions'>
		<cfif qactions.currentrow mod 2><cfset back="background: ##eaeaea;"><cfelse><cfset back=""></cfif>
		<tr>
			<td nowrap style="width:25%;text-align:right;#back#">#qActions.cDescription#<input type="checkbox" name='checkbox__#qActions.iActionType_ID#' value='0' onClick='detailcheckboxcheck();'></td>
			<td nowrap style="text-align:left;#back#"><TextArea name='detailcomments__#qActions.iActionType_ID#' rows=1 cols=40 onkeyup="adjustcom(this,40);" onblur="resetcom(this,40);"></TextArea></td><!--- onBlur='detailcheckboxcheck(this);' --->
		</tr>
		</cfloop>
	</table>
</td></tr>
<tr><td colspan=100% style='text-align:left;'>Comments for this activity <textarea name="cComments" cols="80" rows="1" maxlength=5000 onFocus='inUse(1);' onkeyup='adjustcom(this,80);' onBlur='resetcom(this,80); inUse(0);'></textarea></td></td></tr>
<tr><td colspan=100>&nbsp;</td></tr>
<tr>
	<td colspan=100><span id="lost"></span></td>
</tr>
<tr><th colspan=100 style="text-align:left;"><dd>Next Action</dd></th></tr>
<tr>
	<td nowrap style="background:whitesmoke;">
		Next Action
		<select name='iNextActionType_id'>
			<cfloop query="qActions">
				<option value="#qActions.iActionType_ID#">#qActions.cDescription#</option>
			</cfloop>
		</select>
		</td>
	<td nowrap style="background:whitesmoke;" colspan=100>Due Date <input type='text' name='duedate' size=9 value='#dateformat(now(),"mm/dd/yyyy")#'></td>
</tr>
<tr><td colspan=100% style='text-align:left;background:whitesmoke;'>Comments for next Action: <textarea name='cNextComments' cols="80" rows="" onFocus='inUse(1);' onkeyup="adjustcom(this,this.cols);" onBlur='inUse(0);'></textarea></td></td></tr>

<tr><td colspan=100% style='text-align:center;'><input type="button" name="Save" value="Save" onClick='return validatesubmit();'>&nbsp;<input type='button' name='Cancel' value='Cancel' style='color:red;' onClick='eventclose();'></td></tr>
<tr><td class="bottomleftcap"></td><td class="bottomrightcap" colspan=100></td></tr>
</table>
</form>
</body>
</CFOUTPUT>