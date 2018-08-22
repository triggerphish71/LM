<cfquery name="GetAverageMaintenanceHours" datasource="#ftads#">	
	select 
		(CASE WHEN ((sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) 
		else (mAvg_rate*iTotalHours) end)) <> 0) THEN
		sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) 
		else (mAvg_rate*iTotalHours) end) / sum(iTotalHours) ELSE 0 END) as Avg_rate
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
		vcCategory = 'Maintenance'
</cfquery>