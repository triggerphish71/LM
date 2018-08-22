

<!--- ==============================================================================
Retrieve all non-deleted ops areas
=============================================================================== --->
<CFQUERY NAME = "OPSAreas" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	OpsArea.iOpsArea_ID, 
			OpsArea.iRegion_ID, 
			OpsArea.iDirectorUser_ID, 
			OpsArea.cName, 
			OpsArea.cNumber, 
			OpsArea.cPhoneNumber1, 
			OpsArea.iPhoneType1_ID, 
			OpsArea.cPhoneNumber2, 
			OpsArea.iPhoneType2_ID, 
			OpsArea.cPhoneNumber3, 
			OpsArea.iPhoneType3_ID, 
			OpsArea.cAddressLine1, 
			OpsArea.cAddressLine2, 
			OpsArea.cCity, 
			OpsArea.cStateCode, 
			OpsArea.cZipCode, 
			OpsArea.cComments, 
			OpsArea.iRowStartUser_ID, 
			OpsArea.dtRowStart, 
			OpsArea.iRowEndUser_ID, 
			OpsArea.dtRowEnd, 
			OpsArea.iRowDeletedUser_ID, 
			OpsArea.dtRowDeleted,
			Region.cName as Division,
			Region.cNumber as DivisionNumber
			
	FROM 	OPSArea
	JOIN	Region ON (Region.iRegion_ID = OpsArea.iRegion_ID AND Region.dtRowDeleted IS NULL)
	WHERE	OpsArea.dtRowDeleted IS NULL
	ORDER BY	Region.cName, OpsArea.cNumber
</CFQUERY>

<!--- ==============================================================================
Include intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<H1	CLASS="PAGETITLE">Operations Area Administration</H1>
<HR><A HREF = "OpsAreasEdit.cfm?Insert=1" CLASS = "Summary">Create New Operations Area</A>
<BR>

<TABLE>
	
<TR><TH>Division</TH><TH>Number</TH><TH>Name</TH><TH>Delete</TH></TR>

<CFOUTPUT QUERY="OPSAreas">
	<!--- ==============================================================================
	Check to see if there are any  houses in this opsarea
	=============================================================================== --->
	<CFQUERY NAME="qHouseCheck" DATASOURCE="#APPLICATION.datasource#">
		SELECT	* FROM House WHERE	dtRowDeleted IS NULL  AND iOPSArea_ID = #OPSAreas.iOpsArea_ID# ORDER BY cName
	</CFQUERY>
	<CFSET NAME = OPSAreas.iOPSArea_ID & 'List'>
	<CFSET Name = ValueList(qHouseCheck.cName, ",")>
	<TR>
		<TD>#OPSAreas.Division#</TD>
		<TD>#OPSAreas.DivisionNumber##OPSAreas.cNumber#	</TD>
		<TD><A HREF="OPSAreasEdit.cfm?ID=#OPSAreas.iOpsArea_ID#">#OPSAreas.cName#</A></TD>
		<TD STYLE="text-align: right;">
			<CFIF qHouseCheck.RecordCount GT 0>
				<INPUT CLASS="BlendedTextBoxR" STYLE="border-bottom: 1px solid navy;" TYPE="text" NAME="#OPSAreas.iOPSArea_ID#" VALUE="#qHouseCheck.RecordCount# houses in this area." onMouseOver="show#OPSAreas.iOPSArea_ID#(this);" onMouseOut="clean#OPSAreas.iOPSArea_ID#();">
			<CFELSE>
				<INPUT CLASS="BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteOPSArea.cfm?typeID=#OPSAreas.iOpsArea_ID#'">
			</CFIF>
			<DIV ID="#OPSAreas.iOPSArea_ID#show"></DIV>
			<SCRIPT>
				o#OPSAreas.iOPSArea_ID#="<TABLE CELLSPACING=0 CELLPADDING=0 STYLE='width: 1%;'><CFLOOP INDEX=I LIST='#Name#' DELIMITERS=','><TR><TD NOWRAP>#I#</TD></TR></CFLOOP></TABLE>";
				function show#OPSAreas.iOPSArea_ID#(obj){
					if (obj.name == #OPSAreas.iOPSArea_ID#){
						document.all['#OPSAreas.iOPSArea_ID#show'].style.display = 'block';
						document.all['#OPSAreas.iOPSArea_ID#show'].innerHTML = o#OPSAreas.iOPSArea_ID#;
					}
				}
				function clean#OPSAreas.iOPSArea_ID#(){ document.all['#OPSAreas.iOPSArea_ID#show'].style.display = 'none'; }
			</SCRIPT>
		</TD>
	</TR>
</CFOUTPUT>
	
</TABLE>
<BR><BR>
<CFOUTPUT>
	<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>
</CFOUTPUT>

<!--- ==============================================================================
Include intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">
