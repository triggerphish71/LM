

<CFINCLUDE TEMPLATE="../../header.cfm">

<A HREF="CashReceipts.cfm" STYLE="font-size: 18;"> Click Here to Continue.</A>
<BR>

<CFOUTPUT>
<CFIF IsDefined("url.ReceiptID")>
	<CF_CashReceiptsCSV iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# iCashReceipt_ID=#url.ReceiptID# DEBUG=1>
<CFELSEIF IsDefined("form.Slip")>
	<CF_CashReceiptsCSV iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# iCashReceipt_ID=#form.Slip# DEBUG=1>
</CFIF>
</CFOUTPUT>	
	
<BR>
<A HREF="CashReceipts.cfm" STYLE="font-size: 18;"> Click Here to Continue.</A>

<CFINCLUDE TEMPLATE="../../Footer.cfm">