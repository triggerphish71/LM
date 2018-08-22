 /*
	This is a javascript document that is shared by several templates.
	TenantEFThouse.cfm
	TenantEFTAll.cfm
	Because all but one function are the same on both templates I have decided to
	create this js template to be used by both templates.
 */

// these function are shared by both templates 
 function loadstartqryday(){	
 	var e = document.getElementById("iStartDay");    
	var strday = e.options[e.selectedIndex].text; 	
	document.getElementById("startqryday").value = strday;
	document.getElementById("days").value = 'seldays';
 }
 
 function loadendqryday(){	
 	var e = document.getElementById("iEndDay");    
	var endday = e.options[e.selectedIndex].text; 	
	document.getElementById("endqryday").value = endday;
 }
 
 function firstfive(){
 	document.getElementById("days").value = 'seldays';
	document.getElementById("startqryday").value = 1;
	document.getElementById("endqryday").value = 5;
 	formSubmit();
 }
 
  function alldays(){
 	document.getElementById("days").value = 'seldays';
	document.getElementById("startqryday").value = 1;
	document.getElementById("endqryday").value = 25;
 	formSubmit();
 } 

function thismonth(){
	document.getElementById("View").value = 'thismonth';
	document.getElementById("days").value = 'seldays';
	document.getElementById("startqryday").value = 1;
	document.getElementById("endqryday").value = 25; 
	formSubmit();
}

function nextmonth(){
	document.getElementById("View").value = 'nextmonth';
	document.getElementById("days").value = 'seldays';
	document.getElementById("startqryday").value = 1;
	document.getElementById("endqryday").value = 25; 
	formSubmit();
}

/* because each template has a different form name we need to know 
   which template the call is being made from
*/
function formSubmit(){
	var template = window.location.pathname; // set the pathname to a variable
	var isHouse = template.search(/all/i);  // case insensitive seach for the word all. This function returns the starting position of the value being searched. -1 if value is not found.
	if(isHouse != -1){
		document.getElementById("tenanteftall").submit();	
	}
	else{
		document.getElementById("houseeft").submit();
	}	
}

