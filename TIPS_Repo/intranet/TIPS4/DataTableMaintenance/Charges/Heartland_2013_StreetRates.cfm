<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Recurring Charge Adjustments for 2013</title>
</head>
<cfset thisenddate = CreateODBCDateTime('2020-12-31')>
<cfquery name="qryChargeUpdateList"  datasource="#APPLICATION.datasource#">
SELECT SR2013.House_ID, chg.icharge_id, SR2013.RateType, SR2013.mamount as newamount, chg.mamount, chg.cdescription, chg.ihouse_id
FROM [TIPS4].[dbo].[Charges] chg
	join house h on chg.iHouse_ID = h.iHouse_ID
	join [TIPS4].[dbo].[Heartland_StreetRates_2013B$] SR2013 on chg.iHouse_ID = SR2013.House_ID
		and chg.cDescription = SR2013.RateType
	join dbo.SLevelType slt on chg.iSLevelType_ID = slt.iSLevelType_ID
		and slt.cSLevelTypeSet = h.cSLevelTypeSet
where  chg.cchargeset = '2012Jan'
	and chg.dtrowdeleted is null
order by chg.ihouse_id, chg.mamount
  
</cfquery>
	<body>
	<cfset count = 0>
		<cfoutput>
		
			<cfloop query="qryChargeUpdateList">
 				<!--- <cfquery name="updatechg"  datasource="#APPLICATION.datasource#">  ---> 
					<cfif ((newamount is not '') and (newamount is not ' ') and(newamount is not 0))>
				 		<!--- update Charge  --->
 #House_ID#,  #icharge_id#,  #RateType#,  #newamount#,  #mamount#,  #cdescription#,  #ihouse_id#
						set mamount = #newamount#
						,dtEffectiveEnd = #thisenddate#
						where ihouse_id = #ihouse_id# and iCharge_ID = #iCharge_ID#
					<cfelse>
						<!--- update RecurringCharge  ---> 
 #House_ID#,  #icharge_id#,  #RateType#,  #newamount#,  #mamount#,  #cdescription#,  #ihouse_id#
						OLDRATE= #mAmount#
						set dtEffectiveEnd = #thisenddate#
						where iTenant_ID = #iTenant_ID# and iCharge_ID = #iCharge_ID#
					</cfif>
				 <!--- </cfquery>   ---><br />
				<cfset count = count + 1>
			</cfloop>
			<br />#count# updated
		</cfoutput>
	</body>
</html>
