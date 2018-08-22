
function hardhaltvalidation(formCheck) {
	if(formCheck.bondval.value==1){
		var tenantname = RelocateTenant.iTenant_ID.options[RelocateTenant.iTenant_ID.selectedIndex].text;
 		if (tenantname == 'Choose Resident'){
 			alert("Please select a resident.")
 			return false;
 		}

		var recert;
		for(j=0;j<RelocateTenant.cBondTenantEligibleAfterRelocate.length;j++){
			if(RelocateTenant.cBondTenantEligibleAfterRelocate[j].checked){
				var recert = true;
				if(RelocateTenant.cBondTenantEligibleAfterRelocate[j].value == 1){
					var recert_value = true;
				}
				else{
					var recert_value = false;
				}
			}
		}

		if(!recert){
			alert("Please indicate if the resident certified for bond status.");
			return false;
		}
	 	
		if (RelocateTenant.txtBondReCertDate.value == '' || RelocateTenant.txtBondReCertDate.value == '00/00/0000'){
			alert("Please enter a re-certification date that is valid, and not in the future. \n mm/dd/yyyy.");
			return false;
		}

		if(ValidBondDate(RelocateTenant.txtBondReCertDate.value) == false){
			RelocateTenant.txtBondReCertDate.focus();
			alert("Please enter a re-certification date that is valid, and not in the future.");
			return false;
		}
		
		var bondroom = RelocateTenant.iAptAddress_ID.options[RelocateTenant.iAptAddress_ID.selectedIndex].text;
		var bRoomisBond = false;
		var bRoomisBondIncluded = false;
		if((bondroom.indexOf("Bond")) > 0){
			bRoomisBond = true;
		}
		if((bondroom.indexOf("Included")) > 0){
			bRoomisBondIncluded = true;
		}
		if(recert_value == false && bRoomisBond == true){
			alert("Tenant is marked as not being eligible as bond.\n \nPlease select a room that is not bond designated.");
			return false;
		}
		else if(recert_value == true && bRoomisBondIncluded == false){
			alert("Tenant is marked as being eligible as bond. \n \nThe room selected is not bond applicable. \n \nPlease select a bond included room.")
			return false;
		}

		var alertcount;
		if(RelocateTenant.Percent < 20){
			if(alertcount!=1){
				alertcount==1;
				alert("Bond Apartment count is under the required amount. \n \nPlease select a non-bond room to make it bond if possible.");
				return false;
			}
		}
	 return true;
	}
}  // end of function

function ValidBondDate(dtbond){
	if(isDate(dtbond)==false){
		return false;
	}
	return true;
}

//also seen on MoveInForm
function isDate(dtStr){
	var dtCh= "/";
	var minYear=2009;
	var year=new Date();
	var now=new Date();
	var maxYear=year.getYear();
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
		return false;
	}
	if (strMonth.length<1 || month<1 || month>12){
		//alert("Please enter a valid month")
		return false;
	}

	if (strDay.length<1 || day<1 || day>31 ||(month==02 && day>daysInFebruary(year)) || day > daysInMonth[month]){// ||
		//alert("Please enter a valid day.")
		return false;
	}
	if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
		//alert("Please enter a valid 4 digit year. \n \n(ie "+maxYear+")")
		return false;
	}
	if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
		//alert("Please enter a valid date")
		return false;
	}
	if(strDay.length<2){strDay = 0 + strDay}
	if(strMonth.length<2){strMonth = 0 + strMonth}
	var RearrangedInput=strYear+strMonth+strDay
	RearrangedInput = parseFloat(RearrangedInput)
	var TodayDay = parseInt(now.getDate());
	TodayDay = TodayDay +'';
	if (TodayDay.length<2){TodayDay = 0 + TodayDay;}

	var TodayMonth = parseInt(now.getMonth());
	TodayMonth = (TodayMonth + 1)+'';
	if (TodayMonth.length<2){TodayMonth = 0 + TodayMonth;}

	var TodayYear = now.getFullYear();
	var TodayRearranged = (TodayYear + ''+ TodayMonth +''+ TodayDay)
	TodayRearranged = parseFloat(TodayRearranged);
	if (RearrangedInput>TodayRearranged){
		//alert("Please no future dates.")
		return false;
	}
return true;
}

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
function redirect() { 
	window.location = "../mainmenu.cfm"; 
}

function moveoutinvoicecheck(obj) {
	var tidList = document.getElementById("tenantidlist").value;
	var tmoveoutcnt = document.getElementById("tenantmoveoutcnt").value;
	tenantids = new Array(tidList);
	moveoutcountpertenant = new Array(tmoveoutcnt);
	for (i=0;i<=(tenantids.length-1);i++){
		if ((obj.value == tenantids[i]) && (moveoutcountpertenant[i] > 0)){
			document.forms[0].save.style.visibility='hidden';
			alert('A move out invoice for this resident has been found. \
					\rYou may not relocate residents that are in the process of moving out. \
					\rPlease go to the move out process and indicate that this resident is not moving out before relocating this resident.');
			break;
		}
		else {
			document.forms[0].save.style.visibility='visible';
		}
	}
}




function secondarycheck ()	{
	s = document.all['recurringchange'].innerHTML;
	sa = "Change to Basic Service Fee - Second";
	sb = "Change to Second";
	sc="Change to Basic Service Fee - MC Second";
	sd="Change to MC Second";
	
	var a = document.getElementById("Ten1");
	var b = a.options[a.selectedIndex].text;	
	var fname = b.split(',').pop().split('(').shift();	
	var lname = b.substr(0, b.indexOf(','));	
	var acct= b.match(/\d/g);
	var acct = acct.join("");
	var fullname = fname+lname+' '+'('+ acct+')'	
	if(s.indexOf(sa) > -1) {
		alert(fullname +' will be second occupant and occupancy will be zero');
	}
	if(s.indexOf(sb) > -1) {
		alert(fullname +' will be second occupant and occupancy will be zero');
	}
	if(s.indexOf(sc) > -1) {
		alert(fullname +' will be second occupant and occupancy will be zero');
	}
	if(s.indexOf(sd) > -1) {
	alert(fullname +' will be second occupant and occupancy will be zero');
	}
	alert (document.getelementbyID('Year').value);
}

function checkyear (){
	var x = document.forms[0].Year.value;
	if (x==""){
		alert('Select Year in effective date');
		return false;
	}
 	var oldApt=(document.getElementById("icurrentroomID").value);
 	var newApt=(document.getElementById("iAptAddress_ID").value);
	  if (oldApt == newApt){
   		alert("The \'Move To\' room number cannot be the same as the Current Room Number. Please select a different room.");
  		 return false;
   	}
   
	 if(window.hasBundledPricing == 1){
   		return checkBundled();
  	}
   	
}

function checkIfStudio(apt){
	var arrStudioList = document.getElementById("studiolistid").value;
	for(i=0;i<=arrStudioList.length;i++){
		if(apt == arrStudioList[i]){
			return true;
			break;
		}
	}
	return false;
}


function checkBundled(){
	currentlyInstudio= window.bIsStudio;
	goingInToStudio = checkIfStudio(window.goingtoApt);
	if(currentlyInstudio == "No" && goingInToStudio == true){
		alert("Bundled pricing is available for this apartment type.");
		return true;
	}
	if(currentlyInstudio == "Yes" && goingInToStudio == false){
		var n = confirm("Bundled pricing WILL NOT be available for this apartment type.");
		if(n == true){
			document.getElementById("hasBundledPricing").value='';
			return true;
		}
		else{
			return false;
		}
	}

}
