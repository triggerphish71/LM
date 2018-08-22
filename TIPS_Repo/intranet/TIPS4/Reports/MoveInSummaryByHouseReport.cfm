

<CFOUTPUT>
	<CFIF NOT IsDefined("SESSION.USERID")><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"></CFIF>
	<CENTER><B STYLE="font-size: 30;"> Please wait while the report is loading.... </B></CENTER>
</CFOUTPUT>

<!---<SCRIPT>report = window.open("loading.htm","MoveInSummaryByHouseReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>
--->
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>
	
<CFOUTPUT>
	<CFSCRIPT> User="rw"; Password="4rwriter"; </CFSCRIPT>
<script>
//window.open('http://krishna.alcco.com/ReportServer/Pages/ReportViewer.aspx?%2fTIPS4%2fMove-Ins+Summary+By+House&rc:Command=Render&rc:Parameters=false&Scope=House&Selection=#HouseData.cName#&Period=#form.prompt1#&ResidencyType=0','popwin','scrollbars=yes,resizable=yes');
window.open('http://#Application.HOUSES_APPDBServer#/ReportServer/Pages/ReportViewer.aspx?%2fTIPS4%2fMove-Ins+Summary+By+House&rc:Command=Render&rc:Parameters=false&Scope=House&Selection=#HouseData.cName#&Period=#form.prompt1#&ResidencyType=0','popwin','scrollbars=yes,resizable=yes');
</script>
	<!---<FORM NAME="MoveInSummaryByHouseReport" action="//#crserver#/reports/tips/tips4/MoveInSummaryByHouse.rpt" method="POST" TARGET="MoveInSummaryByHouseReport">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<input type=hidden name="user0" value="#User#">
		<input type=hidden name="password0" value="#Password#">
		<INPUT TYPE="Hidden" name="prompt0" value="#HouseData.cName#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#form.prompt1#">--->
		
		<SCRIPT> location.href='#HTTP_REFERER#'; document.MoveInSummaryByHouseReport.submit(); </SCRIPT>
		#HouseData.cNumber#<BR>
	<!---</FORM>--->
</CFOUTPUT>

	

