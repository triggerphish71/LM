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
| gthota     | 02/28/2013 | Added new code for assessment print option                         |
| Gthota     | 03/38/2013 | added code for disable to active assessment activate button link   |
| S Farmer   | 02/03/2015 |Review after Initial Review changed from 30 days to 90 days         |
| M shah	 | 05/13/2016 | Mshah added assessment tool 28, 29, 30 to code LINE NUM 556 AND 441|
| S Farmer   | 03-24-2017 | addDays2GivenDate & ChangeDateRange if( isNaN(reviewType)   )      |
|            |            | days = 0; changed to {days = 90;                                   |
|  gthota    | 10-03-2017 | Added Care plan print option.                                       |
----------------------------------------------------------------------------------------------->
<cfset assessmentreview = createobject('component',"Components.Assessment")>
<cfset getassesst_p = assessmentreview.GETASSESST_P(tenantId = tenantId)>
<cfset getassesst = assessmentreview.GETASSESST(tenantId = tenantId)> 
<cfset assessmentCount = VAL(getassesst_p.P_BBILLINGACTIVE_CNT + getassesst.BBILLINGACTIVE_CNT)> 
<cfset DCheck = assessmentreview.DCheck()>  
<cfset ListVal = ValueList(DCheck.cDescription)>
<cfif ListFindNoCase("WA,OR",session.house.getstatecode(),",") EQ 1>
	<cfset  assessmentToolid = 26>
	<cfset  cSLevelTypeID = 15>
<cfelse>
	<cfset assessmentToolid = 25>
	<cfset cSLevelTypeID = 14>
</cfif>

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

<!--- project 88898 for review date validation --->
   <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
	<cfelse>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6/jquery.min.js" type = "text/javascript"></script>
    <script src="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/jquery-ui.min.js" type = "text/javascript"></script> 
    <link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8/themes/base/jquery-ui.css" rel = "Stylesheet" type="text/css" /> 
		<script type = "text/javascript">
			$(function () {
				$("##idreviewStartDate").datepicker({
					onSelect: function (date, obj) {
						//alert("You selected: " + date);
						addDays2GivenDate();
					}, 					        
					showOn: 'button',
					buttonImageOnly: true,
					//buttonImage: 'http://jqueryui.com/demos/datepicker/images/calendar.gif'
					buttonImage: '../global/Calendar/calendar.gif'
					
				});
			});
		</script>
	</cfif>
  <script language="JavaScript" type="text/javascript">		
		function addDays2GivenDate(days)
		{			
			var datepicker = document.AssessmentFormView.reviewStartDate.value;
			var parms = datepicker.split("/");
			// mm/dd/yyyy
			var joindate = new Date(parms[0]+"/"+parms[1]+"/"+parms[2]);
			
			var AssessmentFormViewObj = document.AssessmentFormView;
			var selReviewType = AssessmentFormViewObj.reviewType.options[AssessmentFormViewObj.reviewType.selectedIndex].text;
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
			//return joinFormattedDate;			 
			AssessmentFormViewObj.nextReviewDate.value = joinFormattedDate;	
			return joinFormattedDate;
		}
		
		function ChangeDateRange()
		{
			var AssessmentFormViewObj = document.AssessmentFormView;
			var selReviewType = AssessmentFormViewObj.reviewType.options[AssessmentFormViewObj.reviewType.selectedIndex].text;
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
		    
			AssessmentFormViewObj.nextReviewDate.value = addDays2GivenDate(days); //addDays2CurrentDate(days);	
		
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

<!--- 01/15/2010 Sathya added this as per Project 41315 --->
<script language="JavaScript" type="text/javascript">	
	
	function statusvalidation(formCheck)
	{
		//01/11/2010 Sathya Project 41315 added this varibles to check for reviewdate validation
		
		var rwDate = new Date(formCheck.reviewStartDate.value);
		var reviewStart = new Date(formCheck.reviewStartDate.value);
		var reviewDateCheck = new Date(formCheck.nextReviewDate.value);
		
		var MaxBillingDay = formCheck.MaxReviewBillingDays.value;
		
	//	var today = new Date();
    //    var priorDate = new Date().setDate(today.getDate()-30);
        
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
		if(formCheck.tenantweight.value < 10)// || formCheck.tenantweight.value.length == 1 )
		{
			formCheck.tenantweight.focus();
			alert("Please enter a valid Tenant weight to proceed!");
			return false;
		}	
		if(formCheck.tenantheightinfeet.value == 0)
		{
			formCheck.tenantheightinfeet.focus();
			alert("Please enter a Tenant height in feet to proceed!");
			return false;
		}
		if(formCheck.tenantheightinfeet.value == 0 && formCheck.tenantheightinc.value == 0)
		{
			formCheck.tenantheightinc.focus();
			alert("Please enter a Tenant height in feet to proceed!");
			return false;
		}
		//sathya this check is for if the review date being selected is greater than the (review start date of assessment + Maximun Future billing days)
		if(reviewDateCheck > reviewStart)
		{
			formCheck.nextReviewDate.focus();
			alert("This assessment was done on "+rwDate.toDateString()+". The next Assessment due can not be greater than "+MaxBillingDay+"days!. Please pick another due date for next assessment.");
			return false;
		}
		// Added project -88898  depends on user selection on Base level option 
		var base =document.getElementById('base');
		var baseno =document.getElementById('baseno');	
						
		   if ((document.getElementById('base').value == "no" && document.getElementById('base').checked == true) && (totalPoints == 0 ))
				//(document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false))
			{
				if (document.getElementById('baseno').getAttribute('type') == 'radio')
					{  alert(" 0 Points selected base level option will be 'Yes'");
					  document.getElementById('baseno').checked = true;
					}
			}
			if((document.getElementById('base').value == "no" && document.getElementById('base').checked == false) && (document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == false) && (totalPoints == 0))
		   {
		     if (document.getElementById('baseno').getAttribute('type') == 'radio')
					{  //alert(" 0 Points selected base level option will be 'Yes'");
					  document.getElementById('baseno').checked = true;
					}
		   }
		   if((document.getElementById('base').value == "no" && document.getElementById('base').checked == false) && (document.getElementById('baseno').value == "yes" && document.getElementById('baseno').checked == true) && (totalPoints > 0))
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
			  //alert(" Base Level Option default it will select option - 'YES' Continue...  ");			  
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
<!---Ganga - added code for disable to active assessment activate button link --->
<cfquery name="GetdtBillingActive" datasource="#Application.Datasource#">
			SELECT  *
			FROM
				AssessmentToolMaster with (nolock)				
			WHERE
				 itenant_id = (SELECT  iTenant_id FROM	AssessmentToolMaster WHERE iAssessmentToolMaster_id = #ASSESSMENTID#) 
			 and bbillingActive =1 
	</cfquery> 	
	<cfquery name="GetbBillingActive" datasource="#Application.Datasource#">
			SELECT  *
			FROM
				AssessmentToolMaster with (nolock)				
			WHERE
				 itenant_id = (SELECT  iTenant_id FROM	AssessmentToolMaster WHERE iAssessmentToolMaster_id = #ASSESSMENTID#) 
			 and bbillingActive =0 and iAssessmentToolMaster_id = #ASSESSMENTID#
	</cfquery>
<!---Project 88898  05/02/2012  Diagnosis Types DropDown Query--->
 <cfquery name="DCheck" datasource="#Application.Datasource#">
		        SELECT iDiagnosisType_ID, cDescription
		        FROM DiagnosisType
		        WHERE dtRowDeleted is null order by cDescription
		 </cfquery>
 
<cfquery name="qregion" datasource="#Application.Datasource#">
        SELECT House.iHouse_ID AS HouseId, House.cName AS HouseName ,House.cNumber ,House.cCity ,House.cStateCode AS StateCode
		,OpsArea.cName AS OpsAreaName ,Region.cName AS RegionName 
		FROM House
		INNER JOIN  OpsArea	ON  OpsArea.iOpsArea_ID = House.iOpsArea_ID and opsarea.dtrowdeleted is null
		INNER JOIN  Region	ON  Region.iRegion_ID = OpsArea.iRegion_ID and region.dtrowdeleted is null		
			WHERE	
			House.dtRowDeleted IS NULL 
			and AssetClass is not null 
			and bIsSandbox = 0
			and Region.cName = 'EAST'
			and House.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
 </cfquery> 
    
<cfset ListVal = ValueList(DCheck.cDescription)>

<form name="AssessmentFormView" action="index.cfm"  method="post" onsubmit="return validate();">
<input type="hidden" name="moveinDate" id="moveindate" value="#DateFormat(moveinDate,'yyyy-mm-dd')#">
<table width="800" id="container">
	<tr>
		<td align="left">
			<table>
				<!--- 01/15/2010 Sathya Project 41315 added this to display date of birth --->	
				<tr>
					<td class="assessmentHeader">Date of Birth: </td>
					<td><input type="text" value="#DateFormat(getTenantDob,"mm/dd/yyyy")#" disabled="disabled"/></td>
				</tr>
				<tr>   <!--- project 88898 added review date range for new assessemnt 06/06/2012--->
					<td class="assessmentHeader">Review Date Range  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; From: </td>
					<cfset reviewStartDate = DateFormat(Assessment.GetReviewStartDate(),"mm/dd/yyyy")>
					<td><cfif IsDefined("Assessment") AND NOT Assessment.GetIsFinalized()>
							<cfif IsDefined("Assessment")>					    				
							<input type="text" name="reviewStartDate" id="idreviewStartDate" size="10" value="#reviewStartDate#" onblur="JavsScript:addDays2GivenDate();">
							<cfelse> <input type="text" name="reviewStartDate" id="idreviewStartDate" size="10" value="" ></cfif>
						<cfelse>
						    <input type="text" name="reviewStartDate" id="idreviewStartDate" size="10" value="#reviewStartDate#" onblur="JavsScript:addDays2GivenDate();" disabled="disabled">
						</cfif>
						
				 To : <cfif IsDefined("Assessment") AND Assessment.GetIsFinalized() >
					    <cfset reviewEndDate = DateFormat(Assessment.GetReviewEndDate(),"mm/dd/yyyy")> 
						 <input type="text" name="reviewEndDate" id="idreviewEndDate" size="10" value="#reviewEndDate#" >  
						<cfelse> Not Finalize </cfif>						
				 
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
					<td class="assessmentHeader">Review Type:</td><td>
						<!--- 01/28/2010 sathya as per project 41315 added this to display the old reviewtype even if they dont belong to the particular house --->
						<cfif IsDefined("Assessment") AND NOT Assessment.GetIsFinalized()>
							
						<select name="reviewType" onchange="JavsScript:ChangeDateRange();">              <!--- GetIsBillingActive() / onchange="ChangeDate(this,'nextReviewDate')"  --->
							<cfloop from="1" to="#arrayLen(reviewTypeArray)#" index="i">
								<!--- initial only --->
								<cfif assessmentCount EQ 0  AND ListFindNoCase("4,5,7",ReviewTypeArray[i].getID(),",") EQ 0>
									<option value="#ReviewTypeArray[i].getID()#">#ReviewTypeArray[i].getDescription()#</option>	
								<!--- initial, 30 day, change --->						
								<cfelseif (Points EQ 0) AND (assessmentCount EQ 1) AND ListFindNoCase("5",ReviewTypeArray[i].getID(),",") EQ 0>
									<option value="#ReviewTypeArray[i].getID()#" <cfif Assessment.GetReviewType().getID() EQ ReviewTypeArray[i].getID()>SELECTED</cfif>>#ReviewTypeArray[i].getDescription()#</option>
								<!--- 30 day and change --->
								<cfelseif (assessmentCount EQ 1) AND (points NEQ 0) AND ListFindNoCase("1,5",ReviewTypeArray[i].getID(),",") EQ 0>
									<option value="#ReviewTypeArray[i].getID()#" <cfif Assessment.GetReviewType().getID() EQ ReviewTypeArray[i].getID()>SELECTED</cfif>>#ReviewTypeArray[i].getDescription()#</option>
									<!--- 90 day and change --->
								<cfelseif (assessmentcount GTE 2) AND ListFindNoCase("1,7",ReviewTypeArray[i].getID(),",") EQ 0>
									<option value="#ReviewTypeArray[i].getID()#" <cfif Assessment.GetReviewType().getID() EQ ReviewTypeArray[i].getID()>SELECTED</cfif>>#ReviewTypeArray[i].getDescription()#</option>
								</cfif>
							</cfloop>
						
						<cfelseif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
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
				<cfif isDefined("Assessment") AND Assessment.GetIsFinalized() AND NOT Assessment.GetIsBillingActive() AND #GetbBillingActive.bbillingActive# eq 0>
				<cfif Assessment.GetReviewStartDate() GT DateAdd('d',-30,Now())>
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
						<!---<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized() >
						<cfelse>--->
						<a onclick="show_calendar3('document.forms[0].activeBillingDate',document.getElementsByName('activeBillingDate')[0].value);"> <img src="../global/Calendar/calendar.gif" alt="Calendar" width="16" height="15" border="0" align="middle" style="border: 3px solid ##ccccff;"> </a>
					<!---</cfif>	--->
					</td>
				</tr>

				</cfif>
			</cfif> <!--- 12352 --->
			<!--- 	<cfelseif IsDefined("Assessment") AND Assessment.GetIsBillingActive()> ---> <!--- 12352 --->
				<tr>
					<td class="assessmentHeader">Evaluation</td>
					<td> <cfif AssessmentToolArray[i].GetId() eq 25 or AssessmentToolArray[i].GetId() eq 26 or AssessmentToolArray[i].GetId() eq 27 or AssessmentToolArray[i].GetId() eq 28
					or AssessmentToolArray[i].GetId() eq 29 or AssessmentToolArray[i].GetId() eq 30>
					         <!---<a href="index.cfm?fuse=printAssessmentnew&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>--->
					       <cfif assessmentType eq "resident">
							   <a href="index.cfm?fuse=printAssessmentEnquiry&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
							<cfelse>
							   <a href="index.cfm?fuse=printAssessmentnew&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
							</cfif>
						 <cfelse>
						     <a href="index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
						 </cfif>
						<!---<a href="index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>--->
					</td>
				</tr>
			<!---	<cfif #GetbBillingActive.bbillingActive# NEQ 0>  --->
			<!--- Gthota 10/06/2017  - Added code for care plan assessment will show seleted service list only in pdf  --->	
			<!---	<cfif #SESSION.qSelectedHouse.iHouse_ID# EQ 230 or #SESSION.qSelectedHouse.iHouse_ID# EQ 287 or #SESSION.qSelectedHouse.iHouse_ID# EQ 288 or #SESSION.qSelectedHouse.iHouse_ID# EQ 229 
				or #SESSION.qSelectedHouse.iHouse_ID# EQ 254 or #SESSION.qSelectedHouse.iHouse_ID# EQ 265 or #SESSION.qSelectedHouse.iHouse_ID# EQ 266 or #qregion.recordcount# GT 0>  --->
				<tr>
					<td class="assessmentHeader">Care Plan  </td>
					<td> <cfif AssessmentToolArray[i].GetId() eq 25 or AssessmentToolArray[i].GetId() eq 26 or AssessmentToolArray[i].GetId() eq 27 or AssessmentToolArray[i].GetId() eq 28
					or AssessmentToolArray[i].GetId() eq 29 or AssessmentToolArray[i].GetId() eq 30>
					         
					       <cfif assessmentType eq "resident">
							   <a href="index.cfm?fuse=printAssessmentcareInquiry&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
							<cfelse>
							   <a href="index.cfm?fuse=printAssessmentcare&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
							</cfif>
						 <cfelse>
						     <a href="index.cfm?fuse=printAssessmentcare&assessmentId=#assessment.GetId()#" class="breadcrumbs" target="_blank">Print</a>
						 </cfif>
						
					</td>
				</tr>
				<!--- </cfif> ---> 
				<!--- Gthota 10/06/2017  - care plan code END --->	
			<!---	</CFIF> --->
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
				<td><input type="text" name="tenantweight" value="#Variables.tenantweight#" size="10" maxlength="5"> Lbs</td>	
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
					<td class="assessmentHeader" align="left"> <!---Project 88898 for new assessments 05/14/2012 --->
				<!--- <cfif reviewStartDate gt '06/01/2012'>--->
				<cfif Assessment.GetAssessmentTool().GetId() EQ 26 or Assessment.GetAssessmentTool().GetId() EQ 25 or 
			    Assessment.GetAssessmentTool().GetId() EQ 27 or Assessment.GetAssessmentTool().GetId() EQ 28 or Assessment.GetAssessmentTool().GetId() EQ 29
                or Assessment.GetAssessmentTool().GetId() EQ 30>
				 Diagnosis Types:   <br><br />
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
				  
				</cfif>					
					</td>
					<td class="assessmentHeader" align="left" colspan="2">Admitting Diagnosis Notes:<br>
					<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized()>
					<textarea name="diagnosis" rows="5" cols="45" disabled="disabled">#Assessment.GetDiagnosis()#</textarea>
					<cfelse>
					<cfif IsDefined("Assessment")>
					<textarea name="diagnosis" rows="5" cols="45">#Assessment.GetDiagnosis()#</textarea>
					<cfelse>
					<textarea name="diagnosis" rows="5" cols="45"></textarea>
					</cfif></cfif>
					<br />Allergies:<br>
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
		
<td align="left" class="assessmentDirections">There are 12 sections to complete on this assessment. Answer Yes or No to each question. You will be required to add service plan notes in the <b>add notes</b> section for every <b>Yes answer</b>. You will not be able to finalize the assessment if you do not add notes.  For all items marked <b>NURSE</b>, the nurse should be consulted prior to accepting the potential resident.&nbsp;&nbsp; For items marked <strong>RDO</strong>, the <strong>RDO</strong> must be consulted prior to accepting the resident.&nbsp;&nbsp;<!---<font color="red">Select YES Questions REQUIRED <u>Note</u> Information before Saving</font>---></td>

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
	<input type="button" value="Save" onmouseover="return statusvalidation(AssessmentFormView);" onclick="SubmitAssessment('new')"  class="assessmentMain"> 
</cfif>
<cfif isDefined("Assessment") AND NOT Assessment.GetIsFinalized()>
	<!--- 01/15/2010 sathya as per project 41315 added the validation onmouseover="return statusvalidation(AssessmentForm);" --->
	<!---<cfif session.House.GetId() eq 17>--->
&nbsp;&nbsp;<input type="submit" value="Finalize" onmouseover="return statusvalidation(AssessmentFormView);" class="assessmentMain" />
   <!---<cfelse><input type="button" value="Finalize" onmouseover="return statusvalidation(AssessmentFormView);" onclick="SubmitAssessment('finalize')" class="assessmentMain">
   </cfif>--->
         <!--- <input type="submit" value="Submit" class="assessmentMain"---> <!--- onclick="validation(this)" --->
<!---onmouseover="return statusvalidation(AssessmentFormView);" onclick="SubmitAssessment('finalize')"--->

</cfif>
</cfoutput>
</form>
 <!---project 88898 - Ganga 06/11/2012  Checking yes/no radio button for finalize  validation--->
<script type="text/javascript">
	serviceArray = vServiceList.split(',');
   // notesArray = vnotesList.split(',');
	
	function validate()
	{ 
		frmObj = document.AssessmentFormView;
		msg = '';
		
		for( i=0; i < serviceArray.length-1 ; i++)
		{  
			radioName = serviceArray[i];
			labelName = strip( trim( document.getElementById('t_'+radioName).innerHTML ) );	
			classN = 'classRight';		

			if( frmObj[radioName][0].checked ==false && frmObj[radioName][1].checked==false )
			{   
				msg = msg + 'Pls check '+labelName+'\n';
				classN = 'classWrong'
			}
			document.getElementById('t_'+radioName).className = classN;			

			/*if( frmObj[radioName][0].checked ==true && frmObj[radioName][0].value=='Yes' && frmObj[radioName+'Notes_'].value=='' )
			{
				msg = msg + 'Pls enter notes for '+labelName+'\n';
				classN = 'classWrongNotes'
			}*/
			//document.getElementById(radioName+'Notes_').className = classN;			
		}
		if( msg.length > 0 )
		{
			alert(msg);
			return false;
		}
		else
		{
			return true;
		}
	}
	function trim (str) {
		str = str.replace(/^\s+/, '');
		for (var i = str.length - 1; i >= 0; i--) {
			if (/^\S/.test(str.charAt(i))) {
				str = str.substring(0, i + 1);
				break;
			}
		}
		return str;
	}	
	function strip(html)
	{
	   var tmp = document.createElement("DIV");
	   tmp.innerHTML = html;
	   return tmp.textContent||tmp.innerText;
	}	

	
function validate()
	{ 
		frmObj = document.AssessmentFormView;
		serviceArray = vServiceList.split(',');		
		msg = 'Missing Response for the following Questions: \n';
		
		for( i=0; i < serviceArray.length-1 ; i++)
		{  
			radioName = serviceArray[i];
			labelName = strip( trim( document.getElementById('t_'+radioName).innerHTML ) );				
			classN = 'classRight';	
			
            // checking 1-yes/0-no button true or false in each and every service.
			if( frmObj[radioName][0].checked ==false && frmObj[radioName][1].checked==false )
			{   
				msg = msg + ''+labelName+'\n';
				classN = 'classWrong'				
			}
			document.getElementById('t_'+radioName).className = classN;	
			
			// checking notes is not null when you select radio button yes option.
			serviceId = radioName.substring(radioName.indexOf('_') + 1,serviceArray[i].length);

			if(frmObj[radioName][1].checked ==true && frmObj[radioName][1].value=='yes' && typeof frmObj['add_notes_'+serviceId] != 'undefined'  )
			{  
				if( frmObj['add_notes_'+serviceId].value=='' )
				{
					msg = msg + 'Please Enter Notes for Question: \n'+labelName+'\n';
					classN = 'classWrongNotes';
					//alert(frmObj[radioName][1].checked+'  ' + frmObj[radioName][1].value+'  '+ frmObj['add_notes_'+serviceId].value);
				}
			} 
			if( typeof frmObj['add_notes_'+serviceId] != 'undefined' )
			{
				document.getElementById('add_notes_'+serviceId).className = classN;				
			}
		}
		
		if( msg.length > 48 )
		{
			alert(msg);
			return false;
		}
		else
		{  // If validation is true/done finalize the assessment.
			SubmitAssessment('finalize');
		}
	}
</script>
<!--- this needs to go here so the submit button gets disabled --->
<cfif IsDefined("Assessment") AND Assessment.GetIsFinalized() OR Assessment.GetReviewStartDate() LT DateAdd('d',-30,Now())>
	<script language="javascript">
		DisableAll();
	</script>
</cfif>