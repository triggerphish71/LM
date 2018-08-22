<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/RemoveMoveOutData.cfm                                                  |
| Replace all Move out Data with NULL. 														   |
| To release from the pending state.											   			   |
|----------------------------------------------------------------------------------------------|
| Called by: 		MoveOutForm.cfm															   |
| Calls/Submits:	MainMenu.cfm													           |                                |
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
|Paul Buendia| 03/11/2002 | Original Authorship						                  	       |
|MLAW        | 08/07/2006 | Create initial flowerbox                                           |
|MLAW		 | 08/07/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
----------------------------------------------------------------------------------------------->
<!--- 08/07/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<CFOUTPUT>

<CFIF NOT IsDefined("url.iTenant_ID") OR NOT IsDefined("url.iInvoiceMaster_ID")>
	<CENTER>
		<B STYLE="color: blue; font-size: 20;">
			An problem has occured. Please, retry your request at a later time.
			ALC IT Department
		</B><BR>
		<INPUT CLASS="BlendedButton" TYPE="Button" NAME="Continue" VALUE="Click Here to Continue" onClick="location.href='../MainMenu.cfm'">
	</CENTER>
</CFIF>

<CFTRANSACTION>

<!--- ==============================================================================
Change all move out data for this tenant to NULL
=============================================================================== --->
<CFQUERY NAME="qRemoveMOData" DATASOURCE="#APPLICATION.datasource#">
	UPDATE 	TenantState
	SET	dtNoticeDate = NULL,
		dtChargeThrough = NULL,
		dtMoveOut = NULL,
		iMoveReasonType_ID = NULL,
		dtRowStart = getdate(),
		iRowStartUser_ID = #SESSION.USERID#
	WHERE	iTenant_ID = #url.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Retrieve information for chosen invoice
=============================================================================== --->
<CFIF url.iInvoiceMaster_id neq '' or 1 eq 1>
	<CFQUERY NAME="qMOInvoice" DATASOURCE="#APPLICATION.datasource#">
		SELECT * FROM InvoiceMaster WHERE iInvoiceMaster_ID = #url.iInvoiceMaster_ID#
	</CFQUERY>
<CFELSE>
	<CFQUERY NAME="qMOInvoice" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*, INV.cComments as Comments, IM.cComments as InvoiceComments
		FROM	InvoiceMaster IM
		JOIN InvoiceDetail INV ON IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND inv.dtrowdeleted is null
		WHERE IM.dtrowdeleted is null AND IM.bMoveOutInvoice IS NOT NULL 
		AND ( INV.iTenant_ID = #url.iTenant_ID# 
			or 0 = (select count(distinct iinvoicedetail_id) 
			from invoicedetail where dtrowdeleted is null and iinvoicemaster_id = im.iinvoicemaster_id
		) )
	</CFQUERY>
</CFIF>

<!--- ==============================================================================
If the chosen invoice is a move out invoice and is not deleted then delete this invoice
otherwise leave it alone.
=============================================================================== --->
<CFIF qMOInvoice.bMoveOutInvoice NEQ "" AND qMOInvoice.dtRowDeleted IS "">
	<CFQUERY NAME="qDeleteMOInvoice" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	InvoiceMaster
		SET		dtRowDeleted = getdate(),
				iRowDeletedUser_ID = #SESSION.USERID#
		WHERE	iInvoiceMaster_ID = #url.iInvoiceMaster_ID#
	</CFQUERY>
</CFIF>
<!--- Mamta---update query secondaryswitchdate to null, when resident is not movingout--->
<CFIF #form.SecondaryTenantId# NEQ "">
<CFQUERY NAME="updatesecondarySwitchDatenull" DATASOURCE="#APPLICATION.datasource#">
UPDATE tenantstate
set dtsecondaryswitchdate = null
where itenant_id = #form.SecondaryTenantId#
</CFQUERY>
</cfif>
<!---mamta testing--->

<!--- ==============================================================================
DEBUG
<CFTRANSACTION ACTION="Rollback"/>
=============================================================================== --->

</CFTRANSACTION>

<CFIF SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146>
	<CFIF ShowBtn>
		<A CLASS="HLink" HREF="../MainMenu.cfm">Continue</A>
	<CFELSE>
		<A CLASS="HLink" HREF="../census/FinalizeMoveOut.cfm">Continue</A>
	</CFIF>
<CFELSE>
	<CFIF ShowBtn>
		<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL="../census/FinalizeMoveOut.cfm" ADDTOKEN="No">
	</CFIF>
</CFIF>

</CFOUTPUT>