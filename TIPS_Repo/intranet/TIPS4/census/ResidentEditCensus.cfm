<!---<cfdump var="#form#">--->

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Validate Daily Census</title>
</head>



<!---  CreateODBCDateTime(now()) --->
<cfif not isDefined("session.qselectedhouse.ihouse_id") or not isDefined("session.userid")>
	<cflocation url="../../Loginindex.cfm" addtoken="yes">
</cfif>

<!--- Include Intranet header --->
<cfinclude template="../../header.cfm">

<!--- Include the page for house header --->
<cfinclude template="../Shared/HouseHeader.cfm">

<body>
<table align="center">
<tr valign="top">
	<td align="center">
		<h3><b>Edit Daily Census</b></h3>
	</td>
</tr>
</table>
<p>
<cfset censusdate = #ParseDateTime(form.prompt1)#> 
<cfset CensusStartDate = createDate(year(censusdate), month(censusdate), 1)> 
<cfset CensusEndDate = dateAdd("d", -1, dateAdd("m", 1, CensusStartDate))> 

<!---<cfoutput> 
CensusStartDate = #CensusStartDate#<br> 
CensusEndDate = #CensusEndDate#<br> 
</cfoutput>--->


<cfquery name="CheckCensus" datasource="#application.datasource#">
	select t.cfirstname,t.clastname,t.itenant_ID,dc.*,ls.iLeavestatus_ID, LSM.ileavetype_ID from 
	Tenantstate ts join Tenant t on t.itenant_ID= ts.itenant_ID 
	join dailycensustrack dc on ts.itenant_ID=dc.itenant_ID
	join dailycensus d on dc.census_date = d.census_date
	left join LeaveStatus LS on LS.iLeaveStatus_ID = dc.iLeaveStatus_ID
	Left join LeaveStatusmaster LSM	on LSM.ileavetype_ID = LS.ileavetype_ID
	where ts.itenant_ID = #PROMPT0# 
	and dc.census_date between #CensusStartDate# and #CensusEndDate#
	and t.dtrowdeleted is null
	and ts.dtrowdeleted is null
	and dc.dtrowdeleted is null
	and d.dtrowdeleted is null
	and d.ihouse_ID= #session.qselectedhouse.ihouse_ID#
	order by census_date
</cfquery>
	<!---<cfdump var="#CheckCensus#">--->

	<cfquery name="LeaveStatus" datasource="#application.datasource#">
	Select * from Leavestatus
	</cfquery>
	<!---<cfdump var="#LeaveStatus#">--->
	
	<cfquery name="LeaveType" datasource="#application.datasource#">
	Select * from Leavestatusmaster
	</cfquery>
	<!---<cfdump var="#LeaveType#">--->
	
	<!---Mshah added query to check for medicaid recordcount--->
	<cfquery name="Medicaidrecordcount" datasource="#application.datasource#">
	select * from tenant t join tenantstate ts on ts.itenant_ID=t.itenant_ID
	where ts.itenantstatecode_ID=2
	and ts.iresidencytype_ID= 2
	and ts.dtrowdeleted is null
	and t.dtrowdeleted is null
	and t.itenant_ID= #PROMPT0# 
	</cfquery>
	<!---<cfdump var="#Medicaidrecordcount#">--->
	<!---Mshah--->
	
	
	<script language="JavaScript">
				//Create the array
				WhereToGoArray = new Array();
				 
				<cfset i = 0>
			
				<cfoutput query="LeaveStatus">
				   
				   InnerArray = new Array();
				   
				   // Populate the array
				  	InnerArray[1] = #iLeaveStatus_ID#; //leave stautsid
					InnerArray[2] = '#cLeaveStatus#'; //leave type
					InnerArray[3] = #iLeaveType_ID#; //leave typeid
					
					WhereToGoArray[#i#] = InnerArray;
				  	<cfset i = i + 1>
				 </cfoutput>
				function ClearDropDown(object)
				{
					//don't delete the first option "Select One..."
					for(i = object.length; i > 0; i--)
					{
						object.remove(i);
					}
				}
				function test(newstatusObj,leaveTypeObj)
				{
					//alert (newstatusObj);

					var newstatus = document.getElementsByName(newstatusObj)[0];

					var selectednewStatusId = newstatus.options[newstatus.selectedIndex].value;
				
					//alert(selectednewStatusId);
					//alert(document.getElementById('leaveTypeh').value);
					//alert(leaveTypeObj);
					if(selectednewStatusId == 'N' && document.getElementById('leaveTypeh').value == 'test' )
					{
						//alert("inside if");
						var leaveType = document.getElementsByName(leaveTypeObj)[0];

						var selectedleaveType = leaveType.options[leaveType.selectedIndex].value;
					
						//document.getElementById('leaveStatush').value = selectedleaveStatus;
						
						document.getElementById('leaveTypeh').value = selectedleaveType;
						
						//alert(selectedleaveType);
						//alert(document.getElementById('leaveTypeh').value);
						//document.getElementById('leaveType_2').value = document.getElementById('leaveTypeh').value;	
					}
					
					
				}
				
				
				function SelectedLeaveStatus(newstatusObj,leaveStatusObj)
				{
					//alert (newstatusObj);
					//alert (leaveStatusObj);

					var newstatus = document.getElementsByName(newstatusObj)[0];

					var selectednewStatusId = newstatus.options[newstatus.selectedIndex].value;
				
					//alert(selectednewStatusId);
					//alert(document.getElementById('leaveStatush').value);
					//alert(leaveStatusObj);
					if(selectednewStatusId == 'N' && document.getElementById('leaveStatush').value == 'test' )
					{
						//alert("inside if");
						var leaveStatus = document.getElementsByName(leaveStatusObj)[0];

						var selectedleaveStatus = leaveStatus.options[leaveStatus.selectedIndex].value;
					
						//document.getElementById('leaveStatush').value = selectedleaveStatus;
						
						document.getElementById('leaveStatush').value = selectedleaveStatus;
						
						//alert(selectedleaveStatus);
						//alert(document.getElementById('leaveTypeh').value);
						//document.getElementById('leaveType_2').value = document.getElementById('leaveTypeh').value;	
					}
					
					
				}

				
				
				function Selectedreturndate(newstatusObj,ExpectedDateofReturnObj)
				{
					//alert (newstatusObj);
					//alert (ExpectedDateofReturnObj);

					var newstatus = document.getElementsByName(newstatusObj)[0];

					var selectednewStatusId = newstatus.options[newstatus.selectedIndex].value;
				
					//alert(selectednewStatusId);
					//alert(document.getElementById('ExpectedDateofReturnh').value);
					//alert(ExpectedDateofReturnObj);
					if(selectednewStatusId == 'N' && document.getElementById('ExpectedDateofReturnh').value == '' )
					{
						//alert("inside if");
						var ExpectedDateofReturn1 = document.getElementById(ExpectedDateofReturnObj).value;

						// alert (ExpectedDateofReturn1);
						
						document.getElementById('ExpectedDateofReturnh').value = ExpectedDateofReturn1;
						
						//alert('test');
						//alert(document.getElementById('ExpectedDateofReturnh').value);
						//document.getElementById('leaveType_2').value = document.getElementById('leaveTypeh').value;	
					}
					
					
				}
				
				
				function SelectedMoveOutdate(newstatusObj,ExpectedDateofMoveoutObj)
				{
					//alert (newstatusObj);
					//alert (ExpectedDateofMoveoutObj);

					var newstatus = document.getElementsByName(newstatusObj)[0];

					var selectednewStatusId = newstatus.options[newstatus.selectedIndex].value;
				
					//alert(selectednewStatusId);
					//alert(document.getElementById('ExpectedDateofMoveouth').value);
					//alert(ExpectedDateofReturnObj);
					if(selectednewStatusId == 'N' && document.getElementById('ExpectedDateofMoveouth').value == '' )
					{
						//alert("inside if");
						var ExpectedDateofMoveout1 = document.getElementById(ExpectedDateofMoveoutObj).value;

						// alert (ExpectedDateofMoveout1);
						
						document.getElementById('ExpectedDateofMoveouth').value = ExpectedDateofMoveout1;
						
						//alert('test');
						//alert(document.getElementById('ExpectedDateofReturnh').value);
						//document.getElementById('leaveType_2').value = document.getElementById('leaveTypeh').value;	
					}
					
					
				}

				
				function SelectedReason(newstatusObj,ReasontochangeObj)
				{
					//alert (newstatusObj);
					//alert (ReasontochangeObj);

					var newstatus = document.getElementsByName(newstatusObj)[0];

					var selectednewStatusId = newstatus.options[newstatus.selectedIndex].value;
				
					//alert(selectednewStatusId);
					//alert(document.getElementById('Reasontochangeh').value);
					//alert(ExpectedDateofReturnObj);
					if(selectednewStatusId == 'N' && document.getElementById('Reasontochangeh').value == '' )
					{
						//alert("inside if");
						var Reasontochange1 = document.getElementById(ReasontochangeObj).value;

						// alert (Reasontochange1);
						
						document.getElementById('Reasontochangeh').value = Reasontochange1;
						
						//alert('test');
						//alert(document.getElementById('ExpectedDateofReturnh').value);
						//document.getElementById('leaveType_2').value = document.getElementById('leaveTypeh').value;	
					}
					
					
				}
				
				
				function Autodropdown(newstatusObj,leaveTypeObj,leaveStatusObj,ExpectedDateofReturnObj,ExpectedDateofMoveoutObj,ReasontochangeObj)
				{
					//alert (leaveTypeObj);

					var newstatus = document.getElementsByName(newstatusObj)[0];

					var selectednewStatusId = newstatus.options[newstatus.selectedIndex].value;
					//alert(selectednewStatusId);
					//alert(document.getElementById('leaveTypeh').value);
					//alert(document.getElementById('leaveStatush').value);
					if(selectednewStatusId == 'N' && document.getElementById('leaveTypeh').value != 'test' )
					{
						var leaveType = document.getElementsByName(leaveTypeObj)[0];
						var leaveStatus = document.getElementsByName(leaveStatusObj)[0];
						var selectedleaveType = leaveType.options[leaveType.selectedIndex].value;
						var selectedleaveStatus = leaveStatus.options[leaveStatus.selectedIndex].value;
						//alert(leaveType);
						//alert(selectedleaveType);
						document.getElementById(leaveTypeObj).value = document.getElementById('leaveTypeh').value;	
						document.getElementById(leaveStatusObj).value = document.getElementById('leaveStatush').value;
						document.getElementById(ExpectedDateofReturnObj).value = document.getElementById('ExpectedDateofReturnh').value;
						document.getElementById(ExpectedDateofMoveoutObj).value = document.getElementById('ExpectedDateofMoveouth').value;
						document.getElementById(ReasontochangeObj).value = document.getElementById('Reasontochangeh').value;
					}
					
					//alert(selectednewStatusId);
					//alert(leaveTypeObj);
					//alert(leaveStatusObj);
					if(selectednewStatusId == 'Y')
					{
						document.getElementById(ReasontochangeObj).value= '';
						document.getElementById(ExpectedDateofReturnObj).value='';
						document.getElementById(ExpectedDateofMoveoutObj).value='';
						document.getElementById(leaveTypeObj).value=0;
						document.getElementById(leaveStatusObj).value=0;
					}
						
					if(selectednewStatusId == 'N'  && document.getElementById('leaveTypeh').value == 'test' )
					{
						document.getElementById(ReasontochangeObj).value= '';
					}
							
				}				
				function PopulateWhereToGo(objName,currentrow) 
				{
					//alert ('test');
					
					//create a variable with the where to go dropdown for this specific tenant
					var whereToGoDropDown = document.getElementsByName('Leavestatus_' +currentrow )[0];
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
				
				/*function resetfields(newstatusobj,currentstatusobj)
				{
					alert('test');
					alert(newstatusobj);
					var newstatus1 = document.getElementById(newstatusobj).value;
					alert(newstatus1);
					var currentstatus1 = document.getElementById(currentstatusobj).value;
					if (newstatus1=='Y' && currentstatus1=='N')
					{
						alert('reset');
						document.getElementById(currentstatusobj).value = NULL;
						
					}
				}*/
				
				
				function validateForm(cnt) {
					//alert(cnt);
					for(i = 1; i < cnt+1; i++)
					{
						eval("var x = document.CheckCensus1.newstatus_"+i+".value");
						//var x = 'document.CheckCensus1.newstatus_'+i;
						//alert(x);
						eval("var csb = document.CheckCensus1.CurrentStatus_"+i+".value");
						//alert(csb);
						if (x !== csb) 
						{   
							eval("var y = document.CheckCensus1.Reasontochange_"+i+".value");
							if (y == "") 
							{
								alert("Reason for change must be filled out");
								return false;
							}
						}
						
						//returndate
						if (x == "N") 
						{
							eval("var a = document.CheckCensus1.leaveType_"+i+".value");
							//alert(a);
							if (a == "0") 
							{
								alert("leaveType must be selected");
								return false;
							}
						}
						
						if (x == "N") 
						{
							eval("var b = document.CheckCensus1.LeaveStatus_"+i+".value");
							//alert(b);
							if (b == "0") 
							{
								alert("leaveStatus must be selected");
								return false;
							}
						}
						
						if (x == "N") 
						{
							eval("var z = document.CheckCensus1.ExpectedDateofReturn_"+i+".value");
							eval("var a = document.CheckCensus1.leaveType_"+i+".value");
							//alert(z);
							//alert (a);
							if (z == "" && a == 1 ) 
							{
								alert("Return Date must be filled out");
								return false;
							}
						}
					}
					//return false;
				//} function end

				
	//function SubmitForm()
	//{//create a var for the form
		//var arrayInputItems = theForm.getElementsByTagName('input');
		inputArray = document.getElementsByTagName('Input');
		
		for(i = 1; i < inputArray.length; i++)
		{
		
		if(inputArray[i].name.indexOf('ExpectedDateofReturn_') != -1)
		{
			var dateStr = inputArray[i].value;
			//alert (dateStr);
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
				//if (dateStr < CurrentDate)
				//{
					//alert ("The Expected Date of Return cannot be less than Current Date!");
					//return false;
				//}
			}
		}
	
		}
	//}
				
	//function approved(){
					//alert('test')
					cnt= document.CheckCensus1.queryCount.value;
					if (cnt > 0){
						var x = confirm('This daily census data is used by Enlivant to accurately calculate reimbursement amounts to which the company may be entitled From the relevant Medicaid waiver program state authority or its designated managed care organization.  By submitting this data, you are attesting that this census data is accurate and complete for each resident.  If you subsequently learn that this census data is incorrect for any reason, you must promptly submit a correction for each resident. \nClick OK to Approve and Cancel to return!');
					  if (x== true)
					  {
						 //alert('true') ;
						 document.CheckCensus1.submit();
					  }
					  else 
					  {
						 
						 // alert('false') ;
						 // window.location.replace("http://vmappprod01dev3/intranet/tips4/Census/Census.cfm") ;
						  return false; 
					  }
					}
				}
	</script>

	
	
<cfoutput>
<!---NAME="form#CheckCensus.itenant_ID#"--->
	<FORM NAME="CheckCensus1" ACTION="../census/ResidentUpdateCensus.cfm" onsubmit="return validateForm(#CheckCensus.RecordCount#); " METHOD="POST">
		<table align="center">
			  <tr align="center">
				 	<td> <h4> <b> Resident Name-	#CheckCensus.clastname#, #CheckCensus.cfirstname#	</b> </h4> </td> 
				 	<td> <h4> <b> Payor Type- Medicaid </b> </h4> </td>
			   </tr>
		</table>
		<p>
		<table border="1" align="center" >	   
			    <tr> 
			    	<td> Date </td>
			    	<td> Original Status </td>
			    	<td> New Status </td>
			    	<td> Reason for change </td>
			    	<td> Leave Type  </td>
			    	<td> Where To  </td>
			    	<td> Expected Date of Return  </td>
			    	<td> Expected Date of Move out  </td>
			    </tr>
			    <input type="hidden" name="tenantID" value="#CheckCensus.itenant_ID#">
			    <input type="hidden" name="leaveTypeh" id="leaveTypeh" value="test">
			    <input type="hidden" name="leaveTypeh" id="leaveStatush" value="test">
			    <input type="hidden" name="ExpectedDateofReturnh" id="ExpectedDateofReturnh" value="">
			    <input type="hidden" name="ExpectedDateofMoveouth" id="ExpectedDateofMoveouth" value="">
			    <input type="hidden" name="Reasontochangeh" id="Reasontochangeh" value="">
			    <input type="hidden" name="cnt" id="cnt" value=0>
			    <input type="hidden" name="queryCount" id="queryCount" value=<cfoutput>"#Medicaidrecordcount.RecordCount#"</cfoutput> /> 
			    
		<cfloop query="CheckCensus">
			<tr> 
			<input type="hidden" name="CensusDate_#CheckCensus.currentrow#" value="#CheckCensus.Census_date#">
			<input type="hidden" name="CurrentStatus_#CheckCensus.currentrow#" id="CurrentStatus_#CheckCensus.currentrow#" value="#CheckCensus.CURRENTSTATUSINBEDATMIDNIGHT#">
					<td> #Dateformat(Census_date, 'MM/DD/YYYY')# </td>
					<td> #CURRENTSTATUSINBEDATMIDNIGHT# </td>
					<td> 
					 	<select name="newstatus_#CheckCensus.currentrow#" id="newstatus_#CheckCensus.currentrow#" onChange="Autodropdown('newstatus_#CheckCensus.currentrow#','leaveType_#CheckCensus.currentrow#','leaveStatus_#CheckCensus.currentrow#','ExpectedDateofReturn_#CheckCensus.currentrow#','ExpectedDateofMoveout_#CheckCensus.currentrow#','Reasontochange_#CheckCensus.currentrow#');">	
							<option value="Y" <CFIF #CURRENTSTATUSINBEDATMIDNIGHT# eq 'Y'>selected="selected"</CFIF>>Y</option>
							<option value="N" <CFIF #CURRENTSTATUSINBEDATMIDNIGHT# eq 'N'>selected="selected"</CFIF>>N</option>
						</select>
					</td>
					<td> <input type="text" name="Reasontochange_#CheckCensus.currentrow#" value="#CheckCensus.reasoncensuschange#" id="Reasontochange_#CheckCensus.currentrow#"  onfocusout="SelectedReason('newstatus_#CheckCensus.currentrow#','Reasontochange_#CheckCensus.currentrow#');"> </td>
					<td> 
						<select name="leaveType_#CheckCensus.currentrow#" onChange="test('newstatus_#CheckCensus.currentrow#','leaveType_#CheckCensus.currentrow#')" onClick="PopulateWhereToGo('leaveType_#CheckCensus.currentrow#','#CheckCensus.currentrow#')";>
						<option value="0">Select Type  </option>
						<cfloop query ="LeaveType">
							<option value="#ILeavetype_ID#"<CFIF #CheckCensus.iLeavetype_ID# eq #Leavetype.ILeavetype_ID#>selected="selected"</CFIF> > #LeaveType.cdescription#</option>
						</cfloop>
						</select>
					</td>
					<td> 
						<select name="LeaveStatus_#CheckCensus.currentrow#" id="LeaveStatus_#CheckCensus.currentrow#" onChange="SelectedLeaveStatus('newstatus_#CheckCensus.currentrow#','leaveStatus_#CheckCensus.currentrow#')">
						<option value="0">Select  </option>
						<cfloop query ="LeaveStatus">
							<option value="#ILeaveStatus_ID#"<CFIF #CheckCensus.iLeavestatus_ID# eq #LeaveStatus.ILeaveStatus_ID#>selected="selected"</CFIF> > #LeaveStatus.cLeavestatus#</option>
						</cfloop>
					</td>
					
					
					
					<td> <input type="text" name="ExpectedDateofReturn_#CheckCensus.currentrow#" id="ExpectedDateofReturn_#CheckCensus.currentrow#"  value="<cfif #dateformat(CheckCensus.TempStatusInDate,'mm/dd/yyyy')# NEQ '01/01/1900'>#dateformat(CheckCensus.TempStatusInDate,'mm/dd/yyyy')#</cfif>" onfocusout="Selectedreturndate('newstatus_#CheckCensus.currentrow#','ExpectedDateofReturn_#CheckCensus.currentrow#');"> </td>
					
					<td> <input type="text" name="ExpectedDateofMoveout_#CheckCensus.currentrow#" id="ExpectedDateofMoveout_#CheckCensus.currentrow#" value="<cfif #dateformat(CheckCensus.DischargeDate,'mm/dd/yyyy')# NEQ '01/01/1900'>#dateformat(CheckCensus.DischargeDate,'mm/dd/yyyy')#</cfif>" onfocusout="SelectedMoveOutdate('newstatus_#CheckCensus.currentrow#','ExpectedDateofMoveout_#CheckCensus.currentrow#');"> </td>
				</tr>
				
		</cfloop>
		</table>
		<p>
		<table align="center">
		<tr align="center">
			<td>
				<input type="submit" name="submit" value="Submit" >
				
			</td>
		</tr>
		</table>
	</FORM>
</cfoutput>

</body>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">