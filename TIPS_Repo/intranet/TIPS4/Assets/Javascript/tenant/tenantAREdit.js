/*******************************************************************************************************************
/* mstriegel  3/13/2018 - Created this page so that all the javascript for the Admin Edit move out dates secction is in one place
                          and that is is separate presentation from the BL

/******************************************************************************************************************/

// function to validate the form fields
function validateMe(){
	// create a variable to hold all the error messages.
	var errorList = "";
	/* get all the form input elements into an convert them into an array 
	   considering we are only concerned with the date values we will access them
	   by there array position.
    */

	formArray = document.forms['updDates'].getElementsByTagName("input");
	//Physical move out date
	if(formArray[5].value == ''){
		errorList = errorList +'\nPhysical move out date is required!';				
	}
	//check if its a date
	if(formArray[5].value != '' &&  isDate(formArray[5].value) == false){
		errorList = errorList + '\nPyshical move out date must be a valid date.'
	}
	//Charge Through Date
	if(formArray[6].value == ''){
		errorList = errorList + '\nCharge through date is required!';					
	}
 		//Charge Through Date
	if(formArray[6].value != '' && isDate(formArray[6].value) == false){
		errorList = errorList + '\nCharge through date must be a validate date!';					
	}
	// charge through can't be greater then physical
	if(formArray[6].value < formArray[5].value){
		errorList = errorList + '\nCharge through date can not be before physical move out date';
	}
	//Projected Physical Move out date
	if(formArray[7].value == ''){
		errorList = errorList + '\nProject physical move out date is required!';				
	}
	//check if date
	if(formArray[7].value != '' && isDate(formArray[7].value) == false){
		errorList = errorList + '\nProject physical move out date must be a valid date!';				
	}
	if(errorList.length > 0){
		alert(errorList);
		return false;
	}
	//no errors yeah!
	return true;		
}


function isDate(sDate){
	var scratch = new Date(sDate);
	if(scratch.toString() == "NaN"){
		return false;
	}
	else{
		return true;
	}
}

function nextstuffD() {
	solomonkeyvalue  = document.getElementById('solomonid').value;
	window.location.href = "EditMoveOutDates.cfm?solomonid=" + solomonkeyvalue;
}	

function nextstuffI(){
	solomonkeyvalue  = document.getElementById('solomonid').value;
	window.location.href = "EditInvoiceAmts.cfm?solomonid=" + solomonkeyvalue;
}	

function showNotice(string){
	if (string.checked == true){ 
		document.getElementById("noticedt_id1").style.display='none';
		document.getElementById("noticedt_id2").style.display='block';		
		document.getElementById("noticedt").focus();
		showcomments(1);
	}
	else { document.all['datesection'].innerHTML=''; showcomments(0); string.checked = false; }
}		

