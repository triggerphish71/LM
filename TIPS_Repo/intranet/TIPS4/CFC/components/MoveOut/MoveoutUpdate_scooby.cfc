
<cfcomponent displayname="Moveout" Hint="Resident Move out level care calculation">

 <cffunction access="public" name="getTipsMonth" output="false" returntype="query">
 	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
 	<cfargument name="houseid" type="numeric" required="true">

 	<CFQUERY NAME="qTipsMonth" DATASOURCE='#APPLICATION.datasource#'>
		SELECT iHouse_ID, dtCurrentTipsMonth
		FROM houselog with (nolock)
		WHERE  dtrowdeleted is null and ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
	</CFQUERY>
	<cfreturn qTipsMonth>
 </cffunction>

 <cffunction access="public" name="getTimeStamp" output="false" retunrtype="query">
 	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
 	<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#"> 
		SELECT getdate() as TimeStamp
	</CFQUERY>
	<cfreturn qTimeStamp>
 </cffunction>

  <cffunction access="public" name="getHouseMedicaid" output="false" returntype="query">
 	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
 	<cfargument name="houseid" type="numeric" required="true">

 	<CFQUERY NAME="qHouseMedicaid" DATASOURCE='#APPLICATION.datasource#'>
		SELECT mMedicaidBSF 
		FROM HouseMedicaid with (nolock)
		WHERE ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
	</CFQUERY>
	<cfreturn qHouseMedicaid>
 </cffunction>


<cffunction access="public" name="Tenant" output="false" returntype="query" hint="Gets Tenants result set from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="tenantID" type="numeric" required="false" >

	 <CFQUERY NAME="Tenant" DATASOURCE="#arguments.datasource#">
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
			FROM Tenant	T with (nolock)
			JOIN TenantState TS with (nolock) ON T.iTenant_ID = TS.iTenant_ID		
			JOIN ResidencyType RT with (nolock) ON RT.iResidencyType_ID = TS.iResidencyType_ID
			LEFT OUTER JOIN	AptAddress AD with (nolock) ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
			WHERE T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL AND T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</CFQUERY>
	  
	     <cfreturn Tenant>
</cffunction>
 
  <cffunction access="public" name="InvoiceCheck" output="false" returntype="query" hint="Gets Tenants last open invoice from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="formdata" type="struct" required="true" default="">
	 
 <CFQUERY NAME="InvoiceCheck" DATASOURCE="#arguments.datasource#">
		SELECT	Distinct iInvoiceMaster_ID, iInvoiceNumber, dtInvoiceStart
		FROM	InvoiceMaster IM with (nolock)
		WHERE IM.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#">
		AND bMoveOutInvoice IS NOT NULL	AND IM.bFinalized IS NULL AND IM.dtRowDeleted IS NULL
		AND (1 <= (select count(iinvoicedetail_id) from invoicedetail where dtrowdeleted is null
			and itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#">
			and iinvoicemaster_id = im.iinvoicemaster_id)
		OR 0 = (select count(iinvoicedetail_id) from invoicedetail where dtrowdeleted is null
			and iinvoicemaster_id = im.iinvoicemaster_id) )
	</CFQUERY>
 	<cfreturn InvoiceCheck>
 </cffunction>
 
 <cffunction access="public" name="DeleteDetail" output="false" returntype="void" hint="Tenants current month care changes">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
     <CFQUERY NAME = "DeleteDetail" DATASOURCE = "#arguments.datasource#">
			UPDATE	InvoiceDetail
			SET	iRowDeletedUser_ID = #arguments.formdata.UserID#,
			    dtRowDeleted = <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
			WHERE iInvoiceMaster_ID = #arguments.formdata.iInvoiceMaster_ID#
			AND dtRowDeleted IS NULL AND (iRowStartUser_ID = 0 or iRowStartUser_ID = 9999) 
			AND iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#">
		</CFQUERY>  	
 </cffunction>
 
 <cffunction name="NewInvoice" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
				
		<CFQUERY NAME = "NewInvoice" DATASOURCE = "#arguments.datasource#">
			INSERT INTO InvoiceMaster
				( iInvoiceNumber ,cSolomonKey ,bMoveOutInvoice ,bFinalized ,cAppliesToAcctPeriod ,cComments, 
				mLastInvoiceTotal ,dtAcctStamp ,dtInvoiceStart ,iRowStartUser_ID ,dtRowStart )
			VALUES
				('#arguments.formdata.iInvoiceNumber#',
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#">,
				 1,
				 NULL,				
				'#arguments.formdata.AppliesTo#',				
				'#arguments.formdata.InvoiceComments#',				
				0,
				'#arguments.formdata.dtAcctStamp#',
				<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#">,
				 <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" /> 
				 )
		</CFQUERY> 
	</cffunction> 
 
 <cffunction access="public" name="HouseNumberControl" output="false" returntype="void" hint="Gets next invoice number.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="iNextInvoice" type="numeric" required="false" >
	  <cfargument name="iHouse_ID" type="numeric" required="false" >
	 
	      <CFQUERY NAME = "HouseNumberControl" DATASOURCE = "#arguments.datasource#">
				UPDATE	HouseNumberControl
				SET		iNextInvoice = #arguments.iNextInvoice + 1#
				WHERE	iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
			</CFQUERY>  
 </cffunction> 
 
  <cffunction access="public" name="qRespiteRate" output="false" returntype="query" hint="Gets next invoice number.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="Occupancy" type="numeric" required="false" >
	  <cfargument name="iHouse_ID" type="numeric" required="false" >
	  
		  <CFQUERY NAME="qRespiteRate" DATASOURCE="#arguments.datasource#">
				SELECT	mAmount
				FROM Charges C with (nolock)
				JOIN ChargeType CT with (nolock) ON C.iChargeType_ID = CT.iChargeType_ID AND CT.dtRowDeleted IS NULL
				and (C.iOccupancyPosition = #Occupancy# 
				     OR C.iOccupancyPosition IS NULL)
				WHERE C.dtRowDeleted IS NULL AND C.iResidencyType_ID = 3
				  AND C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">
			</CFQUERY>	
   	<cfreturn qRespiteRate>
 </cffunction>
  
 
  <cffunction access="public" name="GetGlAccount" output="false" returntype="query" hint="Tenants current month care changes">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">    
    
  <cfset QTenant = session.oMoveOutUpdate.Tenant(tenantID = #arguments.formdata.tenantID#)>
  
	 <CFQUERY NAME="GetGlAccount" DATASOURCE="#arguments.datasource#">
			SELECT	iChargeType_ID, cDescription
			FROM ChargeType with (nolock)
			WHERE dtRowDeleted IS NULL
			
			<CFIF #arguments.formdata.glacc# EQ 'top'>	
			     <CFIF QTenant.iResidencyType_ID EQ 1 and QTenant.iProductline_ID eq 1 and QTenant.cbillingtype eq 'M'>
			       AND cGLAccount = 3010 and bisdaily is null and bisprepay is null and bSLevelType_ID is null and ichargetype_ID=1682
				<CFELSEIF QTenant.iResidencyType_ID EQ 1 and QTenant.iProductline_ID eq 1>  
					AND cGLAccount = 3010 and bisdaily is not null and bisprepay is not null and bSLevelType_ID is null
				<CFELSEIF QTenant.iResidencyType_ID EQ 2 and QTenant.iProductline_ID eq 1> 
					AND cGLAccount in ('3011','3012','3091','3092') and bismedicaid is not null 
				<CFELSEIF QTenant.iProductline_ID eq 2> 
				    AND iChargeType_ID=1748
				</CFIF>
			</cfif>
			<CFIF #arguments.formdata.glacc# EQ 'Bottom'>
			    <CFIF QTenant.iResidencyType_ID EQ 1 and QTenant.iProductline_ID eq 1 and QTenant.cbillingtype eq 'M'>
			       AND cGLAccount = 3010 and bisdaily is null and bisprepay is null and bSLevelType_ID is null and ichargetype_ID=1682
				<CFELSEIF QTenant.iResidencyType_ID EQ 1 and QTenant.iProductline_ID eq 1> 
					AND cGLAccount = 3020 and bIsRentAdjustment is not null
				<CFELSEIF QTenant.iResidencyType_ID EQ 2 and QTenant.iProductline_ID eq 1> 
					AND cGLAccount = 3021 and bIsRentAdjustment is not null and bismedicaid is not null
				<CFELSEIF QTenant.iProductline_ID eq 2> 
				    AND iChargeType_ID=1748
				</CFIF>
			</CFIF>
			Order by ichargetype_id
		</CFQUERY>
    <cfreturn GetGlAccount>
 </cffunction> 
 
 
 <cffunction access="public" name="GetNextInvoice" output="false" returntype="query" hint="Get Tenants last open invoice from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="iHouse_ID" type="numeric" required="false" >
	 
      <CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#arguments.datasource#">
			select iNextInvoice 
			from HouseNumberControl with (nolock)
			where dtRowDeleted is null
			and iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#"> 
		</CFQUERY>
	<cfreturn GetNextInvoice>
 </cffunction>	
 
  <cffunction access="public" name="NewMasterID" output="false" returntype="query" hint="Get Tenants last open invoice from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="cSolomonKey" type="string" required="false" default="">
	 
       <CFQUERY NAME = "NewMasterID" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	iInvoiceMaster_ID, dtInvoiceStart, dtInvoiceEnd, iInvoiceNumber
			FROM InvoiceMaster with (nolock)
			WHERE cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#">
			AND bMoveOutInvoice IS NOT NULL AND bFinalized IS NULL AND dtRowDeleted IS NULL
			AND dtRowStart = (Select max(dtRowStart) from InvoiceMaster WHERE cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#">)
		</CFQUERY>
      <cfreturn NewMasterID>
 </cffunction>			
		
 
<cffunction access="public" name="qryLastOpenInvoice" output="false" returntype="query" hint="Get Tenants last open invoice from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="cSolomonKey" type="string" required="false" default="">

	  <cfquery name="qryLastOpenInvoice"  DATASOURCE = "#arguments.datasource#">
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
		from invoicedetail inv with (nolock)
		join invoicemaster im with (nolock) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
		where <!---bFinalized = 1 and --->
		im.dtrowdeleted is null 
			and inv.dtrowdeleted is null 
			and im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#">
			and ichargetype_id in (8,31,1661,1682,1748)
		order by inv.cappliestoacctperiod desc
	  </cfquery>
	  
	   <cfreturn qryLastOpenInvoice>
</cffunction>
 

<cffunction access="public" name="qryInvoicecare" output="false" returntype="query" hint="Tenants calculate the rate as they are monthly and based on daily charge">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="cSolomonKey" type="string" required="false" default="">  
	  <cfargument name="MoveInPeriod" type="string" required="false" default="">
	 
		 <cfquery name="qryInvoicecare"  DATASOURCE = "#arguments.datasource#">
			select inv.iInvoiceDetail_ID,
				inv.iChargeType_ID,
				inv.cAppliesToAcctPeriod,
				inv.bIsRentAdj,
				inv.dtTransaction,
				inv.iQuantity,
				inv.cDescription,
				inv.mAmount 
			from invoicedetail inv with (nolock)
			join invoicemaster im with (nolock) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
			where bmoveininvoice = 1 and im.dtrowdeleted is null 
				and inv.dtrowdeleted is null 
				and im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#">
				and ichargetype_id in (1750)
				and inv.cAppliesToAcctPeriod= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveInPeriod#">
			order by inv.cappliestoacctperiod desc
		</cfquery>

	   <cfreturn qryInvoicecare>
</cffunction>
  
<cffunction access="public" name="qryInvoiceRB" output="false" returntype="query" hint="Tenants calculate the rate as they are monthly and based on daily charge">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="cSolomonKey" type="string" required="false" default="">
	  <cfargument name="MoveInPeriod" type="string" required="false" default="">
	 
		<cfquery name="qryInvoiceRB"  DATASOURCE = "#arguments.datasource#">
			select inv.iInvoiceDetail_ID,
				inv.iChargeType_ID,
				inv.cAppliesToAcctPeriod,
				inv.bIsRentAdj,
				inv.dtTransaction,
				inv.iQuantity,
				inv.cDescription,
				inv.mAmount 
			from invoicedetail inv with (nolock)
			join invoicemaster im with (nolock) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
			where bmoveininvoice = 1 and im.dtrowdeleted is null 
				and inv.dtrowdeleted is null 
				and im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#">
				and ichargetype_id in (1749)
				and inv.cAppliesToAcctPeriod= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveInPeriod#">
			order by inv.cappliestoacctperiod desc
		</cfquery>
	 
	   <cfreturn qryInvoiceRB> 
</cffunction> 
 
 
   <cffunction access="public" name="qGetHistoricalRent" output="false" returntype="query" hint="Tenant charges for monthly - Invoice history">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">  
  <!---<cfdump var="#arguments#"><cfabort> --->
    <CFQUERY NAME="qGetHistoricalRent" DATASOURCE="#APPLICATION.datasource#">
	
			SELECT	count(INV.iInvoiceDetail_ID) as reccount
			<cfif #arguments.formdata.Restype# EQ 'Medicaid'>
				,case WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 31 THEN (#arguments.formdata.mMedicaidBSF#)
					WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 1661 THEN (#arguments.formdata.mMedicaidCopay#)
					else (round(SUM(iQuantity * mAmount),2)) end as ChargedRentRate
					,INV.cDescription
					,INV.cAppliesToAcctPeriod
					,case WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 31 
						THEN round(#arguments.formdata.mMedicaidBSF#/#arguments.formdata.dtChargeThroughdays#,2)
					WHEN CT.cGLAccount = 3011 and ct.ichargetype_id = 1661 
						THEN round(#arguments.formdata.mMedicaidCopay#/#arguments.formdata.dtChargeThroughdays#,2)
					<!---mamta addede this--->	
					<cfif arguments.formdata.proratedstateRB NEQ ''>
					WHEN CT.cGLAccount = 3091 and ct.ichargetype_id = 1749
						THEN round(#arguments.formdata.proratedstateRB#,2)	
					</cfif>	
					<cfif arguments.formdata.proratedstatecare NEQ ''> 
					WHEN CT.cGLAccount = 3092 and ct.ichargetype_id = 1750
						THEN round(#arguments.formdata.proratedstatecare#,2)
					</cfif>						
					WHEN (CT.bIsDaily IS NOT NULL) 
						THEN (INV.mAmount)
					ELSE round(SUM(iQuantity * mAmount),2)/
						<CFIF arguments.formdata.iResidencyType_ID EQ 2 AND arguments.formdata.dtChargeThrough NEQ ''>#arguments.formdata.dtChargeThroughdays#<CFELSE>30</CFIF>
					END  as ProratedRent
					,IM.bMoveInInvoice, IM.bMoveOutInvoice
					,CT.bIsRent, CT.bIsMedicaid
					,CT.bIsDiscount, CT.bIsRentAdjustment
					, CT.iChargetype_id as original
			</cfif> 		   
		    
			<cfif #arguments.formdata.Restype# EQ 'AL'>				  
				, (round(SUM(iQuantity * mAmount),2))   as ChargedRentRate
					,INV.cDescription
					,INV.cAppliesToAcctPeriod
					,round(CASE WHEN (CT.bIsDaily IS NOT NULL) THEN (INV.mAmount)
					                <cfif arguments.formdata.proratedamountformonthlyBSF NEQ  ''>  
					             WHEN (CT.ichargetype_ID in (1682,1748))THEN 
					                 #arguments.formdata.proratedamountformonthlyBSF#
					                </cfif>
					         ELSE round(SUM(iQuantity * mAmount),2)/<CFIF arguments.formdata.iResidencyType_ID EQ 2  AND arguments.formdata.dtChargeThrough NEQ ''>#arguments.formdata.dtChargeThroughdays#<CFELSE>30</CFIF> 
					END,2)
					as ProratedRent
					,IM.bMoveInInvoice, IM.bMoveOutInvoice
					,CT.bIsRent, CT.bIsMedicaid
					,CT.bIsDiscount, CT.bIsRentAdjustment
					, CT.iChargetype_id as original
				 </cfif>	
					,<CFIF arguments.formdata.MonthDiff GT 0>
						CT.iChargeType_ID
			          <CFELSE>			       
				       	
						<CFIF #arguments.formdata.AcctStamp# GTE '2004-01-01'>  
								CASE 
								WHEN CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL THEN CT.iChargeType_ID
								WHEN CT.cGLAccount = 3014 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3020 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3015 THEN (SELECT top 1 iChargeType_ID FROM ChargeType with (nolock) 
																WHERE dtrowdeleted is null and cGLAccount = 3021 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3016 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3022 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3010 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock) 
																WHERE dtrowdeleted is null and cGLAccount = 3020 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3011 THEN (SELECT top 1 iChargeType_ID FROM ChargeType with (nolock) 
																WHERE dtrowdeleted is null and cGLAccount = 3021
																 AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																 AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3012 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3022 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3017 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3027 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								ELSE CT.iChargeType_ID
								END as iChargeType_ID
							<CFELSE>
								CASE 
								WHEN CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL THEN CT.iChargeType_ID
								WHEN CT.cGLAccount = 3010 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3014 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3011 THEN (SELECT top 1 iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3015 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3012 THEN (SELECT iChargeType_ID FROM ChargeType with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3016 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND isNULL(bIsMedicaid,0) = isNULL(CT.bIsMedicaid,0))
								WHEN CT.cGLAccount = 3017 THEN (SELECT iChargeType_ID FROM ChargeType  with (nolock)
																WHERE dtrowdeleted is null and cGLAccount = 3014 
																AND isNull(bIsRent,0) = isNull(CT.bIsRent,0) 
																AND IsNull(bIsMedicaid,0) = isNull(CT.bIsMedicaid,0))
								ELSE CT.iChargeType_ID
								END as iChargeType_ID
							</CFIF>
						</CFif>
						
			FROM	InvoiceDetail INV with (nolock)
			JOIN	InvoiceMaster IM with (nolock) on IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID 
			and IM.dtRowDeleted IS NULL AND IM.iInvoiceMaster_ID <> #arguments.formdata.iInvoiceMaster_ID#
			JOIN	ChargeType CT with (nolock) on CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
			and INV.dtRowDeleted IS NULL and INV.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#">
			and (CT.bIsRent IS NOT NULL OR INV.iRowStartUser_ID = 0)
			and INV.cAppliesToAcctPeriod = #arguments.formdata.I#	
			AND INV.iInvoiceMaster_ID <> (select top 1 inv.iInvoiceMaster_ID	 
												from invoicedetail inv with (nolock)
												join invoicemaster im with (nolock) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
												where im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#">	
												 <cfif arguments.formdata.doeditMO EQ true> AND im.dtrowdeleted is null and bFinalized is null </cfif>
													and inv.dtrowdeleted is null	
												order by inv.cappliestoacctperiod desc)  
									  
			and INV.iInvoiceMaster_ID <> #arguments.formdata.iInvoiceMaster_ID#
			and INV.mAmount <> 0 and CT.bIsDeposit IS NULL and CT.cGLAccount <> 2210
			and im.bMoveOutInvoice is Null			
			 and INV.iChargeType_ID not in (1740, 1741,69,1710,13,1672 <cfif "#arguments.formdata.MoveOutPeriod#" EQ #arguments.formdata.I#> ,14,1710,13,1672,1685,1680</cfif>) 
			                                                            <!---Mamta removed 8  /gthota added 1710,13,1672,1680 on 01/23/2018--->		
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
 	 <cfreturn qGetHistoricalRent> 
</cffunction>
 
 
<cffunction access="public" name="MCdate" output="false" returntype="query" hint="Tenants MC previous care rate">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	 
		 <cfquery name="MCdate" datasource="#application.datasource#">
		   SELECT LEFT(convert(varchar(10),dtMCSwitch,112),6) as mcswitchperiod, convert(varchar(10),dtMCSwitch,110) as dtMCSwitch FROM TenantState 
		      WHERE iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#">
		      AND LEFT(convert(varchar(10),dtMCSwitch,112),6) BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.stopdatemonth#"> and <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.MoveOutPeriod#"> 
		 </cfquery>
	  <cfreturn MCdate> 
</cffunction> 
  
<!---  Care level calculation for Memory care START --->
<cffunction access="public" name="getLatestDataMC" output="false" returntype="query" hint="Tenants MC care rate">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >
	<cfargument name="prevdatemonth" type="string" required="false" default="">
	  
	<cfquery name="getLatestDataMC" datasource="#arguments.datasource#">
		select mAmount
		from InvoiceDetail with (NOLOCK)
		where bIsRentAdj IS NULL
		      and cAppliesToAcctPeriod =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prevdatemonth#">          
		      and iChargetype_id = 91
		      and dtrowDeleted IS NULL
		      and iTenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
		order by iInvoiceMaster_ID asc
	</cfquery>
	  <cfreturn getLatestDataMC> 
</cffunction>

<cffunction access="public" name="qGetprelvlcare" output="false" returntype="query" hint="Tenants MC previous care rate">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">

		<CFQUERY NAME="qGetprelvlcare" DATASOURCE="#arguments.datasource#">
		  select * , REPLACE(cComments, 'pts','') as ccomments1,ROW_NUMBER() OVER(ORDER BY dtrowstart ASC) AS cnt
		    from InvoiceDetail with (NOLOCK)
			  where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#"> 
			  and iChargeType_ID = 91 		                        
			  and bIsRentAdj = 1	  
			<!---   and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.prevdatemonth#"> 	
			  AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  between <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.prevdate#"> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">  --->         
		
		<cfswitch expression ="#arguments.formdata.caretype#">
		      <cfcase value = "MC">
		        and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.prevdatemonth#">
				AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  between <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.prevdate#"> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">        
		      </cfcase>
		      <cfcase value = "Future">  <!--- Future month --->
				  and iInvoiceMaster_ID = (select top 1 iInvoiceMaster_ID from InvoiceMaster where csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#"> 
			                               and bMoveOutInvoice is null order by iInvoiceMaster_ID desc)	                        
				  and bIsRentAdj = 1	  
				  and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.MoveOutPeriod#"> 
				  and iRowStartUser_ID <> 9999
				  AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  between <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.preprevdate#"> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">
				     AND DTTRANSACTION  > =  (select dtActualEffective from HouseLog where iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iHouse_ID#">)   	
				  AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  < <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#"> 
		      </cfcase>		     
		      <cfcase value = "PCM">   <!--- Previous month period --->
				      <cfif #arguments.formdata.MonthDiff# EQ -2>
					  <cfelse>
					  and iInvoiceMaster_ID = (select top 1 iInvoiceMaster_ID from InvoiceMaster where csolomonkey = '#Tenant.cSolomonKey#' 
					                            and bMoveOutInvoice is null order by iInvoiceMaster_ID desc)
					  </cfif> 
					  and cAppliesToAcctPeriod = '#prevdatemonth#' 
					  and iRowStartUser_ID <> 9999
					  AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  < '#dateformat(dtChargeThrough, "yyyy-mm-dd")#' 
					  AND convert(varchar, DTTRANSACTION,101) > =  (select convert(varchar,dtActualEffective,101) from HouseLog where iHouse_ID = #SESSION.qSelectedHouse.iHouse_id#)   
		      </cfcase>
		      <cfcase value = "Currentmonth">  <!--- Current month move out --->
				  and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.prevdatemonth#">
				  and iRowStartUser_ID <> 9999	
				  AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  between <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.prevdate#"> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">
				   AND DTTRANSACTION  > =  (select dtActualEffective from HouseLog where iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iHouse_ID#">)	
				  <!--- AND convert(varchar, DTTRANSACTION,101)  > =  (select convert(varchar,dtActualEffective,101) from HouseLog where iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iHouse_ID#">)	  --->
		      </cfcase>
		      
		      <cfdefaultcase>
		        AND 1=1
		      </cfdefaultcase>
		      </cfswitch>
		
		</CFQUERY>
<cfreturn qGetprelvlcare> 
</cffunction>

<cffunction access="public" name="qGetlvlcare" output="false" returntype="query" hint="Tenants MC current care rent">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">

<!---<cfdump var ="#arguments#"><cfabort>  --->	
		<CFQUERY NAME="qGetlvlcare" DATASOURCE="#arguments.datasource#">
		  select * , REPLACE(cComments, 'pts','') as ccomments1,ROW_NUMBER() OVER(ORDER BY dtrowstart ASC) AS cnt
		    from InvoiceDetail with (NOLOCK)
			  where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#"> 
			  and iChargeType_ID = 91 	 	                       
			  and bIsRentAdj = 1 and iRowStartUser_ID <> 9999
		      and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.MoveOutPeriod#">
		     
		      <cfswitch expression ="#arguments.formdata.caretype#">
		      <cfcase value = "MC">
				      AND LEFT(convert(varchar(10),CAST(replace(right(cComments,8), '-', '') as DATETIME),112),6) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.MoveOutPeriod#">
				      AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  < <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtMCSwitch#">  
		      </cfcase>
		      <cfcase value = "Future">  <!--- Future month --->
				      and iInvoiceMaster_ID = (select top 1 iInvoiceMaster_ID from InvoiceMaster where csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#">
				                                and bMoveOutInvoice is null order by iInvoiceMaster_ID desc) 	                       
					  and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.MoveOutPeriod#">
					   AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  BETWEEN <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.startOfMonthmdate#"> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">    
				      AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  < <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#"> 			      
				      
		      </cfcase>
		      <cfcase value ="PV">
		         		 AND CAST(replace(right(cComments,8), '-', '') as DATETIME) between <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.startOfMonthdate#"> AND <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">
		      </cfcase>
		      <cfcase value = "TMC">   <!--- Previous month period --->
				        and dtrowdeleted is null
				        AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  < <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughdate#">   
		      </cfcase>
		      <cfcase value = "Currentmonth">  <!--- Current month move out --->
					  and dtrowdeleted is null 
				      AND LEFT(convert(varchar(10),CAST(replace(right(cComments,8), '-', '') as DATETIME),112),6) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.MoveOutPeriod#">	      
				      AND CAST(replace(right(cComments,8), '-', '') as DATETIME)  < '#arguments.formdata.dtChargeThroughdate#'
				      and month(DTTRANSACTION) = month(#CreateODBCDateTime(SESSION.AcctStamp)#) 
				      and right(cComments,8) <> '#arguments.formdata.cCommentdate#'
		      </cfcase>
		      
		      <cfdefaultcase>
		        AND 1=1
		      </cfdefaultcase>
		      </cfswitch>
		      
		</CFQUERY>
<cfreturn qGetlvlcare> 
</cffunction> 

<cffunction access="public" name="getMCrates" output="false" returntype="query" hint="Tenants MC RnB and care rate">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >
	<cfargument name="cSolomonKey" type="string" required="false" default="">
	<cfargument name="MoveOutPeriod" type="string" required="false" default="">
	
		<cfquery name="getMCrates" datasource="#arguments.datasource#">
			select * from InvoiceDetail with (NOLOCK) where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			 and dtRowDeleted is null  
			 and iChargeType_ID in (89,91) 
			 and iInvoiceMaster_ID = (select top 1 iInvoiceMaster_ID from InvoiceMaster where csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#"> 
			                               and bMoveOutInvoice is null and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveOutPeriod#"> 
			                               and dtrowdeleted is null)
			 and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveOutPeriod#">
		</cfquery>
	  <cfreturn getMCrates> 
</cffunction>

<cffunction access="public" name="getMCRB" output="false" returntype="query" hint="Tenants MC room and board">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >	
	<cfargument name="MoveOutPeriodMCRB" type="string" required="false" default="">
	
		<cfquery name="getMCRB" datasource="#arguments.datasource#">
			select * from InvoiceDetail with (NOLOCK) where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			 and dtRowDeleted is null  
			 and iChargeType_ID in (1748)	 
			 and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveOutPeriodMCRB#"> 
		</cfquery> 
	  <cfreturn getMCRB> 
</cffunction>

<cffunction access="public" name="getPrevMC" output="false" returntype="query" hint="Tenants MC care rates details">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >	
	<cfargument name="prevdatemonth" type="string" required="false" default="">
	
		 <cfquery name="getPrevMC" datasource="#application.datasource#">
			select * from InvoiceDetail with (NOLOCK)
			where bIsRentAdj IS NULL
			      and cAppliesToAcctPeriod =  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prevdatemonth#">
			      and iChargetype_id = 91
			      and dtrowDeleted IS NULL
			      and iTenant_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			order by iInvoiceMaster_ID desc
			</cfquery>
	  <cfreturn getPrevMC> 
</cffunction>
<!--- Memory Care SQL statements END --->
  
 <cffunction access="public" name="getcompareData" output="false" returntype="query" hint="Tenants previous care details">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >
	<cfargument name="MoveOutPeriod" type="string" required="false" default="">	
	 
 <cfquery name="getcompareData" datasource="#arguments.datasource#">
     select rtrim(right(cComments,8)) as cComments from InvoiceDetail where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantId#">
     and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveOutPeriod#"> 
     and iChargeType_ID = 91 and bIsRentAdj = 1
 </cfquery>
  <cfreturn getcompareData> 
</cffunction>

 <cffunction access="public" name="getLatestData" output="false" returntype="query" hint="Tenants previous care care">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >
	<cfargument name="prevdatemonth" type="string" required="false" default="">
	    
	<cfquery name="getLatestData" datasource="#arguments.datasource#">
		select *
		from InvoiceDetail with (NOLOCK)
		where bIsRentAdj IS NULL
		      and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.prevdatemonth#">        
		      and iChargetype_id = 91
		      and dtrowDeleted IS NULL
		      and iTenant_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
		order by iInvoiceMaster_ID desc
	 </cfquery> 
   <cfreturn getLatestData> 
</cffunction> 
  
  <cffunction name="SAVE" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">

 <!---<cfdump var ="#arguments#"><cfabort> --->					
		<cfquery name="SAVE" datasource="#arguments.datasource#">
			INSERT INTO InvoiceDetail(
										iInvoiceMaster_ID,
										iTenant_ID, 
										iChargeType_ID, 
										cAppliesToAcctPeriod, 
										bIsRentAdj, 
										dtTransaction, 
										iQuantity, 
										cDescription, 
										mAmount,
										cComments, 
										dtAcctStamp, 
										iRowStartUser_ID,  
										dtRowStart,
										iDaysBilled
									)VALUES( 	
					  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iInvoiceMaster_ID#">
					 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantid#">				 
					 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iChargeType_ID#" null="#IIF(len(arguments.formdata.iChargeType_ID) EQ 0,'true','false')#">
					 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cAppliesToAcctPeriod#"> 
					 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.bIsRentAdj#" null="#IIF(len(arguments.formdata.bIsRentAdj) EQ 0,'true','false')#">
					 ,<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
					 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iQuantity#"> <!--- #arguments.formdata.iQuantity# --->	
					 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cDescription#" null="#IIF(len(arguments.formdata.cDescription) EQ 0,'true','false')#">			 
					 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.mAmount#">					 
					 ,<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cComments#" null="#IIF(len(arguments.formdata.cComments) EQ 0,'true','false')#">
					 ,<cfqueryparam cfsqltype="cf_sql_timestamp" value=#arguments.formdata.dtAcctStamp#>
					 ,#arguments.formdata.iRowStartUser_ID#
					 ,<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
					 ,<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.iDaysBilled#" null="#IIF(len(arguments.formdata.iDaysBilled) EQ 0,'true','false')#">					
					 )										
		</cfquery>			
	</cffunction>
 
 <!--- Ancillary rent SQL --->
 <cffunction access="public" name="qGetancilery" output="false" returntype="query" hint="Tenants ancillary rent charges">
	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantID" type="numeric" required="false" >
	<cfargument name="prevdatemonth" type="string" required="false" default="">
	<cfargument name="cSolomonKey" type="string" required="false" default="">
	<cfargument name="iHouse_ID" type="numeric" required="false" >
	    
	<cfquery name="qGetancilery" datasource="#arguments.datasource#">
		select *
	    from InvoiceDetail with (NOLOCK)
		  where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
		  and iChargeType_ID in (1710,13,1672,1680)  
		  and cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.MoveOutPeriod#">
		  AND dtrowdeleted is null	and iRowStartUser_ID <> 9999
		  and DTTRANSACTION   >= (select dtActualEffective from HouseLog where iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.iHouse_ID#">) 
		  AND iInvoiceMaster_ID <> (select top 1 iInvoiceMaster_ID from InvoiceMaster where cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.cSolomonKey#">
		                             and iInvoiceNumber like '%MO' order by dtRowStart desc)  
	 </cfquery> 
   <cfreturn qGetancilery> 
</cffunction> 
       
    <cffunction name="TenantLOCchrg" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	  
	   <CFQUERY NAME = "TenantLOCchrg" DATASOURCE="#APPLICATION.datasource#">
		 SELECT	* from InvoiceDetail with (NOLOCK) where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantid#"> 
		  and cAppliesToAcctPeriod =  #arguments.formdata.dtChargeThroughdate#
		  and iChargeType_ID = 91 and dtRowDeleted is null
		</CFQUERY>
 	 <cfreturn TenantLOCchrg> 
	</cffunction>  
   
   
   <!--- Checking 0 values in invoice detail table to delete --->
  <cffunction name="ProratedRentDel" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	  
	   <CFQUERY NAME="ProratedRentDel" DATASOURCE="#arguments.datasource#">
		Update InvoiceDetail 
		  SET  dtRowDeleted = <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
		  Where iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#">
		   AND iInvoiceMaster_ID = #arguments.formdata.iInvoiceMaster_ID#
		   AND (iQuantity = 0 or mAmount = 0)  				 		
	    </CFQUERY> 
 	</cffunction>  

   <cffunction name="GetCID" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
     <CFQUERY NAME = "GetCID" DATASOURCE = "#arguments.datasource#"> <!---Mshah added top 1 and desc in query to get the correct contact ID--->
			SELECT	iContact_ID
			FROM	Contact with (nolock)
			WHERE	cFirstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cFirstName#">
			AND		cLastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.clastname#">
			AND		cAddressLine1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cAddressLine1#" null="#IIF(len(arguments.formdata.cAddressLine1) EQ 0,'true','false')#">			                     
			AND		iRowStartUser_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#"> 			
		</CFQUERY>
	 <cfreturn GetCID> 
	</cffunction>		
 

   <cffunction name="TenantState" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
 
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
						dtChargeThrough = <CFIF arguments.formdata.dtChargeThrough NEQ ""> <cfqueryparam cfsqltype="cf_sql_date" value="#DateFormat(arguments.formdata.dtChargeThrough,'yyyy-mm-dd')#">, </CFIF>
						<!--- mstiregel 03/10/2018 --->
						dtNoticeDate = <CFIF arguments.formdata.dtNotice NEQ ""> #arguments.formdata.dtNotice#,<cfelse>NULL, </CFIF>
						<!--- end mstriegel 03/10/2018--->
						dtMoveOut = <CFIF arguments.formdata.dtMoveOut NEQ ""> #arguments.formdata.dtMoveOut#, </CFIF>
						dtAcctStamp = '#arguments.formdata.dtAcctStamp#'
						<CFIF Tenant.iTenantStateCode_ID LT 3>				
							,iTenantStateCode_ID = 2
						</CFIF>		
				WHERE dtrowdeleted is null and iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantID#">
			</CFQUERY>
 	</cffunction>
  
 
    <cffunction name="qInvoiceDamage" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
	      <CFQUERY NAME="qInvoiceDamage" DATASOURCE="#arguments.datasource#">
				update invoicemaster
				set	iDamageStatus = #arguments.formdata.DamageStatus#
					,dtrowstart = <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
					,irowstartuser_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#">
				where iinvoicemaster_id = #arguments.formdata.iInvoiceMaster_ID#
			</CFQUERY>
 	</cffunction> 
 	
  <cffunction access="public" name="qRecordCheck" output="false" returntype="query" hint="Gets Tenants result set from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="formdata" type="struct" required="true" default="">
	 
		    <CFQUERY NAME="qRecordCheck" DATASOURCE="#arguments.datasource#">
				SELECT	Count(*) as count
				FROM	InvoiceDetail with (nolock)
				WHERE	dtRowDeleted IS NULL AND iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.iInvoiceMaster_ID#">	
			</CFQUERY>
 	 <cfreturn qRecordCheck> 
	</cffunction>
 
 
   <cffunction access="public" name="qZeroCharge" output="false" returntype="query" hint="Gets Tenants result set from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="tenantID" type="numeric" required="false" >
	
	<cfset QTenant = session.oMoveOutUpdate.Tenant(tenantID = #arguments.tenantID#)>
	 
       <CFQUERY NAME="qZeroCharge" DATASOURCE="#arguments.datasource#">
			SELECT top 1 * FROM ChargeType with (nolock) 
			  WHERE dtRowDeleted IS NULL AND bIsRent IS NOT NULL 
			<CFIF QTenant.iResidencyType_ID EQ 2> AND cGLAccount = 3011 <CFELSE> AND bIsDaily IS not NULL AND cGLAccount = 3010 </CFIF> 
			<CFIF QTenant.iResidencyType_ID EQ 1>AND cDescription not like '%respite%'</CFIF> 
		</CFQUERY>
  	 <cfreturn qZeroCharge> 
	</cffunction>
 
 
   <cffunction name="UpdateLinkTenantContact" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
	 		<CFQUERY NAME="UpdateLinkTenantContact" DATASOURCE="#arguments.datasource#">
				UPDATE LinkTenantContact
				SET	iRelationshipType_ID = #arguments.formdata.IRELATIONSHIPTYPE_ID# 
					,dtrowstart = <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
					,irowstartuser_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#">
					,bIsMoveOutPayer = 1
				WHERE iContact_ID = #arguments.formdata.iContact_ID#
			</CFQUERY>
	</cffunction>
 
 
    <cffunction name="UpdateContact" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
	     <CFQUERY NAME = "UpdateContact" DATASOURCE="#arguments.datasource#">
					UPDATE 	Contact
					SET	
					 cFirstName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cFirstName#" null="#IIF(len(arguments.formdata.cFirstName) EQ 0,'true','false')#">,
					 cLastName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cLastName#" null="#IIF(len(arguments.formdata.cLastName) EQ 0,'true','false')#">,
					 cAddressLine1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cAddressLine1#" null="#IIF(len(arguments.formdata.cAddressLine1) EQ 0,'true','false')#">, 
					 cAddressLine2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cAddressLine2#" null="#IIF(len(arguments.formdata.cAddressLine2) EQ 0,'true','false')#">,
					 cCity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cCity#" null="#IIF(len(arguments.formdata.cCity) EQ 0,'true','false')#">,
					 cStateCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cStateCode#" null="#IIF(len(arguments.formdata.cStateCode) EQ 0,'true','false')#">,	
					 cZipCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cZipCode#" null="#IIF(len(arguments.formdata.cZipCode) EQ 0,'true','false')#">,	
					 cPhoneNumber1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cPhoneNumber1#" null="#IIF(len(arguments.formdata.cPhoneNumber1) EQ 0,'true','false')#">,
					 cPhoneNumber2 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cPhoneNumber2#" null="#IIF(len(arguments.formdata.cPhoneNumber2) EQ 0,'true','false')#">
				WHERE	iContact_ID = #arguments.formdata.iContact_ID#	
			</CFQUERY>
 	</cffunction>
 
 
     <cffunction name="NewContact" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
     <CFQUERY NAME = "NewContact" DATASOURCE = "#APPLICATION.datasource#" result="NewContact">
			INSERT INTO Contact
			(	cFirstName, cLastName, cPhoneNumber1, iPhoneType1_ID, cPhoneNumber2, iPhoneType2_ID, 
				cPhoneNumber3, iPhoneType3_ID, cAddressLine1, cAddressLine2, cCity, cStateCode, 
				cZipCode, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart	
			)VALUES(
				'#arguments.formdata.cFirstName#',
				 '#arguments.formdata.cLastName#',
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.PHONENUMBER1#" null="#IIF(len(arguments.formdata.PHONENUMBER1) EQ 0,'true','false')#">,
				1,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.PHONENUMBER2#" null="#IIF(len(arguments.formdata.PHONENUMBER2) EQ 0,'true','false')#">,
				5, NULL, NULL,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.CADDRESSLINE1#" null="#IIF(len(arguments.formdata.CADDRESSLINE1) EQ 0,'true','false')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.CADDRESSLINE2#" null="#IIF(len(arguments.formdata.CADDRESSLINE2) EQ 0,'true','false')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cCity#" null="#IIF(len(arguments.formdata.cCity) EQ 0,'true','false')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cStateCode#" null="#IIF(len(arguments.formdata.cStateCode) EQ 0,'true','false')#">,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cZipCode#" null="#IIF(len(arguments.formdata.cZipCode) EQ 0,'true','false')#">,				
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cComments#" null="#IIF(len(arguments.formdata.cComments) EQ 0,'true','false')#">,
				#arguments.formdata.dtAcctStamp#,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#">,
				<cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
			)	
		</CFQUERY>
  	</cffunction>
  
 
  <cffunction name="Charge" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
      <CFQUERY NAME="Charge" DATASOURCE="#arguments.datasource#">
			SELECT C.iChargeType_ID
			FROM Charges C	with (nolock)
			JOIN ChargeType CT with (nolock) ON C.iChargeType_ID = CT.iChargeType_ID
			WHERE C.iCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.chargeid#">
		</CFQUERY>
	 <cfreturn Charge> 
	</cffunction> 
  
 	<!--- Retrieve Contact information --->
 <cffunction name="Contact" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	 	
		  <CFQUERY NAME="Contact" DATASOURCE="#arguments.datasource#">
				SELECT	C.*
				FROM LinkTenantContact LTC with (nolock)
				JOIN Contact C with (nolock) ON (LTC.iContact_ID = C.iContact_ID	AND C.dtRowDeleted IS NULL)	
				WHERE LTC.dtRowDeleted IS NULL 
				and bIsMoveOutPayer  = 1
				AND iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantId#">		
				and rtrim(ltrim(c.cfirstname)) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cFirstName#">   
				and rtrim(ltrim(c.clastname)) = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.clastname#">  
			</CFQUERY>
	 <cfreturn Contact> 
	</cffunction> 
	
	
    <cffunction name="NewLinkTenantContact" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
		
	 <CFQUERY NAME="NewLinkTenantContact" DATASOURCE="#arguments.datasource#"> 	  
	     declare @count int
	
			select @count = (select count(ilinktenantcontact_id) 
			from linktenantcontact with (nolock) where dtrowdeleted is null and icontact_id = #arguments.formdata.iContact_ID# and itenant_ID=#arguments.formdata.tenantid#)
			
			<!--- if not exist (select 1 from linktenantcontact with (nolock) where dtrowdeleted is null and icontact_id = #arguments.formdata.iContact_ID# and itenant_ID=#arguments.formdata.tenantid#) --->
			if @count = 0 
			begin 
	    INSERT INTO LinkTenantContact
			(	iTenant_ID, iContact_ID, iRelationshipType_ID,   bIsPowerOfAttorney, bIsMedicalProvider, 
				cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart, bIsMoveOutPayer
			)VALUES(
				  #arguments.formdata.tenantid#,
				  #arguments.formdata.iContact_ID#, 
				  #arguments.formdata.iRelationshipType_ID#,  
				   NULL, NULL,
				 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cComments#" null="#IIF(len(arguments.formdata.cComments) EQ 0,'true','false')#">,
				 <cfqueryparam cfsqltype="cf_sql_timestamp" value=#arguments.formdata.dtAcctStamp#>,
				  <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.iRowStartUser_ID#">, 
				  <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />,
				 1
			)
			end
	  </CFQUERY>
	</cffunction> 
		
 <!---  SecondaryTenantId SQL statement --->
 <cffunction access="public" name="qDetermineRentEffective" output="false" returntype="query" hint="Gets Tenants result set from the database.">
	 <cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	 <cfargument name="SecondaryTenantId" type="numeric" required="false" >
	 
	   <cfquery name="qDetermineRentEffective" DATASOURCE="#arguments.datasource#">
			Select * from tenantstate with (nolock) where itenant_id= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.SecondaryTenantId#">
		</cfquery>
	 <cfreturn qDetermineRentEffective> 
	</cffunction> 
 
  <cffunction name="updatesecondarySwitchDate" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	
		 <CFQUERY NAME="updatesecondarySwitchDate" DATASOURCE="#arguments.datasource#" result="result">
			UPDATE tenantstate
			set dtsecondaryswitchdate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.dtChargeThroughSec#" null="#IIF(len(arguments.formdata.dtChargeThroughSec) EQ 0,'true','false')#"> 
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.formdata.SecondaryTenantId#"> 
		</CFQUERY>
 	</cffunction>  
 

  <cffunction name="UpdateCompanionSwitchDatenull" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	 
	   <CFQUERY NAME="UpdateCompanionSwitchDatenull" DATASOURCE="#arguments.datasource#">
			UPDATE tenantstate
			set  dtCompanionToFullSwitch= Null
				,dtFullToCompanionSwitch = null
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantId#"> 
		</CFQUERY>
  	</cffunction> 
 

    <cffunction name="SolomonTrans" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">

	
	   <CFQUERY NAME="SolomonTrans" DATASOURCE="#arguments.datasource#">		
			SELECT SUM(	CASE WHEN doctype in ('PA','CM') then -origdocamt ELSE origdocamt END) as Total  
			FROM ardoc with (nolock) 
			WHERE custid = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#">
			   AND doctype <> 'IN' 
			   AND User7 > = '#arguments.formdata.dtInvoiceStart#'
		</CFQUERY>
 	 <cfreturn SolomonTrans> 
	</cffunction>

 
   <cffunction name="CurrentTotal" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	 
		 <CFQUERY NAME="CurrentTotal" DATASOURCE="#arguments.datasource#">
			SELECT	round(Sum(mAmount * iQuantity),2) as Total
			FROM	InvoiceDetail with (nolock)
			WHERE	dtRowDeleted IS NULL
			AND		iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.iInvoiceMaster_ID#">
		 </CFQUERY> 
 	 <cfreturn CurrentTotal> 
	</cffunction>
 
 
    <cffunction name="TotalRefundables" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="tenantid" type="numeric" required="false" >
	
		 <CFQUERY NAME="TotalRefundables" DATASOURCE="#APPLICATION.datasource#">
			rw.sp_MoveOutDeposits #arguments.tenantid#
		 </CFQUERY>
 	 <cfreturn TotalRefundables> 
	</cffunction>
 
   <cffunction name="LastTotal" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
 
		 <CFQUERY NAME="LastTotal" DATASOURCE="#arguments.datasource#">
			SELECT	 top 1 mInvoiceTotal as Total, dtInvoiceEnd
			FROM	 InvoiceMaster	IM with (nolock)
					 JOIN InvoiceDetail INV with (nolock)	ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
			WHERE	 INV.dtRowDeleted IS NULL and IM.dtRowDeleted IS NULL and IM.bMoveOutInvoice IS NULL
					 and	IM.bFinalized IS NOT NULL 
					 and im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cSolomonKey#">
		             AND	(IM.cAppliesToAcctPeriod <= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.PastDueMonth#">   
		             OR 	(IM.cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.TipsMonth#">  
							AND IM.bMoveInInvoice IS NOT NULL))
			ORDER BY im.cAppliesToAcctPeriod desc, im.dtinvoiceend desc, im.iinvoicemaster_id desc
		</CFQUERY> 
	 <cfreturn LastTotal> 
	</cffunction>  
 
 
    <cffunction name="UpdateTotal" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
 
		 <CFQUERY NAME="UpdateTotal" DATASOURCE="#APPLICATION.datasource#">
				UPDATE	InvoiceMaster
				SET		mInvoiceTotal = #arguments.formdata.NewInvoiceTotal#,
						mLastInvoiceTotal = #arguments.formdata.LastTotal#,
						dtInvoiceStart = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.LastTotaldtInvoiceEnd#">,
						cAppliesToAcctPeriod = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.TipsMonth#">,
						dtRowStart = <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />,
						iRowStartUser_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#">						
						,cComments= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.cComments#"> 
				WHERE	dtRowDeleted IS NULL
				AND		iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.iInvoiceMaster_ID#"> 
			</CFQUERY>
     </cffunction>
 
   
 <cffunction name="qDeleteDetails" access="public" returntype="void" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">
	 
  <CFQUERY NAME="qDeleteDetails" DATASOURCE="#arguments.datasource#">
		update invoicedetail
		set dtrowdeleted= <cfqueryparam value="#CreateODBCDateTime(now())#" cfsqltype="cf_sql_timestamp" />
		,irowdeleteduser_id= <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.formdata.UserID#">
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
		where t.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.formdata.tenantId#">
	</CFQUERY> 
</cffunction>	 

 <cffunction access="public" name="getSecRate" output="false" returntype="query">
 	<cfargument name="theQuery" type="query" required="true">
 	<cfargument name="cnt" type="numeric" required="true"> 	
 	<cfquery name="qSecRate" dbType="query">
 		SELECT
 		<cfif arguments.cnt EQ 0>
 		SUM(mamount) as  mamount
 		<cfelse>
 		 mamount,iQuantity
 		</cfif> 
 		FROM arguments.theQuery
 		<cfif arguments.cnt NEQ 0>
 			WHERE cnt = #arguments.cnt#
 		<cfelse>
 			ORDER BY DTROWSTART desc
 		</cfif> 	
 	</cfquery>
 	<cfreturn qSecRate>
 </cffunction>

<cffunction name="qValidateCharge" access="public" returntype="query" output="true">
  	<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
	<cfargument name="formdata" type="struct" required="true" default="">

		<CFQUERY NAME="qValidateCharge" DATASOURCE="#arguments.datasource#">
				SELECT bIsRent, bIsMedicaid
				FROM ChargeType WHERE iChargeType_ID = #GetToken(ActualChargeType, Number, ",")#
		</CFQUERY>
	 <cfreturn qValidateCharge> 
</cffunction>

 <cffunction access="public" name="GetHistoricalRent" output="false" returntype="query">
 	<cfargument name="theQuery" type="query" required="true">

 	<cfquery name="qList" dbType="query">
 		SELECT	ProratedRent ,cDescription, iChargeType_ID, original FROM arguments.theQuery
 		 WHERE	bIsRent = 1 or ichargetype_ID in (1749,1750,44)
 	</cfquery>
 	<cfreturn qList>
 </cffunction>  

</cfcomponent> 