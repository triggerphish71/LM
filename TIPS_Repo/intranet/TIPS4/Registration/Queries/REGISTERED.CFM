


<CFQUERY NAME="REGISTERED" DATASOURCE="CENSUS" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
	SELECT 		* 
	FROM 		TENANTS 
	WHERE 		NHOUSE = 2000 
			AND TENANT_STATUS_ID = 2002 
		<cfif isdefined("form.dayrespite")>
			OR 	PAYTYPE = 'Day Respite'
		</cfif>
		<CFIF ISDEFINED("form.previoustenants")>
			OR (nUnitNumber = 998 AND nhouse = 2000 and dMoveOut > '1999-01-01')
		</CFIF>
</CFQUERY>