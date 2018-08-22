<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<!----------------------------------------------------------------------------------------------
| DESCRIPTION: changes status of resident to "move-in" list if NRF discount is rejected        |
|----------------------------------------------------------------------------------------------|
| ResetMoveIn.cfm                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by:                                                                                   |
| Calls/Submits:                                                                               |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Ticket      |Description                                           |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |             |Added for deferred New Resident Fee project 75019     |
|Sfarmer     |09/18/2013  | 102919      |Revise NRF approval process                           |
|            |            |                                                                    |
 --- -----------------------------------------------------------------------------------------|
| Sfarmer   | 10/18/2013  |Proj. 102481 removed Walnut db and tables Census & Leadtracking     |
----------------------------------------------------------------------------------------------->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>TIPS Reset Move-in NRF Adjustment Rejected</title>
</head>
 
<cfquery name="qryTenantPending" datasource="#application.datasource#">
	Select T.cLastName, T.cFirstName, 
	TS.mBaseNRF, 
	TS.mAdjNRF
	, TS.iNRFMid
	, T.itenant_id
	, ts.irowstartuser_id as 'Tenuserid'
	,t.csolomonkey
	,IM.irowstartuser_id as 'Invuserid'
	from Tenant T
		join tenantState TS on T.itenant_id = TS.itenant_id
		join InvoiceMaster IM on t.cSOLOMONKEY = IM.csolomonkey
	where T.itenant_id = #URL.iTenant_ID#
</cfquery>

   <CFQUERY NAME="MovedInState" datasource = "#APPLICATION.datasource#">
	UPDATE	TenantState
	SET		 bNRFPend = 0
	<!---iTenantStateCode_ID = 0 
			,dtRowStart = null
			,dtSPEvaluation = null
			,
			,iNRFMid = null
			,iRowStartUser_ID = null
			,mBaseNRF = 0
			,mAdjNRF = 0
			,dtMoveIn = null --->
	WHERE	iTenant_ID = #URL.iTenant_ID#
</CFQUERY>   
<body>
<!--- <cfoutput>
<cfif qryTenantPending.Tenuserid is not "" and qryTenantPending.Tenuserid le 2000>
	<cfquery name="qryEmployee" datasource="FTA">
		select cemail as 'email', crole, cfullname , cname
		FROM    FTA.dbo.vw_House 
		JOIN FTA.dbo.vw_UserAccountDetailsExtended ON [vw_House].CNAME = vw_UserAccountDetailsExtended.cHouseName
		where cnumber = #qryTenantPending.Tenuserid# AND CROLE in ('RD', 'RSM', 'CSM')
	</cfquery>
<cfelseif qryTenantPending.Invuserid is not "" and qryTenantPending.Invuserid le 2000>
	<cfquery name="qryEmployee" datasource="FTA">
		select cemail as 'email', crole, cfullname 
		FROM     FTA.dbo.vw_House 
		JOIN  FTA.dbo.vw_UserAccountDetailsExtended ON vw_House.CNAME = vw_UserAccountDetailsExtended.cHouseName
		where cnumber = #qryTenantPending.Invuserid# AND CROLE in ('RD', 'RSM', 'CSM')
	</cfquery>  
<cfelseif qryTenantPending.Tenuserid is not "">
	<cfquery name="qryEmployee" datasource="DMS">
	SELECT vwe.email
	 FROM   vw_employees vwe  
	  where vwe.Employee_Ndx = #qryTenantPending.Tenuserid#
	</cfquery>
<cfelse>
	<cfquery name="qryEmployee" datasource="DMS">
	SELECT vwe.email
	 FROM   vw_employees vwe  
	  where vwe.Employee_Ndx = #qryTenantPending.Invuserid#
	</cfquery>
</cfif>
<cfif qryEmployee.email is not "">
 <CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#qryEmployee.email#"   SUBJECT="Move-in New Resident Fee Discount rejected">
		The Discounted NRF of #qryTenantPending.cFirstName# #qryTenantPending.cLastName# has been rejected. 
		<br />Please contact #session.fullname# for further instructions.
</CFMAIL> 
<cfelse>
<br />
NO Email is available for this house RD or RSM or CSM<br />
Userid: #qryTenantPending.Invuserid#<br />
Please copy this and send it to IT Support<br /><br />
Reset Movein NRF/Deferral Rejection error.<br /><br />
Rejection process completed.<br />
Notify
</cfif>
TO="#qryEmployee.email#"<br />
 FROM="TIPS4-Message@alcco.com"<br />
    SUBJECT="Move-in New Resident Fee Discount rejected" <br />
		The Discounted NRF of #qryTenantPending.cFirstName# #qryTenantPending.cLastName# has been rejected. 
		<br />Please contact #session.fullname# for further instructions.
		 		
	
</cfoutput>	 --->
<!--- <CFIF SESSION.USERID EQ 3863 >
	<BR><A HREF="../Registration/Registration.cfm">Continue.</A>
<CFELSE>
 	<CFLOCATION URL="../Registration/Registration.cfm" ADDTOKEN="No"> 
</CFIF> --->		
 
	<Cfquery name="qryHouseRegion" datasource="#application.datasource#">
	SELECT RO.regionID
		,RO.regionname
		,RO.opsname
		,RO.iDirectorUser_ID
		,RO.opsareaID
		,RO.iRegion_ID
		,RO.houseID
		,RO.cNumber
		,RO.cName
	 
	  FROM [TIPS4].[rw].[vw_Reg_Ops_house] RO  
	 
	  WHERE houseID =  #SESSION.qSelectedHouse.iHouse_ID#
	</Cfquery>
	
	<Cfquery name="qryRDO" datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM FTA.dbo.vw_UserAccounts 
	  where cscope = '#qryHouseRegion.opsname#'
	  and cROle like '%RDO%'
	</Cfquery>
<cfquery name="qryapprover" datasource="FTA">

SELECT  cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
  FROM [FTA].dbo.vw_UserAccountDetailsExtended
  where cusername = '#session.username#'	
  and ihouseid = #session.qselectedhouse.ihouse_id#
</cfquery>

	 <Cfquery name="qryRD" datasource="FTA">
	Select cFullName 
		  ,cUserName
		  ,cEmail
		  ,cRole
		  ,cScope
	  FROM FTA.dbo.vw_UserAccounts 
	  where cscope = '#session.housename#'
	  and cROle like '%RD%'
	</Cfquery>
	
	<cfquery name="qryARAnalyst" datasource="#application.datasource#">
		SELECT	h.cname,Du.Email, DU.FNAME, DU.LNAME,DU.JOBTitle 
		FROM	House H
		<!--- JOIN	WALNUT.ALCWEB.dbo.employees DU ON H.iAcctUser_ID = DU.Employee_ndx --->
		JOIN	ALCWEB.dbo.employees DU ON H.iAcctUser_ID = DU.Employee_ndx
		where h.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
	</cfquery>

	<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#qryRD.cEmail#,#qryapprover.cEmail#,#qryARAnalyst.Email#"   SUBJECT="ejected NRF">
			The NRF for #qryTenantPending.cFirstName# #qryTenantPending.cLastName# at #session.housename# has been rejected by #mid(qryRDO.cFullName,(refindnocase(',',qryRDO.cFullName)+1),(len(qryRDO.cFullName)-refindnocase(',',qryRDO.cFullName)))#  #left(qryRDO.cFullName,(refindnocase(',',qryRDO.cFullName)))#.
			<br />You must contact your AR analyst to enter the correct adjustment on the account.
			<br />
			<br />Solomon Key: #qryTenantPending.csolomonkey#
	</CFMAIL> 
	
	<CFIF (cgi.server_name is 'vmappprod01dev3') or (SESSION.USERID is 3863)  or (SESSION.Username is 'dhansen') or (SESSION.Username is  'tracym')>
		 <CFoutput>
		  FROM="TIPS4-Message@alcco.com" 
			<br />TO="#qryRD.cEmail#,#qryRDO.cEmail#,#qryARAnalyst.Email#" 
			<br />  SUBJECT="REJECTED NRF" 
			<br />The NRF for #qryTenantPending.cFirstName# #qryTenantPending.cLastName# at #session.housename# has been rejected by #session.fullname#. <!--- #mid(qryRDO.cFullName,(refindnocase(',',qryRDO.cFullName)+1),(len(qryRDO.cFullName)-refindnocase(',',qryRDO.cFullName)))#  #left(qryRDO.cFullName,(refindnocase(',',qryRDO.cFullName)))#.  --->
			<br />You must contact your AR analyst to enter the correct adjustment on the account.
			<br />
			<br />Solomon Key: #qryTenantPending.csolomonkey#
		</CFoutput> 
	
		<br /><A HREF="../MainMenu.cfm">Continue</A>
		
	<cfelse>
		<CFLOCATION URL="../MainMenu.cfm"ADDTOKEN="No">
	</CFIF>
 
</body>
</html>

<cfinclude template="../../footer.cfm">
