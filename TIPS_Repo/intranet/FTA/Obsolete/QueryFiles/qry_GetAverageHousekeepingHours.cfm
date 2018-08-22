<cfquery name="GetAverageHouseKeepingHours" datasource="#ftads#">
	select 
		sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) as Avg_rate
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