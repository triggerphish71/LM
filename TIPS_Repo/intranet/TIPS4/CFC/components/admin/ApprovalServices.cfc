<cfcomponent displayname="Approval Services">

	<cffunction access="public" name="getApprovalCount" output="false" returntype="query" hint="I return a recordset for all tenants with un-approved assessments">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfargument name="acctPeriod" type="date" required="true">

		<cfset local.qApprovalCount = queryNew("ID","varchar")>
		<cfquery name="local.qApprovalCount" datasource="#arguments.datasource#">
			SELECT h.cname as House_name , t.itenant_id as Tenant_ID, t.clastname+','+t.cfirstname as Full_Name, t.csolomonkey as Solomon_Key
				, 'Resident Care - Level '+sl.cDescription as Description, Round(vwc.mamount*30,1) as Amount, im.cappliestoacctperiod as Period 	
			FROM invoicemaster im with (nolock)
			INNER JOIN tenant t with (nolock)	on im.cSolomonKey = t.cSolomonKey
			INNER JOIN tenantstate ts with (nolock)	on t.iTenant_ID = ts.iTenant_ID
			INNER JOIN house h with (nolock)	on t.iHouse_ID = h.iHouse_ID
			INNER JOIN rw.vw_charges vwc with (nolock)	on vwc.iHouse_ID = h.iHouse_ID	AND	isnull(vwc.cChargeSet, 'ZZZ') = isnull(t.cChargeSet, 'ZZZ')
			INNER JOIN ChargeType CT with (nolock)	on vwc.iChargeType_ID = CT.iChargeType_ID
			INNER JOIN SLevelType SL with (nolock)	on t.cSLevelTypeSet = SL.cSLevelTypeSet	AND ts.ispoints between iSPointsMin AND iSPointsMax
			LEFT JOIN invoicedetail id  with (nolock)	on im.iInvoiceMaster_ID = id.iInvoiceMaster_ID	AND id.dtRowDeleted is null	AND id.iChargeType_ID = 91 AND id.cAppliesToAcctPeriod = im.cAppliesToAcctPeriod
			WHERE im.dtRowDeleted is null
			AND im.cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_char" value="#Year(arguments.acctperiod)##DateFormat(arguments.acctperiod, 'mm')#">
			AND im.cSolomonKey = t.csolomonkey
			AND id.iTenant_ID is null
			AND im.bFinalized is null
			AND im.bMoveInInvoice is null
			AND im.bMoveOutInvoice is null
			AND TS.iProductLine_ID = 1
			AND t.cBillingType = 'D'
			AND ts.iResidencyType_ID = 1
			AND iTenantStateCode_ID = 2
			AND ispoints <> 0
			AND vwc.dtrowdeleted is null
			AND CT.dtrowdeleted is null
			AND CT.bisrecurring = 1
			AND	vwc.dtRowDeleted Is NULL
			AND	'#arguments.acctperiod#' between vwc.dtEffectiveStart AND vwc.dtEffectiveEnd
			AND	isnull(vwc.cChargeSet, 'ZZZ') = isnull(t.cChargeSet, 'ZZZ')
			AND	vwc.iSLevelType_ID = SL.iSLevelType_ID
			AND	vwc.iResidencyType_ID = ts.iResidencyType_ID
			AND	Left(sl.cDescription,1) > 0
			AND	isnull(ct.bIsPrePay, 0) = 1
			AND	isnull(ct.bResidencyType_ID, 0) = 1
			AND	isnull(ct.bIsRent, 0) = 1
			AND	isnull(ct.bIsDaily, 0) = 1
			AND	isnull(ct.bOccupancyPosition, 0) = 0
			AND	isnull(ct.bIsMedicaid, 0) = 0
			AND	ct.dtRowDeleted is null
			AND ct.ichargetype_ID = 91
			AND ts.bMC2AL IS NULL
			AND h.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			ORDER BY House_Name,t.cSolomonKey	
		</cfquery>
		<cfreturn local.qApprovalCount>
	</cffunction>	





<!----  need to review to see if i can keep or delete the functions below

	<cffunction access="public" name="getMc2ALDate" output="false" returntype="date" hint="I return the date when the user moved from MC to AL">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">

		<cfquery name="qGetMC2ALInfo" datasource="#arguments.datasource#">
			SELECT dtRowStart,iProductLine_ID
			FROM tenantstate WITH (NOLOCK)
			WHERE iTenant_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			UNION
			SELECT dtRowStart,iProductLine_ID
			FROM p_tenantstate WITH (NOLOCK)
			WHERE iTenant_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>

		<cfset pLineID = 0>
		<cfset retVal = DateFormat(Now(),"mm/dd/yyyy")>
		<cfloop query="qGetMC2ALInfo">
			<cfif pLineID EQ 0>
				<cfset pLineID = qGetMC2ALInfo['iProductline_ID'][currentrow]>
			</cfif>
			<cfif qGetMC2ALInfo['iProductline_ID'][currentrow] NEQ pLineID>
				<cfset  retval =  DateFormat(qGetMC2ALInfo['dtRowStart'][currentrow],"mm/dd/yyyy")>
				<cfbreak>
			</cfif>
		</cfloop>
		<cfreturn retVal>				
	</cffunction>

	<cffunction access="public" name="getProrateMCDays" output="false" returntype="numeric" hint="I return the number of days for MC Prorate">	
		<cfargument name="ALSwitchDt" type="date" required="true">
		<cfset local.mcStartDt = CreateDate(Year(arguments.ALSwitchDt),Month(arguments.ALSwitchDt),"01")>
		<cfset local.numberOfDays = DateDiff("d",local.mcStartDt,arguments.ALSwitchDt)>
		<cfreturn local.numberOfDays>
	</cffunction>

	<cffunction access="public" name="getProrateALDays" output="false" returntype="numeric" hint="I return the number of days for AL Prorate">	
		<cfargument name="ALSwitchDt" type="date" required="true">
		<cfset local.EndOfMonth = CreateDate(Year(arguments.ALSwitchDt),Month(arguments.ALSwitchDt),DaysInMonth(arguments.ALSwitchDt))>
		<cfset local.numberOfDays = DateDiff("d",arguments.ALSwitchDt,local.EndOfMonth)>
		<cfreturn local.numberOfDays>
	</cffunction>

	<cffunction access="public" name="getMCProrateCharges" output="false" returntype="query" hint="I return the MC Charge amount">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" require="true">
		<cfargument name="acctPeriod" type="numeric" required="true">

		<cfset local.qGetMCCharges = queryNew("amount,description","decimal,varchar")>

		<cfquery name="local.qGetMCCharges" datasource="#arguments.datasource#">
			SELECT mamount as amount,cDescription as description 
			FROM InvoiceDetail with (NOLOCK)
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND iChargeType_ID = 1748
			AND cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.acctPeriod#">
		</cfquery>
		<cfreturn local.qGetMCCharges>
	</cffunction>


	<cffunction access="public" name="getALProrateCharges" output="false" retuntype="query" hint="I return the charges for AL LOC">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="acctPeriod"  type="numeric" required="true">

		<cfset local.qGetALCharges= queryNew("amount,description","decimal,varchar")>
		<cfquery name="local.qGetALCharges" datasource="#arguments.datasource#">
			SELECT mamount as amount, cDescription as description
			FROM InvoiceDetail with (NOLOCK)
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND iChargeType_ID = 91
			AND cAppliesToAcctPeriod = <cfqueryparam  cfsqltype="cf_sql_integer" value="#arguments.acctPeriod#">
		</cfquery>
		<cfreturn local.qGetALCharges>
	</cffunction>

	<cffunction access="public" name="AddLOCCharges" output="false" returntype="void" hint="I insert the prorated LOC Charges">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="formData" type="struct" required="true">

		<cfdump var="#arguments#" label="arguments" abort>


		<cfquery name="qAddProratedLCCharges" datasource="#arguments.datasource#">
			INSERT INTO InvoiceDetail (iInvoiceMaster_ID,iTenant_Id,ichargeType_ID,iQuantity,cDescription,mAmount,cAppliesToAcctPeriod)
			VALUES(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.InvoiceMasterID#">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.tenantID#">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="91">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.qty#">,
				   <cfqueryparam cfsqltype="cf_sql_varchar" value="Prorated Care Charges">,
				   <cfqueryparam cfsqltype="cf_sql_money"   value="#arguments.formData.amount#">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formData.acctPeriod#">
			)
		</cfquery>

	</cffunction>


---->


</cfcomponent>



