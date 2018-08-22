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
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
----------------------------------------------------------------------------------------------->
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ''> 
     <!--- rsa - 10/28/2005 - changed link from gum to #server_name# --->
     <CFLOCATION URL="http://#server_name#" ADDTOKEN="No"> 
</CFIF>

<!--- Include Share JavaScript  --->
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
<script language="javascript">
	function numbers(e)
  {	  //  Robert Schuette project 23853  - 7-18-08
  	 // removes House ability to enter negative values for the Amount textbox,
  	//  only AR will enter in negative values.  Added extra: only numeric values.
  	
     //alert('Javascript is hit for test.')
  	keyEntry = window.event.keyCode;
  	if((keyEntry < '46') || (keyEntry > '57') || (keyEntry == '47')) {return false;  }
  }
  
 function calcenddate()
{
	var nbrMonths =  document.getElementById('MonthstoPay');
	var strMonth  =  document.getElementById('ApplyToMonth');
	var strYear  =  document.getElementById('ApplyToYear');	
//	var y		  =  document.getElementById("ApplyToMonth").options;
	var MonToPay = nbrMonths.options[nbrMonths.selectedIndex].text;	
	var MonStart = strMonth.options[strMonth.selectedIndex].text;
	var YrStart = strYear.options[strYear.selectedIndex].text;
 	newPayMonth = Number(MonToPay) + Number(MonStart) -1;
	if (newPayMonth > 12)
		{
			newPayMonth = newPayMonth - 12;
			YrStart = Number(YrStart) + 1;
		}
	
	if (newPayMonth < 10)
		{
			newPayMonth = String('0') + String(newPayMonth);
		}
	else
		{newPayMonth =  String(newPayMonth);}
		YrStart = String(YrStart);
	newPayDate = 	newPayMonth + YrStart
// alert( MonToPay  + ' : ' +   MonStart   + ' : ' +  newPayMonth  + ' : ' + YrStart  + ' : ' +  newPayDate)	
 document.getElementById('defEndDate').value = newPayDate;	
} // end function calcenddate   
</script>	

<CFSCRIPT>
	if (IsDefined("form.iTenant_ID") and IsDefined("form.iCharge_ID")) { ACTION="RecurringADD.cfm"; }
	else if (IsDefined("url.typeID")) { ACTION="RecurringUpdate.cfm"; }
	else { ACTION="Recurring.cfm"; }	

	if (IsDefined("url.ID")){ form.iTenant_ID=URL.ID; }
	if (IsDefined("url.typeID")){ form.iCharge_ID=URL.typeID; }
	if (SESSION.UserID IS 3025){ writeOutPut('#Variables.Action#<BR>'); }
</CFSCRIPT>

<!--- MLAW 12/29/2005 Get the cChargeSet value from the house table based on the house id --->
<cfquery name="getHouseChargeset" datasource="tips4">
  select cs.CName from house h
  join chargeset cs
  on cs.iChargeSet_ID = h.iChargeSet_ID
  where ihouse_id = #session.qSelectedHouse.iHouse_ID#
    and h.dtrowdeleted is null
</cfquery>

<!--- ==============================================================================
Retrieve all Tenants who are in a status of Moved IN
=============================================================================== --->
<CFQUERY NAME="TenantList" DATASOURCE="#APPLICATION.datasource#">
	select *
	from tenant t (nolock)
	join tenantstate ts (nolock) on (t.iTenant_ID = ts.iTenant_ID and t.dtRowDeleted is null)
	and ts.iTenantStateCode_ID = 2 and ts.iResidencyType_ID <> 3
	and t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	join AptAddress ad (nolock) on (TS.iAptAddress_ID = AD.iAptAddress_ID and AD.dtRowDeleted is null)
	where ts.iAptAddress_ID is not null
	<CFIF IsDefined("form.iTenant_ID")> and T.iTenant_ID = #form.iTenant_ID# </CFIF>
	order by T.cLastName
</CFQUERY>


<!--- logout user if trying to submit via edited url variables 5/18/05 Paul Buendia--->
<cfif (TenantList.recordcount eq 0 and isDefined("url.id") ) or (isDefined("url.id") and not isDefined("HTTP_REFERER"))>
	<cflocation url="../../logout.cfm">
</cfif>

<!--- ==============================================================================
Retreive all charges for Recurring purposes.
=============================================================================== --->
<!--- MLAW 12/29/2005 include House's cchargeset --->
<CFQUERY NAME="ChargeList" DATASOURCE = "#APPLICATION.datasource#">
	<CFIF NOT IsDefined("url.TypeID")>
		SELECT	C.*, CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, CT.cDescription as typedescription,
				CT.bIsRent, CT.bIsDaily,  CT.iChargeType_ID ,NULL as cComments  <!--- Added 12/26/01 SBD to fix problem reported by Cathy Ricketts --->
		from Charges C
		join ChargeType CT on C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null and c.dtRowDeleted is null
		and cGLAccount <> 1030 and CT.iChargeType_ID <> 23 and CT.bisRecurring is not null
		and CT.bIsDeposit is null 
		and (C.cChargeSet is null or C.cChargeset = '#getHouseChargeset.CName#')
		and (C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR C.iHouse_ID is null)
		and (c.iresidencytype_id <> 3 or c.iresidencytype_id is null)
		where C.dtRowDeleted is null
		and #CreateODBCDateTime(SESSION.TipsMonth)# between c.dteffectivestart and isnull(c.dteffectiveend,getdate())
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0 and  
			( (IsDefined("SESSION.accessrights") and SESSION.accessrights NEQ 'iDirectorUser_ID') or not isDefined("SESSION.accessrights") )>
			and ((bIsRent IS NOT NULL and bisdaily is not null and isleveltype_id is null) OR bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL OR bIsRentAdjustment IS NOT NULL)
			and bisdeposit is null
			and bIsMedicaid is null and cGLACCOUNT NOT IN (3011,3012,3015,3016)
		<CFELSEIF (IsDefined("SESSION.accessrights") and SESSION.accessrights EQ 'iDirectorUser_ID')> 
			and (bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL or (bisrent is not null and bSlevelType_ID is null))
			and bIsMedicaid is null and cGLACCOUNT NOT IN (3011,3012,3015,3016)
			and bisrentadjustment is null
		</CFIF>
		<CFIF IsDefined("form.iCharge_ID")> and iCharge_ID = #form.iCharge_ID# </CFIF>
		ORDER BY C.cDescription, CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc
	<CFELSE>
		SELECT	RC.*, RC.bIsDaily as RCbIsDaily, CT.iChargeType_ID, CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, C.iCharge_ID,  CT.cDescription as typedescription
				,CT.bIsRent, CT.bIsDaily
		FROM	RecurringCharge RC	
		JOIN	Charges C ON (C.icharge_ID = RC.iCharge_ID and C.dtRowDeleted is null and rc.dtRowDeleted is null)
		JOIN	ChargeType CT	ON (CT.iChargeType_ID = C.iChargeType_ID and CT.dtRowDeleted is null)
		and rc.iRecurringCharge_ID = #url.typeID#
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0> and ct.bIsMedicaid is null</CFIF>
		ORDER BY CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc, C.cDescription
	</CFIF>
</CFQUERY>

<CFQUERY NAME='qChargeTypes' DBTYPE='QUERY'>
	SELECT	distinct typedescription, iChargeType_ID FROM ChargeList Order by typedescription
</CFQUERY>

<!--- ==============================================================================
Retreive all the Current Recurring Charges for the House ***  and C.dtEffectiveEnd > '#SESSION.TIPSMonth#'
=============================================================================== --->
<CFQUERY NAME = "CurrentRecurring" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	RC.iRecurringCharge_ID, RC.dtEffectiveStart, RC.dtEffectiveEnd, RC.iQuantity, RC.bIsDaily AS RCbIsDaily, RC.cDescription, RC.mAmount, RC.cComments,
			T.iTenant_ID, T.cFirstname, T.cLastName, CT.bIsDaily, CT.ichargetype_id
	FROM	RecurringCharge RC
	JOIN	Charges C ON C.iCharge_ID = RC.iCharge_ID and C.dtRowDeleted is null
	JOIN 	ChargeType CT ON CT.ichargetype_id = C.iChargeType_ID and CT.dtrowdeleted is null
	JOIN	Tenant T ON	RC.iTenant_ID = T. iTenant_ID and T.dtRowDeleted is null and RC.dtRowDeleted is null
	JOIN	TenantState TS ON TS.iTenant_ID = T.iTenant_ID and TS.dtRowDeleted is null and TS.iTenantStateCode_ID < 3 and TS.iAptAddress_ID IS NOT NULL
	JOIN	House H	ON H.iHouse_ID = T.iHouse_ID and H.dtRowDeleted is null and H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	WHERE	
		<cfif session.userid is "3271" or session.userid is "3273">
		( RC.dtEffectiveEnd >= '#SESSION.TIPSMonth#' OR 
		RC.dtEffectiveEnd >= '3/1/2005' )
		<cfelse>
		RC.dtEffectiveEnd >= '#SESSION.TIPSMonth#'
		</cfif>	
	ORDER BY T.cLastName
</CFQUERY>

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


<FORM NAME="Recurring" ACTION = "#Variables.Action#" METHOD = "POST" onSubmit="return effectivecheck();">

<INPUT NAME = "Message" TYPE = "TEXT" VALUE="" SIZE="77" STYLE = "Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
<cfif isDefined('ChargeList.iChargeType_ID')>
	<INPUT TYPE="hidden" NAME="iChargeType_ID" VALUE="#ChargeList.iChargeType_ID#">
</cfif>
<CFIF IsDefined("URL.typeID")> <INPUT TYPE="Hidden" NAME="iRecurringCharge_ID" VALUE="#url.typeID#"> </CFIF>
<TABLE>
	<CFSCRIPT>if(isDefined("url.ID") and Url.ID NEQ ''){ Action='Edit'; } else{ Action='Add'; }</CFSCRIPT>
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
					<CFLOOP QUERY="TenantList"> <OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstname# </OPTION> </CFLOOP>
				</SELECT>
			</TD>
			<TD><SPAN ID='chargetype'></SPAN></TD>
			<TD></TD><TD></TD>
		</TR>
	</CFIF>	
			
	<CFIF IsDefined("form.iTenant_ID") and IsDefined("form.iCharge_ID")>
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
		
			<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
			<CFIF ChargeList.bIsModifiableAmount GT 0 or listfindNocase(session.codeblock,23) GTE 1 or session.userid EQ 3025 or session.userid EQ 3146 or session.userid is "3271">
			<!--- Katie taking away RDO & House access to overrule modify amount rights set by chargetype administrator: 7/6/05: (isDefined("session.AccessRights") and session.AccessRights EQ 'iDirectorUser_ID') or listfindNocase(session.codeblock,21) GTE 1  --->
			<!---Robert Schuette, project 23853   07-18-2008
				begin: If user is NOT AR then javascript for keyboard restriction on input (only numbers)
				User-group ‘192’ is ‘AR’--->
				<TD STYLE="text-align: center;">
				<cfif ListContains(session.groupid,'192')>
						<CFIF ChargeList.bIsModifiableAmount GT 0 OR listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1>
							<cfif isDefined('Additional.iChargeType_ID')>
								<cfif   	ChargeList.iChargeType_ID is 1740>
									 Enter the amount of the NRF deferral: 
								<cfelse>
									  &nbsp;
								</cfif>
							<cfelse>
							  &nbsp;
							</CFIF>
							<BR> 
							<INPUT TYPE = "text" NAME="mAmount" SIZE="10" STYLE="text-align:right;" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#"  onKeyUp="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));">
						<CFELSE>
							#LSCurrencyFormat(ChargeList.mAmount)#
							<INPUT TYPE="Hidden" NAME="mAmount" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#">
						</CFIF>				
				<!--- 	
				<TD STYLE="text-align: center;">	
					<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#" STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));">
				</TD>
				 --->
				<cfelse>
				
						<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#" STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));" onKeyPress="return numbers(event);">
					</TD>
				</cfif><!---End change. proj 23853--->
				
			<CFELSE>
				<!--- fzahir added readonly field: 11/22/2005 --->
				<td style="text-align: center;">
				<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#" STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));" readonly="" >
				<!---#LSCurrencyFormat(ChargeList.mAmount)# --->
				<!--- MLAW 03/02/2006 this hidden field should be removed --->
				<!---<input type="Hidden" name="mAmount" value="#ChargeList.mAmount#">--->
				</td>
			</CFIF>
			
			<CFIF ChargeList.bIsModifiableQty GT 0>
				<TD STYLE="text-align: center;">
					<cfif (isDefined("ChargeList.iCharge_ID") and (ChargeList.iChargeType_ID is 8 or ChargeList.iChargeType_ID is 1664)) and (SESSION.qSelectedHouse.cStateCode NEQ 'OR')>
					<!--- <cfif (form.iCharge_ID is 86 OR (isDefined("ChargeList.iCharge_ID") and ChargeList.iCharge_ID is 86))
					 and (session.qSelectedHouse.cStateCode NEQ 'OR')> ---><!--- and session.qSelectedHouse.cStateCode NEQ 'IA' or session.qSelectedHouse.iHouse_id eq 150) --->
					 	<CFSCRIPT>
							if (isDefined("ChargeList.RCbIsDaily") and ChargeList.RCbIsDaily is 1) {checked='checked'; }
							else {checked=''; }
						</CFSCRIPT>
						<input type="checkbox" name="bIsDaily" value="1" #checked#> Daily or 
					</cfif>
					<input type="text" name="iQuantity" value="#ChargeList.iQuantity#" size="2" maxlength="2" style="text-align:center;" onBlur="this.value=Numbers(this.value);">
				</TD>
			<CFELSE>
				<TD STYLE="text-align: center;"> #ChargeList.iQuantity# <INPUT TYPE="Hidden" NAME="iQuantity" VALUE="#ChargeList.iQuantity#"></TD>
			</CFIF>
		</TR>
		
	</CFIF>
	<cfif  (ChargeList.iChargeType_ID is 1740)   >
	<CFIF IsDefined("form.iTenant_ID") and IsDefined("form.iCharge_ID")>
			<TR>
				<!--- <TD></TD> --->
				<TD  STYLE="text-align: center;" colspan="2">
				Payment Start Period:<br/><!--- Charge To Period: --->  
 				<SELECT NAME="ApplyToMonth" id="ApplyToMonth">
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
						<CFIF I EQ Month(ChargeList.dtEffectiveStart)><CFSET Selected='SELECTED'><CFELSE><CFSET Selected=''></CFIF>
						<CFIF Len(I) EQ 1><CFSET N='0'&I><CFELSE><CFSET N=I></CFIF><OPTION VALUE="#N#" #SELECTED#>#N#</OPTION>
					</CFLOOP>
				</SELECT>  
				<CFIF MONTH(Now()) EQ 12>
					<SELECT NAME="ApplyToYear" id="ApplyToYear"><OPTION VALUE="#Year(Now())#">#Year(Now())#</OPTION><OPTION VALUE="#Year(DateAdd("yyyy",1,Now()))#">#Year(DateAdd("yyyy",1,Now()))#</OPTION></SELECT>
				<CFELSEIF MONTH(Now()) EQ 1 >
					<SELECT NAME="ApplyToYear"  id="ApplyToYear"><OPTION VALUE="#Year(Now())#">#Year(Now())#</OPTION><OPTION VALUE="#Year(DateAdd("yyyy",-1,Now()))#">#Year(DateAdd("yyyy",-1,Now()))#</OPTION></SELECT>
				<CFELSE>
					<INPUT TYPE="text" NAME="ApplyToYear"  id="ApplyToYear" SIZE=3 READONLY VALUE="#Year(Now())#" STYLE="background: whitesmoke;">
				</CFIF>
				</TD>
				 
			 
				<TD   STYLE="text-align: center;">
				Months to Pay:<br/>   
				<SELECT NAME="MonthstoPay"  id="MonthstoPay" onChange="calcenddate()">
					<CFLOOP index="j" from="1" to="9" step="1" >
						 <OPTION VALUE="#j#"  >#j#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>	
				<td>End Date of Deferral
				<br/>
					<input type="text" name="defEndDate" id="defEndDate" value=""      readonly="Yes" />
				</td>		
				 		
			</TR>	
<!---  --->	
<cfelse>
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
				<INPUT TYPE="Text" NAME="YearStart" Value="#YearStart#" SIZE="3" MAXLENGTH=4  onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)" onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=Numbers(this.value);">
			</TD>
								<cfif isDefined('Additional.iChargeType_ID') and   (Additional.iChargeType_ID is 1740) >
				<!--- 	<input type="hidden" name="iChargeType_ID" id="iChargeType_ID" value="#Additional.iChargeType_ID#" /> --->
				<TD   STYLE="text-align: center;">
				Months to Pay:
				<SELECT NAME="MonthstoPay"  id="MonthstoPay" onChange="calcenddate()">
					<CFLOOP INDEX=I FROM=1 TO=12 STEP=1>
						 <OPTION VALUE="#I#" #SELECTED#>#I#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>	
				<td>End Date of Deferral
				<br/>
					<input type="text" name="defEndDate" id="defEndDate" value=""      readonly="Yes" />
				</td>		
				</cfif>	
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
	</CFIF>	
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
			<cfif prevname is not currname><cfif bgcolor is "EEEEEE"><cfset bgcolor="FFFFFF"><cfelse><cfset bgcolor="EEEEEE"></cfif><cfelse></cfif>	
			<TR>
				<TD STYLE="width: 25%;" NOWRAP bgcolor="#bgcolor#"> #CurrentRecurring.cLastName#, #CurrentRecurring.cFirstName#  </TD>
				<TD NOWRAP STYLE="width: 25%;" bgcolor="#bgcolor#">	
					<A HREF="Recurring.cfm?ID=#CurrentRecurring.iTenant_ID#&typeID=#CurrentRecurring.iRecurringCharge_ID#"> #CurrentRecurring.cDescription# </A>		
				</TD>
				<TD STYLE="text-align: right;" bgcolor="#bgcolor#">	#LSCurrencyFormat(CurrentRecurring.mAmount)#		</TD>
				<TD STYLE="text-align: center;" bgcolor="#bgcolor#"> <cfif RCbIsDaily is "1">daily<cfelse>#qty#</cfif>	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveStart, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveEnd, "mm/dd/yyyy")#	</TD>
				<cfif  CurrentRecurring.iChargeType_ID is  "1740" or CurrentRecurring.iChargeType_ID is  "1741">
				<td>&nbsp;</td>
				<cfelse>
				<TD bgcolor="#bgcolor#"> <cfif CurrentRecurring.iChargeType_ID is not "89" OR (listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1)><!--- Sr. Acct or AR ---><INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteRecurring.cfm?typeID=#CurrentRecurring.iRecurringCharge_ID#'"></cfif> </TD>				
				</cfif>
			</TR>
			<cfset prevname = "#CurrentRecurring.iTenant_ID#">	
		</CFLOOP>
	<CFELSE> <TD COLSPAN=7> There are no recurring charges at this time. </TD> </CFIF>
	</TR>	
</TABLE>

<BR>
</CFOUTPUT>
<SCRIPT>
	try{ dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart); }
	catch(exception){ /*no action*/ }
</SCRIPT>
<CFINCLUDE TEMPLATE="../../footer.cfm">

