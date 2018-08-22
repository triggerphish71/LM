<!---  
 ANALYST     |  DATE      | Description                          |
 ------------ ------------ --------------------------------------|
S Farmer     | 08/27/2014 | 120077  - Aging Report               |
S Farmer     | 04/24/2017 | last occupied date revised to look   |
             |            | at room transfers                    |
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
						<td style="text-align:center">House Aging Report</td> 
					</tr> 	
					<tr> 
						<td style="text-align:center">&nbsp;</td> 
					</tr> 								
					<tr>
						<td><cfoutput>No information found for #qHouse.cname#  please review your selection</cfoutput></td>
					</tr>
				</table>
			</body>
		<cfelse> 
 
			<body>

		</cfif>

</cfsavecontent>
 		
<cfdocument format="PDF" orientation="portrait" margintop="1" >	
	<cfdocumentsection>
		<cfdocumentitem type="header" >
			<cfoutput  >
 
			<h1 style="font-family: Arial, Helvetica, sans-serif; font-size:60px; text-align:center; font-weight:bolder">
			Aging Report for #sp_houseAgingReport.House# 
			</h1>
				<table width="95%"  cellspacing="2" cellpadding="2"  > 
					<tr> 
						<td style="text-align:center; font-family: Arial, Helvetica, sans-serif; font-size:40px">&nbsp;</td> 
					</tr> 								
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:40px">
						Region: #sp_houseAgingReport.Region#</td> 
					</tr>
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:40px ">
						Division: #sp_houseAgingReport.Division#</td> 
					</tr>	
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:40px  ">
						Date: #dateformat(now(), 'mm-dd-yyyy')#</td> 
					</tr>		
				</table>
	
 
			<table width="95%"  cellspacing="2" cellpadding="2"   > 
				  <thead> 
					<tr>
						<th style="width=15%; text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:40px;font-weight:bold">
						Apartment Number
						</th>  
					 
						<th style="width=15%;text-align:center;font-family: Arial, Helvetica, sans-serif;font-size:40px;font-weight:bold">
						Apartment Type
						</th> 
					 
<!--- 						<th style="width=15%; text-align:right;font-family: Arial, Helvetica, sans-serif;font-size:40px;font-weight:bold">
						Move In Date
						</th>  --->
						<th style="width=15%;text-align:right;font-family: Arial, Helvetica, sans-serif;font-size:40px;font-weight:bold">
						Months Vacant
						</th>				 
						<th style="width=15%;text-align:right;font-family: Arial, Helvetica, sans-serif;font-size:40px; font-weight:bold">
						Last Occupied Date<br />(Blank=Occupied)
						</th> 
					 
						<th style="width=15%;text-align:right;font-family: Arial, Helvetica, sans-serif;font-size:40px;font-weight:bold">
						Current BSF Rate
						</th> 
					 
<!--- 						<th style="width=15%;text-align:right;font-family: Arial, Helvetica, sans-serif;font-size:40px;font-weight:bold">
						Last Invoice Rate
						</th>  --->
				 

					</tr>
				  </thead>  	
			</table>	
 			</cfoutput>	
		</cfdocumentitem>
			<table width="95%"  cellspacing="2" cellpadding="2"  > 
				<tbody>
					<cfoutput query="sp_houseAgingReport">
						<tr>  
							<td style="text-align:Center;width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							#AptNumber#
							</td> 							
							<td style="text-align:left;  width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							#aptDescription#
							</td> 
							<td style="text-align:right; width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							#numberformat(daysempty,9999)#
							</td>  
<!--- 							<td style="text-align:right; width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							#dateformat(dtmovein, 'mm/dd/yyyy')#
							</td>  --->
							<td style="text-align:right; width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							<cfif TransferDate is not ''>#dateformat(TransferDate, 'mm/dd/yyyy')#
							<cfelse>#dateformat(MoveOutDate, 'mm/dd/yyyy')#
							</cfif>
							</td> 	
						
							<td style="text-align:right; width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							#numberformat(BSFRate, 999.99)#
							</td> 
<!--- 							<td style="text-align:right; width=15%;font-family: Arial, Helvetica, sans-serif; font-size:10px">
							#numberformat(LastInvoiceRate,999.99)#
							</td> --->

						</tr> 
					</cfoutput>	
				</tbody>
			</table>
		<cfdocumentitem  type="footer">
			<cfoutput>
				<div style="text-align:center;font-size:11px;">Page: #cfdocument.currentpagenumber#
			</cfoutput>
		</cfdocumentitem>
	</cfdocumentsection>
</cfdocument>
 
