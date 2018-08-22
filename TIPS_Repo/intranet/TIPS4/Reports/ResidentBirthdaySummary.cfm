
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html xmlns="http://www.w3.org/1999/xhtml"> 
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<title>Resident Birthday Summary</title>
		</head>
		<body>	 
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID,H.cName, H.cNumber,h.caddressLine1, h.caddressline2
	, h.ccity, h.cstatecode, h.czipcode, h.cnumber
	,h.cPhoneNumber1
	, OA.cNumber as OPS, R.cNumber as Region
	,hl.dtCurrentTipsmonth
	FROM	House H
	Join 	Houselog hl on h.ihouse_id = hl.ihouse_id
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	
	
		<cfparam  name="prompt0" default="">
		<cfif prompt0 is ''>
			<cfset prompt0 = HouseData.cnumber>
		</cfif>
	
		<cfoutput>
			<cfquery name="sp_TenantAges" datasource="#application.datasource#">
				EXEC rw.sp_TenantAges
					@HouseNumber =   '#prompt0#'  
			</cfquery> 
		</cfoutput>
 
		<cfsavecontent variable="PDFHDR">
			<cfoutput>
			 <table width="100%"  cellspacing="0" cellpadding="0" > 
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td>&nbsp;</td>					
				</tr>
				<!---<tr>
					<td><h2>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
					</h2></td>
					<td>&nbsp;</td>	
				</tr>--->
				<tr>					 
					 <td colspan="2"><h1 style="text-align:center">BIRTHDAY SUMMARY</h1> </td>
				</tr>
				<tr>
					 <td>&nbsp;</td>
							
				</tr>
				 <tr>
					 <td colspan="2"><h2  style="text-align:center">
						#sp_TenantAges.cname# - #sp_TenantAges.cnumber#</h2>
					 </td>
				 </tr>
				 <tr>
					 <td>&nbsp;</td>
				</tr>
			 </table> 
			  <table width="100%"  cellspacing="0" cellpadding="0"  > 
				<tr>
					<td width="10px" style="text-align:center;border-bottom:1px solid black;"><h2>Apartment</h2></td>
					<td style="text-align:left;border-bottom:1px solid black;"><h2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SolomonKey</h2></td>
					<td style="text-align:left;border-bottom:1px solid black;"><h2>Resident's Name</h2></td>
					<td style="text-align:center;border-bottom:1px solid black;"><h2>Birthday</h2></td>
					<td style="text-align:center;border-bottom:1px solid black;"><h2>Age</h2></td>
			</table>
			 
			</cfoutput>
		</cfsavecontent>	 
		<cfsavecontent variable="PDFhtml">
					
				  <table width="100%"  cellspacing="2" cellpadding="0"    > 
					<cfoutput>
						
						<cfloop query="sp_TenantAges"> 
							<tr> 
								<td style="text-align:center;">#cAptNumber#</td>
								<td style="text-align:center;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#cSolomonkey#</td>
								<td style="text-align:left;">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#cfirstname# #clastname#</td>
								<td style="text-align:left;">#dateformat(dBirthdate, 'mm/dd/yyyy')#</td>
								<td style="text-align:center;">#Age#</td>				
								 
							</tr>
						</cfloop> 
					</cfoutput>
				</table> 
		</cfsavecontent>

		<cfdocument format="PDF"  orientation="portrait" margintop="2" marginbottom="1">
<cfheader name="Content-Disposition" 
value="attachment;filename=ResidentBirthdaySummary-#HouseData.cname#-#dateformat(now(), 'mm/dd/yyyy')#.pdf">		
			<cfdocumentitem type="header" evalAtPrint="true">
			<cfoutput>
				#variables.PDFHDR#
			</cfoutput>
			</cfdocumentitem>
			<cfoutput>
				#variables.PDFhtml#
			</cfoutput>
			<cfdocumentitem  type="footer"  evalAtPrint="true">
				<cfoutput>
					<table  width="95%">
						<!---<tr>
							<td colspan="3" style="font-size:small;text-align:right">
							Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
							</td>
						</tr>
						<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>--->
							<tr>
								<td style="font-size:small; text-align:left" >BirthdaySummaryReport</td>
								<td style="font-size:small; text-align:center">
								Use only as authorized by Enlivant&trade;
								</td>
								<td colspan="3" style="font-size:small;text-align:right">
							    Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
						    	</td>
						    </tr>
						    <tr>
								<td colspan="5" style="font-size:small; text-align:right">
								Printed: #dateformat(now(), 'mm/dd/yyyy')#
								</td>
							</tr> 
						<!---</cfif>--->			
					</table>		
				</cfoutput>
			</cfdocumentitem>
		</cfdocument>
	</body>
</html>	 
