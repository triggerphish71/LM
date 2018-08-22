

<!--- *********************************************************************************************************************
<CFPARAM NAME = "ATTRIBUTES.iHouse_ID" 		default = "200">

<!--- ==============================================================================
The file location on ASPEN was E:\mssql7\imports\
This will be different as we move to new Applictions Server gum
=============================================================================== --->
<!--- ----------------------------------------------------------------------------------------------
<CFPARAM NAME = "ATTRIBUTES.Destination" 	DEFAULT = "c:\Program Files\Microsoft SQL Server\MSSQL\Imports\">
----------------------------------------------------------------------------------------------- --->
<CFPARAM NAME = "ATTRIBUTES.Destination" 	DEFAULT = "C:\Program Files\Microsoft SQL Server\MSSQL\Imports\">
<CFPARAM NAME = "ATTRIBUTES.TipsMonth" 		DEFAULT = "2001-06-01">
<CFPARAM NAME = "ATTRIBUTES.DEBUG" 			DEFAULT = "no">
<CFPARAM NAME = "ATTRIBUTES.iTenant_ID"		DEFAULT = "3995">
********************************************************************************************************************* --->

<CFIF IsDefined("url.ID")>
	<CFSET form.iTenant_ID = #Url.ID#>
</CFIF>

<!--- ==============================================================================
Retrieve this tenant movein invoice information
=============================================================================== --->
<CFQUERY NAME="qMOInvoice" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Distinct IM.*
	FROM	InvoiceMaster IM
	JOIN	InvoiceDetail INV	ON	IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID
	WHERE	INV.dtRowDeleted IS NULL
	AND	IM.dtRowDeleted IS NULL
	AND	IM.bMoveOutInvoice IS NOT NULL
	AND	INV.iTenant_ID = #form.iTenant_ID#
</CFQUERY>


<CFINCLUDE TEMPLATE="../../header.cfm">
<BR>
<BR>
<CFIF qMOInvoice.RecordCount EQ 0>
	<CFOUTPUT>
			<B STYLE="Font-size: 12; color: red;"> Move Out Invoice Not Found. <BR> The SysAdmin has been Notified.</B>
	</CFOUTPUT>
	
	<CFMAIL TYPE="HTML" TO="PBuendia@alcco.com" FROM="TIPS4_MICSV" SUBJECT="Move In Invoice was NOT found">
		The MoveOut Invoice for TID #form.ID# was not found.
	</CFMAIL>	
<CFELSE>
	<CFSET tmpMOPeriod = #LEFT(qMOInvoice.cAppliesToAcctPeriod,4)# & '-' & #RIGHT(qMOInvoice.cAppliesToAcctPeriod,2)# & '-01'>
	<CFSET MOPeriod = #CreateODBCDateTime(tmpMOPeriod)#>
	<CF_MoveOut iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# TipsMonth=#DateFormat(MOPeriod,"yyyy-mm-dd")# iTenant_ID=#form.iTenant_ID# DEBUG=1>	
</CFIF>	
<BR>
<BR>



<CFOUTPUT>
	<A HREF="#HTTP.Referer#" STYLE="font-size: 18;">Click Here to continue.</A>
</CFOUTPUT>

<CFINCLUDE TEMPLATE="../../footer.cfm">

