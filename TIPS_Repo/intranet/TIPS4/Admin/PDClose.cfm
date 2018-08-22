<!----------------------------------------------------------------------------------------------
| DESCRIPTION   PDClose.cfm                                                                    |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name   																			   |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                     												   |                                                                        
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 03/21/2006 | Create Flower Box                                                  | 
| mlaw       | 03/21/2006 | Comment out HouseData query, this query is not being used          |
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
----------------------------------------------------------------------------------------------->
<!--- <cfdump var="#session#"> --->
<CFTRANSACTION>

<!--- ==============================================================================
Retrieve the corresponding AREmail
=============================================================================== --->
<CFQUERY NAME="GetEmail" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Du.EMail as AREmail
	FROM	House	H
	JOIN	#Application.AlcWebDBServer#.ALCWEB.dbo.employees DU	ON	H.iAcctUser_ID = DU.Employee_ndx
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>
<!---<cfdump var="#GetEmail#"> --->
<cfoutput>#SESSION.HouseName# #SESSION.FULLNAME# #SESSION.TIPSMonth#</cfoutput>
<!--- ==============================================================================
Retrieve the Houses' Data and TIPS Month
=============================================================================== --->
<!--- MLAW 03/21/2006 this query is not being used --->
<!--- <CFQUERY NAME = "HouseData" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	House H
	JOIN 	HouseLog HL	ON H.iHouse_ID = HL.iHouse_ID
	WHERE	H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY> --->

<!--- ==============================================================================
Change bIsPDClosed to 1 or NULL depending if the month is being re-opened or closed
=============================================================================== --->
<CFOUTPUT>
	<CFIF IsDefined("url.close")> <CFSET bIsPDClosed = 1> </CFIF>	
	<CFIF IsDefined("url.open")> <CFSET bIsPDClosed = 'NULL'></CFIF>
</CFOUTPUT>

<!--- ==============================================================================
Update the House Log for the month end 
=============================================================================== --->
<CFQUERY NAME="PDClose" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	HouseLog
	SET 	iHouse_ID			=	#SESSION.qSelectedHouse.iHouse_ID#,
			dtCurrentTipsMonth	=	'#SESSION.TipsMonth#',
			bIsPDclosed			=	#Variables.bIsPDClosed#,
			bIsOpsMgrClosed		=	NULL,
			dtActualEffective	=	GETDATE(),
			cComments			=	NULL,
			dtAcctStamp			=	#CreateODBCDateTime(SESSION.AcctStamp)#,
			iRowStartUser_ID	=	#SESSION.UserID#,
			dtRowStart			=	GETDATE()
	
	WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>


<CFIF IsDefined("url.close")>
	<CFMAIL TYPE="html" FROM="TIPS4-Message@alcco.com" TO="gthota@enlivant.com;mstriegel@enlivant.com" SUBJECT="The #SESSION.HouseName# has been closed.">
		#SESSION.HouseName# has closed TIPS for #DateFormat(SESSION.TIPSMonth, "mm/yyyy")#<BR>
		by #SESSION.FULLNAME#<BR>
		____________________________________________________
	</CFMAIL>
<CFELSEIF IsDefined("url.open")>
	<CFMAIL TYPE="html" FROM="TIPS4-Message@alcco.com" TO="#GetEMail.AREmail#" SUBJECT="The #SESSION.HouseName# has been re-opened.">
		#SESSION.HouseName# has re-opened TIPS for #DateFormat(SESSION.TIPSMonth, "mm/yyyy")#<BR>
		by #SESSION.FULLNAME#<BR>
		____________________________________________________
	</CFMAIL>	
</CFIF>

</CFTRANSACTION>


<!--- ==============================================================================
Return to Administration Page
=============================================================================== --->
<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="yes">
