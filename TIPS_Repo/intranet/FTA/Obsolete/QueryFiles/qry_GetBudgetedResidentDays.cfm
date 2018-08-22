<cfparam name="yearforqueries" default="#year(now())#">
<cfparam name="unitId" default="0">
<cfparam name="datetouse" default="#now()#">

<cfquery name="GetBudgetedResidentDays" datasource="#FtaDs#">
	select distinct
		SUM(#DateFormat(datetouse,"mmm")#) AS residentDays
	from 
		dbo.HouseCensusBudget
	where
		iHouseId = #unitId# AND
		iYear =	#yearforqueries#;
</cfquery>