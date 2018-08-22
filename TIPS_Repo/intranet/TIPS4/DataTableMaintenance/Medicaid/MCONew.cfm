<cfinclude template="../../../header.cfm">
<cfparam name="selstate" default="">
<cfoutput>
 <cfquery name="qrystate"  DATASOURCE="#APPLICATION.datasource#">
SELECT cStateCode
      ,cStateName
      ,bIsMedicaid
  FROM TIPS4.dbo.StateCode where cstatecode = '#selstate#'
</cfquery>
 
<title> Tips 4-Medicaid</title>
<body>
<h1 class="PageTitle"> Tips 4 - Medicaid Provider Setup - #qrystate.cStateName#</h1>

<body>


<cfform name="updMCO" method="post" action="addMCO.CFM">
	<table >
	<tr>
		<td>Provider</td>
		<td><input name="cMCOProvider" value=""></td>
	</tr>
	<tr>
		<td>Provider ID</td>
		<td><input name="iMCO_ID" value=""></td>
	</tr>
	<tr>
		<td>State</td>
		<td><input name="cStateCode" value="#selstate#"  readonly="yes"></td>
	</tr>
	<tr>
		<td>Effective Start Date</td>
		<td><input name="dtEffectiveStart" value=""> format: mm/dd/yyyy</td>
	</tr>		
	<tr>
		<td>Effective End Date</td>
		<td><input name="dtEffectiveEnd" value=""> format: mm/dd/yyyy</td> 
	</tr>	
	<tr>
		<td colspan="2" style="text-align:center"><input name="Submit" type="submit" value="Submit"></td>
	</tr>
</table>
</cfform>
</cfoutput>
 <!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
