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
| sathya     | 01/14/2010 | Modified As per Project 41315 added code to get                    |    
|            |            | MaxNextReviewBillingDays by calling in the ReviewType component.   |
|---------------------------------------------------------------------------------------------->
<cfscript>
	ReviewType = CreateObject("Component","Components.ReviewType");
	ReviewTypeArray = ReviewType.GetReviewTypes(application.datasource);
	// 01/11/2010 As per Project 41315 sathya Added this to get the Maximum Next Review billing Days
	MaxNextReviewBillingDays = ReviewType.GetMaxFutureBillingDays(application.datasource);
	
</cfscript>