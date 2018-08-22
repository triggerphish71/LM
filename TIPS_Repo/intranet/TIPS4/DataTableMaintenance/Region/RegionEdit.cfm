<!--- *********************************************************************************************
Name:       RegionEdit.cfm
Type:       Template
Purpose:    Edit the Data in the Regions Table

Called by: 	Region.cfm

Calls: 		RegionAction.cfm

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
Paul Buendia            04/11/2001      Original Authorship
********************************************************************************************** --->



<!--- =============================================================================================
Include Javascript code for only allowing:
Numbers	:	USE onKeyUp = "this.value=Numbers(this.value)"
Letters:	USE onKeyUp = "this.value=Letters(this.value)"
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../Shared/JavaScript/ResrictInput.cfm">

<!--- *********************************************************************************************
JAVASCRIPT CODE FOR EXCEPTIONS HANDLING (ERROR CHECKING)
********************************************************************************************** --->
<SCRIPT>
	function redirect() { window.location = "region.cfm"; }
</SCRIPT>
	 
<!--- *********************************************************************************************
INCLUDE INTRANET HEADER WITH SYTLE SHEET
********************************************************************************************** --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a region.
Thus, calling RegionInsert.cfm instead of RegionAction.cfm
=============================================================================== --->
<CFIF IsDefined("Url.Insert")>
	<CFSET Variables.Action = 'RegionsInsert.cfm'>
<CFELSE>
	<CFSET Variables.Action = 'RegionsAction.cfm'>
</CFIF>

<!--- =============================================================================================
Get list of users
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../Shared/Queries/UserList.cfm"> 

<!--- ---------------------------------------------------------------------------------------------
	Check to see if a region has been selected.
	If a Region has not been selected send page back to Region select screen.
--------------------------------------------------------------------------------------------- --->
<CFIF NOT IsDefined("url.nbr")>

	<!---	<CFLOCATION URL = "region.cfm"> --->
		
	 <CFQUERY NAME="REGION"	DATASOURCE="#Application.Datasource#">
		SELECT 	*
		FROM	Region
		WHERE  	dtRowDeleted IS NULL
		AND		iRegion_ID = 0
	</CFQUERY>
				
	<CFQUERY NAME="VPName" DATASOURCE="DMS">
		SELECT 	u.UserName, e.fname, e.lname
		FROM	Users u 
		INNER 	JOIN ALCWEB.dbo.Employees e	ON	u.employeeid = e.employee_ndx
		WHERE 	employeeid = 0
	</CFQUERY>

<CFELSE>
	
		<!--- *********************************************************************************************
		RETRIEVE INFORMATION FOR CHOSEN REGION
		********************************************************************************************** --->
		<CFQUERY NAME="REGION" DATASOURCE="#Application.Datasource#">
			SELECT 	*
			FROM	Region
			WHERE  	dtRowDeleted IS NULL
			AND		iRegion_ID = #url.nbr#
		</CFQUERY>
		
		
		<CFQUERY NAME="VPName" DATASOURCE="DMS">
			SELECT 	u.UserName, e.fname, e.lname
			FROM	Users u 
			INNER JOIN ALCWEB.dbo.Employees e	ON	u.employeeid = e.employee_ndx
			WHERE 	employeeid = #REGION.iVPUser_ID#
		</CFQUERY>
</CFIF>

<!--- =============================================================================================
Retrieve Phone Type & State Code Information
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../Shared/queries/PhoneType.cfm">
<CFINCLUDE TEMPLATE = "../../Shared/queries/StateCodes.cfm">

	
<H2>
	<CFOUTPUT>#TRIM(REGION.cName)# Administration	</CFOUTPUT>	
</H2>

<!--- *********************************************************************************************
START HTML FORM FOR SUBMISION OF CHANGES
********************************************************************************************** --->
<CFOUTPUT>
<FORM ACTION="#variables.action#" METHOD="post" NAME="region">

<INPUT TYPE = "hidden" 	NAME = "iRegion_ID" VALUE = "#Region.iRegion_ID#">

	<TABLE WIDTH = "320">
		<TH COLSPAN = "3" STYLE="text-align: Center;">	Region Administration	</TH>
		<TR>	
			<TD>	Region Name	</TD>
			<TD>	<INPUT TYPE="text" NAME="cName" VALUE="#TRIM(REGION.cName)#" STYLE = "text-align: center;" onKeyDown = "this.value=Letters(this.value); Upper(this);">	</TD>	
		</TR>
		
		<TR>	
			<TD>	Region Number		</TD>	
			<TD>	<INPUT TYPE = "text"  NAME = "cNumber" 	VALUE = "#TRIM(REGION.cNumber)#" STYLE = "text-align: center;" onKeyUp = "this.value=Numbers(this.value);">	</TD>	
		</TR>
		
		
		<TR>	
			<TD>	Regional Vice-President		</TD>	
			<TD>
				<SELECT NAME = "iVPUser_ID">
					<OPTION VALUE = "#REGION.iVPUser_ID#" Selected>	#VPName.FName# #VPName.LName#	</OPTION>
						<CFLOOP QUERY = "USERS">
							<OPTION VALUE = "#USERS.employeeid#">	#USERS.Fname# #Users.LName# </OPTION>
						</CFLOOP>
				</SELECT>		
			</TD>	
		</TR>

		<TR>	<TD COLSPAN="3" STYLE = "font-weight: bold;">	Address	Information		</TD>	</TR>
		
		<TR>
			<TD>	Address 	</TD>	
			<TD>	<INPUT TYPE = "text" 	NAME = "cAddressLine1" 	VALUE = "#TRIM(REGION.cAddressLine1)#" SIZE = "40" MAXLENGTH = "40"> </TD>				
		</TR>
		
		
		
		<TR>
			<TD>	Address	2	</TD>
			<TD>	<INPUT TYPE = "text" NAME = "cAddressLine2" VALUE = "#TRIM(REGION.cAddressLine2)#" SIZE = "40" MAXLENGTH = "40">	</TD>
		</TR>
		
		
	
		<TR>
			<TD>	City	</TD>
			<TD>	<INPUT TYPE = "text" NAME = "cCity" VALUE = "#TRIM(REGION.cCity)#" SIZE = "40" onKeyDown = "this.value=Letters(this.value); Upper(this);">	</TD>
		</TR>
			

		<TR>
			<TD>	State	</TD>
			<TD>	
				<SELECT NAME = "cStateCode">
					<OPTION VALUE = "#Region.cStateCode#"> #Region.cStateCode# </OPTION>
					<CFLOOP QUERY="StateCodes">
						<OPTION VALUE = "#StateCodes.cStateCode#">	
							#StateCodes.cStateName# - #StateCodes.cStateCode#
						</OPTION>
					</CFLOOP> 
				</SELECT>
			</TD>
		</TR>
		
		
		<TR>
			<TD>	Zip Code </TD>
			<TD>	<INPUT TYPE = "text" NAME = "cZipCode" VALUE = "#TRIM(REGION.cZipCode)#" SIZE = "40" onKeyUp = "this.value=Numbers(this.value);">	</TD>
		</TR>
		

		<TR>
			<TD>	Office Phone </TD>
			<TD>	
				<CFSET areacode1 = #Left(Region.cPhoneNumber1,3)#>
				<CFSET prefix1	 = #Mid(Region.cPhoneNumber1,4,3)#>
				<CFSET number1	 = #Right(Region.cPhoneNumber1,4)#>
			
				<INPUT TYPE = "text" NAME = "areacode1"	SIZE = "3"	VALUE = "#variables.areacode1#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
				<INPUT TYPE = "text" NAME = "prefix1"	SIZE = "3"	VALUE = "#variables.prefix1#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
				<INPUT TYPE = "text" NAME = "number1"	SIZE = "4"	VALUE = "#variables.number1#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">
			</TD>
					<INPUT TYPE = "hidden" NAME = "iPhoneType1_ID" VALUE = "2">
		</TR>
		
		<TR>
			<TD>	Fax Phone</TD>
			<TD>	
				<CFSET areacode2 = #Left(Region.cPhoneNumber2,3)#>
				<CFSET prefix2	 = #Mid(Region.cPhoneNumber2,4,3)#>
				<CFSET number2	 = #Right(Region.cPhoneNumber2,4)#>
				
				<INPUT TYPE = "text" NAME = "areacode2"	SIZE = "3"	VALUE = "#variables.areacode2#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
				<INPUT TYPE = "text" NAME = "prefix2"	SIZE = "3"	VALUE = "#variables.prefix2#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
				<INPUT TYPE = "text" NAME = "number2"	SIZE = "4"	VALUE = "#variables.number2#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">
			</TD>
					<INPUT TYPE = "hidden" NAME = "iPhoneType2_ID" VALUE = "6">
		</TR>
		
		
		<TR>
			<TD>	Message Phone</TD>
			<TD>	
				<CFSET areacode3 = #Left(Region.cPhoneNumber3,3)#>
				<CFSET prefix3	 = #Mid(Region.cPhoneNumber3,4,3)#>
				<CFSET number3	 = #Right(Region.cPhoneNumber3,4)#>
			
				<INPUT TYPE = "text" NAME = "areacode3"	SIZE = "3"	VALUE = "#variables.areacode3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
				<INPUT TYPE = "text" NAME = "prefix3"	SIZE = "3"	VALUE = "#variables.prefix3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">-
				<INPUT TYPE = "text" NAME = "number3"	SIZE = "4"	VALUE = "#variables.number3#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">	
			</TD>
					<INPUT TYPE = "hidden" NAME = "iPhoneType3_ID" VALUE = "5">
		</TR>
		
		
		<TR>	
			<TD>				Comments													</TD>
			<TD COLSPAN = "2">	<TEXTAREA COLS="50" ROWS="3" NAME="cComments">#TRIM(Region.cComments)#</TEXTAREA>	</TD>
		</TR>	
	</TABLE>
	
	<TABLE WIDTH = "640">
		<TR>	
			<TD style = "background: linen; font-weight: bold; color: red; bordercolor: linen;">	
				<U>Note:</U> You must SAVE to keep information<BR> which you have entered!		
			</TD>	
			
			<TD bordercolor = "linen" style = "background: linen; text-align: left;">
				<INPUT CLASS = "SaveButton" 	TYPE= "SUBMIT" NAME= "Save" 	VALUE = "Save">&nbsp;&nbsp;
				<INPUT CLASS = "DontSaveButton"	TYPE= "BUTTON" NAME= "DontSave" VALUE = "Don't Save" onClick = "redirect()">
			</TD>
		</TR>
	
	</TABLE>
</CFOUTPUT>

</FORM>

<CFINCLUDE TEMPLATE="../../../Footer.cfm">