<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports             |
|SFarmer     |04/12/2015  | changed Houses_APP.dbo.XBANKINFO to left join, isn't used for newer houses  |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Customer Accounting Activity Report</title>
</head>
<style>
hr { 
    display: block;
    margin-top: 0.5em;
    margin-bottom: 0.5em;
    margin-left: auto;
    margin-right: auto;
    border-style: inset;
    border-width: 1px;
} 

Th {
 text-decoration: underline;
}
</style>
<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID,H.cName, H.cNumber,h.caddressLine1, h.caddressline2
	, h.ccity, h.cstatecode, h.czipcode
	,h.cPhoneNumber1
	, OA.cNumber as OPS, R.cNumber as Region
	,hl.dtCurrentTipsmonth
	FROM	House H
	Join 	Houselog hl on h.ihouse_id = hl.ihouse_id
	JOIN	OPSArea OA ON OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R ON OA.iRegion_ID = R.iRegion_ID
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>
<cfparam name="prompt0" default="">
<cfquery name="qryActivity" DATASOURCE="houses_App">
<!--- EXEC	 dbprod02.houses_App.dbo.zsp_CustomerTrialBalance
		@CustID = '#prompt1#' --->
	SELECT	
	ARDoc.CustId, 
	ARDoc.DocDate, 
	ARDoc.DocDesc, 
	ARDoc.DocType, 
	ARDoc.OrigDocAmt, 
	ARDoc.RefNbr, 
	ARDoc.Rlsed,
	Customer.Name,
	XBANKINFO.CnyName,
	ARDoc.User7 User7,
	ARDoc.User1,
 left(convert(varchar(10),ARDoc.DocDate,101),2)+'/'+right(convert(varchar(10),ARDoc.DocDate,101),4) as tranperiod 
  , right(convert(varchar(10),ARDoc.DocDate,101),4)+left(convert(varchar(10),ARDoc.DocDate,101),2)  as sortperiod	
FROM	ARDoc 
JOIN 	Customer 
ON	ARDoc.CustId = Customer.CustId
left JOIN 	Houses_APP.dbo.XBANKINFO XBANKINFO
ON	Customer.ArSub = XBANKINFO.SubAcct
and XBANKINFO.Acct = '1038'
WHERE	ARDoc.CustId = '#prompt0#' 
AND	ARDoc.Rlsed = 1
<!---UNION ALL
SELECT	
	a2.CustId, 
	a2.DocDate, 
	a2.DocDesc, 
	a2.DocType, 
	a2.OrigDocAmt, 
	a2.RefNbr, 
	a2.Rlsed,
	c2.Name,
	x2.CnyName,
	a2.User7 User7,
	a2.User1,
 left(convert(varchar(10),a2.DocDate,101),2)+'/'+right(convert(varchar(10),a2.DocDate,101),4) as tranperiod	
 , right(convert(varchar(10),a2.DocDate,101),4)+left(convert(varchar(10),a2.DocDate,101),2)  as sortperiod	
FROM	HousesArchive.dbo.ARDoc a2
JOIN 	HousesArchive.dbo.Customer c2
ON	a2.CustId = c2.CustId
left JOIN 	Houses_APP.dbo.XBANKINFO x2
ON	c2.ArSub = x2.SubAcct
and x2.Acct = '1038'
WHERE	a2.CustId  = '#prompt0#' 
AND	a2.Rlsed = 1	--->
order by sortperiod asc, user7
</cfquery>
 	
	<cfquery name="LateFeeBalance" DATASOURCE = "#APPLICATION.datasource#">
		EXEC rw.sp_gettenantlatefee @solomonkey='#prompt0#' 
	</cfquery>
	<cfquery name="PaidLateFee" DATASOURCE = "#APPLICATION.datasource#">
		EXEC rw.sp_GetHistoricalPaidTenantLateFee @solomonkey='#prompt0#' 
	</cfquery>
	<cfquery name="SumPaidLateFee" dbtype="query" >
	select sum(mLateFeeAmount) sumLateFeeAmount from PaidLateFee
	</cfquery>

<body>



<cfdocument  format="PDF"  orientation="portrait" margintop="2" marginbottom="1" marginleft=".2" marginright=".2">
	<cfdocumentitem type="header"  evalAtPrint="true">  
<style>
hr { 
    display: block;
    margin-top: 0.5em;
    margin-bottom: 0.5em;
    margin-left: auto;
    margin-right: auto;
    border-style: inset;
    border-width: 1px;
} 

Th {
 border-bottom: 1px solid black;
}
</style>
		<cfoutput>
			<table width="100%"  >
				<tr>
					<td   style="text-align:left;"> 
					<img src="../../images/Enlivant_logo.jpg"/ >
					<!--- <br /><h2>#HouseData.cname#    <br />
						#HouseData.Caddressline1#    <br />
						#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    
<br />(#left(Housedata.cphonenumber1,3)#) #mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
						</h2> ---></td>
					<td align="center">
						<h1 style="text-align:center; text-decoration:underline;">
						Enlivant<br />Customer Accounting Activity Report
						</h1>
					</td>
					<td><h2>Report Print Date:<br /> #dateformat(now(),'mm/dd/yyyy')#</h2></td>					
				</tr>		
 	
				<tr >
					<td colspan="3" style="border-top: 1px solid black; text-align:center;font-size:12px">
					<h1>Resident Name: #qryActivity.Name#</h1>
					</td>
				</tr>
				<tr >
					<td colspan="3" style="border-bottom: 1px solid black; text-align:center;font-size:12px">
					<h1>ID: #qryActivity.CustID#  -   #HouseData.cname#    </h1>
					</td>
				</tr>	
 			
			</table>
			<table width="100%" >
		<colgroup>
			<col span="1" style="width: 11%;">    <!--- tran period --->
			<col span="1" style="width: 11%;">    <!--- invoice nbr --->
			<col span="1" style="width: 12%;">  <!--- amount --->
			<col span="1" style="width: 17%;">    <!--- transaction --->
			<col span="1" style="width: 11%;">  <!--- date --->
			<col span="1" style="width: 19%;">  <!--- description --->
			<col span="1" style="width: 10%;">    <!--- trandate --->
			<col span="1" style="width: 9%;">  <!--- total ---> 		
		</colgroup>			
		<tr>
			<th style="border-bottom: 1px solid black;"><h2>Tran Period</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>Invoice Nbr.</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>Amount</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>Transaction</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>Date</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>Description</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>TranDate</h2></th>
			<th style="border-bottom: 1px solid black;"><h2>Total</h2></th>
		</tr>
		</table>
</cfoutput>
</cfdocumentitem>
<cfset activitytotal = 0>
	<table width="100%"  cellpadding="1" cellspacing="1" border="0">
		<cfoutput query="qryactivity" group="tranperiod" >
		<colgroup>
			<col span="1" style="width: 11%;">    <!--- tran period --->
			<col span="1" style="width: 11%;">    <!--- invoice nbr --->
			<col span="1" style="width: 12%;">  <!--- amount --->
			<col span="1" style="width: 17%;">    <!--- transaction --->
			<col span="1" style="width: 11%;">  <!--- date --->
			<col span="1" style="width: 19%;">  <!--- description --->
			<col span="1" style="width: 10%;">    <!--- trandate --->
			<col span="1" style="width: 9%;">  <!--- total ---> 		
		</colgroup>
		<cfset monthlytotal = 0>
		<tr style="line-height:75%">
			<td colspan="1" style="font-weight:bold;font-size:10px">#tranperiod# </td>
			<td colspan="7">&nbsp;</td>
		</tr>
	
		<cfoutput>
			<tr style="line-height:75%">
				<td>&nbsp;</td> 
				<td style="font-size:10px">#User1#</td>
				<cfif doctype is 'pa'><cfset thisOrigDocAmt =  OrigDocAmt  * -1>
				<cfelseif doctype is 'cm'> <cfset thisOrigDocAmt =  OrigDocAmt  * -1>
				<cfelseif  doctype is 'sb'> <cfset thisOrigDocAmt =  OrigDocAmt  * -1>
				<cfelse><cfset thisOrigDocAmt =  OrigDocAmt></cfif>
				<cfset activitytotal =activitytotal + thisOrigDocAmt>
				<cfset monthlytotal = thisOrigDocAmt + monthlytotal> 
				<td style="text-align:right;font-size:10px">#numberformat(thisOrigDocAmt,'-___,___.99')#</td>
				<td style="text-align:left;font-size:10px">
					<cfif DocType  is 'in' >Invoice
					<cfelseif DocType is 'pa' >Payment-Chk ## #RefNbr#   
					<cfelseif DocType is 'dm' >Debit Memo  
					<cfelseif DocType is 'cm' >Credit Memo</cfif>
				</td>
				<td style="font-size:10px">#dateformat(DocDate,'mm/dd/yy')#</td>
				<td style="text-align:left;font-size:10px">#DocDesc#</td>
				<td style="font-size:10px">#dateformat(user7,'mm/dd/yyyy')#</td>
				<td style="font-size:10px;text-align:right;">$#numberformat(activitytotal,'-___,___.99')#</td>
			</tr>
		</cfoutput>
			<tr>
				<td style="font-weight:bold;font-size:10px">#tranperiod#</td>
				<td nowrap="nowrap" style="font-weight:bold;font-size:10px; ">EOM Balance:</td>
				<td style="font-weight:bold;text-align:right;font-size:10px;border-top: 1px solid black;">
				$#numberformat(monthlytotal,'-___,___.99')#</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp; </td>
				<td nowrap="nowrap" style="font-weight:bold;font-size:10px">Ending Balance:</td>
				<td style="font-weight:bold;font-size:10px;text-align:right;">
				$#numberformat(activitytotal,'-___,___.99')#</td> 
			</tr>
			<tr>
				<td colspan="8"><hr /></td>
			</tr>
		</cfoutput>
		<cfoutput>
			<tr>
				<td colspan="3" style="text-align:left;font-size:11px; font-weight:bold">Final Customer Balance for:</td>
				<td  style="text-align:right;font-size:11px; font-weight:bold">#qryActivity.Name#</td>				
				<td colspan="2">&nbsp;</td>
				<td style="text-align:right;font-size:11px; font-weight:bold">=</td>
				<td style="font-size:12px; font-weight:bold;text-align:right;">
				$#numberformat(activitytotal,'-___,___.99')# *</td>
			</tr>
			<tr>
				<td colspan="3">&nbsp;</td>
				<td style="text-align:right;font-size:11px; font-weight:bold">Resident ID: #qryActivity.CustID#</td>
				<td>&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td style="font-size:11px; font-weight:bold">as of #dateformat(now(),'mmmm dd, yyyy')#</td> 
			</tr>	
			<tr>
				<td colspan="8"><hr /></td>
			</tr>		
		</cfoutput>
	</table>
				
	<cfif LateFeeBalance.recordcount gt 0 >
		<cfdocumentitem type="pagebreak" />	
	<cfelseif PaidLateFee.recordcount gt 0>
		<cfdocumentitem type="pagebreak" />	
	</cfif>
	<cfif LateFeeBalance.recordcount gt 0>
	<cfoutput>
	<table width="100%">
		<tr>
			<td colspan="7" style="border-bottom: 1px solid black; border-top: 1px solid black; text-align:center;">
			List of Pending Late Fees</td>
		</tr>
		
		<tr>
			<td style="border-bottom: 1px solid black;font-size:10px; font-weight:bold;">
			ID
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; font-weight:bold;">
			Description
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Applies To Accounting<br/> Period
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Current Late Fee<br /> Amount
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Actual Late Fee<br /> Amount
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Partial<br /> Payment
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Late Fee Start<br /> Date
			</td>
		</tr>
	<cfloop query="LateFeeBalance">	
		<tr>
			<td style="font-size:10px;">#csolomonkey#</td>
			<td style="text-align:right;font-size:10px;">#cdescription#</td>
			<td style="text-align:center;font-size:10px;">#cAppliestoacctperiod#</td>
			<cfset currlatefeeamt = #mLateFeeAmount#  -  #TotalPartialPayment#>
			<td style="text-align:center;font-size:10px;">$ #numberformat(currlatefeeamt,'999,999.99')#</td>
			<td style="text-align:center;font-size:10px;">$ #numberformat(mlatefeeamount,'999,999.99')#</td>
			<td style="text-align:center;font-size:10px;">$ #numberformat(totalPartialPayment,'999,999.99')#</td>
			<td style="text-align:center;font-size:10px;">#dateformat(dtLateFeeStart,'mm/dd/yyyy')#</td>
		</tr>
	</cfloop>	
	<tr>
		<td colspan="4">&nbsp;</td>
		<td colspan="2" style="font-weight:bold;">Total Pending Late Fee:</td>	
		<td style="font-weight:bold;">$ #Numberformat(LateFeeBalance.totalpendinglatefee,'999,999.99')#</td>
		</tr>
	</table>
	</cfoutput>
	</cfif>
	
	<cfif PaidLateFee.recordcount gt 0>
	<cfoutput>
	<table width="100%">
		<tr>
			<td colspan="7" style="border-bottom: 1px solid black; border-top: 1px solid black; text-align:center;">
			List of Paid Late Fees</td>
		</tr>
		
		<tr>
			<td style="border-bottom: 1px solid black;font-size:10px; font-weight:bold;">
			Invoice Nbr.
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; font-weight:bold;">
			Amount
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Description
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Late Fee<br />Start Date
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Applies To Acct Period
			</td>
			<td style="border-bottom: 1px solid black;font-size:10px; text-align:center; font-weight:bold;">
			Comments
			</td>

		</tr>
	<cfloop query="PaidLateFee">	
		<tr>
			<td style="font-size:10px;">#iinvoicenumber#</td>
			<td style="text-align:right;font-size:10px;">#mLateFeeAmount#</td>
			<td style="text-align:center;font-size:10px;">#Description#</td>
			<td style="text-align:center;font-size:10px;">#dateformat(dtLateFeeStart,'mm/dd/yyyy')#</td>
			<td style="text-align:center;font-size:10px;">#cAppliestoAcctPeriod#</td>
			<td style="text-align:center;font-size:10px;">#cComments#</td>
		</tr>
	</cfloop>	
	<tr>
		<td colspan="4">&nbsp;</td>
		<td colspan="2" style="font-weight:bold; text-align:right">Total Late Fee paid:</td>	
		<td style="font-weight:bold;">$ #Numberformat(SumPaidLateFee.sumLateFeeAmount,'999,999.99')#</td>
		</tr>
	</table>
	</cfoutput>
	</cfif>	
	
	 	<cfdocumentitem  type="footer" evalAtPrint="true">
		<table width="100%">
			<cfoutput>
				<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
 
		<tr>
			<td  colspan="5" style="font-size:small; text-align:center; font-style:italic; color:##0099FF ">
			* This report is intended for internal review purposes only and no guarentees are made regarding the accuracy of the information contained herein.<br />All balances are subject to final review by Enlivant Accounting and may not reflect the actual final balance of a given resident.
			</td>
		</tr>	
 							
				<tr>
					<td width="20%">&nbsp;</td>
					<td width="20%">&nbsp;</td>
					<td  width="20%" style="font-size:small; ">Enlivant</td> 
					<td  width="20%" style="font-size:small; ">Printed: #dateformat(now(),'mm/dd/yyyy')#</td>	
					<td  width="20%" style="font-size:small; ">
					Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
					</td>
				</tr>	
				<cfelse>
				<tr>
					<td>&nbsp;</td>
					<td>&nbsp;</td>
					<td>&nbsp;</td> 
					<td>&nbsp;</td>	
					<td  style="font-size:small; text-align:right ">
					Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
					</td>
				</tr>	
				
				</cfif>
			</cfoutput>
		</table>
	</cfdocumentitem>
	<cfoutput>
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=CustomerAccountingActivityReport-#HouseData.cname#-#trim(qryActivity.Name)#-#qryActivity.tranperiod#.pdf"> 
	</cfoutput>			

</cfdocument>
</body>
</html>
