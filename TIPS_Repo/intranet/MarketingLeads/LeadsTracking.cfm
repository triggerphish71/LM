
<!--- ==============================================================================
Set styleshee
=============================================================================== --->
<LINK REL="StyleSheet" type="text/css" HREF="http://cf01/intranet/tips4/shared/style3.css">
+
<!--- ==============================================================================
Include Javascript file
=============================================================================== --->
<CFINCLUDE TEMPLATE="../TIPS4/Shared/JavaScript/ResrictInput.cfm">

<!--- ==============================================================================
Include StateCode file
=============================================================================== --->
<CFINCLUDE TEMPLATE="../TIPS4/Shared/Queries/StateCodes.cfm">

<!--- ==============================================================================
Include Relation file
=============================================================================== --->
<CFINCLUDE TEMPLATE="../TIPS4/Shared/Queries/Relation.cfm">

<CFINCLUDE TEMPLATE="LeadsPickLists.cfm">

<CFOUTPUT>

<TABLE>
<TR><TH COLSPAN=100% STYLE="#center# #bold# font-size: 20;">Resident Lead Tracking</TH></TR>
<TR>
	<TD>Inquiry Date</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>Form Completed by:</TD>
	<TD STYLE="#center#">#SESSION.FullName#</TD>
</TR>
<TR>
	<TD>Inquiry Method</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#InquiryMethod#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
	<TD>Lead Source</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#LeadSource#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
</TR>
<TR>
	<TD COLPAN=100%>Explanation:</TD>
</TR>
<TR><TH COLSPAN=100% STYLE="text-align:left;">Resident Profile</TH></TR>
<TR>
	<TD>Sex</TD>
	<TD><SELECT NAME="gender"><CFSET Count=1><CFLOOP INDEX=I LIST='#sex#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
	<TD>Marital Status</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#MaritalStatus#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
</TR>
<TR>
	<TD>Care Needs</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#CareNeeds#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
	<TD>Assisstance Required</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#AssisstanceRequired#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
</TR>
<TR>
	<TD>Decision Time</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#DecisionTime#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
	<TD>Apt Preference</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#AptPreference#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
</TR>
<TR>
	<TD>Current Living Situation</TD>
	<TD><SELECT><CFSET Count=1><CFLOOP INDEX=I LIST='#CurrentLivingSituation#'><OPTION VALUE="#Count#">#I#</OPTION><CFSET COUNT=COUNT+1></CFLOOP></SELECT></TD>
	<TD></TD>
	<TD></TD>
</TR>
<TR><TH COLSPAN=100% STYLE="text-align:left;">Primary Contact</TH></TR>
<TR>
	<TD>Name</TD>
	<TD><SELECT NAME="Contacts"><CFLOOP INDEX=N FROM=1 TO=5 STEP=1><OPTION VALUE='#N#'>#N#</OPTION></CFLOOP><OPTION VALUE=''>New Contact</OPTION></SELECT></TD>
	<TD>Relation</TD>
	<TD><SELECT><CFLOOP QUERY="RelationShips"><OPTION VALUE="#RelationShips.iRelationshipType_ID#">#RelationShips.cDescription#</OPTION></CFLOOP></SELECT></TD>
</TR>
<TR>
	<TD>Address</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>Home Phone</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD>City</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>Work Phone</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD>State</TD>
	<TD><SELECT><CFLOOP QUERY="StateCodes"><OPTION VALUE="#StateCodes.cStateCode#">#StateCodes.cStateName#</OPTION></CFLOOP></SELECT></TD>
	<TD>Cell Phone</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD>Zip</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>E-mail</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR><TH COLSPAN=100% STYLE="text-align:left;">Resident Prospect</TH></TR>
<TR>
	<TD>Name</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>Relation</TD>
	<TD><SELECT><CFLOOP QUERY="RelationShips"><OPTION VALUE="#RelationShips.iRelationshipType_ID#">#RelationShips.cDescription#</OPTION></CFLOOP></SELECT></TD>
</TR>
<TR>
	<TD>Address</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>Home Phone</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD>City</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>Work Phone</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD>State</TD>
	<TD><SELECT><CFLOOP QUERY="StateCodes"><OPTION VALUE="#StateCodes.cStateCode#">#StateCodes.cStateName#</OPTION></CFLOOP></SELECT></TD>
	<TD>Cell Phone</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD>Zip</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
	<TD>E-mail</TD>
	<TD><INPUT TYPE="text" NAME="" VALUE=""></TD>
</TR>
<TR>
	<TD COLSPAN=100%> Comments <BR> <TEXTAREA NAME="Comments" ROWS=3 COLS=70></TEXTAREA></TD>
</TR>
</TABLE>
</CFOUTPUT>

<CFINCLUDE TEMPLATE="../Footer.cfm">