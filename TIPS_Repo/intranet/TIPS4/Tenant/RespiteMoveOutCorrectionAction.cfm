<!--- *******************************************************************************
Name:			RespiteMoveOutCorrectionAction.cfm
Process:		Alter Move out dates for Respite

Called by: 		RespiteMoveOutCorrection.cfm
 
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Steven Farmer           09/05/2017     Original Authorship
      Allow AR to change dtmoveout, dtnoticedate, dtchargethrough, dtmoveoutprojecteddate
******************************************************************************** --->
<cfoutput>
<!---   <cfdump var="#form#">
<cfdump var="#session#">
<cfabort>  ---> 
<cfparam name="FailedAt" default="">
<CFTRANSACTION>
<cftry> 

	<!--- Retrieve current SQL Server Time for stamp--->
		<cfset FailedAt="qTimeStamp">
	<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
		SELECT	GetDate() as TimeStamp
	</CFQUERY>
	<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

	<cfset FailedAt="qryUser">
	<cfquery name="qryUser"  DATASOURCE="#APPLICATION.datasource#">
		Select employee_ndx, left(fname,1) + lname 'EmpName' 
		from alcweb.dbo.employees
		where employee_ndx = #session.userid#
	</cfquery>

	<!--- 	Retrieve Chosen Addendum Type --->
	<cfset FailedAt="qAddendumType1">
	<CFQUERY NAME="qAddendumType" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iAddendumType_ID
		FROM	AddendumType
		WHERE	dtRowDeleted IS NULL
		AND		iAddendumType_ID = #form.iAddendumType_ID#
	</CFQUERY>
	<cfset FailedAt="qAddendumType1">		
	<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT	t.cfirstname + ' ' + t.clastname as 'Resident',*
		FROM	Tenant T
		JOIN	TenantState TS ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #form.iTenant_ID#
	</CFQUERY>	 
<!--- <cfif ((isDefined('form.RESETALL')) and  (form.RESETALL is 'resetallyes'))>
<!---  reset all respite move out dates to null --->

	<cfset currentMoveOutdate = left(form.dtmoveout,4) & '-' & mid(form.dtmoveout,5,2)&'-' & right(form.dtmoveout,2)>

	<cfset currentNOTICEDATEdate = left(form.DTNOTICEDATE,4) & '-' & mid(form.DTNOTICEDATE,5,2)&'-' & right(form.DTNOTICEDATE,2)>

	<cfset currentDTCHARGETHROUGHdate = left(form.DTCHARGETHROUGH,4) & '-' & mid(form.DTCHARGETHROUGH,5,2)&'-' & right(form.DTCHARGETHROUGH,2)>



		<cfset FailedAt="qUpdateMoveOut">
		<cfset FailedAt="qUpdateMoveOut-respite">		
		<CFQUERY NAME="qUpdateMoveOut" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtmoveout = NULL,
					dtchargethrough = NULL,
					dtNoticeDate = NULL,
	 				itenantstatecode_id = 2,
	 				iTenantMOLocation_ID = null , 
					iMoveReasonType_ID = null, 
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenant_ID = #form.iTenant_ID#
            		And dtRowDeleted IS NULL
		</CFQUERY>
<!--- Move Out Addendum --->	
	<cfset FailedAt="qAddendumNewNumberct">	
	<CFQUERY NAME="qAddendumNewNumberct" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>		
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset MoveOutDatecomment = 'Physical Move Out Date Reset to null. ' & #TRIM(form.cComments)#>	
	<CFELSE>
		<cfset MoveOutDatecomment = 'Physical Move Out Date Reset to null.' > 
	</CFIF>
	<CFSET	RawAddendumNumber = qAddendumNewNumberct.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
<!--- 	<br />RawAddendumNumber: #RawAddendumNumber# cAddendumNumber: #cAddendumNumber#<br /> --->
 	<cfset FailedAt="qWriteToAddenumLog">						
	<CFQUERY NAME="qWriteToAddenumLog" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber  
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			,#CreateODBCDateTime(now())# 
			,null
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.MoveOutDatecomment") AND TRIM(variables.MoveOutDatecomment) NEQ "">
				,'#TRIM(variables.MoveOutDatecomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createOdbCDate(currentMoveOutdate)#
			,null
		)
	</CFQUERY>

	<CFSET	iNextAddendum = qAddendumNewNumberct.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable">	
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
<!--- NOTICEDATE  --->

	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset NoticeDatecomment = 'Move Out Notice Date Reset to null. ' & #TRIM(form.cComments)#>	
	<CFELSE>
		<cfset NoticeDatecomment = 'Move Out Notice Date Reset to null.' > 
	</CFIF>	
	<cfset FailedAt="qAddendumNewNumberct2">		
	<CFQUERY NAME="qAddendumNewNumberct2" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>		
	<CFSET	RawAddendumNumber = qAddendumNewNumberct2.iNextAddendum>
	<CFSET cAddendumNumber2 = SESSION.HouseNumber & RawAddendumNumber>
	<!--- <br />cAddendumNumber2: #cAddendumNumber2#<br /> --->
 		<cfset FailedAt="qWriteToAddenumLog2">		
		<CFQUERY NAME="qWriteToAddenumLog2" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber 
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber2#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			,#createODBCdate(now())# 
			,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.NoticeDatecomment") AND TRIM(variables.NoticeDatecomment) NEQ "">
				,'#TRIM(variables.NoticeDatecomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createOdbCDate(currentNOTICEDATEdate)#
			,null
		)
	</CFQUERY>

	<CFSET	iNextAddendum2 = qAddendumNewNumberct2.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable3">	
	<CFQUERY NAME="qUpdateControlTable3" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum2#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>

	<!--- currentDTCHARGETHROUGHdate --->  
		<cfset FailedAt="qAddendumNewNumberct5">	<cfset FailedAt="qUpdateControlTable">  
	<CFQUERY NAME="qAddendumNewNumberct5" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>		
		<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
			<cfset FinancialDatecomment = 'Financial Move Out Date Reset to null. ' & #TRIM(form.cComments)#>	
		<CFELSE>
			<cfset FinancialDatecomment = 'Financial Move Out Date Reset to null.' > 
		</CFIF>	
	<CFSET	RawAddendumNumber5 = qAddendumNewNumberct5.iNextAddendum>
	<CFSET cAddendumNumber5 = SESSION.HouseNumber & RawAddendumNumber5>
<!--- 	<br />cAddendumNumber5:: #cAddendumNumber5#<br /> --->
 		<cfset FailedAt="qWriteToAddenumLog5">		
		<CFQUERY NAME="qWriteToAddenumLog" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber 
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber5#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			 ,#CreateODBCDateTime(now())# 
			,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.FinancialDatecomment") AND TRIM(variables.FinancialDatecomment) NEQ "">
				,'#TRIM(variables.FinancialDatecomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createOdbCDate(currentDTCHARGETHROUGHdate)#
			,null
		)
	</CFQUERY>

	<CFSET	iNextAddendum5 = qAddendumNewNumberct5.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable">	
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum5#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>	
<!--- 	<br />end of reset all to null --->
</cfif>
 --->
<!--- <cfif ((CHGTHROUGHDT is not "") or (MOVEOUTDT is not "") or (NOTICEOUTDT is not '') or (PROJMOVEOUTDT is not ""))> --->
<!---  <br />we are doing Move out, Notice date, Charge Through Date or Projected Move Out Date or any combination<br /> --->

<CFIF ((IsDefined("form.moveoutdt")) and (form.moveoutdt is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset moveoutcomment = 'Physical Move Out Date changed: ' &  #TRIM(form.cComments)#>	
	<CFELSE>
		<cfset moveoutcomment = 'Physical Move Out Date changed from:' & mid(form.dtmoveout,5,2)&'/' & right(form.dtmoveout,2) &  '/' & left(form.dtmoveout,4) & ' to: ' & form.moveoutdt & '. '> 
	</CFIF>	
	<!--- Retrieve the next Addendum Number--->
	<cfset FailedAt="qNextAddendum6">
	<CFQUERY NAME="qNextAddendum6" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>

	<CFSET	RawAddendumNumber = qNextAddendum6.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
	<cfset currentMoveOutdate =   left(form.dtmoveout,4) & '-' & mid(form.dtmoveout,5,2)&'/' & right(form.dtmoveout,2)>
 		<cfset FailedAt="qWriteToAddenumLog6">		
		<CFQUERY NAME="qWriteToAddenumLog" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber 
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			,#CreateODBCDateTime(now())# 
			,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.moveoutcomment") AND TRIM(variables.moveoutcomment) NEQ "">
				,'#TRIM(variables.moveoutcomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createOdbCDate(currentMoveOutdate)#
			,#createOdbCDate(moveoutdt)#
		)
	</CFQUERY>
		<cfset FailedAt="qUpdateMoveOut">
		<CFQUERY NAME="qUpdateMoveOut" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtmoveout = #CreateODBCDateTime(form.moveoutdt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenant_ID = #form.iTenant_ID#
            		And dtRowDeleted IS NULL
		</CFQUERY>
	<CFSET	iNextAddendum = qNextAddendum6.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable6">	
	<CFQUERY NAME="qUpdateControlTable6" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>			
</CFIF> <!---  moveoutdt --->

 
<CFIF ((IsDefined("form.projmoveoutdt")) and (form.projmoveoutdt is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset projectedcomment = 'Projected Move Out Date changed: ' & #TRIM(form.cComments)#>	
 
	<CFELSE>
		<cfset projectedcomment = 'Projected Move Out Date changed from:' & mid(form.dtMoveOutProjectedDate,5,2)&'/' & right(form.dtMoveOutProjectedDate,2) &  '/' & left(form.dtMoveOutProjectedDate,4) & ' to: ' & form.projmoveoutdt & '. '> 
	</CFIF>	
	<!--- Retrieve the next Addendum Number--->
	<cfset FailedAt="qNextAddendum7">
	<CFQUERY NAME="qNextAddendum7" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>

	<CFSET	RawAddendumNumber = qNextAddendum7.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>

	<cfset currentProjMoveOutDate =   left(form.dtMoveOutProjectedDate,4) & '-' & mid(form.dtMoveOutProjectedDate,5,2)&'/' & right(form.dtMoveOutProjectedDate,2)>
 		<cfset FailedAt="qWriteToAddenumLog7">		
		<CFQUERY NAME="qWriteToAddenumLog" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber 
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			<CFIF IsDefined("form.date") AND TRIM(form.date) NEQ "">
				 ,#CreateODBCDateTime(form.date)# 
			<CFELSE> 
				,#now()# 
			</CFIF>
			<CFIF IsDefined("form.mAmount") AND TRIM(form.mAmount) NEQ "">
				,#form.mAmount# 
			<CFELSE> 
				,NULL 
			</CFIF>
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.projectedcomment") AND TRIM(variables.projectedcomment) NEQ "">
				,'#TRIM(variables.projectedcomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createODBCDate(currentProjMoveOutDate)#
			,#createODBCDate(projmoveoutdt)#
		)
	</CFQUERY>
	<cfset FailedAt="qUpdateMoveIn">
		<CFQUERY NAME="qUpdateMoveIn" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtmoveoutprojecteddate = #CreateODBCDateTime(form.projmoveoutdt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenant_ID = #form.iTenant_ID#
            		And dtRowDeleted IS NULL
		</CFQUERY>
	<CFSET	iNextAddendum = qNextAddendum7.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable7">	
	<CFQUERY NAME="qUpdateControlTable7" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>		
</CFIF>	<!---projmoveoutdt  --->


<CFIF ((IsDefined("form.noticeoutdt")) and (form.noticeoutdt is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset noticedatecomment = 'Move Out Notice Date changed: ' & #TRIM(form.cComments)#> 	

	<CFELSE>
		<cfset noticedatecomment = 'Move Out Notice Date changed from:' & mid(form.dtNoticeDate,5,2)&'/' & right(form.dtNoticeDate,2) &  '/' & left(form.dtNoticeDate,4) & ' to: ' & form.noticeoutdt & '. '> 
	</CFIF>	
	<!--- Retrieve the next Addendum Number--->
	<cfset FailedAt="qNextAddendum8">
	<CFQUERY NAME="qNextAddendum8" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>

	<CFSET	RawAddendumNumber = qNextAddendum8.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
	<cfset currentNoticeDate =   left(form.dtNoticeDate,4) & '-' & mid(form.dtNoticeDate,5,2)&'/' & right(form.dtNoticeDate,2)>	
 		<cfset FailedAt="qWriteToAddenumLog8">		
		<CFQUERY NAME="qWriteToAddenumLog" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber 
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			<CFIF IsDefined("form.date") AND TRIM(form.date) NEQ "">
				 ,#CreateODBCDateTime(form.date)# 
			<CFELSE> 
				,#now()# 
			</CFIF>
			<CFIF IsDefined("form.mAmount") AND TRIM(form.mAmount) NEQ "">
				,#form.mAmount# 
			<CFELSE> 
				,NULL 
			</CFIF>
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.noticedatecomment") AND TRIM(variables.noticedatecomment) NEQ "">
				,'#TRIM(variables.noticedatecomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createODBCDate(currentNoticeDate)#
			,#createODBCDate(noticeoutdt)#
		)
	</CFQUERY>
		<cfset FailedAt="qUpdateMoveIn">
		<CFQUERY NAME="qUpdateMoveIn" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtnoticedate = #CreateODBCDateTime(form.noticeoutdt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenant_ID = #form.iTenant_ID#
            		And dtRowDeleted IS NULL
		</CFQUERY>
	<CFSET	iNextAddendum = qNextAddendum8.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable8">	
	<CFQUERY NAME="qUpdateControlTable8" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>		
</CFIF>		<!--- end noticeoutdt --->

<CFIF ((IsDefined("form.chgthroughdt")) and (form.chgthroughdt is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset chargethrucomment = 'Financial Move Out changed:' & #TRIM(form.cComments)#> 	

	<CFELSE>
		<cfset chargethrucomment = 'Financial Move Out changed from:' & mid(form.dtchargethrough,5,2)&'/' & right(form.dtchargethrough,2) &  '/' & left(form.dtchargethrough,4) & ' to: ' & form.chgthroughdt & '. '> 
	</CFIF>	
	<!--- Retrieve the next Addendum Number--->
	<cfset FailedAt="qNextAddendum9">
	<CFQUERY NAME="qNextAddendum9" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>

	<CFSET	RawAddendumNumber = qNextAddendum9.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
	<cfset currentChgThrudate =   left(form.dtchargethrough,4) & '-' & mid(form.dtchargethrough,5,2)&'/' & right(form.dtchargethrough,2)>	
 		<cfset FailedAt="qWriteToAddenumLog9">		
		<CFQUERY NAME="qWriteToAddenumLog" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO AddendumLog
		(	cAddendumNumber 
			,iTenant_ID
			,iAddendumType_ID
			,dtAddendum
			,mAmount
			,cAppliesToAcctPeriod 
			,cComments
			,iRowStartUser_ID
			,dtRowStart
			,cRowStartUser_ID
			,dtChangeFrom
			,dtChangeTo				
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			<CFIF IsDefined("form.date") AND TRIM(form.date) NEQ "">
				 ,#CreateODBCDateTime(form.date)# 
			<CFELSE> 
				,#now()# 
			</CFIF>
			<CFIF IsDefined("form.mAmount") AND TRIM(form.mAmount) NEQ "">
				,#form.mAmount# 
			<CFELSE> 
				,NULL 
			</CFIF>
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			<CFIF IsDefined("variables.chargethrucomment") AND TRIM(variables.chargethrucomment) NEQ "">
				,'#TRIM(variables.chargethrucomment)#' 
			<CFELSE> 
				,NULL 
			</CFIF> 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#CreateODBCDate(currentChgThrudate)#
			,#CreateODBCDate(chgthroughdt)#
		)
	</CFQUERY>
		<cfset FailedAt="qUpdateChargeThru">
		<CFQUERY NAME="qUpdateChargeThru" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtChargeThrough = #CreateODBCDateTime(form.chgthroughdt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenant_ID = #form.iTenant_ID#
            		And dtRowDeleted IS NULL
		</CFQUERY>
	<CFSET	iNextAddendum = qNextAddendum9.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable9">	
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
</CFIF>	 <!--- chgthroughdt ---> 

<!--- </cfif> --->
	
	<cfset FailedAt="qryUpdActivityMoveIn">
	<cfquery NAME="qryUpdActivityMoveIn" DATASOURCE="#APPLICATION.datasource#">
		INSERT INTO [dbo].[ActivityLog]
           ([iActivity_ID]
           ,[dtActualEffective]
           ,[iTenant_ID]
           ,[iHouse_ID]
           ,[iAptAddress_ID]
           ,[iSPoints]
           ,[dtAcctStamp]
           ,[iRowStartUser_ID]
           ,[dtRowStart]
           ,[iRowEnduser_ID]
           ,[dtRowEnd]
           ,[iRowDeletedUser_ID]
           ,[dtRowDeleted]
           ,[cRowStartUser_ID]
           ,[cRowEndUser_ID]
           ,[cRowDeletedUser_ID]
           ,[iSLPoints])
     VALUES
           (12
           ,#variables.TimeStamp#
           ,#form.iTenant_ID#
           ,#form.iHouse_ID#
           ,#form.iAptAddress_ID#
           ,#form.iSPoints#
           ,#variables.TimeStamp#
           ,#session.userid#
           ,#variables.TimeStamp#
           ,NULL
           ,NULL 
           ,NULL 
           ,NULL 
           ,#session.userid#
           ,NULL
           ,NULL 
           ,<cfif #form.iSLPoints# is ''>Null <cfelse>#form.iSLPoints# </cfif>)	
	</cfquery>	

	<CFCATCH type="any">
		<h3>Process Failure at Query: #FailedAt#</h3>
		<h3>House ID: #SESSION.qSelectedHouse.iHouse_ID#</h3><br />
	    <CFLOOP index=i from=1 to = #ArrayLen(CFCATCH.TAGCONTEXT)#>
          <CFSET sCurrent = #CFCATCH.TAGCONTEXT[i]#>
              <BR>#i# #sCurrent["ID"]# 
(#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
    </CFLOOP>	
				<cfset processname = "Respite Move Out Date Edit and Addendum" >
				<cfset residentname = #qTenant.resident#>
				<cfset residentID = #qTenant.itenant_id#>
				<cfset Formname = "RespiteMoveOutCorrectionAction.cfm">
 			
			<CFSCRIPT>
				Msg1 = "Respite Move Out Date Edit and Addendum.<BR>";
				Msg1 = Msg1 &  "Failed At: " & #FailedAt#;
			</CFSCRIPT>			
 				<cfset wherefrom = 'Respite Move Out Date Edit'>
    	 <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#"> 	
	</CFCATCH>	
		
	  </cftry> 	
</CFTRANSACTION>
<CFLOCATION URL="RespiteMoveOutCorrection.cfm?tenantid=#form.iTenant_ID#" ADDTOKEN="No"> 
</CFOUTPUT> 