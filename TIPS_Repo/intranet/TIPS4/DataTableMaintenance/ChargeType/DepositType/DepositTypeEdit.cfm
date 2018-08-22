


<!--- ==============================================================================
Check to see if url.insert is given signifying that we are adding a region.
Thus, calling RegionInsert.cfm instead of RegionAction.cfm
=============================================================================== --->
<CFIF IsDefined("Url.Insert")>
	<CFSET Variables.Action = "DepositTypeInsert.cfm">
<CFELSE>
	<CFSET Variables.Action = "DepositTypeUpdate.cfm">
</CFIF>

<!--- ==============================================================================
Retrieve information about the chosen Deposit Type
=============================================================================== --->
<CFQUERY NAME = "DepositTypeTable"	DATASOURCE = "#APPLICATION.datasource#">
	SELECT	DT.*, 
			CT.iChargeType_ID, CT.cDescription as ChargeDescription
	FROM	DEPOSITTYPE	DT
	LEFT JOIN	ChargeType CT	ON	DT.iChargeType_ID = CT.iChargeType_ID
	<CFIF IsDefined("url.Insert")>
		WHERE	iDepositType_ID = 0
	<CFELSE>
		WHERE	iDepositType_ID = #url.typeID#
	</CFIF>
</CFQUERY>

<!--- ==============================================================================
Retrieve all Avaiable Charge Types
=============================================================================== --->
<CFQUERY NAME = "ChargeTypes" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	ChargeType
	WHERE	dtRowDeleted IS NULL
</CFQUERY>

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>	
	
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
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
</SCRIPT>

<!--- ==============================================================================
Include Shared JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../Shared/JavaScript/ResrictInput.cfm">

<!--- =============================================================================================
Include the intranet header
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../header.cfm">
<H1	CLASS = "PAGETITLE">Deposit Type Administration</H1>
<HR>

<CFOUTPUT>

<FORM ACTION = "#Variables.Action#" METHOD = "post">
<INPUT TYPE = "hidden" NAME = "iDepositType_ID" VALUE = "#DepositTypeTable.iDepositType_ID#">

<TABLE>
	<TH COLSPAN = "4">	Deposit Type Edit	</TH>
	<TR>		
		<TD> Deposit Description		</TD>
		<TD STYLE = "text-align: left;"><INPUT TYPE="text" NAME="cDescription" VALUE="#DepositTypeTable.cDescription#" onKeyUp="this.value=Description(this.value)"></TD>
		<TD> Deposit Type Set </TD>
		<TD><INPUT TYPE="text" NAME="cDepositTypeSet" VALUE="#DepositTypeTable.cDepositTypeSet#"></TD>
	</TR>
	
	
	<TR>
		<TD>Amount</TD>	
		<TD><INPUT TYPE="text" NAME="mAmount" SIZE="10" VALUE="#LSCurrencyFormat(DepositTypeTable.mAmount, "none")#" STYLE="text-align: center;"></TD>
		<TD>Charge Type</TD>
		<TD>
			<SELECT NAME = "iChargeType_ID">
				<OPTION VALUE = "#DepositTypeTable.iChargeType_ID#">	#DepositTypeTable.ChargeDescription#	</OPTION>
				<CFLOOP QUERY = "ChargeTypes">
					<OPTION VALUE = "#ChargeTypes.iChargeType_ID#">	#ChargeTypes.cDescription#	</OPTION>
				</CFLOOP>
			</SELECT>
		</TD>
	</TR>
	
	<TR>
		<TD> Display Order			</TD>
		<TD><INPUT TYPE="text" NAME="iDisplayOrder"  SIZE="10" VALUE="#DepositTypeTable.iDisplayOrder#" STYLE="text-align: center;"></TD>
		<TD> Non-Refund Fee		</TD>
		<TD STYLE = "text-align: center;">
			If yes check here ->
			<CFIF DepositTypeTable.bIsFee GTE 1>
				<INPUT TYPE = "CheckBox" NAME = "bIsFee" VALUE = "1" Checked>
			<CFELSE>
				<INPUT TYPE = "CheckBox" NAME = "bIsFee" VALUE = "1">
			</CFIF>
		</TD>
	</TR>
	<TR>
		<TD>Comments</TD>	
		<TD COLSPAN="4"><TEXTAREA COLS="50" ROWS="3" NAME="cComments">#TRIM(DepositTypeTable.cComments)#</TEXTAREA></TD>
	</TR>
</CFOUTPUT>

	<TR>
	<!--- -----------------------------------------------------------------------------------------------
		Used non-standard (not from style sheet) table properties to create asthetic look
	------------------------------------------------------------------------------------------------ --->			
		<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save"></TD>
		<TD></TD>
		<TD></TD>
		<TD><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="history.go(-1)"></TD>
	</TR>
			
	<TR><TD COLSPAN="4" style="font-weight: bold; color: red;">	<U>NOTE:</U> You must SAVE to keep information which you have entered!</TD></TR>
</TABLE>
</FORM>


<!--- =============================================================================================
Include the intranet footer
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">
