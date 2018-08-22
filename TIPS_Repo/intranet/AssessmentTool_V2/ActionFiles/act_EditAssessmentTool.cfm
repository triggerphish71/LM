<CFOUTPUT>
	<CFTRY>
		<CFIF isDefined("form.iassessmenttool_id") and len(trim(form.iassessmenttool_id)) gt 0>
			
			<CFQUERY NAME="qUpdateAsessmentTool" DATASOURCE="#application.datasource#">
				update 
					assessmenttool
				set	
					 cdescription='#form.cdescription#'
					,csleveltypeset='#form.serviceset#'
					,cRowStartUser_id='#session.username#'
					,dtrowstart=getdate()
				where 
					iassessmenttool_id = #form.iassessmenttool_id#
			</CFQUERY>	
		<CFELSE>
			<CFQUERY NAME="qInsertAsessmentTool" DATASOURCE="#application.datasource#">
			begin tran
			
			Declare @errormsg varchar(100)
			declare @dup int
			
			Select @dup = count(iassessmenttool_id) from assessmenttool where dtrowdeleted is null
			and cdescription  = '#trim(form.cdescription)#'
			
			if @dup = 0
			begin
				INSERT INTO assessmenttool
				( cDescription, cSLevelTypeSet, cRowStartUser_id, dtRowStart)
				VALUES
				( '#form.cdescription#', '#form.serviceset#', '#session.username#', getdate()  )
				end
			else
				begin
					Select @errormsg='This record already exists'
					GOTO Err_Handler
				end
			
			if @@error <> 0
			begin
				Select @errormsg='Error inserting record'
				GOTO Err_Handler
			end
			
			COMMIT TRAN
			
			Err_Handler:
			
			RAISERROR(@Errormsg, 16,1)
			ROLLBACK TRAN
			
			</CFQUERY>
		</CFIF>
			
	<CFCATCH type="Any">
		<CFDUMP VAR="#cfcatch#">
		<CFSET catcherror=1>
	</CFCATCH>
	</CFTRY> 
	<CFLOCATION URL="#HTTP_REFERER#" addtoken="false">

</CFOUTPUT>