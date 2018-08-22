<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Recurring Charge Adjustments for 2013</title>
</head>
<cfset thisenddate = CreateODBCDateTime('2020-12-31')> 
<cfset thisstartdate = CreateODBCDateTime('2012-12-01')>
<cfset thisAcctdate = CreateODBCDateTime('2012-12-01')>
<cfset datenow = CreateODBCDateTime(now())>

<cfquery name="qryChargeUpdateList"  datasource="#APPLICATION.datasource#">
SELECT SR2013.HouseID, SR2013.Division, SR2013.Region, SR2013.House, SR2013.Ratetype,
   SR2013.mQuantity, SR2013.RateLevel,SR2013.dtStart, SR2013.dtEnd, SR2013.Final_2013_Rates ,
 h.cSLevelTypeSet
 ,	replace((case   when (len(RateType) = 23) then
				cast(substring(RateType, 23,5)  as  varchar(5))    
			when   (len(RateType) = 34)  then
			cast(substring(RateType, 23,6)  as  varchar(6))     
			when len(RateType) = 35  then
			cast(substring(RateType, 23,7)  as  varchar(7))  
			when len(RateType) = 36  then
			cast(substring(RateType, 23,8)  as  varchar(8))   
      end  ) ,' ','') as 'pointtype'
,      	replace((case   when (len(RateType) = 32) then
				cast(substring(RateType, 23,4)  as  varchar(5))    
			when   (len(RateType) = 33)  then
			cast(substring(RateType, 23,5)  as  varchar(6))     
			when len(RateType) = 34  then
			cast(substring(RateType, 23,6)  as  varchar(7))  
			when len(RateType) = 35  then
			cast(substring(RateType, 23,7)  as  varchar(8))   
      end  ) ,' ','') as 'pointtype2'

FROM  dbo.StreetRates2013Heartland$ SR2013 
 join house h on  SR2013.HouseID = h.ihouse_id 
 where Ratetype <> 'Basic Service Fee - Care Charges' and  Ratetype <>'Basic Service Fee - Room Rent'
 		and Ratetype <> 'Basic Service Fee - Companion'
		and Ratetype  <> 'Basic Service Fee - 2nd Resident'
<!---   where SR2013.HouseID = 48    not in (43,49,148)  ---> 
 	 
order by SR2013.Division, SR2013.Region, SR2013.House, SR2013.Ratetype  
  
</cfquery>
<!---   <cfoutput query="qryChargeUpdateList">
#HouseID#, #Division#, #Region#, #House#, #Ratetype#,
   #mQuantity#, #RateLevel#,#dtStart#, #dtEnd#, #Final_2013_Rates# ,
 #cSLevelTypeSet#, #pointtype#, #pointtype2#  #len(RateLevel)#<br />
</cfoutput>  ---> 
	<body>
	<cfset count = 0>
	 
 	<cftransaction>
		<cfoutput>
			<cfloop query="qryChargeUpdateList">
 
				<cfif  RateLevel is 'null' or  RateLevel is ''>  <!--- type 89 --->
					<CFIF Find('Basic Service Fee -' ,RateType ) ge 1> 
						1<cfset ratetypelen = len(#RateType#)>
						<cfset thisroomtype = #right(RateType,(ratetypelen-20))#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 
					<CFelseIF Find('Basic Service Fee- ' ,RateType ) ge 1> 
					2	<cfset ratetypelen = len(#RateType#)>
						<cfset thisroomtype = #right(RateType,(ratetypelen-19))#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 
					<CFelseIF Find('Private BSF - ' ,RateType ) ge 1> 
					2A	<cfset ratetypelen = len(#RateType#)>
						<cfset thisroomtype = #right(RateType,(ratetypelen-14))#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 
					<CFelseIF Find('Basic Service Fee-' ,RateType ) ge 1> 
					3	<cfset ratetypelen = len(#RateType#)>
						<cfset thisroomtype = #right(RateType,(ratetypelen-18))#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 
					<CFelseIF Find('IL' ,RateType ) ge 1> 
					4	<cfset ratetypelen = len(#RateType#)>
						 <cfset thisroomtype =  #RateType#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery>
					<cfelse><cfset thisroomtype = #RateType#>
						<cfset thisRateType = replace(RateType, '-','', 'All')>
						<br />#RateType#<br />
						5 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisRateType#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 				
					</CFIF>	 
					#thisroomtype# #ratetypelen# #qryAptID.iAptType_ID# #qryAptID.cDescription#<br />
 					<cfif len(RateType) gt 0>
						<cfset ThisRatetype = left(RateType,40)>
					<cfelse>
						<cfset ThisRatetype =  RateType >						
					</cfif>
<!---   	<cfquery name="updatechg"  datasource="#APPLICATION.datasource#">
					INSERT INTO [TIPS4].[dbo].[Charges]
							   ([iChargeType_ID]
							   ,[iHouse_ID]
							   ,[cChargeSet]
							   ,[cDescription]
							   ,[mAmount]
							   ,[iQuantity]
						 	 <cfif Find( 'Second',RateType,1) gt 0>
							   ,[iResidencyType_ID]
							   <cfelse>
							   ,[iResidencyType_ID]
							   ,[iAptType_ID]
							   </cfif>
							   ,[iOccupancyPosition]
							   ,[dtAcctStamp]
							   ,[dtEffectiveStart]
							   ,[dtEffectiveEnd]
							   ,[iRowStartUser_ID]
							   ,[dtRowStart]
							   ,[cRowStartUser_ID]
							   , [iProductLine_ID]
							 )    
						 VALUES  --->               
							(	89 
							   ,#HouseID#  
							   ,'2013Jan'  
							   ,'#ThisRatetype#'  
							   ,#Final_2013_rates#  
							   ,1
							   ,1
							   <cfif Find( 'Second',RateType,1) gt 0>
							   , 1
							   <cfelse> 
							   ,#qryAptID.iAptType_ID#
							   ,1
							   </cfif>
							   ,#thisAcctdate#
							   ,#thisstartdate# 
							   ,#thisenddate#
							   ,#session.userid#
							   ,#datenow#
							   ,'Jan2013 SFarmer  2012-11-30'
							   ,1 
						 ) 
					 		                 <!---   </cfquery>  --->  <br />
		  <cfelse><!--- type 91 --->
		<cfif qryChargeUpdateList.cSLevelTypeSet is 11 and len(Pointtype) is 1>#pointtype#<br />
	==>	1	<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
				SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
				FROM house h
				join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
				and h.ihouse_id = #houseID# and slt.cdescription = '#pointtype#'
			</cfquery>		
  		<cfelseif qryChargeUpdateList.cSLevelTypeSet is 11 and len(pointtype2) gt 0>#pointtype2#<br />
	==>	3	<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
				SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
				FROM house h
				join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
				and h.ihouse_id = #houseID# and slt.cdescription = '#pointtype2# pts'
			</cfquery> 
  		<cfelseif qryChargeUpdateList.cSLevelTypeSet is 14 and len(pointtype2) gt 0>#pointtype2#<br />
	==>	3A	<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
				SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
				FROM house h
				join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
				and h.ihouse_id = #houseID# and slt.cdescription = '#pointtype2# pts'
			</cfquery> 			
		<cfelseif qryChargeUpdateList.cSLevelTypeSet is 11 and len(pointtype) gt 1>#pointtype#<br />
	==>	2	<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
				SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
				FROM house h
				join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
				and h.ihouse_id = #houseID# and slt.cdescription = '#pointtype# pts'
			</cfquery>
 		<cfelseif qryChargeUpdateList.cSLevelTypeSet is 14 and len(pointtype) gt 1>#pointtype#<br />
	==>	2A	<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
				SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
				FROM house h
				join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
				and h.ihouse_id = #houseID# and slt.cdescription = '#pointtype# pts'
			</cfquery>
		<cfelse>
	==>	4	<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
				SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
				FROM house h
				join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
				and h.ihouse_id = #houseID# and slt.cdescription = '#ratelevel#'
			</cfquery>
		</cfif>
	<br />===>	#qrySLT.iHouse_ID#, house#qrySLT.cName#,csl #qrySLT.cSLevelTypeSet#,len#len(pointtype)#  ,PT:#pointtype# ,PT2:#pointtype2#, RL:#ratelevel#<br />

<!---         <cfquery name="updatechg"  datasource="#APPLICATION.datasource#">
 INSERT INTO [TIPS4].[dbo].[Charges]
           ([iChargeType_ID]
           ,[iHouse_ID]
           ,[cChargeSet]
           ,[cDescription]
           ,[mAmount]
           ,[iQuantity]
           ,[iResidencyType_ID]
           ,[cSLevelDescription]
           ,[iSLevelType_ID]
           ,[dtAcctStamp]
           ,[dtEffectiveStart]
           ,[dtEffectiveEnd]
           ,[iRowStartUser_ID]
           ,[dtRowStart]
           ,[cRowStartUser_ID]
		    , [iProductLine_ID]
     ) 
     VALUES  --->                     
 		(	91   
				,#HouseID#  
				,'2013Jan'  
				,'#Ratetype#'  
				,#Final_2013_rates#  
				,1
				,1
				,'#RateLEvel#' 
				,#qrySLT.islevelType_id#
				,#thisAcctdate#
				,#thisstartdate# 
				,#thisenddate#
				,#session.userid#
				,#datenow#
				, 'Jan2013 SFarmer 2012-11-30' 
      			,1 
		   )	               <!--- </cfquery>   ---> <br />
		  	  
				</cfif>
				<cfset count = count + 1>
			</cfloop>
			<br />#count# updated #qryChargeUpdateList.house#
		</cfoutput> 
		 </cftransaction>    
	</body>
</html>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
</body>
</html>
