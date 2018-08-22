<!--- *******************************************************************************
Name:			CashReceipts.cfm
Process:		Enter new cash receipts.

Called by: 		MainMenu.cfm
Calls/Submits:		CashReceiptUpdate.cfm, CashReceiptInsert.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Steve Davison           02/21/2002      This Header added.
Steve Davison           02/21/2002      Comments field limited to 25 characters
Paul Buendia			05/06/2002		Limited Check Number field to 10 characters
******************************************************************************** --->

<CFIF isDefined("url.stmp")>
	<CFSCRIPT>time=CreateDateTime(MID(url.stmp,5,2),Left(url.stmp,2),Mid(url.stmp,3,2),Mid(url.stmp,7,2),Mid(url.stmp,9,2),Mid(url.stmp,11,2));</CFSCRIPT>
	<CFIF datediff('n', time, now()) gt 1><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"> </CFIF>
</CFIF>

<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ""> <CFLOCATION URL="../../Loginindex.cfm" ADDTOKEN="No"> </CFIF>

<!--- ==============================================================================
Include Shared JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>	
<CFOUTPUT>
	function redirect() { window.location = "CashReceipts.cfm";}
	function validtenant(){
		if (document.CashReceipts.iTenant_ID.value == '') { alert('Please choose resident.'); return false; }
		else if (document.CashReceipts.cCheckNumber.value == '') { alert('Check Number is required.'); return false; }
		else if ( (document.forms[0].mAmount.value == '') || (document.forms[0].mAmount.value < 0.01) ){ alert('Check Amount is required.'); return false; }	
		else if(document.CashReceipts.cComments.value == '') { alert('Description is required.'); return false; }		
		return dups();
	}  
	//dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);
	function dtcheck() {
		thisdate = new Date(document.forms[0].Year.value, document.forms[0].Month.value-1, document.forms[0].Day.value); 
		today = new Date(#year(now())#,#evaluate(month(now())-1)#,#Day(now())#); 
		//alert(thisdate); alert(today);
		if (thisdate > today) {
			document.forms[0].Year.value=#year(now())#;
			document.forms[0].Day.value=#Day(now())#;
			document.forms[0].Month.value=#evaluate(month(now()))#;
			alert('Checks dates for the future may not be entered.');
		}
	}
	function disable(href) {
		for (var i=0; i<document.links.length; i++) {
			if (document.links[i].href == href) { document.links[i].style.visibility='hidden'; }
		}
	}
</CFOUTPUT>
</SCRIPT>

<!--- ==============================================================================
SET form path according to last action (either update or insert
=============================================================================== --->
<CFSCRIPT>
	if (IsDefined("url.ID")) { Variables.Action="CashReceiptUpdate.cfm"; } else { Variables.Action="CashReceiptInsert.cfm"; }
	if (SESSION.UserID IS 3025){ WriteOutPut('#VARIABLES.ACTION#');}
</CFSCRIPT>

<CFOUTPUT>
<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- ==============================================================================
Assign Title and Heading for the Page
=============================================================================== --->
<TITLE>TIPS 4 - Cash Receipts</TITLE>
<H1 CLASS="PageTitle"> TIPS 4 - Cash Receipts </H1>
<CFSET Cachetime=CreateTimeSpan(0, 0, 0, 10)>

<!--- ==============================================================================
Include House Header for TIPS
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<TABLE CLASS="noborder"><TR><TD CLASS="transparent"><HR></TD></TR></TABLE>

<!--- ==============================================================================
Retrieve a list of all tenants either moved in or registered
=============================================================================== --->
<CFQUERY NAME = "AvailableTenants" DATASOURCE = "#APPLICATION.datasource#" CACHEDWITHIN="#Cachetime#">
	SELECT	T.iTenant_ID
		,(SELECT currbal=currbal+futurebal from #Application.HOUSES_APPDBServer#.Houses_app.dbo.ar_balances where custid = T.cSolomonKey) as bal
		,TS.iTenantStateCode_ID, T.cFirstName, T.cLastName, T.cSolomonKey,
		T.bIsMedicaid, T.bIsMisc, T.bIsDayRespite, AD.cAptNumber
	FROM	TENANT T (NOLOCK)
	JOIN 	TenantState TS	ON T.iTenant_ID = TS.iTenant_ID
	LEFT JOIN	AptAddress AD ON (AD.iAptAddress_ID = TS.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	WHERE	(TS.iTenantStateCode_ID < 4 
			OR (TS.iTenantStateCode_ID = 4 AND  0 < (SELECT currbal=currbal+futurebal from #Application.HOUSES_APPDBServer#.Houses_app.dbo.ar_balances where custid = T.cSolomonKey) ) )
	AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		T.dtRowDeleted IS NULL AND T.bisMisc is null
	AND		TS.dtRowDeleted IS NULL
	ORDER BY T.cLastName, T.cSolomonKey
</CFQUERY>


<!--- ==============================================================================
Retrieve Current Deposit Number
=============================================================================== --->
<CFQUERY NAME = "DepositNumber" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	CM.*, CD.iCashReceiptItem_ID
	FROM	CashReceiptMaster CM (NOLOCK)
	LEFT JOIN	CashReceiptDetail CD ON (CD.iCashReceipt_ID = CM.iCashReceipt_ID AND CD.dtRowDeleted IS NULL)
	WHERE 	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND CM.dtRowDeleted IS NULL AND CM.bFinalized IS NULL
	ORDER BY iCashReceiptNumber
</CFQUERY>


<!--- ==============================================================================
Get new Deposit number from housecontrolnumber table if
there is now current cashreceipt being used
=============================================================================== --->
<CFIF DepositNumber.RecordCount EQ 0 OR (IsDefined("DepositNumber.iCashReceipt_ID") EQ "")>
	<!--- ==============================================================================
	Retrieve Next Cash Receipt Number for House
	=============================================================================== --->
	<CFQUERY NAME = "NextCashReceipt" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	iNextCashReceipt FROM HouseNumberControl WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<CFTRANSACTION>
	<!--- ==============================================================================
	Create new Cash Receipt
	=============================================================================== --->
	<CFQUERY NAME = "NewReceipt" DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO CashReceiptMaster
		( iCashReceiptNumber, iHouse_ID, bFinalized, dtAcctStamp, iRowStartUser_ID, dtRowStart )
		VALUES
		( #NextCashReceipt.iNextCashReceipt#, #SESSION.qSelectedHouse.iHouse_ID#, NULL, '#SESSION.AcctStamp#', #SESSION.UserID#, GetDate() )		
	</CFQUERY>
	</CFTRANSACTION>
	
	<CFSET NewReceipt = NextCashReceipt.iNextCashReceipt + 1>
	
	<!--- ==============================================================================
	Update the Houses next cash receipt number
	=============================================================================== --->
	<CFQUERY NAME="NextNumber" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextCashReceipt = #NewReceipt# ,dtRowStart = GetDate() ,iRowStartUser_ID = #SESSION.UserID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<!--- ==============================================================================
	Retrieves all current cash receipts and their iCashReceipt_ID & iCashReceiptItem_ID
	=============================================================================== --->
	<CFQUERY NAME = "GetCashReceiptID" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*
		FROM	CashReceiptMaster CM 
		LEFT OUTER JOIN  CashReceiptDetail CD ON (CM.iCashReceipt_ID = CD.iCashReceipt_ID AND CD.dtRowDeleted IS NULL)
		WHERE	CM.dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		AND		bFinalized IS NULL
	</CFQUERY>
	<CFSCRIPT> iCashReceiptNumber = NextCashReceipt.iNextCashReceipt; iCashReceipt_ID = GetCashReceiptID.iCashReceipt_ID; iCashReceiptItem_ID = GetCashReceiptID.iCashReceiptItem_ID; </CFSCRIPT>
<CFELSE>
	<CFSCRIPT> iCashReceiptNumber = DepositNumber.iCashReceiptNumber; iCashReceipt_ID = DepositNumber.iCashReceipt_ID; iCashReceiptItem_ID	= DepositNumber.iCashReceiptItem_ID; </CFSCRIPT>
</CFIF>

<!--- ==============================================================================
Retrieve Tenants with CashReceipts
=============================================================================== --->
<CFQUERY NAME="CashReceipts" DATASOURCE="#APPLICATION.datasource#">

	<CFIF IsDefined("url.ID")>
		SELECT	T.iTenant_ID, T.cFirstName, T.cLastName, 
				AP.iAptAddress_ID, AD.cAptNumber,
				CD.dtCheckDate, CD.cCheckNumber, CD.mAmount, CD.cComments, CD.iCashReceiptItem_ID
		FROM	CashReceiptDetail CD (NOLOCK)			
		JOIN	CashReceiptMaster CM	ON	(CD.iCashReceipt_ID = CM.iCashReceipt_ID AND CM.dtRowDeleted IS NULL)
		JOIN	Tenant T				ON	(CD.iTenant_ID = T.iTenant_ID AND T.dtRowDeleted IS NULL)
		LEFT JOIN	APTLOG AP			ON	(AP.iTenant_ID = T.iTenant_ID AND AP.dtRowDeleted IS NULL)
		LEFT JOIN	APTADDRESS AD		ON	(AP.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #url.ID#
		AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		AND		CD.iCashReceiptItem_ID = #url.item#
		AND		T.dtRowDeleted IS NULL
		AND		CD.dtRowDeleted IS NULL
		AND		CM.bFinalized IS NULL
	<CFELSE>
		SELECT	T.iTenant_ID, T.cFirstName, T.cLastName, AP.iAptAddress_ID, AD.cAptNumber
		FROM	CashReceiptDetail CD (NOLOCK)	
		JOIN	CashReceiptMaster CM	ON	(CD.iCashReceipt_ID = CM.iCashReceipt_ID AND CM.dtRowDeleted IS NULL)
		JOIN	Tenant T				ON	(CD.iTenant_ID = T.iTenant_ID AND T.dtRowDeleted IS NULL)
		LEFT JOIN	APTLOG AP			ON	(AP.iTenant_ID = T.iTenant_ID AND AP.dtRowDeleted IS NULL)
		LEFT JOIN	APTADDRESS AD		ON	(AP.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
		WHERE 	T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		AND		CD.dtRowDeleted IS NULL
		AND		CM.dtRowDeleted IS NULL
		AND		CM.bFinalized IS NULL
	</CFIF>

</CFQUERY>

<!--- ==============================================================================
Retreive all existing Cash Receipt entries for the house
=============================================================================== --->
<CFQUERY NAME = "CurrentEntries" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	T.*, TS.*, AD.*, CD.*, CM.*
	FROM	CASHRECEIPTDETAIL CD (NOLOCK)
	JOIN 	CASHRECEIPTMASTER CM 	ON	CD.iCashReceipt_ID =  CM.iCashReceipt_ID
	JOIN	Tenant	T				ON	T.iTenant_ID = CD.iTenant_ID
	JOIN	TenantState TS			ON	T.iTenant_ID = TS.iTenant_ID
	LEFT OUTER JOIN 	APTADDRESS	AD	ON	AD.iAptAddress_ID = TS.iAptAddress_ID
	WHERE	CD.dtRowDeleted IS NULL
	AND		CM.dtRowDeleted IS NULL
	AND		TS.dtRowDeleted IS NULL
	AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		T.dtRowDeleted IS NULL
	AND		bFinalized IS NULL
	AND		CM.iCashReceipt_ID = #Variables.iCashReceipt_ID#
	<CFIF IsDefined("SelectOrderby")>
		<CFIF url.SelectOrderBy EQ "Name"> ORDER BY T.cLastName
		<CFELSEIF url.SelectOrderBy EQ "TenantID"> ORDER BY T.cSolomonKey
		<CFELSEIF url.SelectOrderBy EQ "Apt"> ORDER BY AD.cAptNumber, T.cLastName
		<CFELSEIF url.SelectOrderBy EQ "Check"> ORDER BY CD.cCheckNumber, T.cLastName
		<CFELSEIF url.SelectOrderBy EQ "CheckDate"> ORDER BY CD.dtCheckDate, T.cLastName
		<CFELSEIF url.SelectOrderBy EQ "Amount"> ORDER BY CD.mAmount, T.cLastName </CFIF>
	</CFIF>
</CFQUERY>

	<script type="text/javascript" src="../../../cfide/scripts/wddx.js"></script>
	<script>
	<cfwddx action="cfml2js" input="#CurrentEntries#" topLevelVariable="qEntriesJS">	
	function dups(){
		t=document.getElementsByName("iTenant_ID"); c=document.getElementsByName("cCheckNumber");
		for (a=0;a<=qEntriesJS['itenant_id'].length-1;a++) {
			window.status=qEntriesJS['itenant_id'][a];
			if (t[0].value == qEntriesJS['itenant_id'][a] && c[0].value == qEntriesJS['cchecknumber'][a]) { 
				alert('***\r\tThis check has already been entered.\r***'); c[0].value=''; return false;
			}
		}
	}
	</script>


<TABLE CLASS="noborder" STYLE="text-align: left; font-weight: bold;">
 	<TR>	
		<CFIF (CashReceipts.RecordCount NEQ 0 AND CurrentEntries.RecordCount NEQ 0) OR SESSION.UserID IS 3025>
			<TD NOWRAP CLASS="Summary" STYLE='background:transparent;'> <A HREF="FinalizeCashReceipt.cfm?CRID=#Variables.iCashReceipt_ID#&Num=#Variables.iCashReceiptNumber#" onClick="setTimeout('disable(\'' + this.href + '\'),100')">	Finalize Deposit Slip & Print </A> </TD>
			<CFSET COLSPAN="COLSPAN=100%">
		<CFELSE> <CFSET COLSPAN=''> </CFIF>
		<TD CLASS="Summary" #COLSPAN# STYLE="text-align:right;background:transparent;"> 	
			<A HREF="HistoricCashReceipts.cfm?HID=#SESSION.qSelectedHouse.iHouse_ID#">	View Historic Deposit Slips </A> 
		</TD>
	</TR>
</TABLE>

<FORM NAME="CashReceipts" ACTION="#Variables.Action#" METHOD="POST" onSubmit="return validtenant();">
<INPUT TYPE="hidden" NAME="iCashReceiptNumber" VALUE="#Variables.iCashReceiptNumber#">
<INPUT TYPE="hidden" NAME="iCashReceipt_ID"	VALUE="#Variables.iCashReceipt_ID#">

	<TABLE>
		<TR> <TH>Name</TH> <TH>Check</TH> <TH>Check Date</TH> <TH>Amount</TH> </TR>
		<TR STYLE="text-align: center;">
		<CFIF IsDefined("url.ID")>
			<TD> #CashReceipts.cFirstName# #CashReceipts.cLastName#	</TD>
			<CFSCRIPT>
				cCheckNumber = CashReceipts.cCheckNumber; Month = Month(CashReceipts.dtCheckDate); Day = Day(CashReceipts.dtCheckDate); Year = Year(CashReceipts.dtCheckDate);
				cCheckNumber = CashReceipts.cCheckNumber; mAmount = CashReceipts.mAmount; cComments = TRIM(CashReceipts.cComments);
			</CFSCRIPT>
			<INPUT TYPE="hidden" NAME="iCashReceiptItem_ID"	VALUE="#CashReceipts.iCashReceiptItem_ID#">
			<INPUT TYPE="hidden" NAME="iTenant_ID"	VALUE="#CashReceipts.iTenant_ID#">
		<CFELSE>
			<CFSCRIPT>cCheckNumber = ""; Month = Month(Now()); Day = Day(Now()); Year = Year(Now()); cCheckNumber = ""; mAmount = ""; cComments = "";</CFSCRIPT>
			<TD>
				<SELECT NAME="iTenant_ID">
					<OPTION VALUE="">	*** Select Resident *** </OPTION>
					<CFLOOP QUERY = "AvailableTenants">
						<CFSCRIPT>
							if (AvailableTenants.bIsMedicaid NEQ "" OR AvailableTenants.bIsMisc NEQ "" OR AvailableTenants.bIsDayRespite NEQ "") {
								STYLE = 'STYLE="color: blue; background: gainsboro;"';}
							else{ STYLE=''; }
							if (Len(AvailableTenants.cAptNumber) GT 0){ aptnumber = '###AvailableTenants.cAptNumber#'; } else { aptnumber = ''; }
						</CFSCRIPT>
						<OPTION VALUE="#AvailableTenants.iTenant_ID#" #STYLE#>#aptnumber# #AvailableTenants.cLastName#, #AvailableTenants.cFirstName# (#AvailableTenants.cSolomonKey#)</OPTION>
					</CFLOOP>
				</SELECT>
			</TD>
		</CFIF>
			<TD> <INPUT TYPE="text" NAME="cCheckNumber" VALUE="#cCheckNumber#" SIZE="10" MAXLENGTH="10" onKeyUp="this.value=Numbers(this.value);"> </TD>
			<TD NOWRAP>
			
			<CFIF 0 IS 1>
			<!--- <CFIF SESSION.USERID IS 3025> --->
				<INPUT TYPE="TEXT" NAME="DATE" SIZE="10" MaxLength="10" VALUE="#DateFormat(Now(),"mm/dd/yyyy")#" onKeyUp="Dates(this);">
			<CFELSE>
				<SELECT NAME="Month" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year); dtcheck();">	
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> <CFIF Month EQ #I#> <CFSET SELECTED = 'Selected'> <CFELSE> <CFSET Selected = ''> </CFIF>
						<OPTION VALUE="#I#" #Selected#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/
				<SELECT NAME="Day" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year); dtcheck();">
					<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1"> <CFIF Day EQ I> <CFSET SELECTED = 'Selected'> <CFELSE> <CFSET Selected = ''> </CFIF>					
						<OPTION VALUE="#I#" #Selected#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/
				<CFIF Variables.Month NEQ 1> 
				<!---SS ---02/07/2008--- Commented this line as the request was made which needed even to select the previous year while putting the check.
					<INPUT TYPE="Text" NAME="Year" Value="#Year#" SIZE="3" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year); dtcheck();"> --->
					<CFSET LastYear = Year -1>
					<SELECT NAME="Year"  onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year); dtcheck();">
					<OPTION VALUE="#YEAR#"> #YEAR# </OPTION> <OPTION VALUE="#LastYear#"> #LastYear# </OPTION></SELECT>	
				<CFELSE>
					<CFSET LastYear = Year -1>
					<SELECT NAME="Year"><OPTION VALUE="#YEAR#"> #YEAR# </OPTION> <OPTION VALUE="#LastYear#"> #LastYear# </OPTION></SELECT>		
				</CFIF>
			
			</CFIF>
			</TD>
			<TD> <INPUT TYPE="TEXT" Name="mAmount" VALUE="#LSCurrencyFormat(mAmount , "none")#" SIZE="10" MAXLENGTH="8" STYLE="text-align: right;" onKeyUp="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(Numbers(this.value)));"> </TD>			
		</TR>
		<TR><TD COLSPAN=100% STYLE="font-weight: bold;">Comments:<BR><TEXTAREA COLS="60" ROWS="2" NAME="cComments">#TRIM(variables.cComments)#</TEXTAREA></TD></TR>
		<TR>	
			<TD STYLE="text-align:Left;"> <INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" onClick="return validtenant();"> </TD>
			<TD COLSPAN=2></TD>
			<TD STYLE="text-align:right;"><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="redirect()"></TD>
		</TR>
		<TR><TD COLSPAN=100% STYLE="font-weight: bold; color: red;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </TD></TR>
	</TABLE>
	
<BR>
</FORM>

<FORM ACTION="CashReceiptCSV.cfm" METHOD="Post">	
	<TABLE CLASS="noborder">	
		<TR>	
			<TD CLASS="Summary"> Deposit Number - #Variables.iCashReceiptNumber# </TD>	
			<TD COLSPAN="3" CLASS = "Summary" STYLE="text-align: left;">
				<CFIF SESSION.USERID IS 3025 OR ListFindNoCase(session.Codeblock,23) GT 1>
					<!--- Retrieve All Valid DepositSlips for the house --->
					<CFQUERY NAME="qGetSlips" DATASOURCE="#APPLICATION.datasource#">
						SELECT * FROM CashReceiptMaster CM (NOLOCK)
						WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND	dtRowDeleted IS NULL AND bFinalized IS NOT NULL
						ORDER BY iCashReceiptNumber 
					</CFQUERY>
				
					<B STYLE="font-size: 12;">Re-Create Slip CSV</B>
					<SELECT NAME="Slip">
					<CFLOOP QUERY="qGetSlips">
					<OPTION VALUE="#qGetSlips.iCashReceipt_ID#"><CFIF SESSION.USERID EQ 3025>#qGetSlips.iCashReceipt_ID# </CFIF> #qGetSlips.iCashReceiptNumber# #DateFormat(qGetSlips.dtRowStart,"mm/dd/yy")# </OPTION>
					</CFLOOP>
					</SELECT>
				
					<INPUT TYPE="Submit" NAME="Go" VALUE="GO" onClick="submit();">
				<CFELSE>
					<CFIF ListFindNoCase(session.Codeblock,22) GT 1 OR ListFindNoCase(session.Codeblock,23) GT 1
					OR ListFindNoCase(session.Codeblock,24) GT 1 OR ListFindNoCase(session.Codeblock,25) GT 1>
						<A HREF="CashReceiptCSV.cfm?ReceiptID=#Variables.iCashReceipt_ID#" STYLE="color: gold; background: indigo;"> Create Deposit Slip CSV </A>
					</CFIF>
				</CFIF>
			</TD>	
		</TR>
	</TABLE>

	<TABLE>			
		<TR>	
			<TH> <A HREF="CashReceipts.cfm?SelectOrderBy=Name" STYLE="COLOR: WHITE;"> Name </A></TH>
			<TH> <A HREF="CashReceipts.cfm?SelectOrderBy=TenantID" STYLE="COLOR: WHITE;"> Resident ID </A></TH>
			<TH> <A HREF="CashReceipts.cfm?SelectOrderBy=Apt" STYLE="COLOR: WHITE;"> Apt </A></TH>		
			<TH> <A HREF="CashReceipts.cfm?SelectOrderBy=Check" STYLE="COLOR: WHITE;"> Check </A></TH>	
			<TH> <A HREF="CashReceipts.cfm?SelectOrderBy=CheckDate" STYLE="COLOR: WHITE;"> Check Date </A></TH>
			<TH> <A HREF="CashReceipts.cfm?SelectOrderBy=Amount" STYLE="COLOR: WHITE;"> Amount </A></TH>	
			<TH> Current Balance </TH>
			<TH> Delete </TH>
		</TR>

<CFIF CurrentEntries.RecordCount GT 0 >
	<CFSET TOTAL = 0>	
	<CFLOOP QUERY="CurrentEntries">		
		<CFSET TOTAL = TOTAL + 	CurrentEntries.mAmount>
		<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
			<CFSET rl='CashReceipts.cfm?ID=#CurrentEntries.iTenant_ID#&item=#CurrentEntries.iCashReceiptItem_ID#'>
			<TD STYLE = "text-align: left;"><A HREF ="#rl#"> #CurrentEntries.cFirstName# #CurrentEntries.cLastName# </A></TD>
			<TD> #CurrentEntries.cSolomonKey# </TD>	
			<TD> #CurrentEntries.cAptNumber# </TD>		
			<TD> #CurrentEntries.cCheckNumber# </TD>
			<TD> #DateFormat(CurrentEntries.dtCheckDate, "mm/dd/yyyy")#</TD>
			<TD STYLE = "text-align: right;">	#LSCurrencyFormat(CurrentEntries.mAmount)#			</TD>	
			<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>	<CFQUERY NAME="CurrentBalance" DATASOURCE="SOLOMON-HOUSES"> exec tips_GetCurrBal '#CurrentEntries.cSolomonKey#' </CFQUERY> </CFIF>
			<TD STYLE="text-align: right;"> <CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>#LSCurrencyFormat(CurrentBalance.currbal)#<CFELSE>ZetaTest</CFIF> </TD>
			<TD> <INPUT CLASS="BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteCashReceipt.cfm?itemID=#CurrentEntries.iCashReceiptItem_ID#'"> </TD>	
		</cf_ctTR>
	</CFLOOP>
		<TR STYLE="text-align: right; font-weight; bold;"> <TD COLSPAN=7>Total Number of Checks</TD><TD> #CurrentEntries.RecordCount#	</TD> </TR>
		<TR STYLE="text-align: right; font-weight; bold;"> <TD COLSPAN=7> Cash Receipts Total </TD><TD> #LSCurrencyFormat(Total)# </TD> </TR>
	</TABLE>
<CFELSE>
	<TR> <TD COLSPAN="8" STYLE="font-weight: bold;"> There are no entries at this time.	</TD></TR>	
	</TABLE>
</CFIF>

</FORM>

</CFOUTPUT>

<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">