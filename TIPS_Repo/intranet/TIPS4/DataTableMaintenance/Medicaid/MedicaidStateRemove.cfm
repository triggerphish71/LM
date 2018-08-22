 <cfinclude template="../../../header.cfm">

<title>TIPS4 - Medicaid Remove State Eligible</title>
</head>
<cfquery name="qryState" DATASOURCE="#APPLICATION.datasource#">
	select cStateName 
	from StateCode
	where cStateCode = '#cStateCode#'
</cfquery>

<body>
<cfquery name="qryHouse" DATASOURCE="#APPLICATION.datasource#"> 
	select distinct h.cname  from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id
	join house h on t.ihouse_id = h.ihouse_id and h.cstatecode = '#cStateCode#'
	where ts.itenantstatecode_id in (1,2,3) and ts.iresidencytype_id = 2
	and t.dtrowdeleted is null 
	and ts.dtrowdeleted is null 
	and h.dtrowdeleted is null 
	and h.iunitsavailable > 0
	and t.clastname <> 'Medicaid'
	order by h.cname
</cfquery>

<cfquery name="qryResidents" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant t
	join tenantstate ts on t.itenant_id = ts.itenant_id
	join house h on t.ihouse_id = h.ihouse_id and h.cstatecode = '#cStateCode#'
	where ts.itenantstatecode_id in (1,2,3) 
		and ts.iresidencytype_id = 2
		and t.clastname <> 'Medicaid'
	
</cfquery>

<cfoutput>
	<cfif qryResidents.recordcount gt 0>
		<table>
		<tr><td>Removing #qryState.cStateName# from Medicaid eligibilty is not allowed at this time.
		<br>There are residents still in the system at one or more of the following statuses:</td></tr>
		<tr><td><ul><li>Inquiry/Move-In</li><li>Current Resident</li><li>Move-Out Not Finalize</li></ul></td></tr>
		<tr><td>At Houses: <br><ul><cfloop query="qryHouse"><li>#qryHouse.cname#</li></cfloop></ul></td></tr>
		</table>
	<cfelse>
		
		<cfquery name="removeStateEligible" DATASOURCE="#APPLICATION.datasource#">
			update stateCode
			set bIsMedicaid = null
			where cStateCode = '#cStateCode#'
		</cfquery>
		
		<cflocation url="MedicaidStateMaintenance.cfm">
	</cfif>
</cfoutput>
<!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
