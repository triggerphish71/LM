<!--- Added for Update Medicaid Residents February 2015  this unit for New Jersey Houses              |
|SFarmer,     | 2015-09-28 |             | Medicaid, Memory Care Updates                              |
|MShah        |            |             |                                                            |
 ------------------------------------------------------------------------------------------------  --->  
  
    <!---	Check to see if there are any charges for this invoice --->
	<cfif IsDefined('form.mStateMedAidAmtBSFD') and (mStateMedAidAmtBSFD gt 0)	>						
		<cfquery name="UpdateBSFTenant" datasource="#application.datasource#"> <!---mamta change the query--->
			Update TenantState
			set mBSFOrig =  #mStateMedAidAmtBSFD#
			    ,mMedicaidcopay=0
			where itenant_id = #tenant.itenant_id#
		</cfquery>		  
	</cfif>
    <cfquery name="qRecordCheck" datasource="#application.datasource#">
    select Count(*) as count from InvoiceDetail where iInvoiceMaster_ID = #variables.iInvoiceMaster_ID# and dtRowDeleted is null
    </cfquery>
    <cfif qRecordCheck.RecordCount EQ 0 or qRecordCheck.RecordCount EQ "" or qRecordCheck.count EQ 0>
      <!--- If there are no details automatically add a zero charge to the 3011 medicaid co-pay account --->
		<cfquery name="qMedZeroCharge" datasource="#application.datasource#">
			select c.*
			from ChargeType ct
			join Charges c on c.iChargeType_ID = ct.iChargeType_ID
			where ct.dtRowDeleted is null and c.dtRowDeleted is null 
			and ct.bIsMedicaid is not null 
			<!--- and ct.bIsDaily is null  --->
			<!---mamta added this for WI--->
			<cfif #session.qselectedhouse.cstatecode# is 'WI'>
			and cGLAccount in (3091,3092)
			<cfelse><!---end--->
			and cGLAccount in (3011, 3012)
			</cfif>
			and c.cChargeSet = '#getHouseChargeset.CName#'
			and c.ihouse_id = #tenant.ihouse_id#
		</cfquery>
		<cfquery name="tenantype" datasource="#APPLICATION.datasource#"> 
		Select ts.iresidencytype_id, t.ihouse_id, dtmovein, h.cname, ts.mMedicaidCopay, t.csolomonkey, ts.mBSFOrig, h.cstatecode
		from tenant t join tenantstate ts on t.itenant_id = ts.itenant_id
		join house h on t.ihouse_id = h.ihouse_id
		where t.itenant_id =  #tenant.itenant_id#
		</cfquery>
  <cfdump var="#tenantype#"> 
		<cfquery name="qTenantCopay" datasource="#application.datasource#">
			Select mMedicaidCopay from tenantstate  where itenant_id =  #tenant.itenant_id#
		</cfquery>	
<!--- 		<cfdump var="#qTenantCopay#">  ---> 
<!--- 	 <cfoutput>
	 <cfdump var="#qMedZeroCharge#" label="qMedZeroCharge">
	<cfdump var="#qryHouseMedicaid#" label="qryHouseMedicaid">	 
	<cfdump var="#MonthList#"  label="MonthList">
	</cfoutput> ---> 
      <!--- Insert Zero amount Mediciad Charge Allow for join between InvoiceMaster and Detail --->
    <cfloop from=1 TO='#ArrayLen(MonthList)#' step='1' index=i>	 
		<cfif  ( #MonthList[i]#   LT  #session.TIPSMonth# )>
			<cfset CoPayDaysInMonth = #DaysInMonth(MonthList[i])#>
			<cfset MoveInPeriod = Year(#MonthList[i]#) & DateFormat(#MonthList[i]#,"mm")>
			<cfset monthdays[i] = #ChargeDays[i]#>
			<cfset CoPayDays = (#ChargeDays[i]#/#CoPayDaysInMonth#)>			
			<cfloop query="qMedZeroCharge"> 
				<cfif tenantype.mMedicaidCopay is ''>
					<cfset StateMedicaidChg = (#qMedZeroCharge.mAmount# * #ChargeDays[i]#)>
 				<!---Mshah added here--->
 				<cfelseif tenantype.cstatecode eq 'DE' >
 				<cfset StateMedicaidChg = (#qMedZeroCharge.mAmount# * #ChargeDays[i]#)>
 				<!---Mshah end--->
				<cfelse>
					<cfset StateMedicaidChg = (#qMedZeroCharge.mAmount# * #ChargeDays[i]#) - 
						(#tenantype.mMedicaidCopay# * #CoPayDays#)>
					<!---Mshah added here for state medicaid in IA--->
					   <cfif StateMedicaidChg LT 0>
					   		<cfset StateMedicaidChg=0>
					   </cfif>
				</cfif>				
				<cfif #qMedZeroCharge.iChargeType_ID# is 1661 >
					
					<cfset CoPayProRate = (#tenantype.mMedicaidCopay# * #CoPayDays#)>
					
					<cfoutput>
						<br />
						
						Copay: #CoPayProRate# : #CoPayDays# : #tenantype.mMedicaidCopay# * #ChargeDays[i]#/#CoPayDaysInMonth#
							 ::#MoveInPeriod# :: #ichargetype_id#
						<br />
					</cfoutput>
				</cfif>
				<cfif #qMedZeroCharge.iChargeType_ID# is 8 >
					<cfset ThisAmt =  round(#StateMedicaidChg#*100)/100 >
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 1749>
					<cfset ThisAmt =  round((#form.mStateMedAidAmtRB# * #ChargeDays[i]#)*100)/100>
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 1750 >
					<cfset ThisAmt = round((#form.mStateMedAidAmtcare# * #ChargeDays[i]#)*100)/100>
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 31 >
					<cfset ThisAmt = round(#qryHouseMedicaid.mMedicaidBSF#*100)/100  >
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 1661 >
					<cfset ThisAmt = round(#CoPayProRate#*100)/100>
				<cfelse>
					<cfset ThisAmt =   0.00 >
				</cfif> 		
		<cfquery name="ZeroAddition" datasource="#application.datasource#" result="ZeroAddition">
			insert into InvoiceDetail
			(iInvoiceMaster_ID 
				,iTenant_ID 
				,iChargeType_ID 
				,cAppliesToAcctPeriod 
				,bIsRentAdj 
				,dtTransaction 
				,iQuantity
				,cDescription 
				,mAmount 
				,cComments 
				,dtAcctStamp 
				,iRowStartUser_ID 
				,dtRowStart
				,iDaysBilled )
				values
			(#iInvoiceMaster_ID# 
				,#TenantInfo.iTenant_ID# 
				,#qMedZeroCharge.iChargeType_ID# 
				,'#MoveInPeriod#' 
				,null
				,getdate() 
				 <cfif #qMedZeroCharge.iChargeType_ID# is 8 >
					,1 
					,'#trim(qMedZeroCharge.cDescription)#'
					<!---<cfif ((tenantype.mBSFOrig gt 0) and (tenantype.cstatecode is 'WI'))>
					,#tenantype.mBSFOrig# * #ChargeDays[i]#
					<cfelse> Mamta commented as WI will not use state medicaid--->
					, #ThisAmt# 
					<!---</cfif>--->
					,#CoPayDays# 
					<!---Mamta added--->	
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 1749>
					,1 
					,'#trim(qMedZeroCharge.cDescription)#'
					, #ThisAmt#
					,#CoPayDays# 
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 1750 >
					,1 
					,'#trim(qMedZeroCharge.cDescription)#'
					, #ThisAmt#
					,#CoPayDays# 				
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 31 >
					, 1 
					,'#trim(qMedZeroCharge.cDescription)#'
					,#ThisAmt#  
					,#CoPayDays# 
				<cfelseif #qMedZeroCharge.iChargeType_ID# is 1661 >
					, 1 
					,'#trim(qMedZeroCharge.cDescription)#'
					,#ThisAmt#
					,#CoPayDays#
				<cfelse>
					, 1 
					,'#trim(qMedZeroCharge.cDescription)#'				 
					, #ThisAmt# 
					,'' 					
				</cfif> 

				,#CreateODBCDateTime(session.AcctStamp)# 
				,0 
				,getdate() 
				,#ChargeDays[i]#)
		</cfquery>
		<!---<cfdump var="#ZeroAddition#">--->
		</cfloop> 
	  </cfif>
	  </cfloop>

    </cfif> 
