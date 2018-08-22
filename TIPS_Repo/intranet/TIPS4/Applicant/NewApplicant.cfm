<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|  Create/Add Applicants                                                                       |
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
| pbuendia   | 02/20/2002 | This Programmers Header created, Excluded Moved out People from    |
|                         | the link to section for the solomonkeys                            |
| ranklam    | 10/05/2005 | Added product line infornmation.                                   |
| ranklam    | 10/24/2005 | removed datasource information fromqActiveTenants                  |
----------------------------------------------------------------------------------------------->

<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a region.
Thus, calling HouseInsert.cfm instead of HouseUpdate.cfm
=============================================================================== --->

	<!--- rsa - 10/5/05 - added retrieve house product line info --->
<cfquery name="qproductline" datasource="#application.datasource#">
	SELECT
		pl.iproductline_id, pl.cdescription
	FROM 
		houseproductline hpl
	INNER JOIN
		productline pl on pl.iproductline_id = hpl.iproductline_id 	AND pl.dtrowdeleted is null
	WHERE
		hpl.dtrowdeleted is null and hpl.ihouse_id = #session.qselectedhouse.ihouse_id#
</cfquery>

<CFIF IsDefined("Url.ID")> 
	<CFSET Variables.Action='NewApplicantUpdate.cfm'> 
<CFELSE> 
	<CFSET Variables.Action='NewApplicantInsert.cfm'> 
</CFIF>

<!--- YUCK!! More hard coded values!! --->
<CFIF SESSION.UserID IS 3025> <CFOUTPUT> #Variables.Action# </CFOUTPUT> </CFIF>

<!--- =============================================================================================
Include Javascript code for only allowing:
Numbers	:	USE onKeyUp = "this.value=Numbers(this.value)"
Letters:	USE onKeyUp = "this.value=Letters(this.value)"
============================================================================================= --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>	
	function redirect() {	window.location = "../Registration/Registration.cfm"; }
	function phone(){		
		
		if (document.NewApplicant.prefix1.value.length >=1 && document.NewApplicant.areacode1.value.length !=3){
		(document.NewApplicant.Message.value = "Please, enter the Area Code");
		document.NewApplicant.areacode1.focus();
		return;
		}

		if (document.NewApplicant.prefix2.value.length >=1 && document.NewApplicant.areacode2.value.length !=3){
		(document.NewApplicant.Message.value = "Please, enter the Area Code");
		document.NewApplicant.areacode2.focus();
		return;
		}
		
		if (document.NewApplicant.prefix3.value.length >=1 && document.NewApplicant.areacode3.value.length !=3){
		(document.NewApplicant.Message.value = "Please, enter the Area Code");
		document.NewApplicant.areacode3.focus();
		return;
		}
				
		if (document.NewApplicant.number1.value.length >=1 && document.NewApplicant.prefix1.value.length !=3){
		(document.NewApplicant.Message.value = "Please, enter the phone number prefix");
		document.NewApplicant.prefix1.focus();
		return;
		}
	
		if (document.NewApplicant.number2.value.length >=1 && document.NewApplicant.prefix2.value.length !=3){
		(document.NewApplicant.Message.value = "Please, enter the phone number prefix");
		document.NewApplicant.prefix2.focus();
		return;
		}
		
		if (document.NewApplicant.number3.value.length >=1 && document.NewApplicant.prefix3.value.length !=3){
		(document.NewApplicant.Message.value = "Please, enter the phone number prefix");
		document.NewApplicant.prefix3.focus();
		return;
		}
		
		if (document.NewApplicant.number1.value.length == "" && document.NewApplicant.prefix1.value.length ==3){
		(document.NewApplicant.Message.value = "Please, enter the phone number prefix");
		document.NewApplicant.number1.focus();
		return;
		}
	
		if (document.NewApplicant.number2.value.length =="" && document.NewApplicant.prefix2.value.length ==3){
		(document.NewApplicant.Message.value = "Please, enter the phone number prefix");
		document.NewApplicant.number2.focus();
		return;
		}
		
		if (document.NewApplicant.number3.value.length =="" && document.NewApplicant.prefix3.value.length ==3){
		(document.NewApplicant.Message.value = "Please, enter the phone number prefix");
		document.NewApplicant.number3.focus();
		return;
		}		
		
		if (document.NewApplicant.areacode1.value.length >= 1 && document.NewApplicant.areacode1.value.length !=3){
		(document.NewApplicant.Message.value = "Area Code Requires 3 numbers");
		document.NewApplicant.areacode1.focus();
		return;
	}		
		if (document.NewApplicant.areacode2.value.length >= 1 && document.NewApplicant.areacode2.value.length !=3){
		(document.NewApplicant.Message.value = "Area Code Requires 3 numbers");
		document.NewApplicant.areacode2.focus();	
		return;
	}	
		if (document.NewApplicant.areacode3.value.length >= 1 && document.NewApplicant.areacode3.value.length !=3){
		(document.NewApplicant.Message.value = "Area Code Requires 3 numbers");
		document.NewApplicant.areacode3.focus();	
		return;
	}
		if (document.NewApplicant.prefix1.value.length >= 1 && document.NewApplicant.prefix1.value.length !=3){
		(document.NewApplicant.Message.value = "This Field Requires 3 numbers");
		document.NewApplicant.prefix1.focus();
		return;
	}		
		if (document.NewApplicant.prefix2.value.length >= 1 && document.NewApplicant.prefix2.value.length !=3){
		(document.NewApplicant.Message.value = "This Field Requires 3 numbers");
		document.NewApplicant.prefix2.focus();	
		return;
	}	
		if (document.NewApplicant.prefix3.value.length >= 1 && document.NewApplicant.prefix3.value.length !=3){
		(document.NewApplicant.Message.value = "This Field Requires 3 numbers");
		document.NewApplicant.prefix3.focus();	
		return;
	}
		if (document.NewApplicant.number1.value.length >= 1 && document.NewApplicant.number1.value.length != 4){
		(document.NewApplicant.Message.value = "This Field Requires 4 numbers");
		document.NewApplicant.number1.focus();
		return;
	}		
		if (document.NewApplicant.number2.value.length >= 1 && document.NewApplicant.number2.value.length !=4){
		(document.NewApplicant.Message.value = "This Field Requires 4 numbers");
		document.NewApplicant.number2.focus();	
		return;
	}	
		if (document.NewApplicant.number3.value.length >= 1 && document.NewApplicant.number3.value.length !=4){
		(document.NewApplicant.Message.value = "This Field Requires 4 numbers");
		document.NewApplicant.number3.focus();	
		return;
	}
		else {
		(document.NewApplicant.Message.value = "")		
		return true;
	}
	}
	
	function areacode(string) {
		if (string.value.length >= 1 && string.value.length != 3){
		(document.NewApplicant.Message.value = "Area Code Requires 3 numbers");
		string.focus();
		return;
		}
		else {
		(document.NewApplicant.Message.value = "")
		return true;
		}
	}

	function prefix(string) {
		if (string.value.length >= 1 && string.value.length != 3){
		(document.NewApplicant.Message.value = "This field requires 3 numbers");		
		string.focus();
		return;
	}
		else {
		(document.NewApplicant.Message.value = "")
		return true;
		}	
	}	

	function number(string) {
		if (string.value.length >= 1 && string.value.length != 4){
		(document.NewApplicant.Message.value = "This field requires 4 numbers");
		string.focus();
		return;
	}
		else {
		(document.NewApplicant.Message.value = "")
		return true;
		}	
	}	
				
	function required() {
	var failed = false;

		if (document.NewApplicant.cFirstName.value.length < 2){
		document.NewApplicant.cFirstName.focus();
		(document.NewApplicant.Message.value = "Please Enter or Check First Name")
		return false;
		}

		if (document.NewApplicant.cLastName.value.length < 2){
		document.NewApplicant.cLastName.focus();
		(document.NewApplicant.Message.value = "Please Enter or Check Last Name")
		return false;
		}
		
		if (document.NewApplicant.cOutsideAddressLine1.value.length < 3){
		document.NewApplicant.cOutsideAddressLine1.focus();
		(document.NewApplicant.Message.value = "Please Enter or Check Address")
		return false;
		}
	
		if (document.NewApplicant.cOutsideCity.value.length < 3){
		document.NewApplicant.cOutsideCity.focus();
		(document.NewApplicant.Message.value = "Please Enter or Check City")
		return false;
		}

		if (document.NewApplicant.cOutsideStateCode.value.length < 2){
		document.NewApplicant.cOutsideStateCode.focus();
		(document.NewApplicant.Message.value = "Please Check State")
		return false;
		}

		if (document.NewApplicant.cOutsideZipCode.value.length < 5){
		document.NewApplicant.cOutsideZipCode.focus();
		(document.NewApplicant.Message.value = "Please Enter the 5 Digit Zip Code")
		return false;
		}
		
		if (document.NewApplicant.cSolomonKey.value == "none"){
		document.NewApplicant.cSolomonKey.focus();
		(document.NewApplicant.Message.value = "Please, select from the List")
		return false;
		}
		
		if (document.NewApplicant.Year.value == ''){
			alert('Invalid year.');
			(document.NewApplicant.Message.value = "A blank year is not allowed.");
			string.focus();		
		}
		
		else {
		(document.NewApplicant.Message.value = "")
		return true;
		}
		
		phone();
	}
	
	function Birthyear(string) {
		if (string.value == '' || string.value.length < 4){
			alert('Invalid Year.');
			(document.NewApplicant.Message.value = "Invalid Year");
			string.focus();
		}
		if 	((string.value > 1990) || (string.value < 1880)) {
			(string.value = "")
			string.focus();
		}
	}
	
</SCRIPT>


<!--- =============================================================================================
Include Intranet Header
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../header.cfm">
<H1  CLASS = "PageTitle"> Tips 4 - New Applicant </H1>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">


<!--- =============================================================================================
Retreive list of State Codes, PhoneType, and Tenant Information
============================================================================================= --->
<CFINCLUDE TEMPLATE="../Shared/Queries/StateCodes.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/PhoneType.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/TenantInformation.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/Residency.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/SolomonKeyList.cfm">


<CFOUTPUT>
<FORM NAME = "NewApplicant" ACTION="#Variables.Action#" METHOD="POST" onSubmit="return required();" onKeyPress="CancelEnter();">
<INPUT NAME="Message" TYPE="TEXT" VALUE="Required are listed in red." SIZE = "75" READONLY STYLE="Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">

<TABLE>
	<TH COLSPAN="4"> Register a New Applicant </TH>
	<TR>	
		<TD CLASS="required"> First Name </TD>
		<TD><INPUT TYPE="TEXT" NAME="cFirstName" VALUE="#TenantInfo.cFirstName#" onBlur="this.value=Letters(this.value);  Upper(this);">	</TD>
		<TD CLASS="required"> Last Name </TD>		
		<TD><INPUT TYPE="TEXT" NAME="cLastName"  VALUE="#TenantInfo.cLastName#" onBlur="this.value=Letters(this.value);  Upper(this);" onKeyDown="backspace(this);"> </TD>	
	</TR>

	<TR>	
		<TD CLASS="required"> Address Line 1 </TD>	
		<TD COLSPAN=2> <INPUT TYPE="TEXT" NAME="cOutsideAddressLine1" VALUE="#TenantInfo.cOutsideAddressLine1#" SIZE="40" MAXLENGTH="40" onKeyDown="backspace(this);"> </TD>
		<TD></TD>
	</TR>
	
	<TR>	
		<TD> Address Line 2 </TD>	
		<TD COLSPAN="2"> <INPUT TYPE="TEXT" NAME="cOutsideAddressLine2" VALUE="#TenantInfo.cOutsideAddressLine2#" SIZE="40" MAXLENGTH="40" onKeyDown="backspace(this);"> </TD>
		<TD></TD>	
	</TR>

	<TR>	
		<TD CLASS="required"> City </TD>
		<TD><INPUT TYPE="TEXT" NAME="cOutsideCity" VALUE="#TenantInfo.cOutsideCity#" onBlur="this.value=Letters(this.value); Upper(this);" onKeyDown="backspace(this);"></TD>
		<TD></TD> <TD></TD>
	</TR>
	
	<TR>	
		<TD CLASS="required"> State </TD>	
		<TD>
			<SELECT NAME = "cOutsideStateCode" onBlur= "required();" onKeyDown="backhandler();">
				<CFLOOP Query="StateCodes">
					<CFIF TenantInfo.cOutsideStateCode EQ StateCodes.cStateCode><CFSET Selected='Selected'><CFELSE><CFSET Selected=''></CFIF>
					<OPTION VALUE ="#cStateCode#" #Selected#> #cStateName# - #cStateCode# </OPTION>
				</CFLOOP>
			</SELECT>
		<TD></TD>
		<TD></TD>
	</TR>
	
	<TR>	
		<TD CLASS="required"> Zip Code </TD>	
		<TD><INPUT TYPE="TEXT" NAME="cOutsideZipCode" VALUE="#TenantInfo.cOutsideZipCode#" onKeyDown="backspace(this);"></TD>
		<TD></TD> <TD></TD>	
	</TR>

	<TR>
		<TD> Account Number </TD>
		<TD COLSPAN="2">
			<!--- ==============================================================================
			Query the solomonkey list and filter the moved out tenants
			=============================================================================== --->
			<CFQUERY NAME="qActiveTenants" DBTYPE="Query">
				SELECT	cSolomonKey, cFirstName, cLastName, iTenantStateCode_ID
				FROM	SolomonKeyList
				WHERE	iTenantStateCode_ID < 3
			</CFQUERY>
			<SELECT NAME="cSolomonKey" onBlur="required();" onKeyDown="backhandler();">
				<OPTION VALUE="">	Create new Account </OPTION>
				<CFLOOP QUERY="qActiveTenants">
					<OPTION VALUE="#qActiveTenants.cSolomonKey#"> Link to #qActiveTenants.cLastName#, #qActiveTenants.cFirstName# (#qActiveTenants.cSolomonKey#)</OPTION>
				</CFLOOP>
			</SELECT>
		</TD>
		<TD></TD>
	</TR>
	
	<TR>
		<TD> Charge Application Fee?	<INPUT TYPE="CheckBox" NAME="bApplicationFee" VALUE="1" onKeyDown="backspace(this);">	</TD>
		<TD></TD><TD></TD><TD></TD>
	</TR>
	<!--- rsa - 10/5/05 - added product line select --->
	<tr>
		<td> Product line </td>
		<td>
		<select id="iproductline_id" name="iproductline_id" onChange="genRes(this)">
		<cfloop query= "qproductline">
			<option value= "#qproductline.iproductline_id#">	#qproductline.cDescription#	</option>
		</cfloop>
		</select>	
		</td>
		<td colspan="2"></td>
	</tr>
	<TR>
		<TD> Residency Type	</TD>
		<TD>
			<SELECT NAME = "iResidencyType_ID" onKeyDown="backhandler();">
				<CFLOOP QUERY="Residency"><OPTION VALUE = "#Residency.iResidencyType_ID#">	#Residency.cDescription#</OPTION></CFLOOP>
			</SELECT>	
		</TD>
		<TD></TD><TD></TD>
	</TR>
	
	<TR>
		<TD>Does this person <BR> satisfy a Bond Requirement?</TD>	
		<TD>If Yes, Click Here -><INPUT TYPE="checkbox"	NAME="Bond" VALUE="" onKeyDown="backspace(this);"></TD>	
		<TD></TD><TD></TD>
	</TR>
	
	<TR>
		<TD> SSN </TD>
		<TD>
			<CFSET First=LEFT(TenantInfo.cSSN,3)>
			<CFSET Middle=Mid(TenantInfo.cSSN,4,3)>
			<CFSET Last=RIGHT(TenantInfo.cSSN,4)>
			<INPUT TYPE="text" NAME="First" VALUE="#Variables.first#" SIZE="3" MAXLENGTH="3" onKeyUp="this.value=Numbers(this.value);" onKeyDown="backspace(this);">	-
			<INPUT TYPE="text" NAME="Middle" VALUE="#Variables.Middle#" SIZE="2" MAXLENGTH="2" onKeyUp="this.value=Numbers(this.value);" onKeyDown="backspace(this);">	-
			<INPUT TYPE="text" NAME="Last" VALUE="#Variables.Last#" SIZE="4" MAXLENGTH="4" onKeyUp="this.value=Numbers(this.value);" onKeyDown="backspace(this);">
		</TD>
		<TD></TD>
		<TD></TD>
	</TR>	
	
	
	<TR>	
		<TD> Birthdate </TD>	

		<CFIF TenantInfo.dBirthDate NEQ "">
			<CFSET MONTH = Month(TenantInfo.dBirthDate)>
			<CFSET Day = Day(TenantInfo.dBirthDate)>
			<CFSET Year = Year(TenantInfo.dBirthDate)>
		<CFELSE>
			<CFSET Month = Month(Now())>
			<CFSET Day = Day(Now())>
			<CFSET Year = 1920>	
		</CFIF>
		<TD>
			<SELECT NAME="Month" onBlur="dayslist(document.NewApplicant.Month,document.NewApplicant.Day,document.NewApplicant.Year);" onKeyDown="backhandler();">
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> 
						<CFIF Variables.Month EQ #I#> <CFSET Selected = 'Selected'> <CFELSE> <CFSET Selected = ''> </CFIF>
						<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
					</CFLOOP>
			</SELECT>
			/
			<SELECT NAME = "Day" onKeyDown="backhandler();">
				<OPTION VALUE = "#Day#">	#Day#	</OPTION>
					<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1"> 
						<OPTION VALUE="#I#"> #I# </OPTION>
					</CFLOOP>
			</SELECT>	
			/
			<INPUT TYPE="Text" NAME="Year" Value="#Year#" SIZE="3" MAXLENGTH=4 onBlur="dayslist(document.NewApplicant.Month,document.NewApplicant.Day,document.NewApplicant.Year); Birthyear(this);" onKeyDown="backspace(this);">
		</TD>
		<TD></TD>
		<TD></TD>
	</TR>
	
		
	<TR>	
		<TD>Home Phone	<INPUT TYPE = "Hidden" NAME = "iOutSidePhoneType1_ID" VALUE = "1"> </TD>	
		<TD>
			<CFSET areacode1 = Left(TenantInfo.cOutsidePhoneNumber1,3)>
			<CFSET prefix1 = Mid(TenantInfo.cOutsidePhoneNumber1,4,3)>
			<CFSET number1 = Right(TenantInfo.cOutsidePhoneNumber1,4)>
			<INPUT TYPE="text" NAME="areacode1"	SIZE="3" VALUE="#Variables.areacode1#" MAXLENGTH="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">-
			<INPUT TYPE="text" NAME="prefix1" SIZE="3" VALUE="#Variables.prefix1#" MAXLENGTH="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">-
			<INPUT TYPE="text" NAME="number1" SIZE="4" VALUE="#Variables.number1#" MAXLENGTH="4" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">
		</TD>
	
		<TD>	
			Message Phone
			<INPUT TYPE = "Hidden" NAME = "iOutsidePhoneType2_ID" VALUE = "5">		
		</TD>	
		<TD>
			<CFSET areacode2 = Left(TenantInfo.cOutsidePhoneNumber2,3)>
			<CFSET prefix2 = Mid(TenantInfo.cOutsidePhoneNumber2,4,3)>
			<CFSET number2 = Right(TenantInfo.cOutsidePhoneNumber2,4)>	
			<INPUT TYPE="text" NAME="areacode2"	SIZE="3" VALUE="#Variables.areacode2#" MAXLENGTH="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">-
			<INPUT TYPE="text" NAME="prefix2" SIZE="3" VALUE="#Variables.prefix2#" MAXLENGTH="3" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">-
			<INPUT TYPE="text" NAME="number2" SIZE="4" VALUE="#Variables.number2#" MAXLENGTH="4" onKeyUp="this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">
		</TD>
	</TR>
	<TR>	
		<TD>	
			<SELECT NAME = "iOutsidePhoneType3_ID" onKeyDown="backspace(this);">
			<OPTION VALUE = ""> Additional Phone </OPTION>
			<CFLOOP QUERY = "PhoneType">
				<OPTION VALUE = "#PhoneType.iPhoneType_ID#"> #PhoneType.cDescription#	</OPTION>
			</CFLOOP>
			</SELECT>			
		</TD>	
		<TD>
			<CFSET areacode3 = Left(TenantInfo.cOutsidePhoneNumber3,3)>
			<CFSET prefix3 = Mid(TenantInfo.cOutsidePhoneNumber3,4,3)>
			<CFSET number3 = Right(TenantInfo.cOutsidePhoneNumber3,4)>
			<INPUT TYPE = "text" NAME = "areacode3"	SIZE = "3"	VALUE = "#Variables.areacode3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">-
			<INPUT TYPE = "text" NAME = "prefix3"	SIZE = "3"	VALUE = "#Variables.prefix3#" MAXLENGTH = "3" onKeyUp = "this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">-
			<INPUT TYPE = "text" NAME = "number3"	SIZE = "4"	VALUE = "#Variables.number3#" MAXLENGTH = "4" onKeyUp = "this.value=LeadingZeroNumbers(this.value);" onBlur="phone();" onKeyDown="backspace(this);">
		</TD>
		<TD></TD><TD></TD>
	</TR>
	
	<TR>	
		<TD> Email </TD>	
		<TD COLSPAN="2"> <INPUT TYPE="TEXT" NAME="cEmail" VALUE="#TenantInfo.cEmail#" SIZE="40" MAXLENGTH="70" onKeyDown="backspace(this);"> </TD>
		<TD></TD>	
	</TR>
	
	<TR>
		<TD> Comments: </TD>
		<TD COLSPAN="3"><TEXTAREA COLS="50" ROWS="3" NAME="cComments" VALUE="#TenantInfo.cComments#" onKeyDown="backspace(this);"></TEXTAREA></TD>
	</TR>
</CFOUTPUT>

	<TR>		
		<TD STYLE="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save"></TD>
		<TD COLSPAN=2></TD>
		<TD><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="location.href='../MainMenu.cfm'"></TD>
	</TR>
	<TR> <TD COLSPAN="4" style="font-weight: bold; color: red;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </TD> </TR>
</TABLE>

</FORM>

<CFINCLUDE TEMPLATE="../../footer.cfm">