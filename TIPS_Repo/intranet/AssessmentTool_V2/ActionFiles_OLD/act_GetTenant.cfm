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
| sathya     | 01/14/2010 | Modified As per Project 41315 added code to get  the heigth and    |    
|            |            | weight of tenant by calling in the tenant component.               |
|---------------------------------------------------------------------------------------------->
<cfparam name="tenantId" default="0">
<cfparam name="residentId">
<cfscript>
	Tenant = CreateObject("Component","Components_OLD.Tenant");
	Tenant.Init(tenantId,residentId,application.datasource,application.LeadTrackingDBServer,application.censusdbserver);
	// 01/12/2010 As per Project 41315 sathya Added this to get DOB, height and weight of the tenant
	getTenantDob = Tenant.GetBirthDate(application.datasource);
	getTenantWeight = Tenant.GetWeight(application.datasource);
	getTenantHeight = Tenant.GetHeight(application.datasource);
	getActiveAssessmentID = Tenant.GetAssessmentId(application.datasource);
</cfscript>