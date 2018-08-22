

<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3025><CFIF IsDefined("form.fieldnames")>#form.fieldnames#<BR></CFIF></CFIF>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>

<SCRIPT>report=window.open("loading.htm","MailingLabels","toolbar=no,resizable=yes");report.moveTo(0,0);</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>
<CFSET User="rw">
<CFSET Password="4rwriter">
<FORM NAME="MailingLabels" action="//#crserver#/reports/tips/tips4/MailingLabels.rpt" method="POST" TARGET="MailingLabels">
	<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
	<input type=hidden name="promptOnRefresh" value=1>
	<input type=hidden name="user0" value="#User#">
	<input type=hidden name="password0" value="#Password#">
	<INPUT TYPE="Hidden" name="prompt0" value="#HouseData.iHouse_ID#">
	<SCRIPT> location.href='#HTTP_REFERER#'; document.MailingLabels.submit(); </SCRIPT>
</FORM>
</CFOUTPUT>

	

