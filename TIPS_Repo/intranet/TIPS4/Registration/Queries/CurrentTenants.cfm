

<CFQUERY NAME = "Current" DATASOURCE = "Census">
	SELECT	* 
	FROM	tenants
	WHERE	nhouse = 2000 
		AND	tenant_status_id = 2003
</CFQUERY>