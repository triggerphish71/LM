<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Respite Move Out Summary</title>
</head>
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
<CFQUERY NAME = "TenantInfo" DATASOURCE = "#APPLICATION.datasource#">
	SELECT DISTINCT
		T.*
		, TS.iTenantState_ID
		,TS.dtMoveIn
		,TS.iSPoints
		,TS.dtChargeThrough
		,TS.dtMoveOut
		,TS.dtNoticeDate
		,TS.iTenantStateCode_ID
		,TS.iResidencyType_ID
		,TS.dtChargeThrough
		,TS.dtMoveOutProjectedDate
		,ts.dtRentEffective
		,AD.cAptNumber
		,TS.iAptAddress_ID
		,TS.iTenantMOLocation_ID
		,ts.IMONTHSDEFERRED
		,ts.madjnrf
		,ts.mbasenrf
		,ts.mAmtDeferred
		,AT.cDescription as AptType
		,AT.iAptType_ID
		,RT.cDescription as Residency
		,MT.cDescription as Reason
		,MT.iMoveReasonType_ID
		,MT2.cDescription as Reason2
		,MT2.iMoveReasonType_ID as iMoveReason2Type_ID
		,ts.dtRowStart
		,ts.iProductLine_ID
			
	FROM   Tenant T (nolock)
    LEFT JOIN rw.vw_Invoices IM (nolock) ON (IM.iTenant_ID = T.iTenant_ID AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NOT NULL)
    LEFT JOIN TenantState ts (nolock) ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
    LEFT JOIN rw.vw_aptAddress_History AD (nolock) ON (AD.iAptAddress_ID = TS.iAptAddress_ID 
	<!--- AND (isNull(IM.dtInvoiceStart,getdate()) between AD.dtRowStart AND isNull(AD.dtRowEnd,getdate())) --->)
    LEFT JOIN AptType AT (nolock) ON (AT.iAptType_ID = AD.iAptType_ID AND AT.dtRowDeleted IS NULL)
    LEFT JOIN ResidencyType RT (nolock) ON (TS.iResidencyType_ID = RT.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
    LEFT JOIN MoveReasonType MT (nolock) ON (TS.iMoveReasonType_ID = MT.iMoveReasonType_ID AND MT.dtRowDeleted IS NULL)
    LEFT JOIN MoveReasonType MT2 (nolock) ON (TS.iMoveReason2Type_ID = MT2.iMoveReasonType_ID AND MT2.dtRowDeleted IS NULL)
	WHERE T.dtRowDeleted IS NULL AND T.csolomonkey = '#prompt0#' AND IsNull(AT.iAptType_id,0) > 0
    ORDER BY ts.dtrowstart desc
</CFQUERY>
<cfquery name="RRInvoice" datasource="#application.datasource#">
	Select count(IM.iInvoiceMaster_ID) as 'IMCount', sum(IM.mInvoiceTotal) as 'IMSum'
	From InvoiceMaster IM 
	where IM.dtrowdeleted is null
	and IM.bFinalized = 1
	and IM.cSolomonKey = '#prompt0#'
</cfquery>

 <cfquery name="GetInvoices" datasource="#application.datasource#">
	select distinct rim.iinvoiceMaster_id, t.itenant_id, iInvoiceNumber, cAppliesToAcctPeriod, mInvoiceTotal, rim.cSolomonKey, 
	isnull(bMoveInInvoice,0) as bMoveInInvoice, isnull(bMoveOutInvoice, 0) as bMoveOutInvoice
	,convert(varchar(10),rim.dtInvoiceStart,101) as StartDate
	,isnull(convert(varchar(10),rim.dtInvoiceEnd,101),convert(varchar(10),getdate(),101)) as EndDate 
	from InvoiceMaster rim
	join tenant t on t.csolomonkey = rim.csolomonkey
	where rim.cSolomonKey = '#prompt0#'
	and rim.bFinalized = 1
	and rim.dtrowdeleted is null and bMoveOutInvoice is not null
</cfquery>
<cfquery name="spMoveOutInvoice" DATASOURCE="#APPLICATION.datasource#">
		EXEC rw.sp_MoveOutInvoice
		@TenantID = #TenantInfo.itenant_id#,
		@iInvoiceMaster_ID = #GetInvoices.iinvoicemaster_id#  
</cfquery>
<cfquery name="qryTotalCharges" dbtype="query">
select sum(mamount * iquantity) as totalamount from spMoveOutInvoice
</cfquery>
<cfquery name="spPayments" DATASOURCE="#APPLICATION.datasource#">
	EXEC [rw].[sp_MoveOutPayments]
		@SolomonKey = '#prompt0#',
		@iInvoiceMaster_ID = #GetInvoices.iinvoicemaster_id#
</cfquery>
<cfquery name="qrypaymenttotal" dbtype="query">
select sum(amount) as totalamount from spPayments
</cfquery>

<cfquery name="spMoveOutDeposits" DATASOURCE="#APPLICATION.datasource#">
	EXEC [rw].[sp_MoveOutDeposits]
		@iTenant_ID = #TenantInfo.itenant_id#
</cfquery>
<cfquery name="qryDepositstotal" dbtype="query">
select sum(mamount) as  DepositsTotal from spMoveOutDeposits
</cfquery>

<cfquery name="qryPayer" DATASOURCE="#APPLICATION.datasource#">
select top 1 con.cfirstname
	,con.clastname
	,con.caddressline1
	,con.caddressline2
	,con.ccity
	,con.cstatecode
	,con.czipcode 
	,con.cphonenumber1 contactphonenumber1 
	,ltc.bispayer
from linktenantcontact ltc
join contact con on ltc.icontact_id = con.icontact_id 
 where ltc.itenant_id = #tenantinfo.itenant_id# and ltc.bispayer = 1 
 and con.dtrowdeleted is null and ltc.dtrowdeleted is null
 order by con.icontact_id desc
</cfquery>
<cfquery name="spContactPhone" DATASOURCE="#APPLICATION.datasource#">
EXEC	 rw.sp_InvoiceContact
		@invoiceDate = '#spMoveOutInvoice.dtinvoicestart#',
		@cSolomonKey = '#tenantinfo.csolomonkey#',
		@TenantID = '#tenantinfo.itenant_id#'
</cfquery>
<body>

<cfdocument  format="PDF"  orientation="portrait" margintop="2" marginbottom="3" marginleft=".5" marginright=".5">
		<cfdocumentitem type="header"  evalAtPrint="true">  
			<cfoutput>
				<table width="100%">
					<tr>
						<td colspan="2" align="center">
							<h1 style="text-align:center; text-decoration:underline;">MOVE OUT SUMMARY</h1>
						</td>
					</tr>			
					<tr>
						<td   style="text-align:left;"> <img src="../../images/Enlivant_logo.jpg"/ >
						<br /><h2>#HouseData.cname#   <br />
						#HouseData.Caddressline1#    <br />
						#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    
						<br />(#left(Housedata.cphonenumber1,3)#) #mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
						</h2></td>
						<td align="right"><h2>For questions regarding this account,<br />please contact us at 888-252-5001 Ext 8992</h2></td>
					</tr>
				</table>
			</cfoutput>
		</cfdocumentitem>
		<table width="100%" style="border-bottom: 1px solid black; border-top: 1px solid black;">
				<tr>
					<td colspan="1" style="border-bottom: 1px solid black;font-size:12px; font-weight:bold;">
					Tenant Information:</td>
					<td colspan="4">&nbsp;</td>					
				</tr>
			<cfoutput>

				<tr>
					<td style="font-size:12px">Account Number:</td>
					<td style="font-size:12px"> #TenantInfo.csolomonkey#</td>
					<td style="font-size:12px">Unit Number:</td>
					<td style="font-size:12px">#TenantInfo.cAptNumber#</td>
					<td style="font-size:12px">Notice Date:</td>
					<td style="font-size:12px">#dateformat(TenantInfo.dtNoticeDate,'mm/dd/yyyy')#</td>
				</tr>
				<tr>
					<td style="font-size:12px">Tenant Name:</td>
					<td style="font-weight:bold; font-size:12px"> #TenantInfo.cFirstName# #TenantInfo.cLastname#</td>
					<td style="font-size:12px">Apartment Size:</td>
					<td style="font-size:12px">#TenantInfo.AptType#</td>
					<td style="font-size:12px">Physical Move Out Date:</td>
					<td style="font-size:12px">#dateformat(TenantInfo.dtMoveOut,'mm/dd/yyyy')#</td>
				</tr>		
				<tr>
					<td style="font-size:12px">Move In Date:</td>
					<td style="font-size:12px"> #dateformat(TenantInfo.dtmovein,'mm/dd/yyyy')#</td>
					<td style="font-size:12px">Payment Method:</td>
					<td style="font-size:12px">Respite</td>
					<td style="font-size:12px">Charge Through Date:</td>
					<td style="font-size:12px">#dateformat(TenantInfo.dtChargeThrough,'mm/dd/yyyy')#</td>
				</tr>	
				<cfif qryPayer.contactphonenumber1 is not ''>
					<tr>
						<td style="font-size:12px">Contact Phone Number:</td>
						<td colspan="2" style="font-size:12px">
						<cfif IsNumeric(#qryPayer.contactphonenumber1#)>
(#left(qryPayer.contactphonenumber1,3)#)  #mid(qryPayer.contactphonenumber1,4,3)# - #right(qryPayer.contactphonenumber1,4)#
						<cfelse>
						#qryPayer.contactphonenumber1#
						</cfif> </td>
						<td colspan="3">&nbsp;</td>	
					</tr>		
				</cfif>			
			</cfoutput>
		</table>
		<table width="100%" >
		<cfoutput>
		<cfset InvoiceDate = CreateDate(year(spMoveOutInvoice.dtInvoiceStart),month(spMoveOutInvoice.dtInvoiceStart),1)>
		
			<tr>
				<td colspan="3">&nbsp;</td>
				<td colspan="2" style="text-align:right; font-size:14px; font-weight:bold;">Balance Due as of: #dateformat(InvoiceDate,'mm/dd/yyyy')#:</td>
 				<td style="text-align:right; font-size:14px; font-weight:bold;" > #numberformat(spMoveOutInvoice.mLastInvoiceTotal,'$(999,999.99)')#</td>
			</tr>		
			<tr>
				<td colspan="2" style="border-bottom: 1px solid black;font-size:12px; font-weight:bold;" >
				Transaction Summary:</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>	
												
			</tr>
			<tr>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px" >AR Type</td>
				<td colspan="2" style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Description</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Document Date</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Amount</td>
				<td>&nbsp; </td>	
				<!--- <td>&nbsp;</td> --->															
			</tr>	
		<cfloop query="spPayments">
			<tr>
				<td style=" font-weight:bold; font-size:12px;" >
				<cfif #doctype# is 'CM'>
				Credit Memo
				<cfelseif #doctype# is 'PA'>
				Payment
				<cfelse>
				&nbsp;
				</cfif></td>
				<td colspan="2" style="font-weight:bold; font-size:12px">#docdesc#</td>
				<td style="font-weight:bold; font-size:12px">#dateformat(docdate,'mm/dd/yyyy')#</td>
				<td style="font-weight:bold; font-size:12px"> #numberformat( amount,'$(999,999.99)' )#</td>
				<td style="font-weight:bold; font-size:12px">&nbsp;</td>	
				<!--- <td>&nbsp;</td>	 --->														
			</tr>	
		</cfloop>
			<tr>
				<td>&nbsp;</td>
				<td >&nbsp;</td>
				<td>&nbsp;</td>
				<td colspan="2" style="text-align:right; font-size:14px; font-weight:bold;">Total Transactions:</td>
				<td style="text-align:right; font-size:14px; font-weight:bold;">#numberformat(qrypaymenttotal.totalamount,'$(999,999.99)')#</td>
			</tr>
	<!---  --->		
			<tr>
				<td colspan="2"  style="border-bottom: 1px solid black;font-size:12px; font-weight:bold;" >
				Current Tenant Charges:</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>	
			</tr>
			<tr>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px" >Period</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Description/Comments</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Amount</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px"> Quantity</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Price</td>	
				<td>&nbsp;</td>															
			</tr>	
		<cfloop query="spMoveOutInvoice">
			<tr>
				<td style="font-weight:bold; font-size:12px;" >#DetailAppliestoAcctPeriod#</td>
				<td style="font-weight:bold; font-size:12px">#cDescription#</td>
				<td style="font-weight:bold; font-size:12px"> #numberformat( mamount,'$(999,999.99)' )#</td>
				<td style="font-weight:bold; font-size:12px">#iQuantity#</td>
				<cfset sumtotal = mamount * iquantity>
				<td style="font-weight:bold; font-size:12px">#numberformat(sumtotal,'$(999,999.99)' )#</td>	
				<td>&nbsp;</td>															
			</tr>	
		</cfloop>
			<tr>
				<td>&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td colspan="2" style="text-align:right; font-size:14px; font-weight:bold;">Total Current Charges:</td>
				<td style="text-align:right; font-size:14px; font-weight:bold;">
				#numberformat(qryTotalCharges.totalamount,'$(999,999.99)' )#</td>
			</tr>	
	<!---  --->		
	<cfif #spMoveOutDeposits.recordcount# gt 0>
			<tr>
				<td colspan="2" style="border-bottom: 1px solid black; font-size:12px; font-weight:bold;" >
				Refundable Deposits:</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>	
			</tr>
			<tr>
				<td colspan="2" style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Description</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Amount</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Quantity</td>
				<td style="border-bottom: 1px solid black; font-weight:bold; font-size:12px">Price</td>	
				<td>&nbsp;</td>															
			</tr>	
		<cfloop query="spMoveOutDeposits">
			<tr>
				<td colspan="2" style="font-weight:bold; font-size:12px;" >#cdescription#</td>
				<td style="font-weight:bold; font-size:12px">#numberformat(mamount,'$(999,999.99)')#</td>
				<td style="font-weight:bold; font-size:12px">#iquantity#</td>
				<cfset sumtotal = mamount * iquantity>
				<td style="font-weight:bold; font-size:12px">#numberformat(sumtotal,'$(999,999.99)')#</td>	
				<td>&nbsp;</td>															
			</tr>	
		</cfloop>
		<tr >
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td>&nbsp;</td>
			<td colspan="2" style="text-align:right; font-size:14px; font-weight:bold;">Total Deposits:</td>
			<td style="text-align:right; font-size:14px; font-weight:bold;">
			#numberformat(qryDepositstotal.DepositsTotal,'$(999,999.99)' )#</td>
		</tr>	
		</cfif>
		<cfif IsNumeric(qryDepositstotal.DepositsTotal)> 
			<cfset DepositsTotal =  qryDepositstotal.DepositsTotal> 
		<cfelse>
			<cfset DepositsTotal = 0>
		</cfif>
		<cfif IsNumeric(qryTotalCharges.totalamount )> 
			<cfset totalamount = qryTotalCharges.totalamount> 
		<cfelse> 
			<cfset totalamount = 0>
		</cfif>	
		<cfif IsNumeric(qrypaymenttotal.totalamount )> 
			<cfset paymenttotal = qrypaymenttotal.totalamount> 
		<cfelse> 
			<cfset paymenttotal = 0>
		</cfif>	
		<cfif IsNumeric(spMoveOutInvoice.mLastInvoiceTotal )> 
			<cfset lastinvoicetotal = spMoveOutInvoice.mLastInvoiceTotal> 
		<cfelse> 
			<cfset lastinvoicetotal = 0>
		</cfif>	
		<cfset invtotal = totalamount
		+  paymenttotal
		+  DepositsTotal 
		+ lastinvoicetotal>		
		<cfif invtotal lt 0>
			
		<tr>
			<td colspan="3">&nbsp;</td>
			<td colspan="2" style="text-align:right; font-size:14px; font-weight:bold;">Amount to be refunded:</td>
			<td style="text-align:right; font-size:14px; font-weight:bold;">#numberformat(invtotal,'$(999,999.99)')#</td>
		</tr>
		<cfelse>
		<tr>
			<td colspan="3">&nbsp;</td>
			<td colspan="2" style="text-align:right; font-size:14px; font-weight:bold;">Total Amount Due: </td>
			<td style="text-align:right; font-size:14px; font-weight:bold;">#numberformat(invtotal,'$(999,999.99)')#</td>
		</tr>		
		</cfif>
<!--- 		<tr>
			<td colspan="6" style="text-align:center; border-top:1px dashed black;font-size:12px" >
			Cut along dashed line and return with payment
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
			<td style="font-size:12px">Account Number:</td>
			<td style="font-size:12px">#Tenantinfo.csolomonkey#</td>
		</tr>
		<tr>
			<td style="font-size:12px">&nbsp;</td>
			<td colspan="3" style="font-size:12px">Send Payments to:</td>
			<td style="font-size:12px">&nbsp;</td>
			<td style="font-size:12px">&nbsp;</td>
		</tr>		
		<tr>
			<td style="font-size:12px">&nbsp;</td>
			<td colspan="2" style="font-size:12px;"  >
				Enlivant<br />330 N. Wabash<br />Chicago, Il 60611<br />Attn: Collections Department</td>
			<td >&nbsp;</td>
			<td style="font-size:14px; font-weight:bold;">Total Amount Due:</td> 
			<td style="font-size:14px; font-weight:bold; border: 2px solid black; text-align:right;">
			 #numberformat(invtotal,'$(___,999,999.99)')#</td>
		</tr>		
		<tr>
			<td colspan="2">&nbsp;</td>
			<td colspan="2" style="font-weight:bold; font-size:12px; text-align:center;">Make checks payable to:<br />Enlivant</td>
			<td colspan="2">&nbsp;</td>
		</tr>
		<cfif qryPayer.bispayer is 1>
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>	
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>				
			<tr>
				<td>&nbsp;</td>
				<td  colspan="2" style="font-size:12px;">
					#qryPayer.cfirstname# #qryPayer.clastname#<br />
					#qryPayer.caddressline1# <br />
					<cfif  qryPayer.caddressline2 is not ''> #qryPayer.caddressline2#<br /></cfif>
					#qryPayer.ccity#, #qryPayer.cstatecode# #qryPayer.czipcode#  
				</td>
				<td colspan="3">&nbsp;</td>
			</tr>
		<cfelse>
			<tr>
				<td>&nbsp;</td>
				<td  colspan="2" style="font-size:12px;text-align:left;">No Move-Out Payer has been entered.</td>
				<td colspan="3">&nbsp;</td>
			</tr>	
		</cfif> --->
	</cfoutput>	
						
		</table>
		<cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
		<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>		
		<table width="100%">
		<tr>
			<td colspan="6" style="text-align:center; border-top:1px dashed black;font-size:12px" >
			Cut along dashed line and return with payment
			</td>
		</tr>
		<tr>
			<td colspan="4">&nbsp;</td>
			<td colspan="1" style="font-size:12px; text-align:right">Account Number:</td>
			<td colspan="1" style="font-size:12px">#Tenantinfo.csolomonkey#</td>
		</tr>
		<cfif invtotal lt 0>
			<tr>
				<td colspan="2">&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td colspan="2">&nbsp;</td>
			</tr>	
		<cfelse>
			<tr>
				<td style="font-size:13px">&nbsp;</td>
				<td colspan="3" style="font-size:13px">Send Payments to: <cfif invtotal gt 0> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"> <b>Make checks payable to: Enlivant</b></font> </cfif> </td></td>
				<td style="font-size:13px">&nbsp;</td>
				<td style="font-size:13px">&nbsp;</td>
			</tr>				
		</cfif>	
		<tr>
			<td colspan="1" style="font-size:12px">&nbsp;</td>
			<td colspan="2" style="font-size:13px;"  >
				Enlivant<br />330 N. Wabash<br />Chicago, Il 60611<br />Attn: Collections Department</td>
			<td colspan="1" >&nbsp;</td>
			<cfif invtotal lt 0>
				<td colspan="1" style="font-size:14px; font-weight:bold; text-align:right">
				Refund Amount:
				</td> 
				<td colspan="1" style="font-size:14px; font-weight:bold; border: 2px solid black; text-align:center">
				 #numberformat(invtotal,'$(___,999,999.99)')#
				 </td>						
			<cfelse>
				<td colspan="1" style="font-size:14px; font-weight:bold;text-align:right">
				Total Amount Due:
				</td> 					
				<td colspan="1" style="font-size:14px; font-weight:bold; border: 2px solid black; text-align:center">
				 #numberformat(invtotal,'$(___,999,999.99)')#
				 </td>
			 </cfif>
		</tr>		
		<!---<cfif invtotal lt 0>
			<tr>
				<td colspan="2">&nbsp;</td>
				<td colspan="2">&nbsp;</td>
				<td colspan="2">&nbsp;</td>
			</tr>					
		<cfelse>					
			<tr>
				<td colspan="2">&nbsp;</td>
				<td colspan="2" style="font-weight:bold; text-align:center;">Make checks payable to:<br />Enlivant</td>
				<td colspan="2">&nbsp;</td>
			</tr>
		</cfif>--->
		<cfif qryPayer.bispayer is 1>
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>	
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>
			<tr>
				<td colspan="6">&nbsp;</td>
			</tr>				
			<tr>
				<td>&nbsp;</td>
				<td  colspan="2" style="font-size:13px;">
					#qryPayer.cfirstname# #qryPayer.clastname#<br />
					#qryPayer.caddressline1# <br />
					<cfif  qryPayer.caddressline2 is not ''> #qryPayer.caddressline2#<br /></cfif>
					#qryPayer.ccity#, #qryPayer.cstatecode# #qryPayer.czipcode#  
				</td>
				<td colspan="3">&nbsp;</td>
			</tr>
		<cfelse>
			<tr>
				<td>&nbsp;</td>
				<td  colspan="2" style="font-size:13px;text-align:left;">No Move-Out Payer has been entered.</td>
				<td colspan="3">&nbsp;</td>
			</tr>	
		</cfif>
		</table>		
	<cfelse>
		<table width="100%">
			<tr>
				<td>Enlivant</td>
				<td style="font-size:small; text-align:right ">
				Printed: #dateformat(now(),'mm/22/yyyy')# #timeformat(now(),'h:mm tt')#
				</td>
				<td>#cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</td>
			</tr>
		</table>		
	</cfif>	
		</cfoutput>			
		</cfdocumentitem>
	<cfoutput>
<cfheader name="Content-Disposition" value="attachment;filename=RespiteMoveOutSummary-#HouseData.cname#-#trim(tenantinfo.cfirstName)##trim(tenantinfo.clastName)#.pdf"> 
	</cfoutput>			

</cfdocument>				
</body>
</html>
