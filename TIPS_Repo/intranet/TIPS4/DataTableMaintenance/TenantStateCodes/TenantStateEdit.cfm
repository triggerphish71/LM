

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>	
	function redirect() {
		window.location = "TenantStateCodes.cfm";
	}
</SCRIPT>


<!--- ==============================================================================
Include the intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">



<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a Status.
Thus, calling TenantStateInsert.cfm instead of RegionAction.cfm
=============================================================================== --->
<CFIF IsDefined("Url.Insert")>

	<CFSET Variables.Action = 'TenantStateInsert.cfm'>

<CFELSE>

	<CFSET Variables.Action = 'TenantStateUpdate.cfm'>

</CFIF>



<!--- ==============================================================================
Retrieve Chosen State entry for editing
=============================================================================== --->
<CFQUERY NAME = "TenantStates" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	TENANTSTATECODES
	
	<CFIF IsDefined("url.ID")>
		WHERE	iTenantStateCode_ID = #url.ID#
	<CFELSE>
		WHERE	iTenantStateCode_ID = 0
	</CFIF>

</CFQUERY>

<CFOUTPUT>	
<FORM NAME = "TenantStateEdit" ACTION = "#Variables.Action#" METHOD = "POST">

<TABLE STYLE = "width: 50%;">
	<TH COLSPAN = "4">	Edit Tenant State Codes </TH>

		<TR STYLE = "text-align: center;">
			<TD>	System ID		</TD>	
			
			<TD></TD>
			<TD></TD>
			
			<TD>	Description		</TD>
		</TR>
		
		<TR STYLE = "text-align: center;">
			<TD>	#TenantStates.iTenantStateCode_ID#		</TD>	
			
			<TD></TD>
			<TD></TD>
			
			<TD>	<INPUT TYPE = "Text" NAME = "cDescription" VALUE = "#TenantStates.cDescription#"> </TD>
		</TR>
		
		<TR>
	
			<TD bordercolor = "linen" style = "background: linen; text-align: left;">
				<INPUT CLASS = "SaveButton" 	TYPE= "SUBMIT" NAME= "Save" 	VALUE = "Save">
			</TD>
			<TD></TD>
	
			<TD></TD>
			<TD STYLE = "text-align: right;">
				<INPUT CLASS = "DontSaveButton"	TYPE= "BUTTON" NAME= "DontSave" VALUE = "Don't Save" onClick = "redirect()">
			</TD>
		</TR>
				
		<TR>		
			<TD COLSPAN = "4" style = "background: linen; font-weight: bold; color: red; bordercolor: linen;">	
				<U>NOTE:</U> You must SAVE to keep information which you have entered!		
			</TD>	
		</TR>
</TABLE>


</FORM>
</CFOUTPUT>

<!--- ==============================================================================
Include the intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">


