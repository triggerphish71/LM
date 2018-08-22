<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Reeports/RespiteInvoiceReport.cfm                                              |
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
<cfparam name="form.prompt0" default="">
<cfset INVNBR = URL.INVNBR>
<!---<cfset SolID = URL.SolID>--->

<!--- <SCRIPT> 
	window.open("loading.htm","RInvoiceReport","toolbar=no,resizable=yes");
</SCRIPT> --->
<CFOUTPUT>
<!--- 	
	
	<FORM NAME="RInvoice" ACTION = "//#crserver#/reports/tips/tips4/RespiteInvoice.rpt" METHOD="POST" TARGET="RInvoiceReport" >
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<input type=hidden name="promptOnRefresh" value=0>
		<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
		<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
		<INPUT TYPE = "Hidden" NAME="user0@InvoicecontactSubrpt.rpt" VALUE="rw">
		<INPUT TYPE = "Hidden" NAME="password0@InvoicecontactSubrpt.rpt" VALUE="4rwriter">
		<INPUT TYPE = "Hidden" NAME="user0@Transactions" VALUE="rw">
		<INPUT TYPE = "Hidden" NAME="password0@Transactions" VALUE="4rwriter">
		
		<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#INVNBR#">
	
		<SCRIPT>
			location.href='#HTTP_REFERER#'; 
			document.RInvoice.submit();
		</SCRIPT>

	</FORM> --->
	<cflocation url="InvoiceReportRespite.cfm?prompt0=#SolID#&INVNBR=#INVNBR#">
</CFOUTPUT>
