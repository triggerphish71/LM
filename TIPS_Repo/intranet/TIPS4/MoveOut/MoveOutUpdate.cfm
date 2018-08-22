<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/MoveOutUpdate.cfm                                                      |
|----------------------------------------------------------------------------------------------|
| Called by: 		MoveOutForm..cfm														   |
| Calls/Submits:	MoveOutFormSummary.cfm 													   |
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
|sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 07/19/2012 | 92897 - invoicecomments not saving, corrected query UpdateTotal    |
|s Farmer    | 11/27/2013 | 105419 - zero default added to NRF deferred fields in tenant query |
|sfarmer     | 12/10/2013 | 112478 - adjustments to Billing Information                        |
|sfarmer     | 05/05/2014 | 117056 - NewLinkTenantContact - changed  #TRIM(form.cComments)#' to           |
|            |            | <CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', <CFELSE> NULL, </CFIF> |
|sfarmer     } 08/06/2014 | 119240 limited cdescription at invoicedetail to 50 chars.                     |
|S Farmer    | 2015-01-12 | 116824   Final Move-in Enhancements                                           |
|S Farmer    | 2017-01-10 | Add Details for populating iDaysBilled                             |
---------------------------------------------------------------------------------------------------------->
<!---  <cfdump var="#form#" label="form" >
<br />
<cfabort>  --->
<CFPARAM name="ShowBtn" default="True">
<cfparam name="CFREMAININGBAL" default="">
<cfparam name="ProrateFactorSet" default="">
<cfparam name="lastinvoiceperiod" default="">

<cfset todaysdate = CreateODBCDateTime(now())> 
 
<CFQUERY NAME="qTipsMonth" DATASOURCE='#APPLICATION.datasource#'>
	select iHouse_ID, dtCurrentTipsMonth
	 from houselog with (NOLOCK)
	where dtrowdeleted is null and ihouse_id = #SESSION.qSelectedHouse.iHouse_id#
</CFQUERY> 

<CFTRY>
	<CFSCRIPT>
		CareDate = form.moveincaremonth& "/" & form.moveincareday  & "/" & form.moveincareyear;
		ChargeDate = form.CHARGEMONTH & "/" & form.CHARGEDAY & "/" & form.CHARGEYEAR;
		NoticeDate = form.NOTICEMONTH & "/" & form.NOTICEDAY & "/" & form.NOTICEYEAR;
		MoveOutDate = form.MOVEOUTMONTH & "/" & form.MOVEOUTDAY & "/" & form.MOVEOUTYEAR;
		ChargeMonthCompareDate = form.CHARGEMONTH & "/01/" & form.CHARGEYEAR;
		if (len(form.CHARGEMONTH) eq 1)
		{MoveOutPeriod = form.CHARGEYEAR&'0'&form.CHARGEMONTH;
		 TipsPeriod = year(qTipsMonth.dtCurrentTipsMonth)&'0'&month(qTipsMonth.dtCurrentTipsMonth);
		 ThisPeriod = year(todaysdate)&'0'&month(todaysdate);}
		else
		{MoveOutPeriod = form.CHARGEYEAR&form.CHARGEMONTH;
		 TipsPeriod = year(qTipsMonth.dtCurrentTipsMonth)&month(qTipsMonth.dtCurrentTipsMonth);
		 ThisPeriod = year(todaysdate)&month(todaysdate);}
 		
		dtCareDate = CreateODBCDateTime(CareDate);
		dtChargeThrough=CreateODBCDateTime(ChargeDate);
		dtNotice=CreateODBCDateTime(NoticeDate);
		dtMoveOut=CreateODBCDateTime(MoveOutDate);
		dtChargeMonthCompareDate=CreateODBCDateTime(ChargeMonthCompareDate);
	</CFSCRIPT>	
	<CFCATCH TYPE="ANY">	
			<CENTER STYLE="color:red;font-size:medium;">
				An invalid MoveOut Date, Notice Date, <BR> or ChargeThrough Date has been entered.<BR>
				<CFOUTPUT><A HREF="#http.referer#">Click here to correct this date.</A></CFOUTPUT>
			</CENTER>
		<CFABORT>
	</CFCATCH>
</CFTRY>
<cfoutput>ChargeMonthCompareDate #ChargeMonthCompareDate # </cfoutput>
<CFIF NOT IsDefined("SESSION.TipsMonth") OR NOT IsDefined("SESSION.USERID")>
	<CFLOCATION URL='../MainMenu.cfm' ADDTOKEN="yes">
</CFIF>

<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#"> 
	SELECT getdate() as TimeStamp
</CFQUERY>

<CFSCRIPT>
	TimeStamp = TRIM(qTimeStamp.TimeStamp);
	CurrPer = DateFormat(SESSION.TIPSMonth,"yyyymm");
</CFSCRIPT>

<!--- ==============================================================================
Retrieve Tenant Information// mamta added  ,TS.dtSecondarySwitchDate,ts.dtfulltocompanion 
and dtcomapniontofull
=============================================================================== ---> 
	<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT	T.iTenant_ID, T.cSolomonkey, TS.iResidencyType_ID
				, TS.dtChargeThrough, TS.dtMoveIn, ts.dtRentEffective
				, TS.iTenantStateCode_ID, T.iHouse_ID
				, T.cFirstName, T.cLastName, TS.dtMoveOut
				, IsNull(TS.mAmtDeferred,0) as AmtDeferred
				, IsNUll(TS.IMONTHSDEFERRED,0) as MONTHSDEFERRED
				, IsNUll(ts.mAdjNRF,0) as AdjNRF
				,IsNull(ts.mAmtNRFPaid,0) AmtNRFPaid
				,TS.dtSecondarySwitchDate
				,Ts.dtCompanionToFullSwitch
				,Ts.dtFullToCompanionSwitch
				,ts.mMedicaidCopay,ts.iProductline_ID
				,t.cbillingtype
		FROM Tenant	T with (NOLOCK)
		JOIN TenantState TS with (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID		
		JOIN ResidencyType RT with (NOLOCK) ON RT.iResidencyType_ID = TS.iResidencyType_ID
		LEFT OUTER JOIN	AptAddress AD with (NOLOCK) ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
		WHERE T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL AND T.iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
	
	<cfset thesedaysinmonth = daysinmonth(#Tenant.dtmovein#)>
	<cfscript>
	if (len(Month(Tenant.dtMoveIn)) eq 1){
			MoveInPeriod = year(Tenant.dtMoveIn)&'0'&Month(Tenant.dtMoveIn);}
	else{	MoveInPeriod = year(Tenant.dtMoveIn)&Month(Tenant.dtMoveIn);}
	</cfscript>
	<cfquery name="qryHouseMedicaid" DATASOURCE = "#APPLICATION.datasource#"> 
		select mMedicaidBSF from HouseMedicaid with (NOLOCK) where ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>
	<cfoutput><br />MoveOutPeriod #MoveOutPeriod# :: ThisPeriod #ThisPeriod# ::
	TipsPeriod #TipsPeriod# :: MoveInPeriod #MoveInPeriod# ::mMedicaidBSF #qryHouseMedicaid.mMedicaidBSF# 
	:: mMedicaidCopay #tenant.mMedicaidCopay#<br /></cfoutput>
<!--- Check for an Existing Move Out Invoice--->
	<CFQUERY NAME="InvoiceCheck" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Distinct iInvoiceMaster_ID, iInvoiceNumber, dtInvoiceStart
		FROM	InvoiceMaster IM with (NOLOCK)
		WHERE IM.cSolomonKey = '#TRIM(Tenant.cSolomonKey)#'
		AND bMoveOutInvoice IS NOT NULL	AND IM.bFinalized IS NULL AND IM.dtRowDeleted IS NULL
		AND (1 <= (select count(iinvoicedetail_id) from invoicedetail with (NOLOCK) where dtrowdeleted is null
			and itenant_id = #Tenant.iTenant_id# and iinvoicemaster_id = im.iinvoicemaster_id)
		OR 0 = (select count(iinvoicedetail_id) from invoicedetail with (NOLOCK) where dtrowdeleted is null
			and iinvoicemaster_id = im.iinvoicemaster_id) )
	</CFQUERY>

	<CFIF InvoiceCheck.RecordCount GT 0> 
		<!---Deleted all prior system detail records before writing new records --->
		<CFQUERY NAME = "DeleteDetail" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	InvoiceDetail
			SET	iRowDeletedUser_ID = #SESSION.UserID#, dtRowDeleted = '#TimeStamp#'
			WHERE iInvoiceMaster_ID = #InvoiceCheck.iInvoiceMaster_ID#
			AND dtRowDeleted IS NULL AND iRowStartUser_ID = 0 AND iTenant_ID = #Tenant.iTenant_ID#
		</CFQUERY>
	</CFIF>

	<CFIF InvoiceCheck.RecordCount EQ 0> 
		<!--- Retrieve the next invoice number --->
		<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
			select iNextInvoice 
			from HouseNumberControl with (NOLOCK)
			where dtRowDeleted is null
			and iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# 
		</CFQUERY>
		
		<CFSET HouseNumber = SESSION.HouseNumber>
		<CFSET iInvoiceNumber = Variables.HouseNumber & GetNextInvoice.iNextInvoice>	
		
		<!--- Calculate and Record a new Invoice Number --->
		<CFQUERY NAME = "NewInvoice" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO InvoiceMaster
				( iInvoiceNumber ,cSolomonKey ,bMoveOutInvoice ,bFinalized ,cAppliesToAcctPeriod ,cComments, 
				mLastInvoiceTotal ,dtAcctStamp ,dtInvoiceStart ,iRowStartUser_ID ,dtRowStart )
			VALUES
				(<CFSET iInvoiceNumber = '#Variables.iInvoiceNumber#' & 'MO'>
				'#Variables.iInvoiceNumber#',
				 '#Tenant.cSolomonKey#',
				1,
				 NULL,
				<CFSET AppliesTo = Year(SESSION.TipsMonth) & DateFormat(SESSION.TipsMonth, "mm")>
				'#Variables.AppliesTo#',
				<CFIF IsDefined("form.InvoiceComments") AND form.InvoiceComments NEQ "">
				'#TRIM(form.InvoiceComments)#',
				<CFELSE>
				NULL,
				</CFIF>
				0,
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				getdate(),
				 #SESSION.UserID#,getDate() )
		</CFQUERY> 
		
		<!--- Increment the next Invoice Number in the HouseNumberControl Table --->
		<CFQUERY NAME = "HouseNumberControl" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	HouseNumberControl
			SET		iNextInvoice = #GetNextInvoice.iNextInvoice + 1#
			WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>

		<!--- Retrieve the Invoice Master ID that was created above --->
		<CFQUERY NAME = "NewMasterID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceMaster_ID, dtInvoiceStart, dtInvoiceEnd, iInvoiceNumber
			FROM InvoiceMaster with (NOLOCK)
			WHERE cSolomonKey ='#Tenant.cSolomonKey#'
			AND bMoveOutInvoice IS NOT NULL AND bFinalized IS NULL AND dtRowDeleted IS NULL
			AND dtRowStart = (Select max(dtRowStart) from InvoiceMaster  with (NOLOCK) WHERE cSolomonKey = '#Tenant.cSolomonKey#')
		</CFQUERY>

		<CFSCRIPT>
			iInvoiceMaster_ID = NewMasterID.iInvoiceMaster_ID;
			iInvoiceNumber = NewMasterID.iInvoiceNumber;			
			dtInvoiceStart = NewMasterID.dtInvoiceStart;
		</CFSCRIPT>
	<CFELSE>
		<CFSCRIPT>
			iInvoiceMaster_ID = InvoiceCheck.iInvoiceMaster_ID;
			iInvoiceNumber = InvoiceCheck.iInvoiceNumber;			
			dtInvoiceStart = InvoiceCheck.dtInvoiceStart;
		</CFSCRIPT>		
	</CFIF>
<cfoutput>House: #SESSION.qSelectedHouse.iHouse_id#   dtChargeThrough:: #dtChargeThrough# 
MIP :: #MoveInPeriod#  --  MOP :: #MoveOutPeriod# :: #day(dtChargethrough)#  - #Day(tenant.dtmovein)#<br /></cfoutput>
<CFSCRIPT>
	NumberOfDays = Day(dtChargeThrough);
	NumberOfDaysCare = Day(dtChargeThrough);
	if (Tenant.iResidencyType_ID EQ 2) 
			
		{ If  (MoveInPeriod  eq  MoveOutPeriod) 
			{ProrateDaysInMonth = DaysInMonth(dtChargeThrough);
				/*Prorate = Day(dtChargethrough) - Day(tenant.dtmovein) + 1;*/
				Prorate = thesedaysinmonth - Day(tenant.dtmovein) + 1;
				ProrateFactor  = Prorate/ProrateDaysInMonth;
				ProrateFactorSet = 'A';}
			else if (MoveInPeriod  lt  MoveOutPeriod)
				{ProrateDaysInMonth = DaysInMonth(dtChargeThrough);
				Prorate = Day(dtChargethrough);
				ProrateFactor  = 1;
				ProrateFactorSet = 'B';} /*Prorate/ProrateDaysInMonth;}*/
 		}
	else 
		{ ProrateDaysInMonth = 30;  
		ProrateFactor = 1;
		ProrateFactorSet = 'C';}
	//Set number of days(days to prorate) equal to the date of the charge through date

	//If the Charge Day is over 30 OR the ChargeThrough date is last day of february Over30Days to 1 (bit = true)
	//no longer have 30 day policy ----- form.ChargeDay GTE 30 OR 
	if ((dtChargeThrough NEQ "" AND Month(dtChargeThrough) EQ 2 
	AND form.ChargeDay EQ DaysInMonth(dtChargeThrough)) ){
		Prorate = 'No'; Over30days = 1;
		//If this is a medicaid use actual days in this month (Medicaid State Policies)
		if (Tenant.iResidencyType_ID NEQ 2) { DaysToCharge = 30; } else { DaysToCharge=NumberOfDays; }
	}
	else {
		Prorate = 'Yes'; Over30days = 0;
		/*	If the tenant is not being charged full month.
			1)	and they are moveing out the the same month and year that they moved in
				set the prorated days (daystocharge) = difference between the charge through 
				date and the move in date
			2)	otherwise just use the value in the number of days variable (Day of charge through date)
		*/
		if (NumberOfDays eq DaysInMonth(dtChargeThrough) ) { DaysToCharge = 0; /*Do not charge since we already charged last month */ }
		else if ((Month(Tenant.dtRentEffective) EQ Month(Variables.dtChargeThrough)) 
		AND (Year(Tenant.dtRentEffective) EQ Year(dtChargeThrough)) ) {
			DaysToCharge = (Variables.dtChargeThrough - Tenant.dtRentEffective) +1; }		
		else { DaysToCharge = NumberOfDays; }
		if (NumberOfDaysCare eq DaysInMonth(dtChargeThrough) ) { DaysToCharge = 0; /*Do not charge since we already charged last month */ }
		else if ((Month(Tenant.dtMoveIn) EQ Month(Variables.dtChargeThrough)) 
		AND (Year(Tenant.dtMoveIn) EQ Year(dtChargeThrough)) ) {
			DaysToChargeCare = (Variables.dtChargeThrough - Tenant.dtMoveIn) +1; }		
		else { DaysToChargeCare = NumberOfDaysCare; }		
	}
</CFSCRIPT>

<CFSET TIPSMonth = SESSION.TIPSMonth>
<CFSET MonthDiff = DateDiff("m",TipsMonth,dtChargeMonthCompareDate)>

<!--- If the month difference is negative (ie. we are crediting back) then set a variable that states were are crediting back --->
<cfoutput> MonthDiff #MonthDiff#</cfoutput>
<CFIF MonthDiff LTE 0> 
	<CFSET TransType= 'Credit'>
	<CFIF MonthDiff EQ 0 AND Tenant.iResidencyType_ID NEQ 3> 
		<CFSET MonthList = DateFormat(dtChargeThrough,"yyyymm")>
	<CFELSE>
		<CFSET MonthList = ''>
	</CFIF>
<CFELSE>
	<CFSET TransType='Charge'>
	<CFSET MonthList = ''>
</CFIF>
<cfquery name="qryLastOpenInvoice"  DATASOURCE = "#APPLICATION.datasource#">
select top 1 inv.iInvoiceDetail_ID,
	inv.iInvoiceMaster_ID,
	inv.iTenant_ID,
	inv.iChargeType_ID,
	inv.cAppliesToAcctPeriod,
	inv.bIsRentAdj,
	inv.dtTransaction,
	inv.iQuantity,
	inv.cDescription,
	inv.mAmount,
    im.bMoveIninvoice 
from invoicedetail inv with (NOLOCK)
join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
where <!---bFinalized = 1 and --->
im.dtrowdeleted is null 
	and inv.dtrowdeleted is null 
	and im.csolomonkey = '#Tenant.cSolomonKey#'
	and ichargetype_id in (8,31,1661,1682,1748)<!---Mamta added--->
order by inv.cappliestoacctperiod desc
</cfquery>
<!--<cfdump var="#qryLastOpenInvoice#"> <cfoutput>#qryLastOpenInvoice.bMoveIninvoice# </cfoutput>--->
<!--- if chargetype is 1749 or 1750 calculate the rate as they are monthly and based on daily charge--->
<cfquery name="qryInvoicecare"  DATASOURCE = "#APPLICATION.datasource#">
select inv.iInvoiceDetail_ID,
	inv.iChargeType_ID,
	inv.cAppliesToAcctPeriod,
	inv.bIsRentAdj,
	inv.dtTransaction,
	inv.iQuantity,
	inv.cDescription,
	inv.mAmount 
from invoicedetail inv with (NOLOCK)
join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
where bmoveininvoice = 1 and im.dtrowdeleted is null 
	and inv.dtrowdeleted is null 
	and im.csolomonkey = '#Tenant.cSolomonKey#'
	and ichargetype_id in (1750)
	and inv.cAppliesToAcctPeriod= #MoveInPeriod#
order by inv.cappliestoacctperiod desc
</cfquery>
<!---<cfdump var="#qryInvoicecare#">--->
<cfquery name="qryInvoiceRB"  DATASOURCE = "#APPLICATION.datasource#">
select inv.iInvoiceDetail_ID,
	inv.iChargeType_ID,
	inv.cAppliesToAcctPeriod,
	inv.bIsRentAdj,
	inv.dtTransaction,
	inv.iQuantity,
	inv.cDescription,
	inv.mAmount 
from invoicedetail inv with (NOLOCK)
join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
where bmoveininvoice = 1 and im.dtrowdeleted is null 
	and inv.dtrowdeleted is null 
	and im.csolomonkey = '#Tenant.cSolomonKey#'
	and ichargetype_id in (1749)
	and inv.cAppliesToAcctPeriod= #MoveInPeriod#
order by inv.cappliestoacctperiod desc
</cfquery>


<cfif qryInvoiceRB.recordcount GT 0 and qryInvoicecare.recordcount gt 0 >
<cfset proratedstateRB= #qryInvoiceRB.mAmount#/(#DaysInMonth(Tenant.dtrenteffective)#-#day(Tenant.dtrenteffective)#+1)>
<cfset proratedstatecare=#qryInvoicecare.mAmount#/(#DaysInMonth(Tenant.dtrenteffective)#-#day(Tenant.dtrenteffective)#+1)>
<cfoutput> proratedstateRB#proratedstateRB#, proratedstatecare#proratedstatecare#</cfoutput>
</cfif>
<!---Mamta end--->
<cfif 	qryLastOpenInvoice.recordcount gt 0>
	<cfset lastinvoiceperiod = qryLastOpenInvoice.cappliestoacctperiod>
</cfif>

<CFIF Tenant.iResidencyType_ID EQ 3> 
	<!--- Retrieve the Respite Daily Rate (THERE ARE NO MONTHY RATES FOR RESPITE - Corporate Rule) --->
	<CFQUERY NAME="qRespiteRate" DATASOURCE="#APPLICATION.datasource#">
		SELECT	mAmount
		FROM Charges C with (NOLOCK)
		JOIN ChargeType CT with (NOLOCK)  ON C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL
		and (C.iOccupancyPosition = #Occupancy# OR C.iOccupancyPosition IS NULL)
		WHERE C.dtRowDeleted IS NULL AND C.iResidencyType_ID = 3 AND C.iHouse_ID = #Tenant.iHouse_ID#
	</CFQUERY>	
</CFIF>

<cfif Tenant.iResidencyType_ID neq 3> 
	<!--- If the transaction is a credit set the variable "factor" to -1 such that we reverse the transaction --->
	<CFSWITCH EXPRESSION="#TransType#">
		<CFCASE VALUE='Credit'> <CFSET Factor = -1> </CFCASE>
		<CFCASE VALUE='Charge'> <CFSET Factor = 1> </CFCASE>
	</CFSWITCH>

	<!--- Create list of months that will be needed --->
	<CFSET nMonth = CreateODBCDateTime(TIPSMonth)>
	<CFLOOP INDEX="I" FROM=1 To="#Abs(MonthDiff)#">
		<CFSET nMonth = DateAdd("m",Factor,nMonth)>
		<CFSET nMonthPeriod = DateFormat(nMonth,"yyyymm")>
		
		<CFIF MonthList NEQ ""> 
		
			<CFSET MonthList = MonthList & ',' & nMonthPeriod>
		<CFELSE>
			<CFSET MonthList = nMonthPeriod>
		</CFIF>
	</CFLOOP>

	<!--- ==============================================================================
	Retrieve ChargeType where GL account if for current period rent
	=============================================================================== --->
		<cfoutput> I #I# MonthDiff #MonthDiff#</cfoutput>
		<CFQUERY NAME="GetGlAccount" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iChargeType_ID, cDescription
		FROM ChargeType with (NOLOCK)
		WHERE dtRowDeleted IS NULL
		<!---AND	bIsRent IS NOT NULL--->
		<CFIF I lte '200401' OR Variables.MonthDiff GTE 0>	
		     <CFIF Tenant.iResidencyType_ID EQ 1 and Tenant.iProductline_ID eq 1 and Tenant.cbillingtype eq 'M'>
		       AND cGLAccount = 3010 and bisdaily is null and bisprepay is null and bSLevelType_ID is null and ichargetype_ID=1682
			<CFELSEIF Tenant.iResidencyType_ID EQ 1 and Tenant.iProductline_ID eq 1>  
				AND cGLAccount = 3010 and bisdaily is not null and bisprepay is not null and bSLevelType_ID is null
			<CFELSEIF Tenant.iResidencyType_ID EQ 2 and Tenant.iProductline_ID eq 1> 
				AND cGLAccount in ('3011','3012','3091','3092') and bismedicaid is not null 
			<CFELSEIF Tenant.iProductline_ID eq 2> 
			    AND iChargeType_ID=1748
			</CFIF>
		<CFELSE>
		    <CFIF Tenant.iResidencyType_ID EQ 1 and Tenant.iProductline_ID eq 1 and Tenant.cbillingtype eq 'M'>
		       AND cGLAccount = 3010 and bisdaily is null and bisprepay is null and bSLevelType_ID is null and ichargetype_ID=1682
			<CFELSEIF Tenant.iResidencyType_ID EQ 1 and Tenant.iProductline_ID eq 1> 
				AND cGLAccount = 3020 and bIsRentAdjustment is not null
			<CFELSEIF Tenant.iResidencyType_ID EQ 2 and Tenant.iProductline_ID eq 1> 
				AND cGLAccount = 3021 and bIsRentAdjustment is not null and bismedicaid is not null
			<CFELSEIF Tenant.iProductline_ID eq 2> 
			    AND iChargeType_ID=1748
			</CFIF>
		</CFIF>
		Order by ichargetype_id
	</CFQUERY>
	
<!--- I <== --->
	<CFSET LoopNumber = 1>
	<CFLOOP INDEX="I" LIST="#MonthList#" DELIMITERS=",">
	<cfoutput>LOOP <== #I#</cfoutput> 
		<!--- Find if there are is any rent history for this tenant in the interested period
		USING TOP 1 IN QUERY SINCE WE ARE ONLY INTERESTED IN THE CORRECT GLACCOUNT --->
		<cfif Tenant.iResidencyType_ID is 2> <!--- IS Medicaid --->
		<CFQUERY NAME="qGetHistoricalRent" DATASOURCE="#APPLICATION.datasource#">
			SELECT	count(INV.iInvoiceDetail_ID) as reccount
				,case WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 31 THEN (<cfif #qryHouseMedicaid.mMedicaidBSF# NEQ ''>#qryHouseMedicaid.mMedicaidBSF#<cfelse> 0 </cfif>)
					WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 1661 THEN (<cfif #tenant.mMedicaidCopay# NEQ ''>#tenant.mMedicaidCopay#<cfelse> 0 </cfif>)
					else (round(SUM(iQuantity * mAmount),2)) end as ChargedRentRate
					,INV.cDescription
					,INV.cAppliesToAcctPeriod
					,case WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 31 
						THEN round(<cfif #qryHouseMedicaid.mMedicaidBSF# neq ''>#qryHouseMedicaid.mMedicaidBSF#<cfelse> 0 </cfif>/#DaysInMonth(dtChargeThrough)#,2)
					WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 1661 
						THEN round(<cfif #tenant.mMedicaidCopay# neq ''>#tenant.mMedicaidCopay#<cfelse>0</cfif>/#DaysInMonth(dtChargeThrough)#,2)
					<!---mamta addede this--->	
					<cfif isdefined("proratedstateRB")>
					WHEN CT.cGLAccount = 3091 and ct.ichargetype_id = 1749
						THEN round(#proratedstateRB#,2)	
					</cfif>	
					<cfif isdefined("proratedstatecare")>
					WHEN CT.cGLAccount = 3092 and ct.ichargetype_id = 1750
						THEN round(#proratedstatecare#,2)
					</cfif>						
					WHEN (CT.bIsDaily IS NOT NULL) 
						THEN (INV.mAmount)
					ELSE round(SUM(iQuantity * mAmount),2)/
						<CFIF Tenant.iResidencyType_ID EQ 2 AND IsDefined("dtChargeThrough")>#DaysInMonth(dtChargeThrough)#<CFELSE>30</CFIF>
					END  as ProratedRent
					,IM.bMoveInInvoice, IM.bMoveOutInvoice
					,CT.bIsRent, CT.bIsMedicaid
					,CT.bIsDiscount, CT.bIsRentAdjustment
					,<CFIF Variables.MonthDiff GT 0>
						CT.iChargeType_ID
					<CFELSE>
						<CFIF SESSION.AcctStamp GTE '2004-01-01'>  
								CASE 
								WHEN CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL THEN CT.iChargeType_ID
								WHEN CT.cGLAccount = 3014 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3020 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3015 THEN (SELECT top 1 iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3021 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3016 THEN (SELECT iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3022 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3010 THEN (SELECT iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3020 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3011 THEN (SELECT top 1 iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3021
																 AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																 AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3012 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3022 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3017 THEN (SELECT iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3027 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								ELSE CT.iChargeType_ID
								END as iChargeType_ID
							<CFELSE>
								CASE 
								WHEN CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL THEN CT.iChargeType_ID
								WHEN CT.cGLAccount = 3010 THEN (SELECT iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3014 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3011 THEN (SELECT top 1 iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3015 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3012 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3016 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3017 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3014 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								ELSE CT.iChargeType_ID
								END as iChargeType_ID
							</CFIF>
						</CFIF>
						, CT.iChargetype_id as original
			FROM	InvoiceDetail INV with (NOLOCK)
			JOIN	InvoiceMaster IM with (NOLOCK) on IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID 
			and IM.dtRowDeleted IS NULL AND IM.iInvoiceMaster_ID <> #iInvoiceMaster_ID#
			JOIN	ChargeType CT with (NOLOCK) on CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
			and INV.dtRowDeleted IS NULL and INV.iTenant_ID = #form.iTenant_ID#
			and (CT.bIsRent IS NOT NULL OR INV.iRowStartUser_ID = 0)
			and INV.cAppliesToAcctPeriod = #I#
			and INV.iInvoiceMaster_ID <> #Variables.iInvoiceMaster_ID#
			and INV.mAmount <> 0 and CT.bIsDeposit IS NULL and CT.cGLAccount <> 2210
			and im.bMoveOutInvoice is Null
			<!--- <cfif dtCareDate gt dtChargeThrough>
			 and INV.iChargeType_ID not in (1740, 1741,69,91) 
			 <cfelse> --->
			 and INV.iChargeType_ID not in (1740, 1741,69) <!---Mamta removed 8--->
			<!---  </cfif> --->
			GROUP BY INV.cDescription, INV.cAppliesToAcctPeriod
			, IM.bMoveinInvoice, IM.bMoveOutInvoice
			, INV.mAmount
			, CT.bIsDaily
			, CT.bIsRent
			, CT.bIsMedicaid
			, CT.iChargeType_ID
			, CT.cGLAccount
			, CT.bIsDiscount
			, CT.bIsRentAdjustment
			ORDER BY INV.cAppliesToAcctPeriod
		</CFQUERY>
		<cfelse> IS NOT Medicaid mamta added  proratedamountformonthlyBSF for monthly BSF<cfoutput>Variables.MonthDiff  #Variables.MonthDiff#</cfoutput>
		<cfoutput>DaysInMonth(dtChargeThrough)#DaysInMonth(dtChargeThrough)#qrylastopeninvoice.mamount#qrylastopeninvoice.mamount#</cfoutput>
		<cfif #qrylastopeninvoice.recordcount# GTE 1> 
		<cfset proratedamountformonthlyBSF= Round((#qrylastopeninvoice.mamount#/#DaysInMonth(dtChargeThrough)#)*100)/100>
		<cfoutput>proratedamountformonthlyBSF #proratedamountformonthlyBSF#</cfoutput>
		</cfif>
		<CFQUERY NAME="qGetHistoricalRent" DATASOURCE="#APPLICATION.datasource#">
			SELECT	count(INV.iInvoiceDetail_ID) as reccount
				, (round(SUM(iQuantity * mAmount),2))   as ChargedRentRate
					,INV.cDescription
					,INV.cAppliesToAcctPeriod
<!--- 					, round(SUM(iQuantity * mAmount),2)/30 as ProratedRent //---><!---Mamta- proratedrent for 1682 is being calcukated for a month, 
                           need to calculate from the days charged- (amount/numberofdaysin month from movein)*30 --->
					,round(CASE WHEN (CT.bIsDaily IS NOT NULL) THEN (INV.mAmount)
					                <cfif isdefined('proratedamountformonthlyBSF') and #Trim(proratedamountformonthlyBSF)# NEQ  '' >  
					             WHEN (CT.ichargetype_ID in (1682,1748))THEN 
					                 #proratedamountformonthlyBSF#
					                </cfif>
					         ELSE round(SUM(iQuantity * mAmount),2)/<CFIF Tenant.iResidencyType_ID EQ 2
					  AND IsDefined("dtChargeThrough")>#DaysInMonth(dtChargeThrough)#<CFELSE>30</CFIF> 
					END,2)
					as ProratedRent
					,IM.bMoveInInvoice, IM.bMoveOutInvoice
					,CT.bIsRent, CT.bIsMedicaid
					,CT.bIsDiscount, CT.bIsRentAdjustment
					,<CFIF Variables.MonthDiff GT 0>
						CT.iChargeType_ID
					<CFELSE>
						<CFIF SESSION.AcctStamp GTE '2004-01-01'>  
								CASE 
								WHEN CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL THEN CT.iChargeType_ID
								WHEN CT.cGLAccount = 3014 THEN (SELECT iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3020 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3015 THEN (SELECT top 1 iChargeType_ID FROM ChargeType  with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3021 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3016 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3022 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3010  and CT.ichargetype_ID <> 1748 and CT.ichargetype_ID <> 1682
								                                THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3020 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3011 THEN (SELECT top 1 iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3021
																 AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																 AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3012 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3022 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3017 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3027 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								ELSE CT.iChargeType_ID
								END as iChargeType_ID
							<CFELSE>
								CASE 
								WHEN CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL THEN CT.iChargeType_ID
								WHEN CT.cGLAccount = 3010 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3014 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3011 THEN (SELECT top 1 iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3015 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3012 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3016 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3017 THEN (SELECT iChargeType_ID FROM ChargeType with (NOLOCK)
																WHERE dtrowdeleted is null and cGLAccount = 3014 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								ELSE CT.iChargeType_ID
								END as iChargeType_ID
							</CFIF>
						</CFIF>
						, CT.iChargetype_id as original
			FROM	InvoiceDetail INV with (NOLOCK)
			JOIN	InvoiceMaster IM  with (NOLOCK) on IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID 
			and IM.dtRowDeleted IS NULL AND IM.iInvoiceMaster_ID <> #iInvoiceMaster_ID#
			JOIN	ChargeType CT with (NOLOCK)  on CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
			and INV.dtRowDeleted IS NULL and INV.iTenant_ID = #form.iTenant_ID#
			and (CT.bIsRent IS NOT NULL OR INV.iRowStartUser_ID = 0)
			and INV.cAppliesToAcctPeriod = #I#
			and INV.iInvoiceMaster_ID <> #Variables.iInvoiceMaster_ID#
			and INV.mAmount <> 0 and CT.bIsDeposit IS NULL and CT.cGLAccount <> 2210
			and im.bMoveOutInvoice is Null
			<!--- <cfif dtCareDate gt dtChargeThrough>
			 and INV.iChargeType_ID not in (1740, 1741,69,91) 
			 <cfelse> --->
			 and INV.iChargeType_ID not in (1740, 1741,69,8) 
			<!---  </cfif> --->
			GROUP BY INV.cDescription, INV.cAppliesToAcctPeriod
			, IM.bMoveinInvoice, IM.bMoveOutInvoice
			, INV.mAmount
			, CT.bIsDaily
			, CT.bIsRent
			, CT.bIsMedicaid
			, CT.iChargeType_ID
			, CT.cGLAccount
			, CT.bIsDiscount
			, CT.bIsRentAdjustment
			ORDER BY INV.cAppliesToAcctPeriod
		</CFQUERY>		
		</cfif>
<cfoutput>  <br />qGetHistoricalRent ==>
		  if there is rent hi story use this information  </cfoutput>	
		<CFIF qGetHistoricalRent.RecordCount GT 0> 
			<CFSET ActualPeriod = ValueList(qGetHistoricalRent.cAppliesToAcctPeriod)>
			<CFSET ActualRent = ValueList(qGetHistoricalRent.ChargedRentRate)>
			<CFSET ActualDescription = ValueList(qGetHistoricalRent.cDescription)>
			<CFSET ActualChargeType = ValueList(qGetHistoricalRent.iChargeType_ID)>
            <!---Mamta set the month and year charges applies to--->
			<cfset chargeyear= left(#qGetHistoricalRent.cAppliesToAcctPeriod#,4)>
			<cfset chargemonth= right(#qGetHistoricalRent.cAppliesToAcctPeriod#,2)>	
			<cfset chargeDate= #chargeyear#&'-'&#chargemonth#&'-01'>
			<!---<cfoutput> Mamta#chargeyear# #chargemonth# #chargeDate#</cfoutput>	--->				
			<!--- If the history is a move in invoice (ie. move in and move out in same month)
			set the prorate as the daily rent amount from the previous page --->
			<CFIF qGetHistoricalRent.bMoveInInvoice GT 0> 
				<CFSET CalcProrate = form.DailyRent> 
			<CFELSE>
				<CFSET CalcProrate = qGetHistoricalRent.ProratedRent><!--- N2 <== --->
			</CFIF>
			
			<!---If the tenant is respite set the prorate to the respite daily rate --->
			<CFIF Tenant.iResidencyType_ID EQ 3>  
				<CFSET CalcProrate = qRespiteRate.mAmount>
			</CFIF>
	
		<CFELSEIF Tenant.iResidencyType_ID NEQ 2>
			<!---if there is no history and this tenant is not mediciaduse the current standard rent --->
			<CFSET CurrentRentRate = form.StandardRent>
			<CFSET ActualRent = CurrentRentRate>
			<CFSET ActualChargeType = GetGLAccount.iChargeType_ID>
			
			<CFIF Tenant.iResidencyType_ID EQ 3> 
				<!--- If this tenant is respite and there is not history also use the respite daily rate --->
				<CFSET CalcProrate = qRespiteRate.mAmount>
			<CFELSE>
				<!--- if this tenant is private pay use the cacluated prorate rent --->
				<CFSET CalcProrate = form.DailyRent>
			</CFIF>
		<CFELSE>
			<!--- If the tenant has no rent history and it is NOT a respite tenant
			(most likely a medicaid)
			Use the standard rent and set the actual rent to 0 --->
			<CFSET CurrentRentRate = form.Standardrent>
			<CFSET CalcProrate = form.DailyRent>
			<CFSET ActualRent = 0.00>		
			<CFSET ActualChargeType = GetGLAccount.iChargeType_ID>
		</CFIF>


<cfoutput><br>ProrateFactor:: #ProrateFactor# ::: ProrateFactorSet :: #ProrateFactorSet#<br></cfoutput>
	<!--- If this tenant is neither mediciad nor respite. And is private and there is no history of rent
	** CREDIT BACK THE FULL MONTH OF RENT ** --->
		<CFIF Tenant.iResidencyType_ID NEQ 3 
			OR (Tenant.iResidencyType_ID EQ 2 AND qGetHistoricalRent.RecordCount GT 0)
			OR (Tenant.iResidencyType_ID EQ 1 AND qGetHistoricalRent.RecordCount GT 0)>	 
			
			<CFIF (RIGHT(I,2) NEQ DateFormat(dtChargeThrough,"mm") OR Over30days EQ 0)
			 AND qGetHistoricalRent.recordcount NEQ 0>  

				<!--- 	Record Full Month Rent Charges/Credits--->
				<CFSET COUNT = 1>
				<CFLOOP INDEX="ActualRentIndex" LIST="#ActualRent#" DELIMITERS=",">
					<CFSET Number = #ListFind(ActualRent, ActualRentIndex)#>
					<cfif (I NEQ DateFormat(dtChargeThrough,"yyyymm") OR (NumberOfDays neq DaysInMonth(dtChargeThrough)
					 AND I EQ DateFormat(dtChargeThrough,"yyyymm") ) )
					and GetToken(ActualChargeType, Number, ",") is not ""> 
						<cfif qGetHistoricalRent.ichargetype_id is 69><!--- S1<== #qGetHistoricalRent.ichargetype_id# --->
						<cfelse>
					<!---   <cfoutput>AA==>#GetToken(ActualChargeType, count, ",")#</cfoutput>  <br /> --->
 						<cfoutput>==>thisperiod: #I# :: lastInvPeriod: #lastinvoiceperiod# ::
						MoveOutPeriod: #moveoutperiod# :: ProrateFactor: #ProrateFactor# ::
						CreditBack #GetToken(ActualChargeType, count, ",")# ActualRentIndex#ActualRentIndex#<br />
							<br />
						</cfoutput>
						
						<CFQUERY NAME="CreditBack" DATASOURCE="#APPLICATION.datasource#" result="CreditBack">
						INSERT INTO InvoiceDetail
							(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, 
								bIsRentAdj, dtTransaction, iQuantity, cDescription, mAmount, cComments, 
								dtAcctStamp, iRowStartUser_ID, dtRowStart,iDaysBilled
							)VALUES(
								#Variables.iInvoiceMaster_ID#
								, #form.iTenant_ID#,
								<CFSET Number = ListFind(ActualRent, ActualRentIndex)>
								#GetToken(ActualChargeType, count, ",")#,
								'#I#'
								,1
								,GetDate()
								,1, 
								<CFIF Variables.MonthDiff LTE 0>  
			LEFT('CR:#LEFT(ListGetAt(ActualDescription,Count),15)#... #LEFT(Tenant.cFirstName,1)#.#Tenant.cLastName# #LEFT(I,4)##RIGHT(I,2)#',50),
								<CFELSE> 
									'Rent for #MonthAsString(RIGHT(I,2))# #LEFT(I,4)#',
								</CFIF>					
								<CFSET FinalAmount = Factor * ActualRentIndex>
								<cfif #GetToken(ActualChargeType, count, ",")# is 52> 
									<cfif (I eq lastinvoiceperiod) >
										<cfif (lastinvoiceperiod gt moveoutperiod)>
											<cfset #FinalAmount#   = #FinalAmount#>
										<cfelse>
								 			<cfset #FinalAmount#   = #FinalAmount#  * #ProrateFactor#>
										</cfif>
									<cfelse>
								 		<cfset #FinalAmount#   = #FinalAmount#  * #ProrateFactor#>
									</cfif>										
								 	#FinalAmount#
								 <cfelse>
								 	#FinalAmount#
								 </cfif>
								,  Null 
								, '#SESSION.AcctStamp#'
								,0
								,GetDate() 
							    ,#Daysinmonth(chargeDate)# )
						</CFQUERY>
						
					
 <!---  --->	
 <cfoutput>FinalAmount: #FinalAmount#</cfoutput>
<!--- <cfoutput> 							<br />	#Variables.iInvoiceMaster_ID#
							<br />	#form.iTenant_ID#,
							<br />		<CFSET Number = ListFind(ActualRent, ActualRentIndex)>
							<br />		#GetToken(ActualChargeType, count, ",")#,
							<br />		'#I#'
							<br />		,1
							<br />		,GetDate()
							<br />		,1, 
							<br />		<CFIF Variables.MonthDiff LTE 0>  
			LEFT('CR:#LEFT(ListGetAt(ActualDescription,Count),15)#... #LEFT(Tenant.cFirstName,1)#.#Tenant.cLastName# #LEFT(I,4)##RIGHT(I,2)#',50),
								<CFELSE> 
									'Rent for #MonthAsString(RIGHT(I,2))# #LEFT(I,4)#',
								</CFIF>					
							<br />		<CFSET FinalAmount = Factor * ActualRentIndex>
							<br />		#FinalAmount#,
								 
							<br />		  '#SESSION.AcctStamp#'
							<br />		 0</cfoutput> --->
								  
 <!---  --->	
						<CFQUERY NAME="qValidateCharge" DATASOURCE="#APPLICATION.datasource#">
							SELECT bIsRent, bIsMedicaid
							FROM ChargeType with (NOLOCK) WHERE iChargeType_ID = #GetToken(ActualChargeType, Number, ",")#
						</CFQUERY>
						
						<CFIF (qValidateCharge.bIsRent NEQ "" AND qValidateCharge.bIsMedicaid NEQ "")
						 OR qValidateCharge.bIsRent NEQ ""> 
							<CFSET CalcProrate = ROUND(100 * (ActualRentIndex/ProrateDaysInMonth)) / 100>
						</CFIF>
						</cfif>
						<CFSET COUNT = COUNT + 1>
					</cfif>
				</CFLOOP>		
			</CFIF>
		</CFIF>
				<cfif qGetHistoricalRent.iChargeType_ID is 44>
				  testing condition mamta
				</cfif>
	<!---IF the tenant is not medicaid OR is not a respite moving in/out in same month
	OR the tenant is medicaid with NO Rent History THEN charge prorated rent as necessary
	(determined by prorate bit)---> <cfoutput> Prorate #Prorate# </cfoutput>
		<CFIF Prorate EQ 'Yes' AND (I EQ DateFormat(ChargeMonthCompareDate,"yyyymm"))> 
		
			<CFIF qGetHistoricalRent.RecordCount EQ 0>
			<cfoutput> A:: #prorate#, #I#, #ChargeMonthCompareDate# :: #ListGetAt(CalcProrate, 1, ",")# & ',' & #form.DailyCare#<br /></cfoutput>
				<CFSET CalcProrateList = ListGetAt(CalcProrate, 1, ",") & ',' & form.DailyCare>
				<CFSET CalcProrateDesc = GetGlAccount.cDescription & ',' & 'Daily Care'>
				<CFSET CalcProrateChargetype = GetGlAccount.iChargetype_id >
				<CFSET CalcProrateOriginalChargetype = GetGlAccount.iChargetype_id >
			<CFELSE><br /> B::qGetHistoricalRent.RecordCount gt 0<br />
 				<CFQUERY NAME='qList' DBTYPE='QUERY'> 
					SELECT	ProratedRent ,cDescription, iChargeType_ID, original FROM qGetHistoricalRent WHERE
					bIsRent = 1 or ichargetype_ID in (1749,1750,44)
								<!--- Mshah added this for state medicaid to prorate--->
				</CFQUERY>
			
				<CFSET CalcProrateList = ValueList(qList.ProratedRent)>
				<CFSET CalcProrateDesc = ValueList(qList.cDescription)>
				<CFSET CalcProrateChargetype = ValueList(qList.iChargeType_ID)>
				<CFSET CalcProrateOriginalChargetype = ValueList(qList.original)>
 			</CFIF>
        
			 
			<CFSET COUNT = 1>
			<CFLOOP INDEX="T" LIST="#CalcProrateList#" DELIMITERS=",">
				<!--- Record Prorated Rent ---><cfoutput>T #T# I #I# #DateFormat(dtChargeThrough,"yyyymm") # NumberOfDays #NumberOfDays#</cfoutput><br /> 
				
	<CFIF (I NEQ DateFormat(dtChargeThrough,"yyyymm") 
				OR (NumberOfDays neq DaysInMonth(dtChargeThrough) AND I EQ DateFormat(dtChargeThrough,"yyyymm") ) and qGetHistoricalRent.RecordCount NEQ 0 )>Y
	<!--- <br />
		  <cfoutput>
			  BB #CalcProrateChargetype# ==> <br />#ListGetAt(CalcProrateChargetype,Count,",")# is 1645) 
		  		and (#dtCareDate# gt #dtChargeThrough#)
			</cfoutput>
			<br />	--->
			
		<cfif ((#ListGetAt(CalcProrateChargetype,Count,",")# is 1645) and (dtCareDate gt dtChargeThrough))>
  		<br />	skipping this one	going here  <!---<cfoutput>'this is 2  #T# #CalcProrateChargetype# #dateformat(dtCareDate,"yyyy-mm-dd")#, #dateformat(dtChargeThrough,"yyyy-mm-dd")#', #TRIM(Variables.DaysToCharge)#</cfoutput><br /> --->
		  <cfelse>
			  <cfif ((#ListGetAt(CalcProrateChargetype,Count,",")# is 1645) or  (#ListGetAt(CalcProrateChargetype,Count,",")# is 91))>
			  	<cfset chargedays = DaysToChargeCare>
			  <cfelse>
			  	<cfset chargedays = DaysToCharge>
			  </cfif>
			  	<!---mshah set the quantity and amount for state medicaid proration--->
			  	 <cfif ((#ListGetAt(CalcProrateOriginalChargetype,Count,",")# is 8))>
			  	    <cfset T = T*chargedays>
				  	<cfset chargedays = 1>
				  </cfif>
				 <!---end--->
				
			<cfoutput>testing #chargedays# #T# #CalcProrateOriginalChargetype#</cfoutput><br /> 
 			  <CFQUERY NAME="ProratedRent" DATASOURCE="#APPLICATION.datasource#" result="ProratedRent2">
					INSERT INTO InvoiceDetail 
		 		(	iInvoiceMaster_ID
				, iTenant_ID
				, iChargeType_ID
				, cAppliesToAcctPeriod
				, bIsRentAdj
				, dtTransaction
				,iQuantity
				, cDescription
				, mAmount
				, cComments
				, dtAcctStamp
				, iRowStartUser_ID
				,  dtRowStart
				,iDaysBilled				
					)VALUES(
						#Variables.iInvoiceMaster_ID#, 
						#form.iTenant_ID#,
						<CFIF listlen(CalcProrateChargetype) GT 1>  
							#ListGetAt(CalcProrateChargetype,Count,",")#, 
						<CFELSE> 
							#CalcProrateChargetype#, 
						</CFIF>
						'#DateFormat(dtChargeThrough,"yyyymm")#',
						1, 
						#CreateODBCDateTime(TimeStamp)#,
					    <cfif ListFindNoCase("1748,1682",ListGetAt(CalcProrateOriginalChargeType,Count,",")) GT 0> 1 <cfelse> #TRIM(Variables.chargedays)# </cfif>,  
						'#TRIM(ListGetAt(CalcProrateDesc,Count,","))# <CFIF (LEFT(MonthAsString(Month(dtChargeThrough)),3) NEQ RIGHT(ListGetAt(CalcProrateDesc,Count,","),3)) AND len(TRIM(ListGetAt(CalcProrateDesc,Count,","))) lt 43> for #LEFT(MonthAsString(Month(dtChargeThrough)),3)#</CFIF>',
						 <cfif ListFindNoCase("1748,1682",ListGetAt(CalcProrateOriginalChargeType,Count,",")) GT 0> #T*TRIM(Variables.chargedays)# <cfelse> #T# </cfif>,
						 null ,
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						0,
						#CreateODBCDateTime(TimeStamp)#, 
					    #TRIM(Variables.chargedays)#) 
				  </CFQUERY>  
				  
<!--- 				  <cfoutput>'this is 2  #T# #CalcProrateChargetype# #dateformat(dtCareDate,"yyyy-mm-dd")#, #dateformat(dtChargeThrough,"yyyy-mm-dd")#'</cfoutput> --->
				  </cfif>
				</CFIF>

				<CFSET COUNT = COUNT + 1>
			</CFLOOP>	
		</CFIF>

		<CFSET LoopNumber = LoopNumber +1>
	</CFLOOP>
</cfif>

<CFSET PHONENUMBER1 = TRIM(form.AREACODE1) & TRIM(form.PREFIX1) & TRIM(form.NUMBER1)>
<CFSET PHONENUMBER2 = TRIM(form.AREACODE2) & TRIM(form.PREFIX2) & TRIM(form.NUMBER2)>

<CFTRANSACTION>

	<CFQUERY NAME = "TenantState" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	TenantState
		SET		<CFIF isdefined("form.reason") and form.reason neq ''> iMoveReasonType_ID=#form.Reason#,
		<CFELSE>  iMoveReasonType_ID=6, 
		</CFIF>
				<cfif isdefined("form.DisplayReason2") and form.DisplayReason2 eq 1>
				iMoveReason2Type_ID=#form.Reason2#,
				<cfelse>
				iMoveReason2Type_ID=null,
				</cfif>
				<cfif isdefined("form.slctTenantMOLocation") and form.slctTenantMOLocation neq ''>
					iTenantMOLocation_ID=#form.slctTenantMOLocation#,
				<cfelse>
					iTenantMOLocation_ID=null,
				</cfif>
				dtChargeThrough = <CFIF Variables.dtChargeThrough NEQ ""> #dtChargeThrough#, </CFIF>
				dtNoticeDate = <CFIF Variables.dtNotice NEQ ""> #dtNotice#, </CFIF>
				dtMoveOut = <CFIF Variables.dtMoveOut NEQ ""> #dtMoveOut#, </CFIF>
				dtAcctStamp = '#SESSION.AcctStamp#'
				<CFIF Tenant.iTenantStateCode_ID LT 3>				
					,iTenantStateCode_ID = 2
				</CFIF>		
		WHERE dtrowdeleted is null and iTenant_ID = #form.iTenant_ID#
	</CFQUERY>

	<!--- 	Insert a record into the invoice detail for the damages. --->
	<CFIF IsDefined("form.DamageAmount") AND form.DamageAmount GT 0> 
	<!---   CC 36====>  <br />  --->	
	<CFQUERY NAME = "Damages"	DATASOURCE="#APPLICATION.datasource#">
			INSERT INTO InvoiceDetail
			(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, 
				bIsRentAdj, dtTransaction, iQuantity, cDescription, mAmount, cComments, 
				dtAcctStamp, iRowStartUser_ID, dtRowStart
			)VALUES(
				#iInvoiceMaster_ID#, #form.iTenant_ID#,36,	
				<CFSET AppliesTo = YEAR(Variables.dtChargeThrough) & DateFormat(Variables.dtChargeThrough,"mm")>
				'#APPLIESTO#', NULL, getDate(), 1, 'Damages', #TRIM(form.DamageAmount)#,'#form.DamageComments#',
				#CreateODBCDateTime(SESSION.AcctStamp)#, #SESSION.UserID#, getDate() 
			)
		</CFQUERY> 
	</CFIF>

	<CFIF (isDefined("form.DamageStatus") AND trim(form.DamageStatus) neq '')> 
		<CFQUERY NAME='qInvoiceDamage' DATASOURCE='#APPLICATION.DATASOURCE#'>
			update invoicemaster
			set	iDamageStatus=#trim(form.DamageStatus)#
				,dtrowstart=getdate()
				,irowstartuser_id = #SESSION.USERID#
			where iinvoicemaster_id = #iInvoiceMaster_ID#
		</CFQUERY>
	</CFIF>

	<!--- 	Retrieve the Charge and ChargeType Information dependent upon the type of "Other Charge" Chosen --->
	<CFSCRIPT>
		if (IsDefined("form.OtheriCharge_ID") AND form.OtheriCharge_ID NEQ "") 
			{ chargeid= form.OtheriCharge_ID; }
		else 
			{ chargeid = 0; }
	</CFSCRIPT>
	
	<CFIF IsDefined("form.OtherAmount") AND form.OtherAmount NEQ 0> 
	<cfoutput>
		<CFQUERY NAME="Charge" DATASOURCE="#APPLICATION.datasource#">
			SELECT C.iChargeType_ID
			FROM Charges C	with (NOLOCK)
			JOIN ChargeType CT with (NOLOCK)  ON C.iChargeType_ID = CT.iChargeType_ID
			WHERE C.iCharge_ID = #chargeid#
		</CFQUERY>
	</cfoutput>	
		<!--- 	Insert a record into the invoice detail for the other charges --->	
		<!--- <cfoutput> DD #Charge.iChargeType_ID# ==>  </cfoutput> <br /> --->
		<CFQUERY NAME = "Other"	DATASOURCE="#APPLICATION.datasource#" result="insertingothercharges">
	INSERT INTO InvoiceDetail
			( iInvoiceMaster_ID	,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,bIsRentAdj ,dtTransaction ,iQuantity
				,cDescription ,mAmount ,cComments ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart,iDaysBilled
			)VALUES(
				#iInvoiceMaster_ID#
				, #form.iTenant_ID#
				<cfif #Charge.iChargeType_ID# eq 69>
				,1741
				<cfelse>
				,#Charge.iChargeType_ID#
				</cfif>
				, <CFIF IsDefined("form.AppliesToMonth") AND IsDefined("form.AppliesToYear")> 
					<CFSET Appliesto = #form.AppliesToYear# & #NumberFormat(form.AppliesToMonth, "09")#>
				<CFELSE>
					<CFSET Appliesto = #YEAR(TIPSMONTH)# & #DateFormat(TIPSMONTH,"mm")#>
				</CFIF>
				'#AppliesTo#'
				, NULL
				, GetDate()
<!---Mshah--->	, <cfif ListFindNoCase("1748,1682",#trim(Charge.iChargeType_ID)#,",")GT 0 > 1 <cfelse> #form.OtheriQuantity# </cfif>
				,'#left(form.OthercDescription,50)#'
<!---Mshah--->	, <cfif ListFindNoCase("1748,1682",#trim(Charge.iChargeType_ID)#,",")GT 0> #Trim(NumberFormat(form.OtherAmount*form.OtheriQuantity,"99999999.99"))# <cfelse> #Trim(NumberFormat(form.OtherAmount,"99999999.99"))# </cfif>
				, <CFIF IsDefined("form.OtherComments") AND form.OtherComments NEQ ""> 
					'#Trim(form.OtherComments)#'
				<CFELSE>
					null
				</CFIF> 
				,#CreateODBCDateTime(SESSION.AcctStamp)#
				,#SESSION.UserID#, GetDate() 
				, #form.OtheriQuantity#
			)
		</CFQUERY> 
	</CFIF>
	
<!--- 	<CFQUERY NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#">  
		SELECT	inv.dtTransaction, ts.mAmtDeferred,  ts.iMonthsDeferred
		from   InvoiceMaster IM  with (NOLOCK)
		join InvoiceDetail inv with (NOLOCK) on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID and inv.dtRowDeleted is null
		and IM.dtRowDeleted is null	and IM.bMoveInInvoice is not null and IM.bMoveOutInvoice is null
		and IM.cSolomonKey = '#tenant.cSolomonKey#'
		JOIN	ChargeType CT with (NOLOCK)	ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
		AND CT.iChargeType_ID  = 1740
		left join recurringcharge rchg with (NOLOCK) on rchg.iRecurringCharge_ID = inv.iRecurringCharge_ID
		LEFT JOIN	Tenant T with (NOLOCK)	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
		join tenantstate ts with (NOLOCK) on t.itenant_ID = ts.itenant_id
		ORDER BY	INV.iTenant_ID DESC, INV.cAppliesToAcctPeriod
	</CFQUERY> --->	
		<cfquery NAME="GetNRF" DATASOURCE="#APPLICATION.datasource#">
 	 		select  sum(IsNUll(inv.mamount,0)) as Accum
			from invoicedetail inv  with (NOLOCK)
			join invoicemaster im with (NOLOCK) on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	im.csolomonkey =  '#tenant.cSolomonKey#'
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null
			and im.bFinalized = 1
		</cfquery>
		<cfquery NAME="GetNRFCount" DATASOURCE="#APPLICATION.datasource#">
		 select count (mamount) as dispnbrpaymentmade
			from invoicedetail inv  with (NOLOCK)
			join invoicemaster im with (NOLOCK)  on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where   inv.dtrowdeleted is null  
			and	im.csolomonkey  =  '#tenant.cSolomonKey#' 
			and inv.ichargetype_id = 1741 
			and im.bMoveOutInvoice is null			
			and im.bFinalized = 1
		</cfquery>
		<cfquery name="qryNRFRecurringChg"  DATASOURCE="#APPLICATION.datasource#">
			SELECT rc.*
			FROM  RecurringCharge  RC with (NOLOCK)
			join  charges  chg with (NOLOCK) on chg.iCharge_ID = rc.iCharge_ID
			where rc.iTenant_ID= #tenant.itenant_id#	
		</cfquery>
		<CFQUERY NAME="qRecordCheck1743" DATASOURCE="#APPLICATION.datasource#">
			SELECT	Count(*) as count1743
			FROM	InvoiceDetail with (NOLOCK)
			WHERE	dtRowDeleted IS NULL AND iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#	
					and ichargetype_id = 1743	
		</CFQUERY>
<!---   	<cfif ((GetNRFCount.dispnbrpaymentmade lt tenant.MONTHSDEFERRED) and (qRecordCheck1743.count1743 is 0))> --->    
	  	<!--- <cfif  GetNRFCount.dispnbrpaymentmade lt tenant.iMonthsDeferred >  ---> 
<!--- 		<cfif Tenant.AdjNRF is "">
			<cfset thisadjnrf = 0>
		<cfelse>
			<cfset thisadjnrf = Tenant.AdjNRF>
		</cfif> --->

<!--- 		<cfif Tenant.mAmtNRFPaid is "">
			<cfset thismAmtNRFPaid = 0>
		<cfelse>
			<cfset thismAmtNRFPaid = Tenant.mAmtNRFPaid>
		</cfif> --->
		
<!--- 		<cfif GetNRF.Accum is "">
			<cfset thisAccum = 0>
		<cfelse>
			<cfset thisAccum= GetNRF.Accum>
		</cfif> --->
		<cfset paymentsleft =  tenant.MONTHSDEFERRED - GetNRFCount.dispnbrpaymentmade>
		 <!--- <cfset paymentrem = tenant.mAmtDeferred - GetNRF.Accum>    --->
		<cfif IsNumeric(tenant.adjnrf) and IsNumeric(tenant.AmtNRFPaid) and IsNumeric(GetNRF.Accum)>
			<cfset paymentrem =  ((tenant.adjnrf - tenant.AmtNRFPaid) - GetNRF.Accum) >		
		<cfelse> 
			<cfset paymentrem = 0>
		</cfif>	
			<!---  <cfoutput> hello - #tenant.adjnrf# / #tenant.AmtNRFPaid# / #GetNRF.Accum# #qRecordCheck1743.count1743# paymentrem #paymentrem# paymentsleft #paymentsleft#</cfoutput> --->
		
		<CFIF IsDefined("form.AppliesToMonth") AND IsDefined("form.AppliesToYear")>
			<CFSET Appliesto = #form.AppliesToYear# & #NumberFormat(form.AppliesToMonth, "09")#>
		<CFELSE>
			<CFSET Appliesto = #YEAR(TIPSMONTH)# & #DateFormat(TIPSMONTH,"mm")#>
		</CFIF>
 		<!--- <cfoutput>EE 1743 #GetNRFCount.dispnbrpaymentmade# lt #tenant.MONTHSDEFERRED#) and (#qRecordCheck1743.count1743# ==> </cfoutput> --->
  <cfif CFRemainingBal gt 0>
	<CFQUERY NAME = "Other"	DATASOURCE="#APPLICATION.datasource#" result="insertingothercharges1">
			INSERT INTO InvoiceDetail
			( iInvoiceMaster_ID	
				,iTenant_ID 
				,iChargeType_ID 
				,cAppliesToAcctPeriod
				,dtTransaction 
				,iQuantity
				,cDescription 
				,mAmount  
				,dtAcctStamp 
				,iRowStartUser_ID 
				,dtRowStart
			)VALUES( 
		 	#iInvoiceMaster_ID#
				, #form.iTenant_ID#
				, 1743
				,'#AppliesTo#'
				, GetDate() 
				,1
				,'Community Fee Unpaid Balance'
				,#Trim(NumberFormat( abs(CFRemainingBal),"99999999.99"))#
				,#CreateODBCDateTime(SESSION.AcctStamp)#
				,#SESSION.UserID#
				, GetDate() 
			)
	 	</CFQUERY> 	  
	</cfif>
 	<!--- Check to see if there are any charges for this MOVE OUT invoice --->
	<CFQUERY NAME="qRecordCheck" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Count(*) as count
		FROM	InvoiceDetail with (NOLOCK)
		WHERE	dtRowDeleted IS NULL AND iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#		
	</CFQUERY>
	
	<!--- If there are no details automatically add a zero charge to the 3011 medicaid co-pay account--->
	<CFIF qRecordCheck.Count EQ 0 OR (qRecordCheck.count EQ 0 AND Over30Days EQ 0)>
		<CFQUERY NAME="qZeroCharge" DATASOURCE="#APPLICATION.datasource#">
			SELECT top 1 * FROM ChargeType with (NOLOCK) WHERE dtRowDeleted IS NULL AND bIsRent IS NOT NULL 
			<CFIF Tenant.iResidencyType_ID EQ 2> AND cGLAccount = 3011 <CFELSE> AND bIsDaily IS not NULL AND cGLAccount = 3010 </CFIF> 
			<CFIF Tenant.iResidencyType_ID EQ 1>AND cDescription not like '%respite%'</CFIF> 
		</CFQUERY>
	
		<!--- 	Insert Zero amount Mediciad Charge--->
<!---  <cfoutput>	FF #qZeroCharge.iChargeType_ID#</cfoutput> =======>   <br /> --->
		<CFQUERY NAME = "ZeroAddition" DATASOURCE = "#APPLICATION.datasource#">
			INSERT INTO InvoiceDetail
			(	iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, 
				iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart
			)VALUES(
				#Variables.iInvoiceMaster_ID#,
				#Tenant.iTenant_ID#,
				#qZeroCharge.iChargeType_ID#,
				<CFIF Tenant.dtMoveOut NEQ "">'#DateFormat(Tenant.dtMoveOut,"yyyymm")#'
				<CFELSE>#DateFormat(SESSION.TIPSMonth,"yyyymm")#</CFIF>,
				NULL,GETDATE(),1,
				'#qZeroCharge.cDescription#',
				0.00,   NULL  ,
				#CreateODBCDateTime(SESSION.AcctStamp)#,
				0,GETDATE()
			)
		</CFQUERY> 
	</CFIF>

	<CFSCRIPT>
		if (isDefined("form.icontact_id") and len(trim(form.icontact_id)) gt 0) { contactid= "and c.icontact_id =" & trim(form.icontact_id); }
		else { contactid= ''; }
	</CFSCRIPT>
	
	<!--- Retrieve Contact information --->
	<CFQUERY NAME="Contact" DATASOURCE="#APPLICATION.datasource#">
		SELECT	C.*
		FROM LinkTenantContact LTC with (NOLOCK)
		JOIN Contact C with (NOLOCK) ON (LTC.iContact_ID = C.iContact_ID	AND C.dtRowDeleted IS NULL)	
		WHERE LTC.dtRowDeleted IS NULL <!--- AND bIsPayer IS NOT NULL --->
		and bIsMoveOutPayer  = 1
		AND iTenant_ID = #form.iTenant_ID#
		<!--- #contactid# --->
		and rtrim(ltrim(c.cfirstname)) = '#trim(form.cFirstName)#' and rtrim(ltrim(c.clastname)) = '#trim(form.clastname)#'
	</CFQUERY>
	
	<CFIF Contact.RecordCount GT 0> 
		<CFQUERY NAME="UpdateLinkTenantContact" DATASOURCE="#APPLICATION.datasource#" result="UpdateLinkTenantContact">
			UPDATE LinkTenantContact
			SET	iRelationshipType_ID = #form.IRELATIONSHIPTYPE_ID# 
				,dtrowstart=getdate()
				,irowstartuser_id = #SESSION.UserID#
				,bIsMoveOutPayer = 1
			WHERE iContact_ID = #Contact.iContact_ID#
		</CFQUERY>
	 
		<CFQUERY NAME = "UpdateContact" DATASOURCE="#APPLICATION.datasource#" result="UpdateContact">
				UPDATE 	Contact
				SET		
				<CFIF form.cFirstName NEQ ""> cFirstName = '#form.CFIRSTNAME#', <CFELSE> cFirstName = NULL,	</CFIF>	
				<CFIF form.cLastName NEQ ""> cLastName = '#form.CLASTNAME#', <CFELSE> cLastName = NULL, </CFIF>
				<CFIF form.cAddressLine1 NEQ ""> cAddressLine1 = '#form.CADDRESSLINE1#', 
				<CFELSE> cAddressLine1 = NULL,	</CFIF>
				<CFIF form.cAddressLine2 NEQ ""> cAddressLine2 = '#form.CADDRESSLINE2#', 
				<CFELSE> cAddressLine2 = NULL, </CFIF>			
				<CFIF form.cCity NEQ ""> cCity = '#form.CCITY#', <CFELSE> cCity = NULL, </CFIF>
				<CFIF form.cStateCode NEQ ""> cStateCode = '#form.CSTATECODE#', <CFELSE> cStateCode = NULL, </CFIF>	
				<CFIF form.cZipCode NEQ ""> cZipCode = '#form.CZIPCODE#', </CFIF>	
				<CFIF Variables.PhoneNumber1 NEQ ""> cPhoneNumber1 = '#TRIM(Variables.PHONENUMBER1)#', 
				<CFELSE> cPhoneNumber1 = NULL, </CFIF>
				<CFIF Variables.PhoneNumber2 NEQ ""> cPhoneNumber2 = '#TRIM(Variables.PHONENUMBER2)#' 
				<CFELSE> cPhoneNumber2 = NULL </CFIF>
			WHERE	iContact_ID = #Contact.iContact_ID#	
		</CFQUERY>
	 
	<CFELSEIF TRIM(form.cLastName) NEQ "" AND TRIM(form.cFirstName) NEQ "">
		<CFQUERY NAME = "NewContact" DATASOURCE = "#APPLICATION.datasource#" result="NewContact">
			INSERT INTO Contact
			(	cFirstName, cLastName, cPhoneNumber1, iPhoneType1_ID, cPhoneNumber2, iPhoneType2_ID, 
				cPhoneNumber3, iPhoneType3_ID, cAddressLine1, cAddressLine2, cCity, cStateCode, 
				cZipCode, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart	
			)VALUES(
				'#TRIM(form.cFirstName)#', '#TRIM(form.cLastName)#',
				<CFIF PhoneNumber1 NEQ ""> '#TRIM(Variables.PHONENUMBER1)#', <CFELSE> NULL, </CFIF>
				1,
				<CFIF PhoneNumber2 NEQ ""> '#TRIM(Variables.PHONENUMBER2)#', <CFELSE> NULL, </CFIF>
				5, NULL, NULL,
				<CFIF form.cAddressLine1 NEQ ""> '#TRIM(form.CADDRESSLINE1)#', <CFELSE> NULL, </CFIF>
				<CFIF form.cAddressLine2 NEQ ""> '#TRIM(form.CADDRESSLINE2)#', <CFELSE> NULL, </CFIF>
				<CFIF form.cCity NEQ ""> '#TRIM(form.cCity)#', <CFELSE> NULL, </CFIF>
				<CFIF form.cStateCode NEQ ""> '#TRIM(form.cStateCode)#', <CFELSE> NULL, </CFIF>
				<CFIF form.cZipCode NEQ "">	'#TRIM(form.cZipCode)#', <CFELSE> NULL, </CFIF>
				<CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', <CFELSE> NULL, </CFIF>
				#CreateODBCDateTime(SESSION.AcctStamp)#, #SESSION.UserID#, getDate()
			)	
		</CFQUERY>
		
	
		<CFQUERY NAME = "GetCID" DATASOURCE = "#APPLICATION.datasource#"> <!---Mshah added top 1 and desc in query to get the correct contact ID--->
			SELECT	iContact_ID
			FROM	Contact with (NOLOCK)
			WHERE	cFirstName = '#TRIM(form.cFirstName)#'
			AND		cLastName = '#TRIM(form.cLastName)#'
			AND		cAddressLine1 <CFIF TRIM(form.cAddressLine1) NEQ "">= '#TRIM(form.cAddressLine1)#'
			<CFELSE>IS NULL</CFIF>
			AND		iRowStartUser_ID = #SESSION.UserID#
			<!---order by icontact_ID desc--->
		</CFQUERY>
	
		<CFQUERY NAME="NewLinkTenantContact" DATASOURCE="#APPLICATION.datasource#" result="NewLinkTenantContact">
			declare @count int
	
			select @count = (select count(ilinktenantcontact_id) 
			from linktenantcontact where dtrowdeleted is null and icontact_id = #GetCID.iContact_ID# and itenant_ID=#form.iTenant_ID#) <!---mshah addd here to avoid taking another tenantID--->
	
			if @count = 0 
			begin 
			INSERT INTO LinkTenantContact
			(	iTenant_ID, iContact_ID, iRelationshipType_ID,   bIsPowerOfAttorney, bIsMedicalProvider, 
				cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, bIsMoveOutPayer
			)VALUES(
				#form.iTenant_ID#, #GetCID.iContact_ID#, #form.iRelationshipType_ID#,  
				NULL, NULL,
				  <CFIF form.cComments NEQ ""> '#TRIM(form.cComments)#', <CFELSE> NULL, </CFIF>
				  #CreateODBCDateTime(SESSION.AcctStamp)#,
				#SESSION.UserID#, #todaysdate#, 1
			)
			end
		</CFQUERY>
		
	</CFIF>	
	

<cfif #form.SecondaryTenantId# NEQ "">
	<cfquery name="qDetermineRentEffective" DATASOURCE="#APPLICATION.datasource#">
		Select * from tenantstate with (NOLOCK) where itenant_id= #form.SecondaryTenantId#
	</cfquery>
</cfif>
<CFIF #form.IsTenantPrimary# EQ 1 and #form.SecondaryTenantId# NEQ "" and #qDetermineRentEffective.dtRentEffective# LT #dtMoveOut# >

<CFQUERY NAME="updatesecondarySwitchDate" DATASOURCE="#APPLICATION.datasource#" result="result">
UPDATE tenantstate
set dtsecondaryswitchdate = DATEADD(day,1,#dtChargeThrough#) 
where itenant_id = #form.SecondaryTenantId#
</CFQUERY>
</CFIF>
<!---Mamta-query added to null the Secondaryswitchdate if tenant is movingout b4 that" </cfoutput>---> 
<CFIF #Tenant.dtSecondarySwitchDate# NEQ "" and #Variables.dtMoveOut# LTE #Tenant.dtSecondarySwitchDate# >
<CFQUERY NAME="updatesecondarySwitchDatenull" DATASOURCE="#APPLICATION.datasource#">
UPDATE tenantstate
set dtsecondaryswitchdate = null
where itenant_id = #form.iTenant_ID#
</CFQUERY>
</CFIF>
<!---mamta added to reset fulltocomapnion and companiontofull switch, if the tenant is movingout on the same day--->
<cfif Trim(#Tenant.dtCompanionToFullSwitch#) NEQ "" and #Tenant.dtCompanionToFullSwitch# GTE #dtChargeThrough#
	OR Trim(#Tenant.dtFullToCompanionSwitch#) NEQ "" and #Tenant.dtFullToCompanionSwitch# GTE #dtChargeThrough#>
	<CFQUERY NAME="UpdateCompanionSwitchDatenull" DATASOURCE="#APPLICATION.datasource#">
	UPDATE tenantstate
	set  dtCompanionToFullSwitch= Null
		,dtFullToCompanionSwitch = null
	where itenant_id = #form.iTenant_ID#
	</CFQUERY>
</cfif>

</CFTRANSACTION>	

<CFSET PastDueMonth = DateFormat(DateAdd("m",-1,SESSION.TIPSMonth),"yyyymm")>

<!---Retrieve the Last FINALIZED  last Invoice Total--->
<CFQUERY NAME="LastTotal" DATASOURCE="#APPLICATION.datasource#">
	SELECT	 top 1 mInvoiceTotal as Total, dtInvoiceEnd
	FROM	 InvoiceMaster	IM with (NOLOCK)
			 JOIN InvoiceDetail INV with (NOLOCK)	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
	WHERE	 INV.dtRowDeleted IS NULL and IM.dtRowDeleted IS NULL and IM.bMoveOutInvoice IS NULL
			 and	IM.bFinalized IS NOT NULL 
			 and im.csolomonkey = '#Tenant.csolomonkey#'
             AND	(IM.cAppliesToAcctPeriod <= '#PastDueMonth#' OR 
             		(IM.cAppliesToAcctPeriod = '#DateFormat(SESSION.TipsMonth,'yyyymm')#' 
					AND IM.bMoveInInvoice IS NOT NULL))
	ORDER BY im.cAppliesToAcctPeriod desc, im.dtinvoiceend desc, im.iinvoicemaster_id desc
</CFQUERY> 

<CFSET LastTotaldtInvoiceEnd = LastTotal.dtInvoiceEnd>

<!--- Retrieve Solomon Transaction Information for tenant (if the house is not zeta) --->
<CFIF SESSION.qSelectedHouse.iHouse_ID NEQ 200> 
	<CFQUERY NAME="SolomonTrans" DATASOURCE="SOLOMON-HOUSES">
		<!--- SELECT SUM(	CASE WHEN doctype in ('PA','CM','SB','PP') then -origdocamt ELSE origdocamt END) as Total --->
		SELECT SUM(	CASE WHEN doctype in ('PA','CM') then -origdocamt ELSE origdocamt END) as Total  
		FROM ardoc with (NOLOCK)  WHERE custid = '#TRIM(Tenant.cSolomonKey)#' AND doctype <> 'IN' 
		AND User7 > = '#Variables.dtInvoiceStart#'
	</CFQUERY>
</CFIF>	

<CFIF IsDefined("SolomonTrans.Total") AND SolomonTrans.Total NEQ ""> 
	<CFSET SolomonTransTotal = SolomonTrans.Total>
<CFELSE>
	<CFSET SolomonTransTotal = 0.00>
</CFIF>

<!--- Retrieve the current total for this moveout invoice --->
<CFQUERY NAME="CurrentTotal" DATASOURCE="#APPLICATION.datasource#">
	SELECT	round(Sum(mAmount * iQuantity),2) as Total
	FROM	InvoiceDetail with (NOLOCK)
	WHERE	dtRowDeleted IS NULL
	AND		iInvoiceMaster_ID = '#Variables.iInvoiceMaster_ID#'
</CFQUERY> 

<!---Retrieve Refundable Deposits for this person --->
<CFQUERY NAME="TotalRefundables" DATASOURCE="#APPLICATION.datasource#">
	rw.sp_MoveOutDeposits #Tenant.iTenant_ID#
</CFQUERY>

<CFSET RefundTotal = 0>

<CFLOOP QUERY="TotalRefundables">
	<CFSET	RefundTotal = (TotalRefundables.mAmount * TotalRefundables.iQuantity) + RefundTotal>
</CFLOOP>

<CFSCRIPT>
	if (IsDefined("CurrentTotal.Total") AND CurrentTotal.Total NEQ "")
		{ CurrentTotal = CurrentTotal.Total; }
	else 
		{ CurrentTotal = 0.00; }

	if (IsDefined("LastTotal.Total") AND LastTotal.Total NEQ "" AND form.Occupancy EQ 1) 
		{ LastTotal = LastTotal.Total; }
	else 
		{LastTotal = 0.00; }
	
	NewInvoiceTotal = (LastTotal + CurrentTotal + SolomonTransTotal) - RefundTotal;
</CFSCRIPT>

<CFIF Tenant.iTenantStateCode_ID LT 4> 
	<CFQUERY NAME="UpdateTotal" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	InvoiceMaster
		SET		mInvoiceTotal = #NewInvoiceTotal#,
				mLastInvoiceTotal = #LastTotal#,
				dtInvoiceStart = <CFIF LastTotaldtInvoiceEnd NEQ ''>'#LastTotaldtInvoiceEnd#',<CFELSE>getdate(),</CFIF>
				cAppliesToAcctPeriod = '#DateFormat(SESSION.TIPSMonth,"yyyymm")#',
				dtRowStart = GetDate(),
				iRowStartUser_ID = #SESSION.UserID#
				<CFIF IsDefined("form.InvoiceComments") AND form.InvoiceComments NEQ "">
				 ,cComments='#form.InvoiceComments#' </CFIF>
		WHERE	dtRowDeleted IS NULL
		AND		iInvoiceMaster_ID = #Variables.iInvoiceMaster_ID#
	</CFQUERY>

	<CFQUERY NAME="qDeleteDetails" DATASOURCE="#APPLICATION.datasource#">
		update invoicedetail
		set dtrowdeleted=getdate()
		,irowdeleteduser_id='#SESSION.UserID#'
		,crowdeleteduser_id='sys_pdmoveout'
		from invoicedetail inv
		join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id 
		and im.dtrowdeleted is null
		and inv.dtrowdeleted is null 
		and im.bfinalized is null 
		and im.bmoveoutinvoice is null 
		and im.bmoveininvoice is null
		join tenant t on t.itenant_id = inv.itenant_id and t.dtrowdeleted is null
		join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
		join house h on h.ihouse_id = t.ihouse_id and h.dtrowdeleted is null
		and ts.itenantstatecode_id = 3
		where t.itenant_id = #Tenant.iTenant_ID#
	</CFQUERY> 
</CFIF>
    
<CFOUTPUT>
<cfif session.userID is 3863>
		<A HREF="MoveOutFormSummary.cfm?ID=#form.iTenant_ID#&ShowBtn=#ShowBtn#">Continue.</A>
<cfelse>
	<CFIF IsDefined("url.edit")>
		<CFSET Action='MoveOutForm.cfm?ID=#form.iTenant_ID#&edit=1&ShowBtn=#ShowBtn#'>
	<CFELSE>
		<CFSET Action='MoveOutFormSummary.cfm?ID=#form.iTenant_ID#&ShowBtn=#ShowBtn#'>
	</CFIF>
	
	  <CFLOCATION URL="#Action#" ADDTOKEN="No"> 
</cfif>
</CFOUTPUT>