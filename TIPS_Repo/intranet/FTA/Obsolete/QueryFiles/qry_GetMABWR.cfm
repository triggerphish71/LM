<cfquery name="getMABWR" datasource="#ComshareDS#">
	select 
		*
	from 
		ALC.FINLOC_BASE
	where
		year_id =	#yearforqueries# 		
	and
		Line_id =	80000097 	
	and
		unit_id =	#unitId#		
	and
		ver_id = 1		
	and
		Cust1_id = 0		
	and
		Cust2_id = 0		
	and
		Cust3_id = 80000003	
	and
		Cust4_id = 0		
</cfquery>