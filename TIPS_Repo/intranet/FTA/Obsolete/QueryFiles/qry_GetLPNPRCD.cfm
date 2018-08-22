<cfquery name="getLPNPRCD" datasource="#ComshareDS#">
	select 
		P0
	from 
		ALC.FINLOC_BASE
	where
		year_id =	#yearforqueries# 		
	and
		Line_id =	80000117 
	and
		unit_id =	#unitId#	
	and
		ver_id = 1		
	and
		Cust1_id = 0		
	and
		Cust2_id = 0		
	and
		Cust3_id  IN ('80000005','80000028','80000079','80000089')
	and
		Cust4_id = 0
	and
		P0 IS NOT NULL
	and
		P0 <> 0.0
</cfquery>