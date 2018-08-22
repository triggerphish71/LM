<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MoveOut entry form                                            				   |
|----------------------------------------------------------------------------------------------|
| MoveOutForm.cfm                                                            		           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		MainMenu.cfm          													   |
| Calls/Submits:	MoveOutUpdate														       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|Paul Buendia|02/11/2002  |     Changed default on move out date and 						   |
|			 |			  |				notice date to default the historical				   |
|			 |			  |				data thereby after calculating number 				   |
|			 |			  |				of days in month									   |	
|Paul Buendia|02/19/2002  |		Changed Daily Rate/Monthly rate displays					   |
|			 |			  |				to accomidate respite tenants. (ie. no monthly		   |	
|			 |			  |				rent amounts)										   |
|Steve D     |02/19/2002  |		Fixed target chargethrough date to add 29 days instead of 30.  |
|Steve D 	 |04/22/2002  |		Added check for companion suite when determining occupancy	   |	
|Paul Buendia|07/24/2002  |		Changed Tenant query to use rw.vw_AptHistory view			   |	
|Paul Buendia|07/25/2002  |		Tenant query changed to be time sensitive                      |
|			 |			  |				according to the start of the invoice date			   |
|			 |			  |				and if is null the current date						   |
|			 |			  |				Changed ChargeTypes query to ignore any charge types   |
|			 |			  |				without a charge associated with it.				   |
|MLAW        | 10/18/2005 | Format the description field to not over database size limit       |
|MLAW        | 11/21/2005 | Fix the retrieve Tenant SQL Heat Call 808095                       |
|			 |			  |	In the Tenant Move Out process - retrieve Tenant section, the      |
|			 |		      |	system matches Tenants with the invoice master records by using    |
|			 |		      |	Solomon Key.  If there are 2 Tenants charged by the same invoice   |
|			 |			  |	and 1 of the tenants moved out before the other tenant and the     |
|			 |			  |	room is a new memory care room.  The system will not be able to    |
|			 |			  |	find the existing Tenant to match the correct invoice.  We come up |
|			 |			  |	a permanent fix for this case without changing any existing        |
|			 |			  |	program's functionality by using iTenant_ID.                       |
|MLAW        | 12/12/2005 | Use chargeset to validate the charges list                         |
|MLAW        | 03/08/2006 | Remedy Call 32362 - User should allow to change all charges except |
|            |            | ChargeType - R&B rate, R&B discount                                |
|MLAW		 | 08/04/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
|MLAW        | 08/17/2006 | Make sure the charges are assigned to correct Product Line ID      |
|MLAW        | 10/23/2006 | If user is AR Admin then the move out date is changeable, otherwise|
|            |            | the move out date is read only                                     |
|SSathya     | 02/11/2008 | Diabled the Save button from clicking multiple times.              |
|SSathya     | 03/12/2008 | Commented the condition in the chargelist query as it did not allow|
|                            the new aptments to be displayed in the drop-down list for the new|
|							House (SouthEast Region).                                          |
|SSathya     |04/10/2008  | Added more condition for the Javascript validation purpose upon    |
                             Clicking the save & View button.
|Ssathya     |11/06/2008  | Made changes according to Project 30096 Move Out Date Edits and    |
|                         | validations                                                        |
|rschuette	 |3/31/2009   | small code add for proj 35510                                      |
|rschuette	 |6/02/2009   | small code add for proj 38407                                      |
|rschuette   |4/9/2010    | Project 51267 - MO Codes and Locations                             |
|Sathya      |05/25/2010  | Project 20933 Late Fee project. Modified queries not to display the|
|            |            | late fee that was been added to the invoice                        |
|rschuette   |06/22/2010  | Proj 25575 - Respite Incremental Time Billing					   |
|sathya      |07/28/2010  | Project 20933 Part-B modifications. Not to show up the records of  |
|            |            | Late fee which were added to invoicedetail table, as AR Analyst is |
|            |            | getting confused and deleting the charge upon display.             |
|SFarmer     |03/20/2012  | Project 75019 Added Deferred NRF to charge back unpaid portion     |
|            |            | if early move out                                                  |
|SFarmer     | 05/01/2012 | 90201 - adjusted tenant query when Tenant.iResidencyType_ID eq 3   |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 07/06/2012 | 92432 corrections for respite-death move out                       |
|sfarmer     | 07/06/2012 | 92852 changed  move out reasons from drop down to list of radio    |
|                         |                                                             buttons|
|S Farmer    | 09/13/2012 | TPG Collectors Database changes added 'SB' & 'PP' to doctype       |
|sfarmer     | 12/10/2013 | 112478 - adjustments to Billing Information                        |
|S Farmer    | 2015-01-12 | 116824    Final Move-in Enhancements                               |
| M Shah	 | 2016-06-13 | added training documents link
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                |
|MStriegel	 | 02/10/2018 | Added logic so respites can moveout without notice date            |
----------------------------------------------------------------------------------------------->
 

<!--- 08/04/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<!--- set dates paramenter --->
<CFPARAM name="lvNoticeDate" type="date" default="#dateformat(now(),"mm/dd/yyyy")#">
<CFPARAM name="lvDischargeDate" type="date" default="#dateformat(now(),"mm/dd/yyyy")#">
<CFPARAM name="lvChargeThroughDate" type="date" default="#DateFormat(dateadd("d", +29, now()), "mm/dd/yyyy")#">

<cfparam name="paymentmonths" default="">
<cfparam name="monthlypayment" default="">
<cfparam name="paymentsmade" default="">
<cfparam name="remainingbal" default="">
<cfparam name="amtpaid" default="0">
<cfparam  name="thisNbrPaymnt" default="1">
<cfparam name="DaysChargedCare" default="0">
 

<!--- ==============================================================================
Javascript Validation
=============================================================================== --->
<SCRIPT>
	//#51267-RTS-4/12/2010 - MO Codes
	function Step2check(){
		if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
				alert("The Primary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
	}
	//end 51267
	
	function validdate(){
		//#51267-RTS-3/19/2010 - MO Codes
		if (document.forms[0].DisplayReason2.checked != ''){
			if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text){
				alert("The secondary Move Out Reason cannot \n be the same as the primary.");
				window.scrollTo(1,1);
				return false;
			}
			if(MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text == "Select Item"){
				alert("The secondary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
			var death = MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text;
			if(((death.indexOf("Death")) > 0) || (MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Death")){
				alert("The secondary Move Out Reason cannot \nexist when primary is Death.");
				window.scrollTo(1,1);
				return false;
			}
		}
		if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
			alert("The primary Move Out Reason cannot \n be 'Select Item'.");
			window.scrollTo(1,1);
			return false;
		}
		//if(MoveOutForm.slctTenantMOLocation.options[MoveOutForm.slctTenantMOLocation.selectedIndex].text == 'Select Location') {
		//	alert("The Destination Location cannot be 'Select Location'.");
		//	window.scrollTo(1,1);
		//	return false;
		//}
		//end 51267
		
		if (document.forms[0].ChargeMonth.value == '' || document.forms[0].ChargeDay.value =='' || document.forms[0].ChargeDay.year =='') { 
			document.forms[0].ChargeMonth.focus(); alert('Invalid Charge Through Date');
		return false;
		}
		//11/06/2008 project#30096  sathya changed the alert message everything else is the same and not changed at all...
		else
		 if ( document.forms[0].MoveOutMonth.value =='' || document.forms[0].MoveOutDay.value =='' || document.forms[0].MoveOutYear.value =='') {
			document.forms[0].MoveOutMonth.focus(); alert('Please enter a valid Physical Move Out Date');
			return false;
		}
		else if ( (document.forms[0].NoticeMonth.value =='' || document.forms[0].NoticeDay.value =='' || document.forms[0].NoticeYear.value =='')) {
			document.forms[0].NoticeMonth.focus(); alert('Invalid Notice Date');
			return false;
		}
		
		var miyear = (document.MoveOutForm.moveinyear.value); var mimonth = ((document.MoveOutForm.moveinmonth.value) - 1); 
		var miday = (document.MoveOutForm.moveinday.value); var movein = new Date(miyear, mimonth, miday);
		
		var moyear = (document.MoveOutForm.MoveOutYear.value); var momonth = ((document.MoveOutForm.MoveOutMonth.value) - 1);
		var moday = (document.MoveOutForm.MoveOutDay.value); var moveout = new Date(moyear, momonth, moday);
		
		var noyear = (document.MoveOutForm.NoticeYear.value); var nomonth = ((document.MoveOutForm.NoticeMonth.value) - 1);
		var noday = (document.MoveOutForm.NoticeDay.value); var notice = new Date(noyear, nomonth, noday);
		
		
		var chyear = (document.MoveOutForm.ChargeYear.value); var chmonth = ((document.MoveOutForm.ChargeMonth.value) - 1);
		var chday = (document.MoveOutForm.ChargeDay.value); var charge = new Date(chyear, chmonth, chday);		
		
		
		if (movein > moveout){ var message = ('The MoveOut is before the movein date \r' + 'which is' + ' ' + movein); 
		alert(message); document.forms[0].MoveOutMonth.focus(); return false; }
		else if (movein > notice && document.MoveOutForm.NoticeDay.value !== '')
		{ var message = ('The Notice is before the movein date \r' + 'which is' + ' ' + movein); 
		alert(message); document.forms[0].NoticeMonth.focus(); return false;	}
		else if (movein > charge){ var message = ('The Charge Date is before the movein date \r' + 'which is' + ' ' + movein); 
		alert(message); document.forms[0].ChargeMonth.focus(); return false; }
		
	
		//else if (notice > charge){ var message = ('The Notice Date is after the charge through date \r' + 'which is' + ' ' + movein); alert(message); return false; }
		//04/10/08 Ssathya added the more condtions for validation 
		else if(document.MoveOutForm.cFirstName.value=='')
		{
			alert("Please enter the FirstName");
			return false;
		}
		else if(document.MoveOutForm.cLastName.value=='')
		{
			alert("Please enter the LastName");
			return false;
		}
		
		else if(document.MoveOutForm.cAddressLine1.value=='')
		{
			alert("Please enter the Address");
			return false;
		}
		else if(document.MoveOutForm.cCity.value=='')
		{
			alert("Please enter the City");
			return false;
		}
		else if(document.MoveOutForm.cZipCode.value=='')
		{
			alert("Please enter the Zip Code");
			return false;
		}
		else if(document.MoveOutForm.iRelationshipType_ID.options[document.MoveOutForm.iRelationshipType_ID.selectedIndex].value == ''){
			alert("Select the Relationship of the Contact.");
			
			return false;
		}		
		
		else{ return true;}
	}


 //Project 30096 ssathya added this as part of Validation 
function ValidatedateifValid(enterdate){
	
	///var dt=dbirthdate
	/*if (isDate(enterdate)==false){
		return false;
	}
	else{
    */
    return true;
	///}
}
	
	//functions cent and round are from developer.irt.org FAQ (no authors specified)	
	function CreditNumbers(string) {
		for (var i=0, output='', valid="1234567890.-"; i<string.length; i++)
	       if (valid.indexOf(string.charAt(i)) != -1)
	       output += string.charAt(i)
	   	return output;
	} 	

	function mocent(amount) {
	//CODE originally from developer.it.org returns the amount in the .99 format
	amount -= 0;
	return (amount == Math.floor(amount)) ? amount + '.00' : (  (amount*10 == Math.floor(amount*10)) ? amount + '0' : amount);
	}

	function moround(number,X) {
	// rounds number to X decimal places, defaults to 2
	X = (!X ? 2 : X);
	result = Math.round(number*Math.pow(10,X))/Math.pow(10,X);
	if (isNaN(result) == true || result == '..') { result=0; }
	return result
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
		else { set('myLayer','hidden');	return true; }
	}
	
	function required(){ var failed = false; validdate(); return; }

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
	    if ( isNaN (buffer) ) { alert( startMsg ) ; return null ; }
		
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
	    {	case 'd': case 'D': 
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
		if (bit == false || bit == 0) { bit = 0; }
		switch (bit) {
			case 1:
				document.MoveOutForm.dtChargeThroughTarget.value = "Involuntary";
				break;
			default:
				document.MoveOutForm.dtChargeThroughTarget.value = tctdate.getMonth() + 1 + ' / ' + tctdate.getDate() + ' / ' + tctdate.getYear();
		}
		return true;
	}
function ChkMonth(){

//alert('here');
  if(document.MoveOutForm.ChargeMonth.value == '')
  	{alert('Enter the appropriate Month value 01 - 12');
		document.MoveOutForm.ChargeMonth.focus();}
 	else if (document.MoveOutForm.ChargeMonth.value > 12)
 	{alert('Enter the appropriate Month value 01 - 12');
 		document.MoveOutForm.ChargeMonth.focus();}
 	else if (document.MoveOutForm.ChargeMonth.value < 1)
 	{alert('Enter the appropriate Month value 01 - 12');
 		document.MoveOutForm.ChargeMonth.focus();}
 	else
 		{document.MoveOutForm.ChargeDay.focus();}  
}
function ChkDay(){

//alert('here');
  if(document.MoveOutForm.ChargeDay.value == '')
  	{alert('Enter the appropriate Day value 01 - 31');
		document.MoveOutForm.ChargeDay.focus();}
 	else if (document.MoveOutForm.ChargeDay.value > 12)
 	{alert('Enter the appropriate Day value 01 - 31');
 		document.MoveOutForm.ChargeDay.focus();}
 	else if (document.MoveOutForm.ChargeMonth.value < 1)
 	{alert('Enter the appropriate Day value 01 - 31');
 		document.MoveOutForm.ChargeDay.focus();}
 	else
 		{document.MoveOutForm.ChargeYear.focus();}  
}
</SCRIPT>

<CFSCRIPT>
	if (IsDefined("url.ID")){ form.iTenant_ID = url.ID; } 
	else if (IsDefined("form.iTenant_ID")) { url.ID = form.iTenant_ID; }
	else { url.id=tenant.itenant_id; }
	if (IsDefined("url.MID")){ iInvoiceMaster_ID = url.MID; }
</CFSCRIPT>
<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(GetDate.Stamp)>

<!--- ==============================================================================
Retreive the DamageTypes
=============================================================================== --->
<CFQUERY NAME='qDamageType' DATASOURCE='#APPLICATION.datasource#'>
	select * from damagetype (nolock) where dtrowdeleted is null
</CFQUERY>

<!--- ==============================================================================
Retreive the House TIPS Month
=============================================================================== --->
	<cfquery name="qryHouseLog" DATASOURCE='#APPLICATION.datasource#'>
	Select iHouse_ID, dtCurrentTipsMonth from HouseLog where iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
	</cfquery>
<!--- MLAW	11/21/2005	Use the new Retrieve Tenants Query which will catch different scenerios. --->
<!---
<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	T.*, TS.iTenantState_ID,
			TS.dtMoveIn, TS.iSPoints, TS.dtChargeThrough, TS.dtMoveOut, 
			TS.dtNoticeDate, TS.iTenantStateCode_ID, TS.iResidencyType_ID,
			AD.cAptNumber, TS.iAptAddress_ID,
			AT.cDescription as AptType, AT.iAptType_ID,
			RT.cDescription as Residency,
			MT.cDescription as Reason, MT.iMoveReasonType_ID
	FROM	Tenant T (nolock)
	LEFT JOIN InvoiceMaster IM (nolock) ON (IM.cSolomonKey = T.cSolomonKey AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NOT NULL)
	LEFT JOIN TenantState ts (nolock) ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
	LEFT JOIN rw.vw_aptAddress_History AD (nolock) ON (AD.iAptAddress_ID = TS.iAptAddress_ID AND (isNull(IM.dtInvoiceStart,getdate()) between AD.dtRowStart AND isNull(AD.dtRowEnd,getdate())))
	LEFT JOIN AptType AT (nolock) ON (AT.iAptType_ID = AD.iAptType_ID AND AT.dtRowDeleted IS NULL)
	LEFT JOIN ResidencyType RT (nolock) ON (TS.iResidencyType_ID = RT.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
	LEFT JOIN MoveReasonType MT (nolock) ON (TS.iMoveReasonType_ID = MT.iMoveReasonType_ID AND MT.dtRowDeleted IS NULL)
	WHERE T.dtRowDeleted IS NULL AND T.iTenant_ID = #url.ID# AND IsNull(AT.iAptType_id,0) > 0
	ORDER BY ts.dtrowstart desc
</CFQUERY>
--->
<!--- ==============================================================================
Retreive the Tenants Information
=============================================================================== --->
<!--- MLAW 08/17/2006 Display Tenant's product line --->
<!--- 51267 - rts - MO reason2 and MOLocation --->
<!--- 25575 - rts - Respite Billing - added chargethrough & PMO--->
<!--- 90201 - SFarmer - adjusted tenant query when Tenant.iResidencyType_ID eq 3 --->
<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT DISTINCT
		T.*
		, TS.iTenantState_ID
		,TS.dtMoveIn
		,TS.iSPoints
		,TS.dtChargeThrough
		,TS.dtMoveOut
		,TS.dtNoticeDate
		,TS.iTenantStateCode_ID
		,TS.iResidencyType_ID
		,TS.dtChargeThrough
		,TS.dtMoveOutProjectedDate
		,ts.dtRentEffective
		,AD.cAptNumber
		,TS.iAptAddress_ID
		,TS.iTenantMOLocation_ID
		,ts.IMONTHSDEFERRED
		,ts.madjnrf
		,ts.mbasenrf
		,ts.mAmtDeferred
		,AT.cDescription as AptType
		,AT.iAptType_ID
		,RT.cDescription as Residency
		,MT.cDescription as Reason
		,MT.iMoveReasonType_ID
		,MT2.cDescription as Reason2
		,MT2.iMoveReasonType_ID as iMoveReason2Type_ID
		,ts.dtRowStart
		,ts.iProductLine_ID
			
	FROM   Tenant T (nolock)
    LEFT JOIN rw.vw_Invoices IM (nolock) ON (IM.iTenant_ID = T.iTenant_ID AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NOT NULL)
    LEFT JOIN TenantState ts (nolock) ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
    LEFT JOIN rw.vw_aptAddress_History AD (nolock) ON (AD.iAptAddress_ID = TS.iAptAddress_ID 
	<!--- AND (isNull(IM.dtInvoiceStart,getdate()) between AD.dtRowStart AND isNull(AD.dtRowEnd,getdate())) --->)
    LEFT JOIN AptType AT (nolock) ON (AT.iAptType_ID = AD.iAptType_ID AND AT.dtRowDeleted IS NULL)
    LEFT JOIN ResidencyType RT (nolock) ON (TS.iResidencyType_ID = RT.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
    LEFT JOIN MoveReasonType MT (nolock) ON (TS.iMoveReasonType_ID = MT.iMoveReasonType_ID AND MT.dtRowDeleted IS NULL)
    LEFT JOIN MoveReasonType MT2 (nolock) ON (TS.iMoveReason2Type_ID = MT2.iMoveReasonType_ID AND MT2.dtRowDeleted IS NULL)
	WHERE T.dtRowDeleted IS NULL AND T.iTenant_ID = #url.ID# AND IsNull(AT.iAptType_id,0) > 0
    ORDER BY ts.dtrowstart desc
</CFQUERY>
<!---<cfdump Var="#tenant#">--->
<!--- 25575 - rts - Respite - If they are entering MO process again and the invoice has been set to MO, 
so the not null check for bIsMOInvoice is gone --->
<cfif Tenant.iResidencyType_ID eq 3>
	<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
		SELECT DISTINCT
	        	T.* 
			, TS.iTenantState_ID
		,TS.dtMoveIn
		,TS.iSPoints
		,TS.dtChargeThrough
		,TS.dtMoveOut
		,TS.dtNoticeDate
		,TS.iTenantStateCode_ID
		,TS.iResidencyType_ID
		,TS.dtChargeThrough
		,TS.dtMoveOutProjectedDate
		,ts.dtRentEffective
		,AD.cAptNumber
		,TS.iAptAddress_ID
		,TS.iTenantMOLocation_ID
		,ts.IMONTHSDEFERRED
		,ts.madjnrf
		,ts.mbasenrf
		,ts.mAmtDeferred
		,AT.cDescription as AptType
		,AT.iAptType_ID
		,RT.cDescription as Residency
		,MT.cDescription as Reason
		,MT.iMoveReasonType_ID
		,MT2.cDescription as Reason2
		,MT2.iMoveReasonType_ID as iMoveReason2Type_ID
		,ts.dtRowStart
		,ts.iProductLine_ID
		FROM   Tenant T (nolock)
	    LEFT JOIN rw.vw_Invoices IM (nolock) ON (IM.iTenant_ID = T.iTenant_ID AND IM.dtRowDeleted IS NULL)
	    LEFT JOIN TenantState ts (nolock) ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
	    LEFT JOIN rw.vw_aptAddress_History AD (nolock) ON (AD.iAptAddress_ID = TS.iAptAddress_ID )
			<!--- AND (isNull(IM.dtInvoiceStart,getdate()) between AD.dtRowStart AND isNull(AD.dtRowEnd,getdate())) ) --->
	    LEFT JOIN AptType AT (nolock) ON (AT.iAptType_ID = AD.iAptType_ID AND AT.dtRowDeleted IS NULL)
	    LEFT JOIN ResidencyType RT (nolock) ON (TS.iResidencyType_ID = RT.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
	    LEFT JOIN MoveReasonType MT (nolock) ON (TS.iMoveReasonType_ID = MT.iMoveReasonType_ID AND MT.dtRowDeleted IS NULL)
	    LEFT JOIN MoveReasonType MT2 (nolock) ON (TS.iMoveReason2Type_ID = MT2.iMoveReasonType_ID AND MT2.dtRowDeleted IS NULL)
		WHERE T.dtRowDeleted IS NULL AND T.iTenant_ID = #url.ID# AND IsNull(AT.iAptType_id,0) > 0
	    ORDER BY ts.dtrowstart desc
	</CFQUERY>
</cfif>
<!--- end 25575 --->
<!--- ==============================================================================
Retreive the DischargeDate from dailycensustrack Information
=============================================================================== --->
<CFQUERY NAME = "GetMoveOutDate" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 
		TOP 1 DischargeDate, * 
	FROM 
		dailycensustrack 
	WHERE 
		itenant_ID = #url.ID#
	AND
		DischargeDate <> '' 
	ORDER BY 
		Census_date DESC
</CFQUERY>

<!--- ==============================================================================
Retreive the NoticeOfDischargeDate from DailyCensusTrack Information
=============================================================================== --->
<CFQUERY NAME = "GetNoticeDate" DATASOURCE = "#APPLICATION.datasource#">
	SELECT 
		TOP 1 Census_date, (Census_date + 29) as ChargedThroughDate
	FROM 
		dailycensustrack 
	WHERE 
		itenant_ID = #url.ID#
	AND
		DischargeDate <> '' 
	ORDER BY 
		Census_date 
</CFQUERY>

<CFIF GetNoticeDate.ChargedThroughDate neq '' AND GetNoticeDate.ChargedThroughDate neq '1900-01-01 00:00:00.000'>
  <CFSET lvChargeThroughDate = #dateformat(GetNoticeDate.ChargedThroughDate,"mm/dd/yyyy")#>
</CFIF>

<!--- ==============================================================================
Check for an Existing Move Out Invoice
=============================================================================== --->
<CFQUERY NAME = "InvoiceCheck" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct IM.*
	FROM	InvoiceMaster IM (nolock) 
	JOIN	InvoiceDetail INV	(nolock) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL
	AND		IM.cSolomonKey = '#Tenant.cSolomonKey#' AND INV.iTenant_ID = #Tenant.iTenant_ID#
	WHERE	bMoveOutInvoice IS NOT NULL AND IM.bFinalized IS NULL AND IM.dtRowDeleted IS NULL
</CFQUERY>
<CFSET iInvoiceMaster_ID = InvoiceCheck.iInvoiceMaster_ID>



<CFIF IsDefined("url.stp") AND Url.STP GTE 4 AND SESSION.userID EQ 3025 AND 0 EQ 1>
	<!--- ==============================================================================
	Check for an Existing Move Out Invoice
	=============================================================================== --->
	<CFQUERY NAME = "InvoiceCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT distinct IM.*
		FROM InvoiceMaster IM (nolock) 
		JOIN InvoiceDetail INV (nolock) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL
		AND IM.cSolomonKey = '#TRIM(Tenant.cSolomonKey)#' AND INV.iTenant_ID = #Tenant.iTenant_ID#
		WHERE IM.dtRowDeleted IS NULL AND bMoveOutInvoice IS NOT NULL AND IM.bFinalized IS NULL
	</CFQUERY>
	
	<CFIF InvoiceCheck.RecordCount EQ 0>
		<CFQUERY NAME = "InvoiceCheck" DATASOURCE="#APPLICATION.datasource#">
			SELECT top 1 IM.*
			FROM InvoiceMaster IM (nolock) 
			WHERE IM.dtRowDeleted IS NULL AND bMoveOutInvoice IS NOT NULL AND IM.bFinalized IS NULL 
			AND IM.cSolomonKey = '#TRIM(Tenant.cSolomonKey)#'
			ORDER BY dtRowStart desc
		</CFQUERY>	
	</CFIF>

	
	<!--- ==============================================================================
	If there no available invoice. 
	We get the next number from house number control and update the invoice master table
	=============================================================================== --->
	<CFIF InvoiceCheck.RecordCount LTE 0>
		<CFSET CurrPer = Year(SESSION.TIPSMonth) & DateFormat(SESSION.TIPSMonth,"mm")>

		<!--- ==============================================================================
		Retrieve the next invoice number
		=============================================================================== --->
		<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iNextInvoice FROM HouseNumberControl (nolock) 
			WHERE dtRowDeleted IS NULL and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
		</CFQUERY>

		<CFSCRIPT> HouseNumber = SESSION.HouseNumber; iInvoiceNumber = '#Variables.HouseNumber#' & GetNextInvoice.iNextInvoice; </CFSCRIPT>

		<!--- ==============================================================================
		Retrieve the start date of current invoice
		=============================================================================== --->
		<CFQUERY NAME="CurrentInvoice" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	IM.iInvoiceMaster_ID, IM.dtInvoiceStart, IM.dtInvoiceEnd
			FROM	InvoiceMaster IM (nolock) 
			JOIN	InvoiceDetail INV	(nolock) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL
			and bMoveOutInvoice IS NULL AND IM.dtRowDeleted IS NULL
			and	INV.iTenant_ID = #Tenant.iTenant_ID# AND IM.cSolomonKey = '#Tenant.cSolomonKey#' AND IM.cAppliesToAcctPeriod = '#CurrPer#'
			and	bFinalized IS NULL 
		</CFQUERY>

		<!--- ==============================================================================
		Calculate and Record a new Invoice Number
		=============================================================================== --->
		<CFQUERY NAME = "NewInvoice" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO InvoiceMaster
			( iInvoiceNumber ,cSolomonKey ,bMoveOutInvoice ,bFinalized ,cAppliesToAcctPeriod ,cComments 
			,dtAcctStamp ,dtInvoiceStart ,iRowStartUser_ID ,dtRowStart)
			VALUES
			(	<CFSET iInvoiceNumber = '#Variables.iInvoiceNumber#' & 'MO'>
				'#Variables.iInvoiceNumber#' 
				,'#Tenant.cSolomonKey#' 
				,1 
				,NULL 
				,<CFSET AppliesTo = Year(SESSION.TipsMonth) & DateFormat(SESSION.TipsMonth, "mm")>
				'#Variables.AppliesTo#' 
				,NULL 
				,#CreateODBCDateTime(SESSION.AcctStamp)#
				,<CFIF CurrentInvoice.RecordCount GT 0  AND CurrentInvoice.dtInvoiceStart NEQ "">
					'#CurrentInvoice.dtInvoiceStart#'
				<CFELSE> 
					#TimeStamp# 
				</CFIF>
				,#SESSION.UserID# 
				,getDate() )
		</CFQUERY>
		<CFSET iNewNextInvoice = GetNextInvoice.iNextInvoice + 1>
		<!--- ==============================================================================
		Increment the next Invoice Number in the HouseNumberControl Table
		=============================================================================== --->
		<CFQUERY NAME = "HouseNumberControl" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	HouseNumberControl
			SET		iNextInvoice = #Variables.iNewNextInvoice#
			WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>

		<!--- ==============================================================================
		Retrieve the Invoice Master ID that was created above
		=============================================================================== --->
		<CFQUERY NAME="NewMasterID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceMaster_ID, dtInvoiceStart, dtInvoiceEnd
			FROM	InvoiceMaster (nolock) 
			WHERE	cSolomonKey ='#Tenant.cSolomonKey#'
			AND		bMoveOutInvoice IS NOT NULL AND bFinalized IS NULL AND dtRowDeleted IS NULL AND iInvoiceNumber = '#Variables.iInvoiceNumber#'
		</CFQUERY>
		<CFSCRIPT>	iInvoiceMaster_ID = NewMasterID.iInvoiceMaster_ID; dtInvoiceStart = NewMasterID.dtInvoiceStart; </CFSCRIPT>
	<CFELSE>
		<CFSCRIPT> iInvoiceMaster_ID = InvoiceCheck.iInvoiceMaster_ID; iInvoiceNumber = '#InvoiceCheck.iInvoiceNumber#'; dtInvoiceStart = InvoiceCheck.dtInvoiceStart;	</CFSCRIPT>
	</CFIF>
		<!--- ==============================================================================
		Retrieve the current open invoice and its transactions
		=============================================================================== --->
		<CFQUERY NAME="CurrentInvoice" DATASOURCE="#APPLICATION.datasource#">
			SELECT	INV.*
			FROM	InvoiceMaster IM (nolock) 
			JOIN	InvoiceDetail INV (nolock) ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
			WHERE	IM.dtRowDeleted IS NULL
			AND		INV.dtRowDeleted IS NULL AND IM.bMoveInInvoice IS NULL AND IM.bMoveOutInvoice IS NULL AND IM.bFinalized IS NULL
			AND		INV.iTenant_ID = #url.ID#
		</CFQUERY>
</CFIF>

<!--- ==============================================================================
Calculate and create a charge through variable
=============================================================================== --->
	
	
	<CFSCRIPT>
		 
		dtCareDate = CreateODBCDateTime(tenant.dtmovein);
		if (Tenant.dtChargeThrough EQ "" AND (NOT IsDefined("form.ChargeYear") OR NOT IsDefined("form.ChargeDay"))) 
			{ dtChargeThrough = Now(); dtChargeDayOne = Now(); }
		else if (IsDefined("form.ChargeYear")) {
			dtChargeThrough = CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & form.ChargeDay);
			dtChargeDayOne = CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & '01'); }
		else { 
			dtChargeThrough = Tenant.dtChargeThrough; form.ChargeYear = Year(Tenant.dtChargeThrough);
				 form.ChargeMonth = Month(Tenant.dtChargeThrough);
			form.ChargeDay = Day(Tenant.dtChargeThrough);
			dtChargeDayOne = CreateODBCDateTime(form.ChargeYear & "/" & form.ChargeMonth & "/" & '01'); }
	</CFSCRIPT>
	
	
<!--- ==============================================================================
Retrieve the last invoice end date for the following solomon query
=============================================================================== --->
<CFQUERY NAME = "StartRange" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	MAX(dtInvoiceStart) as dtInvoiceEnd
	FROM	InvoiceMaster IM (nolock) 
	JOIN	InvoiceDetail INV (nolock) ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
	AND		bFinalized IS NOT NULL AND INV.iTenant_ID = #Url.ID#
	WHERE	bMoveOutInvoice IS NULL
</CFQUERY>

<CFSCRIPT> if (StartRange.RecordCount GT 0) {StartRange = StartRange.dtInvoiceEnd; } else { StartRange = '2001-01-01'; } </CFSCRIPT>

<!--- ==============================================================================
Retrieve Solomon Transactions to Date.
Original code written by John Lian for Solomon Lookup.
=============================================================================== --->
<CFQUERY NAME="Statements" DATASOURCE="SOLOMON-HOUSES">
	SELECT 	doctype, refnbr, docdate, docdesc, custid, user1, user3, user7, PerClosed,
			amount = 	CASE 	WHEN doctype in ('PA','CM', 'SB', 'PP') then -origdocamt 	ELSE origdocamt END
						,CASE	WHEN doctype = 'PA' then 'Payment' WHEN	doctype = 'IN' then 'Invoice'
								ELSE 'Other'
						END as Type
	FROM 	ardoc (NOLOCK)
	WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
	and doctype = 'PA'
	and docdate between '#Variables.StartRange#' and '#DateFormat(Now(), "yyyy-mm-dd")#'
	ORDER BY PerClosed, type
</CFQUERY>

<!--- ==============================================================================
Retrieve Solomon Transactions to Date.
Original code written by John Lian for Solomon Lookup.
=============================================================================== --->
<CFQUERY NAME = "StatementsTotal" DATASOURCE = "SOLOMON-HOUSES">
	SELECT 	sum(OrigDocAmt) as Total
	FROM 	ardoc (nolock) 
	WHERE	custid = '#TRIM(Tenant.cSolomonKey)#'
	and doctype = 'PA'
	and docdate between '#Variables.StartRange#' and '#DateFormat(Now(), "yyyy-mm-dd")#'
	GROUP BY doctype, refnbr, docdate, docdesc, custid, user1, user3, user7, PerClosed, OrigDocAmt
	ORDER BY PerClosed
</CFQUERY>

<!--- ==============================================================================
Retrieve any Move Out Charges already created for this tenant
=============================================================================== --->
<CFQUERY NAME = "MoveOutCharges" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*, INV.cComments as Comments, IM.cComments as InvoiceComments
	FROM InvoiceMaster IM (nolock) 
	JOIN InvoiceDetail INV (nolock) ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID and INV.dtRowDeleted is null
	and IM.dtrowdeleted is null and IM.bMoveOutInvoice is not null and im.bfinalized is null
	and INV.dtRowDeleted IS NULL and INV.iTenant_ID = #form.iTenant_ID#
	JOIN ChargeType CT (nolock) ON CT.iChargeType_ID = INV.iChargeType_ID
</CFQUERY>
<!---<cfdump var="#MoveOutCharges#">--->
<CFSCRIPT>DamageComments = ''; OtherComments = '';</CFSCRIPT>
<!--- ==============================================================================
Retreive the Solomon Past Balance for this tenant
=============================================================================== --->
<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200>
	<CFSET PerPost = Year(SESSION.AcctStamp) & DateFormat(SESSION.AcctStamp,"mm")>
	<CFQUERY NAME = "PastBalance" DATASOURCE = "SOLOMON-HOUSES">		
		SELECT 	sum(case when doctype in ('PA','CM', 'SB', 'PP') THEN -origdocamt ELSE origdocamt end) as PastDue
		FROM 	ARDOC (nolock) 
		WHERE 	custid='#Tenant.cSolomonKey#'
		AND		PerPost = '#PerPost#'
	</CFQUERY>
</CFIF>
<!--- ==============================================================================
Check if there is deferred NRF remaining                                            
=============================================================================== --->
<cfquery name="qryDefNRF"  datasource="#application.datasource#">
select t.cfirstname
	, t.clastname
	,IsNull(ts.mBaseNRF,0) as 'BaseNRF'
	,IsNull(ts.mAdjNRF,0) as 'AdjNRF'
	<!--- ,rc.mAmount as 'DeferredNRF' --->
	,rc.cdescription
	,ts.cNRFAdjApprovedBy
	,rc.dtRowStart
	,rc.dtEffectiveStart
	,rc.dtEffectiveEnd
	,rc.dtRowDeleted
		,ts.cNRFAdjApprovedBy
		,ts.dtMoveIn	
		,IsNull(ts.mAmtDeferred,0) as 'mAmtDeferred'
		,IsNUll(ts.mAdjNRF,0)   as 'AdjNRF'
		,rc.dtRowDeleted
		,IsNull(ts.imonthsdeferred,0)	as 'nbrpaymnt'		
		,IsNull(ts.mAmtNRFPaid,0) as 'mAmtNRFPaid'
		,IsNull((	select count (mamount)
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =  t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null			
			and im.bFinalized = 1
			),0) as  nbrpaymentmade
		,IsNull(	(select sum (mamount)
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =   t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null
			and im.bFinalized = 1
			),0) as Accum	
from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id
	join dbo.RecurringCharge RC on RC.iTenant_ID = t.iTenant_ID 
  	join Charges Chg on Chg.icharge_id = Rc.icharge_id
		and ichargetype_id = 1741
where T.iTenant_ID = #url.ID#
</cfquery>

<cfoutput query="qryDefNRF">
<cfif  AdjNRF is "">
 	<cfset thisadjnrf = 0>
<cfelse>
	<cfset thisadjnrf = AdjNRF>
</cfif>

<cfif  qryDefNRF.mAmtNRFPaid is "">
 	<cfset thismAmtNRFPaid = 0>
</cfif>	

<cfif qryDefNRF.nbrpaymnt is ""  >
	<cfset thisNbrPaymnt = 1>
<cfelseif qryDefNRF.nbrpaymnt  is 0>
	<cfset thisNbrPaymnt = 1>
</cfif>
	<cfset thismAmtNRFPaid = AdjNRF/thisNbrPaymnt>


<cfif  qryDefNRF.Accum is "">
 	<cfset thisAccum = 0>
<cfelse>
	<cfset thisAccum= qryDefNRF.Accum>
</cfif>
<cfset paymentmonths =  abs(mAmtDeferred/thisNbrPaymnt) * -1>
<cfset monthlypayment = abs((AdjNRF - mamtNRFPaid)/thisNbrPaymnt) >
<!--- <cfset monthlypayment = abs(mAmtDeferred/ nbrpaymnt)> --->
<cfset paymentrem =  thisNbrPaymnt -  nbrpaymentmade>
<cfset paymentsmade = nbrpaymentmade>
 
<cfset remainingbal =  ((thisadjnrf- thismAmtNRFPaid)   - thisAccum) >
  
</cfoutput>

<!--- ==============================================================================
Check to see if the points are within range of this set
=============================================================================== --->
<CFQUERY NAME="qGetMinMax" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Min(iSPointsMin) as MinimumPoints, Max(iSPointsMax) As MaxPoints
	FROM	SLevelType (nolock) 
	<CFIF Tenant.cSLevelTypeSet EQ ""> 
		WHERE cSLevelTypeSet = #SESSION.cSLevelTypeSet# 
	<CFELSE>
	 	WHERE cSLevelTypeSet = #Tenant.cSLevelTypeSet#
	 </CFIF>
</CFQUERY>

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
		<TR>
			<TD>
				<CFIF ShowBtn>
					<A HREF="../MainMenu.cfm">Click Here to Return to the Summary Section</A>
				<CFELSE>
					<A HREF="../census/FinalizeMoveOut.cfm">Click Here to Go Back.</A>
				</CFIF>
			</TD>
		</TR>
	</TABLE>
	<CFABORT>
</CFOUTPUT>	
</CFIF>

<!--- ==============================================================================
Retrieve the ServiceLevel
=============================================================================== --->
<CFQUERY NAME="GetSLevel" DATASOURCE="#APPLICATION.datasource#">
	SELECT * 
	FROM SLevelType (nolock) 
	<CFIF Tenant.cSLevelTypeSet EQ ""> WHERE cSLevelTypeSet = #SESSION.cSLevelTypeSet# <CFELSE> WHERE cSLevelTypeSet = #Tenant.cSLevelTypeSet# </CFIF>
	AND	iSPointsMin <= #Tenant.iSPoints# AND iSPointsMax >= #Tenant.iSPoints#
	AND	dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Stored Proc. to find the date the tenant dropped to state 3
=============================================================================== --->
<CFQUERY NAME="FindDtStateChange" DATASOURCE = "#APPLICATION.datasource#">
	SELECT isnull(min(stateDtRowStart), getdate()) dtStateChange
	FROM rw.vw_Tenant_History_with_State
	WHERE tendtRowDeleted IS NULL AND statedtRowDeleted IS NULL	
	AND iTenant_ID = #Tenant.iTenant_ID#
	AND cSolomonKey = '#Tenant.cSolomonKey#'
	AND iAptAddress_ID = #Tenant.iAptAddress_ID#
	AND iTenantStateCode_ID = 3
</CFQUERY>

<!--- ==============================================================================
Stored Proc. to find if there is another tenant in the room
=============================================================================== --->
<CFQUERY NAME="FindOccupancy" DATASOURCE = "#APPLICATION.datasource#">
	SELECT *
	FROM rw.vw_Tenant_History_with_State
	WHERE iAptAddress_ID = #Tenant.iAptAddress_ID#
	AND	iTenantStateCode_ID = 2 AND tendtRowDeleted IS NULL AND statedtRowDeleted IS NULL
	AND <CFIF IsDefined("FindDtStateChange.dtStateChange") AND FindDtStateChange.dtStateChange LTE NOW()>#CreateODBCDateTime(FindDtStateChange.dtStateChange)#<CFELSE>getdate()</CFIF> between tendtRowStart and isnull(tendtRowEnd, getDate())
	AND <CFIF IsDefined("FindDtStateChange.dtStateChange") AND FindDtStateChange.dtStateChange LTE NOW()>#CreateODBCDateTime(FindDtStateChange.dtStateChange)#<CFELSE>getdate()</CFIF> between statedtRowStart and isnull(statedtRowEnd, getDate())
	AND cSolomonKey = '#Tenant.cSolomonKey#'
	AND iTenant_ID <> #Tenant.iTenant_ID#
	ORDER BY iSPoints DESC
</CFQUERY>

<!--- ==============================================================================
Get Acuity Level of other Tenant (if exists)
=============================================================================== --->
<CFIF FindOccupancy.RecordCount GT 0>
	<CFQUERY NAME="qOtherTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT *, SLT.cDescription as Level
		FROM  Tenant T (nolock) 
		JOIN SLevelType SLT (nolock) ON SLT.cSLevelTypeSet = T.cSLevelTypeSet
		JOIN TenantState TS (nolock) ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL)
		WHERE T.dtRowDeleted IS NULL AND SLT.dtRowDeleted IS NULL
		AND	iSPointsMin <= #FindOccupancy.iSPoints#
		AND	iSPointsMax >= #FindOccupancy.iSPoints#
		AND	T.iTenant_ID <> #Tenant.iTenant_ID#
		AND	T.cSolomonKey = '#Tenant.cSolomonKey#'
	</CFQUERY>
</CFIF>

<CFSCRIPT>
	if (IsDefined("PastBalance.RecordCount") AND PastBalance.RecordCount GT 0 AND FindOccupancy.RecordCount EQ 1) { PastDue = PastBalance.PastDue; }
	else { PastDue = 0.00; }
	if (FindOccupancy.RecordCount GT 0) { Occupancy = 2; } else { Occupancy = 1; }
</CFSCRIPT>


<CFQUERY NAME="CheckCompanionFlag" DATASOURCE="#APPLICATION.datasource#">
	SELECT bIsCompanionSuite
	FROM AptAddress AD (nolock) 
	JOIN AptType AT (nolock) ON (AD.iAptType_ID = AT.iAptType_ID AND AT.dtRowDeleted is NULL)
	WHERE AD.dtRowDeleted IS NULL AND AD.iAptAddress_ID = #Tenant.iAptAddress_ID#
</CFQUERY>

<CFIF CheckCompanionFlag.bIsCompanionSuite EQ 1> <CFSET Occupancy = 1> </CFIF>

<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut NEQ ""> <CFSET dtMoveOut=Tenant.dtMoveOut> <CFELSE> <CFSET dtMoveOut=Now()> </CFIF>
<!---<cfdump var="#session#">
<cfoutput>house number #session.nhouse#</cfoutput>--->
<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
	<CFIF Tenant.iResidencyType_ID NEQ 3>
		EXEC rw.sp_MoveOutMonthlyRate @iTenant_ID=#Tenant.iTenant_ID#, @HouseNumber=#session.nhouse#,@dtComparison=<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF> 
	<CFELSE>
		SELECT  *, mAmount as mRoomAmount, 0 as mCareAmount
		FROM Charges (nolock) 
		WHERE iHouse_ID = #Tenant.iHouse_ID#
		AND iResidencyType_ID = #Tenant.iResidencyType_ID#
		AND iOccupancyPosition = #Occupancy#
		AND (iAptType_ID = #Tenant.iAptType_ID# OR iAptType_ID IS NULL)
		AND dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
		AND dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
		AND Charges.iProductLine_ID = #Tenant.iProductLine_ID#
	</CFIF>
</CFQUERY>
<!--- <cfoutput> test 1 </cfoutput> --->

<CFIF Tenant.iResidencyType_ID EQ 2>
	<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
		Select 0 mRoomAmount, 0 mCareAmount
	</CFQUERY>
</CFIF>

<CFIF (IsBlank(StandardRent.mRoomAmount,0) + IsBlank(StandardRent.mCareAmount,0)) LTE 0 OR Tenant.cBillingType EQ 'D'>
	<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
	<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
		<CFIF Occupancy EQ 1>
			SELECT	C.cDescription ,C.mAmount as mRoomAmount,C.iQuantity ,CT.iChargeType_ID, 0 as mCareAmount
			FROM	Charges C (nolock) 
			JOIN	ChargeType CT (nolock) on CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND	CT.bIsDaily IS NULL AND	CT.bSLevelType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.iAptType_ID = #Tenant.iAptType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
			WHERE	C.dtRowDeleted IS NULL
		<CFELSE>
			SELECT	C.cDescription ,C.mAmount as mRoomAmount,C.iQuantity ,CT.iChargeType_ID, 0 as mCareAmount
			FROM	Charges C (nolock) 
			JOIN	ChargeType CT (nolock) ON CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NULL 	AND	CT.bSLevelType_ID IS NULL
			AND	C.iAptType_ID IS NULL AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
			WHERE	C.dtRowDeleted IS NULL
		</CFIF>		
	</CFQUERY>

	<CFIF StandardRent.RecordCount EQ '0'>
	  	<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
		<CFQUERY NAME = "StandardRent" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount as mRoomAmount, 0 as mCareAmount
			FROM Charges C (nolock) 
			JOIN ResidencyTYPE RT (nolock) ON	C.iResidencyType_ID = RT.iResidencyType_ID
			LEFT OUTER JOIN	SLevelType ST (nolock) ON C.iSLevelType_ID = ST.iSLevelType_ID
			JOIN ChargeType CT (nolock) ON CT.iChargeType_ID = C.iChargeType_ID
			WHERE C.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL
			AND	C.iOccupancyPosition = #Occupancy#	
			<CFIF Tenant.cChargeSet NEQ ""> AND	C.cChargeSet = '#Tenant.cChargeSet#' <CFELSE> AND C.cChargeSet IS NULL </CFIF>
			<CFIF Tenant.iResidencyType_ID NEQ 3>
				AND		C.iAptType_ID = #Tenant.iAptType_ID#
				AND		C.iSLevelType_ID = #GetSLevel.iSLevelType_ID#
				AND		CT.bIsDaily IS NULL
			</CFIF>
			AND		C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND		C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
		</CFQUERY>
	</CFIF>
	
	<!---<cfoutput>#Occupancy#</cfoutput>
<cfdump var="#StandardRent#">--->

	<CFIF Tenant.iResidencyType_ID EQ 2>
		<!--- ==================================================================================================
		Added by Paul Buendia 12102002 medicaid tenants will not have reg. room & board or care charges
		================================================================================================== --->
		<CFQUERY NAME="StandardRent" DATASOURCE="#APPLICATION.datasource#">
			SELECT 0 as mRoomAmount, 0 as mCareAmount
		</CFQUERY>
	</CFIF>
    
	<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
	<CFQUERY NAME = "DailyRent" DATASOURCE = "#APPLICATION.datasource#">
		<CFIF Occupancy EQ 1>
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C (nolock) 
			JOIN	ChargeType CT (nolock) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NOT NULL AND	CT.bSLevelType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.iAptType_ID = #Tenant.iAptType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
		<CFELSE>
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C (nolock) 
			JOIN	ChargeType CT (nolock) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			WHERE	C.dtRowDeleted IS NULL
			AND	CT.bIsRent IS NOT NULL
			AND	CT.bIsDiscount IS NULL AND CT.bIsRentAdjustment IS NULL AND CT.bIsMedicaid IS NULL
			AND	CT.bAptType_ID IS NOT NULL AND CT.bIsDaily IS NOT NULL 	AND	CT.bSLevelType_ID IS NULL
			AND	C.iAptType_ID IS NULL
			AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID#
			AND	C.iOccupancyPosition = #Occupancy#
			AND	C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
			AND C.iProductLine_ID = #Tenant.iProductLine_ID#
		</CFIF>	
	</CFQUERY>

	<CFIF DailyRent.RecordCount EQ 0>
		<!--- MLAW 08/17/2006 Add iProductline_ID filter --->
		<CFQUERY NAME = "DailyRent" DATASOURCE = "#APPLICATION.datasource#">
			<CFIF Occupancy EQ 1>
				SELECT	C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
				FROM Charges C (nolock) 
				JOIN ResidencyTYPE RT (nolock) ON C.iResidencyType_ID = RT.iResidencyType_ID
				LEFT OUTER JOIN	SLevelType ST (nolock) ON C.iSLevelType_ID = ST.iSLevelType_ID
				JOIN ChargeType CT ON CT.iChargeType_ID = C.iChargeType_ID
				WHERE C.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL
				<CFIF Tenant.cChargeSet NEQ ""> AND	C.cChargeSet = '#Tenant.cChargeSet#' <CFELSE> AND C.cChargeSet IS NULL </CFIF>
				<CFIF Tenant.iResidencyType_ID NEQ 3>
					AND C.iAptType_ID = #Tenant.iAptType_ID#
					AND	C.iSLevelType_ID = #GetSLevel.iSLevelType_ID#
				</CFIF>
				AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID# AND C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
				AND	CT.bIsDaily IS NOT NULL
				AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
				AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
				AND C.iProductLine_ID = #Tenant.iProductLine_ID#
			<CFELSE>
				SELECT	*
				FROM Charges C (nolock) 
				JOIN ChargeType CT (nolock) ON C.iChargeType_ID = CT.iChargeType_ID
				WHERE C.dtRowDeleted IS NULL
				AND CT.dtRowDeleted IS NULL AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
				AND C.iResidencyType_ID = #Tenant.iResidencyType_ID# AND CT.bIsDaily IS NOT NULL
				AND iOccupancyPosition = 2 AND iSLevelType_ID = #GetSLevel.iSLevelType_ID#
				AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
				AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
				AND C.iProductLine_ID = #Tenant.iProductLine_ID#
			</CFIF>
		</CFQUERY>
	</CFIF>	
			
</CFIF>
	<cfif 	ISDefined("Tenant.dtmoveIn") and  IsDefined("Tenant.dtMoveOut") and (tenant.dtmoveIn lte Tenant.dtMoveOut)> 
	<CFQUERY NAME='qResidentCare' DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
		FROM	Charges C
		JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		AND 	CT.bIsRent IS NOT NULL AND CT.bIsMedicaid IS NULL AND CT.bIsDiscount IS NULL
		AND 	CT.bIsRentAdjustment IS NULL
		WHERE	C.dtRowDeleted IS NULL AND C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
		AND	C.iResidencyType_ID = #Tenant.iResidencyType_ID# AND C.iAptType_ID IS NULL 
		AND iSLevelType_ID = #GetSLevel.iSLevelType_ID# 
		AND CT.bIsDaily IS NULL
		AND iOccupancyPosition IS NULL
		AND	C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
			#CreateODBCDateTime(dtMoveOut)#
		<CFELSE>
			#Now()#
		</CFIF>
		AND	C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>
			#CreateODBCDateTime(dtMoveOut)#
		<CFELSE>
			#Now()#
		</CFIF>
	</CFQUERY>
	</cfif>
	<!--- 25575 - rts - 6/24/2010 - respite billing - get care info ( that is not residency type related) --->
	<cfif Tenant.iResidencyType_ID neq 3>
	<CFQUERY NAME='qDailyCare' DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
		FROM	Charges C
		JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
		and CT.bIsRent IS NOT NULL AND CT.bIsMedicaid IS NULL AND CT.bIsDiscount IS NULL
		and CT.bIsRentAdjustment IS NULL
		and C.dtRowDeleted IS NULL AND C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
		and C.iResidencyType_ID = #Tenant.iResidencyType_ID# AND C.iAptType_ID IS NULL AND iSLevelType_ID = #GetSLevel.iSLevelType_ID# AND CT.bIsDaily IS NOT NULL
		and iOccupancyPosition IS NULL
		and C.dtEffectiveStart <= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
		and C.dtEffectiveEnd >= <CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
	</CFQUERY>
	<cfelse>
		<CFQUERY NAME='qDailyCare' DATASOURCE="#APPLICATION.datasource#">
			SELECT	C.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
			FROM	Charges C
			JOIN	ChargeType CT ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted IS NULL)
			and CT.bIsRent IS NOT NULL AND CT.bIsMedicaid IS NULL AND CT.bIsDiscount IS NULL
			and CT.bIsRentAdjustment IS NULL
			and C.dtRowDeleted IS NULL AND C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			<CFIF Tenant.cChargeSet NEQ ''>AND C.cChargeSet = '#Tenant.cChargeSet#'<CFELSE>AND C.cChargeSet IS NULL</CFIF>
			AND C.iAptType_ID IS NULL AND iSLevelType_ID = #GetSLevel.iSLevelType_ID# AND CT.bIsDaily IS NOT NULL
			and iOccupancyPosition IS NULL
			and C.dtEffectiveStart <= 
					<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
			and C.dtEffectiveEnd >= 
					<CFIF IsDefined("Tenant.dtMoveOut") AND Tenant.dtMoveOut LTE NOW()>#CreateODBCDateTime(dtMoveOut)#<CFELSE>#Now()#</CFIF>
		</CFQUERY>
	</cfif>
	<!--- end 25575 --->
<CFSCRIPT>
	//	If the Tenant is not respite devide std. rent by num days or 30; if is respite do not divide as respites do not have a monthly rate
	if (Tenant.iResidencyType_ID NEQ 3) {
		if (Tenant.iResidencyType_ID EQ 2){ resdays = DaysInMonth(Variables.dtChargeThrough);} else{ resdays=30; }
		if (Tenant.cBillingType eq 'D'){ DailyRentCalc=DailyRent.mAmount; }
		else if (StandardRent.mRoomAmount EQ "" OR StandardRent.mCareAmount EQ "" OR (StandardRent.mRoomAmount + StandardRent.mCareAmount) EQ 0) { DailyRentCalc = 0.00; }
		else { DailyRentCalc = (StandardRent.mRoomAmount + StandardRent.mCareAmount)/resdays; }
	}
	else { DailyRentCalc = (isBlank(StandardRent.mRoomAmount,0) + isBlank(StandardRent.mCareAmount,0)); }

	DailyRent = NumberFormat(DailyRentCalc,"-9999999.99");
</CFSCRIPT>

<!--- ==============================================================================
Retreive a List of Current ChargeTypes
=============================================================================== --->
<CFQUERY NAME="ChargeTypes" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct CT.*
	FROM	ChargeType CT (nolock)
	JOIN Charges C (nolock) ON C.iChargeType_ID = CT.iChargeType_ID AND C.dtRowDeleted IS NULL
	AND	(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR C.iHouse_ID IS NULL)
	<CFIF ListFindNoCase(SESSION.codeblock,23) EQ 0> and CT.bAcctOnly is null </CFIF>
	and CT.dtRowDeleted IS NULL AND CT.bIsMoveOut IS NOT NULL
	ORDER BY CT.cDescription
</CFQUERY>

<!--- ==============================================================================
Retrieve the charges for the chosen charge type
=============================================================================== --->
<CFIF IsDefined("form.OtheriChargeType_ID")>
	<CFIF IsDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB'>
		<CFSET filter=''>
	<CFELSE>
		<CFSET filter='AND C.dtEffectiveStart <= getDate() AND C.dtEffectiveEnd >= getDate()'>
	</CFIF>

	<!--- 12/13/2005 MLAW: check to see if there are any charges for the selected charge type --->
	<cfquery name="ValidateCharges" DATASOURCE="#APPLICATION.datasource#">
		SELECT DISTINCT	iChargeType_ID
		FROM	charges c
		WHERE
			ichargetype_ID = #form.OtheriChargeType_ID#
		AND		
			(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
				OR 
			iHouse_ID IS NULL)	
		AND
			dtrowdeleted is NULL
		AND
			cChargeSet IS NOT NULL
	</cfquery>
	<!--- <CFDUMP var="#ValidateCharges.RecordCount#, #filter#, #Tenant.cChargeset#, #Tenant.cSLevelTypeSet#"> --->
	<cfif ValidateCharges.RecordCount neq 0>
		<!--- 12/13/05 MLAW: C.chargeset matches Tenanat's chargeset --->
		<!--- 03/11/08 SSathya: commented the condition as it did not allow the new aptments to be displayed in the drop-down list for the respite resident--->
		<CFQUERY NAME="ChargesList" DATASOURCE="#APPLICATION.datasource#">
			SELECT	distinct CT.bIsDaily, C.*
			FROM	Charges C (NOLOCK)
			JOIN	ChargeType CT (NOLOCK) ON (C.iChargeType_ID = CT.iChargeType_ID #filter#)	
					<!---AND (C.iAptType_ID = #Tenant.iAptType_ID# OR C.iAptType_ID IS NULL)) --->	
			LEFT OUTER JOIN	SLevelType ST ON (ST.iSLevelType_ID = C.iSLevelType_ID
					AND	ST.cSLevelTypeSet = #Tenant.cSLevelTypeSet#)
			WHERE	C.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL AND ST.dtRowDeleted IS NULL	
			AND		C.iChargeType_ID = #form.OtheriChargeType_ID#
			AND		(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR iHouse_ID IS NULL)	
			<cfif Tenant.cChargeset eq ''>
				AND C.cChargeset is NULL
			<cfelse> 
				AND C.cChargeset = '#Tenant.cChargeset#'
				
			</cfif>
			ORDER BY C.cDescription
			</CFQUERY>
	<cfelse>
		<!--- 12/13/05 MLAW: C.chargeset matches Tenanat's chargeset --->
		<!--- 03/11/08 SSathya: commented the condition as it did not allow the new aptments to be displayed in the drop-down list for the respite resident--->
		<CFQUERY NAME="ChargesList" DATASOURCE="#APPLICATION.datasource#">
			SELECT	distinct CT.bIsDaily, C.*
			FROM	Charges C (NOLOCK)
			JOIN	ChargeType CT (NOLOCK) ON (C.iChargeType_ID = CT.iChargeType_ID #filter#)	
					<!---AND (C.iAptType_ID = #Tenant.iAptType_ID# OR C.iAptType_ID IS NULL)) --->
			LEFT OUTER JOIN	SLevelType ST ON (ST.iSLevelType_ID = C.iSLevelType_ID
					AND	ST.cSLevelTypeSet = #Tenant.cSLevelTypeSet#)
			WHERE	C.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL AND ST.dtRowDeleted IS NULL	
			AND		C.iChargeType_ID = #form.OtheriChargeType_ID#
			AND		(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR iHouse_ID IS NULL)	
			AND C.cChargeset is NULL
			ORDER BY C.cDescription
		</CFQUERY>
	</cfif>
</CFIF>

<!--- ==============================================================================
Retrieve sum of all current charges
=============================================================================== --->
<CFQUERY NAME="Charges" DATASOURCE="#APPLICATION.datasource#">
	SELECT	SUM(INV.mAmount * INV.iQuantity) as SUM
	FROM	InvoiceMaster IM (NOLOCK)
	JOIN	InvoiceDetail INV (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	and inv.dtRowDeleted is null and im.dtrowdeleted is null
	and bMoveInInvoice IS NULL and IM.bMoveOutInvoice IS NOT NULL
	and INV.iTenant_ID = #url.ID# 
	JOIN	ChargeType CT (NOLOCK) ON CT.iChargeType_ID = INV.iChargeType_ID
</CFQUERY>

<!--- ==============================================================================
Retrieve all Current MoveOut Charges
=============================================================================== --->
<CFQUERY NAME = "CurrentCharges" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	INV.*, IM.bMoveOutInvoice, CT.bIsRent, CT.bIsMedicaid, CT.bIsDiscount, INV.cAppliesToAcctPeriod, IM.bEditSysDetails
	FROM InvoiceMaster IM (NOLOCK)
	JOIN InvoiceDetail INV (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	JOIN ChargeType CT (NOLOCK) ON INV.iChargeType_ID = CT.iChargeType_ID	
	WHERE bMoveInInvoice IS NULL AND INV.dtRowDeleted IS NULL AND IM.dtRowDeleted IS NULL AND CT.dtRowDeleted IS NULL 
	AND IM.bMoveOutInvoice IS NOT NULL AND IM.bFinalized IS NULL
	AND INV.iTenant_ID = #url.ID#
	<!--- 05/25/2010 Project 20933 Sathya added this to exclude the display of the late fee thats been added --->
	and (INV.bNoInvoiceDisplay is null OR INV.bNoInvoiceDisplay = 0)
	<!--- End of Code Project 20933 --->
	<!--- 07/28/2010 Project 20933 Part-B sathya added this condition upon project request not to display late fee --->
	<!---This is the only place where its hardcoded for late fee in tips so that the charge is not visible for deletion by AR--->
	and INV.iChargeType_ID not in (1697) <!---mshah removed 1741--->
	<!--- and INV.iChargeType_ID <> 1697   exclude deferred paymnt chg s farmer 02-04-2012 --->
	<!--- End of Code Project 20933 Part-B --->
	order by inv.cappliestoacctperiod, inv.cdescription
</CFQUERY>

<!--- ==============================================================================
Retrieve Detail for selected Charge
=============================================================================== --->
<CFIF IsDefined("form.OtheriCharge_ID") AND form.OtheriCharge_ID NEQ "">
	<CFQUERY NAME = "ChargeDetail" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	*, C.cDescription as cDescription
		FROM	Charges C (NOLOCK)
		JOIN	ChargeType CT (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID)
		WHERE	iCharge_ID = #form.OtheriCharge_ID#
	</CFQUERY>
</CFIF>
 
<CFSCRIPT>
	//Retreive the Recent payments for this House
	if (Tenant.dtChargeThrough NEQ "") {PerPost = Year(Tenant.dtChargeThrough) & DateFormat(Tenant.dtChargeThrough,"mm"); }
	else { PerPost = Year(SESSION.AcctStamp) & DateFormat(SESSION.AcctStamp,"mm"); }
</CFSCRIPT>

<CFQUERY NAME = "Payments" DATASOURCE = "SOLOMON-HOUSES">
	SELECT 	doctype, refnbr, docdate, docdesc, custid, user1, user3, user7, PerClosed,
			mamount = CASE	WHEN doctype in ('PA','CM', 'SB', 'PP') then -origdocamt ELSE origdocamt END
			,CASE	WHEN doctype = 'PA' then 'Payment'	WHEN doctype = 'IN' then 'Invoice'	ELSE 'Other' END as Type
	FROM ardoc (NOLOCK)
	WHERE custid = '#TRIM(Tenant.cSolomonKey)#'
	AND doctype = 'PA' AND PerPost = '#PerPost#'
	ORDER BY PerClosed, type
</CFQUERY>

<!--- ==============================================================================
Retreive Payor Information
=============================================================================== --->
<CFQUERY NAME="Payor" DATASOURCE="#APPLICATION.datasource#">
	SELECT C.*, LTC.iRelationshipType_ID, RT.cDescription as RelationShip
	FROM LinkTenantContact LTC
	JOIN RelationshipType RT (NOLOCK) ON RT.iRelationshipType_ID = LTC.iRelationshipType_ID and RT.dtrowdeleted is null	
	JOIN Contact C (NOLOCK) ON C.iContact_ID = LTC.iContact_ID and c.dtrowdeleted is null
	JOIN Tenant T (NOLOCK) ON LTC.iTenant_ID = T.iTenant_ID and t.dtrowdeleted is null
	WHERE LTC.dtrowdeleted is null   and LTC.bIsPayer IS NOT NULL  
		AND (LTC.iTenant_ID = #url.ID# AND T.cSolomonKey = '#trim(Tenant.cSolomonKey)#')
	order by c.dtrowstart desc
</CFQUERY>
<CFQUERY NAME="MoveOutPayor" DATASOURCE="#APPLICATION.datasource#">
	SELECT C.*, LTC.iRelationshipType_ID, RT.cDescription as RelationShip
	FROM LinkTenantContact LTC
	JOIN RelationshipType RT (NOLOCK) ON RT.iRelationshipType_ID = LTC.iRelationshipType_ID and RT.dtrowdeleted is null	
	JOIN Contact C (NOLOCK) ON C.iContact_ID = LTC.iContact_ID and c.dtrowdeleted is null
	JOIN Tenant T (NOLOCK) ON LTC.iTenant_ID = T.iTenant_ID and t.dtrowdeleted is null
	WHERE LTC.dtrowdeleted is null 
		AND (LTC.iTenant_ID = #url.ID# AND T.cSolomonKey = '#trim(Tenant.cSolomonKey)#')
		AND LTC.bIsMoveOutPayer = 1
	order by c.dtrowstart desc
</CFQUERY>
<!--- ==============================================================================
Retrieve if Security Deposit has been paid
=============================================================================== --->
<CFQUERY NAME="Refundable" DATASOURCE="#APPLICATION.datasource#">
	SELECT	sum(INV.mAmount) as mAmount
	FROM	InvoiceMaster IM (NOLOCK)
	JOIN	InvoiceDetail INV (NOLOCK) ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
	JOIN	ChargeType CT (NOLOCK) ON INV.iChargeType_ID = CT.iChargeType_ID	
	JOIN	DepositLOG DL (NOLOCK) ON DL.iTenant_ID = INV.iTenant_ID	
	JOIN	DepositType DT (NOLOCK) ON DT.iDepositType_ID = DL.iDepositType_ID
	WHERE	bMoveInInvoice IS NOT NULL 
	AND	INV.dtRowDeleted IS NULL
	AND	INV.iTenant_ID = #url.ID#
	AND	CT.cGLAccount = 1030
	AND	DT.bIsFee IS NULL
</CFQUERY>

<!--- ==============================================================================
Retrieve all current GLAccounts
=============================================================================== --->
<CFQUERY NAME="GLAccounts" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct cGLaccount FROM ChargeType WHERE dtRowDeleted IS NULL
</CFQUERY>

<!--- ------------------------------------------------------------------------------
Retrieve information for chosen reason
ticket# 92432
------------------------------------------------------------------------------- --->
<CFIF IsDefined("url.Rsn") and url.Rsn is not ""> 
	<CFQUERY NAME="ChosenReason" DATASOURCE="#APPLICATION.datasource#">
		SELECT * FROM MoveReasonType WHERE iMoveReasonType_ID = #url.Rsn# AND dtRowDeleted IS NULL order by iDisplayOrder
	</CFQUERY>
<CFELSEIF Tenant.Reason NEQ "">
	<CFQUERY NAME="ChosenReason" DATASOURCE = "#APPLICATION.datasource#">
		SELECT * FROM MoveReasonType WHERE iMoveReasonType_ID = #Tenant.iMoveReasonType_ID# AND dtRowDeleted IS NULL order by iDisplayOrder
	</CFQUERY>
	<CFSET url.Rsn = Tenant.iMoveReasonType_ID>
	<CFSET url.stp = 4>
</CFIF>

<!--- ==============================================================================
Retrieve list of reasons depending on if voluntary or involuntary
=============================================================================== --->
<CFQUERY NAME="Reason" DATASOURCE = "#APPLICATION.datasource#">
	SELECT *
	FROM MoveReasonType (NOLOCK)
	<CFIF IsDefined("URL.Vol") AND URL.Vol GT 0>
		WHERE bIsVoluntary IS NOT NULL	
	<CFELSEIF IsDefined("URL.Vol") AND URL.Vol EQ 0>
		WHERE bIsVoluntary IS NULL
	<CFELSEIF IsDefined("url.Rsn") AND ChosenReason.bIsVoluntary NEQ "">
		WHERE bIsVoluntary = #ChosenReason.bIsVoluntary#
	<CFELSE>
		WHERE bIsVoluntary is null
	</CFIF>
	AND dtRowDeleted IS NULL order by iDisplayOrder
</CFQUERY>
<!--- <cfquery name="qryOrigPaymnt"  datasource="#application.datasource#"> 
 select IsNull(sum(inv.mamount),0) as totlamount 
 from invoicedetail inv 
  join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id  
  join tenant t on inv.itenant_id = t.itenant_id
  where
   inv.ichargetype_id = 1741 
 and inv.dtrowdeleted is null
 and im.dtrowdeleted is null 
 and t.itenant_id = #url.ID#
 </cfquery> --->
 
 <cfquery name="qryPayments"  datasource="#application.datasource#">
 select   isNull(sum(inv.mamount), 0)  as totalpayments
 from invoicedetail inv  
 join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id  
 join tenant t on t.itenant_id = inv.itenant_id
 join tenantstate ts on t.itenant_id = ts.itenant_id
 where   inv.ichargetype_id = 1741 
 and inv.dtrowdeleted is null
 and im.dtrowdeleted is null 
 and im.bfinalized = 1
and t.itenant_id = #url.ID# 
</cfquery>
<cfset totalpayments = qryPayments.totalpayments>
<!--- <cfif ((Isnumeric(tenant.iMonthsDeferred)) and (tenant.iMonthsDeferred gt 0))>

<cfset totalpayments = (qryPayments.paymentamt/tenant.iMonthsDeferred) + qryOrigPaymnt.totlamount>
<cfelse>
<cfset totalpayments = (qryPayments.paymentamt/1) + qryOrigPaymnt.totlamount>
</cfif> --->
<!--- *******************************************************************************
TEMPORARY
Retrieve All Move reason Types
******************************************************************************** --->
<CFQUERY NAME="qVoluntaryReason" DATASOURCE="#APPLICATION.datasource#">
	SELECT * FROM MoveReasonType WHERE dtRowDeleted IS NULL AND bIsVoluntary IS NOT NULL ORDER BY iDisplayOrder,cDescription
</CFQUERY>

<!--- *******************************************************************************
TEMPORARY
Retrieve All Move reason Types
******************************************************************************** --->
<CFQUERY NAME="qInVoluntaryReason" DATASOURCE="#APPLICATION.datasource#">
	SELECT * FROM MoveReasonType WHERE dtRowDeleted IS NULL AND bIsVoluntary IS NULL ORDER BY iDisplayOrder,cDescription
</CFQUERY>
<!--- 51267 - 4/1/2010 RTS - MO Codes - for secondary reason --->
<cfquery name="qInVoluntaryReason2" dbtype="query">
	select * from qInVoluntaryReason where cDescription not like '%Death%' ORDER BY iDisplayOrder
</Cfquery>
<!--- end 51267 --->
<!--- 51267 - RTS - MO Codes 3/29/2010 --->
<cfquery name="TenantMOLocation" DATASOURCE="#APPLICATION.datasource#">
	Select * from TenantMOLocation where dtRowDeleted is null 
</cfquery>
<!--- end 51267 --->
<!--- ==============================================================================
Mamta - Retreive if Tenant is Primary 
=============================================================================== --->
<CFQUERY NAME = "IsTenantPrimary" DATASOURCE = "#APPLICATION.datasource#">
	Select distinct
		c.ioccupancyposition
	from
		tenantstate t,
		recurringcharge r,
		charges c
	where
		t.itenant_ID=r.itenant_ID
	and r.Icharge_ID=c.Icharge_ID
	and c.ioccupancyposition is not Null
	and r.dtRowDeleted is NULL
	and c.dtRowDeleted is NULL
	and t.itenant_ID=#url.ID#
</CFQUERY>
<!--- ==============================================================================
Mamta - Retreive if secondary tenant exists\added c.dtRowDeleted,order by r.iRecurringCharge_ID 
DESC this to avoid the issue of older chargeset
=============================================================================== --->
<CFQUERY NAME = "SecondaryTenantExist" DATASOURCE = "#APPLICATION.datasource#">
select ts.itenant_id, r.iRecurringCharge_ID
from 
tenantstate ts,
tenant t,
recurringcharge r,
charges c
where
ts.itenant_id= t.itenant_ID
and t.itenant_ID=r.itenant_ID
and r.Icharge_ID=c.Icharge_ID
and ts.iaptaddress_id=#Tenant.iAptAddress_ID# 
and ts.dtrowdeleted is null
and ts.dtchargethrough is null
and r.dtRowDeleted is NULL
and c.dtRowDeleted is NULL 
and ts.itenantstatecode_ID=2
and c.ioccupancyposition=2
and ts.itenant_id != #url.ID#
order by r.iRecurringCharge_ID DESC
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
<!---  08/04/2006 MLAW If ShowBtn is true then show Header else add the style sheet --->
<CFIF ShowBtn>
	<CFINCLUDE TEMPLATE="../../header.cfm">	
    <!---<A HREF="../MainMenu.cfm" STYLE="font-size: 14;">Click Here to Go Back To TIPS Summary.</A>--->
	<table style="border:none;">
		<tr>
			<td>
			<A HREF="../MainMenu.cfm" STYLE="font-size: 14;">Click Here to Go Back To TIPS Summary.</A>
			
			</td>
		
			<td colspan="2">
			Need help with a Move Out? Select here:&nbsp;&nbsp; <a href="HelpwithMoveoutProcess.pdf" target="new"> <img src="../../images/Move-In-Help.jpg" width="25" height="25"/> <a/>
			</td>
		</tr>
	</table>
<CFELSE>
	<style type="text/css">
	<!--
	body {
		background-color: #FFFFCC;
	}
	-->
	</style>
	<CFOUTPUT>
		<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
			<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
		<CFELSE>
			<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
		</CFIF>
	</CFOUTPUT>
</CFIF>
<!--- 04/10/08 Ssathya added this for validation so that the billing info is not missed --->
<!--- Project 30096 modification 11/18/2008 sathya added more fields for validation --->

<script>
	//Project 30096 added this function as it calculates the number of days in a month
	function daysInMonth(iMonth, iYear)
   {
 	return 32 - new Date(iYear, iMonth, 32).getDate();
  }


//mstriegel 03/10/2018
	function RespiteMoveOut(){

		 if( document.MoveOutForm.ARCheck.value == 1){ 
		 	
		 	if(document.MoveOutForm.ResidencyType.value != 3){
		 		
				return checkbillinginfoonsaveForAR(); 
			}
			else if (document.MoveOutForm.ResidencyType.value == 3 && document.MoveOutForm.dtNoticeDateChk.value != ''){
				return	checkbillinginfoonsaveForAR();
			}
			else{
				return checkbillinginfoonsaveForARnonotice();
			}
		 }
		 else{
			if(document.MoveOutForm.ResidencyType.value != 3){
				return checkbillinginfoonsave();
			}
			else if (document.MoveOutForm.ResidencyType.value == 3 && document.MoveOutForm.dtNoticeDateChk.value != ''){
				return checkbillinginfoonsave();
			}
			else{
				return checkbillinginfoonsavenonotice();
			}
		}
	}

	function checkbillinginfoonsavenonotice()
		{
			//#51267-RTS-3/19/2010 - MO Codes
			if (document.forms[0].DisplayReason2.checked != ''){
				if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text){
					alert("The secondary Move Out Reason cannot \n be the same as the primary.");
					window.scrollTo(1,1);
					return false;
				}
				if(MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text == "Select Item"){
					alert("The secondary Move Out Reason cannot \n be 'Select Item'.");
					window.scrollTo(1,1);
					return false;
				}
				var death = MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text;
				if(((death.indexOf("Death")) > 0) || (MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Death")){
					alert("The secondary Move Out Reason cannot \nexist when primary is Death.");
					window.scrollTo(1,1);
					return false;
				}
			}
			if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
				alert("The primary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
			if(MoveOutForm.slctTenantMOLocation.options[MoveOutForm.slctTenantMOLocation.selectedIndex].text == 'Select Location') {
				alert("The Destination Location cannot be 'Select Location'.");
				window.scrollTo(1,1);
				return false;
			}
			//end 51267
			
			<!--- Project 30096 modification 11/18/2008 sathya added this code --->
			var chargedyear = (document.MoveOutForm.ChargeYear.value); 
			var chargedmonth = (document.MoveOutForm.ChargeMonth.value)-1;
			var chargedday = (document.MoveOutForm.ChargeDay.value); 
			var chargedDate = new Date(chargedyear, chargedmonth, chargedday);
					
			var movedoutyear = (document.MoveOutForm.MoveOutYear.value); 
			var movedoutmonth = (document.MoveOutForm.MoveOutMonth.value)-1;
			var movedoutday = (document.MoveOutForm.MoveOutDay.value); 
			var movedoutdate = new Date(movedoutyear, movedoutmonth, movedoutday);
			
			var noticemonth = (document.MoveOutForm.NoticeMonth.value)-1;
			var noticeday =(document.MoveOutForm.NoticeDay.value);
			var noticeyear =(document.MoveOutForm.NoticeYear.value);
			var noticeDate = new Date(noticeyear,noticemonth,noticeday);

			//var chargedDateforvalidation = new Date(chargedyear, chargedmonth-1, chargedday);
			var currentDate = new Date();
			
			var currentMonth = currentDate.getMonth();
			//var nextMonth = currentMonth + 1;
			//var priorMonth = currentDate.getMonth()-1;
			
					
			var currentYear = currentDate.getYear();
			var priorYear = currentDate.getYear() - 1;
			var nextYear = currentDate.getYear() + 1;
			
			if(currentMonth ==11)
			{
				var priorMonth = 10;
				var nextMonth = 0;
				//var priornumberofdays= daysInMonth(priorMonth,currentYear);
				var priorMonthDate = new Date(currentYear,priorMonth,1);
				
				var nextnumberofdays= daysInMonth(nextMonth,nextYear);
				var nextMonthDate = new Date(nextYear,nextMonth,nextnumberofdays);
				
			}
			else if(currentMonth ==0)
			{
				var priorMonth = 11;
				var nextMonth = 1;
				//var priornumberofdays= daysInMonth(priorMonth,priorYear);
				var priorMonthDate = new Date(priorYear,priorMonth,1);
				
				var nextnumberofdays= daysInMonth(nextMonth,currentYear);
				var nextMonthDate = new Date(currentYear,nextMonth,nextnumberofdays);
				
			}
			else
			{
				var nextMonth = currentMonth + 1;
				var priorMonth = currentDate.getMonth()-1;
				//var priornumberofdays= daysInMonth(priorMonth,currentYear);
				var priorMonthDate = new Date(currentYear,priorMonth,1);
				
				var nextnumberofdays= daysInMonth(nextMonth,currentYear);
				var nextMonthDate = new Date(currentYear,nextMonth,nextnumberofdays);
				
			}
			
			
			var NoticeDate1 =document.MoveOutForm.NoticeMonth.value + "/" + document.MoveOutForm.NoticeDay.value + "/" + document.MoveOutForm.NoticeYear.value;
			var ChargeDate1 =document.MoveOutForm.ChargeMonth.value + "/" + document.MoveOutForm.ChargeDay.value + "/" + document.MoveOutForm.ChargeYear.value;
			var MoveOutDate1 =document.MoveOutForm.MoveOutMonth.value + "/" + document.MoveOutForm.MoveOutDay.value + "/" + document.MoveOutForm.MoveOutYear.value;
		
			if(document.MoveOutForm.cFirstName.value=='')
			{
				//Project 30096 modification 11/18/2008 sathya added this 
				document.MoveOutForm.cFirstName.focus();
				alert("Please enter the Bill to FirstName ");
				return false;
			}
			
			else if(document.MoveOutForm.cLastName.value=='')
			{
				//Project 30096 modification 11/18/2008 sathya added this 
				document.MoveOutForm.cLastName.focus();
				alert("Please enter the Bill to LastName ");
				return false;
			}
			else if(document.MoveOutForm.cAddressLine1.value=='')
			{
				//Project 30096 modification 11/18/2008 sathya added this 
				document.MoveOutForm.cAddressLine1.focus();
				alert("Please enter the Address for the Bill to");
				return false;
			}
			else if(document.MoveOutForm.cCity.value=='')
			{
				//Project 30096 modification 11/18/2008 sathya added this 
				document.MoveOutForm.cCity.focus();
				alert("Please enter the City of the Bill to");
				return false;
			}
			else if(document.MoveOutForm.cZipCode.value=='')
			{
				//Project 30096 modification 11/18/2008 sathya added this 
				document.MoveOutForm.cZipCode.focus();
				alert("Please enter the Zip Code of the Bill to")
				return false;
			}
		
		//Project 30096 modification 11/18/2008 sathya added some more fields for validation Charge month, day and year.
		 	else if(document.MoveOutForm.ChargeMonth.value =='')
			{
				document.MoveOutForm.ChargeMonth.focus();
				alert("Please enter a valid Charge Month")
				return false;
			}
			else if(document.MoveOutForm.ChargeMonth.value >=13)
			{
				document.MoveOutForm.ChargeMonth.focus();
				alert("Please enter a valid Charge Month")
				return false;
			}
			else if(document.MoveOutForm.ChargeDay.value =='')
			{
				document.MoveOutForm.ChargeDay.focus();
				alert("Please enter a valid Charge Day")
				return false;
			}
			else if(document.MoveOutForm.ChargeDay.value >=32)
			{
				document.MoveOutForm.ChargeDay.focus();
				alert("Please enter a valid Charge Day")
				return false;
			}
			else if(document.MoveOutForm.ChargeYear.value =='')
			{
				document.MoveOutForm.ChargeYear.focus();
				alert("Please enter a valid Charge Year");
				return false;
			}
			else if(ValidatedateifValid(ChargeDate1)== false)
			{
				document.MoveOutForm.ChargeYear.focus();
				alert("Please enter a valid Charge Through date by validate function");
				return false;
			}
			else if((chargedDate <priorMonthDate) || (chargedDate >nextMonthDate) )
			{
				document.MoveOutForm.ChargeMonth.focus();
				alert(" Charge Month can be prior, current and next month");
				return false;
			}
			else if ((document.MoveOutForm.ChargeYear.value < priorYear) || (document.MoveOutForm.ChargeYear.value >nextYear))
			{
				document.MoveOutForm.ChargeYear.focus();
				alert(" ChargeYear Year can be prior, current and next year only");
				return false;
			}		
			else if(document.MoveOutForm.MoveOutMonth.value =='')
			{
				document.MoveOutForm.MoveOutMonth.focus();
				alert("Please enter a valid MoveOut Month")
				return false;
			}
			else if(document.MoveOutForm.MoveOutMonth.value >=13)
			{
				document.MoveOutForm.MoveOutMonth.focus();
				alert("Please enter a valid MoveOut Month")
				return false;
			}
			else if(document.MoveOutForm.MoveOutDay.value =='')
			{
				document.MoveOutForm.MoveOutDay.focus();
				alert("Please enter a valid MoveOut Day")
				return false;
			}
			else if(document.MoveOutForm.MoveOutDay.value >=32)
			{
				document.MoveOutForm.MoveOutDay.focus();
				alert("Please enter a valid MoveOut Day")
				return false;
			}
			else if(document.MoveOutForm.MoveOutYear.value =='')
			{
				document.MoveOutForm.MoveOutYear.focus();
				alert("Please enter a valid MoveOut Year");
				return false;
			}		
			else if((movedoutdate<priorMonthDate ) ||(movedoutdate>nextMonthDate))
			{
				 document.MoveOutForm.MoveOutMonth.focus();
				alert("Move Out Month can be prior, current and next month");
				return false;
				
			}
			else if ((document.MoveOutForm.MoveOutYear.value < priorYear) || (document.MoveOutForm.MoveOutYear.value >nextYear))
			{
				document.MoveOutForm.MoveOutYear.focus();
				alert(" MoveOut Year can be prior, current and next year only");
				return false;
			}
			else if(ValidatedateifValid(MoveOutDate1)== false)
			{
				document.MoveOutForm.MoveOutYear.focus();
				alert("Please enter a valid Physical Move Out date");
				return false;
			}
			else if (chargedDate<movedoutdate)
			{
				document.MoveOutForm.ChargeDay.focus();
				alert("Charge through date cannot be less than the Physical Move Out Date");
				return false;
			}	
			else
			{				
				return true;				
			}
	  }
	
/*	///var dt=dbirthdate
	if (isDate(enterdate)==false){
		return false;
	}
    return true;
}*/
  //Project 30096 ssathya added Validation only for AR only as AR can key in any date but then the charge through date !<Move out date and another condition is
  //Date of notice cannot be a future date
	function checkbillinginfoonsaveForARnonotice()
	{
		//#51267-RTS-3/19/2010 - MO Codes
		if (document.forms[0].DisplayReason2.checked != ''){
			if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text){
				alert("The secondary Move Out Reason cannot \n be the same as the primary.");
				window.scrollTo(1,1);
				return false;
			}

			if(MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text == "Select Item"){
				alert("The secondary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
			var death = MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text;
			if(((death.indexOf("Death")) > 0) || (MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Death")){
				alert("The secondary Move Out Reason cannot \nexist when primary is Death.");
				window.scrollTo(1,1);
				return false;
			}
		}
		if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
			alert("The primary Move Out Reason cannot \n be 'Select Item'.");
			window.scrollTo(1,1);
			return false;
		}
		if(MoveOutForm.slctTenantMOLocation.options[MoveOutForm.slctTenantMOLocation.selectedIndex].text == 'Select Location') {
			alert("The Destination Location cannot be 'Select Location'.");
			window.scrollTo(1,1);
			return false;
		}
		//end 51267
		
		<!--- Project 30096 modification 11/18/2008 sathya added this code --->
		var chargedyear = (document.MoveOutForm.ChargeYear.value); 
		var chargedmonth = (document.MoveOutForm.ChargeMonth.value);
		var chargedday = (document.MoveOutForm.ChargeDay.value); 
		var chargedDate = new Date(chargedyear, chargedmonth-1, chargedday);		
		
		var movedoutyear = (document.MoveOutForm.MoveOutYear.value); 
		var movedoutmonth = (document.MoveOutForm.MoveOutMonth.value);
		var movedoutday = (document.MoveOutForm.MoveOutDay.value); 
		var movedoutdate = new Date(movedoutyear, movedoutmonth-1, movedoutday);
		
		var noticemonth = (document.MoveOutForm.NoticeMonth.value);
		var noticeday =(document.MoveOutForm.NoticeDay.value);
		var noticeyear =(document.MoveOutForm.NoticeYear.value);
		var noticeDate = new Date(noticeyear,noticemonth-1,noticeday);
		//this was commented as the condition is not been checked
		var currentDate = new Date();
		var currentMonth = currentDate.getMonth();
		var currentYear = currentDate.getYear();
		var priorYear = currentDate.getYear() - 1;
		var nextYear = currentDate.getYear() + 1;
			
		var NoticeDate2 =document.MoveOutForm.NoticeMonth.value + "/" + document.MoveOutForm.NoticeDay.value + "/" + document.MoveOutForm.NoticeYear.value;
		var ChargeDate2 =document.MoveOutForm.ChargeMonth.value + "/" + document.MoveOutForm.ChargeDay.value + "/" + document.MoveOutForm.ChargeYear.value;
		var MoveOutDate2 =document.MoveOutForm.MoveOutMonth.value + "/" + document.MoveOutForm.MoveOutDay.value + "/" + document.MoveOutForm.MoveOutYear.value;
 
		if(document.MoveOutForm.cFirstName.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cFirstName.focus();
			alert("Please enter the FirstName  ");
			return false;
		}
		else if(document.MoveOutForm.cLastName.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cLastName.focus();
			alert("Please enter the LastName ");
			return false;
		}
		else if(document.MoveOutForm.iRelationshipType_ID.options[document.MoveOutForm.iRelationshipType_ID.selectedIndex].value=='')
		{
			selectedvalue = document.MoveOutForm.iRelationshipType_ID.options[document.MoveOutForm.iRelationshipType_ID.selectedIndex].value;
			//Project 30096 modification 11/18/2008 sathya added this 
			//document.MoveOutForm.cLastName.focus();
			alert("Please select the Relationship ");
			return false;
		}		
 		
		else if(document.MoveOutForm.cAddressLine1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cAddressLine1.focus();
			alert("Please enter the Address");
			return false;
		}
		else if(document.MoveOutForm.cCity.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cCity.focus();
			alert("Please enter the City");
			return false;
		}
		else if(document.MoveOutForm.cStateCode.options[document.MoveOutForm.cStateCode.selectedIndex].value=='')
		{
			selectedstate = document.MoveOutForm.cStateCode.options[document.MoveOutForm.iRelationshipType_ID.cStateCode].value;
			//Project 30096 modification 11/18/2008 sathya added this 
			//document.MoveOutForm.cLastName.focus();
			alert("Please select the State ");
			return false;
		}
		else if(document.MoveOutForm.cZipCode.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cZipCode.focus();
			alert("Please enter the Zip Code")
			return false;
		}
		else if(document.MoveOutForm.areacode1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this    
			document.MoveOutForm.areacode1.focus();
			alert("Please enter the Phone Area code")
			return false;
		}
		else if(document.MoveOutForm.prefix1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this   
			document.MoveOutForm.prefix1.focus();
			alert("Please enter the Phone prefix number ")
			return false;
		}
		else if(document.MoveOutForm.number1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this   
			document.MoveOutForm.number1.focus();
			alert("Please enter the Phone number ")
			return false;
		}
	 	else if(document.MoveOutForm.ChargeMonth.value =='')
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert("Please enter a valid Charge Month")
			return false;
		}
		else if(document.MoveOutForm.ChargeMonth.value >=13)
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert("Please enter a valid Charge Month")
			return false;
		}
		else if(document.MoveOutForm.ChargeDay.value =='')
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Please enter a valid Charge Day")
			return false;
		}
		else if(document.MoveOutForm.ChargeDay.value >=32)
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Please enter a valid Charge Day")
			return false;
		}
		else if(document.MoveOutForm.ChargeYear.value ==''|| document.MoveOutForm.ChargeYear.value < 2000)
		{
			document.MoveOutForm.ChargeYear.focus();
			alert("Please enter a valid Charge Year");
			return false;
		}
		else if(ValidatedateifValid(ChargeDate2)== false)
		{
			document.MoveOutForm.ChargeYear.focus();
			alert("Please enter a valid Charge Through date");
			return false;
		}		
		else if(document.MoveOutForm.MoveOutMonth.value =='')
		{
			document.MoveOutForm.MoveOutMonth.focus();
			alert("Please enter a valid MoveOut Month")
			return false;
		}
		else if(document.MoveOutForm.MoveOutMonth.value >=13)
		{
			document.MoveOutForm.MoveOutMonth.focus();
			alert("Please enter a valid MoveOut Month")
			return false;
		}
		else if(document.MoveOutForm.MoveOutDay.value =='')
		{
			document.MoveOutForm.MoveOutDay.focus();
			alert("Please enter a valid MoveOut Day")
			return false;
		}
		else if(document.MoveOutForm.MoveOutDay.value >=32)
		{
			document.MoveOutForm.MoveOutDay.focus();
			alert("Please enter a valid MoveOut Day")
			return false;
		}
		else if(document.MoveOutForm.MoveOutYear.value =='' || document.MoveOutForm.MoveOutYear.value < 2000)
		{
			document.MoveOutForm.MoveOutYear.focus();
			alert("Please enter a valid MoveOut Year");
			return false;
		}
		else if(ValidatedateifValid(MoveOutDate2)== false)
		{
			document.MoveOutForm.MoveOutYear.focus();
			alert("Please enter a valid Physical Move Out date");
			return false;
		}
		else if ((noticeDate >  movedoutdate) || (noticeDate > chargedDate))
		{	alert('Notice Date cannot be greater than Moved Out Date or Charge Through Date');
		return false;}
		else if (chargedDate<movedoutdate)
		{
			if(document.MoveOutForm.ResidencyType.value != 3)
				document.MoveOutForm.ChargeDay.focus();
			alert("Charge through date cannot be less than the Physical Move Out Date");
			return false;
		}		
		else
		{			
			return true;
		}
    }

    function validatenonotice(){
		//#51267-RTS-3/19/2010 - MO Codes
		if (document.forms[0].DisplayReason2.checked != ''){
			if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text){
				alert("The secondary Move Out Reason cannot \n be the same as the primary.");
				window.scrollTo(1,1);
				return false;
			}
			if(MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text == "Select Item"){
				alert("The secondary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
			var death = MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text;
			if(((death.indexOf("Death")) > 0) || (MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Death")){
				alert("The secondary Move Out Reason cannot \nexist when primary is Death.");
				window.scrollTo(1,1);
				return false;
			}
		}
		if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
			alert("The primary Move Out Reason cannot \n be 'Select Item'.");
			window.scrollTo(1,1);
			return false;
		}
				
		if (document.forms[0].ChargeMonth.value == '' || document.forms[0].ChargeDay.value =='' || document.forms[0].ChargeDay.year =='') { 
			document.forms[0].ChargeMonth.focus(); alert('Invalid Charge Through Date');
		return false;
		}
		//11/06/2008 project#30096  sathya changed the alert message everything else is the same and not changed at all...
		else
		 if ( document.forms[0].MoveOutMonth.value =='' || document.forms[0].MoveOutDay.value =='' || document.forms[0].MoveOutYear.value =='') {
			document.forms[0].MoveOutMonth.focus(); alert('Please enter a valid Physical Move Out Date');
			return false;
		}
	
		var miyear = (document.MoveOutForm.moveinyear.value); var mimonth = ((document.MoveOutForm.moveinmonth.value) - 1); 
		var miday = (document.MoveOutForm.moveinday.value); var movein = new Date(miyear, mimonth, miday);
		
		var moyear = (document.MoveOutForm.MoveOutYear.value); var momonth = ((document.MoveOutForm.MoveOutMonth.value) - 1);
		var moday = (document.MoveOutForm.MoveOutDay.value); var moveout = new Date(moyear, momonth, moday);
		
		var noyear = (document.MoveOutForm.NoticeYear.value); var nomonth = ((document.MoveOutForm.NoticeMonth.value) - 1);
		var noday = (document.MoveOutForm.NoticeDay.value); var notice = new Date(noyear, nomonth, noday);
		//alert('notice: ' + notice);
		
		var chyear = (document.MoveOutForm.ChargeYear.value); var chmonth = ((document.MoveOutForm.ChargeMonth.value) - 1);
		var chday = (document.MoveOutForm.ChargeDay.value); var charge = new Date(chyear, chmonth, chday);		
		
		
		if (movein > moveout){ var message = ('The MoveOut is before the movein date \r' + 'which is' + ' ' + movein); 
		alert(message); document.forms[0].MoveOutMonth.focus(); return false; }
		else if (movein > notice && document.MoveOutForm.NoticeDay.value !== '')
		{ var message = ('The Notice is before the movein date \r' + 'which is' + ' ' + movein); 
		alert(message); document.forms[0].NoticeMonth.focus(); return false;	}
		else if (movein > charge){ var message = ('The Charge Date is before the movein date \r' + 'which is' + ' ' + movein); 
		alert(message); document.forms[0].ChargeMonth.focus(); return false; }
		
	
		else if (notice > charge){ var message = ('The Notice Date cannot be after the Charge Through date'); alert(message); return false; }
		//04/10/08 Ssathya added the more condtions for validation 
		else if(document.MoveOutForm.cFirstName.value=='')
		{
			alert("Please enter the FirstName");
			return false;
		}
		else if(document.MoveOutForm.cLastName.value=='')
		{
			alert("Please enter the LastName");
			return false;
		}
		
		else if(document.MoveOutForm.cAddressLine1.value=='')
		{
			alert("Please enter the Address");
			return false;
		}
		else if(document.MoveOutForm.cCity.value=='')
		{
			alert("Please enter the City");
			return false;
		}
		else if(document.MoveOutForm.cZipCode.value=='')
		{
			alert("Please enter the Zip Code");
			return false;
		}
		else if(document.MoveOutForm.iRelationshipType_ID.options[document.MoveOutForm.iRelationshipType_ID.selectedIndex].value == ''){
			alert("Select the Relationship of the Contact.");
			
			return false;
		}		
		
		else{return true;}
	}


// end mstriegel 3/10/2018




function checkbillinginfoonsave()
	{
		//#51267-RTS-3/19/2010 - MO Codes
		if (document.forms[0].DisplayReason2.checked != ''){
			if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text){
				alert("The secondary Move Out Reason cannot \n be the same as the primary.");
				window.scrollTo(1,1);
				return false;
			}
			if(MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text == "Select Item"){
				alert("The secondary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
			var death = MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text;
			if(((death.indexOf("Death")) > 0) || (MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Death")){
				alert("The secondary Move Out Reason cannot \nexist when primary is Death.");
				window.scrollTo(1,1);
				return false;
			}
		}
		if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
			alert("The primary Move Out Reason cannot \n be 'Select Item'.");
			window.scrollTo(1,1);
			return false;
		}
		if(MoveOutForm.slctTenantMOLocation.options[MoveOutForm.slctTenantMOLocation.selectedIndex].text == 'Select Location') {
			alert("The Destination Location cannot be 'Select Location'.");
			window.scrollTo(1,1);
			return false;
		}
		//end 51267
		
		<!--- Project 30096 modification 11/18/2008 sathya added this code --->
		var chargedyear = (document.MoveOutForm.ChargeYear.value); 
		var chargedmonth = (document.MoveOutForm.ChargeMonth.value)-1;
		var chargedday = (document.MoveOutForm.ChargeDay.value); 
		var chargedDate = new Date(chargedyear, chargedmonth, chargedday);
				
		var movedoutyear = (document.MoveOutForm.MoveOutYear.value); 
		var movedoutmonth = (document.MoveOutForm.MoveOutMonth.value)-1;
		var movedoutday = (document.MoveOutForm.MoveOutDay.value); 
		var movedoutdate = new Date(movedoutyear, movedoutmonth, movedoutday);
		
		var noticemonth = (document.MoveOutForm.NoticeMonth.value)-1;
		var noticeday =(document.MoveOutForm.NoticeDay.value);
		var noticeyear =(document.MoveOutForm.NoticeYear.value);
		var noticeDate = new Date(noticeyear,noticemonth,noticeday);

		//var chargedDateforvalidation = new Date(chargedyear, chargedmonth-1, chargedday);
		var currentDate = new Date();
		
		var currentMonth = currentDate.getMonth();
		//var nextMonth = currentMonth + 1;
		//var priorMonth = currentDate.getMonth()-1;
		
				
		var currentYear = currentDate.getYear();
		var priorYear = currentDate.getYear() - 1;
		var nextYear = currentDate.getYear() + 1;
		
		if(currentMonth ==11)
		{
			var priorMonth = 10;
			var nextMonth = 0;
			//var priornumberofdays= daysInMonth(priorMonth,currentYear);
			var priorMonthDate = new Date(currentYear,priorMonth,1);
			
			var nextnumberofdays= daysInMonth(nextMonth,nextYear);
			var nextMonthDate = new Date(nextYear,nextMonth,nextnumberofdays);
			
		}
		else if(currentMonth ==0)
		{
			var priorMonth = 11;
			var nextMonth = 1;
			//var priornumberofdays= daysInMonth(priorMonth,priorYear);
			var priorMonthDate = new Date(priorYear,priorMonth,1);
			
			var nextnumberofdays= daysInMonth(nextMonth,currentYear);
			var nextMonthDate = new Date(currentYear,nextMonth,nextnumberofdays);
			
		}
		else
		{
			var nextMonth = currentMonth + 1;
			var priorMonth = currentDate.getMonth()-1;
			//var priornumberofdays= daysInMonth(priorMonth,currentYear);
			var priorMonthDate = new Date(currentYear,priorMonth,1);
			
			var nextnumberofdays= daysInMonth(nextMonth,currentYear);
			var nextMonthDate = new Date(currentYear,nextMonth,nextnumberofdays);
			
		}
		
		
		var NoticeDate1 =document.MoveOutForm.NoticeMonth.value + "/" + document.MoveOutForm.NoticeDay.value + "/" + document.MoveOutForm.NoticeYear.value;
		var ChargeDate1 =document.MoveOutForm.ChargeMonth.value + "/" + document.MoveOutForm.ChargeDay.value + "/" + document.MoveOutForm.ChargeYear.value;
		var MoveOutDate1 =document.MoveOutForm.MoveOutMonth.value + "/" + document.MoveOutForm.MoveOutDay.value + "/" + document.MoveOutForm.MoveOutYear.value;
	
		if(document.MoveOutForm.cFirstName.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cFirstName.focus();
			alert("Please enter the Bill to FirstName ");
			return false;
		}
		
		else if(document.MoveOutForm.cLastName.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cLastName.focus();
			alert("Please enter the Bill to LastName ");
			return false;
		}
		else if(document.MoveOutForm.cAddressLine1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cAddressLine1.focus();
			alert("Please enter the Address for the Bill to");
			return false;
		}
		else if(document.MoveOutForm.cCity.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cCity.focus();
			alert("Please enter the City of the Bill to");
			return false;
		}
		else if(document.MoveOutForm.cZipCode.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cZipCode.focus();
			alert("Please enter the Zip Code of the Bill to")
			return false;
		}
	
	//Project 30096 modification 11/18/2008 sathya added some more fields for validation Charge month, day and year.
	 	else if(document.MoveOutForm.ChargeMonth.value =='')
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert("Please enter a valid Charge Month")
			return false;
		}
		else if(document.MoveOutForm.ChargeMonth.value >=13)
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert("Please enter a valid Charge Month")
			return false;
		}
		else if(document.MoveOutForm.ChargeDay.value =='')
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Please enter a valid Charge Day")
			return false;
		}
		else if(document.MoveOutForm.ChargeDay.value >=32)
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Please enter a valid Charge Day")
			return false;
		}
		else if(document.MoveOutForm.ChargeYear.value =='')
		{
			document.MoveOutForm.ChargeYear.focus();
			alert("Please enter a valid Charge Year");
			return false;
		}
		else if(ValidatedateifValid(ChargeDate1)== false)
		{
			document.MoveOutForm.ChargeYear.focus();
			alert("Please enter a valid Charge Through date by validate function");
			return false;
		}
		else if (noticeDate  > movedoutdate)
			{alert('Notice Date MUST BE Equal or Less Than the Move Out Date');
			return false;}
		else if (noticeDate  > chargedDate)
			{alert('Notice Date MUST BE Equal or Less Than the Charge Through Date');
			return false;}	

	/*	else if ((currentMonth == 0) && ((chargedmonth !=11) && (chargedmonth !=0) && (chargedmonth !=1)))
		{
					document.MoveOutForm.ChargeMonth.focus();
					alert(" Charge Month can be prior, current and next month 0 month");
					return false;
				
				
		}
			else if ((currentMonth == 11) && ((chargedmonth !=10) && (chargedmonth !=0) && (chargedmonth !=11)))
		{
			
					document.MoveOutForm.ChargeMonth.focus();
					alert(" Charge Month can be prior, current and next month only 11 month"+chargedmonth);
					return false;
			
		}
		else if ((currentMonth != 0) && (currentMonth != 11) && ((chargedmonth < priorMonth) || (chargedmonth >nextMonth)))
				{
				
					document.MoveOutForm.ChargeMonth.focus();
					alert(" Charge Month can be prior, current and next month only nor 0 nor 11");
					return false;
				
				}*/
				
		else if((chargedDate <priorMonthDate) || (chargedDate >nextMonthDate) )
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert(" Charge Month can be prior, current and next month");
			return false;
		}
		else if ((document.MoveOutForm.ChargeYear.value < priorYear) || (document.MoveOutForm.ChargeYear.value >nextYear))
		{
			document.MoveOutForm.ChargeYear.focus();
			alert(" ChargeYear Year can be prior, current and next year only");
			return false;
		}
		//Project 30096 modification 11/18/2008 sathya added some more fields for validation Notice month, day and year.
		else if(document.MoveOutForm.NoticeMonth.value =='')
		{
			document.MoveOutForm.NoticeMonth.focus();
			alert("Please enter a valid Notice Month")
			return false;
		}
		else if(document.MoveOutForm.NoticeMonth.value >=13)
		{
			document.MoveOutForm.NoticeMonth.focus();
			alert("Please enter a valid Notice Month")
			return false;
		}
		else if(document.MoveOutForm.NoticeDay.value =='')
		{
			document.MoveOutForm.NoticeDay.focus();
			alert("Please enter a valid Notice Day")
			return false;
		}
		else if(document.MoveOutForm.NoticeDay.value >=32)
		{
			document.MoveOutForm.NoticeDay.focus();
			alert("Please enter a valid Notice Day")
			return false;
		}
		else if(document.MoveOutForm.NoticeYear.value =='')
		{
			document.MoveOutForm.NoticeYear.focus();
			alert("Please enter a valid Notice Year");
			return false;
		}
		
		else if ((document.MoveOutForm.NoticeYear.value < priorYear) ||(document.MoveOutForm.NoticeYear.value >nextYear))
		{
			document.MoveOutForm.NoticeYear.focus();
			alert("Notice Year can be prior, current or next year");
			return false;
		}
	else if( (ValidatedateifValid(NoticeDate1)== false))
		{
			document.MoveOutForm.NoticeYear.focus();
			alert("Please enter a valid notice date");
			return false;
		}
		//Project 30096 modification 11/18/2008 sathya added some more fields for validation Move out month, day and year.
		else if(document.MoveOutForm.MoveOutMonth.value =='')
		{
			document.MoveOutForm.MoveOutMonth.focus();
			alert("Please enter a valid MoveOut Month")
			return false;
		}
		else if(document.MoveOutForm.MoveOutMonth.value >=13)
		{
			document.MoveOutForm.MoveOutMonth.focus();
			alert("Please enter a valid MoveOut Month")
			return false;
		}
		else if(document.MoveOutForm.MoveOutDay.value =='')
		{
			document.MoveOutForm.MoveOutDay.focus();
			alert("Please enter a valid MoveOut Day")
			return false;
		}
		else if(document.MoveOutForm.MoveOutDay.value >=32)
		{
			document.MoveOutForm.MoveOutDay.focus();
			alert("Please enter a valid MoveOut Day")
			return false;
		}
		else if(document.MoveOutForm.MoveOutYear.value =='')
		{
			document.MoveOutForm.MoveOutYear.focus();
			alert("Please enter a valid MoveOut Year");
			return false;
		}
		
	//to check the prior current and previous month validation
		/*	else if ((currentMonth == 0) && ((movedoutmonth !=11) && (movedoutmonth !=0) && (movedoutmonth !=1)))
		{
		
					document.MoveOutForm.MoveOutMonth.focus();
					alert("Moved out Month can be prior, current and next month");
					return false;
				
		}
			else if ((currentMonth == 11) && ((movedoutmonth !=10)&& (movedoutmonth !=0) && (movedoutmonth !=11)))
		{
					document.MoveOutForm.MoveOutMonth.focus();
					alert("Moved out Month can be prior, current and next month ");
					return false;
				
			
		}
		else if ((movedoutmonth != 0) && (movedoutmonth != 11) &&((movedoutmonth < priorMonth) || (movedoutmonth >nextMonth)))
				{
				    document.MoveOutForm.MoveOutMonth.focus();
					alert("Charge Month can be prior, current and next month");
					return false;
				
				
				} */
				
				else if((movedoutdate<priorMonthDate ) ||(movedoutdate>nextMonthDate))
				{
					 document.MoveOutForm.MoveOutMonth.focus();
					alert("Move Out Month can be prior, current and next month");
					return false;
					
				}
	else if ((document.MoveOutForm.MoveOutYear.value < priorYear) || (document.MoveOutForm.MoveOutYear.value >nextYear))
	{
			document.MoveOutForm.MoveOutYear.focus();
			alert(" MoveOut Year can be prior, current and next year only");
			return false;
		}
		else if(ValidatedateifValid(MoveOutDate1)== false)
		{
			document.MoveOutForm.MoveOutYear.focus();
			alert("Please enter a valid Physical Move Out date");
			return false;
		}
		else if (chargedDate<movedoutdate)
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Charge through date cannot be less than the Physical Move Out Date");
			return false;
		}
		else if(noticeDate>currentDate)
		{
			document.MoveOutForm.NoticeYear.focus();
			alert(" Notice Date cannot be a future date ");
			return false;
		}
		
		else
		{
			
			return true;
			
		}
  }

  //Project 30096 ssathya added this as part of Validation 


function isInteger(s){
	var i;
    for (i = 0; i < s.length; i++){   
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

//Project 30096 ssathya added this as part of Validation 
function stripCharsInBag(s, bag){
	var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){   
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}
 //Project 30096 ssathya added this as part of Validation 
function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}
function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
		if (i==2) {this[i] = 29}
   } 
   return this
}
 //Project 30096 ssathya added this as part of Validation 
function isDate(dtStr){
	var dtCh= "/";
	var minYear=1900;
	var year=new Date();
	var maxYear=year.getYear() + 10;
	var daysInMonth = DaysArray(12)
	var pos1=dtStr.indexOf(dtCh)
	var pos2=dtStr.indexOf(dtCh,pos1+1)
	var strMonth=dtStr.substring(0,pos1)
	var strDay=dtStr.substring(pos1+1,pos2)
	var strYear=dtStr.substring(pos2+1)
	strYr=strYear
	if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
	if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
	for (var i = 1; i <= 3; i++) {
		if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
	}
	month=parseInt(strMonth)
	day=parseInt(strDay)
	year=parseInt(strYr)
	if (pos1==-1 || pos2==-1){
		//alert("The date format should be : mm/dd/yyyy")
		return false
	}
	if (strMonth.length<1 || month<1 || month>12){
		//alert("Please enter a valid month")
		return false
	}
	if (strDay.length<1 || day<1 || day>31 || (month==2 && day>daysInFebruary(year)) || day > daysInMonth[month]){
		//alert("Please enter a valid day")
		return false
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		//alert("Please enter a valid 4 digit year between "+minYear+" and "+maxYear)
		return false
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		//alert("Please enter a valid date")
		return false
	}
return true
}


  //Project 30096 ssathya added Validation only for AR only as AR can key in any date but then the charge through date !<Move out date and another condition is
  //Date of notice cannot be a future date
function checkbillinginfoonsaveForAR()
	{ 
		//#51267-RTS-3/19/2010 - MO Codes
		if (document.forms[0].DisplayReason2.checked != ''){
			if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text){
				alert("The secondary Move Out Reason cannot \n be the same as the primary.");
				window.scrollTo(1,1);
				return false;
			}

			if(MoveOutForm.Reason2.options[MoveOutForm.Reason2.selectedIndex].text == "Select Item"){
				alert("The secondary Move Out Reason cannot \n be 'Select Item'.");
				window.scrollTo(1,1);
				return false;
			}
			var death = MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text;
			if(((death.indexOf("Death")) > 0) || (MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Death")){
				alert("The secondary Move Out Reason cannot \nexist when primary is Death.");
				window.scrollTo(1,1);
				return false;
			}
		}
		if(MoveOutForm.Reason.options[MoveOutForm.Reason.selectedIndex].text == "Select Item"){
			alert("The primary Move Out Reason cannot \n be 'Select Item'.");
			window.scrollTo(1,1);
			return false;
		}
		if(MoveOutForm.slctTenantMOLocation.options[MoveOutForm.slctTenantMOLocation.selectedIndex].text == 'Select Location') {
			alert("The Destination Location cannot be 'Select Location'.");
			window.scrollTo(1,1);
			return false;
		}
		//end 51267
		
		<!--- Project 30096 modification 11/18/2008 sathya added this code --->
		var chargedyear = (document.MoveOutForm.ChargeYear.value); 
		var chargedmonth = (document.MoveOutForm.ChargeMonth.value);
		var chargedday = (document.MoveOutForm.ChargeDay.value); 
		var chargedDate = new Date(chargedyear, chargedmonth-1, chargedday);		
		
		var movedoutyear = (document.MoveOutForm.MoveOutYear.value); 
		var movedoutmonth = (document.MoveOutForm.MoveOutMonth.value);
		var movedoutday = (document.MoveOutForm.MoveOutDay.value); 
		var movedoutdate = new Date(movedoutyear, movedoutmonth-1, movedoutday);
		
		var noticemonth = (document.MoveOutForm.NoticeMonth.value);
		var noticeday =(document.MoveOutForm.NoticeDay.value);
		var noticeyear =(document.MoveOutForm.NoticeYear.value);
		var noticeDate = new Date(noticeyear,noticemonth-1,noticeday);
		//this was commented as the condition is not been checked
		var currentDate = new Date();
		var currentMonth = currentDate.getMonth();
		var currentYear = currentDate.getYear();
		var priorYear = currentDate.getYear() - 1;
		var nextYear = currentDate.getYear() + 1;
			
		var NoticeDate2 =document.MoveOutForm.NoticeMonth.value + "/" + document.MoveOutForm.NoticeDay.value + "/" + document.MoveOutForm.NoticeYear.value;
		var ChargeDate2 =document.MoveOutForm.ChargeMonth.value + "/" + document.MoveOutForm.ChargeDay.value + "/" + document.MoveOutForm.ChargeYear.value;
		var MoveOutDate2 =document.MoveOutForm.MoveOutMonth.value + "/" + document.MoveOutForm.MoveOutDay.value + "/" + document.MoveOutForm.MoveOutYear.value;
 
		if(document.MoveOutForm.cFirstName.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cFirstName.focus();
			alert("Please enter the FirstName  ");
			return false;
		}
		else if(document.MoveOutForm.cLastName.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cLastName.focus();
			alert("Please enter the LastName ");
			return false;
		}
		else if(document.MoveOutForm.iRelationshipType_ID.options[document.MoveOutForm.iRelationshipType_ID.selectedIndex].value=='')
		{
			selectedvalue = document.MoveOutForm.iRelationshipType_ID.options[document.MoveOutForm.iRelationshipType_ID.selectedIndex].value;
			//Project 30096 modification 11/18/2008 sathya added this 
			//document.MoveOutForm.cLastName.focus();
			alert("Please select the Relationship ");
			return false;
		}		
 		
		else if(document.MoveOutForm.cAddressLine1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cAddressLine1.focus();
			alert("Please enter the Address");
			return false;
		}
		else if(document.MoveOutForm.cCity.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cCity.focus();
			alert("Please enter the City");
			return false;
		}
		else if(document.MoveOutForm.cStateCode.options[document.MoveOutForm.cStateCode.selectedIndex].value=='')
		{
			selectedstate = document.MoveOutForm.cStateCode.options[document.MoveOutForm.iRelationshipType_ID.cStateCode].value;
			//Project 30096 modification 11/18/2008 sathya added this 
			//document.MoveOutForm.cLastName.focus();
			alert("Please select the State ");
			return false;
		}
		else if(document.MoveOutForm.cZipCode.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this 
			document.MoveOutForm.cZipCode.focus();
			alert("Please enter the Zip Code")
			return false;
		}
		else if(document.MoveOutForm.areacode1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this    
			document.MoveOutForm.areacode1.focus();
			alert("Please enter the Phone Area code")
			return false;
		}
		else if(document.MoveOutForm.prefix1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this   
			document.MoveOutForm.prefix1.focus();
			alert("Please enter the Phone prefix number ")
			return false;
		}
		else if(document.MoveOutForm.number1.value=='')
		{
			//Project 30096 modification 11/18/2008 sathya added this   
			document.MoveOutForm.number1.focus();
			alert("Please enter the Phone number ")
			return false;
		}
	
	//Project 30096 modification 11/18/2008 sathya added some more fields for validation Charge month, day and year.
	
	 	else if(document.MoveOutForm.ChargeMonth.value =='')
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert("Please enter a valid Charge Month")
			return false;
		}
		else if(document.MoveOutForm.ChargeMonth.value >=13)
		{
			document.MoveOutForm.ChargeMonth.focus();
			alert("Please enter a valid Charge Month")
			return false;
		}
		else if(document.MoveOutForm.ChargeDay.value =='')
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Please enter a valid Charge Day")
			return false;
		}
		else if(document.MoveOutForm.ChargeDay.value >=32)
		{
			document.MoveOutForm.ChargeDay.focus();
			alert("Please enter a valid Charge Day")
			return false;
		}
		else if(document.MoveOutForm.ChargeYear.value ==''|| document.MoveOutForm.ChargeYear.value < 2000)
		{
			document.MoveOutForm.ChargeYear.focus();
			alert("Please enter a valid Charge Year");
			return false;
		}
		else if(ValidatedateifValid(ChargeDate2)== false)
		{
			document.MoveOutForm.ChargeYear.focus();
			alert("Please enter a valid Charge Through date");
			return false;
		}
		//Project 30096 modification 11/18/2008 sathya added some more fields for validation Notice month, day and year.
		else if(document.MoveOutForm.NoticeMonth.value =='')
		{
			document.MoveOutForm.NoticeMonth.focus();
			alert("Please enter a valid Notice Month")
			return false;
		}
		else if(document.MoveOutForm.NoticeMonth.value >=13)
		{
			document.MoveOutForm.NoticeMonth.focus();
			alert("Please enter a valid Notice Month")
			return false;
		}
		else if(document.MoveOutForm.NoticeDay.value =='')
		{
			document.MoveOutForm.NoticeDay.focus();
			alert("Please enter a valid Notice Day")
			return false;
		}
		else if(document.MoveOutForm.NoticeDay.value >=32)
		{
			document.MoveOutForm.NoticeDay.focus();
			alert("Please enter a valid Notice Day")
			return false;
		}
		else if(document.MoveOutForm.NoticeYear.value =='' || document.MoveOutForm.NoticeYear.value < 2000)
		{
			document.MoveOutForm.NoticeYear.focus();
			alert("Please enter a valid Notice Year");
			return false;
		}
		else if(ValidatedateifValid(NoticeDate2)== false)
		{
			document.MoveOutForm.NoticeYear.focus();
			alert("Please enter a valid notice date");
			return false;
		}
			//Project 30096 modification 11/18/2008 sathya added some more fields for validation Move out month, day and year.
		else if(document.MoveOutForm.MoveOutMonth.value =='')
		{
			document.MoveOutForm.MoveOutMonth.focus();
			alert("Please enter a valid MoveOut Month")
			return false;
		}
		else if(document.MoveOutForm.MoveOutMonth.value >=13)
		{
			document.MoveOutForm.MoveOutMonth.focus();
			alert("Please enter a valid MoveOut Month")
			return false;
		}
		else if(document.MoveOutForm.MoveOutDay.value =='')
		{
			document.MoveOutForm.MoveOutDay.focus();
			alert("Please enter a valid MoveOut Day")
			return false;
		}
		else if(document.MoveOutForm.MoveOutDay.value >=32)
		{
			document.MoveOutForm.MoveOutDay.focus();
			alert("Please enter a valid MoveOut Day")
			return false;
		}
		else if(document.MoveOutForm.MoveOutYear.value =='' || document.MoveOutForm.MoveOutYear.value < 2000)
		{
			document.MoveOutForm.MoveOutYear.focus();
			alert("Please enter a valid MoveOut Year");
			return false;
		}
		else if(ValidatedateifValid(MoveOutDate2)== false)
		{
			document.MoveOutForm.MoveOutYear.focus();
			alert("Please enter a valid Physical Move Out date");
			return false;
		}
		else if ((noticeDate >  movedoutdate) || (noticeDate > chargedDate))
		{	alert('Notice Date cannot be greater than Moved Out Date or Charge Through Date');
		return false;}
	else if (chargedDate<movedoutdate)
		{
			if(document.MoveOutForm.ResidencyType.value != 3)
				document.MoveOutForm.ChargeDay.focus();
			alert("Charge through date cannot be less than the Physical Move Out Date");
			return false;
		}
		else if(noticeDate>currentDate)
		{
			document.MoveOutForm.NoticeYear.focus();
			alert("Notice Date cannot be a future date");
			return false;
		}
		
		else
		{return true;}
  }
  </script>


<CFOUTPUT>
<BR>

<FORM NAME="MoveOutForm" ACTION="MoveOutForm.cfm?ShowBtn=#ShowBtn#" METHOD="POST" onSubmit="return validdate();"> 
<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#url.ID#">

<INPUT TYPE="Hidden" NAME="moveincareyear" VALUE="#YEAR(Tenant.dtMoveIn)#">
<INPUT TYPE="Hidden" NAME="moveincareday" VALUE="#Day(Tenant.dtMoveIn)#">
<INPUT TYPE="Hidden" NAME="moveincaremonth" VALUE="#Month(Tenant.dtMoveIn)#"> 

<INPUT TYPE="Hidden" NAME="moveinyear" VALUE="#YEAR(Tenant.dtRentEffective)#">
<INPUT TYPE="Hidden" NAME="moveinday" VALUE="#Day(Tenant.dtRentEffective)#">
<INPUT TYPE="Hidden" NAME="moveinmonth" VALUE="#Month(Tenant.dtRentEffective)#">

<INPUT TYPE="Hidden" NAME="StandardRent" VALUE="#StandardRent.mRoomAmount# + #StandardRent.mCareAmount#">
<INPUT TYPE="Hidden" NAME="DailyRent" VALUE="#trim(DailyRent)#">
<INPUT TYPE="Hidden" NAME="Occupancy" VALUE="#Occupancy#">
<input type="hidden" name="ResidencyType" value="#Tenant.iResidencyType_ID#" />

 <!--- mstriegel 03/10/2018 --->
<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
	<input type="hidden" name="ARCheck" value="1">
<cfelse>
	<input type="hidden" name="ARCheck" value="0">
</cfif>
<input type="hidden" name="dtNoticeDateChk" value="#Tenant.dtNoticeDate#">
<!--- end mstriegel 03/10/2018 --->

<TABLE>	

	<!---Mshah commented this as we dont want to show this msg even 0 amount and billing is M <CFIF (StandardRent.mRoomAmount EQ "" OR StandardRent.mCareAmount EQ "" OR (StandardRent.mRoomAmount + StandardRent.mCareAmount) EQ 0)
		<CFIF (StandardRent.mRoomAmount EQ "" OR StandardRent.mCareAmount EQ "" OR (StandardRent.mRoomAmount + StandardRent.mCareAmount) EQ 0)
		AND Tenant.cBillingType NEQ 'D'>
	 <cfif #MoveOutCharges.ichargetype_ID# is not 1748>
			 <cfif #MoveOutCharges.ichargetype_ID# is not 1682>
		
		<TR>
			<TD COLSPAN="100%" STYLE="background: lightyellow; color: red; font-size: 16; text-align: center; border: thin solid navy;">
				<B>Can not find any valid standard rent amount(s) for this #Tenant.Residency# tenant. <BR> 
				This amount will need to be entered manually.<BR>
				Please, contact your AR Specialist for assistance.</B>
			</TD>
		</TR>
        </cfif>
	 </cfif>
	</CFIF> --->	

	<TR>
		<TH COLSPAN="2">Move Out Form</TH>
	</TR>
	<TR>
		<TD STYLE="text-align: center; width: 50%;">
			<TABLE CLASS="noborder" STYLE="width: 80%;">			
				<TR>
					<TD nowrap="nowrap">Account Number(Resident ID):</TD>
					<TD STYLE="text-align: right;"> #TENANT.cSolomonKey# </TD>
				</TR>
				<TR>
					<TD>Name</TD>
					<TD STYLE="text-align: right;"> #TENANT.cFirstName# #TENANT.cLastName# </TD>
				</TR>	
				<TR>
					<TD>Financial Possession Date</TD>
					<TD STYLE="text-align: right;"> #LSDateFormat(TENANT.dtRentEffective, "mm/dd/yyyy")# </TD>
				</TR>	
				<TR>
					<TD>Physical Move In Date</TD>
					<TD STYLE="text-align: right;"> #LSDateFormat(TENANT.dtMoveIn, "mm/dd/yyyy")# </TD>
				</TR>
			</TABLE>
		</TD>

		<TD STYLE="text-align: center;">
			<TABLE CLASS="noborder" STYLE="width: 80%;">
				<TR>
					<TD>&nbsp;</TD>
					<TD STYLE="text-align: right;">&nbsp;</TD>
				</TR>
				<TR>
					<TD>Unit</TD> 
					<TD STYLE="text-align: right;"> #trim(TENANT.cAptNumber)# </TD>
				</TR>
				<TR>
					<TD>Apartment Size</TD>
					<TD STYLE="text-align: right;"> #trim(TENANT.AptType)# </TD>
				</TR>
				<TR>
					<TD>Payment Method</TD>
					<TD STYLE="text-align: right;"> #trim(TENANT.Residency)# </TD>
				</TR>

			</TABLE>
		</TD>
	</TR>
</TABLE>


<TABLE>			
	<CFIF NOT IsDefined("URL.STP") AND Tenant.Reason IS "">
		<CFIF (isDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\9999')>
		<SCRIPT>
			Voluntary = new Array(<CFLOOP QUERY="qVoluntaryReason"><CFIF qVoluntaryReason.CurrentRow EQ 1>'#TRIM(qVoluntaryReason.cDescription)#'<CFELSE>,'#TRIM(qVoluntaryReason.cDescription)#'</CFIF></CFLOOP>);
			function reasonlist(string){
				if (string.value == 1){ 
					o="<SELECT NAME='Reason'>";
					o+="<OPTION VALUE=''>Choose</OPTION>";
					o+="<CFLOOP QUERY='qVoluntaryReason'><CFIF Tenant.iMoveReasonType_ID EQ qVoluntaryReason.iMoveReasonType_ID><CFSET selected='selected'><CFELSE><CFSET selected=''></CFIF><OPTION VALUE='#qVoluntaryReason.iMoveReasonType_ID#' #SELECTED#>#TRIM(qVoluntaryReason.cDescription)#</OPTION></CFLOOP>";
					o+="</SELECT>";
					document.all['SelectReason'].innerHTML = o;
				}
				else{	
					o="<SELECT NAME='Reason'><OPTION VALUE=''>Choose</OPTION><CFLOOP QUERY='qInVoluntaryReason'><CFIF Tenant.iMoveReasonType_ID EQ qInVoluntaryReason.iMoveReasonType_ID><CFSET selected='selected'><CFELSE><CFSET selected=''></CFIF><OPTION VALUE='#qInVoluntaryReason.iMoveReasonType_ID#' #SELECTED#>#TRIM(qInVoluntaryReason.cDescription)#</OPTION></CFLOOP></SELECT>";
					document.all['SelectReason'].innerHTML = o; 
				}
			}
		</SCRIPT>

		<TR><TD COLSPAN=100% STYLE="font-weight: bold; width: 25%;"> ***Reason for Move Out:*** </TD></TR>
		<TR>
			<TD>
				<CFSCRIPT>
					if (Tenant.Reason NEQ ""){ VoluntaryRadio='CHECKED'; InVoluntaryRadio=''; Run=1; }
					else { VoluntaryRadio=''; InVoluntaryRadio='Checked'; RUN=0; }
				</CFSCRIPT>
				Was the Reason Voluntary?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Yes - <INPUT TYPE="radio" NAME="Voluntary" #VoluntaryRadio# VALUE="1" onClick="reasonlist(this);">	
				No - <INPUT TYPE="radio" NAME="Voluntary" #InVoluntaryRadio# VALUE="0" onClick="reasonlist(this);">
			</TD>
			<TD ID="SelectReason"></TD>
			<SCRIPT>reasonlist(document.forms[0].Voluntary);</SCRIPT>
		</TR>
		<CFELSE>
		<TR><TD COLSPAN=100% STYLE="font-weight: bold; width: 25%;"> Reason for Move Out: </TD></TR>
		<TR STYLE="color: red;">
			<TD> 
				Was the Primary Reason Voluntary?&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				Yes - <INPUT TYPE="checkbox" NAME="Voluntary" VALUE="1" UnChecked onClick="self.location.href='MoveOutForm.cfm?stp=2&ID=#url.ID#&Vol=1&ShowBtn=#ShowBtn#'">	
				No - <INPUT TYPE="CheckBox" NAME="Voluntary" VALUE="0" UnChecked onClick="self.location.href='MoveOutForm.cfm?stp=2&ID=#url.ID#&Vol=0&ShowBtn=#ShowBtn#'">
			</TD>
			<TD ID="SelectReason"></TD>
		</TR>
		</CFIF>
	</CFIF>		
	<!--- ticket 92432 --->
	<CFIF IsDefined("url.stp") AND URL.STP IS 2>	
		<TR>
			<TD STYLE="font-weight: bold; width: 35%;">	Primary Reason for Move Out<br />Select to Continue: </TD>		
			<TD COLSPAN="2">
					<CFLOOP QUERY="Reason">
						<input type="radio" name="reason" value="#Reason.iMoveReasonType_ID#" onClick="document.MoveOutForm.action='MoveOutForm.cfm?stp=3&ID=#url.ID#&Rsn=#Reason.iMoveReasonType_ID#&ShowBtn=#ShowBtn#'; submit();" /> #Reason.cDescription#<br />
					</CFLOOP>
			</TD>
			<TD STYLE="width: 1%;"> </TD>
		</TR>
	</CFIF>		
<!--- 	<CFIF IsDefined("url.stp") AND URL.STP IS 2>	
		<TR>
			<TD STYLE="font-weight: bold; width: 35%;">	Primary Reason for Move Out: </TD>		
			<TD COLSPAN="2">
				<SELECT NAME="Reason">
					<!--- <OPTION VALUE=""> Choose Reason </OPTION> --->
					<CFLOOP QUERY="Reason">
						<OPTION VALUE="#Reason.iMoveReasonType_ID#"> #Reason.cDescription# </OPTION>
					</CFLOOP>
				</SELECT>
				<!--- 51267 MO Codes - added function to button --->
				<INPUT TYPE="Button" NAME="Submit" VALUE="Continue" STYLE="color: darkgreen;" onmouseover="return Step2check();" onfocus="" onClick="document.MoveOutForm.action='MoveOutForm.cfm?stp=3&ID=#url.ID#&Rsn=#Reason.iMoveReasonType_ID#&ShowBtn=#ShowBtn#'; submit();">
				<!--- end 51267 --->
			</TD>
			<TD STYLE="width: 1%;"> </TD>
		</TR>
	
	</CFIF>	 --->	
		<!--- ticket 92432 --->
	<CFIF IsDefined("URL.STP") AND URL.STP IS 3>
		<TR>
			<TD  nowrap="nowrap"> Primary Reason for Move Out: </TD>
			<TD><input  type="hidden" name="Reason"  value="#ChosenReason.iMoveReasonType_ID#" readonly="readonly" />#ChosenReason.cDescription#</TD>		
<!--- 			<TD> Primary Reason for Move Out: </TD>
			<TD>
				<SELECT NAME="Reason">
					<CFLOOP QUERY="Reason">
						<CFIF (ChosenReason.iMoveReasonType_ID EQ Reason.iMoveReasonType_ID) OR (IsDefined("form.Reason") AND form.Reason EQ Reason.iMoveReasonType_ID)>
							<CFSET Selected = 'Selected'>
						<CFELSE>
							<CFSET Selected =''>
						</CFIF>
						<OPTION VALUE="#Reason.iMoveReasonType_ID#" #Variables.selected#>	#Reason.cDescription# </OPTION>
					</CFLOOP>
				</SELECT>
			</TD> --->
			<TD></TD>
			<TD></TD>
			<TD></TD>
		</TR>	
		<!--- 25575 - rts - 6/24/2010 - respite --->
		<cfif Tenant.iResidencyType_ID eq 3>
			<cfquery name="LastRespiteInvoiceID" DATASOURCE = "#APPLICATION.datasource#">
				Select top 1 (im.iInvoiceMaster_ID) as iInvoiceMaster_ID
				from InvoiceMaster im
				where im.dtRowDeleted is null
				and im.cSolomonKey = '#Tenant.cSolomonKey#'
				order by im.dtInvoiceStart DESC
			</cfquery>
			<cfquery name="LastRespiteInvoiceInfo" DATASOURCE = "#APPLICATION.datasource#">
				Select im.*
				from InvoiceMaster im
				where im.iInvoiceMaster_ID = '#LastRespiteInvoiceID.iInvoiceMaster_ID#'
			</cfquery>
			<cfset ResINVEndDate = #dateformat(LastRespiteInvoiceInfo.dtInvoiceEnd,"mm/dd/yyyy")#>
		</cfif>
		<!--- end 25575 --->
		<TR> <TD COLSPAN="5"><HR></TD> </TR>
		<!--- 25575 - 6/24/2010 - rts --->
		<cfif Tenant.iResidencyType_ID eq 3>
		<TR> <TD COLSPAN="5">Last Invoice End Date : #ResINVEndDate#</TD> </TR>
		</cfif>
		<!--- end 25575 --->
		<TR>
			<TD STYLE="width: 25%;">Financial Move Out (Charge Through) Date: </TD>
			<!--- 11/06/2008 project 30096 sathya added this so that the projects red color --->
			<TD STYLE="width: 50%; color:red;" >
			<!--- 11/05/2008 Project 30096 sathya commented this as the project wanted us to make it into one text box --->
			<!--- 	<CFSCRIPT>
					if (Tenant.dtChargeThrough NEQ ""){ MONTH = Month(Tenant.dtChargeThrough); Day = Day(Tenant.dtChargeThrough); Year = Year(Tenant.dtChargeThrough); }
					else { MONTH = ''; Day=1; Year=Year(now()); }
				</CFSCRIPT> --->
			 
			<!--- 11/05/2008 Project 30096 sathya commented this as the project wanted us to make it into one text box --->
			<!--- 	<SELECT NAME="ChargeMonth" onChange="dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear);">	
					<OPTION VALUE=''></OPTION>
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> 
						<CFIF Variables.Month EQ I> <CFSET SELECTED='Selected'> <CFELSE> <CFSET SELECTED=''> </CFIF>
						<OPTION VALUE="#I#" #Selected#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/ 
				<SELECT NAME="ChargeDay">
					<CFLOOP INDEX=I FROM=1 TO=30 STEP=1> 
						<CFIF Variables.Day EQ I> <CFSET SELECTED='Selected'> <CFELSE> <CFSET SELECTED=''> </CFIF>
						<OPTION VALUE="#I#" #Selected#> #I# </OPTION>
					</CFLOOP>
				</SELECT>				
				/
				<CFIF Variables.Month NEQ 1>
					<INPUT TYPE="Text" NAME="ChargeYear" Value="#Year#" SIZE="3" MAXLENGTH=4 onBlur="this.value=Numbers(this.value);" onFocus="dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear);">
				<CFELSE>
					<CFSET LastYear = Year -1>
					<SELECT NAME="ChargeYear">
						<OPTION VALUE="#YEAR#"> #YEAR# </OPTION> <OPTION VALUE="#LastYear#"> #LastYear# </OPTION>
					</SELECT>	
					</CFIF>		 --->
				 
				 <!--- 11/05/2008 Project 30096 sathya adding text input box --->
				 <CFSCRIPT>
					if (Tenant.dtChargeThrough NEQ ""){ MONTH = Month(Tenant.dtChargeThrough); Day = Day(Tenant.dtChargeThrough); Year = Year(Tenant.dtChargeThrough); }
					else { MONTH = ''; Day=''; Year=''; }
				</CFSCRIPT>
				 
					<!--- 11/05/2008 Project 30096 sathya adding text input box --->
					<CFIF Variables.Month EQ ''>
						<INPUT TYPE="TEXT" NAME="ChargeMonth"  id="ChargeMonth" SIZE="1" maxlength="2"  ><b>/</b>
				    <CFELSE>
				     <INPUT TYPE="TEXT" VALUE ="#MONTH#" NAME="ChargeMonth"   id="ChargeMonth" SIZE="1" maxlength="2" ><b>/</b>
				    </CFIF>
				    <CFIF Variables.Day EQ  ''>
				 <INPUT TYPE="TEXT" NAME="ChargeDay" ID="ChargeDay"  SIZE="1" maxlength="2" ><b>/</b>
				 <CFElse>
				  <INPUT TYPE="TEXT" VALUE ="#Day#" NAME="ChargeDay" SIZE="1" maxlength="2" ><b>/</b>
				 </CFIF>
				 <CFIF Variables.Year EQ  ''>
					  <INPUT TYPE="TEXT" NAME="ChargeYear" ID="ChargeYear" SIZE="2" maxlength="4" >
					 <CFELSE>
					  <INPUT TYPE="TEXT" value ="#YEAR#" NAME="ChargeYear" SIZE="2" maxlength="4" >
					 </CFIF>
				
				<B>(MM/DD/YYYY)</B>  
						
											  
						
			</TD>
			<!--- tickset 92432 --->
			<TD>	
				<INPUT TYPE="button" NAME="ChargeDateSubmit" VALUE="Done" STYLE="color: Blue; font-size: 10; width: 65px; height: 20px; text-align: center; vertical-align: middle;"  onClick="document.MoveOutForm.action='MoveOutForm.cfm?ID=#url.ID#&<cfif isdefined("url.Rsn")>Rsn=#url.Rsn#<cfelse> Rsn=#Reason.iMoveReasonType_ID#</cfif>&stp=4&ShowBtn=#ShowBtn#'; submit();">
			</TD>
			<TD></TD>
			<TD></TD>
		</TR>
		<table>
		<tr>
			<td>
				A 30-day notice is required on any voluntary resident move out per ALC Residency Agreements.  If a 30-day notice was not given by the resident (or responsible party), then the charge through date must be 30 days from the �Date of Notice� or �Move-out� date.  Per ALC policy, you are required to notify your RDO if you did not receive a 30-day notice and your Residence is not charging for the additional days to achieve a 30-day notice.  Note: Exceptions to this policy apply for Medicaid Residents.
			</td>
		</tr>
		</table>
		<!--- 11/06/2008 Project 30096 ssathya commented this --->
		<!--- <SCRIPT> dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear); </SCRIPT> --->
	
	
	</CFIF>
		
	<CFIF (IsDefined("url.stp") AND url.stp IS 4) OR Tenant.Reason NEQ "">
	<!--- 25575 - rts - 6/24/2010 -  Respite billing --->
		<cfif Tenant.iresidencyType_ID eq 3>
			<cfquery name="LastRespiteInvoiceID" DATASOURCE = "#APPLICATION.datasource#">
				Select top 1 (im.iInvoiceMaster_ID) as iInvoiceMaster_ID
				from InvoiceMaster im
				where im.dtRowDeleted is null
				and im.cSolomonKey = '#Tenant.cSolomonKey#'
				order by im.dtInvoiceStart DESC
			</cfquery>
			<cfquery name="LastRespiteInvoiceInfo" DATASOURCE = "#APPLICATION.datasource#">
				Select im.*
				from InvoiceMaster im
				where im.iInvoiceMaster_ID = '#LastRespiteInvoiceID.iInvoiceMaster_ID#'
			</cfquery>
			<cfset ResINVEndDate = #dateformat(LastRespiteInvoiceInfo.dtInvoiceEnd,"mm/dd/yyyy")#>
			<cfset ResPMODate = #dateformat(Tenant.dtMoveOutProjectedDate,"mm/dd/yyyy")#>
			<CFScript>
				r_ctmonth = form.ChargeMonth;
				r_ctday = form.ChargeDay;
				r_ctyear = form.ChargeYear;
				TenantCTDate = r_ctmonth & '/' & r_ctday & '/' & r_ctyear;
				TenantCTDate = dateformat(TenantCTDate,"mm/dd/yyyy");
			</cfscript>
			<!--- <cfset TenantCTDate = #dateformat(Tenant.dtChargeThrough,"mm/dd/yyyy")#> --->
			<cfif ResPMODate neq TenantCTDate and ChosenReason.cdescription NEQ "Death">
				<CFOUTPUT>
					<TABLE >	
						<TR STYLE="background: lightyellow;  font-size: 11; text-align: left; border: thin solid navy;">
							<TD COLSPAN="80%" >
								The last invoice created for #Tenant.cFirstName# #Tenant.cLastName# has an end date of:
							</TD>
							<TD COLSPAN="20%"> #ResINVEndDate#</TD>
						</TR>
						<TR STYLE="background: lightyellow;  font-size: 11; text-align: left; border: thin solid navy;">
							<TD COLSPAN="80%">The charge through date provided is:</TD>
							<TD COLSPAN="20%"> #TenantCTDate#</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" style="text-align: center;">
							<style="font-color:red;">Note:</style></br>
							<cfif TenantCTDate gt ResPMODate>
								<b>Chargethru Date is greater than the Projected Physical Move Out Date.  The Chargethru date should be the same
								 as the PMO, which is #dateformat(ResPMODate,"MM/DD/YYYY")#.
								</b>
							<cfelse>
								<b>Chargethru Date can only be less then the Projected Physical Move out date for Respites on case of Death.
								</b>						
							</cfif>
							</TD>
						</TR>
						<TR>
							<TD COLSPAN="100%" style="text-align: center;">
									<A HREF="MoveOutForm.cfm?stp=3&ID=#url.ID#&Rsn=#Reason.iMoveReasonType_ID#&ShowBtn=#ShowBtn#">Back</A>
							</TD>
						</TR>
						<TR>
							<TD COLSPAN="50%" style="text-align: center;">
									<A HREF="../MainMenu.cfm">Return to the House Main Screen</A>
							</TD>
							<TD  COLSPAN="50%" style="text-align: center;">
									<A HREF="../RespiteInvoicing/RespiteInvoice.cfm?SolID=#Tenant.cSolomonKey#">Respite Invoice Tool</A>
							</TD>
						</TR>
					</TABLE>
					<CFABORT>
				</CFOUTPUT>	
			</CFIF>
		</cfif>
		<!--- end 25575 --->
		<TR>
			<TD NOWRAP> Primary Reason For Move Out: </TD>
			<TD NOWRAP COLSPAN=100% STYLE='text-align: left;'>
					<CFSCRIPT>
						if (reason.bisvoluntary EQ '') { voldesc='InVoluntary'; sqlfilter='is null'; Checked='Checked'; }
						else{ voldesc='Voluntary'; sqlfilter='is not null'; Checked='';}
						if (voldesc eq 'Voluntary') { altvoldesc='InVoluntary'; }
					</CFSCRIPT>
					<CFQUERY NAME='qAltReasons' DATASOURCE='#APPLICATION.datasource#'>
						select * from movereasontype where dtrowdeleted is null
						and bIsVoluntary #sqlfilter#
					</CFQUERY>
				<!--- 51267 - RTS - 3/19/2010 - MO Codes --->
					<SCRIPT>
						function changelist(){
							if (document.forms[0].DisplayReason2.checked == false){
							document.all['checkboxdesc2'].style.display='none';
							document.all['initreasonlist'].style.display='none';
							document.all['initreasonlist'].innerHTML='';
							}
	//Involuntary						
							if (document.forms[0].Voluntarybox.checked == true){
								
								setTargetChargeThrough(1);
								rl="<SELECT NAME='Reason'>";
								<!--- r1+="<OPTION VALUE=''>Select Reason</OPTION>";  --->
								<CFLOOP QUERY='qInVoluntaryReason'>
									rl+="<OPTION VALUE = '#qInVoluntaryReason.iMoveReasonType_ID#'> #qInVoluntaryReason.cDescription# </OPTION>";
								</CFLOOP>
								rl+="</SELECT>";
								
								//51267
								rl_2="<SELECT NAME='Reason2'>";
							    <!--- r1_2+="<OPTION VALUE=0>Select Reason</OPTION>"; ---> 
								<CFLOOP QUERY='qInVoluntaryReason2'>
									rl_2+="<OPTION VALUE = '#qInVoluntaryReason2.iMoveReasonType_ID#'> #qInVoluntaryReason2.cDescription# </OPTION>";
								</CFLOOP>
								rl_2+="</SELECT>";
								//end 51267
	//list 2 : Involuntary	ie DEATH
								document.all['reasonlistone'].style.display='none';
								document.all['reasonlistone'].innerHTML='';
								document.all['reasonlisttwo'].innerHTML=rl;
								document.all['reasonlisttwo'].style.display='inline';
								
								//51267
								if (document.forms[0].DisplayReason2.checked == true){
								document.all['reason2listone'].style.display='none';
								document.all['reason2listone'].innerHTML='';
								document.all['reason2listtwo'].innerHTML=rl_2;
								document.all['reason2listtwo'].style.display='inline';
								}
								//end 51267
								
								document.all['checkboxdesc'].innerHTML='InVoluntary';
								//51267
								document.all['checkboxdesc2'].innerHTML='InVoluntary';
								document.all['initreasonlist'].style.display='none';
								document.all['initreasonlist'].innerHTML='';
								//end 51267
							}
							else { 
								setTargetChargeThrough(0);
								rl2="<SELECT NAME='Reason'>";
								<!--- r12+="<OPTION VALUE=''>Select Reason</OPTION>"; --->
								<CFLOOP QUERY='qVoluntaryReason'>
									rl2+="<OPTION VALUE = '#qVoluntaryReason.iMoveReasonType_ID#'> #qVoluntaryReason.cDescription# </OPTION>";
								</CFLOOP>
								rl2+="</SELECT>";
								
								//51267
								rl2_2="<SELECT NAME='Reason2'>";
								<!--- r12_2+="<OPTION VALUE=0>Select Reason</OPTION>"; --->  
								<CFLOOP QUERY='qVoluntaryReason'>
									rl2_2+="<OPTION VALUE = '#qVoluntaryReason.iMoveReasonType_ID#'> #qVoluntaryReason.cDescription# </OPTION>";
								</CFLOOP>
								rl2_2+="</SELECT>";
								//end 51267
	//list 1 : Voluntary	ie Family							
								document.all['reasonlistone'].innerHTML=rl2;
								document.all['reasonlistone'].style.display='inline'; 
								document.all['reasonlisttwo'].style.display='none'; 
								document.all['reasonlisttwo'].innerHTML='';
							
								//51267
								if (document.forms[0].DisplayReason2.checked == true){
								document.all['reason2listone'].innerHTML=rl2_2;
								document.all['reason2listone'].style.display="inline"; 
								document.all['reason2listtwo'].style.display='none'; 
								document.all['reason2listtwo'].innerHTML='';
								}
								//end 51267
								
								document.all['checkboxdesc'].innerHTML='Voluntary';
								//51267
								document.all['checkboxdesc2'].innerHTML='Voluntary';
								document.all['initreasonlist'].style.display='none';
								document.all['initreasonlist'].innerHTML='';
								//end 51267
							}
						}
						//51267
						function ShowReason2(){
							if (document.forms[0].DisplayReason2.checked == false){
								document.all['checkboxdesc2'].style.display='none';
								document.all['reason2listone'].style.display='none';
								document.all['reason2listtwo'].style.display='none';
								
								document.all['initreasonlist'].style.display='none';
								document.all['initreasonlist'].innerHTML='';
							}else{
								rl_2="<SELECT NAME='Reason2'>"; 
								<!--- r1_2+="<OPTION VALUE=0>Select Reason</OPTION>"; --->
								<CFLOOP QUERY='qVoluntaryReason'>
									rl_2+="<OPTION VALUE = '#qVoluntaryReason.iMoveReasonType_ID#'> #qVoluntaryReason.cDescription# </OPTION>";
								</CFLOOP>
								rl_2+="</SELECT>";
								
								rl2_2="<SELECT NAME='Reason2'>";
								<!--- r12_2+="<OPTION VALUE=0>Select Reason</OPTION>"; --->
								<CFLOOP QUERY='qInVoluntaryReason2'>
									rl2_2+="<OPTION VALUE = '#qInVoluntaryReason2.iMoveReasonType_ID#'> #qInVoluntaryReason2.cDescription# </OPTION>";
								</CFLOOP>
								rl2_2+="</SELECT>";
								<!--- rl_2="<SELECT NAME='Reason2'>";
								<CFLOOP QUERY='qAltReasons'>
									rl_2+="<OPTION VALUE = '#qAltReasons.iMoveReasonType_ID#'> #qAltReasons.cDescription# </OPTION>";
								</CFLOOP>
								rl_2+="</SELECT>"; --->
								
								document.all['initreasonlist'].style.display='none';
								document.all['initreasonlist'].innerHTML='';
								
								document.all['checkboxdesc2'].style.display='inline';
								
								if(document.forms[0].Voluntarybox.checked == true){
									document.all['checkboxdesc2'].innerHTML='InVoluntary';
									
									document.all['reason2listone'].style.display='none';
									document.all['reason2listone'].innerHTML='';
									document.all['reason2listtwo'].style.display='inline';
									document.all['reason2listtwo'].innerHTML=rl2_2;
								}else{
									document.all['checkboxdesc2'].innerHTML='Voluntary';
									
									document.all['reason2listone'].style.display='inline';
									document.all['reason2listone'].innerHTML=rl_2;
									document.all['reason2listtwo'].style.display='none';
									document.all['reason2listtwo'].innerHTML='';
									
									
								}
							}
						}
						//end 51267
					</SCRIPT>
				<INPUT TYPE='checkbox' NAME='Voluntarybox' VALUE=1 onClick='changelist();' #Checked#>
				
			
				<SPAN ID="checkboxdesc">#voldesc#</SPAN>
				 <SPAN ID="reasonlistone"></SPAN>	
				<SPAN ID="reasonlisttwo">
					 <SELECT NAME="Reason" > 
						<CFLOOP QUERY="Reason">
							<CFIF (ChosenReason.iMoveReasonType_ID EQ Reason.iMoveReasonType_ID) OR (IsDefined("form.Reason") AND form.Reason EQ #Reason.iMoveReasonType_ID#)>
								<CFSET Selected = 'Selected'>
							<CFELSE>
								<CFSET Selected =''>
							</CFIF>					
							<OPTION VALUE = "#Reason.iMoveReasonType_ID#" #SELECTED#>	#Reason.cDescription#	</OPTION>
						</CFLOOP>
					</SELECT> 
				</SPAN> 
			</TD>
		</TR>
		<!--- 51267 - MO Codes 3/18/2010 RTS --->
		<TR> 
			<TD NOWRAP>
				Secondary Reason: </br>(optional)
				</br>
				Display Second Reason:<input type="checkbox" name="DisplayReason2" value=1 onclick="ShowReason2();">
			</TD>
			<TD NOWRAP STYLE='text-align: left;' COLSPAN="100%">
			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<SPAN ID="checkboxdesc2" style="text-align:left;"></SPAN> 
				<SPAN style="padding right:2px"></SPAN>
				<SPAN ID="reason2listone" style="text-align:left;"></SPAN>	
				<SPAN ID="reason2listtwo" style="text-align:left;"></SPAN>
				<cfif Tenant.iMoveReason2Type_ID neq ''>
					<script>
						document.forms[0].DisplayReason2.checked = true;
						
						if (document.forms[0].Voluntarybox.checked == true){
							document.all['checkboxdesc2'].innerHTML='InVoluntary';
						}else{
							document.all['checkboxdesc2'].innerHTML='Voluntary';
						}
						document.all['checkboxdesc2'].style.display='inline';
					</script> 
					<SPAN ID="initreasonlist" style="text-align:left;">
					<SELECT NAME="Reason2" > 
							<CFLOOP QUERY="Reason">
								<CFIF (Tenant.iMoveReason2Type_ID EQ Reason.iMoveReasonType_ID)>
									<CFSET Selected2 = 'Selected'>
								<CFELSE>
									<CFSET Selected2 =''>
								</CFIF>					
								<OPTION VALUE = "#Reason.iMoveReasonType_ID#" #SELECTED2#>	#Reason.cDescription#	</OPTION>
							</CFLOOP>
						</SELECT>
					</SPAN>
				<cfelse>
					<SPAN ID="initreasonlist" style="text-align:left;"></span>
				</cfif>
			</TD>
		</TR>
<TR><TD COLSPAN="100%"><HR></TD> </TR>
		<TR><TD COLSPAN='2' STYLE="font-weight: bold; width: 50%;"> DESTINATION LOCATION OF RESIDENT: </TD><TD COLSPAN=2></TD></TR>
		<tr ><td COLSPAN="100%"> 
		 <table Colspan=3 style="width:75%">
			<tr>
				<td COLSPAN="1" STYLE="color:red">Move Out Location:</td>
				<td>
				<select name="slctTenantMOLocation">
					<option value="0">Select Location</option>
					<cfloop query='TenantMOLocation'>
						<cfif TenantMOLocation.iTenantMOLocation_ID eq Tenant.iTenantMOLocation_ID>
							<cfset Selected3 = 'Selected'>
						<cfelse>
							<cfset Selected3 = ''>
						</cfif>
					<option value="#TenantMOLocation.iTenantMOLocation_ID#" #Selected3#>    #TenantMOLocation.cDescription#    </option>
					</cfloop>
				</select>
				</td>
			</tr>
		</table>	
			<!--- <tr>
				<td COLSPAN="1">Place:</td>
				<cfif TenantMOLocation.RecordCount gt 0><cfset place = #TenantMOLocation.cDescription#></cfif>
				<td><input type="text" name="MODLDescription" style="width:75%" value="#place#"></td>
			</tr> 
			 <tr>
				<td COLSPAN="1">Address 1:</td>
				<cfif TenantMOLocation.RecordCount gt 0><cfset add1 = #TenantMOLocation.cAddressLine1#></cfif>
				<td><input type="text" name="MODLAddress1" style="width:75%" value="#add1#"></td>
			</tr>
			<tr>
				<td COLSPAN="1">Address 2:</td>
				<cfif TenantMOLocation.RecordCount gt 0><cfset add2 = #TenantMOLocation.cAddressLine2#></cfif>
				<td><input type="text" name="MODLAddress2" style="width:75%" value="#add2#"></td>
			</tr>
			<tr>
				<td COLSPAN="1">City:</td>
				<cfif TenantMOLocation.RecordCount gt 0><cfset city = #TenantMOLocation.cCity#></cfif>
				<td><input type="text" name="MODLCity" style="width:75%" value="#city#"></td>
			</tr>
			<tr>
				<td COLSPAN="1">State:</td>
				<td >	
						<SELECT NAME="cStateCode">	
							<CFLOOP Query = "StateCodes">
								<cfif StateCodes.cStateCode eq TenantMOLocation.cStateCode>
									<cfset Selected3 = 'Selected'>
								<cfelse>
									<cfset Selected3 = ''>
								</cfif>
								<OPTION VALUE ="#cStateCode#" #Selected3#>	#cStateName# - #cStateCode# </OPTION>
							</CFLOOP>
						</SELECT>
				</td>
			</tr>
			<tr><td COLSPAN="1">Zip Code:</td>
				<cfif TenantMOLocation.RecordCount gt 0><cfset zip = #TenantMOLocation.cZipCode#></cfif>
				<td ><input type="text" name="MODLZip" style="width:25%" value="#zip#"></td>
			</tr>
		</td></tr> 
		</table> --->
		<!--- end 51267 --->
		<TR>
		<TD COLSPAN="100%"><HR></TD> 
		</TR>
		<TR>
		<TD COLSPAN=2 STYLE="font-weight: bold; width: 50%;"> CURRENT MONTH PRORATED RENT: </TD>
		<TD COLSPAN=2></TD>
		</TR>		
		<TR>
			<TD VAlIGN="TOP" COLSPAN="2" STYLE="text-align: center;">
				
				<TABLE width="100%" STYLE="width: 100%; height: 100%; text-align: right; ">
					<TR>
						<TD STYLE="width: 40%; text-align: left;"> Monthly Rent Rate: </TD>						
						<TD STYLE="text-align: right;" > 
							<CFIF Tenant.iResidencyType_ID NEQ 3> 
								<CFIF Tenant.cbillingtype eq 'd' and isdefined("dailyrent")>
									<CFSET monthlyrate= dailyrent * DaysInMonth(dtChargeThrough)>
									$#TRIM(NumberFormat((monthlyrate), "999999.99"))# 
								<CFELSE>
									$#TRIM(NumberFormat((StandardRent.mRoomAmount), "999999.99"))# 
								</CFIF>
							<CFELSE> 
								N/A for Respite 
							</CFIF>
					  </TD>
					</TR>
					<cfif IsDefined("qResidentCare.mAmount")>
					<TR>
						<TD STYLE="width: 40%; text-align: left;">Resident Care</TD>
						<TD STYLE="#right#">#LSCurrencyFormat(qResidentCare.mAmount)#</TD>
					</TR>
					</cfif>
					<TR>
						<TD STYLE="width: 40%; font-size: 12; text-align: left; "  nowrap>Physical Move Out Date: </TD>
						<TD STYLE="text-align: center; color:red" nowrap>
						  <div align="right">
							<!---  MLAW 10/23/2006 Comment the below code --->
							<!---
							<CFSCRIPT>
							if (Tenant.dtMoveOut NEQ "") { MONTH = Month(Tenant.dtMoveOut); Day = Day(Tenant.dtMoveOut); Year = Year(Tenant.dtMoveOut); }
							else if (IsDefined("form.MoveOutDay")) { MONTH = form.MoveOutMonth; Day = form.MoveOutDay; Year = form.MoveOutYear;}
							else { MONTH = ''; Day = '';	Year = Year(Now()); }
						    </CFSCRIPT> 
							--->
							<!--- If there is saved Tenant Move Out Record then use it to display, otherwise use the expected Move Out date from census tracking --->
							<CFIF Tenant.dtMoveOut neq '' AND Tenant.dtMoveOut neq '1900-01-01 00:00:00.000'>
								<CFSET lvDischargeDate = Tenant.dtMoveOut> 
							<CFELSEIF GetMoveOutDate.DischargeDate neq '' AND GetMoveOutDate.DischargeDate neq '1900-01-01 00:00:00.000'>
								<CFSET lvDischargeDate = GetMoveOutDate.DischargeDate>								
							</CFIF>
							
							<CFSCRIPT>
								if (lvDischargeDate NEQ "") { MONTH = Month(lvDischargeDate); Day = Day(lvDischargeDate); Year = Year(lvDischargeDate); }
								else if (IsDefined("form.MoveOutDay")) { MONTH = form.MoveOutMonth; Day = form.MoveOutDay; Year = form.MoveOutYear;}
								else { MONTH = ''; Day = '';	Year = Year(Now()); }
						    </CFSCRIPT>
							
							<!--- MLAW 10/23/2006 If user is AR Admin then the move out date is changeable, otherwise the move out date is read only ---> 
						<!--- Project 30096 modification 11/17/2008 sathya commented this out  --->
						<!--- 	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0> 
								<SELECT NAME="MoveOutMonth" onChange="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear);"
									onBlur="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear);">
									<OPTION VALUE=''></OPTION>
									<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
										<CFIF Month EQ I>
											<CFSET Selected = 'Selected'> 
										<CFELSE> 
											<CFSET Selected = ''> 
										</CFIF> 
										<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
									</CFLOOP>
								</SELECT> 							
							   	/  
 							  	<SELECT NAME="MoveOutDay">
									<OPTION VALUE=''></OPTION>
									<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(lvDischargeDate)#" STEP="1"> 
										<CFIF #LSDateFormat(lvDischargeDate, "dd")# EQ I>
											<CFSET Selected='Selected'> 
										<CFELSE> 
											<CFSET Selected=''> 
										</CFIF> 										
										<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
									</CFLOOP>
								</SELECT>	
							  	/ 		
							  	<INPUT  NAME="MoveOutYear" Value="#Year#" SIZE="2" MAXLENGTH=4 onBlur="this.value=Numbers(this.value); validdate();" onChange="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear);">							
							<cfelse>
								  #LSDateFormat(lvDischargeDate, "mm/dd/yyyy")#
								  <INPUT NAME="MoveOutMonth" TYPE="hidden" Value="#LSDateFormat(lvDischargeDate, "mm")#" SIZE="2" MAXLENGTH="2" >
								  <INPUT NAME="MoveOutDay" TYPE="hidden" Value="#LSDateFormat(lvDischargeDate, "dd")#" SIZE="2" MAXLENGTH="2" >
								  <INPUT NAME="MoveOutYear" TYPE="hidden"Value="#Year#" SIZE="3" MAXLENGTH=4 onBlur="this.value=Numbers(this.value); validdate();" onChange="dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear);">												  
						  	</cfif> --->
						  
						  	<!--- Project 30096 modification added this text box so that they can key in the date --->
					      <CFSCRIPT>
						if (Tenant.dtMoveOut NEQ "")
						{ moMONTH = Month(Tenant.dtMoveOut); moDay = Day(Tenant.dtMoveOut); moYear = Year(Tenant.dtMoveOut); }
						else { moMONTH = ''; moDay=''; moYear=''; }
					</CFSCRIPT>
					     
					     <CFIF Variables.moMonth EQ ''>
					     <INPUT TYPE="TEXT" NAME="MoveOutMonth"  SIZE="1" maxlength="2" ><B>/</B>
					     <CFELse>
					      <INPUT TYPE="TEXT" VALUE="#moMONTH#" NAME="MoveOutMonth"  SIZE="1" maxlength="2" ><B>/</B>
					     </CFIF>
					     <CFIF Variables.moDay EQ ''>
				 			<INPUT TYPE="TEXT" NAME="MoveOutDay"  SIZE="1" maxlength="2" ><B>/</B>
				 			<cfelse>
				 			<INPUT TYPE="TEXT" value="#moDay#" NAME="MoveOutDay"  SIZE="1" maxlength="2" ><B>/</B>
				 			</cfif>
				 			
				 			<CFIF Variables.moYear EQ ''>
							<INPUT TYPE="TEXT" NAME="MoveOutYear" SIZE="2" maxlength="4" >
							<cfelse>
							<INPUT TYPE="TEXT" value="#moYear#" NAME="MoveOutYear" SIZE="2" maxlength="4" >
							</cfif>
					     <B>(MM/DD/YYYY)</B>
					      </div>
						</TD>
					</TR>

					<TR>
						<TD STYLE="font-size: 12; text-align: left;"> Date of Notice: </TD>
						<TD STYLE="text-align: center; color:red;">
						  <div align="right">
						<!--- Project 30096 modification sathya commented this out as they want this to be editable --->
						 <!---  	<CFSCRIPT>
								if (Tenant.dtMoveOut NEQ "") { MONTH = Month(Tenant.dtNoticeDate); Day = Day(Tenant.dtNoticeDate); Year = Year(Tenant.dtNoticeDate); }
								else if (IsDefined("form.NoticeDay")) { MONTH = form.NoticeMonth; Day = form.NoticeDay; Year = form.NoticeYear; }	
								else { MONTH = ''; Day = ''; Year = Year(now()); }	
							ntcMonth = Variables.MONTH;
						    </CFSCRIPT> --->
						   <!--- Project 30096 modification sathya added this to be editable --->
						    <CFSCRIPT>
						    	//mstriegel 03/10/2018 
								if (Tenant.dtMoveOut NEQ "" && tenant.dtNoticeDate NEQ "") {
									 noMONTH = Month(Tenant.dtNoticeDate);
									 noDay = Day(Tenant.dtNoticeDate); 
									 noYear = Year(Tenant.dtNoticeDate); 
								}
								// end mstriegel 
								else if (IsDefined("form.NoticeDay")) { noMONTH = form.NoticeMonth; noDay = form.NoticeDay; noYear = form.NoticeYear; }	
								else { noMONTH = ''; noDay = ''; noYear = ''; }	
							ntcMonth = Variables.noMONTH;
						    </CFSCRIPT> 
							<CFIF Tenant.dtNoticeDate neq '' AND Tenant.dtNoticeDate neq '1900-01-01 00:00:00.000'>
								<CFSET lvNoticeDate = Tenant.dtNoticeDate> 
								<CFSET lvChargeThroughDate = "#DateFormat(DateAdd("d", 29, Tenant.dtNoticeDate), " MM/DD/yyyy")#">
							<CFELSEIF GetNoticeDate.Census_Date neq '' AND GetNoticeDate.Census_Date neq '1900-01-01 00:00:00.000'>
							  <CFSET lvNoticeDate = GetNoticeDate.Census_Date> 
							</CFIF>
					<!--- Project 30096 modification sathya commented this out as they want this to be editable --->
							 <!---  #LSDateFormat(lvNoticeDate, "mm/dd/yyyy")# --->
							  <!--- <SELECT NAME = "NoticeMonth" onChange="dayslist(document.forms[0].NoticeMonth, document.forms[0].NoticeDay, document.forms[0].NoticeYear); setTargetChargeThrough(document.forms[0].Voluntarybox.checked);">			
								<OPTION VALUE=''></OPTION>
								<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> 
									<CFIF Month EQ I>
										<CFSET Selected='Selected'> 
									<CFELSE> 
										<CFSET Selected=''> 
									</CFIF> 									
									<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
								</CFLOOP>
							</SELECT> --->
							<!--- Project 30096 modification sathya commented this out --->
							<!---   <INPUT NAME="NoticeMonth" TYPE="hidden" Value="#LSDateFormat(lvNoticeDate, "mm")#" SIZE="2" MAXLENGTH="2" >	 --->
							  <!--- / ---> 
							  <!--- <SELECT NAME = "NoticeDay" onChange="setTargetChargeThrough(document.forms[0].Voluntarybox.checked);">	
								<OPTION VALUE=''></OPTION>
								<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(isblank(Tenant.dtNoticeDate,now()))#" STEP="1"> 
									<!--- <CFIF Day EQ I>  --->
						  </div>
						  <CFIF #LSDateFormat(GetNoticeDate.Census_Date, "dd")# EQ I>
										<CFSET Selected = 'Selected'> 
									<CFELSE> 
										<CFSET Selected = ''> 
						  </CFIF> 									
									<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
								</CFLOOP>
							</SELECT> --->
							<!--- Project 30096 modification sathya commented this out --->
							<!--- <INPUT NAME="NoticeDay" TYPE="hidden" Value="#LSDateFormat(lvNoticeDate, "dd")#" SIZE="2" MAXLENGTH="2" > --->
							<!--- / --->
							<!--- Project 30096 modification sathya commented this out --->
							<!--- <INPUT NAME="NoticeYear" TYPE="hidden" onBlur="this.value=Numbers(this.value); validdate();" onChange="dayslist(document.forms[0].NoticeMonth, document.forms[0].NoticeDay, document.forms[0].NoticeYear);setTargetChargeThrough(document.forms[0].Voluntarybox.checked);" Value="#Year#" SIZE="3" MAXLENGTH=4 >			 --->
						
						<!---Project 30096 modification sathya added this code so that the dates will be edited  --->
								 <CFIF Variables.noMonth EQ ''>
								<INPUT TYPE="TEXT" NAME="NoticeMonth" SIZE="1" maxlength="2" ><B>/</B>
								<cfelse>
								<INPUT TYPE="TEXT" value="#noMONTH#" NAME="NoticeMonth" SIZE="1" maxlength="2" ><B>/</B>
								</cfif>
								<CFIF Variables.noDay EQ ''>
				 			<INPUT TYPE="TEXT" NAME="NoticeDay" SIZE="1" maxlength="2" ><B>/</B>
				 			<cfelse>
				 			<INPUT TYPE="TEXT" value="#noDay#" NAME="NoticeDay" SIZE="1" maxlength="2" ><B>/</B>
				 			</cfif>
				 				<CFIF Variables.noYear EQ ''>
							<INPUT TYPE="TEXT" NAME="NoticeYear" SIZE="2" maxlength="4" >
							<cfelse>
							<INPUT TYPE="TEXT" value="#noYear#" NAME="NoticeYear" SIZE="2" maxlength="4" >
							</cfif>
							<B>(MM/DD/YYYY)</B> 					
											
					  </TD>
					</TR>

					<TR>
						<TD STYLE="font-size: 12; text-align: left;">Financial Move Out Date (Charged Through): </TD>
							<CFSET NumberOfMonths = DateDiff("m", SESSION.TipsMonth, Variables.dtChargeDayOne)>
							<CFSET Month = NumberOfMonths>
							<INPUT TYPE="Hidden" Name="Month" VALUE="#Month#">
							<!--- ==============================================================================
							Check to see if this move out is the same month and year as the move in
							If this is true, dayscharged = difference in days.
							=============================================================================== --->
							<!--- 25575 - rts - 6/24/2010 - respite billing --->
							<cfif Tenant.iresidencyType_ID neq 3>
								<!--- <CFIF (Month(Tenant.dtMoveIn) EQ Month(Variables.dtChargeThrough))
									AND (Year(Tenant.dtMoveIN) EQ Year(dtChargeThrough))>  --->
								<CFIF (Month(Tenant.dtRentEffective) EQ Month(Variables.dtChargeThrough)) 
								AND (Year(Tenant.dtRentEffective) EQ Year(dtChargeThrough))>
									<CFSET DaysCharged = Variables.dtChargeThrough - Tenant.dtRentEffective +1>
								<CFELSE>
									<CFSCRIPT>
										DaysCharged = Day(Variables.dtChargeThrough);
										if (DaysCharged LTE 30 OR Tenant.iResidencyType_ID EQ 2)
										{ DaysCharged = Day(Variables.dtChargeThrough); } else { DaysCharged = 30; }
									</CFSCRIPT>
		 					</CFIF>
								<!--- calc care days charged  --->	
								<CFIF (Month(Tenant.dtMoveIn) EQ Month(Variables.dtChargeThrough)) 
								AND (Year(Tenant.dtMoveIn) EQ Year(dtChargeThrough))>
									<CFSET DaysChargedCare = Variables.dtChargeThrough - Tenant.dtMoveIn +1>
								<CFELSE>
									<CFSCRIPT>
										DaysChargedCare = Day(Variables.dtChargeThrough);
										if (DaysChargedCare LTE 30 OR Tenant.iResidencyType_ID EQ 2)
										{ DaysChargedCare = Day(Variables.dtChargeThrough); } else { DaysCharged = 30; }
									</CFSCRIPT>
								</CFIF>
							<cfelse>
							<!--- 	since the last invoice for a respite is going to be the MO invoice,
							and they have already recieved it, display days on invoice --->
								<cfquery name="LastRespiteInvoiceID" DATASOURCE = "#APPLICATION.datasource#">
									Select top 1 (im.iInvoiceMaster_ID) as iInvoiceMaster_ID
									from InvoiceMaster im
									where im.dtRowDeleted is null
									and im.cSolomonKey = '#Tenant.cSolomonKey#'
									order by im.dtInvoiceStart DESC
								</cfquery>
								<cfquery name="LastRespiteInvoiceInfo" DATASOURCE = "#APPLICATION.datasource#">
									Select im.*
									from InvoiceMaster im
									where im.iInvoiceMaster_ID = '#LastRespiteInvoiceID.iInvoiceMaster_ID#'
								</cfquery>
								<cfquery name="getDays" datasource="#application.datasource#">
									select datediff(dd,'#LastRespiteInvoiceInfo.dtInvoiceStart#','#LastRespiteInvoiceInfo.dtInvoiceEnd#')+ 1 as Days
								</cfquery>
								<cfset DaysCharged = getDays.Days>		
							</cfif>	
							<!--- end 25575 --->	
							<INPUT TYPE="Hidden" NAME="DaysCharged" VALUE="#DaysCharged#">
							<INPUT TYPE="Hidden" NAME="DaysChargedCare" VALUE="#DaysChargedCare#">
						<!--- 11/06/2008 project 30096  ssathya commented this out --->
						
						 <!--- <TD STYLE="text-align: center;">
							<SELECT NAME="ChargeMonth" onChange="dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay,
							 document.forms[0].ChargeYear); validdate();">
								<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"> 
									<CFIF Tenant.dtChargeThrough NEQ "" AND Month(Tenant.dtChargeThrough) EQ I>
										<CFSET Selected = 'Selected'>
									<CFELSEIF IsDefined("form.ChargeMonth") AND (form.ChargeMonth EQ I)>
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
							<CFSET dtChargeThrough = #Tenant.dtChargeThrough#></CFIF>
							<INPUT TYPE="Text" NAME="ChargeYear" Value="#Year(dtChargeThrough)#" SIZE="3" MAXLENGTH=4 
							onBlur = "this.value=Numbers(this.value);" 
							onChange="dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear); 
							validdate();" >
							</td> --->
						
						<!--- 25575 - rts - 6/24/2010 - respite billing - we don't want changes to the CTDate  
						now that they've gotten to this point (past step 3) --->
						
						<cfif Tenant.iResidencyType_ID neq 3>
								<!--- 11/06/2008 project 30096 ssathya added the input box format for the chargetrough date --->
							 <TD STYLE="text-align: center; color:red;">
							<!--- 	<cfif IsDefined("form.ChargeDay") or form.ChargeDay eq ''> --->
								<INPUT TYPE="TEXT" NAME="ChargeMonth" value="#form.ChargeMonth#" SIZE="1" maxlength="2" ><B>/</B>
					 			<INPUT TYPE="TEXT" NAME="ChargeDay" value="#form.ChargeDay#" SIZE="1" maxlength="2" ><B>/</B>
								<INPUT TYPE="TEXT" NAME="ChargeYear" value="#form.ChargeYear#" SIZE="2" maxlength="4" >
								<B>(MM/DD/YYYY)</B>  
								<!--- </cfif>  --->
							</TD> 
						<cfelse><!---  is respite --->
							<TD>
								#TenantCTDate#
								<INPUT TYPE="Hidden" NAME="FullRespiteCTDate" value="#TenantCTDate#">
								<INPUT TYPE="Hidden" NAME="ChargeMonth" value="#form.ChargeMonth#">
					 			<INPUT TYPE="Hidden" NAME="ChargeDay" value="#form.ChargeDay#">
								<INPUT TYPE="Hidden" NAME="ChargeYear" value="#form.ChargeYear#">
							</TD>
						</cfif>
						<!--- end 25575 --->
					</TR>
			  </TABLE>
			</TD>
			
			
			<TD VALIGN="top" COLSPAN="2" STYLE="text-align: center;">
				<TABLE STYLE="width: 90%; height: 100%;">
					<TR>
						<TD COLSPAN="2" STYLE="width: 75%; font-size: 12; text-align: left;">Daily Rate:</TD>
						<TD STYLE="text-align: right; width: 20%;">
							<CFIF Tenant.iResidencyType_ID NEQ 3> 
							#LSCurrencyFormat(Variables.DailyRent)# 
							<CFELSE>
							 #LSCurrencyFormat((IsBlank(StandardRent.mRoomAmount,0) + IsBlank(StandardRent.mCareAmount,0)))#
							 </CFIF>
						</TD>
					</TR>
					<TR>
						<TD COLSPAN="2" STYLE="width: 75%; font-size: 12; text-align: left;">Daily Care Rate:</TD>
						<TD STYLE="text-align: right; width: 20%;"> #LSCurrencyFormat(qDailyCare.mAmount)# 
						<INPUT TYPE='hidden' NAME='DailyCare' VALUE='#qDailyCare.mAmount#'></TD>
					</TR>
					<TR>
						<TD COLSPAN="2"  STYLE="font-size: 12; text-align: left;"> Number of Days Charged: </TD>
						<TD STYLE="text-align: right;"> #Variables.DaysCharged# </TD>
					</TR>
					<TR>
						<TD COLSPAN="2"  STYLE="font-size: 12; text-align: left;"> Number of Care Days Charged: </TD>
						<TD STYLE="text-align: right;"> #DaysChargedCare# </TD> <!--- removed Variables. --->
					</TR>					
					<TR>
						<TD COLSPAN="2" STYLE="font-size: 12; text-align: left;"> Current Month's Rent Prorated: </TD>
						<TD STYLE="text-align: right;">
							<!--- ==============================================================================
							Modified 12/7/01 SBD (TenantInfo.dtChargeThrough is null the first time through; must handle)
							=============================================================================== --->
							<CFIF IsDefined("TenantInfo.dtChargeThrough") AND TenantInfo.dtChargeThrough NEQ ""
							and TenantInfo.dtChargeThrough lte TenantInfo.dtMoveIn>
								<CFIF DaysCharged LT 30 OR DaysCharged LT DaysInMonth(TenantInfo.dtChargeThrough)>
									<CFSET ProratedRent = NumberFormat(Variables.DailyRent,"-9999999999.99") * Variables.DaysCharged>
								<CFELSE>
									<CFSET ProratedRent = isBlank(StandardRent.mRoomAmount,0) + isBlank(StandardRent.mCareAmount,0)>
								</CFIF>
							<CFELSEIF DaysCharged LT 30 OR DaysCharged LT DaysInMonth(Variables.dtChargeThrough)>
								<CFSET ProratedRent = NumberFormat(Variables.DailyRent,"-9999999999.99") * Variables.DaysCharged>
							<CFELSE>
								<CFSET ProratedRent = isBlank(StandardRent.mRoomAmount,0) + isBlank(StandardRent.mCareAmount,0)>
							</CFIF>
							#LSCurrencyFormat(Variables.ProratedRent)#
							<INPUT TYPE="Hidden" NAME="ProratedRent" VALUE="#Variables.ProratedRent#">
						</TD>
					</TR>

					<TR>
						<TD COLSPAN="2" STYLE="font-size: 12; text-align: left;"> Current Month's Care Prorated: </TD>
						<TD STYLE="text-align: right;">
							<!--- ==============================================================================
							Modified 12/7/01 SBD (TenantInfo.dtChargeThrough is null the first time through; must handle)
							=============================================================================== --->
							<CFIF IsDefined("TenantInfo.dtChargeThrough") AND TenantInfo.dtChargeThrough NEQ ""
							and TenantInfo.dtChargeThrough lte TenantInfo.dtMoveIn>
								<CFIF DaysCharged LT 30 OR DaysCharged LT DaysInMonth(TenantInfo.dtChargeThrough)>
									<CFSET ProratedCare = NumberFormat(qDailyCare.mAmount,"-9999999999.99") * Variables.DaysCharged>
								<CFELSE>
									<cfif IsDefined("qResidentCare.mAmount")>
										<CFSET ProratedCare = qResidentCare.mAmount >
									<cfelse>
										<CFSET ProratedCare =0>
									</CFIF>
								</CFIF>
							<CFELSEIF DaysCharged LT 30 OR DaysCharged LT DaysInMonth(Variables.dtChargeThrough)>
								<CFSET ProratedCare = NumberFormat(qDailyCare.mAmount,"-9999999999.99") * Variables.DaysCharged>
							<CFELSE>
									<cfif IsDefined("qResidentCare.mAmount")>
										<CFSET ProratedCare = qResidentCare.mAmount >
									<cfelse>
										<CFSET ProratedCare =0>
									</CFIF>
							</CFIF>
							#LSCurrencyFormat(Variables.ProratedCare)#
							<INPUT TYPE="Hidden" NAME="ProratedCare" VALUE="#Variables.ProratedCare#">
						</TD>
					</TR>
					
					<TR>
						<TD COLSPAN="2" STYLE="text-align: left;"> Charge Through Date Should Be: </TD>
						<TD>
							<CFIF IsDefined("Reason.bIsVoluntary") AND Reason.bIsVoluntary NEQ "" AND Day neq '' 
							AND Year NEQ '' AND ntcMonth neq ''>
								<!--- 3/31/2009 RTS Proj#35510-- Quick fix. --->
								<cfif ntcMonth EQ 2 and Day GT 28><cfset Day = 28>
								<!--- 6/2/09 RTS Proj #38407--Quick Fix. --->
								<cfelseif ntcMonth EQ 4 and Day GT 30><cfset Day = 30>
								<cfelseif ntcMonth EQ 6 and Day GT 30><cfset Day = 30>
								<cfelseif ntcMonth EQ 9 and Day GT 30><cfset Day = 30>
								<cfelseif ntcMonth EQ 11 and Day GT 30><cfset Day = 30>
								</cfif>
								<CFSET dtTempTarget = CreateODBCDateTime(Year & "/" & ntcMonth & "/" & Day)>
								<CFSET ChargeValue="#DateFormat(DateAdd("d", 29, dtTempTarget), "m / d / yyyy")#">
							<CFELSE>
								<CFSET ChargeValue="Involuntary">
							</CFIF>
							<!--- 25575 - rts - respite billing  --->
							<cfif Tenant.iResidencyType_ID neq 3>
							<!--- 08/14/2006 MLAW Use the lvchargeThroughDate to display on the screen --->
							<INPUT TYPE="Text" CLASS="BlendedTextBoxR" STYLE="width: 85;" READONLY TABINDEX="-1"
							 NAME="dtChargeThroughTarget" Value = "#lvChargeThroughDate#">
							<cfelse>
							<INPUT TYPE="Text" CLASS="BlendedTextBoxR" STYLE="width: 85;" READONLY TABINDEX="-1" 
							NAME="dtChargeThroughTarget" Value = "#TenantCTDate#">
							</cfif>
						</TD>
					</TR>						
				</TABLE>
			</TD>
		</TR>
		<TR><TD COLSPAN="4"><HR></TD></TR>
		<TR><TD COLSPAN="2" STYLE="font-weight: bold; width: 25%;"> <!--- CHARGES OWED ON ACCOUNT:  ---> </TD><TD></TD><TD></TD></TR>
		<!--- 25575 - rts - 7/1/2010 - rts - Respite - if invoice is already finalized, no charges can be added --->
		<!--- <cfif (Tenant.iResidencyType_ID eq 3 AND LastRespiteInvoiceInfo.bFinalized eq 1)>
			<TR>
			<TD COLSPAN="4" STYLE="text-align: center;">
				<TABLE STYLE="width: 80%;">
					<TR>
						<TD COLSPAN=100% NOWRAP> 
							<B>No Additional Charges Can Be Added </B></BR>
						</TD>
					</TR>
					<TR>
						<TD style="text-align:center;">
							The Invoice that is designated to be the Move Out Invoice<br>
							has already been finalized and sent to Solomon.
						</TD>
					</TR>
				</TABLE>
			</TD>
			</TR>		
		<cfelse><!--- end 25575 ... see end IF below too--->
		 --->
		<TR>
			<TD COLSPAN="4" STYLE="text-align: center;">
				<TABLE STYLE="width: 80%;">
					<TR>
						<TD COLSPAN=100% NOWRAP> 
							<B>Damages</B>
								<BR>
								<CFLOOP QUERY='qDamageType'>
									<CFSCRIPT>
										if (qDamageType.currentrow eq 1 OR MoveOutCharges.iDamageStatus eq qDamageType.iDamageType_ID) { 
											selectbit='checked'; 
										} 
										else { selectbit=''; } 
									</CFSCRIPT>
									#qDamageType.cDescription#
									<INPUT NAME='dstatus' TYPE='radio' VALUE='#qDamageType.iDamageType_ID#' #selectbit# 
									onClick='damagestatus(this);'>&nbsp;&nbsp;
								</CFLOOP><BR>
								<SCRIPT>
									function damagestatus(obj){
										if (obj.value != 5) { 
											document.forms[0].DamageAmount.disabled=true; 
											document.forms[0].DamageComments.disabled=true;
											document.forms[0].DamageAmount.style.border="none";
											document.forms[0].DamageComments.style.border="none";
										}
										else { 
											document.forms[0].DamageAmount.disabled=false; 
											document.forms[0].DamageComments.disabled=false; 
											document.forms[0].DamageAmount.style.border="inset 2px";
											document.forms[0].DamageComments.style.border="inset 2px";
											}
									}
								</SCRIPT>
						</TD>
					</TR>
					<TR>
						<TD STYLE="text-align: left; vertical-align:top;">
							<CFSCRIPT>
								if (IsDefined("form.DamageAmount")) { DamageAmount = form.DamageAmount; } else { DamageAmount = "0.00"; }
							</CFSCRIPT>
							$<INPUT TYPE="text" NAME="DamageAmount" VALUE="#TRIM(NumberFormat(Variables.DamageAmount, "999999.99"))#" 
							STYLE="text-align: right;" SIZE="7" onChange="decimal();" MAXLENGHT="9">
						</TD>
						<TD COLSPAN="2" STYLE="vertical-align:top;">
							<CFSCRIPT>
								if (IsDefined("form.DamageComments")){ DamageComments = form.DamageComments; } else {DamageComments = ""; }
							</CFSCRIPT>
							Comments:<BR> 
							<TEXTAREA COLS="35" ROWS="2" NAME="DamageComments" STYLE="font-size: 12;">
							#TRIM(Variables.DamageComments)#
							</TEXTAREA>
						</TD>
					</TR>				
			
						<TR>
							<TD STYLE="width: 25%;"> <B>Other/Additional Charges:</B> </TD>
								<TD COLSPAN="3">
								<CFIF NOT IsDefined("form.OtheriChargeType_ID") AND NOT IsDefined("form.OtheriCharge_ID")>	
									<TABLE STYLE="width: 80%;">
										<TR>
											<TD COLSPAN ="3" STYLE="width: 25%;">
											 	<CFIF Session.userid eq 99999>
													<CFSET scriptaction='sub(this);'>
												<CFELSE>
													<CFSET scriptaction='evaluate();'>
												</CFIF>	
												What Type of Charge is this? <br/><B>(step 1 of 3)</B>	<BR>
												<SELECT NAME="OtheriChargeType_ID" onChange="#scriptaction#">
													<OPTION VALUE = "">	None </OPTION>
													<CFLOOP QUERY="ChargeTypes">
														<OPTION VALUE ="#ChargeTypes.iChargeType_ID#"> #ChargeTypes.cDescription# </OPTION>
													</CFLOOP>
												</SELECT>
											
												<!--- These are For JavaScript Function --->
												<INPUT TYPE="Hidden" NAME="OtheriQuantity" VALUE="0">
												<INPUT TYPE="Hidden" NAME="OtherAmount" VALUE="0">
												<INPUT TYPE="Hidden" NAME="CalculatedOtherAmount" VALUE="0">
												<INPUT TYPE="Hidden" NAME="OthercDescription" VALUE="">
												<INPUT TYPE="Hidden" NAME="OtherComments" VALUE="">
												<div id="myLayer" class="hidden">
													<INPUT TYPE="Button" NAME="Submit" VALUE="Continue" STYLE="color: darkgreen;" 
onClick="document.MoveOutForm.action='MoveOutForm.cfm?ID=#form.iTenant_ID#&Rsn=#url.Rsn#&stp=#Url.Stp#&ShowBtn=#ShowBtn#';submit();">
												</div>
											</TD>
										</TR>
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
												
												<!--- Variables For JavaScript Functions --->
												<INPUT TYPE="Button" NAME="Submit" VALUE="Continue" STYLE="color: darkgreen;" 
			onClick="document.MoveOutForm.action='MoveOutForm.cfm?ID=#form.iTenant_ID#&Rsn=#url.Rsn#&stp=#Url.Stp#&ShowBtn=#ShowBtn#'; submit();">										
												<INPUT TYPE="Hidden" NAME="OtheriQuantity" VALUE="0">
												<INPUT TYPE="Hidden" NAME="OtherAmount" VALUE="0">
												<INPUT TYPE="Hidden" NAME="CalculatedOtherAmount" VALUE="0">
												<INPUT TYPE="Hidden" NAME="OthercDescription" VALUE="">
												<INPUT TYPE="Hidden" NAME="OtherComments" VALUE="">
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
													<INPUT TYPE="text" NAME="OthercDescription" VALUE="#ChargeDetail.cDescription#" 
													MAXLENGTH="15" onKeyUP="this.value=Letters(this.value);  Upper(this);">
												<CFELSE>
													#ChargeDetail.cDescription#
													<INPUT TYPE="Hidden" NAME="OthercDescription" VALUE = "#ChargeDetail.cDescription#">
												</CFIF>
											</TD>
											
											<TD STYLE="text-align: center;">
												<U>Quantity</U><BR>
												<CFIF ChargeDetail.bIsModifiableQTY GT 0 >	
													<INPUT TYPE="text" NAME="OtheriQuantity" VALUE="#ChargeDetail.iQuantity#" 
													SIZE="2" MAXLENGHT="2" onBlur="OtherTotal();" onKeyUP="this.value=Numbers(this.value);">
												<CFELSE>
													#ChargeDetail.iQuantity#
													<INPUT TYPE = "Hidden" NAME = "OtheriQuantity" VALUE = "#ChargeDetail.iQuantity#">
												</CFIF>								
											</TD>
											
											<TD STYLE="text-align: right;">
												<U>Price</U><BR>
												<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
												<CFIF ChargeDetail.bIsModifiableAmount GT 0 OR listfindNocase(session.codeblock,25) GTE 1
												 OR listfindNocase(session.codeblock,23) GTE 1>
													$<INPUT TYPE="text" NAME = "OtherAmount" SIZE="7"
													 VALUE="#TRIM(LSNumberFormat(ChargeDetail.mAmount, "99999.99"))#"  
													 STYLE="text-align: right;" onBlur="decimal(); OtherTotal();" 
													onKeyUP="this.value=CreditNumbers(this.value);">
												<CFELSE>
													$#TRIM(NumberFormat(ChargeDetail.mAmount, "999999.99"))#
													<INPUT TYPE = "Hidden" NAME = "OtherAmount" VALUE = "#ChargeDetail.mAmount#">
												</CFIF>								
											</TD>
											
											<TD STYLE="text-align: right;">
												<CFSET OtherTotal=ChargeDetail.iQuantity * ChargeDetail.mAmount>
													<CFIF isDefined("form.DamageAmount") AND form.DamageAmount EQ "">
														<CFSET form.DamageAmount = 0.00>
													</CFIF>												
												<B><U>Total</U></B><BR>
												<INPUT TYPE="text" NAME="CalculatedOtherAmount" 
												VALUE="#TRIM(LSNumberFormat(Variables.OtherTotal, "99999.99"))#" SIZE="9" 
												STYLE="border: none; text-align: right; color: navy; font-weight: bold;">
											</TD>
										</TR>
										<TR>
											<TD STYLE="text-align: center;"> Apply To Period </TD>
											<TD COLSPAN=2>
											<SELECT NAME="AppliesToMonth">
												<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
													<CFIF Month(SESSION.TIPSMonth) EQ I>
													<CFSET Selected='SELECTED'>
													<CFELSE>
													<CFSET Selected=''>
													</CFIF>
													<OPTION VALUE ="#NumberFormat(I, "09")#" #SELECTED#>
														#NumberFormat(I, "09")#
													</OPTION>
												</CFLOOP>
											</SELECT>
											/
											<INPUT TYPE="Text" NAME="AppliesToYear" VALUE = "#Year(Now())#" SIZE=4 MAXLENGTH=4 
											STYLE="text-align: center;">													

											</TD>
											<TD></TD>
										</TR>
										
										<TR>
											<TD COLSPAN="4" NOWRAP>
												<CFSCRIPT>
													if (IsDefined("ChargeDetail.cComments") AND ChargeDetail.cComments NEQ "") 
													{OtherComments = TRIM(ChargeDetail.cComments); }
													else { OtherComments = ''; }
												</CFSCRIPT>
												Comments: 
												<TEXTAREA COLS="50" ROWS="2" NAME="OtherComments">
												#TRIM(Variables.OtherComments)#
												</TEXTAREA>
											</TD>
										</TR>
										<TR>
											<TD COLSPAN=2 STYLE="text-align: center;">
												<INPUT TYPE="Hidden" NAME="Edit" VALUE="1">												
												<CFIF MoveOutCharges.bEditSysDetails NEQ "" OR (IsDefined("InvoiceCheck.bEditSysDetails")
												 AND InvoiceCheck.bEditSysDetails NEQ "")>
													<!---Modified by Sanipina--02/08/2008--- Modified it so that the savecharge button is disabled once its clicked --->
													<INPUT CLASS="BlendedButton" TYPE="Button" NAME="SaveCharge" VALUE="Save Charge" 
													STYLE="width: 100px;"
						 onClick="document.MoveOutForm.action='MoveOutSysDetailUpdate.cfm?edit=1&ShowBtn=#ShowBtn#'; submit(); this.disabled=true;">
												<CFELSE>
													<INPUT CLASS="BlendedButton" TYPE="Button" NAME="SaveCharge" VALUE="Save Charge" 
													STYLE="width: 100px;" 
							onClick="document.MoveOutForm.action='MoveOutUpdate.cfm?edit=1&ShowBtn=#ShowBtn#'; submit(); this.disabled=true;">
												</CFIF>
											</TD>
											<TD COLSPAN=2>
												<INPUT CLASS="BlendedButton" TYPE="Button" NAME="Cancel Charge" VALUE="Cancel" 
												STYLE="color: green; width: 100px;" onClick="location.href='#HTTP.REFERER#'">
											</TD>
										</TR>
									</TABLE>
							
								</CFIF>
							</TD>	
						</TR>
						
						<TR>
							<TD COLSPAN="4">
								<TABLE STYLE="width: 100%;">
									<CFIF ListFindNoCase(SESSION.codeblock,23) GT 0>
										<CFIF MoveOutCharges.bEditSysDetails NEQ "">
											<CFSET STYLE= "STYLE='font-weight: bold;'">
											<CFSET ButtonValue = "De-Activate">
										<CFELSE>
											<CFSET STYLE="STYLE='color: navy;'">
											<CFSET ButtonValue = "Activate">
										</CFIF>
									
										<!--- ==============================================================================
										REQUIRE atleast ONE save before override can be done
										=============================================================================== --->
										<CFIF MoveoutCharges.RecordCount GT 0>
											<SCRIPT>
												function activatebutton(){
													if (document.forms[0].OverRideSystem.value == "De-Activate"){
														activatemessage = 'By De-Activating your changes will be over written when you save. \r \t Are you sure?'; }
													else { activatemessage = 'Please note: \rBy disabling system charges the charge through date and the prorate days may not correlate.'; }
												
													if (confirm(activatemessage)){
														document.forms[0].action='EditSysDetails.cfm?MasterID=#MoveOutCharges.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#'; 
														document.MoveOutForm.submit(); }
													else { return false; }
												}
											</SCRIPT>
											
											<TR>
												<TD COLSPAN=100% STYLE="background: gainsboro; text-align: center;">
													<B><U>FOR ACCT ONLY</U>: Over Ride System Generated Charges </B>
													<INPUT TYPE="submit" Class="BlendedButton" Name="OverRideSystem" 
													VALUE="#ButtonValue#" #STYLE# onClick="return activatebutton();">
												</TD>
											</TR>
										</CFIF>
									</CFIF>
	
									<TR>
										<TD NOWRAP style="font-weight:bold">Per. To Apply</B> </TD>
										<TD NOWRAP style="font-weight:bold; font-weight:bold">Description</B> </TD>
										<TD STYLE="text-align: right;font-weight:bold">Amount</B> </TD>
										<TD STYLE="text-align: right;font-weight:bold">Qty</B> </TD>
										<TD STYLE="text-align: right;font-weight:bold">Price</B> </TD>
										<TD STYLE="text-align: center;font-weight:bold">Delete</B> </TD>
									</TR>

									<CFIF CurrentCharges.RecordCount GT 0>
											<INPUT TYPE="Hidden" NAME="SysEdit" VALUE="#MoveOutCharges.bEditSysDetails#">
											<CFLOOP QUERY="CurrentCharges">
												<SCRIPT>
													function mathfor#CurrentCharges.iInvoiceDetail_ID#() {
														if (document.forms[0].Sysquantity#CurrentCharges.iInvoiceDetail_ID#.value == '')
														 { document.forms[0].Sysquantity#CurrentCharges.iInvoiceDetail_ID#.value = 1; }
														calc#CurrentCharges.iInvoiceDetail_ID# = mocent(moround(
														(document.forms[0].SysmAmount#CurrentCharges.iInvoiceDetail_ID#.value *
														 document.forms[0].Sysquantity#CurrentCharges.iInvoiceDetail_ID#.value)));
														document.forms[0].SysExtendedPrice#CurrentCharges.iInvoiceDetail_ID#.value =
														 calc#CurrentCharges.iInvoiceDetail_ID#;
														document.forms[0].SysmAmount#CurrentCharges.iInvoiceDetail_ID#.value =
														 mocent(moround((document.forms[0].SysmAmount#CurrentCharges.iInvoiceDetail_ID#.value)));
													}
												</SCRIPT>
												
												<CFIF IsDefined("form.SysmAmount#CurrentCharges.iInvoiceDetail_ID#")>
													<CFSET SysAmount = Evaluate('form.SysmAmount'& CurrentCharges.iInvoiceDetail_ID)>
												<CFELSE>
													<CFSET SysAmount =  CurrentCharges.mAmount>
												</CFIF>
												
												<CFIF IsDefined("form.Sysquantity#CurrentCharges.iInvoiceDetail_ID#")>
													<CFSET Sysquantity= Evaluate('form.Sysquantity'&#CurrentCharges.iInvoiceDetail_ID#)>
												<CFELSE>
													<CFSET Sysquantity =  CurrentCharges.iQuantity>
												</CFIF>
												
												<CFIF CurrentCharges.iRowStartUser_ID EQ 0 AND MoveOutCharges.bEditSysDetails GT 0>
													<TR><!--- per to apply --->
														<TD STYLE="text-align: center;"> <!--- per to apply --->
															<INPUT TYPE="text" NAME="SysPeriod#CurrentCharges.iInvoiceDetail_ID#" 
															VALUE="#CurrentCharges.cAppliesToAcctPeriod#" 
															SIZE="#Len(CurrentCharges.cAppliesToAcctPeriod)#">
														</TD>
														<TD><!--- description --->
									<!--- MLAW 10/18/2005 Format the description size from #Len(TRIM(CurrentCharges.cDescription))# to 50 --->
															<INPUT TYPE="text" NAME="SyscDescription#CurrentCharges.iInvoiceDetail_ID#"
															 VALUE="#CurrentCharges.cDescription#" SIZE="50">
														</TD>
														<TD STYLE="text-align: right;"><!--- amount --->
															<!--- SIZE="#Len(TRIM(CurrentCharges.mAmount))#" --->
															$<INPUT TYPE="text" NAME="SysmAmount#CurrentCharges.iInvoiceDetail_ID#"
															 VALUE="#LSNumberFormat(TRIM(SysAmount),"99999.99")#" 
																STYLE="text-align: right; width: #Len(CurrentCharges.mAmount)#ex;"
												onBlur="this.value=CreditNumbers(this.value); mathfor#CurrentCharges.iInvoiceDetail_ID#();">
														</TD>
														<TD STYLE="text-align: right;"><!--- qty --->
															<INPUT TYPE="text" NAME="Sysquantity#CurrentCharges.iInvoiceDetail_ID#" 
															VALUE="#TRIM(Sysquantity)#" 
																SIZE="#Len(TRIM(Sysquantity))#" 
																STYLE="text-align: center;" 
																MAXLENGTH="3"
												onBlur="this.value=CreditNumbers(this.value); mathfor#CurrentCharges.iInvoiceDetail_ID#();">
														</TD>
														
														<CFIF CurrentCharges.mAmount NEQ "">
															<CFSET ExtendedPrice = #CurrentCharges.mAmount# * #CurrentCharges.iQuantity#>
														<CFELSE>
															<CFSET ExtendedPrice = 0.00>
														</CFIF>
														<TD STYLE="text-align: right;"> <!--- price --->
															$<INPUT TYPE="text" READONLY 
															NAME="SysExtendedPrice#CurrentCharges.iInvoiceDetail_ID#" 
															VALUE="#TRIM(LSNumberFormat(ExtendedPrice,"99999.99"))#" 
															SIZE="#Len(TRIM(LSNumberFormat(ExtendedPrice,"99999.99")))#" 
															STYLE='border: noborder; text-align: right; background:transparent;'>
														</TD>
														<CFIF CurrentCharges.RecordCount GT 1>
															<TD> <INPUT CLASS="BlendedButton" TYPE="Button" NAME="Delete" VALUE="Delete" 
															STYLE="width: 6em;" 
onClick="location.href='DeleteDetail.cfm?ID=#Tenant.iTenant_ID#&DID=#CurrentCharges.iInvoiceDetail_ID#&Rsn=#url.rsn#&stp=#url.stp#&ShowBtn=#ShowBtn#'"> 
														</TD>
														<CFELSE>
															<TD></TD>
														</CFIF>
													</TR>
													<CFIF len(CurrentCharges.cComments) gt 0>
													<TR>
														<TD COLSPAN=100% STYLE='font-size:xx-small;'>
															<DD>**#trim(CurrentCharges.cComments)#</DD>
														</TD>
													</TR>
													</CFIF>
												<CFELSE>
													<TR>
														<TD STYLE="text-align: center;">
														 #CurrentCharges.cAppliesToAcctPeriod# </TD>
														<TD>#CurrentCharges.cDescription#</TD>
														<TD STYLE="text-align: right;">
														 #LSCurrencyFormat(CurrentCharges.mAmount)# </TD>
														<TD STYLE="text-align: right;"> #CurrentCharges.iQuantity# </TD>
														
														<CFIF CurrentCharges.mAmount NEQ "">
															<CFSET ExtendedPrice = CurrentCharges.mAmount * CurrentCharges.iQuantity>
														<CFELSE>
															<CFSET ExtendedPrice = 0.00>
														</CFIF>
														<TD STYLE="text-align: right;"> #LSCurrencyFormat(ExtendedPrice)# </TD>
														<TD STYLE="text-align: center;">
															<CFIF CurrentCharges.RecordCount GT 0 AND (CurrentCharges.bMoveOutInvoice GT 0 
															AND (CurrentCharges.iRowStartUser_ID NEQ 0 AND CurrentCharges.iRowStartUser_ID NEQ 9999))  <!---Ganga adde code to check 9999 records don't show delete button --->
															OR (CurrentCharges.bIsDiscount GT 0 
															AND CurrentCharges.bIsRent GT 0) 
															OR (CurrentCharges.bEditSysDetails GT 0)>
															<INPUT CLASS="BlendedButton" TYPE="Button" NAME="Delete" VALUE="Delete"
															STYLE="width: 6em;" onClick="location.href='DeleteDetail.cfm?ID=#Tenant.iTenant_ID#&DID=#CurrentCharges.iInvoiceDetail_ID#&Rsn=#url.rsn#&stp=#url.stp#&ShowBtn=#ShowBtn#'">
															<CFELSE>
																Invoiced in Period #CurrentCharges.cAppliesToAcctPeriod#
															</CFIF>
														</TD>
													</TR>
													<CFIF len(CurrentCharges.cComments) gt 0>
													<TR>
														<TD COLSPAN=100% STYLE='font-size:xx-small;'>
															<DD>**#trim(CurrentCharges.cComments)#</DD>
														</TD>
													</TR>
													</CFIF>													
												</CFIF>
											</CFLOOP>
									<CFELSE>
										<TR><TD COLSPAN="6">There are no records at this time.</TD></TR>
									</CFIF>		
								</TABLE>
							</TD>
						</TR>
						<!--- </cfif><!--- end 25575 ---> --->
				
	 			<CFIF MoveoutCharges.RecordCount is  0>
					<tr  STYLE="font-weight:bold">
						<td colspan="3">Deferred Community Fee</td>
						<td colspan="3"><cfif tenant.madjnrf is  '' and tenant.iMonthsDeferred gt 0>
						#dollarformat(tenant.mbasenrf)# 
						<cfelse>
						#dollarformat(tenant.madjnrf)# 
						</cfif></td>
					</tr>  
					<tr>
						<td  colspan="2" STYLE="text-align: center;font-weight:bold">
						Installment Payment<br />Start Date
						</td>
						<td  colspan="2" STYLE="text-align: center;font-weight:bold; " nowrap="nowrap">
						Installment Payment<br />End Date
						</td>
						<td  colspan="2" STYLE="text-align: center;font-weight:bold">
						Deferred Amount
						</td>
					</tr>
					<tr>
						<td colspan="2" style="text-align:center">#dateformat(qryDefNRF.dtEffectiveStart, 'mm/yyyy')#</td>
						<td  colspan="2" style="text-align:center">#dateformat(qryDefNRF.dtEffectiveEnd, 'mm/yyyy')#</td>
						<td colspan="2" style="text-align:center">
						<cfif tenant.iMonthsDeferred gt 1>
							<cfif tenant.madjnrf is  ''>
								#dollarformat(tenant.mbasenrf - tenant.mAmtDeferred)#
							<cfelse>
								#dollarformat(tenant.madjnrf- tenant.mAmtDeferred)#
							</cfif>
						<cfelse>
						$0.00
						</cfif>
						</td> <!---  qryDefNRF.mAmtDeferred) qryPayments.paymentamt/tenant.iMonthsDeferred --->
					</tr>
					<tr>
						<td  colspan="2" STYLE="text-align: center;font-weight:bold">Amount Paid</td>
						<td  colspan="2" STYLE="text-align: center;font-weight:bold">Monthly Installment</td>
						<td  colspan="2" STYLE="text-align: center;font-weight:bold">Remaining Balance</td>
					</tr>					
					<tr>
						<input type="hidden" name="CFRemainingBal" id="CFRemainingBal" value="" />						
						<td  colspan="2" style="text-align:center"> #dollarformat(totalpayments)# </td>
						<!--- #numberformat(paymentmonths,0)# --->
						<td  colspan="2" style="text-align:center">#dollarformat(monthlypayment)#</td>
						<cfif ((tenant.iMonthsDeferred is 0) or  (tenant.iMonthsDeferred is '') or  (tenant.iMonthsDeferred is 1))>
							<cfset CFRemainingBal = 0>						
						<cfelseif ((tenant.madjnrf is  '') and (tenant.iMonthsDeferred gt 1))>
							<cfset CFRemainingBal = tenant.mbasenrf - totalpayments>
						<cfelse>
							<cfset CFRemainingBal =	tenant.madjnrf - totalpayments >
						</cfif>						
<!--- 						<cfif tenant.iMonthsDeferred is 0 or  tenant.iMonthsDeferred is ''>
							<cfset CFRemainingBal = 0>						
						<cfelseif tenant.madjnrf is  '' and tenant.iMonthsDeferred gt 0>
							<cfset CFRemainingBal = tenant.mbasenrf - totalpayments>
						<cfelse>
							<cfset CFRemainingBal =	tenant.madjnrf - totalpayments >
						</cfif> --->
<!---  						<cfscript>
						CFRemainingBal = variables.remainingbal;
						</cfscript>  --->
						<td colspan="2" style="text-align:center">#dollarformat(CFRemainingBal)#
						<input type="hidden" name="CFRemainingBal" id="CFRemainingBal" value="#numberformat(CFRemainingBal,'9999.99')#"  readonly=""/>
						</td>
					</tr>
 				</CFIF>
 
				</CFIF>			
				</TABLE>
			</TD>
		</TR>
		
	<CFIF IsDefined("url.Rsn") AND Url.stp EQ 4 >
		<TR><TD COLSPAN=100% STYLE="font-weight: bold;"> BILLING INFORMATION: </TD></TR>	
		<CFSCRIPT>
			if (MoveOutPayor.RecordCount gt 0 ) {
				iContact_id = MoveOutPayor.iContact_id;
				cFirstName = MoveOutPayor.cFirstName;
				cLastName = MoveOutPayor.cLastName;
				iRelationshipType_ID	= MoveOutPayor.iRelationshipType_ID;
				cAddressLine1 = MoveOutPayor.cAddressLine1;
				cAddressLine2 = MoveOutPayor.cAddressLine2;
				cCity = MoveOutPayor.cCity;
				cStateCode = MoveOutPayor.cStateCode;
				cZipCode = MoveOutPayor.cZipCode;		}
			else if (Payor.RecordCount gt 0) {
				iContact_id = Payor.iContact_id;
				cFirstName = Payor.cFirstName;
				cLastName = Payor.cLastName;
				iRelationshipType_ID	= Payor.iRelationshipType_ID;
				cAddressLine1 = Payor.cAddressLine1;
				cAddressLine2 = Payor.cAddressLine2;
				cCity = Payor.cCity;
				cStateCode = Payor.cStateCode;
				cZipCode = Payor.cZipCode;}
			else if (Payor.RecordCount EQ 0 AND (IsDefined ("form.cLastName") AND (form.cFirstName NEQ "" AND form.cLastName NEQ ""))) 
			{
				iContact_id = '';
				cFirstName = form.cFirstName; 
				cLastName = form.cLastName; 
				iRelationshipType_ID = form.iRelationshipType_ID;	
				cAddressLine1 = form.cAddressLine1;
				cAddressLine2 = form.cAddressLine2;	
				cCity = form.cCity;	
				cStateCode = form.cStateCode; 
				cZipCode = form.cZipCode; 
					}
			else  
			{
				iContact_id = '';
					cFirstName = tenant.cFirstName; 
					cLastName = tenant.cLastName;
					iRelationshipType_ID = 17;	
					cAddressLine1 = '' ;
					cAddressLine2 = '';
					cCity = '';	
					cStateCode = ''; 
					cZipCode = ''; 
					}					
		</CFSCRIPT>
		
		<CFIF (isDefined("iContact_id") AND len(iContact_id) GT 0)>
		<INPUT TYPE=hidden NAME='iContact_ID' VALUE='#iContact_ID#'>
		</CFIF>
		<TR>
			<TD COLSPAN="5" STYLE="text-align: center;">
				<TABLE STYLE="width: 75%;">
					<TR>
						<TD STYLE="Font-weight: bold; width: 25%; color: red;"> First Name </TD>
						<TD><INPUT TYPE="text" NAME="cFirstName" VALUE="#Variables.cFirstName#" 
						MAXLENGTH="25" 
						onBlur="this.value=Letters(this.value); Upper(this);"></TD>
						<TD></TD>
						<TD></TD>	
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold; width: 25%; color: red;">	Last Name</TD>
						<TD><INPUT TYPE="text" NAME="cLastName" VALUE="#Variables.cLastName#" 
						MAXLENGTH="25" onBlur="this.value=Letters(this.value); Upper(this);"></TD>
						<TD></TD>
						<TD></TD>	
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold; color: red;">	RelationShip:</TD>
						<TD>	
							<SELECT NAME = "iRelationshipType_ID">
								<option value="">Select</option>
								<CFLOOP QUERY = "RELATIONSHIPS">
									<CFSCRIPT>
										if (IsDefined("form.iRelationshipType_ID") 
										AND form.iRelationshipType_ID EQ RelationShips.iRelationshipType_ID)
										{Selected = 'Selected';}
										else if (MoveOutPayor.iRelationshipType_ID EQ RelationShips.iRelationshipType_ID)
										{Selected = 'Selected';}
										else if (Payor.iRelationshipType_ID EQ RelationShips.iRelationshipType_ID)
										{Selected = 'Selected';}

										else {Selected = '';}
									</CFSCRIPT>
									<OPTION VALUE = "#RelationShips.iRelationshipType_ID#" #Selected#>#RelationShips.cDescription#</OPTION>
								</CFLOOP>
							</SELECT>
						</TD>
						<TD></TD><TD></TD>	
					</TR>
					<TR>
						<TD STYLE = "Font-weight: bold; color: red;">Address (Line 1)</TD>
						<TD> <INPUT TYPE="text" Name="cAddressLine1" VALUE="#Variables.cAddressLine1#" SIZE="40" MAXLENGTH="40"> </TD>
						<TD></TD><TD></TD>	
					</TR>					
					<TR>
						<TD STYLE="Font-weight: bold;">	Address (Line 2)</TD>
						<TD> <INPUT TYPE="text" Name="cAddressLine2" VALUE="#Variables.cAddressLine2#" SIZE="40" MAXLENGTH = "40"> </TD>
						<TD></TD><TD></TD>	
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold; color: red;">	City </TD>
						<TD COLSPAN="3"> <INPUT TYPE="text" Name="cCity" VALUE="#Variables.cCity#" onKeyUp="this.value=Letters(this.value)"></TD>
					</TR>
					<TR>
						<TD STYLE = "Font-weight: bold; color: red;"> State	</TD>
						<TD COLSPAN = "3">
							<SELECT NAME="cStateCode">	
								<OPTION VALUE ="" #SELECTED#>Select</OPTION>	
								<CFLOOP Query = "StateCodes">
									<CFSCRIPT>
										if (IsDefined("MoveOutPayor.cStateCode") AND MoveOutPayor.cStateCode EQ cStateCode){ Selected = 'Selected';}
										else if (IsDefined("Payor.cStateCode") AND Payor.cStateCode EQ cStateCode){ Selected = 'Selected';}

										else if (IsDefined("form.cStateCode") AND form.cStateCode EQ cStateCode) { Selected = 'Selected'; }
										else { selected = '';}
									</CFSCRIPT>
									<OPTION VALUE ="#cStateCode#" #SELECTED#>	#cStateName# - #cStateCode# </OPTION>
								</CFLOOP>
							</SELECT>
						</TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold; color: red;">Zip Code</TD>
						<TD COLSPAN="3">
							<INPUT TYPE="text" Name="cZipCode" VALUE="#Variables.cZipCode#" onKeyUp="this.value=LeadingZeroNumbers(this.value);">
						</TD>
					</TR>
					<TR>
						<TD STYLE="Font-weight: bold; color: red;">Primary Phone:</TD>
						<TD>
							<CFSCRIPT>
								if (IsDefined("form.areacode1") AND IsDefined("form.prefix1") AND IsDefined("form.number1")) {
									areacode1 = form.areacode1; prefix1 = form.prefix1; number1 = form.number1;}
								else if (Len(MoveOutPayor.cPhoneNumber1) EQ 10) {
									areacode1 = LEFT(MoveOutPayor.cPhoneNumber1,3); prefix1 = Mid(MoveOutPayor.cPhoneNumber1,4,3);
									 number1 = RIGHT(MoveOutPayor.cPhoneNumber1,4); }

								else if (Len(Payor.cPhoneNumber1) EQ 10) {
									areacode1 = LEFT(Payor.cPhoneNumber1,3); prefix1 = Mid(Payor.cPhoneNumber1,4,3); 
									number1 = RIGHT(Payor.cPhoneNumber1,4); }
								else{ areacode1 = ''; prefix1 = ''; number1 = ''; }
							</CFSCRIPT>
							<INPUT TYPE="text" NAME="areacode1"	SIZE="3" VALUE="#Variables.areacode1#" MAXLENGTH="3"
							 onKeyUP="this.value=LeadingZeroNumbers(this.value)">-
							<INPUT TYPE="text" NAME="prefix1"	SIZE="3" VALUE="#Variables.prefix1#" MAXLENGTH="3" 
							onKeyUP="this.value=LeadingZeroNumbers(this.value)">-
							<INPUT TYPE="text" NAME="number1"	SIZE="4" VALUE="#Variables.number1#" MAXLENGTH="4" 
							onKeyUP="this.value=LeadingZeroNumbers(this.value)">
							<INPUT TYPE="hidden" NAME="iPhoneType1_ID"	VALUE="1">						
						</TD>
						<TD></TD><TD></TD>	
					</TR>
					<TR>
						<TD STYLE = "Font-weight: bold; ">Message Phone:</TD>
						<TD>
							<CFSCRIPT>
								if (IsDefined("form.areacode2") AND IsDefined("form.prefix2") AND IsDefined("form.number2"))
								 { areacode2 = form.areacode2; prefix2 = form.prefix2; number2 = form.number2; }
								else { areacode2 = LEFT(Payor.cPhoneNumber2,3); prefix2 = Mid(Payor.cPhoneNumber2,4,3);
								 number2 = RIGHT(Payor.cPhoneNumber2,4); }
							</CFSCRIPT>
							<INPUT TYPE="text" NAME="areacode2"	SIZE="3" VALUE="#Variables.areacode2#" MAXLENGTH="3" 
							onKeyUP="this.value=LeadingZeroNumbers(this.value)">-
							<INPUT TYPE="text" NAME="prefix2" SIZE="3" VALUE="#Variables.prefix2#" MAXLENGTH="3" 
							onKeyUP="this.value=LeadingZeroNumbers(this.value)">-
							<INPUT TYPE="text" NAME="number2" SIZE="4" VALUE="#Variables.number2#" MAXLENGTH="4" 
							onKeyUP="this.value=LeadingZeroNumbers(this.value)">
							<INPUT TYPE="hidden" NAME="iPhoneType2_ID"	VALUE="5">
						</TD>
						<TD></TD><TD></TD>	
					</TR>
					<TR>
						<TD>
							<CFSCRIPT>
								if (IsDefined("form.cComments")){ cComments = form.cComments;} else if (Payor.cComments NEQ "") 
								{ cComments = Payor.cComments; } else{cComments = "";}
							</CFSCRIPT>
							Comments:
						</TD>
						<TD><TEXTAREA COLS="35" ROWS="2" NAME="cComments" VALUE="#Variables.cComments#">#Variables.cComments#</TEXTAREA></TD>
						<TD></TD><TD></TD>
					</TR>					
				</TABLE>
			</TD>
		</TR>
		<TR>
			<TD COLSPAN="5" STYLE="text-align: left;">
				<CFSCRIPT>if (MoveOutCharges.InvoiceComments NEQ ""){InvoiceComments = MoveOutCharges.InvoiceComments;} else
				 {InvoiceComments = '';}</CFSCRIPT>
				<B>Past Due Balance Description</B><BR> <TEXTAREA COLS="70" ROWS="2" NAME="InvoiceComments"
				 VALUE="#Variables.cComments#">#Variables.InvoiceComments#</TEXTAREA>
			</TD>
		</TR>
	</CFIF>		
	</TABLE>
	<!---created the hidden form variable to submit to form//mamta
	<cfoutput> Mamta - Secondary to Primary IsTenantPrimary #IsTenantPrimary.ioccupancyposition# and secondary itenant_id #SecondaryTenantExist.itenant_id#</cfoutput>--->
	<input type="hidden" name="IsTenantPrimary" value="#IsTenantPrimary.ioccupancyposition#">
	<input type="hidden" name="SecondaryTenantId" value="#SecondaryTenantExist.itenant_id#">
	<!---end--->

 <CFIF ((IsDefined("form.Reason") OR IsDefined("url.Rsn")) AND IsDefined("form.ChargeDay"))>
	<TABLE>
		<TR>
			<TD STYLE="text-align: left;">
				<CFSCRIPT>
					if (MoveOutCharges.bEditSysDetails NEQ "") { 
						script="document.MoveOutForm.action='MoveOutSysDetailUpdate.cfm?MID=#Variables.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#';";
					}
					else {  script="document.MoveOutForm.action='MoveOutUpdate.cfm?MID=#MoveOutCharges.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#';"; }
				</CFSCRIPT>
				<SCRIPT>
					function formvalidate() {
						var miyear = (document.MoveOutForm.moveinyear.value); var mimonth = ((document.MoveOutForm.moveinmonth.value) - 1); 
						var miday = (document.MoveOutForm.moveinday.value); var movein = new Date(miyear, mimonth, miday);
						
						var moyear = (document.MoveOutForm.MoveOutYear.value); var momonth = ((document.MoveOutForm.MoveOutMonth.value) - 1);
						var moday = (document.MoveOutForm.MoveOutDay.value); var moveout = new Date(moyear, momonth, moday);
						
						var noyear = (document.MoveOutForm.NoticeYear.value); var nomonth = ((document.MoveOutForm.NoticeMonth.value) - 1);
						var noday = (document.MoveOutForm.NoticeDay.value); var notice = new Date(noyear, nomonth, noday);
						
						
					var chyear = (document.MoveOutForm.ChargeYear.value); var chmonth = ((document.MoveOutForm.ChargeMonth.value) - 1);
						var chday = (document.MoveOutForm.ChargeDay.value); var charge = new Date(chyear, chmonth, chday);
			


					//mstriegel 03/10/2018 
					 if(document.MoveOutForm.ResidencyType.value !=3){
					 validdate();
					 }
					 if (document.MoveOutForm.ResidencyType.value == 3 && document.MoveOutForm.dtNoticeDateChk.value != ''){
							validdate();
					
					 }
					 if(document.MoveOutForm.ResidencyType.value == 3 && document.MoveOutForm.dtNoticeDateChk.value == ''){

					 	validatenonotice();		
					 	#script# document.forms[0].submit();
						//	alert("1. Please Wait while the information is saving\n2. Do not Click again the Save & View Summary Button\n3. Click OK to proceed");
						alert("Do not Click again the Save & View Summary Button\n Click OK to proceed");
						return true;
					 }
					 //end mstriegel 03/10/2018
					
						//if (document.forms[0].DamageStatus.value == "") { document.forms[0].DamageStatus.focus(); alert('Are there any damages that need to be entered?'); return false;}
						if (document.forms[0].cFirstName.value !== "" && document.forms[0].cLastName.value !== ""
							&& document.forms[0].cAddressLine1.value !== "" && document.forms[0].cCity.value !== ""
							&& document.forms[0].cZipCode.value !== ""
							) {
							if (document.forms[0].MoveOutDay.value !== "" && document.forms[0].MoveOutMonth.value !== ""
							&& document.forms[0].NoticeDay.value !== "" && document.forms[0].NoticeMonth.value !== ""
							&& (moveout >= movein && charge >= movein)) {
								
								#script# document.forms[0].submit();
								
							//	alert("1. Please Wait while the information is saving\n2. Do not Click again the Save & View Summary Button\n3. Click OK to proceed");
								alert("Do not Click again the Save & View Summary Button\n Click OK to proceed");

							}
							else{ validdate(); }
						}
						else { alert('Final Billing address information is required.'); document.forms[0].cFirstName.focus(); return false;}
					}

//mstriegel 03/10/2018
	function RespiteMoveOut(){

		 if( document.MoveOutForm.ARCheck.value == 1){ 
		 	
		 	if(document.MoveOutForm.ResidencyType.value != 3){
		 		
				return checkbillinginfoonsaveForAR(); 
			}
			else if (document.MoveOutForm.ResidencyType.value == 3 && document.MoveOutForm.dtNoticeDateChk.value != ''){
				return	checkbillinginfoonsaveForAR();
			}
			else{
				return checkbillinginfoonsaveForARnonotice();
			}
		 }
		 else{
			if(document.MoveOutForm.ResidencyType.value != 3){
				return checkbillinginfoonsave();
			}
			else if (document.MoveOutForm.ResidencyType.value == 3 && document.MoveOutForm.dtNoticeDateChk.value != ''){
				return checkbillinginfoonsave();
			}
			else{
				return checkbillinginfoonsavenonotice();
			}
		}
	} //end function Respite Move oUT
//end mstriegel 03/10/2018 

				</SCRIPT>
				<!--- Project 30096 modification 11/18/2008 sathya added the onfocus --->
				<!---Modified by Sanipina--02/08/2008-- modified it so that the Save & View Summary button when clicked it checks for validations ---><!--- removed "this.disabled=true;" causing problems --->
				 <!--- Project 30096 ssathya added this so that the AR will have a different set of validation than the house people have.Because one of the condition says that it has to override the condition that AR can enter any date --->
				 <cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
				<!--- mstreigel 03/10/2018 --->
				<INPUT TYPE="button" NAME="Save" VALUE="Save & View Summary" STYLE="width:150px; color:navy;
				 font-size:xx-small;" onmouseover="RespiteMoveOut();" onClick="formvalidate();"
				  onfocus="RespiteMoveOut();">
				<cfelse>
				<INPUT TYPE="button" NAME="Save" VALUE="Save & View Summary" STYLE="width:150px; color:navy; 
				font-size:xx-small;" onmouseover="RespiteMoveOut();" onClick="formvalidate();" onfocus="RespiteMoveOut();">
				<!--- end mstriegel --->
				</cfif>
			</TD>
			<CFIF Tenant.iTenantStateCode_ID LT 3 and tenant.dtmoveout neq "">
				<SCRIPT>
				function confirmation(){
					if (confirm('Are you sure you want delete all move out information?')){
						document.forms[0].action='RemoveMoveOutData.cfm?iTenant_ID=#Tenant.iTenant_ID#&iInvoiceMaster_ID=#MoveOutCharges.iInvoiceMaster_ID#&ShowBtn=#ShowBtn#';
						document.forms[0].submit(); }
				}
				</SCRIPT>	
				<TD><INPUT TYPE="Button" NAME="MoReset" VALUE="Resident is not moving out" 
				STYLE="width:160px; color:maroon; font-size:xx-small;" onClick="confirmation();"></TD>
			</CFIF>
			<TD STYLE="Text-align: right;">
				<INPUT TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" style="color:red;font-size:xx-small;"
				 onClick="<cfif ShowBtn>self.location.href='../MainMenu.cfm'
				 <cfelse>
				 self.location.href='../census/FinalizeMoveOut.cfm?ShowBtn=#ShowBtn#'
				 </cfif>">
			</TD>
		</TR>
	</TABLE>
</CFIF>
</FORM>
</CFOUTPUT>
<BR>
<CFIF ShowBtn>
	<A HREF="../MainMenu.cfm" STYLE="Font-size: 18;">Click Here to Go Back To TIPS Summary.</A>
<CFELSE>
	<A HREF="../census/FinalizeMoveOut.cfm" STYLE="Font-size: 18;">Click Here to Go Back.</A>
</CFIF>

<SCRIPT>
	try {
		//11/06/2008 project 30096 ssathya commented this and modified this
		if (document.forms[0].ChargeMonth.value !== '' && document.forms[0].ChargeDay.value !==''
		&& document.forms[0].ChargeDay.year !=='' && document.forms[0].MoveOutMonth.value !==''
		&&	document.forms[0].ChargeDate.value !== '' && document.forms[0].MoveOutMonth.value !==''
			&& document.forms[0].MoveOutDay.value !=='' && document.forms[0].MoveOutYear.value !==''
			&& document.forms[0].NoticeMonth.value !=='' && document.forms[0].NoticeDay.value !==''
			&& document.forms[0].NoticeYear.value !==''){
			dayslist(document.forms[0].MoveOutMonth, document.forms[0].MoveOutDay, document.forms[0].MoveOutYear);
			dayslist(document.forms[0].NoticeMonth, document.forms[0].NoticeDay, document.forms[0].NoticeYear);
			
			//11/06/2008 project 30096 ssathya commented this line of code
		dayslist(document.forms[0].ChargeMonth, document.forms[0].ChargeDay, document.forms[0].ChargeYear);
			dayslist(document.forms[0].ChargeDate.value);
			
			setTargetChargeThrough(document.forms[0].Voluntarybox.checked);
		}
		for (i=0;i<=(document.forms[0].dstatus.length-1);i++) { if (document.forms[0].dstatus[i].defaultChecked == true) 
		{ damagestatus(document.forms[0].dstatus[i]); } }
		validdate();
	}
	catch (exception) { /* do nothing */ }
</SCRIPT>

<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">


