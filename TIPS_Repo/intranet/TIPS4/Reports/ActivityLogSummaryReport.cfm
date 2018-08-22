<SCRIPT>
	window.open("","TenantActivitySummaryReport","toolbar=no,resizable=yes");
</SCRIPT>

<CFOUTPUT>		

	<CENTER>
		<B STYLE="font-size: 30;">
			Please, wait while the report is loading....
		</B>
	</CENTER>

	<CFSET user="rw">
	<CFSET password="4rwriter">

	<FORM NAME="TenantActivitySummary" ACTION="http://#crserver#/reports/tips/TIPS4/TenantActivitySummary.rpt" METHOD="Post" TARGET="TenantActivitySummaryReport" onLoad="runhid();">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<input type=hidden name="promptOnRefresh" value=0>
		<INPUT TYPE="Hidden" NAME="user0" VALUE="#user#">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="#Password#">
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#url.ID#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="">

		<SCRIPT>
			location.href='#HTTP_REFERER#'
			document.TenantActivitySummary.submit();  
		</SCRIPT>

	</FORM>
	
</CFOUTPUT>