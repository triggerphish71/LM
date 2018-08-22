<!----------------------------------------------------------------------------------------------
| DESCRIPTION - HouseEdit.cfm                                                 |
|----------------------------------------------------------------------------------------------|
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|Sathya      | 08/25/2010 | Project 59492 Added the option to change the Assessment review     |
|            |            | state. Also added the flowerbox                                    |
----------------------------------------------------------------------------------------------->

<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a region.
Thus, calling HouseInsert.cfm instead of HouseUpdate.cfm
=============================================================================== --->
<CFIF IsDefined("Url.Insert")>
	<CFSET Variables.Action = 'HouseInsert.cfm'>
<CFELSE>
	<CFSET Variables.Action = 'HouseUpdate.cfm'>		
</CFIF>

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
	function redirect() { window.location = "house.cfm";}
	function required(string){ if (string.value < 3){ string.focus(); document.HouseEdit.Message.value = "This field is required"; return; } }
</SCRIPT>

<!--- =============================================================================================
Include intranet header
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<!--- =============================================================================================
Retrieve the house information from the House reference table

Following query will be used after proper table data is available
	SELECT 	*
	FROM 	OPSAREA O INNER JOIN HOUSE H
	ON	O.iOPSArea_ID = H.iOPSArea_ID
	
	SELECT	*
	FROM	HOUSE
==============================================================added  mamta bIsMedicaid--->
<CFQUERY NAME = "HouseEdit" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	H.*, O.iRegion_ID, O.cName as OPSAreaName, H.cName as cName, H.cNumber as cNumber
	,h.cNurseUser_id,h.bIsMedicaid, h.bIsCensusMedicaidOnly
	FROM 	OPSAREA O 
	INNER JOIN HOUSE H	ON	(O.iOPSArea_ID = H.iOPSArea_ID AND H.dtRowDeleted IS NULL)
	<CFIF IsDefined("url.HID")>
		WHERE	iHouse_ID = #url.HID#	
	</CFIF>
	
	<CFIF IsDefined("url.Insert")>
		WHERE	iHouse_ID = 0
	<CFELSEIF NOT IsDefined("url.HID")>
		WHERE	iHouse_ID = #url.HID#
	</CFIF>

</CFQUERY>
<!---Mamta added query to check id state is medicaid--->
<CFQUERY NAME="qGetHouseMedicaid" DATASOURCE="#APPLICATION.datasource#">
	SELECT	h.bIsMedicaid as HouseMedicaid,s.bismedicaid as StateMedicaid
	FROM	house h join statecode s on h.cstatecode=s.cstatecode 
	<CFIF IsDefined("url.HID")>
		WHERE	iHouse_ID = #url.HID#	
	</CFIF>
	
	<CFIF IsDefined("url.Insert")>
		WHERE	iHouse_ID = 0
	<CFELSEIF NOT IsDefined("url.HID")>
		WHERE	iHouse_ID = #url.HID#
	</CFIF>
	AND		dtRowDeleted IS NULL
</CFQUERY>
<!---<cfdump var="#qGetHouseMedicaid#">--->

<!--- =============================================================================================
Retrieve PD UserName
============================================================================================= --->
<CFQUERY NAME="PDName" DATASOURCE="DMS">
	SELECT 	u.UserID, u.UserName, e.fname, e.lname
	FROM	Users u 
	INNER JOIN ALCWEB.dbo.Employees e	ON	u.employeeid = e.employee_ndx
	<CFIF NOT IsDefined("url.Insert")>
		WHERE 	employeeid 	= #HouseEdit.iPDUser_ID#
	<CFELSE>
		WHERE	employeeid	= 0
	</CFIF>
</CFQUERY>


<!--- =============================================================================================
Retrieve Acct UserName
============================================================================================= --->
<CFQUERY NAME="AcctName" DATASOURCE="DMS">
	SELECT 	u.UserID, u.UserName, e.fname, e.lname
	FROM	Users u 
	inner join ALCWEB.dbo.Employees e	ON	u.employeeid = e.employee_ndx
	<CFIF NOT IsDefined("url.Insert")>
		WHERE 	employeeid 	= #HouseEdit.iAcctUser_ID#
	<CFELSE>
		WHERE	employeeid	= 0
	</CFIF>
</CFQUERY>


<!--- =============================================================================================
Retreive House employeeeID
============================================================================================= --->
<CFQUERY NAME = "HouseID"	DATASOURCE = "DMS">
	SELECT	u.employeeid, e.employee_ndx, e.fname, e.lname
	FROM	USERS	u
	INNER JOIN ALCWEB.dbo.Employees E	ON	u.employeeid = e.employee_ndx
	<CFIF NOT IsDefined("url.Insert")>
		WHERE 	u.EmployeeID = #HouseEdit.iPDUser_ID#
	<CFELSE>
		WHERE 	u.EmployeeID = 0
	</CFIF>

</CFQUERY>


<!--- =============================================================================================
Retreive House employeeeID
============================================================================================= --->
<CFQUERY NAME="AcctID"	DATASOURCE="DMS">
	SELECT	u.employeeid, e.employee_ndx, e.fname, e.lname
	FROM	USERS	u
	JOIN ALCWEB.dbo.Employees E	ON	u.employeeid = e.employee_ndx
	<CFIF NOT IsDefined("url.Insert")>
		WHERE 	u.EmployeeID = #isBlank(HouseEdit.iAcctUser_ID,0)#
	<CFELSE> WHERE 	u.EmployeeID = 0 </CFIF>
</CFQUERY>


<!--- =============================================================================================
Retreive Nurse employeeeID
============================================================================================= --->
<CFQUERY NAME="NurseID"	DATASOURCE="DMS">
	SELECT	u.employeeid, e.employee_ndx, e.fname, e.lname
	FROM	USERS	u
	INNER JOIN ALCWEB.dbo.Employees E	ON	u.employeeid = e.employee_ndx
	<CFIF NOT IsDefined("url.Insert")>WHERE u.EmployeeID = #isBlank(HouseEdit.cNurseUser_ID,0)#
	<CFELSE> WHERE 	u.EmployeeID = 0 </CFIF>
</CFQUERY>

<!--- 08/25/2010 Project 59492 Sathya added this change for the assessment reviewType --->
<!--- Get the information for the AssessmentCycle which has the review information --->
<CFQUERY NAME="AssessmentCycle"	DATASOURCE="#APPLICATION.datasource#">
	SELECT iPeriod_id,cDescription,FutureBillingDays 
	FROM AssessmentCycle
	WHERE dtrowdeleted is null
</CFQUERY>
<!--- End of project Project 59492 --->

<!---Mamta--->
<cfquery name="qryResidents" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id
	join house h on t.ihouse_id = h.ihouse_id and
	 <CFIF IsDefined("url.HID")>
		h.iHouse_ID = #url.HID#	
	</CFIF>
	
	<CFIF IsDefined("url.Insert")>
		h.iHouse_ID = 0
	<CFELSEIF NOT IsDefined("url.HID")>
		h.iHouse_ID = #url.HID#
	</CFIF>
	where ts.itenantstatecode_id in (1,2,3) 
		and ts.iresidencytype_id = 2
		and t.clastname <> 'Medicaid'
</cfquery>
<cfdump var="#qryResidents#">
<!---mamta--->
<!--- =============================================================================================
Retrieve Phone Type, State Code, OPSArea, Userlist Information
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../Shared/queries/PhoneType.cfm">
<CFINCLUDE TEMPLATE = "../../Shared/queries/StateCodes.cfm">
<CFINCLUDE TEMPLATE = "../../Shared/queries/OPSAreas.cfm">
<CFINCLUDE TEMPLATE = "../../Shared/queries/UserList.cfm">


<CFOUTPUT>
<!--- =============================================================================================
Start display of House Information
============================================================================================= --->
<FORM NAME = "HouseEdit" ACTION = "#Variables.Action#"	METHOD = "POST">
	
<!--- ==============================================================================
Set hidden variable for the house's SQL index Number
=============================================================================== --->
<INPUT TYPE = "hidden" NAME = "iHouse_ID" VALUE = "#HouseEdit.iHouse_ID#">
<INPUT NAME="Message" TYPE="TEXT" VALUE="Required are listed in red." SIZE="75" STYLE="Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">

	<TABLE WIDTH="640">
		<TR><TH COLSPAN="2" STYLE="text-align: center;"> House Administration </TH></TR>
		<TR>
			<TD CLASS="Required"> House Name </TD>	
			<TD><INPUT TYPE = "type" NAME = "cName"	VALUE = "#TRIM(HouseEdit.cName)#" STYLE = "text-align: center;" 
			onChange = "this.value=Letters(this.value);  Upper(this);" onBlur="this.obj=required(this)"></TD>
		</TR>		
		<TR>
			<TD CLASS = "Required"> House Number </TD>
			<TD>	
				<INPUT TYPE = "type" NAME = "cNumber"	VALUE = "#TRIM(HouseEdit.cNumber)#" STYLE = "text-align: center;" SIZE = "20"
				 MAXLENGTH = "4" onKeyUp = "this.value=Numbers(this.value);" onBlur="this.obj=required(this)">					
			</TD>			
		</TR>
		<TR>	
			<TD> Program Director </TD>
			<TD>	
				<SELECT NAME = "iPDUser_ID">
					<CFIF NOT IsDefined("url.Insert")>
						
						<!--- ==============================================================================
						Retrieve House Account and Email from ASPEN CENSUS HouseAddresses AND Houses Tables
						<CFQUERY NAME="HouseUser" DATASOURCE="Census">
							SELECT	* FROM	HouseAddresses HA
							JOIN 	Houses H	ON	H.nhouse = HA.nhouse
							WHERE	HA.nHouse = #HouseEdit.cNumber#
						</CFQUERY>
						
						<CFIF HouseID.RecordCount EQ 0 OR HouseID.employeeid EQ "">
							<CFSET HouseAcct = 'SELECTED'>
						<CFELSE>
							<CFSET HouseAcct = ''>
						</CFIF>
						<OPTION VALUE="#HouseUser.nHouse#" #HouseAcct#> #HouseUser.HouseName#	</OPTION>
						=============================================================================== --->						
						<OPTION VALUE="#HouseEdit.cnumber#"> #HouseEdit.cName#	</OPTION>
						<CFIF HouseID.employeeid NEQ "" OR HouseEdit.iPDUSER_ID EQ #SESSION.nHouse#>
							<CFLOOP QUERY="Users">
								<CFIF HouseID.employeeid EQ Users.employeeid>
									<CFSET Selected='Selected'>
								<CFELSE>
									<CFSET Selected=''>
								</CFIF>							
								<OPTION VALUE="#Users.employeeid#" #Selected#>	#Users.Lname#,&nbsp;#Users.Fname#	</OPTION>
							</CFLOOP>			
						</CFIF>
					
					<CFELSE>
					
						<OPTION VALUE = "0">	Program Director </OPTION>				
						<CFLOOP QUERY = "Users">
							<OPTION VALUE = "#Users.employeeid#">	#Users.Fname#&nbsp;#Users.Lname#	</OPTION>
						</CFLOOP>		
					
					</CFIF>
				</SELECT>
			</TD>	
		</TR>
		
		<TR>	
			<TD>Accounts Receivable Specialist</TD>
			<TD>	
				<SELECT NAME = "iAcctUser_ID">
					<CFIF NOT IsDefined("url.Insert")>
					
						<CFIF AcctID.employeeid NEQ "">
							<CFLOOP QUERY = "Users">
								<CFIF AcctID.employeeid EQ Users.employeeid>
									<CFSET Selected = 'Selected'>
								<CFELSE>
									<CFSET Selected = ''>
								</CFIF>
								<OPTION VALUE = "#Users.employeeid#" #Selected#>	#Users.Lname#,&nbsp;#Users.Fname#	</OPTION>
							</CFLOOP>			
						</CFIF>
					
					<CFELSE>
					
						<OPTION VALUE = "0">	Accounts Receivable Specialist	 </OPTION>				
						<CFLOOP QUERY = "Users">
							<OPTION VALUE = "#Users.employeeid#">	#Users.Fname#&nbsp;#Users.Lname#	</OPTION>
						</CFLOOP>		
					
					</CFIF>
				</SELECT>
			</TD>	
		</TR>		
	
			<TR>	
			<TD>Nursing Staff</TD>
			<TD>	
				<SELECT NAME="cNurseUser_ID">
					<CFIF NOT IsDefined("url.Insert")>
					
						<CFIF AcctID.employeeid NEQ "">
							<CFLOOP QUERY = "Users">
								<CFIF NurseID.employeeid EQ Users.employeeid>
									<CFSET Selected = 'Selected'>
								<CFELSE>
									<CFSET Selected = ''>
								</CFIF>
								<OPTION VALUE = "#Users.employeeid#" #Selected#>	#Users.Lname#,&nbsp;#Users.Fname#	</OPTION>
							</CFLOOP>			
						</CFIF>
					
					<CFELSE>
					
						<OPTION VALUE = "0"> Nurse Staff </OPTION>				
						<CFLOOP QUERY = "Users">
							<OPTION VALUE = "#Users.employeeid#">	#Users.Fname#&nbsp;#Users.Lname#	</OPTION>
						</CFLOOP>		
					
					</CFIF>
				</SELECT>
			</TD>	
		</TR>		
		
		<TR>
			<TD>	Operations Area		</TD>
			<TD>
				<SELECT NAME = "iOPSArea_ID">
					<CFIF NOT IsDefined("url.Insert")>
					
						<CFIF HouseEdit.iOPSArea_ID NEQ "">
							<OPTION VALUE = "#HouseEdit.iOPSArea_ID#" SELECTED>	###HouseEdit.iRegion_ID##HouseEdit.cNumber# - #HouseEdit.OPSAreaName# 	</OPTION>
							<CFLOOP QUERY = "OPSAreas">
								<OPTION VALUE = "#OPSAreas.iOpsArea_ID#">
									 ###OpsAreas.iRegion_ID##OpsAreas.cNumber# - #OpsAreas.cName# 
								</OPTION>
							</CFLOOP>
						</CFIF>
					
					<CFELSE>
					
						<OPTION VALUE = "21"> Portland & Central Oregon	</OPTION>
						<CFLOOP QUERY = "OPSAreas">
							<OPTION VALUE = "#OPSAreas.iOpsArea_ID#">
								#OpsAreas.cName#
							</OPTION>
						</CFLOOP>
					
					</CFIF>
				</SELECT>
			</TD>			
		</TR>
		<TR>
			<TD>GL Subaccount</TD>	
			<TD><INPUT TYPE="text" NAME="cGLsubaccount" MAXLENGTH="9" VAlUE = "#HouseEdit.cGLsubaccount#"></TD>	
		</TR>
		
		<CFIF remote_addr EQ '10.1.0.201' OR remote_addr EQ '10.1.0.218' OR remote_addr EQ '10.1.0.211'
		or session.userid eq '36' or 1 eq 1>
		<TR>
			<TD>Service Level Type Set</TD>	
			<TD>	
				<CFIF HouseEdit.cSLevelTypeSet NEQ "">	
					<INPUT TYPE = "text" NAME = "cSLevelTypeSet" VAlUE = "#HouseEdit.cSLevelTypeSet#">
				<CFELSE>
					<INPUT TYPE = "text" NAME = "cSLevelTypeSet" VAlUE = "9" style="border:0px;text-align:center;" readonly>
				</CFIF>	
			</TD>	
		</TR>
		<CFELSE>
			<INPUT TYPE='hidden' NAME='cSLevelTypeSet' VALUE='#HouseEdit.cSLevelTypeSet#'>
		</CFIF>

		<!---
		<TR>	
			<TD>Deposit Type Set</TD>
			<TD><INPUT TYPE="text" NAME="cDepositTypeSet" 	VAlUE="#HouseEdit.cDepositTypeSet#"></TD>	
		</TR>
		
		<TR>
			<TD>Medicaid Only Flag</TD>	
			<TD>	
				<CFIF HouseEdit.bIsCensusMedicaidOnly EQ 1>
					<INPUT TYPE = "CheckBox" NAME = "bIsCensusMedicaidOnly" VAlUE = "1" CHECKED> 	
				<CFELSE>
					<INPUT TYPE = "CheckBox" NAME = "bIsCensusMedicaidOnly" VAlUE = "0">
				</CFIF>
			</TD>	
		</TR>
		--->
		
		<TR>
			<TD>Address Line 1</TD>
			<TD><INPUT TYPE="type" NAME="cAddressLine1"	SIZE="40" VALUE="#TRIM(HouseEdit.cAddressLine1)#" MAXLENGTH="40"></TD>
		</TR>
		<TR>	
			<TD>Address Line 2</TD>
			<TD><INPUT TYPE="type" NAME="cAddressLine2"	SIZE="40" VALUE="#TRIM(HouseEdit.cAddressLine2)#" MAXLENGTH="40"></TD>
		</TR>
		<TR>
			<TD>City</TD>	
			<TD><INPUT TYPE="type" NAME="cCity"	VALUE="#TRIM(HouseEdit.cCity)#" onKeyDown="this.value=Letters(this.value);  Upper(this);"></TD>
		</TR>
		<TR>
			<TD>State Code</TD>	
			<TD>	
				<SELECT NAME = "cStateCode">
					<OPTION VALUE = "#HouseEdit.cStateCode#" Selected> #HouseEdit.cStateCode# </OPTION>
					<CFLOOP QUERY="StateCodes"> <OPTION VALUE = "#StateCodes.cStateCode#"> #StateCodes.cStateName# - #StateCodes.cStateCode# </OPTION> </CFLOOP> 
				</SELECT>
			</TD>
		</TR>
		<TR>	
			<TD>Zip Code</TD>
			<TD><INPUT TYPE="type" NAME="cZipCode"	VALUE="#TRIM(HouseEdit.cZipCode)#" MAXLENGTH = "5" STYLE = "text-align: Center;" onKeyUp = "this.value=Numbers(this.value);"></TD>	
		</TR>
		<TR>
		<TR> <!---mamta added--->	
		<cfif #TRIM(qGetHouseMedicaid.StateMedicaid)# eq 1>
			<TD> Medicaid ?</TD>
			<cfif #TRIM(qGetHouseMedicaid.HouseMedicaid)# eq 1>
			<TD><INPUT TYPE="checkbox" NAME="bIsMedicaid" VALUE="#TRIM(qGetHouseMedicaid.HouseMedicaid)#" STYLE = "text-align: Center;" checked="checked"</TD>	
			<cfelse> <TD><INPUT TYPE="checkbox" NAME="bIsMedicaid" VALUE="#TRIM(qGetHouseMedicaid.HouseMedicaid)#" STYLE = "text-align: Center;" </TD>	
			 </cfif>
		</cfif>
			</TR><!---mamta added end--->	
		<TR>
			<TD>	Phone Number 1	- Office				</TD>	
			<TD>	
				<CFSET areacode1 = #Left(HouseEdit.cPhoneNumber1,3)#>
				<CFSET prefix1	 = #Mid(HouseEdit.cPhoneNumber1,4,3)#>
				<CFSET number1	 = #Right(HouseEdit.cPhoneNumber1,4)#>
			
				<INPUT TYPE = "text" NAME = "areacode1"	SIZE = "3"	VALUE = "#variables.areacode1#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);"> -
				<INPUT TYPE = "text" NAME = "prefix1"	SIZE = "3"	VALUE = "#variables.prefix1#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);"> -
				<INPUT TYPE = "text" NAME = "number1"	SIZE = "4"	VALUE = "#variables.number1#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">
				<INPUT TYPE = "hidden" NAME = "iPhoneType1_ID"	VALUE = "2">
			</TD>	
		</TR>
		<TR>
			<TD>Phone Number 2	- Fax</TD>	
			<TD>	
				<CFSET areacode2 = #Left(HouseEdit.cPhoneNumber2,3)#>
				<CFSET prefix2	 = #Mid(HouseEdit.cPhoneNumber2,4,3)#>
				<CFSET number2	 = #Right(HouseEdit.cPhoneNumber2,4)#>
				<INPUT TYPE = "text" NAME = "areacode2"	SIZE = "3"	VALUE = "#variables.areacode2#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);"> -
				<INPUT TYPE = "text" NAME = "prefix2"	SIZE = "3"	VALUE = "#variables.prefix2#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);"> -
				<INPUT TYPE = "text" NAME = "number2"	SIZE = "4"	VALUE = "#variables.number2#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">
				<INPUT TYPE = "hidden" NAME = "iPhoneType2_ID"	VALUE = "6">
			</TD> 		
		</TR>
		<TR>	
			<TD> Phone Number 3	- Pager </TD>
			<TD>	
				<CFSET areacode3 = #Left(HouseEdit.cPhoneNumber3,3)#>
				<CFSET prefix3	 = #Mid(HouseEdit.cPhoneNumber3,4,3)#>
				<CFSET number3	 = #Right(HouseEdit.cPhoneNumber3,4)#>
				<INPUT TYPE = "text" NAME = "areacode3"	SIZE = "3"	VALUE = "#variables.areacode3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);"> -
				<INPUT TYPE = "text" NAME = "prefix3"	SIZE = "3"	VALUE = "#variables.prefix3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);"> -
				<INPUT TYPE = "text" NAME = "number3"	SIZE = "4"	VALUE = "#variables.number3#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);">
				<INPUT TYPE = "hidden" NAME = "iPhoneType3_ID"	VALUE = "4"> 		
			</TD>	
		</TR>
		<!--- 08/25/2010 Project 59492 Sathya added this change for the assessment reviewType --->
		<TR>
			<TD>Assessment Review Type:</TD>
			<TD>
				<SELECT NAME = "Period_id">
					<OPTION VALUE = ""> None </OPTION>
					<CFLOOP QUERY="AssessmentCycle"> 
						<cfscript>
						 if (AssessmentCycle.iPeriod_id EQ HouseEdit.iPeriod_id)
							{ Selected = 'Selected'; }
						else
							{ Selected = ''; }
						</cfscript>
						<OPTION VALUE = "#AssessmentCycle.iPeriod_id#" #Selected#> 
							#AssessmentCycle.cDescription# - #AssessmentCycle.FutureBillingDays# days 
						</OPTION> 
					</CFLOOP> 
				</SELECT>
			</TD>
		</TR>
		<!--- End of code Project 59429 --->
		<TR>
			<TD> Comments </TD>	
			<TD><TEXTAREA COLS="50" ROWS="3" NAME="cComments">#TRIM(HouseEdit.cComments)#</TEXTAREA></TD>
		</TR>

		<script>
			function test()
			{
			alert('Removing from Medicaid eligibilty is not allowed at this time.');
			}
		</script>
		<TR>
			<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" <cfif qryResidents.recordcount gt 0> onclick="test()"</cfif>></TD>
			<TD style="text-align: right;"><INPUT CLASS = "DontSaveButton"	TYPE= "BUTTON" NAME= "DontSave" VALUE = "Don't Save" onClick = "redirect()"></TD>
		</TR>	
		<TR><TD COLSPAN="2" style="font-weight: bold; color: red; bordercolor: linen;">	<U>Note:</U> You must SAVE to keep information which you have entered! </TD></TR>
	</TABLE>

</CFOUTPUT>
</FORM>

<!--- Include Intranet Footer --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">