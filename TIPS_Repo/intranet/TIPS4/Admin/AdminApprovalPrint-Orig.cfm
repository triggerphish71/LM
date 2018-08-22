<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>AdminApprovalPrint</title>
</head>
<!---    <cfoutput><cfdump var="#form#"></cfoutput> --->
 
<body>
	<cfoutput>	 
  
 	<CFSET rowlist=''>
	<CFLOOP INDEX=A LIST='#form.fieldnames#'>
		<CFSCRIPT>
			if (findnocase("row_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
		</CFSCRIPT>
	</CFLOOP>
 	 #rowlist#  #findnocase("row_",A,1)# A #A# form.fieldnames #form.fieldnames#<BR>
	test 
	<cfset Occurrences  = REFindNoCase(#form.fieldnames#,'ROW_',1,true) >

<!---      <cfoutput><cfdump var="#form.fieldnames#"><br />#Occurrences#</cfoutput>
 <cfabort>  --->   
			 <cfdocument  format="PDF" orientation="landscape" margintop="1" marginbottom="1" marginleft=".5" marginright=".5">
				<cfdocumentitem type="header"  evalAtPrint="true">   
					 
						<table width="100%">
							<tr>
								<td style="text-align:left;"> <img src="../images/Enlivant_logo.jpg" width="115" height="75" ></td>
								<td align="center">
									<h3 style="text-align:center;">Approved Selected BSF and Care Changes</h3>
								</td>
								<td  nowrap="nowrap" style="text-align:right;">Date: <br />#dateformat(now(),'mm/dd/yyyy')#</td>
							</tr>
						</table>
					 
				 
					<table width="100%" >
						<tr> 
							<th style="width:6%;" >Division</th>
							<th style="width:11%;">Region</th>
							<th style="width:15%;">Community</th>
							<th style="width:15%;">Resident</th>
							<th style="width:8%;" >SolomonID</th>
							<th style="width:10%;">Description</th>
							<th style="width:7%;" >Action</th>
							<th style="width:10%;">New Amount</th>
							<th style="width:10%;">Comments</th>
							<th style="width:8%;" >Acct Period</th>
						</tr>
					</table>
			 </cfdocumentitem>  
				<table width="100%" >
			 
				<!--- <cfloop   from="1" to="#row#"  index="B"> --->
		 <CFLOOP INDEX=B LIST='#rowlist#'>
						<tr>	 
							<td style="text-align:center; font-size:10px;width:6%;">#evaluate("cDivision_" & B)#</td>
							<td style="text-align:center; font-size:10px;width:11%;">#evaluate("cRegion_" & B)#</td>
							<td style="text-align:left; font-size:10px;width:15%;">#evaluate("House_" & B)#</td>
							<td style="text-align:left; font-size:10px;width:15%;">#evaluate("cTenantName_" & B)#</td>
							<td style="text-align:left; font-size:10px;width:8%;">#evaluate("cSolomonKey_" & B)#</td>
							<td style="text-align:left; font-size:10px;width:10%;">#evaluate("description_" & B)#</td>
							<td style="text-align:center; font-size:10px;width:7%;">#evaluate("Action_" & B)#</td>
							<td style="text-align:right;font-size:10px;width:10%;">#LSCurrencyFormat(evaluate("newamount_" & B))#</td>
							<td style="text-align:right; font-size:10px;width:10%;">#evaluate("comments_" & B)#</td>
							<td style="text-align:right; font-size:10px;width:8%;">#evaluate("cappliestoacctperiod_" & B)#</td>				
						</tr>
				  </CFLOOP> 
	 
				</table>	
			 	<cfdocumentitem type="footer"  evalAtPrint="true">  
			 		<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>  
						<table width="100%">
						<tr>
							<td>Approved Selected BSF and Care Changes</td>
							<td style="text-align:center">Enlivant</td>
							<td style="text-align:right">Page  #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#  </td>
						</tr>
						</table>
 					<cfelse>
						<table width="100%">
						<tr>
							<td>Approved Selected BSF and Care Changes</td>
							<td a style="text-align:center">Enlivant</td>
							<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
						</tr>
						</table>		
					</cfif>  
 				</cfdocumentitem>
				<cfheader name="Content-Disposition"   
					value="attachment;filename=ApprovedSelectedBSFandCareChanges-#Now()#.pdf"> 
			</cfdocument>  
		</CFOUTPUT>
	</body>
</html>
