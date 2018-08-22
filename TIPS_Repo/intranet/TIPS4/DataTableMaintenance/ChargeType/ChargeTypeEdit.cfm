

<!--- ==============================================================================
SET form path according to last action (either update or insert
=============================================================================== --->
<CFIF IsDefined("url.Insert")>
	<CFSET Variables.Action = "ChargeTypeInsert.cfm">
<CFELSE>
	<CFSET Variables.Action = "ChargeTypeUpdate.cfm">
</CFIF>


<CFIF SESSION.UserID IS 3025>
	<CFOUTPUT>#Variables.Action#</CFOUTPUT>
</CFIF>

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>	
	function redirect() {
		window.location = "ChargeType.cfm";
	}
	
	function required() {
	var failed = false;
				
		if (document.ChargeTypeEdit.cDescription.value.length < 3){
		document.ChargeTypeEdit.cDescription.focus();
		(document.ChargeTypeEdit.Message.value = "Please Enter the Description (no spaces)")
		return false;
		}
	
		if (document.ChargeTypeEdit.cGLAccount.value.length < 4){
		document.ChargeTypeEdit.cGLAccount.focus();
		(document.ChargeTypeEdit.Message.value = "Please Enter the GLAccount")
		return false;
		}
	}
	
	
	function Description(string) {
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890()- "; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
</SCRIPT>


<!--- ==============================================================================
Include Shared JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../Shared/JavaScript/ResrictInput.cfm">



<!--- ==============================================================================
Retrieve the Selected Charge Type Information
=============================================================================== --->
<CFQUERY NAME = "SelectedCharge" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	ChargeType

	<CFIF IsDefined("url.ID")>
		WHERE	iChargeType_ID = #url.ID#
	<CFELSE>
		WHERE	iChargeType_ID = 0
	</CFIF>

</CFQUERY>

<CFIF SelectedCharge.bIsOpsControlled NEQ "">
	<CFSET CheckboxbIsOpsControlled = "Checked">
<CFELSE>
	<CFSET CheckboxbIsOpsControlled = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsPrePay NEQ "">
	<CFSET CheckboxbIsPrePay = "Checked">
<CFELSE>
	<CFSET CheckboxbIsPrePay = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsModifiableDescription NEQ "">
	<CFSET CheckboxbIsModifiableDescription = "Checked">
<CFELSE>
	<CFSET CheckboxbIsModifiableDescription = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsModifiableAmount NEQ "">
	<CFSET CheckboxbIsModifiableAmount = "Checked">
<CFELSE>
	<CFSET CheckboxbIsModifiableAmount = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsModifiableQty NEQ "">
	<CFSET CheckboxbIsModifiableQty = "Checked">
<CFELSE>
	<CFSET CheckboxbIsModifiableQty = "unChecked">
</CFIF>


<CFIF SelectedCharge.bOccupancyPosition NEQ "">
	<CFSET CheckboxbOccupancyPosition = "Checked">
<CFELSE>
	<CFSET CheckboxbOccupancyPosition = "unChecked">
</CFIF>


<CFIF SelectedCharge.bResidencyType_ID NEQ "">
	<CFSET CheckboxbResidencyType_ID = "Checked">
<CFELSE>
	<CFSET CheckboxbResidencyType_ID = "unChecked">
</CFIF>

<CFIF SelectedCharge.biHouse_ID NEQ "">
	<CFSET CheckboxbiHouse_ID = "Checked">
<CFELSE>
	<CFSET CheckboxbiHouse_ID = "unChecked">
</CFIF>

<CFIF SelectedCharge.bAptType_ID NEQ "">
	<CFSET CheckboxbAptType_ID = "Checked">
<CFELSE>
	<CFSET CheckboxbAptType_ID = "unChecked">
</CFIF>

<CFIF SelectedCharge.bSLevelType_ID NEQ "">
	<CFSET CheckboxbSLevelType_ID = "Checked">
<CFELSE>
	<CFSET CheckboxbSLevelType_ID = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsRent GT	0>
	<CFSET CheckboxbIsRent = "Checked">
<CFELSE>
	<CFSET CheckboxbIsRent = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsMedicaid GT	0>
	<CFSET CheckboxbIsMedicaid = "Checked">
<CFELSE>
	<CFSET CheckboxbIsMedicaid = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsDaily 	GT	0>
	<CFSET CheckboxbIsDaily = "Checked">
<CFELSE>
	<CFSET CheckboxbIsDaily = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsDiscount 	GT	0>
	<CFSET CheckboxbIsDiscount = "Checked">
<CFELSE>
	<CFSET CheckboxbIsDiscount = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsRentAdjustment 	GT	0>
	<CFSET CheckboxbIsRentAdjustment = "Checked">
<CFELSE>
	<CFSET CheckboxbIsRentAdjustment = "unChecked">
</CFIF>

<CFIF SelectedCharge.bAcctOnly GT 0>
	<CFSET CheckboxbAcctOnly = "Checked">
<CFELSE>
	<CFSET CheckboxbAcctOnly = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsDeposit GT 0>
	<CFSET CheckboxbIsDeposit = "Checked">
<CFELSE>
	<CFSET CheckboxbIsDeposit = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsRefundable GT 0>
	<CFSET CheckboxbIsRefundable = "Checked">
<CFELSE>
	<CFSET CheckboxbIsRefundable = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsRecurring GT 0>
	<CFSET CheckboxbIsRecurring = "Checked">
<CFELSE>
	<CFSET CheckboxbIsRecurring = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsMoveIn GT 0>
	<CFSET CheckboxbIsMoveIn = "Checked">
<CFELSE>
	<CFSET CheckboxbIsMoveIn = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsCharges GT 0>
	<CFSET CheckboxbIsCharges = "Checked">
<CFELSE>
	<CFSET CheckboxbIsCharges = "unChecked">
</CFIF>

<CFIF SelectedCharge.bIsMoveOut GT 0>
	<CFSET CheckboxbIsMoveOut = "Checked">
<CFELSE>
	<CFSET CheckboxbIsMoveOut = "unChecked">
</CFIF>

<CFINCLUDE TEMPLATE="../../../header.cfm">


<CFOUTPUT>
<FORM NAME = "ChargeTypeEdit" ACTION = "#Variables.Action#" METHOD = "POST" onSubmit = "return required();">
<INPUT NAME = "Message" TYPE = "TEXT" VALUE="Required are listed in red." SIZE = "75" STYLE = "Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
<INPUT TYPE = "Hidden" NAME = "iChargeType_ID" VALUE = "#SelectedCharge.iChargeType_ID#">

<TABLE>
	<TH COLSPAN="6"> Charge Type Administration	</TH>
	<TR>
		<TD CLASS="required">	Description	</TD>
		<TD> <INPUT TYPE="TEXT" NAME="cDescription" SIZE="#LEN(SelectedCharge.cDescription)#" VALUE="#SelectedCharge.cDescription#" MAXLENGTH="35" onBlur="this.value=Description(this.value);"> </TD>
		<TD CLASS="required" > GL Account	</TD>
		<TD STYLE="text-align: center;"><INPUT TYPE="TEXT" NAME="cGLAccount" SIZE="#LEN(SelectedCharge.cGLAccount)#" VALUE="#SelectedCharge.cGLAccount#" onBlur="required();"></TD>
	</TR>
	<TR>
		<TD> Controled by OPS? </TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsOpsControlled" VALUE="1" #CheckboxbIsOpsControlled#>
		</TD>
		
		<TD>	Is this a Prepaid Charge?	</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsPrePay" VALUE = "1" #CheckboxbIsPrePay#>
		</TD>
	</TR>
	
	<TR>
		<TD NOWRAP>	Is this Description Modifiable?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsModifiableDescription" VALUE = "1" #CheckboxbIsModifiableDescription#>
		</TD>
		
		<TD>	Is the Amount Modifiable?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsModifiableAmount" VALUE = "1" #CheckboxbIsModifiableAmount#>
		</TD>
	</TR>

	
	<TR>
		<TD>	Is this Quantity Modifiable?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsModifiableQty" VALUE = "1" #CheckboxbIsModifiableQty#>
		</TD>
		
		<TD NOWRAP>	Is the Occupancy Position of Concern?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bOccupancyPosition" VALUE = "1" #CheckboxbOccupancyPosition#>
		</TD>
	</TR>

	
	
	<TR>
		<TD>	Is Residency Required?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bResidencyType_ID" VALUE = "1" #CheckboxbResidencyType_ID#>
		</TD>
		
		<TD NOWRAP>	Does this Require a House Number?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "biHouse_ID" VALUE = "1" #CheckboxbiHouse_ID#>
		</TD>
	</TR>
	
	<TR>
		<TD>	Is AptType of Concern?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bAptType_ID" VALUE = "1" #CheckboxbAptType_ID#>
		</TD>
		
		<TD>	Is this Dependent upon Service Level?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bSLevelType_ID" VALUE = "1" #CheckboxbSLevelType_ID#>
		</TD>
	</TR>
	
	<TR>
		<TD>	Is this a Rent Charge?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsRent" VALUE = "1" #CheckboxbIsRent#>
		</TD>
		
		<TD>	Is this a Medicaid Charge?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsMedicaid" VALUE = "1" #CheckboxbIsMedicaid#>
		</TD>
	</TR>
	
	<TR>
		<TD>	Is this a Daily Charge?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsDaily" VALUE = "1" #CheckboxbIsDaily#>
		</TD>
		
		<TD>	Is this a Discount?	</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE = "Checkbox" NAME = "bIsDiscount" VALUE = "1" #CheckboxbIsDiscount#>
		</TD>
	</TR>

	<TR>
		<TD>	Is this a Rent Adjustment?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsRentAdjustment" VALUE="1" #CheckboxbIsRentAdjustment#>
		</TD>
		<TD>	Is this a Deposit?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsDeposit" VALUE="1" #CheckboxbIsDeposit#>
		</TD>
	</TR>
	
	<TR>
		<TD STYLE="background: gainsboro; font-weight: bold;"> Assign to Accounting Only: </TD>
		<TD STYLE = "text-align: center; background: gainsboro;">
			<INPUT TYPE="Checkbox" NAME="bAcctOnly" VALUE="1" #CheckboxbAcctOnly#>
		</TD>
		<TD>	Is this a Refundable Deposit?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsRefundable" VALUE="1" #CheckboxbIsRefundable#>
		</TD>		
	</TR>
	
	<TR>
		<TD>	Display on the Recurring Charges/Credit Page?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsRecurring" VALUE="1" #CheckboxbIsRecurring#>
		</TD>
		<TD>	Display on the Move-In Page?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsMoveIn" VALUE="1" #CheckboxbIsMoveIn#>
		</TD>
	</TR>
	
	<TR>
		<TD>	Display on the Charges/Credit Page?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsCharges" VALUE="1" #CheckboxbIsCharges#>
		</TD>
		<TD>	Display on the Move-Out Page?		</TD>
		<TD STYLE = "text-align: center;">
			<INPUT TYPE="Checkbox" NAME="bIsMoveOut" VALUE="1" #CheckboxbIsMoveOut#>
		</TD>
	</TR>
	
	<TR>		
		<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save"></TD>
		<TD></TD>
		<TD></TD>
		<TD><INPUT CLASS="DontSaveButton"	TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="redirect()"></TD>
	</TR>
	<TR><TD COLSPAN="4" style="font-weight: bold; color: red; bordercolor: linen;">	<U>NOTE:</U> You must SAVE to keep information which you have entered! </TD></TR>
</TABLE>
</FORM>
</CFOUTPUT>

<CFINCLUDE TEMPLATE="../../../footer.cfm">