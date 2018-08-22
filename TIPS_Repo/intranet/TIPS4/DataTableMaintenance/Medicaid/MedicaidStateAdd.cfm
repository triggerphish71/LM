 
<title>TIPS4 - Medicaid Remove State Eligible</title>
</head>

<cfquery name="addStateEligible" DATASOURCE="#APPLICATION.datasource#">
	update stateCode
	set bIsMedicaid = 1
	where cStateCode = '#cStateCode#'
</cfquery>

<cflocation url="MedicaidStateMaintenance.cfm">
<body>
<!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
