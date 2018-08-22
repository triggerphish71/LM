				<cfquery name="qrylatefee1" datasource="#application.datasource#">
					Select    sum(mAmount) as LateFeeAmount
			From (	<!--- Gets the sum of all Late Fees not Paid or Waived--->
					Select  IsNull(sum(mLateFeeAmount),0) as mAmount
					From TenantLateFee tlf
					Where dtRowdeleted is Null
						and  dtLateFeeDelete is null  
					and  dtLateFeePaid is null    
						and cAppliesToAcctPeriod <= '#thisdate#'
					and isNull(bpaid,0) = 0
					and isNull(bAdjustmentDelete,0) = 0
					and isNull(bPartialPaid,0) = 0
					and  tlf.cSolomonKey = '#eftinfo.cSolomonKey#'

					Union All

						<!--- Gets the sum of the unpaid portion of partially paid late fees--->
					Select  IsNUll(sum(mActualLateFee - mLateFeePartialPayment),0) as mAmount
					From TenantLateFee tlf
					JOIN TenantLateFeeAdjustmentDetail lfa ON lfa.iInvoiceLateFee_ID = tlf.iInvoiceLateFee_Id 
						and lfa.dtRowDeleted is null
					Where tlf.dtRowdeleted is Null
					and tlf.dtLateFeeDelete is null	  
					and tlf.dtLateFeePaid is null	  
					and tlf.cAppliesToAcctPeriod <= '#thisdate#'
					and isNull(tlf.bPartialPaid,0) = 1
					and  tlf.cSolomonKey = '#eftinfo.cSolomonKey#'

					) as LateFeeAmount  
				</cfquery> 		
						
			<cfset LateFee =  #qrylatefee1.LateFeeAmount#>