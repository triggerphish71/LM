<!--- *******************************************************************************
Name:			DeleteDeposit.cfm
Process:		Flag chosen Deposit Charge as Deleted

Called by: 		DepositCharges.cfm
Calls/Submits:	DepositCharges.cfm

Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            05/31/2002      Original Authorship
******************************************************************************** --->

<CFOUTPUT>

<CFTRANSACTION>
	<CFQUERY NAME="qEditDeposit" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	Charges
		SET		dtRowDeleted = getdate(),
				iRowDeletedUser_ID = #SESSION.USERID#
		WHERE	iCharge_ID = #url.iCharge_ID#
	</CFQUERY>
</CFTRANSACTION>

<CFIF SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146>
	<A HREF="DepositCharges.cfm">Continue</A>
<CFELSE>
	<CFLOCATION URL="DepositCharges.cfm" ADDTOKEN="No">
</CFIF>
</CFOUTPUT>