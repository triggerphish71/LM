<cftry>
<cfoutput>
<cfset DSN = 'LeadTracking'>
<cfset tipsDSN='TIPS4'>

<!--- check status of the chosen potential resident --->
<cfquery name="qresident" datasource="#dsn#">
select * from Resident r
join residentstate rs on rs.iresident_id = r.iresident_id and rs.dtrowdeleted is null
where r.dtRowDeleted is null and r.iResident_ID = #trim(form.iresident_id)#
</cfquery>

<cfif qresident.istatus_id eq 7 and qresident.itenant_id neq ""
and form.iStatus_ID neq 5>
	<cftransaction>
		<!--- update projected move in date --->
		<cfquery name="qupdatemoveindate" datasource="#tipsDSN#">
			update tenantstate
			set dtrowstart=getdate()
					<cfif isDefined("form.dtmovein")>,dtmovein='#trim(form.dtmovein)#'<cfelse>,dtmovein=null</cfif>
					<cfif isDefined("form.iresidencytype_id") and trim(form.iresidencytype_id) neq "">,iresidencytype_id = #trim(form.iresidencytype_id)#</cfif>
					,irowstartuser_id='#trim(session.userid)#'
					,crowstartuser_id='inq_update'
			where itenant_id = #trim(qresident.itenant_id)#
		</cfquery>
	</cftransaction>
</cfif>	


<cfif IsDefined("form.fieldnames")>
	<cfset ActionsList = ''>
	<cfloop index="fields" LIST="#form.fieldnames#">
		<cfscript>
		if (FindNoCase('checkbox', fields, 1) GT 0 AND Len(Evaluate(fields)) GT 0) {
			if (LEN(ActionsList) EQ 0) { ActionsList = GetToken(fields, 2, '__'); } 
			else { ActionsList = ActionsList & ',' & GetToken(fields, 2, '__');} 
		}
		</cfscript>
	</cfloop>
	
	<cftransaction>
	<cfquery NAME='qTransactions' DATASOURCE='#DSN#'>
		BEGIN
		Declare @time datetime
		Declare @dupCount int
		Declare @Eventid int
		Declare @tmpEventid int
		Declare	@status int
		Declare @errormsg varchar(100)
		SET @time = (SELECT getdate())
		
		SELECT	@dupCount = count(iEvent_ID) FROM EventMaster WHERE dtRowDeleted IS NULL 
		and	iResident_ID = #form.iResident_ID# and cShortDescription = '#trim(replacenocase(form.cShortDescription,"'","'","all"))#'
		and	cLongDescription = '#trim(replacenocase(form.cLongDescription,"'","'","all"))#' and cComments = '#trim(replacenocase(form.cComments,"'","'","all"))#'
		
		IF (@dupCount = 0)
			BEGIN
			INSERT INTO EventMaster
				(iResident_ID , cShortDescription ,cLongDescription ,cComments ,cRowStartUser_ID ,dtRowStart
				)VALUES(
				#form.iResident_ID# 
				,'#replacenocase(form.cShortDescription,"'","'","all")#'	
				,'#replacenocase(form.cLongDescription,"'","'","all")#' 
				,'#replacenocase(form.cComments,"'","'","all")#' 
				,'#SESSION.USERNAME#' ,@time)
				
				if @@error <> 0
				begin 
				<!--- rollback tran return --->
				Select @errormsg='Error inserting event master'
				RAISERROR(@errormsg, 16,1)
				ROLLBACK TRAN
				end				
			END
		ELSE
			BEGIN
				SELECT	@tmpEventid = max(iEvent_ID) FROM EventMaster WHERE dtRowDeleted IS NULL 
				and	iResident_ID = #trim(form.iResident_ID)# and cShortDescription = '#trim(form.cShortDescription)#'
				and	cLongDescription = '#trim(form.cLongDescription)#' and cComments = '#trim(form.cComments)#'
			
				UPDATE	EventMaster
				SET	dtRowStart = @time 
					,cRowStartUser_ID = '#SESSION.USERNAME#' 
					,cShortDescription = '#replace(form.cShortDescription,"'","'","all")#'		
					,cLongDescription = '#replace(form.cLongDescription,"'","'","all")#' 
					,cComments = '#replace(form.cComments,"'","'","all")#'
				WHERE iEvent_ID = @tmpEventid

				if @@error <> 0
				begin 
				<!--- rollback tran return --->
				Select @errormsg='Error updating event master'
				RAISERROR(@errormsg, 16,1)
				ROLLBACK TRAN
				end						
			END
			
		SELECT	@Eventid = iEvent_ID
		FROM EventMaster
		WHERE cRowStartUser_ID = '#SESSION.USERNAME#' and dtRowStart between DateAdd(s,-2,@time) and DateAdd(s,2,@time)
		
		<cfloop index="Actions" LIST='#ActionsList#'>
		BEGIN	<!--- detailcomments#Actions# == #Evaluate('form.DetailComments__' & Actions)#<BR> --->
			INSERT INTO EventDetail
			(iEvent_ID ,iActionType_ID ,cComments ,cRowStartUser_ID ,dtRowStart ,dtDue ,iNextActionType_ID ,cNextComments
			) values ( 
			@Eventid 
			,#Actions# 
			,'#replacenocase(Evaluate('form.DetailComments__' & Actions),"'","''","all")#' 
			,'#SESSION.USERNAME#' 
			,@time 
			,'#trim(form.duedate)#'
			,'#form.iNextActionType_ID#'
			,'#replacenocase(trim(form.cNextComments),"'","'","all")#'
			)
			if @@error <> 0
			begin 
				<!--- rollback tran return --->
				Select @errormsg='Error inserting event detail'
				RAISERROR(@errormsg, 16,1)
				ROLLBACK TRAN
			end
		END
		</cfloop>
		
		SELECT	@status = iStatus_ID FROM ResidentState WHERE iResident_ID = #form.iResident_ID#
		
		if @status <> #form.iStatus_ID# 
			begin
			update ResidentState
			set	iStatus_ID = #form.iStatus_ID# ,dtRowStart = @time ,cRowStartUser_ID = '#SESSION.USERNAME#'
<cfif isDefined("form.reason") and isDefined("form.cdestination")>,imovereasontype_id=#form.reason# ,cdestination='#replacenocase(form.cdestination,"'","'","all")#'</cfif>
			where iResident_ID = #form.iResident_ID#
			end
			if @@error <> 0
			begin 
				Select @errormsg='Error updating status'
				RAISERROR(@errormsg, 16,1)
				ROLLBACK TRAN
			end
		END

	</cfquery>
	</cftransaction>
</cfif>

<cfif IsDefined("form.iStatus_ID") and (form.iStatus_ID EQ 6 or form.iStatus_ID EQ 7)>
	<cfscript>
		form.cFirstName = form.cFirstName; form.cLastName = form.cLastName;
		form.cOutSideAddressLine1 = form.cAddressLine1; form.cOutSideAddressLine2 = '';
		if (isDefined("form.cSolomonKey")) { form.cSolomonKey = form.cSolomonKey; }
		form.cOutSideCity = form.cCity;
		form.cOutSideStateCode = form.cStateCode;
		form.cOutSideZipCode = form.cZipCode;
		form.cComments = form.cComments;
		form.iResidencyType_ID = form.iResidencyType_ID;
		form.first = ''; form.middle = '';  form.last = '';
		form.areacode1 = ''; form.prefix1 = '';	form.number1 = '';
		form.areacode2 = ''; form.prefix2 = ''; form.number2 = '';
		form.areacode3 = ''; form.prefix3 = ''; form.number3 = '';
		form.month=''; form.day=''; form.year='';
		form.iOutSidePhoneType1_ID=1; form.iOutSidePhoneType2_ID=2;	form.iOutSidePhoneType3_ID=3;
		form.cOutSidePhoneNumber1=''; form.cOutSidePhoneNumber2=''; form.cOutSidePhoneNumber3='';
		leads=1;
	</cfscript>
	<cfif qresident.itenant_id eq ''>
		<cfinclude template="../TIPS4/Applicant/NewApplicantInsert.cfm">
	<cfelse>
		<script>
		opener.document.write("<center style='vertical-align: middle;'><strong style='font-size: large; color: red;'>Reloading Data.</strong></center>"); 
		opener.location.href='Leads.cfm';
		opener.focus();
		</script>
	</cfif>
<cfelse>
	<script>
	opener.document.write("<center style='vertical-align: middle;'><strong style='font-size: large; color: red;'>Reloading Data.</strong></center>"); 
	opener.location.href='Leads.cfm';
	opener.focus();
	</script>
</cfif>
</cfoutput>
<cfcatch type="ANY">
	<cfoutput>#cfcatch.message#<BR><CFDUMP VAR="#cfcatch#"><BR><cfif isDefined("Error.Diagnostics")>#Error.Diagnostics#</cfif></cfoutput>
	<cfmail type="HTML" from="TIPS4-Message@alcco.com" to="cfdevelopers@alcco.com" subject="Event Save Catch">
		#cfcatch.message#<br />
		<cfif isDefined("session.username")>#session.username#<br /></cfif>
		<cfdump var="#cfcatch#">
		<cfif isDefined("form")><cfdump var="#form#"></cfif>
		<cfif isDefined("Error.Diagnostics")>#Error.Diagnostics#</cfif>
	</cfmail>
</cfcatch>
</cftry>