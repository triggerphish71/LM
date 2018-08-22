

<CFQUERY NAME="Cash" DATASOURCE="Census" DBTYPE="ODBC">
	SELECT 		* 
	FROM 		TenantTransactions
	WHERE		nhouse = 2000 
			AND	monthof = '7/2000'
</CFQUERY>

<cfoutput>#cash.recordcount#</CFOUTPUT>