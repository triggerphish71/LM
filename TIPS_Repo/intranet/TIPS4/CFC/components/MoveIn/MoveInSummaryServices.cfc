<cfcomponent displayname="Move in Summary Services" hint="I provide all the functions for the move in summary template">

	<cffunction access="public" name="getDate" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfquery name="qGetDate" datasource="#arguments.datasource#">
			SELECT getDate() as Stamp
		</cfquery>		
		<cfreturn qGetDate>
	</cffunction>

	<cffunction access="public" name="getAssessmentCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qAssessmentCheck" datasource="#arguments.datasource#">
			SELECT am.iassessmenttoolmaster_id
			FROM tenant t	
		 	left join assessmenttoolmaster am on  am.itenant_id = t.itenant_id  AND am.dtrowdeleted is null AND am.bbillingactive is not null
			WHERE t.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
		<cfreturn qAssessmentCheck>
	</cffunction>

	<cffunction access="public" name="getMoveInInvoice" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="invoiceID" type="numeric" required="true">
		<cfquery name="qMoveInInvoice" datasource="#arguments.datasource#">
			SELECT * 
			FROM InvoiceMaster 
			WHERE dtRowDeleted is null 
			AND iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoiceID#">
		</cfquery>
		<cfreturn qMoveInInvoice>
	</cffunction>

	<cffunction access="public" name="getFindOccupancy" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="AddressID" type="numeric" required="true">
		<cfargument name="TenantID" type="numeric" required="true">
		<cfquery name="qFindOccupancy" datasource="#arguments.datasource#">
			SELECT T.iTenant_ID
				,iResidencyType_ID
				,ST.cDescription as Level
				,TS.dtMoveIn
				,TS.dtMoveOut
				,TS.iSPoints
				,ts.iMonthsDeferred as PaymentMonths
				,ts.mBaseNrf as NRFBase
				,ts.mAdjNrf as NRFAdj
			FROM AptAddress AD WITH (NOLOCK)
			INNER JOIN TenantState ts WITH (NOLOCK) on (ts.iAptAddress_ID = ad.iAptAddress_ID AND ts.dtRowDeleted is null)
			INNER JOIN Tenant T WITH (NOLOCK) on (t.iTenant_ID = ts.iTenant_ID AND t.dtRowDeleted is null)
			INNER JOIN SLevelType ST WITH (NOLOCK) on (ST.cSLevelTypeSet = t.cSLevelTypeSet AND ts.iSPoints between ST.iSPointsMin AND ST.iSPointsMax)
			WHERE ad.dtRowDeleted is null 
			AND ts.iTenantStateCode_ID = 2
			AND ad.iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.addressID#">	
			AND ts.iTenant_ID <>  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TenantID#">
		</cfquery>
		<cfreturn qFindOccupancy>
	</cffunction>

	<cffunction access="public" name="getMedicaidRate" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseId" type="numeric" required="true">
		<cfquery name="qryMedicaidRate" datasource="#arguments.datasource#">
			SELECT mStateMedicaidAmt_BSF_Daily,mStateMedicaidAmt_BSF_Monthly
			FROM HouseMedicaid 
			WHERE ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>	
		<cfreturn qryMedicaidRate>
	</cffunction>

	<cffunction access="public" name="getMedicaidDate" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentId" type="numeric" required="true">
		<cfquery name="qryMedicaidDate" DATASOURCE = "#arguments.datasource#">
			SELECT distinct inv.cappliestoacctperiod
			FROM invoicedetail inv
			join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id AND im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">
			WHERE bMoveininvoice = 1 AND im.dtrowdeleted is null 
			AND inv.dtrowdeleted is null
		</cfquery>
		<cfreturn qryMedicaidDate>
	</cffunction>

	<cffunction access="public" name="getSelMedicaidCoPay" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">
		<cfargument name="acctPeriod" type="string" required="true">
		<cfquery name="qrySelMedicaidCoPay" datasource = "#arguments.datasource#">
			SELECT sum(inv.mamount) FROM invoicedetail inv
			inner join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
			AND im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">
			WHERE bMoveininvoice = 1 AND im.dtrowdeleted is null 
			AND inv.cappliestoacctperiod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">
			AND inv.dtrowdeleted is null AND im.dtrowdeleted is null
			AND inv.ichargetype_id in (1661)
		</cfquery>
		<cfreturn qrySelMedicaidCoPay>
	</cffunction>

	<cffunction access="public" name="getSelMedicaidBSF" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">
		<cfargument name="acctPeriod" type="string" required="true">
		<cfquery name="qrySelMedicaidBSF" datasource = "#arguments.datasource#">
			SELECT sum(inv.mamount) FROM invoicedetail inv
			inner join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
			AND im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">
			WHERE bMoveininvoice = 1 AND im.dtrowdeleted is null 
			AND inv.cappliestoacctperiod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">
			AND inv.dtrowdeleted is null AND im.dtrowdeleted is null
			AND inv.ichargetype_id in (31)
		</cfquery>
		<cfreturn qrySelMedicaidBSF>
	</cffunction>

	<cffunction access="public" name="getSelMedicaidState" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">
		<cfargument name="acctPeriod" type="string" required="true">
		<cfquery name="qrySelMedicaidState" datasource = "#arguments.datasource#">
			SELECT iinvoicedetail_id , mamount,iquantity FROM invoicedetail inv
			inner join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
			AND im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">
			WHERE bMoveininvoice = 1 AND im.dtrowdeleted is null
			AND inv.cappliestoacctperiod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">
			AND inv.dtrowdeleted is null 
			AND im.dtrowdeleted is null
			AND inv.ichargetype_id in (8)
		</cfquery>
		<cfreturn qrySelMedicaidState>
	</cffunction>

	<cffunction access="public" name="getSumMedicaidState" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">		
		<cfquery name="qrySumMedicaidState" datasource = "#arguments.datasource#">
			SELECT sum (mamount) as SumMedicaidState
			FROM invoicedetail inv
			join invoicemaster im on inv.iinvoicemaster_id = im.iinvoicemaster_id
			AND im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">
			WHERE bMoveininvoice = 1 AND im.dtrowdeleted is null
			AND inv.dtrowdeleted is null 
			AND im.dtrowdeleted is null
			AND inv.ichargetype_id in (8)
		</cfquery>
		<cfreturn qrySumMedicaidState>
	</cffunction>

	<cffunction access="public" name="updCommFeePaymnt" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">		
		<cfargument name="monthsDeferred" type="numeric" required="true">
		<cfquery name="qryUpdCommFeePaymnt" datasource = "#arguments.datasource#">
			Update tenantstate
			set iMonthsDeferred = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.monthsDeferred#">
			WHERE itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantId#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getChargeId" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfquery name="qChargeID"  datasource='#arguments.datasource#'>
			SELECT cdescription FROM chargetype WHERE ichargetype_id = 1741
		</cfquery>
		<cfreturn qChargeID >
	</cffunction>

	<cffunction access="public" name="inRecurring" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="qinRecurring"  datasource='#arguments.datasource#'>
			INSERT INTO RecurringCharge
			( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, 
			mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
			VALUES
			( <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.tenantID#">,
			  1741,getdate(),DateAdd("yyyy",10,getdate()),1, 
			  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.desc#">,
			  <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.theData.amount#">,
			  'Recurring Comm Fee created at move in', 
			  <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.AcctStamp#">, 
			  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">,
			  getdate()
			)
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="getNRFPaymnt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<CFQUERY NAME = "qryNrfPymnt" DATASOURCE = "#arguments.datasource#">
			SELECT	*, (T.cFirstName + ' ' + T.cLastName) as FullName
				, RT.cDescription
				, TS.bNRFPend
				, ts.cSecDepCommFee
				,ts.iMonthsDeferred as PaymentMonths
				, ts.mBaseNrf as NRFBase
				, ts.mAdjNrf as NRFAdj
			FROM TENANT	T WITH (NOLOCK)
			JOIN TenantState TS WITH (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID
			JOIN AptAddress AD WITH (NOLOCK) ON AD.iAptAddress_ID = TS.iAptAddress_ID
			JOIN ResidencyType RT WITH (NOLOCK) ON RT.iResidencyType_ID = TS.iResidencyType_ID
			WHERE T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</CFQUERY>
		<cfreturn qryNrfPymnt>
	</cffunction>

	<cffunction access="public" name="updNbrPymnt" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="updNbrPymnt" datasource = "#arguments.datasource#">
			UPDATE	TenantState
			SET	iMonthsDeferred = 1 
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TenantID#">
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="GetSolomonTransactions" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentId" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfquery name="qGetSolomonTransactions" datasource="#arguments.datasource#">
			SELECT * 
			FROM rw.vw_Get_Trx 
			WHERE custid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentId#">
			AND	User7 >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtInvoiceStart#">
			AND	User7 <= <cfif arguments.theData.dtInvoiceEnd neq ""> <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtInvoiceEnd#"> <cfelse> getDate() </cfif>
		</cfquery>
		<cfreturn qGetSolomonTransactions>
	</cffunction>

	<cffunction access="public" name="GetSolomonTrxTotal" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentId" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfquery name="qGetSolomonTrxTotal" datasource="#arguments.datasource#">
			SELECT sum(amount) as total
			FROM rw.vw_Get_Trx 
			WHERE custid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentId#">
			AND	User7 >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtInvoiceStart#">
			AND	User7 <= <cfif arguments.theData.dtInvoiceEnd neq ""> <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtInvoiceEnd#"> <cfelse> getDate() </cfif>
		</cfquery>
		<cfreturn qGetSolomonTrxTotal>
	</cffunction>

	<cffunction access="public" name="getHistSet" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="MoveInDt" type="string" required="true">
		<cfquery name='qHistSet' datasource="#arguments.datasource#">
			SELECT distinct tendtRowStart, cSLevelTypeSet, tendtRowEnd, tendtRowDeleted
			FROM rw.vw_tenant_history_with_state
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantId#">
			AND	<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.MoveInDt#"> BETWEEN tenDtRowStart AND tendtRowEnd 
			ORDER BY tenDtRowStart desc
		</cfquery>
		<cfreturn qHistSet>
	</cffunction>


	<cffunction access="public" name="getSLevel" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="qry1" type="query" required="true">
		<cfargument name="qry2" type="query" required="true">
		<cfargument name="sLevelType" type="string" required="true">
		<cfquery name="qGetSLevel" datasource="#arguments.datasource#">
			SELECT * 
			FROM SLevelType WITH (NOLOCK)
			WHERE dtRowDeleted is null
			AND iSPointsMin <= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.qry1.iSPoints#">
			AND iSPointsMax >= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.qry1.iSPoints#">
			<cfif arguments.qry2.RecordCount gt 0 AND arguments.qry2.cSLevelTypeSet neq ''>
				AND cSLevelTypeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.qry2.cSLevelTypeSet#">
			<cfelseif arguments.qry1.cSLevelTypeSet neq "" OR arguments.qry1.cSLevelTypeSet neq 0>
				AND cSLevelTypeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.qry1.cSLevelTypeSet#">
			<cfelse>
		 		AND cSLevelTypeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sLevelType#">
		 	</cfif>
		</cfquery>
		<cfreturn qGetSLevel>
	</cffunction>

	<cffunction access="public" name="getCredits" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="qry1" type="query" required="true">
		<cfargument name="mid" type="numeric" required="true">
		<cfquery name="qCredits" datasource="#arguments.datasource#">
			SELECT	*, inv.cDescription as cDescription
			FROM InvoiceDetail inv WITH (NOLOCK)
			INNER JOIN InvoiceMaster im WITH (NOLOCK)	on (inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID AND im.dtRowDeleted is null)
			INNER JOIN ChargeType ct WITH (NOLOCK) on (ct.iChargeType_ID = inv.iChargeType_ID AND ct.dtRowDeleted is null)
			WHERE iTenant_ID = #url.ID#
			AND	im.iInvoiceMaster_ID = 
				<cfif arguments.qry1.iInvoiceMaster_ID neq ''>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.qry1.iInvoiceMaster_ID#">
				<cfelse>
					<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.MID#">
				</cfif>
			AND	inv.dtRowDeleted is null
			AND	(ct.bIsMedicaid is null or (ct.bIsMedicaid is not null AND ct.bIsRent is not null))
			AND	ct.bIsDeposit is null AND	(inv.iRowStartUser_ID is null or inv.iRowStartUser_ID <> 0)
			AND inv.iChargeType_ID <> 1741
		</cfquery>
		<cfreturn qCredits>
	</cffunction>

	<cffunction access="public" name="getDepositCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfquery name="qGetDepositCheck" datasource="#arguments.datasource#">
			SELECT count(*) as count 
			FROM Charges C WITH (NOLOCK)
			INNER JOIN ChargeType ct WITH (NOLOCK) on (ct.iChargeType_ID = C.iChargeType_ID AND ct.dtRowDeleted is null)
			WHERE C.dtRowDeleted is null AND ct.bIsDeposit is not null 
			AND iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
		</cfquery>
		<cfreturn qGetDepositCheck>
	</cffunction>

	<cffunction access="public" name="getRefundable" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="houseSpecific" type="boolean" required="true">
		<cfquery name="qRefundable" datasource="#arguments.datasource#">
			SELECT	distinct inv.*
			FROM InvoiceDetail inv WITH (NOLOCK)
			INNER JOIN ChargeType ct WITH (NOLOCK) on (ct.iChargetype_ID = inv.iChargeType_ID AND ct.dtRowDeleted is null)
			INNER JOIN Charges C WITH (NOLOCK) on (C.iChargeType_ID = ct.iChargeType_ID AND C.dtRowDeleted is null)
			INNER JOIN Tenant T WITH (NOLOCK) on (T.iTenant_ID = inv.iTenant_ID AND T.dtRowDeleted is null)
			WHERE inv.dtRowDeleted is null
			<cfif arguments.HouseSpecific eq 1> 
				AND T.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			<cfelse>
				AND C.iHouse_ID is null	
			</cfif>	
			AND ct.bIsDeposit is not null AND ct.bIsRefundable is not null 
			AND inv.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TenantID#">
			AND inv.dtrowdeleted is null
		</cfquery>
		<cfreturn qRefundable>
	</cffunction>

	<cffunction access="public" name="getFees" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="houseSpecific" type="boolean" required="true">
		<cfquery name="qFees" datasource="#arguments.datasource#">
			SELECT	distinct inv.*, inv.mAmount as mAmount
			FROM InvoiceDetail inv WITH (NOLOCK)
			INNER JOIN ChargeType ct WITH (NOLOCK) on (ct.iChargetype_ID = inv.iChargeType_ID AND ct.dtRowDeleted is null)
			INNER JOIN Charges C WITH (NOLOCK) on (C.iChargeType_ID = ct.iChargeType_ID AND C.dtRowDeleted is null)
			INNER JOIN Tenant T WITH (NOLOCK) on (T.iTenant_ID = inv.iTenant_ID AND T.dtRowDeleted is null)
			INNER JOIN InvoiceMaster im WITH (NOLOCK) on (im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID AND im.dtRowDeleted is null)
			WHERE inv.dtRowDeleted is null
			<cfif arguments.HouseSpecific eq 1> 
				AND T.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">  
			<cfelse> 
				AND C.iHouse_ID is null
			</cfif>
			AND ct.bIsDeposit is not null 
			AND ct.bIsRefundable is null 
			AND inv.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TenantID#">
		</cfquery>
		<cfreturn qFees>
	</cffunction>

	<cffunction access="public" name="getCheckCompanionFlag" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="addressID" type="numeric" required="true">
		<cfquery name="qCheckCompanionFlag" datasource="#arguments.datasource#">
			SELECT	bIsCompanionSuite 
			FROM AptAddress AD
			INNER JOIN AptType AT on (AD.iAptType_ID = AT.iAptType_ID AND AT.dtRowDeleted is NULL)
			WHERE AD.dtRowDeleted is null AND AD.iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.addressID#">
		</cfquery>
		<cfreturn qCheckCompanionFlag>
	</cffunction>

	<cffunction access="public" name="getStandardRent" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="occupancy" type="string" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfquery name="qStandardRent" datasource="#arguments.datasource#">
			<cfif arguments.Occupancy eq 1>
				SELECT * 
				FROM Charges C WITH (NOLOCK)
				INNER JOIN ChargeType ct WITH (NOLOCK) on 
					(
						ct.iChargeType_ID = C.iChargeType_ID AND ct.dtRowDeleted is null
						AND ct.bIsRent is not null 
						AND ct.bIsMedicaid is null 
						AND ct.bIsDiscount is null
						AND ct.bIsRentAdjustment is null
					)
				WHERE C.dtRowDeleted is null 
				AND C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND C.iResidencyType_ID = 1 
				AND C.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_ID#">
				AND ct.bIsDaily is null AND C.iOccupancyPosition = 1
				<cfif arguments.theData.cChargeSet neq ""> 
					AND C.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#">
				<cfelse> 
					AND C.cChargeSet is null
				</cfif>
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				ORDER BY C.dtRowStart Desc				
			<cfelse>
				SELECT * 
				FROM Charges C WITH (NOLOCK)
				INNER JOIN ChargeType ct WITH (NOLOCK) on C.iChargeType_ID = ct.iChargeType_ID
				WHERE C.dtRowDeleted is null 
				AND ct.dtRowDeleted is null 
				AND iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND C.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_ID#">
				AND iOccupancyPosition = 2
				<cfif arguments.theData.iResidencyType_ID neq 3>
					AND ct.bIsDaily is null					
				</cfif>
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				ORDER BY C.dtRowStart Desc
			</cfif>	
		</cfquery>
		<cfreturn qStandardRent>
	</cffunction>

	<cffunction access="public" name="getStandardRent2" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="occupancy" type="string" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfquery name="qStandardRent" datasource="#arguments.datasource#">
			SELECT C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
			FROM Charges C WITH (NOLOCK)
			INNER JOIN 	ResidencyTYPE RT WITH (NOLOCK) on C.iResidencyType_ID = RT.iResidencyType_ID
			INNER JOIN 	ChargeType ct WITH (NOLOCK) on ct.iChargeType_ID = C.iChargeType_ID
			WHERE C.dtRowDeleted is null 
			AND ct.dtRowDeleted is null 
			AND IsNull(C.iOccupancyPosition,1) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.Occupancy#">	
			<cfif arguments.theData.cChargeSet neq ""> 
				AND C.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#">
			<cfelse> 
				AND C.cChargeSet is null 
			</cfif>
			<cfif arguments.theData.iResidencyType_ID neq 3>
				<cfif arguments.Occupancy neq 2> 
					AND C.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_ID#">
				<cfelse> 
					AND C.iAptType_ID is null 
				</cfif>				
				AND ct.bIsDaily is null
			</cfif>
			AND C.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_ID#">
			AND C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND (   (iCharge_id = 
						(SELECT top 1 iCharge_id 
						 FROM rw.vw_Charges_history 
						 WHERE ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				 		 AND'#arguments.thedata.dtMoveIn#' BETWEEN dtrowstart AND isNull(dtrowend,getdate())
						 AND iChargeType_ID = C.iChargeType_ID 
						 AND iAptType_ID = C.iAptType_ID			
				 		 AND dtRowDeleted is null
				 		)
				    ) 
					OR  
					(dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#"> 
					 AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				    ) 
				) 
				
			<cfif arguments.theData.iResidencyType_ID eq 3>
				AND c.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_ID#">
			</cfif>
			AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
			ORDER BY C.dtRowStart Desc
		</cfquery>
		<cfreturn qStandardRent>
	</cffunction>

	<cffunction access="public" name="getDailyRent" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="occupancy" type="string" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfquery name="qDailyRent" datasource="#arguments.datasource#">
			<cfif arguments.theData.iresidencytype_id is 5>
				SELECT	C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
				FROM Charges	C
				INNER JOIN ResidencyTYPE RT	ON	C.iResidencyType_ID = RT.iResidencyType_ID
				LEFT join SLevelType ST  on C.iSLevelType_ID = ST.iSLevelType_ID
				INNER JOIN ChargeType ct on ct.iChargeType_ID = C.iChargeType_ID
				WHERE C.dtRowDeleted is null 
				AND ct.dtRowDeleted is null
				AND C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND C.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_ID#">
				<cfif arguments.theData.cChargeSet neq ""> 
					AND C.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#">
				<cfelse> 
					AND C.cChargeSet is null
				</cfif>
				AND C.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_ID#">
				AND C.iSLevelType_ID is null 
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart desc
			<cfelseif arguments.Occupancy eq 1>
				SELECT	C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
				FROM Charges	C
				INNER JOIN ResidencyTYPE RT	ON	C.iResidencyType_ID = RT.iResidencyType_ID
				LEFT join SLevelType ST  on C.iSLevelType_ID = ST.iSLevelType_ID
				INNER JOIN ChargeType ct on ct.iChargeType_ID = C.iChargeType_ID
				WHERE C.dtRowDeleted is null 
				AND ct.dtRowDeleted is null
				AND ct.bIsDaily is not null
				AND C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND C.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_ID#">
				<cfif arguments.theData.cChargeSet neq ""> 
					AND C.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#"> 
				<cfelse> 
					AND C.cChargeSet is null
				</cfif>
				AND C.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_ID#">
				AND C.iSLevelType_ID is null 
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart desc			
			<cfelse>
				SELECT *
				FROM Charges C
				INNER JOIN ChargeType ct	ON C.iChargeType_ID = ct.iChargeType_ID
				WHERE C.dtRowDeleted is null AND ct.dtRowDeleted is null
				AND iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND ct.bIsDaily is not null
				AND iOccupancyPosition = 2 
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart desc
			</cfif>
		</cfquery>
		<cfreturn qDailyRent>
	</cffunction>

	<cffunction access="public" name="getDailyRent2" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="occupancy" type="string" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfargument name="sLevelTypeID" type="numeric" required="true">
		<cfquery name="qDailyRent" datasource="#arguments.datasource#">
			<cfif arguments.Occupancy eq 1>
				select C.iChargeType_ID, C.iQuantity, C.cDescription, C.mAmount
				from Charges	C
				join 	ResidencyTYPE RT	 on C.iResidencyType_ID = RT.iResidencyType_ID
				left outer join SLevelType ST	ON C.iSLevelType_ID = ST.iSLevelType_ID
				join 	ChargeType ct		 on ct.iChargeType_ID = C.iChargeType_ID
				where C.dtRowDeleted is null 
				AND ct.dtRowDeleted is null
				<cfif arguments.theData..cChargeSet neq ""> 
					AND C.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#"> 
				<cfelse> 
					AND C.cChargeSet is null
				</cfif>
				<cfif arguments.theData.iResidencyType_ID neq 3>
					AND C.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_ID#"> 
				</cfif>
				AND C.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_ID#">
				AND C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND ct.bIsDaily is not null
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart desc				
			<cfelse>
				select * 
				from Charges C
				join ChargeType ct	ON C.iChargeType_ID = ct.iChargeType_ID
				where C.dtRowDeleted is null
				AND ct.dtRowDeleted is null AND ct.bIsDaily is not null 
				AND iOccupancyPosition = 2
				AND iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND C.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_ID#">
				AND iSLevelType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sLevelTypeID#"> 
				AND dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#">
				AND	c.iproductline_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart desc
			</cfif>
		</cfquery>
		<cfreturn qDailyRent>
	</cffunction>

	<cffunction access="public" name="getMoveInCharges" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="mid" type="numeric" required="true">
		<cfquery name='qMoveInCharges' datasource='#arguments.datasource#'>
			SELECT inv.* 
			FROM InvoiceDetail inv WITH (NOLOCK)
			INNER JOIN ChargeType ct on inv.iChargeType_ID = ct.iChargeType_ID AND ct.dtRowDeleted is null
			INNER JOIN InvoiceMaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID 
			AND im.dtRowDeleted is null 
			AND im.iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mid#">
			WHERE inv.dtRowDeleted is null 
			AND ct.bIsDeposit is null 
			AND inv.iRowStartUser_ID = 0	
		</cfquery>
		<cfreturn qMoveInCharges>
	</cffunction>


	<cffunction access="public" name="getDailyRentCharges" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="AcctPeriod" type="string" required="true">
		<cfquery name="qDailyRentCharges" datasource="#arguments.datasource#">
			select inv.*
			from InvoiceDetail inv
			join ChargeType ct on inv.iChargeType_ID = ct.iChargeType_ID
			join InvoiceMaster im 	ON inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where bIsRent is not null and bIsDaily is not null and ct.bSLevelType_ID is null
			and im.bMoveInInvoice is not null and inv.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			and inv.dtRowDeleted is null
			and inv.cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctPeriod#">
		</cfquery>
		<cfreturn qDailyRentCharges>
	</cffunction>

	<cffunction access="public" name="getMonthRentCharges" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="AcctPeriod" type="string" required="true">
		<cfquery name="qMonthRentCharges" datasource="#arguments.datasource#">
			select inv.*
			from InvoiceDetail inv
			join ChargeType ct ON	inv.iChargeType_ID = ct.iChargeType_ID
			join InvoiceMaster im	ON	inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			where bIsRent is not null and bIsDaily is null and im.bMoveInInvoice is not null
			and inv.iTenant_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			and inv.dtRowDeleted is null
			and inv.cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.acctperiod#">
		</cfquery>
		<cfreturn qMonthRentCharges>
	</cffunction>

	<cffunction access="public" name="getCareCharges" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ResidencyTypeID" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qCareCharges" datasource="#application.datasource#">
			<cfif arguments.ResidencyTypeID neq 2>
				select inv.iQuantity ,inv.mAmount ,inv.cDescription 
				,Sum(inv.iQuantity * inv.mAmount) as ExtendedAmount, inv.cAppliesToAcctPeriod
				from InvoiceDetail inv
				join ChargeType ct on inv.iChargeType_ID = ct.iChargeType_ID
				join InvoiceMaster im 	ON inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
				where bIsRent is not null and ct.bAptType_ID is null and im.bMoveInInvoice is not null
				and inv.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> and inv.dtRowDeleted is null
				group by inv.iQuantity ,inv.mAmount ,inv.cDescription ,inv.cAppliesToAcctPeriod
				order by inv.cAppliesToAcctPeriod
			<cfelse> 
				select 0 as extendedamount 
			</cfif>
		</cfquery>
		<cfreturn qCareCharges>
	</cffunction>

	<cffunction access="public" name="getDailyCare" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="theData" type="query" required="true">
		<cfargument name="sLevelTypeID" type="numeric" required="true">
		<cfquery name='qDailyCare' datasource="#arguments.datasource#">
			select C.cDescription ,C.mAmount ,C.iQuantity ,ct.iChargeType_ID
			from Charges C
			join ChargeType ct on (ct.iChargeType_ID = C.iChargeType_ID and ct.dtRowDeleted is null)
			and ct.bIsRent is not null and ct.bIsMedicaid is null and ct.bIsDiscount is null
			and ct.bIsRentAdjustment is null
			where C.dtRowDeleted is null and C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			<cfif arguments.theData.cChargeSet neq ''>
				and C.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData..cChargeSet#">
			<cfelse>
				and C.cChargeSet is nulls
			</cfif>
			and	C.iResidencyType_ID = 1 and C.iAptType_ID is null 
			and iSLevelType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sLevelTypeID#"> 
			and ct.bIsDaily is not null
			and iOccupancyPosition is null
			and dtEffectiveStart <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.theData.dtMoveIn#"> 
			and dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_data" value="#arguments.theData.dtMoveIn#">
		</cfquery>
		<cfreturn qDailyCare>
	</cffunction>

	<cffunction access="public" name="qryNrfPymntNbr" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<CFQUERY NAME = "qryNrfPymntNbr" datasource = "#arguments.datasource#">
			SELECT	ts.iMonthsDeferred as NbrPaymentMonths
			FROM	TENANT	T
			JOIN 	TenantState TS ON T.iTenant_ID = TS.iTenant_ID
			WHERE	T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</CFQUERY>
		<cfreturn qryNrfPymntNbr>
	</cffunction>

	<cffunction access="public" name="qryHouseRegion" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<Cfquery name="qryHouseRegion" datasource="#arguments.datasource#">
			SELECT RO.regionID
				,RO.regionname
				,RO.opsname
				,RO.iDirectorUser_ID
				,RO.opsareaID
				,RO.iRegion_ID
				,RO.houseID
				,RO.cNumber
				,RO.cName			 
			  FROM [TIPS4].[rw].[vw_Reg_Ops_house] RO  			 
			  WHERE houseID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</Cfquery>
		<cfreturn qryHouseRegion>
	</cffunction>

</cfcomponent>