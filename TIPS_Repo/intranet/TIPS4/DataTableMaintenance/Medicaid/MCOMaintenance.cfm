<cfinclude template="../../../header.cfm">

<cfparam name="selMCOid" default="">
<cfparam name="selstate" default="">
<cfquery name="qryMCO" DATASOURCE="#APPLICATION.datasource#">
SELECT   [iMCOProvider_ID]
      ,[cMCOProvider]
   FROM [TIPS4].[dbo].[MCOProvider]
   where cstatecode = '#selstate#'
</cfquery>

<title> Tips 4-Medicaid</title>
<body>
<h1 class="PageTitle"> Tips 4 - Medicaid</h1>

<!--- <cfinclude template="../../Shared/HouseHeader.cfm"> --->
<cfoutput>
<table>
	<tr>
		<td style="text-align:center; font-weight:bold"> Medicaid MCO Provider Maintenance</td>
	</tr>
</table>
<cfif selMCOid is ''>
	<cfform name="SelMCO"  method="post"   action="MCOMaintenance.cfm">
		<table>
			<tr  style="background-color:##CCFFFF">
				<td style="text-align:center">Select MCO</td>
			</tr>
			<tr  style="background-color:##FFFFCC">
				<td style="text-align:center">

						<cfselect name="selMCOid"  id="selMCOid" >
									<option value="">Select From List</option>					
							<cfloop query="qryMCO">
									<option value="#iMCOProvider_ID#">#cMCOProvider#</option>
							</cfloop>
						</cfselect>
					
				</td>
			</tr>
			<tr  style=" background-color:##66FF66">
				<td style="text-align:center"><input type="submit" name="Submit" value="Submit"></td>
			</tr>
		</table >
	</cfform>
<cfelse>
<cfquery name="qryMCO" DATASOURCE="#APPLICATION.datasource#">
SELECT   [iMCOProvider_ID]
         ,[cMCOProvider]
      ,[iMCO_ID]
      ,[cStateCode]
      ,[dtRowStart]
      ,[iRowStartUser_ID]
      ,[dtRowEnd]
      ,[iRowEndUser_ID]
      ,[dtRowDeleted]
      ,[iRowDeletedUser_id]
      ,[cRowStartUser_id]
      ,[cRowEndUser_ID]
      ,[cRowDeletedUser_ID]
      ,[dtEffectiveStart]
      ,[dtEffectiveEnd]
 
  FROM [TIPS4].[dbo].[MCOProvider]
  where iMCOProvider_id = #selMCOid#
</cfquery>
<cfquery name="qrystate"  DATASOURCE="#APPLICATION.datasource#">
SELECT cStateCode
      ,cStateName
      ,bIsMedicaid
  FROM TIPS4.dbo.StateCode
</cfquery>

<cfform name="updMCO" method="post" action="updMCO.CFM">
	<table >
	<cfloop query="qryMCO">
	<input type="hidden" name="iMCOProvider_ID" value="#iMCOProvider_ID#">
	<tr style=" background-color: ##FFFF99">
		<td>Provider</td>
		<td><input name="cMCOProvider" value="#cMCOProvider#"></td>
	<tr>
	<tr>
		<td>Provider ID</td>
		<td><input name="iMCO_ID" value="#iMCO_ID#"></td>
	</tr>
	<tr style=" background-color: ##FFFF99">
		<td>State</td>
		<td><cfselect name="cStateCode" value="cStateCode" query="qrystate" selected="#qryMCO.cStateCode#"></cfselect></td>
	<tr>
	<tr>
		<td>Delete Date <br >(Use ONLY to REMOVE the MCO from available list)</td>
		<td><input name="dtRowDeleted" value="#dtRowDeleted#"> format: mm/dd/yyyy</td>
	<tr>
	<tr style=" background-color: ##FFFF99">
		<td>Effective Start Date</td>
		<td><input name="dtEffectiveStart" value="#dateformat(dtEffectiveStart, 'mm/dd/yyyy')#"> format: mm/dd/yyyy</td>
	</tr>		
	<tr>
		<td>Effective End Date</td>
		<td><input name="dtEffectiveEnd" value="#dateformat(dtEffectiveEnd, 'mm/dd/yyyy')#"> format: mm/dd/yyyy</td> 
	</tr>	
	<tr  style=" background-color:##66FF66">
		<td colspan="2" style="text-align:center"><input name="Submit" type="submit" value="Submit"></td>
	</tr>
	</cfloop>
</cfform>

</table>
</cfif>
</cfoutput>
<!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
