<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/ResetTenant.cfm                                                        |
|----------------------------------------------------------------------------------------------|
| 													                                           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|MLAW        | 08/07/2006 | Create an initial ResetTenant page                      	       |
|MLAW		 | 08/07/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
|RSchuette   | 03/25/2010 | 51267 - MO CODES- added code to reset the tenant                   |
|MStriegel   | 01/04/2018 | Reset secondary switch date                                        |
----------------------------------------------------------------------------------------------->
<!--- 08/07/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<!--- ==============================================================================
Retrieve the Tenants Information
=============================================================================== --->
<CFQUERY NAME = "Tenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	Tenant T
	JOIN	TenantState TS ON T.iTenant_ID = TS.iTenant_ID
	WHERE	T.iTenant_ID = #url.ID#
</CFQUERY>


<!--- ==============================================================================
Update the Tenant State to AcctClosed Status
=============================================================================== --->
<!--- 51267 - MO CODES - RTS - added iMoveReason2Type_ID,iTenantMOLocation_ID code to reset the tenant --->
<CFQUERY NAME = "ResetAccount" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		iTenantStateCode_ID	=	2,
			dtNoticeDate		=	NULL,
			dtChargeThrough		=	NULL,
			dtMoveOut			=	NULL,
			iMoveReasonType_ID	=	NULL,
			iMoveReason2Type_ID =	NULL,
			iTenantMOLocation_ID =  NULL,
			iRowStartUser_ID 	= 	#SESSION.UserID#,
			dtRowStart			=	Getdate()
	WHERE	iTenant_ID 			= 	#url.ID#
</CFQUERY>
<!--- end 51267 --->



<!--- ==============================================================================
Write Activity in the ActivityLog
1	Registered
2	Moved IN
3	Moved Out
4	Transfer
5	AcctClose
=============================================================================== --->
<CFQUERY NAME = "RecordActivity" DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO 	ActivityLog
					(
						iActivity_ID, 
						dtActualEffective, 
						iTenant_ID, 
						iHouse_ID, 
						iAptAddress_ID, 
						iSPoints, 
						dtAcctStamp, 
						iRowStartUser_ID, 
						dtRowStart
					)
					VALUES
					(
						2,
						GetDate(),
						#url.ID#,
						#SESSION.qSelectedHouse.iHouse_ID#,
						#Tenant.iAptAddress_ID#,
						#Tenant.iSPoints#,
						'#SESSION.AcctStamp#',
						#SESSION.UserID#,
						GetDate()
					)
</CFQUERY>



<!--- ==============================================================================
Retrieve the move out invoice number
=============================================================================== --->
<CFQUERY NAME = "InvoiceID" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	iInvoiceMaster_ID
	FROM	InvoiceMaster
	WHERE	bMoveOutInvoice IS NOT NULL
	AND		cSolomonKey = '#Tenant.cSolomonKey#'
</CFQUERY>

<cfset iInvoiceIDList = ValueList(InvoiceID.iInvoiceMaster_ID)>

<!--- ==============================================================================
Flag the Invoice as Deleted
=============================================================================== --->
<CFQUERY NAME = "DeleteMoveOutInvoice" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	InvoiceMaster
	SET		iRowDeletedUser_ID = #SESSION.UserID#,
			dtRowDeleted = GetDate()
	WHERE	iInvoiceMaster_ID IN (#iInvoiceIDList#) 
</CFQUERY>

	
<!--- ==============================================================================
Flag the Detail Records as Deleted
=============================================================================== --->	
<CFQUERY NAME = "DeleteDetails" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	InvoiceDetail
	SET		iRowDeletedUser_ID 	= #SESSION.UserID#,
			dtRowDeleted		= GetDate()
	WHERE	iInvoiceMaster_ID 	IN (#iInvoiceIDList#) 
</CFQUERY>

<!---- 01/04/2018 MStriegel reset secondary switch date ---->
<!--- ==============================================================================
Remove the secondary switch date
=============================================================================== --->	
<cfquery name="qCheckForRoommate" datasource="#application.datasource#">
	select itenant_ID
	from  TenantState WITH (NOLOCK)
	where iAptAddress_ID = #Tenant.iAptAddress_ID#
	AND iTenant_ID <> #url.id#
</cfquery>
<cfif qCheckForRoomMate.recordcount GT 0>
	<cfquery name="updRoommate" datasource="#application.datasource#">
		UPDATE TenantState
		set dtSecondarySwitchDate = NULL
		where itenant_ID = #qCheckForRoommate.iTenant_ID#
	</cfquery>
</cfif>
<!--- end mstriegel --->

<CFIF ShowBtn>
	<!--- ==============================================================================
	Relocate page to Main menu
	=============================================================================== --->
	<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">
<CFELSE>
	<CFLOCATION URL="../census/FinalizeMoveOut.cfm" ADDTOKEN="No">
</CFIF>



