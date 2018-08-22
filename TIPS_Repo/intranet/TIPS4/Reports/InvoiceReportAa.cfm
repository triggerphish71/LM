 	<cfparam  NAME="prompt0" default="">
 	<cfparam  NAME="prompt1" default="">
	<cfparam  NAME="prompt2" default="">
	<cfparam  NAME="prompt3" default="">
	<cfparam  NAME="prompt4" default="">
	
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

	<cfif prompt0 is 'All'>
		<cfquery name="SelectAll"  datasource="#application.datasource#">
		select t.csolomonkey  from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join invoicemaster im on im.csolomonkey = t.csolomonkey and im.cappliestoacctperiod = '#prompt2#'
		where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# and im.dtrowdeleted is null  
		and 	im.bMoveInInvoice is null 
		and 	im.bMoveOutInvoice is null
		order by t.csolomonkey
		</cfquery>
	<cfelse>
		<cfquery name="SelectAll"  datasource="#application.datasource#">
		select t.csolomonkey from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join invoicemaster im on im.csolomonkey = t.csolomonkey 
		and im.cappliestoacctperiod = '#prompt2#'
		where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# 
		and t.csolomonkey ='#prompt0#' and im.dtrowdeleted is null
		order by t.csolomonkey
		</cfquery>		
	</cfif>
	<cfset count = 0>
<cfloop query="SelectAll"  >
<CFOUTPUT>
<cfset count = count + 1>
#csolomonkey# - #count# <br />
	<cfset prompt0 = #csolomonkey#>
	
	<cfquery name="sp_Invoices_report" datasource="#application.datasource#">
		EXEC rw.sp_Invoices_report
			  @HouseNumber =   '#HouseData.cnumber#' , 
			@AcctPeriod =   '#prompt2#' ,
			@SolomonKey =   '#prompt0#'  
	</cfquery> 

	<cfquery name="qryTenant"  datasource="#application.datasource#">
	select t.itenant_id, t.cfirstname, t.clastname, t.bisPayer , t.csolomonkey
	,ts.dtmovein, ts.dtrenteffective, ts.dtmoveout, t.cbillingtype, t.cchargeset
	 from tenant t
	 join tenantstate ts on t.itenant_id = ts.itenant_id
		where t.csolomonkey = '#sp_Invoices_report.csolomonkey#'
	</cfquery>

	<cfquery name="qryTenantContact"  datasource="#application.datasource#">
	select top 1 *
	from linktenantcontact ltc
	join contact cont on  ltc.icontact_id = cont.icontact_id
	and ltc.bispayer = 1
	where ltc.itenant_id = #qrytenant.itenant_id#
	and cont.dtrowdeleted is null and ltc.dtrowdeleted is null
	order by ltc.dtrowstart
	</cfquery>	

	<cfquery name="qryTransactions" datasource="#application.datasource#">
		SELECT doctype, refnbr, docdate, docdesc, custid
			, user1, user3, User4, user7, PerClosed
			, PerPost, amount, rlsed
		FROM     dbprod02.Houses_APP.dbo.vw_tips_GetTran   vw_tips_GetTran
		where custid = '#sp_Invoices_report.csolomonkey#' and 
		(vw_tips_GetTran.user7 between '2015-07-01'  and '#sp_Invoices_report.dtInvoiceEnd#')
		and doctype in ('CM', 'DM',  'IN', 'PA')
	</cfquery>
	
	<cfquery name="qryInvoiceCharges" datasource="#application.datasource#">
	select im.iinvoicemaster_id iminvmasterid
	,im.iInvoiceNumber iminvnumber
	,im.cappliestoacctperiod imacctperiod
	,inv.cappliestoacctperiod invacctperiod
	,inv.cdescription
	,inv.mamount
	,inv.iquantity
	,round(inv.mamount * inv.iquantity,2) linetotal
	from invoicemaster im
	join invoicedetail inv on im.iinvoicemaster_id = inv.iinvoicemaster_id
	where im.csolomonkey = '#prompt0#'
	and im.cappliestoacctperiod = '#prompt2#'
	and inv.dtrowdeleted is null and im.dtrowdeleted is null
	and im.bMoveInInvoice is null 
	and im.bMoveOutInvoice is null	
	</cfquery>
</CFOUTPUT>
  <cfsavecontent variable="PDFhtml"> 
<cfoutput>
  <cfheader name="Content-Disposition" 
	value="attachment;filename=InvoiceReport-sp_Invoices_report.pdf">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Resident Invoice</title>
		 <style>
			table{ 
				font-size:0em;
				border-collapse: collapse;
			}
		</style>
	</head>
<body>
 	<cfset paymnttotal = 0>
 	<cfset chargestotal = 0>

 
 
<table  width="95%" style=" border:medium; border-left:hidden; border-right:hidden; "  > 
<tr><td colspan="4"><hr></td></tr>
<tr style="border-bottom:thick">
	<td style="font-size:12px; font-weight:bold;text-align:center">RESIDENT INVOICE<br />
	Questions you may have regarding this invoice should be directed to the House Adminstrator at the number indicated above. <br />If you are unable to resolve your question with the House Adminstrator, you may contact Corporate Billing and Accounts Receivable Department at (888) 252-5001, extension 8760.
	</td>
</tr>
<tr><td colspan="4"><hr></td></tr>
</table>
<table  width="95%" style="border-bottom:thin">
	<tr>
		<td>Invoice To:</td>
	<tr/>
	<cfif qryTenant.bIsPayer is 1>
		<tr>
		<td style="font-size:10px;">#sp_Invoices_report.cTenantName#</td>
		</tr>
		<tr>
		<td style="font-size:10px;">#HouseData.Caddressline1# Apt. #sp_Invoices_report.cAptNumber#</td>
		 </tr>
		<tr>
		<td style="font-size:10px;">#HouseData.cCity#, #HouseData.cstatecode# #HouseData.czipcode#</td>
		</tr>
	<cfelse>
		<tr>
		<td style="font-size:10px;">#qryTenantContact.cfirstname#  #qryTenantContact.cfirstname#</td>
		</tr>
		<tr>
		<td style="font-size:10px;">#qryTenantContact.Caddressline1# </td> 
		</tr>
		<cfif qryTenantContact.Caddressline2 is not ''>
			<tr>
			<td style="font-size:10px;">#qryTenantContact.Caddressline2# </td> 
			</tr>
		</cfif>
		<tr style="border-bottom:thick">
		<td style="font-size:10px;">
		#qryTenantContact.cCity#, #qryTenantContact.cstatecode#  #qryTenantContact.czipcode#</td>
		</tr>
	</cfif>
			<tr><td ><hr></td></tr>
</table>
<table width="95%" cellpadding="5";  cellspacing="5">
			<cfoutput>
			
			<tr style="line-height:100%">
				<td style="font-size:12px; font-weight:bold;">
				Resident Name:</td>
				<td style="font-size:12px"> #sp_Invoices_report.cTenantName#</td>
				<td style=" font-size:12px;font-weight:bold;">
				Apartment:</td> 
				<td style="font-size:12px">  #sp_Invoices_report.cAptNumber#</td>			
			</tr>
			<tr>
				<td style="font-size:12px; font-weight:bold;">
				Account Nbr: </td>
				<td style="font-size:12px">  #sp_Invoices_report.cSolomonKey# </td>
				<td style="font-size:12px;font-weight:bold;">
				Invoice Number:</td>
				<td style="font-size:12px">  #sp_Invoices_report.iinvoicenumber#</td>
			</tr>
			<tr style="border-bottom: .5px solid black;">
				<td style="font-size:12px;font-weight:bold;" >
				Invoice Date:
				</td>
				<td style="font-size:12px;"> 
				 #dateformat(sp_Invoices_report.dtinvoiceend, 'mmm. dd, yyyy')# 
			  </td>
				<td style="font-size:12px;font-weight:bold;" >
				Invoice Month:
				</td>
				<td style="font-size:12px;"> 
					<cfif right(sp_Invoices_report.cappliestoacctperiod,2) is 01>
					January #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 02>
					February #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 03>
					March #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 04>
					April #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 05>
					May #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 06>
					June #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 07>
					July #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 08>
					August #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 09>
					September #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 10>
					October #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 11>
					November #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 12>
					December #left(sp_Invoices_report.cappliestoacctperiod,4)#
					</cfif>
				</td>
			</tr>
			<tr style="border-bottom: .5px solid black;">
				<td style="font-size:12px;font-weight:bold;" >
				Due Date:
				</td>
				<td style="font-size:12px;"> 
					<cfif right(sp_Invoices_report.cappliestoacctperiod,2) is 01>
					January 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 02>
					February 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 03>
					March 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 04>
					April 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 05>
					May 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 06>
					June 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 07>
					July 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 08>
					August 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 09>
					September 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 10>
					October 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 11>
					November 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 12>
					December 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					</cfif>
				</td>
			</tr>
			<tr>
				<td colspan="5"><hr></td>
			</tr>
			<tr>
				<td colspan="4" style="text-align:right; font-size:12px; font-weight:bold">Previous Balance:  $</td>
				<td  style="text-align:right; font-size:12px; font-weight:bold">
				   #numberformat(sp_Invoices_report.mLastInvoiceTotal,'(___,___.99)')#
				</td>
			</tr>			
		</cfoutput>
</table> 
<table width="95%" cellpadding="5";  cellspacing="5"  >
	<tr >
		<td colspan="7"  style="text-align:left; font-size:12px; font-weight:bold">Transactions</td>
	</tr>
	<tr>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; "> 
		Reference <br /> Number
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; " >
		Document<br />Date
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
		Transaction<br />Type
		</td>
		<td  colspan="2" style="text-align:center; font-size:12px; border-bottom: .5px solid black;" >
		Description
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
		Amount
		</td>
		<td>&nbsp;</td>
	</tr>
	<cfloop query="qryTransactions">
	<tr>
		<td style="font-size:10px;">#refnbr#</td>
		<td style="font-size:10px;">#dateformat(docdate, 'mm/dd/yyyy')#</td> 
		<td  style="font-size:10px;">
			<cfIf doctype is 'CM'>
			'Credit Memo'
			<cfElseif   doctype  is 'DM'>
			'Debit Memo'
			<cfElseIf  doctype  is 'IN'>
			'Invoice'
			<cfElseIf  doctype  is 'PA'>
			 Payment-Chk Nbr: #RefNbr# 
			</cfIf>
		</td>
		<td  colspan="2" style="font-size:10px;">#DocDesc#</td>
		<td style="font-size:10px;text-align:right">#dollarformat(Amount)#</td>
		 <td>&nbsp;</td>  
	</tr>
	<cfset paymnttotal = paymnttotal + #Amount#>
	</cfloop>
	<tr>
		<td colspan="6" style="text-align:right;font-size:10px; font-weight:bold">Total Transactions:  $</td>
		<td nowrap="nowrap"  style="text-align:right; font-size:10px;font-weight:bold; border-top:.5px solid black;">
		  #numberformat(paymnttotal , '(___,___.99)')#</td>
	</tr>
	<tr>
		<td colspan="7"  style="text-align:left; font-size:12px; font-weight:bold; text-decoration:underline">
		Current Charges
		</td>
	</tr>
	<tr>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; "> 
		Invoice <br /> Number
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; " >
		Accounting<br />Period
		</td>
		<td  style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
		Description
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black;" >
		Amount
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
		Qty
		</td>
		<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
		Total<br />Amount
		</td>
		<td>&nbsp;</td>
	</tr>
	
 	<cfloop query="qryInvoiceCharges">
	<tr>
		<td style="font-size:10px;">#iminvnumber#</td>
		<td style="font-size:10px;"><cfif right(invacctperiod,2) is 01>
					January
					<cfelseif right(invacctperiod,2) is 02>
					February				
					<cfelseif right(invacctperiod,2) is 03>
					March
					<cfelseif right(invacctperiod,2) is 04>
					April				
					<cfelseif right(invacctperiod,2) is 05>
					May				
					<cfelseif right(invacctperiod,2) is 06>
					June
					<cfelseif right(invacctperiod,2) is 07>
					July
					<cfelseif right(invacctperiod,2) is 08>
					August			
					<cfelseif right(invacctperiod,2) is 09>
					September
					<cfelseif right(invacctperiod,2) is 10>
					October				
					<cfelseif right(invacctperiod,2) is 11>
					November
					<cfelseif right(invacctperiod,2) is 12>
					December
					</cfif></td> 
		<td style="font-size:10px;">#cdescription#</td>
		<td style="font-size:10px;text-align:right" >#dollarformat(mamount)#</td>
		<td style="font-size:10px;font-size:10px;text-align:right">#iquantity#</td>
		<td style="font-size:10px;text-align:right">#dollarformat(linetotal)#</td>
	</tr>
	 	<cfset chargestotal = chargestotal + #linetotal#>
	</cfloop>
	<tr >
		<td colspan="3">&nbsp;</td>
		<td colspan="3" style="text-align:right;font-size:12px; font-weight:bold; border-bottom:.5px solid black;">
		Total Current Charges:  $
		</td>
		<td style="text-align:right;font-size:12px; font-weight:bold; 	
			border-top:.5px solid black;
		 	border-bottom:.5px solid black;"> 
		  #numberformat(chargestotal,'(___,___.99)')#
		</td>
	</tr>
	<cfset finalcharge = #chargestotal# + #paymnttotal# + #sp_Invoices_report.mLastInvoiceTotal#>
	<tr>
		<td colspan="6"  style="text-align:right;font-size:12px; font-weight:bold">Total Due by 					
				<cfif right(sp_Invoices_report.cappliestoacctperiod,2) is 01>
					January 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 02>
					February 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 03>
					March 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 04>
					April 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 05>
					May 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 06>
					June 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 07>
					July 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 08>
					August 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 09>
					September 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 10>
					October 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 11>
					November 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 12>
					December 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
					</cfif>: </td>
			<td nowrap="nowrap"  style="text-align:right;font-size:12px; font-weight:bold; border:.5px solid black;"> 
			$  #numberformat(finalcharge,'(___,___.99)')#
			</td>
		</tr>

		<tr>
			<td colspan="7" style="font-size: 8px;text-align:center; font-style:italic">
			Help us be the very best! 
			If you have a compliment to share or a concern that needs to be resolved, we want to know about it. <br />Please call our Enlivant Cares toll free line at 1-888-777-4780. <br />Prompt attention will be given to your call.
			</td>
		</tr>
		
		<tr>
			<td colspan="7" style="font-size:medium; text-align:center" >Payment is due by the 1st. Balances are considered past due on the 5th and must be paid in full immediately. There will be a fee for returned checks and late payments.
			</td>
		</tr>
		<tr>		
			<td colspan="7" style="text-align:center; font-size:small;">
			Payments received after the 10th of the month will not show on statement
			</td>
		</tr>
		<tr>					
		<td colspan="7" style="font-style:italic;text-align:center; font-size:small">By  mailing your payment you are authorizing Enlivant to convert your payment from a paper check to an electronic transaction that will be presented via the ACH network</td>	
		</tr>
	</table> 
</cfoutput>
 </cfsavecontent> 
	<cfdocument format="PDF" orientation="portrait" margintop="1" marginbottom="1"  >	
	<cfdocumentsection>
		<cfdocumentitem type="header" >  
			<cfoutput>
			<table>
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
					</td>
				</tr>
			</table>
			</cfoutput>	
		</cfdocumentitem> 
		<cfoutput>
			#variables.PDFhtml#
		</cfoutput>		
			<cfdocumentitem  type="footer" evalAtPrint="true">
				<cfoutput>
					<h3 align="right">
					Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
					</h3>
							
					<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>			
					<h3>
For Office Use Only: Charge Set: #qryTenant.cchargeset# / Billing Type: #qryTenant.cbillingtype#
					</h3>

					<h3 align="center">Enlivant&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Printed: #dateformat(now(), 'mm/dd/yyyy')#</h3>
					</cfif>
				</cfoutput>
			</cfdocumentitem>
	</cfdocumentsection>
</cfdocument> 

</body>
</html>
<cfoutput>#csolomonkey#</cfoutput>
</cfloop>
	 