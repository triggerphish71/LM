<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Reeports/LegacyRespiteInvoiceReport.cfm                                        |
|----------------------------------------------------------------------------------------------|
| get crystalreport for invoice                                                                |
| Called by: 		HistRespiteInvoice / reports                                               |
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
|R Schuette  | 08/09/2010 | Prj 25575 - Original Authorship                                    |
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
----------------------------------------------------------------------------------------------->
<!---<cfset form.cComments = ''>
<cfset form.bUsesEFT = ''>
<cfset SolID = URL.SolID>
<cfset INVNBR = URL.INVNBR>

<cfquery name="getInvoiceMSTRInfo" datasource="#application.datasource#">
	Select distinct im.iInvoiceMaster_ID, im.cAppliesToAcctPeriod, h.cNumber
	from InvoiceMaster im
	join tenant t on t.csolomonkey = im.csolomonkey
	join house h on h.ihouse_id = t.ihouse_id
	where im.cSolomonKey = '#SolID#'
	and im.iInvoiceNumber = '#INVNBR#'
</cfquery>
 
<SCRIPT> window.open("loading.htm","InvoiceReport","toolbar=no,resizable=yes"); </SCRIPT>--->
 
<cfparam name="form.prompt0" default="">
<cfset INVNBR = URL.INVNBR>

<CFOUTPUT>
   	<!--- <FORM NAME="Invoice" ACTION = "/Reports/RespiteInvoiceReport.cfm" METHOD="POST" TARGET="InvoiceReport"> 
		 <input type=hidden name="init" value="actx">   <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
 			<input type=hidden name="promptOnRefresh" value=0>
			<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="user0@InvoiceContactSubRpt.rpt" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@InvoiceContactSubRpt.rpt" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="user0@Prev_Trx2.rpt" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@Prev_Trx2.rpt" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="user0@ChargesSubRpt.rpt" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@ChargesSubRpt.rpt" VALUE="4rwriter">				
			<INPUT TYPE = "Hidden" NAME="user0@TenantNames" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@TenantNames" VALUE="4rwriter">				
			<INPUT TYPE = "Hidden" NAME="user0@HeartLetter" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0@HeartLetter" VALUE="4rwriter"> 
			
			<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#form.cComments#">
 			<INPUT TYPE = "Hidden" NAME="prompt1" VALUE="#form.bUsesEFT#">
	               
			<INPUT TYPE = "Hidden" NAME="prompt2" VALUE="#getInvoiceMSTRInfo.cNumber#">
			<INPUT TYPE = "Hidden" NAME="prompt3" VALUE="#getInvoiceMSTRInfo.cAppliesToAcctPeriod#">
			<INPUT TYPE = "Hidden" NAME="prompt4" VALUE="#URL.SolID#">
			
 	<SCRIPT>location.href='#HTTP_REFERER#'; document.Invoice.submit(); </SCRIPT> 
	</FORM>--->	
	<cflocation url="InvoiceReportRespite.cfm?prompt0=#SolID#&INVNBR=#INVNBR#">
</CFOUTPUT>