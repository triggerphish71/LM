


<CFQUERY NAME = "SolomonKeyList" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	cSolomonKey, cFirstName, cLastName, TS.iTenantStateCode_ID
	FROM	TENANT T
			JOIN TenantState TS ON TS.iTenant_ID = T.iTenant_ID
	WHERE	TS.dtRowDeleted IS NULL
	AND		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		T.dtRowDeleted IS NULL
	AND		T.bIsMedicaid IS NULL
	AND		T.bIsMisc IS NULL
	AND		T.bIsDayRespite IS NULL
</CFQUERY>