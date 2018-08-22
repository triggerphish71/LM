

INSERT

<!--- ==============================================================================
Insert for new Tenant Status
=============================================================================== --->
<CFTRANSACTION>

	<CFQUERY NAME = "NewTenantState" DATASOURCE = "#APPLICATION.datasource#">
	
		INSERT INTO TenantStateCodes
					(
					cDescription, 
					iRowStartUser_ID, 
					dtRowStart
					)
					VALUES
					(
					<CFIF form.cDescription NEQ "">	'#TRIM(form.cDescription)#', 	<CFELSE>	NULL,	</CFIF>
					#SESSION.UserID#, 
					GetDate()
					)
	
	</CFQUERY>

</CFTRANSACTION>

<CFLOCATION URL = "TenantStateCodes.cfm">