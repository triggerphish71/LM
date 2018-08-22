


<!--- ==============================================================================
Update Deposit Type entry
=============================================================================== --->
<CFQUERY NAME = "DepositTypeEdit"	DATASOURCE = "#APPLICATION.datasource#">
	UPDATE DepositType
	SET 	
			<CFIF form.iChargeType_ID NEQ "">
				iChargeType_ID = #form.iChargeType_ID#,
			<CFELSE>
				iChargeType_ID = NULL,
			</CFIF>
			
	
			<CFIF form.cDepositTypeSet 	NEQ "">		
				cDepositTypeSet = '#TRIM(form.cDepositTypeSet)#',	
			<CFELSE>	
				cDepositTypeSet = NULL,	
			</CFIF> 
			
			
			
			<CFIF form.iDisplayOrder NEQ "">	
				iDisplayOrder = #TRIM(form.iDisplayOrder)#,				
			<CFELSE>	
				iDisplayOrder = NULL,	
			</CFIF> 
			
			
			
			<CFIF IsDefined("form.bIsFee")>	
				bIsFee 	= 	#TRIM(form.bIsFee)#,
			<CFELSE>	
				bIsFee 	= 	NULL,	
			</CFIF>
			
			
			
			<CFIF form.cDescription	NEQ "">	
				cDescription = '#TRIM(form.cDescription)#',	
			<CFELSE>	
				cDescription = NULL,	
			</CFIF>
			
			
			<CFIF form.mAmount NEQ "">	
				mAmount = #TRIM(form.mAmount)#,			
			<CFELSE>	
				mAmount = NULL,	
			</CFIF>
			
			
			<CFIF form.cComments NEQ "">		
				cComments = '#TRIM(form.cComments)#',			
			<CFELSE>	
				cComments = NULL,	
			</CFIF>
			
			
			iRowStartUser_ID 	= #SESSION.UserID#,
			dtRowStart 			= GetDate()
	WHERE iDepositType_ID 		= #form.iDepositType_ID#
	
</CFQUERY>



<!--- *****************************************************************************
<CFQUERY NAME = "History" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	P_DepositType
	SET		iRowEndUser_ID		=	#SESSION.UserID#
	WHERE	iDepositType_ID 	= 	#form.iDepositType_ID#
	AND		dtRowEnd			=	(Select Max(dtRowEnd)as EndDate from P_DepositType WHERE iDepositType_ID 	= 	#form.iDepositType_ID# AND cDescription = '#form.cDescription#')
</CFQUERY>
****************************************************************************** --->


<CFLOCATION URL = "DepositType.cfm">