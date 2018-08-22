

<CFOUTPUT>
	<CFIF NOT IsDefined("SESSION.USERID")><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"></CFIF>
	<CENTER><B STYLE="font-size: 30;"> Please wait while the report is loading.... </B></CENTER>
</CFOUTPUT>

<SCRIPT>report = window.open("loading.htm","MoveInMoveOutActivitySummaryByHouseReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>
	
<CFOUTPUT>
	<CFSCRIPT> User="rw"; Password="4rwriter"; </CFSCRIPT>
<CFSET User="rw">
<CFSET Password="4rwriter">

	<FORM NAME="MoveInMoveOutActivitySummaryByHouseReport" action="//#crserver#/reports/tips/tips4/MoveInMoveOutActivitySummaryByHouse.rpt" method="POST" TARGET="MoveInMoveOutActivitySummaryByHouseReport">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<INPUT TYPE=hidden name="PromptOnRefresh" value="FALSE">
		<input type=hidden name="user0" value="#User#">
		<input type=hidden name="password0" value="#Password#">
		<INPUT TYPE="Hidden" name="prompt0" value="#HouseData.cName#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#form.pPeriod#">
		<INPUT TYPE="Hidden" NAME="prompt2" VALUE="">
		<INPUT TYPE="Hidden" NAME="prompt3" VALUE="#form.pActivityType#">
		<INPUT TYPE="Hidden" NAME="prompt4" VALUE="#form.pResidencyType#">

		<SCRIPT> location.href='#HTTP_REFERER#'; document.MoveInMoveOutActivitySummaryByHouseReport.submit(); </SCRIPT>
		#HouseData.cNumber#<BR>
	</FORM>
</CFOUTPUT>

	

