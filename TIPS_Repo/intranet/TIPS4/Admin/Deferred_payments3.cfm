	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Residents With NRF Installments Payment Detail</h1>
<!---  
 |sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                             |
 |sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                    |
 --->  	
	
<cfquery name="qryDeferred"  datasource="#application.datasource#">
		select
		t.itenant_id 
		,t.csolomonkey 
		,t.cfirstname
		, t.clastname
		, h.cname as housename
		,h.ihouse_id
		, h.iOpsArea_ID 
		,h.cnumber
		,OPSA.cName	as 'OPSname'
		,OPSA.iRegion_ID
		,reg.cName	as 'Regionname'			
		, HL.dtCurrentTipsMonth as dtCurrentTipsMonth	
		,cast(cast(ts.mBaseNRF as decimal(10,2)) as varchar(10))  as 'BaseNRF'
 
		<!--- ,cast(cast(abs(rc.mAmount) as decimal(10,2)) as varchar(10))  as 'DeferredNRF '  --->
		,rc.cdescription
		,ts.cNRFAdjApprovedBy
		,ts.dtMoveIn	
		,ts. mAdjNRF 
		,ts.cNRFAdjApprovedBy 
		,ts.dtNRFAdjApproved 
		,ts.iNRFMid 
		,ts. bNRFPend 
		,ts.cNRFDiscAppUsername 
		,ts. mAmtDeferred 
		,ts. iMonthsDeferred 
		,ts.mAmtNRFPaid 
		,ts.imonthsdeferred	as 'nbrpaymnt'	
		,isNUll(ts.mAmtDeferred,0) as 'mAmtDeferred'
		,case when ts.itenantstatecode_id	> 2 then 'Moved Out' else 	'Current' end as 'Status'
		,IsNUll(ts.mAdjNRF,0)   as 'AdjNRF'
		,convert(varchar, rc.dtRowStart, 101) as dtRowStart
		,convert(varchar, rc.dtEffectiveStart, 101) as dtEffectiveStart
		,convert(varchar, rc.dtEffectiveEnd, 101) as dtEffectiveEnd
		,rc.dtRowDeleted
	
		,IsNUll((	select count (mamount)
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =  t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null			
			and im.bFinalized = 1
			),0) as dispnbrpaymentmade
		,	IsNUll((select sum (mamount)
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =   t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null
			and im.bFinalized = 1
			),0) as Accum
			,ts.mAdjNRF
			,ts.mAmtNRFPaid 
		from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join house h on t.ihouse_id = h.ihouse_id
		join dbo.OpsArea OPSA on OPSA.iOpsArea_ID  = h.iOpsArea_ID
		join dbo.Region reg on reg.iRegion_ID = OPSA.iRegion_ID
		join dbo.RecurringCharge RC on RC.iTenant_ID = t.iTenant_ID 
		JOIN HouseLog HL ON h.iHouse_ID = HL.iHouse_Id
		join charges chg on chg.iCharge_ID = RC.iCharge_ID and chg.ichargetype_id = 1741
 
		where ts.bIsNRFDeferred = 1
		  and   rc.dtEffectiveEnd >= getdate() 
		  and t.itenant_id = #url.tenantid#
	 
		order by housename,t.clastname,t.cfirstname
</cfquery>
<cfquery name="qryInvPayment"   datasource="#application.datasource#">
	  select IM.iInvoiceNumber, inv.cDescription, inv.mAmount  , inv.cAppliesToAcctPeriod
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and im.csolomonkey = #qryDeferred.csolomonkey# 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null
			and im.bFinalized = 1
			ORDER BY iInvoiceNumber
			 
</cfquery>
<body>
	<Table>
			<tr>
				<th colspan="12" style="font-size:14px;font-weight:400; text-align:center">Residents With NRF Installments</th>
			</tr>

		<cfoutput query="qryDeferred" group="HouseName">
			<tr style="background-color:##99CCCC">
				 <td  colspan="3">#clastname#, #cfirstname#</td>			
					<td colspan="3">Solomon: #csolomonkey# </td> 
					<td colspan="6"></td>
			</tr>
			<tr  style="background-color:##FFFFCC">
 
				<th>Move In Date</th>				
				<th>Installment Start Date</th>
				<th>Installment End Date</th>
				<th>Number of<br> Installments</th>
				<th>Completed Installments</th>
				<th>House Base NRF</th>
				<th>Adjusted NRF</th>
				<th>NRF Deferred</th>
				<th>Monthly Installment</th>		
				<th>Cumulative Installments</th>
				<th>Remaining Balance</th>		
				<th>Status</th>		
			</tr>
			<cfoutput>
 		
				<cfset monthlypayment = abs((qryDeferred.mAdjNRF- qrydeferred.mamtNRFPaid)/nbrpaymnt) * -1>
				<cfset rembal = numberformat((qryDeferred.mAdjNRF - qryDeferred.mAmtNRFPaid  - Accum),'999999.00')>
				<cfset paymentrem =  nbrpaymnt - dispnbrpaymentmade> 
				<cfset dspAccum =   abs(Accum)  * -1>
 
				<tr>
					
					<td>#dateformat(dtmovein, 'mm/dd/yyyy')#</td>					
					<td>#dateformat(dtEffectiveStart, 'mm/dd/yyyy')#</td>
					<td>#dateformat(dtEffectiveEnd, 'mm/dd/yyyy')#</td>
					<td style="text-align:center">#nbrpaymnt#</td>
					<td style="text-align:center">#dispnbrpaymentmade#</td>
					<td>#numberformat(BaseNRF, '999999.99')#</td> 
					<td>#numberformat(AdjNRF, '999999.99')#</td> 
					<td>#numberformat(mAmtDeferred, '999999.99')#</td>
					<td>#numberformat(round(monthlypayment*100)/100, '99999.99')#</td>
					<td>#numberformat(dspAccum, '999999.99')#</td> 
					<td>#numberformat(rembal, '999999.99')#</td>
					<td nowrap="nowrap">#Status#</td>					
				</tr>
			</cfoutput>
		</cfoutput>
		<tr>
			<th colspan="12">Invoice Payment Payment History</th>	
								
		</tr>		
		<tr>
			<th>Account Period</th>
			<th>Invoice Number</th>
			<th colspan="3">Description</th>
			<th>Amount of Payment</th>	
			<th colspan="7">&nbsp;</th>					
		</tr>
		<cfoutput query="qryInvPayment">
		<tr>
			<TD>#cAppliesToAcctPeriod#</TD>
			<td >#iInvoiceNumber#</td>
			<td colspan="3">#cDescription#</td>
			<td>#mAmount#</td>	
			<tD colspan="6">&nbsp;</tD>									
		</cfoutput>
	</Table>
</body>
		<cfinclude template="../../footer.cfm">	
