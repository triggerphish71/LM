

<CFOUTPUT>
	<CFIF IsDefined("url.prompt0")><CFSET form.prompt0 = #url.prompt0#></CFIF>
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>

<SCRIPT>report=window.open("loading.htm","CSVExceptionReport","toolbar=no,resizable=yes"); report.moveTo(0,0);</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID and OA.dtrowdeleted is null
	JOIN	Region R ON	OA.iRegion_ID = R.iRegion_ID and R.dtrowdeleted is null
	WHERE	h.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<CFOUTPUT>		

<CFSET User="rw">
<CFSET Password="4rwriter">

<!--- ==============================================================================
		Form for calling a Crystal Report
				Developed by Steve Davison on 9/28/01
				Edit 10/3/01 by Steve Davison:  Moved form tag outside of TD tag to prevent
								expansion of cell height.
				The form action must be the filename of the report to be loaded
				The login for the container report is passed as user0/password0
				The login for each subreport is passed as user0@subreportname/password0@subreportname
				In this case, an HREF tag is expanded by including an OnClick event that
				submits the form instead of loading the HREF value ("return cancel" will
				negate the redirection of the anchor tag and process the form action instead
					Possible enhancements:
				1.	Use form action to call a ColdFusion page that would dynamically build
					the username/password combinations and redirect to the report.  This method
					would hide the username/password from "View Source" as user would never "see"
					the html page that loads the report).
=============================================================================== --->
		
		<form action="//#crserver#/reports/tips/tips4/CSVExceptionSummary.rpt" method="POST" name="CSVException" TARGET="CSVExceptionReport">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=0>
			<input type=hidden name="user0" value="#USER#">
			<input type=hidden name="password0" value="#Password#">
			<input type=hidden name="user0@Details" value="#USER#">
			<input type=hidden name="password0@Details" value="#Password#">
			<input type=hidden name="prompt0" value="#HouseData.cNumber#">
			<input type=hidden name="prompt1" value="">
			<input type=hidden name="prompt2" value="Y">
			<input type=hidden name="prompt3" value="Y">
			<input type=hidden name="prompt4" value="Y">
			<SCRIPT>location.href='#HTTP_REFERER#'; document.CSVException.submit();</SCRIPT>
		</form>
</CFOUTPUT>

	

