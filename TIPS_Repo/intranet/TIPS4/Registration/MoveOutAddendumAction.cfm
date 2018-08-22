<!----------------------------------------------------------------------------------------------
| DESCRIPTION - Registration/MoveOutAddendumAction.cfm                                         |
|----------------------------------------------------------------------------------------------|
| Called by: 		MoveOutAddendum.cfm														   |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|MLAW        | 08/07/2006 | Create a flower box                                                |
|MLAW		 | 08/07/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
----------------------------------------------------------------------------------------------->
<!--- 08/07/2006 MLAW show menu button --->

<CFPARAM name="ShowBtn" default="True">
<cfparam name="FailedAt" default="">
<cfparam name="moveoutcomment" default="">
<cfparam name="chargethrucomment" default="">

<cfoutput>
<CFTRANSACTION>
 <cftry>

	<CFIF IsDefined("form.fieldnames")>
		<CFLOOP INDEX="I" LIST="#form.fieldnames#" DELIMITERS=",">
			#I# = #Evaluate(I)#<BR>
		</CFLOOP>
	</CFIF>
 
	<!--- ==============================================================================
	Retrieve current SQL Server Time for stamp
	=============================================================================== --->
	<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
		SELECT	GetDate() as TimeStamp
	</CFQUERY>
	<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>
	<cfset FailedAt="qryUser">
	<cfquery name="qryUser"  DATASOURCE="#APPLICATION.datasource#">
		Select employee_ndx, left(fname,1) + lname 'EmpName' 
		from alcweb.dbo.employees with (nolock)
		where employee_ndx = #session.userid#
	</cfquery>	

	<!--- ==============================================================================
	Retrieve TenantInformation
	=============================================================================== --->
	<cfset FailedAt="qTenant">
	<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT	t.cfirstname + ' ' + t.clastname as 'Resident',*
		FROM	Tenant T with (nolock)
		JOIN	TenantState TS with (nolock) ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #form.iTenant_ID#
	</CFQUERY>

	<!--- ==============================================================================
	Retrieve Chosen Addendum Type
	=============================================================================== --->
	<cfset FailedAt="qAddendumType">	
	<CFQUERY NAME="qAddendumType" DATASOURCE="#APPLICATION.datasource#">
		SELECT	*
		FROM	AddendumType with (nolock)
		WHERE	dtRowDeleted IS NULL
		AND		iAddendumType_ID = #form.iAddendumType_ID#
	</CFQUERY>	


	<CFIF ((IsDefined("form.moveoutdt")) and (form.moveoutdt is not ''))>  
		<!--- ==============================================================================
		UPDATE	TenantState Table with New Move In Date
		=============================================================================== --->
	<cfset FailedAt="qUpdateMoveOut">
		<CFQUERY NAME="qUpdateMoveOut" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtMoveOut = #CreateODBCDateTime(form.moveoutdt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenantState_ID = #qTenant.iTenantState_ID#
		</CFQUERY>
			
	<!--- ==============================================================================
	Retrieve the next Addendum Number
	=============================================================================== --->
	<cfset FailedAt="qNextAddendumMoveOut">
	<CFQUERY NAME="qNextAddendum" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl with (nolock)
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<CFSET	RawAddendumNumber = qNextAddendum.iNextAddendum>

	
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
	
	
 		<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
			<cfset moveoutcomment = 'Physical Move Out changed: ' & #TRIM(form.cComments)#> 
		<CFELSE>
			<cfset moveoutcomment = 'Physical Move Out Changed from:' & mid(form.dtmoveout,5,2)&'/' & right(form.dtmoveout,2) &  '/' & left(form.dtmoveout,4) & ' to: ' 
			& form.moveoutdt + '. '> 
		</CFIF>
	<cfset currentMoveOutdate =   left(form.dtmoveout,4) & '-' & mid(form.dtmoveout,5,2)&'-' & right(form.dtmoveout,2)>	
	<!--- ==============================================================================
	Insert the new information into the AddendumLog
	=============================================================================== --->
	<cfset FailedAt="qWriteToAddenumLogMoveOut">
	<CFQUERY NAME="qWriteToAddenumLogMoveOut" DATASOURCE="#APPLICATION.datasource#">
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
		) VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			 ,#now()# 
			 ,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			,'#moveoutcomment#' 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createODBCDate(currentMoveOutdate)#
			,#createODBCDate(form.moveoutdt)#
		)
 </CFQUERY>
    
   <!--- Ganga 11/28/2017 checking null values ---> 
    <cfif qNextAddendum.iNextAddendum EQ 'null' or qNextAddendum.iNextAddendum EQ '' >
	  <cfset qNextAddendum.iNextAddendum = 10000>	
	 </cfif>
	<!--- gthota end code of checking null values --->
	<CFSET	iNextAddendum = qNextAddendum.iNextAddendum +1>
	
	
	<!--- ==============================================================================
	Update the house number control with the new iNextAddendum Number
	=============================================================================== --->
	<cfset FailedAt="qUpdateControlTable">
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>	
<!---   End dtMoveOut Change ---> 
	 </CFIF>
 	
	<!--- Updates TenantState and Addendum for dtChargeThrough  --->
	<CFIF ((IsDefined("form.chgthroughdt")) and (form.chgthroughdt is not ''))> 
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset chargethrucomment = 'Financial Move Out changed: ' & #TRIM(form.cComments)#>	
<!--- 	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset chargethrucomment = 'Financial Move Out changed from:' & mid(form.dtchargethrough,5,2)&'/' & right(form.dtchargethrough,2) &  '/' & left(form.dtchargethrough,4) & ' to: ' & form.chgthroughdt & '. ' & #TRIM(form.cComments)#> ---> 
	</CFIF>
	<CFif form.chgthroughdt is not ''>
		<cfset chargethrucomment = 'Financial Move Out changed from:' & mid(form.dtchargethrough,5,2)&'/' & right(form.dtchargethrough,2) &  '/' & left(form.dtchargethrough,4) & ' to: ' & form.chgthroughdt & '. '> 
	</CFIF>	 
					
	<cfset FailedAt="qUpdateChgThru">	
		<!--- ==============================================================================
		UPDATE	TenantState Table with New Move In Date
		=============================================================================== --->
		<CFQUERY NAME="qUpdateChgThru" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtchargethrough = #CreateODBCDateTime(form.chgthroughdt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenantState_ID = #qTenant.iTenantState_ID#
		</CFQUERY>																																
		
	<cfset FailedAt="qAddendumNewNumberct">	
	<CFQUERY NAME="qAddendumNewNumberct" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl with (nolock)
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>	
	<CFSET	RawAddendumNumberct = qAddendumNewNumberct.iNextAddendum>
	
	
	<CFSET cAddendumNumberCT = SESSION.HouseNumber & RawAddendumNumberct>
		
	<cfset currentChgThrudate =   left(form.dtchargethrough,4) & '-' & mid(form.dtchargethrough,5,2)&'-' & right(form.dtchargethrough,2)>	
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
		)
		VALUES( 
			'#Variables.cAddendumNumberCT#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			  ,#now()#
			  ,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			,'#chargethrucomment#' 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createOdbCDate(currentChgThrudate)#
			,#createOdbCDate(form.chgthroughdt)#			
		 )
	</CFQUERY> 
	
	<!--- Ganga 11/28/2017 checking null values --->
	<cfif qAddendumNewNumberct.iNextAddendum EQ 'null' or qAddendumNewNumberct.iNextAddendum EQ '' >
	  <cfset qAddendumNewNumberct.iNextAddendum = 10000>	
	 </cfif>
	<!--- gthota end code of checking null values --->
	<CFSET	iNextAddendumct = qAddendumNewNumberct.iNextAddendum +1>

	
	<!--- ==============================================================================
	Update the house number control with the new iNextAddendum Number
	=============================================================================== --->
	<cfset FailedAt="qUpdateControlTable">	
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendumct#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
		 	
</cfif> <!--- End dtChargeThrough update --->
<!--- Move Out Notive Date  --->
	<CFif form.noticedt is not ''>
		<cfset NoticeComment = 'Move Out Notice Date changed from:' & mid(form.dtCurrNoticeDate,5,2)&'/' & right(form.dtCurrNoticeDate,2) &  '/' & left(form.dtCurrNoticeDate,4) & ' to: ' & form.noticedt & '. '> 
 
					
	<cfset FailedAt="qUpdateNoticeDt">	
		<!--- ==============================================================================
		UPDATE	TenantState Table with New Notice Date
		=============================================================================== --->
		<CFQUERY NAME="qUpdateNoticeDate" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtNoticeDate = #CreateODBCDateTime(form.noticedt)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenantState_ID = #qTenant.iTenantState_ID#
		</CFQUERY>																																
		
	<cfset FailedAt="qAddendumNewNumberND">	
	<CFQUERY NAME="qAddendumNewNumberND" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl with (nolock)
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>	
	<CFSET	RawAddendumNumberND = qAddendumNewNumberND.iNextAddendum>
 1) ********* #RawAddendumNumberND# Raw RawAddendumNumberND<BR> 
	 2) ********* #SESSION.HouseNumber# Three Digit HouseNumber<BR>
	
	<CFSET cAddendumNumberND = SESSION.HouseNumber & RawAddendumNumberND>                          
 3) ********* #cAddendumNumberND# Concatenated<BR>	
	<cfset CURRENTNOTICEDATE = left(form.dtCurrNoticeDate,4) & '-' & mid(form.dtCurrNoticeDate,5,2)&'-' & right(form.dtCurrNoticeDate,2)>	

	<cfset FailedAt="qWriteToAddenumLogND">
		 
	<CFQUERY NAME="qWriteToAddenumLogND" DATASOURCE="#APPLICATION.datasource#">
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
		)
		VALUES( 
			'#Variables.cAddendumNumberND#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
			  ,#now()#
			  ,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
 			,'#NoticeComment#' 
			,#SESSION.USERID#
			,#TimeStamp#
			,'#qryUser.EmpName#'
			,#createODBCDate(variables.currentNoticeDate)#
			,#createODBCDate(form.noticedt)#			
		 )
	</CFQUERY> 
    
    <!--- Ganga 11/28/2017 checking null values --->
    <cfif qAddendumNewNumberND.iNextAddendum EQ 'null' or qAddendumNewNumberND.iNextAddendum EQ '' >
	  <cfset qAddendumNewNumberND.iNextAddendum = 10000>	
	 </cfif>
	 <!--- gthota end code of checking null values --->
	<CFSET	iNextAddendumND = qAddendumNewNumberND.iNextAddendum +1>
	4) ********* #iNextAddendumND# Created Next iNextAddendumND Number<BR> 
	
	<!--- ==============================================================================
	Update the house number control with the new iNextAddendum Number
	=============================================================================== --->
	<cfset FailedAt="qUpdateControlTableND">	
	<CFQUERY NAME="qUpdateControlTableND" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendumND#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
		 	
</cfif> <!--- End dtNoticeDate update --->

<!---  --->
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
           ,<cfif #form.iSLPoints# is ''>#form.iSPoints#<cfelse>#form.iSLPoints#</cfif>)	
		</cfquery>

		<cfset FailedAt="All Query Clear">
		<CFCATCH type="any"><h3>Process Failure at Query: #FailedAt#</h3>
		<h3>House ID: #SESSION.qSelectedHouse.iHouse_ID#</h3><br />
		<br />
		    <CFLOOP index=i from=1 to = #ArrayLen(CFCATCH.TAGCONTEXT)#>
          <CFSET sCurrent = #CFCATCH.TAGCONTEXT[i]#>
              <BR>#i# #sCurrent["ID"]# 
				(#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
    		</CFLOOP>	

				<cfset processname = "Move Out Date Edit and Addendum" >
				<cfset residentname = #qTenant.resident#>
				<cfset residentID = #qTenant.itenant_id#>
				<cfset Formname = "MoveOutAddendumAction.cfm">
				<cfif isDefined('form.chgthroughdt') and form.chgthroughdt is not "">
					<cfset chgthrutxt = "Financial Move Out Date: " & #form.chgthroughdt# & "<br> ">
				<cfelse>
					<cfset chgthrutxt = "Financial Move Out Date no entry <br> ">
				</cfif>
				<cfif isDefined('form.moveoutdt') and form.moveoutdt is not "">
					<cfset moveouttxt = "Physical Move Out Date: " & #form.moveoutdt# & "<br> ">
				<cfelse>
					<cfset moveouttxt = "Physical Move Out Date no entry <br> ">
				</cfif>		
				<cfset lastquery = "Last Query Processed: " & #FailedAt# & "<br>">		
			<CFSCRIPT>
				Msg1 = "Move Out Date Edit.<BR>";
				Msg1 = Msg1 & chgthrutxt;
				Msg1 = Msg1 & moveouttxt;
				Msg1 = Msg1 & lastquery; 
			</CFSCRIPT>			
 				<cfset wherefrom = 'Move Out Date Edit'>
  			 <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">
		</CFCATCH>	
  </cftry>		
 
</CFTRANSACTION>

<!--- <CFIF ListFindNoCase(SESSION.CodeBlock,13) GT 0>
	<A HREF="MoveOutAddendum.cfm?ID=#form.iTenant_ID#&ShowBtn=#ShowBtn#">Page Finished Continue</A>
<CFELSE> --->
 	<CFLOCATION URL="MoveOutAddendum.cfm?ID=#form.iTenant_ID#&ShowBtn=#ShowBtn#" ADDTOKEN="No">
<!--- </CFIF> --->

</CFOUTPUT> 