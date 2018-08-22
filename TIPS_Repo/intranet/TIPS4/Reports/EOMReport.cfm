

<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3025><CFIF IsDefined("form.fieldnames")>#form.fieldnames#<BR></CFIF></CFIF>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>
<SCRIPT>report=window.open("loading.htm","EOMReport","toolbar=no,resizable=yes");report.moveTo(0,0);</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>

<!--- *****************************************************************************
There are two Sub Reports

1)	RentSR.RPT
2)	EOMSummaryExceptionsSub.RPT

There are two Parameters

1)	HouseID	This is the iHouse_ID  (Example 081 for Paris Oaks)
2)	Period		This this the cAppliestoAcctPeriod (Example 200111)
****************************************************************************** --->
<CFSET User="rw">
<CFSET Password="4rwriter">
<form NAME="EOM" action="//#crserver#/reports/tips/tips4/EoMSummary2.rpt" method="POST" TARGET="EOMReport">
	<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
	<input type=hidden name="promptOnRefresh" value=0>
	<input type=hidden name="user0" value="#User#">
	<input type=hidden name="password0" value="#Password#">
	<input type=hidden name="user0@RentSR.rpt" value="#User#">
	<input type=hidden name="password0@RentSR.rpt" value="#Password#">
	<input type=hidden name="user0@EOMSummaryExceptionsSub.RPT" value="#User#">
	<input type=hidden name="password0@EOMSummaryExceptionsSub.RPT" value="#Password#">						
	<input type=hidden name="prompt0" value="#HouseData.cNumber#">
	<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#form.prompt1#">
	<INPUT TYPE="Hidden" NAME="prompt2" VALUE="">
	<SCRIPT>location.href='#HTTP_REFERER#'; document.EOM.submit();</SCRIPT>
	#HouseData.cNumber#<BR>
</form>
</CFOUTPUT>

	

