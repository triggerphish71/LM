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
01/14/2016  |S Farmer     |         |  Replaced crystal report with Coldfusion CFDocument-PDF |
01/26/2016  | S Farmer    |         | corrected qryTransactions for end date                  |
 --->	
 	<cfparam  NAME="prompt0" default="">
 	<cfparam  NAME="prompt1" default="">
	<cfparam  NAME="prompt2" default="">
	<cfparam  NAME="prompt21" default="">
	<cfparam  NAME="prompt3" default="">
	<cfparam  NAME="prompt4" default="">
	<cfparam name="bUsesEFT" default="">
<cfif prompt0 is 'All'>
<cflocation url="InvoiceReportC.cfm?prompt0=#prompt0#&prompt1=#prompt1#&prompt2=#prompt2#&prompt21=#prompt21#&prompt3=#prompt3#&prompt4=#prompt4#&bUsesEFT=#bUsesEFT#">
</cfif>
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
		FROM	House H (NOLOCK) 
		JOIN 	OPSArea OA (NOLOCK) ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
		JOIN 	Region R (NOLOCK) ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
		WHERE	<!---H.dtRowDeleted IS NULL	
		AND	--->	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	</CFQUERY>	


		<cfquery name="SelectAll"  datasource="#application.datasource#">
		select t.csolomonkey 
		from tenant t (NOLOCK) 
		join tenantstate ts (NOLOCK) on t.itenant_id = ts.itenant_id
		join invoicemaster im (NOLOCK) on im.csolomonkey = t.csolomonkey 
		and im.cappliestoacctperiod = '#prompt2#'
		where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# 
			and t.csolomonkey ='#prompt0#' 
			and im.dtrowdeleted is null
			and 	im.bMoveInInvoice is null 
			and 	im.bMoveOutInvoice is null	
		order by t.csolomonkey
		</cfquery>		

	<cfif SelectAll.recordcount lt 1>
		<cfoutput>
			<cfquery name="SelectAll"  datasource="#application.datasource#">
				select t.csolomonkey, t.cfirstname + ' ' + t.clastname as Residentname
				from tenant t (NOLOCK) 
				join tenantstate ts (NOLOCK) on t.itenant_id = ts.itenant_id
				where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#   
					and t.csolomonkey ='#prompt0#'
			</cfquery>
			<cfquery name="lastinvoice"  datasource="#application.datasource#">
			select max(cappliestoacctperiod) cappliestoacctperiod 
			from invoicemaster (NOLOCK)
			where csolomonkey = #SelectAll.csolomonkey#
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
	
	<cfquery name="sp_Invoices_report" datasource="#application.datasource#">
		EXEC rw.sp_Invoices_report
			  @HouseNumber =   '#HouseData.cnumber#' , 
			@AcctPeriod =   '#prompt2#' ,
			@SolomonKey =   '#prompt0#'  
	</cfquery> 
	<cfif sp_Invoices_report.recordcount lt 1>
		<cfoutput>
			<cfquery name="SelectAll"  datasource="#application.datasource#">
				select t.csolomonkey, t.cfirstname + ' ' + t.clastname as Residentname
				from tenant t (NOLOCK) 
				join tenantstate ts (NOLOCK) on t.itenant_id = ts.itenant_id
				where t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#   
					and t.csolomonkey ='#prompt0#'
			</cfquery>
			<cfquery name="lastinvoice"  datasource="#application.datasource#">
			select max(cappliestoacctperiod) cappliestoacctperiod 
			from invoicemaster (NOLOCK)
			where csolomonkey = #SelectAll.csolomonkey#
				and dtrowdeleted is null 			
				and bMoveInInvoice is null 
				and bMoveOutInvoice is null	
			</cfquery>
			<div>
				<h2>Reports - Print Invoice</h2><br />
				<h3>No Regular Invoice Was Found for #SelectAll.Residentname# (Resident ID #prompt0#) for Period #prompt2#</h3>

				<br /><br /><a href="Menu.cfm">Return to Reports Menu</a>
			</div>
		</cfoutput>
		<cfabort>
	</cfif>	
   <!---<cfdump var="#sp_Invoices_report#">--->
	<cfquery name="qryTenant"  datasource="#application.datasource#">
	select t.itenant_id, t.cfirstname, t.clastname, t.bisPayer , t.csolomonkey
	,ts.dtmovein, ts.dtrenteffective, ts.dtmoveout, t.cbillingtype, t.cchargeset
	,t.cfirstname + ' ' + t.clastname as Residentname, ts.bUsesEFT
	 from tenant t (NOLOCK)
	 join tenantstate ts (NOLOCK) on t.itenant_id = ts.itenant_id
		where t.csolomonkey = '#sp_Invoices_report.csolomonkey#'
	</cfquery>
<!--- <cfdump var="#qryTenant#">  --->
	<cfquery name="qryTenantContact"  datasource="#application.datasource#">
	select top 1 *
	from linktenantcontact ltc (NOLOCK) 
	join contact cont (NOLOCK) on  ltc.icontact_id = cont.icontact_id
		and ltc.bispayer = 1
	where ltc.itenant_id = #qrytenant.itenant_id#
		and cont.dtrowdeleted is null and ltc.dtrowdeleted is null
	order by ltc.dtrowstart
	</cfquery>	
<cfif sp_Invoices_report.dtInvoiceEnd is ''>
	<cfset invoiceenddate =  '#dateformat(now(),'yyyy-mm-dd')#' &' '& '23:59:59.000' >
<cfelse>
	<cfset invoiceenddate = #sp_Invoices_report.dtInvoiceEnd#>
</cfif>
	<cfquery name="qryTransactions" datasource="#application.datasource#">
		SELECT doctype, refnbr, docdate, docdesc, custid
			, user1, user3, User4, user7, PerClosed
			, PerPost, amount, rlsed
		FROM     vmdbpro02dev.Houses_APP.dbo.vw_tips_GetTran   vw_tips_GetTran (NOLOCK)
		where custid = '#sp_Invoices_report.csolomonkey#' and 
		(vw_tips_GetTran.user7 between '#sp_Invoices_report.dtInvoiceStart#' and '#invoiceenddate#'     )
		and docdesc <> 'AR Opening Balance' 
		and docdesc not like '%BKD Invoice Ref%'
		<!---and doctype in ('CM', 'DM',  'IN', 'PA')--->
	</cfquery>
 
	<cfquery name="qryInvoiceCharges" datasource="#application.datasource#">
			EXEC  rw.sp_InvoiceChargesInvoiceReport
			@iInvoiceNumber =  '#sp_Invoices_report.iInvoicenumber#'
	</cfquery>

</CFOUTPUT>

<body> 
	<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="2">
 
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
						<!---<cfif right(sp_Invoices_report.cappliestoacctperiod,2) is 01>
						January, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 02>
						February, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 03>
						March, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 04>
						April, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 05>
						May, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 06>
						June, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 07>
						July, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 08>
						August, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 09>
						September, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 10>
						October, #left(sp_Invoices_report.cappliestoacctperiod,4)#				
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 11>
						November, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						<cfelseif right(sp_Invoices_report.cappliestoacctperiod,2) is 12>
						December, #left(sp_Invoices_report.cappliestoacctperiod,4)#
						</cfif>--->
						
						<!--- Tpecku...Switched out multiple cfelseif lines of code to cfswitch/cfcase --->
						<cfswitch expression="#right(sp_Invoices_report.cappliestoacctperiod,2)#">
				        <cfcase value="01">
				           January, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="02">
				            February, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="03">
				            March, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="04">
				            April, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="05">
				            May, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="06">
				            June, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="07">
				            July, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="08">
				            August, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="09">
				            September, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="10">
				            October, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="11">
				            November, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="12">
				            December, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				       </cfcase>
				    </cfswitch>
					</td>
				</tr>
				<tr style="border-bottom: .5px solid black;">
					<td style="font-size:12px;font-weight:bold;" >
					Due Date:
					</td>
					<td style="font-size:12px;"> 
						<!---<cfif right(sp_Invoices_report.cappliestoacctperiod,2) is 01>
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
						</cfif>--->
						
					<!--- Tpecku...Switched out multiple cfelseif lines of code to cfswitch/cfcase --->
						<cfswitch expression="#right(sp_Invoices_report.cappliestoacctperiod,2)#">
				        <cfcase value="01">
				           January 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="02">
				            February 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="03">
				            March 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="04">
				            April 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="05">
				            May 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="06">
				            June 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="07">
				            July 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="08">
				            August 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="09">
				            September 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="10">
				            October 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
					<cfcase value="11">
				            November 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				        </cfcase>
				        <cfcase value="12">
				            December 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
				       </cfcase>
				    </cfswitch>
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
		<td style="font-size:12px;">
					<!---<cfif right(detailappliestoacctPeriod,2) is 01>
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
					</cfif>--->
				
				<!--- Tpecku...Switched out multiple cfelseif lines of code to cfswitch/cfcase --->
					<cfswitch expression="#right(detailappliestoacctPeriod,2)#">
			        <cfcase value="01">
			           January
			        </cfcase>
			        <cfcase value="02">
			            February
			        </cfcase>
			        <cfcase value="03">
			            March
			        </cfcase>
			        <cfcase value="04">
			            April
			        </cfcase>
				<cfcase value="05">
			            May
			        </cfcase>
			        <cfcase value="06">
			            June
			        </cfcase>
				<cfcase value="07">
			            July
			        </cfcase>
			        <cfcase value="08">
			            August
			        </cfcase>
				<cfcase value="09">
			            September
			        </cfcase>
			        <cfcase value="10">
			            October
			        </cfcase>
				<cfcase value="11">
			            November
			        </cfcase>
			        <cfcase value="12">
			            December
			       </cfcase>
			</cfswitch>
					</td> 
		<td style="font-size:12px;">#Invoicedescription#<br />#ccomments#</td>
		<td style="font-size:12px;text-align:right" >#dollarformat(mamount)#</td>
		<td style="font-size:12px;font-size:12px;text-align:right">#iquantity#</td>
		<cfset linetotal = mamount * iquantity>
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
				<!---<cfif right(sp_Invoices_report.cappliestoacctperiod,2) is 01>
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
					</cfif>--->
					
				<!--- Tpecku...Switched out multiple cfelseif lines of code to cfswitch/cfcase --->
					<cfswitch expression="#right(sp_Invoices_report.cappliestoacctperiod,2)#">
			        <cfcase value="01">
			           January 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="02">
			            February 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="03">
			            March 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="04">
			            April 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
				<cfcase value="05">
			            May 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="06">
			            June 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
				<cfcase value="07">
			            July 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="08">
			            August 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
				<cfcase value="09">
			            September 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="10">
			            October 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
				<cfcase value="11">
			            November 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			        </cfcase>
			        <cfcase value="12">
			            December 1, #left(sp_Invoices_report.cappliestoacctperiod,4)#
			       </cfcase>
			</cfswitch>
			: 
				</td>
			<td nowrap="nowrap"  style="text-align:right;font-size:12px; font-weight:bold; border:.5px solid black;"> 
			$  #numberformat(finalcharge,'(___,___.99)')#
			</td>
		</tr>
	</table> 
<table>

</table>
	</cfoutput>	

	<cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			<table width="100%">
<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>				
					<tr>
						<td  colspan="2" style="text-align:center; font-style:italic; font-size:xx-large;">
						 Help us be the very best! If you have a compliment to share or a concern that needs to be resolved, we want to know about it. <br />Please call our Enlivant Cares toll free line at 1-888-777-4780. <br />Prompt attention will be given to your call.
 							</td>
					</tr>
 					<tr>
						<td colspan="2" style="text-align:center;" ><h1> Payment is due by the 1st.  Balances are considered past due on the 5th and must be paid in full immediately.  There will be a fee for returned checks and late payments. Payments received after the 10th of the month will  not show on statement.</h1> 
						</td>
					</tr>
					<tr>
						<td  colspan="2" style="text-align:center;">
						<h2>Enlivant&trade;
						&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
						Printed: #dateformat(now(), 'mm/dd/yyyy')#</h2>						
						</td>
					</tr>
					<tr>					
						<td style="font-style:italic;text-align:center;"><h1>
			 By  mailing your payment you are authorizing Enlivant to convert your payment from a paper check to an electronic transaction that will be presented via the ACH network. </h1>
						</td>
						<td width="25%" style="font-style:italic;text-align:center; border: .5px solid black; font-size:xx-large; ">
			 For Office Use Only: <br />Charge Set: #qryTenant.cchargeset# Billing Type: #qryTenant.cbillingtype# 
						</td>	
					</tr>
					<tr>
						<td colspan="2" align="right">
						<h2>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount# </h2>
						</td>
					</tr>		
				<cfelse>	
					<tr>
						<td colspan="2" align="right"  style="font-size:small">
						  Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount# 
						</td>
					</tr>	
				</cfif>									
			</table>
		</cfoutput>
	</cfdocumentitem>	

	<cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=InvoiceReport-#qryTenant.Residentname#-#prompt2#.pdf"> 
	</cfoutput> 			

</cfdocument> 

</body>
</html>


	 