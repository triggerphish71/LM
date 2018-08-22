<!---------------------------------------------------------------------------------------------------
|Name:       TenantPromotionReport.cfm                                                                      |
|Type:       Template                                                                                |
|Purpose:    This page will pull the TenantPromotionReport.rpt                                       |
|----------------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                                  |
|----------------------------------------------------------------------------------------------------|
|  none                                                                                              |
|----------------------------------------------------------------------------------------------------|
|Called by: Menu.cfm                                                                                 |
|    Parameter Name                      Description                                                 |
|----------------------------------------------------------------------------------------------------|
|----------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                              |
|------------|------------|--------------------------------------------------------------------------|
| Sathya  	 |08/12/10    | Created this page as part of project 50227 Tips Promotions               |
------------------------------------------------------------------------------------------------------>

<CFOUTPUT>
	<cfif isDefined("form.prompt0")>
		<cfset HouseScope = #form.prompt0#>
		<cfif form.prompt0 EQ 'ALL'>
			<cfset HouseScope = 0>
		</cfif>
	<cfelse>
		<cfset HouseScope = 0>
	</cfif>
	
	
	
	<CENTER><B STYLE="font-size: 30;">Please, wait while the report is loading....</B></CENTER>
</CFOUTPUT>

<SCRIPT> window.open("loading.htm","TenantswithPromotion","toolbar=no,resizable=yes"); </SCRIPT>

<!--- For Testing only
 <cfoutput>
 HouseScope: #HouseScope#

<br></br>
form.prompt0: #form.prompt0#


</cfoutput> --->


<CFOUTPUT>		
	<FORM NAME="Promotions" ACTION = "//#crserver#/reports/tips/tips4/TenantswithPromotion.rpt" METHOD="POST" TARGET="TenantswithPromotion" onSubmit="opennew();">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="promptOnRefresh" value=0>
			<INPUT TYPE = "Hidden" NAME="user0" VALUE="rw">
			<INPUT TYPE = "Hidden" NAME="password0" VALUE="4rwriter">
			<INPUT TYPE = "Hidden" NAME="prompt0" VALUE="#HouseScope#">
 			
			
		<SCRIPT>location.href='#HTTP_REFERER#'; document.Promotions.submit(); </SCRIPT>
	</FORM>
	<CENTER><B STYLE="font-size: 30;"> Please, wait while the report is loading.... </B></CENTER>
</CFOUTPUT>

