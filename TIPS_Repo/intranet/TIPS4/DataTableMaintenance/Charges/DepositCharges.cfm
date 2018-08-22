<!--- *******************************************************************************
Name:			DepositCharges.cfm
Process:		Create/Add/Edit House Specific Deposits

Called by: 		Admin/Menu.cfm
Calls/Submits:	.Admin/Menu.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            05/31/2002      Original Authorship
******************************************************************************** --->

<CFOUTPUT>

<!--- ==============================================================================
Determine if there are any house specific deposits
=============================================================================== --->
<CFQUERY NAME='qHouseCount' DATASOURCE='#APPLICATION.datasource#'>
	SELECT	iCharge_ID
	FROM	Charges C
	JOIN	ChargeType CT ON (C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
	WHERE	C.dtRowDeleted IS NULL
	AND		CT.bIsDeposit IS NOT NULL
	AND 	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>
<CFIF qHouseCount.RecordCount GT 0><CFSET General=0><CFELSE><CFSET General=1></CFIF>

<!--- ==============================================================================
Retrieve all applicable charge types
=============================================================================== --->
<CFQUERY NAME='qChargeTypes' DATASOURCE='#APPLICATION.datasource#'>
	SELECT	*
	FROM	ChargeType
	WHERE	dtRowDeleted IS NULL
	AND		bIsDeposit IS NOT NULL
	ORDER BY cDescription
</CFQUERY>

<!--- ==============================================================================
Create array lists for types and glaccounts
=============================================================================== --->
<CFSET TypeList = ValueList(qChargeTypes.iChargeType_ID)>
<CFSET GLList = ValueList(qChargeTypes.cGLAccount)>

<!--- ==============================================================================
Retrieve all House Specific Deposits
=============================================================================== --->
<CFQUERY NAME='qDepositCharges' DATASOURCE='#APPLICATION.datasource#'>
	SELECT	*, C.cDescription as cDescription
	FROM	Charges C
	JOIN	ChargeType CT ON (C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
	WHERE	C.dtRowDeleted IS NULL
	AND		CT.bIsDeposit IS NOT NULL
	AND 	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>

<!--- ==============================================================================
Set the Page description header messages
=============================================================================== --->
<CFIF IsDefined("url.iCharge_ID")>
	<CFSET SetType='Edit House Specific Deposits'>
<CFELSE>
	<CFSET SetType='#SESSION.HouseName# Specific Deposits'>
</CFIF>

<!--- ==============================================================================
If there are not any house specific deposits retrieve the general deposits
=============================================================================== --->
<CFIF qDepositCharges.RecordCount EQ 0 AND NOT IsDefined("form.Specific")>
	<CFQUERY NAME='qDepositCharges' DATASOURCE='#APPLICATION.datasource#'>
		SELECT	*
		FROM	Charges C
		JOIN	ChargeType CT ON (C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		WHERE	C.dtRowDeleted IS NULL
		AND		CT.bIsDeposit IS NOT NULL
		AND 	iHouse_ID IS NULL
	</CFQUERY>
	
	<!--- ==============================================================================
	Set Header type message
	=============================================================================== --->	
	<CFSET SetType='General Deposits'>
</CFIF>

<!--- ==============================================================================
If the chargetype has been submited via a form retrieve its attributes
=============================================================================== --->
<CFIF IsDefined("form.iChargeType_ID")>
	<CFQUERY NAME="qSelectedChargeType" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	ChargeType
		WHERE	iChargeType_ID = #form.iChargeType_ID#
	</CFQUERY>
	<CFSET cGLAccount = qSelectedChargeType.cGLAccount>
</CFIF>

<!--- ==============================================================================
If a specific deposit charge has been selected set local variables for its attributes
otherwise set them to NULL ("")
=============================================================================== --->
<CFIF IsDefined("url.iCharge_ID")>
	<CFQUERY NAME="qSelectedCharge" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*, C.cDescription as cDescription
		FROM	Charges C
		JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		WHERE	C.dtRowDeleted IS NULL
		AND		C.iCharge_ID = #url.iCharge_ID#
	</CFQUERY>
	<CFSET form.iChargeType_ID = qSelectedCharge.iChargeType_ID>
	<CFSET cGLAccount = qSelectedCharge.cGLAccount>
	<CFSET cDescription = qSelectedCharge.cDescription>
	<CFSET mAmount = qSelectedCharge.mAmount>
	<CFSET iQuantity = qSelectedCharge.iQuantity>
<CFELSE>
	<CFSET cDescription = ''>
	<CFSET mAmount = ''>
	<CFSET iQuantity = 1>
</CFIF>

<!--- ==============================================================================
Include Intranet Header files
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<!--- ==============================================================================
Include Application Javascript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../Shared/JavaScript/ResrictInput.cfm">
<BR><BR>

<!--- ==============================================================================
Link to return to the Administration page
=============================================================================== --->
<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 18;">Click Here to go back to Administration menu.</A>
<BR><BR>

<FORM ACTION="DepositCharges.cfm" METHOD="POST">

<!--- ==============================================================================
If url icharge_Id has been passed set to a hidden variable to be passed via form
=============================================================================== --->
<CFIF IsDefined("url.iCharge_ID")><INPUT TYPE="hidden" NAME="iCharge_ID" VALUE="#url.iCharge_ID#"></CFIF>

<!--- ==============================================================================
Show or appropriate button depending on if we are adding or viewing house specific deposits
=============================================================================== --->
<CFIF NOT IsDefined("form.Specific")>
	<INPUT TYPE="submit" NAME="Specific" STYLE="width: 200;" VALUE="Create House Specific Deposits"><BR><BR>
<CFELSE>
	<B STYLE="font-size: 18;">Add House Specific Deposits</B><BR><BR>
</CFIF>

<!--- ==============================================================================
Show header message
=============================================================================== --->
<B STYLE="font-size: 18;">#SetType#</B> <BR>

<!--- ==============================================================================
Show edit/add charge section if a charge type has been chose or a specific charge
has been selected
=============================================================================== --->
<CFIF IsDefined("form.Specific") OR IsDefined("url.iCharge_ID")>
<INPUT TYPE="hidden" NAME="Specific" VALUE="1">
<TABLE>
	<TR>
		<TH COLSPAN=100% STYLE="text-align: left;">
			Deposit Type 
			<SELECT NAME='iChargeType_ID'>
				<CFLOOP QUERY='qChargeTypes'>
					<CFIF IsDefined("form.iChargeType_ID") AND form.iChargeType_ID EQ qChargeTypes.iChargeType_ID> <CFSET Selected='SELECTED'> <CFELSE> <CFSET Selected=''> </CFIF>
					<CFIF qChargeTypes.bIsRefundable GT 0><CFSET Refundable='(Refundable)'><CFELSE><CFSET Refundable=''></CFIF>
					<OPTION VALUE='#qChargeTypes.iChargeType_ID#' #SELECTED#>#qChargeTypes.cDescription# #Refundable#</OPTION>
				</CFLOOP>
			</SELECT>
			<INPUT TYPE="submit" Name="ChargeType" VALUE="GO">
		</TH>
	</TR>
	<CFIF IsDefined("form.iChargeType_ID") OR IsDefined("url.iCharge_ID")> 
		<TR><TD>GLAccount (#Variables.cGLAccount#)</TD><TD>cDescription <INPUT TYPE='text' NAME='cDescription' SIZE=25 MAXLENGHT=35 VALUE='#Variables.cDescription#'></TD><TD>Quantity <INPUT STYLE='text-align: center;' TYPE='text' NAME='iquantity' SIZE=3 MAXLENGHT=3 VALUE='#Variables.iQuantity#' onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=round(this.value);"></TD><TD>Amount <INPUT TYPE='text' NAME='mamount' SIZE=6 MAXLENGHT=6 VALUE='#NumberFormat(Variables.mAmount,"-9999999.99")#' onKeyDown="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));"></TD></TR>
		<TR>
			<CFIF IsDefined("url.iCharge_ID")><CFSET Action="document.forms[0].action='AddDeposit.cfm?Edit=1'; submit();"><CFELSE><CFSET Action="document.forms[0].action='AddDeposit.cfm'; submit();"></CFIF>
			<TD STYLE="text-align: center;"><INPUT TYPE='button' NAME='SAVE' VALUE='Save' onClick="#Action#"></TD>
			<TD></TD><TD></TD>
			<TD STYLE="text-align: center;"><INPUT TYPE='button' NAME='Cancel' VALUE='Cancel' onClick="location.href='DepositCharges.cfm'"></TD></TR>
	</CFIF>
</TABLE><BR>
</CFIF>


<!--- ==============================================================================
Table to show data for either the house specific or general deposits
dependant upon data
=============================================================================== --->
<TABLE>
	<TR><TH NOWRAP>GLAccount</TH><TH>Description</TH><TH>Quantity</TH><TH>Amount</TH><CFIF General EQ 0><TH>Delete</TH></CFIF></TR>
	<CFIF qDepositCharges.RecordCount GT 0>
		<CFLOOP QUERY="qDepositCharges">
			<TR>
				<TD STYLE="text-align: center;">#qDepositCharges.cGLAccount#</TD>
				<TD><CFIF qDepositCharges.iHouse_ID EQ "">#qDepositCharges.cDescription#<CFELSE><A HREF="DepositCharges.cfm?iCharge_ID=#qDepositCharges.iCharge_ID#">#qDepositCharges.cDescription#</A></CFIF></TD>
				<TD STYLE="text-align: center;">#qDepositCharges.iQuantity#</TD>
				<TD STYLE="text-align: right;">#LSCurrencyFormat(qDepositCharges.mAmount)#</TD>
				<CFIF General EQ 0><TD STYLE="text-align: center;"><INPUT CLASS=BlendedButton TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="location.href='deletedeposit.cfm?iCharge_ID=#qDepositCharges.iCharge_ID#'"></TD></CFIF>
			</TR>
		</CFLOOP>
	<CFELSE>
		<TR><TD COLSPAN=4>There are no house specific deposits for this house at his time.</TD></TR>
	</CFIF>
</TABLE>
<BR>

<!--- ==============================================================================
Link to return to the Administration page
=============================================================================== --->
<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 18;">Click Here to go back to Administration menu.</A>
</FORM>

<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">

</CFOUTPUT>