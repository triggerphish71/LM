<!--- *******************************************************************************
Name:			MoveOutForm.cfm
Process:		MoveOut entry form

Called by: 		MainMenu.cfm
Calls/Submits:	MoveOutUpdate
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            02/11/2002      Changed default on move out date and 
										notice date to default the historical
										data thereby after calculating number
										of days in month
										
Paul Buendia			02192002		Changed Daily Rate/Monthly rate displays
										to accomidate respite tenants. (ie. no monthly
										rent amounts)
Steve Davison			02192002		Fixed target chargethrough date to add 29 days instead of 30.
Steve Davison			04/22/2002		Added check for companion suite when determining occupancy	
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                 							
******************************************************************************** --->

<CFIF SESSION.UserID IS 3025 AND IsDefined("form.fieldnames")>
	<CFOUTPUT>	#form.fieldnames# </CFOUTPUT>
</CFIF>

<!--- ==============================================================================
Javascript Validation
=============================================================================== --->
<script>
	function validdate(){
		if (document.forms[0].Reason.value == ''){
			alert('A reason must be specified.');
			document.forms[0].Reason.focus();
		}
		
		var miyear = (document.MoveOutForm.moveinyear.value);
		var mimonth = ((document.MoveOutForm.moveinmonth.value) - 1);
		var miday = (document.MoveOutForm.moveinday.value);
		var movein = new Date(miyear, mimonth, miday);
		
		var moyear = (document.MoveOutForm.MoveOutYear.value);
		var momonth = ((document.MoveOutForm.MoveOutMonth.value) - 1);
		var moday = (document.MoveOutForm.MoveOutDay.value);
		var moveout = new Date(moyear, momonth, moday);
		
		var noyear = (document.MoveOutForm.NoticeYear.value);
		var nomonth = ((document.MoveOutForm.NoticeMonth.value) - 1);
		var noday = (document.MoveOutForm.NoticeDay.value);
		var notice = new Date(noyear, nomonth, noday);
		
		var chyear = (document.MoveOutForm.ChargeYear.value);
		var chmonth = ((document.MoveOutForm.ChargeMonth.value) - 1);
		var chday = (document.MoveOutForm.ChargeDay.value);
		var charge = new Date(chyear, chmonth, chday);		
	
		if (movein > moveout){
			var message = ('The MoveOut is before the movein date \r' + 'which is' + ' ' + movein);
			alert(message);
			return false;
		}
		
		else if (movein > notice){
			var message = ('The Notice is before the movein date \r' + 'which is' + ' ' + movein);
			alert(message);
			return false;
		}
		else if (movein > charge){
			var message = ('The Charge Date is before the movein date \r' + 'which is' + ' ' + movein);
			alert(message);
			return false;
		}
		else{
		return true;
		}
	}
	
	//functions cent and round are from developer.irt.org FAQ (no authors specified)	
	function CreditNumbers(string) {
		for (var i=0, output='', valid="1234567890.-"; i<string.length; i++)
	       if (valid.indexOf(string.charAt(i)) != -1)
	       output += string.charAt(i)
	   	return output;
	} 	
		
	
	function mocent(amount) {
	//CODE originally from developer.it.org
	// returns the amount in the .99 format
	amount -= 0;
	return (amount == Math.floor(amount)) ? amount + '.00' : (  (amount*10 == Math.floor(amount*10)) ? amount + '0' : amount);
	}


	function moround(number,X) {
	// rounds number to X decimal places, defaults to 2
	X = (!X ? 2 : X);
	return Math.round(number*Math.pow(10,X))/Math.pow(10,X);
	}

	
	function decimal(){
	document.MoveOutForm.DamageAmount.value = mocent(moround(document.MoveOutForm.DamageAmount.value)); 
	document.MoveOutForm.OtherAmount.value = mocent(moround(document.MoveOutForm.OtherAmount.value));
	return;
	}
	
	
	function OtherTotal() {
		if ( (eval(document.MoveOutForm.OtheriQuantity.value)<0) || (eval(document.MoveOutForm.OtherAmount.value)<0)) {	
			(factor = -1);}
		else { (factor = 1); }
	
	qty = (document.MoveOutForm.OtheriQuantity.value*1);
	amt = (document.MoveOutForm.OtherAmount.value*1);
	total = (qty * amt);
	document.MoveOutForm.CalculatedOtherAmount.value = mocent(moround(total));
	return;
	}
	
	
	function set(What,Value) {
	//alert(What + '\n' + Value);
	    if (document.layers && document.layers[What] != null) document.layers[What].visibility = Value;
	   else if (document.all) eval('document.all.'+What+'.style.visibility ="'+ Value+'"');
	}
	
	function clicked(Form,list,Layer) {
	    for (var i=0; i<Form[list].length; i++) {
	        if (Form[list][i].value = '') set(Layer,visible);
	    }
	}	
	
	function evaluate(){
		if (document.MoveOutForm.OtheriChargeType_ID.value != ''){ set('myLayer','visible'); return false; }
		else { set('myLayer','hidden'); return true; }
	}
	
	function required(){ var failed = false; validdate(); return;}

	function dateAdd( start, interval, number ) {
		
	    // Create 3 error messages, 1 for each arASHent. 
	    var startMsg = "Sorry the start parameter of the dateAdd function\n"
	        startMsg += "must be a valid date format.\n\n"
	        startMsg += "Please try again." ;
			
	    var intervalMsg = "Sorry the dateAdd function only accepts\n"
	        intervalMsg += "d, h, m OR s intervals.\n\n"
	        intervalMsg += "Please try again." ;
	
	    var numberMsg = "Sorry the number parameter of the dateAdd function\n"
	        numberMsg += "must be numeric.\n\n"
	        numberMsg += "Please try again." ;
			
	    // get the milliseconds for this Date object. 
	    var buffer = Date.parse( start ) ;
		
	    // check that the start parameter is a valid Date. 
	    if ( isNaN (buffer) ) {
	        alert( startMsg ) ;
	        return null ;
	    }
		
	    // check that an interval parameter was not numeric. 
	    if ( interval.charAt == 'undefined' ) {
	        // the user specified an incorrect interval, handle the error. 
	        alert( intervalMsg ) ;
	        return null ;
	    }
	
	    // check that the number parameter is numeric. 
	    if ( isNaN ( number ) )	{
	        alert( numberMsg ) ;
	        return null ;
	    }
	
	    // so far, so good...
	    //
	    // what kind of add to do? 
	    switch (interval.charAt(0))
	    {
	        case 'd': case 'D': 
	            number *= 24 ; // days to hours
	            // fall through! 
	        case 'h': case 'H':
	            number *= 60 ; // hours to minutes
	            // fall through! 
	        case 'm': case 'M':
	            number *= 60 ; // minutes to seconds
	            // fall through! 
	        case 's': case 'S':
	            number *= 1000 ; // seconds to milliseconds
	            break ;
	        default:
	        // If we get to here then the interval parameter
	        // didn't meet the d,h,m,s criteria.  Handle
	        // the error. 		
	        alert(intervalMsg) ;
	        return null ;
	    }
	    return new Date( buffer + number ) ;
	}

	function setTargetChargeThrough(bit){
		var ctyear = (document.MoveOutForm.NoticeYear.value);
		var ctmonth = ((document.MoveOutForm.NoticeMonth.value) - 1);
		var ctday = (document.MoveOutForm.NoticeDay.value);
		var ctdate = new Date(ctyear, ctmonth, ctday);
		var tctdate = dateAdd(ctdate, 'D', 29);
		//alert(tctdate.getMonth() + 1 + ' / ' + tctdate.getDate() + ' / ' + tctdate.getYear());
		//if (typeof bit == "undefined") {
		//	bit = 0;
		//}
		bit = (bit * 1);
		switch (bit) {
			case 0:
				document.MoveOutForm.dtChargeThroughTarget.value = "Involuntary";
				break;
			default:
				document.MoveOutForm.dtChargeThroughTarget.value = tctdate.getMonth() + 1 + ' / ' + tctdate.getDate() + ' / ' + tctdate.getYear();
		}
		return true;
	}
//-->
</SCRIPT>

<CFIF IsDefined("form.iTenant_ID")> <CFSET URL.ID=#form.iTenant_ID#> </CFIF>
<CFIF IsDefined("url.ID")> <CFSET form.iTenant_ID=#url.ID#> </CFIF>

<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(GetDate.Stamp)>


<!--- ==============================================================================
Retreive the Tenants Information
=============================================================================== --->
<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	T.*, TS.iTenantState_ID,
			TS.dtMoveIn, TS.iSPoints, TS.dtChargeThrough, TS.dtMoveOut, 
			TS.dtNoticeDate, TS.iTenantStateCode_ID, TS.iResidencyType_ID,
			AD.cAptNumber, AD.iAptAddress_ID,
			AT.cDescription as AptType, AT.iAptType_ID,
			RT.cDescription as Residency,
			MT.cDescription as Reason, MT.iMoveReasonType_ID
	FROM	Tenant T
			LEFT JOIN	TenantState TS	ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
			LEFT JOIN	AptAddress AD	ON (AD.iAptAddress_ID = TS.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
			LEFT JOIN	AptType AT		ON (AT.iAptType_ID = AD.iAptType_ID AND AT.dtRowDeleted IS NULL)
			LEFT JOIN	ResidencyType RT ON (TS.iResidencyType_ID = RT.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
			LEFT JOIN	MoveReasonType MT ON (TS.iMoveReasonType_ID = MT.iMoveReasonType_ID AND MT.dtRowDeleted IS NULL)
	WHERE	T.iTenant_ID = #url.ID#
	AND		T.dtRowDeleted IS NULL
</CFQUERY>


<CFIF IsDefined("url.stp") AND Url.STP GTE 4 AND SESSION.userID EQ 3025>
	<!--- ==============================================================================
	Check for an Existing Move Out Invoice
	=============================================================================== --->
	<CFQUERY NAME = "InvoiceCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	distinct IM.*
		FROM	InvoiceMaster IM
		JOIN	InvoiceDetail INV	ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
		WHERE	IM.cSolomonKey = '#Tenant.cSolomonKey#'
		AND		INV.iTenant_ID = #url.ID#
		AND		bMoveOutInvoice IS NOT NULL
		AND		IM.dtRowDeleted IS NULL
	</CFQUERY>
	
	<CFIF InvoiceCheck.RecordCount EQ 0>
		<CFQUERY NAME = "InvoiceCheck" DATASOURCE="#APPLICATION.datasource#">
			SELECT	top 1 IM.*
			FROM	InvoiceMaster IM
			WHERE	IM.cSolomonKey = '#Tenant.cSolomonKey#'
			AND		bMoveOutInvoice IS NOT NULL
			AND		IM.dtRowDeleted IS NULL
			AND		IM.bFinalized IS NULL
			ORDER BY dtRowStart desc
		</CFQUERY>	
	</CFIF>
	
<!--- ==============================================================================
	If there no available invoice. 
	We get the next number from house number control and update the invoice master table
=============================================================================== --->
<CFIF InvoiceCheck.RecordCount LTE 0>
		<CFSET CurrPer = #Year(SESSION.TIPSMonth)# & #DateFormat(SESSION.TIPSMonth,"mm")#>

		<!--- ==============================================================================
		Retrieve the next invoice number
		=============================================================================== --->
		<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iNextInvoice
			FROM	HouseNumberControl
			WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND		dtRowDeleted IS NULL
		</CFQUERY>

		<CFSET HouseNumber = #SESSION.HouseNumber#>	
		<CFSET iInvoiceNumber = '#Variables.HouseNumber#'&#GetNextInvoice.iNextInvoice#>

		<!--- ==============================================================================
		Retrieve the start date of current invoice
		=============================================================================== --->
		<CFQUERY NAME="CurrentInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	IM.iInvoiceMaster_ID, IM.dtInvoiceStart, IM.dtInvoiceEnd
			FROM	InvoiceMaster IM
			JOIN	InvoiceDetail INV	ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
			WHERE	bFinalized IS NULL
			AND		bMoveOutInvoice IS NULL
			AND		IM.dtRowDeleted IS NULL
			AND		INV.iTenant_ID = #Tenant.iTenant_ID#
			AND		IM.cSolomonKey = '#Tenant.cSolomonKey#'
			AND		IM.cAppliesToAcctPeriod = '#CurrPer#'
		</CFQUERY>

		<!--- ==============================================================================
		Calculate and Record a new Invoice Number
		=============================================================================== --->
		<CFQUERY NAME = "NewInvoice" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO 	InvoiceMaster
							(	iInvoiceNumber, 
								cSolomonKey, 
								bMoveOutInvoice, 
								bFinalized, 
								cAppliesToAcctPeriod, 
								cComments, 
								dtAcctStamp,
								dtInvoiceStart, 
								iRowStartUser_ID, 
								dtRowStart
							)VALUES(
								<CFSET iInvoiceNumber = '#Variables.iInvoiceNumber#' & 'MO'>
								'#Variables.iInvoiceNumber#',
								'#Tenant.cSolomonKey#',
								1,
								NULL,
								<CFSET AppliesTo = #Year(SESSION.TipsMonth)# & #DateFormat(SESSION.TipsMonth, "mm")#>
								'#Variables.AppliesTo#',
								NULL,
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								<CFIF CurrentInvoice.RecordCount GT 0  AND CurrentInvoice.dtInvoiceStart NEQ "">	'#CurrentInvoice.dtInvoiceStart#', <CFELSE> #TimeStamp#, </CFIF>
								#SESSION.UserID#,
								GETDATE()
							)
		</CFQUERY>
		<CFSET iNewNextInvoice = #GetNextInvoice.iNextInvoice# + 1>
		<!--- ==============================================================================
		Increment the next Invoice Number in the HouseNumberControl Table
		=============================================================================== --->
		<CFQUERY NAME = "HouseNumberControl" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	HouseNumberControl
			SET		iNextInvoice 	= #Variables.iNewNextInvoice#
			WHERE	iHouse_ID 		= #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>

		<!--- ==============================================================================
		Retrieve the Invoice Master ID that was created above
		=============================================================================== --->
		<CFQUERY NAME="NewMasterID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceMaster_ID, dtInvoiceStart, dtInvoiceEnd
			FROM	InvoiceMaster
			WHERE	cSolomonKey ='#Tenant.cSolomonKey#'
			AND		bMoveOutInvoice IS NOT NULL
			AND		bFinalized IS NULL
			AND		dtRowDeleted IS NULL
			AND		iInvoiceNumber = '#Variables.iInvoiceNumber#'
		</CFQUERY>
		<CFSET Variables.iInvoiceMaster_ID = #NewMasterID.iInvoiceMaster_ID#>
		<CFSET dtInvoiceStart = #NewMasterID.dtInvoiceStart#>
	<CFELSE>
		<CFSET iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#>
		<CFSET iInvoiceNumber = '#InvoiceCheck.iInvoiceNumber#'>			
		<CFSET dtInvoiceStart = #InvoiceCheck.dtInvoiceStart#>
	</CFIF>

		<!--- ==============================================================================
		Retrieve the current open invoice and its transactions
		=============================================================================== --->
		<CFQUERY NAME="CurrentInvoice" DATASOURCE="#APPLICATION.datasource#">
			SELECT	INV.*
			FROM	InvoiceMaster IM
			JOIN	InvoiceDetail INV	ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
			WHERE	IM.dtRowDeleted IS NULL
			AND		INV.dtRowDeleted IS NULL
			AND		IM.bMoveInInvoice IS NULL
			AND		IM.bMoveOutInvoice IS NULL
			AND		IM.bFinalized IS NULL
			AND		INV.iTenant_ID = #url.ID#
		</CFQUERY>
</CFIF>

<!--- ==============================================================================
Calculate and create a charge through variable
=============================================================================== --->
	<CFIF Tenant.dtChargeThrough EQ "" AND NOT IsDefined("form.ChargeYear")>
		<CFSET dtChargeThrough = Now()>
		<CFSET dtChargeDayOne = Now()>
	<CFELSEIF IsDefined("form.ChargeYear")>	
		<CFSET dtChargeThrough = #CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & form.ChargeDay)#>
		<CFSET dtChargeDayOne = #CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & '01')#>
	<CFELSE>
		<CFSET dtChargeThrough 	= #Tenant.dtChargeThrough#>
		<CFSET form.ChargeYear 	= #Year(Tenant.dtChargeThrough)#>
		<CFSET form.ChargeMonth = #Month(Tenant.dtChargeThrough)#>
		<CFSET form.ChargeDay 	= #Day(Tenant.dtChargeThrough)#>
		<CFSET dtChargeDayOne = #CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & '01')#>
	</CFIF>

<!--- ==============================================================================
Retrieve the last invoice end date for the following solomon query
=============================================================================== --->
<CFQUERY NAME = "StartRange" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	MAX(dtInvoiceStart) as dtInvoiceEnd
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
	WHERE	bMoveOutInvoice IS NULL
	AND		bFinalized IS NOT NULL
	AND		INV.iTenant_ID = #Url.ID#
</CFQUERY>

<CFIF StartRange.RecordCount GT 0>
	<CFSET StartRange = #StartRange.dtInvoiceEnd#>
<CFELSE>
	<CFSET StartRange = '2001-01-01'>
</CFIF>

<!--- ==============================================================================
Retrieve Solomon Transactions to Date.
Original code written by John Lian for Solomon Lookup.
=============================================================================== --->
<CFQUERY NAME="Statements" DATASOURCE="SOLOMON-HOUSES">
	SELECT 	doctype, refnbr, docdate, docdesc, custid, user1, user3, user7, PerClosed,
			amount = 	CASE 	WHEN doctype in ('PA','CM') then -origdocamt 	ELSE origdocamt END
						,CASE	WHEN doctype = 'PA' then 'Payment' WHEN	doctype = 'IN' then 'Invoice'
								ELSE 'Other'
						END as Type
	FROM 	ardoc (NOLOCK)
	WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
	AND		doctype = 'PA'
	AND		docdate between '#Variables.StartRange#' and '#DateFormat(Now(), "yyyy-mm-dd")#'
	ORDER BY PerClosed, type
</CFQUERY>

<!--- ==============================================================================
Retrieve Solomon Transactions to Date.
Original code written by John Lian for Solomon Lookup.
=============================================================================== --->
<CFQUERY NAME = "StatementsTotal" DATASOURCE = "SOLOMON-HOUSES">
	SELECT 	sum(OrigDocAmt) as Total
	FROM 	ardoc
	WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
	AND		doctype = 'PA'
	AND		docdate between '#Variables.StartRange#' and '#DateFormat(Now(), "yyyy-mm-dd")#'
	GROUP BY doctype, refnbr, docdate, docdesc, custid, user1, user3, user7, PerClosed, OrigDocAmt
	ORDER BY PerClosed
</CFQUERY>

<!--- ==============================================================================
Retrieve any Move Out Charges already created for this tenant
=============================================================================== --->
<CFQUERY NAME = "MoveOutCharges" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*, INV.cComments as Comments,
			IM.cComments as InvoiceComments
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
	JOIN	ChargeType CT		ON CT.iChargeType_ID = INV.iChargeType_ID
	WHERE	INV.iTenant_ID = #form.iTenant_ID#
	AND		IM.bMoveOutInvoice IS NOT NULL
	AND		INV.dtRowDeleted IS NULL
</CFQUERY>

<CFSET DamageComments = ''>
<CFSET OtherComments = ''>

<!--- ==============================================================================
Retreive the Solomon Past Balance for this tenant
=============================================================================== --->
<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>
		
	<CFSET PerPost = #Year(SESSION.AcctStamp)# & #DateFormat(SESSION.AcctStamp,"mm")#>
	
	<CFQUERY NAME = "PastBalance" DATASOURCE = "SOLOMON-HOUSES">		
		SELECT 	sum(case when doctype in ('PA','CM') THEN -origdocamt ELSE origdocamt end) as PastDue
		FROM 	ARDOC
		WHERE 	custid='#Tenant.cSolomonKey#'
		AND		PerPost = '#PerPost#'
	</CFQUERY>
</CFIF>

<!--- ==============================================================================
Check to see if the points are within range of this set
=============================================================================== --->
<CFQUERY NAME="qGetMinMax" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Min(iSPointsMin) as MinimumPoints, Max(iSPointsMax) As MaxPoints
	FROM	SLevelType
	<CFIF Tenant.cSLevelTypeSet EQ "">
		WHERE	cSLevelTypeSet 	= #SESSION.cSLevelTypeSet#
	<CFELSE>
		WHERE	cSLevelTypeSet = #Tenant.cSLevelTypeSet#
	</CFIF>
</CFQUERY>`

<CFIF Tenant.iSPoints LT qGetMinMax.MinimumPoints OR Tenant.iSPoints GT qGetMinMax.MaxPoints>
<CFOUTPUT>
	<TABLE>	
		<TR>
			<TD COLSPAN="100%" STYLE="background: lightyellow; color: red; font-size: 16; text-align: center; border: thin solid navy;">
				<B>The service points are out of range for the set assigned to #Tenant.cFirstName# #Tenant.cLastName#<BR> 
				Please, verify the service Level Information and try again.
				</B>
			</TD>
		</TR>
		<TR><TD><A HREF="../MainMenu.cfm">Click Here to Return to the Summary Section</A></TD></TR>
	</TABLE>
	<CFABORT>
</CFOUTPUT>	
</CFIF>

<!--- ==============================================================================
Retrieve the ServiceLevel
=============================================================================== --->
<CFQUERY NAME = "GetSLevel" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 	* 
	FROM 	SLevelType
	<CFIF Tenant.cSLevelTypeSet EQ "">
		WHERE	cSLevelTypeSet 	= #SESSION.cSLevelTypeSet#
	<CFELSE>
		WHERE	cSLevelTypeSet = #Tenant.cSLevelTypeSet#
	</CFIF>
	AND	iSPointsMin  		<= #Tenant.iSPoints#
	AND	iSPointsMax 		>= #Tenant.iSPoints#
	AND	dtRowDeleted IS NULL
</CFQUERY>


<!--- ==============================================================================
Stored Proc. to find the date the tenant dropped to state 3
=============================================================================== --->
<CFQUERY NAME="FindDtStateChange" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	isnull(min(stateDtRowStart), getdate()) dtStateChange
	FROM	vw_Tenant_History_with_State
	WHERE	iAptAddress_ID = #Tenant.iAptAddress_ID#
	AND		iTenantStateCode_ID = 3
	AND		tendtRowDeleted IS NULL
	AND		statedtRowDeleted IS NULL
	AND		cSolomonKey = '#Tenant.cSolomonKey#'
	AND		iTenant_ID = #Tenant.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Stored Proc. to find if there is another tenant in the room
=============================================================================== --->
<CFQUERY NAME="FindOccupancy" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	vw_Tenant_History_with_State
	WHERE	iAptAddress_ID = #Tenant.iAptAddress_ID#
	AND		iTenantStateCode_ID = 2
	AND		tendtRowDeleted IS NULL
	AND		statedtRowDeleted IS NULL
	AND		<CFIF IsDefined("FindDtStateChange.dtStateChange") AND FindDtStateChange.dtStateChange LTE NOW()>#CreateODBCDateTime(FindDtStateChange.dtStateChange)#<CFELSE>getdate()</CFIF> between tendtRowStart and isnull(tendtRowEnd, getDate())
	AND		<CFIF IsDefined("FindDtStateChange.dtStateChange") AND FindDtStateChange.dtStateChange LTE NOW()>#CreateODBCDateTime(FindDtStateChange.dtStateChange)#<CFELSE>getdate()</CFIF> between statedtRowStart and isnull(statedtRowEnd, getDate())
	AND		cSolomonKey = '#Tenant.cSolomonKey#'
	AND		iTenant_ID <> #Tenant.iTenant_ID#
	ORDER BY iSPoints DESC
</CFQUERY>

<!--- ==============================================================================
Get Acuity Level of other Tenant (if exists)
=============================================================================== --->
<CFIF FindOccupancy.RecordCount GT 0>
	<CFQUERY NAME="qOtherTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT 	*, SLT.cDescription as Level
		FROM 	Tenant T
		JOIN	SLevelType SLT	ON SLT.cSLevelTypeSet = T.cSLevelTypeSet
		JOIN	TenantState TS	ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
		WHERE	T.dtRowDeleted IS NULL
		AND		SLT.dtRowDeleted IS NULL
		AND	iSPointsMin <= #FindOccupancy.iSPoints#
		AND	iSPointsMax >= #FindOccupancy.iSPoints#
		AND	T.iTenant_ID <> #Tenant.iTenant_ID#
		AND	T.cSolomonKey = '#Tenant.cSolomonKey#'
	</CFQUERY>
	
</CFIF>

<CFIF IsDefined("PastBalance.RecordCount") AND PastBalance.RecordCount GT 0 AND FindOccupancy.RecordCount EQ 1>
	<CFSET PastDue = #PastBalance.PastDue#>
<CFELSE>
	<CFSET PastDue = 0.00>
</CFIF>

<CFIF FindOccupancy.RecordCount GT 0>
	<CFSET Occupancy = 2>	
<CFELSE>
	<CFSET Occupancy = 1>
</CFIF>

<CFQUERY NAME="CheckCompanionFlag" DATASOURCE="#APPLICATION.datasource#">
	SELECT	bIsCompanionSuite
	FROM	AptAddress AD
	JOIN	AptType AT ON (AD.iAptType_ID = AT.iAptType_ID AND AT.dtRowDeleted is NULL)
	WHERE	AD.dtRowDeleted IS NULL
	AND		AD.iAptAddress_ID = #Tenant.iAptAddress_ID#
</CFQUERY>

<CFIF CheckCompanionFlag.bIsCompanionSuite EQ 1>
	<CFSET Occupancy = 1>
</CFIF>

<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut NEQ "">
	<CFSET dtMoveOut=#Tenant.dtMoveOut#>
<CFELSE>
	<CFSET dtMoveOut=#Now()#>
</CFIF>


<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
	<CFIF Tenant.iResidencyType_ID NEQ 3>
		EXEC sp_MoveOutMonthlyRate @iTenant_ID=#Tenant.iTenant_ID#, @dtComparison=<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF> 
	<CFELSE>
		SELECT  *
		FROM	Charges
		WHERE	iHouse_ID = #Tenant.iHouse_ID#
		AND		iResidencyType_ID = #Tenant.iResidencyType_ID#
		AND 	iOccupancyPosition = #Occupancy#
		AND		(iAptType_ID = #Tenant.iAptType_ID# OR iAptType_ID IS NULL)
		AND		dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
		AND		dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
	</CFIF>
</CFQUERY>

<CFIF StandardRent.mAmount LTE 0>
	<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
		SELECT  *
		FROM	Charges C
		JOIN	ChargeType CT ON CT.iChargeType_ID = C.iChargeType_ID
		WHERE	C.iHouse_ID = #Tenant.iHouse_ID#
		AND		C.iResidencyType_ID = #Tenant.iResidencyType_ID#
		AND 	C.iOccupancyPosition = #Occupancy#
		AND		C.iSLevelType_ID = #GetSLevel.iSLevelType_ID#
		AND		CT.bIsDaily IS NULL
		AND		C.iAptType_ID <CFIF Tenant.iResidencyType_ID NEQ 3 AND Occupancy EQ 1>= #Tenant.iAptType_ID#<CFELSE>IS NULL</CFIF>
		AND		C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
		AND		C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
	</CFQUERY>
</CFIF>


<!--- ==============================================================================
If the Tenant is not respite devide std. rent by num days or 30
if is respite do not divide as respites do not have a monthly rate
=============================================================================== --->
<CFIF Tenant.iResidencyType_ID NEQ 3>
	<CFIF Tenant.iResidencyType_ID EQ 2><CFSET resdays=#DaysInMonth(Variables.dtChargeThrough)#><CFELSE><CFSET resdays=30></CFIF>
	
	<CFIF StandardRent.mAmount EQ "" OR StandardRent.mAmount EQ 0>
		<CFSET DailyRentCalc = 0.00>
	<CFELSE>
		<CFSET DailyRentCalc = #StandardRent.mAmount#/#resdays#>			
	</CFIF>
	

<CFELSE>		
	<CFSET DailyRentCalc = #StandardRent.mAmount#>
</CFIF>
<CFSET DailyRent = #NumberFormat(DailyRentCalc,"-9999999.99")#>


<!--- ==============================================================================
Retreive a List of Current ChargeTypes
=============================================================================== --->
<CFQUERY NAME="ChargeTypes" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct CT.*, CT.cDescription as Description
	FROM	ChargeType CT
	JOIN	Charges C ON (C.iChargeType_ID = CT.iChargeType_ID AND C.dtRowDeleted IS NULL)
	WHERE	CT.dtRowDeleted IS NULL
	ORDER BY CT.cDescription
</CFQUERY>

<!--- ==============================================================================
Retrieve the charges for the chosen charge type
C.iChargeType_ID = #form.OtheriChargeType_ID#
=============================================================================== --->
<CFQUERY NAME="ChargesList" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct CT.bIsDaily, C.*
	FROM	Charges C
	JOIN	ChargeType CT ON (C.iChargeType_ID = CT.iChargeType_ID
				AND		C.dtEffectiveStart <= GetDate()
				AND		C.dtEffectiveEnd >= GetDate()	
				AND		(C.iAptType_ID = #Tenant.iAptType_ID# OR C.iAptType_ID IS NULL))	
	LEFT OUTER JOIN	SLevelType ST ON (ST.iSLevelType_ID = C.iSLevelType_ID
				AND	ST.cSLevelTypeSet = #Tenant.cSLevelTypeSet#)
	WHERE	(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR iHouse_ID IS NULL)	
	AND		C.dtRowDeleted IS NULL
	AND		CT.dtRowDeleted IS NULL
	AND		ST.dtRowDeleted IS NULL
	ORDER BY C.cDescription
</CFQUERY>

<!--- ==============================================================================
Retrieve sum of all current charges
=============================================================================== --->
<CFQUERY NAME="Charges" DATASOURCE="#APPLICATION.datasource#">
	SELECT	SUM(INV.mAmount * INV.iQuantity) as SUM
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	JOIN	ChargeType CT		ON CT.iChargeType_ID = INV.iChargeType_ID
	WHERE	bMoveInInvoice IS NULL
	AND		INV.iTenant_ID = #url.ID# 
	AND		INV.dtRowDeleted IS NULL
	AND		IM.bMoveOutInvoice IS NOT NULL
</CFQUERY>

<SCRIPT>
	function ext(){
		calcext = (document.forms[0].otherAmount.value * document.forms[0].otheriQuantity.value);
		extend = cent(round(calcext));
		document.forms[0].otherextended.value = extend;
	}
	function resetother(){
		document.all['EditCharge'].innerHTML='';
	}
	function submitsave(){
		document.forms[0].action='MoveOutUpdate.cfm?edit=1';
		document.forms[0].submit();
	}
	<CFOUTPUT>
		//alert(string.value);
		<CFLOOP QUERY="ChargeTypes">
		
			<CFQUERY NAME="ChargesList" DATASOURCE="#APPLICATION.datasource#">
				SELECT	distinct CT.bIsDaily, C.*, CT.*, C.cDescription as cDescription
				FROM	Charges C
				JOIN	ChargeType CT ON (C.iChargeType_ID = CT.iChargeType_ID
							AND		C.dtEffectiveStart <= GetDate()
							AND		C.dtEffectiveEnd >= GetDate()	
				<CFIF ChargeTypes.bAptType_ID NEQ ''> AND (C.iAptType_ID = #Tenant.iAptType_ID# OR C.iAptType_ID IS NULL) </CFIF>)
				<CFIF ChargeTypes.bSLevelType_ID NEQ ''> JOIN	SLevelType ST ON (ST.iSLevelType_ID = C.iSLevelType_ID AND ST.cSLevelTypeSet = #Tenant.cSLevelTypeSet# AND ST.dtRowDeleted IS NULL) </CFIF>
				WHERE	C.iChargeType_ID = #ChargeTypes.iChargeType_ID#
				AND		(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR iHouse_ID IS NULL)	
				AND		C.dtRowDeleted IS NULL
				AND		CT.dtRowDeleted IS NULL
				ORDER BY C.cDescription
			</CFQUERY>	
			charges#ChargeTypes.iChargeType_ID#="Select a Charge <BR> <SELECT NAME='otheriCharge_ID' onFocus='details(this);'><CFIF ChargesList.RecordCount GT 1><OPTION VALUE=''>Choose Charge</OPTION></CFIF><CFLOOP QUERY="ChargesList"><OPTION VALUE='#ChargesList.iCharge_ID#'>#ChargesList.cDescription#</OPTION></CFLOOP></SELECT>";
			<CFLOOP QUERY="ChargesList">
				<CFSET uneditable = 'border: noborder; background: linen;'>
				<CFIF ChargesList.bIsModifiableDescription NEQ ''><CFSET descstyle='#uneditable#'><CFSET descread='READONLY'><CFELSE><CFSET descstyle=''><CFSET descread=''></CFIF>
				<CFIF ChargesList.bIsModifiableAmount NEQ ''><CFSET amtstyle='#uneditable#'><CFSET amtread='READONLY'><CFELSE><CFSET amtstyle=''><CFSET amtread=''></CFIF>
				<CFIF ChargesList.bIsModifiableQty NEQ ''><CFSET qtystyle='#uneditable#'><CFSET qtyread='READONLY'><CFELSE><CFSET qtystyle=''><CFSET qtyread=''></CFIF>
				chargescdescription#ChargesList.iCharge_ID# = "<INPUT TYPE='text' NAME='othercdescription' #descread#  SIZE=25 VALUE='#TRIM(ChargesList.cDescription)#' STYLE='#descstyle#'>";
				chargesmamount#ChargesList.iCharge_ID# = "<INPUT TYPE='text' NAME='otherAmount' #amtread# SIZE=6 VALUE='#TRIM(NumberFormat(ChargesList.mAmount,'99999999.99'))#' STYLE='#amtstyle#' onBlur='ext(this);'>";
				chargesiquantity#ChargesList.iCharge_ID# = "<INPUT TYPE='text' NAME='otheriQuantity' #qtyread# SIZE=3 VALUE='#TRIM(ChargesList.iQuantity)#' STYLE='#qtystyle# text-align: center;' onBlur='ext(this);'>";
				chargesactualamount#ChargesList.iCharge_ID# = #ChargesList.mAmount#;
				chargesactualqty#ChargesList.iCharge_ID# = #ChargesList.iQuantity#;
			</CFLOOP>
			//alert (charges#ChargeTypes.iChargeType_ID#);
		</CFLOOP>
		function list(string){
		<CFLOOP QUERY="ChargeTypes"><CFLOOP QUERY="ChargeTypes">if (string.value == #ChargeTypes.iChargeType_ID#) { document.all['ChargeList'].innerHTML = charges#ChargeTypes.iChargeType_ID#; }</CFLOOP></CFLOOP>
		details(document.forms[0].otheriCharge_ID);
		}
		function details(string){
			if (string.value != ''){ 
				inputperiod = "<INPUT TYPE='text' name='othercAppliesToAcctPeriod' VALUE='#DateFormat(SESSION.TIPSMonth,"yyyymm")#' SIZE=6>";
				inputdesc = eval('chargescdescription' + string.value); 
				inputamt = eval('chargesmamount' + string.value);
				inputqty = eval('chargesiquantity' + string.value);
				amt = eval('chargesactualamount' + string.value);
				qty = eval('chargesactualqty' + string.value);
				extended = (amt * qty);
				extendedprice = " $<INPUT TYPE='text' name='otherextended' READONLY VALUE='" + cent(round(extended)) + "' SIZE=5 STYLE='background: linen; border: noborder;'>";
				savebuttons="<INPUT TYPE='button' NAME='Save' VALUE='Save' onClick='submitsave();'>";
				savebuttons+="&nbsp;<INPUT TYPE='submit' NAME='Cancel' VALUE='Cancel'>";
				o = inputperiod + ' ' + inputdesc + '<BR>'+  inputqty + ' x ' + inputamt + ' = ' + extendedprice + savebuttons;
				document.all['EditCharge'].innerHTML = o; 
			}
			else { document.all['EditCharge'].innerHTML = ''; }
		}
	</CFOUTPUT>
</SCRIPT>


<!--- ==============================================================================
Retrieve all Current MoveOut Charges
=============================================================================== --->
<CFQUERY NAME = "CurrentCharges" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	INV.*, IM.bMoveOutInvoice, CT.bIsRent, CT.bIsMedicaid, CT.bIsDiscount, INV.cAppliesToAcctPeriod, IM.bEditSysDetails
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
	JOIN	ChargeType CT		ON (INV.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL)
	WHERE	bMoveInInvoice IS NULL
	AND		IM.dtRowDeleted IS NULL
	AND		IM.bMoveOutInvoice IS NOT NULL
	AND		IM.bFinalized IS NULL
	AND		INV.iTenant_ID = #url.ID#
</CFQUERY>

<!--- ==============================================================================
Retrieve Detail for selected Charge
=============================================================================== --->
<CFIF IsDefined("form.OtheriCharge_ID") AND form.OtheriCharge_ID NEQ "" AND 1 EQ 0>
	<CFQUERY NAME = "ChargeDetail" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*, C.cDescription as cDescription
		FROM	Charges C
		JOIN	ChargeType CT 	ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		WHERE	iCharge_ID = #form.OtheriCharge_ID#
	</CFQUERY>
</CFIF>


<!--- ==============================================================================
Retreive the Recent payments for this House
=============================================================================== --->
	<CFIF Tenant.dtChargeThrough NEQ "">
		<CFSET PerPost = #Year(Tenant.dtChargeThrough)# & #DateFormat(Tenant.dtChargeThrough,"mm")#>
	<CFELSE>
		<CFSET PerPost = #Year(SESSION.AcctStamp)# & #DateFormat(SESSION.AcctStamp,"mm")#>
	</CFIF>
	
<CFQUERY NAME = "Payments" DATASOURCE = "SOLOMON-HOUSES">
	SELECT 	doctype, refnbr, docdate, docdesc, custid, user1, user3, user7, PerClosed,
			mamount = CASE	WHEN doctype in ('PA','CM') then -origdocamt ELSE origdocamt END
			,CASE	WHEN doctype = 'PA' then 'Payment'	WHEN doctype = 'IN' then 'Invoice'	ELSE 'Other' END as Type
	FROM 	ardoc (NOLOCK)
	WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
	AND		doctype = 'PA'
	AND		PerPost = '#PerPost#'
	ORDER BY PerClosed, type
</CFQUERY>

<!--- ==============================================================================
Retreive Payor Information
=============================================================================== --->
<CFQUERY NAME="Payor" DATASOURCE="#APPLICATION.datasource#">
	SELECT	C.*, LTC.iRelationshipType_ID, RT.cDescription as RelationShip
	FROM	LinkTenantContact LTC
	JOIN	RelationshipType RT		ON RT.iRelationshipType_ID = LTC.iRelationshipType_ID	
	JOIN	Contact C				ON C.iContact_ID = LTC.iContact_ID
	JOIN	Tenant T				ON LTC.iTenant_ID = T.iTenant_ID
	WHERE	(LTC.iTenant_ID = #url.ID# OR T.cSolomonKey = '#Tenant.cSolomonKey#')
	AND		LTC.bIsPayer IS NOT NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve if Security Deposit has been paid
=============================================================================== --->
<CFQUERY NAME="Refundable" DATASOURCE="#APPLICATION.datasource#">
	SELECT	sum(INV.mAmount) as mAmount
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON 	IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
	JOIN	ChargeType CT		ON	INV.iChargeType_ID = CT.iChargeType_ID	
	JOIN	DepositLOG DL		ON	DL.iTenant_ID = INV.iTenant_ID	
	JOIN	DepositType DT		ON	DT.iDepositType_ID = DL.iDepositType_ID
	WHERE	bMoveInInvoice IS NOT NULL 
	AND	INV.dtRowDeleted IS NULL
	AND	INV.iTenant_ID = #url.ID#
	AND	CT.cGLAccount = 1030
	AND	DT.bIsFee IS NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve all current GLAccounts
=============================================================================== --->
<CFQUERY NAME = "GLAccounts" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct cGLaccount
	FROM	ChargeType
	WHERE	dtRowDeleted IS NULL
</CFQUERY>

<!--- ------------------------------------------------------------------------------
Retrieve information for chosen reason
------------------------------------------------------------------------------- --->
<CFIF IsDefined("url.Rsn")>

	<CFQUERY NAME="ChosenReason" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	MoveReasonType
		WHERE	iMoveReasonType_ID = #url.Rsn#
		AND		dtRowDeleted IS NULL
	</CFQUERY>
	
<CFELSEIF Tenant.Reason NEQ "">
	
	<CFQUERY NAME="ChosenReason" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*
		FROM	MoveReasonType
		WHERE	iMoveReasonType_ID = #Tenant.iMoveReasonType_ID#
		AND		dtRowDeleted IS NULL
	</CFQUERY>
	
	<CFSET url.Rsn = #Tenant.iMoveReasonType_ID#>
	<CFSET url.stp = 4>
	
</CFIF>

<!--- ==============================================================================
Retrieve list of reasons depending on if voluntary or involuntary
=============================================================================== --->
<CFQUERY NAME="Reason" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	MoveReasonType
	
	<CFIF IsDefined("URL.Vol") AND URL.Vol GT 0>
		WHERE	bIsVoluntary IS NOT NULL	
	<CFELSEIF IsDefined("URL.Vol") AND URL.Vol EQ 0>
		WHERE	bIsVoluntary IS NULL
	<CFELSEIF IsDefined("url.Rsn") AND ChosenReason.bIsVoluntary NEQ "">
		WHERE	bIsVoluntary = #ChosenReason.bIsVoluntary#
	<CFELSE>
		WHERE	bIsVoluntary is null
	</CFIF>
	AND		dtRowDeleted IS NULL
</CFQUERY>

<!--- *******************************************************************************
TEMPORARY
Retrieve All Move reason Types
******************************************************************************** --->
<CFQUERY NAME="qVoluntaryReason" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	MoveReasonType
	WHERE	dtRowDeleted IS NULL
	AND		bIsVoluntary IS NOT NULL
	ORDER BY cDescription
</CFQUERY>

<!--- *******************************************************************************
TEMPORARY
Retrieve All Move reason Types
******************************************************************************** --->
<CFQUERY NAME="qInVoluntaryReason" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	MoveReasonType
	WHERE	dtRowDeleted IS NULL
	AND		bIsVoluntary IS NULL
	ORDER BY cDescription
</CFQUERY>


<!--- ==============================================================================
Retreive Tenant Information
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/Queries/TenantInformation.cfm">
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/Relation.cfm">
<CFINCLUDE TEMPLATE="../Shared/Queries/StateCodes.cfm">


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<CFOUTPUT>

<A HREF="../MainMenu.cfm" STYLE="font-size: 14;">Click Here to Go Back To TIPS Summary.</A>
<BR>

<FORM NAME="MoveOutForm" ACTION="MoveOutForm.cfm" METHOD="POST" onSubmit="return validdate()"> <!--- --->
<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#url.ID#">
<INPUT TYPE="Hidden" NAME="moveinyear" VALUE="#YEAR(Tenant.dtMoveIn)#">
<INPUT TYPE="Hidden" NAME="moveinday" VALUE="#Day(Tenant.dtMoveIn)#">
<INPUT TYPE="Hidden" NAME="moveinmonth" VALUE="#Month(Tenant.dtMoveIn)#">
<INPUT TYPE="Hidden" NAME="StandardRent" VALUE="#StandardRent.mAmount#">
<INPUT TYPE="Hidden" NAME="DailyRent" VALUE="#TRIM(DailyRent)#">
<INPUT TYPE="Hidden" NAME="Occupancy" VALUE="#Occupancy#">

<TABLE>	
	<CFIF StandardRent.mAmount EQ "" OR StandardRent.mAmount EQ 0>
		<TR>
			<TD COLSPAN="100%" STYLE="background: lightyellow; color: red; font-size: 16; text-align: center; border: thin solid navy;">
				<B>
				Can not find any valid standard rent amount(s) for this #Tenant.Residency# tenant. <BR> 
				This amount will need to be entered manually.<BR>
				Please, contact your AR Specialist for assistance.
				</B>
			</TD>
		</TR>
	</CFIF>	

	<TR><TH COLSPAN=100%>Move Out Form</TH></TR>
	<TR>
		<TD STYLE="text-align: center; width: 50%;">
			<TABLE STYLE="width: 80%;">			
				<TR><TD>Account Number:</TD><TD STYLE="text-align: right;"> #TENANT.cSolomonKey# </TD></TR>
				<TR><TD>Name</TD><TD STYLE="text-align: right;"> #TENANT.cFirstName# #TENANT.cLastName# </TD></TR>	
				<TR><TD>Move In Date</TD><TD STYLE="text-align: right;"> #LSDateFormat(TENANT.dtMoveIn, "mm/dd/yyyy")# </TD></TR>	
			</TABLE>
		</TD>

		<TD STYLE="text-align: center;">
			<TABLE STYLE="width: 80%;">
				<TR><TD>Unit</TD><TD STYLE="text-align: right;"> #TENANT.cAptNumber# </TD></TR>
				<TR><TD>Apartment Size</TD><TD STYLE="text-align: right;"> #TENANT.AptType# </TD><TR>
				<TR><TD>Payment Method</TD><TD STYLE="text-align: right;"> #TENANT.Residency# </TD></TR>
			</TABLE>
		</TD>
	</TR>
</TABLE>


<TABLE>
		<SCRIPT>
			function reasonlist(string){
				if (string.value == 1){ 
					o="<SELECT NAME='Reason'>";
					o+="<OPTION VALUE=''>Choose Reason</OPTION>";
					o+="<CFLOOP QUERY='qVoluntaryReason'><CFIF Tenant.iMoveReasonType_ID EQ qVoluntaryReason.iMoveReasonType_ID><CFSET selected='selected'><CFELSE><CFSET selected=''></CFIF><OPTION VALUE='#qVoluntaryReason.iMoveReasonType_ID#' #SELECTED#>#TRIM(qVoluntaryReason.cDescription)#</OPTION></CFLOOP>";
					o+="</SELECT>";
					document.all['SelectReason'].innerHTML = o;
				}
				else if (string.value == 0) {	
					o="<SELECT NAME='Reason'><OPTION VALUE=''>Choose Reason</OPTION><CFLOOP QUERY='qInVoluntaryReason'><CFIF Tenant.iMoveReasonType_ID EQ qInVoluntaryReason.iMoveReasonType_ID><CFSET selected='selected'><CFELSE><CFSET selected=''></CFIF><OPTION VALUE='#qInVoluntaryReason.iMoveReasonType_ID#' #SELECTED#>#TRIM(qInVoluntaryReason.cDescription)#</OPTION></CFLOOP></SELECT>";
					document.all['SelectReason'].innerHTML = o; 
				}
			}
		</SCRIPT>

		<TR><TD COLSPAN=100% STYLE="font-weight: bold; width: 25%;"> Reason for Move Out:</TD></TR>
		<TR>
			<CFIF Tenant.Reason NEQ "">
				<CFSET VoluntaryRadio='CHECKED'>
				<CFSET InVoluntaryRadio=''>
				<CFSET Run=1>
			<CFELSE>
				<CFSET VoluntaryRadio=''>
				<CFSET InVoluntaryRadio='Checked'>
				<CFSET RUN=0>
			</CFIF>
			<TD NOWRAP COLSPAN=2 STYLE="font-weight: bold; width: 50%;">
				Was this Move Out Voluntary?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Yes - <INPUT TYPE="radio" NAME="Voluntary" #VoluntaryRadio# VALUE="1" onClick="setTargetChargeThrough(this.value); reasonlist(this);">	
				No - <INPUT TYPE="radio" NAME="Voluntary" #InVoluntaryRadio# VALUE="0" onClick="setTargetChargeThrough(this.value); reasonlist(this);">
			</TD>
			<TD NOWRAP COLSPAN=2 STYLE="width: 50%;" ID="SelectReason"></TD>
		</TR>
		<SCRIPT>reasonlist(document.forms[0].Voluntary);</SCRIPT>

		<TR><TD COLSPAN=100%><HR></TD></TR>
		<TR><TD COLSPAN=100% STYLE="font-weight: bold;"> CURRENT MONTH PRORATED RENT: </TD></TR>		

		<TR>
			<TD VALIGN="TOP" COLSPAN="2" STYLE="text-align: center;">
				
				<TABLE STYLE="width: 85%; height: 100%; text-align: right; ">
					<TR>
						<TD NOWRAP STYLE="font-size: 12; text-align: left;"> Monthly Rent Rate: </TD>						
						<TD STYLE="text-align: right;"> 
							<CFIF Tenant.iResidencyType_ID NEQ 3>
								$#TRIM(NumberFormat(StandardRent.mAmount, "999999.99"))# 
							<CFELSE>
								N/A for Respite
							</CFIF>
						</TD>
					</TR>
					<TR>
						<TD STYLE="font-size: 12; text-align: left;"> Moved Out Date: </TD>
						<CFIF Tenant.dtMoveOut NEQ "">
							<CFSET MONTH 	= #Month(Tenant.dtMoveOut)#>
							<CFSET Day 		= #Day(Tenant.dtMoveOut)#>
							<CFSET Year 	= #Year(Tenant.dtMoveOut)#>
						<CFELSEIF IsDefined("form.MoveOutDay")>
							<CFSET MONTH 	= #form.MoveOutMonth#>
							<CFSET Day 		= #form.MoveOutDay#>
							<CFSET Year 	= #form.MoveOutYear#>
						<CFELSE>
							<CFSET MONTH 	= #Month(Now())#>
							<CFSET Day 		= #Day(Now())#>
							<CFSET Year 	= #Year(Now())#>	
						</CFIF>								
						<TD NOWRAP STYLE="text-align: center;">						
							<SELECT NAME="MoveOutMonth" onChange="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear); validdate();"
							onBlur="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear); validdate();">
									<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
										<CFIF Month EQ #I#>
											<CFSET Selected = 'Selected'>
										<CFELSE>
											<CFSET Selected = ''>
										</CFIF> 
										<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
									</CFLOOP>
							</SELECT>
								
							/ 
								
							<SELECT NAME="MoveOutDay">
									<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(dtMoveout)#" STEP="1"> 
										<CFIF Day EQ #I#> <CFSET Selected='Selected'> <CFELSE> <CFSET Selected=''> </CFIF> 										
										<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
									</CFLOOP>
							</SELECT>
								
							/
								
							<INPUT TYPE="Text" NAME="MoveOutYear" Value="#Year#" SIZE="3" onBlur="this.value=Numbers(this.value); validdate();" onChange="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear);">							
						</TD>
					</TR>
								
					<TR>
						<TD STYLE="font-size: 12; text-align: left;"> Date of Notice: </TD>
						<TD STYLE="text-align: center;">
							<CFIF Tenant.dtMoveOut NEQ "">
								<CFSET MONTH 	= #Month(Tenant.dtNoticeDate)#>
								<CFSET Day 		= #Day(Tenant.dtNoticeDate)#>
								<CFSET Year 	= #Year(Tenant.dtNoticeDate)#>
							<CFELSEIF IsDefined("form.NoticeDay")>
								<CFSET MONTH 	= #form.NoticeMonth#>
								<CFSET Day 		= #form.NoticeDay#>
								<CFSET Year 	= #form.NoticeYear#>								
							<CFELSE>
								<CFSET MONTH 	= #Month(Now())#>
								<CFSET Day 		= #Day(Now())#>
								<CFSET Year 	= #Year(Now())#>	
							</CFIF>		
							<CFSET	ntcMonth	= #Variables.MONTH#>

							<SELECT NAME = "NoticeMonth" onChange="dayslist(document.forms[0].NoticeMonth, document.forms[0].NoticeDay, document.forms[0].NoticeYear); validdate();setTargetChargeThrough(#Reason.bIsVoluntary#);">			
								<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> 
									<CFIF Month EQ #I#> <CFSET Selected='Selected'> <CFELSE> <CFSET Selected=''> </CFIF> 									
									<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
								</CFLOOP>
							</SELECT>
								
							/ 
								
							<SELECT NAME = "NoticeDay" onChange="setTargetChargeThrough(#Reason.bIsVoluntary#);">	
								<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(dtChargeThrough)#" STEP="1"> 
									<CFIF Day EQ #I#> <CFSET Selected = 'Selected'> <CFELSE> <CFSET Selected = ''> </CFIF> 									
									<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
								</CFLOOP>
							</SELECT>
								
							/
								
							<INPUT TYPE="Text" NAME="NoticeYear" Value="#Year#" SIZE=3 onBlur="this.value=Numbers(this.value); validdate();" onChange="dayslist(document.forms[0].NoticeMonth, document.forms[0].NoticeDay, document.forms[0].NoticeYear);setTargetChargeThrough(#Reason.bIsVoluntary#);">							
						</TD>
					</TR>

					<TR>
						<TD STYLE="font-size: 12; text-align: left;"> Charged Through: </TD>

							<CFSET NumberOfMonths = #DateDiff("m", SESSION.TipsMonth, Variables.dtChargeDayOne)#>
		
							<CFSET Month = #NumberOfMonths#>
							<INPUT TYPE="Hidden" Name="Month" VALUE="#Month#">
							

							<!--- ==============================================================================
							Check to see if this move out is the same month and year as the move in
							If this is true, dayscharged = difference in days.
							=============================================================================== --->
							<CFIF (Month(Tenant.dtMoveIn) EQ Month(Variables.dtChargeThrough)) AND (Year(Tenant.dtMoveIN) EQ Year(dtChargeThrough))>
								<CFSET DaysCharged = #Variables.dtChargeThrough# - #Tenant.dtMoveIn# +1>
							<CFELSE>
								<CFSET DaysCharged = #Day(Variables.dtChargeThrough)#>
								<CFIF DaysCharged LTE 30 OR Tenant.iResidencyType_ID EQ 2>
									<CFSET DaysCharged = #Day(Variables.dtChargeThrough)#>
								<CFELSE>
									<CFSET DaysCharged = 30>
								</CFIF>
							</CFIF>
							<INPUT TYPE="Hidden" NAME="DaysCharged" VALUE="#DaysCharged#">					

							
						<TD STYLE="text-align: center;">
								<SELECT NAME="ChargeMonth" onChange="dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear); validdate();">	
									<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> 
										<CFIF Tenant.dtChargeThrough NEQ "" AND Month(Tenant.dtChargeThrough) EQ #I#>
											<CFSET Selected = 'Selected'>
										<CFELSEIF IsDefined("form.ChargeMonth") AND (form.ChargeMonth EQ #I#)>
											<CFSET Selected = 'Selected'>
										<CFELSE>
											<CFSET Selected = ''>
										</CFIF>
										
										<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
									</CFLOOP>
								</SELECT>
								
							/ 
								
							<SELECT NAME="ChargeDay">
								<CFLOOP INDEX="I" FROM="1" TO="31" STEP="1"> 
									<CFIF Tenant.dtChargeThrough NEQ "" AND Day(Tenant.dtChargeThrough) EQ #I#>
										<CFSET Selected = 'Selected'>
									<CFELSEIF IsDefined("form.ChargeDay") AND (form.ChargeDay EQ #I#)>
										<CFSET Selected = 'Selected'>
									<CFELSE>
										<CFSET Selected = ''>
									</CFIF>
																			
									<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
								</CFLOOP>
							</SELECT>
								
							/
							
							<CFIF IsDefined("Tenant.dtChargeThrough") AND Tenant.dtChargeThrough NEQ "">
								<CFSET dtChargeThrough = #Tenant.dtChargeThrough#>
							</CFIF>
							
							<INPUT TYPE="Text" NAME="ChargeYear" Value="#Year(dtChargeThrough)#" SIZE = "3" onBlur = "this.value=Numbers(this.value);" onChange="dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear); validdate();" >
						</TD>
					</TR>
				</TABLE>
			</TD>
			
			
			<TD VALIGN="top" COLSPAN="2" STYLE="text-align: center;">
				<TABLE STYLE="width: 90%; height: 100%;">
					<TR>
						<TD COLSPAN="2" STYLE="width: 75%; font-size: 12; text-align: left;"> 
							Daily Rate:
						</TD>
						
						<TD STYLE="text-align: right; width: 20%;">
							<CFIF Tenant.iResidencyType_ID NEQ 3>
								#LSCurrencyFormat(Variables.DailyRent)#
							<CFELSE>
								#LSCurrencyFormat(StandardRent.mAmount)#
							</CFIF>
						</TD>
						
					</TR>
					
					<TR>
						<TD NOWRAP COLSPAN="2"  STYLE="font-size: 12; text-align: left;"> Number of Days Charged: </TD>
						<TD STYLE="text-align: right;"> #Variables.DaysCharged# </TD>
					</TR>
					
					<TR>
						<TD NOWRAP COLSPAN="2" STYLE="font-size: 12; text-align: left;"> Current Month's Rent Prorated: </TD>
						<TD STYLE="text-align: right;">
							<!--- ==============================================================================
							Modified 12/7/01 SBD (TenantInfo.dtChargeThrough is null the first time through; must handle)
							=============================================================================== --->
							<CFIF IsDefined("TenantInfo.dtChargeThrough") AND TenantInfo.dtChargeThrough NEQ "">
								<CFIF DaysCharged LT 30 OR DaysCharged LT DaysInMonth(TenantInfo.dtChargeThrough)>
									<CFSET ProratedRent = #NumberFormat(Variables.DailyRent,"-9999999999.99")# * #Variables.DaysCharged#>
								<CFELSE>
									<CFSET ProratedRent = #StandardRent.mAmount#>
								</CFIF>
							<CFELSEIF DaysCharged LT 30 OR DaysCharged LT DaysInMonth(Variables.dtChargeThrough)>
								<CFSET ProratedRent = #NumberFormat(Variables.DailyRent,"-9999999999.99")# * #Variables.DaysCharged#>
							<CFELSE>
								<CFSET ProratedRent = #StandardRent.mAmount#>
							</CFIF>
							#LSCurrencyFormat(Variables.ProratedRent)#
							<INPUT TYPE="Hidden" NAME="ProratedRent" VALUE="#Variables.ProratedRent#">
						</TD>
						
					</TR>
					
					<TR>
						<TD NOWRAP COLSPAN="2" STYLE="font-size: 12; text-align: left;"> Charge Through Date Should Be: </TD>
						<TD>
							<INPUT TYPE = "Text" CLASS="BlendedTextBoxR" STYLE="width: 85;" READONLY TABINDEX=-1 NAME = "dtChargeThroughTarget" Value = 
							<CFIF IsDefined("Reason.bIsVoluntary") AND Reason.bIsVoluntary NEQ "">
								<CFSET dtTempTarget = CreateODBCDateTime(Year & "/" & ntcMonth & "/" & Day)>
								"#DateFormat(DateAdd("d", 29, dtTempTarget), "m / d / yyyy")#"
							<CFELSE>
								"Involuntary"
							</CFIF>
						</TD>
					</TR>						
				</TABLE>
			</TD>
		</TR>
		<TR><TD COLSPAN="4"><HR></TD></TR>
				
		<TR>
			<TD COLSPAN="4" STYLE="text-align: center;">
				<TABLE STYLE="width: 80%;">
					<TR>
						<TD STYLE=" 25%;">	<B>Damages	</B>	</TD>
						<TD STYLE="text-align: left;">
							<CFIF IsDefined("form.DamageAmount")>
								<CFSET DamageAmount = #form.DamageAmount#>
							<CFELSE>	
								<CFSET DamageAmount = "0.00">
							</CFIF>
							
							$<INPUT TYPE="text" NAME="DamageAmount" VALUE = "#TRIM(NumberFormat(Variables.DamageAmount, "999999.99"))#" STYLE="text-align: right;" SIZE="7" onChange="decimal();" MAXLENGHT="9">
						</TD>
						<TD COLSPAN="2">
							<CFIF IsDefined("form.DamageComments")>
								<CFSET DamageComments = #form.DamageComments#>
							<CFELSE>	
								<CFSET DamageComments = "">
							</CFIF>
							Comments:<BR>
							<TEXTAREA COLS="35" ROWS="2" NAME="DamageComments" STYLE="font-size: 12;">#TRIM(Variables.DamageComments)#</TEXTAREA>
						</TD>
					</TR>				
			
						<TR>
							<TD STYLE="width: 25%;">	<B>Other/Additional Charges:</B>	</TD>							
								<TD COLSPAN=3>
								<CFIF NOT IsDefined("form.OtheriChargeType_ID") AND NOT IsDefined("form.OtheriCharge_ID")>	
									<TABLE STYLE="width: 80%;">
										<TR>
<!--- ==============================================================================
											<!--- These are For JavaScript Function --->
											<INPUT TYPE="Hidden" NAME="OtheriQuantity" VALUE="0">
											<INPUT TYPE="Hidden" NAME="OtherAmount" VALUE="0">
											<INPUT TYPE="Hidden" NAME="CalculatedOtherAmount" VALUE="0">
											<INPUT TYPE="Hidden" NAME="OthercDescription" VALUE="">
											<INPUT TYPE="Hidden" NAME="OtherComments" VALUE="">
=============================================================================== --->
											<TD NOWRAP COLSPAN=2 STYLE="width: 25%;">
												What Type of Charge is this?<BR>
												<SELECT NAME="OtheriChargeType_ID" onChange="list(this);">
													<OPTION VALUE=""> None </OPTION>
													<CFLOOP QUERY="ChargeTypes"> <OPTION VALUE="#ChargeTypes.iChargeType_ID#"> #ChargeTypes.cDescription# </OPTION> </CFLOOP>
												</SELECT>
											</TD>											
											<TD NOWRAP><DIV ID="ChargeList"></DIV></TD>
										</TR>
										<TR><TD NOWRAP COLSPAN=100%><DIV ID="EditCharge"></DIV></TD></TR>
									</TABLE>
								<CFELSEIF NOT IsDefined("form.OtheriCharge_ID")>
									<TABLE STYLE="width:100%;">
										<TR>	
											<TD COLSPAN ="3" STYLE="width: 25%;">
												<B>(step 2 of 3)</B><BR>
												<SELECT NAME="OtheriCharge_ID">
													<OPTION VALUE=""> Choose a Charge (Set #Tenant.cSLevelTypeSet#)</OPTION>
													<CFLOOP QUERY="ChargesList">
														<OPTION VALUE ="#ChargesList.iCharge_ID#"> 
															#ChargesList.cDescription# 
															<CFIF IsDefined("ChargesList.bIsDaily") AND ChargesList.bIsDaily GT 0> (Daily) </CFIF>	
														</OPTION>
													</CFLOOP>
												
												</SELECT>
												
												<!--- These are For JavaScript Function --->
												<INPUT TYPE = "Button" NAME = "Submit" VALUE = "Continue" STYLE="color: darkgreen;" onClick="document.MoveOutForm.action='MoveOutForm.cfm?ID=#form.iTenant_ID#&Rsn=#url.Rsn#&stp=#Url.Stp#'; submit();">										
												<INPUT TYPE = "Hidden" NAME = "OtheriQuantity" VALUE = "0">
												<INPUT TYPE = "Hidden" NAME = "OtherAmount" VALUE = "0">
												<INPUT TYPE = "Hidden" NAME = "CalculatedOtherAmount" VALUE = "0">
												<INPUT TYPE = "Hidden" NAME = "OthercDescription" VALUE = "">
												<INPUT TYPE = "Hidden" NAME = "OtherComments" VALUE = "">
											</TD>
										</TR>
									</TABLE>
								</CFIF>	

						

								<CFIF IsDefined("form.OtheriCharge_ID") AND form.OtheriCharge_ID NEQ "">
								
								<INPUT TYPE = "Hidden" NAME = "OtheriCharge_ID" VALUE = "#ChargeDetail.iCharge_ID#">
									<TABLE STYLE="width:100%;">
										<TR>
											<TD NOWRAP>
												<U>Description</U> &nbsp; <B>(step 3 of 3)</B><BR>
												<CFIF ChargeDetail.bIsModifiableDescription GT 0 >
													<INPUT TYPE="text" NAME="OthercDescription" VALUE="#ChargeDetail.cDescription#" MAXLENGTH="15" onKeyUP="this.value=Letters(this.value);  Upper(this);">
												<CFELSE>
													#ChargeDetail.cDescription#
													<INPUT TYPE="Hidden" NAME="OthercDescription" VALUE = "#ChargeDetail.cDescription#">
												</CFIF>
											</TD>
											
											<TD STYLE="text-align: center;">
												<U>Quantity</U><BR>
												<CFIF ChargeDetail.bIsModifiableQTY GT 0 >	
													<INPUT TYPE="text" NAME="OtheriQuantity" VALUE="#ChargeDetail.iQuantity#" SIZE="2" MAXLENGHT="2" onBlur="OtherTotal();" onKeyUP="this.value=Numbers(this.value);">
												<CFELSE>
													#ChargeDetail.iQuantity#
													<INPUT TYPE = "Hidden" NAME = "OtheriQuantity" VALUE = "#ChargeDetail.iQuantity#">
												</CFIF>								
											</TD>
											
											<TD STYLE="text-align: right;">
												<U>Price</U><BR>
												<CFIF ChargeDetail.bIsModifiableAmount GT 0 >
													$<INPUT TYPE="text" NAME = "OtherAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeDetail.mAmount, "99999.99"))#"  STYLE="text-align: right;" onBlur="decimal(); OtherTotal();" onKeyUP="this.value=CreditNumbers(this.value);">
												<CFELSE>
													$#TRIM(NumberFormat(ChargeDetail.mAmount, "999999.99"))#
													<INPUT TYPE = "Hidden" NAME = "OtherAmount" VALUE = "#ChargeDetail.mAmount#">
												</CFIF>								
											</TD>
											
											<TD STYLE="text-align: right;">
												<CFSET OtherTotal = #ChargeDetail.iQuantity# * #ChargeDetail.mAmount#>
												
													<CFIF form.DamageAmount EQ "">
														<CFSET form.DamageAmount = 0.00>
													</CFIF>												
												<B><U>Total</U></B><BR>
												<INPUT TYPE="text" NAME="CalculatedOtherAmount" VALUE="#TRIM(LSNumberFormat(Variables.OtherTotal, "99999.99"))#" SIZE="9" STYLE="border: none; background: linen; text-align: right; color: navy; font-weight: bold;">
											</TD>
										</TR>
										
										<TR>
											<TD STYLE="text-align: center;">
												Apply To Period 
											</TD>
											<TD COLSPAN=2>
											<SELECT NAME="AppliesToMonth">
												<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
													<CFIF Month(SESSION.TIPSMonth) EQ I><CFSET Selected='SELECTED'><CFELSE><CFSET Selected=''></CFIF>
													<OPTION VALUE ="#NumberFormat(I, "09")#" #SELECTED#>
														#NumberFormat(I, "09")#
													</OPTION>
												</CFLOOP>
											</SELECT>
											/
																					
											<INPUT TYPE="Text" NAME="AppliesToYear" VALUE="#Year(Now())#" SIZE="4" MAXLENGTH="4" STYLE="text-align: center;">												
												
											</TD>
											<TD></TD>
										</TR>
										
										<TR>
											<TD COLSPAN="4" NOWRAP>
												<CFIF IsDefined("ChargeDetail.cComments") AND ChargeDetail.cComments NEQ "">
													<CFSET OtherComments = #TRIM(ChargeDetail.cComments)#>
												<CFELSE>
													<CFSET OtherComments = ''>
												</CFIF>
												Comments:
												<TEXTAREA COLS="50" ROWS="2" NAME="OtherComments">#TRIM(Variables.OtherComments)#</TEXTAREA>
											</TD>
										</TR>
										<TR>
											<TD COLSPAN=2 STYLE="text-align: center;">
												<INPUT TYPE="Hidden" NAME="Edit" VALUE="1">												
												<CFIF MoveOutCharges.bEditSysDetails NEQ "" OR (IsDefined("InvoiceCheck.bEditSysDetails") AND InvoiceCheck.bEditSysDetails NEQ "")>
													<INPUT CLASS="BlendedButton" TYPE="Button" NAME="SaveCharge" VALUE="Save Charge" STYLE="width: 100px;" onClick="document.MoveOutForm.action='MoveOutSysDetailUpdate.cfm?edit=1'; submit();">
												<CFELSE>
													<INPUT CLASS="BlendedButton" TYPE="Button" NAME="SaveCharge" VALUE="Save Charge" STYLE="width: 100px;" onClick="document.MoveOutForm.action='MoveOutUpdate.cfm?edit=1'; submit();">
												</CFIF>
											</TD>
											<TD COLSPAN=2>
												<INPUT CLASS="BlendedButton" TYPE="Button" NAME="Cancel Charge" VALUE="Cancel" STYLE="color: green; width: 100px;" onClick="location.href='#HTTP.REFERER#'">
											</TD>
										</TR>
									</TABLE>
							
								</CFIF>
							</TD>	
						</TR>
						
						<TR>
							<TD COLSPAN=100%>
								<TABLE STYLE="width: 100%;">
									<CFIF ListFindNoCase(SESSION.codeblock,23) GT 0>
										<CFIF MoveOutCharges.bEditSysDetails NEQ "">
											<CFSET STYLE= "STYLE='font-weight: bold;'">
											<CFSET ButtonValue = "De-Activate">
										<CFELSE>
											<CFSET STYLE="STYLE='color: navy;'">
											<CFSET ButtonValue = "Activate">
										</CFIF>
									
										<SCRIPT>
											function activatebutton(){
												if (document.forms[0].OverRideSystem.value == "De-Activate"){
													activatemessage = 'By De-Activating your changes will be over written when you save. \r \t Are you sure?'; }
												else { activatemessage = 'Please note: \rBy disabling system charges the charge through date and the prorate days may not correlate.'; }
											
												if (confirm(activatemessage)){
													document.forms[0].action='EditSysDetails.cfm?MasterID=#MoveOutCharges.iInvoiceMaster_ID#'; 
													document.MoveOutForm.submit(); }
												else { return false; }
											}
										</SCRIPT>
										
										<TR>
											<TD COLSPAN=100% STYLE="background: gainsboro; text-align: center;">
												<B><U>FOR ACCT ONLY</U>: Over Ride System Generated Charges </B>
												<INPUT TYPE="submit" Class="BlendedButton" Name="OverRideSystem" VALUE="#ButtonValue#" #STYLE# onClick="return activatebutton();">
											</TD>
										</TR>
									</CFIF>
	
									<TR>
										<TD NOWRAP> <B>Per. To Apply</B> </TD>
										<TD NOWRAP> <B>Description</B> </TD>
										<TD STYLE="text-align: right;"> <B>Amount</B> </TD>
										<TD STYLE="text-align: right;"> <B>Qty</B> </TD>
										<TD STYLE="text-align: right;"> <B>Price</B> </TD>
										<TD STYLE="text-align: center;"> <B>Delete</B> </TD>
									</TR>

									<CFIF CurrentCharges.RecordCount GT 0>
											<INPUT TYPE="Hidden" NAME="SysEdit" VALUE="#MoveOutCharges.bEditSysDetails#">
											<CFLOOP QUERY="CurrentCharges">
												<SCRIPT>
													function mathfor#CurrentCharges.iInvoiceDetail_ID#() {
														if (document.forms[0].Sysquantity#CurrentCharges.iInvoiceDetail_ID#.value == '') { document.forms[0].Sysquantity#CurrentCharges.iInvoiceDetail_ID#.value = 1; }
														calc#CurrentCharges.iInvoiceDetail_ID# = mocent(moround((document.forms[0].SysmAmount#CurrentCharges.iInvoiceDetail_ID#.value * document.forms[0].Sysquantity#CurrentCharges.iInvoiceDetail_ID#.value)));
														document.forms[0].SysExtendedPrice#CurrentCharges.iInvoiceDetail_ID#.value = calc#CurrentCharges.iInvoiceDetail_ID#;
														document.forms[0].SysmAmount#CurrentCharges.iInvoiceDetail_ID#.value = mocent(moround((document.forms[0].SysmAmount#CurrentCharges.iInvoiceDetail_ID#.value)));
													}
												</SCRIPT>
												
												<CFIF IsDefined("form.SysmAmount#CurrentCharges.iInvoiceDetail_ID#")>
													<CFSET SysAmount = Evaluate('form.SysmAmount'&#CurrentCharges.iInvoiceDetail_ID#)>
												<CFELSE>
													<CFSET SysAmount =  #CurrentCharges.mAmount#>
												</CFIF>
												
												<CFIF IsDefined("form.Sysquantity#CurrentCharges.iInvoiceDetail_ID#")>
													<CFSET Sysquantity= Evaluate('form.Sysquantity'&#CurrentCharges.iInvoiceDetail_ID#)>
												<CFELSE>
													<CFSET Sysquantity =  #CurrentCharges.iQuantity#>
												</CFIF>
												
												<CFIF CurrentCharges.iRowStartUser_ID EQ 0 AND MoveOutCharges.bEditSysDetails GT 0>
													<TR>
														<TD STYLE="text-align: center;"> 
															<INPUT TYPE="text" NAME="SysPeriod#CurrentCharges.iInvoiceDetail_ID#" VALUE="#CurrentCharges.cAppliesToAcctPeriod#" SIZE="#Len(CurrentCharges.cAppliesToAcctPeriod)#">
														</TD>
														<TD>
															<INPUT TYPE="text" NAME="SyscDescription#CurrentCharges.iInvoiceDetail_ID#" VALUE="#CurrentCharges.cDescription#" SIZE="#Len(TRIM(CurrentCharges.cDescription))#">
														</TD>
														<TD STYLE="text-align: right;">
															<!--- SIZE="#Len(TRIM(CurrentCharges.mAmount))#" --->
															$<INPUT TYPE="text" NAME="SysmAmount#CurrentCharges.iInvoiceDetail_ID#" VALUE="#LSNumberFormat(TRIM(SysAmount),"99999.99")#" 
																STYLE="text-align: right; width: #Len(CurrentCharges.mAmount)#ex;"
																onBlur="this.value=CreditNumbers(this.value); mathfor#CurrentCharges.iInvoiceDetail_ID#();">
														</TD>
														<TD STYLE="text-align: right;">
															<INPUT TYPE="text" NAME="Sysquantity#CurrentCharges.iInvoiceDetail_ID#" VALUE="#TRIM(Sysquantity)#" 
																SIZE="#Len(TRIM(Sysquantity))#" STYLE="text-align: center;" MAXLENGTH=3
																onBlur="this.value=CreditNumbers(this.value); mathfor#CurrentCharges.iInvoiceDetail_ID#();">
														</TD>
														
														<CFIF CurrentCharges.mAmount NEQ "">
															<CFSET ExtendedPrice = #CurrentCharges.mAmount# * #CurrentCharges.iQuantity#>
														<CFELSE>
															<CFSET ExtendedPrice = 0.00>
														</CFIF>
														<TD STYLE="text-align: right;"> 
															$<INPUT TYPE="text" READONLY NAME="SysExtendedPrice#CurrentCharges.iInvoiceDetail_ID#" VALUE="#TRIM(LSNumberFormat(ExtendedPrice,"99999.99"))#" SIZE="#Len(TRIM(LSNumberFormat(ExtendedPrice,"99999.99")))#" STYLE='border: noborder; background: linen; text-align: right;'>
														</TD>
														<CFIF CurrentCharges.RecordCount GT 1>
															<TD> <INPUT CLASS="BlendedButton" TYPE="Button" NAME="Delete" VALUE="Delete" STYLE="width: 6em;" onClick="location.href='DeleteDetail.cfm?ID=#Tenant.iTenant_ID#&DID=#CurrentCharges.iInvoiceDetail_ID#&Rsn=#url.rsn#&stp=#url.stp#'"> </TD>
														<CFELSE>
															<TD></TD>
														</CFIF>
													</TR>
												<CFELSE>
													<TR>
														<TD STYLE="text-align: center;"> #CurrentCharges.cAppliesToAcctPeriod# </TD>
														<TD>#CurrentCharges.cDescription#</TD>
														<TD STYLE="text-align: right;"> #LSCurrencyFormat(CurrentCharges.mAmount)# </TD>
														<TD STYLE="text-align: right;"> #CurrentCharges.iQuantity# </TD>
														
														<CFIF CurrentCharges.mAmount NEQ "">
															<CFSET ExtendedPrice = #CurrentCharges.mAmount# * #CurrentCharges.iQuantity#>
														<CFELSE>
															<CFSET ExtendedPrice = 0.00>
														</CFIF>
														<TD STYLE="text-align: right;"> #LSCurrencyFormat(ExtendedPrice)# </TD>
														<TD STYLE="text-align: center;">
															<CFIF CurrentCharges.RecordCount GT 1 AND (CurrentCharges.bMoveOutInvoice GT 0 AND CurrentCharges.iRowStartUser_ID NEQ 0) OR (CurrentCharges.bIsDiscount GT 0 AND CurrentCharges.bIsRent GT 0) OR (CurrentCharges.bEditSysDetails GT 0)>
																<INPUT CLASS="BlendedButton" TYPE="Button" NAME="Delete" VALUE="Delete" STYLE="width: 6em;" onClick="location.href='DeleteDetail.cfm?ID=#Tenant.iTenant_ID#&DID=#CurrentCharges.iInvoiceDetail_ID#&Rsn=#url.rsn#&stp=#url.stp#'">
															<CFELSE>
																Invoiced in Period #CurrentCharges.cAppliesToAcctPeriod#
															</CFIF>
														</TD>
													</TR>													
												</CFIF>
											</CFLOOP>
									<CFELSE>
										<TR><TD COLSPAN=100%>There are no records at this time.</TD></TR>
									</CFIF>		
								</TABLE>
							</TD>
						</TR>			
				</TABLE>
			</TD>
		</TR>
		
		<TR><TD COLSPAN=100% STYLE="font-weight: bold;"> BILLING INFORMATION: </TD></TR>	
		
		<CFIF Payor.RecordCount EQ 0 AND (IsDefined ("form.cLastName") AND (form.cFirstName NEQ "" AND form.cLastName NEQ ""))>
			<CFSET cFirstName = #form.cFirstName#>
			<CFSET cLastName = #form.cLastName#>
			<CFSET iRelationshipType_ID	= #form.iRelationshipType_ID#>
			<CFSET cAddressLine1 = #form.cAddressLine1#>
			<CFSET cAddressLine2 = #form.cAddressLine2#>
			<CFSET cCity = #form.cCity#>
			<CFSET cStateCode = #form.cStateCode#>
			<CFSET cZipCode = #form.cZipCode#>
		<CFELSE>
			<CFSET cFirstName = #Payor.cFirstName#>
			<CFSET cLastName = #Payor.cLastName#>
			<CFSET iRelationshipType_ID	= #Payor.iRelationshipType_ID#>
			<CFSET cAddressLine1 = #Payor.cAddressLine1#>
			<CFSET cAddressLine2 = #Payor.cAddressLine2#>
			<CFSET cCity = #Payor.cCity#>
			<CFSET cStateCode = #Payor.cStateCode#>
			<CFSET cZipCode = #Payor.cZipCode#>
		</CFIF>
		
		
		<TR>
			<TD COLSPAN=100% STYLE="text-align: center;">
				<TABLE STYLE="width: 75%;">
					<TR>
						<TD STYLE="Font-weight: bold; width: 25%;">	First Name</TD>
						<TD COLSPAN=3>
							<INPUT TYPE="text" NAME="cFirstName" VALUE="#Variables.cFirstName#" onBlur="this.value=Letters(this.value); Upper(this);">
						</TD>
					</TR>

					<TR>
						<TD STYLE="Font-weight: bold; width: 25%;">	Last Name</TD>
						<TD COLSPAN=3>
							<INPUT TYPE="text" NAME="cLastName" VALUE="#Variables.cLastName#" onBlur="this.value=Letters(this.value); Upper(this);">
						</TD>
					</TR>

					
					<TR>
						<TD STYLE="Font-weight: bold;">	RelationShip:</TD>
						<TD COLSPAN=3>	
							<SELECT NAME = "iRelationshipType_ID">
								<CFLOOP QUERY = "RELATIONSHIPS">
									
									<CFIF IsDefined("form.iRelationshipType_ID") AND form.iRelationshipType_ID EQ #RelationShips.iRelationshipType_ID#>
										<CFSET Selected = 'Selected'>
									<CFELSEIF Payor.iRelationshipType_ID EQ #RelationShips.iRelationshipType_ID#>
										<CFSET Selected = 'Selected'>
									<CFELSE>
										<CFSET Selected = ''>
									</CFIF>
								
									<OPTION VALUE = "#RelationShips.iRelationshipType_ID#" #Selected#>	
										#RelationShips.cDescription#	
									</OPTION>
								</CFLOOP>
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	Address (Line 1)</TD>
						<TD COLSPAN=3> <INPUT TYPE="text" Name="cAddressLine1" VALUE="#Variables.cAddressLine1#" SIZE="40" MAXLENGTH="40"> </TD>
					</TR>					
					<TR>
						<TD STYLE="Font-weight: bold;">	Address (Line 2)</TD>
						<TD COLSPAN=3> <INPUT TYPE="text" Name="cAddressLine2" VALUE="#Variables.cAddressLine2#" SIZE="40" MAXLENGTH = "40"> </TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	City	</TD>
						<TD COLSPAN="3"> <INPUT TYPE="text" Name="cCity" VALUE="#Variables.cCity#" onKeyUp="this.value=Letters(this.value)"></TD>
					</TR>
					<TR>
						<TD STYLE = "Font-weight: bold;"> State	</TD>
						<TD COLSPAN = "3">
							<SELECT NAME = "cStateCode">
																
								<CFLOOP Query = "StateCodes">
									
									<CFIF IsDefined("Payor.cStateCode") AND Payor.cStateCode EQ #cStateCode#>
										<CFSET Selected = 'Selected'>
									<CFELSEIF IsDefined("form.cStateCode") AND form.cStateCode EQ #cStateCode#>
										<CFSET Selected = 'Selected'>									
									<CFELSE>
										<CFSET Selected = ''>
									</CFIF>
								
									<OPTION VALUE ="#cStateCode#" #SELECTED#>	#cStateName# - #cStateCode# </OPTION>
								</CFLOOP>
							
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	Zip Code	</TD>
						<TD COLSPAN="3">
							<INPUT TYPE = "text" Name = "cZipCode" 	VALUE = "#Variables.cZipCode#" onKeyUp = "this.value=Numbers(this.value)">
						</TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	Home Phone:</TD>
						<TD COLSPAN=3>
							<CFIF IsDefined("form.areacode1") AND IsDefined("form.prefix1") AND IsDefined("form.number1")>
								<CFSET areacode1 	= #form.areacode1#>
								<CFSET prefix1	 	= #form.prefix1#>
								<CFSET number1	 	= #form.number1#>
							<CFELSEIF Len(Payor.cPhoneNumber1) EQ 10>
								<CFSET areacode1 	= #LEFT(Payor.cPhoneNumber1,3)#>
								<CFSET prefix1	 	= #Mid(Payor.cPhoneNumber1,4,3)#>
								<CFSET number1	 	= #RIGHT(Payor.cPhoneNumber1,4)#>
							<CFELSE>
								<CFSET areacode1 = ''>
								<CFSET prefix1 = ''>
								<CFSET number1 = ''>
							</CFIF>
							
							<INPUT TYPE = "text" NAME = "areacode1"	SIZE = "3"	VALUE = "#Variables.areacode1#" MAXLENGTH = "3" onKeyUP = "this.value=Numbers(this.value)">-
							<INPUT TYPE = "text" NAME = "prefix1"	SIZE = "3"	VALUE = "#Variables.prefix1#" MAXLENGTH = "3" onKeyUP = "this.value=Numbers(this.value)">-
							<INPUT TYPE = "text" NAME = "number1"	SIZE = "4"	VALUE = "#Variables.number1#" MAXLENGTH = "4" onKeyUP = "this.value=Numbers(this.value)">
							<INPUT TYPE = "hidden" NAME = "iPhoneType1_ID"	VALUE = "1">						
						</TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold;">	Message Phone:</TD>
						<TD COLSPAN=3>
							<CFIF IsDefined("form.areacode2") AND IsDefined("form.prefix2") AND IsDefined("form.number2")>
								<CFSET areacode2 	= #form.areacode2#>
								<CFSET prefix2	 	= #form.prefix2#>
								<CFSET number2	 	= #form.number2#>
							<CFELSE>
								<CFSET areacode2 	= #LEFT(Payor.cPhoneNumber2,3)#>
								<CFSET prefix2	 	= #Mid(Payor.cPhoneNumber2,4,3)#>
								<CFSET number2	 	= #RIGHT(Payor.cPhoneNumber2,4)#>
							</CFIF>						
							
							<INPUT TYPE = "text" NAME = "areacode2"	SIZE = "3"	VALUE = "#Variables.areacode2#" MAXLENGTH = "3" onKeyUP = "this.value=Numbers(this.value)">-
							<INPUT TYPE = "text" NAME = "prefix2"	SIZE = "3"	VALUE = "#Variables.prefix2#" MAXLENGTH = "3" onKeyUP = "this.value=Numbers(this.value)">-
							<INPUT TYPE = "text" NAME = "number2"	SIZE = "4"	VALUE = "#Variables.number2#" MAXLENGTH = "4" onKeyUP = "this.value=Numbers(this.value)">
							<INPUT TYPE = "hidden" NAME = "iPhoneType2_ID"	VALUE = "5">
						</TD>
					</TR>
					
					<TR>
						<TD>
							<CFIF IsDefined("form.cComments")>
								<CFSET cComments=#TRIM(form.cComments)#>
							<CFELSEIF Payor.cComments NEQ "">
								<CFSET cComments = #TRIM(Payor.cComments)#>
							<CFELSE>
								<CFSET cComments="">
							</CFIF>
							Comments:
						</TD>
						<TD COLSPAN=3>
							<TEXTAREA COLS="35" ROWS="2" NAME="cComments" VALUE="#Variables.cComments#">#Variables.cComments#</TEXTAREA>	
						</TD>
					</TR>					
				</TABLE>
			</TD>
		</TR>	
		
		<TR>
			<TD COLSPAN=100% STYLE="text-align: left;">
				<CFIF MoveOutCharges.InvoiceComments NEQ "">
					<CFSET InvoiceComments = #MoveOutCharges.InvoiceComments#>
				<CFELSE>	
					<CFSET InvoiceComments = ''>
				</CFIF>
				<!--- ==============================================================================
				Changed 1/24/02 SBD Per Accounting
				<B>Program Director / Accounting Notes</B><BR>
				=============================================================================== --->
				<B>Past Due Balance Description</B><BR>
				<TEXTAREA COLS="70" ROWS="2" NAME="InvoiceComments" VALUE="#Variables.cComments#">#Variables.InvoiceComments#</TEXTAREA>
			</TD>
		</TR>
	</TABLE>

	<TABLE>
		<TR>
			<TD STYLE="text-align: left;">
				<CFIF MoveOutCharges.bEditSysDetails NEQ "">
					<INPUT TYPE="Submit" NAME="Save" VALUE="Save & View Summary" STYLE="width: 150px; color: navy;" onClick="document.MoveOutForm.action='MoveOutSysDetailUpdate.cfm?MID=#MoveOutCharges.iInvoiceMaster_ID#';">
				<CFELSE>
					<INPUT TYPE="Submit" NAME="Save" VALUE="Save & View Summary" STYLE="width: 150px; color: navy;" onClick="document.MoveOutForm.action='MoveOutUpdate.cfm?MID=#MoveOutCharges.iInvoiceMaster_ID#';">
				</CFIF>
			</TD>
			<CFIF Tenant.iTenantStateCode_ID LT 3>
				<SCRIPT>
					function confirmation(){
						if (confirm('Are you sure you want delete all move out information?')){
							document.forms[0].action='RemoveMoveOutData.cfm?iTenant_ID=#Tenant.iTenant_ID#&iInvoiceMaster_ID=#MoveOutCharges.iInvoiceMaster_ID#';
							document.forms[0].submit();
						}
					}
				</SCRIPT>	
			<TD>
				<INPUT TYPE="Button" NAME="MoReset" VALUE="Tenant is not moving out" STYLE="width: 160px; color: maroon;" onClick="confirmation();">  
			</TD>
			</CFIF>
			<TD STYLE="Text-align: right;">
				<INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="self.location.href='../MainMenu.cfm'">
			</TD>
		</TR>
	</TABLE>

</FORM>

<SCRIPT>
	<CFIF Tenant.Reason NEQ "">
		document.forms[0].Voluntary.value = 1;
		document.forms[0].Voluntary.checked = true;
	<CFELSE>
		document.forms[0].Voluntary.value = 0;
		document.forms[0].Voluntary.checked = false;		
	</CFIF>
	reasonlist(document.forms[0].Voluntary);
</SCRIPT>

</CFOUTPUT>

<BR>
<A HREF="../MainMenu.cfm" STYLE="Font-size: 18;">Click Here to Go Back To TIPS Summary.</A>



<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">


