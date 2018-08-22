 	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> ---><head>
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

 
		<cfquery name="SelectAll"  datasource="#application.datasource#">
		select t.csolomonkey  from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join invoicemaster im on im.csolomonkey = t.csolomonkey 
		join AptAddress aa on ts.iAptAddress_id = aa.iAptAddress_id
		and im.cappliestoacctperiod = '#prompt2#'
		where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# 
		and im.dtrowdeleted is null  
		and 	im.bMoveInInvoice is null 
		and 	im.bMoveOutInvoice is null
		order by aa.cAptNumber
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
			select max(cappliestoacctperiod) cappliestoacctperiod 
			from invoicemaster where csolomonkey = #SelectAll.csolomonkey#
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
<CFOUTPUT>
<cfloop query="SelectAll"  >

<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="2">
<!--- <cfsavecontent variable="PDFhtml">

</cfsavecontent>  --->	

 	<cfdocumentitem type="header" >  
 
			<table>
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
					<td style="text-align:center"><h2>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
			(#left(Housedata.cphonenumber1,3)#)	#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
					</h2></td>
				</tr>
			</table>
 
 	</cfdocumentitem>	
<cfheader name="Content-Disposition" 
value="attachment;filename=Invoices-#HouseData.cname#-#prompt2#.pdf"> 


	<cfset count = 0>

	<!--- left(#prompt2#,4)&'-'&(right(#prompt2#,2)-1)&'-'&'10'> --->

<cfset count = count + 1>
<!--- <cfif count gt 1>
<cfdocumentitem type="pagebreak"/>
</cfif> --->
<!--- #csolomonkey# - #count# <br /> --->
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
		,t.cfirstname + ' ' + t.clastname as Residentname, ts.bUsesEFT
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
	
	<cfif sp_Invoices_report.dtInvoiceEnd is not ''>
		<cfset datebegin= dateadd('m',-1,#sp_Invoices_report.dtInvoiceEnd#)>
		<cfset datebegin = dateformat(#datebegin#, 'yyyy-mm-dd')>
	<cfelse>
		<cfset datebegin = dateformat(#now()#, 'yyyy-mm-dd')>
	</cfif>
	
	<cfquery name="qryTransactions" datasource="#application.datasource#">
		SELECT doctype, refnbr, docdate, docdesc, custid
			, user1, user3, User4, user7, PerClosed
			, PerPost, amount, rlsed
		FROM     dbprod02.Houses_APP.dbo.vw_tips_GetTran   vw_tips_GetTran
		where custid = '#sp_Invoices_report.csolomonkey#' 
		and (vw_tips_GetTran.user7 between '#sp_Invoices_report.dtInvoiceStart#' 
		and '#sp_Invoices_report.dtInvoiceEnd#'     )
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
		and inv.ichargetype_id not in (1749, 1750)
	</cfquery>
 
 
  	
 
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
		<td style="font-size:12px;">#sp_Invoices_report.cTenantName#</td>
		</tr>
		<tr>
		<td style="font-size:12px;">#HouseData.Caddressline1# Apt. #sp_Invoices_report.cAptNumber#</td>
		 </tr>
		<tr style="border-bottom:thick">
		<td style="font-size:12px;">#HouseData.cCity#, #HouseData.cstatecode# #HouseData.czipcode#</td>
		</tr>
	<cfelseif Isdefined('qryTenantContact')>
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
	<cfelse>
		<tr>
		<td style="font-size:12px;">#sp_Invoices_report.cTenantName#</td>
		</tr>
		<tr>
		<td style="font-size:12px;">#HouseData.Caddressline1# Apt. #sp_Invoices_report.cAptNumber#</td>
		 </tr>
		<tr style="border-bottom:thick">
		<td style="font-size:12px;">#HouseData.cCity#, #HouseData.cstatecode# #HouseData.czipcode#</td>
		</tr>
	</cfif>
			<tr><td ><hr></td></tr>
</table>
<table width="95%" cellpadding="5";  cellspacing="5">
 
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
			 #dateformat(sp_Invoices_report.dtinvoiceend, 'mmmm dd, yyyy')# 
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
		<td style="font-size:12px;text-align:right">$ #numberformat(Amount,'(___,___.99)')#</td>
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
		<td style="font-size:12px;">#iminvnumber#</td>
		<td style="font-size:12px;"><cfif right(invacctperiod,2) is 01>
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
		<td style="font-size:12px;">#cdescription#</td>
		<td style="font-size:12px;text-align:right" >#dollarformat(mamount)#</td>
		<td style="font-size:12px;text-align:right">#iquantity#</td>
		<td style="font-size:12px;text-align:right">#dollarformat(linetotal)#</td>
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
	</table> 
 
 	
	<cfdocumentitem  type="footer" evalAtPrint="true">
 
		<cfquery name="qryTenantFt"  datasource="#application.datasource#">
		select t.itenant_id, t.cfirstname, t.clastname, t.bisPayer , t.csolomonkey
		,ts.dtmovein, ts.dtrenteffective, ts.dtmoveout, t.cbillingtype, t.cchargeset
		,t.cfirstname + ' ' + t.clastname as Residentname, ts.bUsesEFT
		 from tenant t
		 join tenantstate ts on t.itenant_id = ts.itenant_id
			where t.csolomonkey = '#sp_Invoices_report.csolomonkey#'
	</cfquery>	
			<table width="100%">
						<tr>
							<td  colspan="2" style="text-align:center; font-style:italic;">
							<h2>Help us be the very best! If you have a compliment to share or a concern that needs to be resolved, we want to know about it. <br />Please call our Enlivant Cares toll free line at 1-888-777-4780. <br />Prompt attention will be given to your call.
</h2>							</td>
						</tr>
				<cfif qryTenantFt.bUsesEFT is 1>
					<tr>
					<td colspan="2" style="text-align:center" ><h1>For Your Records Only<br />Balance on account will be deducted from your checking account on the 5th of the month.</h1></td>
					</tr>
				<cfelse>
					<tr>
					<td  colspan="2" style="text-align:center" ><h1>Payment is due by the 1st. Balances are considered past due on the 5th and must be paid in full immediately.<br /> There will be a fee for returned checks and late payments.</h1>
					</td>
					</tr>
				</cfif>
					<tr>		
						<td  colspan="2" style="text-align:center;">
						<h1>Payments received after the 10th of the month will not show on statement.</h1>
						</td>
					</tr>
					<tr>					
						<td  colspan="2" style="font-style:italic;text-align:center;">
						<h1>By  mailing your payment you are authorizing Enlivant to convert your payment from a paper check to an electronic transaction that will be presented via the ACH network.</h1>
						</td>	
					</tr>
					<tr>					
						<td width="25%" style="font-style:italic;text-align:center; border: .5px solid black; ">		 						<h3>For Office Use Only: Charge Set: #qryTenant.cchargeset# <br />
					 Billing Type: #qryTenant.cbillingtype#</h3>
						</td>
						<td style="font-style:italic;text-align:center;">
						<h2>Enlivant&trade;
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						Printed: #dateformat(now(), 'mm/dd/yyyy')#
						InvoiceReportC.cfm</h2>
						</td>
					</tr>
					<tr><td>&nbsp;</td>
					<td align="right" style="font-size:small;">
					Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount# - #sp_Invoices_report.csolomonkey#
					</td>
					</tr>
				<!--- 	</cfif> --->
			</table>
 
	</cfdocumentitem>
   	
<!--- 		<cfheader name="Content-Disposition"   
 		value="attachment;filename=InvoiceReport-#HouseData.cname#-#prompt2#.pdf"> 
 			 --->

</cfdocument>   



  </cfloop> 
 </cfoutput>
 </body>
</html>
 
	 