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
| ranklam    | 12/14/2006 | Created                                                            |
----------------------------------------------------------------------------------------------->
<cfscript>
	AptType = CreateObject("Component","Components.AptType");
	AptTypeArray = AptType.GetAllAptTypes(application.datasource);

	//create a list of apttype id's to pass to the processing page.	
	aptTypeList = "";

	for(i = 1; i lte ArrayLen(AptTypeArray); i = i + 1)
	{
		aptTypeList = aptTypeList & AptTypeArray[i].GetId() & ",";
	}
</cfscript>