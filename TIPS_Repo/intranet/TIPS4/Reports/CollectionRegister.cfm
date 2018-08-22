<SCRIPT> report=window.open("loading.htm","CollectionRegister","toolbar=no,resizable=yes"); report.moveTo(0,0); </SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region, H.cName
	FROM	House H
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>

<CFOUTPUT>
	<FORM NAME="CollectionRegister" ACTION="//#crserver#/reports/tips/tips4/CollectionRegister.rpt" METHOD="Post" TARGET="CollectionRegister" onSubmit="opennew();">
			<input type=hidden name="init" value="actx">
			<input type=hidden name="promptOnRefresh" value=0>
		<INPUT TYPE="Hidden" NAME="user0" VALUE="rw">
		<INPUT TYPE="Hidden" NAME="password0" VALUE="4rwriter">
		<INPUT TYPE="Hidden" NAME="prompt0" VALUE="#HouseData.cName#">
		<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#form.Period#">
		<INPUT TYPE="Hidden" NAME="prompt2" VALUE="#form.Type#">
		<SCRIPT> location.href='#HTTP_REFERER#'; document.CollectionRegister.submit(); </SCRIPT>
	</FORM>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>