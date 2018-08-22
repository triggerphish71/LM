<cfinclude template="../../../header.cfm">
<title>TIPS4 - Designate Medicaid State</title>
</head>
<cfquery name="qryMedicaidState" DATASOURCE="#APPLICATION.datasource#">
SELECT [cStateCode]
      ,[cStateName]
      ,[bIsMedicaid]
  FROM [dbo].[StateCode] where bIsMedicaid = 1
</cfquery>
<cfquery name="qryState" DATASOURCE="#APPLICATION.datasource#">
SELECT [cStateCode]
      ,[cStateName]
      ,[bIsMedicaid]
  FROM [dbo].[StateCode]  
</cfquery>
<body>
<h1 class="PageTitle"> Tips 4 - Medicaid States Setup & Maintenance</h1>
<cfoutput>
	<table>
		<tr  style="background-color:##CCFFFF">
			<td>States That Are Currently Medicaid Elgibile</br>(Select to Remove State From Medicaid Eligible List)</td>
		</tr>
			<cfloop query="qryMedicaidState">
			<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
				<td><a href="MedicaidStateRemove.cfm?cstatecode=#cstatecode#"> #cStateName#</a></td>
			</cf_ctTR>
		</cfloop>
	</table>
		<cfform name="selstate" method="post" action="MedicaidStateAdd.cfm">
			<table>
				<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
					<td style="text-align:right">Select to Add State as Medicaid Eligible </td>
					<td><cfselect name="cStateCode" value="cStateCode" query="qryState" display="cStateName" ></cfselect></td>
				</cf_ctTR>
				<tr  style=" background-color:##66FF66">
					<td colspan="2" style="text-align:center"><input type="submit" name="submit" value="submit"></td>
				</tr>		
			</table>
		</cfform>
</cfoutput>
<!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
