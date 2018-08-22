



<!--- ==============================================================================
Flags Chosen Entry As Deleted
=============================================================================== --->
<CFQUERY NAME = "FlagDeleted" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	DEPOSITTYPE
	SET		iRowDeletedUser_ID	=	#SESSION.UserID#,
			dtRowDeleted 		=	GetDATE()
	WHERE	iDepositType_ID		= 	#url.typeID#
</CFQUERY>


<!--- *****************************************************************************
<!--- =============================================================================================
Write Transaction Record to the History Table
============================================================================================= --->
<CFQUERY NAME = "History" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	P_DepositType
	SET		iRowEndUser_ID		=	#SESSION.UserID#
	WHERE	iDepositType_ID 	= 	#url.typeID#
	AND		dtRowEnd			=	(Select Max(dtRowEnd) as EndDate from P_DepositType WHERE iDepositType_ID = #url.typeID#)
</CFQUERY>
****************************************************************************** --->


<CFLOCATION URL = "DepositType.cfm">