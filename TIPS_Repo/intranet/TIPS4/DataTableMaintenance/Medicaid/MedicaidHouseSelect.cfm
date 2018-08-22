<cfinclude template="../../../header.cfm">
<title>TIPS4 - House Medicaid Setup</title>
</head>
<cfquery name="qryMedicaidHouse"   DATASOURCE="#APPLICATION.datasource#">
	select * from house where bIsMedicaid = 1 and dtrowdeleted is null 
</cfquery>
<body>
 <h1 class="PageTitle"> Tips 4 - Medicaid House Rates Setup</h1>

<cfform name="selMedicaidHouse" method="post" action="MedicaidHouseUpdate.cfm">
	<cfoutput>	
		<table>
			<tr style=" background-color: ##FFFF99">
				<td style="text-align:center">Select Medicaid House to Update</td>
			</tr>
			<tr>
				<td style="text-align:center"><cfselect name="iHouse_ID" value="iHouse_ID" query="qryMedicaidHouse" display="cName" ></cfselect></td>
			</tr>
			<tr>
				<td style="text-align:center">
				Note: If the house you want to setup is not in this list then it hasn't been established as a Medicaid House
				</td>
			<tr  style=" background-color:##66FF66">
				<td style="text-align:center"><input type="submit" value="Submit" name="Submit" ></td>
			</tr>
		</table>
	</cfoutput>
</cfform>
  <!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
