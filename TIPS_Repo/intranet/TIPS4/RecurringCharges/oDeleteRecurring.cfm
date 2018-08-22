
<CFIF (isDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB') OR 1 EQ 1>
	<CFQUERY NAME="RecurringInfo" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*, RC.mAmount as mAmount
		FROM RecurringCharge RC (NOLOCK)
		JOIN Charges C (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID	
		JOIN ChargeType CT (NOLOCK) ON CT.iChargeType_ID = C.iChargeType_ID
		WHERE iRecurringCharge_ID = #Url.typeID#
	</CFQUERY>
	<CFQUERY NAME="qResident" DATASOURCE="#APPLICATION.datasource#">
	select * from tenant where dtrowdeleted is null and itenant_id = #recurringinfo.itenant_id#
	</CFQUERY>
</CFIF>

<!--- ==============================================================================
Delete Chosen Charge by Flagging as Deleted
=============================================================================== --->
<CFQUERY NAME = "DeleteCharge" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	RecurringCharge
	SET		iRowDeletedUser_ID = #SESSION.UserID#,
			dtRowDeleted = getDate() 
	WHERE	iRecurringCharge_ID	= #Url.typeID#
</CFQUERY>

<CFIF (isDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB') OR 1 EQ 1>
	<CFIF isDefined("SESSION.RDOEmail") AND RecurringInfo.bDirectorEmail GT 0>
		<CFSCRIPT>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='PBuendia@alcco.com'; }
			else { email=SESSION.RDOEmail; } 
			message= RecurringInfo.cdescription & " has changed for " & qResident.cFirstName & ', ' & qResident.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "The rate in the amount of " & LSCurrencyFormat(RecurringInfo.mAmount) & " has been deleted from recurring charges. ";
			message= message & "<BR>by: " & SESSION.FullName;
		</CFSCRIPT>
		<CFMAIL TYPE ="HTML" FROM="TIPS4_Recurring_Change@alcco.com" TO="#email#" BCC="pbuendia@alcco.com" SUBJECT="Deleted Recurring Rate for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>

<!--- ==============================================================================
Relocate to the Charges Page
=============================================================================== --->
<CFLOCATION URL="Recurring.cfm" ADDTOKEN="No">