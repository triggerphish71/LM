<CFOUTPUT>
<LINK REL="stylesheet" TYPE="text/css" HREF="http://#server_name#/intranet/tips4/shared/style3.css">
<CFQUERY NAME="qreviewtypes" datasource="TIPS4">
	select ireviewtype_id, cdescription, csortorder from reviewtype where dtrowdeleted is null
	order by (csortorder*1)
</CFQUERY>
<script type="text/javascript" src="../../../CFIDE/scripts/wddx.js"></script>
<SCRIPT>
<cfwddx action="cfml2js" input="#qreviewtypes#" topLevelVariable="qreviewtypesJS">
function edit(str) {
	for (a=0;a<=qreviewtypesJS['ireviewtype_id'].length-1;a++){
		if (str == qreviewtypesJS['ireviewtype_id'][a]) { 
			document.forms[0].cDescription.value=qreviewtypesJS['cdescription'][a];
			document.forms[0].cSortOrder.value=qreviewtypesJS['csortorder'][a];
			document.forms[0].ireviewtype_id.value=qreviewtypesJS['ireviewtype_id'][a];
		}
	}
	if (str*1 !== document.forms[0].ireviewtype_id.value*1) { document.forms[0].ireviewtype_id.value=''; }
}
</SCRIPT>
<FORM ACTION="ReviewTypeUpdate.cfm" METHOD="POST">
<INPUT TYPE="hidden" NAME="ireviewtype_id" VALUE="">
<TABLE>
	<TR><TH COLSPAN=2> ReviewType Administration </TH></TR>
	<TR>
		<TD>Description <INPUT TYPE="text" NAME="cDescription" VALUE=""></TD>
		<TD>List Order <INPUT TYPE="text" NAME="cSortOrder" size=3 VALUE=""></TD>
	</TR>
	<TR>
		<TD><INPUT TYPE="submit" NAME="Submit" VALUE="Save"></TD>
		<TD STYLE="text-align:right;"><INPUT TYPE="button" NAME="Cancel" VALUE="Cancel" onClick="javascript: self.close();"></TD>
	</TR>
	<TR>
		<TD colspan=2 STYLE="text-align:center;">
		<TABLE border=1 STYLE="width:70%;">
			<TR><TH>Description</TH><TH>List Order</TH></TR>
			<CFLOOP QUERY="qreviewtypes">
				<TR>
					<TD><A HREF="javascript:;" onclick="edit(#qreviewtypes.ireviewtype_id#);">#qreviewtypes.cDescription#</A></TD>
					<TD>#qreviewtypes.cSortOrder#</TD>
				</TR>
			</CFLOOP>
		</TABLE>
		</TD>
	</TR>
</TABLE>
</FORM>
</CFOUTPUT>