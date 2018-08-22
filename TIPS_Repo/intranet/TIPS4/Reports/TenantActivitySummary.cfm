
<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3025>
		<CFIF IsDefined("form.fieldnames")>
			#form.fieldnames#<BR>
			#form.prompt0#<BR>
		</CFIF>
	</CFIF>
	
	<CFIF IsDefined("url.prompt0")>
		<CFSET form.prompt0 = #url.prompt0#>
	</CFIF>
	
	<CENTER>
		<B STYLE="font-size: 30;">
			Please, wait while the report is loading....
		</B>
	</CENTER>
	
</CFOUTPUT>


<SCRIPT>
		window.open("loading.htm","tenantactivitysummary","toolbar=no,resizable=yes");
</SCRIPT>

<CFOUTPUT>		
	<FORM NAME="tenantactivitysummary" ACTION = "http://#crserver#/reports/tips/tips4/tenantactivitysummary.rpt" METHOD="POST" TARGET="tenantactivitysummary">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=1>
			<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#form.prompt0#">
			<INPUT TYPE = "Hidden" NAME="prompt1" VALUE="">
		<SCRIPT>
			location.href='#HTTP_REFERER#'
			document.tenantactivitysummary.submit();
		</SCRIPT>
	</FORM>
	<BR>
</CFOUTPUT>