<cfcomponent displayname="Move in Credit Services" hint="I provide all the functions for the move in credits template">

	<cffunction access="public" name="getTenantType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qtenantype" datasource="#arguments.datasource#">
			Select ts.iresidencytype_id, t.ihouse_id, ts.dtmovein, h.cname
				, rt.cdescription,ts.iproductline_id ,ts.iResidencyType_ID
				, t.cbillingtype, ts.iAptAddress_ID,h.bIsMemoryCare,ts.dtrenteffective
				,h.isecuritydeposit, chgst.cname cchargeset
				,t.cfirstname + ' ' + t.clastname as 'Resident',
				pl.cDescription as 'ProductDesc',
				rt.cDescription as 'ResidentDesc'
			FROM tenant t WITH (NOLOCK) 
			INNER JOIN tenantstate ts WITH (NOLOCK) on t.itenant_id = ts.itenant_id
			INNER JOIN house h WITH (NOLOCK) on t.ihouse_id = h.ihouse_id
			INNER JOIN residencytype rt WITH (NOLOCK) on ts.iresidencytype_id = rt.iResidencyType_ID
			INNER JOIN chargeset chgst WITH (NOLOCK) on h.ichargeset_id = chgst.ichargeset_id
			INNER JOIN productline pl WITH (NOLOCK) on ts.iProductLine_ID = pl.iProductLine_ID
			WHERE t.itenant_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>		
		<cfreturn qtenantype>
	</cffunction>

	<cffunction access="public" name="getHouseChargeset" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qryHouseChargeset" datasource="#arguments.datasource#">
			SELECT chgs.cName as  'ChargeSet'
			FROM house h WITH (NOLOCK) 
			INNER JOIN Chargeset chgs WITH (NOLOCK) on h.ichargeset_id = chgs.ichargeset_id
			WHERE h.ihouse_id = <Cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qryHouseChargeset>
	</cffunction>

	<cffunction access="public" name="getMedicaidHouse" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qryMedicaidHouse" datasource="#arguments.datasource#">
			SELECT * 
			FROM HouseMedicaid WITH (NOLOCK) 
			WHERE iHouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<Cfreturn qryMedicaidHouse>		
	</cffunction>

	<cffunction access="public" name="getFindOccupancy" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="AddressID" type="numeric" required="true">
		<cfargument name="TenantID" type="numeric" required="true">
		<cfquery name="qFindOccupancy" datasource="#arguments.datasource#">
			SELECT t.iTenant_ID, iResidencyType_ID, ST.cDescription as Level, ts.dtMoveIn, ts.dtMoveOut
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

	<cffunction access="public" name="getIsCompanion" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="addressID" type="numeric" required="true">		
		<cfquery name="qrybiscompanion" datasource="#arguments.datasource#">
			SELECT * 
			FROM aptaddress ad WITH (NOLOCK) 
			INNER JOIN apttype at WITH (NOLOCK) on ad.iapttype_ID= at.iapttype_ID
			AND ad.iaptaddress_ID= <Cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.addressID#">
		</cfquery>
		<cfreturn qrybIsCompanion>
	</cffunction>

	<cffunction access="public" name="getHouseCommunityFee" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qryHouseCommunityFee" datasource="#arguments.datasource#">
			SELECT mamount 
			FROM charges chg WITH (NOLOCK)
			INNER JOIN house h WITH (NOLOCK) on h.ihouse_id = chg.ihouse_id
			INNER JOIN chargeset chgset WITH (NOLOCK) on h.ichargeset_id = chgset.ichargeset_id
			WHERE chg.cchargeset = chgset.cdescription
			AND h.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND chg.ichargetype_id = 69
			AND chg.dtrowdeleted is null 
			AND chgset.dtrowdeleted is null
		</cfquery>
		<cfreturn qryHouseCommunityFee>
	</cffunction>

	<cffunction access="public" name="getAptType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		 <cfquery name="qryAptType" datasource="#arguments.datasource#">
			SELECT  aa.iAptAddress_ID ,
				aa.iAptType_ID, aa.cAptNumber
				,chg.mamount
				,at.cdescription
				,chg.ichargetype_id
				,ct.cdescription
				,ct.bResidencyType_ID
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig				
			FROM tenant t WITH (NOLOCK)
			INNER JOIN  tenantstate ts WITH (NOLOCK) on t.itenant_id = ts.itenant_id
			INNER JOIN house h WITH (NOLOCK) on t.ihouse_id = h.ihouse_id
			INNER JOIN chargeset chgst WITH (NOLOCK) on h.ichargeset_id = chgst.ichargeset_id
			INNER JOIN dbo.AptAddress AA WITH (NOLOCK) on aa.iAptAddress_id = ts.iAptAddress_id
			INNER JOIN dbo.AptType AT WITH (NOLOCK) on aa.iAptType_ID = at.iAptType_ID
			INNER JOIN charges chg WITH (NOLOCK) on chg.iAptType_ID = at.iAptType_ID AND chg.ihouse_id = t.ihouse_id
			INNER JOIN dbo.ChargeType ct WITH (NOLOCK) on ct.ichargetype_id = chg.ichargetype_id 
			INNER JOIN opsarea ops WITH (NOLOCK) on h.iopsarea_id = ops.iopsarea_id
			WHERE chg.ihouse_id = t.ihouse_id 
			AND chg.cchargeset = chgst.cname 
			AND ts.itenant_id =  <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND chg.dtrowdeleted is null
			AND aa.dtrowdeleted is null
			AND ct.bisdaily is null
			AND aa.dtrowdeleted is null
			AND chg.iresidencytype_id = ts.iresidencytype_id
		</cfquery>
		<cfreturn qryAptType>
	</cffunction>

	<cffunction access="public" name="getAptType1" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="bIsCompanion" type="numeric" required="true">
		<cfargument name="productLineID" type="numeric" required="true">
		<cfquery name="qryAptType" datasource="#arguments.datasource#">
			SELECT 
				chg.mamount
				,chg.ichargetype_id
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig	
			FROM tenant t 
			INNER JOIN  tenantstate ts on t.itenant_id = ts.itenant_id
			INNER JOIN house h on t.ihouse_id = h.ihouse_id
			INNER JOIN chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
			INNER JOIN opsarea ops on h.iopsarea_id = ops.iopsarea_id
			INNER JOIN charges chg on chg.ihouse_id = t.ihouse_id  AND chg.cchargeset = chgst.cname
			INNER JOIN dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
			INNER JOIN dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID AND at.iapttype_ID= #qrybiscompanion.iapttype_ID#
			<cfif arguments.biscompanion EQ 0>
				AND chg.ioccupancyposition = 2
			</cfif>
			<cfif arguments.productLineID eq 2>
				AND chg.ichargetype_ID=1748
			</cfif>
			WHERE t.itenant_id =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">	
		</cfquery>	
		<cfreturn qryAptType>
	</cffunction>

	<cffunction access="public" name="getAptType2" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		 <cfquery name="qryAptType" datasource="#arguments.datasource#">
			SELECT  aa.iAptAddress_ID ,
				aa.iAptType_ID, aa.cAptNumber
				,chg.mamount
				,at.cdescription
				,chg.ichargetype_id
				,ct.cdescription
				,ct.bResidencyType_ID
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig
			FROM tenant t 
			INNER JOIN  tenantstate ts on t.itenant_id = ts.itenant_id
			INNER JOIN house h on t.ihouse_id = h.ihouse_id
			INNER JOIN chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
			INNER JOIN dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
			INNER JOIN dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID
			INNER JOIN charges chg on chg.iAptType_ID = at.iAptType_ID AND chg.ihouse_id = t.ihouse_id
			INNER JOIN dbo.ChargeType ct on ct.ichargetype_id = chg.ichargetype_id 
			INNER JOIN opsarea ops on h.iopsarea_id = ops.iopsarea_id
			WHERE chg.ihouse_id = t.ihouse_id 
			AND chg.cchargeset = chgst.cname 
			AND   ts.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
			AND chg.dtrowdeleted is null
			AND aa.dtrowdeleted is null
			AND ct.ichargetype_id = case when (ts.iresidencytype_id = 1) then 89 
										when (ts.iresidencytype_id = 3) then 7 
										when (ts.iresidencytype_id = 5) then   89
										else  31 
									end
			AND aa.dtrowdeleted is null
			AND chg.iresidencytype_id = ts.iresidencytype_id
		</cfquery>
		<cfreturn qryAptType>
	</cffunction>

	<cffunction access="public" name="getAptType3" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">			
		<cfquery name="qryAptType" datasource="#arguments.datasource#">  
			SELECT  aa.iAptAddress_ID 
				,aa.iAptType_ID
				,aa.cAptNumber
				,chg.mamount
				,at.cdescription
				,chg.ichargetype_id
				,ct.cdescription
				,ct.bResidencyType_ID
				,ops.cname as 'Region' 
				,ts.iresidencytype_id 
				,ts.mBSFOrig
			FROM tenant t 
			INNER JOIN  tenantstate ts on t.itenant_id = ts.itenant_id
			INNER JOIN house h on t.ihouse_id = h.ihouse_id
			INNER JOIN chargeset chgst on h.ichargeset_id = chgst.ichargeset_id
			INNER JOIN dbo.AptAddress AA on aa.iAptAddress_id = ts.iAptAddress_id
			INNER JOIN dbo.AptType AT on aa.iAptType_ID = at.iAptType_ID
			INNER JOIN charges chg on  chg.ihouse_id = t.ihouse_id
			INNER JOIN dbo.ChargeType ct on ct.ichargetype_id = chg.ichargetype_id 
			INNER JOIN opsarea ops on h.iopsarea_id = ops.iopsarea_id
			WHERE chg.ihouse_id = t.ihouse_id 
			AND chg.cchargeset = chgst.cname 
			AND   ts.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
			AND chg.dtrowdeleted is null
			AND aa.dtrowdeleted is null
 			AND ct.ichargetype_id = case when (ts.iresidencytype_id = 1) then 89 
										 when (ts.iresidencytype_id = 3) then 7 
										 else   31 
									end  
			AND aa.dtrowdeleted is null
		</cfquery>
		<cfreturn qryAptType>
	</cffunction>

	<cffunction access="public" name="updTenantStateBSF" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
	
		<cfquery name="UpdateTenantStateBSF" datasource="#arguments.datasource#">			
			update TenantState 
			set mBaseNRF = <cfqueryparam cfsqltype="cf_sql_money" value="#VAL(arguments.theData.mBaseNRF)#">,
			    mBSFOrig =  <cfqueryparam cfsqltype="cf_sql_money" value="#VAL(arguments.theData.mBSFOrig)#">
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.tenantID#">
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="getSecDep" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">		
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="chargeset" type="string" required="true">
		<cfquery name="qSocDep" datasource="#arguments.datasource#">
			SELECT mamount
			FROM Charges 
			WHERE iChargeType_ID = 53
			AND iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.chargeset#">
		</cfquery>	
		<cfreturn qSocDep>
	</cffunction>

	<cffunction access="public" name="getInvoiceMaster" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="invoiceDetailID" type="numeric" required="true">
		<cfquery name="qryInvoiceMaster" datasource="#arguments.datasource#">
			SELECT iinvoicemaster_id 
			FROM invoicedetail
			WHERE iInvoiceDetail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoiceDetailID#">
		</cfquery>
		<cfreturn qryInvoiceMaster>
	</cffunction>

	<cffunction access="public" name="updInvoiceDetail" output="false" returntype="void" hint="I update the invoicedetail table with the new amounts for  Assissted Living R&B rates">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">	
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="id" type="numeric" required="true">
		<cfquery name="UpdateInvoiceDetail" datasource="#arguments.datasource#">			
			UPDATE InvoiceDetail 
			SET mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#ReplaceNoCase(ReplaceNoCase(arguments.amount,'$','ALL'),',','ALL')#">
			WHERE  dtrowdeleted is null		
			AND ichargetype_id in (7,89)	
			AND iinvoicemaster_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">			
		</cfquery>			
	</cffunction>

	<cffunction access="public" name="updMCInvoiceDetail" output="false" returntype="void" hint="I update the invoicedetail table with the new amounts for Memory Care R&B Rates">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="formData" type="struct" required="true">
		<cfquery name="qMCInvoiceDetailCurr" datasource="#arguments.datasource#">
			<cfloop from="1" to="#arguments.formdata.totalCount#" index="elem">
			<cfset tempAmt = Evaluate("arguments.formData.amount#elem#")>
			<cfset tempID = Evaluate("arguments.formData.invoiceid#elem#")>
				UPDATE InvoiceDetail
				SET mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#tempAmt#">
				WHERE iInvoiceDetail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#tempID#">
			</cfloop>		
		</cfquery>	
	</cffunction>


	<cffunction access="public" name="updNewAmt" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="mBSFDisc" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="UpdateNewAmtDetail" datasource="#arguments.datasource#">
			update TenantState 
			set mBSFDisc = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.mBSFDisc#">
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantid#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getTenantMonDef" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qTenantMonDef" datasource="#arguments.datasource#">
			SELECT  ts.iMonthsDeferred
			FROM tenant t 
			INNER JOIN tenantstate ts on t.itenant_id = ts.itenant_id
			WHERE t.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
		<cfreturn qTenantMonDef>
	</cffunction>

	<cffunction access="public" name="getRecurrChg" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="chargeSet" type="string" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qryRecurrChgNewDef" DATASOURCE='#arguments.datasource#'>
			Select irecurringCharge_id from recurringcharge rchg
			join Charges chg on rchg.icharge_id = chg.icharge_id
			where chg.ichargetype_id = 1741 
			AND chg.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			AND chg.dtrowdeleted is null 
			AND chg.cchargeset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.chargeset#">
			AND rchg.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
			AND rchg.dtrowdeleted is null
		</cfquery>	
		<cfreturn qryRecurrChgNewDef>
	</cffunction>

	<cffunction access="public" name="updInvoiceDetails" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="mAmount" type="numeric" required="true" >
		<cfargument name="id" type="numeric" required="true">
		<cfquery name="UpdateInvoiceDetail" datasource="#arguments.datasource#">
			set LOCK_TIMEOUT 60000		
			update InvoiceDetail 
			set mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#VAL(arguments.mAmount)#">
			where dtrowdeleted is null
			AND iInvoiceDetail_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">
		</cfquery>	
	</cffunction>

	<cffunction access="public" name="updNewNRFAmt" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="mAdjNRF" type="numeric" required="true">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="UpdateNewNRFAMt" datasource="#arguments.datasource#">
 			set LOCK_TIMEOUT 60000		
			update TenantState 
			set mAdjNRF = <cfqueryparam cfsqltype="cf_sql_money" value="#VAL(arguments.mAdjNRF)#">
			,mAmtDeferred = 0
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>			
	</cffunction>

	<cffunction access="public" name="updNewDeferred" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="mAmtDeferred" type="numeric" required="true">
		<cfquery name="updNewDeferred"  datasource="#arguments.datasource#">
			update TenantState 
			set mAmtDeferred = <cfqueryparam cfsqltype="cf_sql_money" value="#VAL(arguments.mAmtDeferred)#">
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="updNewDeferredRC" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="recurringID" type="numeric" required="true">
		<cfquery name="updNewDeferred"  datasource="#arguments.datasource#">
			update RecurringCharge   
			set mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#VAL(arguments.amount)#">
			where irecurringCharge_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.recurringID#"> 
		</cfquery>		
	</cffunction>

	<cffunction access="public" name="updNewDeferredTS" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="updNewDeferred"  datasource="#arguments.datasource#">
			update TenantState 
			set iMonthsDeferred = 1
			where itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getSLevel" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="points" type="numeric" required="true">
		<cfargument name="LevelTypeSet" type="numeric" required="true">
		<cfargument name="sLevelTypeSet" type="numeric" required="true">
		<cfquery NAME = "GetSLevel" DATASOURCE = "#arguments.datasource#">
			SELECT 	* 
			FROM 	SLevelType
			WHERE	dtRowDeleted IS NULL
			AND		iSPointsMin <= <cfqueryparam cfsqltype="cf_sql_integer" Value="#arguments.points#"> AND iSPointsMax >= <cfqueryparam cfsqltype="cf_sql_integer" Value="#arguments.points#">
			AND	cSLevelTypeSet	= 
			<CFIF arguments.LevelTypeSet NEQ 0>
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.LevelTypeSet#"> 
			<CFELSE> 
				<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.sLevelTypeSet#"> 
			</CFIF>	
		</cfquery>
		<cfreturn GetSLevel>
	</cffunction>

	<cffunction access="public" name="getMoveInInvoice" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery NAME="qMoveInInvoice" DATASOURCE="#arguments.datasource#">
			SELECT	distinct IM.iInvoiceMaster_ID as Master_ID
			FROM	InvoiceDetail INV
			JOIN 	InvoiceMaster IM	ON	INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
			WHERE	iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND	INV.dtRowDeleted IS NULL AND IM.bMoveInInvoice IS NOT NULL 
			AND IM.dtRowDeleted IS NULL AND IM.bFinalized IS NULL
		</cfquery>
		<cfreturn qMoveInInvoice>
	</cffunction>

	<cffunction access="public" name="getCommFeeInvoiceCount" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="Id" type="numeric" required="true">
		<CFQUERY NAME="qCommFeeInvoiceCount" DATASOURCE="#arguments.datasource#">
			SELECT	count( IM.iInvoiceDetail_id) as EntryCount, IM.ichargetype_id
			FROM	InvoiceDetail IM
			WHERE	IM.iInvoiceMaster_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.id#">
			AND	 IM.dtRowDeleted IS NULL AND IM.ichargetype_id in (53, 69) 
			group by IM.ichargetype_id
		</CFQUERY> 
		<cfreturn qCommFeeInvoiceCount>
	</cffunction>

	<cffunction access="public" name="getInvoiceDetail" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">
		<cfargument name="residentTypeID" type="numeric" required="true">
		<CFQUERY NAME="qGetInvoiceDetail" DATASOURCE="#arguments.datasource#">
			SELECT  Day(eomonth(DateFromParts(Left(inv.cAppliesToAcctPeriod,4),Right(inv.cAppliesToAcctPeriod,2),01))) as  daysInMonth,
			CASE WHEN (Month(ts.dtRentEffective) = RIGHT(inv.cAppliesToAcctPeriod,2))
				 THEN (day(eomonth(ts.dtRentEffective)) - day(ts.dtRentEffective)+1)
				 ELSE  day(eomonth(DateFromParts(LEFT(inv.cAppliesToAcctPeriod,4),RIGHT(inv.cAppliesToAcctPeriod,2),01)))
			END as dayToCharge,
			INV.*, T.cFirstName, T.cLastName, CT.cGLAccount, ts.dtmovein, ts.dtRentEffective
			FROM InvoiceMaster IM WITH (NOLOCK)
 			INNER JOIN InvoiceDetail inv WITH (NOLOCK) on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 	
 			AND inv.dtRowDeleted is null 
 			AND IM.dtRowDeleted is null 
 			AND IM.bMoveInInvoice is not null 	
 			AND IM.bMoveOutInvoice is null 
 			AND IM.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">	
			INNER JOIN	ChargeType CT WITH (NOLOCK)	ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
			LEFT JOIN	Tenant T WITH (NOLOCK)	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
			INNER JOIN tenantstate ts WITH (NOLOCK) on t.itenant_id = ts.itenant_id
			<cfif FindNoCase(arguments.residentTypeID,"1,3",1) NEQ 0>
			where INV.iChargeType_ID not in (1741)  
			</cfif>
			ORDER BY CASE WHEN(ct.iChargeType_ID = 1748 OR ct.iChargeType_ID = 89)
						  THEN 1
						  ELSE 2
					 END, INV.cAppliesToAcctPeriod
		</CFQUERY>
		<cfreturn qGetInvoiceDetail>	
	</cffunction>


	<cffunction access="public" name="getCollectedApplicationFee" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">
		<CFQUERY NAME = "qCollectedApplicationFee" DATASOURCE = "#arguments.datasource#">
			SELECT 	*
			FROM DepositLog DL (nolock)
			JOIN Tenant T (nolock) on T.iTenant_ID = DL.iTenant_ID		
			AND	DL.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">			
			AND DL.iDepositType_ID = 6	
			WHERE DL.dtRowDeleted IS NULL 
			AND T.dtRowDeleted IS NULL
		</CFQUERY>
		<cfreturn qCollectedApplicationFee>
	</cffunction>

	<cffunction access="public" name="getNRF" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentID" type="numeric" required="true">
		<CFQUERY NAME="qGetNRF" DATASOURCE="#arguments.datasource#"> 
			SELECT	INV.mAmount as 'NRFee'
			FROM InvoiceMaster IM WITH (NOLOCK)
			INNER JOIN InvoiceDetail inv WITH (NOLOCK) on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
			AND inv.dtRowDeleted is null
			AND IM.dtRowDeleted is null	AND IM.bMoveInInvoice is not null 
			AND IM.bMoveOutInvoice is null
			AND IM.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.residentID#">	
			INNER JOIN ChargeType CT WITH (NOLOCK)	ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL AND CT.iChargeType_ID in (53, 69)
			LEFT JOIN Tenant T WITH (NOLOCK)	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
		 	ORDER BY INV.iTenant_ID DESC, INV.cAppliesToAcctPeriod
		</CFQUERY>
		<cfreturn qGetNRF>
	</cffunction>

	<cffunction access="public" name="getDailyRent" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="query" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="occupancy" type="numeric" required="true">
		<cfquery name="qDailyRent" datasource="#arguments.datasource#">
			<cfif arguments.Occupancy EQ 1>
				select c.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
				from Charges C
				inner join ChargeType ct on (CT.iChargeType_ID = c.iChargeType_ID AND ct.dtRowDeleted is null)
				where c.dtRowDeleted is null
				AND ct.bIsRent is not null
				AND ct.bIsDiscount is null AND ct.bIsRentAdjustment is null AND ct.bIsMedicaid is null
				<cfif arguments.theData.iResidencyType_ID EQ 3>
					AND (C.iAptType_ID is null or c.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_Id#">)
				<cfelse>
					AND ct.bAptType_ID is not null 
					AND ct.bIsDaily is not null
					AND ct.bSLevelType_ID is null
				</cfif>
					AND c.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_id#">
					AND c.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
					AND c.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_Id#">
	            	AND c.iOccupancyPosition = 1 
					AND dtEffectiveStart <= getDate() AND dtEffectiveEnd >= getDate()
				<cfif arguments.theData.cChargeSet neq '' AND arguments.theData.iResidencyType_ID neq 3>
					AND c.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#">
				<cfelse>
					AND c.cChargeSet is null
				</cfif>
				AND c.iProductLine_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart Desc
			<cfelse>  
				select c.cDescription ,C.mAmount ,C.iQuantity ,CT.iChargeType_ID
				from Charges C
				join ChargeType ct on (CT.iChargeType_ID = c.iChargeType_ID AND ct.dtRowDeleted is null)
				where c.dtRowDeleted is null
				AND ct.bIsRent is not null
				AND ct.bIsDiscount is null 
				AND ct.bIsRentAdjustment is null 
				AND ct.bIsMedicaid is null				
				AND ct.bIsDaily is not null 
				AND ct.bSLevelType_ID is null
				<cfif arguments.theData.iResidencyType_ID EQ 3>
					AND (C.iAptType_ID is null or c.iAptType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iAptType_Id#">)
				<cfelse>
					AND c.iAptType_ID is null
				</cfif>
				AND c.iResidencyType_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iResidencyType_Id#">
				AND c.iOccupancyPosition = 2
				AND c.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
				AND dtEffectiveStart <= getDate() 
				AND dtEffectiveEnd >= getDate()					
				<cfif arguments.theData.cChargeSet neq '' >				
					AND c.cChargeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cChargeSet#">				
				</cfif>
				AND c.iProductLine_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.iProductLine_ID#">
				order by c.dtRowStart Desc
			</cfif>	
		</cfquery>	
		<cfreturn qDailyRent>
	</cffunction>

	<cffunction access="public" name="getHouseMedicaid" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qryHouseMedicaid" datasource="#arguments.datasource#">
			Select mMedicaidBSF, mStateMedicaidAmt_BSF_Daily 
			from HouseMedicaid 
			where ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qryHouseMedicaid>
	</cffunction>


	<cffunction access="public" name="GetNewInvoiceDetail" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="residentId" type="numeric" required="true">
		<CFQUERY NAME="qGetNewInvoiceDetail" DATASOURCE="#arguments.datasource#">
			SELECT	sum(inv.mamount * inv.iquantity) as MedInvTotal
			from InvoiceMaster IM
			join InvoiceDetail inv on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID 
			AND inv.dtRowDeleted is null
			AND IM.dtRowDeleted is null	
			AND im.bfinalized is null
			AND IM.bMoveInInvoice is not null 
			AND IM.bMoveOutInvoice is null
			AND IM.cSolomonKey = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.residentId#">	
			LEFT JOIN	Tenant T	ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL
			join tenantstate ts on t.itenant_id = ts.itenant_id
			where inv.ichargetype_id not in (8,1749,1750)
		</CFQUERY>
		<cfreturn qGetNewInvoiceDetail>
	</cffunction>

	<cffunction access="public" name="getDepositLogCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="desc" type="string" required="true">
		<cfargument name="amount" type="numeric" required="true">
		<CFQUERY NAME="qDepositLogCheck" DATASOURCE="#arguments.datasource#">
			SELECT *
			FROM DepositLog DL (nolock)
			INNER JOIN DepositType DT (nolock) on DT.iDepositType_ID = DL.iDepositType_ID
			AND DL.dtRowDeleted is null 
			AND DT.dtRowDeleted is null
			AND iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			AND cDescription = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.desc#">
			AND DT.mAmount = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">
		</CFQUERY>
		<cfreturn qDepositLogCheck>
	</cffunction>

	<cffunction access="public" name="getQryMonth" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="acctPeriod" type="string" required="true">
		<cfquery name="qryMonth" dbtype="query">
			select iquantity 
			from GetInvoiceDetail 
			where ichargetype_id = 8 
			AND cappliestoacctperiod = '#GetInvoiceDetail.cAppliesToAcctPeriod#'
		</cfquery>
	</cffunction>

	<cffunction access="public" name="updAdjBSF" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="amount" type="numeric" required="true">
		<cfargument name="invoicedetailID" type="numeric" required="true">
		<cfquery name="updAdjBSF" datasource="#arguments.datasource#">
			update invoicedetail
			set mamount = <cfqueryparam cfsqltype="cf_sql_money" value="#arguments.amount#">
			where  iinvoicedetail_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.invoicedetailID#">
		</cfquery>	
	</cffunction>

	<cffunction access="public" name="getAdditional" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="sLevelType" type="string" required="true">
		<cfargument name="chargeSet" type="string" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="codeblock" type="string" required="true">
		<cfargument name="qryData" type="query" required="true">
		<cfargument name="frmData" type="struct" required="true">
		<CFQUERY NAME = "qGetAdditional" DATASOURCE = "#arguments.datasource#">
			SELECT C.cDescription, C.ICHARGE_ID,C.MAMOUNT, CT.BISMODIFIABLEDESCRIPTION, CT.BISMODIFIABLEAMOUNT,
			       CT.BISMODIFIABLEQTY, C.IQUANTITY, CT.iChargeType_ID
			FROM Charges C WITH (NOLOCK)
			INNER JOIN  ChargeTYPE CT WITH (NOLOCK)	ON C.iChargeType_ID = CT.iChargeType_ID AND CT.dtrowdeleted is NULL
			LEFT OUTER JOIN	SLevelType ST ON C.iSLevelType_ID = ST.iSLevelType_ID AND (ST.cSLevelTypeSet = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.sLevelType#"> OR cSLevelTypeSet IS NULL)	
			WHERE C.dtRowDeleted IS NULL 
			AND CT.bIsMoveIn = 1
			AND c.cchargeset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.chargeset#">
			AND	(C.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseId#"> OR C.iHouse_ID IS NULL) 
			AND CT.cGLAccount <> 1030			
			<CFIF ListFindNoCase(arguments.codeblock,23) EQ 0> 
				AND CT.bAcctOnly is null 
				<CFIF arguments.qryData.iResidencyType_ID EQ 2>				
					AND (bIsRent is null or (bIsRent is not null AND bIsMedicaid is not null) or ct.cgrouping = 'PM')
					AND (CT.bAcctOnly is null or (bIsRent is not null AND bIsMedicaid is not null))
				<CFELSE>
					AND (CT.bIsRent is null or ct.cgrouping = 'PM') AND CT.bAcctOnly IS NULL 
				</CFIF>				
				AND CT.bIsRentAdjustment IS NULL
			<CFELSE>
				AND	(bIsRent IS NULL or (bIsRent is not null AND bIsMedicaid is not null) or bisrentadjustment is not null or bisdiscount is not null or ct.cgrouping = 'PM')
			</CFIF>
			AND CT.iChargeType_ID <> 1740  
			AND CT.iChargeType_ID <> 1741 	
			AND	C.dtRowDeleted is null AND dtEffectiveStart <= getDate() AND dtEffectiveEnd >= getDate()
			<CFIF IsDefined("arguments.frmData.iCharge_ID") AND arguments.frmData.iCharge_ID NEQ ""> 
				AND iCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.frmData.iCharge_ID#">
			</CFIF>
			ORDER BY C.cDescription	
		</CFQUERY>
		<cfreturn qGetAdditional>
	</cffunction>

	<cffunction access="public" name="getInvoiceDetailMC" output="false" returntype="query">
		<cfargument name="theQuery" type="query" required="true">

		<cfquery name="qGetInvoiceDetailMC" dbtype="query">
		   SELECT *
		   FROM arguments.theQuery
		   WHERE iChargeType_ID = 1748 
		</cfquery>
		<cfreturn qGetInvoiceDetailMC>
	</cffunction>

</cfcomponent>
