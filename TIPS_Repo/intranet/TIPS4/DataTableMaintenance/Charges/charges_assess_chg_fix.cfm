<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head><!---  41,156,139,137,133,245,118,103,78,59,238,240,239,241,243,242,244 --->
<cfset thishouse = 212>
<cfquery name="extrMamount" DATASOURCE='#APPLICATION.datasource#'>
 
select     ochg.iChargeType_ID as oldiChargeType_ID
           ,ochg.iHouse_ID as oldiHouse_ID
           ,ochg.cChargeSet as oldcChargeSet
           ,ochg.cDescription as oldcDescription
           ,ochg.mAmount as oldmAmount
           ,ochg.iQuantity as oldiQuantity
           ,ochg.bIsRentUNUSED as oldbIsRentUNUSED
           ,ochg.bIsMedicaidUNUSED as oldbIsMedicaidUNUSED
           ,ochg.iResidencyType_ID as oldiResidencyType_ID
           ,ochg.iAptType_ID as oldiAptType_ID
           ,ochg.cSLevelDescription as oldcSLevelDescription
           ,ochg.iSLevelType_ID as oldiSLevelType_ID
           ,ochg.iOccupancyPosition as oldiOccupancyPosition
           ,ochg.dtAcctStamp as olddtAcctStamp
           ,ochg.dtEffectiveStart as olddtEffectiveStart
           ,ochg.dtEffectiveEnd as olddtEffectiveEnd
           ,ochg.iRowStartUser_ID as oldiRowStartUser_ID
           ,ochg.dtRowStart as olddtRowStart
           ,ochg.iRowEndUser_ID as oldiRowEndUser_ID
           ,ochg.dtRowEnd as olddtRowEnd
           ,ochg.iRowDeletedUser_ID as oldiRowDeletedUser_ID
           ,ochg.dtRowDeleted as olddtRowDeleted
           ,ochg.cRowStartUser_ID as oldcRowStartUser_ID
           ,ochg.cRowEndUser_ID as oldcRowEndUser_ID
           ,ochg.cRowDeletedUser_ID as oldcRowDeletedUser_ID
           ,ochg.iProductLine_ID as oldiProductLine_ID
           ,ochg.bIsMoveInCharge  as oldbIsMoveInCharge
		  ,nchg.iChargeType_ID as newiChargeType_ID
           ,nchg.iHouse_ID as newiHouse_ID
           ,nchg.cChargeSet as newcChargeSet
           ,nchg.cDescription as newcDescription
           ,nchg.mAmount as newmAmount
           ,nchg.iQuantity as newiQuantity
           ,nchg.bIsRentUNUSED as newbIsRentUNUSED
           ,nchg.bIsMedicaidUNUSED as newbIsMedicaidUNUSED
           ,nchg.iResidencyType_ID as newiResidencyType_ID
           ,nchg.iAptType_ID as newiAptType_ID
           ,nchg.cSLevelDescription as newcSLevelDescription
           ,nchg.iSLevelType_ID as newiSLevelType_ID
           ,nchg.iOccupancyPosition as newiOccupancyPosition
           ,nchg.dtAcctStamp as newdtAcctStamp
           ,nchg.dtEffectiveStart as newdtEffectiveStart
           ,nchg.dtEffectiveEnd as newdtEffectiveEnd
           ,nchg.iRowStartUser_ID as newiRowStartUser_ID
           ,nchg.dtRowStart as newdtRowStart
           ,nchg.iRowEndUser_ID as newiRowEndUser_ID
           ,nchg.dtRowEnd as newdtRowEnd
           ,nchg.iRowDeletedUser_ID as newiRowDeletedUser_ID
           ,nchg.dtRowDeleted as newdtRowDeleted
           ,nchg.cRowStartUser_ID as newcRowStartUser_ID
           ,nchg.cRowEndUser_ID as newcRowEndUser_ID
           ,nchg.cRowDeletedUser_ID as newcRowDeletedUser_ID
           ,nchg.iProductLine_ID as newiProductLine_ID
           ,nchg.bIsMoveInCharge  as newbIsMoveInCharge
from  charges Ochg
join charges Nchg on ochg.cdescription = nchg.cdescription
where
Ochg.ihouse_id = #thishouse# and Ochg.ichargetype_id=91  and Ochg.cchargeset='2012Jan'
and nchg.ihouse_id = #thishouse# and nchg.ichargetype_id=91  and nchg.cchargeset='2013Jan'
and ochg.cdescription = nchg.cdescription and nchg.dtrowdeleted is null   and ochg.dtrowdeleted is null 
 order by Ochg.mamount 
 

</cfquery>
<body>
<cfset reccount = 0>
<cftransaction>
<cfoutput>
<cfloop query="extrMamount">
<!---       <cfquery name="addrec" DATASOURCE='#APPLICATION.datasource#'>
 INSERT INTO [TIPS4].[dbo].[Charges]
           ([iChargeType_ID]
           ,[iHouse_ID]
           ,[cChargeSet]
           ,[cDescription]
           ,[mAmount]
           ,[iQuantity]
           ,[bIsRentUNUSED]
           ,[bIsMedicaidUNUSED]
           ,[iResidencyType_ID]
           ,[iAptType_ID]
           ,[cSLevelDescription]
           ,[iSLevelType_ID]
           ,[iOccupancyPosition]
           ,[dtAcctStamp]
           ,[dtEffectiveStart]
           ,[dtEffectiveEnd]
           ,[iRowStartUser_ID]
           ,[dtRowStart]
           ,[iRowEndUser_ID]
           ,[dtRowEnd]
           ,[iRowDeletedUser_ID]
           ,[dtRowDeleted]
           ,[cRowStartUser_ID]
           ,[cRowEndUser_ID]
           ,[cRowDeletedUser_ID]
           ,[iProductLine_ID]
           ,[bIsMoveInCharge])
     VALUES (     --->  
	  #oldiChargeType_ID#
           ,#oldiHouse_ID#
           ,'#oldcChargeSet#'
           ,'#oldcDescription#'
           ,#oldmAmount#
           ,#oldiQuantity#
           ,Null
           ,Null
           ,#oldiResidencyType_ID#
           ,Null
           ,'#oldcSLevelDescription#'
           ,#newiSLevelType_ID#
           ,Null
           ,'#olddtAcctStamp#'
           ,'#olddtEffectiveStart#'
           ,'#olddtEffectiveEnd#'
           ,3863
           ,'#olddtRowStart#'
           ,Null
           ,Null
           ,Null
           ,Null
           ,'sfarmer-assessmentfix'
           ,Null
           ,Null
            ,<cfif #oldiProductLine_ID# is ''>1 <cfelse>#oldiProductLine_ID#</cfif> 
           ,Null
	 ) 
  
<!---    </cfquery>   ---><br />
<cfset reccount = reccount + 1>
</cfloop>
done: #reccount# - #extrMamount.oldiHouse_ID# 
</cfoutput>
</cftransaction>
</body>
</html>
