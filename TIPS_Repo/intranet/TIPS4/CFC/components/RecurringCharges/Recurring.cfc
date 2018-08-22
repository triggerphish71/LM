<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////
Author:           Hans Lim
Date Created:     8/20/2018
Files Associated: /TIPS/RecurringCharges/Recurring.cfm
///////////////////////////////////////////////////////////////////////////////////////////////////////// --->
<cfcomponent displayname="Recurring Charges" output="false" hint="Recurring Charges">


  <!--- start: getHouseChargeset --->
  <cffunction access="public" name="getHouseChargeset" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iHouse_ID" type="numeric" required="true">
    <cfquery name="getHouseChargeset" datasource="#arguments.datasource#">
    SELECT  cs.CName
    FROM house h WITH (NOLOCK)
    INNER JOIN chargeset cs with (NOLOCK) ON cs.iChargeSet_ID = h.iChargeSet_ID
    WHERE ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
    AND h.dtrowdeleted is null
    </cfquery>
    <cfreturn getHouseChargeset>
  </cffunction>
  <!--- end: getHouseChargeset --->


  <!--- start: qryRegion --->
  <cffunction access="public" name="qryRegion" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iHouse_ID" type="numeric" required="true">
    <cfquery name="qryRegion" datasource="#arguments.datasource#">
    SELECT h.cname as house, ops.cname as region, reg.cname as division
  	FROM house h with (NOLOCK)
  	INNER JOIN opsarea ops with (NOLOCK) on h.iopsarea_id = ops.iopsarea_id
  	INNER JOIN region reg with (NOLOCK) on ops.iregion_id = reg.iregion_id
  	WHERE h.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
    </cfquery>
    <cfreturn qryRegion>
  </cffunction>
  <!--- end: qryRegion --->


  <!--- start: TenantList --->
  <cffunction access="public" name="TenantList" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iTenant_ID" type="numeric" required="true">
    <cfargument name="iHouse_ID" type="numeric" required="false" default="#SESSION.qSelectedHouse.iHouse_ID#">
    <cfquery name="TenantList" datasource="#arguments.datasource#">
    SELECT *
  	FROM tenant t (nolock)
  	INNER JOIN tenantstate ts (nolock) on (t.iTenant_ID = ts.iTenant_ID AND t.dtRowDeleted is null)	AND ts.iTenantStateCode_ID = 2 AND ts.iResidencyType_ID <> 3
  			   AND t.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
  	INNER JOIN AptAddress ad (nolock) on (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted is null)
  	WHERE ts.iAptAddress_ID is not null
  	<CFIF arguments.iTenant_ID NEQ 0> AND T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iTenant_ID#"></CFIF>
  	ORDER BY T.cLastName
    </cfquery>
    <cfreturn TenantList>
  </cffunction>
  <!--- end: TenantList --->


  <!--- start: FindMissingRecurring --->
  <cffunction access="public" name="FindMissingRecurring" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iHouse_ID" type="numeric" required="false" default="#SESSION.qSelectedHouse.iHouse_ID#">
    <cfargument name="TIPSMonth" type="string" required="false" default="#SESSION.TIPSMonth#">
    <cfquery name="FindMissingRecurring" datasource="#arguments.datasource#">
    SELECT t.cfirstname+', '+t.clastname as Residentname,t.csolomonkey, t.ihouse_ID
    FROM tenant t with (NOLOCK)
    INNER JOIN tenantstate ts with (NOLOCK) on ts.itenant_ID =t.itenant_ID
    WHERE ts.itenantstatecode_ID=2
    AND t.ihouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
    AND t.dtrowdeleted is null AND ts.dtrowdeleted is null AND ts.iresidencytype_ID=1
    AND t.itenant_ID not in
    (
      SELECT	rc.itenant_ID
      FROM	RecurringCharge RC with (NOLOCK)
      INNER JOIN	Charges C with (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID AND C.dtRowDeleted is null
      INNER JOIN 	ChargeType CT with (NOLOCK) ON CT.ichargetype_id = C.iChargeType_ID AND CT.dtrowdeleted is null AND CT.ichargetype_ID in (89,1748,1682)
      INNER JOIN	Tenant T with (NOLOCK) ON RC.iTenant_ID = T. iTenant_ID AND T.dtRowDeleted is null AND RC.dtRowDeleted is null
      INNER JOIN	TenantState TS with (NOLOCK) ON TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted is null AND TS.iTenantStateCode_ID < 3 AND TS.iAptAddress_ID IS NOT NULL AND ts.iresidencytype_ID=1
      INNER JOIN	House H	with (NOLOCK) ON H.iHouse_ID = T.iHouse_ID AND H.dtRowDeleted is null AND H.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
      WHERE	RC.dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TIPSMonth#">
    )
    </cfquery>
    <cfreturn FindMissingRecurring>
  </cffunction>
  <!--- end: FindMissingRecurring --->


  <!--- start: Findincorrectrate --->
  <cffunction access="public" name="Findincorrectrate" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="TIPSMonth" type="string" required="false" default="#SESSION.TIPSMonth#">
    <cfargument name="iHouse_ID" type="numeric" required="false" default="#SESSION.qSelectedHouse.iHouse_ID#">
    <cfquery name="Findincorrectrate" datasource="#arguments.datasource#">
    SELECT
    ts.iaptaddress_ID,ad.captnumber,h.cname,ts.itenant_ID, t.clastname +', '+ t.cfirstname as Residentname,t.csolomonkey,c.ioccupancyposition
  	FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
  	INNER JOIN house h with (NOLOCK) on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 AND h.ihouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
  	INNER JOIN recurringcharge rc with (NOLOCK) on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TIPSMonth#">
  	INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682)
  	INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null
  	INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
  	INNER JOIN  (
      SELECT
      ts.iaptaddress_ID,ad.captnumber,h.cname,count(ts.iaptaddress_ID) as aptcnt
			FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
		 	INNER JOIN house h on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 AND h.ihouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
			INNER JOIN recurringcharge rc with (NOLOCK) on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TIPSMonth#">
		 	INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682)
		 	INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null
		 	INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
			WHERE  ts.itenantstatecode_ID=2
			GROUP BY ts.iaptaddress_ID, ad.captnumber,h.cname
		 	HAVING count(ts.iaptaddress_id)>1 AND count(distinct c.ioccupancyposition)=1
    ) a
  	ON ts.iaptaddress_ID=a.iaptaddress_ID
  	WHERE ts.itenantstatecode_ID=2

  	UNION

  	SELECT
    ts.iaptaddress_ID ,ad.captnumber,h.cname,ts.itenant_ID, t.clastname +', '+ t.cfirstname as Residentname,t.csolomonkey,c.ioccupancyposition
  	FROM tenantstate ts  with (NOLOCK)
  	INNER JOIN tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
  	INNER JOIN house h with (NOLOCK) on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 AND h.ihouse_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
  	INNER JOIN recurringcharge rc with (NOLOCK) on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TIPSMonth#">
  	INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682)
  	INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null
  	INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
  	LEFT JOIN (
      SELECT ts.iaptaddress_ID,ad.captnumber,h.cname,ts.itenant_ID, t.cfirstname,t.clastname,c.ioccupancyposition,rc.mamount,rc.cdescription
  		FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on t.itenant_ID= ts.itenant_ID AND t.dtrowdeleted is null AND ts.dtrowdeleted is null
      INNER JOIN house h with (NOLOCK) on h.ihouse_ID=t.ihouse_ID AND h.dtrowdeleted is null AND h.bissANDbox=0 AND h.ihouse_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
			INNER JOIN recurringcharge rc on rc.itenant_ID = t.itenant_ID AND rc.dtrowdeleted is null AND rc.dteffectiveend >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TIPSMonth#">
			INNER JOIN charges c with (NOLOCK) on c.icharge_ID=rc.icharge_ID AND c.dtrowdeleted is null AND c.ichargetype_ID in (89,1748,1682)
			INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID= ts.iaptaddress_ID AND ad.dtrowdeleted is null
			INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID AND (at.biscompanionsuite is null or at.biscompanionsuite = 0)
			WHERE ts.itenantstatecode_ID=2  AND c.iOccupancyposition= 1 AND ts.iresidencytype_ID=1
    ) a
  	ON ts.iaptaddress_ID=a.iaptaddress_ID
  	WHERE  ts.itenantstatecode_ID=2 AND c.iOccupancyposition= 2 AND ts.iresidencytype_ID=1 AND a.itenant_ID is null
    </cfquery>
    <cfreturn Findincorrectrate>
  </cffunction>
  <!--- end: Findincorrectrate --->


  <!--- start: CurrentRecurring --->
  <cffunction access="public" name="CurrentRecurring" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="TIPSMonth" type="string" required="false" default="#SESSION.TIPSMonth#">
    <cfargument name="iHouse_ID" type="numeric" required="false" default="#SESSION.qSelectedHouse.iHouse_ID#">
    <cfquery name="CurrentRecurring" datasource="#arguments.datasource#">
    SELECT
    RC.iRecurringCharge_ID, RC.dtEffectiveStart, RC.dtEffectiveEnd, RC.iQuantity,
    RC.bIsDaily AS RCbIsDaily, RC.cDescription, ROUND(RC.mAmount,2) as mAmount, RC.cComments,
    T.iTenant_ID, T.cFirstname, T.cLastName, CT.bIsDaily, CT.ichargetype_id, TS.mAdjNRF, TS.mAmtNRFPaid
    FROM	RecurringCharge RC with (NOLOCK)
    INNER JOIN	Charges C with (NOLOCK) ON C.iCharge_ID = RC.iCharge_ID AND C.dtRowDeleted is null
    INNER JOIN 	ChargeType CT with (NOLOCK) ON CT.ichargetype_id = C.iChargeType_ID AND CT.dtrowdeleted is null
    INNER JOIN	Tenant T with (NOLOCK) ON RC.iTenant_ID = T. iTenant_ID AND T.dtRowDeleted is null AND RC.dtRowDeleted is null
    INNER JOIN	TenantState TS with (NOLOCK)ON TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted is null AND TS.iTenantStateCode_ID < 3 AND TS.iAptAddress_ID IS NOT NULL
    INNER JOIN	House H	with (NOLOCK) ON H.iHouse_ID = T.iHouse_ID AND H.dtRowDeleted is null AND H.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
    WHERE	RC.dtEffectiveEnd >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.TIPSMonth#">
    ORDER BY T.cLastName
    </cfquery>
    <cfreturn CurrentRecurring>
  </cffunction>
  <!--- end: CurrentRecurring --->


  <!--- start: ChargeList --->
  <cffunction access="public" name="ChargeList" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="TypeID" type="numeric" required="true">
    <cfargument name="iCharge_ID" type="numeric" required="true">
    <cfargument name="TIPSMonth" type="string" required="false" default="#SESSION.TIPSMonth#">
    <cfargument name="CName" type="string" required="true">
    <cfargument name="iHouse_ID" type="numeric" required="false" default="#SESSION.qSelectedHouse.iHouse_ID#">
    <cfargument name="accessrights" type="numeric" required="true">
    <cfargument name="CodeBlock" type="numeric" required="true">
    <cfif arguments.TypeID EQ 0>
      <cfquery name="ChargeList" datasource="#arguments.datasource#">
      SELECT
      C.*, CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, CT.cDescription as typedescription,
      CT.bIsRent, CT.bIsDaily, NULL as cComments, NULL as cInvoiceComments, CT.iChargeType_ID
      FROM Charges C with (NOLOCK)
      INNER JOIN ChargeType CT with (NOLOCK)on C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted is null AND c.dtRowDeleted is null
        AND cGLAccount <> 1030 AND CT.iChargeType_ID <> 23 AND CT.bisRecurring is not null
              AND CT.bIsDeposit is null
              AND (C.cChargeSet is null or C.cChargeset = '#arguments.CName#')
              AND (C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#"> OR C.iHouse_ID is null)
              AND (c.iresidencytype_id <> 3 or c.iresidencytype_id is null)
              AND ct.iChargeType_ID not in (1740,171)
      WHERE C.dtRowDeleted is null
      AND #CreateODBCDateTime(arguments.TipsMonth)# between c.dteffectivestart AND isnull(c.dteffectiveend,getdate())
      <cfif arguments.accessrights EQ 1>
        AND ((bIsRent IS NOT NULL AND bisdaily is not null AND isleveltype_id is null) OR bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL OR bIsRentAdjustment IS NOT NULL)
        AND bisdeposit is null
        AND bIsMedicaid is null AND cGLACCOUNT NOT IN (3011,3012,3015,3016)
      <cfelseif arguments.accessrights EQ 2>
        AND (bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL or (bisrent is not null AND bSlevelType_ID is null))
        AND bIsMedicaid is null AND cGLACCOUNT NOT IN (3011,3012,3015,3016)
        AND bisrentadjustment is null
      </cfif>
      <cfif arguments.iCharge_ID NEQ 0> AND iCharge_ID = #arguments.iCharge_ID#</cfif>
      ORDER BY C.cDescription, CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc
      </cfquery>
    <cfelse>
      <cfquery name="ChargeList" datasource="#arguments.datasource#">
    		SELECT
        RC.*, RC.bIsDaily as RCbIsDaily, CT.iChargeType_ID, CT.bIsModifiableDescription,
        CT.bIsModifiableAmount, CT.bIsModifiableQty, C.iCharge_ID,  CT.cDescription as typedescription,
        CT.bIsRent, CT.bIsDaily, NULL as cComments, NULL as cInvoiceComments
    		FROM	RecurringCharge RC	with (NOLOCK)
    		INNER JOIN	Charges C with (NOLOCK) ON (C.icharge_ID = RC.iCharge_ID AND C.dtRowDeleted is null AND rc.dtRowDeleted is null)
    		INNER JOIN	ChargeType CT	with (NOLOCK) ON (CT.iChargeType_ID = C.iChargeType_ID AND CT.dtRowDeleted is null)	AND rc.iRecurringCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.TypeID#">
    		<cfif arguments.CodeBlock EQ 1>
    		AND ct.bIsMedicaid is null
    		</cfif>
    		ORDER BY CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc, C.cDescription
      </cfquery>
    </cfif>
    <cfreturn ChargeList>
  </cffunction>
  <!--- end: ChargeList --->


  <!--- start: Findroommate --->
  <cffunction access="public" name="Findroommate" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iTenant_ID" type="numeric" required="true">
    <cfargument name="iAptAddress_ID" type="numeric" required="true">
    <cfquery name="Findroommate" datasource="#arguments.datasource#">
    SELECT *,at.iapttype_ID as apttype
    FROM tenantstate ts with (NOLOCK) join tenant t with (NOLOCK) on ts.itenant_ID=t.itenant_ID
    INNER JOIN aptaddress ad with (NOLOCK) on ad.iaptaddress_ID=ts.iaptaddress_id
    INNER JOIN apttype at with (NOLOCK) on at.iapttype_ID=ad.iapttype_ID
    LEFT JOIN recurringcharge r with (NOLOCK) on r.itenant_ID=t.itenant_ID AND r.dtRowDeleted is NULL
    LEFT JOIN charges c with (NOLOCK) on c.icharge_ID=r.icharge_ID AND c.dtRowDeleted is NULL  AND c.ichargetype_ID in (89,1682,1748,31,1749)
    WHERE ts.iaptaddress_id=<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iAptAddress_ID#">
    AND ts.dtrowdeleted is null
    AND ts.dtchargethrough is null
    AND ts.itenantstatecode_ID=2
    AND ad.dtrowdeleted is null
    AND (at.biscompanionsuite = 0 or at.biscompanionsuite is null)
    AND ts.itenant_id != <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iTenant_ID#">
    ORDER by r.iRecurringCharge_ID DESC
    </cfquery>
    <cfreturn Findroommate>
  </cffunction>
  <!--- end: Findroommate --->


  <!--- start: qTenant --->
  <cffunction access="public" name="qTenant" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iTenant_ID" type="numeric" required="true">
    <cfquery name="qTenant" datasource="#arguments.datasource#">
    SELECT	 ts.iaptaddress_ID
    FROM Tenant T with (NOLOCK)
    INNER JOIN tenantstate ts with (NOLOCK) on ts.itenant_ID=t.itenant_ID AND ts.dtrowdeleted is null
    INNER JOIN House H with (NOLOCK) ON T.iHouse_ID = H.iHouse_ID AND H.dtRowDeleted IS NULL AND  T.dtRowDeleted IS NULL AND T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iTenant_ID#">
    </cfquery>
    <cfreturn qTenant>
  </cffunction>
  <!--- end: qTenant --->


  <!--- start: FindChargeType --->
  <cffunction access="public" name="FindChargeType" output="false" returntype="query">
    <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
    <cfargument name="iCharge_ID" type="numeric" required="true">
    <cfquery name="FindChargeType" datasource="#arguments.datasource#">
    SELECT iChargeType_ID
    FROM charges with (NOLOCK)
    WHERE icharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iCharge_ID#">
    </cfquery>
    <cfreturn FindChargeType>
  </cffunction>
  <!--- end: qTenant --->


</cfcomponent>
