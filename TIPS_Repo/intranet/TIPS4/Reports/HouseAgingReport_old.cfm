<!---  
S Farmer     | 08/27/2014 |   - Aging Report               |
 
 --->
  	<cfparam name="prompt0" default="50">
		<cfquery name="sp_houseAgingReport" datasource="#application.datasource#">
			EXEC rw.sp_AgingReport
				@ihouseID =   '#prompt0#' 
		</cfquery> 		
<cfsavecontent variable="PDFhtml">
	<cfheader name="Content-Disposition" value="attachment;filename=Aging Report-#sp_houseAgingReport.House#.pdf">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Aging Report</title>
	</head>
 
		<cfif sp_houseAgingReport.recordcount is 0>
			<cfquery name="qHouse" datasource="#application.datasource#">
				Select h.cname from house where ihouse_id = #prompt0#
			</cfquery> 

			<body>
			
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<tr> 
						<div><td style="text-align:center">House Aging Report</td> </div>
					</tr> 	
					<tr> 
						<div><td style="text-align:center">&nbsp;</td> </div>
					</tr> 								
					<tr>
						<td><cfoutput>No information found for #qHouse.cname#  please review your selection</cfoutput></td>
					</tr>
				</table>
			</body>
		<cfelse> 
 
			<body>
			<cfoutput  >
				<table width="95%"  cellspacing="2" cellpadding="2" > 
					<tr> 
						<div>
						<td style="text-align:center;  font-size:18px; font-family:"Times New Roman", Times, serif">
						Aging Report for #sp_houseAgingReport.House#
						</td> 
						</div>
					</tr>			
					<tr> 
						<div><td style="text-align:center">&nbsp;</td> </div>
					</tr> 								
					<tr> 
						<div>
						<td   style="text-align:left; font-size:16px; ">Region: #sp_houseAgingReport.Region#</td> 
						</div>
					</tr>
					<tr> 
						<div>
						<td   style="text-align:left; font-size:16px; ">Division: #sp_houseAgingReport.Division#</td> 
						</div>
					</tr>	
					<tr> 
						<div>
						<td   style="text-align:left; font-size:16px; ">Date: #dateformat(now(), 'mm-dd-yyyy')#</td> 
						</div>
					</tr>		
				</table>			
			</cfoutput>
			<table width="95%"  cellspacing="2" cellpadding="2" > 
				<thead>
					<tr>
						<th>Apartment</th>
						<th>Apartment<br /> Type</th>
						<th>Move In <br />Date</th>
						<th>Move Out <br />Date</th>
						<th>BSF<br /> Rate</th>
						<th>Last<br /> Invoice Rate</th>
						<th>Months<br />Empty</th>
					</tr>
				</thead>
				<tbody>
				<cfoutput query="sp_houseAgingReport">
					<div>
						<tr> 
							<td style="text-align:Center">#AptNumber#</td> 							
							<td style="text-align:left"  >#aptDescription#</td> 
							<td style="text-align:right" >#dtmovein#</td> 
							<td style="text-align:right" >#MoveOutDate#</td> 							
							<td style="text-align:right" >#numberformat(BSFRate, 999.99)#</td> 
							<td style="text-align:right" >#numberformat(LastInvoiceRate,999.99)#</td>
							<td style="text-align:right" >#numberformat(daysempty,9999)#</td>  
								
						</tr> 
					</div>	
				</cfoutput>	
				</tbody>
			</table>
		</cfif>

</cfsavecontent>
<!--- <cfsavecontent variable="PDFhtml2">
				<cfoutput>
				<table>
				
				</table>
				</cfoutput>
			 <br /><br /><br /><br /><br />
				<cfoutput>
			<div   style="width:250px;   text-align:center; font-size: medium; border:2px solid; width:100px">For Office Use Only </div>
 		
			<div   style="width:250px;  text-align:center;  background:##CCCCCC; font-size:medium; border:2px solid; width:100px">
			Last Update: #dateformat(now(), "mm/dd/yyyy")# #Timeformat(now(),  "short")# 
			</cfoutput>
 
			</body>
			</html>	
</cfsavecontent> --->			
<cfdocument format="PDF" orientation="portrait" margintop="1" >	
	<cfdocumentsection>
	<cfdocumentitem type="header">
		<div  style="text-align:center; "></div>
	</cfdocumentitem>

	<cfoutput>
		#variables.PDFhtml#
<!---   <cfdocumentitem type="pagebreak" > </cfdocumentitem>	  --->
<!--- 		#variables.PDFhtml2# --->	
	</cfoutput>

 	<cfdocumentitem  type="footer">
		<cfoutput>
			<div style="text-align:center;font-size:11px;">Page: #cfdocument.currentpagenumber#</div>
		</cfoutput>
	</cfdocumentitem>
	</cfdocumentsection>
</cfdocument>
 
