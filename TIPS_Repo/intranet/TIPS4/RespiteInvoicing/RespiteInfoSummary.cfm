<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInfoSummary.cfm                                        |
| Display Resident Info Details of a Respite Resident in a Summary box at top                  |
|----------------------------------------------------------------------------------------------|
| Called by: 		RespiteInvoice.cfm					  	                                   |
| Calls/Submits:	                                                                           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|Developed for Project 25575 - Incremental Time Period Billing                                 |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|R Schuette  | 05/18/2010 | Prj 25575 - Original Authorship     							   |
----------------------------------------------------------------------------------------------->
<!--- #Application.AlcWebDBServer# --->

<cfquery name="RRInfo" datasource="#application.datasource#">
	select 
	(t.cFirstName+' '+t.cLastName) as TenantName,t.cSolomonKey,t.cChargeset,t.iHouse_ID
	,aa.cAptNumber,aa.iAptType_ID
	,atm.iSPoints as 'iAAPoints'
	,rs.cDescription as 'Residency'
	,att.cDescription as 'AptType'
	,convert(varchar(10),ts.dtMoveIn,101) as 'dtMoveIn'
	,convert(varchar(10),ts.dtMoveOutProjectedDate,101) as 'dtMoveOutProjectedDate',
	atm.dtbillingActive
	from tenant t
	join TenantState ts on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null)
	join AptAddress aa on (aa.iAptAddress_ID = ts.iAptAddress_ID and aa.dtRowDeleted is null)
	join ResidencyType rs on (rs.iResidencyType_ID = ts.iResidencyType_ID and rs.dtRowDeleted is null)
	join AssessmentToolMaster atm on (atm.iTenant_id = t.iTenant_ID and atm.dtRowDeleted is null and atm.bBillingActive = 1)
	join AptType att on (att.iAptType_ID = aa.iAptType_ID)
	where t.dtRowDeleted is null
	and t.cSolomonKey = '#URL.SolID#'
</cfquery>

 <cfquery name="GetAnswer" datasource="#application.datasource#">
	Select count(*) as count
	from InvoiceMaster im
	where im.cSolomonKey = '#URL.SolID#'
	and im.dtrowdeleted is null
	and im.bFinalized = 1
	and (getdate() between im.dtInvoiceStart and im.dtInvoiceEnd)
</cfquery>

<cfquery name="qCurrentBalance" datasource="SOLOMON-HOUSES">
	Select 	custid, currbal=currbal+futurebal
	from ar_balances
	where custid = '#URL.SolID#'
</cfquery>

<cfif qCurrentBalance.recordCount lt 1>
	<cfset TenBal = '0.00'>
<cfelse>
	<cfset TenBal = qCurrentBalance.currbal>
</cfif>

<table border="1" cellspacing="0" cellpadding="0" style='border-collapse: collapse;border: none;'>
		<tr>
			<td nowrap valign="top" style="border: solid windowtext .5pt;background: D9D9D9; padding: ''0in 5.4pt 0in 5.4pt;text-align:center">
				<p>
				   <span style="font-weight:bold">Respite Resident Summary</span> 
				</p>
			</td>
		</tr>
</table><br />

<cfoutput>	
	<table >
		<tr>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt">
				<p>
					Solomon Number:<br />
					Resident Name:<br />
					Residency Type:<br />
				</p>            </td>
			 <td nowrap valign="top" style="width: 35px;border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>  
					#RRInfo.cSolomonkey#</span><br />
					<span style="white-space:NOWRAP">#RRInfo.TenantName#</span><br />
					#RRInfo.Residency#<br />
				</p>            </td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt">
				<p>
					Apartment Number:<br />
					Apartment Type:<br />
					Current Assessment Points:<br />
					Assessment Activation date:<br />
				</p>            </td>
			 <td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>  
					#RRInfo.cAptNumber#<br />
					<span style="white-space:NOWRAP">#RRInfo.AptType#</span><br />
					#RRInfo.iAAPoints#<br />
					#dateformat(RRInfo.dtbillingActive,"MM/DD/YYYY")#
				</p>            </td>
		</tr>
		<tr>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
					<span NOWRAP>Move In Date:</span><br />
					<span NOWRAP>Current PMO Date:</span>
				</p>
			</td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
					#RRInfo.dtMoveIn#<br />
					#RRInfo.dtMoveOutProjectedDate#
				</p>
			</td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
					<span NOWRAP>Current Balance:</span><br />
					<span NOWRAP>Today Within Invoice:</span>
				</p>
			</td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
					<span NOWRAP>#dollarFormat(TenBal)#</span><br />
					<cfif GetAnswer.count gt 0> 
						<font color="green">Yes</font>
					<cfelse>
						<font color="red">No</font>
					</cfif>
				</p>
			</td>
		</tr>
	</table>
</cfoutput>