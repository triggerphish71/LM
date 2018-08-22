<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!----------------------------------------------------------------------------------------------
| DESCRIPTION: Listing of residents awaiting approval that have deferred NRF                   |
|----------------------------------------------------------------------------------------------|
| NRFAwaitingApproval.cfm                                                                      |
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
|            |            |                                                                    |
----------------------------------------------------------------------------------------------->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Move-In NRF Discounts Awaiting Approval</title>
	</head>
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Move-In NRF Discounts Awaiting Approval</h1>
	
	<!--- <cfinclude template="../Shared/HouseHeader.cfm"> --->
	<cfquery name="qryNRFNotAppvd"  datasource="#application.datasource#">
		select t.itenant_id
		,t.cfirstname
		,t.clastname
		,h.cname 'housename' 
		,ts.cNRFDiscAppUsername
		,ts.dtRowStart
		,h.ihouse_id
		from dbo.Tenant t
		 join dbo.TenantState ts on t.itenant_id = ts.itenant_id
		 join house h on t.ihouse_id = h.ihouse_id
		 where iTenantStateCode_ID = 2
		 and bNRFPend = 1
		 order by housename, clastname
	</cfquery>
 
	<body>
		<table>
			<h2>Move-Ins Awaiting NRF Discount Approval</h2>
			<cfoutput query="qryNRFNotAppvd" group="housename">
				<tr style="background-color:##99FFCC">
					<td colspan="3">#housename#</td>
				</tr>
				<cfoutput group="clastname">

					<tr style="background:##FFFF99">
						<td>Approver</td>
						<td>Tenant</td>
						<td>Date Entered</td>
					</td>
					<tr>
					<cfif cNRFDiscAppUsername is ""	>
						<cfquery name="apprver" datasource="FTA">
							Select top 1 UAD.cFullName 
							FROM FTA.dbo.vw_UserAccountDetails UAD
							where  
							((UAD.cROle like '%RDO%') or ( UAD.cROle in ('RDQCS', 'RDSM')))
							and UAD.ihouseid = #ihouse_id#
						</cfquery>
							<td>#apprver.cFullName#</td>
					<cfelse>
							<td>#cNRFDiscAppUsername#</td>
					</cfif>
						<td>#cfirstname# #clastname#</td>
						<td>#dateformat(dtRowStart, 'mm/dd/yyyy')#</td>
					</tr>
				</cfoutput>
			</cfoutput>
		</table>
	</body>
</html>
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">	