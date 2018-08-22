

<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3025>
		<CFIF IsDefined("form.fieldnames")>
			#form.fieldnames#<BR>
		</CFIF>
	</CFIF>
	
	<CENTER>
		<B STYLE="font-size: 30;">
			Please, wait while the report is loading....
		</B>
	</CENTER>
	
</CFOUTPUT>


<SCRIPT>
		window.open("loading.htm","OutdatedMoveOuts","toolbar=no,resizable=yes");
</SCRIPT>
7
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
			JOIN	OPSArea OA
			ON	OA.iOPSArea_ID = H.iOPSArea_ID
			JOIN	Region R
			ON	OA.iRegion_ID = R.iRegion_ID
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

		<form NAME="OutdatedMoveOuts" action="//#crserver#/reports/tips/tips4/OutdatedMoveOuts.rpt" method="POST" TARGET="OutdatedMoveOuts">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=1>
			<input type=hidden name="user0" value="#User#">
			<input type=hidden name="password0" value="#Password#">
			<input type=hidden name="user0@HouseInfo" value="#User#">
			<input type=hidden name="password0@HouseInfo" value="#Password#">
			<input type=hidden name="prompt0" value="#HouseData.iHouse_ID#">
			<input type=hidden name="prompt1" value="#form.NumDays#">
			<input type=hidden name="prompt2" value="#form.dtCompare#">
			<SCRIPT>
				location.href='#HTTP_REFERER#'
				document.OutdatedMoveOuts.submit();
			</SCRIPT>
			#HouseData.cNumber#<BR>#form.NumDays#<BR>#form.dtCompare#<BR>END
		</form>
</CFOUTPUT>

	

