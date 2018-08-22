<!---  -----------------------------------------------------------------------------------------------
| Author     | Date       | Ticket      | Description                                                |
|            |            | Project Nbr.|                                                            |
------------------------------------------------------------------------------------------------------
|sfarmer     | 4/10/2012  |  75019      |  EFT Update/NRF Deferral.                                  |
|sfarmer     | 06/09/2012 | 75019       | NRF/Deferred Installation                                  | 
|Sfarmer     | 09/18/2013 | 102919      |Revise NRF approval process                                 |
 |S Farmer   | 09/08/2014 | 116824             | Allow all houses edit BSF and Community Fee Rates |
 ------------------------------------------------------------------------------------------------ --->
 
 <head>
<title>Revise Move_in NRF Amount</title>
</head>
<cfquery name="qryTenantPending" datasource="#application.datasource#">
	Select T.cLastName, T.cFirstName, TS.mBaseNRF, TS.mAdjNRF, TS.iNRFMid, T.itenant_id, t.csolomonkey 
	from Tenant T
		join tenantState TS on T.itenant_id = TS.itenant_id
	where T.itenant_id = #URL.ID#
</cfquery>
<cfquery name="qryRecurringNRF" datasource="#application.datasource#">  
SELECT   
                      ind.iInvoiceMaster_ID, ind.iInvoiceDetail_ID, ind.iRecurringCharge_ID, ind.iTenant_ID, ind.iChargeType_ID, ind.bIsRentAdj, ind.dtTransaction, ind.iQuantity, ind.cDescription AS InvoiceDescription, 
                      ind.mAmount, ind.dtRowDeleted, inm.cAppliesToAcctPeriod, inm.iInvoiceNumber, inm.cSolomonKey, inm.bMoveInInvoice, inm.dtInvoiceStart, 
                      inm.dtInvoiceEnd, inm.bMoveOutInvoice, chg.cDescription AS ChargeDescription, chg.bOccupancyPosition, chg.bIsMedicaid, chg.bIsRent, 
                      ind.cAppliesToAcctPeriod AS detailAppliesToAcctPeriod, inm.bFinalized, ind.cComments, inm.dtRowStart AS masterDtRowStart, 
                      inm.dtRowDeleted AS masterDtRowDeleted, ind.bNoInvoiceDisplay 
					  
FROM         dbo.InvoiceDetail ind INNER JOIN
                      dbo.InvoiceMaster inm ON ind.iInvoiceMaster_ID = inm.iInvoiceMaster_ID INNER JOIN
                      dbo.ChargeType chg ON ind.iChargeType_ID = chg.iChargeType_ID AND ISNULL(chg.dtRowDeleted, ISNULL(inm.dtInvoiceEnd, GETDATE())) 
                      >= ISNULL(inm.dtInvoiceEnd, GETDATE())
WHERE     (ind.dtRowDeleted IS NULL) AND (inm.dtRowDeleted IS NULL) and ind.ichargetype_id in (69,1740, 1741)
and ind.iTenant_ID = #URL.ID#
ORDER BY ind.ichargetype_id
</cfquery>
<CFQUERY NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#"> 
		select c.mamount as NRF 
	from Charges c 
	join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
	where c.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and c.cChargeSet = (select cs.cName 
	from Chargeset cs 
	join House h on (h.iChargeSet_ID = cs.iChargeSet_ID and h.iHouse_ID = #session.qSelectedHouse.iHouse_ID#))
	and c.dtRowDeleted is null
	and c.iChargeType_ID   in (69)
	and c.bIsMoveInCharge = 1
</CFQUERY>
<cfparam name="defamount" default="0">
<script language="JavaScript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>
<script  type="text/javascript">
	function initialize() { 
		document.getElementById("NRFDISC").style.background = 'red';	
		document.getElementById("NRFDISC").focus();
	}


	function adjNrfAmt()
	{
	var newrate = 0;
	newrate =  document.getElementById('NRFDISC').value;	

	if ( round(document.getElementById('NRFDISC').value) > round(document.getElementById("nrfee").value)  )
		{
		alert('New Resident Fee entered is GREATER than the base value');
		document.getElementById("NRFDISC").style.background = 'red';	
		document.getElementById("NRFDISC").focus();
		return;
		}

	else if (  (document.getElementById('NRFDISC').value != '')  && (document.getElementById("NRFDISC").value == 0 ))
		{
			var answer = confirm('Are you WAIVING the New Resident Fee?');
			if (answer)
			{	discamount = document.getElementById('nrfee').value - document.getElementById('NRFDISC').value;	
				document.getElementById("dferNRF").style.display='none';
				document.getElementById("deferredNRF").style.display='none';
				newrate = document.getElementById('NRFDISC').value;	
				document.getElementById('NewNRFee').value =  cent(round(newrate));  
				document.getElementById('discamount').value =  cent(round(discamount));  		
				document.MoveInForm.NRFDeferral.value = 0;
				document.getElementById("deferredNRF").style.display='none';	
		document.getElementById("paymnt1").style.display="none";  
		document.getElementById("paymnt2").style.display="none"; 
		document.getElementById("paymnt3").style.display="none";  
		document.getElementById("paymnt4").style.display="none"; 
		document.getElementById("paymnt5").style.display="none"; 
		document.getElementById("paymnt6").style.display="none"; 
		document.getElementById("paymnt7").style.display="none";  
		document.getElementById("paymnt8").style.display="none"; 
		document.getElementById("paymnt9").style.display="none"; 
		document.getElementById('payment1').value = 0;
		document.getElementById('rembalance1').value = 0;
		document.getElementById('dtpayment1').value = '';
		document.getElementById('payment2').value = 0;
		document.getElementById('rembalance2').value = 0;
		document.getElementById('dtpayment2').value = '';	
		document.getElementById('payment3').value = 0;
		document.getElementById('rembalance3').value = 0;
		document.getElementById('dtpayment3').value = '';	
		document.getElementById('payment4').value = 0;
		document.getElementById('rembalance4').value = 0;
		document.getElementById('dtpayment4').value = '';
		document.getElementById('payment5').value = 0;
		document.getElementById('rembalance5').value = 0;
		document.getElementById('dtpayment5').value = '';	
		document.getElementById('payment6').value = 0;
		document.getElementById('rembalance6').value = 0;
		document.getElementById('dtpayment6').value = '';	
		document.getElementById('payment7').value = 0;
		document.getElementById('rembalance7').value = 0;
		document.getElementById('dtpayment7').value = '';	
		document.getElementById('payment8').value = 0;
		document.getElementById('rembalance8').value = 0;
		document.getElementById('dtpayment8').value = '';	
		document.getElementById('payment9').value = 0;
		document.getElementById('rembalance9').value = 0;
		document.getElementById('dtpayment9').value = '';				
		document.getElementById('defEndDate').value = '';	
		document.getElementById('dispEndDate').value  = '';
	 
		document.getElementById('amtpaid').value =   0;

		document.getElementById('deferredAmount').value =   0 ;

		document.getElementById('defpymntamt').value =  0;	

		document.getElementById('mcalcrembalance').value = 	0;


				}
			else	{
				document.getElementById("NRFDISC").style.background = 'red';	
				document.getElementById("NRFDISC").focus();
					}
		}
	else
	{  
			document.getElementById('NewNRFee').value  =  cent(round(newrate));  
		//	document.getElementById("NRFDef").style.display='block';
	}		
}	
 	function nrfDefApp(NewRFApp)
	{
  	 	if (NewRFApp.value == 1) 
		{
	 	 document.getElementById("deferredNRF").style.display='block';	
			document.getElementById('NewNRFee').value  =  cent(round(document.getElementById('NRFDISC').value)); 
			document.getElementById("mAmount").focus(); 		 	
 	 	}
		else 
		{
	 	 document.getElementById("deferredNRF").style.display='none';		
	 	 document.getElementById("MonthstoPay").value = 0;	
		 document.getElementById("iChargeType_ID").value = '';	   
		 document.getElementById("deferredAmount").value = 0;
		 document.getElementById("defpymntamt").value = 0;
		 document.getElementById("defEndDate").value = '';
 	 	}
 	}
	function showfeepaid()
	{
			document.getElementById("resfeepaid").style.display='block';
			document.getElementById("selmonthstopay").style.display='block'; 
			document.getElementById("initpayment").style.display='block'; 		
	} 	
 function calcenddate()
{ 

 
  if (round(document.getElementById("mAmount").value) >=  round(document.getElementById("NewNRFee").value))
	{
  	alert('Amount Paid MUST BE LESS than the amount of the New Resident Fee!');
	document.getElementById("mAmount").style.background = 'white';	
	document.getElementById("mAmount").focus();
	return false;
	}
  else
{
  
 //	alert(document.getElementById('MonthstoPay').value);
 	document.getElementById("paymnt1").style.display="none";  
 	document.getElementById("paymnt2").style.display="none"; 
	document.getElementById("paymnt3").style.display="none";  
 	document.getElementById("paymnt4").style.display="none"; 
	document.getElementById("paymnt5").style.display="none"; 
 	document.getElementById("paymnt6").style.display="none"; 
	document.getElementById("paymnt7").style.display="none";  
 	document.getElementById("paymnt8").style.display="none"; 
	document.getElementById("paymnt9").style.display="none"; 
 	document.getElementById('payment1').value = 0;
 	document.getElementById('rembalance1').value = 0;
 	document.getElementById('dtpayment1').value = '';
 	document.getElementById('payment2').value = 0;
 	document.getElementById('rembalance2').value = 0;
 	document.getElementById('dtpayment2').value = '';	
 	document.getElementById('payment3').value = 0;
 	document.getElementById('rembalance3').value = 0;
 	document.getElementById('dtpayment3').value = '';	
 	document.getElementById('payment4').value = 0;
 	document.getElementById('rembalance4').value = 0;
 	document.getElementById('dtpayment4').value = '';
 	document.getElementById('payment5').value = 0;
 	document.getElementById('rembalance5').value = 0;
 	document.getElementById('dtpayment5').value = '';	
 	document.getElementById('payment6').value = 0;
 	document.getElementById('rembalance6').value = 0;
 	document.getElementById('dtpayment6').value = '';	
 	document.getElementById('payment7').value = 0;
 	document.getElementById('rembalance7').value = 0;
 	document.getElementById('dtpayment7').value = '';	
 	document.getElementById('payment8').value = 0;
 	document.getElementById('rembalance8').value = 0;
 	document.getElementById('dtpayment8').value = '';	
 	document.getElementById('payment9').value = 0;
 	document.getElementById('rembalance9').value = 0;
 	document.getElementById('dtpayment9').value = '';	
 
   var months = new Array(13);
   months[0]  = "January";
   months[1]  = "February";
   months[2]  = "March";
   months[3]  = "April";
   months[4]  = "May";
   months[5]  = "June";
   months[6]  = "July";
   months[7]  = "August";
   months[8]  = "September";
   months[9]  = "October";
   months[10] = "November";
   months[11] = "December";
	var endPayYear = 0;	  
	var endPayMonth = 0;	  
 	var nbrMonths =  document.getElementById('MonthstoPay');
	if (nbrMonths == '')
	 nbrMonths = 1; 

 	var strMonth  =  document.getElementById('ApplyToMonthA');
 
 	var strYear  =  document.getElementById('ApplyToYearA');	
  //	var y		  =  document.getElementById("ApplyToYearA").options;
    var MonToPay = nbrMonths.options[nbrMonths.selectedIndex].text;	

 //	var MonStart = strMonth.options[strMonth.selectedIndex].text;

 //	var YrStart = strYear.options[strYear.selectedIndex].text;

    endPayMonth =    Number(MonToPay)   +  Number(strMonth.value) -1;
 //   	alert( MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);
	if (document.getElementById('mAmount').value == ''){
		alert('Please enter the amount of the NRF that was paid');
 		document.getElementById("mAmount").focus();
		return false;
	}
  	var  endPayMonthL = endPayMonth.length;	
 	if (endPayMonth > 12)
 	 	{
			endPayMonth = endPayMonth - 12;
  			if (endPayMonth < 10)
				{endPayMonth = String('0') + String(endPayMonth);}
			endPayYear  = Number(strYear.value) + 1;
			 //  	alert('A ' + endPayMonthL + ' :: ' +  MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);	
    	}
  	else if (endPayMonth <= 12)
  		{
   			if (endPayMonth < 10)
  			{endPayMonth = String('0') + String(endPayMonth);}
			endPayYear  = Number(strYear.value);
 //  	alert('B '  + endPayMonthL   + ' :: ' +    MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);				
  		}
  	else
 	{endPayMonth =  String(endPayMonth);
  // 	alert('C ' + endPayMonthL   + ' :: ' +  MonToPay  + ' :: ' +  strYear.value  + ' :: ' + strMonth.value  + ' ' + endPayMonth + ' ' + endPayYear);		
	}

 	YrStart = String(strYear.value);
  	newPayDate = 	endPayMonth + YrStart;
   	document.getElementById('defEndDate').value = newPayDate;	
	document.getElementById('dispEndDate').value  = endPayMonth + '-' + endPayYear;
 
   	document.getElementById('amtpaid').value =    document.getElementById('mAmount').value;
 	amtdef = document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value;
	payamt =  (document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value;
    nbrmnth = nbrMonths.value;
	document.getElementById('deferredAmount').value =      cent(round(amtdef)) ;
    document.getElementById('defpymntamt').value =    	cent(round((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value)); 	
	document.getElementById('mcalcrembalance').value = 	(document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value;
	newbal = amtdef - ((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value);

var YrStartdisp = YrStart; 
var nbrofMonth = 0; 
var i=0;
for (i=0;i<=nbrmnth-1;i++)
{
//alert(nbrmnth + ' ' +  i );
	if  (i == 0)
	{
	document.getElementById("paymnt1").style.display="block";

	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1));	
// 	alert(i + " : " + payamt + " : " + newbal  + " : " +  Number(strMonth.value));
	document.getElementById('payment1').value = cent(round(payamt));
	document.getElementById('rembalance1').value = cent(round(newbal)) ;
	document.getElementById('dtpayment1').value = months[Number(strMonth.value)-1] + ', ' + YrStartdisp  ;
 	}
	else if  (i == 1)
	{
		document.getElementById("paymnt2").style.display="block";
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal + " : " +  months[nbrofMonth] + ', ' + YrStartdisp);
	document.getElementById('payment2').value = cent(round(payamt));
	document.getElementById('rembalance2').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = YrStart + 1;}	
	document.getElementById('dtpayment2').value = months[nbrofMonth] + ', ' + YrStartdisp ;
	}
	else if  (i == 2)
	{
	document.getElementById("paymnt3").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 // 		alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment3').value = cent(round(payamt));
	document.getElementById('rembalance3').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment3').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}	
	else if  (i == 3)
	{
	document.getElementById("paymnt4").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment4').value = cent(round(payamt));
	document.getElementById('rembalance4').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment4').value = months[nbrofMonth] + ', ' + YrStartdisp ;		
	}	
	else if  (i == 4)
	{
	document.getElementById("paymnt5").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 // 		alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment5').value = cent(round(payamt));
	document.getElementById('rembalance5').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment5').value = months[nbrofMonth] + ', ' + YrStartdisp ;		
	}
	else if  (i == 5)
	{
	document.getElementById("paymnt6").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment6').value = cent(round(payamt));
	document.getElementById('rembalance6').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment6').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}	
	else if  (i == 6)
	{
	document.getElementById("paymnt7").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment7').value = cent(round(payamt));
	document.getElementById('rembalance7').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment7').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}		
	else if  (i == 7)
	{
	document.getElementById("paymnt8").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
 //	 	alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment8').value = cent(round(payamt));
	document.getElementById('rembalance8').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment8').value = months[nbrofMonth] + ', ' + YrStartdisp ;
	}	
	else if  (i == 8)
	{
	document.getElementById("paymnt9").style.display="block";	
	newbal = amtdef - (((document.getElementById('NewNRFee').value - document.getElementById('amtpaid').value) / nbrMonths.value) * (i+1))	
// 	 alert(i + " : " + payamt + " : " + newbal);
	document.getElementById('payment9').value = cent(round(payamt));
	document.getElementById('rembalance9').value = cent(round(newbal));	
	nbrofMonth = Number(strMonth.value)-1 + i;
	if (nbrofMonth  > 11)
		{nbrofMonth = nbrofMonth - 12;
		YrStartdisp = Number(YrStart) + 1;}	
	document.getElementById('dtpayment9').value = months[nbrofMonth] + ', ' + YrStartdisp ;	
	}	
}
}
} // end function calcenddate 

 
</script>


 



 
<title> TIPS 4 Finalize Move In Pending Approval </title>

<cfinclude template="../../header.cfm">
<cfinclude template="../Shared/HouseHeader.cfm">
<body onLoad="initialize()">
	<h1 class="PageTitle"> TIPS 4 -  Revise NRF Discount </h1>
	<form name="ReviseMoveInDiscount"   method="post" action="ReviseMoveInDiscount.cfm" > 
		<cfoutput>
		<input type="hidden" name="iNRFMid" 	id="iNRFMid" 	value="#qryTenantPending.iNRFMid#" /> 
		<input type="hidden" name="itenant_id" 	id="itenant_id" value="#qryTenantPending.itenant_id#" />	
		<input type="hidden" name="nrfApprove"  id="nrfApprove" value="#SESSION.USERNAME#" />
		<input type="hidden" name="nrfee"       id="nrfee"      value="#GetNRF.NRF#" />
		</cfoutput>
		<cfoutput  query="qryTenantPending">
			<table>
				<tr >
					<td>Tenant Name: #cFirstName# #cLastName# </td>
				</tr>

				<tr style="background-color:##CCFFCC">
					<td>House New Resident Fee: #dollarformat(mBaseNRF)# </td>
					<td>Adjusted New Resident Fee:  #dollarformat(mAdjNRF)#</td>
				</tr>		
				<cfloop query="qryRecurringNRF">
<!--- 					<cfif ichargetype_id is 1740>
						<cfset defamount = mamount>
							<tr style="background-color:##CCFFCC">
								<td>Installment Terms: Amount Installment Payment: #dollarformat(abs(mamount))#</td>
								<input type="hidden" name="defermaRCNRF"  id="defermaRCNRF" value="#iRecurringCharge_id#" />
								<input type="hidden" name="defermaMID1740"    id="defermaMID"   value="#iInvoiceMaster_ID#" />
								<input type="hidden" name="defermaDID"    id="defermaDID"   value="#iInvoiceDetail_ID#" />		 		
								<input type="hidden" name="MPDID1740"   id="MPDID"  value="#iInvoiceDetail_ID#" />								 															
					<cfelseif  ichargetype_id is 1741>
						<cfset payamount = mamount>
						<td>Installment Terms: Monthly Payment: #dollarformat(abs(mamount))#</td>
						<input type="hidden" name="MPRCMP"  id="MPRCMP" value="#iRecurringCharge_id#" />
						<input type="hidden" name="MPMID"   id="MPMID"  value="#iInvoiceMaster_ID#" />
						<input type="hidden" name="MPDID1741"   id="MPDID"  value="#iInvoiceDetail_ID#" />		 		
						<input type="hidden" name="defermaDID1741"    id="defermaDID"   value="#iInvoiceDetail_ID#" />							 
						</tr>	 --->
					<cfif 	ichargetype_id is 69>		
						<input type="hidden" name="houseNRF" id="houseNRF" value="#iRecurringCharge_id#" />						
						<input type="hidden" name="NRFMID"   id="NRFMID"   value="#iInvoiceMaster_ID#" />
						<input type="hidden" name="NRFDID"   id="NRFDID"   value="#iInvoiceDetail_ID#" />		 		
						<input type="hidden" name="defermaDID69"    id="defermaDID"   value="#iInvoiceDetail_ID#" />	
						<input type="hidden" name="MPDID69"   id="MPDID"  value="#iInvoiceDetail_ID#" />	
						<input type="hidden" name="MPDID1741"   id="MPDID"  value="" />												 
					</cfif>
				</cfloop>
				<cfif Isdefined('defamount') and isDefined('payamount') and IsNumeric(payamount)>
					<cfset nbrmonths = abs(defamount)/(payamount)>
				<cfelse>
					<cfset nbrmonths = 0>				
				</cfif>
				<!--- <tr style="background-color:##CCFFCC">
					<td colspan="2">Deferred Terms: Number of payments: #round(nbrmonths)#</td>
				</tr> --->
				<tr>	
					<td  colspan="5">
						<div id="NRFDscAmount"  style="text-align:justify; font-size:larger; font-weight: bold; color:red;"> 
							&nbsp; Enter Revised New Resident Fee Amount: $  <input  type="text" id="NRFDISC" name="NRFDISC" value="#numberformat(mBaseNRF,'999999.99')#"   onchange="adjNrfAmt()"  onBlur="this.value=cent(round(this.value));"/> <br />
						</div>
					</td>
				</tr> 	
				<!--- <tr  id="dferNRF" style="display:block">
					<td  style="Font-weight: bold;" colspan="5" >New Resident Fee deferral is temporarily suspended</td>
				</tr>				
  				<tr  id="dferNRF" style="display:block">
					<td  style="Font-weight: bold;" colspan="5" >Is the New Resident Fee being deferred?	
						Yes <input name="NRFDeferral" type="radio" value="1" onClick="document.ReviseMoveInDiscount.NRFDeferral.value=this.value;nrfDefApp(this);">  
						No	<input name="NRFDeferral" type="radio" value="0" onClick="document.ReviseMoveInDiscount.NRFDeferral.value=this.value;nrfDefApp(this);">
					</td>
				</tr>  --->
				<tr>
					<td colspan="5" id="deferredNRF" style="display:none" >
					<table width="100%">
						<tr>
							<td colspan="4">Solomon Key: #qryTenantPending.cSolomonkey#</td>
						</tr>		
						<TR id="resfeepaid" > 
							<td  style="text-align:center">New Resident Fee:<br />$<input type="text" name="NewNRFee" id="NewNRFee" value=""   /></td>
						</TR> 
							<!--- <TD colspan="2" style="text-align:center; font-weight: bold; color:red;">
							<input type="hidden" name="amtpaid" id="amtpaid" value="" />
									Enter the amount of the<br /> New Resident Fee that was Paid<BR> 
										$<INPUT TYPE = "text" NAME="mAmount" id="mAmount" SIZE="10" STYLE="text-align:right;" VALUE="0"  onKeyUp="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value)); calcenddate();">  
										<INPUT TYPE="hidden" NAME="iQuantity"  VALUE="1" >
										<INPUT TYPE="hidden" NAME="iChargeType_ID" VALUE="1740">
										<INPUT TYPE="Hidden" NAME="cDescription" VALUE="New Resident Fee Deferred" MAXLENGTH="15">
										<INPUT TYPE="Hidden" NAME="mcalcrembalance" VALUE="calculated remaining balance" MAXLENGTH="15">
							</TD> 
							  <TD style="text-align:center; font-weight: bold; color:red;"  >
								Select Number of Payments<br /> Remaining:<br/>
									<SELECT NAME="MonthstoPay"  id="MonthstoPay" onChange="calcenddate()">
										<CFLOOP INDEX="i" FROM="1" TO="9" STEP="1">
											 <OPTION VALUE="#i#"  >#i#</OPTION>
										</CFLOOP>
									</SELECT>
							</TD> 				

						  <TR style="background-color: ##FFFF99" id="selmonthstopay"    >   
							<td colspan="2" nowrap="nowrap"  STYLE="text-align: center;">Installment Payment Start Date:<br/> 
							<input type="text" name="thistipsdate" value="#dateformat(session.tipsmonth, 'mm')#-#dateformat(session.tipsmonth, 'yyyy')#"  size="7"/>
									<cfset applytodate = dateformat(#session.tipsmonth#, 'yyyymm')>
									<input type="hidden" name="ApplyToYear"  id="ApplyToYearA"  value="#left(applytodate, 4)#"  size="4"/>
									<input type="hidden" name="ApplyToMonth" id="ApplyToMonthA" value="#right(applytodate, 2)#" size="2"/> 
							</td>
			 
							<td colspan="2" style="text-align:center">Installment Payment End Date:<br /> 
								<input type="hidden" name="defEndDate" id="defEndDate" value=""  size="10" readonly="Yes" />
								<input type="text" name="dispEndDate" id="dispEndDate" value=""  size="7" readonly="Yes" />
							</td>	
						</TR> 	 
		
						 <tr id="initpayment"    >
							<td colspan="2"  style="text-align:center">Amount<br /> Deferred:<br /> $<input type="text" name="deferredAmount"  id="deferredAmount" value=""  readonly="Yes" size="7"></td>
							<td colspan="2"  style="text-align:center">NRF Installment<br /> Payment Amount:<br /> $<input type="text" name="defpymntamt"  id="defpymntamt" value=""  readonly="Yes" size="7"></td>
						</tr> 			
						  <tr>
							<td colspan="4" style="text-align:center; background-color: ##FFFF99" >Payment Schedule</td>
						</tr>
						<tr  style="background-color: ##FFFF99" >
							<td style="text-align:center">Payment</td>
							<td style="text-align:center">Payment Amount</td>
							<td style="text-align:center">Remaining Balance</td>
							<td style="text-align:center">Payment Date</td>
						</tr>
		
						  <cfloop from="1"  to="9" index="i">  
						<tr id="paymnt#i#" style="display:none">
							<td style="text-align:center">#i#</td>
							<td style="text-align:right"><input type="text"  id="payment#i#"    value="" name="payment#i#"/></td>
							<td style="text-align:right"><input type="text"  id="rembalance#i#" value="" name="rembalance#i#"/></td>	
							<td style="text-align:center"><input type="text" id="dtpayment#i#"  name="dtpayment#i#" value="" /></td>
						</tr>
						 </cfloop> ---> 
													
						</table>
					</td>
				</TR>	
				<tr  style="background-color:##FFC100">
					<td  colspan="2" style="text-align:center; color:red" >Apply these NRF Changes<br>
				 		<input type="submit" name="Submit"   value="Submit Changes" />  
						<!--- <input type="button" name="Revise" value="Revise Adjusted NRF" onClick="self.location.href='ReviseMoveInDiscount.cfm?iTenant_ID=#qryTenantPending.iTenant_ID#&MID=#iNRFMid#'"> </td> --->			
					</td>
				</tr>
			</table>
		</cfoutput>
	</form>
 </body>

<cfinclude template="../../footer.cfm">