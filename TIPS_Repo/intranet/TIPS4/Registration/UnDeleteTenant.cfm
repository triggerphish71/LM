
<!--- ==============================================================================
Retrieve the corresponding AREmail
=============================================================================== --->
<CFQUERY NAME = "GetEmail" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Du.EMail as AREmail
	FROM	House	H
	JOIN	#Application.AlcWebDBServer#.ALCWEB.dbo.employees DU ON H.iAcctUser_ID = DU.Employee_ndx
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>


<!--- ==============================================================================
Retrieve information for this tenant
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*, (T.cFirstName + ' ' + T.cLastname) as FullName
	FROM	Tenant T
	JOIN	TenantState TS ON T.iTenant_ID = TS.iTenant_ID
	WHERE	T.iTenant_ID = #url.ID#
</CFQUERY>


<!--- ==============================================================================
Check if an application fee has been paid for this tenant
=============================================================================== --->
<CFQUERY NAME="ApplicationFee" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct DT.*
	FROM	DepositLog DL
	JOIN 	DepositType DT ON DT.iDepositType_ID = DL.iDepositType_ID
	WHERE	iTenant_ID = #url.ID#
	AND		DT.dtRowDeleted IS NULL AND DL.dtRowDeleted IS NULL AND bIsApplicationFee IS NOT NULL
</CFQUERY>


<CFIF ApplicationFee.RecordCount GT 0>
	<CFMAIL TYPE ="HTML" FROM = "TIPS4-Message@alcco.com" TO="#GetEMail.AREmail#" CC="PBuendia@alcco.com" SUBJECT="Applicant Re-Activated">
	#Tenant.FullName# (#Tenant.cSolomonKey#) has been re-activated from the registered list by #SESSION.FullName#<BR>
	<U>Please Note:</U><BR>
	TIPS 4 records indicate that an Application Fee was paid for this tenant.<BR><BR>
	____________________________________________________
</CFMAIL>	
</CFIF>


<CFSET TimeStamp = #CreateODBCDateTime(Now())#>

<!--- ==============================================================================
Flag the Selected Tenant Record As Deleted
=============================================================================== --->
<CFQUERY NAME="UnDeleteTenant" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	Tenant
	SET		iRowDeletedUser_ID = NULL, dtRowDeleted = NULL, iRowStartUser_ID = #SESSION.UserID#, dtRowStart = #TimeStamp# WHERE	iTenant_ID = #url.ID#
</CFQUERY>

<!--- ==============================================================================
Flag the Tenant State Record as Deleted
=============================================================================== --->
<CFQUERY NAME="DeleteTenantState" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		iRowDeletedUser_ID = NULL,
			dtRowDeleted = NULL,
			iRowStartUser_ID = #SESSION.UserID#,
			dtRowStart = #TimeStamp#			
	WHERE	iTenant_ID = #url.ID#
</CFQUERY>

<!--- ==============================================================================
If the Application Fee IS Deleted Reset the Flag to NULL
=============================================================================== --->
<CFIF ApplicationFee.dtRowDeleted NEQ "">
	<CFQUERY NAME="ResetAppFee" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	DepositLog
		SET		dtRowDeleted = NULL,
				iRowDeletedUser_ID = NULL,
				dtRowStart = getdate(),
				iRowStartUser_ID = #SESSION.UserID#
		WHERE	DL.iDepositLog_ID = #ApplicationFee.iDepositLog_ID#
	</CFQUERY>
</CFIF>


<CFIF SESSION.USERID EQ 3025>
	<A HREF="Registration.cfm"> Continue</A>
<CFELSE>	
	<CFLOCATION URL="Registration.cfm">
</CFIF>