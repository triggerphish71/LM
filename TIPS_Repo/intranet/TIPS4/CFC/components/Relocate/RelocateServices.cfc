<cfcomponent displayname="Relocate" output="false">

	<cffunction access="public" name="getAvailable" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseID" required='true' type="numeric">

		<cfquery name="qAvailable" datasource="#arguments.datasource#">
			SELECT 	
				ad.iAptAddress_ID
				,ad.cAptNumber
				,ap.cDescription
				,c.cChargeSet
				,(SELECT count(t.itenant_id)
				  FROM tenantstate ts WITH (NOLOCK)
				  inner join tenant t  WITH (NOLOCK) on t.itenant_id = ts.itenant_id 	AND ts.dtrowdeleted is null
				  WHERE t.dtrowdeleted is null 
			      AND ts.iaptAddress_id = ad.iaptaddress_id 
				  AND ts.itenantstatecode_id = 2) as occupancy
				,c.*
	
				,AD.bIsBond
				,AD.bBondIncluded
				,AD.bIsMedicaidEligible
				,isnull(AD.bIsMemoryCareEligible,0) as bIsMemoryCareEligible
				,AP.bIscompanionsuite
			FROM APTADDRESS AD WITH (NOLOCK)
			INNER JOIN APTTYPE AP WITH (NOLOCK)	ON (AP.iAptType_ID = AD.iAptType_ID AND AP.dtRowDeleted IS NULL)
			INNER JOIN houseproductline HP WITH (NOLOCK) on HP.ihouseproductline_ID = AD.ihouseproductline_ID	AND HP.ihouse_ID = AD.ihouse_ID
			INNER JOIN charges c WITH (NOLOCK) 	on c.iapttype_id = ap.iapttype_id 	AND c.iproductline_ID = HP.iproductline_ID	AND c.dtrowdeleted is null 	AND getdate() between dteffectivestart AND dteffectiveend
			AND c.ihouse_id = ad.ihouse_id 
			AND c.iresidencytype_id = 1
			INNER join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id AND ct.dtrowdeleted is null 
			WHERE AD.dtRowDeleted IS NULL 
			AND ad.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
			ORDER BY ad.cAptNumber
		</cfquery>
		<cfreturn qAvailable>
	</cffunction>

	<cffunction access="public" name="getTenantList" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseID" required="true" type="numeric">
		<cfquery name="qGetTenantList" datasource="#arguments.datasource#">
			SELECT	distinct  count(distinct IM.iInvoiceMaster_ID) as moveoutcount
				,T.iTenant_ID ,T.cLastName ,T.cFirstName ,T.cSolomonKey, TS.iresidencytype_id
				,T.cChargeSet, T.bIsBond,TS.iproductline_ID,t.cbillingtype,t.ihouse_ID,t.bIsOriginalTenant
				,ts.iaptaddress_id 
				,h.bIsBundledPricing,CASE WHEN (apt.cDescription Like '%studio%') THEN 'Yes' ELSE 'No' END as isStudio				
			FROM	Tenant	T WITH (NOLOCK)
			INNER JOIN	TenantState	TS WITH (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID
			LEFT JOIN InvoiceDetail INV WITH (NOLOCK) ON (T.iTenant_ID = INV.iTenant_ID AND INV.dtRowDeleted IS NULL)
			LEFT JOIN InvoiceMaster IM WITH (NOLOCK) ON (IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NOT NULL)
			INNER JOIN House h WITH (NOLOCK) ON t.iHouse_ID= h.iHouse_ID
			INNER JOIN AptAddress aa WITH (NOLOCK) on ts.iAptAddress_ID = aa.iAptAddress_ID 
			INNER JOIN AptType apt WITH (NOLOCK) ON aa.iAptType_ID = apt.iAptType_ID
			WHERE T.dtRowDeleted IS NULL AND iTenantStateCode_ID = 2
			AND TS.dtMoveIN IS NOT NULL  AND t.iHouse_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
			GROUP BY T.cLastName, T.iTenant_ID, T.cFirstName, T.cSolomonKey, TS.iresidencytype_id,T.cChargeSet,T.bIsBond,TS.iproductline_ID,t.cbillingtype,t.ihouse_ID,t.bIsOriginalTenant,ts.iaptaddress_id
					,h.bIsBundledPricing ,apt.cDescription
			ORDER BY T.cLastName, T.iTenant_ID, T.cFirstName, T.cSolomonKey, TS.iresidencytype_id,ts.iaptaddress_id
		</cfquery>
		<cfreturn qGetTenantList>
	</cffunction>

	<cffunction access="public" name="getSecondRate" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseID" required="true" type="numeric">
		<cfquery name="qGetSecondRate" datasource="#arguments.datasource#">
			SELECT *
			FROM charges c WITH (NOLOCK)
			INNER JOIN chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id AND ct.dtrowdeleted is null 	AND bisrent is not null 
					AND c.ioccupancyposition <> 1
					AND c.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
			WHERE c.dtrowdeleted is null
			AND getdate() between c.dteffectivestart AND c.dteffectiveend
			AND c.ichargetype_ID = 89
		</cfquery>
		<cfreturn qGetSecondRate>
	</cffunction>

	<cffunction access="public" name="getSecondRateALMonthly" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseID" required="true" type="numeric">
		<cfquery name="qGetSecondRateALMonthly" datasource="#arguments.datasource#">
			SELECT *
			FROM charges c WITH (NOLOCK)
			INNER JOIN chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id AND ct.dtrowdeleted is null
				AND bisrent is not null 				
				AND c.ioccupancyposition <> 1
				AND c.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
			WHERE c.dtrowdeleted is null
			AND getdate() between c.dteffectivestart AND c.dteffectiveend
			AND c.ichargetype_ID = 1682
		</cfquery>
		<cfreturn qGetSecondRateALMonthly>
	</cffunction>

	<cffunction access="public" name="getSecondRateMC" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseID" required="true" type="numeric">
		<cfquery name="qGetSecondRateMC" datasource="#arguments.datasource#">
		    SELECT *
			FROM charges c WITH (NOLOCK)
			inner join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id AND ct.dtrowdeleted is null
					AND bisrent is not null 					
					AND c.ioccupancyposition <> 1
					AND c.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.HouseID#">
			WHERE c.dtrowdeleted is null
			AND getdate() between c.dteffectivestart AND c.dteffectiveend
			AND c.ichargetype_ID = 1748
		</cfquery>
		<cfreturn qGetSecondRateMC>
	</cffunction>

	<cffunction access="public" name="getRecurring" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfargument name="statecode" type="string" required="true">
		<cfquery name="qRecurring" datasource="#arguments.datasource#">
			SELECT rc.irecurringcharge_id, rc.itenant_id, rc.cdescription, rc.mamount, c.cChargeSet,rc.icharge_id, c.ioccupancyposition
			FROM recurringcharge rc WITH (NOLOCK)
			INNER JOIN tenant t (NOLOCK) on t.itenant_id = rc.itenant_id  AND t.dtrowdeleted is null
			INNER JOIN tenantstate ts (NOLOCK) on ts.itenant_id = t.itenant_id AND ts.dtrowdeleted is null AND ts.itenantstatecode_id = 2
			INNER JOIN charges c (NOLOCK) on c.icharge_id = rc.icharge_id
			INNER JOIN chargetype ct (NOLOCK) on ct.ichargetype_id = c.ichargetype_id	 <cfif arguments.statecode NEQ "WI">AND ct.bisrent is not null</cfif>
			WHERE rc.dtrowdeleted is null
			AND t.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND getdate() between rc.dteffectivestart AND rc.dteffectiveend
		</cfquery>
		<cfreturn qRecurring>
	</cffunction>

	<cffunction access="public" name="getStudioList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qStudioList" datasource="#arguments.datasource#">
			SELECT iAptAddress_ID
			FROM AptAddress ad  WITH (NOLOCK)
			INNER JOIN AptType apt  WITH (NOLOCK) on ad.iAptType_ID = apt.iAptType_ID
			INNER JOIN House h WITH (NOLOCK) on ad.iHouse_ID = h.iHouse_ID
			WHERE h.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND apt.cDescription like '%studio%'
		</cfquery>
		<cfreturn qStudioList>
	</cffunction>

	<cffunction access="public" name="getRoomANDBoard" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfargument name="dailyfilter" typee="string" required="true">
 		<cfquery name="qRoomANDBoard" datasource="#arguments.datasource#">
			SELECT c.icharge_id, c.cdescription, c.mAmount, c.iresidencytype_id,
				isNull(c.isleveltype_id,0) as isleveltype_id, c.iOccupancyPosition
			FROM charges c WITH (NOLOCK)
			INNER JOIN chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id AND ct.dtrowdeleted is null
			WHERE c.dtrowdeleted is null
			AND c.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND ct.bisrent is not null AND ct.bSLevelType_ID is null AND ct.bisdaily #arguments.dailyfilter#
			AND getdate() between c.dteffectivestart AND c.dteffectiveend
		</cfquery>
		<cfreturn qRoomAndBoard>
	</cffunction>

	<cffunction access="public" name="getHouseApts" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qGetHouseApts" datasource="#arguments.datasource#">
			SELECT aa.iaptaddress_id,aa.cAptNumber,aa.bisbond,aa.bbondincluded,aa.bIsMedicaidEligible,at.cdescription
			FROM aptaddress aa WITH (NOLOCK)
			INNER JOIN apttype at WITH (NOLOCK) on aa.iapttype_ID= at.iapttype_ID
			WHERE aa.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND aa .dtrowdeleted is null AND at.dtrowdeleted is null
			ORDER BY aa.cAptNumber
		</cfquery>
		<cfreturn qGetHouseApts>
	</cffunction>

	<cffunction access="public" name="getHouseAptBond" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qGetHouseAptBond" datasource="#arguments.datasource#">
			SELECT AA.iAptAddress_ID
			FROM AptAddress AA WITH (NOLOCK)
			WHERE AA.bIsBond = 1
			AND AA.dtrowdeleted is null
			AND AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qGetHouseAptBond>
	</cffunction>
	
	<cffunction access="public" name="getHouseAptBondIncluded" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qHouseAptBondIncluded" datasource="#arguments.datasource#">
			SELECT AA.iAptAddress_ID
			FROM AptAddress AA WITH (NOLOCK)
			WHERE AA.bBondIncluded = 1
			AND AA.dtrowdeleted is null
			AND AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qHouseAptBondIncluded>
	</cffunction>
	
	<cffunction access="public" name="getbAptCount" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qGetbAptCount" datasource="#arguments.datasource#">
			SELECT count(AA.iAptAddress_ID) as B
			FROM AptAddress AA WITH (NOLOCK)
			WHERE AA.bIsBond = 1
			AND AA.dtrowdeleted is null
			AND AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qGetbAptCount>
	</cffunction>

	<cffunction access="public" name="getBondAptCountTot" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetAptCountTot" datasource="#arguments.datasource#">
			SELECT count(AA.iAptAddress_ID) as T
			FROM AptAddress AA WITH (NOLOCK)
			WHERE AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND AA.bBondIncluded = 1
			AND AA.dtrowdeleted is null
		</cfquery>
		<cfreturn qgetAptCountTot>
	</cffunction>

	<cffunction access="public" name="getOccupied" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qGetOccupied" datasource="#arguments.datasource#">
			SELECT distinct TS.iAptAddress_ID
			FROM TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS (NOLOCK)
			INNER JOIN TIPS4.dbo.Tenant T on (T.iTenant_ID = TS.iTenant_ID AND T.dtRowDeleted is null)
			INNER JOIN TIPS4.dbo.AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID AND AD.dtRowDeleted is null)
			WHERE TS.dtRowDeleted is null
			AND TS.iTenantStateCode_ID = 2
			AND AD.iHouse_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND TS.iAptAddress_ID = aa.iAptAddress_ID
			AND te.iTenant_ID = ts.iTenant_ID
			AND aa.bBondIncluded = 1
		</cfquery>
		<cfreturn qGetOccupied>
	</cffunction>

	<cffunction access="public" name="getMedicaidAptList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetMedicaidAptList" datasource="#arguments.datasource#">
			SELECT aa.*,at1.*
			FROM AptAddress aa WITH (NOLOCK)
			INNER JOIN apttype at1 on at1.iAptType_ID = aa.iAptType_ID AND at1.dtrowdeleted is null
			WHERE aa.iHouse_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND aa.bIsMedicaidEligible = 1
			AND aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qgetMedicaidAptList>
	</cffunction>

	<cffunction access="public" name="getMedicaidbondApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetMedicaidbondApt" datasource="#arguments.datasource#">
			SELECT aa.*,at1.*
			FROM AptAddress aa WITH (NOLOCK)
			INNER JOIN apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID AND at1.dtrowdeleted is null
			WHERE aa.iHouse_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND aa.bIsMedicaidEligible = 1
			AND aa.bIsbond=1
			AND aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qgetMedicaidbondApt>
	</cffunction>

	<cffunction access="public" name="getMedicaidbondincludedApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetMedicaidbondincludedApt" datasource="#arguments.datasource#">
			SELECT aa.*,at1.*
			FROM AptAddress aa WITH (NOLOCK)
			INNER JOIN apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID AND at1.dtrowdeleted is null
			WHERE aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND aa.bIsMedicaidEligible = 1
			AND aa.bbondIncluded=1
			AND aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qgetMedicaidbondincludedApt>
	</cffunction>

	<cffunction access="public" name="getMedicaidAptCount" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetMedicaidAptCount" datasource="#arguments.datasource#">
			SELECT count(AA.iAptAddress_ID) as TotalMedicaidApt
			FROM AptAddress AA WITH (NOLOCK)
			WHERE AA.bIsMedicaidEligible = 1
			AND AA.dtrowdeleted is null
			AND AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qgetMedicaidAptCount>
	</cffunction>

	<cffunction access="public" name="getMedicaidAptCountTotal" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetMedicaidAptCountTotal" datasource="#arguments.datasource#">
			SELECT count(AA.iAptAddress_ID) as T
			FROM AptAddress AA WITH (NOLOCK)
			WHERE AA.iHouse_ID = <cfqueryparam cfsqltype="cf_Sql_intger" value="#arguments.houseid#">
			AND AA.dtrowdeleted is null
		</cfquery>
		<cfreturn qgetMedicaidAptCountTotal>
	</cffunction>

	<cffunction access="public" name="getOccupiedMedicaidApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetOccupiedMedicaidApt" datasource="#arguments.datasource#">
			SELECT distinct TS.iAptAddress_ID
			FROM TenantState TS WITH (NOLOCK)
			INNER JOIN Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID AND T.dtRowDeleted is null
			INNER JOIN AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID AND AD.dtRowDeleted is null
			WHERE TS.dtRowDeleted is null
			AND	TS.iTenantStateCode_ID = 2
			AND AD.Bismedicaideligible=1
			AND	AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qgetOccupiedMedicaidApt>
	</cffunction>

	<cffunction access="public" name="getMemCareAptList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetMemCareAptList" datasource="#arguments.datasource#">
			SELECT aa.*,at1.*
			FROM AptAddress aa WITH (NOLOCK)
			INNER JOIN apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID AND at1.dtrowdeleted is null
			WHERE aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND aa.bIsmemorycareeligible = 1
			AND aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qgetMemCareAptList>
	</cffunction>

	<cffunction access="public" name="getOccupiedMemcareApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetOccupiedMemcareApt" datasource="#arguments.datasource#">
			SELECT distinct TS.iAptAddress_ID
			FROM TenantState TS WITH (NOLOCK)
			INNER JOIN Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID AND T.dtRowDeleted is null
			INNER JOIN AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID
			AND AD.dtRowDeleted is null
			WHERE TS.dtRowDeleted is null
			AND	TS.iTenantStateCode_ID = 2
			AND AD.bIsMemoryCareEligible=1
			AND	AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qgetOccupiedMemcareApt>
	</cffunction>

	<cffunction access="public" name="getBondHouse" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseid" type="numeric" required="true">
		<cfquery name="qgetBondHouse" datasource="#arguments.datasource#">
			SELECT * 
			FROM house WITH (NOLOCK)  
			WHERE ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
		</cfquery>
		<cfreturn qgetBondHouse>
	</cffunction>


<!--- RELOCATE UPDATE FUNCTIONS START HERE --->

	<cffunction access="public" name="getChangeRoomDate" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qGetChangeRoomDate" datasource="#arguments.datasource#">
			SELECT MAX (dtActualEffective) AS ActualEffectivedt 
	 		FROM activitylog WITH (NOLOCK)
			WHERE itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
		<cfreturn qGetChangeRoomDate>
	</cffunction>

	<cffunction access="public" name="getDate" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">		
		<cfquery name="qGetDate" datasource="#arguments.datasource#">
			SELECT	GetDate() as Stamp
		</cfquery>
		<cfreturn qGetDate>
	</cffunction>

	<cffunction access="public" name="getTenant" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qGetTenant" datasource="#arguments.datasource#">
			SELECT	*
			FROM Tenant T WITH (NOLOCK)
			INNER JOIN TenantState TS WITH (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID
			WHERE T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND T.dtRowDeleted IS NULL 
			AND TS.dtRowDeleted IS NULL
		</cfquery>
		<cfreturn qGetTenant>
	</cffunction>

	<cffunction access="public" name="getMoveInDate" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qGetMoveInDate" datasource="#arguments.datasource#">
			SELECT	dtMoveIn 
			FROM TenantState WITH (NOLOCK) 
			WHERE dtRowDeleted IS NULL 
			AND iTenant_ID =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
		<cfreturn qGetMoveInDate>
	</cffunction>


	<cffunction access="public" name="getBondIncludedAptCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qGetBondIncludedAptCheck" datasource="#arguments.datasource#">
			select ad.bBondIncluded 
			from AptAddress ad  WITH (NOLOCK)
			where ad.iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfreturn qGetBondIncludedAptCheck>
	</cffunction>

	<cffunction access="public" name="getCurrentAptType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qgetCurrentAptType" datasource="#arguments.datasource#">
			Select	 b.bIscompanionSuite			           
			from 	 aptaddress a WITH (NOLOCK)
			INNER JOIN apttype b WITH (NOLOCK) ON a.iAptType_ID=b.iAptType_ID
			where a.iAPTAddress_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfreturn qgetCurrentAptType>
	</cffunction>

	<cffunction access="public" name="getSelectAptType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qgetSelectAptType" datasource="#arguments.datasource#">
			Select	 b.bIscompanionSuite
			from  aptaddress a WITH (NOLOCK) 
			INNER JOIN apttype b WITH (NOLOCK) on  a.iAptType_ID=b.iAptType_ID
			where a.iAPTAddress_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">			
		</cfquery>
		<cfreturn qgetSelectAptType>
	</cffunction>

	<cffunction access="public" name="getCheckbundled" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qCheckBundled" datasource="#arguments.datasource#">
			select bIsBundled
			FROM TenantState WITH (NOLOCK)
			where iTenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">			
		</cfquery>
		<cfreturn qCheckBundled>
	</cffunction>

	<cffunction access="public" name="updAptRelocate" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			UPDATE	APTLOG
			SET	iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.AptAddressID#">,
				dtActualEffective = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.theData.dtActualEffective#">,
				iRowStartUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.UserID#">,
				dtRowStart = <cfqueryparam cfsqltype="cf_sql_timestamp" value="#arguments.theData.dtRowStart#">
			WHERE	iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.tenantID#">			
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="updTenantStateChange" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="AddressID" type="numeric" required="true">
		<cfargument name="UserID" type="numeric" required="true">
		<cfargument name="dtRowStart" type="date" required="true">
		<cfargument name="cBIsCompanion" type="numeric" required="true">
		<cfargument name="sBIsCompanion" type="numeric" required="true">
		<cfargument name="dtSwitchDate" type="date" required="true">
		<cfargument name="hasBP" type="string" required="true">
		<cfargument name="cBundled" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">

		<cfquery name="q" datasource="#arguments.datasource#">
			UPDATE	TENANTSTATE
			SET	iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AddressID#">,			
				iRowStartUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">,
				dtRowStart = <cfqueryparam cfsqltype="cf_sql_time" value="#arguments.dtRowStart#">,
				cBondHouseEligibleAfterRelocate = 1
				<cfif arguments.hasBP EQ "">
					,bIsBundled = NULL
				<cfelse>
					<cfif arguments.hasBP EQ 1 AND arguments.cBundled EQ 1>
					,bIsBundled = 1
					<cfelse>
					,bIsBundled = 0
					</cfif>
				</cfif>
				<cfif arguments.cBIsCompanion EQ 1 AND arguments.sBIsCompanion EQ 0>
					,dtCompanionToFullSwitch=<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dtSwitchDate#">
				</cfif>
				<cfif arguments.cBIsCompanion EQ 0 AND arguments.sBIsCompanion EQ 1>
					,dtFulltoCompanionSwitch = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dtSwitchDate#">
				</cfif>
				WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="getCompanionSwitchchk" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qCompanionSwitchchk" datasource="#arguments.datasource#">
			SELECT dtCompanionToFullSwitch, dtFulltoCompanionSwitch,itenantState_ID,iTenant_ID  
			FROM TenantState WITH (NOLOCK)	
	 		WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfreturn qCompanionSwitchchk>
	</cffunction>

	<cffunction access="public" name="updCompanionSwitch" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qupdCompanionSwitch" datasource="#arguments.datasource#">
			UPDATE TenantState
			SET dtCompanionToFullSwitch = null ,  
				dtFulltoCompanionSwitch = null
			WHERE itenantState_ID= 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND dtCompanionToFullSwitch is not null 
			AND dtFulltoCompanionSwitch is not null
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="insWriteActivity" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="activityID" type="numeric" required="true">
		<cfargument name="actualEffective" type="date" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="houseid" type="numeric" required="true">
		<cfargument name="AptAddressID" type="numeric" required="true">
		<cfargument name="points" type="numeric" required="true">
		<cfargument name="acctstamp" type="date" required="true">
		<cfargument name="userid" type="numeric" required="true">
		<cfargument name="dt" type="date" required="true">		
		<cfquery name="qInsWriteActivity" datasource="#arguments.datasource#">
			INSERT INTO ActivityLog(iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints, dtAcctStamp, iRowStartUser_ID, dtRowStart)
			VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.activityID#">,
				<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.actualEffective#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AptAddressID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.points#">,
				<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.acctstamp#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">,
				<cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dt#">
			)	
		</cfquery>	
	</cffunction>

	<cffunction access="public" name="getRelocatingtenantoccupancy" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qRelocatingtenantoccupancy" datasource="#arguments.datasource#">
			Select c.ioccupancyposition,r.iRecurringCharge_ID,t.dtrenteffective
			from tenantstate t WITH (NOLOCK)
			INNER JOIN	recurringcharge r WITH (NOLOCK) ON t.itenant_ID=r.itenant_ID 
			INNER JOIN  charges c WITH (NOLOCK) ON  r.Icharge_ID=c.Icharge_ID
			where c.ioccupancyposition is not Null
			AND r.dtRowDeleted is NULL
			AND c.dtRowDeleted is NULL
			AND t.itenant_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			order by r.iRecurringCharge_ID DESC			
		</cfquery>
		<cfreturn qRelocatingtenantoccupancy>
	</cffunction>

	<cffunction access="public" name="getCheckifChargeThroughDtExists" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qCheckifChargeThroughDtExists" datasource="#arguments.datasource#">
			select ISNULL(max(dtchargethrough),getdate()) as dtChargeThrough
			FROM TenantState
			where iAptaddress_ID = 	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">		
		</cfquery>
		<cfreturn qCheckifChargeThroughDtExists>
	</cffunction>

	<cffunction access="public" name="getNewOccupancyofRelocatingTenant" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qNewOccupancyofRelocatingTenant" datasource="#arguments.datasource#">
			Select * 
			from charges WITH (NOLOCK) 
			where icharge_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfreturn qNewOccupancyofRelocatingTenant>
	</cffunction>

	<cffunction access="public" name="getSerachTenantAdrressID" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="AddressID" type="numeric" required="true">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qSerachTenantAdrressID" datasource="#arguments.datasource#">
			Select *
			from tenantstate WITH (NOLOCK)
			where iaptaddress_id= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AddressID#">
			AND dtrowdeleted is null
			AND dtchargethrough is null
			AND itenantstatecode_ID=2
			AND itenant_ID != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">		
		</cfquery>
		<cfreturn qSerachTenantAdrressID>
	</cffunction>

	<cffunction access="public" name="updSecondarySwitchDatenull" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qSecondarySwitchDatenull" datasource="#arguments.datasource#">
			UPDATE tenantstate
			set dtsecondaryswitchdate = null
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>	
	</cffunction>

	<cffunction access="public" name="getSerachTenantPreviousAdrressID" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="AddressID" type="numeric" required="true">
		<cfquery name="qSerachTenantPreviousAdrressID" datasource="#arguments.datasource#">
			Select * from 
			tenantstate t WITH (NOLOCK) 
			INNER JOIN recurringcharge r WITH (NOLOCK) ON t.itenant_ID=r.itenant_ID
			INNER JOIN charges c WITH (NOLOCK) ON r.Icharge_ID=c.Icharge_ID
			where c.ioccupancyposition=2
			AND r.dtRowDeleted is NULL
			AND c.dtRowDeleted is NULL
			AND t.itenant_ID != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND t.iaptaddress_id= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AddressID#">
			AND t.dtrowdeleted is null
			AND t.dtchargethrough is null
			AND t.itenantstatecode_ID=2
			order by r.iRecurringCharge_ID DESC		
		</cfquery>
		<cfreturn qSerachTenantPreviousAdrressID>
	</cffunction>

	<cffunction access="public" name="getUpdatesecondarySwitchDateforsecondary" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="dt" type="date" required="true">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qUpdatesecondarySwitchDateforsecondary" datasource="#arguments.datasource#">
			UPDATE tenantstate
			set dtsecondaryswitchdate = <cfqueryparam cfsqltype="date" value="#arguments.dt#">
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">	
		</cfquery>		
	</cffunction>
	<cffunction access="public" name="getCheckSwitch" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qCheckSwitch" datasource="#arguments.datasource#">
			SELECT dtsecondaryswitchdate
			FROM tenantState WITH (NOLOCK)
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfreturn qCheckSwitch>
	</cffunction>


	<cffunction access="public" name="getTenantOccupancyBeforeFirstMove" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qTenantOccupancyBeforeFirstMove" datasource="#arguments.datasource#">
			Select top 1  t.itenant_id , r.icharge_id , c.ioccupancyposition, r.dtRowStart 
			from  tenantstate t WITH (NOLOCK) 
			INNER JOIN	p_recurringcharge r WITH (NOLOCK) ON t.itenant_ID=r.itenant_ID
			INNER JOIN	charges c WITH (NOLOCK) ON r.Icharge_ID=c.Icharge_ID
			WHERE c.ioccupancyposition is not Null
			AND r.dtRowDeleted is NULL
			AND c.dtRowDeleted is NULL
			AND t.itenant_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND r.dtRowStart NOT IN (select MAX (r.dtRowStart) 
									 from tenantstate t WITH (NOLOCK)
									 INNER JOIN p_recurringcharge r WITH (NOLOCK) ON t.itenant_ID=r.itenant_ID
									 INNER JOIN charges c WITH (NOLOCK) ON r.Icharge_ID=c.Icharge_ID
									 where c.ioccupancyposition is not Null
									 AND r.dtRowDeleted is NULL
									 AND c.dtRowDeleted is NULL
									 AND t.itenant_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">)
			order by dtRowStart asc			
		</cfquery>
		<cfreturn qTenantOccupancyBeforeFirstMove>
	</cffunction>

	<cffunction access="public" name="updSSD" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="updSSD" datasource="#arguments.datasource#">
			UPDATE tenantstate
			SET dtsecondaryswitchdate = null
			WHERE itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>	
	</cffunction>

	<!---- start of the new charges AND proration for R&B --->

	<cffunction access="public" name="getChargeType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="TenantMedicaid" type="string" required="true">
		<cfquery name="qChargeType" datasource="#arguments.datasource#">
			SELECT  ct.IChargeType_ID
			FROM  InvoiceDetail inv WITH (NOLOCK)
			INNER JOIN Tenant t WITH (NOLOCK) ON t.iTenant_ID = inv.iTenant_ID AND t.dtRowDeleted IS NULL 
			INNER JOIN TenantState ts WITH (NOLOCK) ON ts.iTenant_ID = t.iTenant_ID AND ts.dtRowDeleted IS NULL 
			INNER JOIN InvoiceMaster im WITH (NOLOCK) ON im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID AND im.dtRowDeleted IS NULL AND im.bMoveInInvoice IS NULL AND im.bMoveOutInvoice IS NULL AND im.bFinalized IS NULL 
	        INNER JOIN ChargeType ct WITH (NOLOCK) ON ct.iChargeType_ID = inv.iChargeType_ID AND ct.dtRowDeleted IS NULL AND ct.bIsRent IS NOT NULL AND ct.bIsDiscount IS NULL AND ct.bIsRentAdjustment IS NULL AND ct.bSLevelType_ID IS NULL
			WHERE (inv.dtRowDeleted IS NULL) 
			AND (inv.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">) 
			AND (ct.bIsMedicaid #arguments.TenantMedicaid#)
			ORDER BY inv.iInvoiceDetail_ID DESC			
		</cfquery>
		<cfreturn qChargeType>
	</cffunction>

	<cffunction access="public" name="getMostRecentInvoiceDetail" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="ChargeTypeID" type="numeric" required="true">
		<cfquery name="qMostRecentInvoiceDetail" datasource="#arguments.datasource#">
			SELECT inv.iInvoiceDetail_ID, inv.iQuantity,inv.iInvoicemaster_ID
			FROM InvoiceDetail inv WITH (NOLOCK) 
			INNER JOIN invoicemaster im WITH (NOLOCK) on im.iinvoicemaster_ID=inv.iinvoicemaster_ID
			WHERE inv.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND inv.iChargeType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.chargeTypeID#">
			AND inv.dtRowDeleted is NULL 
			AND im.dtrowdeleted is null
			ORDER BY iInvoiceDetail_ID DESC
		</cfquery>
		<cfreturn qMostRecentInvoiceDetail>
	</cffunction>

	<cffunction access="public" name="getMostRecentInvoiceMaster" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qMostRecentInvoiceMaster" datasource="#arguments.datasource#">
			SELECT InvoiceDetail.iInvoiceDetail_ID, InvoiceMaster.iInvoiceMaster_ID 
			FROM InvoiceDetail WITH  (NOLOCK)
			INNER JOIN InvoiceMaster WITH (NOLOCK) ON InvoiceDetail.iInvoiceMaster_ID = InvoiceMaster.iInvoiceMaster_ID
			WHERE InvoiceDetail.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND Invoicemaster.dtrowdeleted is null
			ORDER BY InvoiceMaster.iInvoiceMaster_ID DESC			
		</cfquery>
		<cfreturn qMostRecentInvoiceMaster>
	</cffunction>


	<cffunction access="public" name="GetMostRecentLOCcharges" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qMostRecentLOCcharges" datasource="#arguments.datasource#">
			SELECT * 
			FROM InvoiceDetail WITH (NOLOCK)
			INNER JOIN InvoiceMaster WITH (NOLOCK) ON InvoiceDetail.iInvoiceMaster_ID = InvoiceMaster.iInvoiceMaster_ID
			WHERE InvoiceDetail.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#"> 
			AND InvoiceDetail.ichargetype_ID= 91
			ORDER BY InvoiceMaster.iInvoiceMaster_ID DESC			
		</cfquery>
		<cfreturn qMostRecentLOCcharges>
	</cffunction>

	<cffunction access="public" name="GetOldReccuringCharge" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="chargeTypeID" type="numeric" required="true">
		<cfquery name="qOldReccuringCharge" datasource="#arguments.datasource#">
			SELECT RecurringCharge.iRecurringCharge_ID AS RecCharge, RecurringCharge.mAmount as RCmAmount, Charges.*
			FROM RecurringCharge WITH (NOLOCK)
			INNER JOIN Charges WITH (NOLOCK) ON RecurringCharge.iCharge_ID = Charges.iCharge_ID AND Charges.dtRowDeleted is NULL
			INNER JOIN ChargeType WITH (NOLOCK) ON Charges.iChargeType_ID = ChargeType.iChargeType_ID AND ChargeType.dtRowDeleted is NULL
			WHERE RecurringCharge.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#"> 
			AND RecurringCharge.dtRowDeleted is NULL
			AND ChargeType.iChargeType_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.chargeTypeID#">
			ORDER BY iRecurringCharge_ID DESC			
		</cfquery>
		<cfreturn qOldReccuringCharge>
	</cffunction>

	<cffunction access="public" name="getRoomDescription" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="AddressID" type="numeric" required="true">
		<cfquery name="qRoomDescription" datasource="#arguments.datasource#">
			select cDescription 
			from AptType WITH (NOLOCK) 
			inner join AptAddress WITH (NOLOCK) ON AptAddress.iAptType_ID = AptType.iAptType_ID
			where AptAddress.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#"> 
			AND AptAddress.iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.AddressID#">			
		</cfquery>
		<cfreturn qRoomDescription>
	</cffunction>

	<cffunction access="public" name="getCheckForPreInvoice" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="relocationdt" type="string" required="true">
		<cfargument name="chargeTypeID" type="numeric" required="true">
		<cfquery name="qcheckForPreInvoice" datasource="#arguments.datasource#">
			Select * 
			from invoicedetail inv with (NOLOCK)
			join invoicemaster im WITH (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID AND inv.dtrowdeleted is null AND im.dtrowdeleted is null
			AND inv.itenant_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND inv.cappliestoacctperiod= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.relocationdt#">
			<cfif arguments.chargeTypeID NEQ 0>
				AND inv.ichargetype_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.chargeTypeID#">			
			</cfif>
		</cfquery>
		<cfreturn qcheckForPreInvoice>
	</cffunction>

	<cffunction access="public" name="addNewInvoiceDetail" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			INSERT INTO InvoiceDetail (iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, iDaysBilled)
			VALUES(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.InvoiceMasterID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.tenantID#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.chargeTypeID#">,
				<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.theData.acctperiod#">,
				NULL,
				getdate(),
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.qty#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.desc#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.amt#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.comments#" null="#IIF(len(arguments.theData.comments) EQ 0,true,false)#">,
				<cfqueryparam cfsqltype="cf_sql_time" value="#arguments.theData.acctstamp#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.userid#">,
				<cfqueryparam cfsqltype="cf_sql_time" value="#arguments.theData.timestamp#">,
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.daysBilled#">
			)			
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="getCheckForPreInvoiceLoc" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="acctperiod" type="string" required="true">
		<cfquery name="qCheckForPreInvoiceLOC" datasource="#arguments.datasource#">
			SELECT * 
			from invoicedetail inv WITH (NOLOCK)
			INNER JOIN invoicemaster im WITH (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID AND inv.dtrowdeleted is null AND im.dtrowdeleted is null
			AND inv.itenant_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			AND inv.cappliestoacctperiod= <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.acctPeriod#">
			AND inv.ichargetype_ID= 91			
		</cfquery>
		<cfreturn qCheckForPreInvoiceLOC>
	</cffunction>


	<cffunction access="public" name="updDeleteOldReccuringCharge" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="dt" type="date" required="true">
		<cfargument name="userid" type="numeric" required="true">
		<cfargument name="rcID" type="numeric" required="true">
		<cfquery name="qupdDeleteOldReccuringCharge" datasource="#arguments.datasource#">
			UPDATE RecurringCharge
			SET dtRowDeleted = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.dt#">, 
			iRowDeletedUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">, 
			dtEffectiveEnd = getdate()
			WHERE RecurringCharge.iRecurringCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.rcID#">			
		</cfquery>
	</cffunction>

	<cffunction access="public" name="FindNewChargeDescription" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="qFindNewChargeDescription" datasource="#arguments.datasource#">
			  SELECT * 
			  FROM charges WITH (NOLOCK) 
			  where icharge_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>
		<cfreturn qFindNewChargeDescription>
	</cffunction>

	<cffunction access="public" name="inNewRecurringCharges" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="RCData" type="struct" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			INSERT INTO RecurringCharge(iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
			VALUES(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.RCData.tenantID#">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.RCData.chargeID#">,
				   <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(Now())#">,
			 	   <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('yyyy',10,CreateODBCDateTime(now()))#">,			 	
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.RCData.qty#">,
				   <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.RCData.desc#">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.RCData.amt#">,
				   <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.RCData.comment#">,
				   <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.RCData.acctStamp#">,
				   <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.RCData.userid#">,
				   <cfqueryparam cfsqltype="cf_sql_timestamp" value="#CreateODBCDateTime(Now())#">
			)
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getNewRecurringCharge" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfargument name="comments" type="string" required="true">
		<cfquery name="qNewRecurringCharge" datasource="#arguments.datasource#">
			SELECT irecurringcharge_ID 
			FROM recurringcharge WITH (NOLOCK) 
			WHERE  iTenant_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
			and ccomments=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.comments#">
			and dtrowdeleted is null			
		</cfquery>
		<cfreturn qNewRecurringCharge>
	</cffunction>

	<cffunction access="public" name="updInvoiceDetail" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="UpdateInvoiceDetail" datasource="#arguments.datasource#">
			UPDATE InvoiceDetail 
			SET  mAmount = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.amt#">,
				cDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.desc#">,
				irecurringcharge_id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.recurringChargeID#">,
				iDaysBilled=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.daysBilled#">,
				iQuantity = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.qty#">,
				iChargeType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.chargeTypeID#">
			WHERE iInvoiceDetail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.invoiceDetailID#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="updInvoiceDetailMC" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			UPDATE InvoiceDetail 
			SET ichargetype_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.chargetypeID#">,
			    iquantity=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.qty#">,
			    mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.theData.amt#">,
			    cDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.desc#">,
			    irecurringcharge_id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.recurringChargeID#">,
			    iDaysBilled=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.daysbilled#">
			WHERE iInvoiceDetail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.invoiceDetailID#">
		</cfquery>			
	</cffunction>

	<cffunction access="public" name="updInvoiceDetailMC2" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			UPDATE InvoiceDetail 
			SET dtrowdeleted= getdate()
			WHERE iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.invoiceMasterID#">,
			and ichargetype_ID=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.chargeTypeID#">
			and mamount > 0		
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="updTenantBondStatus" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="bIsBond" type="numeric" required="true">
		<cfargument name="bondCert" type="date" required="true">
		<cfargument name="userID" type="string" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			update tenant
			set bIsBond = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.bIsBond#">,
			dtBondCert = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.bondCert#">, 
			cRowEndUser_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.userID#">
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getTenantBCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			SELECT bIsBond 
			FROM tenant WITH (NOLOCK) 
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">			
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction access="public" name="getRoomBCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			SELECT bBondIncluded 
			FROM aptaddress  WITH (NOLOCK)
			WHERE iAptAddress_ID =	<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">		
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction access="public" name="updTurnRoomBond" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="bIsBond" type="numeric" required="true">
		<cfargument name="userid" type="string" required="true">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			UPDATE APTADDRESS
			SET bIsBond =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.bIsBond#">, 
			cRowEndUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
			WHERE iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>	
	</cffunction>

	<cffunction access="public" name="getCurrentRoomCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			Select ad.bismemorycareeligible,ts.iproductline_ID 
			from tenantstate ts WITH (NOLOCK) 
			INNER JOIN aptaddress ad WITH (NOLOCK) on ts.iaptaddress_ID=ad.iaptaddress_ID
            where ts.itenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#"> 			
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction access="public" name="getMemorycareroomcheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			select bismemorycareeligible 
			from aptaddress WITH (NOLOCK) 
			where iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">			
		</cfquery>
		<cfreturn q>
	</cffunction>

	<cffunction access="public" name="updTenantState" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="mtswitch" required="true">
		<cfargument name="productlineid" type="numeric" required="true">
		<cfargument name="tenantid" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			update tenantstate
			set 
			<cfif #arguments.MCSwitch# Neq ''>
			dtMCSwitch = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.mtswitch#">,
			</cfif>
			iProductline_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.productlineid#">
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantid#">			
		</cfquery>	
	</cffunction>

	<cffunction access="public" name="updTenant" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="bType" type="string" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">	
			update tenant
			set cBillingtype = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.btype#">            
			WHERE iTenant_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
	    </cfquery>	
	</cffunction>


	<cffunction access="public" name="getSubAccount" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="numeric" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			select hpl.cglsubaccount 
			From Tenant t WITH (NOLOCK) 
			INNER JOIN tenantstate ts WITH (NOLOCK) on t.itenant_id = ts.itenant_id and ts.dtrowdeleted is null
			INNER JOIN houseproductline hpl WITH (NOLOCK) on hpl.iproductline_id = ts.iproductline_id and hpl.dtrowdeleted is null and hpl.ihouse_id = t.ihouse_id
			where t.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">			
		</cfquery>
		<cfreturn q>
	</cffunction>
	<cffunction access="public" name="getSLDetails" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="string" required="true">
		<cfquery name="q" datasource="#arguments.datasource#">
			SELECT name, SlsSub 
			FROM customer WITH (NOLOCK) 
			WHERE custID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.ID#">			
		</cfquery>
		<cfreturn q>
	</cffunction>
	<cffunction access="public" name="getCustImport" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="ID" type="string" required="true">
		<cfargument name="fname" type="string" required="true">
		<cfargument name="subacct" type="string" required="true">
		<cfargument name="userid" type="string" required="true">
		<cfstoredproc procedure="dbo.tsp_tenantAccountUpdate" datasource="#arguments.datasource#" result="qCustImport">
		 <cfprocparam cfsqltype="cf_sql_char" value="#arguments.id#" dbvarname="@cTenantID" type="in">
		 <cfprocparam cfsqltype="cf_sql_char" value="#arguments.fname#" dbvarname="@FName" type="in">
		 <cfprocparam cfsqltype="cf_sql_char" value="#arguments.subacct#" dbvarname="@SubAccount" type="in">
		 <cfprocparam cfsqltype="cf_sql_char" value="#arguments.userid#" dbvarname="@userID" type="in">		
		</cfstoredproc>		
	</cffunction>

	<cffunction access="public" name="updMCtoALDate" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="switchDT" type="date" required="true">
		<cfquery name="qUpdMC2AL" datasource="#arguments.datasource#">
			UPDATE tenantState
			set dtMC2ALSwitch = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.switchDT#">,
			bMC2AL = 0
			WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getLOCData" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="id" type="numeric" required="true">
		<cfquery name="qGetLOCData" datasource="#arguments.datasource#">
			SELECT c.cdescription,c.mamount,c.iChargeType_ID,t.itenant_id, ts.iSPoints, im.iInvoiceMaster_ID
			FROM charges c WITH (NOLOCK)
			INNER JOIN tenant t WITH (NOLOCK) on  c.iHouse_id = t.iHouse_Id and c.cChargeSet = t.cChargeSet 
			INNER JOIN tenantState ts WITH (NOLOCK) on t.iTenant_id = ts.iTenant_id 
			INNER JOIN sLevelType sl WITH (NOLOCK) ON c.iSLevelType_ID = sl.iSLevelType_ID  and ts.iSPoints BETWEEN sl.iSPointsMin AND sl.iSPointsMax
			INNER JOIN InvoiceMaster im WITH (NOLOCK) ON t.cSolomonKey = im.cSolomonKey AND im.bFinalized IS NULL
			WHERE getDate() BETWEEN c.dtEffectiveStart AND c.dtEffectiveEnd
			AND t.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
		</cfquery>
		<cfreturn qGetLOCData>
	</cffunction>
</cfcomponent>
