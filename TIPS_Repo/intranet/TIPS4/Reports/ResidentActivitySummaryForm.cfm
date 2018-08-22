 
 
<cfsavecontent variable="PDFhtml">
	<cfheader name="Content-Disposition" value="attachment;filename=test.pdf">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	
	
	
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Resident Activity Summary</title>
	</head>
	<cfquery name="ALD" datasource="#application.datasource#">
		EXEC rw.sp_ActivityLog_Detail
			@iTenant_ID =   '#prompt0#' ,
			@cPeriod =   ''  
	</cfquery> 
		<cfif ALD.recordcount is 0>
			<cfquery name="qResident" datasource="#application.datasource#">
				Select t.clastname, t.cfirstname , t.csolomonkey from tenant t where t.itenant_id = #prompt0#
			</cfquery> 
			<body>
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<tr> 
						<div><td style="text-align:center">Resident Activity Summary</td> </div>
					</tr> 				
					<tr>
						<td><cfoutput>No information found for #qResident.cfirstname# #qResident.clastname#, Resident ID #t.csolomonkey# please review your selection</cfoutput></td>
					</tr>
				</table>
			</body>
		<cfelse> 
			<body>
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<cfoutput query="ALD" group="cSolomonKey" >
<!--- 						<tr> 
							<div>
							<td colspan="8" style="text-align:center; font-size:14px; font-weight:bold; text-decoration:underline">Resident Activity Summary</td> 
							</div>
						</tr> 
						<tr> 
							<div>
							<td colspan="8" style="text-align:center">#ctenantname#</td> 
							</div>
						</tr> 
						<tr> 
							<div>
							<td colspan="8" style="text-align:center">#csolomonkey#</td> 
							</div>
						</tr>	
						<tr> 
							<div>
							<td colspan="8" style="text-align:center">#cHouseName#</td> 
							</div>
						</tr> --->		
						<cfoutput>
							<tr> 
								<div>
								<td colspan="8" style="text-align:left; font-weight:bold">Invoice Period: #cappliestoacctperiod#</td> 
								</div>
							</tr> 
							<tr>
								<div>
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Effective</div></td>
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Entered</div></td>
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Activity</div></td>
								<Td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Old Apt Nbr</div></Td>
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>New Apt Nbr</div></td>
								<!--- <Td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Old Room and Board Rate</div></Td> --->				
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Room and Board Rate</div></td>
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Old Points</div></td>
								<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>New Points</div></td>

							<!---	<td style="text-decoration:underline;text-align:center;font-size:smaller"><div>Old  Set/LOC Level</div></td>  --->
								<Td style="text-decoration:underline;text-align:center;font-size:smaller"><div><!---New  Set/ --->LOC Rate</div></Td>
								</div>
							</tr>
							<tr><div>
								<td >#dateformat(dtactualeffective, 'mm/dd/yyyy')#</td>
								</div>
								<div>
								<td >#dateformat(dtRowStart, 'mm/dd/yyyy')#</td>
								</div>
								<div>
								<td   >#cdescription#</td>
								</div>
								<div>
								<td >#coldaptnumber#</td>
								</div>
								<div>
								<td style="text-align:center">#cnewaptnumber#</td>
								</div>
<!--- 								<div>
									<td   style="text-align:center"><!--- #coldsleveltypeset#/ --->#ioldservicelevel#/#dollarformat(OldStandardRent)#</td>
								</div> --->
								<div>
								<td   style="text-align:left" ><!--- #cnewsleveltypeset#/#inewservicelevel#/ --->#dollarformat(OldStandardRent)#</td>
								</div>			
								<div>					
								<td style="text-align:center">#ioldspoints#</td>
								</div>
								<div>
								<td style="text-align:center">#inewspoints#</td>
							 <!---	<td style="text-align:center">#dollarformat(moldservicelevelamt)# (oldstandardrent)# </td> --->
								</div>
								<div>
								<td   >#dollarformat(mnewservicelevelamt)# <!--- newstandardrent)# ---></td>
								</div>

							</tr>
							<tr>
								<div>
								<td colspan="8"  >&nbsp;</td>
								</div>
							</tr>
						</cfoutput> 
					</cfoutput>
				</table> 
				<div align="center">
					<table>
					<tr>
						<td style="text-align:center">
							<cfoutput>Use only as authoried by Enlivant</cfoutput>	
						</td>
					</tr> 
					</table>
				</div>
			</body>
		</cfif>
	</html>
</cfsavecontent>

<cfdocument format="PDF"  orientation="landscape" margintop="1" >
	<cfdocumentitem type="header">
		<cfoutput query="ALD" maxrows="1"> 
			<div style="text-align:center; font-size:large; font-weight:bold; text-decoration:underline">Resident Activity Summary</div>
			<div style="text-align:center; font-size:large;">#ctenantname#</div>
			<div style="text-align:center; font-size:large;">Resident ID: #csolomonkey#</div>
			<div style="text-align:center; font-size:large;">#cHouseName#</div>
		</cfoutput>	
	</cfdocumentitem>
	<cfoutput>
		#variables.PDFhtml#
	</cfoutput>
 	<cfdocumentitem type="footer">
		<cfoutput>
			<div  style="text-align:center; font-size:large">Use only as authoried by Enlivant</div>
			<div style="text-align:center; font-size:11px;">Printed: #dateformat(now(), "mm/dd/yyyy")# #Timeformat(now(),  "short")#</div>
			<div style="text-align:right;font-size:11px;">Page: #cfdocument.currentpagenumber#</div>
		</cfoutput>
	</cfdocumentitem>
</cfdocument>
 
