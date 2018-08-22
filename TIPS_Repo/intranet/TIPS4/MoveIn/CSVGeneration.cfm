

<!--- *********************************************************************************************************************
CALLED BY Reports Main Menu to RE-Generate Move In Invoices
********************************************************************************************************************* --->

<CFIF IsDefined("url.ID")>
	<CFSET form.iTenant_ID = #Url.ID#>
</CFIF>

<!--- ==============================================================================
Retrieve this tenant movein invoice information
=============================================================================== --->
<CFQUERY NAME="qMiInvoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Distinct IM.*
	FROM	InvoiceMaster IM
		JOIN	InvoiceDetail INV
		ON	IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
	WHERE	INV.dtRowDeleted IS NULL
	AND	IM.dtRowDeleted IS NULL
	AND	IM.bMoveInInvoice IS NOT NULL
	AND	INV.iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<CFINCLUDE TEMPLATE="../../header.cfm">
<BR>
<BR>
<CFIF qMiInvoice.RecordCount EQ 0>
	<CFOUTPUT>
			<B STYLE="Font-size: 12; color: red;"> Move In Invoice Not Found. <BR> The SysAdmin has been Notified.</B>
	</CFOUTPUT>
	
	<CFMAIL TYPE="HTML" TO="PBuendia@alcco.com" FROM="TIPS4_MICSV" SUBJECT="Move In Invoice was NOT found">
		The MoveIn Invoice for TID #form.ID# was not found.
	</CFMAIL>
<CFELSE>
	<CFSET tmpMIPeriod = #LEFT(qMiInvoice.cAppliesToAcctPeriod,4)# & '-' & #RIGHT(qMiInvoice.cAppliesToAcctPeriod,2)# & '-01'>
	<CFSET MiPeriod = #CreateODBCDateTime(tmpMIPeriod)#>
	<CF_MoveIn iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# TipsMonth=#DateFormat(MiPeriod,"yyyy-mm-dd")# iTenant_ID=#form.iTenant_ID# Debug=1>	
</CFIF>

<CFOUTPUT>
	<A HREF="#HTTP.Referer#" STYLE="font-size: 18;">Click Here to continue.</A>
</CFOUTPUT>

<CFINCLUDE TEMPLATE="../../Footer.cfm">

