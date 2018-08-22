<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| To create Daily Census Report for each house                                                 |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
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
| fzahir     | 11/03/2005 | To generate Daily Census Report for each House                     |
| sfarmer    | 02/02/2016 | Updated for Coldfusion/PDF report                                  |
----------------------------------------------------------------------------------------------->
<!--- 
 <CFOUTPUT>
	<CFIF NOT IsDefined("SESSION.USERID")><CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes"></CFIF>
	<CENTER><B STYLE="font-size: 30;"> Please wait while the report is loading.... </B></CENTER>
</CFOUTPUT>

<SCRIPT>report = window.open("loading.htm","DailyCensusReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>
 
 --->
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	(OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN	Region R	ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	AND		H.dtRowDeleted IS NULL
	AND		H.bisSandbox = 0
</CFQUERY>

<CFOUTPUT>
<!--- 	 <CFSCRIPT> User="rw"; Password="4rwriter"; </CFSCRIPT>  --->

<!--- //#crserver#/reports/tips/tips4/BirthdaySummary.rpt --->
<!--- <FORM NAME="DailyCensusReport" action="//#crserver#/reports/tips/tips4/DailyCensusReport.rpt" method="POST" TARGET="DailyCensusReport">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<INPUT TYPE=hidden name="PromptOnRefresh" value=1>
		<input type=hidden name="user0" value="#User#">
		<input type=hidden name="password0" value="#Password#">
		<input type=hidden name="user0@HouseInfo" value="#USER#">
		<input type=hidden name="password0@HouseInfo" value="#Password#"> --->
		<!--- <input type=hidden name="user0@exception with special groups.rpt" value="#USER#">
		<input type=hidden name="password0@exception with special groups.rpt" value="#Password#"> --->
<!--- 		<input type=hidden name="prompt0" value="#HouseData.iHouse_ID#"> --->
		<!--- <input type=hidden name="prompt1" value="-1"> ---> 
<!--- 		<input type=hidden name="prompt1" value="#form.dtcompare#"> 
		
		<SCRIPT> location.href='#HTTP_REFERER#'; document.DailyCensusReport.submit(); </SCRIPT>
		#HouseData.cNumber# <BR>#form.dtcompare#<BR>END 
	</FORM> --->
	<cfset prompt0 = #HouseData.iHouse_ID#>
	<cfset prompt1 = #form.dtcompare#>
	<cflocation url="CensusDailyReport.cfm?prompt0=#prompt0#&prompt1=#prompt1#">
</CFOUTPUT>
 


 
	

