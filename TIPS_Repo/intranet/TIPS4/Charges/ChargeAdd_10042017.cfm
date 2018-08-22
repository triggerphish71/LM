<!----------------------------------------------------------------------------------------------
| DESCRIPTION   ChargeAdd.cfm                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name   																			   |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                     												   |                                                                        
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 03/21/2006 | Create Flower Box                                                  | 
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
| rschuette	 | 03/13/2009 | Proj 34921 - query change for duplicate check.					   |
| Jaime Cruz | 06/08/2009 | Modified to fix Medicaid billing issue. 						   |
|S Farmer    | 2017-01-12 | Add Details for populating iDaysBilled on InvoiceDetail record     |
|            |            | with TotalMonthDays                                                |
----------------------------------------------------------------------------------------------->

<!--- ==============================================================================
Retreive TimeStamp
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT	getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<CFSET cAppliesToAcctPeriod = form.AppliesToYear & NumberFormat(form.AppliesToMonth ,"09")>
<!--- 06/08/2009 Added by Jaime Cruz as part of Medicaid Billing fix. --->
<CFSET cDaysInMonth = #DaysInMonth(NumberFormat(form.AppliesToMonth, "09"))#>
<CFSET iDayOfMonth = Day(#now()#)>
<cfset iDaysToCharge = (cDaysInMonth - iDayOfMonth + 1)>
<!--- Proj 34921 - 3/13/2009 Added invoicemaster table so to grab the current invoicemaster id --->
<CFIF IsDefined("form.cDescription") AND IsDefined("mAmount")>
	<CFQUERY NAME = "DuplicateCheck" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	id.* 
		FROM InvoiceDetail id
		Join InvoiceMaster im on (im.iInvoiceMaster_ID = id.iInvoiceMaster_ID and im.bFinalized <>1)
		WHERE id.dtrowdeleted is null 
		AND	id.iTenant_ID = #form.iTenant_ID# AND id.iQuantity = #form.iQuantity#
		AND id.cDescription = '#form.cDescription#' AND id.cAppliesToAcctPeriod='#Variables.cAppliesToAcctPeriod#'
		AND id.mAmount = <CFIF form.mAmount NEQ "">#form.mAmount#<CFELSE>1</CFIF>
		<CFIF form.cComments NEQ ''>AND id.cComments = '#TRIM(form.cComments)#'<CFELSE> AND id.cComments IS NULL </CFIF>
	</CFQUERY>

	<CFIF DuplicateCheck.RecordCount GT 0>
		<CFINCLUDE TEMPLATE="../../header.cfm">
			<BR><BR><BR>
			<A HREF="Charges.cfm" STYLE="font-size: 18; color: red;">	This Record Already exists. Click Here to Continue.	</A>
			<BR><BR>
		<CFINCLUDE TEMPLATE="../../footer.cfm">
		<CFABORT>
	</CFIF>

</CFIF>

<CFTRANSACTION>
	<!--- ==============================================================================
	Retreive Chosen Charge Information
	=============================================================================== --->
	<CFQUERY NAME="ChargeInfo" DATASOURCE = "#APPLICATION.datasource#">
		<CFIF IsDefined("form.iCharge_ID")>
			SELECT * 
			FROM Charges C
			join ChargeType CT on CT.iChargeType_ID = C.iChargeType_ID and CT.dtrowdeleted is null
			WHERE iCharge_ID = #form.iCharge_ID#
		</CFIF>
		<CFIF IsDefined("form.iChargeType_ID")>
			SELECT * FROM ChargeType WHERE iChargeType_ID = #form.iChargeType_ID#
		</CFIF>
	</CFQUERY>

	<!--- ==============================================================================
	Retrieve Tenant Information
	=============================================================================== --->
	<!--- 25575 - RTS - 6/4/2010 - added residency type --->
	<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT	T.*, H.cStateCode, ts.iResidencyType_ID
		FROM Tenant T 
		INNER JOIN House H ON T.iHouse_ID = H.iHouse_ID 
		join tenantstate ts on (ts.iTenant_ID = t.iTenant_ID)
		WHERE T.dtRowDeleted IS NULL AND H.dtRowDeleted IS NULL AND T.iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
	<cfset resType = qTenant.iResidencyType_ID>
			<!--- ------------------------------------------- --->
			<!--- Added by Katie: 10/1/03: Do the calculation so amount is added into Invoice Details properly for State Medicaid if Daily is checked and it's the proper state --->
			
			<cfif ChargeInfo.iChargeType_ID is 8 OR ChargeInfo.iChargeType_ID is 1661 >
				<!--- get copay and R&B amounts from Invoice Detail for same AppliesToAcctPeriod (Tips Month) if they exist --->
				<cfquery name="getMedicaidCoPay" datasource="#application.datasource#">
					SELECT iInvoiceDetail_ID, mAmount from InvoiceDetail
					WHERE iTenant_ID = #form.iTenant_ID# AND cAppliesToAcctPeriod= <CFIF Variables.cAppliesToAcctPeriod NEQ "">'#Variables.cAppliesToAcctPeriod#'<CFELSE>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</CFIF> AND iChargeType_ID = 1661 AND dtRowDeleted IS NULL
				</cfquery>
				
				<cfquery name="getStateMedicaid" datasource="#application.datasource#">
					SELECT iInvoiceDetail_ID, mAmount from InvoiceDetail
					WHERE iTenant_ID = #form.iTenant_ID# AND cAppliesToAcctPeriod= <CFIF Variables.cAppliesToAcctPeriod NEQ "">'#Variables.cAppliesToAcctPeriod#'<CFELSE>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</CFIF> AND iChargeType_ID = 8 AND dtRowDeleted IS NULL
				</cfquery>
				
				<cfif getMedicaidCopay.recordcount is not 0>
					<cfset MedicaidCopay = #getMedicaidCopay.mAmount#>
				<cfelse>
					<cfset MedicaidCopay = 0>
				</cfif>
				
				<cfif getStateMedicaid.recordcount is not 0>
					<!--- get the mAmount (in most cases: DAILY rate the state approves) from the recurring charges table --->
					<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
						SELECT mAmount 
						FROM recurringcharge 
						WHERE iTenant_ID = #form.iTenant_ID# AND cDescription like '%State Medicaid%' and dtRowDeleted IS NULL
					</cfquery>
					<cfset StateMedicaid = #StateMedicaidRecurringInfo.mAmount#>
				<cfelse>
					<cfset StateMedicaid = 0>
				</cfif>
				
				<!--- calculate the New MONTHLY Amount for State Medicaid --->
				<!--- 06/08/2009 Modified by Jaime Cruz as part of Medicaid Billing fix. --->
				<CFIF Variables.cAppliesToAcctPeriod NEQ "">
					<cfset TotalMonthDays = Variables.cDaysInMonth>
				<CFELSE>
					<cfset TotalMonthDays = #DaysInMonth(SESSION.TipsMonth)#>
				</CFIF>

				<cfoutput>State: #qTenant.cStateCode#  ChargeTypeID: #ChargeInfo.iChargeType_ID#</cfoutput><BR>
				
				<cfif qTenant.cStateCode is not "OR">
					<cfif ChargeInfo.iChargeType_ID is 8 AND isDefined("form.bIsDaily") AND form.bIsDaily is "1">
						<!--- only do this equasion if entering a state medicaid recurring charge --->
						<cfset NewAmount = (#form.mAmount# * #TotalMonthDays#) - #MedicaidCoPay#>
					<cfelseif ChargeInfo.iChargeType_ID is 1661>
						<!--- only do this equasion if entering a medicaid Copay charge and State Medicaid recurring is DAILY--->
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
							SELECT bIsDaily 
							FROM recurringcharge 
							WHERE iTenant_ID = #form.iTenant_ID# 
							AND cDescription like '%State Medicaid%' and dtRowDeleted IS NULL
						</cfquery>
						<!--- 06/08/2009 Modified by Jaime Cruz as part of Medicaid Billing fix. --->
						<!--- Was using form value which should only be applied when the State   --->
						<!--- Medicaid is being changed.										 --->
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>
							<cfif isDefined("form.mAmount") and form.mAmount gt 0>
								<cfset addCoPay = #form.mAmount# >
							<cfelse>
								<cfset addCoPay = 0.00>
							</cfif>
							<cfset NewAmount = (#StateMedicaid# * #TotalMonthDays#) - (#MedicaidCoPay# + #addCoPay#)>
						</cfif>
					</cfif>
				<cfelseif  qTenant.cStateCode is "OR">
		
					<cfif ChargeInfo.iChargeType_ID is 8 and isDefined("form.bIsDaily") and form.bIsDaily is "1">
							<cfset NewAmount = (#form.mAmount# * #TotalMonthDays#)>
						
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
					<cfelseif ChargeInfo.iChargeType_ID is 8 and isDefined("form.bIsDaily") and form.bIsDaily is not "1">
						<cfset NewAmount = #form.mAmount# >
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
					<cfelseif ChargeInfo.iChargeType_ID is 1661>					
						<cfquery name="StateMedicaidRecurringInfo" datasource="#application.datasource#">
							select bIsDaily 
							from recurringcharge 
							where iTenant_ID = #form.iTenant_ID# 
							and cDescription like '%State Medicaid%' and dtRowDeleted is null
						</cfquery>						
						<cfif StateMedicaidRecurringInfo.bIsDaily is 1>							
								<cfset NewAmount = (#StateMedicaid# * #TotalMonthDays#) - #form.mAmount# >
								<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						<cfelseif StateMedicaidRecurringInfo.bIsDaily is not 1>
							<cfset NewAmount = #form.mAmount# >
						<cfif NewAmount LT 0><cfset NewAmount = 0></cfif>
						</cfif>
					</cfif>		 			
				</cfif>
			</cfif>
			<cfif isDefined("NewAmount")>New Amount: <cfoutput>#newamount#</cfoutput><BR></cfif>
					
			<!--- calculate TotalMonthDays --->
			<!--- <cfset TotalMonthDays = #DaysInMonth(SESSION.TipsMonth)#> --->
		<!--- 25575 - RTS - 6/4/2010 - Respite quantity --->
			<cfif resType neq 3>
				<cfif isDefined("form.bIsDaily") and form.bIsDaily is "1">
					<cfset iQuantity = #TotalMonthDays#>
				<cfelse>
					<cfset iQuantity = #form.iQuantity#>
				</cfif>
			<cfelse>
				<cfquery name="RespiteInvoiceInfoMSTR" datasource="#application.datasource#">
					select IM.* from InvoiceMaster IM
					WHERE IM.iInvoiceMaster_ID = (select max(im2.iInvoiceMaster_ID) 
									from InvoiceMaster im2
									join tenant t2 on (t2.cSolomonKey = im2.cSolomonKey)
									where im2.dtRowDeleted is null
									and t2.iTenant_ID = #form.iTenant_ID# 
									and im2.bFinalized is null
									)
				</cfquery>
				<cfset RespiteInvoiceMSTRID = RespiteInvoiceInfoMSTR.iInvoiceMaster_ID>
				<cfquery name="PeriodCheckForRInvoice" datasource="#Application.datasource#">
					select datediff(mm,im.dtInvoiceStart,im.dtInvoiceEnd) as Periods
					from InvoiceMaster im
					join tenant t on (t.cSolomonKey = im.cSolomonKey)
					where t.iTenant_ID = #form.iTenant_ID#
					and im.iInvoiceMaster_ID = (select max(im2.iInvoiceMaster_ID) 
									from InvoiceMaster im2
									join tenant t2 on (t2.cSolomonKey = im2.cSolomonKey)
									where im2.dtRowDeleted is null
									and t2.iTenant_ID = #form.iTenant_ID# 
									and im2.bFinalized is null
									)
				</cfquery>
				<cfscript>
					INVMSTRStartDate = RespiteInvoiceInfoMSTR.dtInvoiceStart;
					INVMSTREndDate = RespiteInvoiceInfoMSTR.dtInvoiceEnd;
					Periods = PeriodCheckForRInvoice.Periods;
				</cfscript>
				<cfquery NAME="RInvoiceInfo" DATASOURCE="#APPLICATION.datasource#">
					select datediff(dd,im.dtInvoiceStart,im.dtInvoiceEnd)+ 1 as Days
					from InvoiceMaster im
					join tenant t on (t.cSolomonKey = im.cSolomonKey)
					where t.iTenant_ID = #form.iTenant_ID#
					and im.iInvoiceMaster_ID = (select max(im2.iInvoiceMaster_ID) 
									from InvoiceMaster im2
									join tenant t2 on (t2.cSolomonKey = im2.cSolomonKey)
									where im2.dtRowDeleted is null
									and t2.iTenant_ID = #form.iTenant_ID# 
									and im2.bFinalized is null
									)
				</cfquery>
				
			</cfif>
		<!--- end 25575 --->
			<!--- 25575 - 8/5/2010 - Respite insert to take place below all this --->
			<cfif resType neq 3>
					<!--- ==============================================================================
						If no records exist and it is in the proper effective range.
						Insert a new record in to the Database
					=============================================================================== --->
					<!--- insert detail of record submitting change for --->
					<cfif ChargeInfo.iChargeType_ID is not 8 OR 
						(ChargeInfo.iChargeType_ID is 8 AND not isDefined("form.bIsDaily"))>
						<!--- enter in detail for most charges --->
						<!--- 25575 - rts - 6/4/2010 - respite quantity usage --->
						<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#" result="InsertDetail1">
							INSERT INTO InvoiceDetail
							(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj
								, dtTransaction,iQuantity, cDescription, mAmount, cComments, dtAcctStamp
								, iRowStartUser_ID, dtRowStart,idaysbilled
								 ) <!--- , cInvoiceComments --->
							VALUES
							(
								#form.iInvoiceMaster_ID#,
								#form.iTenant_ID#,
								<!---Mamta added this as CF charge does not go to SL if they are 69 chargetype--->
								<cfif #ChargeInfo.iChargeType_ID# eq 69>
								1741,
								<cfelse>
								#ChargeInfo.iChargeType_ID#,
								</cfif>
								<CFIF Variables.cAppliesToAcctPeriod NEQ "">
									'#Variables.cAppliesToAcctPeriod#',
								<CFELSE>
									<CFSET AcctStamp = Year(SESSION.AcctStamp) & NumberFormat(SESSION.AcctStamp, "09")>
									'#Variables.AcctStamp#',
								</CFIF>
								<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, 
								<CFELSE> NULL, 
								</CFIF>
								getdate(),
								<CFIF IsDefined("form.iQuantity")> #form.iQuantity#, 
								<CFELSE> #ChargeInfo.iQuantity#,
								</CFIF>
								<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', 
								<CFELSE> '#ChargeInfo.cDescription#', 
								</CFIF>
								<CFIF IsDefined("form.mAmount")> #form.mAmount#, 
								<CFELSE> #IsBlank(ChargeInfo.mAmount,0.00)#,	
								</CFIF>
								<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', 
								<CFELSE> NULL, 
								</CFIF>
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								#SESSION.UserID#,
								#TimeStamp#,
								<CFIF IsDefined("form.iQuantity")> #form.iQuantity#
								<CFELSE> #ChargeInfo.iQuantity#
								</CFIF>
                                <!--- , <CFIF IsDefined("form.cInvoiceComments")>'#TRIM(form.cInvoiceComments)#'<cfelse>NULL</CFIF> --->
							)
						</CFQUERY>
						<cfdump var="#InsertDetail1#">
					<cfelseif ChargeInfo.iChargeType_ID is 8 AND isDefined("form.bIsDaily") AND form.bIsDaily is "1">
						<!--- enter in detail for State Medicaid DAILY charges --->
						<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
							INSERT INTO InvoiceDetail
							(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID
							, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction
							, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart )
							<!---  cInvoiceComments --->
							VALUES
							(
								#form.iInvoiceMaster_ID#, 
								#form.iTenant_ID#,
								#ChargeInfo.iChargeType_ID#,
								<CFIF Variables.cAppliesToAcctPeriod NEQ "">
									'#Variables.cAppliesToAcctPeriod#',
								<CFELSE>
									<CFSET AcctStamp = Year(SESSION.AcctStamp) & NumberFormat(SESSION.AcctStamp, "09")>
									'#Variables.AcctStamp#',
								</CFIF>
								<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, 
								<CFELSE> NULL, 
								</CFIF>
								getdate(),
								1,
								<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', 
								<CFELSE> '#ChargeInfo.cDescription#', 
								</CFIF>
								#NewAmount#,
								<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', 
								<CFELSE> NULL, 
								</CFIF>
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								#SESSION.UserID#,
								#TimeStamp# 
                               <!---  '#form.cInvoiceComments#' --->
							)
						</CFQUERY>
					</cfif>
			<cfelse><!--- RESPITE - 25575--->
				<cfif not isDefined("form.bIsDaily") OR form.bIsDaily neq "1" ><!---  Not daily, qty is 1 or keyed (1 is default on screen) --->
					<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
							INSERT INTO InvoiceDetail
							(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj
							, dtTransaction, iQuantity, cDescription, mAmount, cComments
								, dtAcctStamp, iRowStartUser_ID, dtRowStarts, iDaysBilled  ) <!--- , cInvoiceComment --->
							VALUES
							(
								#RespiteInvoiceMSTRID#,<!--- #form.iInvoiceMaster_ID#, --->
								#form.iTenant_ID#,
								<cfif #ChargeInfo.iChargeType_ID# eq 69>
								1741,
								<cfelse>
								#ChargeInfo.iChargeType_ID#,
								</cfif>
								<CFIF Variables.cAppliesToAcctPeriod NEQ "">
									'#Variables.cAppliesToAcctPeriod#',
								<CFELSE>
									<CFSET AcctStamp = Year(SESSION.AcctStamp) & NumberFormat(SESSION.AcctStamp, "09")>
									'#Variables.AcctStamp#',
								</CFIF>
								<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, 
								<CFELSE> NULL, 
								</CFIF>
								getdate(),
								<CFIF IsDefined("form.iQuantity")> #form.iQuantity#, 
								<CFELSE> #ChargeInfo.iQuantity#, 
								</CFIF>
								<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', 
								<CFELSE> '#ChargeInfo.cDescription#', 
								</CFIF>
								<CFIF IsDefined("form.mAmount")> #form.mAmount#, 
								<CFELSE> #IsBlank(ChargeInfo.mAmount,0.00)#,	
								</CFIF>
								<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', 
								<CFELSE> NULL, 
								</CFIF>
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								#SESSION.UserID#,
								#TimeStamp# ,
								<CFIF IsDefined("form.iQuantity")> #form.iQuantity#, 
								<CFELSE> #ChargeInfo.iQuantity#, 
								</CFIF>
                               
							)	<!---  '#form.cInvoiceComments#' --->
					</CFQUERY>
				<cfelse><!--- IS DAILY --->
					<cfif Month(RespiteInvoiceInfoMSTR.dtInvoiceStart) eq Month(RespiteInvoiceInfoMSTR.dtInvoiceEnd)>
						<cfif Len(Month(RespiteInvoiceInfoMSTR.dtInvoiceStart)) lt 2>
							<cfset AcctMnth = "0"& Month(RespiteInvoiceInfoMSTR.dtInvoiceStart)>
						<cfelse>
							<cfset AcctMnth = Month(RespiteInvoiceInfoMSTR.dtInvoiceStart)>
						</cfif>
						<cfset APeriod = Year(RespiteInvoiceInfoMSTR.dtInvoiceStart)& AcctMnth>
						<cfset QuantityDays = RInvoiceInfo.Days>
						<!--- <cfset QuantityDays=datediff("d",RespiteInvoiceInfoMSTR.dtInvoiceStart,RespiteInvoiceInfoMSTR.dtInvoiceEnd);> --->
							<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
								INSERT INTO InvoiceDetail
								(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod
								, bIsRentAdj, dtTransaction, iQuantity, cDescription, mAmount
									, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, iDaysBilled  )
									 <!--- cInvoiceComments --->
								VALUES
								(
									#form.iInvoiceMaster_ID#,
									#form.iTenant_ID#,
									#ChargeInfo.iChargeType_ID#,
									'#APeriod#',
									<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, 
									<CFELSE> NULL, 
									</CFIF>
									getdate(),
									#QuantityDays#,
									<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', 
									<CFELSE> '#ChargeInfo.cDescription#', 
									</CFIF>
									<CFIF IsDefined("form.mAmount")> #form.mAmount#, 
									<CFELSE> #IsBlank(ChargeInfo.mAmount,0.00)#,	
									</CFIF>
									<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', 
									<CFELSE> NULL, 
									</CFIF>
									#CreateODBCDateTime(SESSION.AcctStamp)#,
									#SESSION.UserID#,
									#TimeStamp# ,
									#QuantityDays#                                    
								) <!--- '#form.cInvoiceComments#' --->
							</CFQUERY>
					<cfelse>
						<cfscript> MPeriods = Periods;</cfscript>
						<cfloop from="0" to="#MPeriods#" step="1" index="i">
							<cfif i eq 0><!--- Beginning Period --->
								<cfscript> 
								FirstDayOfBillingMonth = dateadd("m",i+1,INVMSTRStartDate);
								FirstDayOfBillingMonth = MONTH(FirstDayOfBillingMonth)&'/01/'&YEAR(FirstDayOfBillingMonth);
								QuantityDays=datediff("d",INVMSTRStartDate,FirstDayOfBillingMonth);
								if(Len(Month(INVMSTRStartDate)) lt 2) 
									{AcctMnth = "0"&Month(INVMSTRStartDate);}
								else{AcctMnth = Month(INVMSTRStartDate);}
								</cfscript>
								<cfset APeriod = Year(INVMSTRStartDate)& AcctMnth>
									<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
										INSERT INTO InvoiceDetail
										(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod
										, bIsRentAdj, dtTransaction, iQuantity, cDescription, mAmount
											, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled  )<!---  cInvoiceComments --->
										VALUES
										(
											#form.iInvoiceMaster_ID#,
											#form.iTenant_ID#,
											#ChargeInfo.iChargeType_ID#,
											'#APeriod#',
											<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, 
											<CFELSE> NULL, 
											</CFIF>
											getdate(),
											#QuantityDays#,
											<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', 
											<CFELSE> '#ChargeInfo.cDescription#', 
											</CFIF>
											<CFIF IsDefined("form.mAmount")> #form.mAmount#, 
											<CFELSE> #IsBlank(ChargeInfo.mAmount,0.00)#,	
											</CFIF>
											<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', 
											<CFELSE> NULL, 
											</CFIF>
											#CreateODBCDateTime(SESSION.AcctStamp)#,
											#SESSION.UserID#,
											#TimeStamp# ,
											#iDaysToCharge#                                          
										) <!---  '#form.cInvoiceComments#' --->
									</CFQUERY>
							<cfelseif i eq MPeriods> <!--- Ending Period --->
								<cfscript>
									FirstDayOfBillingMonth = DateAdd("m",i,INVMSTRStartDate);
									FirstdayOfBillingMonth = MONTH(	FirstdayOfBillingMonth)&"/01/"&YEAR(FirstdayOfBillingMonth);
									QuantityDays = DateDiff("d",FirstdayOfBillingMonth,INVMSTREndDate)+1;
									if (Len(Month(dateadd("m",i,INVMSTRStartDate))) lt 2)
										{AcctMnth = "0"& Month(dateadd("m",i,INVMSTRStartDate));}
									else{AcctMnth = Month(dateadd("m",i,INVMSTRStartDate));}
									APeriod = Year(dateadd("m",i,INVMSTRStartDate))& AcctMnth;
								</cfscript>
									<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
										INSERT INTO InvoiceDetail
										(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID
										, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
											iQuantity, cDescription, mAmount, cComments, dtAcctStamp
											, iRowStartUser_ID, dtRowStart, iDaysBilled)<!---  , cInvoiceComments --->
										VALUES
										(
											#RespiteInvoiceMSTRID#,
											#form.iTenant_ID#,
											#ChargeInfo.iChargeType_ID#,
											'#APeriod#',
											<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, 
											<CFELSE> NULL, 
											</CFIF>
											getdate(),
											#QuantityDays#,
											<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', 
											<CFELSE> '#ChargeInfo.cDescription#',
											 </CFIF>
											<CFIF IsDefined("form.mAmount")> #form.mAmount#,
											 <CFELSE> #IsBlank(ChargeInfo.mAmount,0.00)#,	
											 </CFIF>
											<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', 
											<CFELSE> NULL, 
											</CFIF>
											#CreateODBCDateTime(SESSION.AcctStamp)#,
											#SESSION.UserID#,
											#TimeStamp#,
											#QuantityDays#
                                          <!---   '#form.cInvoiceComments#' --->
										)
									</CFQUERY>
							<cfelse> <!--- Middle Period --->
								<cfscript>
								QuantityDays = DaysInMonth(DateAdd("m",i,INVMSTRStartDate));
								if(Len(Month(dateadd("m",i,INVMSTRStartDate))) lt 2)
									{AcctMnth = "0"& Month(dateadd("m",i,INVMSTRStartDate));}
								else{AcctMnth = Month(dateadd("m",i,INVMSTRStartDate));}
								APeriod = Year(dateadd("m",i,INVMSTRStartDate))& AcctMnth;
								</cfscript>
								<CFQUERY NAME = "InsertDetail" DATASOURCE = "#APPLICATION.datasource#">
										INSERT INTO InvoiceDetail
										(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod
										, bIsRentAdj, dtTransaction, iQuantity, cDescription, mAmount
										, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, iDaysBilled ) <!--- , cInvoiceComments --->
										VALUES
										(
											#RespiteInvoiceMSTRID#,
											#form.iTenant_ID#,
											#ChargeInfo.iChargeType_ID#,
											'#APeriod#',
											<CFIF ChargeInfo.bIsRent NEQ ""> #ChargeInfo.bIsRent#, <CFELSE> NULL, </CFIF>
											getdate(),
											#QuantityDays#,
											<CFIF IsDefined("form.cDescription")> '#TRIM(form.cDescription)#', <CFELSE> '#ChargeInfo.cDescription#', </CFIF>
											<CFIF IsDefined("form.mAmount")> #form.mAmount#, <CFELSE> #IsBlank(ChargeInfo.mAmount,0.00)#,	</CFIF>
											<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', <CFELSE> NULL, </CFIF>
											#CreateODBCDateTime(SESSION.AcctStamp)#,
											#SESSION.UserID#,
											#TimeStamp# ,
                                           #iDaysToCharge#
										) <!---  '#form.cInvoiceComments#' --->
									</CFQUERY>
							</cfif>
						</cfloop>
					</cfif>
				</cfif>
			</cfif>
		<!--- 	End 25575 --->
			<cfif isDefined("NewAmount") and ChargeInfo.iChargeType_ID is 1661 and getStateMedicaid.recordcount is not 0>
				<!--- if entering co-pay, and State Medicaid amount already exits, update State Medicaid amount in recurring charges AND invoice details --->
				<CFQUERY NAME = "UpdateStateMedicaidDetail" DATASOURCE = "#APPLICATION.datasource#">
					UPDATE	InvoiceDetail
					SET		 mAmount = #NewAmount# 
							,iQuantity = 1
							,dtRowStart = getDate() 
							,iRowStartUser_ID = 0 <!--- #User# --->
					WHERE	iInvoiceDetail_ID = #getStateMedicaid.iInvoiceDetail_ID#
				</CFQUERY>
			</cfif>
	
<CFIF (IsDefined("AUTH_USER") AND AUTH_USER EQ 'ALC\PaulB') OR 1 EQ 1>
	<CFQUERY NAME="qResident" DATASOURCE="#APPLICATION.datasource#">
		select * from tenant where dtrowdeleted is null and itenant_id = #form.itenant_id#
	</CFQUERY>
	<CFQUERY NAME='qDetail' DATASOURCE='#APPLICATION.datasource#'>
		select inv.cdescription as description, inv.mamount as amount, inv.iquantity as quantity, sum(inv.mamount * inv.iquantity) as extended
			,inv.ccomments as comments
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
			and inv.dtrowdeleted is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
			and im.bfinalized is null
		where im.csolomonkey = '#qResident.cSolomonKey#' and inv.itenant_id = #qResident.itenant_id#
		and im.cappliestoacctperiod='#trim(Variables.cAppliesToAcctPeriod)#'
		group by inv.cdescription, inv.mamount, inv.iquantity, inv.ccomments
	</CFQUERY>
	<CFSET results="<BR><BR>Current Charges:<BR><TABLE STYLE='border: 1px solid black; text-align: right;'>">
	<CFSET results = results & "<TR><TD>Description</TD><TD>Amount</TD><TD>Quantity</TD><TD>Extended</TD><TD>Comments</TD></TR>">
	<CFLOOP QUERY='qDetail'>
		<CFSET results = results & "<TR><TD>#qDetail.Description#</TD><TD>#qDetail.Amount#</TD><TD>#qDetail.quantity#</TD><TD>#qDetail.extended#</TD><TD>#qDetail.comments#</TD></TR>">
	</CFLOOP>
	<CFQUERY NAME='qTotal' DATASOURCE='#APPLICATION.datasource#'>
		select sum(inv.mamount * inv.iquantity) as total
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
			and inv.dtrowdeleted is null and im.bmoveoutinvoice is null and im.bmoveininvoice is null
			and im.bfinalized is null
		where im.csolomonkey = '#qResident.cSolomonKey#' and inv.itenant_id = #qResident.itenant_id#
		and im.cappliestoacctperiod='#trim(Variables.cAppliesToAcctPeriod)#'
	</CFQUERY>
	<CFSET results = results & "<TR><TD COLSPAN=100 STYLE='text-align: right;'>Current Total = #qTotal.total#</TD></TR>">
	<CFSET results = results & "</TABLE>">
	<CFIF isDefined("SESSION.RDOEmail") AND ChargeInfo.bDirectorEmail GT 0>
		<CFSCRIPT>
			if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='CFDevelopers@alcco.com'; }
			else { email=SESSION.RDOEmail; } 
			message= "<STRONG>" & ChargeInfo.cdescription & "</STRONG>" & " has been entered for " & qResident.cFirstName & ', ' & qResident.cLastName & ' at ' & SESSION.HouseName & ' ' & "<BR>";
			message= message & "A charge has been entered for " & LSCurrencyFormat(form.mAmount);
			message= message & "<BR>by: " & SESSION.FullName;
			//message= message & "<BR>" & results & "****";
		</CFSCRIPT>

		<CFMAIL TYPE ="HTML" FROM="TIPS4_ChargeAdded@alcco.com" TO="#email#" SUBJECT="Current Month Charge Added for #SESSION.HouseName#">#message#</CFMAIL>
	</CFIF>
</CFIF>
</CFTRANSACTION>

<CFOUTPUT>
	<CFIF isDefined("AUTH_USER") AND (AUTH_USER EQ 'ALC\cebbott' OR SESSION.USERID is 3271)>
		<A HREF = "#HTTP.REFERER#?Added=#form.iTenant_ID#"> Continue </A>
	<CFELSE>
		<CFLOCATION URL="Charges.cfm?Added=#form.iTenant_ID#" ADDTOKEN="No">
	</CFIF>
</CFOUTPUT>
