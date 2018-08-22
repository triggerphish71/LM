
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ''> <CFLOCATION URL="http://gum" ADDTOKEN="No"> </CFIF>

<!--- ==============================================================================
Include Share JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
<SCRIPT>
	function effectivecheck() {
		var MonthStart = (document.Recurring.MonthStart.value - 1);
		var MonthEnd = (document.Recurring.MonthEnd.value - 1);
		var	start = new Date(document.Recurring.YearStart.value, MonthStart, document.Recurring.DayStart.value);
		var	end = new Date(document.Recurring.YearEnd.value, MonthEnd, document.Recurring.DayEnd.value);
		if (start > end) { (document.Recurring.Message.value = 'The start date may not be later than the end date'); return false; }
		else{ (document.Recurring.Message.value = ''); return; }
	}
</SCRIPT>

<CFSCRIPT>
	if (IsDefined("form.iTenant_ID") AND IsDefined("form.iCharge_ID")) { ACTION="RecurringADD.cfm"; }
	else if (IsDefined("url.typeID")) { ACTION="RecurringUpdate.cfm"; }
	else { ACTION="Recurring.cfm"; }	

	if (IsDefined("url.ID")){ form.iTenant_ID=URL.ID; }
	if (IsDefined("url.typeID")){ form.iCharge_ID=URL.typeID; }
	if (SESSION.UserID IS 3025){ writeOutPut('#Variables.Action#<BR>'); }
</CFSCRIPT>

<!--- ==============================================================================
Retrieve all Tenants who are in a status of Moved IN
=============================================================================== --->
<CFQUERY NAME="TenantList" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM Tenant T
	JOIN TenantState TS ON (T.iTenant_ID = TS.iTenant_ID AND T.dtRowDeleted IS NULL)
	JOIN AptAddress AD ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	WHERE TS.iAptAddress_ID IS NOT NULL
	AND TS.iTenantStateCode_ID = 2 AND TS.iResidencyType_ID <> 3
	AND	T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	<CFIF IsDefined("form.iTenant_ID")> AND T.iTenant_ID = #form.iTenant_ID# </CFIF>
	ORDER BY T.cLastName
</CFQUERY>


<!--- ==============================================================================
Retreive all charges for Recurring purposes.
=============================================================================== --->
<CFQUERY NAME="ChargeList" DATASOURCE = "#APPLICATION.datasource#">
	<CFIF NOT IsDefined("url.TypeID")>
		SELECT	C.*,
				CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, CT.cDescription as typedescription,
				CT.bIsRent, CT.bIsDaily, NULL as cComments   <!--- Added 12/26/01 SBD to fix problem reported by Cathy Ricketts --->
		FROM	Charges C
		JOIN	ChargeType CT	ON	(C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		WHERE	C.dtRowDeleted IS NULL
		AND	cGLAccount <> 1030 AND CT.iChargeType_ID <> 23
		AND	CT.bIsDeposit IS NULL AND C.cChargeSet is null
		AND (C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR C.iHouse_ID IS NULL)
		AND #CreateODBCDateTime(SESSION.TipsMonth)# between c.dteffectivestart and isnull(c.dteffectiveend,getdate())
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0 AND (IsDefined("SESSION.accessrights") AND SESSION.accessrights NEQ 'iDirectorUser_ID')>
			AND		((bIsRent IS NOT NULL AND bisdaily is not null and isleveltype_id is null) OR bIsRent IS NULL OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL)
			AND 	bIsMedicaid IS NULL AND cGLACCOUNT NOT IN (3011,3012,3015,3016)
		<CFELSEIF (IsDefined("SESSION.accessrights") AND SESSION.accessrights EQ 'iDirectorUser_ID')> 
			AND		(bIsRent IS NULL OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL or (bisrent is not null and bSlevelType_ID is null))
			AND 	bIsMedicaid IS NULL AND cGLACCOUNT NOT IN (3011,3012,3015,3016)
			AND		bisrentadjustment is null
		</CFIF>
		<CFIF IsDefined("form.iCharge_ID")> AND iCharge_ID = #form.iCharge_ID# </CFIF>
		ORDER BY C.cDescription, CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc
	<CFELSE>
		SELECT	RC.*, CT.iChargeType_ID, CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, C.iCharge_ID,  CT.cDescription as typedescription
				,CT.bIsRent, CT.bIsDaily
		FROM	RecurringCharge RC	
		JOIN	Charges C 		ON	(C.icharge_ID = RC.iCharge_ID AND C.dtRowDeleted IS NULL)
		JOIN	ChargeType CT	ON	(CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		WHERE	RC.dtRowDeleted IS NULL
		AND		iRecurringCharge_ID = #url.typeID#
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0> AND bIsMedicaid IS NULL</CFIF>
		ORDER BY CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc, C.cDescription
	</CFIF>
</CFQUERY>

<CFQUERY NAME='qChargeTypes' DBTYPE='QUERY'>
	SELECT	distinct typedescription, iChargeType_ID FROM ChargeList Order by typedescription
</CFQUERY>

<!--- ==============================================================================
Retreive all the Current Recurring Charges for the House ***  AND C.dtEffectiveEnd > '#SESSION.TIPSMonth#'
=============================================================================== --->
<CFQUERY NAME = "CurrentRecurring" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	RC.iRecurringCharge_ID, RC.dtEffectiveStart, RC.dtEffectiveEnd, RC.iQuantity, RC.cDescription, RC.mAmount, RC.cComments,
			T.iTenant_ID, T.cFirstname, T.cLastName, CT.bIsDaily
	FROM	RecurringCharge RC
	JOIN	Charges C ON (C.iCharge_ID = RC.iCharge_ID AND C.dtRowDeleted IS NULL)
	JOIN 	ChargeType CT ON CT.ichargetype_id = C.iChargeType_ID and CT.dtrowdeleted is null
	JOIN	Tenant T ON	(RC.iTenant_ID = T. iTenant_ID AND T.dtRowDeleted IS NULL)
	JOIN	TenantState TS ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL AND TS.iTenantStateCode_ID < 3 AND TS.iAptAddress_ID IS NOT NULL)
	JOIN	House H	ON (H.iHouse_ID = T.iHouse_ID AND H.dtRowDeleted IS NULL)
	WHERE	RC.dtEffectiveEnd >= '#SESSION.TIPSMonth#'
	AND		RC.dtRowDeleted IS NULL
	AND		H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY T.cLastName
</CFQUERY>

<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- *********************************************************************************************
HTML head.
********************************************************************************************** --->
<TITLE> Tips 4  - Recurring Charges </TITLE>
<BODY>

<!--- =============================================================================================
Display the page header.
============================================================================================== --->
<H1 CLASS="PageTitle"> Tips 4 - Recurring Charges </H1>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<HR>

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


<FORM NAME="Recurring" ACTION = "#Variables.Action#" METHOD = "POST" onSubmit="return effectivecheck();">
<TABLE STYLE='border:none;'>
	<TR>
		<TD STYLE='font-size:small;'><A Href="../../../intranet/Tips4/Charges/Charges.cfm" style="color: Navy;">Back To Charges.</a></TD>
		<TD STYLE='font-size:small;text-align:right;'><A HREF='../Admin/Menu.cfm' style="color: Navy;">Go to Administration</A></TD>
	</TR>
</TABLE>
<INPUT NAME = "Message" TYPE = "TEXT" VALUE="" SIZE="77" STYLE = "Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
<CFIF IsDefined("URL.typeID")> <INPUT TYPE="Hidden" NAME="iRecurringCharge_ID" VALUE="#url.typeID#"> </CFIF>
<TABLE>
	<CFSCRIPT>if(isDefined("url.ID") AND Url.ID NEQ ''){ Action='Edit'; } else{ Action='Add'; }</CFSCRIPT>
	<TR> <TH COLSPAN = "4"> #Action# Recurring Charges </TH> </TR>
	<TR STYLE = "font-weight: bold;">
		<TD STYLE="width: 25%;"> Name </TD>
		<TD STYLE="width: 25%;"> Charge </TD>
		<TD STYLE="width: 25%;text-align: center;"> Amount </TD>
		<TD STYLE="width: 25%; text-align: center;"> Quantity </TD>
	</TR>
	<CFIF NOT IsDefined("form.iTenant_ID")>
		<TR>
			<TD NOWRAP>
				<SELECT NAME="iTenant_ID" onChange="showtypes(this);">
					<OPTION VALUE="0"> None </OPTION>
					<CFLOOP QUERY="TenantList"> <OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstname# </OPTION> </CFLOOP>
				</SELECT>
			</TD>
			<TD><SPAN ID='chargetype'></SPAN></TD>
			<TD></TD><TD></TD>
		</TR>
	</CFIF>	
			
	<CFIF IsDefined("form.iTenant_ID") AND IsDefined("form.iCharge_ID")>
		<TR>
			<TD>#TenantList.cLastName#, #TenantList.cFirstname# <INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#TenantList.iTenant_ID#"></TD>
			<CFIF ChargeList.bIsModifiableDescription GT 0>
				<TD>
					<INPUT TYPE="text" NAME="cDescription" VALUE="#ChargeList.cDescription#" MAXLENGTH="15"  onBlur="this.value=Letters(this.value);  Upper(this);">
					<INPUT TYPE="Hidden" NAME="iCharge_ID" VALUE="#ChargeList.iCharge_ID#">
				</TD>
			<CFELSE>
				<TD>	
					#ChargeList.cDescription#
					<INPUT TYPE="Hidden" NAME="iCharge_ID" VALUE="#ChargeList.iCharge_ID#">
					<INPUT TYPE="Hidden" NAME="cDescription" VALUE="#ChargeList.cDescription#">
				</TD>
			</CFIF>
		
			<CFIF ChargeList.bIsModifiableAmount GT 0 OR (IsDefined("SESSION.AccessRights") AND SESSION.AccessRights EQ 'iDirectorUser_ID') 
				OR listfindNocase(session.codeblock,21) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1 OR SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146>
				<TD STYLE="text-align: center;">	
					<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#" STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));">
				</TD>
			<CFELSE>
				<TD STYLE="text-align: center;">#LSCurrencyFormat(ChargeList.mAmount)# <INPUT TYPE="Hidden" NAME="mAmount" VALUE="#ChargeList.mAmount#"> </TD>
			</CFIF>
			
			<CFIF ChargeList.bIsModifiableQty GT 0>
				<TD STYLE="text-align: center;"><INPUT TYPE="text" NAME="iQuantity" VALUE="#ChargeList.iQuantity#" SIZE="2" MAXLENGHT="2" STYLE="text-align:center;" onBlur="this.value=Numbers(this.value);"></TD>
			<CFELSE>
				<TD STYLE="text-align: center;"> #ChargeList.iQuantity# <INPUT TYPE="Hidden" NAME="iQuantity" VALUE="#ChargeList.iQuantity#"></TD>
			</CFIF>
		</TR>
	</CFIF>
	
	<CFIF IsDefined("form.iTenant_ID") AND IsDefined("form.iCharge_ID")>
		<TR>
			<TD>Effective Beginning	</TD>
			<TD>
				<CFSCRIPT>
					if (ChargeList.dtEffectiveStart NEQ "") { 
						MonthStart = Month(ChargeList.dtEffectiveStart); DayStart = Day(ChargeList.dtEffectiveStart); YearStart = Year(ChargeList.dtEffectiveStart); }
					else{ MonthStart = "#Month(now())#"; DayStart = "#Day(Now())#"; YearStart = "#Year(Now())#"; }
				</CFSCRIPT>
				<SELECT NAME="MonthStart" onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)">	
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"><CFIF MonthStart EQ I><CFSET sel='selected'><CFELSE><CFSET sel=''></CFIF><OPTION VALUE="#I#" #sel#> #I# </OPTION></CFLOOP>
				</SELECT>
				/ 
				<SELECT NAME = "DayStart" onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)">
					<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1"><CFIF DayStart EQ I><CFSET sel='selected'><CFELSE><CFSET sel=''></CFIF><OPTION VALUE="#I#"#sel#> #I# </OPTION></CFLOOP>
				</SELECT>	
				/
				<INPUT TYPE="Text" NAME="YearStart" Value="#YearStart#" SIZE="3" MAXLENGTH=4  onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)" onKeyUp="this.value=Numbers(this.value);" onblur="this.value=Numbers(this.value);">
			</TD>
			<TD> Effective End </TD>
			<TD>
				<CFSCRIPT>
					if (ChargeList.dtEffectiveEnd NEQ ""){
						MonthEnd = Month(ChargeList.dtEffectiveEnd); DayEnd = Day(ChargeList.dtEffectiveEnd); YearEnd = Year(ChargeList.dtEffectiveEnd); }
					else { MonthEnd = "#Month(now())#"; DayEnd = "#Day(Now())#"; YearEnd = "2010"; }
				</CFSCRIPT>
				<SELECT NAME = "MonthEnd" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"><CFIF MonthEnd EQ I><CFSET sel='selected'><CFELSE><CFSET sel=''></CFIF><OPTION VALUE="#I#"#sel#> #I# </OPTION></CFLOOP>
				</SELECT>
				/ 
				<SELECT NAME = "DayEnd" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
					<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1"><CFIF DayEnd EQ I><CFSET sel='selected'><CFELSE><CFSET sel=''></CFIF><OPTION VALUE="#I#"#sel#> #I# </OPTION></CFLOOP>
				</SELECT>
				/
				<INPUT TYPE="Text" NAME="YearEnd" Value="#YearEnd#" SIZE="3" MAXLENGTH=4 onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=Numbers(this.value); dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd);" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
			</TD>
		</TR>
		<TR><TD COLSPAN="4">Comments: <BR> <TEXTAREA COLS="75" ROWS="2" NAME="cComments">#ChargeList.cComments#</TEXTAREA></TD></TR>
		<TR>		
			<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save"></TD>
			<TD></TD><TD></TD>
			<TD><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="location.href='Recurring.cfm'"></TD>
		</TR>
		<TR><TD COLSPAN="4" style="font-weight: bold; color: red;">	<U>NOTE:</U> You must SAVE to keep information which you have entered! </TD></TR>	
	</CFIF>
</TABLE>
</FORM>

<TABLE>
	<TR><TH COLSPAN="7" STYLE="text-align: left;">	Existing Recurring Charges:	</TH></TR>
	<TR STYLE="font-weight: bold;">
		<TD STYLE="width: 25%;" NOWRAP>Name</TD>
		<TD STYLE="width: 25%;">Charge</TD>
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
			<cfif prevname is not currname><cfif bgcolor is "EEEEEE"><cfset bgcolor="FFFFFF"><cfelse><cfset bgcolor="EEEEEE"></cfif><cfelse></cfif>	
			<TR>
				<TD STYLE="width: 25%;" NOWRAP bgcolor="#bgcolor#"> #CurrentRecurring.cLastName#, #CurrentRecurring.cFirstName#  </TD>
				<TD NOWRAP STYLE="width: 25%;" bgcolor="#bgcolor#">	
					<A HREF="Recurring.cfm?ID=#CurrentRecurring.iTenant_ID#&typeID=#CurrentRecurring.iRecurringCharge_ID#"> #CurrentRecurring.cDescription# </A>		
				</TD>
				<TD STYLE="text-align: right;" bgcolor="#bgcolor#">	#LSCurrencyFormat(CurrentRecurring.mAmount)#		</TD>
				<TD STYLE="text-align: center;" bgcolor="#bgcolor#"> #qty#	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveStart, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveEnd, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#"> <INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteRecurring.cfm?typeID=#CurrentRecurring.iRecurringCharge_ID#'"> </TD>				
			</TR>
			<cfset prevname = "#CurrentRecurring.iTenant_ID#">	
		</CFLOOP>
	<CFELSE> <TD COLSPAN=7> There are no recurring charges at this time. </TD> </CFIF>
	</TR>	
</TABLE>

<BR><BR>

<A HREF="../../../intranet/Tips4/Charges/Charges.cfm" style="color: Navy; Font-size: 18;">Click Here to Go Back To Charges Screen.</a>
</CFOUTPUT>
<SCRIPT>
	try{ dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart); }
	catch(exception){ /*no action*/ }
</SCRIPT>
<CFINCLUDE TEMPLATE="../../footer.cfm">

