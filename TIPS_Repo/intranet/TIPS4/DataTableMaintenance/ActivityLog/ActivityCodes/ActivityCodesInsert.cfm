

<!--- ==============================================================================
Insert into ActivityTypeCodes
=============================================================================== --->
<CFQUERY NAME = "ActivityCodesInsert" DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO	ActivityTypeCodes
				(cDescription, iRowStartUser_ID, dtRowStart)
				VALUES
				('#TRIM(form.cDescription)#', #SESSION.UserID#, GetDate())
</CFQUERY>

<CFLOCATION URL = "ActivityCodes.CFM">
