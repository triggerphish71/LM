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
| ranklam    | 10/12/2006 | Created                                                            |
| ranklam    | 10/12/2006 | Changed sum(itotalhours) to a case statment to return 1 if total   |                                                            |
|            |            | hours are 0                                                        |
----------------------------------------------------------------------------------------------->

<cfquery name="GetAverageActivitiesHours" datasource="#ftads#">
	select 
		sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / case when sum(iTotalHours) = 0 then 1 else sum(iTotalHours) end as Avg_rate
	from 
		AveHourlyWageRates 
	where 
		vcMonthYear = '#DateFormat(Datetouse,'mmmm YYYY')#' 
	and 
		vcHouseNumber = '#HouseNumber#' 
	and 
		dtRowDeleted IS NULL 
	and 
		vcPayCodeName is not NULL 
	and 
		vcCategory = 'Activities'
</cfquery>