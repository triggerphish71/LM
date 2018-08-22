
<SCRIPT>report=window.open("loading.htm","CashReceiptsReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>		
	<FORM NAME="CashReceipts" ACTION="//#crserver#/reports/tips/tips4/cr4applicants.rpt" METHOD="Post" TARGET="CashReceiptsReport" onSubmit="opennew();">
		<INPUT TYPE="Hidden" NAME="user0" VALUE="rw">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="4rwriter">
		<INPUT TYPE="Hidden" NAME="user0@getglbalancesub.rpt" VALUE="rw">
		<INPUT TYPE="Hidden" NAME="password0@getglbalancesub.rpt" VALUE="4rwriter">
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#SESSION.nHouse#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#HouseData.OPS#">
		<INPUT TYPE="Hidden" NAME="prompt2" VALUE="#HouseData.Region#">
		<SCRIPT>location.href='#HTTP_REFERER#'; document.CashReceipts.submit(); </SCRIPT>
	</FORM>
	<CENTER><B STYLE="font-size: 30;"> Please, wait while the report is loading.... </B></CENTER>
</CFOUTPUT>