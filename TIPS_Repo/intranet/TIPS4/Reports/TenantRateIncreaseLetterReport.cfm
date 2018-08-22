
<CFOUTPUT>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>
<SCRIPT> window.open("loading.htm","TenantRateIncreaseLetterReport","toolbar=no,resizable=yes"); </SCRIPT>
<cfset alist = "ASTOR HOUSE,BAYSIDE AT SOUTH BEACH,SAWYER HOUSE,RACKLEFF HOUSE,PARKHURST HOUSE,MACKLYN HOUSE,LINKVILLE HOUSE,JACKSON HOUSE,HUFFMAN HOUSE
,HILLSIDE HOUSE,GRACE HOUSE,DOUGLAS HOUSE,DAVENPORT HOUSE,SHASTA VIEW,VICTORIA HOUSE,SYDNEY HOUSE,ALBRIGHT HOUSE,MOUNTAINVIEW HOUSE,LOUISA HOUSE
,LEXINGTON HOUSE,KARR HOUSE,FRANKLIN HOUSE,CRAWFORD HOUSE,COLONIAL HOUSE,CASCADE HOUSE,WARREN HOUSE,TETON HOUSE,AWBREY HOUSE,ASPEN COURT
,ANNABELLE HOUSE,ROSEWIND HOUSE,PIONEER HOUSE,ORCHARD HOUSE,MALLORY HOUSE,JUNIPER HOUSE,CLEARWATER HOUSE,CHENOWETH HOUSE,CHAPARELLE HOUSE
,CARRIAGE HOUSE,BROOKSIDE HOUSE,BLOSSOM HOUSE,WINDRIVER HOUSE,SYLVAN HOUSE,CLARK HOUSE">

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.cNumber, OA.cNumber as OPS, R.cNumber as Region,H.cName as HouseName
	FROM	House H
	JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	H.dtRowDeleted IS NULL	
	AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>
	<cfif #ListContains(aList, HouseData.HouseName)# eq 0>
		<!--- New report to replace TenantRateIncreaseLetter made by Ryan Posted By PaulB 1/20/04---> 
		<FORM NAME="TenantRateIncreaseLetter" ACTION = "http://#crserver#/reports/tips/tips4/RateIncreaseLetter_2008_v2.rpt" METHOD="POST" TARGET="TenantRateIncreaseLetterReport">
	<cfelse>
		<!--- New report to replace TenantRateIncreaseLetter made by Ryan Posted By PaulB 1/20/04---> 
		<FORM NAME="TenantRateIncreaseLetter" ACTION = "http://#crserver#/reports/tips/tips4/RateIncreaseLetter_2008_v1.rpt" METHOD="POST" TARGET="TenantRateIncreaseLetterReport">
	</cfif>		
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=0>
			<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">

			<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="'#HouseData.HouseName#'">
			<!---<INPUT TYPE = "Hidden" NAME="prompt1" VALUE="FALSE">
						
			<INPUT TYPE = "Hidden" NAME="prompt1" VALUE="#trim(form.adminname)#">
			<INPUT TYPE = "Hidden" NAME="prompt2" VALUE="#trim(form.title)#">
			--->
		<SCRIPT>location.href='#HTTP_REFERER#'; document.TenantRateIncreaseLetter.submit();</SCRIPT>
	</FORM>
	#HouseData.cNumber#<BR>
</CFOUTPUT>