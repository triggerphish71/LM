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
| jcruz      | 06/26/2008 | Modified by adding four new form fields 						   |
|            |            | as part of project 12392 to incorporate Service Plans	           |
|			 |			  | into the assessment process.									   |
|----------------------------------------------------------------------------------------------|
| sathya     | 01/14/2010 | Modified this as part of project 41315. Added the height and weight|
|            |            | of the tenant to be saved in the tenant table by calling tenant    |
|            |            | component and by updating the information                          |
|----------------------------------------------------------------------------------------------|
| Sathya     | 02/18/2010 | As per project 41315-B added code for service category notes to be |
|            |            | saved. Added a ServiceCategoryArray to store the CategoryID.       |
|            |            | Added a condition to check the service category. 
----------------------------------------------------------------------------------------------->

<cfparam name="tenantId" default="0">
<cfparam name="residentId" default="0">

<cfscript>
	//first we need to figure out which services and subservices we are using
	FieldArray = ListToArray(form.fieldnames);
	//create arrays to hold hte services, subservices, and notes
	ServiceArray = ArrayNew(1);
	SubServiceArray = ArrayNew(1);
	NotesArray = ArrayNew(2);
	//02/18/2010 sathya added this for category as part of project 41315-B
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
	
	//create a new assessment
	//Modified by Jaime Cruz to include Service Plan data
	Assessment = CreateObject("Component","Components.Assessment");	
	Assessment = Assessment.New(Form["assessmentTool"]
							   ,tenantId
							   ,residentId
							   ,Form["reviewType"]
							   ,0
							   ,DateFormat(NOW(),"mm/dd/yyyy")
							   ,false
							   ,""
							   ,false
							   ,""
							   ,Form["nextReviewDate"]
							   ,""
							   ,""
							   ,""
							   //02/18/2010 Sathya added ServiceCategoryArray as part of Project 41315-B
							   ,ServiceCategoryArray
							    // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
							   ,ServiceArray
							   ,SubServiceArray
							   ,NotesArray
							   ,application.datasource
							   ,application.LeadTrackingDBServer
							   ,application.CensusDBServer
							   ,Form["statuscode"]
							   ,Form["diagnosis"]
							   ,Form["allergies"]
							   ,Form["otherservices"]); 
							   

     // 01/14/2010 As per Project 41315 Sathya Added this to save the heigth and weight of the tenant
	Tenant = CreateObject("Component","Components.Tenant");
	Tenant.Init(tenantId,residentId,application.datasource,application.LeadTrackingDBServer,application.censusdbserver);
	Tenant.SetTenantHeight(Form["getcalculatedheight"]);
	Tenant.SetTenantWeight(Form["tenantweight"]);
	Tenant.UpdateTenantInfo();							   
</cfscript>

<cflocation url="index.cfm?fuse=assessmentMain">