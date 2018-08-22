<CFSET DSN='LeadTracking'>

<CFOUTPUT>
<!--- ==============================================================================
Import style sheet
=============================================================================== --->
<LINK REL="stylesheet" TYPE="text/css" HREF="http://gum/intranet/tips4/shared/style3.css">

<!--- ==============================================================================
Retrieve all current status types
=============================================================================== --->
<CFQUERY NAME="qMaritalStatus" DATASOURCE="#DSN#">
	SELECT	*
	FROM	MaritalStatus
	WHERE	dtRowDeleted IS NULL
</CFQUERY>

<SCRIPT>
function descriptioncheck(){ if(document.forms[0].cDescription.value.length == 0){return false;}}
</SCRIPT>

<CFIF IsDefined("url.id")>
	<!--- ==============================================================================
	Retriev Chosen Status Type
	=============================================================================== --->
	<CFQUERY NAME="qChosenMaritalStatus" DATASOURCE="#DSN#">
		SELECT	* 
		FROM 	MaritalStatus
		WHERE	dtRowDeleted IS NULL
		AND 	iMaritalStatus_ID = #url.id#
	</CFQUERY>
	<FORM ACTION="EditMaritalStatus.cfm" METHOD="POST">
		<INPUT TYPE="hidden" NAME="iMaritalStatus_ID" VALUE="#qChosenMaritalStatus.iMaritalStatus_ID#">
		<TABLE STYLE="width:40%;">
			<TR><TH COLSPAN=100%>Edit MaritalStatus</TH></TR>
			<TR><TD COLSPAN=100%>Description <INPUT TYPE="text" NAME="cDescription" VALUE="#TRIM(qChosenMaritalStatus.cDescription)#" SIZE=50 MAXLENGTH=50></TD></TR>
			<TR>
				<TD><INPUT TYPE="submit" NAME="save" VALUE="Save" onClick="return descriptioncheck();"></TD>
				<TD STYLE="#right#"><INPUT TYPE="button" NAME="Cancel" VALUE="Cancel" onClick="location.href='MaritalStatus.cfm';"></TD>
			</TR>
		</TABLE>
	</FORM>	
<CFELSE>
	<SCRIPT>
		o="	<FORM ACTION='AddMaritalStatus.cfm' METHOD='POST'>";
		o+="<TABLE STYLE='width:40%;'>";
		o+="<TR><TH COLSPAN=100%>Add New MaritalStatus</TH></TR>";
		o+="<TR><TD COLSPAN=100%>Description <INPUT TYPE='text' NAME='cDescription' VALUE='' SIZE=50 MAXLENGTH=50></TD></TR>";
		o+="<TR><TD><INPUT TYPE='submit' NAME='save' VALUE='Save' onClick='return descriptioncheck();'></TD><TD STYLE='#right#'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='window.location.reload();'></TD></TR>";
		o+="</TABLE>";
		o+="</FORM>";
		function add(){ document.all['newarea'].innerHTML=o; }
	</SCRIPT>
	<DIV ID="newarea"><INPUT TYPE="button" NAME="new" VALUE="Add New Marital Status" onClick="add();"><BR><BR></DIV>
</CFIF>

<TABLE STYLE="width:40%;">
	<TR><TH>Marital Status##</TH><TH>Description</TH></TR>
	<CFLOOP QUERY="qMaritalStatus"><TR><TD><A HREF="?id=#qMaritalStatus.iMaritalStatus_ID#">#qMaritalStatus.iMaritalStatus_ID#</A></TD><TD><A HREF="?id=#qMaritalStatus.iMaritalStatus_ID#">#qMaritalStatus.cDescription#</A></TD></TR></CFLOOP>
</TABLE>

</CFOUTPUT>