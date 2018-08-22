<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>CustomerTrialBalanceReport</title>
</head>
<cfparam  name="prompt0" default="">

<cfoutput>
	<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
		SELECT	H.cNumber
		, h.caddressline1
		, h.ccity
		, h.cstatecode
		,h.czipcode
		, h.cname
		,h.cphonenumber1
		, OA.cNumber as OPS
		, R.cNumber as Region
		FROM	House H
		JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
		JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
		WHERE	H.dtRowDeleted IS NULL	
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	</CFQUERY>
	<cfquery name="spCustTrialBal" datasource="Solomon-Houses">
		EXEC dbo.zsp_CustomerTrialBalance
		@CustID = N'#prompt0#'
	</cfquery> 	
</cfoutput>		
<body>
<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="1" marginleft=".5" marginright=".5">
	<cfdocumentitem type="header"  evalAtPrint="true">  
		<cfoutput>
			<table width="100%">
				<tr>
					<td style="text-align:left;"> <img src="../../images/Enlivant_logo.jpg"/ width="115" height="75" ></td>
					<td align="center">
						<h3 style="text-align:center;">
						Enlivant<br />Customer Accounting Activity Report
						</h3>
					</td>
					<td  nowrap="nowrap" style="text-align:right;">
					 
					Report Print Date: <br />#dateformat(now(),'mm/dd/yyyy')#
					 </td>
				</tr>
			</table>
		</cfoutput>
	</cfdocumentitem>
	<cfoutput>
	<table width="100%" style="border-top: 1px solid black; border-bottom: 1px solid black;">
		<tr>
			<td colspan="2">Resident Name: #trim(spCustTrialBal.Name)#</td>
		</tr>
		<tr>
			<td>Resident ID Nbr.: #spCustTrialBal.Custid#</td>
			<td>#HouseData.cname#</td>
		</tr>
	</table>
	</cfoutput>	
	<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td>&nbsp;</td>
			<td style="border-bottom:.5px solid black; font-size:10px; font-weight:bold;">Invoice Nbr.</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">Amount</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">Transaction</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">Date</td>
			<td style="border-bottom:.5px solid black;font-size:10px; font-weight:bold;">Description</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
		</tr>
		<cfset runningbalance = 0>
		<cfoutput query ="spCustTrialBal"  group="sortdate">
				<cfset monthamount = 0>
		<cfoutput>
		<tr>
			<td>&nbsp;</td>
			<td style="font-size:10px;">#User1#</td>
			<cfif DocType is  'pa' or DocType is 'cm' or DocType is 'sb'>
				<cfset mamount =  #OrigDocAmt# *-1>
			<cfelse>
				<cfset mamount =  #OrigDocAmt# *1> 
			</cfif>
			<cfif  DocType is  'in'><td style="text-align:right;font-size:10px; color:##0066FF;">#dollarformat(mamount)#</td>
			<cfelseif DocType is  'pa'><td style="text-align:right;font-size:10px; color:##FF0000;">#dollarformat(mamount)#</td>
			<cfelseif DocType is  'dm'><td style="text-align:right;font-size:10px; color:##0066FF;">#dollarformat(mamount)#</td>
			<cfelseif DocType is 'cm'><td style="text-align:right;font-size:10px; color:##009933;">#dollarformat(mamount)#</td>
			</cfif> 
			
			<td style="font-size:10px;"><cfif  DocType is  'in'>Invoice
			<cfelseif DocType is  'pa'>Payment-Chk Nbr. RefNbr
			<cfelseif DocType is  'dm'>Debit Memo
			<cfelseif DocType is 'cm'>Credit Memo</cfif></td>
			<td style="font-size:10px;">#dateformat(DocDate,'mm/dd/yyyy')#</td>
			<td style="font-size:10px;">#DocDesc#</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>			
		</tr>	
				<cfset monthamount = monthamount + mamount>
				<cfset runningbalance = runningbalance  + mamount>
			</cfoutput>		
			
		<tr style="border-bottom:.5px solid black;">	
			<td style="font-size:10px;font-weight:bold;">#dateformat(docdate,'mm/yyyy')#</td>
			<td style="font-size:10px;font-weight:bold;">EOM Balance:</td>
			<td style="font-size:10px;font-weight:bold;;border-top:.5px solid black;">#dollarformat(monthamount)#</td>
			<td style="">&nbsp;</td>
			<td style="">&nbsp;</td>
			<td style="">&nbsp;</td>
			<td style="font-size:10px;font-weight:bold;">Ending Balance:</td>
			<cfif runningbalance lt 0>
			<td style="font-size:10px;font-weight:bold; color:##FF0000">#dollarformat(runningbalance)#</td>
			<cfelse>
			<td style="font-size:10px;font-weight:bold;">#dollarformat(runningbalance)#</td>
			</cfif>
		</tr>
		<tr>
			<td colspan="8"><hr width="100%" /></td>
		</tr>
		</cfoutput>	
	</table>

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
				<td colspan="3"  style="font-style:italic; color:##006699; text-align:center;"><h2>* This report is intended for internal review purposes only and no quarantees are made regarding the accuracy of the information contained herein. All balances are subjuct to final review by Enlivant Accounting and may not reflect final balance of a given tenant</h2></td>
			</tr>
			<tr>
				<td>Customer Accounting Activity Report</td>
				<td style="text-align:center">Enlivant</td>
				<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
		</table>
		<cfelse>
		<table width="100%">
			<tr>
				<td>Customer Accounting Activity Report</td>
				<td a style="text-align:center">Enlivant</td>
				<td style="text-align:right">Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
		</table>		
		</cfif>
		</cfoutput>
	</cfdocumentitem>
	<cfoutput>
	<cfheader name="Content-Disposition"   
		value="attachment;filename=CustomerTrialBalanceReport-#HouseData.cname#-#trim(spCustTrialBal.Name)#.pdf"> 
	</cfoutput>		
</cfdocument>			
</body>
</html>
