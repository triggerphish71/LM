
<CFOUTPUT>
<HEAD>
<SCRIPT>
	bUsed = 0; //initialize flag to see if form is un use & set close flag to false
	// timer focus on child window to ensure user processing
	function top(string){ 
		// set timer to bring child window to front if placed in back... used to ensure user processing.
		if (string == 1){ alert('You have started a new event that has not been saved. \r Please finish or cancel this event before continuing.'); } 
		if (this.closed == false) { 
			try { opener.bwinevent = true; opener.disablelinks(); } catch (exception) { /*none*/ }
			self.focus(); focustimer=setTimeout('top(0)',30000);
		} 
		else { opener.bwinevent = false; opener.disablelinks();} }
		
	// function that determines if any form fields are in use
	function inUse(string){ 
		if (bUsed !== 1){ clearTimeout(focustimer); if(string = 1){ bUsed=1; focustimer=setTimeout('top(1)',60000); } else { bUsed=0; top(); } }
	}
	
	// if child window is closed set bit in parent for this child window to false and allow link clicks
	window.onunload=function(){ try {opener.bwinevent = false; opener.disablelinks();} catch (exception) { /**/ } }
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
		if(document.forms[0].cShortDescription.value.length < 4){
			alert('The event descriptions must be alteast 5 characters long'); return false;
		}
		else { document.forms[0].submit(); return true; } //alert('else'); 
	}
	checkboxcount = 0;
	function detailcheckboxcheck(obj){
		if (obj.name.indexOf('detail') !== -1 ){
			nameaslist = obj.name.split('__'); actiontype = nameaslist[1]; objname = 'checkbox__' + actiontype;	fullobjname = eval('document.forms[0].' + objname);
			if (obj.value.length > 0){ fullobjname.checked = true; checkboxcount = checkboxcount+1;}
			else { fullobjname.checked = false; checkboxcount = checkboxcount-1; }
		}
		else if (obj.name.indexOf('checkbox') !== -1 ){ if(obj.checked == true){ checkboxcount = checkboxcount+1; } else { checkboxcount = checkboxcount-1; } }
	}
	function committed(obj){
		if (obj.value == 6) { document.all['requiredinformation'].style.display = "inline";	}
		else { if ( document.all['requiredinformation'].innerHTML.length > 0) { document.all['requiredinformation'].style.display = "none";} }
		resizewindow();
	}
</SCRIPT>
</HEAD>
<LINK REL='stylesheet' type='text/css' HREF='http://#server_name#/intranet/tips4/shared/style3.css'>
<CFSET DSN='LeadTracking'>

<!--- Query for resident information --->
<CFQUERY NAME='qResident' DATASOURCE='#DSN#'>
	SELECT	cFirstName ,cLastName ,iResident_ID , (cLastName + ', '+ cFirstName) as FullName
			,cAddressLine1 ,cCity ,cStateCode, cZipCode
	FROM	Resident WHERE	dtRowDeleted IS NULL AND iResident_ID = #id#
</CFQUERY>

<!--- Query for Status Information --->
<CFQUERY NAME='qStatus' DATASOURCE='#DSN#'>
	SELECT cDescription, iStatus_ID FROM Status WHERE dtRowDeleted IS NULL AND cDescription <> 'New' ORDER BY iStatus_ID
</CFQUERY>

<!--- Query for Actions Information --->
<CFQUERY NAME='qActions' DATASOURCE='#DSN#'>
	SELECT cDescription, iActionType_ID FROM ActionType WHERE dtRowDeleted IS NULL ORDER BY iActionType_ID
</CFQUERY>

<CFINCLUDE TEMPLATE='../TIPS4/Shared/Queries/Residency.cfm'>
<CFINCLUDE TEMPLATE='../TIPS4/Shared/Queries/SolomonKeyList.cfm'>
<CFINCLUDE TEMPLATE='../TIPS4/Shared/Queries/TenantInformation.cfm'>
<CFINCLUDE TEMPLATE='../TIPS4/Shared/Queries/StateCodes.cfm'>

<BODY>
<FORM ACTION='EventSave.cfm' METHOD='POST'>
<INPUT TYPE='hidden' NAME='iResident_ID' VALUE='#qResident.iResident_ID#'>

<TABLE ID='eventtable' VALIGN='MIDDLE' STYLE='text-align:center;border:none;'>
<TR><TH CLASS="topleftcap"></TH><TH COLSPAN=100 CLASS="toprightcap"></TH></TR>
<TR>
	<TH COLSPAN=2 STYLE="text-align:left;"><DD>New Event for #qResident.FullName#</DD></TH>
	<TH COLSPAN=2><INPUT TYPE=button NAME=Save VALUE=Save onClick='return validatesubmit();'>&nbsp;<INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' STYLE='color:red;' onClick='eventclose();'></TH>
</TR>
<TR><TD COLSPAN=100%>
	<SPAN ID='requiredinformation' STYLE="display:'none';">
		<TABLE>
			<TR>
				<TD>FirstName</TD><TD><INPUT TYPE='text' NAME='cFirstName' SIZE=25 MaxLength=25 VALUE='#TRIM(qResident.cFirstName)#' onFocus="javascript: cfirstname='#TRIM(qResident.cFirstName)#'" onChange="detectchanges(cfirstname,this);"></TD>
				<TD>LastName</TD><TD><INPUT TYPE='text' NAME='cLastName' SIZE=25 MaxLength=25 VALUE='#TRIM(qResident.cLastName)#' onFocus="javascript: clastname='#TRIM(qResident.clastname)#'" onChange="detectchanges(clastname,this);"></TD>
			</TR>
			<TR><TD>AddressLine1</TD><TD><INPUT TYPE='text' NAME='cAddressLine1' SIZE=25 MaxLength=50 VALUE='#TRIM(qResident.cAddressLine1)#'></TD><TD>City</TD><TD><INPUT TYPE='text' NAME='cCity' VALUE='#TRIM(qResident.cCity)#'></TD></TR>
			<TR>
				<TD>State</TD>
				<TD>
				<SELECT NAME="cStateCode" onBlur="required();" onKeyDown="backhandler();">
				<OPTION VALUE=""> Select State </OPTION>
				<CFLOOP Query="StateCodes"><CFIF qResident.cStateCode EQ StateCodes.cStateCode><CFSET Sel='selected'><CFELSE><CFSET Sel=''></CFIF><OPTION VALUE="#cStateCode#" #sel#> #cStateCode# - #cStateName# </OPTION></CFLOOP>
				</SELECT>
				</TD>
				<TD>Zip</TD><TD><INPUT TYPE='text' NAME='cZipCode' VALUE='#TRIM(qResident.cZipCode)#'></TD>
			</TR>
			<TR>
				<TD COLSPAN=2 STYLE='width:50%;'>If this person will share a billing statement with another resident please select that person from the following list:</TD>
				<TD COLSPAN=2>
					<LI>
						<!--- ==============================================================================
						Query the solomonkey list and filter the moved out tenants
						=============================================================================== --->
						<CFQUERY NAME="qActiveTenants" DATASOURCE="SolomonKeyList" DBTYPE="QUERY">
							SELECT	cSolomonKey, cFirstName, cLastName, iTenantStateCode_ID	FROM SolomonKeyList WHERE iTenantStateCode_ID < 3
						</CFQUERY>
						<SELECT NAME="cSolomonKey" onBlur="required();" onKeyDown="backhandler();">
							<OPTION VALUE=""> Create individual account </OPTION>
							<CFLOOP QUERY="qActiveTenants">
								<OPTION VALUE="#qActiveTenants.cSolomonKey#"> Link to #qActiveTenants.cLastName#, #qActiveTenants.cFirstName# (#qActiveTenants.cSolomonKey#)</OPTION>
							</CFLOOP>
						</SELECT>
					</LI>
				</TD>
			</TR>
			<TR><TD COLSPAN=2>Will you be collecting an application fee before they officially move in?</TD><TD COLSPAN=2><LI><INPUT NAME='bApplicationFee' TYPE='checkbox' VALUE=1> (if yes check this box)</LI></TD></TR>
			<TR><TD COLSPAN=2>What is the payment type for this resident?</TD>
			<TD COLSPAN=2>
			<LI>
				<SELECT NAME="iResidencyType_ID" onKeyDown="backhandler();">
				<CFLOOP QUERY="Residency"><OPTION VALUE = "#Residency.iResidencyType_ID#">#Residency.cDescription#</OPTION></CFLOOP>
				</SELECT>
			</LI>
			</TD>
			</TR>
			<TR><TD COLSPAN=2>Does this resident help satisfy a bond requirement?</TD><TD COLSPAN=2><LI><INPUT TYPE='checkbox' NAME="Bond" VALUE=""> (if yes check this box)</LI></TD></TR>
		</TABLE>
	</SPAN>
	</TD>
</TR>
<TR><TD>Short Description</TD><TD>Detailed Explanation</TD><TD COLSPAN=2>Status</TD></TR>
<TR>
	<TD><INPUT TYPE='text' NAME='cShortDescription' VALUE='' onFocus='inUse(1);' onBlur='inUse(0);'></TD>
	<TD><TEXTAREA NAME='cLongDescription' COLS="40" ROWS="" onFocus='inUse(1);' onBlur='inUse(0);'></TEXTAREA></TD>
	<TD COLSPAN=2>
		<SELECT NAME='iStatus_ID' onChange='committed(this)' onFocus='inUse(1);' onBlur='inUse(0);'>
		<CFLOOP QUERY='qStatus'><OPTION VALUE='#qStatus.iStatus_ID#'>#qStatus.cDescription#</OPTION></CFLOOP>
		</SELECT>
	</TD>
</TR>
<TR><TD COLSPAN=100% STYLE='text-align:center;'>
	<TABLE STYLE='width:95%;'>
		<TR><TH COLSPAN=100% STYLE="text-align:left;"><DD>Actions Performed:</DD></TH></TR>
		<CFLOOP QUERY='qActions'>
		<TR>
			<TD NOWRAP STYLE='text-align:right;'>#qActions.cDescription#<INPUT TYPE=checkbox NAME='checkbox__#qActions.iActionType_ID#' VALUE='1' onClick='detailcheckboxcheck(this);'></TD>
			<TD NOWRAP STYLE='text-align:right;'>#qActions.cDescription# - Comments <TextArea NAME='detailcomments__#qActions.iActionType_ID#' ROWS=1 COLS=40 onBlur='detailcheckboxcheck(this);'></TextArea></TD>
		</TR>
		</CFLOOP>
	</TABLE>
</TD></TR>
<TR><TD COLSPAN=100% STYLE='text-align:left;'>Comments for this activity <TEXTAREA NAME='cComments' COLS="70" ROWS="" onFocus='inUse(1);' onBlur='inUse(0);'></TEXTAREA></TD></TD></TR>
<TR><TD COLSPAN=100>&nbsp;</TD></TR>
<TR><TH COLSPAN=100 STYLE="text-align:left;"><DD>Next Action</DD></TH></TR>
<TR>
	<TD NOWRAP STYLE="background:whitesmoke;">
		Next Action 
		<SELECT NAME='iNextActionType_id'>
			<CFLOOP QUERY="qActions">
				<OPTION VALUE="#qActions.iActionType_ID#">#qActions.cDescription#</OPTION>
			</CFLOOP>
		</SELECT>
		</TD>
	<TD NOWRAP STYLE="background:whitesmoke;" COLSPAN=100>Due Date <INPUT TYPE='text' name='duedate' size=9 value='#dateformat(now(),"mm/dd/yyyy")#'></TD>
</TR>
<TR><TD COLSPAN=100% STYLE='text-align:left;background:whitesmoke;'>Comments for next Action: <TEXTAREA NAME='cNextComments' COLS="70" ROWS="" onFocus='inUse(1);' onBlur='inUse(0);'></TEXTAREA></TD></TD></TR>

<TR><TD COLSPAN=100% STYLE='text-align:center;'><INPUT TYPE=button NAME=Save VALUE=Save onClick='return validatesubmit();'>&nbsp;<INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' STYLE='color:red;' onClick='eventclose();'></TD></TR>
<TR><TD CLASS="bottomleftcap"></TD><TD CLASS="bottomrightcap" COLSPAN=100></TD></TR>
</TABLE>
</FORM>
</BODY>
<SCRIPT> 
	function resizewindow(){ self.resizeTo(document.all['eventtable'].clientWidth + 40,document.all['eventtable'].clientHeight + 100); } 
	resizewindow();
	//set default values
	n = new Array(); v = new Array();
	for (i=0;i<=document.forms[0].elements.length-1;i++){ n[i] = document.forms[0].elements[i].name; v[i] = document.forms[0].elements[i].value;} 
	function detectchanges(){
		changesmade=0;
		for (t=0;t<=document.forms[0].elements.length-1;t++){ if (n[t] == document.forms[0].elements[t].name && v[t] !== document.forms[0].elements[t].value) { changesmade = changesmade + 1; } }
		setTimeout("detectchanges()",100);
	}	detectchanges();
</SCRIPT>		
</CFOUTPUT>