<!--- *********************************************************************************************
Name:       TenantInformation.cfm
Type:       Template
Purpose:    Retrieve Tenant Information


Called by: Registration.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.ID                				Tenant Index Number (auto incremented for look-up)


Calls: MoveInForm.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
	URL.ID								Tenant Index Number (auto incremented for look-up)

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
P. Buendia              08 May 01       Original Authorship
Paul Buendia            02/20/2002      Changed Contact Query to be by solomon
										key rather than tenant id. As the contact
										should be for both tenants if this is a liked
										tenant
										Added Query for second tenant information (qSecondTenantInfo)
|S Farmer    | 08/20/2014 | 116824 - back-off different move-in rent-effective dates           |
|            |            | allow adjustment of rates by all regions                           |
 |S Farmer    | 09/08/2014 | 116824             | Allow all houses edit BSF and Community Fee Rates |
| MStriegel  | 11/13/2017 | added house to the tenantInfo and WITH (NOLOCK) to all queries   |
********************************************************************************************** --->



<!--- ==============================================================================
Retrieve Tenant Information
=============================================================================== --->
<CFQUERY NAME = "TenantInfo" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct t.*, TS.*, TC.*, AD.*, AP.cDescription as RoomType, RT.cDescription as Residency, T.cComments as TenantComments
	<!--- mstriegel:11/13/2017 --->
	,h.bIsBundledPricing
	<!--- end mstriegel:11/13/2017 --->
	FROM	TENANT T WITH (NOLOCK)
	INNER JOIN 	TENANTSTATE TS WITH (NOLOCK)			ON (T.iTenant_ID = TS.iTenant_ID AND TS.dtRowDeleted IS NULL)
	INNER JOIN	TENANTSTATECODES TC WITH (NOLOCK)		ON (TS.iTenantStateCode_ID = TC.iTenantStateCode_ID AND TC.dtRowDeleted IS NULL)
	LEFT OUTER JOIN	APTADDRESS AD WITH (NOLOCK)	ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	LEFT OUTER JOIN	APTTYPE AP WITH (NOLOCK)		ON (AP.iAptType_ID = AD.iAptType_ID AND AP.dtRowDeleted IS NULL)
	INNER JOIN	ResidencyType RT WITH (NOLOCK)		ON (RT.iResidencyType_ID = TS.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
	INNER JOIN House H WITH (NOLOCK) ON h.iHouse_ID = t.iHouse_ID  <!--- mstriegel:11/13/2017 --->
	<CFIF IsDefined("url.ID") AND url.ID NEQ "">
		WHERE 	T.iTenant_ID = #url.ID#
	<CFELSE>
		WHERE	T.iTenant_ID = 0
	</CFIF>
</CFQUERY>

<CFIF  IsDefined("url.ID") AND TenantInfo.RecordCount NEQ "" AND TenantInfo.iTenant_ID NEQ "">
<!--- ==============================================================================
Retrieve Second Tenant Information (if there is any)
=============================================================================== --->
<CFQUERY NAME="qSecondTenantInfo" DATASOURCE="#APPLICATION.datasource#">
	SELECT	distinct t.*, TS.*, TC.*, AD.*, AP.cDescription as RoomType, RT.cDescription as Residency
	FROM	TENANT T WITH (NOLOCK)
	INNER JOIN 	TENANTSTATE TS	WITH (NOLOCK) ON (T.iTenant_ID = TS.iTenant_ID and TS.dtRowDeleted IS NULL)
	INNER JOIN	TENANTSTATECODES TC WITH (NOLOCK)	ON (TS.iTenantStateCode_ID = TC.iTenantStateCode_ID AND TC.dtRowDeleted IS NULL)
	INNER JOIN	ResidencyType RT WITH (NOLOCK)	ON (RT.iResidencyType_ID = TS.iResidencyType_ID AND RT.dtRowDeleted IS NULL)
	LEFT OUTER JOIN	APTADDRESS AD WITH (NOLOCK)	ON (TS.iAptAddress_ID = AD.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	LEFT OUTER JOIN	APTTYPE AP WITH (NOLOCK)	ON AP.iAptType_ID = AD.iAptType_ID 
	WHERE	T.cSolomonKey = '#TenantInfo.cSolomonKey#'
	AND		T.iTenant_ID <> #TenantInfo.iTenant_ID#
</CFQUERY>


<!--- ==============================================================================
Retrieve Contact Information
=============================================================================== --->
<!--- ==============================================================================
	<CFIF IsDefined("url.ID")>
		WHERE 	T.iTenant_ID = #url.ID#
	<CFELSE>
		WHERE	T.iTenant_ID = 0
	</CFIF>
=============================================================================== --->
<CFQUERY NAME = "CONTACTINFO" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	C.*, LTC.*, R.cDescription as Relation, LTC.bIsPayer as bIsContactPayor
	FROM TENANT T WITH (NOLOCK)
	JOIN LinkTenantContact LTC WITH (NOLOCk) ON T.iTenant_ID = LTC.iTenant_ID and ltc.dtrowdeleted is null
	JOIN CONTACT C WITH (NOLOCK) ON C.iContact_ID = LTC.iContact_ID and c.dtrowdeleted is null
	JOIN RelationShipType R WITH (NOLOCK) ON LTC.iRelationshipType_ID = R.iRelationshipType_ID and r.dtrowdeleted is null
	WHERE t.dtrowdeleted is null and T.cSolomonKey = '#trim(TenantInfo.cSolomonKey)#'
	<cfif isdefined('URL.CID')>and LTC.iContact_ID = #URL.CID#</cfif>
</CFQUERY>
</CFIF>