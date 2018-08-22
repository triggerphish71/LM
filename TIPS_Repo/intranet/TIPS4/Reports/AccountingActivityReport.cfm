<!----------------------------------------------------------------------------------------------
| DESCRIPTION - AccountingActivityReport.cfm                                                               |
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
| Sathya     |05/12/2010  | Project 20933 Modified the paramater prompt list                   |
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
----------------------------------------------------------------------------------------------->
<!--- <SCRIPT> report = window.open("","AccountingActivityReport","toolbar=no,resizable=yes"); report.moveTo(0,0); </SCRIPT>
 ---><CFOUTPUT>
<!--- 	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
	 <CFSET user="ro">
	 <CFSET password="read"> 

	<FORM NAME="AcctActivityRpt" ACTION="http://#crserver#/reports/tips/tips4/CustomerAccountingActivity.rpt" METHOD="Post" TARGET="AccountingActivityReport" onLoad="runhid();">
		<INPUT TYPE="Hidden" NAME="user0" VALUE="#user#">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="#Password#">
		<!--- 05/12/2010 Project 20933 Late Fee Sathya added this for the userid and password for the subreports--->
		<INPUT TYPE="Hidden" NAME="user0@TenantLateFee" VALUE="rw">
		<INPUT TYPE="Hidden" NAME="password0@TenantLateFee" VALUE="4rwriter">
		<INPUT TYPE="Hidden" NAME="user0@TenantHistoricalPaidLateFee" VALUE="rw">
		<INPUT TYPE="Hidden" NAME="password0@TenantHistoricalPaidLateFee" VALUE="4rwriter">
		<!--- project 20933 project code end here --->
		
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#form.prompt0#">
		<!--- 05/10/2010 Project 20933 Late Fee Sathya Added this another parameter for the two sub report --->
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#form.prompt0#">
		<INPUT TYPE="Hidden" NAME="prompt2" VALUE="#form.prompt0#">
		<!--- End of code project 20933 --->
		<SCRIPT>location.href='#HTTP_REFERER#'; document.AcctActivityRpt.submit(); 	</SCRIPT>
	</FORM> --->
	<cflocation url="CustomerAccountingActivityReport.cfm?prompt0=#prompt0#">
</CFOUTPUT>