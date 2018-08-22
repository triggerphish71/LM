<CFSET DSN='LeadTracking'>

<!--- ==============================================================================
Assign style sheet
=============================================================================== --->
<LINK REL="stylesheet" Type="text/css" HREF="http://gum/intranet/tips4/shared/style3.css">

<CFOUTPUT>

<!--- ==============================================================================
Retrieve house Information
=============================================================================== --->
<CFQUERY NAME="qHouse" DATASOURCE="TIPS4">
	SELECT	cName, cNumber, iHouse_ID
	FROM	House
	WHERE	dtRowDeleted IS NULL
	AND		iHouse_ID = 200
</CFQUERY>

<!--- ==============================================================================
Retrieve all current categories
=============================================================================== --->
<CFQUERY NAME="qCategories" DATASOURCE="#DSN#">
	SELECT 	iCategory_ID, cDescription
	FROM 	Categories 
	WHERE 	dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve all group data from database
=============================================================================== --->
<CFQUERY NAME="qGroups" DATASOURCE="#DSN#">
	SELECT	G.iGroup_ID, G.iCategory_ID, G.cDescription, C.cDescription as CategoryName
	FROM	Groups G
	JOIN	Categories C ON (G.iCategory_ID = C.iCategory_ID AND C.dtRowDeleted IS NULL)
	WHERE	G.dtRowDeleted IS NULL
	AND		G.iHouse_ID = 200
	ORDER BY G.iCategory_ID
</CFQUERY>

<SCRIPT>
	function showedit(string){
		thisaction="editgroup.cfm";
		<CFLOOP QUERY="qGroups">
			<CFIF qGroups.CurrentRow EQ 1><CFSET conditional='if'><CFELSE><CFSET conditional='else if'></CFIF>
			#conditional# (string == #qGroups.iGroup_ID#) {
				var categoryid= #qGroups.iCategory_ID#;
				edit#qGroups.iGroup_ID#="<FORM ACTION='EditGroup.cfm' METHOD='POST'>";
				edit#qGroups.iGroup_ID#+="<INPUT TYPE='hidden' NAME='iGroup_ID' VALUE='#qGroups.iGroup_ID#'>";
				edit#qGroups.iGroup_ID#+="<TABLE>";
				edit#qGroups.iGroup_ID#+="<TR><TH>House Name</TH><TH>Description</TH><TH>Category</TH><TH>Delete</TH></TR>";
				edit#qGroups.iGroup_ID#+="<TR><TD>#qHouse.cName# <INPUT TYPE='hidden' NAME='iHouse_ID' VALUE='#qHouse.iHouse_ID#'></TD>";
				edit#qGroups.iGroup_ID#+="<TD><INPUT TYPE='text' NAME='cDescription' VALUE='#TRIM(qGroups.cDescription)#' SIZE=30 MAXLENGTH=50></TD>";
				edit#qGroups.iGroup_ID#+="<TD><SELECT NAME='iCategory_ID'><CFLOOP QUERY='qCategories'><OPTION VALUE='#qCategories.iCategory_ID#'>#qCategories.cDescription#</OPTION></CFLOOP></SELECT></TD>";
				edit#qGroups.iGroup_ID#+="<TD STYLE='#center#'><INPUT CLASS='BlendedButton' TYPE='button' NAME='Delete' VALUE='Delete'></TD></TR>";
				edit#qGroups.iGroup_ID#+="<TR><TD COLSPAN=2><INPUT TYPE='button' NAME='Save' VALUE='Save' onClick='save();'></TD>";
				edit#qGroups.iGroup_ID#+="<TD COLSPAN=2 STYLE='#right#'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='window.location.reload();'></TD></TR>";
				edit#qGroups.iGroup_ID#+="</TABLE>";
				edit#qGroups.iGroup_ID#+="</FORM>";
				document.all['addoredit'].innerHTML=edit#qGroups.iGroup_ID#;
				for (i=0;i<=document.forms[0].iCategory_ID.options.length-1;i++){ if(document.forms[0].iCategory_ID.options[i].value == categoryid){ document.forms[0].iCategory_ID.options[i].selected = true; } }
			}
		</CFLOOP>
		else { alert('No match found'); }
	}
	
	add="<FORM ACTION='AddGroup.cfm' METHOD='POST'>";
	add+="<TABLE>";
	add+="<TR><TH>House Name</TH><TH>Description</TH><TH>Category</TH><TH>Delete</TH></TR>";
	add+="<TR><TD>#qHouse.cName# <INPUT TYPE='hidden' NAME='iHouse_ID' VALUE='#qHouse.iHouse_ID#'></TD>";
	add+="<TD><INPUT TYPE='text' NAME='cDescription' VALUE='' SIZE=30 MAXLENGTH=50></TD>";
	add+="<TD><SELECT NAME='iCategory_ID'><CFLOOP QUERY='qCategories'><OPTION VALUE='#qCategories.iCategory_ID#'>#qCategories.cDescription#</OPTION></CFLOOP></SELECT></TD>";
	add+="<TD STYLE='#center#'><INPUT CLASS='BlendedButton' TYPE='button' NAME='Delete' VALUE='Delete'></TD></TR>";
	add+="<TR><TD COLSPAN=2><INPUT TYPE='button' NAME='Save' VALUE='Save' onClick='save();'></TD>";
	add+="<TD COLSPAN=2 STYLE='#right#'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='window.location.reload();'></TD></TR>";
	add+="</TABLE>";
	add+="</FORM>";
	
	function save(){ document.forms[0].action = thisaction; document.forms[0].submit(); }
	function overcursor(obj){ obj.style.cursor = 'hand'; }
	function showadd(){ thisaction="addgroup.cfm"; document.all['addoredit'].innerHTML= add; }
	function removegroup(string){ location.href="deletegroup.cfm?id="+string; }
</SCRIPT>

<DIV ID="addoredit"><INPUT TYPE="button" NAME="AddNew" VALUE="Add New Group" onClick="showadd();"><BR><BR></DIV>

<TABLE>
	<TR><TH COLSPAN=100%>Groups Administration</TH></TR>
	<TR><TD STYLE="#center#"><B>Category</B></TD><TD STYLE="#center#"><B>Description</B></TD><TD>Remove Group</TD></TR>
	<CFLOOP QUERY="qGroups"><TR><TD>#qGroups.CategoryName#</TD><TD><A onMouseOver="overcursor(this);" onClick="showedit(#qGroups.iGroup_ID#);"><U>#qGroups.cDescription#</U></A></TD><TD STYLE="#Center#"><INPUT Class=Blendedbutton TYPE="button" NAME="Delete" VALUE="Remove Now" onClick="removegroup(#qGroups.iGroup_ID#);"></TD></TR></CFLOOP>
</TABLE>

</CFOUTPUT>