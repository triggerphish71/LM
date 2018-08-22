<SCRIPT> report=window.open("loading.htm","TipsAccountBalance","toolbar=no,resizable=yes"); report.moveTo(0,0); </SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region, H.cName
	FROM	House H
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>

<CFOUTPUT>
		<FORM NAME="TipsAccountBalance" ACTION="//#crserver#/reports/tips/tips4/TipsAccountBalanceSummary.rpt" METHOD="Post" TARGET="TipsAccountBalance" onSubmit="opennew();">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<input type=hidden name="promptOnRefresh" value=0>
		<INPUT TYPE="Hidden" NAME="user0" VALUE="rw">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="4rwriter">
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#HouseData.cName#">
		<SCRIPT> location.href='#HTTP_REFERER#'; document.TipsAccountBalance.submit(); </SCRIPT>
	</FORM>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>