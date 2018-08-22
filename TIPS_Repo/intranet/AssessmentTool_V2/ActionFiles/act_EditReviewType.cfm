
<CFOUTPUT>

<CFTRY>

<CFIF isDefined("form.ireviewtype_id") AND len(trim(form.ireviewtype_id)) gt 0>

<CFQUERY NAME="qUpdateType" datasource="TIPS4">
update reviewtype
set cDescription='#form.cdescription#' ,cSortorder='#form.cSortOrder#' 
	,crowstartuser_id='#session.username#', dtrowstart=getdate()
where ireviewtype_id = #form.ireviewtype_id#
</CFQUERY>

<CFELSE>
<CFQUERY NAME="qInsertNewType" datasource="TIPS4">
begin tran

Declare @errormsg varchar(100)
declare @dup int

Select @dup = count(ireviewtype_id) from reviewtype where dtrowdeleted is null
and cdescription  = '#trim(form.cdescription)#'

if @dup = 0
begin
	INSERT INTO ReviewType
	( [cDescription], [cSortOrder], [cRowStartUser_ID], [dtRowStart])
	VALUES( '#form.cdescription#', '#form.cSortOrder#', '#session.username#', getdate() )
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
	<CFABORT>
</CFCATCH>

</CFTRY>

<CFIF isDefined("cfcatch.message")>
	<A HREF="#http.referer#">Continue</A>
<CFELSE>
	<CFLOCATION URL="#http.referer#">
</CFIF>
</CFOUTPUT>