<CFSET DSN='LeadTracking'>

<CFOUTPUT>
<!--- ==============================================================================
Import style sheet
=============================================================================== --->
<LINK REL="stylesheet" TYPE="text/css" HREF="http://gum/intranet/tips4/shared/style3.css">

<!--- ==============================================================================
Retrieve all current status types
=============================================================================== --->
<CFQUERY NAME="qSituation" DATASOURCE="#DSN#">
	SELECT	*
	FROM	CurrentSituation
	WHERE	dtRowDeleted IS NULL
</CFQUERY>

<SCRIPT>
function descriptioncheck(){ if(document.forms[0].cDescription.value.length == 0){return false;}}
</SCRIPT>

<CFIF IsDefined("url.id")>
	<!--- ==============================================================================
	Retriev Chosen Status Type
	=============================================================================== --->
	<CFQUERY NAME="qChosenSituation" DATASOURCE="#DSN#">
		SELECT	* 
		FROM 	CurrentSituation
		WHERE	dtRowDeleted IS NULL
		AND 	iCurrentSituation_ID = #url.id#
	</CFQUERY>
	<FORM ACTION="EditSituation.cfm" METHOD="POST">
		<INPUT TYPE="hidden" NAME="iCurrentSituation_ID" VALUE="#qChosenSituation.iCurrentSituation_ID#">
		<TABLE STYLE="width:40%;">
			<TR><TH COLSPAN=100%>Edit Situation</TH></TR>
			<TR><TD COLSPAN=100%>Description <INPUT TYPE="text" NAME="cDescription" VALUE="#TRIM(qChosenSituation.cDescription)#" SIZE=50 MAXLENGTH=50></TD></TR>
			<TR>
				<TD><INPUT TYPE="submit" NAME="save" VALUE="Save" onClick="return descriptioncheck();"></TD>
				<TD STYLE="#right#"><INPUT TYPE="button" NAME="Cancel" VALUE="Cancel" onClick="location.href='CurrentSituation.cfm';"></TD>
			</TR>
		</TABLE>
	</FORM>	
<CFELSE>
	<SCRIPT>
		o="	<FORM ACTION='AddSituation.cfm' METHOD='POST'>";
		o+="<TABLE STYLE='width:40%;'>";
		o+="<TR><TH COLSPAN=100%>Add New Situation</TH></TR>";
		o+="<TR><TD COLSPAN=100%>Description <INPUT TYPE='text' NAME='cDescription' VALUE='' SIZE=50 MAXLENGTH=50></TD></TR>";
		o+="<TR><TD><INPUT TYPE='submit' NAME='save' VALUE='Save' onClick='return descriptioncheck();'></TD><TD STYLE='#right#'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='window.location.reload();'></TD></TR>";
		o+="</TABLE>";
		o+="</FORM>";
		function add(){ document.all['newarea'].innerHTML=o; }
	</SCRIPT>
	<DIV ID="newarea"><INPUT TYPE="button" NAME="new" VALUE="Add New Situation" onClick="add();"><BR><BR></DIV>
</CFIF>

<TABLE STYLE="width:40%;">
	<TR><TH>Situation##</TH><TH>Description</TH></TR>
	<CFLOOP QUERY="qSituation"><TR><TD><A HREF="?id=#qSituation.iCurrentSituation_ID#">#qSituation.iCurrentSituation_ID#</A></TD><TD><A HREF="?id=#qSituation.iCurrentSituation_ID#">#qSituation.cDescription#</A></TD></TR></CFLOOP>
</TABLE>

</CFOUTPUT>