
<CFOUTPUT>

<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<CFQUERY NAME="qValidTenants" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM Tenant T
	JOIN TenantState TS ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
	AND T.dtRowDeleted IS NULL AND TS.iTenantStateCode_ID = 2 
	AND T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY T.cLastName
</CFQUERY>

<CFSCRIPT>
	if (IsDefined("form.lookupmonth")) { LookupMonth = form.lookupmonth; } 	else { LookupMonth = Month(Now()); }
	if (IsDefined("form.lookupmonth")) { LookupYear = form.lookupyear; } 	ELSE { LookupYear = Year(Now()); }
	ThisMonth =  variables.lookupyear & '-' & variables.lookupmonth & '-01';
	FirstOfThisMonth = CreateODBCDateTime(thismonth);
	EndofMonth =  variables.lookupyear & '-' & variables.lookupmonth & '-' & DaysInMonth(ThisMonth);
	EndOfThisMonth = CreateODBCDateTime(EndOfmonth);
</CFSCRIPT>

<CFQUERY NAME="qGetAdjHistory" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*, ADR.cComments as cComments, ADR.dtRowStart as dtRowStart
	FROM	AdjustmentRequest ADR
	JOIN	Tenant T ON (T.iTenant_ID = ADR.iTenant_ID AND T.dtRowDeleted IS NULL)
	WHERE	ADR.dtRowDeleted IS NULL
	AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		ADR.dtRowStart <= #EndOfThisMonth#
	AND		ADR.dtRowStart >= #FirstOfThisMonth#
	ORDER BY ADR.dtRowStart desc
</CFQUERY>

<CFQUERY NAME="Time" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = #Time.TimeStamp#>

<SCRIPT>
	TIDs = new Array(<CFLOOP QUERY="qValidTenants"><CFIF qValidTenants.CurrentRow EQ 1>#qValidTenants.iTenant_ID#<CFELSE>,#qValidTenants.iTenant_ID#</CFIF></CFLOOP>);
	SolKeys = new Array(<CFLOOP QUERY="qValidTenants"><CFIF qValidTenants.CurrentRow EQ 1>'#qValidTenants.cSolomonKey#'<CFELSE>,'#qValidTenants.cSolomonKey#'</CFIF></CFLOOP>);
	
	<CFIF SESSION.USERID EQ 3025> //alert(TIDs); //alert(SolKeys); </CFIF>
	
	function TID(obj){ 
		for (i=0;i<=(TIDs.length-1);i++){
			if (obj.value == TIDs[i]) { document.all['ID'].innerHTML="<INPUT TYPE='text' NAME='SolomonKey' READONLY SIZE=8 VALUE='" + SolKeys[i] + "' STYLE='border: noborder; background: linen;'>"; }
			if (obj.value == ""){ document.all['ID'].innerHTML=""; }
		}	
	}
	
	//functions cent and round are from developer.irt.org FAQ (no authors specified)	
	function CreditNumbers(string) {
		for (var i=0, output='', valid="1234567890.-"; i<string.length; i++)
	       if (valid.indexOf(string.charAt(i)) != -1)
	       output += string.charAt(i)
	   	return output;
	} 		
	
	function resetbutton(){ document.all['area'].innerHTML=''; document.forms[0].type.value = ''; }
	function typem(){
		
		if (document.forms[0].type.value == "" && document.forms[0].iTenant_ID.value !== ""){ 
			if (confirm('The data below will be discarded. \r Are you sure?')) { } else { return false; }
		}
		
		if (document.forms[0].type.value == 1){
		//if (document.forms[0].type.value == 1 || document.forms[0].type.value == 2 || document.forms[0].type.value == 3){
			o="<TABLE><TR><TH COLSPAN=100%>Resident Absences (meal credits)</TH></TR>";
			o+="<TR><TD STYLE='width: 25%;'>Resident Name</TD>";
			o+="<TD><SELECT NAME='iTenant_ID' STYLE='background: whitesmoke;' onChange='TID(this);'>";
			o+="<OPTION VALUE=''>Choose Resident</OPTION><CFLOOP QUERY='qValidTenants'><OPTION VALUE='#qValidTenants.iTenant_ID#'>#qValidTenants.cLastName#, #qValidTenants.cFirstName#</OPTION></CFLOOP></SELECT></TD></TR>";
			o+="<TR><TD>Resident ID</TD><TD><DIV ID='ID'></DIV></TD></TR>";
			o+="<TR><TD>What date did the resident leave the building?</TD><TD><INPUT TYPE='text' NAME='dtLeave' SIZE=10 VALUE='' onKeyUp='Dates(this);' onBlur='verifydateformat(this);'> (mm/dd/yyyy)</TD></TR>";
			o+="<TR><TD>What date did the resident return?</TD><TD><INPUT TYPE='text' NAME='dtReturn' VALUE='' SIZE=10 onKeyUp='Dates(this);' onBlur='verifydateformat(this);'> (mm/dd/yyyy)</TD></TR>";
			o+="<TR><TD>Reason for absence</TD><TD><TEXTAREA COLS=50 ROWS=2 NAME='reason'></TEXTAREA></TD></TR>";
			o+="<TR><TD>M/C copay</TD><TD><INPUT TYPE='text' NAME='mCoPay' VALUE='' SIZE=8 onKeyUp='this.value=Numbers(this.value);' onBlur='decimal(this);' STYLE='text-align: right;'></TD></TR>";
			
			//if (document.forms[0].type.value == 2){
			//	o+="<TR><TD>M/C copay</TD><TD><INPUT TYPE='text' NAME='CoPay' VALUE='' SIZE=8 onKeyUp='this.value=Numbers(this.value);' onBlur='decimal(this);' STYLE='text-align: right;'></TD></TR>";
			//}

			
			o+="<TR><TD>Comments:</TD><TD><TEXTAREA COLS=50 ROWS=2 NAME='cComments'></TEXTAREA></TD></TR></TABLE>";
			o+="<TABLE><TR><TD STYLE='text-align: center;'><INPUT TYPE='Submit' NAME='Save' VALUE='Save' onClick='return validate();'></TD>";
			o+="<TD STYLE='text-align: center;'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='resetbutton();'></TD></TR></TABLE>";			
			document.all['area'].innerHTML=o;
		}
		else if (document.forms[0].type.value == 4){
			o="<TABLE><TR><TH COLSPAN=100%>All Other Adjustments</TH></TR>";
			o+="<TR><TD>Resident Name</TD>";
			o+="<TD><SELECT NAME='iTenant_ID' onChange='TID(this);'>";
			o+="<OPTION VALUE=''>Choose Resident</OPTION><CFLOOP QUERY='qValidTenants'><OPTION VALUE='#qValidTenants.iTenant_ID#'>#qValidTenants.cLastName#, #qValidTenants.cFirstName#</OPTION></CFLOOP></SELECT></TD></TR>";
			o+="<TR><TD>Resident ID</TD><TD><DIV ID='ID'></DIV></TD></TR>";
			o+="<TR><TD>Amount of the Adjustment</TD><TD><INPUT TYPE='text' NAME='mAmount' VALUE='' SIZE=8 onKeyUp='this.value=CreditNumbers(this.value);' onBlur='decimal(this);' STYLE='text-align: right;'></TD></TR>";
			o+="<TR><TD>Effective Date (mm/dd/yyyy)</TD><TD><INPUT TYPE='text' NAME='dtEffective' VALUE='' SIZE=10 onKeyUp='Dates(this);' onBlur='verifydateformat(this);'></TD></TR>";
			o+="<TR><TD>Reason for Adjustment</TD><TD><TEXTAREA COLS=50 ROWS=2 NAME='reason'></TEXTAREA></TD></TR>";
			o+="<TR><TD>Comments</TD><TD><TEXTAREA COLS=50 ROWS=2 NAME='cComments'></TEXTAREA></TD></TR></TABLE>";
			o+="<TABLE><TR><TD STYLE='text-align: center;'><INPUT TYPE='Submit' NAME='Save' VALUE='Save' onClick='return validate();'></TD>";
			o+="<TD STYLE='text-align: center;'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='resetbutton();'></TD></TR></TABLE>";
			document.all['area'].innerHTML=o;
		}
		else { document.all['area'].innerHTML='';}
	}
	
	function datevalidate(string){
		if (string.value.length == 2){
			if (string.value > 12) { string.value = 12; }
			string.value = string.value + '/';
		}
	}

	function decimal(string){ string.value = cent(round(string.value)); return; }
	
	function validate(){ if (document.forms[0].iTenant_ID.value == ""){ alert('Please choose a tenant.'); return false;}	}
</SCRIPT>

<CFINCLUDE TEMPLATE="../../header.cfm">

<FORM ACTION="AdjRequestAction.cfm" METHOD="POST">

	<TABLE>
		<TR><TH>Adjustment Request Form</TH></TR>
		<TR>
			<TD COLSPAN=100% STYLE="background: gainsboro;">
				Choose Adjustment Request Type: 
				<SELECT NAME="type" onChange="typem();">
					<OPTION VALUE="">None</OPTION>
					<OPTION VALUE="1">Adjust for any resident absence</OPTION>
					<OPTION VALUE="4">All Other Adjustments</OPTION>
				</SELECT>
			</TD>
		</TR>
		<TR><TD><DIV ID="area"></DIV></TD></TR>
	</TABLE>
<TABLE>
	<TR>
		<TH COLSPAN=4>Changes for this House</TH>
		<TH COLSPAN=2>	
			<SELECT NAME="lookupmonth">
				<CFLOOP INDEX=I FROM=1 TO=12 STEP=1>
					<CFIF I EQ Month(Now())><CFSET X='SELECTED'><CFELSE><CFSET X=''></CFIF>
					<OPTION VALUE="#I#" #X#>#I#</OPTION>
				</CFLOOP>
			</SELECT>
			<SELECT NAME="lookupyear">
				<CFLOOP INDEX=I FROM="1980" TO="#YEAR(DateAdd('yyyy', 1, Now()))#" STEP=1>
					<CFIF I EQ Year(Now())><CFSET X='SELECTED'><CFELSE><CFSET X=''></CFIF>
					<OPTION VALUE="#I#" #X#>#I#</OPTION>
				</CFLOOP>
			</SELECT>
			<SCRIPT>
				function search(){ 
					if (document.forms[0].type.value != ""){ 
						if (confirm('The data above will be discarded. \r Are you sure?')) { 
							document.forms[0].action='AdjustmentRequest.cfm'; 
							document.forms[0].submit();
						} 
						else { return false; }
					}
					else {
						document.forms[0].action='AdjustmentRequest.cfm'; 
						document.forms[0].submit();
					}
				}
			</SCRIPT>
			<INPUT TYPE="button" NAME="lookup" VALUE="GO" onClick="search();">
		</TH>			
	</TR>
	<CFIF qGetAdjHistory.RecordCount GT 0>	
		<TR><TD NOWRAP><B>Name</B></TD><TD><B>Reason</B></TD><TD><B>Comments</B></TD><TD><B>Amount</B></TD><TD><B>CoPay</B></TD><TD NOWRAP><B>Date</B></TD></TR>
		<CFLOOP QUERY="qGetAdjHistory">
			<CFQUERY NAME="hTenant" DATASOURCE="#APPLICATION.datasource#">
				SELECT * FROM Tenant WHERE dtRowDeleted IS NULL AND iTenant_ID = #qGetAdjHistory.iTenant_ID#
			</CFQUERY>
		<TR><TD NOWRAP>#hTenant.cLastName#, #hTenant.cFirstName#</TD><TD>#qGetAdjHistory.cReason#</TD><TD>#qGetAdjHistory.cComments#</TD><TD>#LSCurrencyFormat(qGetAdjHistory.mAmount)#</TD><TD>#LSCurrencyFormat(qGetAdjHistory.mCoPay)#</TD><TD NOWRAP>#qGetAdjHistory.dtRowStart#</TD></TR>
		</CFLOOP>
	</CFIF>		
</TABLE>

</FORM>

<BR>

<CFINCLUDE TEMPLATE="../../footer.cfm">
</CFOUTPUT>