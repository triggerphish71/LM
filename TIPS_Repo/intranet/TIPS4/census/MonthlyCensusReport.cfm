<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| To create Daily Census Report for each house                                                 |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES: sp_monthlycensusreport                                                    |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| fzahir     | 11/03/2005 | To generate Monthly Census Report for each House. This report      |
|            |            | tracks monthly activity of each tenant. This report also tracks    |
|            |            | leave of each tenant by a month.                                   |
----------------------------------------------------------------------------------------------->

<!--- <CFOUTPUT>
	<CFIF NOT IsDefined("SESSION.USERID")><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"></CFIF>
	<CENTER><B STYLE="font-size: 30;"> Please wait while the report is loading.... </B></CENTER>
</CFOUTPUT>

<SCRIPT>report = window.open("loading.htm","MonthlyCensusReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>
 --->
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	  AND	H.dtrowdeleted is NULL
	  AND	H.bisSandbox = 0
</CFQUERY>
	
<CFOUTPUT>
<!--- 	<CFSCRIPT> User="rw"; Password="4rwriter"; </CFSCRIPT>

	<FORM NAME="MonthlyCensusReport" action="//#crserver#/reports/tips/tips4/MonthlyCensusReport.rpt" method="POST" TARGET="MonthlyCensusReport">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<INPUT TYPE=hidden name="PromptOnRefresh" value="1">
		<input type=hidden name="user0" value="#User#">
		<input type=hidden name="password0" value="#Password#">
		<input type=hidden name="prompt0" value="#HouseData.iHouse_ID#">  
        <input type=hidden name="prompt1" value="#form.dtCompare#">

		<SCRIPT> location.href='#HTTP_REFERER#'; document.MonthlyCensusReport.submit(); </SCRIPT>
		#HouseData.cNumber#<BR>#form.dtCompare#<BR>END
		
	</FORM> --->
	<cfset prompt0 =#HouseData.iHouse_ID#>
	<cfset prompt1 =#form.dtCompare#>
	<cflocation url="CensusMonthlyReport.cfm?prompt0=#prompt0#&prompt1=#prompt1#">
</CFOUTPUT>