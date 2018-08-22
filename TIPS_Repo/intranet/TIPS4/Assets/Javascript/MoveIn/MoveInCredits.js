
function SelCommFee(){
	var mylist=document.getElementById("CommFeePaymentSel");
	var monthSel =mylist.options[mylist.selectedIndex].text;
	//alert(monthSel);
	document.getElementById('CommFeePayment') = monthSel.value;
}

function calcenddate(){ 
 	var nbrMonths =  document.getElementById('MonthstoPay');
 	var strMonth  =  document.getElementById('ApplyToMonthA');
 	var strYear  =  document.getElementById('ApplyToYearA');	 
	var MonToPay = nbrMonths.options[nbrMonths.selectedIndex].text;	
    newPayMonth =    Number(MonToPay)   +  Number(strMonth.value) -1;
 	if (newPayMonth > 12)
 	 	{
  			newPayMonth = newPayMonth - 12;
  			strYear.value = Number(strYear.value) + 1;
  	}
 	if (newPayMonth < 10)
  		{
  			newPayMonth = String('0') + String(newPayMonth);
  		}
  	else
 	{newPayMonth =  String(newPayMonth);}
 	YrStart = String(strYear.value);
  	newPayDate = 	newPayMonth + YrStart
   document.getElementById('defEndDate').value = newPayDate;	
} 

function showRtnNote(){
	alert('WARNING: Returning to the Move-In page you will reset Community Fee changes.');
}

function validatesel() { 
	var thissel = document.getElementById("iCharge_ID").selectedIndex;
	var y = document.getElementById("iCharge_ID").options.text;
	if (thissel == 0){
		alert('No Charge/Credit selection was made');
	 	return false;
	}
}

// update the daily rate display for r&b
function rateCheck(cnt,id){
	var tCount = document.getElementById("tCount").value;
	var nVal = document.getElementById("NewmAmount"+id+cnt).value;
	var nQty = document.getElementById("hQty"+id+cnt).value;
	var newValue = parseFloat(nVal * nQty);
	var newValueFormated = '$'+newValue.toLocaleString('en');
	document.getElementById("hVal"+id+cnt).value = newValueFormated;
	
	for(i=1;i<=tCount;i++){	
		if(i != cnt){
			if(typeof document.getElementById("hVal"+id+i) !== "undefined"  && typeof document.getElementById("hQty"+id+i) !== "undefined"){
				if(document.getElementById("hQty"+id+i)){
					document.getElementById("NewmAmount"+id+i).value = document.getElementById("NewmAmount"+id+cnt).value;
					var tVal = document.getElementById("NewmAmount"+id+cnt).value;
					var tQty = document.getElementById("hQty"+id+i).value;
					var tValue = parseFloat(tVal * tQty);
					var tValueFormated = '$'+tValue.toLocaleString('en');				
					document.getElementById("hVal"+id+i).value = tValueFormated;
				}
			}
		}
	}
}

// updated daily rate display for community fee, etc..
function rateCheckComFee(cnt, id){
	var nVal = document.getElementById("NewResidentFeeAmt").value;	
	var nQty = document.getElementById("hQty"+id+cnt).value;	
	var newValue = parseFloat(nVal * nQty);
	var newValueFormated = '$'+newValue.toLocaleString('en');
	document.getElementById("hVal"+id+cnt).value = newValueFormated;
}

function showHelp(){
	window.open("TIPS-Move-In-Process.pdf");
}

//this function will check to see if the value is 0, 0.00 or blank which is not allowed.
function checkForZero(amt,cnt,bType,isSecond){		

	// this is for AL billing type
	if(bType != 'M'){		
		if(amt == 'a'){
		 var nAmt=document.getElementById('NewmAmount'+cnt).value;
		}
		else{
		var nAmt = amt;
		}
	
		
		if(nAmt == '' || nAmt < 0){			
			alert("Amount can not be blank or a negative number.");
			document.getElementById("subBtn"+cnt).disabled=true;			
			return false;							
		}
		document.getElementById('subBtn'+cnt).disabled=false;
		return true;
	}
	// this is for memory care billing type
	else{
		nCnt = cnt;
		// if the resident is a second resident then we allow 0.00 dollars 
		if(isSecond == 1){

			if(amt == '0.00' || amt == '' || amt <= 0 ){
				alert("Amount can not be blank, a negative number , or 0.00 ");
				document.getElementById("subBtn"+nCnt).disabled=true;			
				return false;
			}
		}
		else{
			if(amt == '' || amt < 0 ){
				alert("Amount can not be blank or a negative number. ");
				document.getElementById("subBtn"+nCnt).disabled=true;			
				return false;
			}

		}
		document.getElementById("subBtn"+nCnt).disabled=false;	
		return true;
	}
}

// prorate the current month and update future months
/* Because of time constraints I could not complete merging this function with the daily prorate amount and respite.
   In the future this function needs to be modified so that the input id values are the same as AL.
 
*/
function proration(cnt){
	var totalcount = document.getElementById("totalCount").value;
	var monthlyamount = document.getElementById("monthlyamount"+cnt).value;	
	var totaldays = document.getElementById("daysinmonth1").value;
	var rate= (parseFloat(monthlyamount.replace(/,/g, '')) /totaldays);
	var daystocharge = document.getElementById("daytocharge1").value;
	var proratedrate = rate*daystocharge;	
	for(i=1;i<=totalcount;i++){
		if(i == 1){
			document.getElementById("NewmAmount"+i).value= Math.round(proratedrate * 100) / 100;
			document.getElementById("monthlyamount"+i).value = monthlyamount;
			//populate the hidden form fields 
			document.getElementById("hamount"+i).value = Math.round(proratedrate * 100) / 100;		
		}
		else{
			document.getElementById("monthlyamount"+i).value = monthlyamount;
			document.getElementById("NewmAmount"+i).value=monthlyamount;
			//populate the hidden form fields
			document.getElementById("hamount"+i).value = monthlyamount;		
		}
	}
}

// populate and submit the hidden form (MC Only)
function populateHiddenForm(cnt){	
    var frm = document.getElementById("moveincreditshidden");
    frm.submit();
}

// prorate the current month and update future months for respite
function prorationRespit(cnt){
	var totalCount = document.getElementById("totalCount").value;
	var monthlyamount = document.getElementById("monthlyamount"+cnt).value;	
	var totaldays = 30;
	var rate= (parseFloat(monthlyamount.replace(/,/g, '')) /totaldays);
	var daystocharge = document.getElementById("daytocharge1").value;
	var proratedrate = rate*daystocharge;	
	for(i=1;i<=totalCount;i++){
		if(i == 1){
			document.getElementById("NewmAmount"+i).value= Math.round(proratedrate * 100) / 100;
			document.getElementById("monthlyamount"+i).value = monthlyamount;
			//populate the hidden form fields 
			document.getElementById("hamount"+i).value = Math.round(proratedrate * 100) / 100;		
		}
		else{
			document.getElementById("monthlyamount"+i).value = monthlyamount;
			document.getElementById("NewmAmount"+i).value=monthlyamount;
			//populate the hidden form fields
			document.getElementById("hamount"+i).value = monthlyamount;		
		}
	}
}


