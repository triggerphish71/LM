<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| jcruz      | 06/26/2008 | Modified by adding four new input objects						   |
|            |            | as part of project 12392 to incorporate Service Plans	           |
|			 |			  | into the assessment process.									   |
|			 |			  | Also modified links to use both tenant and resident ids when a user|
|			 |			  | to save a new assessment.									   |
|----------------------------------------------------------------------------------------------|
| Sathya     | 01/11/2010 | Modified as per Project 41315. Added javascript for validation     |
|            |            | for the Next Review Date. Added the DOB, height, weight of a tenant|
| S Farmer   | 09/19/2011 |Project 12352 Allow for all document types to be printed.           |
|            |            | Date Picker is visible only with "change" review type              |
| Ganga      | 05/27/2012 | Project 88898 - Added new 7 Diagnosis dropdowns for new Assessment |
|            |            | Requirement, And checkbox options to radio button of Assesment     |
|            |            |  service list.                                                     |
| S Farmer   | 02/03/2015 |Review after Initial Review changed from 30 days to 90 days         |
| S Farmer   | 02-11-2015 | all assessments next date set by MaxNextReviewBillingDays in       |
|            |            | dbo.ReviewType                                                     | 
| S Farmer   | 03-24-2017 | addDays2GivenDate & ChangeDateRange if( isNaN(reviewType)   )      |
|            |            | days = 0; changed to {days = 90;                                   |
----------------------------------------------------------------------------------------------->

<cfset assessmentreview = createobject('component',"Components.Assessment")>

<!--- <cfdump var="#assessmentreview.GETASSESST_P(tenantId = URL.tenantId)#" label="GETASSESST_P">  --->
 
<cfoutput>
<style type="text/css">
td.hidden {display:none;}
</style>
<script language="javascript">
	var totalPoints = 0;
</script>
<script language="JavaScript" src="../global/calendar/ts_picker2.js" type="text/javascript"></script>
<script language="javascript">
	function DisableAllServices(theObj,pointsSpan)
	{
		var inputArray = document.getElementsByTagName('input');
		var baseFound = false;
		var disable = null;
		
		//set the disable to true if base equals yes   //88898 project 		 
		(theObj.value == 'yes') ? disable = true: disable = false;
		if(theObj.value == 'yes'){ 
		alert(" YES Base Level Selection will mark all Services to NO ");
		} 
		for(i = 0; i < inputArray.length; i++)
		{					 			
			//if the base is found disable or enable all the objects below it
			if(baseFound && inputArray[i].type != 'submit' && inputArray[i].type != 'button') //&& inputArray[i].type != 'hidden')
			{
			
				if(disable)
				{	                    
					//inputArray[i].disabled = true;
					//inputArray[i].checked = false;
					//alert(arguments.length+"Test here");					
				   if(inputArray[i].value == 'no')
					 {  //alert(totalPoints+"test here-2");
					 
					  inputArray[i].checked = true;					  
					 
					 }
					 if( inputArray[i].name.indexOf('sub') != -1 )
						 {  
						  inputArray[i].checked = false;    
						 }					 	
				}
				else
				{
					//inputArray[i].disabled = false;
					//if this is not a sub service
					if(inputArray[i].name.indexOf('sub') == -1)
					{						
						
						if(inputArray[i].value == 'no') //&& totalPoints > 0 )
						{  //alert("test here-2");
							inputArray[i].checked = false;
						}						
					}
				}
  				   
			}				
			//first check for the base level object
			if(inputArray[i].name == theObj.name && !baseFound)
			{   // alert(inputArray[i].name+"hello...");
				baseFound = true;
				i++;
			}
			
		}
				 
		ResetLevel();
	}
	
</script>
<script language="JavaScript" type="text/javascript">
				
		function addDays2GivenDate(days)
		{
			
			var datepicker = document.AssessmentForm.reviewStartDate.value;
			var parms = datepicker.split("/");
			// mm/dd/yyyy
			var joindate = new Date(parms[0]+"/"+parms[1]+"/"+parms[2]);
			
			var AssessmentFormObj = document.AssessmentForm;
			var selReviewType = AssessmentFormObj.reviewType.options[AssessmentFormObj.reviewType.selectedIndex].text;
			var reviewType = parseInt( selReviewType );
		//alert(" Test here");
			if( isNaN(reviewType)  )
			{
				days = 90;
			}
			else 
			{
				days = reviewType;
			}
			if(selReviewType == 'Initial')
			{
			days = 30;
			}
			
			var numberOfDaysToAdd = days;
			  
			joindate.setDate(joindate.getDate() + numberOfDaysToAdd);
			
			var dd = joindate.getDate();
			var mm = joindate.getMonth() + 1;
			if (mm<10) mm="0"+mm;
			var y = joindate.getFullYear();
			var joinFormattedDate = mm + '/' + dd + '/' + y;
			return joinFormattedDate;			 
			//AssessmentFormViewObj.nextReviewDate.value = joinFormattedDate;	
			//return joinFormattedDate;
		}
		
		function ChangeDateRange()
		{
			var AssessmentFormObj = document.AssessmentForm;
			var selReviewType = AssessmentFormObj.reviewType.options[AssessmentFormObj.reviewType.selectedIndex].text;
			var reviewType = parseInt( selReviewType );
		//alert(" Test here");
			if( isNaN(reviewType)  )
			{
				days = 90;
			}
			else 
			{
				days = reviewType;
			}
			if(selReviewType == 'Initial')
			{
			days = 30;
			}
		    
			AssessmentFormObj.nextReviewDate.value = addDays2GivenDate(days);  //addDays2CurrentDate(days);	
		
			if( selReviewType == 'Change' ){
				document.getElementById("withdate").style.display='block';  
				document.getElementById("idNextReviewDate").readOnly=false; 
				}
			else{
				document.getElementById("withdate").style.display='none';			 
				document.getElementById("idNextReviewDate").readOnly=true; 					
			}
		}
</script>
<script language="JavaScript" type="text/javascript">	
	// 06/01/2012  Ganga - project 88898 New assessment project for 7 diagnosis dropdowns 
	function enableSelectPrimary(){
	
	// The number of dropdowns you have (use the naming convention 'dropx' as an id attribute)
    var iDropdowns = 7;  
    var sValue;
    var sValue2;
    // Loop over dropdowns
    for(var i = 1; i <= iDropdowns; ++i)
    {
        // Get selected value
		sValue = document.getElementById('drop' + i).value;
		// checking for primary is not null
		if(i == 1 && document.getElementById('drop1').value == 0 ) 
		/*&& (document.getElementById('drop2').value !=0 || document.getElementById('drop3').value !=0 || document.getElementById('drop4').value !=0 || document.getElementById('drop5').value !=0 || document.getElementById('drop6').value !=0 || document.getElementById('drop7').value !=0 )*/
		{
		document.getElementById('drop1').focus();
		alert("First select a Primary Diagnosis Type...");
		return false;
		}
		// Nested loop - loop over dropdowns again		
		for(var j = 1; j <= iDropdowns; ++j)
		{
		    // Get selected value
	        sValue2 = document.getElementById('drop' + j).value;	        
	        // If we're not checking the same dropdown and the values are the same...
			if(sValue != 0)
			{
				if ( i != j && sValue == sValue2 )
				{
					// ...we have a duplicate!
					alert('Diagnosis' +' " '+ sValue2 +' " '+ 'is already selected...!');
					document.getElementById('drop' + j).value = 0;
					document.getElementById('drop' + j).focus();			    
					return false;
				}
		    }
	    }
	}
	// No duplicates
	return true;	
	}		  			// -- 88898 project ends 
	
	function statusvalidation(formCheck)
	{     
		//01/11/2010 Sathya Project 41315 added this varibles to check for reviewdate validation
		var todayDate = new Date();
		var reviewDateCheck = new Date(formCheck.nextReviewDate.value);		
		var MaxBillingDay = formCheck.MaxReviewBillingDays.value;		
		var test = parseInt(MaxBillingDay);
		todayDate.setDate(todayDate.getDate()+ test);
		var sValue = document.getElementById('drop1');
		
		
						
		if(formCheck.statuscode.value == "None")
		{
			formCheck.statuscode.focus();
			alert("Please Select a Status Code from the Drop Down List to proceed!");
			return false;
		}
		if(formCheck.tenantweight.value < 10)// || formCheck.tenantweight.value.length == 1 )
		{
			formCheck.tenantweight.focus();
			alert("Please enter a valid Tenant weight to proceed!");
			return false;
		}	
		/*if(formCheck.tenantweight.value == 0)
		{
			formCheck.tenantweight.focus();
			alert("Please enter a Tenant weight  to proceed!");
			return false;
		}*/
		if(formCheck.tenantheightinfeet.value == 0)
		{
			formCheck.tenantheightinfeet.focus();
			alert("Please enter a Tenant height in feet to proceed!");
			return false;
		}
		//01/11/2010 Sathya Project 41315 added this javascript to check for reviewdate validation
		if(formCheck.nextReviewDate.value == "")
		{
			formCheck.nextReviewDate.focus();
			alert("You cannot save untill a review Date is entered");
			return false;
		}
		
		if(reviewDateCheck > todayDate)
		{
			formCheck.nextReviewDate.focus();
			alert("Next Review Date cannot be more than "+MaxBillingDay+" days!");
			return false;
		}
		// checking Diagnosis is checked or not, If not Primary Diagnosis is required  --Ganga 05/20/2012  project-88898
		if(document.getElementById('drop1').value == 0)
		{
			 document.getElementById('drop1').focus();
			 alert("Please select a Primary Diagnosis type...");
			 return false;
		}
		// This code 88898 project for check any check box or radio button seleted under subservices on page -- Ganga 08/02/2012			
			var base =document.getElementById('base');
			var baseno =document.getElementById('baseno');				
				
	    if((document.getElementById('base').value == "no" && document.getElementById('base').checked == false) && (document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false) && (totalPoints == 0))
		   {
		     if (document.getElementById('baseno').getAttribute('type') == 'radio')
					{  alert(" 0 Points selected base level option will be 'Yes'");
					  document.getElementById('baseno').checked = true;
					}
		   }
	  if((document.getElementById('base').value == "no" && document.getElementById('base').checked == false) && (document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false) && (totalPoints > 0))
		   {
		     if (document.getElementById('base').getAttribute('type') == 'radio')
					{  alert(" Base level option will be 'No' select..");
					  document.getElementById('base').checked = true;
					}
		   }	   
	  if((document.getElementById('base').value == "no" && document.getElementById('base').checked == true) && (document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false) && (totalPoints == 0 ))
	    {
		   if (document.getElementById('baseno').getAttribute('type') == 'radio')
		    { 
			  document.getElementById('baseno').checked = true;
			  alert(" Base Level Option default it will select option - 'YES' Continue...  ");			  
			}
		} 
		  
	   
		  		
	}
	//01/12/2010 Sathya Added this for Project 41315 to calculate the convertion of height to save it in datebase
	function convertfeettoInches(formCheck)
	{
	  var getfeetvalue = 0;
	  var getincvalue = 0;
	   getfeetvalue = formCheck.tenantheightinfeet.value;
	  getfeetvalue =  getfeetvalue * 12;
	  
	  if(formCheck.tenantheightinc.value != '')
	  {
	  	getincvalue = parseInt(formCheck.tenantheightinc.value);
	    getfeetvalue = getfeetvalue + getincvalue;
	  }
	  
	  formCheck.getcalculatedheight.value = getfeetvalue;
	}
	
</script>

<cfset DCheck = assessmentreview.DCheck()>  
<cfset getassesst_p = assessmentreview.GETASSESST_P(tenantId = URL.tenantId)>
<cfset getassesst = assessmentreview.GETASSESST(tenantId = URL.tenantId)> 
<cfset assessmentCount = VAL(getassesst_p.P_BBILLINGACTIVE_CNT + getassesst.BBILLINGACTIVE_CNT)> 
<cfset ListVal = ValueList(DCheck.cDescription)>
<!----
<cfloop from="1" to="#arrayLen(ReviewTypeArray)#" index="inx">
	<Cfoutput>
		#reviewTypeArray[inx].getID()#<br />
		#ReviewTypeArray[inx].GetGutureBillingDays()#<br />
	</Cfoutput>
</cfloop>--->
<form name="AssessmentForm" id="form1" action="index.cfm" method="post">
<!---<input type="hidden" name="serviceReset"  value="0" >--->
<table width="800">
	<tr>
		<td align="left">
			<table>
				<!--- 01/12/2010 Sathya Project 41315 added this to display date of birth --->	
				<tr>
				<td class="assessmentHeader">Date of Birth: </td>
				<td><input type="text" value="#DateFormat(getTenantDob,"mm/dd/yyyy")#" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="assessmentHeader">Review Start Date &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  </td>
					<td> <input type="text" name="reviewStartDate" id="idreviewStartDate" size="10" value="#DateFormat(NOW(),"mm/dd/yyyy")#" onblur="JavsScript:addDays2GivenDate();">  
					<!--- To : <input type="text" name="reviewEndDate" id="idreviewEndDate" size="10" value="#DateFormat(NOW(),"mm/dd/yyyy")#" > 
						<a onclick="show_calendar3('document.forms[0].reviewStartDate',document.getElementsByName('reviewStartDate')[0].value);"> 
						<img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>--->						
				 
					</td>
				</tr>			 
				<tr>
					<td class="assessmentHeader">Assessment Tool</td>
					<td>
						<select name="assessmentTool" onchange="ShowTool(this,'assessment')">
						<cfloop from="1" to="#ArrayLen(AssessmentToolArray)#" index="i">
							<cfif isDefined("Assessment") and Assessment.GetAssessmentTool().GetId() eq AssessmentToolArray[i].GetId()>
								<option value="#AssessmentToolArray[i].GetId()#" \SELECTED>#AssessmentToolArray[i].GetDescription()#</option>
								<cfbreak>
							<cfelseif NOT isDefined("Assessment")AND AssessmentToolArray[i].GetSLevelTypeSet() eq session.House.GetSLevelTypeSet()>
								<option value="#AssessmentToolArray[i].GetId()#" \SELECTED>#AssessmentToolArray[i].GetDescription()#</option>
								<cfbreak>
							</cfif>
						</cfloop>
						</select>
					</td>
				</tr>				
				<tr>
				 <!--- 01/11/2010 Sathya Project 41315 added this to check for reviewdate validation --->	
					<input type="hidden" name="MaxReviewBillingDays" value="#MaxNextReviewBillingDays#">
				 <!--- 01/12/2010 Sathya Project 41315 changed this to populate the correct reviewtype --->
				<td class="assessmentHeader">Review Type:</td>
				<td>
					<select name="reviewType" onChange="ChangeDate(this,'nextReviewDate')">						
						<cfloop from="1" to="#arrayLen(reviewTypeArray)#" index="i">
							<cfif assessmentID EQ 0 AND ListFindNoCase("4,5,7",ReviewTypeArray[i].getID(),",") EQ 0>
								<option value="#ReviewTypeArray[i].getID()#">#ReviewTypeArray[i].getDescription()#</option>							
							<cfelseif (assessmentID NEQ 0) AND (Points EQ 0) AND (assessmentCount EQ 1) AND ListFindNoCase("5,7",ReviewTypeArray[i].getID(),",") EQ 0>
								<option value="#ReviewTypeArray[i].getID()#">#ReviewTypeArray[i].getDescription()#</option>
							<cfelseif (assessmentcount EQ 2) AND ListFindNoCase("1,5",ReviewTypeArray[i].getID(),",") EQ 0>
								<option value="#ReviewTypeArray[i].getID()#" <cfif ReviewTypeArray[i].getID() EQ 7>SELECTED</cfif>>#ReviewTypeArray[i].getDescription()#</option>
							<cfelseif (assessmentcount GT 2 ) AND ListFindNoCase("1,7",ReviewTypeArray[i].getID(),",") EQ 0>
								<option value="#ReviewTypeArray[i].getID()#">#ReviewTypeArray[i].getDescription()#</option>
							</cfif>
						</cfloop>
					</select>
					<!---- Ganga's Code 
						<select name="reviewType" onchange="ChangeDate(this,'nextReviewDate')">  <!--- /  onchange="JavsScript:ChangeDateRange();"--->
							<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i"> 								
								 <cfif assessmentType eq "resident">
									 <cfif #ReviewTypeArray[i].GetId()# EQ 1>
									  <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ((ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()) OR (getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ ''))>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
									 </cfif>
								<cfelseif getassesst_p.P_BBILLINGACTIVE_CNT GT 0 and getassesst.BBILLINGACTIVE_CNT GT 0>
									 <cfif #ReviewTypeArray[i].GetId()# NEQ 1 AND #ReviewTypeArray[i].GetId()# NEQ 7>
									  <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ((ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()) OR (getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ ''))>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
									 </cfif>
								<cfelse>
									 <cfif #ReviewTypeArray[i].GetId()# NEQ 1 AND #ReviewTypeArray[i].GetId()# NEQ 5>
									  <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ((ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()) OR (getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ ''))>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
									 </cfif>
								</cfif>
							</cfloop> 
						</select>  	
						---->
												
						<!---- production code 
						<select name="reviewType" onchange="JavsScript:ChangeDateRange();">  <!--- onchange="ChangeDate(this,'nextReviewDate')" --->
							<!--- <option value="None">Select Review Type</option> --->
							<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i">	
								<!--- 01/28/2010 SATHYA 41315 commented this out and rewrote it below --->							
								<!--- <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
							 --->
							  <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ((ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()) OR (getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ ''))>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
							</cfloop>
						</select>---->
					</td>					
				</tr>

 				<tr> <!--- Modified as part of project 28821 - Jaime Cruz - 10/15/2008 --->
					<td class="assessmentHeader">When will the next assessment be due:</td>
					<!--- 12352 added display none/block to hide datepicker unless "change" is selected --->
						<!--- <cfif isDefined("Assessment") and 
						(getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ '')>  sfarmer 02-11-2015 --->
						<cfset nextDate = DateFormat(DateAdd('d',#MaxNextReviewBillingDays#,NOW()),"mm/dd/yyyy")>
						<!--- <cfelse>
						<cfset nextDate = DateFormat(DateAdd('d',90,NOW()),"mm/dd/yyyy")>  sfarmer 02-11-2015 --->
						<!--- <cfset nextDate = DateFormat(DateAdd('d',30,NOW()),"mm/dd/yyyy")> --->
						<!--- </cfif>  sfarmer 02-11-2015 --->
					<td >
						<!--- 01/28/2010 Sathya project 41315 commented the code out and rewrote it 
						(no hardcoding to 1 because now there are many reviewtype and now checking
						 if the tenant had any previous assessment which was activated)--->
						<!--- orignial prod code 
						 <cfif isDefined("Assessment") and Assessment.GetReviewType().GetID() neq 1> --->
						 	<!--- Ganga 03/21/2018   added review type option code  ---> 
						  <cfif assessmentType eq "resident">													
						   <cfset nextDate = DateFormat(DateAdd('d',30,NOW()),"mm/dd/yyyy")>
						  <cfelse>
						   <cfset nextDate = DateFormat(DateAdd('d',90,NOW()),"mm/dd/yyyy")>
						 </cfif> 
						 <!--- Ganga 03/21/2018   added review type option code END --->
						<!--- 01/28/2010 sathya commented it according to Project 41315 rewrote it instead of 90 marked as #MaxNextReviewBillingDays#--->
						<!--- <cfset nextDate = DateFormat(DateAdd('d',90,NOW()),"mm/dd/yyyy")> --->

						  <input  type="text" name="nextReviewDate"  id="idNextReviewDate" size="10" value="#nextDate#"  readonly="true"  />
					</td>
				</tr>
				<tr id="withdate" style="display:none">
					<td class="assessmentHeader">Select Date:</td>
					<td><a onclick="show_calendar2('document.forms[0].nextReviewDate',document.getElementsByName('nextReviewDate')[0].value);"> <img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a></td>
				</tr>
				<cfif fuse neq "newAssessment">
				<cfif isDefined("Assessment") AND Assessment.GetIsFinalized() AND NOT Assessment.GetIsBillingActive()>
				<tr>
					<td class="assessmentHeader">Activate</td>
					<td>
						<cfif Assessment.GetTenant().GetType() eq "Tenant" AND Assessment.GetTenant().GetState().GetResidencyType() eq 3>
							<a href="javascript:ActivateAssessment('Respite')" class="breadcrumbs">Activate</a>
						<cfelse>
							<a href="javascript:ActivateAssessment('#Assessment.GetTenant().GetType()#')" class="breadcrumbs">Activate</a>
						</cfif>
					</td>
				</tr>
				<tr>
					<td class="assessmentHeader">Activate Billing On</td>
					<td>
						<input type="text" name="activeBillingDate" size="10" value="#DateFormat(NOW(),"mm/dd/yyyy")#">
						<a onclick="show_calendar2('document.forms[0].activeBillingDate',document.getElementsByName('activeBillingDate')[0].value);"> <img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
					</td>
				</tr>
				</cfif> <!--- 12352 --->
				<!---<cfelseif IsDefined("Assessment") AND Assessment.GetIsBillingActive()> ---> <!--- 12352 --->
				<tr>
					<td class="assessmentHeader">Print</td>
					<td>
						<a href="index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
					</td>
				</tr>
				<!---</cfif> ---> <!--- 12352 --->
				</cfif>
			</table>	
		</td>
		<td align="right" valign="top">
			<table>
				<tr>
					<td class="assessmentHeader" align="right">Code Status:</td>
					<td>
						<select name="statuscode"> 
							<cfif #ServicePlan.GetStatusCode()# eq 'None' or #ServicePlan.GetStatusCode()# eq ''>
								<option value="None" Selected="True">Select Status</option>
								<option value="DNR">DNR</option>
								<option value="CPR">CPR</option>
							<cfelse>
								<option value="#ServicePlan.GetStatusCode()#" \Selected>#ServicePlan.GetStatusCode()#</option>
									<cfif #ServicePlan.GetStatusCode()# eq 'CPR'>
										<option value="DNR">DNR</option>
									<cfelse>
										<option value="CPR">CPR</option>
									</cfif>
								<option value="None" Select="True">Select Status</option>
							</cfif>														
						</select>
					</td>
				</tr>
<!--- 01/12/2010 Sathya Project 41315 added this to accomodate height and weight of a person --->
			<cfscript>
			// project 41315 Sathya for documentation purpose getTenantWeight is retrived from act_GetTenant.cfm
             if (getTenantWeight NEQ "") 
                  { tenantweight=getTenantWeight; }
             else { tenantweight=''; }					
            </cfscript>
			
			<tr>
				<td class="assessmentHeader"> Weight:</td>
				<td><input type="text" name="tenantweight" value="#Variables.tenantweight#" size="10" maxlength="5"> Lbs</td>	
			</tr>
			
			<cfscript>
				//Sathya for documentation purpose getTenantHeight is retrived from act_GetTenant.cfm
             if (getTenantHeight NEQ "" OR getTenantHeight NEQ 0) 
                  {
                  	 feet = 0;
	  				 inc = 0;
	   				getinput = 0;
	  				getinput = getTenantHeight;
	  				feet = Int(getinput/12);
	  				inc = getinput - (feet * 12);	
                     getcalculatedheight = getTenantHeight;
                     tenantheightinfeetval = feet;
                     tenantheightincval = inc;
                     
                  }
             else { 
             	     tenantheightinfeet= 0; 
                     tenantheightinc = 0;
                     getcalculatedheight = 0;
             	  }					
            </cfscript>
			<tr>
				<td class="assessmentHeader"> Height:</td>
				<td><select name="tenantheightinfeet" onChange="convertfeettoInches(AssessmentForm)">
		        		<cfloop from="0" to="7" index="i">
							<cfif #tenantheightinfeetval# EQ #i#> <cfset Selected = 'Selected'>
						     <cfelse> <cfset Selected = ''> 
							</cfif>
						<option value="#i#" #Selected#>#i#</option>
						</cfloop>
					</select>	
					Feet
					<select name="tenantheightinc" onChange="convertfeettoInches(AssessmentForm)">
						<cfloop from="0" to="11" index="i">
						     <cfif #tenantheightincval# EQ #i#> <cfset Selected = 'Selected'>
						      <cfelse> <cfset Selected = ''> 
							 </cfif>
						<option value="#i#" #Selected#>#i#</option>
						</cfloop>
					</select>
					Inches
				</td>
				<td><input type="hidden" name="getcalculatedheight" value="#Variables.getcalculatedheight#" size="5">
					</td>
			</tr>
			
			</table>
		</td>
	</tr>
	
</table>
<table>
<tr align="left" valign="top">
		<td align="left" valign="top">
			<table>
			Selected Options:
				<tr>
				<td class="assessmentHeader" align="left"> Diagnosis Types: <br /><br/> <!---Added code 88898 Created 7 dropdowns for Diagnosis  05/04/2012--->
				<!---<font style="visibility:hidden"><textarea name="diagnosis" rows="2" cols="5" disabled="disabled">NULL</textarea></font><br/>--->					
				<table>
				   <tr>
				      <td class="assessmentHeader" align="left"> Primary  :</td>
					  <td align="left"> <select name="Primary" id="drop1" onchange="enableSelectPrimary()"> <!---onchange="doCheck(this);" / enableSelectPrimary()--->
										  <cfif #ServicePlan.GetPrimary()# eq 'None' or #ServicePlan.GetPrimary()# eq '0'>										     
											      <option value="0">--Select One Diagnosis--</option>
										      <cfloop query="DCheck">					 
										          <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										  <!--- <cfloop list="#ListVal#" index="ii"><option value="#ii#">#ii#</option></cfloop>--->
										  <cfelse>
											  <option value="#ServicePlan.GetPrimary()#" selected>#ServicePlan.GetPrimary()#</option>											   
											   <cfloop query="DCheck">					 
												   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										  </cfif>
								        </select> 
					   </td>
					</tr>
				    <tr>
				      <td class="assessmentHeader" align="left">Second :</td>
					  <td align="left"> <select name="Secondary" id="drop2" onchange="enableSelectPrimary()" >
					                    <cfif #ServicePlan.GetSecondary()# eq 'None' or #ServicePlan.GetSecondary()# eq '0'>					                   
										      <option value="0">--Select Second Diagnosis--</option>	
										  <cfloop query="DCheck">					 
											   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>			      
									   <cfelse>
 									          <option value="#ServicePlan.GetSecondary()#" selected>#ServicePlan.GetSecondary()#</option>										   	
										  <cfloop query="DCheck">					 
											   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
									    </cfif>
									    </select>
					  </td>
					</tr>
				    <tr>
					  <td class="assessmentHeader" align="left"> Third  : </td>
					  <td align="left"><select name="Third" id="drop3" onchange="enableSelectPrimary()" >
					                 <cfif #ServicePlan.GetThird()# eq 'None' or #ServicePlan.GetThird()# eq '0'>					                          
										      <option value="0">--Select Third Diagnosis--</option>
										  <cfloop query="DCheck">					 
										      <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>				     
									 <cfelse>
										        <option value="#ServicePlan.GetThird()#" selected>#ServicePlan.GetThird()#</option>												
											  <cfloop query="DCheck">					 
												<option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
									 </cfif>
									  </select>
					   </td>
					 </tr>
				     <tr>
					    <td class="assessmentHeader" align="left"> Fourth   :</td>
						<td align="left"> <select name="Fourth" id="drop4" onchange="enableSelectPrimary()" >
										 <cfif #ServicePlan.GetFourth()# eq 'None' or #ServicePlan.GetFourth()# eq '0'>						
												  <option value="0">--Select Fourth Diagnosis--</option>
											   <cfloop query="DCheck">					 
												   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										 <cfelse>
												  <option value="#ServicePlan.GetFourth()#" selected>#ServicePlan.GetFourth()#</option>									  
											   <cfloop query="DCheck">					 
												   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										 </cfif>
					                    </select>
						</td>
					 </tr>
				     <tr>
					   <td class="assessmentHeader" align="left">Fifth  :</td>
					   <td align="left"> <select name="Fifth" id="drop5" onchange="enableSelectPrimary()" >
					                  <cfif #ServicePlan.GetFifth()# eq 'None' or #ServicePlan.GetFifth()# eq '0'>
				                             <option value="0">--Select Fifth Diagnosis--</option>
					                     <cfloop query="DCheck">					 
							                 <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
									 <cfelse>
									         <option value="#ServicePlan.GetFifth()#" selected>#ServicePlan.GetFifth()#</option>									  
										 <cfloop query="DCheck">					 
										     <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
									 </cfif>
					        </select>
						</td>
					  </tr>
				      <tr>
					     <td class="assessmentHeader" align="left">Sixth  :</td>
						 <td align="left"> <select name="Sixth" id="drop6" onchange="enableSelectPrimary()" >
						                <cfif #ServicePlan.GetSixth()# eq 'None' or #ServicePlan.GetSixth()# eq '0'>
											   <option value="0">--Select Sixth Diagnosis--</option>
											 <cfloop query="DCheck">					 
											   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										<cfelse>
										       <option value="#ServicePlan.GetSixth()#" selected>#ServicePlan.GetSixth()#</option>									  
										    <cfloop query="DCheck">					 
										       <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										</cfif>
					                     </select>
						</td>
					 </tr>
				     <tr>
					   <td class="assessmentHeader" align="left">Seventh  :</td>
					   <td align="left"> <select name="Seventh" id="drop7" onchange="enableSelectPrimary()">
					                    <cfif #ServicePlan.GetSeventh()# eq 'None' or #ServicePlan.GetSeventh()# eq '0'>
											     <option value="0">--Select Seventh Diagnosis--</option>
											 <cfloop query="DCheck">					 
												 <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										<cfelse>
										       <option value="#ServicePlan.GetSeventh()#" selected>#ServicePlan.GetSeventh()#</option>									  
										    <cfloop query="DCheck">					 
										       <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option></cfloop>
										</cfif>
					                </select>
						</td>
					</tr>
				</table>
					
					</td>
					<td class="assessmentHeader" align="left">Admitting Diagnosis Notes:<br>
					<cfif #ServicePlan.GetDiagnosis()# neq ''>
					<textarea name="diagnosis" rows="5" cols="45">#ServicePlan.GetDiagnosis()#</textarea>
					<cfelse>
					<textarea name="diagnosis" rows="5" cols="45"></textarea>
					</cfif>
					<br />Allergies:<br>
					<cfif #ServicePlan.GetAllergies()# neq ''>
					<textarea name="allergies" rows="5" cols="45">#ServicePlan.GetAllergies()#</textarea>
					<cfelse>
					<textarea name="allergies" rows="5" cols="45"></textarea>
					</cfif>
					<!---<td class="assessmentHeader" align="left" colspan="2">Allergies:<br>
					<cfif #ServicePlan.GetAllergies()# neq ''>
					<textarea name="allergies" rows="5" cols="45">#ServicePlan.GetAllergies()#</textarea>
					<cfelse>
					<textarea name="allergies" rows="5" cols="45"></textarea>
					</cfif>--->
				</tr>
			</table>
		</td>
	</tr>
</table>
<br>
<br> 
<span class="points" name="pointsSpan" id="pointsSpan">0 Points :: Level 0</span>
<br>

<table width="800" bgcolor="##000000" cellspacing="1" cellpadding="3">
	<tr>
			
	<td align="left" class="assessmentDirections">There are 12 sections to complete on this assessment. Answer Yes or No to each question. You will be required to add service plan notes in the <b><font color="red">add notes</font></b> section for every <b><font color="red">Yes answer</font></b>. You will not be able to finalize the assessment if you do not add notes.  For all items marked <b>NURSE</b>, the nurse should be consulted prior to accepting the potential resident.&nbsp;&nbsp; For items marked <strong>RDO</strong>, the <strong>RDO</strong> must be consulted prior to accepting the resident.&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<!---<font color="red">Selected YES Questions REQUIRE Note Information before Saving.. </font>---></td>
</tr>
</table>
<div id="assessment" name="assessment">
Assessments go here.
</div>

<script>
	ShowTool(document.getElementsByName('assessmentTool')[0],'assessment');
	LoadNotes();
</script>
<cfif fuse eq "viewAssessment">
	<input type="hidden" name="assessmentId" value="#assessmentId#">
</cfif>

<input type="hidden" name="fuse" value="">
<!--- Modified 03/21/09 by Jaime Cruz as part of project 18506 --->
<cfif #assessmentType# eq 'Tenant' or #assessmentType# eq 'FromStar' or #assessmentType# eq 'FromStarInquiry'>
	<input type="hidden" name="tenantid" value="#tenantid#">
<cfelseif #assessmentType# eq 'Resident'>
	<input type="hidden" name="residentId" value="#residentId#">
	<input type="hidden" name="tenantid" value="#Resident.GetTenantId()#">
</cfif>

<cfif #ServicePlan.GetOtherServices()# neq ''>
<table>
<tr align="left" valign="top">
		<td align="left" valign="top">
			<table>
				<tr>
					<td class="assessmentHeader" align="left">Other Services:<br>
					<textarea name="otherservices" rows="5" cols="45">#ServicePlan.GetOtherServices()#</textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table><br><br>
	<input type="button" value="Save" onmouseover="return statusvalidation(AssessmentForm);" onclick="SubmitAssessment('new')" class="assessmentMain"> 
<cfelse>
<table>
<tr align="left" valign="top">
		<td align="left" valign="top">
			<table>
				<tr>
					<td class="assessmentHeader" align="left">Other Services:<br>
					<textarea name="otherservices" rows="5" cols="45"></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table><br><br>
	<input type="button" value="Save" onmouseover="return statusvalidation(AssessmentForm);" onclick="SubmitAssessment('new')"  class="assessmentMain"> 
</cfif>
<cfif isDefined("Assessment") AND NOT Assessment.GetIsFinalized()>
	<!--- 01/15/2010 sathya as per project 41315 added the validation onmouseover="return statusvalidation(AssessmentForm);" --->
&nbsp;&nbsp;<!---<input type="button" value="Finalize" onmouseover="return statusvalidation(AssessmentForm);" onclick="SubmitAssessment('finalize')" class="assessmentMain">--->
</cfif>
</cfoutput>
  
</form>
<!--- this needs to go here so the submit button gets disabled --->
<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
	<script language="javascript">
		DisableAll();
	</script>
</cfif>