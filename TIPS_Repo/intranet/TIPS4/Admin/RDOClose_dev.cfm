<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RDOClose.cfm                                                                   |
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
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
----------------------------------------------------------------------------------------------->

<!--- Do not allow house rolls less than 1 day apart --->
<!---
<CFQUERY NAME="qLastRolled" DATASOURCE="#APPLICATION.datasource#">
	select max(dtrowstart) as dtrowstart
	from vw_houseLog_history
	where ihouse_id = #SESSION.qSelectedHouse.ihouse_id# and bIsOpsMgrClosed is not null
	and dtrowdeleted is null
</CFQUERY>
--->

<!--- get current dbase time --->
<CFQUERY NAME="qDBaseTime" DATASOURCE="#APPLICATION.datasource#">
	select getdate() as timestamp
</CFQUERY>


<!--- Do not allow house roll if already rolled within one day --->
<!---
<CFIF Abs(DateDiff('d',qLastRolled.dtRowStart,qDBaseTime.timestamp)) LT 1>
<CFOUTPUT>
	<CENTER>
	<A HREF="http://#server_name#/intranet/tips4/mainmenu.cfm">
	<P STYLE="color: red; font-size: medium;">
	This house has already been closed and rolled <BR>
	into a new month within one day.<BR>
	<B>Click Here to Continue</B>
	</P>
	</A>
	</CENTER>
	<CFABORT>
</CFOUTPUT>
</CFIF>
--->	
	
<B STYLE="font-size:small;color:navy;">
<U>Please Note: </U>
<BR> Each house closure will take time to close. 
<BR> Please do not stop or interupt the process once it has started.
<BR> Doing so may cause discrepancies in invoices for the next month.
<BR><BR>
</B>

<CFIF (findnocase("index.cfm",http.referer,1) gt 0)>
	<CFFLUSH>
	<CFFLUSH INTERVAL="10000">
</CFIF>

<CFSCRIPT>
	/* set houseid variable according to list or session variable */
	//writeoutput(findnocase("index.cfm",http.referer,1));
	if (isDefined("form.fieldnames") and findnocase("index.cfm",http.referer,1) gt 0) {
		houselist='';
		for (i=1; i lte listlen(form.fieldnames); i=i+1){
			name=listgetat(form.fieldnames,i,",");
			if (findnocase("close_",name,1) gt 0 ) { houselist=listappend(houselist, gettoken(name, 2, "_"), ","); } 
		}
		location=http.referer;
	}
	else if (isDefined("session.qselectedhouse.ihouse_id")) { 
		ihouseid=session.qselectedhouse.ihouse_id;  
		houselist=session.qselectedhouse.ihouse_id; 
		location="../Mainmenu.cfm";
	}
	else { ihouseid=200; }
</CFSCRIPT>

<CFLOOP INDEX="ihouseid" list="#houselist#">

<!--- ==============================================================================
Retrieve the corresponding AREmail
=============================================================================== --->
<CFQUERY NAME = "GetEmail" DATASOURCE="#APPLICATION.datasource#">
	SELECT	Du.EMail,  DU.Email  	 as PDEmail
		<!--- CASE IsNull(Du.EMail,'None') WHEN 'None' THEN AH.HouseEMail ELSE DU.Email END as PDEmail --->
	FROM House H WITH (NOLOCK)
	LEFT OUTER JOIN	ALCWEB.dbo.employees DU WITH (NOLOCK)	ON H.iPDUser_ID = DU.Employee_ndx
<!--- 	JOIN #application.censusdbserver#.Census.dbo.HouseAddresses AH ON AH.nHouse = H.cNumber --->
	WHERE H.iHouse_ID = #ihouseid#
</CFQUERY>


<CFTRANSACTION>

<!--- ==============================================================================
Retrieve the Houses' Data and TIPS Month
=============================================================================== --->
<CFQUERY NAME = "HouseData" DATASOURCE = "#APPLICATION.datasource#">
	SELECT *, HL.iHouseLog_ID as LogID
	FROM House H WITH (NOLOCK)
	JOIN HouseLog HL WITH (NOLOCK) ON H.iHouse_ID = HL.iHouse_ID	
	WHERE H.iHouse_ID = #ihouseid#
	AND	H.dtRowDeleted IS NULL AND HL.dtRowDeleted IS NULL
</CFQUERY>

<CFSCRIPT>
	/* Set house variables for the current house */
	housename=housedata.cname;
	housenumber=housedata.cnumber;
	housemonth=housedata.dtCurrentTipsMonth;
	
	/* Calculate next tips month */
	NewTIPSMonth = DateAdd("m", 1, HouseData.dtCurrentTipsMonth);
	TIPSCSVPeriod = HouseData.dtCurrentTipsMonth;

	//Write onScreen output
	WriteOutPut("Closing " & housename & "....");
</CFSCRIPT>
	
	<!--- ==============================================================================
	Update the House Log for the RDO Close
	=============================================================================== --->
	<CFQUERY NAME="RDOClose" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	HouseLog
		SET 	iHouse_ID = #ihouseid#,
				dtCurrentTipsMonth = '#housemonth#',
				bIsOpsMgrClosed = 1,
				dtActualEffective = getDate(),
				cComments = NULL,
				dtAcctStamp = #CreateODBCDateTime(SESSION.AcctStamp)#,
				iRowStartUser_ID = #SESSION.UserID#,
				dtRowStart = getDate()
		WHERE 	dtRowDeleted IS NULL and iHouse_ID = #ihouseid#		
	</CFQUERY>

	<!--- ==============================================================================
	Update the House Log for the RDO Close
	=============================================================================== --->
	<CFQUERY NAME="NewMonth" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	HouseLog
		SET 	iHouse_ID = #ihouseid#,
				dtCurrentTipsMonth = '#DateFormat(NewTipsMonth,"yyyy-mm-dd")#',
				bIsPDClosed	= NULL,
				bIsOpsMgrClosed	= NULL,
				dtActualEffective = getDate(),
				cComments = NULL,
				dtAcctStamp = #CreateODBCDateTime(SESSION.AcctStamp)#,
				iRowStartUser_ID = #SESSION.UserID#,
				dtRowStart = getDate()
		WHERE 	dtRowDeleted IS NULL and iHouse_ID = #ihouseid#		
	</CFQUERY>	
<cfif session.userid eq 4711>
 <cfoutput> #housenumber#</cfoutput>


	<!--- ==============================================================================
	Run End of Month Stored Proceedure
	=============================================================================== --->
	<CFSET Procname='rw.sp_EOM1A'>
	<cfstoredproc procedure="#ProcName#" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
		<cfprocresult name="rsChangedInvoices">
		<cfprocparam type="IN" value="#housenumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="IN" value="0" DBVARNAME="@bCheckForChanges" cfsqltype="CF_SQL_BIT">
		<cfprocparam type="IN" value="1" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
		<cfprocparam type="IN" value="1" DBVARNAME="@bMonthEnd" cfsqltype="CF_SQL_BIT">
		<cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">
	</cfstoredproc>
	<cfdump var="#rsChangedInvoices#">
	<cfoutput>value of icnt- "#iCnt#"</cfoutput>
	<cfabort>
</cfif>
	<CFSET Procname='rw.sp_EOM1A'>
	<cfstoredproc procedure="#ProcName#" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
		<cfprocresult name="rsChangedInvoices">
		<cfprocparam type="IN" value="#housenumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
		<cfprocparam type="IN" value="0" DBVARNAME="@bCheckForChanges" cfsqltype="CF_SQL_BIT">
		<cfprocparam type="IN" value="1" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
		<cfprocparam type="IN" value="1" DBVARNAME="@bMonthEnd" cfsqltype="CF_SQL_BIT">
		<cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">
	</cfstoredproc>
	
	<CFIF CFSTOREDPROC.STATUSCODE NEQ 0>
		<CFTRANSACTION ACTION="ROLLBACK">
		An error has occurred. <BR> <CFOUTPUT>ERROR CODE : #CFSTOREDPROC.STATUSCODE#</CFOUTPUT> <A HREF ="../MainMenu.cfm">Click Here to Continue.</A>
		<CFMAIL TYPE ="html" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="STOREDPROC STATUS CODE ERROR">
			#ihouseid#<BR> ERROR CODE : #CFSTOREDPROC.STATUSCODE#<BR> ____________________________________________________
		</CFMAIL>			
		
		<CFABORT>
	</CFIF>
	
	<!--- ==============================================================================
	Reset the Session Variable for the TIPS Month
	=============================================================================== --->
	<CFQUERY NAME = "NewTIPSMonth" DATASOURCE = "#APPLICATION.datasource#">
		SELECT dtCurrentTipsMonth FROM HouseLog WITH (NOLOCK) WHERE dtRowDeleted IS NULL AND iHouse_ID = #ihouseid#		
	</CFQUERY>
	
	<CFSCRIPT>
		//WriteOutPut(NewTipsMonth.dtCurrentTipsMonth); // write debug
		/* Set Variables for the past and new months */
		oldtipsmonth=housemonth; 	NewMonth=NewTipsMonth.dtCurrentTipsMonth;
		if (not isDefined("houselist") ) { SESSION.TIPSMonth = NewMonth; }
	</CFSCRIPT>
	
</CFTRANSACTION>

<!---  Do not run imports for zeta test house --->
<CFIF ihouseid NEQ 200>
	<!--- mstriegel:11/17/2017 added autoRelease and converted to a cfc 
	<cfset qAutoImport = session.storedProc.sp_ExportInv2Solomon(iHouseID=#trim(iHouseID)#,period='#dateFromat(oldtipsmonth,"yyyymm")#',invoice="",autoRelease=1)>---->
	
	<CFTRY>
		<!--- <CFIF server_name neq 'OLDBIRCH'></CFIF> --->
		<!--- Run autoimport procedure --->
		<CFQUERY NAME='qAutoImport' DATASOURCE="#APPLICATION.datasource#">
			Declare @Status int 
			exec sp_ExportInv2Solomon  #trim(ihouseid)#, '#DateFormat(oldtipsmonth,"yyyymm")#', NULL, @Status OUTPUT
			Select @Status
		</CFQUERY>

		<CFCATCH>
			<!---- Send debug email for error during import ---->
			<cfif    (CGI.SERVER_NAME is not "vmappprod01dev3")>
			<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="Auto Import Monthly">
				Declare @Status int
				exec sp_ExportInv2Solomon  #trim(ihouseid)#, '#DateFormat(oldtipsmonth,"yyyymm")#', NULL, @Status OUTPUT
				Select @Status<BR>
				#server_name#
			</CFMAIL>
			</cfif>
		</CFCATCH>
	</CFTRY>
	
	<!--- mstriegel:11/17/17 --->
</CFIF>
<cfoutput> #trim(ihouseid)#, '#DateFormat(oldtipsmonth,"yyyymm")#'</cfoutput>
<!--- ==============================================================================
Generate MonthlyCSV's for this House
<CF_Invoice iHouse_ID=#ihouseid# TipsMonth=#DateFormat(TIPSCSVPeriod,"yyyy-mm-dd")#>
<CFPARAM NAME="FileCSV" TYPE="string" Default="">
=============================================================================== --->

<!--- <CFMAIL TYPE="html" FROM="TIPS4-Message@alcco.com" TO="#GetEMail.PDEmail#" SUBJECT="Accounting has approved TIPS for #housename#">
	Accounting has approved TIPS for #housename#.<BR>
	The TIPS Month is now #DateFormat(NewMonth,"mm/yyyy")#<BR><BR>
	<FONT style="font-size:xx-small;">
		[#server_name#] server_time #now()# 
		<CFIF isDefined("session.fullname")>user:#session.fullname#</CFIF>
	</FONT>
	<CFIF isDefined("fielcsv")>CSV File: #FileCSV#<BR></CFIF>
</CFMAIL> --->
	
<CFSCRIPT>
	WriteOutPut(housename & " is now closed. <BR>");
</CFSCRIPT>

</CFLOOP>

<CFOUTPUT>
 
<CFIF (findnocase("index.cfm",http.referer,1) gt 0)>
	<A HREF='#location#'>Click Here to Continue</A>
<CFELSE>
	<CFLOCATION URL='http://#server_name#/intranet/TIPS4/MainMenu.cfm' addtoken="no">
</CFIF>

</CFOUTPUT>
