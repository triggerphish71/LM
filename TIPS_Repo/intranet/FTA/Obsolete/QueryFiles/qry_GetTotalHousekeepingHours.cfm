<cfquery name="GetTotalHousekeepingHours" datasource="#ftads#">
	select 
		sum(iTotalHours) as Avg_rate
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
		vcCategory = 'Housekeeping'
</cfquery>