<cfinclude template="../../../header.cfm">
<cfparam name="selstate" default="">
	<cfquery name="qryMCOState" DATASOURCE="#APPLICATION.datasource#">
		SELECT cStateCode
		,cStateName
		,bIsMedicaid
		FROM TIPS4.dbo.StateCode
		where bIsMedicaid = 1
	</cfquery>
 
<title> Tips 4-Medicaid</title>
<body>
<h1 class="PageTitle"> Tips 4 - Medicaid Provider Setup & Maintenance</h1>

<!--- <cfinclude template="../../Shared/HouseHeader.cfm"> --->
 	<cfoutput>
	<table>
		<tr  style="background-color:##CCFFFF">
			<td style="text-align:center; font-weight:bold">MCO Home</td>
		</tr>
	</table>
	<cfif selstate is ''>
		<cfform name="selstate" method="post" action="MCOHome.cfm">
			<table>
				<tr  style="background-color:##FFFFCC">
					<td style="text-align:right">Select State</td>
					<td><cfselect name="selstate" value="cStateCode" query="qryMCOState" display="cStateName" ></cfselect></td>
				</tr>
				<tr  style=" background-color:##66FF66">
					<td colspan="2" style="text-align:center"><input type="submit" name="submit" value="submit"></td>
				</tr>		
			</table>
		</cfform>
	<cfelse>
		<table>
			<cf_cttr colorOne="E6E6FA" colorTwo="E6E6F0">
				<td>Select Activity:</td>
			</tr>
			<tr>
				<td><a  href="MCOReview.cfm?selstate=#selstate#" >View Exisitng Medicaid Provider</a> </td>
			</tr>			
			<tr style=" background-color: ##FFFF99">
				<td><a  href="MCONew.cfm?selstate=#selstate#" >Setup New Medicaid Provider</a> </td>
			</tr>
			<tr>
				<td><a href="MCOMaintenance.cfm?selstate=#selstate#" >Update Existing Medicaid Provider</a></td>
			</tr>
		</table>
	</cfif>
	</cfoutput>
<!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">