<cfcomponent displayname="Move in Form Services" hint="I provide all the functions for the move in form template">


	<cffunction access="public" name="getAvailableApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfset unavailableApts = getUnavailableApts(houseID=arguments.houseid)>
		<cfquery NAME="qAvailable" DATASOURCE="#arguments.datasource#">
			SELECT 	*
			FROM 	APTADDRESS AD (NOLOCK)
			JOIN 	APTTYPE AP ON (AP.iAptType_ID = AD.iAptType_ID AND AD.dtRowDeleted IS NULL)
			WHERE 	iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseid#">
			AND ad.iAptAddress_ID NOT IN (#unavailableApts#)
			ORDER BY  ad.iAptAddress_ID,cAptNumber
		</cfquery>
		<cfreturn qAvailable>
	</cffunction> 

	<cffunction access="public" name="getUnavailableApts" output="false" returntype="string">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="houseid" required="true" type="numeric">
		<cfquery name="qGetUnavailableApts" datasource="#arguments.datasource#">
			SELECT DISTINCT (ts.iAptAddress_ID), COUNT(ts.iAptAddress_ID) as cnt 
			FROM TenantState TS WITH (NOLOCK)
			INNER JOIN Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
			INNER JOIN AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
			WHERE TS.dtRowDeleted is null 
			AND	TS.iTenantStateCode_ID = 2
			AND	AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			GROUP BY ts.iAptAddress_ID
			HAVING COUNT(ts.iAptAddress_ID) > 1
		</cfquery>
		<!--- we are adding and element to the list with the value of zero to prevent an empty list and error that arise with an empty list --->
		<cfreturn ListPrepend(ValueList(qGetUnavailableApts.iAptAddress_Id),"0",",")>
	</cffunction>


	<cffunction access="public" name="getRegCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qRegCheck" datasource="#arguments.datasource#">
			select dtMoveIn 
			from tenantstate WITH (NOLOCK) 
			where dtrowdeleted is null 
			AND iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#"> 
			AND dtMoveIn is null
		</cfquery>
		<cfreturn qRegCheck>
	</cffunction>

	<cffunction access="public" name="getTenantInfo" output="false" returntype="query" hint="">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qGetTenantInfo" datasource="#arguments.datasource#">
			SELECT iTenantStateCode_ID
			,t.itenant_ID
			,cSolomonkey
			,cBillingType
			,cSLevelTypeSet
			,iResidencyType_ID
			,ts.itenantstate_id
			,cFirstName
			,cLastName
			,cSSN
			,dBirthDate
			,cOutsideAddressLine1
			,cOutsideAddressLine2
			,cOutsideCity
			,cOutsideStateCode
			,cOutsideZipCode
			,bIsPayer
			,bisprimarypayer
			,bMICheckReceived
			,cResidenceAgreement
			,cResidentFee
			,bDeferredPayment
			,bAppFeePaid
			,cMiddleInitial
			,cPreviousAddressLine1
			,cPreviousAddressLine2
			,dtBondCert
			,bIsBond
			,chasExecutor
			,ts.cMilitaryVA
			,ts.iMonthsDeferred
			,ts.mAmtDeferred
			,ts.bIsNRFDeferred
			,ts.mBaseNRF
			,ts.MADJNRF
			,cPreviousCity
			,cpreviouszipcode
			,t.ihouse_id
			,t.cchargeset
			,ts.csex
			FROM Tenant T WITH (NOLOCK)
			INNER JOIN TenantState TS WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted is null
			WHERE T.dtRowDeleted is null AND T.iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery>
		<cfreturn qGetTenantInfo>
	</cffunction>

	<cffunction access="public" name="getResetNRF" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qResetNRF" datasource="#arguments.datasource#">
			update TenantState
			set
			bIsNRFDeferred = null
			,cNRFDefApproveUser_ID  = null
			,mBaseNRF = null
			,mAdjNRF = null
			,cNRFAdjApprovedBy = null
			,dtNRFAdjApproved = null
			,iNRFMid = null
			,bNRFPend = null
			,cNRFDiscAppUsername = null
			,mAmtDeferred = null
			,iMonthsDeferred = null
			,mAmtNRFPaid = null
			,mMedicaidCopay = null
			,mBSFOrig = null
			,mBSFDisc  = null
			Where  iTenant_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
		</cfquery> 
	</cffunction>

	<cffunction access="public" name="getQryRC1740" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="qryRC1740" datasource="#arguments.datasource#">
			SELECT irecurringCharge_id 
			FROM recurringcharge rchg WITH (NOLOCK)
			INNER JOIN Charges chg WITH (NOLOCK) on rchg.icharge_id = chg.icharge_id
			WHERE chg.ichargetype_id = 1740 
			AND chg.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.houseid#"> 
			AND chg.dtrowdeleted is null 
			AND chg.cchargeset = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.cchargeset#">		
			AND rchg.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.TenantID#"> 
			AND rchg.dtrowdeleted is null
		</cfquery>
		<cfreturn qryRC1740>
	</cffunction>

	<cffunction access="public" name="getQryRC" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="qryRC" datasource="#arguments.datasource#">
			SELECT irecurringCharge_id 
			FROM recurringcharge rchg WITH (NOLOCK)
			INNER JOIN Charges chg WITH (NOLOCK) on rchg.icharge_id = chg.icharge_id
			WHERE chg.ichargetype_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.chargeTypeID#"> 
			AND chg.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.houseid#"> 
			AND chg.dtrowdeleted is null 
			AND chg.cchargeset = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.theData.cchargeset#">		
			AND rchg.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.TenantID#"> 
			AND rchg.dtrowdeleted is null
		</cfquery>
		<cfreturn qryRC>
	</cffunction>

	<cffunction access="public" name="getDelNRFhg" output="false" returntype="void">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfargument name="todaysDate" type="date" required="false" default="#CreateODBCDateTime(now())#">
		<cfquery datasource="#arguments.datasource#">
			UPDATE RecurringCharge
			SET dtRowDeleted = <cfqueryparam cfsqltype="cf_sql_date" value="#arguments.todaysdate#">
			    ,iRowDeletedUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.userID#"> 
			WHERE iRecurringCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.recurringChargeID#">
			AND iTenant_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.theData.tenantID#">
		</cfquery>
	</cffunction>

	<cffunction access="public" name="getDiagnosisType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfquery name="qGetDiagnosisType" datasource="#arguments.datasource#">
			SELECT idiagnosistype_id, cdescription 
			FROM diagnosistype WITH (NOLOCK)
			WHERE dtRowDeleted is null	
		</cfquery>
		<cfreturn qGetDiagnosisType>
	</cffunction>

	<cffunction access="public" name="getTenantPromotion" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfquery name="qGetTenantPromotion" datasource="#arguments.datasource#">
			SELECT iPromotion_ID, cDescription 
			FROM TenantPromotionSet WITH (NOLOCK)
			WHERE dtRowDeleted is null
		</cfquery>
		<cfreturn qGetTenantPromotion>
	</cffunction>

	<cffunction access="public" name="getqProductline" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qProductLine" datasource="#arguments.datasource#">
			select pl.iproductline_id, pl.cdescription
			from houseproductline hpl WITH (NOLOCK)
			inner join productline pl on pl.iproductline_id = hpl.iproductline_id AND pl.dtrowdeleted is null
			where hpl.dtrowdeleted is null AND hpl.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qProductLine>
	</cffunction>

	<cffunction access="public" name="getHouseDetail" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qGetHouseDetail" datasource="#arguments.datasource#">
			select st.bIsMedicaid StateMedicaid
				, h.bIsMedicaid HouseMedicaid
				, h.cstatecode 
				,chgs.cName ChargeSet
				, h.ihouse_id
				,hm.mStateMedicaidAmt_BSF_Daily
				,hm.mStateMedicaidAmt_BSF_Monthly
				,hm.mMedicaidBSF
				,hm.mMedicaidCopay
			from House h WITH (NOLOCK)
			inner join statecode st WITH (NOLOCK) on h.cstatecode = st.cstatecode
			inner join ChargeSet chgs WITH (NOLOCK) on h.iChargeSet_ID = chgs.iChargeSet_ID
			left join HouseMedicaid hm WITH (NOLOCK) on  hm.ihouse_id = h.ihouse_id
			where h.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> 
			AND chgs.dtRowDeleted is null 
			AND h.dtrowdeleted is null
			AND hm.dtrowdeleted is null
		</cfquery>
		<cfreturn qGetHouseDetail>
	</cffunction>

	<cffunction access="public" name="getResidency" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">
		<cfquery name="residency" datasource="#application.datasource#">
			SELECT rt.iresidencytype_id ,rt.cdescription 
			FROM houseproductline hpl WITH (NOLOCK)
			INNER JOIN productline pl WITH (NOLOCK) on pl.iproductline_id = hpl.iproductline_id AND pl.dtrowdeleted is null
			INNER JOIN ProductLineResidencyType plrt WITH (NOLOCK) on plrt.iproductline_id = pl.iproductline_id AND plrt.dtrowdeleted is null
			INNER JOIN residencytype rt WITH (NOLOCK) on rt.iresidencytype_id = plrt.iresidencytype_id AND rt.dtrowdeleted is null
			WHERE hpl.dtrowdeleted is null AND hpl.ihouse_id = <cfqueryparam cfsqltype="cf_sql_Integer" value="#arguments.theData.houseID#">
			AND hpl.iproductline_id=1
			<cfif #arguments.theData.StateMedicaid# eq 1 AND #arguments.theData.HouseMedicaid#  eq 1>
				AND rt.iresidencytype_id in (1,2,3)
			<cfelse>
				AND rt.iresidencytype_id in (1,3)
			</cfif>
		</cfquery>
		<cfreturn residency>
	</cffunction>

	<cffunction access="public" name="getResidencyMemoryCare" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="theData" type="struct" required="true">

		<cfquery name="residency" datasource="#application.datasource#">
			SELECT rt.iresidencytype_id ,rt.cdescription 
			FROM houseproductline hpl WITH (NOLOCK)
			INNER JOIN productline pl WITH (NOLOCK) on pl.iproductline_id = hpl.iproductline_id AND pl.dtrowdeleted is null
			INNER JOIN ProductLineResidencyType plrt WITH (NOLOCK) on plrt.iproductline_id = pl.iproductline_id AND plrt.dtrowdeleted is null
			INNER JOIN residencytype rt WITH (NOLOCK) on rt.iresidencytype_id = plrt.iresidencytype_id AND rt.dtrowdeleted is null
			WHERE hpl.dtrowdeleted is null AND hpl.ihouse_id = <cfqueryparam cfsqltype="cf_sql_Integer" value="#arguments.theData.houseID#">
			AND hpl.iproductline_id=2
			<cfif #arguments.theData.StateMedicaid# neq 1 AND #arguments.theData.HouseMedicaid#  neq 1>
				AND rt.iresidencytype_id not in (2)			
			</cfif>

		</cfquery>
		<cfreturn residency>
	</cffunction>


	<cffunction access="public" name="getAppPoints" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfquery name="qAppPoints" datasource="#arguments.datasource#">
			SELECT distinct am.iSPoints
			FROM assessmenttoolmaster am WITH (NOLOCk)
			Where am.dtrowdeleted is null
			AND am.bfinalized = 1
			AND am.bBillingActive = 1
			AND itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#trim(arguments.tenantID)#">
		</cfquery>
		<cfreturn qAppPoints>
	</cffunction>

	<cffunction access="public" name="getPriorMI" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="tenantID" type="numeric" required="true">
		<cfargument name="solKey" type="string" required="true">
		<cfquery name='qPriorMI' datasource="#APPLICATION.datasource#">
			select distinct im.iinvoicemaster_id
			from invoicemaster im WITH (NOLOCK)
			left join invoicedetail inv WITH (NOLOCK) on inv.iinvoicemaster_id = im.iinvoicemaster_id 
			AND  im.dtrowdeleted is null 
			AND inv.dtrowdeleted is null 
			AND inv.itenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.tenantID#">
			where im.bmoveininvoice is not null 
			AND im.bfinalized is null 
			AND im.csolomonkey = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.solKey#">
		</cfquery>
		<cfreturn qPriorMI>
	</cffunction>

	<cffunction access="public" name="getRespiteChargec" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
			<cfquery name="qRespiteChargeCheck" datasource="#APPLICATION.datasource#">
				Select iCharge_ID 
				From Charges 
				Where dtRowDeleted is null AND ihouse_ID = <cfqueryparam cfsqltype="cf_sql_Integer" value="#arguments.houseID#"> 
				AND iResidencyType_ID = 3
			</cfquery>
		<cfreturn qRespiteChargeCheck>
	</cffunction>

	<cffunction access="public" name="getNRFDef" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfquery name="qNRFDef" datasource="#arguments.datasource#">
			SELECT nEmployeeNumber
				,nDepartmentNumber
				,LName
				,FName
				,MName
				,JobTitle
				,Fname + ' ' +  Lname as 'FullName'
			FROM  ALCWeb.dbo.Employees WITH (NOLOCK) 
			WHERE JobTitle like '%President%' or JobTitle like '%Regional Manager%' AND dtrowdeleted is null
		</cfquery>
		<cfreturn qNRFDef>
	</cffunction>
	
	<cffunction access="public" name="getVADef" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfquery name="qryVADef" datasource="#arguments.datasource#">
			SELECT nEmployeeNumber
			      ,nDepartmentNumber
			      ,LName
			      ,FName
			      ,MName
			      ,JobTitle
				  ,Fname + ' ' +  Lname as 'FullName'
			FROM  ALCWeb.dbo.Employees WITH (NOLOCK)
			WHERE JobTitle like '%President%'   AND dtrowdeleted is null
		</cfquery>
		<cfreturn qryVADef>
	</cffunction>

	<cffunction access="public" name="getNRF" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
	
		<cfquery NAME="qGetNRF" DATASOURCE="#APPLICATION.datasource#"> 
			select c.mamount as NRF 
			from Charges c 
			inner join ChargeType ct on (ct.iChargeType_ID = c.iChargeType_ID)
			where c.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND c.cChargeSet = (select cs.cName 
								from Chargeset cs WITH (NOLOCK)
								inner join House h WITH (NOLOCK) on (h.iChargeSet_ID = cs.iChargeSet_ID AND h.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">))
			AND c.dtRowDeleted is null
			AND c.iChargeType_ID   in (69)
			AND c.bIsMoveInCharge = 1
		</cfquery>

		<cfreturn qGetNRF>
	</cffunction>

	<cffunction access="public" name="getHouseLog" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qHouseLog" datasource="#arguments.datasource#">
			SELECT bIsPDClosed 
			FROM HouseLog WITH (NOLOCK) 
			WHERE iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND dtRowDeleted is null
		</cfquery>
		<cfreturn qHouseLog>
	</cffunction>

	<cffunction access="public" name="getHouseDeposits" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qHouseDeposits" datasource="#APPLICATION.datasource#">
			select ct.* from ChargeType ct WITH (NOLOCK)
			join Charges C WITH (NOLOCK) on (c.iChargeType_ID = ct.iChargeType_ID AND c.dtRowDeleted is null)
			where ct.dtRowDeleted is null AND bIsDeposit is not null AND c.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qHouseDeposits>
	</cffunction>

	<cffunction access="public" name="getRefundables" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="codeBlock" type="string" required="true">
		<cfargument name="houseDepositRC" type="numeric" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		
		<cfquery name="qRefundables" datasource="#arguments.datasource#">
			SELECT ct.*, c.cDescription as cDescription, c.iCharge_ID
			FROM ChargeType ct WITH (NOLOCK)
			INNER JOIN Charges C WITH (NOLOCK) on (c.iChargeType_ID = ct.iChargeType_ID AND c.dtRowDeleted is null)
			WHERE ct.dtRowDeleted is null
			AND bIsDeposit is not null
			AND getdate() between c.dteffectivestart AND c.dteffectiveend
			AND	bIsRefundable is not null
			<cfif FindNoCase(25, arguments.CodeBlock, 1) eq 0>
			AND bAcctOnly is null
			</cfif>	
			<cfif arguments.HouseDepositRC GT 0>
				AND	c.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			<cfelse> 
				AND c.iHouse_ID is null
			</cfif>
			AND c.iChargeType_ID not in (53, 83)
		</cfquery>
		<cfreturn qRefundables>
	</cffunction>

	<cffunction access="public" name="getFees" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="codeBlock" type="string" required="true">
		<cfargument name="houseDepositRC" type="numeric" required="true">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qFees" datasource="#arguments.datasource#">
			select ct.*, c.cDescription as cDescription, c.iCharge_ID
			from ChargeType ct WITH (NOLOCK)
			join Charges C WITH (NOLOCK) on (c.iChargeType_ID = ct.iChargeType_ID and c.dtRowDeleted is null)
			where ct.dtRowDeleted is null and bIsDeposit is not null
			and getdate() between c.dteffectivestart and c.dteffectiveend
			and	bIsRefundable is null
			<cfif FindNoCase(25, arguments.CodeBlock, 1) eq 0>
			AND bAcctOnly is null
			</cfif>	
			<cfif arguments.HouseDepositRC GT 0>
				AND	c.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			<cfelse> 
				AND c.iHouse_ID is null
			</cfif>			
		</cfquery>
		<cfreturn qFees>
	</cffunction>
	
	<cffunction access="public" name="getAvailableCharges" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfargument name="chargeID"  required="false" default="">
		<cfquery name="qAvailableCharges" datasource="#arguments.datasource#">
			select c.*, ct.bIsModifiableDescription, ct.bIsModifiableAmount, ct.bIsModifiableQty
			from Charges c WITH (NOLOCK)
			join 	ChargeType ct WITH (NOLOCK) on c.iChargeType_ID = ct.iChargeType_ID
			where (iHouse_ID is null or c.iHouse_ID= <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">)
			and	c.dtRowDeleted is null and c.mAmount < 1
			<cfif arguments.chargeID NEQ ""> 
				and c.iCharge_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.chargeID#"> 
			</cfif>
		</cfquery>
		<cfreturn qAvailableCharges>
	</cffunction>

	<cffunction access="public" name="getBondHouse" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qBondHouse" datasource="#application.datasource#">
			select iBondHouse, bBondHouseType, iSecurityDeposit, bIsMedicaid,bIsMemorycare 
			from house WITH (NOLOCK)  
			where ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		 </cfquery>
		<cfreturn qBondHouse>
	</cffunction>

	<cffunction access="public" name="getOccupied" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qryGetOccupied" datasource="#arguments.datasource#">
			select distinct TS.iAptAddress_ID 
			from TenantState TS WITH (NOLOCK)
			inner join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
			inner join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
			where TS.dtRowDeleted is null 
			and	TS.iTenantStateCode_ID = 2
			and	AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qryGetOccupied>
	</cffunction>

	<cffunction access="public" name="getOccupiedNonCompanion" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qOccupiedNonCompanion" datasource="#APPLICATION.datasource#">
			select distinct TS.iAptAddress_ID 
			from TenantState TS WITH (NOLOCK)
			inner join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
			inner join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
			inner join apttype at WITH (NOLOCK) on at.iapttype_ID= ad.iapttype_ID and at.dtrowdeleted is null
			where TS.dtRowDeleted is null 
			and	TS.iTenantStateCode_ID = 2
			and at.biscompanionSuite <>1
			and	AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qOccupiedNonCompanion>
	</cffunction>

	<cffunction access="public" name="getBondAppAptList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfquery name="qBondAppAptList" datasource="#APPLICATION.datasource#">
			select aa.*,at1.*
			from AptAddress aa WITH (NOLOCK)
			join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
			where aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and aa.bBondIncluded = 1
			and aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qBondAppAptList >
	</cffunction>

	<cffunction access="public" name="getBondAptList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qBondAptList" datasource="#APPLICATION.datasource#">
			select aa.*,at1.* 
			from AptAddress aa WITH (NOLOCK)
			inner join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
			where aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and aa.bIsBond = 1
			and aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qBondAptList>
	</cffunction>

	<cffunction access="public" name="getBAptCount" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qBAptCount" datasource="#APPLICATION.datasource#">
			select count(AA.iAptAddress_ID) as B 
			from AptAddress AA WITH (NOLOCK)
			where AA.bIsBond = 1
			and AA.dtrowdeleted is null
			and AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qBAptCount>
	</cffunction>

	<cffunction access="public" name="getAptCountTot" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qGetAptCountTot" datasource="#arguments.datasource#">
			select count(AA.iAptAddress_ID) as T 
			from AptAddress AA WITH (NOLOCK)
			where AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and AA.bBondIncluded = 1
			and AA.dtrowdeleted is null
		</cfquery>
		<cfreturn qGetAptCountTot >
	</cffunction>

	<cffunction access="public" name="getOccupiedApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfquery name="qGetOccupiedApt" datasource="#arguments.datasource#">
			select distinct TS.iAptAddress_ID
			from TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS 
			join TIPS4.dbo.Tenant T on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
			join TIPS4.dbo.AptAddress AD on AD.iAptAddress_ID = TS.iAptAddress_ID 
				and AD.dtRowDeleted is null
			where TS.dtRowDeleted is null
			and TS.iTenantStateCode_ID = 2
			and AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and TS.iAptAddress_ID = aa.iAptAddress_ID 
			and te.iTenant_ID = ts.iTenant_ID
			and aa.bBondIncluded = 1
		</cfquery>
		<cfreturn qGetOccupiedApt>
	</cffunction>

	<cffunction access="public" name="getMedicaidAptList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfset unavailableApts = getUnavailableApts(houseID=arguments.houseid)>
		<cfquery name="qgetMedicaidAptList" datasource="#arguments.datasource#">
			select aa.*,at1.* 
			from AptAddress aa WITH (NOLOCK)
			inner join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
			where aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND aa.iAptAddress_ID NOT IN (#unavailableApts#)
			and aa.bIsMedicaidEligible = 1		
		</cfquery>
		<cfreturn qgetMedicaidAptList>
	</cffunction>

	<cffunction access="public" name="getMedicaidBondApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfquery name="qGetMedicaidbondApt" datasource="#arguments.datasource#">
			select aa.*,at1.* 
			from AptAddress aa WITH (NOLOCK)
			join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
			where aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and aa.bIsMedicaidEligible = 1
			and aa.bIsbond=1
			and aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qGetMedicaidbondApt>
	</cffunction>

	<cffunction access="public" name="getMedicaidbondincludedApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qGetMedicaidbondincludedApt" datasource="#arguments.datasource#">
			select aa.*,at1.* 
			from AptAddress aa WITH (NOLOCK)
			join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
			where aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_interger" value="#arguments.houseID#">
			and aa.bIsMedicaidEligible = 1
			and aa.bbondIncluded=1
			and aa.dtRowDeleted is null
		</cfquery>
		<cfreturn qGetMedicaidbondincludedApt >
	</cffunction>

	<cffunction access="public" name="getMedicaidAptCount" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfquery name="qGetMedicaidAptCount" datasource="#arguments..datasource#">
			select count(AA.iAptAddress_ID) as TotalMedicaidApt 
			from AptAddress AA  WITH (NOLOCK)
			where AA.bIsMedicaidEligible = 1
			and AA.dtrowdeleted is null
			and AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qGetMedicaidAptCount>
	</cffunction>

	<cffunction access="public" name="getMedicaidAptCountTot" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="HouseID" type="numeric" required="true">
		<cfquery name="qGetAptCountTotal" datasource="#arguments.datasource#">
			select count(AA.iAptAddress_ID) as T 
			from AptAddress AA WITH (NOLOCK)
			where AA.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and AA.dtrowdeleted is null
		</cfquery>
		<cfreturn qGetAptCountTotal>
	</cffunction>

	<cffunction access="public" name="getOccupiedMedicaidApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qGetOccupiedMedicaidApt" datasource="#arguments.datasource#">
			select distinct TS.iAptAddress_ID 
			from TenantState TS WITH (NOLOCK)
			join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
			join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID 
			and AD.dtRowDeleted is null
			where TS.dtRowDeleted is null 
			and	TS.iTenantStateCode_ID = 2
			and AD.Bismedicaideligible=1
			and	AD.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qGetOccupiedMedicaidApt>
	</cffunction>

	<cffunction access="public" name="getDiagnosis" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfquery name="qDiagnosis" datasource="#arguments.datasource#">
		    Select idiagnosistype_id, cdescription 
			From diagnosistype WITH (NOLOCK)
			Where dtRowDeleted is null	
		</cfquery>
		<cfreturn qDiagnosis>
	</cffunction>

	<cffunction access="public" name="getMemCareAptList" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfset unavailableApts = getUnavailableApts(houseID=arguments.houseid)>
		<cfquery name="qGetMemCareAptList" datasource="#arguments.datasource#">
			select aa.*,at1.* 
			from AptAddress aa WITH (NOLOCK)
			join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
			where aa.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			AND aa.iAptAddress_ID NOT IN (#unavailableApts#)
			and aa.bIsmemorycareeligible = 1
			and aa.dtRowDeleted is null	
		</cfquery>
		<cfreturn qGetMemCareAptList>
	</cffunction>

	<cffunction access="public" name="getOccupiedMemcareApt" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qGetOccupiedMemcareApt" datasource="#arguments.datasource#">
			select distinct TS.iAptAddress_ID 
			from TenantState TS WITH (NOLOCK)
			inner join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
			inner join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID 
			and AD.dtRowDeleted is null
			where TS.dtRowDeleted is null 
			and	TS.iTenantStateCode_ID = 2
			and AD.bIsMemoryCareEligible=1
	    	and	AD.iHouse_ID = <Cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
		</cfquery>
		<cfreturn qGetOccupiedMemcareApt>
	</cffunction>

	<cffunction access="public" name="getAptType" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qGetAptType" datasource="#arguments.datasource#">
			select  aa.iAptAddress_ID ,
			aa.iAptType_ID, aa.cAptNumber
			,chg.mamount
			,at.cdescription
			,chg.ichargetype_id
			,ct.cdescription
			  from charges  chg WITH (NOLOCK)
			join house h WITH (NOLOCK) on chg.ihouse_id = h.ihouse_id
			join chargeset chgst WITH (NOLOCK) on h.ichargeset_id = chgst.ichargeset_id
			join dbo.AptAddress AA WITH (NOLOCK) on aa.ihouse_id = chg.ihouse_id
			join dbo.AptType AT WITH (NOLOCK) on aa.iAptType_ID = at.iAptType_ID
			join dbo.ChargeType ct WITH (NOLOCK) on ct.ichargetype_id = chg.ichargetype_id
			where chg.ihouse_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#"> and chg.cchargeset = chgst.cname 
			and chg.ichargetype_id in (7, 8,31,89)
			and chg.dtrowdeleted is null
			and aa.dtrowdeleted is null
		</cfquery>
		<cfreturn qGetAptType>
	</cffunction>


	<cffunction access="public" name="getRespiteChargeCheck" output="false" returntype="query">
		<cfargument name="datasource" type="string" required="false" default="#application.datasource#">
		<cfargument name="houseID" type="numeric" required="true">
		<cfquery name="qRespiteChargeCheck" datasource="#arguments.datasource#">
			Select iCharge_ID 
			From Charges 
			Where dtRowDeleted is null and ihouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.houseID#">
			and iResidencyType_ID = 3
		</cfquery>
		<cfreturn qRespiteChargeCheck>
	</cffunction>

	<cffunction access="public" name="getBundledPricingHouses" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfquery name="qGetBundledPricingHouses" datasource="#arguments.datasource#">
			SELECT iHouse_ID
			FROM House WITH (NOLOCK)
			WHERE bIsBundledPricing =1
		</cfquery>
		<cfreturn qGetBundledPricingHouses>
	</cffunction>

	<cffunction access="public" name="getMCO" output="false" returntype="query">
		<cfargument name="datasource" required="false" type="string" default="#application.datasource#">
		<cfargument name="statecodeID" required="true" type="string">
		<cfquery name="qMCO" datasource="#arguments.datasource#">
			select * 
			from MCOProvider 
			where cStateCode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.statecodeID#">
		</cfquery>
		<cfreturn qMCO>
	</cffunction>

</cfcomponent>