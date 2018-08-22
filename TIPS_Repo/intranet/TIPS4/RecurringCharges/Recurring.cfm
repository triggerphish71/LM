<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
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
| ranklam    | 10/28/2005 | Added Flowerbox                                                    |
| ranklam    | 10/28/2005 | Renamed GUM link to #server_name#                                  |
| fzahir     | 11/22/2005 | Only TIPS AR people should be able to edit Amount field            |
| mlaw       | 12/29/2005 | include house's cchargeset into the chargelist box                 |
| mlaw       | 03/02/2006 | Remove hidden mAmount value to pass the calling program            |
| mlaw       | 03/08/2006 | Remedy Call 32362 - User should allow to change all charges except |
|            |            | ChargeType - R&B rate, R&B discount                                |
|rschuette	 | 07/18/2008 | Restricted negative value input on Amount based on usergroup       |
|sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |s
|sfarmer     | 06/09/2012 | 92628 - alow only AR to edit NRF/Deferred entries                  |
|mstriegel   | 12/15/2017 | Added logic for penny off issue. Added WITH (NOLOCK), Removed dumps|
|mstriegel   | 01/12/2018 | Added logic to remove the "Delete" button for Community fee charges|
|							Also added with nolock and formatted the whole page                             |
|hlim       | 0816/2018 | Added CFC                                                             |
----------------------------------------------------------------------------------------------->
<cfif NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ''>
  <cflocation URL="http://#server_name#" ADDTOKEN="No">
  <cfabort>
</cfif>


<cfset oRecurringCharges = CreateObject("component","intranet.TIPS4.CFC.Components.RecurringCharges.Recurring")>


<!--- start: queries --->
<cfset getHouseChargeset = oRecurringCharges.getHouseChargeset(iHouse_ID=#session.qSelectedHouse.iHouse_ID#)>
<cfset qryRegion = oRecurringCharges.qryRegion(iHouse_ID=#session.qSelectedHouse.iHouse_ID#)>
<cfif IsDefined("form.iTenant_ID")>
  <cfset TenantList = oRecurringCharges.TenantList(iTenant_ID=#form.iTenant_ID#)>
<cfelse>
  <cfset TenantList = oRecurringCharges.TenantList(iTenant_ID=0)>
</cfif>
<!--- end: queries --->


<cfset monthtouse = "07/2018">
<cfset newmonth = #DateAdd('m', 1, monthtouse)#>


<cfoutput>
<cfloop condition="#DateFormat(newmonth, 'MM/YYYY')# LT #DateFormat(SESSION.TipsMonth, 'MM/YYYY')#">
  <!---#DateFormat(newMonth,"mm/dd/yyyy")#<br>--->
<cfset newmonth = #DateAdd('m', 1, newmonth)#>
</cfloop>
</cfoutput>


<!--- Include Share JavaScript  --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<script>
  function test() {
    if(document.getElementById("CoTenantFN")) {
      var a= document.getElementById("CoTenantFN").value;
      var b= document.getElementById("CoTenantLN").value;
      var c= document.getElementById("CoTenantOP").value;
      var d= document.getElementById("CoTenantCOP").value;
      if (c!==d && d!==''){
        alert ('Making this change will result in two residents are Second/Primary in the same room, please adjust');
        return false;
      }
    }
  }

function pad(n) {
  return (n < 10) ? ("0" + n) : n;
}

function effectivecheck() {

  var MonthStart = (document.Recurring.MonthStart.value - 1);
	var MonthEnd = (document.Recurring.MonthEnd.value - 1);
	var	start = new Date(document.Recurring.YearStart.value, MonthStart, document.Recurring.DayStart.value);
	var	end = new Date(document.Recurring.YearEnd.value, MonthEnd, document.Recurring.DayEnd.value);

  var newstart = document.Recurring.YearStart.value+''+pad(document.Recurring.MonthStart.value)+''+pad(document.Recurring.DayStart.value);
  var	ClosingDate = '<cfoutput>#DateFormat(SESSION.TIPSMonth,'yyyy')##DateFormat(SESSION.TIPSMonth,'mm')##DateFormat(SESSION.TIPSMonth,'dd')#</cfoutput>';

  if(newstart>ClosingDate) {
    if(confirm('You\'re entering a future Effective Beginning date. Do you want to continue?')) {
      //no nothing
    } else {
      return false;
    }
  }

  if (start > end) {
    (document.Recurring.Message.value = 'The start date may not be later than the end date');
    return false;
  } else {
    (document.Recurring.Message.value = ''); return;
  }
}
</script>



<script language="javascript">
	function numbers(e)
  {	  //  Robert Schuette project 23853  - 7-18-08
  	 // removes House ability to enter negative values for the Amount textbox,
  	//  only AR will enter in negative values.  Added extra: only numeric values.

     //alert('Javascript is hit for test.')
  	keyEntry = window.event.keyCode;
  	if((keyEntry < '46') || (keyEntry > '57') || (keyEntry == '47')) {return false;  }
  }
</script>

<CFSCRIPT>
	if (IsDefined("form.iTenant_ID") AND IsDefined("form.iCharge_ID")) { ACTION="RecurringADD.cfm"; }
	else if (IsDefined("url.typeID")) { ACTION="RecurringUpdate.cfm"; }
	else { ACTION="Recurring.cfm"; }

	if (IsDefined("url.ID")){ form.iTenant_ID=URL.ID; }
	if (IsDefined("url.typeID")){ form.iCharge_ID=URL.typeID; }
	if (SESSION.UserID IS 3025){ writeOutPut('#Variables.Action#<BR>'); }
</CFSCRIPT>






<!--- ==============================================================================
Retreive all charges for Recurring purposes.
=============================================================================== --->
<!--- MLAW 12/29/2005 include House's cchargeset --->
<cfif NOT IsDefined("url.TypeID")>
  <cfset newTypeID = 0>
<cfelse>
  <cfset newTypeID = url.TypeID>
</cfif>
<cfif IsDefined("form.iCharge_ID")>
  <cfset newiCharge_ID = form.iCharge_ID>
<cfelse>
  <cfset newiCharge_ID = 0>
</cfif>
<cfif ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0 AND ((IsDefined("SESSION.accessrights") AND SESSION.accessrights NEQ 'iDirectorUser_ID') OR NOT isDefined("SESSION.accessrights"))>
  <cfset accessrights = 1>
<cfelseif (IsDefined("SESSION.accessrights") AND SESSION.accessrights EQ 'iDirectorUser_ID')>
  <cfset accessrights = 2>
<cfelse>
  <cfset accessrights = 3>
</cfif>
<cfif ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0>
  <cfset CodeBlock = 1>
<cfelse>
  <cfset CodeBlock = 2>
</cfif>
<cfset ChargeList = oRecurringCharges.ChargeList(TypeID=#newTypeID#,iCharge_ID=#newiCharge_ID#,CName=#getHouseChargeset.CName#,accessrights=#accessrights#,CodeBlock=#CodeBlock#)>

<CFQUERY NAME='qChargeTypes' DBTYPE='QUERY'>
	SELECT	distinct typedescription, iChargeType_ID
	FROM ChargeList
	Order by typedescription
</CFQUERY>

<!--- mstriegel 01/12/2018  call a function to get the charge type ids assoicatied with any community fee --->
<cfset qCommunityFeeChargeTypeID = session.oChargeServices.getChargeTypeID(wherecondition="community")>
<cfset communityFeeChargeTypeIDList = ValueList(qCommunityFeeChargeTypeID.iChargeType_ID)>
<!---- end mstriegel 01/12/2018 --->

<!--- mstriegel 12/15/2017 added ROUND function on the mAmount --->
<cfset CurrentRecurring = oRecurringCharges.CurrentRecurring()>
<!---Mshah added query to find missing recurringcharge for private resident --->
<cfset FindMissingRecurring = oRecurringCharges.FindMissingRecurring()>
<!---Mshah added this query to see if there are two primary or two secondary in any room--->
<cfset Findincorrectrate = oRecurringCharges.Findincorrectrate()>


<cfinclude template="../Shared/Queries/HouseDetail.cfm">
<!--- include ALC Header --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- HTML head --->
<TITLE> Tips 4  - Recurring Charges/Credits </TITLE>
<BODY>

<!--- Display the page header --->
<H1 CLASS="PageTitle"> Tips 4 - Recurring Charges/Credits </H1>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">


<CFOUTPUT>
<SCRIPT>
	clist="<SELECT NAME='iCharge_ID' onChange='submit()'>";
	clist+="<OPTION VALUE=0> None </OPTION>";
	<CFLOOP QUERY="ChargeList">clist+="<OPTION Value='#ChargeList.iCharge_ID#'> #ChargeList.cDescription# <CFIF ChargeList.bIsRent NEQ ''> #LSCurrencyFormat(ChargeList.mAmount)#</CFIF> <CFIF ChargeList.bIsDaily NEQ ''> (Daily) </CFIF></OPTION>"; </CFLOOP>
	clist+="</SELECT>";
	function showtypes(obj){
		if (obj.value !== ''){ document.all['chargetype'].style.display='inline'; document.all['chargetype'].innerHTML=clist; }
		else { document.all['chargetype'].style.display='none'; document.all['chargetype'].innerHTML=''; }
	}
</SCRIPT>
<!---Mshah added this to show missing recurringcharge in house for private resident--->
<cfif #FindMissingRecurring.recordcount# GT 0>
  <table>
	 <tr>
	 	<td style="font-weight: bold;color:red;">
		  Missing/Expired BSF Recurring Charge for Resident-
		 </td>
	 </tr>
	<cfloop query="FindMissingRecurring">
	 <tr style="font-weight: bold;color:red;">
	 <td>#FindMissingRecurring.Residentname# (#FindMissingRecurring.csolomonkey#) </td>
	 </tr>
	</cfloop>
	</table>
</cfif>
<cfif #Findincorrectrate.recordcount# GT 0>
<table>
	 <tr>
	 	<td style="font-weight: bold;color:red;">
		  Please correct Recurring Charge for below residents. These are either both Primary or Second resident in same Apt or only Second Resident.
		 </td>
	 </tr>
	<cfloop query="Findincorrectrate">
	 <tr style="font-weight: bold;color:red;">
	 <td>#Findincorrectrate.Residentname# (#Findincorrectrate.csolomonkey#) </td>
	 </tr>
	</cfloop>
	</table>
</cfif>


<FORM NAME="Recurring" ACTION = "#Variables.Action#" METHOD = "POST" onSubmit="return effectivecheck();">
	<INPUT NAME = "Message" TYPE = "TEXT" VALUE="" SIZE="77" STYLE = "Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
	<CFIF IsDefined("URL.typeID")> <INPUT TYPE="Hidden" NAME="iRecurringCharge_ID" VALUE="#url.typeID#"> </CFIF>
	<TABLE>
		<CFSCRIPT>if(isDefined("url.ID") AND Url.ID NEQ ''){ Action='Edit'; } else{ Action='Add'; }</CFSCRIPT>
		<TR> <TH COLSPAN = "4"> #Action# Recurring Charges/Credits </TH> </TR>
		<TR STYLE = "font-weight: bold;">
			<TD STYLE="width: 25%;"> Name </TD>
			<TD STYLE="width: 25%;"> Charge/Credit </TD>
			<TD STYLE="width: 25%;text-align: center;"> Amount </TD>
			<TD STYLE="width: 25%; text-align: center;"> Quantity </TD>
		</TR>
		<CFIF NOT IsDefined("form.iTenant_ID")>
			<TR>
				<TD NOWRAP>
					<SELECT NAME="iTenant_ID" onChange="showtypes(this);">
						<OPTION VALUE="0"> None </OPTION>
						<CFLOOP QUERY="TenantList">
						<OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstname# </OPTION>
						</CFLOOP>
					</SELECT>
				</TD>
				<TD><SPAN ID='chargetype'></SPAN></TD>
				<TD></TD><TD></TD>
			</TR>
		</CFIF>

		<CFIF IsDefined("form.iTenant_ID") AND IsDefined("form.iCharge_ID")>
			<!---project primary/secondary--->

				<!--- Retrieve Tenant Information --->
        <cfset qTenant = oRecurringCharges.qTenant(iTenant_ID=#form.iTenant_ID#)>
        <cfset FindChargeType = oRecurringCharges.FindChargeType(iCharge_ID=#form.iCharge_ID#)>


				<!---Mshah added to find if there is any one in room--->
				<cfif ListFindNoCase("1748,1682,89,1749,31",#trim(FindChargeType.iChargeType_ID)#,",")GT 0 >
				<!---Mshah added to find if there is any one in room--->

        <cfset Findroommate = oRecurringCharges.Findroommate(iTenant_ID=#form.iTenant_ID#,iAptAddress_ID=#qTenant.iAptAddress_ID#)>


			    <!---find the charge which is being added--->
				<cfquery name="findoccupancyadded" datasource="#APPLICATION.datasource#">
					SELECT *
					FROM charges with (NOLOCK)
					WHERE icharge_ID= #form.iCharge_ID#
				</cfquery>


		    	<!---set variable for propmt--->
		    	<INPUT TYPE="Hidden" NAME="CoTenant_ID" ID="CoTenant_ID" VALUE="#Findroommate.iTenant_ID#">
		    	<INPUT TYPE="Hidden" NAME="CoTenantFN" ID="CoTenantFN" VALUE="#Findroommate.cfirstname#">
		    	<INPUT TYPE="Hidden" NAME="CoTenantLN" ID="CoTenantLN" VALUE="#Findroommate.cLastname#">
		    	<INPUT TYPE="Hidden" NAME="CoTenantRC" ID="CoTenantLN" VALUE="#Findroommate.irecurringcharge_ID#">
		    	<INPUT TYPE="Hidden" NAME="CoTenantAptID" ID="CoTenantaptID" VALUE="#Findroommate.apttype#">
		    	<cfif #Findroommate.IOCCUPANCYPOSITION# eq 1>
		    	   <INPUT TYPE="Hidden" NAME="CoTenantCOP" ID="CoTenantCOP" VALUE="Primary">
		    	<cfelseif #Findroommate.IOCCUPANCYPOSITION# eq 2>
		    	   <INPUT TYPE="Hidden" NAME="CoTenantCOP" ID="CoTenantCOP" VALUE="Second">
		    	<cfelse>
		    	   <INPUT TYPE="Hidden" NAME="CoTenantCOP" ID="CoTenantCOP" VALUE="">
		    	</cfif>
		    	<cfif #findoccupancyadded.IOCCUPANCYPOSITION# eq 1>
		    	   <INPUT TYPE="Hidden" NAME="CoTenantOP" ID="CoTenantOP" VALUE="Second">
		    	<cfelseif #findoccupancyadded.IOCCUPANCYPOSITION# eq 2 >
		    	   <INPUT TYPE="Hidden" NAME="CoTenantOP" ID="CoTenantOP" VALUE="Primary">
		    	 <cfelse>
		    	 <INPUT TYPE="Hidden" NAME="CoTenantOP" ID="CoTenantOP" VALUE="">
				 </cfif>
				</cfif>

		    	<!---Mshah end--->
				<TR>
				<TD>#TenantList.cLastName#, #TenantList.cFirstname#
				<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#TenantList.iTenant_ID#">
				</TD>
				<CFIF ChargeList.bIsModifiableDescription GT 0>
					<TD>
						<INPUT TYPE="text" NAME="cDescription" VALUE="#ChargeList.cDescription#" MAXLENGTH="15"
						 onBlur="this.value=Letters(this.value);  Upper(this);">
						<INPUT TYPE="text" NAME="iCharge_ID" VALUE="#ChargeList.iCharge_ID#">
					</TD>
				<CFELSE>
					<TD>
						#ChargeList.cDescription#
						<INPUT TYPE="text" NAME="iCharge_ID" VALUE="#ChargeList.iCharge_ID#" readonly>
						<INPUT TYPE="text" NAME="cDescription" VALUE="#ChargeList.cDescription#" readonly>
					</TD>
				</CFIF>

				<!--- MLAW 03/08/2006 Add condition for R&B rate AND R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
				<CFIF ChargeList.bIsModifiableAmount GT 0 or listfindNocase(session.codeblock,23) GTE 1 or session.userid EQ 3025 or session.userid EQ 3146 or session.userid is "3271">
				<!--- Katie taking away RDO & House access to overrule modify amount rights set by chargetype administrator: 7/6/05: (isDefined("session.AccessRights") AND session.AccessRights EQ 'iDirectorUser_ID') or listfindNocase(session.codeblock,21) GTE 1  --->
					<cfif ListContains(session.groupid,'192')>
					<TD STYLE="text-align: center;">
						<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#"
						STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);"
						onkeypress="return numbers(event)" onBlur="this.value=Money(this.value); this.value=cent(round(this.value));">
					</TD>
					<cfelse>
						<TD STYLE="text-align: center;">
							<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#"
							 STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);"
							  onkeypress="return numbers(event)" onBlur="this.value=Money(this.value); this.value=cent(round(this.value));">
						</TD>
					</cfif><!---End change. proj 23853--->

				<CFELSE>
					<td style="text-align: center;">
					<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#"
					 STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);"
					 onBlur="this.value=cent(round(this.value));" readonly >
					</td>
				</CFIF>

				<CFIF ChargeList.bIsModifiableQty GT 0>
					<TD STYLE="text-align: center;">
						<cfif (isDefined("ChargeList.iCharge_ID")
						AND (ChargeList.iChargeType_ID is 8 or ChargeList.iChargeType_ID is 1664 or ChargeList.iChargeType_ID is 1749 or ChargeList.iChargeType_ID is 1750 ))
						 AND (SESSION.qSelectedHouse.cStateCode NEQ 'OR')>
						 	<CFSCRIPT>
								if (isDefined("ChargeList.RCbIsDaily") AND ChargeList.RCbIsDaily is 1) {checked='checked'; }
								else {checked=''; }
							</CFSCRIPT>
							<input type="checkbox" name="bIsDaily" value="1" #checked#> Daily or
						</cfif>
						<input type="text" name="iQuantity" value="#ChargeList.iQuantity#" size="2" maxlength="2"
						style="text-align:center;" onBlur="this.value=Numbers(this.value);">
					</TD>
				<CFELSE>
					<TD STYLE="text-align: center;"> #ChargeList.iQuantity# <INPUT TYPE="Hidden" NAME="iQuantity"
					VALUE="#ChargeList.iQuantity#"></TD>
				</CFIF>
			</TR>
		</CFIF>

		<CFIF IsDefined("form.iTenant_ID") AND IsDefined("form.iCharge_ID")>
			<TR>
				<TD>Effective Beginning	</TD>
				<TD>
					<CFSCRIPT>
						if (ChargeList.dtEffectiveStart NEQ "") {
							MonthStart = Month(ChargeList.dtEffectiveStart);
							 DayStart = Day(ChargeList.dtEffectiveStart);
							  YearStart = Year(ChargeList.dtEffectiveStart); }
						else{ MonthStart = "#Month(now())#";
							DayStart = "#Day(Now())#";
						 	YearStart = "#Year(Now())#"; }
					</CFSCRIPT>
					<SELECT NAME="MonthStart" onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)">
						<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
						<CFIF MonthStart EQ I><CFSET sel='selected'>
						<CFELSE>
						<CFSET sel=''></CFIF>
						<OPTION VALUE="#I#" #sel#> #I# </OPTION>
						</CFLOOP>
					</SELECT>
					/
					<SELECT NAME = "DayStart" onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)">
						<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1">
						<CFIF DayStart EQ I><CFSET sel='selected'>
						<CFELSE><CFSET sel=''>
						</CFIF>
							<OPTION VALUE="#I#"#sel#> #I# </OPTION>
						</CFLOOP>
					</SELECT>
					/
					<INPUT TYPE="Text" NAME="YearStart" Value="#YearStart#" SIZE="3" MAXLENGTH=4 onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)"  onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=Numbers(this.value);">
				</TD>
				<TD> Effective End </TD>
				<TD>
					<CFSCRIPT>
						if (ChargeList.dtEffectiveEnd NEQ ""){
							MonthEnd = Month(ChargeList.dtEffectiveEnd);
							 DayEnd = Day(ChargeList.dtEffectiveEnd);
							 YearEnd = Year(ChargeList.dtEffectiveEnd); }
						else { MonthEnd = "#Month(now())#"; DayEnd = "#Day(Now())#"; YearEnd = "2010"; }
					</CFSCRIPT>
					<SELECT NAME = "MonthEnd" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
						<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
						<CFIF MonthEnd EQ I>
							<CFSET sel='selected'>
						<CFELSE>
							<CFSET sel=''>
						</CFIF>
						<OPTION VALUE="#I#"#sel#> #I# </OPTION>
						</CFLOOP>
					</SELECT>
					/
					<SELECT NAME = "DayEnd" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
						<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1">
						<CFIF DayEnd EQ I>
							<CFSET sel='selected'>
						<CFELSE>
							<CFSET sel=''>
						</CFIF>
						<OPTION VALUE="#I#"#sel#> #I# </OPTION>
						</CFLOOP>
					</SELECT>
					/
					<INPUT TYPE="Text" NAME="YearEnd" Value="#YearEnd#" SIZE="3" MAXLENGTH=4 onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=Numbers(this.value); dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd);" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
				</TD>
			</TR>
			<TR>
	        	<TD COLSPAN="4">
	            	Internal Comments: <BR>
	            	<TEXTAREA COLS="75" ROWS="2" NAME="cComments">#ChargeList.cComments#</TEXTAREA>
	            </TD>
	        </TR>
			<cfif ((ChargeList.iChargeType_ID is   "1737") or (ChargeList.iChargeType_ID is   "1740")
					  or (ChargeList.iChargeType_ID is   ""))>
				<cfif (listfindNocase(session.codeblock,25) GTE 1) OR (listfindNocase(session.codeblock,23) GTE 1)>

					<TR>
						<TD style="text-align: left;">
							<INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" onclick="return test();">
						</TD>
						<TD>&nbsp;</TD>
						<TD>&nbsp;</TD>
						<TD>
							<INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save"
							 onClick="location.href='Recurring.cfm'">
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="4" style="font-weight: bold; color: red;">
							<U>NOTE:</U> You must SAVE to keep information which you have entered!
						</TD>
					</TR>
				<cfelse>
					<TR>
						<TD COLSPAN="4" style="font-weight: bold; color: red;">
							<U>NOTE:</U> Contact AR to edit recurring charges for New Resident Fee changes AND NRF deferrals.
						</TD>
					</TR>
				</cfif>
			<cfelse>
			 	<cfif isValid("email",session.RDOEmail)>
				<TR>
					<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" onclick="return test();"></TD>
					<TD>&nbsp;</TD>
					<TD>&nbsp;</TD>
					<TD>
						<INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="location.href='Recurring.cfm'">
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="4" style="font-weight: bold; color: red;">
						<U>NOTE:</U> You must SAVE to keep information which you have entered!
					</TD>
				</TR>
		 	<tr>
				<td COLSPAN="4">
					The RDO email for this Region (#qryRegion.region#) is #session.RDOEmail#, Division is #qryRegion.division#.
				</td>
			</tr>
	  	<cfelse>
			<tr>
				<td COLSPAN="4" style=" font-size:large; color:red; text-align:center">
					No RDO or RDO email available for this region  (#qryRegion.region#), contact the Support Desk to update this information to continue. Division is #qryRegion.division#.
				</td>
			</tr>
		</cfif>
		</cfif>
		</CFIF>
	</TABLE>
</FORM>
<TABLE>
	<TR><TH COLSPAN="7" STYLE="text-align: left;">	Existing Recurring Charges/Credits:	</TH></TR>
	<TR STYLE="font-weight: bold;">
		<TD STYLE="width: 25%;" NOWRAP>Name</TD>
		<TD STYLE="width: 25%;">Charge/Credit</TD>
		<TD STYLE="text-align: center;">Amount</TD>
		<TD STYLE="text-align: center;">Quantity</TD>
		<TD>Start Date</TD>
		<TD>End Date</TD>
		<TD>Delete</TD>
	</TR>
	<TR><TD COLSPAN="7"> <HR> </TD></TR>
	<CFIF CurrentRecurring.RecordCount GT 0>
		<cfset bgcolor = "FFFFFF">
		<cfset prevname = "0">

		<CFLOOP QUERY="CurrentRecurring">
			<CFSCRIPT>
				if (CurrentRecurring.bisdaily NEQ '') { qty = 'daily'; } else { qty = CurrentRecurring.iquantity; }
			</CFSCRIPT>
			<cfset currname = "#CurrentRecurring.iTenant_ID#">
			<cfif prevname is not currname><cfif bgcolor is "EEEEEE"><cfset bgcolor="FFFFFF"><cfelse><cfset bgcolor="EEEEEE"></cfif>
			<cfelse></cfif>
			<TR>
				<TD STYLE="width: 25%;" NOWRAP bgcolor="#bgcolor#"> #CurrentRecurring.cLastName#, #CurrentRecurring.cFirstName#  </TD>
				<TD NOWRAP STYLE="width: 25%;" bgcolor="#bgcolor#">
					<A HREF="Recurring.cfm?ID=#CurrentRecurring.iTenant_ID#&typeID=#CurrentRecurring.iRecurringCharge_ID#">
					 #CurrentRecurring.cDescription#
					 </A>
				</TD>
				<cfif   CurrentRecurring.iChargeType_ID is   "1740" >
					<cfquery  name="qryInstallment" DATASOURCE="#APPLICATION.datasource#">
					SELECT sum (mamount) as Accum
					FROM invoicedetail inv  WITH (NOLOCK)
					INNER JOIN invoicemaster im WITH (NOLOCK) on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
					WHERE   inv.dtrowdeleted is null
					AND	itenant_id =  #CurrentRecurring.itenant_id#
					AND inv.ichargetype_id = 1741
					AND im.bMoveOutInvoice is null
					AND im.bFinalized = 1
				</cfquery>

				 <cfif qryInstallment.Accum is ''>
				 	<cfset thisAccum = 0>
				 <cfelse>
				 	<cfset thisAccum = qryInstallment.Accum>
				 </cfif>

				 <cfif CurrentRecurring.mAmtNRFPaid is ''>
				 	<cfset thismAmtNRFPaid = 0>
				 <cfelse>
				 	<cfset thismAmtNRFPaid = CurrentRecurring.mAmtNRFPaid>
				 </cfif>

				 <cfif CurrentRecurring.mAdjNRF is ''>
				 	<cfset thismAdjNRF = 0>
				 <cfelse>
				 	<cfset thismAdjNRF = CurrentRecurring.mAdjNRF>
				 </cfif>

				<cfset rembal =  (thismAdjNRF - thismAmtNRFPaid  - thisAccum)>
				<!--- 	<CFSET nbrpayments = datediff('m',dteffectivestart , dteffectiveend)>
					<cfset nbrpaymentsmade = abs(datediff('m',dteffectivestart ,HouseInfo.dtCurrentTipsMonth)) + 1>
					<cfif nbrpaymentsmade is 0 ><cfset nbrpaymentsmade = 1></cfif>
					<cfset paymentamt= abs(CurrentRecurring.mAmount/nbrpayments)>
					<cfset ballanceamt = CurrentRecurring.mAmount + (paymentamt * nbrpaymentsmade)> --->
					<TD STYLE="text-align: right;" bgcolor="#bgcolor#">#LSCurrencyFormat(rembal)# </TD>
				<cfelse>
					<TD STYLE="text-align: right;" bgcolor="#bgcolor#">#LSCurrencyFormat(CurrentRecurring.mAmount)#</TD>
				</cfif>
				<TD STYLE="text-align: center;" bgcolor="#bgcolor#"> <cfif RCbIsDaily is "1">daily<cfelse>#qty#</cfif>	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveStart, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveEnd, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#">
				<!--- 	<cfif (CurrentRecurring.iChargeType_ID is not "1737"
				 		AND CurrentRecurring.iChargeType_ID is not "1740"
						AND CurrentRecurring.iChargeType_ID is not "1741")>
				 --->
				<cfif (CurrentRecurring.iChargeType_ID is not "1737" AND CurrentRecurring.iChargeType_ID is not "1740" )>
					<cfif (listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1)>
						<!--- Sr. Acct or AR --->
						<!--- mstriegel 1/12/2018 added logic to Not displaying delete button if the charge type is of type community --->
						<cfif listFindNoCase(communityFeeChargeTypeIDList,currentRecurring.iChargeType_ID) EQ 0>
							<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteRecurring.cfm?typeID=#CurrentRecurring.iRecurringCharge_ID#'">
						</cfif>
						<!---end mstriegel 01/12/2018 --->
					</cfif>
                </cfif>
                </TD>
			</TR>
			<cfset prevname = "#CurrentRecurring.iTenant_ID#">
		</CFLOOP>
	<CFELSE> <TD COLSPAN=7> There are no recurring charges at this time. </TD> </TR></CFIF>
</TABLE>
<BR>
</CFOUTPUT>
<SCRIPT>
	try{ dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart); }
	catch(exception){ /*no action*/ }
</SCRIPT>
<CFINCLUDE TEMPLATE="../../footer.cfm">
