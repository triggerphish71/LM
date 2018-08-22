
<!--- ==============================================================================
Flags Chosen Entry As Deleted
=============================================================================== --->
<CFQUERY NAME = "FlagDeleted" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	HOUSE
	SET		iRowDeletedUser_ID	=	#SESSION.UserID#,
			dtRowDeleted 		=	GetDATE()
	WHERE	iHouse_ID			= 	#url.typeID#
</CFQUERY>

<!--- *****************************************************************************
<!--- =============================================================================================
Write Transaction Record to the History Table
============================================================================================= --->
<CFQUERY NAME = "HouseHistory" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	P_HOUSE
		SET iRowEndUser_ID = #Session.UserID#
	WHERE iHouse_ID = #url.typeID#
	AND dtRowEnd = (Select Max(dtRowEnd)as MaxEnd from P_House WHERE iHouse_ID = #url.typeID#)
</CFQUERY>
****************************************************************************** --->
<CFLOCATION URL = "house.cfm">