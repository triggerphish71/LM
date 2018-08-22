

<CFINCLUDE TEMPLATE="../../header.cfm">
<TITLE> Tips 4  - Recurring Charges </TITLE>
<H1  CLASS = "PageTitle">Tips 4 - Recurring Charges</H1>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<HR>
<BR>

<SCRIPT>
function Amount() {
	if (document.recurr.Charge.value == "none"){	document.recurr.Amt.value = '0.00'; }
 	if (document.recurr.Charge.value == "Television Cable") {document.recurr.Amt.value = '35.00'; return; }
}

function DataCheck() {
	if ((document.recurr.Charge.value == "none") && (document.recurr.Amt.value = "0.00"))
	alert('A charge must be selected if you wish to save.');
}
</SCRIPT>

<form name="recurr" action="../MainMenu.cfm" Method="Post">
<!--- ==============================================================================
Start the Display for Recurring Charge Form
=============================================================================== --->
<TABLE STYLE = "BACKGROUND: LINEN;">
	<TH COLSPAN="4">Enter New Recurring Charge</TH>
	
	<TR><TD>First Name</TD><TD STYLE="text-align: center; font-weight: bold;">First Name</TD></TR>
	<TR><TD>Last Name</TD><TD STYLE="text-align: center; font-weight: bold;;">Last Name</TD></TR>
	<TR><TD>Choose Charge:</TD>		
		<TD>	
			<SELECT NAME="Charge" onChange="Amount()">
				<OPTION	VALUE="none">None</OPTION>
				<OPTION	VALUE="Television Cable">Television Cable</OPTION>
			</SELECT>
		</TD>		
	</TR>
	
	<TR><TD>Amount:</TD><TD><INPUT TYPE="text" NAME="Amt" VALUE="0.00" READONLY="" STYLE="text-align: center;"></TD></TR>
	<!--- -----------------------------------------------------------------------------------------------
	Used non-standard (not from style sheet) table properties to create asthetic look
	------------------------------------------------------------------------------------------------ --->
		<TD bordercolor = "linen" style = "background: linen; text-align: left;">
			<INPUT TYPE="submit" NAME="Save" VALUE="Save" CLASS="SaveButton" onMouseDown="DataCheck()">&nbsp;&nbsp;
			<INPUT CLASS="DontSaveButton"	TYPE="SUBMIT" NAME="DontSave" VALUE="Don't Save">
		</TD>
	</TR>
</TABLE>
</FORM>

<!--- =============================================================================
Include Intranet Footer
============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">

