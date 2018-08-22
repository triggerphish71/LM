<cfcomponent displayname="Community Fee payment">

	<cffunction access="public" name="getTenantInfo" output="false" returntype="query" hint="I return a resultset of the tenant information">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">name="
		
		<cfquery name="local.qGetTenantInfo" datasource="#arguments.datasource#">
			SELECT	*, (T.cFirstName + ' ' + T.cLastName) as FullName, 
				t.bispayer, 
				t.ihouse_id,
				ts.iTenantStateCode_ID, 
				ts.iResidencyType_ID,
				h.cName HouseName, 
				TS.dtMoveIn, 
				ts.mbasenrf, 
				ts.madjnrf, 
				ts.dtrenteffective,
				chgset.cname as chargeset
			FROM	TENANT	T WITH (NOLOCK)
			Join TenantState TS WITH (NOLOCK) on T.itenant_id = TS.itenant_id
			JOIN 	House H WITH (NOLOCK) on h.ihouse_id = T.ihouse_id
			JOIN ChargeSet chgset on h.ichargeset_id = chgset.ichargeset_id
			WHERE	T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.itenant_id#">
		</cfquery>

		<cfreturn local.qGetTenantInfo>
	</cffunction>

	<cffunction access="public" name="getRecurringCharge" output="false" returntype="query" hint="I return a query with the recurring charges information">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="chargeset" type="string" required="true">
		<cfargument name="tenantID" type="numeric" required="true">

		<cfquery name="qRecurringCharge" datasource="#application.datasource#">
			SELECT irecurringCharge_id 
			FROM recurringcharge rchg WITH (NOLOCK) 
			INNER JOIN Charges chg  WITH (NOLOCK) on rchg.icharge_id = chg.icharge_id
			WHERE chg.ichargetype_id = 1741 
			AND chg.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			AND chg.dtrowdeleted is null 
			AND chg.cchargeset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.chargeSet#">
			AND rchg.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TenantID#"> 
			AND rchg.dtrowdeleted is null
		</cfquery>
		<cfreturn qRecurringCharge>
	</cffunction>

	<cffunction access="public" name="getCommunityFeeCharge" output="false" returntype="query" hint="I return the charge ID for the specific community fee">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="chargeset" type="string" required="true">

		<cfquery name="qCommunityFeeCharge" datasource="#application.datasource#">
			SELECT icharge_id 
			FROM Charges chg WITH (NOLOCK)
			WHERE chg.ichargetype_id = 1741 
			AND chg.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			AND chg.dtrowdeleted is null 
			AND chg.cchargeset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.chargeset#">
		</cfquery>
		<cfreturn qCommunityFeeCharge>
	</cffunction>

	<cffunction access="public" name="InsertRecurringCharges" output="false" returntype="boolean" hint="I handle the inserting of recurring charges">k
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="chargeID" type="numeric" required="true">
		<cfargument name="effectiveStart" type="string" required="true">
		<cfargument name="effectiveEnd" type="string"required="true">
		<cfargument name="quantity" type="numeric" required="true">
		<cfargument name="description" type="string" required="true">
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="comments" type="string" required="false" default="">
		<cfargument name="acctStamp" type="string" required="true">
		<cfargument name="userID" type="numeric" required="true">
		<cfargument name="rowStart" type="string" required="true">

		<cftry>
			<cfquery name="qInsertRecurringCharges" datasource="#application.datasource#">
				INSERT INTO RecurringCharge
				( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, 
				mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
				VALUES
				( <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TenantID#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.chargeID#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(arguments.effectiveStart)#">  
				 ,<cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(arguments.effectiveEnd)#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.quantity#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.description#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">
				 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comments#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(arguments.acctStamp)#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#"> 
				 ,<cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(arguments.rowStart)#">
			    )	
			</cfquery>
			<cfcatch type="any">
				<cfreturn false>
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>

	<cffunction access="public" name="RecurringCharge" output="false" returntype="boolean" hint="I updated the recurring charges table">
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="effectiveEnd" type="string" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="recurringChargeID" type="numeric" required="true">
		<cftry>
			<cfquery name="qUpdRecurringCharges">
				UPDATE RecurringCharge
				SET mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">
				,dtEffectiveEnd = <cfqueryparam cfsqltype="cf_sql_date" value="#CreateODBCDateTime(arguments.effectiveEnd)#">
				WHERE   itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
				AND irecurringCharge_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.recurringChargeID#">
			</cfquery>
			<cfcatch>
				<cfreturn false>
			</cfcatch>
		</cftry>
		<cfreturn true>
	</cffunction>

	<cffunction access="public" name="CommunityPayment" output="false" returntype="void" hint=" I update the tenantState table with the amount deferred">
		<cfargument name="MonthDeferred" type="numeric" required="true">
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">

		<cfquery name="qUpdCommunityPayment" datasource="#application.datasource#">
			UPDATE tenantstate
			SET iMonthsDeferred = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.MonthDeferred#">
			,mAmtDeferred = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
	</cffunction>


</cfcomponent>