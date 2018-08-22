<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<!----------------------------------------------------------------------------------------------
|sfarmer     | 2/22/2012  | Project 75019 - EFT Update/NRF Deferral. added changes for moveins |
|            |            | awaiting approval of NRF discount                                  |
----------------------------------------------------------------------------------------------->
<!---   ONLY RUN THIS PROGRAM ONCE FOR EACH CHARGE TYPE: 1739&  1740 & 1741 --->
<cfset dtEffectiveStart = CreateODBCDateTime('2012-01-01')>
<cfset dtEffectiveEnd = CreateODBCDateTime('2012-12-31')>
<cfquery name="qryhouse"  datasource="#application.datasource#">
select cname, ihouse_id from dbo.house where dtrowdeleted is null
</cfquery>
<cfoutput>
<cfloop query="qryhouse">
#cname# #ihouse_id#
 <cfquery name = "ChargeInsert" datasource = "#application.datasource#">
	insert into	Charges
	( iChargeType_ID ,iHouse_ID ,cDescription ,cChargeSet ,mAmount ,iQuantity
		,iResidencyType_ID  
		,dtEffectiveStart ,dtEffectiveEnd ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, iproductline_id ) 
	values
	( 1741
	, #trim(qryhouse.iHouse_ID)#
	,'Monthly Deferral Charge'
	,'2012Jan'
	,0.00
	,1
	,1
	,#variables.dtEffectiveStart#
	, #variables.dtEffectiveEnd#
	,#CreateODBCDateTime(session.AcctStamp)# 
	,#session.UserID#  
	,getDate()
	,1
	)
 </cfquery> 
<br />
</cfloop>
</cfoutput>

<body>
</body>
</html>
