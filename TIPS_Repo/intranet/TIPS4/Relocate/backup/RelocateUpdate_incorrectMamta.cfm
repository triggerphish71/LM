<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|Update of TenantMissingItems table, which is suppose to run nightly according to project 20125|
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|-----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
|ssanipina   | 06/30/2008 |   Added the flower box                                               |
|Ssanipina   | 09/17/2008 | Rectified the total tenant with missing item                         |
|Ssathya     | 11/10/2008 | Project 30178 the guaranter agreement is been added                  |
|sathya      | 09/09/2010 | Project 60038 changes for Contract Management which was rename later |
|                           as Care Management                                                   |
|SFarmer     | 09/29/2015 | ts.bContractManagementAgreement replaced by ts.bMoveInSummary        |
|------------------------------------------------------------------------------------------------>

<cfparam name="APPLICATION.datasource" default="TIPS4">

<cfquery name="getHouseInfo" datasource="#APPLICATION.datasource#">
	select h.ihouse_id,h.cname as HouseName,
	R.iRegion_ID ,R.cName as Division , OA.cName as  Region,oa.iOPSArea_id
	from House h 
	JOIN OpsArea OA on(OA.iOpsArea_ID = h.iOpsArea_ID) and OA.dtrowdeleted is null
	JOIN  Region R ON (R.iRegion_ID = OA.iRegion_ID) and R.dtrowdeleted is null
	where h.dtrowdeleted is null
	ORDER BY H.ihouse_id
</cfquery>

<!---<cftry>--->
	<cfloop query="getHouseInfo">
		<cfquery name="qResidentTenants" datasource="#application.datasource#">
			select t.ihouse_id as houseid, t.iTenant_ID
			from tenant t
			join	TenantState ts  on ts.itenant_id = t.itenant_id
			where t.ihouse_id = #getHouseInfo.iHouse_ID#
			and ts.iTenantStateCode_ID = 2
			and t.dtrowdeleted is null
			and ts.dtrowdeleted is null
		</cfquery>
		
		<cfset variables.House = getHouseInfo.iHouse_ID>
		<cfset variables.MissingCountfordatadump =0>
		<cfset variables.TotalTenantInHouse =0>
		<cfset variables.totalSSNCount = 0>
		<cfset variables.totalVAMilitaryCount =0>
		<cfset variables.totalResidenceAgreementCount =0>
		<cfset variables.totalBondHouseAgreementCount = 0>
		<cfset variables.totalDOBCount =0>
		<cfset variables.totalContactIsGuaranterCount = 0>
		<cfset variables.totalContractManagement = 0>
		<cfset variables.totalMoveInSummary = 0>	
		
		<cfloop query="qResidentTenants">
			<cfif qResidentTenants.itenant_id neq "">
				<cfset variables.TotalTenantInHouse = variables.TotalTenantInHouse +1>
					<cfquery name="MissingItems" datasource="#application.datasource#">
						select distinct 
						CASE WHEN len(isnull(t.cssn,1)) < 9 or len(isnull(t.cssn,1)) = 10 or len(isnull(t.cssn,1)) > 11 
							or (len(isnull(t.cssn,1)) = 9 and isnull(t.cssn,1) not LIKE '%[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%')
							or (len(isnull(t.cssn,1)) = 11 
							and isnull(t.cssn,1) not LIKE '%[0-9][0-9][0-9][-/ ][0-9][0-9][-/ ][0-9][0-9][0-9][0-9]%')
								THEN 1 ELSE 0 end as SSN,
						CASE WHEN t.dbirthDate is null THEN 1 ELSE 0 end as DOB, 
						CASE WHEN t.cResidenceAgreement is null THEN 1 ELSE 0 end  as Residency_Agreement,
						CASE WHEN ts.cMilitaryVA is null THEN 1 ELSE 0 end as VA_Military,
						CASE WHEN (select ibondhouse from house  where ihouse_id = #variables.House# and bisSandbox = 0)=1 
							and (select cBondHouseEligible from tenantstate where itenant_id = #qResidentTenants.itenant_id# 
							and dtrowdeleted is null) is null 
							THEN 1 ELSE 0 end as Bond_House,
						CASE WHEN isnull(lt2.bIsPayer,0) = 1 and lt2.bIsGuarantorAgreement is null  THEN 1 ELSE 0 end  Guarantor_Agreement,
						CASE WHEN isnull(ts.bMoveInSummary,0)= 0 THEN 1 ELSE 0 end as MoveIn_Summary
						from tenant t
						 left join Tenantstate ts  on ts.iTenant_ID = t.iTenant_ID and ts.dtrowdeleted is null and ts.itenantstatecode_id = 2
						 left join TenantPromotionSet TPS on (ts.cTenantPromotion = TPS.iPromotion_ID)
						 left join (select itenant_id,bIsGuarantorAgreement,bIsPayer from  LinkTenantContact 
							where itenant_id = #qResidentTenants.itenant_id# and bIsPayer = 1 and dtrowdeleted is null) lt2 on lt2.Itenant_id = t.itenant_id  
						where t.itenant_id = #qResidentTenants.itenant_id#
						and t.dtrowdeleted is null
					</cfquery>
					 
					<cfif MissingItems.SSN GT 0> <cfset variables.totalSSNCount = variables.totalSSNCount + MissingItems.SSN></cfif>
					<cfif MissingItems.DOB GT 0><cfset variables.totalDOBCount = variables.totalDOBCount + MissingItems.DOB></cfif>
					
				<cfif MissingItems.Residency_Agreement GT 0>	<cfset variables.totalResidenceAgreementCount = variables.totalResidenceAgreementCount + MissingItems.Residency_Agreement> </cfif>
					
				<cfif MissingItems.VA_Military GT 0>	<cfset variables.totalVAMilitaryCount = variables.totalVAMilitaryCount + MissingItems.VA_Military> </cfif>
					
				<cfif MissingItems.Bond_House GT 0>	<cfset variables.totalBondHouseAgreementCount = variables.totalBondHouseAgreementCount + MissingItems.Bond_House> </cfif>
					
				<cfif MissingItems.Guarantor_Agreement GT 0>	<cfset variables.totalContactIsGuaranterCount = variables.totalContactIsGuaranterCount + MissingItems.Guarantor_Agreement> </cfif>
					
				<cfif MissingItems.MoveIn_Summary GT 0>	<cfset variables.totalMoveInSummary = variables.totalMoveInSummary + MissingItems.MoveIn_Summary> </cfif>
					
					<cfset variables.MissingCountfordatadump = variables.totalSSNCount + variables.totalDOBCount + 
						variables.totalResidenceAgreementCount + variables.totalVAMilitaryCount +
						variables.totalBondHouseAgreementCount + variables.totalContactIsGuaranterCount + variables.totalContractManagement>
						
			</cfif>
		</cfloop>
		
	
		<cfquery name="MissingItemsDetails" datasource="#application.datasource#">
			select ihouse_id from TenantmissingItems where ihouse_id = #getHouseInfo.iHouse_ID#	
		</cfquery>
		
		<cfif MissingItemsDetails.ihouse_id eq "">
            <cfquery name="InsertMissingItems" datasource="#application.datasource#">
                insert into TenantMissingItems
                ( ihouse_id,HouseName,iRegion_Id,Division,iOpsArea_ID,Region
                ,TenantWithMissingItems,dtRowStart,TotalTenantInHouse
                ,cSsnMissing,VAMilitaryMissing
                ,cResidentAgreementMissing,cBondHouseAgreement,cBirthDateMissing,iGuarantorAgreement
                ,iMoveInSummary
                )values(
                    #getHouseInfo.iHouse_ID#, 
                     '#getHouseInfo.HouseName#',
                     #getHouseInfo.iRegion_ID#,
                    '#getHouseInfo.Division#',
                     #getHouseInfo.iOPSArea_id#,
                    '#getHouseInfo.Region#',
                    #variables.MissingCountfordatadump#,			 
                    getDate(),
                    #variables.TotalTenantInHouse#,
                    #variables.totalSSNCount#,
                    #variables.totalVAMilitaryCount#,
                    #variables.totalResidenceAgreementCount#,
                    #variables.totalBondHouseAgreementCount#,
                    #variables.totalDOBCount#,
                    #variables.totalContactIsGuaranterCount#,
                    #variables.totalMoveInSummary#
                )
             </cfquery>
		<cfelse>

			<cfquery name="UpdateMissingItems" datasource="#application.datasource#">
				UPDATE
				TenantMissingItems
				SET
				HouseName='#getHouseInfo.HouseName#'
				,iRegion_Id = #getHouseInfo.iRegion_ID#
				,Division= '#getHouseInfo.Division#'
				,iOpsArea_ID=#getHouseInfo.iOPSArea_id#
				,Region ='#getHouseInfo.Region#'
				,TenantWithMissingItems =#variables.MissingCountfordatadump#
				,dtRowStart =getDate()
				,TotalTenantInHouse=#variables.TotalTenantInHouse#
				,cSsnMissing =#variables.totalSSNCount#
				,cResidentAgreementMissing =#variables.totalResidenceAgreementCount#
				,cBirthDateMissing=#variables.totalDOBCount#
				,VAMilitaryMissing=#variables.totalVAMilitaryCount#
				,cBondHouseAgreement=#variables.totalBondHouseAgreementCount#
				,iGuarantorAgreement=#variables.totalContactIsGuaranterCount#
				,iMoveInSummary = #variables.totalMoveInSummary#
				WHERE ihouse_id =#getHouseInfo.iHouse_ID#	
			</cfquery>
		</cfif>
		</cfloop>
		complete task
		<cfmail to="Mshah@enlivant.com" from="Mshah@enlivant.com" subject="Failure of Schedule process for Missing Tenant Items" type="html"> 
			<cfdump var='#qResidentTenants#'>
		</cfmail> 
<!---	<cfcatch type = "DATABASE">
		 <cftransaction action = "rollback"/>
	<cfmail to="tbates@enlivant.com,gthota@enlivant.com,mshah@enlivant.com" from="TIPS-Message@alcco.com" subject="Failure of Schedule process for Missing Tenant Items" type="html">
	<!---	<cfmail to="gthota@enlivant.com" from="TIPS4@alcco.com" subject="Failure of Schedule process for Missing Tenant Items" type="html">  --->
			The schedules process for Missing Tenant Items has failed to run.This process updates the 
			MissingTenantItems table in TIPS database for TIPS application. Check ScheduledTasks/ActionFiles/Act_UpdateTenantMissingItems.cfm for more details.
		</cfmail> 
		<cfabort>
	</cfcatch>
</cftry>--->
