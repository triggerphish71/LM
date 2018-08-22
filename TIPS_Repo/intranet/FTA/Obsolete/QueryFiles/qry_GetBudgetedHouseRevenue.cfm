<cfparam name="unitId" default="0">
<cfparam name="yearforqueries" default="#Year(Now())#">

<cfquery name="GetBudgetedHouseRevenue" datasource="#ComshareDS#">
	select 
		*
	from 
		ALC.FINLOC_BASE
	where
		year_id = #yearforqueries# 		
	and
		Line_id =	80000015 	
	and
		unit_id =	#unitId#		
	and
		ver_id = 1		
	and
		Cust1_id = 0		
	and
		Cust2_id = 0		
	and
		Cust3_id = 0	
	and
		Cust4_id = 0
</cfquery>