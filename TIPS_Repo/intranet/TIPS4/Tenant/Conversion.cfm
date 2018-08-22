
<CFINCLUDE TEMPLATE="../../header.cfm">


<!--- =============================================================================================
Only Index.cfm can create URL.SelectedHouse_ID.  If it exists set SESSION variables.
============================================================================================== --->

<CFIF  IsDefined("URL.SelectedHouse_ID")>

    <CFINCLUDE  TEMPLATE = "../House/Inc_SQLselectOne.cfm">

    <CFSET  SESSION.qSelectedHouse  =  qHouse>

	<CFSET	SESSION.HouseName		= #qhouse.cName#>
	
	
<!--- ---------------------------------------------------------------------------------------------
We did NOT arrive via Index.cfm.  Verify SESSION variables still exist.
---------------------------------------------------------------------------------------------- --->
<CFELSEIF NOT IsDefined("SESSION.qSelectedHouse")>

    <CFSET UrlStatusMessage=URLEncodedFormat("Your Intranet session has expired. Please select a house.")>

    <CFLOCATION URL="Index.cfm?UrlStatusMessage=#UrlStatusMessage#" ADDTOKEN="NO">

</CFIF>

<!--- ---------------------------------------------------------------------------------------------
Get House iHouse_ID from HOUSE table to obtain cNumber (house number) from new system.
This will allow us to associated the last TIPS houses with the new TIPS iHouse_ID
--------------------------------------------------------------------------------------------- --->
<CFQUERY NAME = "HOUSE" DATASOURCE="#APPLICATION.datasource#">
	SELECT	d.*
	FROM 	HOUSE H		INNER JOIN	#application.censusdbserver#.Do_Not_Touch_Census.dbo.tenants d
					ON	H.cNumber = d.nhouse
	WHERE	H.ihouse_ID = 200
	AND	(d.tenant_status_id <= 2003
	OR	(d.status <> 'Inactive' OR d.status <> 'Pending AR'))
	AND	d.nUnitNumber < 997
	ORDER BY nUnitNumber
</CFQUERY>

<TABLE>
	<TR>	
		<TH>	Name	</TH>
		<TH>	TenantID</TH>
	</TR>
	<CFOUTPUT query = "house">
	<TR>
		<TD><A HREF="test.cfm?tid=#House.ctenantid#">#House.fName# #House.Lname#</A></TD>
		<TD>#House.ctenantid#</TD>
	</TR>
	</CFOUTPUT>
</TABLE>


<CFINCLUDE TEMPLATE="../../footer.cfm">
