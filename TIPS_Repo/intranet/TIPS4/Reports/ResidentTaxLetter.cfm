
<CFOUTPUT>
	<CENTER>
		<B STYLE="font-size: 30;">
			Please, wait while the report is loading....
		</B>
		http://#crserver#/reports/tips/tips4/HouseTaxLetter.rpt
		<br />
		prompt0 = #form.prompt0#; prompt1 = #form.prompt1#; prompt2 = #form.prompt2#
		<br />
	</CENTER>
	
</CFOUTPUT>


 <SCRIPT>
		window.open("loading.htm","residenttaxletter","toolbar=no,resizable=yes");
</SCRIPT>  

<CFOUTPUT>		
 <FORM NAME="residenttaxletter" ACTION = "http://#crserver#/Reports/Tips/Tips4/HouseTaxLetterNew.rpt" METHOD="POST" TARGET="residenttaxletter">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=1>
			<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#form.prompt0#">
			<INPUT TYPE = "Hidden" NAME="prompt1" VALUE="#form.prompt1#">
			<INPUT TYPE = "Hidden" NAME="prompt2" VALUE="#form.prompt2#">
		<SCRIPT>
			location.href='#HTTP_REFERER#'
			document.residenttaxletter.submit();
		</SCRIPT>
	</FORM>  
<!--- 	<cfreport report="http://#crserver#/Reports/Tips/Tips4/HouseTaxLetter.rpt"
		datasource="#APPLICATION.datasource#" 
		username="rw"
		password="4rwriter"  
		formula="prompt0 = #form.prompt0#; prompt1 = #form.prompt1#; prompt2 = #form.prompt2#;">
	</cfreport> --->
 
	<BR>
</CFOUTPUT>