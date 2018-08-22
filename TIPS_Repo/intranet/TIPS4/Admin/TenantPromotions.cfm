<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to add the promotions for the tenants as per project 20125      |                                                                              |
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
<!--- 08/03/2010 Project 50277 Sathya added this --->
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>
<!--- End of code Project 50277 --->

<script language="JavaScript" type="text/javascript">
	function validationOnSave()
	{
		//08/26/2010 project 50227 sathya added this 
		var startdate = document.TenantPromotioninsert.dtEffectiveStart.value;
		var enddate = document.TenantPromotioninsert.dtEffectiveEnd.value;
		//end of project 50227
		if(document.TenantPromotioninsert.cDescription.value =='')
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotioninsert.cDescription.focus();
			//end of code project 50227 
			alert("Please Enter the Description if you want to enter a Promotion");
			return false;
		}
		else if(document.TenantPromotioninsert.dtEffectiveStart.value=='')
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotioninsert.dtEffectiveStart.focus();
			//end of code project 50227 
			alert("Please enter Effective Start Date of Promotion");
			return false;
		}
		//08/26/2010 project 50227 sathya added this 
		else if(isDate(startdate)==false)
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotioninsert.dtEffectiveStart.focus();
			//end of code project 50227 
			alert("Effective Start Date format should be : mm/dd/yyyy");
			return false;
		}
		//End of project 50227
	    else if(document.TenantPromotioninsert.dtEffectiveEnd.value == '')
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotioninsert.dtEffectiveEnd.focus();
			//end of code project 50227 
			alert("Please Enter the Effective End Date of Promotion");
			return false;
		}
		//08/26/2010 project 50227 sathya added this 
		else if(isDate(enddate)==false)
		{
			//08/26/2010 project 50227 sathya added this
			document.TenantPromotioninsert.dtEffectiveEnd.focus();
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
	//08/26/2010 project 50227 sathya added this for date validation
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
<cfquery name="TenantPromotionSet" datasource="#application.datasource#">
	Select * from TenantPromotionSet where dtrowdeleted is null
</cfquery>

<!--- 08/03/2010 Project 50277 Sathya Added this --->
<cfquery name="housePromotionSet" datasource="#application.datasource#">
	select h.ihouse_id, hp.fOccupancyPercentageRestriction, hp.cAppliesToAcctYear, h.cName
	from HousePromotionOccupancyRestriction hp
	join house h
	on h.ihouse_id = hp.ihouse_id
	and h.dtrowdeleted is null
	where hp.ihouse_id =  #SESSION.qSelectedHouse.iHouse_ID#
	and hp.dtrowdeleted is null
</cfquery>
<!--- if in case the previous query returns nothing then we will need the house information --->
<!--- <cfif TenantPromotionSet.recordcount eq 0>
	<cfquery name="GetHouseInfo" datasource="#application.datasource#">
		select cname, ihouse_id
		from house
		where ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		and dtrowdeleted is null
	</cfquery>
</cfif> --->
<!--- End of code Project 50277 --->

<cfoutput>
<!--- Include header file --->
<cfinclude template='../../header.cfm'>
<cfinclude template='../Shared/HouseHeader.cfm'>
<BR> <a href='menu.cfm'>Click Here to Go Back to the Administration Screen.</a> <br>

<!--- 08/03/2010 Project 50277 Sathya Added this --->
<!--- Only the AR Master Admin can edit the Occupancy Restriction for house--->
<!--- DEvelopment its 1381 ListContains(SESSION.groupid, '1381') --->
<!--- Production its 285 is AR MASTER ADMIN so please the below code and skip the code after that --->
<!--- Please UNComment the below cfIF line code when moving to Production --->
<!--- <cfif (ListContains(SESSION.groupid, '285') gt 0)>  --->
<!--- Please Comment the below cfIF line code when moving to Production --->
 <cfif (ListContains(SESSION.groupid, '285') gt 0)>
<table class="noborder">
<tr><td class="transparent" align="center"><P class="PAGETITLE"> Existing Promotion Information For<cfoutput>	#session.HouseName#	</cfoutput></P></td></tr>
</table>
	<TABLE>
		
		<TR><TH COLSPAN=100%>Promotion Information</TH></TR>
		<TR style="font-weight: bold; text-align: center; background: gainsboro;">
			<TD><b>HOUSE</b></TD>
			<TD align="center"><b>OCCUPANCY PERCENTAGE APPLIED</b><br>(e.g, 90)</br></TD>
			<td><b>Applied in which Year</b><br>(e.g, 200909)</br></td>
			<TD><b>CHANGE</b></TD>
		</TR>
		
		<cfif housePromotionSet.recordcount gt 0>
		<FORM NAME="DeleteHousePromotion" ACTION="DeleteHousePromotionOccupancyRestriction.cfm" METHOD="POST">	
		<TR>
			<TD><b>#housePromotionSet.cName#</b></TD>
			<TD style="font-weight: bold;"><INPUT TYPE="Text"  disabled="disabled" NAME="OccupancyPercentage" VALUE="#housePromotionSet.fOccupancyPercentageRestriction#"></TD>
			<TD style="font-weight: bold;"><INPUT TYPE="Text" disabled="disabled" NAME="AppliesToAcctYear" VALUE="#housePromotionSet.cAppliesToAcctYear#"></TD>
			<TD><input name="Delete" type ="submit" value ="Delete"></TD>
		</TR>
		</FORM>
		<cfelse>
		 <FORM NAME="AddHousePromotion" ACTION="AddHousePromotionOccupancyRestriction.cfm" METHOD="POST">	
		<TR>
			<TD><b>#session.HouseName#</b></TD>
			<TD><INPUT TYPE="Text" NAME="OccupancyPercentage" VALUE=""></TD>
			<TD><INPUT TYPE="Text" NAME="AppliesToAcctYear" VALUE=""></TD>
			<TD><input name="Save" type ="submit" value ="Save"></TD>
		</TR>
		</FORM>
	</cfif>
	</TABLE>

<!--- this is for NON-Master Admin  --->
<cfelse>
<table class="noborder">
<tr><td class="transparent" align="center"><P class="PAGETITLE"> Existing Promotion Information For<cfoutput>	#session.HouseName#	</cfoutput></P></td></tr>
</table>
	<TABLE>
		
		<TR><TH COLSPAN=100%>Promotion Information</TH></TR>
		<TR style="font-weight: bold; text-align: center; background: gainsboro;">
			<TD><b>HOUSE</b></TD>
			<TD align="center"><b>OCCUPANCY PERCENTAGE APPLIED</b><br>(e.g, 90)</br></TD>
			<td><b>Applied in which Year</b><br>(e.g, 200909)</br></td>
			<TD><b>CHANGE</b></TD>
		</TR>
		
		<cfif housePromotionSet.recordcount gt 0>
		<TR>
			<TD><b>#housePromotionSet.cName#</b></TD>
			<TD style="font-weight: bold;"><INPUT TYPE="Text"  disabled="disabled" VALUE="#housePromotionSet.fOccupancyPercentageRestriction#"></TD>
			<TD style="font-weight: bold;"><INPUT TYPE="Text" disabled="disabled" VALUE="#housePromotionSet.cAppliesToAcctYear#"></TD>
			<TD>Only AR Master Admin</TD>
		</TR>
		<cfelse>
		<TR>
			<TD><b>#session.HouseName#</b></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" VALUE=""></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" VALUE=""></TD>
			<TD>Only AR Master Admin</TD>
		</TR>
		</cfif>
	</TABLE>
</cfif>  

<!--- End of code Project 50277 --->


<form name="TenantPromotioninsert" action = "TenantPromotionInsert.cfm" method="POST">
<table style="text-align: center;">
	<tr><th>Add a Promotion Here</tr>
</table>
<table>
	<tr>
		<td style="text-align:left;"> 
			<!--- 06/24/2010 Project 50227 TIPS Promotion Update Sathya modified this just gave space in words--->
			<b>Promotion Description</b>
			<!--- Project 50227 end of code --->
			 <input type="text" Name="cDescription"  maxlength="100" 
		size="35" onKeyUp="this.value=LettersNumbers(this.value); this.size=this.value.length;"> </td>
	<tr>
	<tr>
		<td style="text-align:left;"> 
			<!--- 06/24/2010 Project 50227 TIPS Promotion Update Sathya modified this just gave space in words --->
			<b>Promotion Start Date :</b>
			<!--- Project 50227 end of code --->
			<input type="text" Name="dtEffectiveStart" size="12"> 
			
			<!--- 06/24/2010 Project 50227 TIPS Promotion Update Sathya modified this just gave space in words--->
			
			<b>Promotion End Date :</b>
			<!--- Project 50227 end of code --->
		   <input type="text" Name="dtEffectiveEnd" size="12"> </td> 
	</tr>	
	<!--- 06/24/2010 Project 50227 TIPS Promotion Update Sathya made the changes --->
	<tr>
		<td> 
			<b>Does this Promotion has House Occupancy Restriction?</b>
			<input type="checkbox" Name="bISOccupancyRestricted">
		 </td> 
	</tr>	
	<!--- End of code project 50227 --->
	<td colspan="1" style="text-align: left;"><input class="SaveButton" type="submit" name="Save" value="Save" onmouseover="validationOnSave()" onfocus="validationOnSave()" ></td>	
	<td colspan="1" style="text-align: right;"><input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="location.href='#CGI.HTTP_REFERER#'"></td>
	</tr>
	<tr><td colspan="4" style="font-weight: bold; color: red;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </td></tr>	
		</td>	
	</tr>	
	
</table>
</form>


 <b>Existing promotions are listed below.Click on the promotion to edit.</b>
<!--- <table style="text-align: left;"> --->
<table style="text-align: center;nowrap">
	<!--- 06/24/2010 Project 50227 TIPS Promotion Update Sathya made the changes Commented the below line and rewrote it--->
	<!--- 	<tr><th>Description   </th><th> EffectiveStartDate</th><th>EffectiveEndDate</th><th></th> </tr>
	 --->
	 <TR><TH COLSPAN=100%>List of Promotion</TH></TR>
		<TR style="font-weight: bold; text-align: center; background: gainsboro;">
			<TD><b>Description  </b></TD>
			<TD align="center"><b>Promotion <br>Start Date</b></TD>
			<TD align="center"><b>   Promotion <br>End Date</b></TD>
			<td><b>  Occupancy <br>Restriction</b></td>
			<TD><b>  Delete</b></TD>
		</TR>
	 <!--- End of code project 50227 --->
	<cfloop query="TenantPromotionSet">	
		<tr>                           
			<td style="text-align: left;" nowrap><a href="TenantPromotionEdit.cfm?ID=#TenantPromotionSet.iPromotion_ID#">#TenantPromotionSet.cDescription#</A></td>
			 <td style="text-align: center;"> #DateFormat(TenantPromotionSet.dtEffectiveStart,"mm/dd/yyyy")# </td>
			 <td style="text-align: center;">  #DateFormat(tenantPromotionSet.dtEffectiveEnd,"mm/dd/yyyy")#</td>
			<!--- 06/24/2010 Project 50227 TIPS Promotion Update Sathya made the changes --->
			 <td style="text-align: center;"> 
			<cfif (TenantPromotionSet.bIsHouseOccupancyRestricted eq 1)>
			  YES
			<cfelse>
			  NO
			 </cfif>
			 </td>
			<!--- End of code project 50227 --->
			 <td style="text-align: right;"><input class = "BlendedButton" TYPE="button" name="Delete" value="Delete Now" onClick="self.location.href='DeleteTenantPromotion.cfm?typeID=#TenantPromotionSet.iPromotion_ID#'"></td>
		</tr>
	</cfloop>
</table>




	
</cfoutput>