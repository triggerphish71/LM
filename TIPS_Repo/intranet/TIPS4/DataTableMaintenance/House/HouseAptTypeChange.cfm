<!----------------------------------------------------------------------------------------------------------------
--- mstriegel: 11/14/2017: added logic for bundled pricing and added with (nolock) to all queries            ---

------------------------------------------------------------------------------------------------------------------>

<CFOUTPUT>
	

	#form.fieldnames#<BR>

	#form.iAptAddress_ID# = ID<BR>
	#form.NewAptType# = iAptType_ID<BR>

<!--- ==============================================================================
Update the room type for the chosen room//mamta added both cfif to update medicaid
=============================================================================== --->	
<CFTRANSACTION>
<!---mamta added query to update the prodctline with memorycare--->
	<CFQUERY NAME='MemoryCareHouseProductLine' DATASOURCE='#APPLICATION.datasource#'>
		Select * from houseproductline WITH (NOLOCK) where ihouse_ID= #SESSION.qSelectedHouse.iHouse_ID# and iproductline_ID=2 and dtrowdeleted is null
	</CFQUERY>
	<CFQUERY NAME='AssistedLivingHouseProductLine' DATASOURCE='#APPLICATION.datasource#'>
		Select * from houseproductline WITH (NOLOCK) where ihouse_ID= #SESSION.qSelectedHouse.iHouse_ID# and iproductline_ID=1 and dtrowdeleted is null
	</CFQUERY>
	
	<CFQUERY NAME='qUpdateAptType' DATASOURCE='#APPLICATION.datasource#' result="result">
		UPDATE 	APTADDRESS
		SET		<cfif #form.NewAptType# NEQ 'none'>
		        iAptType_ID = #form.NewAptType#,
				</cfif>
				dtRowStart  = GetDate(),
				iRowStartUser_ID = #SESSION.USERID#,
				<cfif isDefined("form.bIsMedicaidEligible")>
				bIsMedicaidEligible = 1,
				<cfelse> 
				bIsMedicaidEligible = null,
				</cfif>	
				<!---added ihouseproductline_ID -mamta--->
				<cfif isDefined("form.bIsMemoryCareEligible") and MemoryCareHouseProductLine.recordcount gt 0>
				bIsMemoryCareEligible = 1
				,ihouseproductline_ID= #MemoryCareHouseProductLine.ihouseproductline_ID#
				<cfelse> 
				bIsMemoryCareEligible = null
				,ihouseproductline_ID= #AssistedLivingHouseProductLine.ihouseproductline_ID#
				</cfif>
	
		WHERE	iAptAddress_ID = #form.iAptAddress_ID#
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<!---=================================================================================
	mamta-update the companionswitch in tenantstate table if the room type is	changing from full 
	to companion or viceversa /compare the #form.NewAptType# and #qGetHouseApts.bIsCompanionSuite#and =====================================--->
	<!---write a query to find newapt type biscompanionsuite--->
	<CFQUERY NAME='qnewapttypeiscompanion' DATASOURCE='#APPLICATION.datasource#'>
	select AT.bIsCompanionSuite
	from AptAddress AA WITH (NOLOCK)
	inner join AptType AT WITH (NOLOCK) ON AA.iAptType_ID = AT.iAptType_ID
	where AA.iAptAddress_ID = #form.iAptAddress_ID#
	</CFQUERY>
	<!---write a query to update the comapnion switch of the tenant staying in this suite--->
	<CFQUERY NAME='qtenantstateIDofApt' DATASOURCE='#APPLICATION.datasource#'>
	Select itenantState_ID from tenantstate  WITH (NOLOCK)
							where iAptAddress_ID = #form.iAptAddress_ID#
							and dtmoveout is null
							and itenantStateCode_ID=2
							and dtrowdeleted is null
	</cfquery>
	<cfloop query="qtenantstateIDofApt">
		<cfif #qtenantstateIDofapt.itenantState_ID# neq "">
			<cfif #form.bIsCompanionSuite# eq 1 and #qnewapttypeiscompanion.bIsCompanionSuite# eq 0>
			<CFQUERY NAME='qUpdateCompaniontoFullSwitch' DATASOURCE='#APPLICATION.datasource#' result='recordcount'>
			UPDATE TenantState
			SET dtCompanionToFullSwitch= #createodbcdatetime(now())# 
			WHERE itenantState_ID= #qtenantstateIDofApt.itenantState_ID#
			</CFQUERY>
			</cfif>
			<cfif #form.bIsCompanionSuite# eq 0 and #qnewapttypeiscompanion.bIsCompanionSuite# eq 1>
			<CFQUERY NAME='qUpdateFulltoCompanionSwitch' DATASOURCE='#APPLICATION.datasource#' result='recordcount'>
			UPDATE TenantState
			SET dtFulltoCompanionSwitch= #createodbcdatetime(now())#
			WHERE itenantState_ID= #qtenantstateIDofApt.itenantState_ID#
			</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	
	
	<!---<cfoutput> new apt type #form.NewAptType# and  is comapanion suite #form.bIsCompanionSuite#
	 newapttypeIscompanion value #qnewapttypeiscompanion.bIsCompanionSuite# </cfoutput>	mamta end--->

	<!--- mstriegel:11/14/2017 Bundled pricing update I check to see if the house has bundled pricing.
		   if so, then we need to check if the apt is studio or not. If it is update the tenantState
		   table with bIsBundled = 0 else bIsBundled = NULL.	
	--->	
	<cfif form.NewAptType NEQ "none">
	 <cfif isdefined("form.hasBundledPricing") AND  hasBundledPricing NEQ "" >

	 	<cfquery name="updateTenantStateBundledPricing" datasource="#application.datasource#">
	 	 if exists (Select 1 from aptType WITH (NOLOCK) where iAptType_ID =<cfqueryparam cfsqltype="cf_sql_integer" value="#VAL(form.NewAptType)#"> AND cDescription LIKE '%studio%')
	 	 	BEGIN
			 	UPDATE TenantState
		 		SET bIsBundled = 0
		 		WHERE iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.iAptAddress_ID#">
		 		AND dtMoveOut IS NULL
		 		AND dtRowDeleted IS NULL
	 		END
	 	ELSE
	 		BEGIN
	 			UPDATE TenantState
		 		SET bIsBundled = NULL
		 		WHERE iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.iAptAddress_ID#">
		 		AND dtMoveOut IS NULL
		 		AND dtRowDeleted IS NULL	 		
		 	END
	 	</cfquery>
	 
	 <cfelse>
	 	<cfquery name="updateTEnantStateBundledPricing" datasource="#application.datasource#">
			UPDATE TenantState
	 		SET bIsBundled = null
	 		WHERE iAptAddress_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.iAptAddress_ID#">
	 		AND dtMoveOut IS NULL
	 		AND dtRowDeleted IS NULL
	 	</cfquery>
	 </cfif> 
	</cfif>
	 <!--- end mstriegel:11/14/2017 --->
</CFTRANSACTION>

<CFIF IsDefined("SESSION.USERID") AND SESSION.USERID EQ 3025123>
	<A HREF="#HTTP.REFERER#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#HTTP.REFERER#" addtoken="false">
</CFIF>

</CFOUTPUT>