

<CFTRANSACTION>


<CFOUTPUT>

<CFQUERY NAME = "DuplicateCheck" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	MoveReasonType
	WHERE	cDescription = '#form.cDescription#'
	AND		bIsVoluntary =	#form.bIsVoluntary#
</CFQUERY>


<CFIF DuplicateCheck.RecordCount LT 1>

	<CFQUERY NAME= "UpdateReasons" DATASOURCE ="#APPLICATION.datasource#">

		INSERT INTO 	MoveReasonType
						(
							iDisplayOrder, 
							cDescription, 
							cComments, 
							bIsVoluntary, 
							dtAcctStamp, 
							iRowStartUser_ID, 
							dtRowStart
						)
							VALUES
						(
							<CFIF form.iDisplayOrder NEQ ""> 		#form.iDisplayOrder#, 		<CFELSE> NULL, </CFIF>
							<CFIF form.cDescription NEQ ""> 		'#form.cDescription#', 		<CFELSE> NULL, </CFIF>
							<CFIF form.cComments NEQ ""> 			'#form.cComments#', 		<CFELSE> NULL, </CFIF>
							<CFIF form.bIsVoluntary NEQ ""> 		#form.bIsVoluntary#, 		<CFELSE> NULL, </CFIF>
							
							'#SESSION.AcctStamp#',
							#SESSION.UserID#,
							GetDate()
						)

	</CFQUERY>
</CFIF>

</CFOUTPUT>


</CFTRANSACTION>

<CFLOCATION URL="MoveOutReasons.cfm" ADDTOKEN="No">
