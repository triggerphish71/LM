<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Main page for Payment Plans                                                                  |
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
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 01/01/2007 | created                                                            |
| mlaw       | 02/28/2007 | Exclude empty rooms                                                |
----------------------------------------------------------------------------------------------->
<!--- Get All the existing Tenants --->

<cfquery name="GetAllTenants" datasource="#application.datasource#">
	select 
		distinct 
		a.cAptNumber 
		, a.iAptType_ID
		, t.iTenant_ID
		, t.cLastName
		, t.cFirstName
		, rt.cDescription 
		, H.cName as HouseName
		, pp.bisPaymentPlan as PaymentPlan
	from 
		AptAddress a (nolock)
	left join houseproductline hpl (nolock) 
		on hpl.ihouseproductline_id = a.ihouseproductline_id 
		and hpl.dtrowdeleted is null
	left join productline pl (nolock) 
		on pl.iproductline_id = hpl.iproductline_id 
		and pl.dtrowdeleted is null
	left join TenantState ts (nolock) 
		on a.iAptAddress_ID = ts.iAptAddress_ID 
		and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID = 2 and ts.dtRowDeleted is null)		
	left outer join AptType APT (nolock) 
		on (apt.iAptType_ID = a.iAptType_ID 
		and apt.dtRowDeleted is null)
	left join Tenant t (nolock) 
		on (t.iTenant_ID = ts.iTenant_ID)
	left join    
		 House H on H.ihouse_id = t.ihouse_id    
	left join	ResidencyType RT (nolock) 
		on (rt.iResidencyType_ID = ts.iResidencyType_ID)
	left join SLevelType ST (nolock) 
		on (t.cSlevelTypeSet = st.cSlevelTypeSet and ts.iSPoints <= iSPointsMax and ts.iSPoints >= iSPointsMin)
	left join TenantPaymentPlan pp
		on pp.iTenant_ID = t.itenant_ID
		and pp.dtrowdeleted is NULL
	where	
		a.dtRowDeleted is null	
		and a.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		and t.dtRowDeleted is null
		and (ts.iTenantStateCode_ID IN (2))			
</cfquery>