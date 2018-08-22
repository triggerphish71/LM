

<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3146>
		<CFIF IsDefined("form.fieldnames")>
			#form.fieldnames#<BR>
			#form.prompt0#<BR>
		</CFIF>
	</CFIF>
	
	<CENTER>
		<B STYLE="font-size: 30;">
			Please, wait while the report is loading....
		</B>
	</CENTER>
	
</CFOUTPUT>


<SCRIPT>
		window.open("loading.htm","HouseActivitySummaryReport","toolbar=no,resizable=yes");
</SCRIPT>

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, H.cNumber, H.cName, OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
			JOIN	OPSArea OA
			ON	OA.iOPSArea_ID = H.iOPSArea_ID
			JOIN	Region R
			ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
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
		
		<form action="//#crserver#/reports/tips/tips4/houseactivitysummary.rpt" method="POST" name="HouseActivity" TARGET="HouseActivitySummaryReport">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=1>
			<input type=hidden name="user0" value="#USER#">
			<input type=hidden name="password0" value="#Password#">
			<input type=hidden name="user0@HouseInfo" value="#USER#">
			<input type=hidden name="password0@HouseInfo" value="#Password#">
			<input type=hidden name="prompt0" value="#HouseData.iHouse_ID#">
			<SCRIPT>
				location.href='#HTTP_REFERER#'
				document.HouseActivity.submit();
			</SCRIPT>
			#HouseData.iHouse_ID#<BR>
		</form>
</CFOUTPUT>

	

