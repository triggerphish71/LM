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
----------------------------------------------------------------------------------------------->

<cfoutput>
<script language="javascript">
	var totalPoints = 0;
</script>

<script language="JavaScript" src="../global/calendar/ts_picker2.js" type="text/javascript"></script>

<script language="JavaScript" type="text/javascript">
	function statusvalidation(formCheck)
	{
		//01/11/2010 Sathya Project 41315 added this varibles to check for reviewdate validation
		var todayDate = new Date();
		var reviewDateCheck = new Date(formCheck.nextReviewDate.value);
		
		var MaxBillingDay = formCheck.MaxReviewBillingDays.value;
		
		 var test = parseInt(MaxBillingDay);
		 todayDate.setDate(todayDate.getDate()+ test);
		
				
		if(formCheck.statuscode.value == "None")
		{
			formCheck.statuscode.focus();
			alert("Please Select a Status Code from the Drop Down List to proceed!");
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
<form name="AssessmentForm" action="index.cfm" method="post">
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
				 <!--- 01/11/2010 Sathya Project 41315 added this to check for reviewdate validation --->	
					<input type="hidden" name="MaxReviewBillingDays" value="#MaxNextReviewBillingDays#">
				 <!--- 01/12/2010 Sathya Project 41315 changed this to populate the correct reviewtype --->
				<td class="assessmentHeader">Review Type:</td><td>
						<select name="reviewType" onchange="ChangeDate(this,'nextReviewDate')">
							<!--- <option value="None">Select Review Type</option> --->
							<cfloop from="1" to="#ArrayLen(ReviewTypeArray)#" index="i">	
								<!--- 01/28/2010 SATHYA 41315 commented this out and rewrote it below --->							
								<!--- <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
							 --->
							  <option value="#ReviewTypeArray[i].GetId()#" <cfif IsDefined("Assessment") AND ((ReviewTypeArray[i].GetId() eq Assessment.GetReviewType().GetID()) OR (getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ ''))>SELECTED</cfif>>#ReviewTypeArray[i].GetDescription()#</option>
							</cfloop>
						</select>
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
				<tr><!--- Modified as part of project 28821 - Jaime Cruz - 10/15/2008 --->
					<td class="assessmentHeader">When will the next assessment be due:</td>
					<td>
						<!--- 01/28/2010 Sathya project 41315 commented the code out and rewrote it 
						(no hardcoding to 1 because now there are many reviewtype and now checking
						 if the tenant had any previous assessment which was activated)--->
						<!--- <cfif isDefined("Assessment") and Assessment.GetReviewType().GetID() neq 1> --->
						<cfif isDefined("Assessment") and (getActiveAssessmentID NEQ 0 OR getActiveAssessmentID NEQ '')>
						<!--- 01/28/2010 sathya commented it according to Project 41315 rewrote it instead of 90 marked as #MaxNextReviewBillingDays#--->
						<!--- <cfset nextDate = DateFormat(DateAdd('d',90,NOW()),"mm/dd/yyyy")> --->
						<cfset nextDate = DateFormat(DateAdd('d',#MaxNextReviewBillingDays#,NOW()),"mm/dd/yyyy")>
						<cfelse>
						<cfset nextDate = DateFormat(DateAdd('d',30,NOW()),"mm/dd/yyyy")>
						</cfif>
						<input type="text" name="nextReviewDate" size="10" value="#nextDate#">
						<a onclick="show_calendar2('document.forms[0].nextReviewDate',document.getElementsByName('nextReviewDate')[0].value);"> <img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
					</td>
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
				<cfelseif IsDefined("Assessment") AND Assessment.GetIsBillingActive()>
				<tr>
					<td class="assessmentHeader">Print</td>
					<td>
						<a href="index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
					</td>
				</tr>
				</cfif>
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
				<td><input type="text" name="tenantweight" value="#Variables.tenantweight#" size="10"> Lbs</td>	
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
				<tr>
					<td class="assessmentHeader" align="left">Diagnosis:<br>
					<cfif #ServicePlan.GetDiagnosis()# neq ''>
					<textarea name="diagnosis" rows="5" cols="45">#ServicePlan.GetDiagnosis()#</textarea>
					<cfelse>
					<textarea name="diagnosis" rows="5" cols="45"></textarea>
					</cfif>
					</td>
					<td class="assessmentHeader" align="left" colspan="2">Allergies:<br>
					<cfif #ServicePlan.GetAllergies()# neq ''>
					<textarea name="allergies" rows="5" cols="45">#ServicePlan.GetAllergies()#</textarea>
					<cfelse>
					<textarea name="allergies" rows="5" cols="45"></textarea>
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
		<td align="left" class="assessmentDirections">There are 12 sections to complete on this assessment.&nbsp;&nbsp;There will be only one score in each subsection <u>unless otherwise indicated</u>.&nbsp;&nbsp;<u>Questions in <b>bold type</b> are asked of each resident</u>.&nbsp;&nbsp;Answer Yes or NO to each question.&nbsp;&nbsp;For all items marked <b>NURSE</b>, the nurse should be consulted prior to accepting a potential resident.&nbsp;&nbsp;For items marked <strong>RDO</strong>, the <strong>RDO</strong> must be consulted before accepting a potential resident.<br><font color="red">Items with the RED text below them require that you select a sub-item, not just the No/Yes options.</font><br><font color="red">Base Service Level MUST BE CHECKED NO if notes are to be added.</font></td>
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