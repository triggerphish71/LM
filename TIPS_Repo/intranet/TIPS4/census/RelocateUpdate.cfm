<!----------------------------------------------------------------------------------------------
| DESCRIPTION - census/RelocateUpdate.cfm                                                      |
|----------------------------------------------------------------------------------------------|
| CALLED BY - census/RelocateTenant.cfm                                                        |
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
| mlaw       | 07/26/2006 | Create an initial relocate tenant update page                      |
| sfarmer    | 07/31/2013 | all 'Room & Board' statements (text) changed to 'Basic Service Fee'|
----------------------------------------------------------------------------------------------->
<CFOUTPUT>
	<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
		<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
	<CFELSE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
	</CFIF>
</CFOUTPUT>

<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CREATEODBCDateTime(GetDate.Stamp)>

<!--- =============================================================================================
Concat. Month Day Year for dBirthDate
============================================================================================= --->
<CFSCRIPT>
	dtActualEffective = form.month & "/" & form.day & "/" & form.year & " " & "23:59:59";
	dtActualEffective = CreateODBCDateTime(Variables.dtActualEffective);
</CFSCRIPT>

<!--- ==============================================================================
If there was no tenant Selected Show Error Below
=============================================================================== ---><style type="text/css">
<!--
body {
	background-color: #FFFFCC;
}
-->
</style>
<CFIF form.iTenant_ID EQ "">
	<CFOUTPUT>	
		<CFINCLUDE TEMPLATE="/intranet/header.cfm">
		<TABLE>
			<TR><TD STYLE="font-size: 20; font-weight: bold; background: white;">You have not selected a Tenant to Relocate.</TD></TR>
		</TABLE>
		<BR><BR>
		<A HREF="/intranet/TIPS4/census/RelocateTenant.cfm" STYLE="Font-size: 18;"> Click Here To Try Again. </A>
		<CFINCLUDE TEMPLATE="/intranet/footer.cfm">
		<CFABORT>
	</CFOUTPUT>	
</CFIF>

<!--- ==============================================================================
Retrieve the Move In Date
=============================================================================== --->
<CFQUERY NAME="MoveInDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	dtMoveIn FROM TenantState WHERE dtRowDeleted IS NULL AND iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<CFIF Variables.dtActualEffective LT MoveInDate.dtMoveIn>
		<CFINCLUDE TEMPLATE="/intranet/header.cfm">
		<TABLE>
			<TR>
				<TD STYLE = "font-size: 20; font-weight: bold; background: white;">
					You have entered a relocation date that is before <BR>
					this tenant moved into the facility.
				</TD>
			</TR>
		</TABLE>
		<BR><BR>
		<A HREF="http://#server_name/intranet/TIPS4/census/RelocateTenant.cfm" STYLE="Font-size: 18;"> Click Here To Try Again. </A>
		<CFINCLUDE TEMPLATE="/intranet/footer.cfm">
		<CFABORT>
</CFIF>

<CFTRANSACTION>

<!--- ==============================================================================
Retrieve the Tenant Current Records
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM Tenant T
	JOIN TenantState TS ON T.iTenant_ID = TS.iTenant_ID
	WHERE T.iTenant_ID = #form.iTenant_ID#
	AND T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
Update the Apartment Log for the new Appartment Address
=============================================================================== --->
<CFQUERY NAME = "AptRelocation" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	APTLOG
	SET		iAptAddress_ID = #TRIM(form.iAptAddress_ID)#,
			dtActualEffective = #TRIM(Variables.dtActualEffective)#,
			iRowStartUser_ID = #SESSION.UserID#,
			dtRowStart = #TimeStamp#
	WHERE	iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Update the Address on the Tenant State Table
=============================================================================== --->
<CFQUERY NAME = "TenantStateChange" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	TENANTSTATE
	SET		iAptAddress_ID = #TRIM(form.iAptAddress_ID)#,
			iRowStartUser_ID = #SESSION.UserID#,
			dtRowStart = #TimeStamp#
	WHERE	iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<CFQUERY NAME="WriteActivity" DATASOURCE="#APPLICATION.datasource#">
	INSERT INTO ActivityLog
	( iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints, dtAcctStamp, iRowStartUser_ID, dtRowStart)
		VALUES
	( 4, #dtActualEffective#, #form.iTenant_ID#, #SESSION.qSelectedHouse.iHouse_ID#, #TRIM(form.iAptAddress_ID)#, #Tenant.iSPoints#, 
	#CreateODBCDateTime(SESSION.AcctStamp)#, #SESSION.UserID#, #TimeStamp# )
</CFQUERY>

<!--- ==============================================================================
Added by Katie 8/15/03
Edit most recent invoice with new qty of R&B charges.  Add new row(s) for debit or credit of remaining qty of R&B charges
=============================================================================== --->

	<!--- 8/25/03: need to remember to add some kind of second tenant check.  If second tenant, R&B rates may also change for old roomate???
			Haven't done this yet --->
	
	<!--- find out if Tenant is Medicaid or not.  This value will be used in getChargeType query. --->
	<cfif Tenant.bIsMedicaid is ""><cfset TenantbIsMedicaid = "IS NULL"><cfelse><cfset TenantbIsMedicaid = "IS NOT NULL"></cfif>
	
	<!--- get appropriate chargetype to use --->
	<cfquery name="getChargeType" datasource="#application.datasource#">
		SELECT  ct.IChargeType_ID
		FROM  InvoiceDetail inv INNER JOIN
               Tenant t ON t.iTenant_ID = inv.iTenant_ID AND t.dtRowDeleted IS NULL INNER JOIN
               TenantState ts ON ts.iTenant_ID = t.iTenant_ID AND ts.dtRowDeleted IS NULL INNER JOIN
               InvoiceMaster im ON im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID AND im.dtRowDeleted IS NULL AND im.bMoveInInvoice IS NULL AND 
                      im.bMoveOutInvoice IS NULL AND im.bFinalized IS NULL INNER JOIN
               ChargeType ct ON ct.iChargeType_ID = inv.iChargeType_ID AND ct.dtRowDeleted IS NULL AND ct.bIsRent IS NOT NULL AND 
                      ct.bIsDiscount IS NULL AND ct.bIsRentAdjustment IS NULL AND ct.bSLevelType_ID IS NULL
		WHERE     (inv.dtRowDeleted IS NULL) AND (inv.iTenant_ID = #form.iTenant_ID#) AND (ct.bIsMedicaid #TenantbIsMedicaid#)
		ORDER BY inv.iInvoiceDetail_ID DESC
	</cfquery>
	
	<cfif getChargeType.iChargeType_ID is not "">
		<!--- get most recent active invoicedetail for tenant where chargetype is #getChargeType.iChargeType_ID# (usually 89) --->
		<cfquery name="getmostrecentinvoicedetail" datasource="#application.datasource#" maxrows="1">
			SELECT iInvoiceDetail_ID, iQuantity
			FROM InvoiceDetail
			WHERE iTenant_ID = #form.iTenant_ID# 
			AND iChargeType_ID = #getChargeType.iChargeType_ID# AND dtRowDeleted is NULL
			ORDER BY iInvoiceDetail_ID DESC
		</cfquery>
	</cfif>

	<!--- if a record is returned, their records can be prorated --->
	<cfif isDefined("getmostrecentinvoicedetail.iInvoiceDetail_ID") AND getmostrecentinvoicedetail.recordcount is not 0>
		
		<!--- figure out how many days at prev room and how many days in new room --->
		<cfset CreateaDate = "#form.month#/#form.day#/#form.year# 00:00:00 AM"> 
		<cfset TotalMonthDays = #DaysInMonth(CreateaDate)#>TotalMonthDays in Change Month<cfoutput> #form.month#/#form.day#/#form.year#: #totalmonthdays#<BR></cfoutput>
		<cfset newroomqty = (#TotalMonthDays# - #form.day#) + 1>newroomqty: <cfoutput>#newroomqty#<BR></cfoutput>
		
		<!-- always going to be editing and adding room change info to most recent invoice master --->
		<cfquery name="GetMostRecentInvoiceMaster" datasource="#application.datasource#" Maxrows="1">
			SELECT InvoiceDetail.iInvoiceDetail_ID, InvoiceMaster.iInvoiceMaster_ID 
			FROM InvoiceDetail 
			INNER JOIN InvoiceMaster ON InvoiceDetail.iInvoiceMaster_ID = InvoiceMaster.iInvoiceMaster_ID
			WHERE InvoiceDetail.iTenant_ID = #form.iTenant_ID# 
			ORDER BY InvoiceMaster.iInvoiceMaster_ID DESC
		</cfquery>
		
		<!--- can't edit old room rate in InvoiceDetail because it's for the month previous to the currently billed month (since we bill one month in advance)
				so instead, calculate a credit or debit (based on room downgrade/upgrade) and enter it as a Basic Service Fee adjustment for the prev month --->
				
		<!--- compare the OLD room rate to NEW room rate and add Basic Service Fee adjustment --->
		<cfquery name="GetOldReccuringCharge" datasource="#Application.datasource#" maxrows="1">
			SELECT RecurringCharge.iRecurringCharge_ID AS RecCharge, RecurringCharge.mAmount as RCmAmount, Charges.*
			FROM RecurringCharge
			INNER JOIN Charges ON RecurringCharge.iCharge_ID = Charges.iCharge_ID AND Charges.dtRowDeleted is NULL
			INNER JOIN ChargeType ON Charges.iChargeType_ID = ChargeType.iChargeType_ID AND ChargeType.dtRowDeleted is NULL
			WHERE RecurringCharge.iTenant_ID = #form.iTenant_ID# 
			AND RecurringCharge.dtRowDeleted is NULL
			AND ChargeType.iChargeType_ID = #getChargeType.iChargeType_ID#
			ORDER BY iRecurringCharge_ID DESC
		</cfquery>
		
		<!--- get room description for insert into InvoiceDetail table --->
<!--- 		<cfquery name="getRoomDescription" datasource="#application.datasource#">
			SELECT AptAddress.iAptAddress_ID, Charges.cDescription FROM Charges
			INNER JOIN AptAddress ON Charges.iAptType_ID = AptAddress.iAptType_ID
			WHERE AptAddress.iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery> --->
		<cfquery name="getRoomDescription" datasource="#application.datasource#">
			select cDescription from AptType 
			inner join AptAddress ON AptAddress.iAptType_ID = AptType.iAptType_ID
			where AptAddress.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and AptAddress.iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery>
		
		<!--- calulate adjustment for relocation month --->
		
		<!--- calculate adjustment difference by DAY --->
		<cfset oldcharge = #GetOldReccuringCharge.RCmAmount#>
		<cfset newcharge = #form.Recurring_mAmount#>
		
		<cfoutput>oldcharge: '#oldCharge#'  Newcharge: '#newcharge#'</cfoutput><BR>

		<cfif oldcharge is not "" and newcharge is not "">
			<cfset difference = newcharge - oldcharge>
		<cfelse>
			<center><font color="red"><strong>No valid Basic Service Fee recurring charge was found for this resident.  Cannot relocate.</strong></font></center>
			<cfabort>
		</cfif>
		
		<!--- enter Adjustment for relocation month in InvoiceDetail --->
		<cfif difference is not 0>
			<cfif difference GT 0><cfset IncreaseOrDecrease = "Increase"><cfelseif difference LT 0><cfset IncreaseOrDecrease = "Decrease"></cfif>
			<Cfoutput>qty: #newroomqty# #Increaseordecrease# #difference#<BR>
			Room change on #form.month#/#form.day#/#form.year# - #trim(getRoomDescription.cDescription)#. Old rate: #oldcharge#  New Rate: #newcharge#</Cfoutput><p>
			<cfset relocationdate = "#form.month#/#form.year#">
			<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#">
				INSERT INTO InvoiceDetail
					(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
					dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
					iRowStartUser_ID, dtRowStart)
					VALUES
					( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
					#form.iTenant_ID#,
					42,		
					#DateFormat(relocationdate,'YYYYMM')#,
					NULL, 
					GETDATE(),
					#newroomqty#,
					'#IncreaseOrDecrease# Basic Service Fee',	
					#difference#,
					'Room change on #form.month#/#form.day#/#form.year# - #trim(getRoomDescription.cDescription)#. Old rate: #DollarFormat(Oldcharge)#  New Rate: #DollarFormat(Newcharge)#',
					#CreateODBCDateTime(SESSION.AcctStamp)#,
					#session.userid#,
					#TimeStamp#)
			</cfquery>
		</cfif>
		
		<!--- get number of months back the relocation date was --->
		<cfset MoveInMonthsAgo = #month(SESSION.TipsMonth)# - #form.month#>
		
		<!--- if moveinmonths ago is GTE 1, must calculate adjustment for all months in between move in and now --->
		<cfif MoveInMonthsAgo GTE 1>
			<cfset monthtouse = "#form.month#/#form.year#">
			<cfset newmonth = #DateAdd('m', 1, monthtouse)#>
			<cfset NewMonthDifference = 0>
			<cfloop condition="#DateFormat(newmonth, 'MM/YYYY')# LT #DateFormat(SESSION.TipsMonth, 'MM/YYYY')#">
				<cfset DaysInNewMonth = #DaysInMonth(newmonth)#>DaysInNewMonth <cfoutput>#DatePart('m',newmonth)#/#DatePart('yyyy',newmonth)# is #DaysInNewMonth#</cfoutput><BR
				
				<!--- figure old and new amount by DAY --->
				<cfset OldAmount = GetOldReccuringCharge.RCmAmount>OldAmount for days in month: <cfoutput>#OldAmount#</cfoutput><BR>
				<cfset NewAmount = form.Recurring_mAmount>NewAmount for days in month: <cfoutput>#NewAmount#</cfoutput><BR>
				<cfset DailyDifference = NewAmount - OldAmount>
				
				<!--- if entering adjustments by month (instead of one lump sum), enter Adjustment in InvoiceDetail now --->
				<cfif DailyDifference is not 0>
					<cfif DailyDifference GT 0><cfset IncreaseOrDecrease = "Increase"><cfelseif DailyDifference LT 0><cfset IncreaseOrDecrease = "Decrease"></cfif>
					<Cfoutput>qty: #daysinnewmonth# #Increaseordecrease# #DailyDifference#<BR>
					Accounting period #DateFormat(SESSION.TipsMonth,'YYYYMM')# - #trim(getRoomDescription.cDescription)#. Old rate: #OldAmount#  New Rate: #NewAmount#</Cfoutput><p>
					<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#">
						INSERT INTO InvoiceDetail
							(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
							dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
							iRowStartUser_ID, dtRowStart)
							VALUES
							( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
							42,		
							#DateFormat(newmonth,'YYYYMM')#,
							NULL, 
							GETDATE(),
							#DaysInNewMonth#,
							'#IncreaseOrDecrease# Basic Service Fee',	
							#DailyDifference#,
							'#trim(getRoomDescription.cDescription)#. Old rate: #DollarFormat(OldAmount)#  New Rate: #DollarFormat(NewAmount)#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#session.userid#,
							#TimeStamp#)
					</cfquery>
				</cfif>
				
				<!--- increment month --->
				<cfset newmonth = #DateAdd('m', 1, newmonth)#>
			</cfloop>
			
		</cfif>
		
		<!--- edit current accounting periods' invoicedetail row with new daily amount and description --->
		<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#">
			UPDATE InvoiceDetail 
			SET mAmount = #form.recurring_mAmount#, cDescription = 'Basic Service Fee - #trim(getRoomDescription.cDescription)#'
			WHERE iInvoiceDetail_ID = #getmostrecentinvoicedetail.iInvoiceDetail_ID#
		</cfquery>
		
		<!--- set old Recurring Charge to deleted and add new reoccuring charge --->
		<cfquery name="deleteOldReccuringCharge" datasource="#application.datasource#">
			UPDATE RecurringCharge
			SET dtRowDeleted = #TimeStamp#, iRowDeletedUser_ID = #SESSION.UserID#, dtEffectiveEnd = getdate()
			WHERE RecurringCharge.iRecurringCharge_ID = #GetOldReccuringCharge.RecCharge#
		</cfquery>
		
		<!--- setting iCharge_ID and Description to the OLD/ORIGINAL Charge_ID --->
		<cfquery name="insertNewRecurringCharge" datasource="#application.datasource#">
			INSERT INTO RecurringCharge
			( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
			VALUES
			( #form.iTenant_id# ,#GetOldReccuringCharge.iCharge_ID# ,getdate() ,DateAdd("yyyy",10,getdate()) ,1 ,'Basic Service Fee - #TRIM(getRoomDescription.cDescription)#' ,#Form.Recurring_mAmount#, 
			  'Recurring created upon room change' ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.USERID# ,getdate() )
		</cfquery>
	
	<cfelse>
		<!--- their Invoices use a chargetype that cannot be prorated, so nothing happens --->
		
	</cfif>

</CFTRANSACTION>

<!--- ==============================================================================
Redirect page back to the main page with the new Apartment Change
=============================================================================== --->
<cfoutput>
	<CFIF SESSION.USERID IS 3025 OR SESSION.USERID is 3271>
		<a href="FinalizeRelocate.cfm?TenantID=#form.iTenant_id#">Continue</a>
	<cfelse>
		<CFLOCATION URL="FinalizeRelocate.cfm?TenantID=#form.iTenant_id#" ADDTOKEN="No">
	</cfif>
</cfoutput>