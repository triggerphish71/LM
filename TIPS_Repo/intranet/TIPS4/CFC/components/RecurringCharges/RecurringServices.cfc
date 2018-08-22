<cfcomponent displayname="Close House Services" output="false" hint="I provide the processes for closing a house.">
	
	<cffunction access="public" name="getHouseChargeSet" output="false" returntype="query" hint="I return a resultset of the houses charge set">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="iHouseID" type="numeric" required="true">

		<cfquery name="local.qGetHouseChargeSet" datasource="#arguments.datasource#">
			SELECT cs.cName
			FROM House h WITH (NOLOCK)
			INNER JOIN chargeset cs WITH (NOLOCK) on h.iChargeSet_ID = cs.iChargeSet_ID
			WHERE iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouseID#">
			AND h.dtRowDeleted IS NULL
		</cfquery>
	
		<cfreturn local.qGetHouseChargeSet>--->
	</cffunction>

	<cffunction access="public" name="getRegion" output="false" returntype="query" hint="I return a resultset of the region information for the house">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="iHouseID" type="numeric" required="true">
		
		<cfquery name="local.qGetRegion" datasource="#arguments.datasource#">
			SELECT h.cname as house, ops.cname as region, reg.cname as division
			FROM house h with (NOLOCK)
			INNER JOIN opsarea ops with (NOLOCK) on h.iopsarea_id = ops.iopsarea_id
			INNER JOIN region reg with (NOLOCK) on ops.iregion_id = reg.iregion_id
			WHERE h.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouseID#">
		</cfquery>

		<cfreturn local.qGetRegion>
	</cffunction>

	<cffunction access="public" name="getTenantList" output="false" returntype="query" hint="I return a resultset of the tenants who are in the status of MoveIn">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="iHouseID" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="false" default="">
		
		<cfquery name="local.qGetTenantList" datasource="#arguments.datasource#">
			SELECT *
			FROM tenant t (nolock) 
			INNER JOIN tenantstate ts (nolock) on (t.iTenant_ID = ts.iTenant_ID AND t.dtRowDeleted is null)	AND ts.iTenantStateCode_ID = 2 AND ts.iResidencyType_ID <> 3 
				AND t.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouseID#">	
			INNER JOIN AptAddress ad (nolock) on (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted is null)
			WHERE ts.iAptAddress_ID is not null
			<cfif LEN(arguments.tenantID) GT 0>
				AND T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
			</cfif>
			ORDER BY T.cLastName
		</cfquery>

		<cfreturn local.qGetTenantList>
	</cffunction>

	<cffunction access="public" name="getChargeListByChargeID" output="false" returntype="query" hint="I return a resultset of the houses chargeset">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="housename" type="string" required="true">
		<cfargument name="houseID" type="numeric" required="true" hint="##SESSION.qSelectedHouse.iHouse_ID##">
		<cfargument name="tipsMonth" type="string" required="true" hint="##SESSION.TipsMonth##">
		<cfargument name="chargeID" type="numeric" required="false" default="">
		
		<cfquery name="local.qGetChargeListByChargeID" datasource="#arguments.datasource#">
			SELECT	C.*, CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, CT.cDescription as typedescription,
				    CT.bIsRent, CT.bIsDaily, NULL as cComments, NULL as cInvoiceComments, CT.iChargeType_ID
			FROM Charges C with (NOLOCK)
			INNER JOIN ChargeType CT with (NOLOCK)on C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted is null AND c.dtRowDeleted is null
				AND cGLAccount <> 1030 AND CT.iChargeType_ID <> 23 AND CT.bisRecurring is not null
            	AND CT.bIsDeposit is null 
            	AND (C.cChargeSet is null or C.cChargeset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.housename#">)
            	AND (C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> OR C.iHouse_ID is null)
            	AND (c.iresidencytype_id <> 3 or c.iresidencytype_id is null)
            	AND ct.iChargeType_ID not in (1740,171)
			WHERE C.dtRowDeleted is null
			AND #CreateODBCDateTime(arguments.tipsMonth)# between c.dteffectivestart AND isnull(c.dteffectiveend,getdate())
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0 AND  
			( (IsDefined("SESSION.accessrights") AND SESSION.accessrights NEQ 'iDirectorUser_ID') or not isDefined("SESSION.accessrights") )>
			AND ((bIsRent IS NOT NULL AND bisdaily is not null AND isleveltype_id is null) OR bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL OR bIsRentAdjustment IS NOT NULL)
			AND bisdeposit is null
			AND bIsMedicaid is null AND cGLACCOUNT NOT IN (3011,3012,3015,3016)
		<CFELSEIF (IsDefined("SESSION.accessrights") AND SESSION.accessrights EQ 'iDirectorUser_ID')> 
			AND (bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL or (bisrent is not null AND bSlevelType_ID is null))
			AND bIsMedicaid is null AND cGLACCOUNT NOT IN (3011,3012,3015,3016)
			AND bisrentadjustment is null
		</CFIF>
		<cfif LEN(arguments.chargeID) GT 0> AND iCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.chargeID#"> </cfif>
		ORDER BY C.cDescription, CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc
		</cfquery>

		<cfreturn local.qGetChargeListByChargeID>
	</cffunction>

	<cffunction access="public" name="getChargeListByTypeID" output="false" returntype="query" hint="I return a resultset of the house chargeset">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="typeID" type="numeric" required="true">

		<cfquery name="local.qGetChargeListByTypeID" datasource="#arguments.datasource#">
			SELECT	RC.*, RC.bIsDaily as RCbIsDaily, CT.iChargeType_ID, CT.bIsModifiableDescription
				,CT.bIsModifiableAmount, CT.bIsModifiableQty, C.iCharge_ID,  CT.cDescription as typedescription
				,CT.bIsRent, CT.bIsDaily, NULL as cComments, NULL as cInvoiceComments
			FROM	RecurringCharge RC	with (NOLOCK)
			INNER JOIN	Charges C with (NOLOCK) ON (C.icharge_ID = RC.iCharge_ID AND C.dtRowDeleted is null AND rc.dtRowDeleted is null)
			INNER JOIN ChargeType CT with (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted is null)
			AND rc.iRecurringCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.typeIDID#">
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0>
			AND ct.bIsMedicaid is null
		</CFIF>
			ORDER BY CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc, C.cDescription
		</cfquery>

		<cfreturn local.qGetChargeListByTypeID>
	</cffunction>

	<cffunction access="public" name="getChargeTypes" output="false" returntype="query" hint="I return a resultset of Charge Types">
		<cfargument name="theQuery" type="query" required="true">
		<cfquery name="local.qChargeTypes" dbtype="query">
			SELECT	distinct typedescription, iChargeType_ID 
			FROM arguments.theQuery 
			Order by typedescription
		</cfquery>
		<cfreturn local.qChargeTypes>
	</cffunction>

	<cffunction access="public" name="getCommunityFeeChargeTypeIDs" output="false" returntype="query" hint="I return a resultset of communtiy fee charge type id's">
		<cfargument name="theQuery" type="query" required="true">
		<cfquery name="local.qCommunityFeeChargeTypeID" dbtype="query">
			SELECT iChargeType_ID
			FROM  arguments.theQuery
			WHERE upper(typedescription) LIKE '%COMMUNITY%
		</cfquery>
		<cfreturn local.qCommunityFeeChargeTypeID>
	</cffunction>


	<cffunction access="public" name="CurrentRecurring" output="false" returntype="query" hint="I return a resultset of the current recurring charges">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseID" required="true" type="numeric" hint="#SESSION.qSelectedHouse.iHouse_ID#">
		<cfargument name="tipsmonth" required="true" type="string" hint="#SESSION.TIPSMonth#">

		<cfquery name="local.qGetCurrentRecurring" datasource="#arguments.datasource#">
			SELECT	RC.iRecurringCharge_ID, RC.dtEffectiveStart, RC.dtEffectiveEnd, RC.iQuantity
			,RC.bIsDaily AS RCbIsDaily, RC.cDescription, ROUND(RC.mAmount,2) as mAmount, RC.cComments,
			T.iTenant_ID, T.cFirstname, T.cLastName, CT.bIsDaily, CT.ichargetype_id, TS.mAdjNRF, TS.mAmtNRFPaid
			FROM RecurringCharge RC with (NOLOCK)
			INNER JOIN	Charges C with (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID AND C.dtRowDeleted is null
			INNER JOIN 	ChargeType CT with (NOLOCK) ON CT.ichargetype_id = C.iChargeType_ID AND CT.dtrowdeleted is null
			INNER JOIN	Tenant T with (NOLOCK) ON RC.iTenant_ID = T. iTenant_ID AND T.dtRowDeleted is null AND RC.dtRowDeleted is null
			INNER JOIN	TenantState TS with (NOLOCK)ON TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted is null AND TS.iTenantStateCode_ID < 3 AND TS.iAptAddress_ID IS NOT NULL
			INNER JOIN	House H	with (NOLOCK) ON H.iHouse_ID = T.iHouse_ID AND H.dtRowDeleted is null AND H.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
			WHERE	RC.dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.tipsmonth#">
			ORDER BY T.cLastName
		</cfquery>

		<cfreturn local.qGetCurrentRecurring>
	</cffunction>

	<cffunction access="public" name="FindMissingRecurring" output="false" returntype="query" hint="I return a resultset of the missing charges">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true" hint="##SESSION.qSelectedHouse.iHouse_ID##">
		<cfargument name="tipsMonth" type="string" required="true" hint="##session.TipsMonth##">

		<cfquery name="local.qFindMissingRecurring" datasource="#arguments.datasource#">
			SELECT t.cfirstname+', '+t.clastname as Residentname,t.csolomonkey, t.ihouse_ID 
			FROM tenant t with (NOLOCK)
			INNER JOIN tenantstate ts with (NOLOCK) on ts.itenant_ID =t.itenant_ID 
			WHERE ts.itenantstatecode_ID=2 
			AND t.ihouse_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			AND t.dtrowdeleted is null AND ts.dtrowdeleted is null AND ts.iresidencytype_ID=1
			AND t.itenant_ID not in
			(SELECT	rc.itenant_ID
			FROM	RecurringCharge RC with (NOLOCK)
			INNER JOIN	Charges C with (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID AND C.dtRowDeleted is null
			INNER JOIN 	ChargeType CT with (NOLOCK) ON CT.ichargetype_id = C.iChargeType_ID AND CT.dtrowdeleted is null AND CT.ichargetype_ID in (89,1748,1682)
			INNER JOIN	Tenant T with (NOLOCK) ON RC.iTenant_ID = T. iTenant_ID AND T.dtRowDeleted is null AND RC.dtRowDeleted is null
			INNER JOIN	TenantState TS with (NOLOCK) ON TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted is null AND TS.iTenantStateCode_ID < 3 AND TS.iAptAddress_ID IS NOT NULL 
				  AND ts.iresidencytype_ID=1 
			INNER JOIN	House H	with (NOLOCK) ON H.iHouse_ID = T.iHouse_ID AND H.dtRowDeleted is null AND H.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			WHERE RC.dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.TipsMonth#">)
		</cfquery>

		<Cfreturn local.qFindMissingRecurring>
	</cffunction>

	<cffunction access="public" name="FindIncorrectRate" output="false" returntype="query" hint="I return a resultset of the incorrect rates">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true" hint="##SESSION.qSelectedHouse.iHouse_ID##">
		<cfargument name="tipsMonth" type="string" required="true" hint="##session.TipsMonth##">

		<cfquery name="local.qFindIncorrectRate" datasource="#arguments.datasource#">
			SELECT ts.iaptaddress_ID,ad.captnumber,h.cname,ts.itenant_ID, t.clastname +', '+ t.cfirstname as Residentname,t.csolomonkey,c.ioccupancyposition
			FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
			INNER JOIN house h with (NOLOCK) on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 
				  AND h.ihouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			INNER JOIN recurringcharge rc with (NOLOCK) on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null
				  AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.tipsMonth#">
			INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682) 
			INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null 
			INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
			INNER JOIN  (SELECT ts.iaptaddress_ID,ad.captnumber,h.cname,count(ts.iaptaddress_ID) as aptcnt
			FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
			INNER JOIN house h on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 AND h.ihouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			INNER JOIN recurringcharge rc with (NOLOCK) on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null 
				  AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.tipsMonth#">
			INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682) 
			INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null 
			INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
			WHERE  ts.itenantstatecode_ID=2
			GROUP BY ts.iaptaddress_ID, ad.captnumber,h.cname
				HAVING count(ts.iaptaddress_id)>1 AND count(distinct c.ioccupancyposition)=1) a
			ON ts.iaptaddress_ID=a.iaptaddress_ID
			WHERE ts.itenantstatecode_ID=2 

			Union

			SELECT ts.iaptaddress_ID ,ad.captnumber,h.cname,ts.itenant_ID, t.clastname +', '+ t.cfirstname as Residentname,t.csolomonkey,c.ioccupancyposition 
			FROM tenantstate ts  with (NOLOCK) 
			INNER JOIN tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
			INNER JOIN house h with (NOLOCK) on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 
				  AND h.ihouse_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			INNER JOIN recurringcharge rc with (NOLOCK) on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null 
				  AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.tipsMonth#">
			INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682) 
			INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null 
			INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
			LEFT JOIN (SELECT ts.iaptaddress_ID,ad.captnumber,h.cname,ts.itenant_ID, t.cfirstname,t.clastname,c.ioccupancyposition,rc.mamount,rc.cdescription
			FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
			INNER JOIN house h with (NOLOCK) on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 
				  AND h.ihouse_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			INNER JOIN recurringcharge rc on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.tipsMonth#">
			INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682) 
			INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null 
			INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
			WHERE ts.itenantstatecode_ID=2  AND c.iOccupancyposition= 1 AND ts.iresidencytype_ID=1) a
			ON ts.iaptaddress_ID=a.iaptaddress_ID
			WHERE  ts.itenantstatecode_ID=2 AND c.iOccupancyposition= 2 AND ts.iresidencytype_ID=1 AND a.itenant_ID is null		
		</cfquery>

		<cfreturn local.qFindIncorrectRate>
	</cffunction>

	<cffunction access="public" name="getTenantAddress" output="false" returntype="query" hint="I return a resultset of the tenant address">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">

		<cfquery name="local.qGetTenantAddress" datasource="#arguments.datasource#">
			SELECT	 ts.iaptaddress_ID 
			FROM Tenant T with (NOLOCK)
			INNER JOIN tenantstate ts with (NOLOCK) on ts.itenant_ID=t.itenant_ID AND ts.dtrowdeleted is null
			INNER JOIN House H with (NOLOCK) ON T.iHouse_ID = H.iHouse_ID AND H.dtRowDeleted IS NULL AND  T.dtRowDeleted IS NULL 
			AND T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer"  value="#arguments.tenantID#">
		</cfquery>

		<cfreturn local.qGetTenantAddress>
	</cffunction> 

	<cffunction access="public" name="FindChargeType" output="false" returntype="query" hint="I return a resultset of the charge types">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="chargeID" type="numeric" required="true">

		<cfquery name="local.qFindChargeType" datasource="#arguments.datasource#">
			SELECT iChargeType_ID 
			FROM charges with (NOLOCK) 
			WHERE icharge_ID=#form.iCharge_ID#
		</cfquery>

		<cfreturn local.qFindChargeType>
	</cffunction> 

	<cffunction access="public" name="findRoommates" output="false" returntype="query" hint="I return a resultset of the roommates" >
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true" hint="##form.iTenant_ID##">

		<cfquery name="local.qFindRoommates" datasource="#arguments.datasource#">
			SELECT *,at.iapttype_ID as apttype
			FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on ts.itenant_ID=t.itenant_ID
			INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID=ts.iaptaddress_id
			INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID
			LEFT JOIN recurringcharge r with (NOLOCK) on r.itenant_ID=t.itenant_ID AND r.dtRowDeleted is NULL
			LEFT JOIN charges c with (NOLOCK) on c.icharge_ID=r.icharge_ID AND c.dtRowDeleted is NULL  AND c.ichargetype_ID in (89,1682,1748,31,1749) 
			WHERE ts.iaptaddress_id=#qTenant.iAptAddress_ID# 
			AND ts.dtrowdeleted is null
			AND ts.dtchargethrough is null
			AND ts.itenantstatecode_ID=2
			AND ad.dtrowdeleted is null
			AND (at.biscompanionsuite = 0 or at.biscompanionsuite is null)
			AND ts.itenant_id != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">			
			ORDER by r.iRecurringCharge_ID DESC
		</cfquery>

		<cfreturn local.qFindRoommates>
	</cffunction> 

	<cffunction access="public" name="fiindOccupancyAdded" output="false" returntype="query" hint="I return a resultset of the charge being added" >
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="chargeID" type="numeric" required="true" hint="##Form.iCharge_ID##">

		<cfquery name="local.findoccupancyadded" datasource="#arguments.datasource#">
			SELECT * 
			FROM charges with (NOLOCK)
			WHERE icharge_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#argumetns.chargeID#">
		</cfquery>

		<cfreturn local.findoccupancyadded>
	</cffunction>

	<cffunction access="public" name="getInstallmentCharge" output="false" returntype="query" hint="I return a resultset of the installment charges">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true" hint="##CurrentRecurring.itenant_id##">

		<cfquery name="local.qGetInstallmentCharge" datasource="#arguments.datasource#">
			SELECT sum (mamount) as Accum
			FROM invoicedetail inv  WITH (NOLOCK)
			INNER JOIN invoicemaster im WITH (NOLOCK) on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
			WHERE   inv.dtrowdeleted is null  
			AND	itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND inv.ichargetype_id = 1741 
			AND im.bMoveOutInvoice is null
			AND im.bFinalized = 1
		</cfquery>

		<cfreturn local.qGetInstallmentCharge>
	</cffunction>
</cfcomponent>
