<!--- 
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
 --->

<!--- <SCRIPT>report=window.open("","CustTrialBalReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT> --->

<cfif isDefined("form.prompt0")><cfset url.prompt0 = #form.prompt0#></cfif>
<CFOUTPUT>		
<!--- 	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
	<CFSET user="ro">
	<CFSET password="read">
	<FORM NAME="CustTrialBal" ACTION="http://#crserver#/reports/tips/TIPS4/customertrialbalance.rpt" METHOD="Post" TARGET="CustTrialBalReport" onLoad="runhid();">
		<INPUT TYPE="Hidden" NAME="user0" VALUE="#user#">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="#Password#">
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#url.prompt0#">
		<SCRIPT> location.href='#HTTP_REFERER#'; document.CustTrialBal.submit(); </SCRIPT>
	</FORM> --->	
	<cflocation url="CustomerTrialBalanceReport.cfm?prompt0=#prompt0#">
</CFOUTPUT>