<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/HistRespiteInvoiceDetails.cfm                                |
|----------------------------------------------------------------------------------------------|
| Display Invoice Details for a Respite Resident that is MOVED OUT (state 4)                               |
| Called by: 		HistRespiteInvoiceDetails.cfm 						  	                                   |
| Calls/Submits:	                                              |
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
|R Schuette  | 07/30/2010 | Prj 25575 - Original Authorship              								   |
----------------------------------------------------------------------------------------------->

<cfquery name="getINVDTLs" datasource="#application.datasource#">
	Select id.iInvoiceDetail_ID, id.cAppliesToAcctPeriod, id.cDescription, id.mAmount, id.iQuantity, 
	im.iInvoiceMaster_ID, im.bFinalized, im.cSolomonKey
	from InvoiceDetail id 
	join InvoiceMaster im on (im.iInvoiceMaster_ID = id.iInvoiceMaster_ID)
	where id.dtRowDeleted is null
	and im.iInvoiceNumber = '#URL.INVNID#'
</cfquery>

<cfset SolID = getINVDTLs.cSolomonKey>

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- HTML head --->
<TITLE> Tips 4  - Respite Resident Invoicing Page </TITLE>
<BODY>

<!--- Display the page header --->
<H1 CLASS="PageTitle"> Tips 4 - Respite Resident Invoice Details Page </H1>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
</br>
<cfoutput>
<a href="HistRespiteInvoices.cfm?SolID=#SolID#">Back to Invoice Listings</a>
</cfoutput>
</br></br>
<TABLE>
	<TR>
		<TD COLSPAN="2" STYLE="background: white;">
			<B STYLE="font-size: 20;">Respite Resident Invoicing - Invoice Details</B>
		</TD>
	</TR>
</TABLE>
<TABLE>
	<TR>
		<th NOWRAP>ID Number</th>
		<th NOWRAP>Applies To Period</th>
		<th NOWRAP>Description</th>
		<th NOWRAP>Quantity</th>
		<th NOWRAP>Amount</th>
		<th NOWRAP>Total</th>
		<th NOWRAP></th>
		<th NOWRAP></th>
	</TR>
		<cfset total = 0>
		<cfoutput query="getINVDTLs">
		<tr>
				<td style="text-align:center"  NOWRAP>
					#getINVDTLs.iInvoiceDetail_ID#
				</td>
				<td style="text-align:center"  NOWRAP>
					#getINVDTLs.cAppliesToAcctPeriod#
				</td>
				<td style="text-align:center"  NOWRAP>
					#getINVDTLs.cDescription#
				</td>
				<td style="text-align:center"  NOWRAP>
					#getINVDTLs.iQuantity#
				</td>
				<td style="text-align:center"  NOWRAP>
					#dollarFormat(getINVDTLs.mAmount)#
				</td>
				<cfset subLineTotal = getINVDTLs.iQuantity * getINVDTLs.mAmount>
				<cfset total = total + subLineTotal>
				<td style="text-align:center"  NOWRAP>
					#dollarFormat(subLineTotal)#
				</td>
				<td>
				</td>
				<td>
				</td>
			</tr>
		</cfoutput>
			<tr>
				<td></td>
				<td></td>
				<td></td>
				<td></td>
				<td>Invoice Total:</td>
				<cfoutput><td style="text-align:center"  NOWRAP>#dollarFormat(total)#</td></cfoutput>
