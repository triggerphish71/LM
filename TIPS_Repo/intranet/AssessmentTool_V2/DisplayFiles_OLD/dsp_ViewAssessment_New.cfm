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
| jcruz      | 06/30/2008 | Created by Jaime Cruz as part of PROJECT 12392					   |
|			 |			  |																	   |
|----------------------------------------------------------------------------------------------|
| Sathya     | 01/15/2010 | Modified as per Project 41315. Added javascript for validation     |
|            |            | for the Next Review Date. Added the DOB, height, weight of a tenant|
| S Farmer   | 09/19/2011 |Project 12352 Allow for all document types to be printed.           |
             |            | Date Picker is visible only with "change" review type              |
----------------------------------------------------------------------------------------------->
<cfparam name="thisreviewtype" default=""> 
<cfoutput>
<style type="text/css">
td.hidden {display:none;}
.classWrong{font-weight: bold; color: red; }
.classWrongNotes{ border-color:red;}
.classRight{font-weight: normal; color: black; }

</style>

<script language="javascript">
	var totalPoints = 0;
</script>

<script language="JavaScript" src="../global/calendar/ts_picker2.js" type="text/javascript"></script>
<!---<script type="text/javascript" src="../ScriptFiles/dump.js"></script>--->
<!--- 01/15/2010 Sathya added this as per Project 41315 --->
<script language="JavaScript" type="text/javascript">
	
	
	function statusvalidation(formCheck)
	{
		//01/11/2010 Sathya Project 41315 added this varibles to check for reviewdate validation
		
		var rwDate = new Date(formCheck.reviewStartDate.value);
		var reviewStart = new Date(formCheck.reviewStartDate.value);
		var reviewDateCheck = new Date(formCheck.nextReviewDate.value);
		
		var MaxBillingDay = formCheck.MaxReviewBillingDays.value;
		
		 var test = parseInt(MaxBillingDay);
		 //sathya here the reviewstart is (reviewstart + Maximum future billing days from teh reviewtype table) 
		 reviewStart.setDate(reviewStart.getDate()+ test);
		 var sValue = document.getElementById('drop1');
		 
		//88898 project 
		if(document.getElementById('drop1').value == 0)
		{
		 document.getElementById('drop1').focus();
		 alert("Please select a Primary Diagnosis type...");
		 return false;
		}
		// sathya this check is for if the next review date is blank
		if(formCheck.nextReviewDate.value == "")
		{
			formCheck.nextReviewDate.focus();
			alert("You cannot save untill a review Date is entered");
			return false;
		}
		//sathya this check is for if the review date being selected is greater than the (review start date of assessment + Maximun Future billing days)
		if(reviewDateCheck > reviewStart)
		{
			formCheck.nextReviewDate.focus();
			alert("This assessment was done on "+rwDate.toDateString()+". The next Assessment due can not be greater than "+MaxBillingDay+"days!. Please pick another due date for next assessment.");
			return false;
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
	
	// 06/01/2012 project 88898 New assessment project for 7 diagnosis dropdowns -- Ganga Thota
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
		alert("Select a Primary Diagnosis Type...");
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
</script>

<!---Project 88898  05/02/2012  Diagnosis Types DropDown Query--->
<cfquery name="DCheck" datasource="#Application.Datasource#">
        SELECT iDiagnosisType_ID, cDescription
        FROM DiagnosisType
        WHERE dtRowDeleted is null order by cDescription
 </cfquery>
<cfset ListVal = ValueList(DCheck.cDescription)>
<cfif session.House.GetId() eq 17 OR session.House.GetId() eq 16 >
<form name="AssessmentFormView" action="index.cfm"  method="post" onsubmit="return validate();" >
<cfelse>
<form name="AssessmentFormView" action="index.cfm" method="post">
</cfif> 
<table width="800" id="container">
	<tr>
		<td align="left">
			<table>
				<!--- 01/15/2010 Sathya Project 41315 added this to display date of birth --->	
				<tr>
					<td class="assessmentHeader">Date of Birth: </td>
					<td><input type="text" value="#DateFormat(getTenantDob,"mm/dd/yyyy")#" disabled="disabled"/></td>
				</tr>
				<tr>
					<td class="assessmentHeader">Review Type:</td><td>
						<!--- 01/28/2010 sathya as per project 41315 added this to display the old reviewtype even if they dont belong to the particular house --->
						<cfif IsDefined("Assessment") AND NOT Assessment.GetIsBillingActive()>
							<select name="reviewType" onchange="ChangeDate(this,'nextReviewDate')">
								<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i">
									<option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
								</cfloop>
							</select>
						<cfelseif IsDefined("Assessment") AND Assessment.GetIsBillingActive()>
							<cfset Reviewdescription = Assessment.GetReviewType().GetDescription() >
							<input type="text" value="#Reviewdescription#" disabled="disabled"/>
						<cfelse>
			 	 			<select name="reviewType" onchange="ChangeDate(this,'nextReviewDate')">
								<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i">
									<option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
								</cfloop>
							</select>
						</cfif>
					</td>
					<!--- 01/15/2010 Sathya Project 41315 added this to check for reviewdate validation --->	
					<input type="hidden" name="MaxReviewBillingDays" value="#MaxNextReviewBillingDays#">
			
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
				<tr>   <!--- project 88898 added review date range for new assessemnt 06/06/2012--->
					<td class="assessmentHeader">Review Date Range  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; From: </td>
					<cfset reviewStartDate = DateFormat(Assessment.GetReviewStartDate(),"mm/dd/yyyy")>
					<td><cfif IsDefined("Assessment")>					    				
						<input type="text" name="reviewStartDate" id="idreviewStartDate" size="10" value="#reviewStartDate#" >
						<cfelse> <input type="text" name="reviewStartDate" id="idreviewStartDate" size="10" value="" ></cfif>
						<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						<cfelse>
						<a onclick="show_calendar3('document.forms[0].reviewStartDate',document.getElementsByName('reviewStartDate')[0].value);"> 
						<img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
						</cfif>
				 To : <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized() >
					    <cfset reviewEndDate = DateFormat(Assessment.GetReviewEndDate(),"mm/dd/yyyy")> 
						 <input type="text" name="reviewEndDate" id="idreviewEndDate" size="10" value="#reviewEndDate#" >  
						<cfelse> Not Finalize<!--- <input type="text" name="reviewEndDate" id="idreviewEndDate" size="10" value="#DateFormat(NOW(),"mm/dd/yyyy")#" >---> </cfif>
						
						<!---<a onclick="show_calendar3('document.forms[0].ReviewDateRange',document.getElementsByName('ReviewDateRange')[0].value);"> 
						<img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>--->						
				 
					</td>
				</tr>
				<tr>
					<td class="assessmentHeader">When will the next assessment be due:</td>
					<td>
						<cfif IsDefined("Assessment")>
							<!--- 01/15/2010 Sathya as per project 41315. To retreive the REviewStartDate inorder not to let them save if the reviewdate is past Max future BillingDays --->
							<cfset reviewStartDate = DateFormat(Assessment.GetReviewStartDate(),"mm/dd/yyyy")>
							<cfset nextDate = DateFormat(Assessment.GetNextReviewDate(),"mm/dd/yyyy")>
						<cfelse>
							<cfset nextDate = DateFormat(DateAdd('m',1,NOW()),"mm/dd/yyyy")>
						</cfif>
						<!--- 01/15/2010 Sathya Project 41315 added this to check for reviewdate validation --->	
						<!---<input type="hidden" name="reviewStartDate" value ="#reviewStartDate#">--->
						<input type="text" name="nextReviewDate" id="idNextReviewDate" size="10" value="#nextDate#"  readonly="true">
						<cfset daysnextassessment = ReviewType.GetMaxFutureBillingDays(application.datasource)>
						<input type="hidden" name="dspDaysnextassessment" id="iddspDaysnextassessment" size="10" value="#daysnextassessment#" >
 					</td>
				</tr>
				<tr   id="withdate" style="display:none">		
					<td class="assessmentHeader">Select to change next Assessment Date:</td>
					<td><a onclick="show_calendar4('document.forms[0].nextReviewDate',document.getElementsByName('nextReviewDate')[0].value);"> <img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a></td>
				</tr>
				<cfif isDefined("Assessment") AND Assessment.GetIsFinalized() AND NOT Assessment.GetIsBillingActive()>
				<cfif Assessment.GetReviewStartDate() GT DateAdd('d',-90,Now())>
				<tr>
					<td class="assessmentHeader">Activate</td>
					<td>
						<cfif Assessment.GetTenant().GetType() eq "Tenant" AND Assessment.GetTenant().GetState().GetResidencyType() eq 3>
					 		<a href="javascript:ActivateAssessment('Respite')" class="breadcrumbs" >Activate</a><!---  onclick="ChangeActDate();" --->
						<cfelse>
							<cfif #AssessmentType# eq 'resident'>
						 		<a href="javascript:ActivateAssessment('resident')" class="breadcrumbs"  >Activate</a>
							<cfelse>
						 		<a href="javascript:ActivateAssessment('#Assessment.GetTenant().GetType()#')" class="breadcrumbs"  >Activate</a>
							</cfif>
						</cfif>
					</td>
				</tr>

				<tr>
					<td class="assessmentHeader">Activate Billing On</td>
					<td>
						<input type="text" name="activeBillingDate" id="idActiveBillingDate" size="10" value="#DateFormat(NOW(),"mm/dd/yyyy")#" >
						<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized() >
						<cfelse>
						<a onclick="show_calendar3('document.forms[0].activeBillingDate',document.getElementsByName('activeBillingDate')[0].value);"> <img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
					</cfif>	
					</td>
				</tr>
<!--- 			 <cfset assdays = #DateFormat(DateAdd("d",ReviewType.GetMaxFutureBillingDays(application.datasource),NOW()),"mm/dd/yyyy")#> ---> 
<!--- 				<tr>
					<td class="assessmentHeader">Update next assessment date based on billing date?</td>
					<td>  </td>
				</tr> --->
				</cfif>
			</cfif> <!--- 12352 --->
			<!--- 	<cfelseif IsDefined("Assessment") AND Assessment.GetIsBillingActive()> ---> <!--- 12352 --->
				<tr>
					<td class="assessmentHeader">Print</td>
					<td>
						<a href="index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
					</td>
				</tr>
				<!--- </cfif> ---> <!--- 12352 --->
			</table>	
		</td>
		<td align="left" valign="top">
			<table>
				<tr>
					<td class="assessmentHeader" align="right">Code Status:</td>
					<td>
						<select name="statuscode">
							<cfif IsDefined("Assessment")> 
								<cfif #Assessment.GetStatusCode()# eq 0>
									<option value="None" selected="true">Select Status</option>
									<option value="DNR">DNR</option>
									<option value="CPR">CPR</option>
								<cfelse>
								<option value="#Assessment.GetStatusCode()#" \Selected>#Assessment.GetStatusCode()#</option>
									<cfif #Assessment.GetStatusCode()# eq 'CPR'>
									<option value="DNR">DNR</option>
									<cfelse>
									<option value="CPR">CPR</option>
									</cfif>
								</cfif>
							<cfelse>
							<option value="None" selected="true">Select Status</option>
							<option value="DNR">DNR</option>
							<option value="CPR">CPR</option>
							</cfif>							
						</select>
					</td>
				</tr>
				<!--- 01/12/2010 Sathya Project 41315 added this to accomodate height and weight of a person --->
			<cfscript>
				//Sathya for documentation purpose getTenantWeight is retrived from act_GetAssessment.cfm
             if (getTenantWeight NEQ "") 
                  { tenantweight=getTenantWeight; }
             else { tenantweight=''; }					
            </cfscript>
			
			<tr>
				<td class="assessmentHeader"> Weight:</td>
				<td><input type="text" name="tenantweight" value="#Variables.tenantweight#" size="10"> Lbs</td>	
			</tr>
			
			<cfscript>
				//Sathya for documentation purpose getTenantHeight is retrived from act_GetAssessment.cfm
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
				<td><select name="tenantheightinfeet" onChange="convertfeettoInches(AssessmentFormView)">
		        		<cfloop from="0" to="7" index="i">
							<cfif #tenantheightinfeetval# EQ #i#> <cfset Selected = 'Selected'>
						     <cfelse> <cfset Selected = ''> 
							</cfif>
						<option value="#i#" #Selected#>#i#</option>
						</cfloop>
					</select>
					Feet	
					<select name="tenantheightinc" onChange="convertfeettoInches(AssessmentFormView)">
						<cfloop from="0" to="11" index="i">
						     <cfif #tenantheightincval# EQ #i#> <cfset Selected = 'Selected'>
						      <cfelse> <cfset Selected = ''> 
							 </cfif>
						<option value="#i#" #Selected#>#i#</option>
						</cfloop>
					</select>
					Inches
				</td>
				<td><input type="hidden" name="getcalculatedheight" value="#Variables.getcalculatedheight#" size="5"></td>
			</tr>
			
			</table>
		</td>
	</tr>
</table>
<table>
<tr align="left" valign="top">
		<td align="left" valign="top">
			<table>
				<tr>
					<td class="assessmentHeader" align="left">Diagnosis: -  <br> <!---Project 88898 for new assessments 05/14/2012 --->
				 <table>
				 <tr><td class="assessmentHeader" align="left">
				  Primary  :</td><td align="left"> <select name="Primary" id="drop1" onchange="enableSelectPrimary()" >				        
						<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						<option value="#Assessment.GetPrimary()#" selected>#Assessment.GetPrimary()#</option>
						<cfelse><option value="0"> -- Select Primary Diagnosis -- </option>
						<cfloop query="DCheck">
							 <cfif IsDefined("Assessment")>
							 <cfif cDESCRIPTION IS Assessment.GetPrimary()> 							 
							   <option value="#Assessment.GetPrimary()#" selected>#Assessment.GetPrimary()#</option>
							 <cfelse>							 				 
							   <option value="#DCheck.cDescription#" >#DCheck.cDescription#</option>
							 </cfif>
							 </cfif> </cfloop>			 
				          </cfif> </select>  </td></tr> 
				<tr><td class="assessmentHeader" align="left">
				 Second:</td><td align="left"> <select name="Secondary" id="drop2" onchange="enableSelectPrimary()">
				        <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						<option value="#Assessment.GetSecondary()#" selected>#Assessment.GetSecondary()#</option>
						<cfelse><option value="0"> -- Select Secondary Diagnosis -- </option>
							<cfloop query="DCheck"> 
				              <cfif IsDefined("Assessment")> 
							  <cfif cDESCRIPTION IS Assessment.GetSecondary()>
							    <option value="#Assessment.GetSecondary()#" selected>#Assessment.GetSecondary()#</option>
							  <cfelse>							  
							    <option value="#DCheck.cDescription#">#DCheck.cDescription#</option>
							  </cfif>
							  </cfif></cfloop>
							</cfif> </select> </td></tr>
				<tr><td class="assessmentHeader" align="left">
				 Third : </td><td align="left"><select name="Third" id="drop3" onchange="enableSelectPrimary()">
				         <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						   <option value="#Assessment.GetThird()#" selected>#Assessment.GetThird()#</option>
						 <cfelse><option value="0"> -- Select Third Diagnosis -- </option> 
						   <cfloop query="DCheck">  
				                <cfif IsDefined("Assessment")>
								 <cfif cDESCRIPTION IS Assessment.GetThird()>
								  <option value="#Assessment.GetThird()#" selected>#Assessment.GetThird()#</option>
								  <cfelse>
									 <option value="#DCheck.cDescription#">#DCheck.cDescription#</option>
									</cfif></cfif></cfloop>
							  </cfif> </select> </td></tr>
				<tr><td class="assessmentHeader" align="left">
				 Fourth :</td><td align="left"> <select name="Fourth" id="drop4" onchange="enableSelectPrimary()">
				         <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						   <option value="#Assessment.GetFourth()#" selected>#Assessment.GetFourth()#</option>
						 <cfelse><option value="0"> -- Select Fourth Diagnosis -- </option> 
						  <cfloop query="DCheck">
				             <cfif IsDefined("Assessment")>
							 <cfif cDESCRIPTION IS Assessment.GetFourth()>
							    <option value="#Assessment.GetFourth()#" selected>#Assessment.GetFourth()#</option>
							  <cfelse>							  
							    <option value="#DCheck.cDescription#">#DCheck.cDescription#</option>
							  </cfif></cfif></cfloop>
							</cfif> </select> </td></tr>
				<tr><td class="assessmentHeader" align="left">
				 Fifth :</td><td align="left"> <select name="Fifth" id="drop5" onchange="enableSelectPrimary()">
				          <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						   <option value="#Assessment.GetFifth()#" selected>#Assessment.GetFifth()#</option>
						  <cfelse><option value="0"> -- Select Fifth Diagnosis -- </option>
						    <cfloop query="DCheck">
				                 <cfif IsDefined("Assessment")>
								  <cfif cDESCRIPTION IS Assessment.GetFifth()>
							        <option value="#Assessment.GetFifth()#" selected>#Assessment.GetFifth()#</option>
							     <cfelse>
							        <option value="#DCheck.cDescription#">#DCheck.cDescription#</option>
							     </cfif></cfif></cfloop> 
								 </cfif></select> </td></tr>
				<tr><td class="assessmentHeader" align="left">
				 Sixth :</td><td align="left"> <select name="Sixth" id="drop6" onchange="enableSelectPrimary()">
				          <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						   <option value="#Assessment.GetSixth()#" selected>#Assessment.GetSixth()#</option>
						  <cfelse><option value="0"> -- Select Sixth Diagnosis -- </option>
							<cfloop query="DCheck">
				                <cfif IsDefined("Assessment")>
								 <cfif cDESCRIPTION IS Assessment.GetSixth()>
							       <option value="#Assessment.GetSixth()#" selected>#Assessment.GetSixth()#</option>
							    <cfelse>
							       <option value="#DCheck.cDescription#">#DCheck.cDescription#</option>
							    </cfif></cfif></cfloop> </cfif> </select> </td></tr>
				<tr><td class="assessmentHeader" align="left">
				 Seventh :</td><td align="left"> <select name="Seventh" id="drop7" onchange="enableSelectPrimary()">
				          <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
						   <option value="#Assessment.GetSeventh()#" selected>#Assessment.GetSeventh()#</option>
						  <cfelse><option value="0"> -- Select Seventh Diagnosis -- </option>
						  <cfloop query="DCheck">
				             <cfif IsDefined("Assessment")>
							 <cfif cDESCRIPTION IS Assessment.GetSeventh()>
							   <option value="#Assessment.GetSeventh()#" selected>#Assessment.GetSeventh()#</option>
							 <cfelse>
							   <option value="#DCheck.cDescription#">#DCheck.cDescription#</option>
							 </cfif></cfif></cfloop></cfif></select>  </td></tr>  
				  </table>                 <!---End 88898 Project --->
					<!---<cfif IsDefined("Assessment")>
					<textarea name="diagnosis" rows="5" cols="45">#Assessment.GetDiagnosis()#</textarea>
					<cfelse>
					<textarea name="diagnosis" rows="5" cols="45"></textarea>
					</cfif>--->
					</td>
					<td class="assessmentHeader" align="left" colspan="2">Allergies:<br>
					<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
					<textarea name="allergies" rows="5" cols="45" disabled="disabled">#Assessment.GetAllergies()#</textarea>
					<cfelse>
					<cfif IsDefined("Assessment")>
					<textarea name="allergies" rows="5" cols="45">#Assessment.GetAllergies()#</textarea>
					<cfelse>
					<textarea name="allergies" rows="5" cols="45"></textarea>
					</cfif>&nbsp;
					</cfif>
				</tr>
			</table>
		</td>
	</tr>
</table>

<br>
<br>
<span class="points" name="pointsSpan" id="pointsSpan">0 Points :: Level 0</span>
<br><br>
<table width="800" bgcolor="##000000" cellspacing="1" cellpadding="3">
	<tr>
		
<td align="left" class="assessmentDirections">There are 12 sections to complete on this assessment. Answer Yes or No to each question. You will be required to add service plan notes in the <b>add notes</b> section for every <b>Yes answer</b>. You will not be able to finalize the assessment if you do not add notes.  For all items marked <b>NURSE</b>, the nurse should be consulted prior to accepting the potential resident.&nbsp;&nbsp; For items marked <strong>RDO</strong>, the <strong>RDO</strong> must be consulted prior to accepting the resident.<br><font color="red"> Base Service Level MUST BE CHECKED NO if notes are to be added.</font></td>

	</tr>
</table>
<div id="assessment" name="assessment">
Assessments go here.
</div>

<script>
	ShowTool(document.getElementsByName('assessmentTool')[0],'assessment');
	
	<cfif isDefined("Assessment")>
		LoadAssessment();
	</cfif>
</script>
<cfif fuse eq "viewAssessment">
	<input type="hidden" name="assessmentId" value="#assessmentId#">
</cfif>

<input type="hidden" name="fuse" value="">

<cfif isDefined("tenantId")>
	<input type="hidden" name="tenantid" value="#tenantid#">
<cfelseif isDefined("residentId")>
	<input type="hidden" name="residentId" value="#residentId#">
</cfif>

<cfif isDefined("Assessment")>
<table>
<tr align="left" valign="top">
		<td align="left" valign="top">
			<table>
				<tr>
					<td class="assessmentHeader" align="left">Other Services:<br>
					<textarea name="otherservices" rows="5" cols="45">#Assessment.GetOtherServices()#</textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table><br><br>
<!--- 01/15/2010 sathya as per project 41315 added the validation onmouseover="return statusvalidation(AssessmentForm);"--->
	<input type="button" value="Save/Update" onmouseover="return statusvalidation(AssessmentFormView);" onclick="SubmitAssessment('save')" class="assessmentMain"> 
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
<!--- 01/15/2010 sathya as per project 41315 added the validation onmouseover="return statusvalidation(AssessmentForm);" --->
	<input type="button" value="Save" onmouseover="return statusvalidation(AssessmentForm);" onclick="SubmitAssessment('new')"  class="assessmentMain"> 
</cfif>
<cfif isDefined("Assessment") AND NOT Assessment.GetIsFinalized()>
	<!--- 01/15/2010 sathya as per project 41315 added the validation onmouseover="return statusvalidation(AssessmentForm);" --->
&nbsp;&nbsp;<input type="button" value="Finalize" onmouseover="return statusvalidation(AssessmentForm);" onclick="SubmitAssessment('finalize')" class="assessmentMain">
</cfif>
</cfoutput>
  
</form>
<!--- this needs to go here so the submit button gets disabled --->
<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
	<script language="javascript">
		DisableAll();
	</script>
</cfif>