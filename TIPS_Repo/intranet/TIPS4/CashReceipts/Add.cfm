<!--- *********************************************************************************************
Name:       Add.cfm
Type:       Template
Purpose:    Set SESSION variables and display the main menu.


Called by: CashReciepts.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
	None

Calls: Tenant/Add.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None


Calls: Tenant/Edit.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.SelectedTenant_ID               Tenant.aTenant_ID value of the tenant the user selected.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
Paul Buendia            15 Apr 01       Original Authorship
********************************************************************************************** --->


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">



<!--- =============================================================================================
Include Javascript code for only allowing:
Numbers	:	USE onKeyUp = "this.value=Numbers(this.value)"
Letters:	USE onKeyUp = "this.value=Letters(this.value)"
============================================================================================= --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">


<SCRIPT>	
	function redirect() {
		window.location = "CashReceipts.cfm";
	}
</SCRIPT>


<!--- *********************************************************************************************
HTML head.
********************************************************************************************** --->

    <TITLE> Tips 4  - Enter Cash Receipts </TITLE>



<BODY>


<!--- =============================================================================================
Display the page header.
============================================================================================== --->

<H1  CLASS = "PageTitle">
Tips 4 - Enter Cash Receipts
</H1>


<CFINCLUDE TEMPLATE = "../SHARED/HOUSEHEADER.CFM">

<HR>
<BR>


<FORM ACTION = "../MainMenu.cfm" METHOD = "POST">
<CFOUTPUT>
	<TABLE>	
		<TR> 
			<TD COLSPAN = "2" Class = "Detail" STYLE = "text-align: left;">	
				<U>Add New Cash Receipt:</U>	
			</TD>	
		</TR>
		
		<TR>
			<TH>	Tenant							</TH>
			<TH>	Check Number					</TH>
			<TH>	Check Date						</TH>
			<TH>	Amount							</TH>
		</TR>
		
		<TR STYLE = "Text-align: center;">
			<TD>
				<SELECT NAME = "iTenant_ID">
					<OPTION>	Tenants		</OPTION>
				</SELECT>
			</TD>
		
			<TD>
				<INPUT TYPE = "text" NAME = "CheckNumber"	VALUE = "" SIZE = "6" onKeyUp = "this.value=Numbers(this.value);">
			</TD>
			
		
			<TD>	
				<INPUT TYPE = "TEXT" NAME = "Month" VALUE = "#DATEFORMAT(NOW(), "mm")#" 	SIZE = "2" MAXLENGTH = "2" onKeyUp = "this.value=Numbers(this.value); MonthTest(this);">	/&nbsp;
				<INPUT TYPE = "TEXT" NAME = "Day" 	VALUE = "#DATEFORMAT(NOW(), "dd")#" 	SIZE = "2" MAXLENGTH = "2" onKeyUp = "this.value=Numbers(this.value); DayTest(this);"> /&nbsp;
				<INPUT TYPE = "TEXT" NAME = "Year" 	VALUE = "#DATEFORMAT(NOW(), "yyyy")#" 	SIZE = "4" MAXLENGTH = "4" onKeyUp = "this.value=Numbers(this.value);" onBlur = "YearTest(this);">
			</TD>
			
			<TD>
				<INPUT TYPE = "TEXT"	NAME = "CashRecAmt" SIZE = "12" VALUE = "0" MAXLENGTH = "12" STYLE = "Text-align: center;" onKeyUp = "this.value=Numbers(this.value);">
			</TD>
		</TR>
		
			
		<TR>
			<TD COLSPAN="3"	STYLE="background: linen; text-align: left;"><INPUT CLASS="SaveButton"	TYPE="SUBMIT" NAME="Save" VALUE="Save"></TD>
			<TD STYLE="background: linen; text-align: right;"> <INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="redirect()"> </TD>
		</TR>
	
	</TABLE>
</CFOUTPUT>

</FORM>

<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">