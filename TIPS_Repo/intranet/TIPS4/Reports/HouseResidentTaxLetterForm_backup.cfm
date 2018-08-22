<!--- <cfdocument format="PDF" filename="file.pdf" overwrite="Yes"> --->
<!--- 		<cfoutput> #prompt0#  ,
				@year =   #prompt1# ,
				@tenantID = #prompt2#</cfoutput> --->
<!--- <cfsetting enablecfoutputonly="true">
<cfcontent type="application/pdf"> --->
<cfsavecontent variable="PDFhtml">
<cfheader name="Content-Disposition" value="attachment;filename=test.pdf">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->



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
<cfif sp_housetaxinfo.recordcount is 0>
		<cfquery name="qResident" datasource="#application.datasource#">
		Select t.clastname, t.cfirstname from tenant t where t.itenant_id = #prompt2#
		</cfquery> 
<body>
<table width="95%"  cellspacing="2" cellpadding="2" > 
<tr><td><cfoutput>No information found for #qResident.cfirstname# #qResident.clastname# for #prompt1# please recheck your resident ID selection and year</cfoutput></td></tr>
</table>
</body>
<cfelse> 
<body>
<table width="95%"  cellspacing="2" cellpadding="2" > 
	<div>
			<p></p>
			<p></p>
			<p></p>
			<p></p>
	</div>
	<tr> 
		<div>
		<td colspan="4"><cfoutput>#Dateformat(now(),'mm/dd/yyyy')#</cfoutput></td> 
		</div>
	</tr> 
			<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>	
 
	<!--- <td>#iHouse_ID#</td> 
	<td>#iResidencyType_ID#</td>  --->
		<cfoutput query="sp_housetaxinfo"> 
			<cfif cPayerName is "None">
			<tr><div>
				<td colspan="4">Dear #tFullName#,</td>
				</div>
			</tr>
			<cfelse>
			<tr><div>
				<td colspan="4">Dear #cPayerName#,</td>
				</div>
			</tr>
			</cfif>
			<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>	
 
			<tr><div>
				<td colspan="4">The #prompt1# annual invoice total for #tFullName# is listed below:</td>
				</div>
			</tr>
			<div>
			  <p></p>
		  </div>
			<tr><div>
				<td style="text-decoration:underline;text-align:center"><div>Private Room & Board</div></td>
				<td style="text-decoration:underline;text-align:center"><div>Private Resident Care</div></td>
				<td style="text-decoration:underline;text-align:center"><div>Other</div></td>
				<Td style="text-decoration:underline;text-align:center"><div>Total</div></Td>
				</div>
			</tr>
			<p></p>
			<cfset sumtotal =  #privateRB#+#privateCare#+#Other#>
			<tr><div>
				<td style="text-align:center">#dollarformat(privateRB)#</td>
				<td style="text-align:center">#dollarformat(privateCare)#</td>
				<td style="text-align:center">#dollarformat(Other)#</td>
				<td style="text-align:center">#dollarformat(sumtotal)#</td>
				</div>
			</tr>
			<p></p>
			<tr>
				<div>
				<td colspan="4"  style="text-align:center;text-decoration:underline">Total Payments</td>
				</div>
			</tr> 			
			<tr>
				<div>
				<td colspan="4"  style="text-align:center">#dollarformat(Payment)#</td>
				</div>
			</tr> 
			<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>
			<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>			
			<tr>
				<div>
				<td colspan="4"  >Sincerely,</td>
				</div>
			</tr>
 			<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>
						<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>
						<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>
			<tr>
				<td colspan="4" ><div>Executive Director</div></td>
			</tr>
    </cfoutput> 
</table> 
<div><p></p></div>
<div><p></p></div>
<div><p></p></div>
<div><p></p></div>
<div align="center">
<table>
<tr><td>
  
	<cfoutput>ALC Provides this statement of charges invoiced in #prompt1# as a courtesy to its residents and <br />
	family members. ALC does not assume any responsibility, and makes no representation or<br />
	warranty with respect to accuracy of the data contained in this statement. You are responsible<br />
	for your personal tax return and should consult with your tax professional on the utilization<br />
	of any information contained within this document. </cfoutput>	</td></tr> 
</table>
</div>

</body>
</cfif>
</html>
</cfsavecontent>

<cfdocument format="PDF" >
 <cfdocumentitem type="header"></cfdocumentitem>
<!--- <cfdocumentitem type="footer" > 
<div align="center"> <font color="black" size="1" face="Tahoma"> 
	<cfoutput>ALC Provides this statement of charges invoiced in #prompt1# as a courtesy to its residents and <br />
	family members. ALC does not assume any responsibility, and makes no representation or<br />
	warranty with respect to accuracy of the data contained in this statement. You are responsible<br />
	for your personal tax return and should consult with your tax professional on the utilization<br />
	of any information contained within this document. </cfoutput> 
</cfdocumentitem>   
 --->
 
  <cfoutput>
    #variables.PDFhtml#
  </cfoutput>

</cfdocument>
 
