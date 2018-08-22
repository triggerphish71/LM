<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Reports/RespiteInvoicesReport.cfm                                              |
|----------------------------------------------------------------------------------------------|
| get PDF for invoice                                                                          |
| Called by: HistRespiteInvoice / reports                                                      |
| Calls/Submits:                                                                               |
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
|S Farmer    | 01/27/2016 | Revisions for ColdFusion PDF form                                  |
|installed 02/16/2017                                                                          |
----------------------------------------------------------------------------------------------->
<cfset form.cComments = ''>
<cfset form.bUsesEFT = ''>
<cfset SolID = URL.SolID>
<cfset INVNBR = URL.INVNBR>

<cfquery name="getInvoiceMSTRInfo" datasource="#application.datasource#">
	Select distinct im.iInvoiceMaster_ID, im.cAppliesToAcctPeriod, h.cNumber,t.csolomonkey
	from InvoiceMaster im
	join tenant t on t.csolomonkey = im.csolomonkey
	join house h on h.ihouse_id = t.ihouse_id
	where im.cSolomonKey = '#SolID#'
	and im.iInvoiceNumber = '#INVNBR#'
</cfquery>
 
<CFOUTPUT>
 	<cfparam  NAME="prompt0" default="">
 	<cfparam  NAME="prompt1" default="">
	<cfparam  NAME="prompt2" default="">
	<cfparam  NAME="prompt3" default="">
	<cfparam  NAME="prompt4" default="">
	<cfparam name="bUsesEFT" default="">
 
			
			<cfset prompt0 = #getInvoiceMSTRInfo.csolomonkey#>
 	  
			<cfset prompt2 =#getInvoiceMSTRInfo.cAppliesToAcctPeriod#>
 
	<cflocation url="InvoiceReportB.cfm?prompt0=#prompt0#&prompt1=#prompt1#&prompt2=#prompt2#&prompt3=#prompt3#&prompt4=#prompt4#">
 
</CFOUTPUT>