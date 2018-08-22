<SCRIPT>
	window.open("","CashReceiptReport","toolbar=no,resizable=yes");
</SCRIPT>

<CFOUTPUT>		

	<CENTER>
		<B STYLE="font-size: 30;">
			Please, wait while the report is loading....
		</B>
	</CENTER>

	<CFSET user="rw">
	<CFSET password="4rwriter">

	<FORM NAME="CashReceipts" ACTION="http://#crserver#/reports/tips/TIPS4/depositslip.rpt" METHOD="Post" TARGET="CashReceiptReport" onLoad="runhid();">
		<INPUT TYPE="Hidden" NAME="user0" VALUE="#user#">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="#Password#">
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#SESSION.nHouse#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#url.id#">

		<SCRIPT>
			location.href='CashReceipts.cfm'
			document.forms[0].submit();  
		</SCRIPT>

	</FORM>
	
</CFOUTPUT>