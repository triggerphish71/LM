<title>Collection Letters</title>

<cfif not isDefined("form.cSolomonKeyList")>

	<form action="collectionletter.cfm" method="post">
	ENTER in the Account numbers you want to generate Collection Letters for seperated by commas:<p>
	<input type="text" name="cSolomonKeyList" size="80">
	<BR>
	Letter Type: 
	<INPUT TYPE="Radio" NAME="LetterType" Value="First" Checked>First
	<INPUT TYPE="Radio" NAME="LetterType" Value="Second">Second
	<BR>
	<input type="submit" value="Submit">
	</p>
	</form>

<cfelseif isDefined("Form.cSolomonKeyList")>
			
	<CFOUTPUT>
		<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
	</CFOUTPUT>
	
	<SCRIPT> window.open("loading.htm","CollectionLetterReport","toolbar=no,resizable=yes"); </SCRIPT>
	<CFIF Form.LetterType EQ "First">
		<CFSET cReport = "CollectionLetter.rpt">
	<CFELSE>
		<CFSET cReport = "CollectionSecondLetter.rpt">
	</CFIF>	
	<CFOUTPUT>		
		<FORM NAME="CollectionLetter" ACTION = "//#crserver#/reports/tips/tips4/#cReport#" METHOD="POST" TARGET="CollectionLetterReport" onSubmit="opennew();">
				<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
				<input type=hidden name="promptOnRefresh" value=0>
				<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
				<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
	
				<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#form.cSolomonKeyList#">
			<SCRIPT>location.href='#HTTP_REFERER#'; document.CollectionLetter.submit(); </SCRIPT>
		</FORM>
		<CENTER><B STYLE="font-size: 30;"> Please, wait while the report is loading.... </B></CENTER>
	</CFOUTPUT>
</cfif>