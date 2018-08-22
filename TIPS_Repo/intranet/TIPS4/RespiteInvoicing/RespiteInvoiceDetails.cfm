<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInvoiceDetails.cfm                                     |
|----------------------------------------------------------------------------------------------|
| Display Invoice Details of an Invoice for a Respite Resident                                 |
| Called by: 		RespiteInvoice.cfm						                                   |
| Calls/Submits:	                                             							   |
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
|R Schuette  | 05/18/2010 | Prj 25575 - Original Authorship              					   |
----------------------------------------------------------------------------------------------->

<!--- Get Detail info --->
<cfquery name="getINVDTLs" datasource="#application.datasource#">
	Select iInvoiceDetail_ID, id.cAppliesToAcctPeriod, cDescription, iQuantity, mAmount, cSolomonKey, im.bFinalized
	from InvoiceDetail id 
	join InvoiceMaster im on (im.iInvoiceMaster_ID = id.iInvoiceMaster_ID  )
	where im.iInvoiceNumber = '#URL.INVNID#'
	and id.dtRowDeleted is null
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
	<a href="RespiteInvoice.cfm?SolID=#SolID#">Back to Invoice Listings</a>
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
				<cfif ListContains(SESSION.groupid, '240')>
				<td>
					<cfif getINVDTLs.bFinalized neq 1>
					<form name="DeleteINVDetail" action="RespiteInvoiceDeleteDTL.cfm?INVDTLID=#getINVDTLs.iInvoiceDetail_ID#&INVNID=#URL.INVNID#" method="post">
						<input type="submit" name="Submit" value="Delete" onMouseOver="" onClick="">
					</form>
					</cfif>
				</td>
				<cfelse>
				<td>
				</td>
				</cfif>
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
			</tr>

