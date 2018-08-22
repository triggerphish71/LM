<cfoutput>
<script>
window.open("loading.htm","ResidentCareSummary","toolbar=no,resizable=yes");
</script>
<cfset User="rw"><cfset Password="4rwriter">
<cfif isDefined("form.scope")><cfset scope=form.scope><cfelse><cfset scope=''></cfif>
<cfif isDefined("form.TenantID")><cfset TenantID=form.TenantID><cfelse><cfset TenantID=''></cfif>
<form name="ResidentCareSum" action="//#crserver#/reports/tips/tips4/ResidentCareSummary.rpt" method="POST" TARGET="ResidentCareSummary">
	<input type="hidden" name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
	<input type="hidden" name="promptOnRefresh" value=1>
	<input type="hidden" name="user0" value="#User#">
	<input type="hidden" name="password0" value="#Password#">		
	<input type="hidden" name="prompt0" value="#scope#">
	<input type="hidden" name="prompt1" value="#year#">
	<input type="hidden" name="prompt2" value="#TenantID#">
	<input type="hidden" name="prompt3" value="#AdminName#">
	<input type="hidden" name="prompt4" value="#Title#">
</form>
<script>location.href='#http_referer#'; document.ResidentCareSum.submit(); </script>
</cfoutput>

	

