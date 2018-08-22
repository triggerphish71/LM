
<!--- ==============================================================================
Include the intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">


<!--- ==============================================================================
Retrieve all current valid states of tenants
=============================================================================== --->
<CFQUERY NAME = "TenantStates" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	TENANTSTATECODES
	WHERE	dtRowDeleted is NULL
</CFQUERY>

<A HREF = "TenantStateEdit.cfm?Insert=1" CLASS = "Summary"> Create New Tenant Status </A>
<BR>
<BR>

<TABLE STYLE = "width: 50%;">
	<TH COLSPAN = "3">	Tenant State Codes </TH>
	
	<CFOUTPUT QUERY = "TenantStates">
		<TR>	
			<TD WIDTH = "25%" Style = "text-align: center;">	#TenantStates.iTenantStateCode_ID#	</TD>
			<TD>	
				<A HREF = "TenantStateEdit.cfm?ID=#TenantStates.iTenantStateCode_ID#">	#TenantStates.cDescription# </A>	
			</TD>	
			
			<TD>
				<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteTenantStateCode.cfm?typeID=#TenantStates.iTenantStateCode_ID#'">
			</TD>
		</TR>
	</CFOUTPUT>
	
</TABLE>


<BR>
<BR>
<CFOUTPUT>
	<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>
</CFOUTPUT>

<!--- ==============================================================================
Include the intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">


