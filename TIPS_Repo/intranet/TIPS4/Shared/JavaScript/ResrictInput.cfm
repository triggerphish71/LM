
<!--- =============================================================================================
Only Allows Numbers for Input Fields
Original code from url developer.irt.org (no author specified)
<SCRIPT LANGUAGE="JavaScript1.2" TYPE="text/javascript">
============================================================================================= --->

<SCRIPT>
<!--
	function trimspaces(obj) {	
		if (obj.value.charAt(obj.value.length) == "" && obj.value.length > 0){
			tmp = obj.value;
			while (tmp.charAt(0) == " ") { tmp = obj.value.substring(1,obj.value.length); obj.value = tmp;}
			while (tmp.charAt(obj.value.length-1) == " ") { btmp = obj.value.substring(0,obj.value.length-1); obj.value = btmp;}
		}
	}

	function hoverdesc(hoverstring){
		document.all['floatercfm'].cursor ="hand";
		l = document.body.scrollLeft + event.x; 
		t = document.body.scrollTop + event.y;
		document.all['floatercfm'].style.position = 'absolute'; 
		document.all['floatercfm'].style.posLeft = l + 10;
		document.all['floatercfm'].style.posTop = t -10; 
		document.all['floatercfm'].style.zindex = 'above';
		hovero = "<TABLE BORDER=1 STYLE='font-weight: bold; border: 1px solid black; width:150px;'><TR><TD STYLE='background: lightyellow;'>" + hoverstring + "</TD></TR></TABLE>";
		timvar = setTimeout("showstring()",500);
	}
	function showstring(){ document.all['floatercfm'].innerHTML = hovero; }
	function resetdesc(){	
		try { if(!timvar == false) { clearTimeout(timvar); } } catch(exception) { /*no action*/ }
		document.all['floatercfm'].style.posLeft = event.x; 
		document.all['floatercfm'].style.posTop = event.y; 
		document.all['floatercfm'].innerHTML = ''; 
	}
	function CancelEnter(){ if (event.keyCode == 13){ event.cancelBubble = true; event.returnValue = false; } } 
	function backhandler() {
	   if (window.event && window.event.keyCode == 8) { // try to cancel the backspace
	      window.event.cancelBubble = true; 
		  window.event.returnValue = false; 
		  return false;}
	}
	
	function backspace(object){
		for (i=0; i <= (document.forms[0].elements.length -1); i++){
			var objectname = (object.name); 
			var elementsname = (document.forms[0].elements[i].name);
			if (objectname == elementsname){ var number = i; }
		}	
		
		if ((window.event && window.event.keyCode == 8) && ((object.value.length == 0) && (document.forms[0].elements[(i - 1)].value.length > 0) )){
      		window.event.cancelBubble = true; 
			window.event.returnValue = false;
			//alert(document.NewApplicant.elements[(number - 1)].name);
			try{ document.forms[0].elements[(number - 1)].focus(); }
			catch(exception){ document.forms[0].elements[(number - 2)].focus();	} 
			return false;
		}
	}
	
	
	function dayslist(month,day,year) {
		days = '';
		var i = (month.value * 1); 	var leap = ((year.value*1) % 4);
		var roundyear = Math.round(leap); var selectedday = (day.value);
		//alert(selectedday); alert(eval(leap));
			if (roundyear = leap){ days = new Array(31,28,31,30,31,30,31,31,30,31,30,31);}
			else{ days = new Array(31,29,31,30,31,30,31,31,30,31,30,31); }
		days = days[(i -1)];
		(day.options.length = days);
		for (a=0; a<=(days -1); a++){
			a = (a * 1); (day.options[a].value = a + 1); (day.options[a].text = a + 1);
			if (selectedday == day.options[a].value) { day.options[a].selected = true; }		
		}
	}	

	function LeadingZeroNumbers(string) {
	for (var i=0, output='', valid="1234567890."; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 	
	

	function Numbers(string) { //if (string == "-" || string == "--" || string <= 0) { return "";}
	for (var i=0, output='', valid="1234567890."; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
	function CreditNumbers(string) {
	if (string.value == "--") { output=''; return output; }
	for (var i=0, output='', valid="1234567890.-"; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
	function Money(string) {	
		for (var i=0, output='', valid="1234567890.-"; i<string.length; i++)
		   if (valid.indexOf(string.charAt(i)) != -1)
			  output += string.charAt(i)
		if (string.indexOf('--') == 0) { output=string.substring(1,string.length); }
		return output;
	}
		
	function Dates(string){
		//alert(window.event.keyCode);
		if (window.event.keyCode == 37 || window.event.keyCode == 8) { return true;	}
		if (window.event.keyCode == 111 || window.event.keyCode == 191 || window.event.keyCode == 109 || window.event.keyCode == 189) {
			//alert('here');	
			var output = '';
			for (i=0;i<(string.value.length-1);i++){ output = output + string.value.charAt(i); }
			string.value = output;
			
			if (string.value.length == 1){ string.value = '0' + string.value + '/'; }
			else if (string.value.length == 4){ 
				//alert('four'); 
				var num = string.value.charAt(3);
				var output2 = '';
				for (i=0;i<(string.value.length-1);i++){ output2 = output2 + string.value.charAt(i); }
				string.value = output2 + '0' + num;
			}
		}
		
		one = '';
		two = '';	
		test = '';
		//alert(window.event.keyCode);
		if (string.value.length == 1 && string.value > 1){
			string.value = '0' + string.value + '/';
		}
		
		else if (string.value.length == 2 && window.event.keyCode != 8){
			string.value = string.value + '/';
		}
		
		else if (string.value.length == 3 && string.value.charAt(2) != '/'){
			for (i=0; i <= (string.value.length -2); i++){
				one = one + string.value.charAt(i);		
			}
			two = string.value.charAt(string.value.length-1);
			if (two > 3) { two='0'+two+'/'; }
			string.value = one + '/' + two;
		}
		
		else if (string.value.length == 4 && string.value.charAt(string.value.length -1) > 3){
			for (i=0; i <= (string.value.length -2); i++){
				one = one + string.value.charAt(i);		
			}
			two = '0' + string.value.charAt(string.value.length -1) + '/';
			string.value = one + two;
		}		
		
		else if (string.value.length == 5 && window.event.keyCode != 8){
			string.value = string.value + '/';
		}

		else if (string.value.length == 7 && (string.value.charAt(6) > 2)){
			for (i=0, seven='' ;i<=(string.value.length-2);i++){ 
				seven += string.value.charAt(i);
			}
				string.value = seven;
		}
		
		else if ((string.value.length == 8) && (string.value.charAt(6) == 0)) {
			var nbr = '<CFOUTPUT>#LEFT(Year(Now()),2)#</CFOUTPUT>' + '0' + string.value.charAt(7);
			for (i=0; i <= (string.value.length -3); i++){ one = one + string.value.charAt(i);}
			string.value =  one + nbr;
		}
				
		else if (string.value.length == 8){
			var digittest =  string.value.charAt(6) + string.value.charAt(7);
			if (digittest < 10){
				var nbr = '<CFOUTPUT>#LEFT(Year(Now()),2)#</CFOUTPUT>' + string.value.charAt(6) + string.value.charAt(7);
				for (i=0; i <= (string.value.length -3); i++){ one = one + string.value.charAt(i);}
				year =  one + nbr;		
			}
		}
		
		else if (string.value.length == 10){
			var thisyear = <CFOUTPUT>#Year(Now())#</CFOUTPUT>;
			var year = '';
			for (i=0; i<=5; i++){ one = one + string.value.charAt(i); }
			for (i=6; i<=9; i++){ year= year + string.value.charAt(i); }

			finalyear = year;
			
			month=(string.value.charAt(0) + string.value.charAt(1));
			if (month > 12){ month = 12 }
			
			day=(string.value.charAt(3) + string.value.charAt(4));
			if (day > 31) { day = 31 } 

			//alert(finalyear);
			if (finalyear % 4 !== 0){ days = new Array(31,28,31,30,31,30,31,31,30,31,30,31); }
			else{ days = new Array(31,29,31,30,31,30,31,31,30,31,30,31); }
			maxdays = days[(month-1)];;
			if (day > maxdays){ string.value = month+'/'+maxdays+'/'+finalyear; } else { string.value = month+'/'+day+'/'+finalyear; }
		}
	}
	
	function verifydateformat(string){
		//alert('running');
		if ((string.value.length > 5 && string.value.length < 10) || (string.value.length > 10 || string.value.length < 8) && string.value !== ''){
			var digittest =  string.value.charAt(6) + string.value.charAt(7);
				if (digittest <= 10) {
					alert('Invalid Date Format');
					string.focus(); string.select();
					if ((string.value.charAt(2) != '/') || (string.value.charAt(5) != '/')){ string.focus(); string.select();}		
				}
			if (string.value.length == 9){ alert('Invalid Date Format'); string.focus(); }
		}
		
	}
	
	function Letters(string) {
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
	function LettersNumbers(string) {
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890.-"; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
	
	function Upper(string) {
		var end = (string.value.substring(1,string.value.length));
		var start = (string.value.charAt(0).toUpperCase());
		string.value = start + end;
	}

	function DayTest(string) {
		if (string.value > 31){
			(string.value = "");
			return;
		}
	}
	
	function MonthTest(string) {
		if 	(string.value > 12) {
			(string.value = "");
			return;
		}	
	}
	
	function YearTest(string) {
		if 	((string.value > 2010) || (string.value < 1900)) {
			(string.value = "");	
			string.focus(); return;
		}	
	}
	
	function Four(string) {
		if 	((string.value.length < 4) && (string.value != "")) { (string.value = ""); string.focus(); return false;}
		else { return true; }
	}
	
	function Three(string) { if (string.value.length < 3) { (string.value = ""); string.focus(); return false; } }
	
	function cent(amount) {
	//CODE originally from developer.it.org
	// returns the amount in the .99 format
	amount -= 0;
	output = (amount == Math.floor(amount)) ? amount + '.00' : (  (amount*10 == Math.floor(amount*10)) ? amount + '0' : amount);
	if (isNaN(output) == true) { return 0.00; }
	return output;
	}

	function round(number,X) {
	// rounds number to X decimal places, defaults to 2
	if (number == "-" || number == "--") { return "0.00";}
	X = (!X ? 2 : X);
	result = Math.round(number*Math.pow(10,X))/Math.pow(10,X);
	if (isNaN(result) == true || result == '..') { result=0; }
	return result
	}
	
	function phone(obj){
		output = ''; count=0;
		for (t=0;t<=(obj.value.length -1);t++){ if (obj.value.charAt(t) == "-"){ count= count+1;} }
		if ( (obj.value.length > 0 && obj.value.length < 10) || count > 2 || (count == 2 && obj.value.length < 12)) { obj.focus(); obj.select(); alert('invalid phone number'); return false; }
		else if (obj.value.length == 10){
			if (count == 0){
				for (i=0;i<=(obj.value.length -1);i++){ if (i==3 || i==6) { output += "-" + obj.value.charAt(i); } else { output += obj.value.charAt(i); } } 
				obj.value = output; 
			}
		}
	}	
	//-->
</SCRIPT>



<!--- ==============================================================================
REQUIRED LEAVE HERE!!!!!!!!
Used for hover description
=============================================================================== --->
<DIV ID="floatercfm" STYLE="color:navy;position:absolute;z-index:above;"></DIV>
