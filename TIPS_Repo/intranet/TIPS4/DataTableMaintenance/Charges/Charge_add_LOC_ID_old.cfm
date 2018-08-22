<cfset enddate = CreateODBCDateTime('2020-12-31')>
<cfset startdate = CreateODBCDateTime('2012-12-10')>
<cfset thishouseID = 25>
<cfset count = 0>

<cfquery name="HouseName" datasource="#application.datasource#">
SELECT cname from house where ihouse_id = #thishouseID#
</cfquery> 

<cfquery name="ChargeCOunt" datasource="#application.datasource#">
SELECT count( iCharge_ID) as 'ChargeCnt'
  FROM TIPS4.dbo.Charges
  where ihouse_id = #thishouseID#
  and ichargetype_id = 91
  and cchargeset = '2013Jan'
    and  dtrowdeleted is null
</cfquery> 
	<cfquery name="SLevelType" datasource="#application.datasource#">
	select *, len(cdescription) 
	 ,case   when (len( cdescription) = 1) then
      cast(substring( cdescription, 1,1)  as  varchar(8))     
     when   (len( cdescription) = 7)  then
      cast(substring( cdescription, 1,3)  as  varchar(8))     
    when len( cdescription) = 8  then
      cast(substring( cdescription, 1,4)  as  varchar(8))  
    when len( cdescription) = 9  then
     cast(substring( cdescription, 1,5)  as  varchar(8))  	   
     end     
      as 'descrip' from SLevelType where csleveltypeset = 16 and dtRowDeleted is null 
	</cfquery>
<cfoutput>	   #ChargeCOunt.ChargeCnt#  <br></cfoutput>
<cftransaction>
<cfoutput query="SLevelType">

<cfquery name="Charge" datasource="#application.datasource#">
	SELECT  iCharge_ID
		  ,iChargeType_ID
		  ,iHouse_ID
		  ,cChargeSet
		  ,cDescription
		  ,mAmount
		  ,iQuantity
		  ,bIsRentUNUSED
		  ,bIsMedicaidUNUSED
		  ,iResidencyType_ID
		  ,iAptType_ID
		  ,cSLevelDescription
		  ,iSLevelType_ID
		  ,iOccupancyPosition
		  ,dtAcctStamp
		  ,dtEffectiveStart
		  ,dtEffectiveEnd
		  ,iRowStartUser_ID
		  ,dtRowStart
		  ,iRowEndUser_ID
		  ,dtRowEnd
		  ,iRowDeletedUser_ID
		  ,dtRowDeleted
		  ,cRowStartUser_ID
		  ,cRowEndUser_ID
		  ,cRowDeletedUser_ID
		  ,iProductLine_ID
		  ,bIsMoveInCharge
		FROM TIPS4.dbo.Charges c
		where ihouse_id = #thishouseID#
			and ichargetype_id = 91
			and cchargeset = '2013Jan'
			and cast('#SLevelType.descrip#' as varchar(5)) = 
		replace(( case   when (len(c.cdescription) = 23) then
			cast(substring(c.cdescription, 23,5)  as  varchar(5))    
			when   (len(c.cdescription) = 34)  then
			cast(substring(c.cdescription, 23,6)  as  varchar(6))     
			when len(c.cdescription) = 35  then
			cast(substring(c.cdescription, 23,7)  as  varchar(7))  
			when len(c.cdescription) = 36  then
			cast(substring(c.cdescription, 23,8)  as  varchar(8)) 	   
			end  ) ,' ','')
			and c.dtrowdeleted is null
  </cfquery>  
<!--- Resident Care - Level 6 + 1 points --->
<!--- Insert for entry of new charge --->
	<cfif Charge.iHouse_ID is not "">
<!---   	<cfquery name = "ChargeInsert" datasource = "#application.datasource#">  
			insert into	Charges
				( iChargeType_ID ,iHouse_ID ,cChargeSet
				,cDescription  ,mAmount ,iQuantity
				,iResidencyType_ID   ,cSLevelDescription ,iSLevelType_ID 
				,dtEffectiveStart ,dtEffectiveEnd ,dtAcctStamp 
				,iRowStartUser_ID ,cRowStartUser_ID,dtRowStart
				, iproductline_id ) 
			values  --->              
				(         
				#Charge.iChargeType_ID#  
				,#thishouseID#
				,'2013JanID'
				,'#trim(ChaRGE.cDescription)#' 
				,#trim(Charge.mAmount)# 
				, 1 
				,#trim(Charge.iResidencyType_ID)# 
				,'#trim(Charge.cSLevelDescription)#' 
				, #trim(SLevelType.iSLevelType_ID)# 
				,#startdate#
				,#enddate#
				,#CreateODBCDateTime(session.AcctStamp)#  
				,#session.UserID# 
				,'SFarmer 16 ManualInsert'
				,#CreateODBCDateTime(now())#
				,1 
				) 
		          <!---  </cfquery>   ---> <br />
	</cfif>
<cfset count = count + 1>
</cfoutput>
</cftransaction>
<cfoutput> done House: #thishouseID# :: #HouseName.cname# :: #count# :: Change 2</cfoutput>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Add LOC Charges</title>
</head>

<body>
</body>
</html>
