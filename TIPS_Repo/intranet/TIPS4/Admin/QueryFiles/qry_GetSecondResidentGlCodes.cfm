<cfquery name="GetSecondResidentGlCodes" datasource="#application.datasource#">
	SELECT TOP 1
		 cSecondResidentGlCode
		,cSecondResidentDiscountGlCode
	FROM
		SecondResidentGlLookup
	ORDER BY
		iSecondResidentGlLookup_ID DESC
</cfquery>