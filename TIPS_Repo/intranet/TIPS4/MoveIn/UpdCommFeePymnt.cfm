<!--- |S Farmer    | 2015-01-12 | 116824      | Final Move-in Enhancements                                       |
	  |M Striegel  | 2018-12-18 | Added WITH (NOLOCK) to the quries                                              |

 --->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<cfparam name="MDEFERREDAMT" default="0">
<cfdump var="#form#">

	<CFQUERY NAME = "TenantInfo" DATASOURCE = "#APPLICATION.datasource#">  
		SELECT	*, (T.cFirstName + ' ' + T.cLastName) as FullName, 
		t.bispayer, 
		t.ihouse_id,
		ts.iTenantStateCode_ID, 
		ts.iResidencyType_ID,
		h.cName HouseName, 
		TS.dtMoveIn, 
		ts.mbasenrf, 
		ts.madjnrf, 
		ts.dtrenteffective,
		ts.iMonthsDeferred,
		chgset.cname as chargeset
		FROM	TENANT	T WITH (NOLOCK)
		Join TenantState TS WITH (NOLOCK) on T.itenant_id = TS.itenant_id
		JOIN 	House H WITH (NOLOCK) on h.ihouse_id = T.ihouse_id
		JOIN ChargeSet chgset on h.ichargeset_id = chgset.ichargeset_id
		WHERE	T.iTenant_ID = #form.itenant_id#
	</CFQUERY>	

	<cfif IsDefined('COMMFEEPAYMENTSEL') and COMMFEEPAYMENTSEL is not ''>
		<cfif COMMFEEPAYMENTSEL gt 1>
			<cfquery name="qChargeID"  DATASOURCE='#APPLICATION.datasource#'>
				Select cdescription from chargetype where ichargetype_id = 1741
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

			
			<cfquery name="qryRecurrChg" DATASOURCE='#APPLICATION.datasource#'>
				Select irecurringCharge_id from recurringcharge rchg WITH (NOLOCK) 
				join Charges chg  WITH (NOLOCK) on rchg.icharge_id = chg.icharge_id
				where chg.ichargetype_id = 1741 
				and chg.ihouse_id = #TenantInfo.ihouse_id# 
				and chg.dtrowdeleted is null 
				and chg.cchargeset = '#TenantInfo.chargeset#'
				and rchg.itenant_id = #TenantInfo.iTenant_id# 
				and rchg.dtrowdeleted is null
			</cfquery>
			<cfquery name="qryCommFeeCharge" DATASOURCE='#APPLICATION.datasource#'>
				Select icharge_id 
				From Charges chg WITH (NOLOCK)
				where chg.ichargetype_id = 1741 
				and chg.ihouse_id = #TenantInfo.ihouse_id# 
				and chg.dtrowdeleted is null 
				and chg.cchargeset = '#TenantInfo.chargeset#'
			</cfquery>			
			<cfif qryRecurrChg.recordcount is 0>
				<CFQUERY NAME='qInsertRecurring' DATASOURCE='#APPLICATION.datasource#'>
					INSERT INTO RecurringCharge
					( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, 
					mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
					VALUES
					( #TenantInfo.iTenant_id# 
						,#qryCommFeeCharge.icharge_id# 
						, #CreateODBCDateTime(now())#  
						,#CreateODBCDateTime(CommDateEnd)# 
						,1 
						,'#TRIM(qChargeID.cDescription)#' 
						,#CommFeePaymntAmt#
						,'Recurring Comm Fee created at move in' 
						,#CreateODBCDateTime(SESSION.AcctStamp)# 
						,#SESSION.USERID# 
						, #CreateODBCDateTime(now())#   )
				</CFQUERY> 	
			<cfelse>
				<cfquery name="UpdRecurringChg" DATASOURCE='#APPLICATION.datasource#'>
				update RecurringCharge
				set mAmount = #CommFeePaymntAmt#
				,dtEffectiveEnd = #CreateODBCDateTime(CommDateEnd)#
				where   itenant_id = #TenantInfo.iTenant_id#
					and irecurringCharge_id = #qryRecurrChg.irecurringCharge_id#
				</cfquery>
			</cfif>	
		</cfif>
		<cfquery name="updCommPaymnt"  DATASOURCE = "#APPLICATION.datasource#">
			Update tenantstate
			set iMonthsDeferred = #COMMFEEPAYMENTSEL#
			,mAmtDeferred = #mDeferredAmt#
			where itenant_id = #form.itenant_id#
		</cfquery>
	</cfif>
<body>

 	<CFLOCATION URL="MoveInCredits.cfm?ID=#form.iTenant_ID#&MID=#form.iInvoiceMaster_ID#&NrfDiscApprove="> 
</body>
</html>
