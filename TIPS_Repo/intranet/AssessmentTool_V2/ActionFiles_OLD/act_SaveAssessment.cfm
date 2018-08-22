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
| jcruz      | 06/26/2008 | Modified by adding four new SET statements (lines 88 - 91)		   |
|            |            | as part of project 12392 to incorporate Service Plans	           |
|			 |			  | into the assessment process.									   |
|----------------------------------------------------------------------------------------------|
| sathya     | 01/14/2010 | As per Project 41315 added code to save the heigth and weight of   |
|            |            | the tenant by calling in the tenant component.                     |
|----------------------------------------------------------------------------------------------|
| Sathya     | 02/17/2010 | As per project 41315-B added code for category notes to be saved   |
---------------------------------------------------------------------------------------------->


<cfparam name="assessmentId" default="0">
<cfparam name="tenantId" default="0">
<cfparam name="residentId" default="0">

<cfscript>
	//first we need to figure out which services and subservices we are using
	FieldArray = ListToArray(form.fieldnames);
	//create arrays to hold hte services, subservices, and notes
	ServiceArray = ArrayNew(1);
	SubServiceArray = ArrayNew(1);
	NotesArray = ArrayNew(2);
	
	//02/17/2010 sathya added this for category as part of project 41315-B
	ServiceCategoryArray = ArrayNew(1);
    // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
	
	for(i = 1; i lte ArrayLen(FieldArray); i = i + 1)
	{
		
		//look for subservices first
		if(FindNoCase("subservice",FieldArray[i]) neq 0)
		{	
			
			if(ListLen(Form[FieldArray[i]],",") eq 1)
			{
				ArrayAppend(SubServiceArray,Form[FieldArray[i]]);
			}
			else
			{
				theArray = ListToArray(Form[FieldArray[i]]);
				
				for(x = 1; x lte ArrayLen(theArray); x = x + 1)
				{
					ArrayAppend(SubServiceArray,theArray[x]);
				}
			}
		}
		else if(FindNoCase("service",FieldArray[i]) neq 0)
		{
			if(Form[FieldArray[i]] eq "yes")
			{
				//well need to pull the service ID from the form field name so i'll convert the form field name to 
				//a list and use the list get at function
				ArrayAppend(ServiceArray,ListGetAt(FieldArray[i],2,"_"));
			}
		}
		else if(FindNoCase("notes",FieldArray[i]) neq 0)
		{
			x = ArrayLen(NotesArray);
			x = x + 1;
			
			//well need to pull the service ID from the form field name so i'll convert the form field name to 
			//a list and use the list get at function
			NotesArray[x][1] = ListGetAt(FieldArray[i],3,"_");
			NotesArray[x][2] = Form[FieldArray[i]];
		}
		
	}
	
	
	//02/19/2010 sathya as per project 41315-B had to add this for category
	//Had to add seperate code as Service category has no option being selected 
	// So have to loop through the notes array to see if it has that particular category number
	for(i = 1; i lte ArrayLen(FieldArray); i = i + 1)
	{
	  if (FindNoCase("category",FieldArray[i]) neq 0)
	  {
	     //	x = ArrayLen(NotesArray);
		//	x = x + 1;
	  	for(j = 1; j lte ArrayLen(NotesArray); j = j + 1)
	  	{
	  	 if(NotesArray[j][1] eq ListGetAt(FieldArray[i],2,"_"))
	  	 {
	  	 	 ArrayAppend(ServiceCategoryArray,ListGetAt(FieldArray[i],2,"_"));
	  	 }
	  	}
	  }
	}
	 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
	
	Assessment = CreateObject("Component","Components_OLD.Assessment");	
	Assessment.Init(form.assessmentId,application.datasource,application.leadtrackingdbserver,application.censusdbserver);
	
	Assessment.SetAssessmentTool(Form["assessmentTool"]);
	Assessment.SetReviewType(Form["reviewType"]);
	Assessment.SetNextReviewDate(Form["nextReviewDate"]);
	Assessment.SetServices(ServiceArray,NotesArray);
	Assessment.SetSubServices(SubServiceArray);
	Assessment.SetStatusCode(Form["statuscode"]);
	Assessment.SetDiagnosis(Form["diagnosis"]);
	Assessment.SetAllergies(Form["allergies"]);
	Assessment.SetOtherServices(Form["otherservices"]);
	
	//02/17/2010 As per project 41315-B add this for the categoryId to be added in the assessmentdetail table
	Assessment.SetServicesCategory(ServiceCategoryArray,NotesArray);
	 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
		
	if(finalize)
	{
		Assessment.SetIsFinalized(true);
		// Modified By Ssathya on 02/26/2008----Suggested by Ryan to add the ReviewEndDate to current date and time---
		Assessment.SetReviewEndDate(DateFormat(Now(),"mm/dd/yy hh:mm:ss"));
	}
		Assessment.Save(NotesArray);
		
	// 01/14/2010 As per Project 41315 Sathya Added this to save the heigth and weight of the tenant
	Tenant = CreateObject("Component","Components_OLD.Tenant");
	Tenant.Init(tenantId,residentId,application.datasource,application.LeadTrackingDBServer,application.censusdbserver);
	Tenant.SetTenantHeight(Form["getcalculatedheight"]);
	Tenant.SetTenantWeight(Form["tenantweight"]);
	Tenant.UpdateTenantInfo();
			
</cfscript>

<cfoutput>

<cfset printUrl = "http://#cgi.SERVER_NAME#/intranet/AssessmentTool_V2/index.cfm?fuse=printAssessment&assessmentId=#assessment.GetId()#">

<script language="javascript">
	window.open('#printUrl#','_blank');
</script>
</cfoutput>
