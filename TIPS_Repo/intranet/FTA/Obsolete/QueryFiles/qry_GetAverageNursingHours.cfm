<cfquery name="GetAverageNursingHours" datasource="#ftads#">
	select 
		sum(case when vcPayCodeName = 'Overtime' then ((mAvg_rate*iTotalHours) * 1.5) else (mAvg_rate*iTotalHours) end) / case when sum(iTotalHours) <> 0 then sum(iTotalHours) else 999999999 end as Avg_rate
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
		vcCategory = 'Nurse Consultant'
</cfquery>