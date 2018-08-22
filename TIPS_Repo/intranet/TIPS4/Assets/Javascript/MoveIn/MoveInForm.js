function primarypayor(obj){
	if (document.getElementById("ContactbIsPayor").checked){
		alert('This will remove the Resident as the Payor');
		document.getElementById("TenantbIsPayer").checked = false;
	}
}

function residentPayor(obj){
	if (document.getElementById("TenantbIsPayer").checked){
		alert('This will remove the Contact as the Payor');
		document.getElementById("ContactbIsPayor").checked = false;
	}
}

function validatePayor(){
	if((document.getElementById("ContactbIsPayor").checked == false) &&  (document.getElementById("TenantbIsPayer").checked  == false) ){
	 	MoveInForm.ContactbIsPayor.focus();
	 	alert("Select either tenant or contact as the Payor");
		 return false;					
	}		
}

function primarypayor(obj){
	if (document.getElementById("ContactbIsPayor").checked){
		alert('This will remove the Resident as the Payor');
		document.getElementById("TenantbIsPayer").checked = false;
	}
}	

function residentPayor(obj){
	if (document.getElementById("TenantbIsPayer").checked){
		alert('This will remove the Contact as the Payor');
		document.getElementById("ContactbIsPayor").checked = false;
	}
}

function validatePayor(){
	if((document.getElementById("ContactbIsPayor").checked == false) &&  (document.getElementById("TenantbIsPayer").checked  == false) ){
	 	MoveInForm.ContactbIsPayor.focus();
	 	alert("Select either tenant or contact as the Payor");
		 return false;					
	}		
}

function bondValidate(){
 	if(MoveInForm.bondval.value==1){
		if(MoveInForm.dtBondCertificationMailed.value == '00/00/0000'){
			MoveInForm.dtBondCertificationMailed.focus();
			alert("Please enter the date the income certification was mailed to the Corporate Office.  "
			+ MoveInForm.bondval.value);
  			return false;
  		}
 		else if (MoveInForm.dtBondCertificationMailed.value == ''){
  			MoveInForm.dtBondCertificationMailed.focus();
  			alert("Please enter the date the income certification was mailed to the Corporate Office.");
  			return false;
  		}
 		else if (bisDate(MoveInForm.dtBondCertificationMailed.value) == false){
  			MoveInForm.dtBondCertificationMailed.focus();
  			alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n"
  			+ MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
  			return false;
  		}
		for(j=0;j<MoveInForm.cBondQualifying.length;j++){
			if(MoveInForm.cBondQualifying[j].checked){
				var bondq = true;
				if(MoveInForm.cBondQualifying[j].value == 1){
  					var bondq_value = true;
  				}
  				else{
  					var bondq_value = false;
  				}
  			}
  		}
                                                                                                                                             //                  						return false;} 
  	}	
}

function checkbond(){ 
	if(MoveInForm.bondval.value==1){
		for(j=0;j<MoveInForm.cBondQualifying.length;j++){
			if(MoveInForm.cBondQualifying[j].checked)
			{var bondq = true;
				if(MoveInForm.cBondQualifying[j].value == 1)
				{
					var bondq_value = true;
				}
			else{
					var bondq_value = false;
				}
			}
		}
		if(!bondq){
			alert("Please select Yes or No if the resident is bond qualified.");
			return false;
		}
		if ((MoveInForm.dtBondCertificationMailed.value == '00/00/0000') 
			&& (bondq_value)){
				MoveInForm.dtBondCertificationMailed.focus();
					alert("Please enter the date the income certification was mailed to the Corporate Office." + bondq_value);
					return false;
		}
		else if ((MoveInForm.dtBondCertificationMailed.value == '') && (bondq_value)){
				MoveInForm.dtBondCertificationMailed.focus();
					alert("Please enter the date the income certification was mailed to the Corporate Office.");
					return false;
		}
		else if ((bisDate(MoveInForm.dtBondCertificationMailed.value) == false) 
				&& (bondq_value)){
				MoveInForm.dtBondCertificationMailed.focus();
					alert("Please enter a valid date in which the income certification was mailed to the Corporate Office. \n \n" 
					+ MoveInForm.dtBondCertificationMailed.value+"  is not a valid date.");
					return false;
		}
	}
}

/// this is called from the residency drop down menuu display additional fields when a house has medicaid 
function typMedicaid(MoveInForm){	
	if (document.getElementById("iResidencyType_ID").value == 2) {
		document.getElementById("typMedicaid").style.display='block';
		document.getElementById("typMedicaid1").style.display='block';
		document.getElementById("typMedicaid2").style.display='block';
		document.getElementById("typMedicaid3").style.display='block';
		document.getElementById("typMedicaid4").style.display='block';
		document.getElementById("typMedicaid5").style.display='block';
		document.getElementById("typMedicaid6").style.display='block';
		document.getElementById("typMedicaid7").style.display='block';
		document.getElementById("typMedicaid8").style.display='block';	
		document.getElementById("typMedicaid9").style.display='block';																							
	}
	else { 
		document.getElementById("typMedicaid").style.display='none';
		document.getElementById("typMedicaid1").style.display='none';
		document.getElementById("typMedicaid2").style.display='none';
		document.getElementById("typMedicaid3").style.display='none';
		document.getElementById("typMedicaid4").style.display='none';
		document.getElementById("typMedicaid5").style.display='none';
		document.getElementById("typMedicaid6").style.display='none';
		document.getElementById("typMedicaid7").style.display='none';
		document.getElementById("typMedicaid8").style.display='none';	
		document.getElementById("typMedicaid9").style.display='none';					 
	}
}

function hardhaltvalidation() {	
	var productLineDropDown = document.getElementById('iproductline_id');
	var residencyDropDown = document.getElementById('iResidencyTypeID'); //iResidencyTypeID

	if (document.getElementById("iResidencyType_ID").value == 2) {
		if (document.getElementById("mMedicaidCopay").value == '') {
			MoveInForm.mMedicaidCopay.focus();
			alert('Please enter the Authorized Copay Amount for this Medicaid Resident');
			return false;
		}	
		if (document.getElementById("cMedicaidAuthorizationNbr").value == ''){
			MoveInForm.cMedicaidAuthorizationNbr.focus();
			alert('Please enter the Medicaid ID for this Medicaid Resident');
			return false;
		}	
	}
	
	if (document.getElementById("iproductline_id").value=='') {
		productLineDropDown.focus();
		alert("Please select a Product Line");
		return false;
	}
	
	if(residencyDropDown.selectedIndex == "") {
		residencyDropDown.focus();
		alert("Please select a Residency Type");
		return false;
	}	
 
	if  ( MoveInForm.thisHouseID.value == 233 || MoveInForm.thisHouseID.value == 229 || MoveInForm.thisHouseID.value == 226) {
	 	if (MoveInForm.FeeType.options[MoveInForm.FeeType.selectedIndex].value == 	'')	{
	 		alert("Select if the Fee Type is Community Fee or Security Deposit"); 		
  	 		return false;
	 	}
	}
	if  ( MoveInForm.thisHouseID.value == 212 ){
	 	if (MoveInForm.FeeType.options[MoveInForm.FeeType.selectedIndex].value == 	'')	{
	 		alert("Select if a Security Deposit is to be charged"); 		
  	 		return false;
	 	}
	}	
	if(MoveInForm.iAptAddress_ID.options[MoveInForm.iAptAddress_ID.selectedIndex].value == ""){
 		MoveInForm.iAptAddress_ID.focus();
 		alert("Please select an Apartment Number");
 		return false;
 	}	
 	if(document.getElementById("cSSN").value.length != 11){
 		MoveInForm.cSSN.focus();
 		alert("Please Enter the SSN of the resident in a 123-45-6789 format.");
 		return false;
 	}
 	if(MoveInForm.cSex.options[MoveInForm.cSex.selectedIndex].value == ""){
 		MoveInForm.cSex.focus();
 		alert("Please Select the Residents Sex  - M/F.");
 		return false;
 	}		
 	if(bisDate(MoveInForm.dbirthdate.value)== false){
 		MoveInForm.dbirthdate.focus();
 		alert("Please enter Birth Date in the MM/DD/YYYY");
 		return false;
 	}
	if(MoveInForm.cPreviousAddressLine1.value==""){
 		MoveInForm.cPreviousAddressLine1.focus();
 		alert("Please enter the previous address of the resident");
 		return false;
 	}
	if(MoveInForm.cPreviousCity.value==""){
 		MoveInForm.cPreviousCity.focus();
 		alert("Please enter the previous City of the resident");
 		return false;
 	}
  	if(MoveInForm.cPreviouszipCode.value.length < 5 ){
 		MoveInForm.cPreviouszipCode.focus();
 		alert("Please enter the previous City Zip (Postal) Code of the resident or check for proper format.");
 		return false;			
 	}
	if (validatePMO() == false){
		return false;
	}
	//The tenant Executor	
	var executor = false;
	for(i=0;i<MoveInForm.hasExecutor.length;i++){
 		if(MoveInForm.hasExecutor[i].checked) {
 			executor = true;
 		}
 	}
	
 	if(MoveInForm.ContactbIsPayor.checked == true){
 		if(MoveInForm.cFirstName.value==""){
 			alert("First Name for the Contact");
 			MoveInForm.cFirstName.focus();
 			return false;
 		}
 		if(MoveInForm.cLastName.value==""){
 			alert("Last Name for the Contact");
 			MoveInForm.cLastName.focus();
 			return false;
 		}
		 if(MoveInForm.cAddressLine1.value==""){
 			alert("Billing address for the Contact");
 			MoveInForm.cAddressLine1.focus();
 			return false;
 		}
 		if(MoveInForm.cCity.value == ""){
 			MoveInForm.cCity.focus();
 			alert("Please enter City for Contact address");
 			return false;
 		}
 		if(MoveInForm.cStateCode.value == ""){
 			MoveInForm.cStateCode.focus();
 			alert("Please select State for Contact address");
 			return false;
 		} 
 		if(MoveInForm.cZipCode.value.length < 5 ){
 			MoveInForm.cZipCode.focus();
 			alert("Please enter Zip (Postal) Code for Contact address or check Zip Code for porper format");
 			return false;					
 		}
		if(MoveInForm.areacode1.value.length != 3 || MoveInForm.prefix1.value.length != 3 || MoveInForm.number1.value.length != 4){
 			MoveInForm.areacode1.focus();
 			alert("Please enter a Home Phone number.");
 			return false;			
 		}
 		if(MoveInForm.cEmail.value !=""){
 			var str=MoveInForm.cEmail.value
 			var filter=/^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i
 			if (filter.test(str)){}else{
 				alert("Please input a valid email address for the contact.")
 				return false;
 			}
 		}
 	}
 	var tmp1 = MoveInForm.areacode1.value; 
 	var tmp1 = tmp1.replace(' ','');
 	if(tmp1.length < 3  && tmp1.length > 0)	{
 		alert('Home Phone Number MUST be Format: 123-456-7890');
 		return false;
 	}
 	var tmp2 = MoveInForm.prefix1.value; 
 	var tmp2 = tmp2.replace(' ','');
 	if( tmp2.length < 3  && tmp2.length > 0 ){
 		alert('Home Phone Number MUST be Format: 123-456-7890 ');
 		return false;
 	}
 	var tmp3 = MoveInForm.number1.value; 
 	var tmp3 = tmp3.replace(' ','');
 	if(  tmp3.length < 4  && tmp3.length > 0){
 		alert('Home Phone Number MUST be Format: 123-456-7890');
 		return false;
 	}		
	var tmp1 = MoveInForm.areacode2.value; 
 	var tmp1 = tmp1.replace(' ','');
 	if(tmp1.length < 3  && tmp1.length > 0){
 		alert('Cell Phone Number MUST be Format: 123-456-7890');
 		return false;
 	}
 	var tmp2 = MoveInForm.prefix2.value; 
 	var tmp2 = tmp2.replace(' ','');
 	if( tmp2.length < 3  && tmp2.length > 0 ){
 		alert('Cell Phone Number MUST be Format: 123-456-7890 ');
 		return false;
 	}
 	var tmp3 = MoveInForm.number2.value; 
 	var tmp3 = tmp3.replace(' ','');
 	if( tmp3.length < 4  && tmp3.length > 0){
 		alert('Cell Phone Number MUST be Format: 123-456-7890');
 		return false;
 	}			
	bondValidate();										
	validatePayor();	
	if ( MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value  == '' || MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value  == ''){ 
	 	alert('Enter a valid Financial Possession Date');
	 	return false;
	}
	if ( MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value  == ''  || MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value  == ''){ 
		alert('Enter a valid Physical Move In Date');
	 	return false;
	}
	var FinPossessionMonth =  MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value;
	if (FinPossessionMonth.length  == 1){FinPossessionMonth = '0' + FinPossessionMonth;	}
	var FinPossessionDay =  MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value;
	if  (FinPossessionDay.length == 1){FinPossessionDay = '0' + FinPossessionDay;	}	 
	var MoveInMonth =  MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value;
	if (MoveInMonth.length  == 1){MoveInMonth = '0' + MoveInMonth;	}
	var MoveInDay =  MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
	if  (MoveInDay.length == 1){MoveInDay = '0' + MoveInDay;}	
	var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  + FinPossessionMonth + FinPossessionDay;
	var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  +  MoveInMonth + MoveInDay;
  	if (MoveInDt < FinPossessionDt){
  		alert('Physical Move In Date must be Same or Greater than Financial Possession Date');
  		MoveInForm.MoveInDay.focus();
  		return false;
	}
	return true;
}

function secondoccupant(){
	var str = document.getElementById("OccupiedListtest").value;
	var n = str.search(MoveInForm.iAptAddress_ID.value);
	var a = document.getElementById("ResidentName").value;
	var b = document.getElementById("cSolomonKey").value;	
	if(n > 0){
		var test = confirm (a + '('+ b +')' + 'will be second occupant and occupancy will be zero. Do you want to continue?');
		if (test== true){
			return true;  
	    }
		else { 
			return false;
		}
	}
}

function validatePMO(){
	var PMODate = document.getElementById("dtmoveoutprojecteddate").value;
	PMODate = new Date(PMODate);
	var AllowDate = document.getElementById("RentMonth").value + '/'+ 
	document.getElementById("RentDay").value + '/' + document.getElementById("RentYear").value;
	var AllowDate = new Date(AllowDate);
	var MoveinDate = new Date(AllowDate);
	AllowDate.setMonth(AllowDate.getMonth() + 3);
	var ErrorFlag = 'No';
	if (document.getElementById("iResidencyType_ID").value== 3){
		if(document.getElementById("dtmoveoutprojecteddate").value == ''){
			ErrorFlag = 'ShowError';
		}		
		if(PMODate > AllowDate){
			ErrorFlag = 'ShowError';
		}
	}	
	if(MoveinDate > PMODate){
		ErrorFlag = 'ShowError';
	}	
	if (ErrorFlag == 'ShowError'){
		document.getElementById("dtmoveoutprojecteddate").focus();
		if(typeof(vWinCal) !== 'undefined'){
			vWinCal.focus();
		}
		alert('Respites REQUIRE Projected Physical Move Out Date \n PMO date can\'t be in the past, or more then 3 months in the future');	
		return false;	
	}
	else{
		document.getElementById("Mes").style.display='none';
		return true;
	}
}

function verifyMoveinPossessionDates(){
 	var FinPossessionMonth =  MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value;
	if (FinPossessionMonth.length  == 1){FinPossessionMonth = '0' + FinPossessionMonth;}
	var FinPossessionDay =  MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value;
	if  (FinPossessionDay.length == 1){FinPossessionDay = '0' + FinPossessionDay;}	
	var MoveInMonth =  MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value;
	if (MoveInMonth.length  == 1){ MoveInMonth = '0' + MoveInMonth;}
	var MoveInDay =  MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
	if  (MoveInDay.length == 1){MoveInDay = '0' + MoveInDay;}	
	var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  +  FinPossessionMonth + FinPossessionDay;
 	var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  +  MoveInMonth + MoveInDay;
  	if (MoveInDt < FinPossessionDt){
  		alert('Physical Move In Date must be Same or Greater than Financial Possession Date');
  		MoveInForm.MoveInDay.focus();
 		return false;
	}
}

function isMedicaidHouse(){
	var MedicaidBSFRate = document.getElementById("iStateMedicaidAmtBSFDaily").value;
	var ResidentType = document.getElementById("iResidencyType_ID").value;
	if((ResidentType == '2'  ) &&(MedicaidBSFRate == 'NF' )) {
		alert ("This Community does not have Medicaid Street Rates established. \n A Medicaid Residency Move In CANNOT be completed until rates are established"); 
		return false;
	}
}

var	df0=document.forms[0];
var vWinCal;
function vaDefApp(VAApp){
 	if (VAApp.value=="1"){
	 	document.getElementById("VAApproval").style.display='block';
	 	document.getElementById("VAApprover").style.display='block';
	}
	else {
	 	document.getElementById("VAApproval").style.display='none';
	 	document.getElementById("VAApprover").style.display='none';
	}
 }	    

function TenantCheck(){ alert("TenantCheck is called. this is an empty function") }

function redirect() { window.location="../Registration/Registration.cfm"; }

function setmonth() {
	var mylist=document.getElementById("RentMonth");
	var monthSel =mylist.options[mylist.selectedIndex].text;
	document.getElementById("RentMonth").value= monthSel;
}

function requiredBeforeYouLeave() {
	var tenantChecked =document.getElementById("TenantbIsPayer").checked;	
	var contactChecked = document.getElementById("ContactbIsPayor").checked;
	if  (tenantChecked == false &&  contactChecked == false) {
		alert("Select either the Resident or the Contact as the Payor"); 
		return false;
	}
	else if (tenantChecked == true &&  contactChecked == true){
		alert("Select either the Resident or the Contact as the Payor but not both"); 
		return false; 
	}
	else{ 
		return true;
	}
	if(MoveInForm.cSex.options[MoveInForm.cSex.selectedIndex].value == ""){
		MoveInForm.cSex.focus();
		alert("Please Select the Residents Sex - M/F.");
		return false;
	}	
	var FinPossessionMonth =  MoveInForm.RentMonth.options[MoveInForm.RentMonth.selectedIndex].value;
	if (FinPossessionMonth.length  == 1){ FinPossessionMonth = '0' + FinPossessionMonth;}
	var FinPossessionDay =  MoveInForm.RentDay.options[MoveInForm.RentDay.selectedIndex].value;
	if  (FinPossessionDay.length == 1)	{FinPossessionDay = '0' + FinPossessionDay;	}		
	var MoveInMonth =  MoveInForm.MoveInMonth.options[MoveInForm.MoveInMonth.selectedIndex].value;
	if (MoveInMonth.length  == 1){MoveInMonth = '0' + MoveInMonth;}
	var MoveInDay =  MoveInForm.MoveInDay.options[MoveInForm.MoveInDay.selectedIndex].value;
	if  (MoveInDay.length == 1)	{MoveInDay = '0' + MoveInDay;}		
	var FinPossessionDt = MoveInForm.RentYear.options[MoveInForm.RentYear.selectedIndex].value  +  FinPossessionMonth + FinPossessionDay;
	var MoveInDt = MoveInForm.MoveInYear.options[MoveInForm.MoveInYear.selectedIndex].value  + MoveInMonth + MoveInDay;
  	if (MoveInDt < FinPossessionDt){
  		alert('Physical Move In Date must be Same or Greater than Financial Possession Date');
  		MoveInForm.MoveInDay.focus();
  		return false;
	}		
    maskZIP(this);
 	return true;
}

function showHelp(){
	window.open("TIPS-Move-In-Process.pdf");
}

function DisplayResidencyType(string) {
	document.MoveInForm.iResidencyTypeID.options.length=0; 
	if (string.value == 2){    
		for (var i = 0; i < document.MoveInForm.iResidencyTypeID_2.options.length; i++){
			document.MoveInForm.iResidencyTypeID.options[i] = new Option(document.MoveInForm.iResidencyTypeID_2.options[i].text, document.MoveInForm.iResidencyTypeID_2.options[i].value);
		}
	}
	else {
		for (var i = 0; i < document.MoveInForm.iResidencyTypeID_1.options.length; i++) {
			document.MoveInForm.iResidencyTypeID.options[i] = new Option(document.MoveInForm.iResidencyTypeID_1.options[i].text, document.MoveInForm.iResidencyTypeID_1.options[i].value);
		}
	}
}

function DisplayAPtList(string){		
	document.MoveInForm.iAptNum.options.length=0;
	if (document.MoveInForm.iproductline_id.value==1){
		if (string.value == 2) {			
			for (var i = 0; i < document.MoveInForm.iAptNum2.options.length; i++){
				document.MoveInForm.iAptNum.options[i] = new Option(document.MoveInForm.iAptNum2.options[i].text, document.MoveInForm.iAptNum2.options[i].value);
			}
		}
		else{  
			for (var j = 0; j < document.MoveInForm.iAptNum3.options.length; j++){	
				document.MoveInForm.iAptNum.options[j] = new Option(document.MoveInForm.iAptNum3.options[j].text,document.MoveInForm.iAptNum3.options[j].value);
			}		
		}
	}
	else { 
		for (var i = 0; i < document.MoveInForm.iAptNum5.options.length; i++){
			document.MoveInForm.iAptNum.options[i] = new Option(document.MoveInForm.iAptNum5.options[i].text, document.MoveInForm.iAptNum5.options[i].value);
		}						
	}	
}

function addBSFandCare(){
    var bsf = document.getElementById("mStateMedAidAmtRB").value;
    var care = document.getElementById("mStateMedAidAmtcare").value;
    var statemedicaid = +bsf + +care;        
    document.getElementById("mStateMedAidAmtBSFD").value = Math.round(statemedicaid * 100) / 100;
}
