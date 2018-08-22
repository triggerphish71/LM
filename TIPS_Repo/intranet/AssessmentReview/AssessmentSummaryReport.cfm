
<CFOUTPUT>
	<CFIF NOT IsDefined("periodid") OR NOT IsDefined("HTTP_Referer")>
		<CENTER>
			<STRONG STYLE='color: red;'>
				An Security error has occurred and the internet administrator has been notified.<BR>
				If you used a short cut to get to this page please refrain from using the short cut and login instead.
			</STRONG><BR>
			<INPUT TYPE='button' NAME='Go Home' VALUE='Click Here to Continue' onClick="location.href='http://#SERVER_NAME#'">
		</CENTER>
		<CFABORT>
	</CFIF>
	<CFIF IsDefined("url.HouseID")> <CFSET form.HouseID = url.HouseID> <CFELSE> <CFSET form.HouseID = 0> </CFIF>
	<CFIF IsDefined("url.PeriodID")> <CFSET form.PeriodID = url.PeriodID> <CFELSE> <CFSET form.PeriodID = 0> </CFIF>

	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>
<SCRIPT> window.open("loading.htm","AssessmentSummaryReport","toolbar=no,resizable=yes"); </SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	H.dtRowDeleted IS NULL	
	AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>		
	<FORM NAME="AssessmentSummary" ACTION = "http://#crServer#/reports/tips/tips4/AssessmentSummary.rpt" METHOD="POST" TARGET="AssessmentSummaryReport">
			<input type=hidden name="init" value="actx">  <!--- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML --->
			<input type=hidden name="promptOnRefresh" value=0>
			<INPUT TYPE="Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE="Hidden" NAME="password0" VALUE="4rwriter">

			<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#form.HouseID#">
 			<INPUT TYPE="Hidden" NAME="prompt1" VALUE=#form.PeriodID#>
		<SCRIPT>
			location.href='#HTTP_REFERER#'
			document.AssessmentSummary.submit();
		</SCRIPT>
	</FORM>
	#HouseData.cNumber#<BR>
</CFOUTPUT>