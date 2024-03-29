<!---   Ganga 6/25/2013 :  Created for new Idaho houses enquiry section assessment crystal reports --->

<cfquery name="HouseData" datasource="#APPLICATION.datasource#">
select H.cNumber, OA.cNumber as OPS, R.cNumber as Region, iHouse_ID, cSLevelTypeSet
from House H
join OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
join Region R ON OA.iRegion_ID = R.iRegion_ID
where iHouse_ID = #session.House.GetId()#	
</cfquery>	

<script> 
report=window.open("loading.htm","AssessmentReport","toolbar=no,resizable=yes"); 
report.moveTo(0,0); 
</script>

<!--- default to NO if no parameter is passed --->
<cfif isDefined("assessmentIdllques")>	<cfset allornone=assessmentIdllques> <cfelse> <cfset allornone='N'> </cfif>
<cfif isDefined("url.scope")>	<cfset scope=scope> <cfelse> <cfset scope=''> </cfif>
<cfoutput>


<form name="AssessmentSummary" ACTION="//#crserver#/reports/tips/tips4/AssessmentToolPrintSummary_Enquiry_ID.rpt" method="Post" target="AssessmentReport">

	<input type="hidden" name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
	<input type="hidden" name="promptOnRefresh" value=0>
	<input type="hidden" name="user0" value="rw">
	<input type="hidden" name="password0" value="4rwriter">	
	<input type="hidden" name="user0@srPointsList" value="rw">
	<input type="hidden" name="password0@srPointsList" value="4rwriter">
	       <input type="hidden" name="user0@pointlistreport" value="ro">
			<input type="hidden" name="password0@pointlistreport" value="read">	
	<input type="hidden" name="prompt0" value="#assessmentId#">
	<input type="hidden" name="prompt1" value="#allornone#">
	<input type="hidden" name="prompt2" value="#scope#">
</form>
<center><b style="font-size:medium;">Please wait while the report is loading....</b></center>

<script>
self.focus();
document.AssessmentSummary.submit(); 
self.close();
</script>
</cfoutput>
