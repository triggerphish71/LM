<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to add the promotions for the tenants  as per project 20125     |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Sathya	 |06/06/08    | Added Flowerbox                                                    |
| Sathya     |06/24/2010  | Modified it according to project 50227                             |
----------------------------------------------------------------------------------------------->
<script language="JavaScript" type="text/javascript">
	function validationOnSave()
	{
		//08/26/2010 project 50227 sathya added this 
		var startdate = document.TenantPromotionEdit.dtEffectiveStart.value;
		var enddate = document.TenantPromotionEdit.dtEffectiveEnd.value;
		//end of project 50227
		if(document.TenantPromotionEdit.cDescription.value =='')
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotionEdit.cDescription.focus();
			//end of code project 50227 
			alert("Please Enter the Description if you want to enter a Promotion");
			return false;
		}
		else if(document.TenantPromotionEdit.dtEffectiveStart.value=='')
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotionEdit.dtEffectiveStart.focus();
			//end of code project 50227 
			alert("Please enter Effective Start Date of Promotion");
			return false;
		}
		//08/26/2010 project 50227 sathya added this 
		else if(isDate(startdate)==false)
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotionEdit.dtEffectiveStart.focus();
			//end of code project 50227 
			alert("Effective Start Date format should be : mm/dd/yyyy");
			return false;
		}
		//End of project 50227		
		
	    else if(document.TenantPromotionEdit.dtEffectiveEnd.value == '')
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotionEdit.dtEffectiveEnd.focus();
			//end of code project 50227 
			alert("Please Enter the Effective End Date of Promotion");
			return false;
		}
		//08/26/2010 project 50227 sathya added this 
		else if(isDate(enddate)==false)
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotionEdit.dtEffectiveEnd.focus();
			//end of code project 50227 
			alert("Effective End Date format should be : mm/dd/yyyy");
			return false;
		}
		//End of project 50227	
		
	   	else
		{
			return true;
		}
	}
	//08/26/2010 Project 50227 Sathya added this for Date Validation
	function isDate(dtStr){
		var dtCh= "/";
		var minYear=2009;
		var year=new Date();
		var now=new Date();
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
//end of project 50227
	
</script>
<cfoutput >
	<cfinclude template='../../header.cfm'>
<cfinclude template='../Shared/HouseHeader.cfm'>
<BR> <a href='menu.cfm'>Click Here to Go Back to the Administration Screen.</a> <br>

<cfquery name="Promotiontype" datasource="#APPLICATION.datasource#">
select * from tenantPromotionset where dtRowDeleted is null and iPromotion_ID = #url.id#
<!--- <cfif IsDefined("form.iPromotion_ID")>
	<cfif form.iPromotion_ID neq "">
		and iPromotion_ID = #form.iPromotion_ID# 
		<cfelseif IsDefined("url.ID")> and iPromotion_ID = #form.iPromotion_ID# 
	</cfif>
</cfif>		 --->
</cfquery>

<!--- <cfset iPromotion_id =#form.iPromotion_ID#> --->


<form name="TenantPromotionEdit" action = "TenantPromotionUpdate.cfm?ID=#Promotiontype.iPromotion_ID#" method="POST">
<table style="text-align: center;">
	<tr><th>Edit  Promotion</tr>
</table>
<table>
	<tr>
		<td style="text-align:left;"> 
			<b>PromotionDescription</b>
			<input type="text" Name="cDescription" value="#Promotiontype.cDescription#" maxlength="100" 
		 onKeyUp="this.value=LettersNumbers(this.value); this.size=this.value.length;">
		</td>
	<tr>
	<tr>
		<td style="text-align:left;"> 
			<b>PromotionStartDate</b>
			<input type="text" Name="dtEffectiveStart" value = "#DateFormat(Promotiontype.dtEffectiveStart,"mm/dd/yyyy")#" size ="12"> <b>PromotionEndDate</b>
		   <input type="text" Name="dtEffectiveEnd" value = "#DateFormat(Promotiontype.dtEffectiveEnd,"mm/dd/yyyy")#" size="12"> </td> 
	</tr>	
	<!--- 06/24/2010 Project 50277 TIPS Promotion Update Sathya made the changes --->
	<tr>
		<td> 
			<b>Does this Promotion has House Occupancy Restriction?</b>
			<cfif Promotiontype.bIsHouseOccupancyRestricted eq 1>
				<input type="checkbox" Name="bOccupancyRestricted" checked="1">
			<cfelse>
				<input type="checkbox" Name="bOccupancyRestricted">
			</cfif>
			
		 </td> 
	</tr>	
	<!--- End of code project 50277 --->	
	<td colspan="1" style="text-align: left;"><input class="SaveButton" type="submit" name="Save" value="Save" onmouseover="validationOnSave()" onfocus="validationOnSave()" ></td>	
	<td colspan="1" style="text-align: right;"><input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="location.href='#CGI.HTTP_REFERER#'"></td>
	</tr>
	<tr><td colspan="4" style="font-weight: bold; color: red;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </td></tr>	
		</td>	
	</tr>	
	
</table>
</form>
</cfoutput>