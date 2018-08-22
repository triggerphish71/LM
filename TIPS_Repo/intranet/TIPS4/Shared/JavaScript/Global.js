//99575 S Farmer 02-01-2013  Updated maskZIP to accomodate Canadian Postal codes
// added ' & . apostrophe and period to ltrs and LettersNumbers S Farmer 02/26/2016

function upperCase(str) {	
		str.value = str.value.replace(/(\w)(\w*)/g, function(g0,g1,g2){return g1.toUpperCase() + g2.toLowerCase();});
	}

	function maskSSN(obj){
	
		var tmp;	
		tmp = obj.value.replace(/-/gi,'');  //remove any dashes that were already added to the SSN

		if (tmp.length < 3)
			obj.value = tmp.substr(0,3);
		
		if (tmp.length >= 4 && tmp.length <= 5)
			obj.value = tmp.substr(0,3)+ '-' + tmp.substr(3,2);
		 
		if (tmp.length > 5)
			obj.value = tmp.substr(0,3)+ '-' + tmp.substr(3,2) + '-' +  tmp.substr(5,4);	
	}
			
	function maskZIP(obj){

		var tmp;	
		tmp = obj.value;
		tmp = tmp.replace(/-/gi,'');  //remove any dashes that were already added to the zip
		tmp = tmp.replace(' ',''); //remove any spaces that were already added to the zip
 	 
		if (tmp.length < 5 && bisInteger(tmp)==true)
			{
			obj.value = tmp;
			alert("ZIP (Postal Code) Must be at least 5 numbers (U.S.) or 6 Characters (Canada) long." );
			}
		if (tmp.length == 5)
			{
			if (bisInteger(tmp)==false)
			{alert("U.S. Postal code must be all numeric. Canadian Postal Code must have the format: A1A 1T1.")
				obj.focus();
			}
			}
		if (tmp.length >  5 && tmp.length < 9 && bisInteger(tmp)==true)
			{
			obj.value = tmp.substr(0,5)+ '-' + tmp.substr(5,4);
			alert("U.S. Postal code +4 format is 12345-1234");
			obj.focus();
			}
		else if (tmp.length == 9)
			obj.value = tmp.substr(0,5)+ '-' + tmp.substr(5,4);
		else if (tmp.length == 6 && bisInteger(tmp)==false)
			{
			tmp = tmp.substr(0,3 )+ ' ' + tmp.substr(3,3);	
			obj.value = tmp.toUpperCase();
			}
		else if (tmp.length == 10)
			obj.value = tmp.substr(0,5)+ '-' + tmp.substr(6,4);		
		else 
			obj.value = tmp.toUpperCase();
	}

	function allowOnlyNumberOnKey(evt)
	{
		var charCode = event.keyCode;

		if(charCode == 45 )  //allow dashes as part of a number
			return true;
		
		if (charCode < 48 || charCode > 57)  //number keycodes are 48 thru 57
			return false;
		
		return true;
	}

	function allowOnlyLettersOnKey(evt)
	{
		var charCode = event.keyCode;
		
		if ((charCode > 64 && charCode < 91) || (charCode > 96 && charCode < 123) || charCode == 8 || charCode == 32)
			return true;
		
		return false;
	}
	
	function bisInteger(s){
		var i;
		for (i = 0; i < s.length; i++){   
			// Check that current character is number.
			var c = s.charAt(i);
			if (((c < "0") || (c > "9"))) return false;
		}
		// All characters are numbers.
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




	function bstripCharsInBag(s, bag){
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
	
	function DaysArray(n) {
		for (var i = 1; i <= n; i++) {
			this[i] = 31
			if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
			if (i==2) {this[i] = 29}
	   } 
	   return this;
	}	
	
	function onlyNumbers(evt)
	{
		var e = event || evt; // for trans-browser compatibility
		var charCode = e.which || e.keyCode;
	
		if (charCode > 31 && (charCode < 48 || charCode > 57))
			return false;
	
		return true;
	
	}
	function daysInFebruary (year){
		// February has 29 days in any year evenly divisible by four,
		// EXCEPT for centurial years which are not also divisible by 400.
		return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
	}
	
	function bisDate(dtStr){
		var dtCh= "/";
		var minYear=1900;
		var year=new Date();
		var now=new Date();
		var maxYear=year.getYear();
		var bdaysInMonth = DaysArray(12)
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
			alert("The date format should be : mm/dd/yyyy")
			return false;
		}
		if (strMonth.length<1 || month<1 || month>12){
			alert("Please enter a valid month")
			return false;
		}
		if (strDay.length<1 || day<1 || day>31 || (month==02 && day>daysInFebruary(year)) || day > bdaysInMonth[month]){ 
			alert("Please enter a valid day.")
			return false;
		}
		if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
			alert("Please enter a valid 4 digit year. \n \n(ie "+maxYear+")")
			return false;
		}
		if (dtStr.indexOf(dtCh,pos2+1)!=-1 || bisInteger(bstripCharsInBag(dtStr, dtCh))==false){
			alert("Please enter a valid date")
			return false;
		}
		if(strDay.length<2){strDay = 0 + strDay}
		if(strMonth.length<2){strMonth = 0 + strMonth}
		var RearrangedInput=strYear+strMonth+strDay
		RearrangedInput = parseFloat(RearrangedInput)
		var TodayDay = parseInt(now.getDate());
		TodayDay = TodayDay +'';
		if (TodayDay.length<2){TodayDay = 0 + TodayDay;
		}
		
		var TodayMonth = parseInt(now.getMonth());
		TodayMonth = (TodayMonth + 1)+'';
		if (TodayMonth.length<2){TodayMonth = 0 + TodayMonth;}
		
		var TodayYear = now.getFullYear();
		var TodayRearranged = (TodayYear + ''+ TodayMonth +''+ TodayDay)
		TodayRearranged = parseFloat(TodayRearranged);
		if (RearrangedInput>TodayRearranged){
			return false;
		}
	return true;
	}

	function dateformat(obj){
		if ((obj.value.length > 5 && obj.value.length < 10) || (obj.value.length > 10 || obj.value.length < 8) && obj.value !== ''){
			var digittest =  obj.value.charAt(6) + obj.value.charAt(7);
				if (digittest <= 10) {
					alert('Invalid Date Format'); obj.focus(); obj.select(); 
					if ((obj.value.charAt(2) != '/') || (obj.value.charAt(5) != '/')){ obj.focus(); obj.select();}		
				}
			if (obj.value.length == 9){ alert('Invalid Date Format'); obj.focus(); }
		}
	for (var i=0, output='', valid="1234567890/"; i<obj.value.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)		
	}

	function trimspaces(obj) {	
		if (obj.value.charAt(obj.value.length) == "" && obj.value.length > 0){
		tmp = obj.value;
		while (tmp.charAt(0) == " ") { tmp = obj.value.substring(1,obj.value.length); obj.value = tmp;}
		while (tmp.charAt(obj.value.length-1) == "  " || tmp.charAt(obj.value.length-1) == "	") { btmp = obj.value.substring(0,obj.value.length-1); obj.value = btmp;}
		}
	}
	
	function hoverdesc(hoverstring,time){
		if (!time) { time=2000; }
		document.all['floater'].cursor ="hand"; //initialize cursor icon
		l = document.body.scrollLeft + event.x; t = document.body.scrollTop + event.y; document.all['floater'].style.zindex = 3;
		document.all['floater'].style.posLeft = l + 10; document.all['floater'].style.posTop = t -10; 
		hovero = "<HTML><BODY><TABLE STYLE='font-size: xx-small; font-family: verdana; font-weight: bold; border: 1px solid navy; background: c0dcc0; color: blue;'><TR><TD nowrap>" + hoverstring + "</TD></TR></TABLE></BODY></HTML>";
		document.frames[0].document.open(); document.frames[0].document.write(hovero); document.frames[0].document.close();
		document.all['floater'].style.width='10px'; //initialize size for detection
		document.all['floater'].style.height = floaterwindow.document.body.scrollHeight+'px';
		timevar=setTimeout('resetdesc()',time);
		document.all['floater'].style.width=floaterwindow.document.body.scrollWidth+'px';
	}
	
	function loadingdesc(hoverstring){
		daf=document.all['floater'];
		daf.cursor ="hand";	pleft=(screen.availWidth/2)-200; daf.style.posLeft = pleft; 
		ptop=(screen.availHeight/2)-200; daf.style.posTop = ptop; daf.style.zindex = 3;		
		hovero="<html><head><script>function changetext(){ document.all['mtext'].innerHTML+='.'; setTimeout('changetext()',1000); } window.onload=changetext;</script></head>";
		hovero+="<body><table style='width:300px; height:150px; font-size: medium;";
		hovero+="font-family: verdana; font-weight: bold; border: 3px outset eaeaea;";
		hovero+="background-color: eaeaea; color: blue;'><tr>";
		hovero+="<td nowrap style='text-align:center;'><span id='mtext'>" + hoverstring + "</span></td></tr></table></body></html>";
		document.frames[0].document.open(); document.frames[0].document.write(hovero); document.frames[0].document.close();
		daf.style.width= '300px'; daf.style.height = '150px';
		timevar=setTimeout('resetdesc()',10000);
	}	
	
	function resetdesc(){
		try{ clearTimeout(timevar); } catch (exception) { /*no action*/ }
		document.all['floater'].style.posLeft = 0; document.all['floater'].style.posTop =  0; 
		document.all['floater'].style.width = '0px'; document.all['floater'].style.height = '0px';		
	}
	
	function CancelEnter(){ if (event.keyCode == 13){ event.cancelBubble = true; event.returnValue = false; } } 
	
	function backhandler() {
	   if (window.event && window.event.keyCode == 8) { // try to cancel the backspace
	      window.event.cancelBubble = true; window.event.returnValue = false; return false;}
	}
	
	function backspace(object){
		for (i=0; i <= (document.forms[0].elements.length -1); i++){
			var objectname = (object.name); var elementsname = (document.forms[0].elements[i].name);
			if (objectname == elementsname){ var number = i; }
		}	
		if ((window.event && window.event.keyCode == 8) && ((object.value.length == 0) && (document.forms[0].elements[(i - 1)].value.length > 0) )){
      		window.event.cancelBubble = true; window.event.returnValue = false;
			try{ document.forms[0].elements[(number - 1)].focus(); }
			catch(exception){ document.forms[0].elements[(number - 2)].focus();	} 
			return false;
		}
	}
	
	function dayslist(month,day,year) {
		days = ''; var i = (month.value * 1); var leap = ((year.value*1) % 4);
		var roundyear = Math.round(leap); var selectedday = (day.value);
		if (roundyear = leap){ 
			days = new Array(31,28,31,30,31,30,31,31,30,31,30,31);}
		else{ 
			days = new Array(31,29,31,30,31,30,31,31,30,31,30,31);}
		days = days[(i -1)]; (day.options.length = days);
		
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
	
	function Numbers(string) {
	for (var i=0, output='', valid="1234567890."; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 

	 function numbers(e)
	  {		//  Robert Schuette project 23853  - 7-14-08
	  	  // removes House ability to enter negative values for the Amount textbox,
	  	//  only AR will enter in negative values.  Added extra: only numeric values.
	   //alert('Javascript is hit for test.')
	  	keyEntry = window.event.keyCode;
	  		if((keyEntry < '46') || (keyEntry > '57') ||( keyEntry == '47')) {return false;  }
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
	
	function verifydateformat(obj){
		if ((obj.value.length > 5 && obj.value.length < 10) || (obj.value.length > 10 || obj.value.length < 8) && obj.value !== ''){
			var digittest =  obj.value.charAt(6) + obj.value.charAt(7);
				if (digittest <= 10) {
					alert('Invalid Date Format'); obj.focus(); obj.select(); 
					if ((obj.value.charAt(2) != '/') || (obj.value.charAt(5) != '/')){ obj.focus(); obj.select();}		
				}
			if (obj.value.length == 9){ alert('Invalid Date Format'); obj.focus(); }
		}
	}
	
	function ltrs(string) {
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'. "; i<string.length; i++)
		if (valid.indexOf(string.charAt(i)) != -1) { output += string.charAt(i); } return output;	
	} 
	
	function LettersNumbers(string) {
	for (var i=0, output='', valid="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 1234567890'.-"; i<string.length; i++)
       if (valid.indexOf(string.charAt(i)) != -1)
          output += string.charAt(i)
    return output;	
	} 
	
	function Upper(string) {
		var end = (string.value.substring(1,string.value.length));
		var start = (string.value.charAt(0).toUpperCase());
		string.value = start + end;
	}
	
	function Four(string) {
		if 	((string.value.length < 4) && (string.value != "")) { (string.value = ""); string.focus(); alert('Four digits required in this field'); return false;}
		else { return true; }
	}
	function Three(string) {
		if 	((string.value.length < 3) && (string.value != "")) { (string.value = ""); string.focus(); alert('Three digits required in this field'); return false;}
		else { return true; }
	}	
	function cent(amount) {
		//CODE originally from developer.it.org returns the amount in the .99 format
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
		for (t=0;t<=(obj.value.length -1);t++){ 
			if (obj.value.charAt(t) == "-"){ count= count+1;} 
			if ( (obj.value.length > 0 && obj.value.length < 10) || count > 2 || (count == 2 && obj.value.length < 12)) 
				{ obj.focus(); obj.select(); alert('invalid phone number'); return false; }
				else if (obj.value.length == 10){
					if (count == 0){
						for (i=0;i<=(obj.value.length -1);i++){ 
							if (i==3 || i==6) { output += "-" + obj.value.charAt(i); } 
							else { output += obj.value.charAt(i); } } 
						obj.value = output; 
					}
			}
		}
	}

	function Dates(obj){
		months = new Array('January','February','March','April','May','June','July','August','September','October','November','December');
		len = obj.value.length; var re_date = /^(\d+)\/(\d+)\/(\d+)$/;
		if (len !== 0) {
			if (!re_date.exec(obj.value)) { 
				alert("Invalid Datetime format: "+ obj.value + '\rValid format is mm/dd/yyyy'); 
				try { obj.focus(); } catch (exception) { /*no action*/ } 
				return false;
			} 
		}
		tDate=new Date (RegExp.$3, RegExp.$1-1, RegExp.$2);
		
		if ( RegExp.$1 == 0 || RegExp.$2 == 0) { alert('Invalid date ' + RegExp.$1 + '/' + RegExp.$2 + '/' + RegExp.$3 ); obj.focus(); }
		
		var dOfMonth = 32 - new Date(RegExp.$3, RegExp.$1-1, 32).getDate();
		if ( RegExp.$2 > dOfMonth ) { alert( months[RegExp.$1-1] + ' does not have ' + RegExp.$2 + ' days'); obj.focus(); }
	}