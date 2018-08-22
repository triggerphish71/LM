


<!--- *********************************************************************************************
JAVASCRIPT CODE FOR EXCEPTIONS HANDLING (ERROR CHECKING)
********************************************************************************************** --->
<SCRIPT>
	function redirect(){ window.location = "OPSAreas.cfm"; }	
</SCRIPT>

<!--- =============================================================================================
Include Javascript code for only allowing:
Numbers	:	USE onKeyUp = "this.value=Numbers(this.value)"
Letters:	USE onKeyUp = "this.value=Letters(this.value)"
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../Shared/JavaScript/ResrictInput.cfm">


<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a region.
Thus, calling RegionInsert.cfm instead of RegionAction.cfm
=============================================================================== --->
<CFIF IsDefined("Url.Insert")>
	<CFSET Variables.Action = 'OPSAreasInsert.cfm'>
<CFELSE>
	<CFSET Variables.Action = 'OPSAreasUpdate.cfm'>
</CFIF>

<CFIF SESSION.UserID IS 3025> <CFOUTPUT>#Variables.Action#</CFOUTPUT> </CFIF>

<!--- ==============================================================================
Retrieve all non-deleted ops areas
=============================================================================== --->
<CFQUERY NAME = "OPSAreaEdit" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	
			iOpsArea_ID, 
			iRegion_ID, 
			iDirectorUser_ID, 
			cName, 
			cNumber, 
			cPhoneNumber1, 
			iPhoneType1_ID, 
			cPhoneNumber2, 
			iPhoneType2_ID, 
			cPhoneNumber3, 
			iPhoneType3_ID, 
			cAddressLine1, 
			cAddressLine2, 
			cCity, 
			cStateCode, 
			cZipCode, 
			cComments, 
			iRowStartUser_ID, 
			dtRowStart, 
			iRowEndUser_ID, 
			dtRowEnd, 
			iRowDeletedUser_ID, 
			dtRowDeleted 
			
	FROM 	OPSArea
	WHERE	dtRowDeleted IS NULL
	<CFIF IsDefined("url.ID")> AND iOpsArea_ID = #URL.ID# <CFELSE> AND iOPSArea_ID = 0 </CFIF>
	ORDER BY	cNumber
</CFQUERY>


<!--- ==============================================================================
Retreive full name of manager
=============================================================================== --->
<CFQUERY NAME="DirectorName" DATASOURCE="DMS">
	SELECT	u.employeeid, e.employee_ndx, e.fname, e.lname
	FROM	USERS	u
	INNER JOIN ALCWEB.dbo.Employees E	ON	u.employeeid = e.employee_ndx
	<CFIF IsDefined("Url.ID") and OPSAreaEdit.iDirectorUser_ID is not ''>
		WHERE	u.employeeid = #OPSAreaEdit.iDirectorUser_ID#
	<CFELSE>
		WHERE	u.employeeid = 0
	</CFIF>
	ORDER BY	e. LName
</CFQUERY>



<!--- ==============================================================================
Retreive cName of current Region
=============================================================================== --->
<CFQUERY NAME = "CurrentRegion" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	REGION
	WHERE	dtRowDeleted IS NULL
	<CFIF IsDefined("url.ID")> AND iRegion_ID=#OPSAreaEdit.iRegion_ID# <CFELSE> AND iRegion_ID = 0 </CFIF>
</CFQUERY>


<!--- ==============================================================================
Include shared queries for application
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../Shared/Queries/PhoneType.cfm">
<CFINCLUDE TEMPLATE="../../Shared/Queries/StateCodes.cfm">
<CFINCLUDE TEMPLATE="../../Shared/Queries/UserList.cfm">
<CFINCLUDE TEMPLATE="../../Shared/Queries/Regions.cfm">

<!--- ==============================================================================
Include intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<CFOUTPUT>

<FORM ACTION = "#Variables.Action#" METHOD = "POST">
<TABLE>
	<TH COLSPAN="4"> OPS Areas Edit	</TH>
	<TR>	
		<TD> OPS Area Name </TD>
		<TD>	
			<INPUT TYPE="text" NAME="cName" VALUE="#OPSAreaEdit.cName#" SIZE="50">
			<INPUT TYPE="hidden" NAME="iOpsArea_ID" VALUE="#OPSAreaEdit.iOpsArea_ID#">
		</TD>	
		<TD></TD>
		<TD></TD>
	</TR>

	<TR>	
		<TD> OPS Region </TD>
		<TD>
			<SELECT NAME="iRegion_ID">
				<CFLOOP QUERY="Regions"> 
					<CFIF CurrentRegion.iRegion_ID EQ Regions.iRegion_ID><CFSET RegionSelected='Selected'><CFELSE><CFSET RegionSelected=''></CFIF>
					<OPTION VALUE="#Regions.iRegion_ID#" #RegionSelected#> #Regions.cName# </OPTION> 
				</CFLOOP>
			</SELECT>
		</TD>
		<TD></TD>
		<TD></TD>
	</TR>
	
	<TR>
		<TD> OPS Area Number </TD>
		<TD> <INPUT TYPE="text" Name="cNumber" VALUE="#OPSAreaEdit.cNumber#" SIZE="2" STYLE="text-align: center;"> </TD>
		<TD></TD>
		<TD></TD>
	</TR>
	
	<TR>
		<TD> Regional Director Of Operations </TD>
		<TD>
			<SELECT NAME = "iDirectorUser_ID">
				<CFLOOP QUERY="Users"> 
					<CFIF DirectorName.employeeid EQ Users.employeeid><CFSET DirectorSelected='Selected'><CFELSE><CFSET DirectorSelected=''></CFIF>
					<OPTION VALUE = "#Users.employeeid#" #DirectorSelected#> #Users.LName#, #Users.FName# </OPTION> 
				</CFLOOP>
			</SELECT>
		</TD>	
		
		<TD></TD>
		<TD></TD>
	</TR>
	
	
	<TR>
		<TD> Address Line 1 </TD>
		<TD> <INPUT TYPE="text" Name="cAddressLine1" VALUE="#OPSAreaEdit.cAddressLine1#" SIZE="30">	</TD>
		<TD></TD>
		<TD></TD>	
	</TR>
	
	<TR>
		<TD> Address Line 2 </TD>
		<TD> <INPUT TYPE="text" Name="cAddressLine2" VALUE="#OPSAreaEdit.cAddressLine2#" SIZE="30"> </TD>	
		<TD></TD>
		<TD></TD>
	</TR>
	
	<TR>	
		<TD> City </TD>
		<TD> <INPUT TYPE="text" Name="cCity" VALUE="#OPSAreaEdit.cCity#"> </TD>
		<TD></TD>
		<TD></TD>
	</TR>
	
	
	<TR>
		<TD> State </TD>
		<TD>	
			<SELECT NAME="cStateCode">
				<OPTION VALUE="#OPSAreaEdit.cStateCode#"> #OPSAreaEdit.cStateCode# </OPTION>
				<CFLOOP QUERY="StateCodes"> <OPTION VALUE = "#StateCodes.cStateCode#"> #StateCodes.cStateName# - #StateCodes.cStateCode# </OPTION></CFLOOP> 
			</SELECT>
		</TD>
		
		<TD></TD>
		<TD></TD>
	</TR>
	
	
	<TR>
		<TD> Zip Code </TD>
		<TD> <INPUT TYPE="text" Name="cZipCode" VALUE="#OPSAreaEdit.cZipCode#"> </TD>	
		<TD></TD>
		<TD></TD>
	</TR>
	
	
	<TR>
		<TD>	Phone Number 1</TD>	
		<TD>
			<CFSET areacode1 = #Left(OPSAreaEdit.cPhoneNumber1,3)#>
			<CFSET prefix1	 = #Mid(OPSAreaEdit.cPhoneNumber1,4,3)#>
			<CFSET number1	 = #Right(OPSAreaEdit.cPhoneNumber1,4)#>
			
			<INPUT TYPE = "text" NAME = "areacode1"	SIZE = "3"	VALUE = "#variables.areacode1#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
			<INPUT TYPE = "text" NAME = "prefix1"	SIZE = "3"	VALUE = "#variables.prefix1#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
			<INPUT TYPE = "text" NAME = "number1"	SIZE = "4"	VALUE = "#variables.number1#" MAXLENGTH = "4" onKeyDown = "this.value=LeadingZeroNumbers(this.value);" onBlur = "Four(this);">
			<INPUT TYPE = "Hidden" NAME = "iPhoneType1_ID" VALUE = "2">
		</TD>	
		<TD></TD>
		<TD></TD>
	</TR>

	<TR>
		<TD> Phone Number 2 </TD>	
		<TD>
			<CFSET areacode2 = #Left(OPSAreaEdit.cPhoneNumber2,3)#>
			<CFSET prefix2	 = #Mid(OPSAreaEdit.cPhoneNumber2,4,3)#>
			<CFSET number2	 = #Right(OPSAreaEdit.cPhoneNumber2,4)#>
			
			<INPUT TYPE = "text" NAME = "areacode2"	SIZE = "3"	VALUE = "#variables.areacode2#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
			<INPUT TYPE = "text" NAME = "prefix2"	SIZE = "3"	VALUE = "#variables.prefix2#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
			<INPUT TYPE = "text" NAME = "number2"	SIZE = "4"	VALUE = "#variables.number2#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);" onBlur = "Four(this);">
			<INPUT TYPE = "Hidden" NAME = "iPhoneType2_ID" VALUE = "6">	
		</TD>	
		<TD></TD>
		<TD></TD>
	</TR>
		
	<TR>
		<TD>	Phone Number 3				</TD>	
		<TD>	
			<CFSET areacode3 = #Left(OPSAreaEdit.cPhoneNumber3,3)#>
			<CFSET prefix3	 = #Mid(OPSAreaEdit.cPhoneNumber3,4,3)#>
			<CFSET number3	 = #Right(OPSAreaEdit.cPhoneNumber3,4)#>
			
			<INPUT TYPE = "text" NAME = "areacode3"	SIZE = "3"	VALUE = "#variables.areacode3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
			<INPUT TYPE = "text" NAME = "prefix3"	SIZE = "3"	VALUE = "#variables.prefix3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
			<INPUT TYPE = "text" NAME = "number3"	SIZE = "4"	VALUE = "#variables.number3#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);" onBlur = "Four(this);">		
		
			<INPUT TYPE = "Hidden" NAME = "iPhoneType3_ID" VALUE = "5">			
		</TD>		
		<TD></TD>
		<TD></TD>
	</TR>
		
	<TR>	
		<TD> Comments </TD>
		<TD COLSPAN="4"><TEXTAREA COLS="50" ROWS="3" NAME="cComments">#TRIM(OPSAreaEdit.cComments)#</TEXTAREA></TD>	
	</TR>
	
	<TR>
		<TD style="text-align: left;"> <INPUT CLASS="SaveButton"	TYPE="SUBMIT" NAME="Save" VALUE="Save"> </TD>
		<TD></TD>
		<TD></TD>
		<TD STYLE="text-align: right;">
			<INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE = "Don't Save" onClick = "redirect()">
		</TD>
	</TR>
			
	<TR>		
		<TD COLSPAN = "4" style = "font-weight: bold; color: red;">	
			<U>NOTE:</U> You must SAVE to keep information which you have entered!		
		</TD>	
	</TR>

</TABLE>

</FORM>
</CFOUTPUT>

<!--- ==============================================================================
Include intranet header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">
