<!--- *******************************************************************************
Name:			ChargeTypeUpdate.cfm
Process:		Charge Type Record Update Script

Called by: 		ChargeTypeEdit.cfm
Calls/Submits:		ChargeType.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia		4/2/02		Added deposit and refundable flags.
******************************************************************************** --->

<CFTRANSACTION>
	<!--- ==============================================================================
	Insert New Charge Type into table
	=============================================================================== --->
	<CFQUERY NAME = "UpdateChargeType"	DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	ChargeType
		SET	 	
			<CFIF form.cDescription NEQ "" > 	
				cDescription = '#TRIM(form.cDescription)#',
			<CFELSE>	
				cDescription = NULL,
			</CFIF>
			
			<CFIF form.cGLAccount NEQ ""> 	
				cGLAccount	= '#TRIM(form.cGLAccount)#',
			<CFELSE>	
				cGLAccount	= NULL,
			</CFIF>
			
			 <CFIF IsDefined("form.bIsOpsControlled")> 	
			 	bIsOpsControlled = #form.bIsOpsControlled#,
			 <CFELSE>	
			 	bIsOpsControlled = NULL,
			 </CFIF>
			  
			<CFIF IsDefined("form.bIsModifiableDescription")> 	
				bIsModifiableDescription = #form.bIsModifiableDescription#,
			<CFELSE>	
				bIsModifiableDescription = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsModifiableAmount")> 	
				bIsModifiableAmount	= #form.bIsModifiableAmount#,
			<CFELSE>	
				bIsModifiableAmount	= NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsModifiableQty")> 	
				bIsModifiableQty = #form.bIsModifiableQty#,
			<CFELSE>	
				bIsModifiableQty = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsPrePay")> 	
				bIsPrePay = #form.bIsPrePay#,
			<CFELSE>	
				bIsPrePay = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bOccupancyPosition")> 	
				bOccupancyPosition = #form.bOccupancyPosition#,
			<CFELSE>	
				bOccupancyPosition = NULL,
			</CFIF>

			<CFIF IsDefined("form.bResidencyType_ID")> 	
				bResidencyType_ID = #form.bResidencyType_ID#,
			<CFELSE>	
				bResidencyType_ID = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.biHouse_ID")> 	
				biHouse_ID = #form.biHouse_ID#,
			<CFELSE>	
				biHouse_ID = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bAptType_ID")> 	
				bAptType_ID = #form.bAptType_ID#,
			<CFELSE>	
				bAptType_ID = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bSLevelType_ID")> 	
				bSLevelType_ID = #form.bSLevelType_ID#,
			<CFELSE>	
				bSLevelType_ID = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsRent")> 	
				bIsRent		 	= #form.bIsRent#,
			<CFELSE>	
				bIsRent		 	= NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsMedicaid")> 	
				bIsMedicaid		= #form.bIsMedicaid#,
			<CFELSE>	
				bIsMedicaid		= NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsDaily")> 	
				bIsDaily = #form.bIsDaily#,
			<CFELSE>	
				bIsDaily = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsDiscount")> 	
				bIsDiscount = #form.bIsDiscount#,
			<CFELSE>	
				bIsDiscount = NULL,
			</CFIF>
	
			<CFIF IsDefined("form.bIsDeposit")> 	
				bIsDeposit = #form.bIsDeposit#,
			<CFELSE>	
				bIsDeposit = NULL,
			</CFIF>	
			
			<CFIF IsDefined("form.bIsRefundable")> 	
				bIsRefundable = #form.bIsRefundable#,
			<CFELSE>	
				bIsRefundable = NULL,
			</CFIF>	
	
			<CFIF IsDefined("form.bIsRentAdjustment")>
				bIsRentAdjustment = #form.bIsRentAdjustment#,
			<CFELSE>
				bIsRentAdjustment = NULL,
			</CFIF>	
	
			<CFIF IsDefined("form.bAcctOnly")>
				bAcctOnly = #form.bAcctOnly#,
			<CFELSE>
				bAcctOnly = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsRecurring")> 	
				bIsRecurring = #form.bIsRecurring#,
			<CFELSE>	
				bIsRecurring = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsMoveIn")> 	
				bIsMoveIn = #form.bIsMoveIn#,
			<CFELSE>	
				bIsMoveIn = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsCharges")> 	
				bIsCharges = #form.bIsCharges#,
			<CFELSE>	
				bIsCharges = NULL,
			</CFIF>
			
			<CFIF IsDefined("form.bIsMoveOut")> 	
				bIsMoveOut = #form.bIsMoveOut#,
			<CFELSE>	
				bIsMoveOut = NULL,
			</CFIF>	
				
				iRowStartUser_ID 	= #SESSION.UserID#,
				dtRowStart			= GetDate()
		
		WHERE	iChargeType_ID = #form.iChargeType_ID#
	</CFQUERY>
</CFTRANSACTION>

<CFLOCATION URL="ChargeType.cfm" ADDTOKEN="No">


