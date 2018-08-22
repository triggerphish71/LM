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

FROM  dbo.StreetRate2013WestA$ SR2013 
 join house h on  SR2013.HouseID = h.ihouse_id 
 where SR2013.HouseID = 49
 	 
order by SR2013.Division, SR2013.Region, SR2013.House, SR2013.Ratelevel
  
</cfquery>

	<body>
	<cfset count = 0>
	<cftransaction>
		<cfoutput>
			<cfloop query="qryChargeUpdateList">
				<cfif RateLevel is ''>  <!--- type 89 --->
					<CFIF Find('Basic Service Fee -' ,RateType ) ge 1> 
						<cfset ratetypelen = len(#RateType#)>
						<cfset thisroomtype = #right(RateType,(ratetypelen-20))#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 
					<CFelseIF Find('Basic Service Fee-' ,RateType ) ge 1> 
						<cfset ratetypelen = len(#RateType#)>
						<cfset thisroomtype = #right(RateType,(ratetypelen-19))#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#thisroomtype#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 
					<cfelse><cfset thisroomtype = #RateType#>
						 <cfquery name="qryAptID"  datasource="#APPLICATION.datasource#">
						select iAptType_ID, cDescription from dbo.AptType APT where '#RateType#' =  APT.cDescription and dtrowdeleted is null
						</cfquery> 				
					</CFIF>	 
 
		 		<cfquery name="updatechg"  datasource="#APPLICATION.datasource#">
					INSERT INTO [TIPS4].[dbo].[Charges]
							   ([iChargeType_ID]
							   ,[iHouse_ID]
							   ,[cChargeSet]
							   ,[cDescription]
							   ,[mAmount]
							   ,[iQuantity]
						 
							   ,[iResidencyType_ID]
							   ,[iAptType_ID]
						 
							   ,[iOccupancyPosition]
							   ,[dtAcctStamp]
							   ,[dtEffectiveStart]
							   ,[dtEffectiveEnd]
							   ,[iRowStartUser_ID]
							   ,[dtRowStart]
						 
							   ,[cRowStartUser_ID]
							 )
						 VALUES  
							(	89 
							   ,#HouseID#  
							   ,'2013Jan'  
							   ,'#RateType#'  
							   ,#Final_2013_rates#  
							   ,1
						 
							   ,1
							   <cfif Find( 'Second',RateType,1) gt 0>
							   ,''
							   , 2
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
						 ) 
					 		   </cfquery>
		  <cfelse><!--- type 91 --->
		
		<cfquery name="qrySLT"  datasource="#APPLICATION.datasource#">
			SELECT h.iHouse_ID, h.cName, h.cSLevelTypeSet,slt.*
			FROM house h
			join  [TIPS4].[dbo].[SLevelType] slt on h.cSLevelTypeSet = slt.cSLevelTypeSet  
			and h.ihouse_id = #houseID# and slt.cdescription = '#ratelevel#'
		</cfquery>
 		  <cfquery name="updatechg"  datasource="#APPLICATION.datasource#">
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
     )
     VALUES    
			(	91   
				,#HouseID#  
				,'2013Jan'  
				,'#RateType#'  
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
      
		   )	</cfquery> 
		  	  
				</cfif>
				<cfset count = count + 1>
			</cfloop>
			<br />#count# updated
		</cfoutput>
		 </cftransaction>
	</body>
</html>



