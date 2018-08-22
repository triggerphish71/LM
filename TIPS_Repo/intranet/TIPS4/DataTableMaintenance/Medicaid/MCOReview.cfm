<cfinclude template="../../../header.cfm">
<cfparam name="selstate" default="">
	<cfquery name="qryMCOState" DATASOURCE="#APPLICATION.datasource#">
		SELECT cStateCode
		,cStateName
		,bIsMedicaid
		FROM TIPS4.dbo.StateCode
		where bIsMedicaid = 1 and cstatecode = '#selstate#'
	</cfquery>
 <CFQUERY name="qryMCO"  DATASOURCE="#APPLICATION.datasource#">
 SELECT   iMCOProvider_ID
      ,cMCOProvider
      ,iMCO_ID
      ,cStateCode
      ,dtRowStart
      ,iRowStartUser_ID
      ,dtRowEnd
      ,iRowEndUser_ID
      ,dtRowDeleted
      ,iRowDeletedUser_id
      ,cRowStartUser_id
      ,cRowEndUser_ID
      ,cRowDeletedUser_ID
      ,dtEffectiveStart
      ,dtEffectiveEnd
  FROM TIPS4.dbo.MCOProvider WHERE CSTATECODE = '#selstate#'
  </CFQUERY>
<title> Tips 4-Medicaid</title>
</head>
<body>
<CFOUTPUT>
<h1 class="PageTitle"> Tips 4 - Medicaid Providers for #qryMCOState.cStateName#</h1>


<body>
<TABLE>
	<tr  style="background-color:##CCFFFF">
		<TD>Provider</TD>
		<td>Provider ID</td>
		<td>Effective Start Date</td>
		<td>Effective End Date</td>
	</TR>
	<cfloop query="qryMCO">
		<cf_cttr colorOne="E6E6FA" colorTwo="E6E6F0">
			<TD><a href="MCOMaintenance.cfm?selMCOid=#iMCOProvider_ID#">#cMCOProvider#</a></TD>
			<td>#iMCO_ID#</td>
			<td>#dateformat(dtEffectiveStart, 'mm/dd/yyyy')#</td>
			<td>#dateformat(dtEffectiveEnd, 'mm/dd/yyyy')#</td>
		</TR>	
	</cfloop>
</TABLE>
</CFOUTPUT>
 <!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">
