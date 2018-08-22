<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/HistRespiteInvoice.cfm                                        |
|----------------------------------------------------------------------------------------------|
| Display Invoices for a Respite Resident that is MOVED OUT (state 4)                          |
| Called by: 		Reports/Menu.cfm						  	                               |
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
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|R Schuette  | 07/30/2010 | Prj 25575 - Original Authorship                                    |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                |
----------------------------------------------------------------------------------------------->

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- HTML head --->
<TITLE> Tips 4  - Respite Resident Invoicing Page </TITLE>
<BODY>

<cfif URL.SolID eq ''>
	<cfset URL.SolID = 'X'>
</cfif>
<cfset variables.MovetoProd = '08/31/2011'>

<!--- Display the page header --->
<H1 CLASS="PageTitle"> Tips 4 - Respite Resident Invoicing Page </H1>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">

<cfquery name="RRInfo" datasource="#application.datasource#">
	select 
	(t.cFirstName+' '+t.cLastName) as TenantName,t.cSolomonKey,t.cChargeset,t.iHouse_ID
	,aa.cAptNumber,aa.iAptType_ID
	,atm.iSPoints as 'iAAPoints'
	,rs.cDescription as 'Residency'
	,att.cDescription as 'AptType'
	,convert(varchar(10),ts.dtMoveIn,101) as 'dtMoveIn'
	,convert(varchar(10),ts.dtMoveOutProjectedDate,101) as 'dtMoveOutProjectedDate'
	,convert(varchar(10),ts.dtMoveOut,101) as 'dtMoveOut'
	from tenant t
	left join TenantState ts on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null)
	left join AptAddress aa on (aa.iAptAddress_ID = ts.iAptAddress_ID and aa.dtRowDeleted is null)
	left join ResidencyType rs on (rs.iResidencyType_ID = ts.iResidencyType_ID and rs.dtRowDeleted is null)
	left join AssessmentToolMaster atm on (atm.iTenant_id = t.iTenant_ID 
		and atm.dtRowDeleted is null
		and atm.bBillingActive = 1
		)
	join AptType att on (att.iAptType_ID = aa.iAptType_ID)
	where t.dtRowDeleted is null
	and t.cSolomonKey = '#URL.SolID#'
</cfquery>

<cfquery name="RRInvoice" datasource="#application.datasource#">
	Select count(IM.iInvoiceMaster_ID) as 'IMCount', sum(IM.mInvoiceTotal) as 'IMSum'
	From InvoiceMaster IM 
	where IM.dtrowdeleted is null
	and IM.bFinalized = 1
	and IM.cSolomonKey = '#URL.SolID#'
</cfquery>

 <cfquery name="GetInvoices" datasource="#application.datasource#">
	select distinct rim.iinvoiceMaster_id, t.itenant_id, iInvoiceNumber, cAppliesToAcctPeriod, mInvoiceTotal, rim.cSolomonKey, 
	isnull(bMoveInInvoice,0) as bMoveInInvoice, isnull(bMoveOutInvoice, 0) as bMoveOutInvoice
	,convert(varchar(10),rim.dtInvoiceStart,101) as StartDate
	,isnull(convert(varchar(10),rim.dtInvoiceEnd,101),convert(varchar(10),getdate(),101)) as EndDate 
	from InvoiceMaster rim
	join tenant t on t.csolomonkey = rim.csolomonkey
	where rim.cSolomonKey = '#URL.SolID#'
	and rim.bFinalized = 1
	and rim.dtrowdeleted is null
</cfquery>

<cfoutput>
<table border="1" cellspacing="0" cellpadding="0" style='border-collapse: collapse;border: none;'>
        <tr>
            <td nowrap valign="top" style="border: solid windowtext .5pt;background: D9D9D9; padding: ''0in 5.4pt 0in 5.4pt;text-align:center">
                <p>
                   <span style="font-weight:bold">Respite Resident Summary</span> 
				</p>
            </td>
        </tr>
        <tr><td>
	<table >
		<tr>
            <td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt">
                <p>
                    <span>Solomon Number:</span><br />
					<span>Resident Name:</span><br />
					<span>Residency Type:</span><br />
				</p>
            </td>
			 <td nowrap valign="top" style="width: 35px;border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>  
                    <span>#RRInfo.cSolomonkey#</span><br />
					<span style="white-space:NOWRAP">#RRInfo.TenantName#</span><br />
					<span>#RRInfo.Residency#</span><br />
			    </p>  
            </td>
            <td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt">
                <p>
                    <span>MO Apartment Number:</span><br />
					<span>MO Apartment Type:</span><br />
					<span>MO Assessment Points:</span><br />
					
				</p>
            </td>
			 <td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>  
                    <span>#RRInfo.cAptNumber#</span><br />
					<span style="white-space:NOWRAP">#RRInfo.AptType#</span><br />
					<span>#RRInfo.iAAPoints#</span><br />
			    </p>  
            </td>
        </tr>
		<tr>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
                    <span NOWRAP>Move In Date:</span><br />
					<span NOWRAP>Physical Move Out Date:</span><br />
				</p>
			</td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
                    <span>#RRInfo.dtMoveIn#</span><br />
					<span>#RRInfo.dtMoveOut#</span><br />
				</p>
			</td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
					<span NOWRAP>Number of Invoices:</span><br />
					<span NOWRAP>Total of Invoices:</span><br />
					<span NOWRAP>Account:</span><br />
				</p>
			</td>
			<td nowrap valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>
					<span NOWRAP>#RRInvoice.IMCount#</span><br />
					<span NOWRAP>#dollarFormat(RRInvoice.IMSum)#</span><br />
					<span NOWRAP>Closed</span><br />
				</p>
			</td>
		</tr>
	</table>
	</td></tr>
</table>
</cfoutput>

</br>
<TABLE>
	<TR>
		<TD COLSPAN="2" STYLE="background: white;">
			<B STYLE="font-size: 20;">Respite Resident Invoicing</B>
		</TD>
	</TR>
</TABLE>
<TABLE>
			<TR>
				<th NOWRAP>Invoice Number</th>
				<th NOWRAP>Period</th>
				<th NOWRAP>Start Date</th>
				<th NOWRAP>End Date</th>
				<th NOWRAP>Number of Days</th>
				<th NOWRAP>Amount</th>
				<th NOWRAP>Finalized</th>
				<th NOWRAP>View</th>
			</TR>

<cfif GetInvoices.RecordCount gt 0>		
			<CFoutput QUERY = "GetInvoices"> 
				<TR>	
					<td style="text-align:center"  NOWRAP>
						<a href="HistRespiteInvoiceDetails.cfm?INVNID=#GetInvoices.iInvoiceNumber#">#GetInvoices.iInvoiceNumber#</a>
					</td>
					<td style="text-align:center"  NOWRAP>
						#GetInvoices.cAppliesToAcctPeriod#
					</td>
					<td style="text-align:center"  NOWRAP>
						#GetInvoices.StartDate#
					</td>
					<td style="text-align:center"  NOWRAP>
						#GetInvoices.EndDate#
					</td>
					<cfquery name="getDays" datasource="#application.datasource#">
						select datediff(dd, cast('#GetInvoices.StartDate#' AS datetime),cast('#GetInvoices.EndDate#' AS datetime))+ 1 as Days
					</cfquery>
					<td style="text-align:center"  NOWRAP>
						#getDays.Days#
					</td>
					<cfset InvoiceAmount = GetInvoices.mInvoiceTotal>
					<td style="text-align:center"  NOWRAP>
						#dollarFormat(InvoiceAmount)#
					</td>
					<cfset bFinal = 'Finalized'>
					<td style="text-align:center"  NOWRAP>
						#bFinal#
					</td> 
					<td>
						<cfif GetInvoices.bMoveInInvoice eq 1> <!--- IS a Move in Invoice, so use Move in Summary --->
							<form name="MoveInSummary" action="../Reports/MoveInReportA.cfm" method="post">
								<input type="hidden" name="prompt0" value="#GetInvoices.itenant_id#">
								<span style="cursor:pointer">
									<a style="text-decoration:underline" onClick="MoveInSummary.submit();">Invoice</a>
								</span>
							</form>
						</cfif>
						
						<cfif GetInvoices.bMoveOutInvoice eq 1> <!--- IS a Move Out Invoice, so use Move Out Summary --->
<!--- 							<a href="../MoveOut/MoveOutReport.cfm?ID=#GetInvoices.itenant_id#&MID=#GetInvoices.iinvoiceMaster_id#">
								Invoice
							</a> --->
							<a href="../Reports/RespiteMoveOutSummary.cfm?prompt0=#RRInfo.cSolomonkey#">Invoice</a>
						</cfif>
						
						<cfset variables.file = "../Reports/RespiteInvoiceReport.cfm">
						<cfif GetInvoices.bMoveInInvoice eq 0 and GetInvoices.bMoveOutInvoice eq 0>
							<cfif GetInvoices.StartDate lt variables.MovetoProd>
								<cfset variables.file = '../Reports/LegacyRespiteInvoiceReport.cfm'>
							</cfif>

							<a href="#variables.file#?SolID=#trim(GetInvoices.cSolomonKey)#&INVNBR=#GetInvoices.iInvoiceNumber#">
								Invoice
							</a>
						</cfif>
						
					</td>
				</TR>
			</CFoutput>
	</TABLE>
<cfelse>
			<TR>
				<TD align="center" colspan="7">No Invoices Found</TD>
			</TR>
</cfif>
