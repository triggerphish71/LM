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
<cfquery name="qryRespiteRooms" datasource="#APPLICATION.datasource#">
select * ,
Round(cast((mamount + (mamount * .20)) as money), 0) as 'NewRespiteRate'
,cast((mamount + (mamount * .20)) as money) as 'RespiteRate'
from dbo.Charges chgs
where  chgs.iAptType_ID in (SELECT  [iAptType_ID]
 
  FROM [TIPS4].[dbo].[AptType]
  where  bIsCompanionSuite <> 1
  and (cdescription like '%Studio%'
  or cdescription like '%One%')
 )
  and chgs.cchargeset = '2013Jan'
--  and chgs.[iChargeType_ID] = 7
  and chgs.dtrowdeleted is null
  order by chgs.ihouse_id, chgs.iAptType_ID
</cfquery>
<body>
<cftransaction>
	<cfoutput >
		<cfloop query="qryRespiteRooms">
<!---   	<cfquery name="updatechg"  datasource="#APPLICATION.datasource#">
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
							   , [iProductLine_ID]
							 )    
						 VALUES  --->               
							(	7 
							   ,#HouseID#  
							   ,'2013Jan'  
							   ,'#ThisRatetype#'  
							   ,#NewRespiteRate#  
							   ,1
							   ,1
  
							   ,#qryAptID.iAptType_ID#
							   ,3
						 
							   ,#thisAcctdate#
							   ,#thisstartdate# 
							   ,#thisenddate#
							   ,#session.userid#
							   ,#datenow#
							   ,'Jan2013 SFarmer Respite 2012-12-03'
							   ,1 
						 ) 
				<!--- </cfquery> ---> <br />
			</cfloop>
		</cfoutput>
	</cftransaction>

</body>
</html>
