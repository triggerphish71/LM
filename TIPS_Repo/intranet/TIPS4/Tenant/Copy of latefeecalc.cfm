							<cfquery name="qrylatefee1" datasource="#application.datasource#">
							Select  sum(mLateFeeAmount) as mAmount
								From TenantLateFee
								Where dtRowdeleted is Null
								
								and  dtLateFeeDelete is null  
								and  dtLateFeePaid is null    
								
								and cAppliesToAcctPeriod < '#thisdate#'
								and isNull(bpaid,0) = 0
								and isNull(bAdjustmentDelete,0) = 0
								and isNull(bPartialPaid,0) = 0
								and TenantLateFee.cSolomonKey =   '#eftinfo.cSolomonKey#'
							</cfquery>
							<cfquery name="qrylatefee2" datasource="#application.datasource#">
								Select sum(mActualLateFee - mLateFeePartialPayment) as mAmount
								From TenantLateFee tlf
								JOIN TenantLateFeeAdjustmentDetail lfa ON lfa.iInvoiceLateFee_ID = tlf.iInvoiceLateFee_Id and lfa.dtRowDeleted is null
								Where tlf.dtRowdeleted is Null
								
								and tlf.dtLateFeeDelete is null	  
								and tlf.dtLateFeePaid is null	  
								
								and tlf.cAppliesToAcctPeriod < '#thisdate#'
								and isNull(tlf.bPartialPaid,0) = 1
								and tlf.cSolomonKey =   '#eftinfo.cSolomonKey#'	 
							</cfquery>		
 	 
							<cfif qryLateFee1.mamount is "">
								<cfset  mamount1 = 0>
							<cfelse>
								<cfset mamount1 = qryLateFee1.mamount>
							</cfif>
							<cfif qryLateFee2.mamount is "">
								<cfset mamount2 = 0>
							<cfelse>
								 <cfset mamount2 = qryLateFee2.mamount>
							</cfif>
						
							<cfset LateFee =  mamount1 +  mamount2>