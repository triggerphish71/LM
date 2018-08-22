<cfquery name="getAverageHoursByCategory" datasource="#ftads#">
	select 
		* 
	from 
		AveHourlyWageRates 
	where 
		dtThrough = '#lastdayofdatetouse#' 
	and 
		vcHouseNumber = '#HouseNumber#' 
	and 
		dtRowDeleted IS NULL 
</cfquery>