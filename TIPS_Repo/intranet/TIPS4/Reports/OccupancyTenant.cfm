<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfquery name="qrytenantid" DATASOURCE = "#APPLICATION.datasource#">
select   dtrundate,itenantid, cResidencyType, cAptNumber, iHouseId from     maple.occupancy.dbo.log_OccupancySummaryDetailsHistory lo 
   where  
    dtrundate between '2013-03-31' and '2013-04-01' 
	and ispoints is null and iHouseId = 16
</cfquery>
<body>
<table>
<cfset countthis = 1>
<cfoutput> 
<tr><td> countthis </td><td> itenantid  </td><td>iHouseId</td><td>  dtrundate </td> <td>cResidencyType</td><td>   iSPoints   </td><td> amountLOC </td><td>  amountBSF  </td><td> occupancy   </td><td>room type</td><td> AdjRate.mamount</td><TD>DISCOUNT AMT</TD></tr>
 
<cfloop query="qrytenantid">
 


<cfquery name="qryispoints" DATASOURCE = "#APPLICATION.datasource#">
SELECT top 1  P_TenantState.iTenantState_ID
	,P_TenantState.iTenant_ID
	,iSPoints
	,P_TenantState.dtRowEnd
	,iAptAddress_ID
	,ihouse_id
	,iResidencyType_ID
FROM [TIPS4].[dbo].[P_TenantState]
	join p_tenant on P_TenantState.itenant_id = p_tenant.itenant_id
  where p_tenant.itenant_id = #itenantid#   
  and P_TenantState.dtrowend < '2013-04-01'
  order by P_TenantState.dtrowend desc
</cfquery>

<cfquery name="qryApt" DATASOURCE = "#APPLICATION.datasource#">
 
 select  top 1  chg.mamount as amountBSF 
   
	from  AptAddress aptadr   
	join  AptType apttyp on aptadr.iAptType_ID = apttyp.iAptType_ID
	join  house h on  h.ihouse_id = #qryispoints.ihouse_id#
	join  ChargeSet chgset on h.iChargeSet_ID = chgset.iChargeSet_ID  
 	join  charges  chg on chg.iHouse_id  = #qryispoints.ihouse_id#
	and chg.iAptType_ID = aptadr.iAptType_ID
	and chg.cchargeset = chgset.cname
	and chg.iResidencyType_ID = #qryispoints.iResidencyType_ID#
 
where aptadr.iAptAddress_ID = #qryispoints.iAptAddress_ID#   
</cfquery>
<cfset occupancy = 0>
<cfquery name="qryoccupancy" DATASOURCE = "#APPLICATION.datasource#">
 select  top 1 iOccupancyPosition , rc.dtrowend
	from  p_RecurringCharge rc
   join  p_charges  chg on rc.icharge_id = chg.icharge_id 
   and rc.dtrowdeleted is null and chg.dtrowdeleted is null
 and chg.ichargetype_id  in  (7,8,89,1642, 1689, 1690, 1691, 1692, 1693, 1695,1725, 1726)
where	 rc.itenant_id = #itenantid#     and rc.dtrowend < '2013-04-01'
 
union 
 select  top 1 iOccupancyPosition , rc.dtrowend
	from  RecurringCharge rc
   join  charges  chg on rc.icharge_id = chg.icharge_id 
   and rc.dtrowdeleted is null and chg.dtrowdeleted is null
  and chg.ichargetype_id  in  (7,8,89,1642, 1689, 1690, 1691, 1692, 1693, 1695,1725, 1726)
where	 rc.itenant_id = #itenantid# 
order by rc.dtrowend desc
</cfquery>
<cfif qryoccupancy.iOccupancyPosition is 2><cfset occupancy = 1></cfif>

<cfset amountLOC = 0>
<cfif qryispoints.iSPoints gt 0>
	<cfquery name="qryLOC" DATASOURCE = "#APPLICATION.datasource#">
		select top 1 chg9.mamount as amountLOC , chg9.dtrowend
		from  house h9   
		join  ChargeSet chgset9 on  chgset9.iChargeSet_ID =h9.iChargeSet_ID
		join   p_charges chg9 on h9.ihouse_id =  chg9.ihouse_id 
		join  p_SLevelType slt9 on slt9.iSLevelType_ID = chg9.iSLevelType_ID
		and slt9.cSLevelTypeSet = h9.cSLevelTypeSet
		and chg9.ichargetype_id = 91 
		and chg9.dtrowdeleted is null
		and chg9.cchargeset  = chgset9.cname
		and  #qryispoints.iSPoints# between slt9.iSPointsMin and slt9.iSPointsMax
		where   h9.ihouse_id = #qryispoints.ihouse_id# 
		union
		select top 1 chg9.mamount as amountLOC , chg9.dtrowend
		from  house h9   
		join  ChargeSet chgset9 on  chgset9.iChargeSet_ID =h9.iChargeSet_ID
		join   charges chg9 on h9.ihouse_id =  chg9.ihouse_id 
		join  SLevelType slt9 on slt9.iSLevelType_ID = chg9.iSLevelType_ID
		and slt9.cSLevelTypeSet = h9.cSLevelTypeSet
		and chg9.ichargetype_id = 91 
		and chg9.dtrowdeleted is null
		and chg9.cchargeset  = chgset9.cname
		and  #qryispoints.iSPoints# between slt9.iSPointsMin and slt9.iSPointsMax
		where   h9.ihouse_id = #qryispoints.ihouse_id# 		
		order by chg9.dtrowend desc
	</cfquery>
	<cfset amountLOC = qryLOC.amountLOC>
</cfif>

	<cfquery name="qryRoomType" DATASOURCE = "#APPLICATION.datasource#">
		select   top 1 apttyp.cDescription
		from  AptAddress aptadr  
		join  AptType apttyp on aptadr.iAptType_ID = apttyp.iAptType_ID
		where aptadr.iAptAddress_ID  = #qryispoints.iAptAddress_ID#
	</cfquery>
	
	<cfif cResidencyType is "Private">	
		<cfquery name="qryAdjRate" DATASOURCE = "#APPLICATION.datasource#">
			select  top 1  rc. mamount ,  rc.dtrowend  
			from  p_RecurringCharge rc
			join  p_charges  chg on rc.icharge_id = chg.icharge_id
			and rc.dtrowdeleted is null 
			and chg.dtrowdeleted is null
			and chg.ichargetype_id  in  (8,89,1642, 1689, 1690, 1691, 1692, 1693, 1695,1725, 1726)
			where	 rc.itenant_id = #itenantid#  
			and rc.dtrowend < '2013-04-01'

			union
			select  top 1  rc. mamount  , rc.dtrowend 
			from  RecurringCharge rc
			join  charges  chg on rc.icharge_id = chg.icharge_id
			and rc.dtrowdeleted is null 
			and chg.dtrowdeleted is null
			and chg.ichargetype_id  in  (8,89,1642, 1689, 1690, 1691, 1692, 1693, 1695,1725, 1726)
			where	 rc.itenant_id =  #itenantID#  
			order by rc.dtrowend desc
		</cfquery>
	<cfelse>
		<cfquery name="qryAdjRate" DATASOURCE = "#APPLICATION.datasource#">
			select   top 1 chg.mamount 
			from  tenant t
			join tenantstate ts on t.itenant_id = ts.itenant_id 
			join  house h on t.ihouse_id = h.ihouse_id
			join ChargeSet chgset on  chgset.iChargeSet_ID =h.iChargeSet_ID
			join  AptAddress aptadr  on aptadr.iAptAddress_ID  = ts.iAptAddress_ID 
			and t.ihouse_id = aptadr.iHouse_ID
			join p_charges chg on chg.ihouse_id = h.ihouse_id 
			and chg.cchargeset = chgset.cName
			and chg.iAptType_ID = aptadr.iAptType_ID
			where t.itenant_id		= #itenantID# 
			and chg.dtrowdeleted is null 
			and chg.cchargeset = chgset.cName   
			and chg.ichargetype_id = 7	
			and chg.dtrowend < '2013-04-01' 
		</cfquery>  
	</cfif>  
		<cfquery name="qryDiscount" DATASOURCE = "#APPLICATION.datasource#">
			select  top 1  rc. mamount AS DISCOUNTAMT ,  rc.dtrowend  
			from  p_RecurringCharge rc
			join  p_charges  chg on rc.icharge_id = chg.icharge_id
			and rc.dtrowdeleted is null 
			and chg.dtrowdeleted is null
			and chg.ichargetype_id  in  (28,96,1657,1658,1696,1698,1699,1700,1701,1703,1704,1705,1706,1707,1708,1709,1716,1722,1728)
			where	 rc.itenant_id = #itenantid#  
			and rc.dtrowend < '2013-04-01'

			union
			select  top 1  rc. mamount AS DISCOUNTAMT , rc.dtrowend 
			from  RecurringCharge rc
			join  charges  chg on rc.icharge_id = chg.icharge_id
			and rc.dtrowdeleted is null 
			and chg.dtrowdeleted is null
			and chg.ichargetype_id  in  (28,96,1657,1658,1696,1698,1699,1700,1701,1703,1704,1705,1706,1707,1708,1709,1716,1722,1728)
			where	 rc.itenant_id =  #itenantID#  
			order by rc.dtrowend desc
		</cfquery>
		<cfif qryDiscount.DISCOUNTAMT is ''>
			<cfset discamount = 0>
		<cfelse>
			<cfset discamount = #qryDiscount.DISCOUNTAMT#> 
		</cfif>

 <cfquery name="updLog" DATASOURCE = "#APPLICATION.datasource#">
	update maple.occupancy.dbo.log_OccupancySummaryDetailsHistory
	set iSPoints = #qryispoints.iSPoints#
	,mAmountBSF = #qryApt.amountBSF#
	,mAmountLOC = #amountLOC#
	,mAmountAdjRate = #qryAdjRate.mamount#
	,bSecondOccupant = #occupancy#
	,cRoomType = '#qryRoomType.cDescription#'
	,mAmountDiscount = #discamount#
	where iTenantId = #itenantID# and dtrundate = '2013-03-31 22:38:31.420'
	and iHouseId = #iHouseId#
	</cfquery>  

<tr>  <td> #countthis#  </td><td>  #itenantid#  </td><td>#iHouseId#</td><td>  #dateformat(dtrundate, 'MM/DD/YYYY')#  </td><td><cfif cResidencyType is "Respite"><b>#cResidencyType# </b><cfelse>#cResidencyType#</cfif></td><td>  #qryispoints.iSPoints#   </td><td> #amountLOC# </td><td> #qryApt.amountBSF#  </td><td> #occupancy#  </td><td>  #qryRoomType.cDescription# </td> <td>#qryAdjRate.mamount#</td><TD>#discamount#</TD></tr> 
<cfset countthis = countthis + 1>
 
</cfloop>
</cfoutput>
</table>
</body>
</html>
