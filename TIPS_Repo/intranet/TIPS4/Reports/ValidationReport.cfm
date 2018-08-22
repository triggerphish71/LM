

<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3025>
		<CFIF IsDefined("form.fieldnames")>
			#form.fieldnames#<BR>
			<CFIF IsDefined("form.prompt0")>#form.prompt0#<CFELSE>Prompt0 is NULL</CFIF><BR>
			<CFIF IsDefined("form.prompt2")>#form.prompt2#<CFELSE>Prompt2 is NULL</CFIF><BR><BR>
		</CFIF>
	</CFIF>
	
	<CFIF IsDefined("url.prompt0")>
		<CFSET form.prompt0 = #url.prompt0#>
		<CFSET form.prompt2 = #url.prompt2#>
	</CFIF>

	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
	
</CFOUTPUT>


<SCRIPT> window.open("loading.htm","ValidationReport","toolbar=no,resizable=yes"); </SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	(OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
	JOIN	Region R	ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	AND		H.dtRowDeleted IS NULL
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
		
		<form action="//#crserver#/reports/tips/tips4/validation.rpt" method="POST" name="Validation" TARGET="ValidationReport">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=1>
			<input type=hidden name="user0" value="#USER#">
			<input type=hidden name="password0" value="#Password#">
			<input type=hidden name="user0@exception with special groups.rpt" value="#USER#">
			<input type=hidden name="password0@exception with special groups.rpt" value="#Password#">
			<input type=hidden name="user0@nonspechousechrg.rpt" value="#USER#">
			<input type=hidden name="password0@nonspechousechrg.rpt" value="#Password#">
			<input type=hidden name="user0@additional house charges.rpt" value="#USER#">
			<input type=hidden name="password0@additional house charges.rpt" value="#Password#">
			<input type=hidden name="user0@apttypesubreport.rpt" value="#USER#">
			<input type=hidden name="password0@apttypesubreport.rpt" value="#Password#">
			<input type=hidden name="user0@HouseInfo" value="#USER#">
			<input type=hidden name="password0@HouseInfo" value="#Password#">
			<input type=hidden name="user0@DuplicateCharges" value="#USER#">
			<input type=hidden name="password0@DuplicateCharges" value="#Password#">
			<input type=hidden name="user0@ServiceLevelData" value="#USER#">
			<input type=hidden name="password0@ServiceLevelData" value="#Password#">
			<input type=hidden name="prompt0" value="#HouseData.iHouse_ID#">
			<input type=hidden name="prompt1" value="-1">
			<input type=hidden name="prompt2" value="#form.dtEffective#">
			<SCRIPT>
				location.href='#HTTP_REFERER#'
				document.Validation.submit();
			</SCRIPT>
			#HouseData.cNumber#<BR>
		</form>
</CFOUTPUT>

	

