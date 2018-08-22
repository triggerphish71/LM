



<!--- ==============================================================================
Flags Chosen Entry As Deleted
=============================================================================== --->

<CFTRANSACTION>

	<CFQUERY NAME = "FlagDeleted" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	REGION
		SET		iRowDeletedUser_ID	=	#SESSION.UserID#,
				dtRowDeleted 		=	GetDATE()
		WHERE	iRegion_ID			= 	#url.typeID#
	</CFQUERY>
	
<!--- *****************************************************************************
	<CFQUERY NAME = "History" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	P_REGION
		SET		iRowEndUser_ID 		= 	#SESSION.UserID#
		WHERE	iRegion_ID			= 	#url.typeID#
		AND		dtRowEnd 			=	(SELECT MAX(dtRowEnd) as EndDate FROM P_REGION WHERE iRegion_ID = #url.typeID#)
	</CFQUERY>
****************************************************************************** --->


</CFTRANSACTION>
	
<CFLOCATION URL = "region.cfm">