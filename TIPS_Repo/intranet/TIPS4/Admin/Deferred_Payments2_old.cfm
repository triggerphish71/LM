	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Residents With NRF Installments</h1>
<!---  
 |sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                             |
 |sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                    |
 --->  	
<!--- 	<cfinclude template="../Shared/HouseHeader.cfm"> --->



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
<!--- 		,cast(cast((ts.mAdjNRF - ts.mBaseNRF) as decimal(10,2)) as varchar(10))  as 'AdjNRF' --->
		,cast(cast(abs(rc.mAmount) as decimal(10,2)) as varchar(10))  as 'DeferredNRF'  
		,rc.cdescription
		,ts.cNRFAdjApprovedBy
		,ts.dtMoveIn	
		,ts.imonthsdeferred	as 'nbrpaymnt'
		,ts.itenantstatecode_id		
		,ts.mAmtDeferred   as 'AdjNRF'
		,convert(varchar, rc.dtRowStart, 101) as dtRowStart
		,convert(varchar, rc.dtEffectiveStart, 101) as dtEffectiveStart
		,convert(varchar, rc.dtEffectiveEnd, 101) as dtEffectiveEnd
		,rc.dtRowDeleted
		,abs(datediff(m,HL.dtCurrentTipsMonth ,rc.dtEffectiveEnd  )) as 'paymentrem'
 		<!--- ,abs(datediff(m,rc.dtEffectiveStart,rc.dtEffectiveEnd) + 1) as 'nbrpaymnt'  ---> 
 		,abs(datediff(m,rc.dtEffectiveStart,HL.dtCurrentTipsMonth )) as 'paymentsmade' 
		,	(select sum (mamount)
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =   t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveInInvoice is null) as Accum
		,(	select count (mamount)
			from invoicedetail inv  
			join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	itenant_id =  t.itenant_id 
			and inv.ichargetype_id = 1741 
			and im.bMoveInInvoice is null) as dispnbrpaymentmade
		from tenant t
		join tenantstate ts on t.itenant_id = ts.itenant_id
		join house h on t.ihouse_id = h.ihouse_id
		join dbo.OpsArea OPSA on OPSA.iOpsArea_ID  = h.iOpsArea_ID
		join dbo.Region reg on reg.iRegion_ID = OPSA.iRegion_ID
		join dbo.RecurringCharge RC on RC.iTenant_ID = t.iTenant_ID 
		JOIN HouseLog HL ON h.iHouse_ID = HL.iHouse_Id
		join charges chg on chg.iCharge_ID = RC.iCharge_ID and chg.ichargetype_id = 1740
 
		where ts.bIsNRFDeferred = 1
		  and   rc.dtEffectiveEnd >= getdate() 
		 <!---  AND rc.mAmount  <> 0 --->
		order by housename,t.clastname,t.cfirstname
</cfquery>
<body>
	<Table>
			<tr>
				<td colspan="14" style="font-size:14px;font-weight:400; text-align:center">Residents With NRF Installments</td>
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
				<td>NRF Paid by Installments</td>
				<td>Monthly Installment Amount</td>	
				<td>Cumulative Installments</td>
				<td>Ending Balance</td>		
				<td>Status</td>		
			</tr>
			<cfoutput>
									<cfif dtEffectiveStart  gt '2012-07-17'>
										<cfset paymentsmade =  paymentsmade + 1>
									<cfelse>
										<cfset paymentsmade =  paymentsmade>
									</cfif>		
									<cfset monthlypayment = AdjNRF\nbrpaymnt>
									<cfset rembal = numberformat((qryDeferred.DeferredNRF- Accum),'999999.00')>
<!--- 									<cfif paymentsmade is nbrpaymnt>	
										<cfset monthlypayment =   numberformat(DeferredNRF - ((qryDeferred.DeferredNRF/qryDeferred.nbrpaymnt) *  (paymentsmade -1)) ,'999999.00')   >
										<cfset Accum1 =  (monthlypayment ) *  (paymentsmade -1) >
										<cfset Accum2 = monthlypayment + Accum1>
										<cfset Accum = numberformat((Accum2),'999999.00')>
										<cfset rembal = numberformat((qryDeferred.DeferredNRF- Accum),'999999.00')>
										<cfset dispnbrpaymentmade = paymentsmade>
									<cfelseif paymentsmade gt nbrpaymnt>	
									 
										<cfset monthlypayment =   0   >
										<cfset Accum = numberformat(qryDeferred.DeferredNRF,'999999.00')>
										<cfset rembal = 0>
										<cfset dispnbrpaymentmade = nbrpaymnt>
										 
									<cfelse>
										<cfset monthlypayment =  numberformat(((qryDeferred.DeferredNRF/qryDeferred.nbrpaymnt) * -1),'999999.00')>									
										<cfset Accum = numberformat((monthlypayment * qryDeferred.paymentsmade),'999999.00')>
										<cfset rembal = numberformat((qryDeferred.DeferredNRF + Accum),'999999.00')>
										<cfset dispnbrpaymentmade = paymentsmade>
									</cfif> --->
			
				<tr>
					<td>#clastname#, #cfirstname#  #itenant_id#</td>			
					<td> #csolomonkey# </td>
					<td>#dateformat(dtmovein, 'mm/dd/yyyy')#</td>					
					<td>#dateformat(dtEffectiveStart, 'mm/dd/yyyy')#</td>
					<td>#dateformat(dtEffectiveEnd, 'mm/dd/yyyy')#</td>
					<td style="text-align:center">#nbrpaymnt#</td>
					<td style="text-align:center">#dispnbrpaymentmade#</td>
					<td>#BaseNRF#</td> 
					<td>#AdjNRF#</td> 
					<td>#DeferredNRF#</td>
					<td>#monthlypayment#</td>
					<td>#Accum#</td> 
					<td>#rembal#</td>
					<td nowrap="nowrap"><cfif itenantstatecode_id gt 2> Moved Out</cfif></td>					
				</tr>
			</cfoutput>
		</cfoutput>
	</Table>
</body>
		<cfinclude template="../../footer.cfm">	
