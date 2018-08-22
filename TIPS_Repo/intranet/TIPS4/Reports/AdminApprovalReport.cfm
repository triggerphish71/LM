<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<CFOUTPUT>
<CFSET rowlist=''>
<CFLOOP INDEX=A LIST='#form.fieldnames#'>
	<CFSCRIPT>
		if (findnocase("row_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
	</CFSCRIPT>
</CFLOOP>
<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="1" marginleft=".5" marginright=".5">
	<cfdocumentitem type="header"  evalAtPrint="true">  
		<cfoutput>
			<table width="100%">
				<tr>
					<td style="text-align:left;"> <img src="../../images/Enlivant_logo.jpg"></td>
					<td align="center">
						<h3 style="text-align:center;">Approve Selected BSF and Care Changes</h3>
					</td>
					<td  nowrap="nowrap" style="text-align:right;">Date: <br />#dateformat(now(),'mm/dd/yyyy')#</td>
				</tr>
			</table>
		</cfoutput>
	</cfdocumentitem>
		<table width="100%" cellpadding="1" cellspacing="1">
			<TR>
			<TH NOWRAP STYLE="text-align:left;"> Trx </TH>
			<TH NOWRAP STYLE="text-align:left;">Community</TH>			
			<TH NOWRAP STYLE="text-align:left;">Resident</TH>
			<TH NOWRAP STYLE="text-align:left;">Sol. Key</TH>
			<TH NOWRAP STYLE="text-align:left;">Description</TH>
			<TH NOWRAP STYLE="text-align:left;">Old Amt</TH>
			<TH NOWRAP STYLE="text-align:left;">New Amt</TH>
			<TH NOWRAP STYLE="text-align:left;">Period</TH>
			<TH NOWRAP STYLE="text-align:left;">Action</TH>
		</TR>
		<cfdocumentitem type="footer"  evalAtPrint="true">
			<cfoutput>
 		<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
 
	<table width="100%" style="border-bottom:2px solid black;border-top:2px solid black;">
		<tr>
			<td><h2>Final Customer Balance for: </h2></td>
			<td><h2>#trim(spCustTrialBal.Name)#<br />
			 Resident ID Nbr.: #spCustTrialBal.Custid#</h2></td>
			 <td><h2>=<br />&nbsp;</h2></td>
			 <td><h2>#dollarformat(runningbalance)# *<br /> as of #dateformat(now(),'mmmm dd, yyyy')#</h2></td>
		</tr>		
	</table>
 
		<table width="100%">

			<tr>
				<td>Approve Selected BSF and Care Changes</td>
				<td style="text-align:center">Enlivant</td>
				<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
		</table>
		<cfelse>
		<table width="100%">
			<tr>
				<td>Approve Selected BSF and Care Changes</td>
				<td a style="text-align:center">Enlivant</td>
				<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
		</table>		
		</cfif>
		</cfoutput>
	</cfdocumentitem>
	<cfoutput>
	<cfheader name="Content-Disposition"   
		value="attachment;filename=ApproveSelectedBSFandCareChanges-#Now()#.pdf"> 
	</cfoutput>		
</cfdocument>
</body>
</html>
