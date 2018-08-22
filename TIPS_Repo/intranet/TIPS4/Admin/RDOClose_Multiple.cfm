<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RDOClose_Multiple.cfm                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Gthota     | 09/21/2017 | Create Flower Box                                                  |
|MStriegel   |11/08/2017  | set autorelease to 1 and changed to call component    			   |
|ganga       |04/05/2018  | Added is not null to isAssetClass                                  |
----------------------------------------------------------------------------------------------->

<CFINCLUDE TEMPLATE="../../header.cfm">
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<cfoutput>
<cfform name ="houseclose">
<cfparam  name="form.iOpsArea_id" default="">


<cfif !isDefined(form.iOpsArea_id)>
	<cfif form.iOpsArea_id is ''>
	Please select a Region to Accounting Close<br /><br/>
	<a href="../Admin/RDOClose_mainpage.cfm"><P STYLE="color: red; font-size: medium;">Return to AR Accounting close Menu</P></a>
	<cfabort>
   </cfif>	
</cfif>

<TABLE style="width:500" border ="2">	
	<CFQUERY NAME="qregionname" DATASOURCE="#APPLICATION.datasource#">
		SELECT cname
		  FROM OpsArea WITH (NOLOCK)
		   WHERE iOpsArea_id = #form.iOpsArea_id# and dtrowdeleted is null	  
	</CFQUERY>

	<TR bgcolor ="yellow">
	 <td>&nbsp;<h3> #qregionname.cname# region Invoice month closing... Please wait..! &nbsp; </h3></td>
	 </TR>	
	</TABLE>
</cfform>
</cfoutput>
	
<!--- Retrieve House Month Information--->
<CFQUERY NAME = "HouseLog" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	bIsPDClosed, bIsCentralized,dtActualEffective,dtAcctStamp,dtCurrentTipsMonth 
	FROM HouseLog with (nolock)
    WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND dtRowDeleted IS NULL
</CFQUERY>

<CFQUERY NAME="qinvoicemonth" DATASOURCE="#APPLICATION.datasource#">
	select * from [dbo].[TIPSInvoiceMonth] WITH (NOLOCK) where dtrowdeleted is null	
</CFQUERY>

<cfset now = #now()#>
<cfset month = #MonthAsString(Month(Now()))#>
<!--- <cfset month1 = #MonthAsString(Month(Now())+1)#> --->
<cfset housemonth = #MonthAsString(Month(HouseLog.dtCurrentTipsMonth))# >

<cfif #Month(qtipsmonth.dtCurrentTipsMonth)# EQ 12>
    <cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth))# >
<cfelseif #Month(qtipsmonth.dtCurrentTipsMonth)# EQ 1>
    <cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)+11)# >
<cfelse>
    <cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)-1)# >
</cfif>

<!--- <cfset housemonth1 = #MonthAsString(Month(HouseLog.dtCurrentTipsMonth)-1)# >  
<cfif #Month(qtipsmonth.dtCurrentTipsMonth)# EQ 1>
<cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)+11)# >
<cfelse>
<cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)-1)# >
</cfif>
--->

<CFQUERY NAME="qHouse" DATASOURCE="#APPLICATION.datasource#">
	SELECT h.ihouse_id as ihouseid,h.cname,h.iopsarea_id,h.cNumber 
	FROM House h with (nolock)
	Join HouseLog hl with (nolock) ON h.ihouse_id = hl.iHouse_id and hl.dtrowdeleted is null
	WHERE iOpsArea_id = #form.iOpsArea_id# and h.dtrowdeleted is null	 
	AND hl.dtCurrentTipsMonth < '#qinvoicemonth.dtCurrentTipsMonth#'  
	AND h.ihouse_id <> 200 and h.bisSandbox = 0
	 AND  h.dtRowDeleted is null 
	 AND h.AssetClass is not null 
</CFQUERY>


<CFIF qHouse.RecordCount GT 0>
	<div id="loadmsg" style="position:absolute; top:25px; margin:auto; color:black;background-color:yellow;padding:2em"> 
	Loading ... Please Wait 
	</div> 
	<cfloop query ="qHouse">   

	<CFIF (findnocase("index.cfm",http.referer,1) gt 0)>
		<CFFLUSH>
		<CFFLUSH INTERVAL="5000">
	</CFIF>

	<!--- ==============================================================================
	Retrieve the corresponding AREmail
	=============================================================================== --->
	<CFQUERY NAME = "GetEmail" DATASOURCE="#APPLICATION.datasource#">
		SELECT	Du.EMail,  DU.Email  	 as PDEmail
			<!--- CASE IsNull(Du.EMail,'None') WHEN 'None' THEN AH.HouseEMail ELSE DU.Email END as PDEmail --->
		FROM House H with (nolock)
		LEFT OUTER JOIN	ALCWEB.dbo.employees DU with (nolock) ON H.iPDUser_ID = DU.Employee_ndx
		WHERE H.iHouse_ID = #ihouseid#
	</CFQUERY>


	<CFQUERY NAME = "HouseLogid" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	dtCurrentTipsMonth 
		FROM HouseLog with (nolock)
	    WHERE iHouse_ID = #qHouse.ihouseid#
	     AND dtRowDeleted IS NULL
	</CFQUERY>

	<cfif #HouseLogid.dtCurrentTipsMonth#  LT #qinvoicemonth.dtCurrentTipsMonth# >

	<CFTRANSACTION>

		<!--- ==============================================================================
		Retrieve the Houses' Data and TIPS Month
		=============================================================================== --->
		<CFQUERY NAME = "HouseData" DATASOURCE = "#APPLICATION.datasource#">
			SELECT *, HL.iHouseLog_ID as LogID
			FROM House H with (nolock)
			JOIN HouseLog HL with (nolock) ON H.iHouse_ID = HL.iHouse_ID	
			WHERE H.iHouse_ID = #ihouseid#
			AND	H.dtRowDeleted IS NULL AND HL.dtRowDeleted IS NULL
		</CFQUERY>

		<CFSCRIPT>
			/* Set house variables for the current house */
			housename=housedata.cname;
			housenumber=housedata.cnumber;
			housemonth=housedata.dtCurrentTipsMonth;
			houseID = housedata.iHouse_ID;
			
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


		<!--- ==============================================================================
		Run End of Month Stored Proceedure
		=============================================================================== --->
		<!--- mstsriegel 01/24/2018 add try catch --->
		<cftry>
		<CFSET Procname='rw.sp_EOM1A'>
		<cfstoredproc procedure="#ProcName#" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
			<cfprocresult name="rsChangedInvoices">
			<cfprocparam type="IN" value="#housenumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
			<cfprocparam type="IN" value="0" DBVARNAME="@bCheckForChanges" cfsqltype="CF_SQL_BIT">
			<cfprocparam type="IN" value="1" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
			<cfprocparam type="IN" value="1" DBVARNAME="@bMonthEnd" cfsqltype="CF_SQL_BIT">
			<cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">
		</cfstoredproc>
		
		<cfcatch type="any">
			<cfset housename = session.oExportInv2Solomon.getHouseInformation(datasource="TIPS4",houseID=iHouseID)>
			<cfset fName = "batchNotCreatedInTips_#dateformat(now(),'mmddyyyy')#_t_#timeformat(now(),'HHnnss')#"> 		
 			<cfset temp =  session.oUtilityServices.spreadsheetNewFromQuery(thedata=qGetHouseInfo,sheetName="Data",filename=fName,outputToBrowser=false)>
	 		<cfmail type="html" from="TIPS4-message@alcco.com" to="jgedelman@enlivant.com" cc="gthota@enlivant.com;mstriegel@enlivant.com;syenugula@enlivant.com" subject="Batch not created in TiPS" mimeattach="#temp#" remove="true">
				The following house #housedata.cname# failed to close in TIPS
			</cfmail>		
		</cfcatch>
		</cftry>
		<!--- end mstriegel --->


		<cfdump var="#rsChangedInvoices#">
		<CFIF CFSTOREDPROC.STATUSCODE NEQ 0>
			<CFTRANSACTION ACTION="ROLLBACK">
			An error has occurred. <BR> <CFOUTPUT>ERROR CODE : #CFSTOREDPROC.STATUSCODE#</CFOUTPUT> <A HREF ="../MainMenu.cfm">Click Here to Continue.</A>
			<CFMAIL TYPE ="html" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="STOREDPROC STATUS CODE ERROR">
				#ihouseid#<BR> ERROR CODE : #CFSTOREDPROC.STATUSCODE#<BR> ____________________________________________________
			</CFMAIL>			
			
			<CFABORT>
		</CFIF>
		
		<!---  =============================================================================
		House Closing log table..
		============================================================================== --->
		<CFQUERY NAME = "NewTIPShouseUpdate" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE HouseClose_Audit
			     SET  dtRowDeleted = getdate(), dtRowDeletedUser = '#SESSION.Username#'
			     WHERE iHouse_ID = #ihouseid#		
		</CFQUERY>
		
		<CFQUERY NAME = "NewTIPSMonth" DATASOURCE = "#APPLICATION.datasource#">
			insert into HouseClose_Audit(iHouse_ID,iOpsArea_ID,cName,dtAcctStamp,iRowStartUser,dtCurrentTipsMonth)
	               Values(#ihouseid#,#iOpsArea_ID#,'#cname#',getdate(),'#SESSION.Username#','#housemonth#')		
		</CFQUERY>	
		
		<!--- ==============================================================================
		Reset the Session Variable for the TIPS Month
		=============================================================================== --->


		<CFQUERY NAME = "NewTIPSMonth" DATASOURCE = "#APPLICATION.datasource#">
			SELECT dtCurrentTipsMonth 
			FROM HouseLog with (nolock) 
			WHERE dtRowDeleted IS NULL AND iHouse_ID = #ihouseid#		
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
		<!--- Run autoimport procedure --->
		<!---- mstriegel:01/18/2018 ---->
		<cfset argsCollection = {iHouseID=#iHouseid#,period=#dateFormat(oldtipsmonth,'yyyymm')#,invoice="",batchType="multihouse"}>
		<cfset qAutoImport = session.oExport2Solomon.sp_ExportInv2Solomon(argumentCollection=argsCollection)>
	 	<!---
		<CFTRY>	
			<CFQUERY NAME='qAutoImport' DATASOURCE="#APPLICATION.datasource#">
				Declare @Status int 
				exec rw.sp_ExportInv2Solomon  #trim(ihouseid)#, '#DateFormat(oldtipsmonth,"yyyymm")#',NULL, @Status OUTPUT
				Select @Status
			</CFQUERY>
				
			<CFCATCH>
				<!---- Send debug email for error during import ---->
				<cfif    (CGI.SERVER_NAME is not "vmappprod01dev3")>
				<CFMAIL TYPE="HTML" FROM="TIPS4-MHCtoINVSolomon@enlivant.com" TO="#session.developerEmailList#" cc="gthota@enlivant.com" SUBJECT="Auto Import Monthly">
					Declare @Status int
					exec rw.sp_ExportInv2Solomon  #trim(ihouseid)#, '#DateFormat(oldtipsmonth,"yyyymm")#',NULL, @Status OUTPUT
					Select @Status<BR>
					#server_name#
					TIPS4\Admin\RDOClose_Multiple.cfm
				</CFMAIL>
				</cfif>
			</CFCATCH>
		</CFTRY>
		--->
	    <!---- end mstriegel:01/18/2018 --->
	</CFIF>


	<!--- ==============================================================================
	Generate MonthlyCSV's for this House
	<CF_Invoice iHouse_ID=#ihouseid# TipsMonth=#DateFormat(TIPSCSVPeriod,"yyyy-mm-dd")#>
	<CFPARAM NAME="FileCSV" TYPE="string" Default="">
	=============================================================================== --->--->
	
	<CFSCRIPT>
		WriteOutPut(housename & " is now closed. <BR>");
	</CFSCRIPT>   
</cfif>  <!--- ganga ---> 
<CFOUTPUT>

<CFIF (findnocase("index.cfm",http.referer,1) gt 0)>
	<A HREF='#location#'>Click Here to Continue</A>
<CFELSE>
	<!---<CFLOCATION URL='http://#server_name#/intranet/TIPS4/MainMenu.cfm' addtoken="no">  --->
</CFIF>
  <!--- <td>House closed for account period of #now()# and House number - #ihouseid#</td> --->
</CFOUTPUT>
 
 </cfloop> 

 
<CFELSE>
<CFOUTPUT>
	<CENTER>	
	<P STYLE="color: red; font-size: medium;">sed. <BR>	
	<B>Click H
	This Region do not have any Community to cloere to Continue</B>
	</P>
	<button onclick="window.history.back();">Go Back</button>
	</CENTER>
	<CFABORT>
</CFOUTPUT>
</CFIF>
</body>
<CFLOCATION URL='http://#server_name#/intranet/TIPS4/MainMenu.cfm' addtoken="no">
