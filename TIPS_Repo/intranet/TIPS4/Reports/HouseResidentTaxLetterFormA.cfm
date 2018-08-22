		<cfquery name="sp_housetaxinfo" datasource="#application.datasource#">
			EXEC rw.sp_houseTaxLetter
					@Scope = N'Tara Plantation',
		@year = N'2013',
		@tenantID = 69872
		</cfquery> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>House Tax Letter</title>
</head>
<cfdocument format="PDF" >
 <cfdocumentitem type="header">House Tax Letter</cfdocumentitem>
<cfdocumentitem type="footer"> 
	<cfoutput>ALC Provides this statement of charges invoiced in 2013 as a courtesy to its residents and <br />
	family members. ALC does not assume any responsibility, and makes no representation or<br />
	warranty with respect to accuracy of the data contained in this statement. You are responsible<br />
	for your personal tax return and should consult with your tax professional on the utilization<br />
	of any information contained within this document. </cfoutput> 
</cfdocumentitem> 

<table width="95%" border="2" cellspacing="2" cellpadding="2" > 
<tr> 
<th>Park</th> 
<th>Manager</th> 
</tr> 
    <cfoutput query="sp_housetaxinfo"> 
    <tr> 
<td>#iHouse_ID#</td> 
<td>#tFullName#</td> 
<td>#cPayerName#</td> 
<td>#iResidencyType_ID#</td> 
</tr>
<tr>
<td>#privateRB#</td>
<td>#privateCare#</td>
<td>#Other#</td>
</tr>
<tr>
<td>#Payment#</td>
    </tr> 
    </cfoutput> 
</table> 

</cfdocument>
 

