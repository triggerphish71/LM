<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| RSchuette  | 09/28/2009 | Created  - Change dates for closed acounts                           |
							Created Page + code for #42573
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                  |
------------------------------------------------------------------------------------------------->
<cfoutput>
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<CFINCLUDE TEMPLATE="../../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<!--- ==============================================================================
Include TIPS header for the House
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../Shared/HouseHeader.cfm"></br>
<script language="JavaScript" src="../../../global/calendar/ts_picker2.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
	function MSG(){
		alert("Please click the calendar icon to fill value.")
		DateDisp.Submit.focus();
		return false;
	}
	
	function press(e)
	{	return MSG();
  			return false; 
  	}
<!--- incase date validation is needed at some point 
function SubmitCheck(){
if(ValidDate(DateDisp.NewMOdate.value) == false){
	return MSG();}
} 	
function ValidDate(dt){
if(isDate(dt)==false){
	return MSG();}
return true;
	}
//also seen on MoveInForm & relocate
function isDate(dtStr){
		var dtCh= "/";
		var minYear=2008;
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
 --->
</script>
	<cfquery name="GetResidentInfo" datasource="#APPLICATION.datasource#">
		select (t.cfirstname + ' ' + t.clastname) as Tenant 
		,t.iTenant_ID
		,ts.dtMoveOut as dtMO
		,ts.dtChargeThrough as dtCT
		,ts.dtNoticeDate as dtND 
		from tenant t
		join tenantstate ts on (ts.iTenant_ID = t.iTenant_ID and ts.dtrowdeleted is null)
		where t.iTenant_ID = '#form.TenantSelect#'
	</cfquery>
	<cfset MODate = DateFormat(GetResidentInfo.dtMO,"mm/dd/yyyy")>
	<cfset CTDate = DateFormat(GetResidentInfo.dtCT,"mm/dd/yyyy")>
	<cfset NDDate = DateFormat(GetResidentInfo.dtND,"mm/dd/yyyy")>
	<cfset TID = GetResidentInfo.iTenant_ID>
<A Href="../TenantDateAdjustments.cfm" style="Font-size: 18;">Choose New Resident</a>
</br></br>


#GetResidentInfo.Tenant# - Date Details on Closed Account
<form name="DateDisp" action="act_UpdateTenantDates.cfm?ID=#'TID'#" method="POST">
<input type="hidden" id="TID" name="TID" value="#TID#">
<table border="1" >
	<tr>
			<td></td>
			<td><u>Current Value:</u></td>
			<td><u>Change To:</u></td>
	</tr>
	 <tr>
			<td>Notice Date</td>
			<td>#NDDate#</td>
			<td><!--- 
				<input type="text" id="NewNDdate" name="NewNDdate" size="10" value="#NDDate#" onfocus="return MSG();" onclick="return MSG();">&nbsp;<a onclick="show_calendar2('document.forms[0].NewNDdate',document.getElementsByName('NewNDdate')[0].value);"> <img src="../../../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
			 ---></td>
	</tr>
	<tr>
			<td>Charge Through Date</td>
			<td>#CTDate#</td>
			<td><!--- 
				<input type="text" id="NewCTdate" name="NewCTdate" size="10" value="#CTDate#" onfocus="return MSG();" onclick="return MSG();">&nbsp;<a onclick="show_calendar2('document.forms[0].NewCTdate',document.getElementsByName('NewCTdate')[0].value);"> <img src="../../../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
			 ---></td>
	</tr> 
	<tr>
			<td>Physical Move Out Date</td>
			<td>#MODate#</td>
			<td>
				<input type="text" id="NewMOdate" name="NewMOdate" size="10" value="#MODate#"  onkeypress="return press(event); DateDisp.Submit.focus();" onClick="return MSG(); DateDisp.Submit.focus();" >&nbsp;<a onClick="show_calendar2('document.forms[0].NewMOdate',document.getElementsByName('NewMOdate')[0].value);"> <img src="../../../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;" id="Cal" name="Cal"> </a>
			 </td>
	</tr>
	<tr>
		<td></td>
		<td></td>
		<td>
			<input type="submit" name="Submit" value="Change Dates">
		</td>
	</tr>
</table>
</form>



</br></br>
<A Href="../../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
<CFINCLUDE TEMPLATE='../../../Footer.cfm'>
</BODY>
</cfoutput>