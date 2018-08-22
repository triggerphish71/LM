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
| sathya     | 01/14/2010 | Modified As per Project 41315 added code to get  the height and    |    
|            |            | weight and DOB of tenant by calling in the tenant component.       |
|----------------------------------------------------------------------------------------------|
|Sathya      | 02/17/2010 | Modified as per project 41315-B added code to get service category |
|---------------------------------------------------------------------------------------------->
<cfparam name="assessmentId" default="0">
<cfscript>
	Assessment = CreateObject("Component","Components_OLD.Assessment");
	Assessment.Init(assessmentid,application.datasource,application.leadtrackingdbserver,application.censusdbserver);
	//02/17/2010 Sathya added this as part of project 41315-B
	AssessmentServiceCategory = Assessment.GetServicesCategory();
	 // This changes Ends here for project 41315-B (Documented this for ease of the developer who is moving this code)
	
	AssessmentServiceArray = Assessment.GetServices();
	AssessmentSubServiceArray = Assessment.GetSubServices();
	// 01/15/2010 Sathya added this part of project 41315 
	tenantId = Assessment.GetTenantID();
	residentId = Assessment.GetResidentID();
	Tenant = CreateObject("Component","Components_OLD.Tenant");
	Tenant.Init(tenantId,residentId,application.datasource,application.LeadTrackingDBServer,application.censusdbserver);
	getTenantDob = Tenant.GetBirthDate(application.datasource);
	getTenantWeight = Tenant.GetWeight(application.datasource);
	getTenantHeight = Tenant.GetHeight(application.datasource);
	
</cfscript>
