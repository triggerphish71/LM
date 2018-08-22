

<!--- ==============================================================================
Deposit Log Entry Insert
=============================================================================== --->
<CFQUERY NAME = "NewDepositType"	DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO DepositType
		(
		iChargeType_ID, 
		cDepositTypeSet, 
		iDisplayOrder, 
		bIsFee, 
		cDescription, 
		mAmount, 
		cComments, 
		iRowStartUser_ID, 
		dtRowStart
		)
		VALUES
		(
		<CFIF form.iChargeType_ID	NEQ "">	#form.iChargeType_ID#		<CFELSE>	NULL,	</CFIF>
		<CFIF form.cDepositTypeSet	NEQ "">	'#form.cDepositTypeSet#',	<CFELSE>	NULL,	</CFIF> 
		<CFIF form.iDisplayOrder	NEQ "">	#form.iDisplayOrder#,		<CFELSE>	NULL,	</CFIF> 
		<CFIF IsDefined("form.bIsFee")>		#form.bIsFee#,				<CFELSE>	NULL,	</CFIF>
		<CFIF form.cDescription		NEQ "">	'#form.cDescription#',		<CFELSE>	NULL,	</CFIF>
		<CFIF form.mAmount			NEQ "">	#form.mAmount#,				<CFELSE>	NULL,	</CFIF>
		<CFIF form.cComments		NEQ "">	'#form.cComments#',			<CFELSE>	NULL,	</CFIF>
		#SESSION.UserID#,
		GETDATE()
		)
</CFQUERY>

<CFLOCATION URL = "DepositType.cfm">