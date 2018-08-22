

<!--- ==============================================================================
Assign style sheet
=============================================================================== --->
<LINK REL="stylesheet" Type="text/css" HREF="http://gum/intranet/tips4/shared/style3.css">

<CFOUTPUT>
<CFSET DSN='LeadTracking'>

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
<CFSET GroupsList=ValueList(qGroups.iGroup_ID)>
<CFSET CorrespondingCategories=ValueList(qGroups.iCategory_ID)>

<!--- ==============================================================================
Retrieve all sources for this house
=============================================================================== --->
<CFQUERY NAME="qSources" DATASOURCE="#DSN#">
	SELECT	S.iSource_ID, S.iGroup_ID, S.cDescription, G.cDescription as GroupName
	FROM	Sources S
	JOIN	Groups G ON (G.iGroup_ID = S.iGroup_ID AND G.dtRowDeleted IS NULL)
	WHERE	S.dtRowDeleted IS NULL
	AND		G.iHouse_ID = 200
</CFQUERY>

<SCRIPT>
	groupids = new Array(#GroupsList#);
	corrcatids = new Array(#CorrespondingCategories#);
	
	add="<FORM ACTION='AddSource.cfm' METHOD='POST'>";
	add+="<TABLE>";
	add+="<TR><TH COLSPAN=100%>#qHouse.cName# <INPUT TYPE='hidden' NAME='iHouse_ID' VALUE='#qHouse.iHouse_ID#'></TH></TR>";
	add+="<TR><TD>Description</TD><TD>Group</TD><TD>Category</TD></TR>";
	//<TD>Delete</TD></TR>";
	add+="<TR><TD><INPUT TYPE='text' NAME='cDescription' VALUE='' SIZE=30 MAXLENGTH=50></TD>";
	add+="<TD><SELECT NAME='iGroup_ID' onChange='setcategory(this);'><CFLOOP QUERY='qGroups'><OPTION VALUE='#qGroups.iGroup_ID#'>#qGroups.cDescription# (#qGroups.CategoryName#)</OPTION></CFLOOP></SELECT></TD>";
	add+="<TD><SELECT NAME='iCategory_ID' onChange='setgroup(this);'<CFLOOP QUERY='qCategories'><OPTION VALUE='#qCategories.iCategory_ID#'>#qCategories.cDescription#</OPTION></CFLOOP></SELECT></TD>";
	//add+="<TD STYLE='#center#'><INPUT CLASS='BlendedButton' TYPE='button' NAME='Delete' VALUE='Delete'></TD></TR>";
	add+="<TR><TD COLSPAN=2><INPUT TYPE='button' NAME='Save' VALUE='Save' onClick='save();'></TD>";
	add+="<TD COLSPAN=2 STYLE='#right#'><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick='window.location.reload();'></TD></TR>";
	add+="</TABLE>";
	add+="</FORM>";
	
	function setcategory(obj){ for (i=0;i<=groupids.length-1;i++){ if (obj.value == groupids[i]){ tmp=(corrcatids[i]); for (c=0;(c<=document.forms[0].iCategory_ID.options.length-1);c++){	if (tmp == document.forms[0].iCategory_ID.options(c).value){ document.forms[0].iCategory_ID.options(c).selected = true;}} }}}
	function setgroup(obj){ for (i=0;i<=corrcatids.length-1;i++){if (obj.value == corrcatids[i]){ tmp=(groupids[i]);	for (c=0;(c<=document.forms[0].iGroup_ID.options.length-1);c++){ if (tmp == document.forms[0].iGroup_ID.options(c).value){ document.forms[0].iGroup_ID.options(c).selected = true; }} }}}
	function showadd(){ document.all['addoredit'].innerHTML=add;}
	function save(){ document.forms[0].action='AddSource.cfm'; document.forms[0].submit(); }
</SCRIPT>
	
	
<DIV ID="addoredit"><INPUT TYPE="button" NAME="showlayer" VALUE="Add New Source" onClick="showadd();"><BR><BR></DIV>


<TABLE>
	<TR><TH>Description</TH><TH>Group</TH></TR>
	<CFLOOP QUERY="qSources"><TR><TD>#qSources.cDescription#</TD><TD>#qSources.GroupName#</TD></TR></CFLOOP>
</TABLE>
</CFOUTPUT>