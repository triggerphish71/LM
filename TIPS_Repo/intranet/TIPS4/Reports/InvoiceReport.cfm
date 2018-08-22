<!----------------------------------------------------------------------------------------------
| DESCRIPTION - InvoiceReport.cfm                                                               |
|----------------------------------------------------------------------------------------------|
|                                                           |
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
| Sathya     |06/10/2010  | Project 20933 Modified the paramater prompt list                   |
| Sathya     | 07/12/2010 | Project 20933 Modified again for late fee                          |
|Sathya      | 07/14/2010 | Reversed it back to the original file nothing needs to be changed  |
|sfarmer     | 2015-01-15 | allow use for deleted (closed) houses                              |
----------------------------------------------------------------------------------------------->
<!---
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFLOCATION URL="http://gum/alc">
</CFIF>
--->
<CFOUTPUT>
	<CFSCRIPT>
		if (IsDefined("url.prompt0")){ form.prompt0 = url.prompt0; form.prompt2 = url.prompt2; form.cComments = ''; }
		if (IsDefined("url.bUsesEFT") AND url.bUsesEFT EQ '1') { form.bUsesEFT = 1; } else { form.bUsesEFT = 0; }
		if (form.prompt0 EQ 'ALL') { form.prompt0 = ''; }
	
		if (SESSION.UserID IS 3146) {
			if (IsDefined("form.fieldnames")) { WriteOutPut(form.fieldnames &'<BR>'& form.prompt0 &'<BR>'& form.prompt2 &'<BR>'& form.bUsesEFT &'<BR>'); }
		}
	</CFSCRIPT>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>

<SCRIPT> window.open("loading.htm","InvoiceReport","toolbar=no,resizable=yes"); </SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
 	WHERE	
<!--- 	H.dtRowDeleted IS NULL 	AND	 --->	
	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>		
	<FORM NAME="Invoice" ACTION = "//#crserver#/reports/tips/tips4/invoice.rpt" METHOD="POST" TARGET="InvoiceReport" onSubmit="opennew();">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
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
 			<INPUT TYPE = "Hidden" NAME="prompt1" VALUE=#form.bUsesEFT#>
	               
			<INPUT TYPE = "Hidden" NAME="prompt2" VALUE="#HouseData.cNumber#">
			<INPUT TYPE = "Hidden" NAME="prompt3" VALUE="#form.prompt2#">
			<INPUT TYPE = "Hidden" NAME="prompt4" VALUE="#form.prompt0#">
			
		<SCRIPT>location.href='#HTTP_REFERER#'; document.Invoice.submit(); </SCRIPT>
	</FORM>
	<CENTER><B STYLE="font-size: 30;"> Please, wait while the report is loading.... </B></CENTER>
</CFOUTPUT>