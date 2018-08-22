<!--- *******************************************************************************
Name:			MoveInAddendumAction.cfm
Process:		Alter finalized Moved In dates dtmovein dtrenteffective

Called by: 		MoveInAddendum.cfm
 
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            02/07/2002      Original Authorship
Steven Farmer           09/05/2017      Revised to allow AR to change dtmovein and dtrenteffective
******************************************************************************** --->
<cfoutput>
<cfparam name="FailedAt"  default="">
<CFTRANSACTION>
<cftry>
<cfparam name="moveincomment" default="">

	<!--- Retrieve current SQL Server Time for stamp--->
	<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
		SELECT	GetDate() as TimeStamp
	</CFQUERY>
	<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>
	<!--- 	Retrieve Chosen Addendum Type --->
	<cfset FailedAt="qAddendumType">
	<CFQUERY NAME="qAddendumType" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iAddendumType_ID
		FROM	AddendumType
		WHERE	dtRowDeleted IS NULL
		AND		iAddendumType_ID = #form.iAddendumType_ID#
	</CFQUERY>	
	<cfset FailedAt="qTenant">	
	<CFQUERY NAME="qTenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT	t.cfirstname + ' ' + t.clastname as 'Resident',*
		FROM	Tenant T
		JOIN	TenantState TS ON (TS.iTenant_ID = T.iTenant_ID AND TS.dtRowDeleted IS NULL AND T.dtRowDeleted IS NULL)
		WHERE	T.iTenant_ID = #form.iTenant_ID#
	</CFQUERY>
	<!--- Physical Move In --->
<cfif ((IsDefined("form.phydate")) and (form.phydate is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset moveincomment = 'Physical Move In Date Changed. ' & #TRIM(form.cComments)#>	
	<CFELSE>
		<cfset moveincomment = 'Physical Move In Date changed. ' & mid(form.currmovindate,5,2)&'/' & right(form.currmovindate,2) &  '/' & left(form.currmovindate,4) & ' to: ' & form.phydate & '. '> 
	</CFIF>		
	
	
	<!--- Retrieve the next Addendum Number--->
		<cfset FailedAt="qNextAddendum">	
	<CFQUERY NAME="qNextAddendum" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<CFSET	RawAddendumNumber = qNextAddendum.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
	<cfset currentmoveindate =   left(form.currmovindate,4) & '-' & mid(form.currmovindate,5,2)&'/' & right(form.currmovindate,2)>
	<cfset FailedAt="qWriteToAddendumLog">	
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
			,dtChangeFrom
			,dtChangeTo
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
		  	,#TimeStamp#
			,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
			,'#TRIM(variables.moveincomment)#' 
			,#SESSION.USERID#
			,#TimeStamp#
			,#createOdbCDate(currentmoveindate)#
			,#createOdbCDate(form.phydate)#
		)
	</CFQUERY>
	<CFSET	iNextAddendum = qNextAddendum.iNextAddendum +1>
	<cfset FailedAt="qAddendumType">
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	<cfset FailedAt="qAddendumType">
	<CFQUERY NAME="qUpdateMoveIn" DATASOURCE="#APPLICATION.datasource#">
			UPDATE	TenantState
			SET		dtMoveIn = #CreateODBCDateTime(form.phydate)#,
					iRowStartUser_ID = #SESSION.USERID#,
					dtRowStart = #TimeStamp#
			WHERE	iTenant_ID = #form.iTenant_ID#
            		And dtRowDeleted IS NULL
	</CFQUERY>
	
	<CFSET	iNextAddendum = qNextAddendum.iNextAddendum +1>
	<cfset FailedAt="qAddendumType">	
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendum#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
</CFif>
<!--- Update  Rent Effective Move In Date --->
<CFIF ((IsDefined("form.RentEffDt")) and (form.RentEffDt is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset RentEffDtcomment = 'Financial Possession Date changed. ' & #TRIM(form.cComments)#>	
<!--- 		<cfset RentEffDtcomment = 'Financial Move Out changed from:' & mid(form.curreffdate,5,2)&'/' & right(form.curreffdate,2) &  '/' & left(form.curreffdate,4) & ' to: ' & form.RentEffDt & '. ' & #TRIM(form.cComments)#> ---> 
	<CFELSE>
		<cfset RentEffDtcomment = 'Financial Possession Date changed. ' & mid(form.curreffdate,5,2)&'/' & right(form.curreffdate,2) &  '/' & left(form.curreffdate,4) & ' to: ' & form.RentEffDt & '. '> 
	</CFIF>	
	<cfset FailedAt="qUpdateMoveIn">	
	<CFQUERY NAME="qUpdateMoveIn" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	TenantState
		SET		dtRentEffective = #CreateODBCDateTime(form.RentEffDt)#,
				iRowStartUser_ID = #SESSION.USERID#,
				dtRowStart = #TimeStamp#
		WHERE	iTenant_ID = #form.iTenant_ID#
				And dtRowDeleted IS NULL
	</CFQUERY>
	<cfset FailedAt="qNextAddendumRE">		
	<CFQUERY NAME="qNextAddendumRE" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<CFSET	RawAddendumNumber = qNextAddendumRE.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
	<cfset currenteffdate =   left(form.curreffdate,4) & '-' & mid(form.curreffdate,5,2)&'/' & right(form.curreffdate,2)>
	<cfset FailedAt="qWriteToAddendumLog">	
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
			,dtChangeFrom
			,dtChangeTo			
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
		  	,#TimeStamp#
			,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
			,'#TRIM(variables.RentEffDtcomment)#' 
			,#SESSION.USERID#
			,#TimeStamp#
			,#createODBCDate(currenteffdate)#
			,#CreateODBCDate(form.RentEffDt)#			
		)
	</CFQUERY>	
	<CFSET	iNextAddendumRE = qNextAddendumRE.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTable">	
	<CFQUERY NAME="qUpdateControlTable" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendumRE#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
</CFif>

<!---  --->
<!--- Update Projected Move Out Date --->
<CFIF ((IsDefined("form.ProjDt")) and (form.ProjDt is not ''))>
	<CFIF IsDefined("form.cComments") AND TRIM(form.cComments) NEQ "">
		<cfset RentProjDtcomment = 'Projected Move Out Date changed. ' & #TRIM(form.cComments)#>	
	<CFELSE>
		<cfset RentProjDtcomment = 'Financial Possession Date changed. ' & mid(form.curreffdate,5,2)&'/' & right(form.curreffdate,2) &  '/' & left(form.curreffdate,4) & ' to: ' & form.RentEffDt & '. '> 
	</CFIF>	
	<cfset FailedAt="qUpdateMoveIn">	
	<CFQUERY NAME="qUpdateMoveIn" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	TenantState
		SET		dtmoveoutprojecteddate = #CreateODBCDateTime(form.ProjDt)#,
				iRowStartUser_ID = #SESSION.USERID#,
				dtRowStart = #TimeStamp#
		WHERE	iTenant_ID = #form.iTenant_ID#
				And dtRowDeleted IS NULL
	</CFQUERY>
	<cfset FailedAt="qNextAddendumPJ">		
	<CFQUERY NAME="qNextAddendumPJ" DATASOURCE="#APPLICATION.datasource#">
		SELECT	iNextAddendum
		FROM	HouseNumberControl
		WHERE	dtRowDeleted IS NULL
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
	
	<CFSET	RawAddendumNumber = qNextAddendumPJ.iNextAddendum>
	<CFSET cAddendumNumber = SESSION.HouseNumber & RawAddendumNumber>
		<cfset currentProjMvOutdt =   left(form.CURRPROJMOVEOUTDATE,4) & '-' & mid(form.CURRPROJMOVEOUTDATE,5,2)&'/' & right(form.CURRPROJMOVEOUTDATE,2)>
	<cfset FailedAt="qWriteToAddendumLogPJ">		
	<CFQUERY NAME="qWriteToAddenumLogPJ" DATASOURCE="#APPLICATION.datasource#">
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
			,dtChangeFrom
			,dtChangeTo			
		)VALUES(
			'#Variables.cAddendumNumber#'
			,#form.iTenant_ID#
			,#qAddendumType.iAddendumType_ID#
		  	,#TimeStamp#
			,NULL 
			,#DateFormat(SESSION.TIPSMonth,"yyyymm")# 
			,'#TRIM(variables.RentProjDtcomment)#' 
			,#SESSION.USERID#
			,#TimeStamp#
			,#createODBCDate(currentProjMvOutdt)#
			,#CreateODBCDate(form.ProjDt)#			
		)
	</CFQUERY>	
	<CFSET	iNextAddendumPJ = qNextAddendumPJ.iNextAddendum +1>
	<cfset FailedAt="qUpdateControlTablePJ">	
	<CFQUERY NAME="qUpdateControlTablePJ" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	HouseNumberControl
		SET		iNextAddendum = #Variables.iNextAddendumPJ#,
				dtRowStart = #TimeStamp#,
				iRowStartUser_ID = #SESSION.USERID#
		WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	</CFQUERY>
</CFif>
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
           (11
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
		<h3>House ID: #SESSION.qSelectedHouse.iHouse_ID#</h3><br />
		<br />
		    <CFLOOP index=i from=1 to = #ArrayLen(CFCATCH.TAGCONTEXT)#>
          <CFSET sCurrent = #CFCATCH.TAGCONTEXT[i]#>
              <BR>#i# #sCurrent["ID"]# 
				(#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
    		</CFLOOP>	

				<cfset processname = "Move in Date Edit and Addendum" >
				<cfset residentname = #qTenant.resident#>
				<cfset residentID = #qTenant.itenant_id#>
				<cfset Formname = "MoveInAddendumAction.cfm">
				<cfif ((isDefined('form.phydate')) and (form.phydate is not ""))>
					<cfset MoveIntxt = "Physical Move In Date: " & #form.phydate# & "<br> ">
				<cfelse>
					<cfset MoveIntxt = "Physical Move In Date no entry <br> ">
				</cfif>
				<cfif ((isDefined('form.RentEffDt')) and (form.RentEffDt is not ""))>
					<cfset RentEfftxt = "Financial Possession Date: " & #form.RentEffDt# & "<br> ">
				<cfelse>
					<cfset RentEfftxt = "Financial Possession Date no entry <br> ">
				</cfif>	
				<cfif ((isDefined('form.ProjDt')) and (form.ProjDt is not ""))>
					<cfset ProjectedMoveOuttxt = "Projected Move Out Date: " & #form.ProjDt# & "<br> ">
				<cfelse>
					<cfset ProjectedMoveOuttxt = "Projected Move Out Date no entry <br> ">
				</cfif>						
				
			<CFSCRIPT>
				Msg1 = "Move In Date Edit and Addendum.<BR>";
				Msg1 = Msg1 & MoveIntxt;
				Msg1 = Msg1 & RentEfftxt;
				Msg1 = Msg1 & ProjectedMoveOuttxt;
				Msg1 = "<br> Failed at: " &  #FailedAt#;
				Msg1 = Msg1 & '<br>' & #formdump#;
			</CFSCRIPT>			
 				<cfset wherefrom = 'Move In Date Edit and Addendum'>
    	 <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">
	
		</CFCATCH>	
		
	  </cftry>	
</CFTRANSACTION>

 
	<CFLOCATION URL="TenantEdit.cfm?ID=#form.iTenant_ID#" ADDTOKEN="No">
</CFOUTPUT>