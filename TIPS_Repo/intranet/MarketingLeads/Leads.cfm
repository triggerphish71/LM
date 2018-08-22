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
| ranklam    | 08/12/2007 | Created                                                            |
| ranklam    | 08/12/2007 | changed the linke to the new assessment tool                       |
-----------------------------------------------------------------------------------------------|
| jcruz		 | 03/14/2008 | Modified file to remove all links that would take a user to the    |
|							new assessment creation page. Link now takes user to the Main      |
|							Assessment page from where he/she needs to select person needing   |
|							an assessment.													   |
-----------------------------------------------------------------------------------------------|
| ssanipina	 |06/26/3008  |Modified so as to make phone number as required field               |
|                          as per project 20125                                                |
| jcruz		 | 03/21/2009 | Modified file to only show inquiry add for non SE region houses    |
| rschuette	 | 03/35/2009 | Undid modification for SE reqion due to errors                     | 
----------------------------------------------------------------------------------------------->

<cfflush interval="10">

<cfoutput>
<cflock scope="session" timeout="10">
<cfset session.application="Inquiry">
</cflock>

<cfscript>
// initialize variables
if (isDefined("session.qSelectedHouse.iHouse_id")) { h=session.qSelectedHouse.iHouse_id; }
else if (isDefined("url.SelectedHouse_ID")) { h=url.SelectedHouse_ID; }
else { h=200; }
</cfscript>

<!--- retrieve house information depending on initialization --->
<cfquery name="qHouse" datasource="#APPLICATION.DataSource#">
select * from House H (NOLOCK)
join  HouseLog HL (NOLOCK) ON (H.iHouse_ID = HL.iHouse_ID AND HL.dtRowDeleted IS NULL AND H.dtRowDeleted IS NULL)
where H.iHouse_ID = #h#
</cfquery>


<cfif not isDefined("session.qselectedhouse")>

<!--- lock variable initialization --->
<cflock scope="session" timeout="5">

<cfscript>
// initialize session variables
CalcHouse = qhouse.cNumber - 1800;
if (Len(CalcHouse) EQ 2) { HouseNumber = '0' & CalcHouse; }
else if (Len(CalcHouse) EQ 1) { HouseNumber = '0' & '0' & CalcHouse; }
else { HouseNumber = '#CalcHouse#'; }

SESSION.qSelectedHouse = qHouse;
SESSION.HouseName = qhouse.cName;
SESSION.HouseNumber = '#HouseNumber#';
SESSION.nHouse = qhouse.cNumber;
SESSION.TIPSMonth = qhouse.dtCurrentTipsMonth;
SESSION.cSLevelTypeSet = qhouse.cSLevelTypeSet;
SESSION.HouseClosed	= qhouse.bIsPDclosed;
SESSION.cDepositTypeSet	= qHouse.cDepositTypeSet;
SESSION.cBillingType = trim(qHouse.cBillingType);

//renew user session variables to renew timeout period.
if (isDefined("SESSION.userid")) {SESSION.userid=SESSION.userid;}
if (isDefined("SESSION.fullname")) {SESSION.fullname=SESSION.fullname;}
</cfscript>

</cflock>

</cfif>

<!--- Set stylesheet --->
<link rel="StyleSheet" type="text/css" href="../TIPS4/Shared/Style3.css">
</cfoutput>

<script language="JavaScript" type="text/javascript" src="../TIPS4/Shared/JavaScript/global.js"></script>
<cfinclude template="../TIPS4/Shared/Queries/StateCodes.cfm">
<cfinclude template="../TIPS4/Shared/Queries/Relation.cfm">
<cfinclude template="LeadsPickLists.cfm">

<cfoutput>
<script language="JavaScript" src="../../cfide/scripts/wddx.js" type="text/javascript"></script>
<script>
	<cfwddx action="cfml2js" input="#qContacts#" toplevelvariable="qContactsJS">
	<cfwddx action="cfml2js" input="#qContactList#" toplevelvariable="qContactListJS">
	<cfwddx action="cfml2js" input="#qResidents#" toplevelvariable="qResidentsJS">
	window.name = 'leadswindow', bwinevent = false;
	
	function initial() { setTimeout("initialrun()",200); }
	
	function initialrun() {
		//urlvars=document.URL.split("?"); requestvars=urlvars[1];
		df0=document.forms[0], initializesource(df0.iGroup_ID);
		<cfif qSources.RecordCount EQ 0 OR qGroups.RecordCount EQ 0> 
			newsource(df0.iGroup_ID); 
			if (!df0.NewSource == false) { df0.NewSource.value=categorieslist(df0.groups); }
		</cfif>
		<!--- <cfif IsDefined("url.iResident_ID")> tmp = new Object; tmp.value = '#url.iResident_ID#'; checkresident(tmp); </cfif> --->
		<cfif qContacts.RecordCount EQ 1>df0.ContactList.value=#qContacts.iInquirer_ID#; addnewcontact(df0.ContactList);</cfif>
		
		<cfif (IsDefined("iResident_ID") and qResident.iStatus_ID EQ 5)>
		for (t=0;t<=df0.elements.length-1;t++){ 
			if (df0.elements[t].type == 'text'){ df0.elements[t].readOnly = 1; }
			else if (df0.elements[t].type == 'select-one' || df0.elements[t].type == 'button') { df0.elements[t].disabled = 1;}
		}
		</cfif>
	
		df0.Residents.value='add', checkresident(df0.Residents), df0.ContactList.value='add', addnewcontact(df0.ContactList);
		firstfocus();
	}
	
	function savebuttoncheck(){ 
		if (df0.ContactList.value.length > 0 && df0.Residents.value.length > 0
			&& df0.cFirstName.value.length > 0 && df0.cLastName.value.length > 0
			&& df0.cInquirerFirstName.value.length > 0 && df0.cInquirerLastName.value.length > 0) { 
			if (df0.cSex.value.length == 0) { df0.cSex.focus(); return false; }
			newsourceaction(); 
		} 
		else { 
			if (df0.cFirstName.value.length == 0 || df0.cLastName.value.length == 0) { alert('The resident information is invalid. \r Please check the information.'); }
			if (df0.cInquirerFirstName.value.length == 0 || df0.cInquirerLastName.value.length == 0) { alert('The inquirer information is invalid. \r Please check the information.'); }
			return false; 
		} 
	}
	function newsourceaction(){ 
		if(df0.ContactList.value == "add" && df0.Residents.value == ""){ alert('please enter resident information'); df0.Residents.value="add"; checkresident(df0.Residents.value); return false; }
		if (((df0.NewSource && df0.NewSource.value !== "") && (df0.groupname && df0.groupname.value !== "")) || (!df0.NewSource && !df0.groupname) || (df0.NewSource && !df0.groupname) ) {
			df0.action='newsource.cfm'; df0.submit(); 
		}
		else { 
			if (df0.NewSource.value == "") { df0.NewSource.focus(); } 
			else if (df0.groupname && df0.groupname.value.length == 0) { df0.groupname.focus(); }
		}
	}
	function deleteinq(string){ df0.action="DeleteInquirer.cfm?IID="+string+"&RID="+df0.iResident_ID.value; df0.submit(); }
	function cancelnewsource(){ document.all['newsource'].innerHTML=""; df0.iGroup_ID[0].selected = true;}
	function cancelcategories(){ if (!document.all['cat'] == false) { document.all['cat'].innerHTML="";} }
	function categorieslist(groupobj){ 
		if (df0.NewSource.value == "") { alert('Please enter a new sourcename' ); df0.NewSource.focus(); }
		if(!groupobj == false && groupobj.value == "" && !document.all['cat'] == false){ 
			c="<table class='noborder' style='width:100%;'>";
			c+="<tr><td>What name would you like to give this group? <br><input type='text' name='groupname' value='' onBlur='trimspaces(this);'></td></tr>";
			c+="<tr><td style='vertical-align:top;'>";
			c+="How would you categorize this group? <br><select name='categories'><cfloop query='qCategories'><option value='#qCategories.iCategory_ID#'>#qCategories.cDescription#</option></cfloop></select>";
			c+="</td></tr></table>"; 
			document.all['cat'].innerHTML = c; df0.groupname.focus();} 

		else { cancelcategories(); }
	}
	function validategroupname(obj){ if(obj.value==""){ alert('please enter group name'); obj.focus(); } }
	function validatesourcename(obj){ if(obj.value==""){ alert('please enter source name'); obj.focus(); } else { shownewgroup(obj); }}
	function initializesource(obj){
		for (g=0;g<=obj.value.length-1;g++){ if (obj.value.charAt(g) == "g" && obj.value !== ""){ obj.name = "iGroup_ID"; }	else { obj.name="iSource_ID"; }}
	}
	
	function newsource(obj){
		initializesource(obj);
		if (obj.value == ""){ 
			document.all['newsource'].style.display='inline'; 
			if (document.all['sourcecont']) { document.all['sourcecont'].style.display='none'; }
			s="<table border='1' style='width:200;'>";
			s+="<tr><td nowrap>What would you like to name this source? <br><input type='text' name='NewSource' size='20' value='' onBlur='trimspaces(this); shownewgroup(this); if (!df0.groups == false) { df0.groups.focus(); }'>"; 
			s+=" <a id='sourcecont' style='background:##eaeaea;padding:1px;color:blue;border:1px solid blue;' onmouseover='aOver();'><b>Continue</b></a> </td></tr>";
			s+="<tr><td><span id='newgroup'></span></td></tr>";
			s+="</table>";
			document.all['newsource'].innerHTML=s; 
			df0.NewSource.focus();
		}
		else { document.all['newsource'].innerHTML=""; }
	}
	
	function aOver(){ 
		if(df0.NewSource.value == ''){ df0.NewSource.focus(); return false;}
		trimspaces(df0.NewSource); shownewgroup(df0.NewSource); 
		if (!df0.groups == false) {df0.groups.focus();} 
		document.all['sourcecont'].style.display='none';
	}
	
	function shownewgroup(obj){
		if (obj.value !== "" && (!df0.groups)) {
			g="<tr><td>How would you group this new source? <br><select name='groups' onChange='categorieslist(this);' onFocus='categorieslist(this);'>";
			g+="<cfloop query='qGroups'><option value='#qGroups.iGroup_ID#' style='background:whitesmoke;'>#qGroups.cDescription#</option></cfloop>";
			g+="<option value='' style='background:lightyellow;color:red;'>Make a New Group</option></select></td></tr>";
			g+="<tr><td nowrap colspan=100%><span id='cat'></span></td></tr>";
			document.all['newgroup'].innerHTML=g;
		}
		else if (obj.value == "" && df0.groups) { alert('please enter a sourcename'); obj.focus(); return false; }
		else if (obj.value !== "" && !df0.groups){ document.all['newgroup'].innerHTML=''; }
	}
	
	function addnewcontact(obj,str){
		if (obj.value == "add"){
			c="<font style='color:red;'>First Name</font> <input type='text' name='cInquirerFirstName' value='' onBlur='trimspaces(this);'><br>";
			c+="<font style='color:red;'>Last Name</font> <input type='text' name='cInquirerLastName' value='' onBlur='trimspaces(this);'><br>";
			c+="Address <input type='text' name='cInquirerAddress' value='' onBlur='trimspaces(this);'><br>";
			c+="City <input type='text' name='cInquirerCity' value='' onBlur='trimspaces(this);'><br>";
			c+="State <select name='cInquirerState' style='width: 150px;'>";
			c+="<option value=''>Choose Location</option>"; 
			<cfloop query='qStateCodes'> c+="<option value='#qStateCodes.cStateCode#'>#trim(qStateCodes.cStateName)#</option>";</cfloop>
			c+="</select><br>";
			c+="Zip <input class=smallfield type='text' name='cInquirerZip' value='#session.qselectedhouse.cZipCode#' onBlur='trimspaces(this);'><br>";
			c+="Phone <input class=smallfield type='text' name='cInquirerPhone1' value='' onBlur='trimspaces(this);'><br>";
			c+="Alt. Phone <input class=smallfield type='text' name='cInquirerPhone2' value='' onBlur='trimspaces(this);'><br>";
			document.all['newcontact'].innerHTML=c; document.all['newcontact'].style.display="inline";
			df0.cInquirerState.value='#SESSION.qSelectedHouse.cStateCode[1]#';
		}
		<cfif isDefined("qContactList") and qContacts.RecordCount gt 0>
			<cfloop query="qContactList">
				else if (obj.value == #trim(qContactlist.iInquirer_ID)#){
					c="<input type='hidden' name='iInquirer_ID' value='#qContactlist.iInquirer_ID#'>";
					c+="<font style='color:red;'>First Name</font> <input type='text' name='cInquirerFirstName' value='#JSStringFormat(qContactlist.InquirercFirstName)#' onChange='altered=true; disablelinks();'><br>";
					c+="<font style='color:red;'>Last Name</font> <input type='text' name='cInquirerLastName' value='#JSStringFormat(qContactlist.InquirercLastName)#' onChange='altered=true; disablelinks();'><br>";
					c+="Address <input type='text' name='cInquirerAddress' value='#JSStringFormat(qContactlist.cAddress)#' onChange='altered=true; disablelinks();'><br>";
					c+="City <input type='text' name='cInquirerCity' value='#qContactlist.cCity#' onChange='altered=true; disablelinks();'><br>";
					c+="State <select name='cInquirerState' style='width: 150px;' onChange='altered=true; disablelinks();'>";
					c+="<option value=''>Choose Location</option>";
					<cfset tStateCode=qContactlist.cStateCode>
					<cfloop query='qStateCodes'>
					<cfif len(trim(tStateCode)) EQ 0 and qStateCodes.CurrentRow EQ 1>
						<cfset SELECTED='selected'>
					<cfelseif trim(tStateCode) EQ trim(qStateCodes.cStateCode) and trim(tStateCode) NEQ ''>
						<cfset SELECTED='Selected'>
					<cfelse> <cfset SELECTED=''></cfif> 
					c+="<option value='#qStateCodes.cStateCode#' #Selected#>#trim(qStateCodes.cStateName)#</option>";
					</cfloop>
					c+="</select><br>";					
					c+="Zip <input class=smallfield type='text' name='cInquirerZip' value='#qContactList.cZipCode#' onChange='altered=true; disablelinks();'><br>";
					<cfif trim(qContactlist.cPhoneNumber1) NEQ ''><cfset Phone1=trim(qContactList.cPhoneNumber1)><cfelse><cfset Phone1=''></cfif>
					c+="<a onMouseOver=hoverdesc('xxx-xxx-xxxx'); onMouseOut='resetdesc();'>Phone</a> <input class=smallfield type='text' name='cInquirerPhone1' MAXLENGTH=12 value='#Phone1#'  onChange='altered=true; disablelinks();' onBlur='phone(this);'><br>";
					<cfif trim(qContactlist.cPhoneNumber2) NEQ ''><cfset Phone2=trim(qContactList.cPhoneNumber2)><cfelse><cfset Phone2=''></cfif>
					c+="<a onMouseOver=hoverdesc('xxx-xxx-xxxx'); onMouseOut='resetdesc();'>Alt. Phone</a> <input class=smallfield type='text' name='cInquirerPhone2' MAXLENGTH=12 value='#Phone2#'  onChange='altered=true; disablelinks();' onBlur='phone(this);'><br>";
					if (df0.Residents.value !== "add") { c+="<input Class='BlendedButton' type='button' Name='deleteinquirer' value='Remove This Contact' style='width: 150px;' onClick='deleteinq(#qContacts.iInquirer_ID#);'>"; }
					document.all['newcontact'].innerHTML=c; document.all['newcontact'].style.display="inline";
				}
			</cfloop>
		</cfif>
		else { document.all['newcontact'].style.display="none"; disablelinks();}
		disablelinks(); copychk();
	}
	altered=false;
	function cancel(string){
		//if( (eval(altered) == true) || (df0.ContactList.value == 'add' || df0.Residents.value == 'add')) {
		if( (eval(altered) == true) && (df0.ContactList.value == 'add' || df0.Residents.value == 'add')) {
			if (	confirm('You have not saved this information.\rAll changes will be lost.\rAre you sure?')	){ 
				if(!string == false){location.href=string;} else{location.href='Leads.cfm';} } 
			else { self.focus();}
		}
		else if ((!window.winevent == false) && (window.winevent.closed == false)) { window.winevent.focus(); }
		else { if(!string == false){ location.href=string;} else{ location.href='Leads.cfm'; } }
	}
	
	function disablelinks(){
		if ((df0.ContactList.value == 'add' || df0.Residents.value == 'add')|| ((bwinevent == true) || eval(altered) == true)){
			for (l=0;l<=document.links.length-1;l++){
				if ((document.links[l].href.indexOf("mailto:") == -1)
					&&(document.links[l].href.indexOf("javascript:cancel(") == -1) && (document.links[l].href.indexOf("http://#server_name#") == -1) ) { 
						document.links[l].href='javascript:cancel("' +document.links[l].href + '");//' + document.links[l].href; 
				}
			}
		}
		else {
			for (l=0;l<=document.links.length-1;l++){
				if (document.links[l].href.indexOf("javascript:cancel(") > -1){ href=document.links[l].href.split(';//'); href2=href[1]; document.links[l].href = href2; }
			}
		}
	}
	winevent = 0;
	function eventswindow(string){
		if (eval(!window.winevent) == false ) { window.winevent.close(); i=100; }
		winevent = window.open("EventWindow.cfm?id="+string,'EventWindow','resizable,scrollbars'); //,"fullscreen"
		winevent.resizeTo(200,100);	l = document.body.scrollLeft + 1; t = document.body.scrollTop + 1; winevent.moveTo(l,t); 
		winevent.focus(); setTimeout('resize()',100); winevent.moveTo(0,0);
	}
	function resizechild(a,b){ winevent.resizeTo(a*1,b*1);}
	i = 100;	
	function resize(){ i=i+30; winevent.resizeTo(i,(i/2)); if (i < 800) { setTimeout('resize()',15);} }
	function firstfocus(){ v=document.getElementsByTagName("SELECT"); if (v[0].disabled == false) { v[0].focus(); } }

	function checkresident(obj,str){
		if (document.all['sourcecont']) { document.all['sourcecont'].style.display='none'; }
		if (document.all['newsource']) { document.all['newsource'].style.display='none'; }
		if (obj.value !== "") { document.all['residentinformation'].style.display='inline'; populateinformation(obj,str);}
		else { document.all['residentinformation'].style.display='none', document.all['deleteresident'].style.display='none'; 
			document.all['copycontactinfo'].style.display='none', disablelinks();
		}
	}
	function copychk() { dmt=document.forms[0];
		if (!dmt.cInquirerFirstName == false && dmt.Residents.value == "add") { 
			document.all['copycontactinfo'].style.display='inline';
			v="<input type='button' name='copycontact' value='copy contact information' onclick='copyinfo()'>";
			document.all['copycontactinfo'].innerHTML=v;
		}
		else { document.all['copycontactinfo'].style.display='none'; }	
	}
	function populateinformation(obj,str){
		dmt=document.forms[0]; copychk();
		if (obj.value == "add"){ 
			dmt.iResident_ID.value='' ,dmt.cFirstName.value='' ,dmt.cLastName.value='' ,dmt.cAddress.value='' ,dmt.cCity.value='';
			dmt.cStateCode.value='#trim(SESSION.qSelectedHouse.cStateCode)#';
			dmt.cZipCode.value='#session.qselectedhouse.cZipCode#' ,dmt.cPhoneNumber.value='' ,dmt.cSSN.value='' ,dmt.dtBirthDate.value='';
			dmt.cSex.value='Female', dmt.iMaritalStatus_ID.value='#trim(qMaritalStatus.iMaritalStatus_ID[1])#';
			dmt.iDecisionTime_ID.value='#qDecisionTime.iDecisionTime_ID[1]#', dmt.iAptType_ID.value='#qAptType.iAptType_ID[1]#';
			dmt.iCurrentSituation_ID.value='#qCurrentSituation.iCurrentSituation_ID[1]#';
			document.all['deleteresident'].style.display='none';
		}

		for (a=0;a<=qResidentsJS["iresident_id"].length-1;a++) {								
			if (obj.value == qResidentsJS["iresident_id"][a]){
				dmt.cFirstName.value = qResidentsJS["cfirstname"][a], dmt.cLastName.value = qResidentsJS["clastname"][a];
				dmt.cAddress.value = qResidentsJS["caddressline1"][a], dmt.cCity.value = qResidentsJS["ccity"][a];
				dmt.cStateCode.value = qResidentsJS["cstatecode"][a], dmt.cZipCode.value = qResidentsJS["czipcode"][a];
				dmt.cPhoneNumber.value = qResidentsJS["cphonenumber1"][a], dmt.cSSN.value = qResidentsJS["cssn"][a];
				if (qResidentsJS["dtbirthdate"][a].length !== 0) { 
					dmt.dtBirthDate.value = (qResidentsJS["dtbirthdate"][a].getMonth()+1)+'/'+qResidentsJS["dtbirthdate"][a].getDate()+'/'+qResidentsJS["dtbirthdate"][a].getFullYear(); 
				} 
				else { dmt.dtBirthDate.value=''; }
				dmt.cSex.value = qResidentsJS["csex"][a];
				dmt.iMaritalStatus_ID.value = qResidentsJS["imaritalstatus_id"][a];
				dmt.iDecisionTime_ID.value = qResidentsJS["idecisiontime_id"][a], dmt.iAptType_ID.value = qResidentsJS["iaptpreftype_id"][a];
				dmt.iCurrentSituation_ID.value = qResidentsJS["icurrentsituation_id"][a];
				dmt.Residents.value = qResidentsJS["iresident_id"][a], dmt.iResident_ID.value = qResidentsJS["iresident_id"][a];
				if (qResidentsJS["isource_id"][a].length !== 0) { dmt.iGroup_ID.value = qResidentsJS["isource_id"][a]; } else { dmt.iGroup_ID.value = qResidentsJS["igroup_id"][a]+'g'; }
				if (dmt.iGroup_ID.options.selectedIndex == -1) { dmt.iGroup_ID.options[0].selected = true; }
				if (qResidentsJS["iresident_id"][a] !== '') {
					document.all['deleteresident'].style.display='inline';
					document.all['deleteresident'].innerHTML="<input type='button' class=BlendedButton style='width:150px;' name='DeleteResident' value='Delete this Resident' onClick=location.href='DeleteResident.cfm?resid="+qResidentsJS["iresident_id"][a]+"'>";
				}
				else { document.all['deleteresident'].style.display='none'; }
			}
		}
		if (obj.value == "") { df0.Residents.value = ''; document.all['residentinformation'].style.display='none'; document.all['deleteresident'].style.display='none'; }
		disablelinks();
		if (str !== 'inq') {
		for(a=0;a<=qContactsJS["iinquirer_id"].length-1;a++) { 
			if (dmt.Residents.value == qContactsJS["itenant_id"][a]) { 
				dmt.ContactList.value = qContactsJS["iinquirer_id"][a];
				addnewcontact(dmt.ContactList,'res');
				break;
			}
		}
		}
	}
	function copyinfo() {
		df0=document.forms[0], df0.cFirstName.value=df0.cInquirerFirstName.value, df0.cLastName.value=df0.cInquirerLastName.value;
		df0.cAddress.value=df0.cInquirerAddress.value, df0.cCity.value=df0.cInquirerCity.value, df0.cStateCode.value=df0.cInquirerState.value;
		df0.cZipCode.value=df0.cInquirerZip.value, df0.cPhoneNumber.value=df0.cInquirerPhone1.value;
	}	
	function loadoutput(){ 
		window.status=document.forms.length;
	}
	
	function assessredirect(str) {
		if ( confirm("An assessment needs to be completed and activated for this resident before the move in may be started.\rWould you like to do this now?") == true) {
		//loc="../AssessmentTool/tips4link.cfm?i="+str; self.location.href=loc;
		loc="../AssessmentTool_v2/index.cfm"; self.location.href=loc;
		}
		//Modified by Jaime Cruz to just open the assessment tool without begining the new assessment. Removed code commented below.
		//?fuse=newAssessment&tenantId="+ str + "&assessmentType=tenant
		//else if (confirm("Continue the move in process?") == true) { loc="../MoveIn/MoveInForm.CFM?ID="+str; self.location.href=loc; }
	}
		
	window.onunload=function(){ if (eval(!window.winevent) == false) {window.winevent.close();} }
	document.onmouseup=function(){ if ( (!window.winevent == false) && (window.winevent.closed == false) ){ clearTimeout(winevent.focustimer); winevent.top();} }
	window.onload=initial;
</script>
<cfscript>
	If (isDefined("iResident_ID")) {
		ResidentID = qResident.iResident_ID;
		ResidentFirstName = qResident.cFirstName;
		ResidentLastName = qResident.cLastName;
		ResidentAddress = qResident.cAddressLine1;
		ResidentCity = qResident.cCity;
		ResidentState = qResident.cStateCode;
		ResidentZip = qResident.cZipCode;
		ResidentPhone = PhoneFormat(IsBlank(qResident.cPhoneNumber1,''));
		ResidentSSN = SSNFormat(qResident.cSSN);
		ResidentSex= qResident.cSex;
		ResidentBirthDate = DateFormat(qResident.dtBirthDate,"mm/dd/yyyy");
		ResidentMaritalStatus = qResident.iMaritalStatus_ID;
		ResidentDecisionTime = qResident.iDecisionTime_ID;
		ResidentCurrentSituation = qResident.iCurrentSituation_ID;
		ResidentAptPref = qResident.iAptPrefType_ID;
		ResidentSource = qResident.iSource_ID;
		ResidentGroup = qResident.iGroup_ID;
		ResidentStatus = qResident.iStatus_ID; }
	else {
		ResidentID = ''; ResidentFirstName = ''; ResidentLastName = ''; ResidentAddress = ''; ResidentCity = '';
		ResidentState = '';	ResidentZip=''; ResidentPhone = ''; ResidentSSN = ''; ResidentSex='Male'; ResidentBirthDate = ''; ResidentMaritalStatus = '';
		ResidentDecisionTime = ''; ResidentCurrentSituation = ''; ResidentAptPref = '';  ResidentSource = ''; ResidentGroup = '';
		ResidentStatus = 1;	}
</cfscript>
<cfset bottomborder="border-bottom: 1px solid gainsboro;">
<style> 
	.tempheader{font-size:xx-small; background:484848; font-weight:bold;} 
	.subth { font-size: xx-small; background: ##ccccff; color:##464646; letter-spacing:0.8px;}
	.tdcell { background: white; color: ##336699; font-size: xx-small; }
	.tdstyle { background: white; color: ##336699; font-size: xx-small; border-bottom: 1px solid black;}
</style>
<form action="" method="POST">
<input type="hidden" name="formcount" value="">
<input type="hidden" name="iResident_ID" value="#ResidentID#">
<input type="hidden" name="iStatus_ID" value="#ResidentStatus#">
<table class="noborder">
	<tr>
		<td class="leftborder">#SESSION.FullName#</td>
		<td style="#center#"><a href="http:\\#server_name#\intranet\logout.cfm">Click Here to Logout</a></td>
		<td class="rightborder" style="#right#"><a href="http:\\#server_name#\intranet\TIPS4\Index.cfm">Select New House</a></td>
	</tr>
	<tr><th class="topleftcap"></th><th colspan=100 class="toprightcap"></th></tr>
	<tr>
	<td colspan="4" class="leftrightborder" style="background:##eaeaea;#center#">
		<cfinclude template="../TIPS4/buttonmainmenu.cfm">
	</td>
	</tr>
	<tr><th colspan="4" style="#center#">#SESSION.qSelectedHouse.cName#</th></tr>
	<!--- 4/24/09 JHC - quick change. Disable following IF on opsarea 29--->
	<!--- 5/26/09 JHC - Commented out entire section for entering new leads as part of project 18650 --->
	<cfif (Session.FullName eq 'Jaime Cruz' or Session.FullName eq 'Gwendolyn Morgan') and session.qSelectedHouse.iHouse_id eq 200>
	<tr><td class="leftborder">
	<table style='width:100%;' border="1">
	<tr><td class='subheader' nowrap>Inquirer Name</td></tr>
	</tr>
		<cfscript>
			if (isDefined("qContactList") and qContactList.RecordCount gt 0 and isDefined("url.iResident_ID") and qContactList.RecordCount gt 5) { size="size=5"; }
			else if (qContactList.RecordCount lt 5) { size="size=#Evaluate(qContactList.RecordCount+1)#"; }
			else { size=''; }
		</cfscript>
		<td nowrap style="#right#">
			<select name="ContactList" #size# onChange="addnewcontact(this);">
				<cfif size EQ ''><option value='Choose'>Choose Contact</option></cfif>
				<cfif isDefined("qContacts") and qContacts.RecordCount gt 0>
					<cfloop query="qContactList"><cfscript>if (isDefined("url.inq") and url.inq EQ qContactList.iInquirer_ID){Selected='Selected';}else{Selected='';}</cfscript>
						<option value='#qContactList.iInquirer_ID#' #Selected#>#qContactList.InquirercFirstName# #qContactList.InquirercLastName#</option>
					</cfloop>
				</cfif>
				<option value='add' style='background:lightyellow;color:red;'>Add New Contact</option>
			</select><br>
			<span id="newcontact" style="#right#"></span>
		</td>
		</tr>	
	</table>
		<td nowrap style="#center#">
			<table style="width:100%;" border=1>
				<tr><td class='subheader' colspan=100%>Resident Information</td></tr>
				<tr>
					<td nowrap colspan=100% style='text-align:right;'>
						<select name='Residents' onChange='checkresident(this);'>
							<option value=''>Choose Resident</option>
							<cfloop query='qResidents'><cfif ResidentID EQ qResidents.iResident_ID><cfset Selected='selected'><cfelse><cfset Selected=''></cfif><option value='#qResidents.iResident_ID#' #selected#>#qResidents.cLastName#, #qResidents.cFirstname#</option></cfloop>
							<option value='add' style='color:red;background:lightyellow;'>Add New Resident</option>
						</select><br>
						<span id='residentinformation' style='display:none;'>
							<font style='color:red;'>First Name</font> <input type="text" name="cFirstName" value='#JSSTringFormat(ResidentFirstName)#' onChange='altered=true; disablelinks(); this.value=ltrs(this.value);' onKeyUp='trimspaces(this);'><br>
							<font style='color:red;'>Last Name</font> <input type="text" name="cLastName" value="#JSStringFormat(ResidentLastName)#" onBlur='trimspaces(this);' onChange='altered=true; disablelinks(); this.value=ltrs(this.value);' ><br>
							Address <input type='text' name='cAddress' value='#ResidentAddress#' MAXLENGTH=50 onChange='altered=true; disablelinks();' onBlur='trimspaces(this);'><br>
							City <input type='text' name='cCity' value='#ResidentCity#' onChange='altered=true; disablelinks(); this.value=ltrs(this.value);' onBlur='trimspaces(this);'><br>
							State 
							<select name="cStateCode" style="width: 150px;" onChange='altered=true; disablelinks();'>
								<cfloop query="qStateCodes"> <cfif ResidentState EQ qStateCodes.cStateCode><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif> <option value="#qStateCodes.cStateCode#" #Selected#>#trim(qStateCodes.cStateName)#</option> </cfloop>
							</select><br>
							Zip <input class="smallfield" type='text' name='cZipCode' value='#ResidentZip#' style="text-align:center;" MAXLENGTH=10 onChange='altered=true; disablelinks();' onBlur='trimspaces(this);'><br>
							<a onMouseOver="hoverdesc('xxx-xxx-xxxx');" onMouseOut="resetdesc();">Phone Number</a> <input class="smallfield" type='text' name='cPhoneNumber' value='#ResidentPhone#' style="text-align:center;" size=12 MAXLENGTH=12 onChange="this.value=CreditNumbers(this.value);" onBlur="trimspaces(this); phone(this);"><br>
							<a onMouseOver="hoverdesc('xxx-xx-xxxx');" onMouseOut="resetdesc();">SSN</a> <input class="smallfield" type='text' name='cSSN' value='#ResidentSSN#' style="text-align:center;" size=11 MaxLength=11 onBlur='trimspaces(this);' onKeyUp="this.value=CreditNumbers(this.value);"><br>
							<a onMouseOver="hoverdesc('mm/dd/yyyy');" onMouseOut="resetdesc();">BirthDate</a> <input class="smallfield" type='text' name='dtBirthDate' value='#ResidentBirthDate#' style="text-align:center;" size=10 MAXLENGTH=10 onBlur="trimspaces(this); if (this.value.length !== 0) { Dates(this); }"><br>
							Sex <select name="cSex" onChange='altered=true; disablelinks();'><option value="Female">Female</option><option value="Male">Male</option></select><br>
							Marital Status 
							<select name="iMaritalStatus_ID" onChange='altered=true; disablelinks();'>
								<cfloop query="qMaritalStatus">
									<cfif ResidentState EQ qMaritalStatus.iMaritalStatus_ID><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif>
									<option value="#qMaritalStatus.iMaritalStatus_ID#" #Selected#>#qMaritalStatus.cDescription#</option>
								</cfloop>
							</select><br>
							Decision Time 
							<select name="iDecisionTime_ID" onChange='altered=true; disablelinks();'>
								<cfloop query="qDecisionTime">
									<cfif ResidentDecisionTime EQ qDecisionTime.iDecisionTime_ID><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif>
									<option value="#qDecisionTime.iDecisionTime_ID#" #Selected#>#qDecisionTime.cDescription#</option>
								</cfloop>
							</select><br>
							Apt Pref. 
							<select name="iAptType_ID" onChange='altered=true; disablelinks();'>
								<cfloop query="qAptType">
									<cfif ResidentAptPref EQ qAptType.iAptType_ID><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif>
									<option value="#qAptType.iAptType_ID#" #Selected#>#qAptType.cDescription#</option>
								</cfloop>
							</select>
							<br>
							Current Living
							<select name="iCurrentSituation_ID" onChange='altered=true; disablelinks();'>
								<cfloop query="qCurrentSituation">
									<cfif ResidentCurrentSituation EQ qCurrentSituation.iCurrentSituation_ID><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif>
									<option value="#qCurrentSituation.iCurrentSituation_ID#" #Selected#>#qCurrentSituation.cDescription#</option>
								</cfloop>
							</select>
							<br>
						</span>
						<dd><span id="copycontactinfo"></span></dd>
						<dd><span id='deleteresident'></span></dd>
					</td>
				</tr>					
			</table>			
		</td>
		<td class="rightborder">
			<table style='width:100%;' border=1>
				<tr><td class='subheader'>Referral Source</td></tr>
				<tr>
					<td>
						<select name="iGroup_ID" onChange="newsource(this);">
							<cfloop query="qGroups">
								<cfif ResidentGroup EQ qGroups.iGroup_ID><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif>
								<option value="#qGroups.iGroup_ID#g" style="color:navy;" #Selected#>#qGroups.cDescription#</option>
								<cfquery name="qSourceList"  dbtype="query">
								select isource_id ,cdescription from qSources where iGroup_ID = #qGroups.iGroup_ID#
								</cfquery>
								<cfloop query="qSourceList">
									<cfif ResidentSource EQ qSourceList.iSource_ID><cfset Selected='Selected'><cfelse><cfset Selected=''></cfif>
									<option value="#trim(qSourceList.iSource_ID)#" #Selected# style="color:indigo;">&nbsp;&nbsp;#qSourceList.cDescription#</dd></option>
								</cfloop>
							</cfloop>
							<option value='' style="background:lightyellow;color:red;">New Source</option>
						</select>
						<span id='newsource' style='display:none;'></span>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td class="bottomleftborder"><input class='BlendedButton' style='color:darkgreen;' type="button" name="Save" value="Save" onClick='savebuttoncheck();'></td>
		<td class="bottomrightborder"colspan=100% style="#right#"><input Class="BlendedButton" type="button" name="Cancel" value="Cancel" onClick="cancel();"></td>
	</tr></cfif>
</table>
</form>

<!--- SECTION TWO --->
<cfscript> 
	if ((IsDefined("url.com") and url.com EQ 'true') OR (IsDefined("iResident_ID") and qResident.iStatus_ID EQ 6)){ comchecked='checked'; lstchecked=''; michecked=''; uref='com';} 
	else if ((IsDefined("url.lst") and url.lst EQ 'true') OR (IsDefined("iResident_ID") and qResident.iStatus_ID EQ 5)){lstchecked='checked'; comchecked=''; michecked=''; uref='lst';}
	else if ( IsDefined("url.mi") and url.mi EQ 'true' ){ michecked='checked'; comchecked=''; lstchecked=''; uref='mi';}
	else{ comchecked=''; lstchecked=''; michecked=''; uref='';}
</cfscript>
<table class="noborder">
	<tr><td class="topleftcap" colspan=2></td><td class="toprightcap" colspan=100></td></tr>
	<tr class="top">
		<th nowrap colspan='2'><a style="color: white;" href="Reports/InquiryReports.cfm">Inquiry Reports</a></th>
		<th colspan='2' style="text-align:left;font-size:xx-small;">
			<input type="checkbox" name="Committed" value=0 style="width:20px;" #comchecked# onClick="location.href='?com='+this.checked"> Show Moved In Prospects
		</th>
		<th colspan='2' style="text-align:left;font-size:xx-small;"><input type="checkbox" name="Lost" value=0 style="width:20px;" #lstchecked# onClick="location.href='?lst='+this.checked"> Show Lost Prospects</th>
		<th colspan='2' style="text-align:left;font-size:xx-small;">
			 <!--- <input type="checkbox" name="Committed" value=0 style="width:20px;" #michecked# onClick="location.href='?mi='+this.checked"> --->
			 <a href="../TIPS4/Registration/Registration.cfm?previoustenants=1" style="color:white;">Show prior moved in residents</a>
		</th>
	</tr>
	<cfquery name='qResidentEventDue'  dbtype='query'>
	select * from qEvents where inextactiontype_id > 0
	</cfquery>
	<tr>
		<a onMouseOver="hoverdesc('Show recorded events & actions')" onMouseOut="resetdesc();"><td class="leftborder" style="#center# #bold# #gainsboro#">Actions</td></a>
		<td style="#center# #bold# #gainsboro#">Inquirer</td>
		<td style="#center# #bold# #gainsboro#"><a href="leads.cfm?sort=ref" onMouseOver="hoverdesc('Sort by Refferal Source')" onMouseOut="resetdesc();">Referral Source</a></td>
		<td style="#center# #bold# #gainsboro#"><a href="leads.cfm?sort=res" onMouseOver="hoverdesc('Sort by Tenant Last Name')" onMouseOut="resetdesc();">Resident</a></td>
		<td style="#center# #bold# #gainsboro#"><a href="leads.cfm?sort=entered" onMouseOver="hoverdesc('Sort by Initial Entry')" onMouseOut="resetdesc();">Date entered</a></td>
		<td style="#center# #bold# #gainsboro#"><a href="leads.cfm?sort=stat" onMouseOver="hoverdesc('Sort by Status')" onMouseOut="resetdesc();">Status</a></td>
		<td style="#center# #bold# #gainsboro#">Action</td>
		<cfif isDefined("qResidentEventDue.dtDue") and qResidentEventDue.dtDue neq ''>
			<td class="rightborder" style="#center# #bold# #gainsboro#">Next-action Date</td>
		</cfif>
	</tr>

	<cfif qResidents.RecordCount gt 0>
		<cfloop query="qResidents">
		<!--- <form name="form#qResidents.iResident_ID#" action="" method="POST"> --->
		<cfquery name="qInquirers" datasource="#DSN#">
			select isNull(I.cFirstName,'none') as cFirstName, isNULL(I.cLastName,'none') as cLastName, I.iInquirer_ID
			from InquirerToResidentLink IR 
			join Inquirer I on (I.iInquirer_ID = IR.iInquirer_ID and I.dtRowDeleted IS NULL)
			where IR.dtRowDeleted IS NULL and IR.iResident_ID = #qResidents.iResident_ID#
		</cfquery>
		
			
		
		<!--- Query main events query for resident specific information --->
		<cfquery name='qResidentEvents'  dbtype='query'>
		select distinct cShortDescription ,cLongDescription ,EventStart, iEvent_ID
		from qEvents where iResident_ID=#qResidents.iResident_ID#
		order by eventstart desc
		</cfquery>
		


		<!--- Query for next due date that is coming up --->
		<cfquery name='qDueDate'  dbtype='query'>
		select dtDue ,clongdescription ,cshortdescription from qEvents where iResident_ID=#qResidents.iResident_ID#
		and dtdue <> '1900-01-01' <!--- and dtdue >= '#DateFormat(now(),"yyyy-mm-dd")#' --->
		order by dtDue desc
		</cfquery>
		

		
		<script>
			// toggle display
			function showevents#qResidents.iResident_ID#(obj){
				der=document.all['eventarea_#qResidents.iResident_ID#'];
				if (der.style.display == 'none'){ der.style.display='inline';} 
				else{ der.style.display='none';}
			}
		</script>
		<tr>
			<td class="leftborder" style='#center# #bottomborder#'>
				<cfif qResidentEvents.RecordCount gt 0>	
				<a class="A_nohighlight" id='view#qResidents.iResident_ID#' href='javascript:showevents#qResidents.iResident_ID#(this);' onmouseover="return false;">
					<img name="view_#qResidents.iResident_ID#" SRC="view.gif" alt="view" border="0" onmouseover="src='../MarketingLeads/o_view.gif'" onmouseout="src='../MarketingLeads/view.gif'">
				</a> 
				</cfif>
			</td>
			<td style="#bottomborder#">
				<!--- <cfset ref='?iResident_ID=#qResidents.iResident_ID#&inq=#qInquirers.iInquirer_ID#&sort=#sort#&ref=#uref#'> --->
				<cfset click="df0.Residents.value=#qResidents.iresident_id#; checkresident(df0.Residents); firstfocus();">
				<cfif qInquirers.RecordCount gt 0>
					<cfset tmpiResident_ID = qResidents.iResident_ID>
					<cfloop Query='qInquirers'>
						<cfset InquirerName = qInquirers.cFirstName & ' ' & qInquirers.cLastName>
						<!--- <a href="?iResident_ID=#tmpiResident_ID#&inq=#qInquirers.iInquirer_ID#&sort=#sort#&uref=#ref#">#isBlank(InquirerName,'none')#<br></a> --->
						<cfset inqclick="df0.ContactList.value='';df0.ContactList.value=#qInquirers.iInquirer_ID#; df0.Residents.value=#tmpiResident_ID#; checkresident(df0.Residents,'inq'); addnewcontact(df0.ContactList); firstfocus();">
						<a href="javascript:;" onClick="#inqclick#">#isBlank(InquirerName,'none')#<br></a>
					</cfloop>
				<cfelse> <a href="javascript:;" onClick="#click#">none</a> </cfif>
			</TD style="#bottomborder#">
			<td style="#bottomborder#"><a href="javascript:;" onClick="#click#">#qResidents.sourcename#</a></td>
			<!--- <td style="#bottomborder#"><a href="#ref#">#qResidents.cLastName#, #qResidents.cFirstName# </a></td> --->
			<td style="#bottomborder#"><a href="javascript:;" onClick="#click#">#qResidents.cLastName#, #qResidents.cFirstName# </a></td>
			<td style="#bottomborder# #right#"><a href="javascript:;" onClick="#click#">#dateformat(qResidents.startdate,"mm/dd/yy")#</a></td>
			<td style="#bottomborder#" nowrap> #qResidents.status# </td>
			<td style='#center# #bottomborder#'>
				<cfif qResidents.iStatus_ID neq '5' and qResidents.iStatus_ID neq '6'>
					<a class="A_nohighlight" href="javascript:eventswindow('#qResidents.iResident_ID#');">
						<img SRC="new.gif" alt="[New Entry]" border=0 onMouseOver="src='../MarketingLeads/o_new.gif'" onMouseOut="src='../MarketingLeads/new.gif'">
					</a>
					<cfif qResidents.iStatus_ID eq '7' and qresidents.dtmovein neq "">
						<cfif qresidents.numactive gt 0>
							<a href="../TIPS4/MoveIn/MoveInForm.cfm?id=#trim(qResidents.itenant_id)#" style="text-decoration:none;background:##006699;color:yellow;padding: 0 2px 0 2px;">
							<b>Move-in</b>
							</a>
						<cfelse>
							<a style="text-decoration:none;background:##006699;color:yellow;padding: 0 2px 0 2px;" onClick="assessredirect(#trim(qResidents.itenant_id)#)">
							<b>Move-in</b>
							</a>
						</cfif>
					</cfif>
				</cfif>
			</td>
			<cfif isDefined("qResidentEventDue.dtDue") and qResidentEventDue.dtDue neq '' and qResidents.istatus_id neq 7>
				<cfif qDueDate.DTDUE gte now()><cfset c="color:blue;font-weight:bold;"><cfelse><cfset c="color:gray;"></cfif>
				<cfif len(trim(qDueDate.clongdescription[1])) gt 0 and 1 eq 0><cfset desc="hoverdesc('<u>#DateFormat(qDueDate.DTDUE,"mm/dd/yyyy")#</u> <li>#JSStringformat(qDueDate.clongdescription[1])#</li>');"><cfelse><cfset desc=""></cfif>
				<td class="rightborder" onMouseOver="#jsstringformat(desc)#" onMouseOut="resetdesc();" style="#bottomborder# #center# #c#"> 
				<a>#DateFormat(qDueDate.dtdue[1],"mm/dd/yyyy")#</a>
				<!--- <cfdump var="#qduedate#"> --->
				</td>
			<cfelseif qResidents.istatus_id eq 7 >
				<td class="rightborder" style="color:blue;#bottomborder# #center#"> 
					<cfif qresidents.dtmovein neq "">	<span style="background:##eaeaea;color:blue;">move-in projected on<br/> #DateFormat(qresidents.dtmovein,"mm/dd/yyyy")#</span> </cfif>
				</td>
			</cfif>
				
		</tr>
	
		<tr>
			<td colspan=100 class="leftrightborder" style="text-align:right;">
				<cfif qResidentEvents.RecordCount gt 0>
				<span id='eventarea_#qResidents.iResident_ID#' style="display:none; width:99%;">
				<table style='width:100%; border:none;'>
					<tr><td style="color:##6F6F6F;">
						<cfset tmpResidentid= qResidents.iResident_ID>
						<cfloop query='qResidentEvents'>
						<dd> 
						<!--- toggle event view --->
						<script> //toggle_#qResidentEvents.iEvent_ID# = -1;
						function display_#qResidentEvents.iEvent_ID#(){
							//toggle_#qResidentEvents.iEvent_ID# = toggle_#qResidentEvents.iEvent_ID# * -1; if (toggle_#qResidentEvents.iEvent_ID# > 0){ 
							if (document.all['Event_#qResidentEvents.iEvent_ID#'].style.display=='none') {
								document.all['Event_#qResidentEvents.iEvent_ID#'].style.display='inline'; document.all['visualexpand__#qResidentEvents.iEvent_ID#'].innerHTML='<FONT class="tdstyle"><strong> ^ </strong></FONT>'; 
							}
							else { document.all['Event_#qResidentEvents.iEvent_ID#'].style.display='none'; document.all['visualexpand__#qResidentEvents.iEvent_ID#'].innerHTML='<FONT class="tdstyle"><strong> + </strong></FONT>';}
						}
						</script>
						<cfif len(trim(qResidentEvents.cLongDescription)) gt 0>
							<!--- hoverdesc() --->
							<cfset mov="#trim(replacenocase(qResidentEvents.cLongDescription,"""","'","all"))#">
							<cfset mou="resetdesc()">
						<cfelse>
							<cfset mov=""><cfset mou="">
						</cfif><!--- onMouseOver="#mov#" onMouseOut="#mou#"  --->
						<a title="#mov#"style='font-size:xx-small;' onClick="display_#qResidentEvents.iEvent_ID#(); return false;">
							<strong>
							<span id='visualexpand__#qResidentEvents.iEvent_ID#' class="tdstyle"><strong> + </strong></span>
							#qResidentEvents.currentrow#)
							<U> #qResidentEvents.cShortDescription# <Font style='font-size:xx-small;'>(#DateFormat(qResidentEvents.EventStart,"mm/dd/yy")# #TimeFormat(qResidentEvents.EventStart,"hh:mmtt")# PST)</font></U>
							</strong>
						</a>
						<strong>
						<cfquery name='qEventActions'  dbtype='query'>
						select 
								 [Action] 
								,iEvent_ID 
								,detailcomments 
								,detailstart
								,dtdue
								,inextactiontype_id
								,cnextcomments
								,ccomments
						from 
							qEvents 
						where 
							iResident_ID=#tmpResidentid# 
						and 
							iEvent_ID = #qResidentEvents.iEvent_ID#
						order by 
							detailstart desc
						</cfquery>

						<br>
						<a id='Event_#qResidentEvents.iEvent_ID#' style="display:none;color:black;">
						<cfif qEventActions.RecordCount gt 0>
							<dd>
							<table style="width:90%; border: 1px inset ##ccccff;">
							<tr>
								<th class="subth" nowrap style="width:10%;">Last Action</th>
								<th class="subth" nowrap style="width:30%;">Comments</th>
								<th class="subth" nowrap style="width:10%;">Next action</th>
								<th class="subth" nowrap style="width:20%;">Due Date</th>
								<th class="subth" nowrap style="width:30%;">Comments for next action</th>
							</tr>
							<cfloop query='qEventActions'>
							<cfset nextaction=''>
							<cfif qEventActions.iNextActionType_id neq ''>
								<cfquery name='qNextEvent' datasource='#DSN#'>
								select cdescription from actiontype where iactiontype_id = #qEventActions.iNextActionType_id#
								</cfquery>
								<cfset nextaction=qNextEvent.cdescription>
							<cfelse> <cfset nextaction=''> </cfif>
							<tr>
								<td class="tdcell">#qEventActions.Action#:</td>
								<td class="tdcell"><cfif qEventActions.detailcomments NEQ ''><strong>"#jsstringformat(trim(qEventActions.detailcomments))#"</strong></cfif></td>
								<td class="tdcell">#nextaction#:</td>
								<td class="tdcell"><cfif qEventActions.dtdue NEQ '1900-01-01'>#trim(DateFormat(qEventActions.dtDue,"mm/dd/yyyy"))#</cfif></td>
								<td class="tdcell"><cfif qEventActions.cNextComments NEQ ''>#trim(qEventActions.cNextComments)#</cfif></td>
							</tr>
							<tr><td class="tdcell" colspan="5" style="border-top:1px solid ccccc;color:black;">#mov#</td></tr>
							<cfif len(trim(qEventActions.cComments)) neq 0>
							<tr>
							<td class="tdstyle" colspan="1">Comments: </td>
							<td colspan="4" class="tdstyle">#jsStringFormat(qEventActions.cComments)#</td>
							</tr>
							</cfif>
						
							</cfloop>
							</table></dd><br>
						</cfif>
						</a>
					</strong></dd></cfloop>

				</td></tr>
				</table>
				</span>
				</cfif>
			</td>
		</tr>
		<!--- AMAL #qResidents.iResident_ID# #qResidents.currentrow# --->
		
		 <cfif qResidents.currentrow eq qResidents.recordcount>
			<script>setTimeout("loadoutput()",500);</script>
		</cfif>
		<!--- </form> --->
		</cfloop>
	<cfelse> <tr><td colspan="8">No Records found.</td></tr> </cfif>
	<tr><td class="bottomleftcap" colspan="4"></td><td class="bottomrightcap" colspan="4"></td></tr>
</table>
</cfoutput>
<script>
// reset window status
window.status='';
</script>

<cfinclude template="../Footer.cfm">


