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
541228,
541229,
544719,
544720,
492679,
492680,
492681,
492682,
544721,
544722,
544723,
544724,
544725,
544726,
544727,
544728,
544729,
544730,
544731,
544732,
544733,
544734,
544735,
544736,
544737,
544738,
544739,
544740
 )
  and chgs.cchargeset = '2013Jan'
  and chgs.dtrowdeleted is null
  and ihouse_id = 174
  order by chgs.ihouse_id, chgs.ichargetype_id 
</cfquery>
<body>
<cfset reccount = 0>
<cftransaction>
	<cfoutput >
		<cfloop query="qryMiscCharges">		
 
<!---  	 <cfquery name="updatechg"  datasource="#APPLICATION.datasource#" >
					INSERT INTO [TIPS4].[dbo].[Charges]
								([iChargeType_ID] 
								,[iHouse_ID]
								,[cChargeSet]
								,[cDescription]
								,[mAmount]
								,[iQuantity]
							<cfif iResidencyType_ID is not ''>	,[iResidencyType_ID]  </cfif>
							<cfif iAptType_ID is not ''>	,[iAptType_ID]  </cfif>
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
						 VALUES   --->                   
							(	#iChargeType_ID# <!--- iChargeType_ID --->
							   ,#iHouse_ID#  	 <!--- iHouse_ID ---> 
							   ,'2013JanID'   	 <!--- cChargeSet --->
							   ,'#cDescription#' <!--- cDescription --->
							   ,#mAmount#  		 <!--- mAmount --->
							   ,#iQuantity#		 <!--- iQuantity --->
								<cfif iResidencyType_ID is not ''>  ,#iResidencyType_ID#</cfif>  <!--- 	 iResidencyType_ID --->
								<cfif iAptType_ID is not ''>	    ,#iAptType_ID# </cfif>	     <!---  iAptType_ID --->
							 	<cfif iOccupancyPosition is not ''> ,#iOccupancyPosition#</cfif> <!--- iOccupancyPosition --->				
							   ,#thisAcctdate#			<!--- dtAcctStamp --->		
							   ,#thisstartdate# 		<!--- dtEffectiveStart --->
							   ,#thisenddate#			<!--- dtEffectiveEnd --->	
							   ,#session.userid#		<!--- iRowStartUser_ID --->
							   ,#datenow#				<!--- dtRowStart --->
							   ,'2013JanID SFarmer Chaparelle 2013-03-01' <!---cRowStartUser_ID  --->
							 	<cfif iProductLine_ID is not ''>    ,#iProductLine_ID#</cfif> <!--- iProductLine_ID --->
							    <cfif bIsMoveInCharge is not ''>    ,#bIsMoveInCharge#</cfif> <!--- IsMoveInCharge --->
								 )
				          </cfquery>  
				   <cfset reccount = reccount + 1>  
			</cfloop>
		</cfoutput>
	</cftransaction>
done  <cfoutput>Count: #reccount#</cfoutput>
</body>
</html>
