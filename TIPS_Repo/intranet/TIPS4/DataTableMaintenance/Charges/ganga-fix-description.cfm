<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfset enddate = CreateODBCDateTime('2020-12-31')>
<cfset thishouseID = 64>
   <cfquery name="ChargeO" datasource="#application.datasource#">
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
  and cchargeset = '2012Jan'
 and c.dtrowdeleted is null
and c.dteffectivestart = '2011-11-14'  	  
order by mamount 
</cfquery> 

    <cfquery name="ChargeN" datasource="#application.datasource#">
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
		and cchargeset = '2012Jan'
		and c.dtrowdeleted is null
		and     dtEffectiveStart > '2012-10-01'   
		order by mamount
 </cfquery> 
 <cfoutput query="cHARGEO">
  #iCharge_ID#
      ,#iChargeType_ID#
      ,#iHouse_ID#
      ,#cChargeSet#
      ,#cDescription#
      ,#mAmount#
      ,#iQuantity#<br />
 </cfoutput>
<br />done with O<br /> 
  <cfoutput query="cHARGEN">
   #iCharge_ID#
      ,#iChargeType_ID#
      ,#iHouse_ID#
      ,#cChargeSet#
      ,#cDescription#
      ,#mAmount#
      ,#iQuantity#<br /> 
 </cfoutput>
 <br />done with N<br /> 
<body>
</body>
</html>
