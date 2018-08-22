<!--- *********************************************************************************************
Name:       Region.cfm
Type:       Template
Purpose:   	Maintenance of the Region Table.

Called by: 	None

Calls: 		None

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
Paul Buendia            04/11/2001      Original Authorship
********************************************************************************************** --->


<!--- ==============================================================================
RETRIEVE ALL REGIONS FOR SELECTION
=============================================================================== --->
<CFQUERY NAME = "RegionList" 	DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	Region
	WHERE	dtRowDeleted IS NULL
	ORDER BY cNumber
</CFQUERY>

<!--- ==============================================================================
INCLUDE INTRANET HEADER
=============================================================================== --->
<CFINCLUDE TEMPLATE = "../../../header.cfm">

<CFOUTPUT>
<BR><BR>
<!--- ==============================================================================
Display and Set the Title and Header for the page
=============================================================================== --->
<TITLE> TIPS 4 - Region Administration</TITLE>
<B STYLE="font-size: 20;">TIPS 4 - Region Administration</B>
<HR><BR>

<CFIF session.userid IS 3025 OR Session.UserID IS 36>
	<BR><A HREF = "RegionEdit.cfm?Insert=1" CLASS = "Summary">Create New Region</A>
	<BR><BR>
</CFIF>

<!--- ==============================================================================
DISPLAY THE REGIONS FOR SELECTION
=============================================================================== --->
<TABLE>
<TR><TH>Number</TH><TH>Name</TH><TH>Location</TH><TH>Delete</TH></TR>
<CFLOOP QUERY = "RegionList">
	<!--- ==============================================================================
	Retrieve the associated OPS Areas For this Region
	=============================================================================== --->
	<CFQUERY NAME="qOpsAreas" DATASOURCE="#APPLICATION.datasource#">
		SELECT 	*	
		FROM	OPSArea		
		WHERE	dtRowDeleted IS NULL
		AND 	iRegion_ID = #Regionlist.iRegion_ID#
	</CFQUERY>
	<CFSET NAME = #Regionlist.iRegion_ID# & 'List'>
	<CFSET Name = ValueList(qOpsAreas.cName, ",")>
	<TR>
		<TD STYLE="text-align: center;">#Regionlist.cNumber#</TD>
		<TD><A HREF="RegionEdit.cfm?nbr=#RegionList.iRegion_ID#" STYLE="font-weight: bold; font-size: 16;">#RegionList.cNAME#</A><BR></TD>
		<TD>#RegionList.cCity#, #Regionlist.cStateCode#</TD>
		<TD STYLE = "text-align: center;">
		<CFIF qOpsAreas.RecordCount GT 0>
			<INPUT CLASS="BlendedTextBoxR" STYLE="border-bottom: 1px solid navy;" TYPE="text" NAME="#RegionList.iRegion_ID#" SIZE="25" VALUE="#qOpsAreas.RecordCount# Operations Areas are in use." onMouseOver="show#RegionList.iRegion_ID#(this);" onMouseOut="clean#RegionList.iRegion_ID#();">
		<CFELSE>			
			<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteRegion.cfm?typeID=#RegionList.iRegion_ID#'">
		</CFIF>
		
		<CFIF SESSION.USERID EQ 3025>
			<DIV ID="#Regionlist.iRegion_ID#show"></DIV>
			<SCRIPT>
				o#Regionlist.iRegion_ID#="<TABLE CELLSPACING=0 CELLPADDING=0 STYLE='width: 1%;'><CFLOOP INDEX=I LIST='#Name#' DELIMITERS=','><TR><TD NOWRAP>#I#</TD></TR></CFLOOP></TABLE>";
				function show#Regionlist.iRegion_ID#(obj){
					if (obj.name == #RegionList.iRegion_ID#){
						document.all['#RegionList.iRegion_ID#show'].style.display = 'block';
						document.all['#RegionList.iRegion_ID#show'].innerHTML = o#RegionList.iRegion_ID#;
					}
				}
				function clean#RegionList.iRegion_ID#(){
					document.all['#RegionList.iRegion_ID#show'].style.display = 'none';
				}
			</SCRIPT>		
		</CFIF>
		</TD>
		
	</TR>
</CFLOOP>
</TABLE>

<BR><BR>
<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>

</CFOUTPUT>

<!--- *********************************************************************************************
INCLUDE THE INTRANET FOOTER
********************************************************************************************** --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">