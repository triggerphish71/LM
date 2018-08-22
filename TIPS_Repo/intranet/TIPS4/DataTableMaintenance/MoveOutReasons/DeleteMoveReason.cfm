


<CFTRANSACTION>

	<CFQUERY NAME = "DeleteReason" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE	MoveReasonType
		SET		dtRowDeleted = GetDate(),
				iRowDeletedUser_ID = #SESSION.UserID#
		WHERE	iMoveReasonType_ID = #url.ID#
	</CFQUERY>

</CFTRANSACTION>

<CFLOCATION URL = "MoveOutReasonsEdit.cfm">
