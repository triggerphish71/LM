<!----------------------------------------------------------------------------------------------
| DESCRIPTION - TrackDailyCensus.cfm                                                           |
|----------------------------------------------------------------------------------------------|
| Records all the Tenants			 	                                                       |
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
| Called by ValidateDailyCensus.cfm															   |     
| Calls TrackTenantStatus.cfm                                                                  |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| fzahir     | 02/02/2006 | To show all tenants in a house. Based on the tenants status, set   | 
|            |            | appropriate flag. If tenant is moving out, enter MoveOut date.     |
| MLAW       | 05/01/2006 | Check to see if DailyCensusTrack has any records                   |
| MLAW       | 07/25/2006 | Add Logic for Transfer/Relocate                                    |
| RSchuette  | 03/17/2010 | 51267 - Remove link for relocate and MO							   |
----------------------------------------------------------------------------------------------->

<!---  CreateODBCDateTime(now()) --->
<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<!--- Set (CompareDate - 1) --->
<cfset PrevDate = #DateFormat(dateadd("d", -1, #CompareDate#), "mm/dd/yyyy")#>
	
<!--- Set Local Variables --->
<cfparam name="DisplayMessage" default="false" type="boolean">
<cfparam name="DisplayMessage1" default="false" type="boolean">

<!--- ==============================================================================
Retrieve database TimeStamp
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- Create an Array --->
<cfset TenantArray = ArrayNew(1)>

<!--- Create a loop --->
<cfloop list="#iTenant_ID#" index="loopvar">
	<!--- create the tenant structure --->
	<cfset TenantStruct = StructNew()>
	<!--- set the tenant structure members --->
	<cfset TenantStruct.tenantId = "">
	<cfset TenantStruct.FullName = "">
	<cfset TenantStruct.CurrentStatus = "">
	<cfset TenantStruct.PreviousStatus = "">
	<cfset TenantStruct.NoticeOfDischarge = "N">
	<cfset TenantStruct.DateMoveOut = "">
	<cfset TenantStruct.tenantId = loopvar>
	<cfset TenantStruct.PreviousStatus  =  form["PreviousStatus_#loopvar#"]>
	<cfset TenantStruct.CurrentStatus  =  form["CSB#loopvar#"]>
 	<cfif isdefined("form.Date_#loopvar#")>
		<cfset TenantStruct.DateMoveOut = form["Date_#loopvar#"]>
		<cfset TenantStruct.NoticeOfDischarge = "Y">
	</cfif> 
	<!--- 	
	<cfif isdefined("form.ND_#loopvar#")>
		<cfset TenantStruct.NoticeOfDischarge = form["ND_#loopvar#"]>
	</cfif> 
	--->

	<!--- Get Tenant Names --->
	<cfquery name="tenantname" datasource="#application.datasource#">
		select 
			iTenant_ID
			, cLastName
			, cFirstName 
		from 
			tenant 
		where 
			iTenant_ID =  #TenantStruct.tenantId#
	</cfquery>
	
	<!--- set the final values of the structure --->	
	<cfset TenantStruct.FullName = tenantname.cLastName & " " & tenantname.cFirstName>
	
	<!--- Check to see if there are records in the system already --->
	<cfquery name="CheckCensusTrack" datasource="#application.datasource#">	
		select * 
		from 
			DailyCensusTrack d
		where
			d.itenant_ID = #TenantStruct.tenantId#
		  and
			d.census_date = '#CompareDate#'
		  and
		    dtrowdeleted is NULL	
	</cfquery>
	<!--- if there are records, then delete the old records --->
	<cfif CheckCensusTrack.Recordcount gt 0>
	   <cfquery name="DeleteCensusTrack" datasource="#application.datasource#">
		   delete from DailyCensusTrack
		   where 
				itenant_ID = #TenantStruct.tenantId#
			 and 
				census_date = '#CompareDate#'
		</cfquery>
	</cfif>
		
	<!--- if the CurrentStatus is 'Y' then insert it --->
	<cfif TenantStruct.CurrentStatus is "Y">
		<!--- Insert DailyCensusTrack --->
		<cfquery name="InsertCensusTrack" datasource="#application.datasource#">		
			insert into DailyCensusTrack 
				(
				  iTenant_ID
				, iLeaveStatus_ID
				, Census_Date
				, DischargeDate
				, CurrentStatusinBedAtMidnight
				, TempStatusOutDate
				, iRowStartUser_ID
				, dtRowStart
				, cRowStartUser_ID
				)
			values 
			(
				#TenantStruct.tenantId#
				, 0
				, '#CompareDate#'
				, '#TenantStruct.DateMoveOut#' 
				, 'Y'
				, ''
				, #SESSION.UserID#
				, getdate()
				, 'TrackDailyCensus'
			)		
		</cfquery>
		<cfset DisplayMessage = true>				
	<cfelse>
		<!--- if the previous status is "N" then copy it to the new date --->
		<!---
		<cfif TenantStruct.PreviousStatus is "N">
			<cfquery name="GetPreviousCensusTrackFor_N" datasource="#application.datasource#">
				SELECT 
					iTenant_ID
					,iLeaveStatus_ID 
					,Census_Date
					,CurrentStatusInBedAtMidnight 
					,NoticeOfDischarge
					,TempWhere
					,DischargeDate
					,iRowStartUser_ID 
					,cRowStartUser_ID
				FROM
					DailyCensusTrack dct
				WHERE
					dct.itenant_ID = #TenantStruct.tenantId#
				order by 
					Census_Date desc
			</cfquery>
				
			<cfquery name="InsertCensusTrackFor_N" datasource="#application.datasource#">		
			insert into DailyCensusTrack 
				(
				  iTenant_ID
				, iLeaveStatus_ID
				, Census_Date
				, CurrentStatusinBedAtMidnight
				, NoticeOfDischarge
				, TempWhere
				, DischargeDate				
				, TempStatusOutDate
				, iRowStartUser_ID
				, dtRowStart
				, cRowStartUser_ID
				)
			values 
			(
				  #TenantStruct.tenantId#
				, #GetPreviousCensusTrackFor_N.iLeaveStatus_ID#
				, '#CompareDate#'
				, 'N'
				, '#GetPreviousCensusTrackFor_N.NoticeOfDischarge#'
				, '#GetPreviousCensusTrackFor_N.TempWhere#'
				, '#TenantStruct.DateMoveOut#'
				, '#CompareDate#'
				, #SESSION.UserID#
				, getdate()
				, 'TrackDailyCensus'
			)		
			</cfquery>
		<cfelse>
		--->
			<!--- Put all the 'N' to an array --->
			<cfset DisplayMessage1 = true>
			<cfset temp = ArrayAppend(TenantArray,TenantStruct)>
		<!--- </cfif> --->
	</cfif>
</cfloop>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Daily Census Tracking</title>

<!--- Get all the leave status codes --->
<cfquery name="GetStatus" DATASOURCE="#application.datasource#">
SELECT distinct 
	 LSM.cDescription
	,LSM.iLeaveType_ID
FROM 
	LeaveStatusMaster LSM
</cfquery>

<!--- Get all the StatusWheretoGo --->
<cfquery name="GetWhereToGo" DATASOURCE="#application.datasource#">
SELECT 
	 LS.iLeaveStatus_ID
	,LS.cLeaveStatus
	,LS.iLeaveType_ID
FROM 
  LeaveStatus LS
ORDER BY 
	cLeaveStatus
</cfquery>

<!--- 
	<CFSET CurrentYear = DateFormat(NOW(), "yyyy")>
	<CFSET CurrentMonth = DateFormat(NOW(),"mm")>
	<CFSET CurrentDay = DateFormat(NOW(),"dd")>
	<cfoutput>
	#CurrentYear#
	#CurrentMonth#
	#CurrentDay#
	</cfoutput> 
--->

<script language = "JavaScript">
	// Create the array
    WhereToGoArray = new Array();
     
	<cfset i = 0>

	<cfoutput query="GetWhereToGo">
	   
	   InnerArray = new Array();
	   
	   // Populate the array
	  	InnerArray[1] = #iLeaveStatus_ID#; //leave stautsid
		InnerArray[2] = '#cLeaveStatus#'; //leave type
		InnerArray[3] = #iLeaveType_ID#; //leave typeid
		
		WhereToGoArray[#i#] = InnerArray;
	  	<cfset i = i + 1>
	 </cfoutput>

	//clear the options in a drop down menu
	function ClearDropDown(object)
	{
		//don't delete the first option "Select One..."
		for(i = object.length; i > 0; i--)
		{
			object.remove(i);
		}
	}

	function PopulateWhereToGo(objName,tenantId) 
	{
		//create a variable with the where to go dropdown for this specific tenant
		var whereToGoDropDown = document.getElementsByName('Place_' + tenantId)[0];
		var statusDropDown = document.getElementsByName(objName)[0];
		
		//first clear all the options in the where to select list
		ClearDropDown(whereToGoDropDown);
		
		//get the id of the selected status
		var selectedLeaveTypeId = statusDropDown.options[statusDropDown.selectedIndex].value;
	
		//loop through the WhereToGoArray array and match status id, if they match add it to the drop down		
		for(i = 0; i < WhereToGoArray.length; i++)
		{
			//alert(WhereToGoArray[i][3]);
			
			if(WhereToGoArray[i][3] == selectedLeaveTypeId)
			{
				var newOption = document.createElement('option');
				newOption.text = WhereToGoArray[i][2];
				newOption.value = WhereToGoArray[i][1];
				whereToGoDropDown.options.add(newOption);
			}
		}
	}

	function close_other_box(objName, itenantID)
	{
		//define vars
		var box = document.getElementsByName(objName)[0];
		var returndate = document.getElementsByName('ReturnDate_' + itenantID)[0];
		
		//testing message
		//alert(box.selectedIndex);
			if(box.selectedIndex == 0 || box.selectedIndex == 1)
			{
				returndate.disabled=true
			}
			else
			{
				returndate.disabled=false
			}
	}

	function disable_other_box(objName, itenantID)
	{
		//define vars
		var box = document.getElementsByName(objName)[0];
		var leavetype = document.getElementsByName('Status_' + itenantID)[0]
		var whereto = document.getElementsByName('Place_' + itenantID)[0]
		var returndate = document.getElementsByName('ReturnDate_' + itenantID)[0];		
		var flag = false;
		//testing message
		//alert(box.selectedIndex);
		if(box.checked == true )
		{	
			leavetype.disabled=true
			whereto.disabled=true
			returndate.disabled=true
		}
		else
		{
			leavetype.disabled=false
			whereto.disabled=false
			returndate.disabled=false
		}
	}

	function SubmitForm()
	{
		//create a var for the form
		var theForm = document.getElementsByName('tenantstatus')[0];
		var arraySelectItems = theForm.getElementsByTagName('select');
		var arrayInputItems = theForm.getElementsByTagName('input');
		inputArray = document.getElementsByTagName('Input');
		//loop through the select items
		for(i = 0; i < arrayInputItems.length; i++)
		{			
			if(arrayInputItems[i].name.indexOf('relocate_') != -1) 
			{
				var box = arrayInputItems[i]
				if (box.checked == true)
				{
					var TenantId = '';
				}
				else
				{
					var TenantId = (arrayInputItems[i].name.substring(9))
				}
				for(y = 0; y < arraySelectItems.length; y++)
				{
					//the first select we we are looking at is the status, make sure something is selected
					if(arraySelectItems[y].name.indexOf('Status') != -1) 
					{
						var StatusTenantId = (arraySelectItems[y].name.substring(7))
						//alert(StatusTenantId);
						//alert(TenantId);
						if (TenantId == StatusTenantId)
						{
							if(arraySelectItems[y].selectedIndex == 0)
							{
								alert('Please select a valid leave type for all tenants.');
								arraySelectItems[y].focus();
								//exit the function
								return;
							}
						}
					}
					else if(arraySelectItems[y].name.indexOf('Place') != -1)
					{
						var PlaceTenantId = (arraySelectItems[y].name.substring(6))
						//alert(arraySelectItems[i].selectedIndex);
						if (TenantId == PlaceTenantId)
						{
							if(arraySelectItems[y].selectedIndex == 0)
							{
								alert('Please select a valid place for all tenants.');
								arraySelectItems[y].focus();
								//exit the function
								return;
							}
							else
							if(arraySelectItems[y].selectedIndex == -1)
							{
								alert('Please re-select a leave type for the tenants without a valid place.');
								//ClearDropDown(Status_#TenantArray[i].tenantId#)
								//arraySelectItems[i].focus();
								//exit the function
								return;
							}
						}					
					}
				}
			}	
			var TenantId ='';		
		}
					
		//loop through the select items
		for(i = 0; i < arraySelectItems.length; i++)
		{
			//the first select we we are looking at is the status, make sure something is selected
			if(arraySelectItems[i].name.indexOf('Status') != -1) 
			{    var leavetype = arraySelectItems[i].selectedIndex;
				if(arraySelectItems[i].selectedIndex == 0)
				{ 			
					alert('Please select a valid leave type for all tenants.');
					arraySelectItems[i].focus();
					//exit the function
					return;
				}
			}
			//the second select we we are looking at is the place, make sure something is selected
			else	if(arraySelectItems[i].name.indexOf('Place') != -1)
			{
				//alert(arraySelectItems[i].selectedIndex);
				if(arraySelectItems[i].selectedIndex == 0)
				{
					alert('Please select a valid place for all tenants.');
					arraySelectItems[i].focus();
					//exit the function
					return;
				}
				else
				if(arraySelectItems[i].selectedIndex == -1)
				{
					alert('Please re-select a leave type for the tenants without a valid place.');
					//ClearDropDown(Status_#TenantArray[i].tenantId#)
					//arraySelectItems[i].focus();
					//exit the function
					return;
				}					
			}
			//alert (leavetype);
			if (leavetype == 2)
			{
				var TenantId = (arraySelectItems[i].name.substring(7))
				for(z = 0; z < inputArray.length; z++)
					{
					//the first select we we are looking at is the returndate, make sure something is selected
						if(inputArray[z].name.indexOf('ReturnDate_') != -1) 
						{
						var ReturnDateTenantId = (inputArray[z].name.substring(11));
						//alert (ReturnDateTenantId);
						//alert (TenantId);
						if (TenantId == ReturnDateTenantId)
							{
							 var dateStr = inputArray[z].value;
							 //alert (dateStr);
							 if (dateStr  == "")
								{
								 alert('return date must be given!');
								 return ;
								}
							else 
								{
								 var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{4})$/;
								 var matchArray = dateStr.match(datePat);
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
						
						}
					}
			}
		}
		
		// check Date
		//get all the input field
		
				
		/*for(i = 1; i < inputArray.length; i++)
		{
			
			if(inputArray[i].name.indexOf('ReturnDate_') != -1)
			{
				var dateStr = inputArray[i].value;
				
				// Checks for the following valid date formats:
				// MM/DD/YY   MM/DD/YYYY   MM-DD-YY   MM-DD-YYYY
				// Also separates date into month, day, and year variables

				if (dateStr != '')
				{
					var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{2}|\d{4})$/;
					
					// To require a 4 digit year entry, use this line instead:
					// var datePat = /^(\d{1,2})(\/|-)(\d{1,2})\2(\d{4})$/;
				
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
					//if (dateStr < CurrentDate)
					//{
						//alert ("The Expected Date of Return cannot be less than Current Date!");
						//return false;
					//}
				}
			}
		}	*/
		//if the function hasn't exited by this point nothing is wrong, submit the form
		theForm.submit();
	}
</script>

</head>

<body >
	<cfif DisplayMessage1> 
	<table align="center">
		<tr valign="top">
			<td align="center">
				<h2><b>
					Check Tenant Status
				</b></h2>
			</td>
		</tr>
	</table>

	<form name="tenantstatus" id="tenantstatus" action="TrackTenantStatus.cfm" method="post" >
	<input type="hidden" name="CompareDate" value="<cfoutput>#CompareDate#</cfoutput>">
	<table border="1" align="center">
		<tr align="right" >
			<td>
				<div align="center"><b>TenantID</b>
			      </div></td>
			<td>
				<div align="center"><b>Name</b>
			      </div></td>
		<!--- 51267 RTS - 3/17/2010 - remove column header --->
			<!--- <td>
				<div align="center"><b><font color="#FF0000">Relocate</b></font>
			      </div></td> --->
		<!--- end 51267 --->
			<td>
				<div align="center"><b>Leave Type</b>
			      </div></td>
			<td>
				<div align="center"><b>Where To</b>
			      </div></td>
			<td>
				<div align="center"><b>Expected Date of Return</b>
			      </div></td>
	  </tr>
		<cfoutput>
			<cfloop from="1" to="#ArrayLen(TenantArray)#" index="i">

				<!--- Check to see if there are any previous records in the system --->
				<cfquery name="GetPrevCensusTrack" datasource="#application.datasource#">	
					select 
						TempStatusInDate as ReturnDate
						, LSM.ileavetype_ID as LeaveTypeID
						, dc.ileavestatus_ID as LeaveStatusID
					from 
						dailycensustrack dc
					join LeaveStatus LS 
					on LS.iLeaveStatus_ID = dc.iLeaveStatus_ID
					join LeaveStatusmaster LSM
					on LSM.ileavetype_ID = LS.ileavetype_ID
					where 
						itenant_ID = #TenantArray[i].tenantId#
					and 
						Census_date = '#PrevDate#'
					and
						dc.dtrowdeleted is NULL	
				</cfquery>
				<!--- if there are records, then delete the old records --->
				<cfif GetPrevCensusTrack.Recordcount gt 0>
					<cfset ReturnDate = #DateFormat(GetPrevCensusTrack.ReturnDate, "mm/dd/yyyy")#>
					<cfset LeaveTypeID = #GetPrevCensusTrack.LeaveTypeID#>
					<cfset LeaveStatusID = #GetPrevCensusTrack.LeaveStatusID#>
				<cfelse>
					<cfset ReturnDate = ''>
					<cfset LeaveTypeID = ''>
					<cfset LeaveStatusID = 'Select Where To Go'>				
				</cfif>				

				<cfif #TenantArray[i].CurrentStatus# is "N">
					<input type="hidden" name="iTenant_ID" value="#TenantArray[i].tenantId#">
						<tr align="center">
							<td align="center">
								#TenantArray[i].tenantId#
							</td>
							<td align="left">
								#TenantArray[i].FullName#
							</td>
							<!--- 51267 - RTS - 3/17/2010 - Remove Link for relocate. --->
							<!--- <td>
								<input name="relocate_#TenantArray[i].tenantId#" type="checkbox" value="" />
							</td> --->
							<!--- end 51267 --->
							<td>
							     <select name="Status_#TenantArray[i].tenantId#" onClick=
								 "PopulateWhereToGo('Status_#TenantArray[i].tenantId#','#TenantArray[i].tenantId#')
								 ;close_other_box('Status_#TenantArray[i].tenantId#','#TenantArray[i].tenantId#')">
									<option value="0">Select Type</option>
										<cfloop query="GetStatus">
										   <option value="#iLeaveType_ID#" <CFIF #iLeaveType_ID# eq #LeaveTypeID#>selected="selected"</CFIF>>
										   		#cDescription#
										   </option>  
										</cfloop>
								 </select>
							</td>
						    <td>
								<select name="Place_#TenantArray[i].tenantId#" width="70" style="width:150" size="1">
									<option value="0">Select Where To Go</option>
									<cfloop query="GetWhereToGo">								
										<cfif GetWhereToGo.iLeaveType_ID eq LeaveTypeID>
									    	<option value="#GetWhereToGo.iLeaveStatus_ID#" <CFIF #GetWhereToGo.iLeaveStatus_ID# eq #LeaveStatusID#>selected="selected"</CFIF>>
												#GetWhereToGo.cLeaveStatus#
										 	</option>
										</cfif>
									</cfloop>
							  	</select>
						   </td>
 							<td>
								<input name="ReturnDate_#TenantArray[i].tenantId#" type="text" size="10" 
								<CFIF ReturnDate neq '' and ReturnDate neq '01/01/1900'>
								  value = "#DateFormat(ReturnDate, 'MM/DD/YYYY')#" 
								</CFIF>
								/>
							</td>
							<td>
								<input name="ND_#TenantArray[i].tenantId#" type="hidden" value="#TenantArray[i].NoticeOfDischarge#" />
							</td>
 							<td>
								<input name="Date_#TenantArray[i].tenantId#" type="hidden" value="#TenantArray[i].DateMoveOut#" />
							</td>
 							<td>
								<input name="FullName_#TenantArray[i].tenantId#" type="hidden" value="#TenantArray[i].FullName#" />
							</td>
						</tr>
			  </cfif>
		  </cfloop>
	  </cfoutput>
	  </table>	
		<table align="center">
			<tr align="center">
				<td>
					<input type="button" name="SubmitButton" value="Submit" onClick="SubmitForm(this)">
					<!--- <input name="ClearButton" type="button" value="Clear" onClick="ClearDropDown(this)"/> --->
				</td>
			</tr>
	  </table>

	</form>
	<cfelse>
		<table align="center">
			<tr align="center">
				<td>
					<b>Please process the Daily Census Approval.</b>
				</td>
			</tr>
		</table>
		<table align="center">
			<tr align="center">
				<!--- <td><INPUT TYPE="button" VALUE="Go Back" OnClick="JavaScript:history.go(-1)"></td> --->
				<td><INPUT TYPE="button" VALUE="Continue" OnClick="window.location.href='census.cfm';"></td>
			</tr>
		</table>
	</cfif>
	
</body>
</html>

<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">