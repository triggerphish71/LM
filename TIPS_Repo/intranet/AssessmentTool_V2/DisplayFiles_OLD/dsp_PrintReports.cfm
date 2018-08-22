
<script> report=window.open("loading.htm","AssessmentToolLetter","toolbar=no,resizable=yes"); report.moveTo(0,0); </script>

<cfscript>
if (isDefined("URL.AN") ) { AdminName = URL.AN; } else { AdminName = ""; }
</cfscript>

<cfoutput>		
	<form name="AssessmentToolLetter" action="//#crserver#/reports/tips/tips4/AssessmenToolLetter.rpt" method="Post" TARGET="AssessmentToolLetter" onsubmit="opennew();">
		<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
		<input type=hidden name="promptOnRefresh" value=0>
		<input type="Hidden" name="user0" value="rw">
		<input type="Hidden" name="password0" value="4rwriter">	
		<input type="Hidden" name="prompt0" value="#url.A#"> <!--- assessment tool master id --->
		<input type="Hidden" name="prompt1" value="#url.h#"> <!--- house id --->
		<input type="Hidden" name="prompt2" value="#url.tot#"> <!--- total house option Y or N --->
		<input type="Hidden" name="prompt3" value="#url.D#"> <!--- letter date --->
		<input type="Hidden" name="prompt4" value="#AdminName#"> <!--- administrator name --->
		<input type="Hidden" name="prompt5" value="#title#"> <!--- Title --->
<!---		<script> location.href='#HTTP_REFERER#'; document.AssessmentToolLetter.submit(); </script> --->
		<script> document.AssessmentToolLetter.submit(); </script>
	</form>
	<b style="font-size:medium;text-align:center;">
	Please wait while the report is loading....
	</b>
</cfoutput>

<script>self.close();</script>