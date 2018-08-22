<!--- |S Farmer    | 2015-01-12 | 116824      | Final Move-in Enhancements                                       |
	  |M Striegel  | 2018-12-18 | Added WITH (NOLOCK) to the queries  and cfqueryparam  converted to use object  |

 --->


<cfset oCommunityFee = CreateObject("component","intranet.TIPS4.CFC.components.MoveIn.CommunityFeePayment")>
<cfparam name="MDEFERREDAMT" default="0">

	<cfset tenantInfo = oCommunityFee.getTenantInfo(datasource=application.datasource,tenantID=form.itenant_ID)>

	<cfif IsDefined('COMMFEEPAYMENTSEL') and COMMFEEPAYMENTSEL is not ''>
		<cfif COMMFEEPAYMENTSEL gt 1>
			<cfquery name="qChargeID"  DATASOURCE='#APPLICATION.datasource#'>
				Select cdescription from chargetype WITH (NOLOCK) where ichargetype_id = 1741
			</cfquery>
			<cfif tenantinfo.mAdjNRF is not ''>
				<cfset NRFAmt = tenantinfo.mAdjNRF>
				<cfset mDeferredAmt =   ((tenantinfo.mAdjNRF/COMMFEEPAYMENTSEL * 100) / 100)>
			<cfelse>
				<cfset  NRFAmt = tenantinfo.mBaseNRF>
				<cfset mDeferredAmt =   ((tenantinfo.mBaseNRF/COMMFEEPAYMENTSEL * 100) / 100)>
			</cfif>
			<cfif COMMFEEPAYMENTSEL is 1>
				<cfset CommFeePaymntAmt =  NRFAmt  >
				<cfset CommDateEnd =   #session.tipsmonth# >	
				<cfset mAmtDeferred =  0>		
			<cfelseif COMMFEEPAYMENTSEL is 2>
				<cfset CommFeePaymntAmt =    mDeferredAmt >
				<cfset CommDateEnd =   #session.tipsmonth# > <!--- dateadd('M', 1, #session.tipsmonth#) --->
				<cfset mAmtDeferred =  0>
			<cfelse>
				<cfset CommFeePaymntAmt =  mDeferredAmt >	
				<cfset CommDateEnd = dateadd('M', 1, #session.tipsmonth#)>		<!--- was 2 --->			
			</cfif>
			
			<cfset qryRecurrChg = oCommunityFee.getRecurringCharge(houseID=tenantInfo.iHouse_Id,chargeSet=tenantInfo.chargeset,tenantID=tenantInfo.iTenant_Id)>
			<cfset qryCommFeeCharge = oCommunityFee.getCommunityFeeCharge(houseID=tenantInfo.iHouse_ID,chargeset=tenantInfo.chargeset)>				
			
			<cfif qryRecurrChg.recordcount is 0>
				<cfset qInsertRecurring = oCommunityFee.InsertRecurringCharges(tenantID=tenantInfo.iTenant_ID,chargeID=qryCommFeeCharge.iCharge_ID,effectiveStart=#now()#,effectiveEnd=commdateend,quantity=1,description=#Trim(qChargeID.cDescription)#,amount=commFeePaymntAmt,comments="Recurring Comm Fee created at move in",acctstamp=session.acctStamp,userID=session.userID,rowstart=#now()#)>	
			<cfelse>
				<cfset qUpdRecurringChg = oCommunityFee.RecurringCharge(amount=commFeePaymntAmt,effectiveEnd=commDateEnd,tenantID=tenantInfo.iTenant_id,recurringChargeID=qryRecurrChg.irecurringCharge_Id)>
			</cfif>	
		</cfif>
		<cfset updCommPaymnt = oCommunityFee.CommunityPayment(monthDeferred=COMMFEEPAYMENTSEL,amount=mDeferredAmt,tenantID=form.iTenant_ID)>		
	</cfif>
 	<CFLOCATION URL="MoveInCredits.cfm?ID=#form.iTenant_ID#&MID=#form.iInvoiceMaster_ID#&thisacctperiod1=#form.thisacctperiod1#&thisacctperiod2=#form.thisacctperiod2#&NrfDiscApprove=" > 

