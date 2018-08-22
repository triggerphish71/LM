<cfquery name="GetTotalKitchenHours" datasource="#ftads#">
	select 
		iTotalHours 
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
		vcCategory = 'Kitchen'
</cfquery>