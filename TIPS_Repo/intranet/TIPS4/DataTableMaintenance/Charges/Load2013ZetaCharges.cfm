<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfset thisenddate = CreateODBCDateTime('2020-12-31')> 
<cfset thisstartdate = CreateODBCDateTime('2012-12-01')>
<cfset thisAcctdate = CreateODBCDateTime('2012-12-01')>
<cfset datenow = CreateODBCDateTime(now())>
<cfquery name="qryMiscCharges" datasource="#APPLICATION.datasource#">
select * 
 
from dbo.Charges chgs
where  chgs.icharge_id in ( 
  536754,
536755,
536756,
536757,
536758,
536759,
536760,
536761,
536762,
536763,
536764,
536765,
536766,
536767,
536768,
536769,
536770,
536771,
536772,
536773,
536774,
536775,
536776,
536777,
536778,
536779,
536780,
536781,
536782,
536783,
536784,
536785,
536786,
536787,
536788,
536789,
536790,
536791,
536792,
536793,
536794,
536795,
536796,
536797,
536798,
536799,
536800,
536801,
536802,
536803,
536804,
536805,
536806,
536807,
536808,
536809,
536810,
536811,
536812,
536813,
536814,
536815,
536816,
536817,
536818,
536819,
536820,
536821,
536822,
536823,
536824,
536825,
536826,
536827,
536828,
536829,
536830,
536831,
536832,
536833,
536834,
536835,
536836,
536837,
536838,
536839,
536840,
536841,
536842,
536843,
536844,
536845,
536846,
536847,
536848,
536849,
536850,
536851,
536852,
536853,
536854,
536855,
536856,
536857,
536858,
536859,
536860,
536861,
536862,
536863,
536864,
536865,
536866,
536867,
536868,
536869,
536870,
536871,
536872,
536873,
536874,
536875,
536876,
536877,
536878,
536879,
536880,
536881,
536882,
536883,
536884,
536885,
536886,
536887,
536888,
536889,
536890,
536891,
536892,
536893,
536894,
536895,
536896,
536897,
536898,
536899,
536900,
536901,
536902,
536903,
536904,
536905,
536906,
536907,
536908,
536909,
536910,
536911,
536912,
536913,
536914,
536915,
536916,
536917,
536918,
536919,
536920,
536921,
536922,
536923,
536924,
536925,
536926,
536927,
536928,
536929,
536930,
536931,
536932,
536933,
536934,
536935,
536936,
536937,
536938,
536939,
536940,
536941,
536942,
536943,
536944,
536945,
536946,
536947,
536948,
536949,
536950,
536951,
536952,
536953,
536954,
536955,
536956,
536957,
536958,
536959,
536960,
536961,
536962,
536963,
536964,
536965,
536966,
536967,
536968,
536969,
536970,
536971,
536972,
536973,
536974,
536975,
536976,
536977,
536978,
536979,
536980,
536981,
536982,
536983,
536984,
536985,
536986,
536987,
536988,
536989,
536990,
536991,
536992,
536993,
536994,
536995,
536996,
536997,
536998,
536999,
537000,
537001,
537002,
537003,
537004,
537005,
537006,
537007,
537008,
537009,
537010,
537011,
537012,
537013,
540971,
540972,
542130,
542131,
542132,
542133,
542134,
542135,
542136,
542137,
542138,
542139,
542140,
542141,
542142,
542143,
542144,
542145,
542146,
542147,
542148,
542149,
542150,
542151,
542152,
542153,
542154
 )
  and chgs.cchargeset = '2013Jan'
  and chgs.dtrowdeleted is null
  and ihouse_id = 50
  order by chgs.ihouse_id, chgs.ichargetype_id 
</cfquery>
<body>
<cfset reccount = 0>
<cftransaction>
	<cfoutput >
		<cfloop query="qryMiscCharges">		
 
<!---     <cfquery name="updatechg"  datasource="#APPLICATION.datasource#" >
					INSERT INTO [TIPS4].[dbo].[Charges]
								([iChargeType_ID] 
								,[iHouse_ID]
								,[cChargeSet]
								,[cDescription]
								,[mAmount]
								,[iQuantity]
							<cfif iResidencyType_ID is not ''>	,[iResidencyType_ID]  </cfif>
							<cfif iAptType_ID is not ''>	,[iAptType_ID]  </cfif>
							<cfif cSLevelDescription is not ''>	,[cSLevelDescription] </cfif>
								<cfif iSLevelType_ID is not ''>, [iSLevelType_ID] </cfif>
							<cfif iOccupancyPosition is not ''>	,[iOccupancyPosition] </cfif>
								,[dtAcctStamp]
								,[dtEffectiveStart]
								,[dtEffectiveEnd]
								,[iRowStartUser_ID]
								,[dtRowStart]
								,[cRowStartUser_ID]
							<cfif iProductLine_ID is not ''>	, [iProductLine_ID] </cfif>
							<cfif bIsMoveInCharge is not ''>	,[bIsMoveInCharge] </cfif>
							 )    
						 VALUES --->                        
							(	#iChargeType_ID# <!--- iChargeType_ID --->
							   ,200  	 <!--- iHouse_ID ---> 
							   ,'2013Jan'   	 <!--- cChargeSet --->
							   ,'#cDescription#' <!--- cDescription --->
							   ,#mAmount#  		 <!--- mAmount --->
							   ,#iQuantity#		 <!--- iQuantity --->
								<cfif iResidencyType_ID is not ''>  ,#iResidencyType_ID#</cfif>  <!--- 	 iResidencyType_ID --->
								<cfif iAptType_ID is not ''>	    ,#iAptType_ID# </cfif>	     <!---  iAptType_ID --->
							 	<cfif cSLevelDescription is not ''>	,'#trim(cSLevelDescription)#' </cfif>
								<cfif iSLevelType_ID is not ''>, #trim(iSLevelType_ID)# </cfif>
								<cfif iOccupancyPosition is not ''> ,#iOccupancyPosition#</cfif> <!--- iOccupancyPosition --->				
							   ,#thisAcctdate#			<!--- dtAcctStamp --->		
							   ,#thisstartdate# 		<!--- dtEffectiveStart --->
							   ,#thisenddate#			<!--- dtEffectiveEnd --->	
							   ,#session.userid#		<!--- iRowStartUser_ID --->
							   ,#datenow#				<!--- dtRowStart --->
							   ,'2013Jan  SFarmer ZetaHouse 2013-03-05' <!---cRowStartUser_ID  --->
							 	<cfif iProductLine_ID is not ''>    ,#iProductLine_ID#</cfif> <!--- iProductLine_ID --->
							    <cfif bIsMoveInCharge is not ''>    ,#bIsMoveInCharge#</cfif> <!--- IsMoveInCharge --->
								 )
				          <!--- </cfquery>  ---> <br />
				   <cfset reccount = reccount + 1>  
			</cfloop>
		</cfoutput>
	</cftransaction>
done  <cfoutput>Count: #reccount#</cfoutput>
</body>
</html>
