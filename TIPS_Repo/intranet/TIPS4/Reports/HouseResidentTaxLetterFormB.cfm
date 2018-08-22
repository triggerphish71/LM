<!--- <cfdocument format="PDF" filename="file.pdf" overwrite="Yes"> --->

<cfsetting enablecfoutputonly="true">
<cfcontent type="application/pdf">
<cfheader name="Content-Disposition" value="attachment;filename=test.pdf">
<cfdocument format="PDF" >
 <cfdocumentitem type="header">House Tax Letter</cfdocumentitem>
<cfdocumentitem type="footer" > 
<div align="center"> <font color="black" size="1" face="Tahoma"> 
	<cfoutput>ALC Provides this statement of charges invoiced in #prompt1# as a courtesy to its residents and <br />
	family members. ALC does not assume any responsibility, and makes no representation or<br />
	warranty with respect to accuracy of the data contained in this statement. You are responsible<br />
	for your personal tax return and should consult with your tax professional on the utilization<br />
	of any information contained within this document. </cfoutput> 
</cfdocumentitem> 
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>House Tax Letter</title>
</head>
		<cfquery name="sp_housetaxinfo" datasource="#application.datasource#">
			EXEC rw.sp_houseTaxLetter
				@Scope =   '#prompt0#' ,
				@year =   #prompt1# ,
				@tenantID = #prompt2#
		</cfquery> 

 


 
<body>
<table width="95%" border="2" cellspacing="2" cellpadding="2" > 
	<p>
	<p>
	<p>
	<p>
	<p>
	<p>	
	<tr> 
		<td colspan="4"><cfoutput>#Dateformat(now(),'mm/dd/yyyy')#</cfoutput></td> 
	</tr> 
	<p>
	<p>
	<!--- <td>#iHouse_ID#</td> 
	<td>#iResidencyType_ID#</td>  --->
		<cfoutput query="sp_housetaxinfo"> 
			<cfif cPayerName is "None">
			<tr>
				<td colspan="4">Dear #tFullName#,</td>
			</tr>
			<cfelse>
			<tr>
				<td colspan="4">Dear #cPayerName#,</td>
			</tr>
			</cfif>
			<p>
			<tr>
				<td colspan="4">The prompt1 annual invoice total for #tFullName# is listed below:</td>
			</tr>
			<p>
			<tr>
				<td>Private Room & Board</td>
				<td>Private Resident Care</td>
				<td>Other</td>
				<Td>Total</Td>
			</tr>
			<p>
		<cfset sumtotal =  #privateRB#+#privateCare#+#Other#>
			<tr>
				<td>#dollarformat(privateRB)#</td>
				<td>#dollarformat(privateCare)#</td>
				<td>#dollarformat(Other)#</td>
				<td>#dollarformat(sumtotal)#</td>
			</tr>
			<p>
			<tr>
				<td colspan="4"  style="text-align:center">#dollarformat(Payment)#</td>
			</tr> 
			<p>
			<p>
			<p>
			<p>
			<tr>
				<td colspan="4"  style="text-align:center">Sincerely,</td>
			</tr>
			<p>
			<p>
			<p>
			<tr>
				<td>Resident Director</td>
			</tr>
    </cfoutput> 
</table> 
</body>
 
</cfdocument>
<!---  	<cfset destFilePath = "\\fs01\ALC_IT\HouseTaxLetter">	
	<cfset filename = "#sp_housetaxinfo.tFullName##now()#" > 
  <cfheader name="Content-Disposition" value="attachment;filename=file.pdf">
<cfcontent type="application/octet-stream"> --->
<!---    ---> 		<cfoutput  query="sp_housetaxinfo"> 
			#iHouse_ID#,  
			#iTenant_ID# ,
			#tFullName#,
			#cPayerName# ,
			#iResidencyType_ID#,
			#privateRB#,
			#privateCare#  ,
			#Other#,
			#Payment#
		</cfoutput> 
		<cfoutput> #prompt0#  ,
				@year =   #prompt1# ,
				@tenantID = #prompt2#</cfoutput>
