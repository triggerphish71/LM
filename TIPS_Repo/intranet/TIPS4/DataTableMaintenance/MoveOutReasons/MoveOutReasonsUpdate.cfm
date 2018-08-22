

<CFTRANSACTION>


<CFOUTPUT>

	<CFQUERY NAME= "UpdateReasons" DATASOURCE ="#APPLICATION.datasource#">

		UPDATE 	MoveReasonType
		SET 							
			<CFIF form.cDescription NEQ "">
				cDescription				=	'#form.cDescription#',
			<CFELSE>
				cDescription				=	NULL,
			</CFIF>
			
			
			<CFIF form.iDisplayOrder NEQ "">
				iDisplayOrder 				=	#form.iDisplayOrder#,
			<CFELSE>
				iDisplayOrder 				=	NULL,
			</CFIF>


			<CFIF form.bIsVoluntary NEQ "">
				bIsVoluntary				=	#form.bIsVoluntary#,
			<CFELSE>
				bIsVoluntary				=	NULL,
			</CFIF>			
			
			
			<CFIF form.cComments NEQ "">
				cComments					=	'#form.cComments#',
			<CFELSE>
				cComments					=	NULL,
			</CFIF>
						
			dtAcctStamp					=	'#SESSION.AcctStamp#',
			iRowStartUser_ID			=	#SESSION.UserID#,
			dtRowStart					=	GetDate()

		WHERE 	iMoveReasonType_ID		= #form.iMoveReasonType_ID#
	</CFQUERY>


</CFOUTPUT>


</CFTRANSACTION>

<CFLOCATION URL="MoveOutReasonsEdit.cfm" ADDTOKEN="No">
