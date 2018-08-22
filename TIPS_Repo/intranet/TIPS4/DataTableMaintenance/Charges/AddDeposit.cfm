<!--- *******************************************************************************
Name:			AddDeposit.cfm
Process:		Create/Add New House Specific Deposit

Called by: 		DepositCharges.cfm
Calls/Submits:	DepositCharges.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            05/31/2002      Original Authorship
******************************************************************************** --->

<CFOUTPUT>
<!--- ==============================================================================
loop over form struct and evaluate the values
=============================================================================== --->
<CFLOOP INDEX=I LIST="#form.fieldnames#">#Evaluate(I)# #I#<BR></CFLOOP>
<BR>

<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(GetDate.Stamp)>

<!--- ==============================================================================
Set Variables to create the start and expire dates for this charge
=============================================================================== --->
<CFSET Month = #DateFormat(Now(),"mm")#>
<CFSET Day = #DateFormat(Now(),"dd")#>
<CFSET expyear = #Year(Now())# + 10>
<CFSET Start = Now()>
<CFSET Expire = expyear & '-' & month & '-' & day>

<!--- ==============================================================================
Enclosed transaction to add the new deposit information to the Charges Table
=============================================================================== --->
<CFTRANSACTION>
	<CFIF IsDefined("url.Edit")>
		<CFQUERY NAME="qEditDeposit" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	Charges
			SET		cDescription = '#form.cDescription#',
					iQuantity = #form.iQuantity#,
					mAmount = #form.mAmount#
			WHERE	iCharge_ID = #form.iCharge_ID#
		</CFQUERY>
	<CFELSE>
		<CFQUERY NAME="qAddDeposit" DATASOURCE="#APPLICATION.datasource#">
			INSERT INTO [Charges]
			(	[iChargeType_ID], [iHouse_ID], [cChargeSet], [cDescription], 
				[mAmount], [iQuantity], [bIsRentUNUSED], [bIsMedicaidUNUSED], 
				[iResidencyType_ID], [iAptType_ID], [cSLevelDescription], [iSLevelType_ID], 
				[iOccupancyPosition], [dtAcctStamp], [dtEffectiveStart], [dtEffectiveEnd], 
				[iRowStartUser_ID], [dtRowStart]
			)VALUES(
				#form.iChargeType_ID#, #SESSION.qSelectedHouse.iHouse_ID#, NULL, '#form.cDescription#', 
				#form.mAmount#, #form.iQuantity#, NULL, NULL, 
				NULL, NULL, NULL, NULL, 
				NULL, #CreateODBCDateTime(SESSION.AcctStamp)#, #start#, '#expire#', 
				#SESSION.USERID#, #TimeStamp#
			)
		</CFQUERY>
	</CFIF>
</CFTRANSACTION>

<BR>
<!--- ==============================================================================
Redirect user according to DepositCharges.cfm unless needed for debug
=============================================================================== --->
<CFIF SESSION.USERID EQ 3025>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL="DepositCharges.cfm" ADDTOKEN="No">
</CFIF>

</CFOUTPUT>