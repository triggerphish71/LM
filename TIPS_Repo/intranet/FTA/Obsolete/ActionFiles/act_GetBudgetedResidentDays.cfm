<cfparam name="yearforqueries" default="#year(now())#">
<cfparam name="unitId" default="0">
<cfparam name="datetouse" default="#now()#">

<cfinclude template="..\QueryFiles\qry_GetBudgetedResidentDays.cfm">

<cfif GetBudgetedResidentDays.RecordCount gt 0>
	<cfset tenantDaysForMonth = GetBudgetedResidentDays.residentDays>
<cfelse>
	<cfthrow message="No budgeted resident days found for unit #unitId# for the month of #DateFormat(datetouse,"mmm")#.">
</cfif>