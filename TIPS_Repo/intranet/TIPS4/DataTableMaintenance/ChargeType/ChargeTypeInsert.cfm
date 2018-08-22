<!--- *******************************************************************************
Name:			ChargeTypeInsert.cfm
Process:		Charge Type Record Creation Script

Called by: 		ChargeTypeEdit.cfm
Calls/Submits:		ChargeType.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Steve Davison		4/9/02		Added deposit and refundable flags.
******************************************************************************** --->

<CFTRANSACTION>
<!--- ==============================================================================
Insert New Charge Type into table
=============================================================================== --->
	<CFQUERY NAME = "NewChargeType"	DATASOURCE = "#APPLICATION.datasource#">
		INSERT INTO 	ChargeType
						(
							cDescription, 
							cGLAccount, 
							bIsOpsControlled, 
							bIsModifiableDescription, 
							bIsModifiableAmount, 
							bIsModifiableQty, 
							bIsPrePay,
							bIsRentAdjustment,
							bOccupancyPosition, 
							bResidencyType_ID, 
							biHouse_ID, 
							bAptType_ID, 
							bSLevelType_ID,
							bIsRent,
							bIsMedicaid,
							bIsDaily,
							bIsDiscount,
							bIsDeposit,
							bIsRefundable,
							bAcctOnly,
							iRowStartUser_ID, 
							dtRowStart,
							bIsRecurring,
							bIsMoveIn,
							bIsCharges,
							bIsMoveOut
						)
						
						VALUES
						
						(
							<CFIF form.cDescription NEQ "">	'#TRIM(form.cDescription)#',	<CFELSE>	NULL,	</CFIF>
							<CFIF form.cGLAccount NEQ "">	'#TRIM(form.cGLAccount)#',		<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsOpsControlled")>			#form.bIsOpsControlled#,			<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsModifiableDescription")>	#form.bIsModifiableDescription#,	<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsModifiableAmount")>		#form.bIsModifiableAmount#,			<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsModifiableQty")>			#form.bIsModifiableQty#,			<CFELSE>	NULL,	</CFIF> 
							<CFIF IsDefined("form.bIsPrePay")>					#form.bIsPrePay#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsRentAdjustment")>			#form.bIsRentAdjustment#,			<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bOccupancyPosition")>			#form.bOccupancyPosition#,			<CFELSE>	NULL,	</CFIF> 
							<CFIF IsDefined("form.bResidencyType_ID")>			#form.bResidencyType_ID#,			<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.biHouse_ID")>					#form.biHouse_ID#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bAptType_ID")>				#form.bAptType_ID#,					<CFELSE>	NULL,	</CFIF> 
							<CFIF IsDefined("form.bSLevelType_ID")>				#form.bSLevelType_ID#,				<CFELSE>	NULL,	</CFIF>
		 					<CFIF IsDefined("form.bIsRent")>					#form.bIsRent#,						<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsMedicaid")>				#form.bIsMedicaid#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsDaily")>					#form.bIsDaily#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsDiscount")>				#form.bIsDiscount#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsDeposit")>					#form.bIsDeposit#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsRefundable")>					#form.bIsRefundable#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bAcctOnly")>					#form.bAcctOnly#,					<CFELSE>	NULL,	</CFIF>	
							#SESSION.UserID#, 
							GETDATE(),
							<CFIF IsDefined("form.bIsRecurring")>					#form.bIsRecurring#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsMoveIn")>					#form.bIsMoveIn#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsCharges")>					#form.bIsCharges#,					<CFELSE>	NULL,	</CFIF>
							<CFIF IsDefined("form.bIsMoveOut")>					#form.bIsMoveOut#					<CFELSE>	NULL	</CFIF>
						)
	</CFQUERY>
</CFTRANSACTION>

<CFLOCATION URL="ChargeType.cfm" ADDTOKEN="No">