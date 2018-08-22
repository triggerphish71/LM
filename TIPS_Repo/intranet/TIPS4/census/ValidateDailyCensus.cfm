<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| To validate all tenants in a house                                                           |
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
| fzahir     | 01/31/2006 | To show all tenants in a house. Based on the tenants status, set     |
|            |            | appropriate flag. If tenant is moving out, enter MoveOut date.       |
| mlaw       | 07/05/2006 | Add Expected Date of Move-Out.  Remove Notice of Discharge.          |
| mlaw       | 01/22/2007 | exclude Move In date after census date                               |
| mlaw       | 03/05/2007 | Modify query checkdailycensustrack, checkdailycensus                 |
| sfarmer    | 04/08/2013 | add user sorting capablities change default is correct room numbers  |
| sfarmer    | 03/10/2014 | Removed ts.dtMoveIn <= '#CompareDate#' due to use of future move-ins |
------------------------------------------------------------------------------------------------->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Validate Daily Census</title>
</head>
<cfparam name="sortby" default="">
<cfif isdefined("form.dtCompare")>
	<cfset dtCompare=#form.dtCompare# >
<cfelse >
	<cfset dtCompare=#url.dtCompare# >
</cfif>


<script language="JavaScript">
	function close_other_box(objName, itenantID){
	//define vars
	var box = document.getElementsByName(objName)[0];
	var otherbox = document.getElementsByName('ND_' + itenantID)[0];
	//var dischargedate = document.getElementsByName('Date_' + itenantID)[0];
	
	//testing message
	alert(box.selectedIndex);
	alert(otherbox);
		if(box.selectedIndex == 0){
			otherbox.disabled=true
			//dischargedate.disabled=true
		}
		else{
			otherbox.disabled=false
			//dischargedate.disabled=false
		}
	}
	//Mshah
	function approved(){
		cnt= document.getElementById('queryCount').value;
		if (cnt > 0){
			alert('This daily census data is used by Enlivant to accurately calculate reimbursement amounts to which the company may be entitled from the relevant Medicaid waiver program state authority or its designated managed care organization.  By submitting this data, you are attesting that this census data is accurate and complete for each resident.  If you subsequently learn that this census data is incorrect for any reason, you must promptly submit a correction for each resident.');
		}
	}
	//Mshah
	
	function isValidDate() 
	{
		//get all the input field
		inputArray = document.getElementsByTagName('Input');
		
		for(i = 1; i < inputArray.length; i++)
		{
			if(inputArray[i].name.indexOf('Date_') != -1)
			{
				var dateStr = inputArray[i].value;
				
				// Checks for the following valid date formats:
				// MM/DD/YY   MM/DD/YYYY   MM-DD-YY   MM-DD-YYYY
				// Also separates date into month, day, and year variables
				if (dateStr != '')
				{
					//var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{2}|\d{4})$/;
					
					// To require a 4 digit year entry, use this line instead:
					 var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{4})$/;
				
					var matchArray = dateStr.match(datePat); // is the format ok?
					
					if (matchArray == null) 
					{
						alert("Date is not in a valid format.");
						return false;
					}
					
					month = matchArray[1]; // parse date into variables
					day = matchArray[3];
					year = matchArray[4];
					
					if (month < 1 || month > 12) 
					{ // check month range
						alert("Month must be between 1 and 12.");
						return false;
					}
					
					if (day < 1 || day > 31) 
					{
						alert("Day must be between 1 and 31.");
						return false;
					}
					
					if ((month==4 || month==6 || month==9 || month==11) && day==31) 
					{
						alert("Month "+month+" doesn't have 31 days!");
						return false;
					}
					
					if (month == 2) 
					{ 
						// check for february 29th
						var isleap = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
						if (day>29 || (day==29 && !isleap)) 
						{
							alert("February " + year + " doesn't have " + day + " days!");
							return false;
						}
					}
				}
			}
			//alert('test')
			//alert ( )
			
			//if(inputArray[i].name.indexOf('Date_') != -1)
			
		}
		a = document.getElementsByTagName('select');
		//alert(a);
		//alert('test2');
		for(i = 1; i < a.length; i++)
		{
			//alert(a[i].name.indexOf('CSB'));
			//alert(a[i].getElemenbyID('CSB').value)
			if(a[i].name.indexOf('CSB') != -1)
			{
				var xyz = a[i].value;	
				//alert(xyz);
				if(xyz=='')
				{
					alert('Missing Current Status for Medicaid Residents');
					return false;
				}
		     }
			
		}
		
		document.getElementsByName('TrackDailyCensus')[0].submit();
	}
</script>


<!---  CreateODBCDateTime(now()) --->
<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<!--- Include the page for house header --->
<cfinclude template="../Shared/HouseHeader.cfm">

<!--- Set Previous Date --->
<cfset YesterdayDate = #DateFormat(dateadd("d", -1, now()), "mm/dd/yyyy")#>

<body> 
	<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
		<cflocation url="../../Loginindex.cfm" addtoken="yes">
	</cfif>
	
	<!--- Set Previous Date --->
	<cfset BeginDate = #DateFormat(dateadd("d", -1, #dtCompare#), "mm/dd/yyyy")#>
	<!--- Set Form Date --->
	<cfset CompareDate = #dtCompare#>
	
	<!--- Check to see if there is any records for the previous days --->
	<cfquery name="checkdailycensustrack" datasource="#application.datasource#">
		select 
			Top 1 
			max(Census_Date) as census_date
			, Census_Date + 1 as NewCensus_Date
			, Census_Date + 2 as Report_Date
		from 
			dailycensustrack dct
		join 
			tenant t
			on t.itenant_ID = dct.itenant_ID
		join
			tenantstate ts
			on ts.itenant_ID = t.itenant_ID
		where 
			ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		  and
			ts.itenantstatecode_id = 2
		  and
			t.dtrowdeleted is NULL
		  and
			ts.dtrowdeleted is NULL	
		  and
	    	dct.dtrowdeleted is NULL	
		group by 
		   Census_Date + 1
		  ,Census_Date + 2
		order by
			census_date desc
	</cfquery>

	<!--- check to see if there is any approval census record in the system --->
	<!--- Set Census_Date, Approve_Date --->
	<cfquery name="checkdailycensus" datasource="#application.datasource#">
		select 
			Top 1 
			max(Census_Date) as census_date
			, Census_Date + 1 as Approve_Date
		from 
			dailycensus dc
		where 
			ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		  and
	    	dc.dtrowdeleted is NULL	
		group by 
		   Census_Date + 1
		order by
			census_date desc
	</cfquery>	
	
	<cfif #checkdailycensus.recordcount# gt 0>
		<cfif #checkdailycensus.census_date# eq CompareDate>
			<center>
			<font color = red>
				<table align="center">
					<tr align="center">
					<td>
						<font color = red>
						<b>You cannot make any changes to the daily census.  It is already approved. </b>
						</font>
					</td>
					</tr>
				</table>
				<table align="center">
					<tr align="center">
						<!--- <td><INPUT TYPE="button" VALUE="Go Back" OnClick="JavaScript:history.go(-1)"></td> --->
						<td><INPUT TYPE="button" VALUE="Back To Main Menu" OnClick="window.location.href='census.cfm';"></td>
					</tr>
				</table>
			</font>
			</center>
			<cfabort>
		</cfif>
	</cfif>
	
	<cfquery name="validatehouse" datasource="#application.datasource#">
		select 
			<!--- distinct ---> 
			a.cAptNumber 
			, len(a.cAptNumber)

			, a.iAptType_ID
			,  t.iTenant_ID 
			,  t.cLastName 
			, t.cFirstName
			, rt.cDescription 
			, isNULL(pdct.CurrentStatusInBedAtMidnight,'Y') as PreviousStatus
			, dct.CurrentStatusInBedAtMidnight
            , dct.NoticeOfDischarge
			, dct.DischargeDate as DischargeDate
			, pdct.DischargeDate as PreviousDischargeDate
			, H.cName as HouseName
		from AptAddress a (nolock)
		left join houseproductline hpl (nolock) 
			on hpl.ihouseproductline_id = a.ihouseproductline_id 
			and hpl.dtrowdeleted is null
		left join productline pl (nolock) 
			on pl.iproductline_id = hpl.iproductline_id 
			and pl.dtrowdeleted is null
		left join	TenantState ts (nolock) 
			on a.iAptAddress_ID = ts.iAptAddress_ID 
			and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID = 2 and ts.dtRowDeleted is null)		
		left outer join AptType APT (nolock) 
			on (apt.iAptType_ID = a.iAptType_ID 
			and apt.dtRowDeleted is null)
		left join Tenant t (nolock) 
			on (t.iTenant_ID = ts.iTenant_ID)
		left join    
			 House H on H.ihouse_id = t.ihouse_id    
		left join	ResidencyType RT (nolock) 
			on (rt.iResidencyType_ID = ts.iResidencyType_ID)
		left join SLevelType ST (nolock) 
			on (t.cSlevelTypeSet = st.cSlevelTypeSet and ts.iSPoints <= iSPointsMax and ts.iSPoints >= iSPointsMin)
		left join     
			 DailyCensusTrack dct on dct.iTenant_ID = t.iTenant_ID    
				  and     
			 dct.Census_Date = '#CompareDate#'  
		left join     
			 DailyCensusTrack pdct on pdct.iTenant_ID = t.iTenant_ID    
				  and    
			 pdct.Census_Date = '#BeginDate#'   
		where	
			a.dtRowDeleted is null	
			and a.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and t.dtRowDeleted is null
			and ((ts.iTenantStateCode_ID is null and ts.dtmovein is NULL) 
				or (ts.iTenantStateCode_ID IN (2))   )		
			<cfif sortby is ''>
				order by len(a.cAptNumber) , a.cAptNumber
			<cfelseif sortby is "Room">
				order by len(a.cAptNumber) , a.cAptNumber
			<cfelseif sortby is "residentid"> 
				order by isNull(t.iTenant_ID, 99999) , len(a.cAptNumber) , a.cAptNumber 
			<cfelseif sortby is "residentname"> 
				order by  IsNull(t.cLastName, 'zzzzz') , len(a.cAptNumber) , a.cAptNumber 		
			</cfif>	
	</cfquery>
	
	<!---Mshah added query to check for medicaid recordcount--->
	<cfquery name="Medicaidrecordcount" datasource="#application.datasource#">
	select * from tenant t join tenantstate ts on ts.itenant_ID=t.itenant_ID
	where ts.itenantstatecode_ID=2
	and ts.iresidencytype_ID= 2
	and ts.dtrowdeleted is null
	and t.dtrowdeleted is null
	and t.ihouse_ID= #session.qselectedhouse.ihouse_ID#
	</cfquery>
	<!---<cfdump var="#Medicaidrecordcount#">--->
	<!---Mshah--->
	<table align="center">
		<tr valign="top">
			<td align="center">
				<h2><b>Validate Daily Census</b></h2>
			</td>
		</tr>
	</table>
	<p>
	<!---onSubmit="return isValidDate('Date_#iTenant_ID#')"--->
	<form name="TrackDailyCensus" action="TrackDailyCensus.cfm" method="post">
		<input type="hidden" name="CompareDate" value="<cfoutput>#CompareDate#</cfoutput>">
	    <table border="1" align="center">
          <tr align="center">
            <td><cfoutput><a href="ValidateDailyCensus.cfm?sortby=room&dtCompare=#dtCompare#"><b>Room</b></a></cfoutput></td>
            <td><cfoutput><a href="ValidateDailyCensus.cfm?sortby=residentID&dtCompare=#dtCompare#"><b>Tenant ID</b></a></cfoutput></td>
            <td nowrap="nowrap"><cfoutput><a href="ValidateDailyCensus.cfm?sortby=residentname&dtCompare=#dtCompare#"><b>Resident Name</b></a></cfoutput></td>
            <td><b>Payor Type</b> </td>
            <td><b>Previous Day Status (Y/N) <cfoutput>#BeginDate#</cfoutput></b> </td>
            <td><b>Current Status in Bed @Midnight (Y/N) <cfoutput>#CompareDate#</cfoutput></b> </td>
            <td><b>Expected Date of Move-Out (MM/DD/YYYY) </b> </td>
<!---             <td><b>Discharge Date (MM/DD/YYYY)</b> </td> --->
          </tr>
          <cfoutput query="validatehouse">
            <input type="hidden" name="iTenant_ID" value="#iTenant_ID#" />
            <input type="hidden" name="PreviousStatus_#iTenant_ID#" value="#ValidateHouse.PreviousStatus#" />
			<input type="hidden" name="residency_#iTenant_ID#" value="#ValidateHouse.cDescription#" />
            
            <!--- <input type="hidden" name="dtMoveOut" value="#DateFormat(validatehouse.dtMoveOut, "mm/dd/yyyy")#"> --->
            <tr align="center">
            	<td width="30"> #cAptNumber# </td>
              	<td> #iTenant_ID# </td>
              	<cfif #iTenant_ID# neq ''>
                	<td nowrap="nowrap"> #cLastName#, #cFirstName# </td>
                	<td> <CFif #validatehouse.cDescription# eq 'Medicaid'> <span style="background-color: yellow"> #cDescription# </span> <cfelse> #cDescription# </cfif> </td>
                	<td nowrap="nowrap">
						<cfif validatehouse.PreviousStatus neq ''>
			        	    #ValidateHouse.PreviousStatus#
            		    <cfelse>
			            	No Previous Status
            		    </cfif>
	                </td>
					<td>
					  <!--- onchange="close_other_box('CSB#iTenant_ID#', '#iTenant_ID#')" --->
					  <select name="CSB#iTenant_ID#" ID="CSB#iTenant_ID#">
					  <!---Mshah added here --->
						 <CFif #validatehouse.cDescription# eq 'Medicaid'>
						    <option value=""  style="background:red" <CFIF CurrentStatusInBedAtMidnight eq ''>selected="selected"</CFIF>> </option>
						    <option value="Y" <CFIF CurrentStatusInBedAtMidnight eq 'Y'>selected="selected"</CFIF>>Y</option>
							<option value="N" <CFIF CurrentStatusInBedAtMidnight eq 'N'>selected="selected"</CFIF>>N</option>
						 <cfelse>
						 	<option value="Y" <CFIF CurrentStatusInBedAtMidnight eq 'Y'>selected="selected"</CFIF>>Y</option>
							<option value="N" <CFIF CurrentStatusInBedAtMidnight eq 'N'>selected="selected"</CFIF>>N</option>
						 </cfif>
					<!---Mshah--->
					  </select>
					</td>
					<!---
					<td>
						<!--- Disable Notice Of Discharge drop down box --->
						<select name="ND_#iTenant_ID#">
						  <option value="Y" <CFIF NoticeOfDischarge eq 'Y'>selected="selected"</CFIF>>Y</option>
						  <option value="N" <CFIF NoticeOfDischarge eq 'N'>selected="selected"</CFIF>>N</option>s
						</select>
					</td>
					--->
					<td align="center">
						<input name="Date_#iTenant_ID#" type="text" size="10"
							<CFIF DischargeDate neq '' and DischargeDate neq '01/01/1900'> 
								value = "#DateFormat(DischargeDate, 'MM/DD/YYYY')#" 
							<CFELSEIF PreviousDischargeDate neq '' and PreviousDischargeDate neq '01/01/1900'> 
								value = "#DateFormat(PreviousDischargeDate, 'MM/DD/YYYY')#" 
							</CFIF>
							>
						</input>
					</td>
                <cfelse>
					<td></td>
					<td></td>
					<td nowrap="nowrap"></td>
					<td></td>
					<td></td>
					<td></td>
              </cfif>
            </tr>
    
            <input type="hidden" name="queryCount" id="queryCount" value="CSB#iTenant_ID#" /> <!---Mshah added for getting medicaid count in funtion validate--->
         </cfoutput>
        </table>
		<table align="center">
			<tr align="center">
				<td>
						<!---<input type="button" onclick=" isValidDate(); required();" value="Submit">--->
					<input type="button" onclick=" isValidDate();" value="Submit">
					<input type="reset" value="Clear" />
				</td>
			</tr>
		</table>
	</form>
</body>
</html>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">