


<!--- ==============================================================================
Delete Chosen Charge by Flagging as Deleted
=============================================================================== --->
<CFQUERY NAME = "DeleteCharge" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	Charges
	SET		iRowDeletedUser_ID	=	#SESSION.UserID#,
			dtRowDeleted		= 	GETDATE()
	WHERE	iCharge_ID			= #Url.typeID#
</CFQUERY>


<!--- ==============================================================================
Relocate to the Charges Page
=============================================================================== --->
<CFLOCATION URL="Charges.cfm?ID=#url.process#" ADDTOKEN="No">