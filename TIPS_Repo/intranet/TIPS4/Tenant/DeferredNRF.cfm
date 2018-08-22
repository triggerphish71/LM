<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!----------------------------------------------------------------------------------------------
| DESCRIPTION: Listing of residents with deferred NRF                                          |
|----------------------------------------------------------------------------------------------|
| DeferredNRF.cfm                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by:                                                                                   |
| Calls/Submits:                                                                               |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
----------------------------------------------------------------------------------------------->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Move-In NRF Discounts Awaiting Approval</title>
	</head>
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Deferred NRF</h1>
	
 
	<cfquery name="qryDefNRF"  datasource="#application.datasource#">
		select
		t.itenant_id 
		,t.csolomonkey 
		,t.cfirstname
		, t.clastname
		, h.cname as housename
 		,HL.dtCurrentTipsMonth		
		,ts.mBaseNRF as 'BaseNRF'
		,ts.mAdjNRF as 'AdjNRF'
		,rc.mAmount as 'DeferredNRF'
		,rc.cdescription
		,ts.cNRFAdjApprovedBy
		,rc.dtRowStart
		,rc.dtEffectiveStart
		,rc.dtEffectiveEnd
		,rc.dtRowDeleted
		,datediff(m,HL.dtCurrentTipsMonth ,rc.dtEffectiveEnd  ) as 'paymentrem'
 		,datediff(m,rc.dtEffectiveStart,rc.dtEffectiveEnd) + 1 as 'nbrpaymnt'  
		from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join house h on t.ihouse_id = h.ihouse_id
		join dbo.RecurringCharge RC on RC.iTenant_ID = t.iTenant_ID 
		JOIN HouseLog HL ON h.iHouse_ID = HL.iHouse_Id
		join charges chg on chg.iCharge_ID = RC.iCharge_ID and chg.ichargetype_id = 1740
 
		where ts.bIsNRFDeferred = 1
		  and   rc.dtEffectiveEnd >= #now()# 
		  AND rc.mAmount  <> 0
		order by h.cname, t.clastname,t.cfirstname
	</cfquery>
 
	<body>
		<table>
			<h2>Tenant With NRF Deferrals</h2>
			<cfoutput query="qryDefNRF" group="housename">
				<tr style="background-color:##99FFCC">
					<td colspan="3">#housename#</td>
				</tr>
				<tr style="background:##FFFF99">
					<td style="text-align:center">Tenant</td>
					<td style="text-align:center">House NRF</td>
					<td style="text-align:center">Adjusted NRF</td>
					<td style="text-align:center">Deferred NRF</td>
					<!--- <td style="text-align:center">Charge Type</td> --->
					<td style="text-align:center">Approved By</td>	
					<td style="text-align:center">Approved Date</td>											
					<td style="text-align:center">Deferral<br /> Start Date</td>
					<td style="text-align:center">Deferral<br />End Date</td>
					<td style="text-align:center">Payment<br />Months</td>
					<td style="text-align:center">Monthly Payment</td>
					<td style="text-align:center">Remaining<br />Balance</td>
					<td style="text-align:center">TIPS Month</td>	
					<td style="text-align:center">Payments Remaining</td>					
				</td>
				<cfoutput group="csolomonkey">
					<cfset paymentmonths = datediff('m',dtEffectiveStart,dtEffectiveEnd) + 1>
					<cfset monthlypayment = abs(DeferredNRF)/ paymentmonths>
					<cfset paymentsmade = datediff('m',dtEffectiveStart, dtCurrentTipsMonth)>
					<cfset remainingbal = abs(DeferredNRF) - (monthlypayment * paymentsmade)> 
					<cfif remainingbal   lte 0>
						<cfset Remainingbal = 0>
					</cfif>
					<tr>
						<td nowrap="nowrap">#cfirstname# #clastname# #itenant_id# #csolomonkey#</td>
						<td style="text-align:right">#numberformat(BaseNRF, '999,999.00')#</td>
						<td style="text-align:right">#numberformat(AdjNRF, '999,999.00')#</td>
						<td style="text-align:right">#numberformat(abs(DeferredNRF), '9,999.00')#</td>
						<td>#cNRFAdjApprovedBy#</td>
						<td style="text-align:center">#dateformat(dtRowStart, 'mm/dd/yyyy')#</td>
						<td style="text-align:center">#dateformat(dtEffectiveStart, 'mm/dd/yyyy')#</td>
						<td style="text-align:center">#dateformat(dtEffectiveEnd, 'mm/dd/yyyy')#</td>
						<td style="text-align:center">#paymentmonths#</td>
						<td>#numberformat(monthlypayment, '999,999.00')#</td>
						<td>#numberformat(remainingbal, '999,999.00')#</td>
						<td>#dateformat(dtCurrentTipsMonth, 'yyyymm')#</td>
						<td>#paymentrem#</td>
						<!---  <td>#nbrpaymnt#</td>  --->
					</tr>
				</cfoutput>
			</cfoutput>
		</table>
	</body>
</html>
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">	