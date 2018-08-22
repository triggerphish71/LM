<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--- ------------------------------------------------------------------------------------------
 sfarmer     | 08/08/2013 |project 106456 EFT Updates                                          |
-----------------------------------------------------------------------------------------------> 
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>


<cfquery name="qrytenantswitheft"  datasource="#application.datasource#">
	SELECT  h.iHouse_ID, t.cSolomonKey, ten.bUsesEFT, ten.itenant_id
	FROM	dbo.P_Tenant t
	JOIN 	tenantState ten 
	ON	t.iTenant_ID = ten.iTenant_ID
	and	ten.iTenantStateCode_ID = 2
	and	ten.bUsesEFT = 1
	JOIN	 dbo.House h
	ON	t.iHouse_ID = h.iHouse_ID
	WHERE	ten.bUsesEFT = 1
	GROUP BY h.iHouse_ID, t.cSolomonKey, ten.bUsesEFT, ten.itenant_id
</cfquery>
<cfset thiscount = 0>
<cfoutput>
	<cfloop query="qrytenantswitheft">
		 <cfquery name="upeft"  datasource="#application.datasource#">
		Update eftaccount 
		
		Set iDayofFirstPull = 5,
		iOrderofPull = 1,
		cEnteredBy = '#session.username#',
		dtBeginEFTDate = #CreateODBCDateTime(now())#,
		dtEnteredDate = #CreateODBCDateTime(now())#,
		dPctFirstPull = 100.00,
		bApproved = 1,
		cApprovedBy = '#session.username#',
		dApprovedDate = #CreateODBCDateTime(now())# 

		Where cSolomonKey = '#qrytenantswitheft.cSolomonKey#'
		 </cfquery> 
		<cfset thiscount = thiscount + 1>
		<br />#iHouse_ID#,  #cSolomonKey#,   #thiscount#<br />
	</cfloop>  
	


</cfoutput>
<body>
</body>
</html>
