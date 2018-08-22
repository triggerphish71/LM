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
<!--- 
01/27/2016  | S Farmer    |         | Respite Resident Invoice converted to Coldfusion PDF    installed 02/16/2016         
 --->	
 	<cfparam  NAME="prompt0" default="">
 	<cfparam  NAME="prompt1" default="">
	<cfparam  NAME="prompt2" default="">
	<cfparam  NAME="prompt3" default="">
	<cfparam  NAME="prompt4" default="">
	<cfparam name="INVNBR" default="">
 
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


		<cfquery name="SelectAll"  datasource="#application.datasource#">
		select t.csolomonkey, t.itenant_id , t.cfirstname, t.clastname from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join invoicemaster im on im.csolomonkey = t.csolomonkey 
		where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# 
		and t.csolomonkey ='#prompt0#' and im.dtrowdeleted is null
			and 	im.iinvoicenumber = '#INVNBR#'	
		order by t.csolomonkey
		</cfquery>		

	<cfif SelectAll.recordcount lt 1>
		<cfoutput>
			<cfquery name="SelectAll"  datasource="#application.datasource#">
				select t.csolomonkey, t.cfirstname + ' ' + t.clastname as Residentname
				from tenant t
				join tenantstate ts on t.itenant_id = ts.itenant_id
				where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#   
				and t.csolomonkey ='#prompt0#'
			</cfquery>
			<cfquery name="lastinvoice"  datasource="#application.datasource#">
			select max(cappliestoacctperiod) cappliestoacctperiod from invoicemaster where csolomonkey = #SelectAll.csolomonkey#
			and dtrowdeleted is null 			
			and bMoveInInvoice is null 
			and bMoveOutInvoice is null	
			</cfquery>
			<div>
				<h2>Reports - Print Invoice</h2><br />
				<h3>No Regular Invoice Was Found for #SelectAll.Residentname# (Resident ID #prompt0#) for Period #prompt2#</h3>
				<h3>The last regular Invoice is for the period #lastinvoice.cappliestoacctperiod#</h3>
				<br /><br /><a href="Menu.cfm">Return to Reports Menu</a>
			</div>
		</cfoutput>
		<cfabort>
	</cfif>
	
	<cfset count = 0>

<CFOUTPUT>
<cfset count = count + 1>

	<cfset prompt0 = #SelectAll.csolomonkey#>
	
	<cfquery name="spInvoicesreport" datasource="#application.datasource#">
		EXEC rw.sp_Respite_Invoice
			@InvoiceNumber = '#INVNBR#'  
	</cfquery> 
<!---    <cfdump var="#spInvoicesreport#"> ---> 
	<cfquery name="qryTenant"  datasource="#application.datasource#">
	select t.itenant_id, t.cfirstname, t.clastname, t.bisPayer , t.csolomonkey
	,ts.dtmovein, ts.dtrenteffective, ts.dtmoveout, t.cbillingtype, t.cchargeset
	,t.cfirstname + ' ' + t.clastname as Residentname, ts.bUsesEFT
	 ,ts.iproductline_ID, ts.iresidencytype_ID from tenant t
	 join tenantstate ts on t.itenant_id = ts.itenant_id
		where t.csolomonkey = '#spInvoicesreport.csolomonkey#'
	</cfquery> 
	
	<cfif qryTenant.itenant_id is ''>
	  <div style="color:##FF0000; font-weight:bold;">
	  Invoice number #INVNBR# for resident #prompt0#, #SelectAll.cfirstname# #SelectAll.clastname# has no invoice detail records.<br />
		Please reolve this issue before continuing.
		</div>
		<br /><br />Use BACK Button to return to Reports Menu
		<cfabort>
	</cfif> 
	
	<cfquery name="qryTenantContact"  datasource="#application.datasource#">
	select top 1 *
	from linktenantcontact ltc
	join contact cont on  ltc.icontact_id = cont.icontact_id
	and ltc.bispayer = 1
	where ltc.itenant_id = #qrytenant.itenant_id#
	and cont.dtrowdeleted is null and ltc.dtrowdeleted is null
	order by ltc.dtrowstart
	</cfquery>	
	
	<cfif spInvoicesreport.dtInvoiceEnd is ''>
		<cfset invoiceenddate =  #dateformat(now(),'yyyy-mm-dd')#  >
	<cfelse>
		<cfset invoiceenddate = #spInvoicesreport.dtInvoiceEnd#>
	</cfif> 

	<cfquery name="qryTransactions" datasource="#application.datasource#">
		EXEC	 [rw].[sp_Respite_Invoice_transactions]
		@InvoiceNumber = '#INVNBR#',
		@cSolomonKey = '#prompt0#',
		@CurrentInvoiceCreation = '#spInvoicesreport.dtinvoicestart#'
	</cfquery>
 
	<cfquery name="qryInvoiceCharges" datasource="#application.datasource#">
		EXEC  rw.sp_InvoiceChargesInvoiceReport
		@iInvoiceNumber =  '#spInvoicesreport.iInvoicenumber#'
	</cfquery>
<cfdump var="#qryInvoiceCharges#">
</CFOUTPUT>

<body>
<div>Content for New Div Tag Goes Here</div> 
	<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="2">
 
	<cfdocumentitem type="header" >  
		<cfoutput>
			<table>
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td><h2>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#</h2>
					</td>
				</tr>
			</table>
		</cfoutput>	
	</cfdocumentitem> 
	

	<cfoutput>
 	<cfset paymnttotal = 0>
 	<cfset chargestotal = 0>
 
<table  width="95%" style=" border:medium; border-left:hidden; border-right:hidden; "  > 
	<tr><td colspan="4"><hr></td></tr>
	<tr style="border-bottom:thick">
		<td style="font-size:14px; font-weight:bold;text-align:center">Respite Resident Invoice</td>
	</tr>	
	<tr style="border-bottom:thick">
		<td style="font-size:12px; font-weight:bold;text-align:center">
		Questions you may have regarding this invoice should be directed to the Executive Director at the number indicated above. <br />If you are unable to resolve your question with the Executive Director, you may contact Corporate Billing and Accounts Receivable Department at (888) 252-5001, extension 8991. 
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
		<td style="font-size:12px;">#spInvoicesreport.cfirstname# #spInvoicesreport.clastname#</td>
		</tr>
		<tr>
		<td style="font-size:12px;">#HouseData.Caddressline1# Apt. #spInvoicesreport.cAptNumber#</td>
	  </tr>
		<tr>
		<td style="font-size:12px;">#HouseData.cCity#, #HouseData.cstatecode# #HouseData.czipcode#</td>
		</tr>
	<cfelse>
		<tr>
		<td style="font-size:12px;">#qryTenantContact.cfirstname#  #qryTenantContact.clastname#</td>
		</tr>
		<tr>
		<td style="font-size:12px;">#qryTenantContact.Caddressline1# </td> 
		</tr>
		<cfif qryTenantContact.Caddressline2 is not ''>
			<tr>
			<td style="font-size:12px;">#qryTenantContact.Caddressline2# </td> 
			</tr>
		</cfif>
		<tr style="border-bottom:thick">
		<td style="font-size:12px;">
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
					<td style="font-size:12px"> #spInvoicesreport.cfirstname# #spInvoicesreport.clastname#</td>
					<td style=" font-size:12px;font-weight:bold;">
					Apartment:</td> 
					<td style="font-size:12px">  #spInvoicesreport.cAptNumber#</td>			
				</tr>
				<tr>
					<td style="font-size:12px; font-weight:bold;">Account Nbr: </td>
					<td style="font-size:12px">#spInvoicesreport.cSolomonKey# </td>
					<td style="font-size:12px;font-weight:bold;">Number of Billed Days:</td>
					<cfset billdays = datediff('d',#spInvoicesreport.dtinvoicestart#,#invoiceenddate#) +1>
					<td style="font-size:12px">#billdays#</td>
				</tr>
				<tr style="border-bottom: .5px solid black;">
					<td style="font-size:12px;font-weight:bold;" >
					Invoice Start Date:
					</td>
					<td style="font-size:12px;"> 
					 #dateformat(spInvoicesreport.dtinvoicestart, 'mm/dd/yyyy')# 
				  	</td>
					<td style="font-size:12px;font-weight:bold;" >
					Invoice End Date:
					</td>
					<td style="font-size:12px;"> 
					#dateformat(invoiceenddate,'mm/dd/yyyy')#
					</td>
				</tr>
				<tr>
					<td colspan="5"><hr></td>
				</tr>
				<tr>
					<td colspan="4" style="text-align:right; font-size:12px; font-weight:bold">Previous Balance:  $</td>
					<td  style="text-align:right; font-size:12px; font-weight:bold">
					   #numberformat(spInvoicesreport.mLastInvoiceTotal,'(___,___.99)')#
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
			<td style="font-size:12px;">#refnbr#</td>
			<td style="font-size:12px;">#dateformat(docdate, 'mm/dd/yyyy')#</td> 
			<td  style="font-size:12px;">
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
			<td  colspan="2" style="font-size:12px;">#DocDesc#</td>
			<td style="font-size:12px;text-align:right">$#numberformat(Amount, '(___,___.__)')#</td>
			 <td>&nbsp;</td>  
		</tr>
		<cfset paymnttotal = paymnttotal + #Amount#>
	</cfloop>
	<tr>
		<td colspan="6" style="text-align:right;font-size:12px; font-weight:bold">Total Transactions:  $</td>
		<td nowrap="nowrap"  style="text-align:right; font-size:12px;font-weight:bold; border-top:.5px solid black;">
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
		<td style="font-size:12px;">#iInvoicenumber#</td>
		<td style="font-size:12px;">#detailappliestoacctPeriod#</td>
		<!--- 			<cfif right(detailappliestoacctPeriod,2) is 01>
					January
					<cfelseif right(detailappliestoacctPeriod,2) is 02>
					February				
					<cfelseif right(detailappliestoacctPeriod,2) is 03>
					March
					<cfelseif right(detailappliestoacctPeriod,2) is 04>
					April				
					<cfelseif right(detailappliestoacctPeriod,2) is 05>
					May				
					<cfelseif right(detailappliestoacctPeriod,2) is 06>
					June
					<cfelseif right(detailappliestoacctPeriod,2) is 07>
					July
					<cfelseif right(detailappliestoacctPeriod,2) is 08>
					August			
					<cfelseif right(detailappliestoacctPeriod,2) is 09>
					September
					<cfelseif right(detailappliestoacctPeriod,2) is 10>
					October				
					<cfelseif right(detailappliestoacctPeriod,2) is 11>
					November
					<cfelseif right(detailappliestoacctPeriod,2) is 12>
					December
					</cfif> ---> 
		<td style="font-size:12px;">#Invoicedescription#<br />#ccomments#</td>
		<td style="font-size:12px;text-align:right" >#dollarformat(mamount)#</td>
		<td style="font-size:12px;font-size:12px;text-align:right"><cfif qryTenant.iproductline_ID eq 2 and qryTenant.iresidencytype_ID eq 3>#iDaysBilled# <cfelse> #iquantity# </cfif></td>
		<cfset linetotal = mamount * iquantity>
		<td style="font-size:12px;text-align:right">#dollarformat(linetotal)#</td>
	</tr>
	 	<cfset chargestotal = chargestotal + #linetotal#>
	</cfloop>
	<tr >
		<td colspan="3">&nbsp;</td>
		<td colspan="3" style="text-align:right;font-size:12px; font-weight:bold;">
		Total Current Invoice Charges:
		</td>
		<td style="text-align:right;font-size:12px; font-weight:bold; 	
			border-top:.5px solid black;"> 
		  $#numberformat(chargestotal,'(___,___.99)')#
		</td>
	</tr>
	<cfset finalcharge = #chargestotal# + #paymnttotal# + #spInvoicesreport.mLastInvoiceTotal#>
	<tr>
		<td colspan="6"  style="text-align:right;font-size:12px; font-weight:bold">
		Total Due by #dateformat(spInvoicesreport.dtinvoicestart, 'mmmm dd, yyyy')#: 
		</td>
		<td nowrap="nowrap"  style="text-align:right;font-size:12px; font-weight:bold; border:.5px solid black;"> 
		$#numberformat(finalcharge,'(___,___.99)')#
		</td>
	</tr>
</table>
	</cfoutput>	

	<cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			<table width="100%">
<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>				

 					<tr>
						<td colspan="2"  style="text-align:center; font-weight:bold" >
<h1>Please provide your payment for the total amount stated above to the Executive Director. You may also contact the Corporate Billing Department for other payment options at (888) 252-5001, extension 8991.<br />Thank You!</h1></td>
					</tr>

					<tr>
						<td colspan="2"  style="text-align:center; font-style:italic; font-size:xx-large;">
 Help us be the very best! If you have a compliment to share or a concern that needs to be resolved, we want to know about it. <br />Please call our Enlivant Cares toll free line at 1-888-777-4780. <br />Prompt attention will be given to your call.</td>
					</tr>
					<tr>					
						<td colspan="2"  style="text-align:center; font-style:italic; font-size:xx-large;"> 
By  providing your payment you are authorizing Enlivant&trade; to convert your payment from a paper check to an electronic transaction that will be processed via the ACH network. <br /> Note: There will be a fee for returned checks and late payments.</td>
				</tr>
				<tr>
					<td colspan="2"  style="font-style:italic;text-align:center; font-weight:bold" >
						<h1>Thank you for choosing Enlivant&trade;</h1>
					</td>
				</tr>
				<tr>
				<tr>
						<td align="right" width="50%">
						  <h2>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</h2> 
						</td>						
						<td  style="text-align:right;">
						<h2>Printed: #dateformat(now(), 'mm/dd/yyyy')#</h2>						
						</td>
	  </tr>		
				<cfelse>	
					<tr>
						<td colspan="2" align="center">
						  <h2>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</h2> 
						</td>
					</tr>	
			  </cfif>									
			</table>
		</cfoutput>
	</cfdocumentitem>	

	<cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=InvoiceReport-#qryTenant.Residentname#.pdf"> 
	</cfoutput> 			

</cfdocument> 

</body>
</html>


	 