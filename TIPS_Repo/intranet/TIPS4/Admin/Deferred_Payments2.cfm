	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Residents With NRF Installments</h1>
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
		,isNUll(ts.mAmtDeferred,0) as 'mAmtDeferred'
		,case when ts.itenantstatecode_id	> 2 then 'Moved Out' else 	'Current' end as 'Status'
		,IsNUll(ts.mAdjNRF,0)   as 'AdjNRF'
		,convert(varchar, rc.dtRowStart, 101) as dtRowStart
		,convert(varchar, rc.dtEffectiveStart, 101) as dtEffectiveStart
		,convert(varchar, rc.dtEffectiveEnd, 101) as dtEffectiveEnd
		,rc.dtRowDeleted
		,ts.imonthsdeferred	as 'nbrpaymnt'		
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
	 
		order by housename,t.clastname,t.cfirstname
</cfquery>
<body>
	<Table>
			<tr>
				<th colspan="14" style="font-size:14px;font-weight:400; text-align:center">Residents With NRF Installments</th>
			</tr>
			<tr>
				<td colspan="14">Create NRF Installment File: <input type="checkbox" name="downloadfile" onClick="location.href='NRFDeferredDwnld2.cfm'"></td>
			</tr>

		<cfoutput query="qryDeferred" group="HouseName">
			<tr style="background-color:##99CCCC">
				<td colspan="14">#HouseName# #iHouse_id# #cnumber# House TIPS period: #dateformat(dtCurrentTipsMonth, 'yyyymm')#</td>
			</tr>
			<tr  style="background-color:##FFFFCC">
				<td>Name</td>			
				<td>Solomon</td>
				<td>Move In Date</td>				
				<td>Installment Start Date</td>
				<td>Installment End Date</td>
				<td>Number of<br> Installments</td>
				<td>Completed Installments</td>
				<td>House Base NRF</td>
				<td>Adjusted NRF</td>
				<td>NRF Deferred</td>
				<td>Monthly Installment Amount</td>	
				<td>Cumulative Installments</td>
				<td>Remaining Balance</td>		
				<td>Status</td>		
			</tr>
			<cfoutput>
 		
				<cfif qryDeferred.mAdjNRF is ''>
					<cfset thismAdjNRF = 0>
				<cfelse >
					<cfset thismAdjNRF = qryDeferred.mAdjNRF>
				</cfif>		
				<cfif qrydeferred.mamtNRFPaid is ''>
					<cfset thismmamtNRFPaid = 0>
				<cfelse >
					<cfset thismmamtNRFPaid = qrydeferred.mamtNRFPaid>
				</cfif>					
				<cfif qrydeferred.nbrpaymnt is ''>
					<cfset thisnbrpaymnt = 1>
				<cfelse >
					<cfset thisnbrpaymnt = qrydeferred.nbrpaymnt>
				</cfif>			
				<cfif qrydeferred.Accum is ''>
					<cfset thisAccum = 0>
				<cfelse >
					<cfset thisAccum = qrydeferred.Accum>
				</cfif>		
				<cfif qrydeferred.nbrpaymnt is ''>
					<cfset thisnbrpaymnt = 0>
				<cfelse >
					<cfset thisnbrpaymnt = qrydeferred.nbrpaymnt>
				</cfif>				
				<cfif thisnbrpaymnt gt 0>							
					<cfset monthlypayment = abs((thismAdjNRF- thismmamtNRFPaid)/thisnbrpaymnt) * -1>
					<cfset rembal = numberformat((thismAdjNRF - thismmamtNRFPaid  - thisAccum),'999999.00')>
					<cfset paymentrem =  thisnbrpaymnt - dispnbrpaymentmade> 
					<cfset dspAccum =   abs(Accum)  * -1>
 				<cfelse>
					<cfset monthlypayment = 0>
					<cfset rembal = 0>
					<cfset paymentrem = 0> 
					<cfset dspAccum =  0>
				</cfif>
				<tr>
					<td nowrap="nowrap"><a href="Deferred_Payments3.cfm?tenantid=#qryDeferred.itenant_id#">#clastname#</a>, #cfirstname# <br> #itenant_id#</td>			
					<td> #csolomonkey# </td>
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
	</Table>
</body>
		<cfinclude template="../../footer.cfm">	
