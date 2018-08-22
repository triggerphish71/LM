<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 01/31/2006 | Created                                                            |
| ranklam    | 08/09/2006 | Changed gethouseinfo.ihouse_id to houseid                          |
----------------------------------------------------------------------------------------------->

<cfparam name="yearforqueries" default="#DatePart("y",now())#">
<cfparam name="houseId" default="0">

<cfquery name="GetBudgetedKitchenOther" datasource="#ComshareDS#">
	select 
		 year_id
		,unit_id
		,sum(jan) as Jan
		,sum(feb) as feb
		,sum(mar) as mar
		,sum(apr) as apr
		,sum(may) as may
		,sum(jun) as jun
		,sum(jul) as jul
		,sum(aug) as aug
		,sum(sep) as sep
		,sum(oct) as oct
		,sum(nov) as nov
		,sum(dec) as dec
		,sum(q1) as q1
		,sum(q2) as q2
		,sum(q3) as q3
		,sum(q4) as q4
		,sum(yr) as yr
	from 
		ALC.FINLOC_BASE
	where
		year_id= #yearforqueries#   
	and
		(Line_id = 4315 
			OR
		 Line_id BETWEEN 4330 AND 4399)
	and               
		unit_id= #houseId#  
	and
		ver_id=  1  
	and
		Cust1_id= 0  
	and
		Cust2_id= 0  
	and
		Cust3_id= 0  
	and
		Cust4_id= 0  
	group by
		 year_id
		,unit_id
</cfquery>