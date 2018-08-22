<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| pbuendia   | 02/07/2002 | Original Authorship                                                |
| pbuendia   | 04/29/2002 | Added jscript document write to avoid processing errors            |
| ranklam    | 11/27/2006 | Created                                                            |
| ranklam    | 11/22/2006 | fixing problem with pdclose not relocating people                  |
| ranklam    | 12/22/2006 | fixing problem with rdoclose reopening houses                      |
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
| mlaw       | 02/26/2007 | add centralize report function for AR                              |
| RTS        | 11/11/2008 | Modifications added for Project 26955  Bond Designations           |
| RTS        | 09/15/2009 | Proj 42877 - Invoice Details Admin for IT Support                  |
| RTS        | 10/09/2009 | Proj 42573 - Closed Account MO Date change                         |
| RTS        | 01/19/2010 | Proj 35227 - MI AutoApply RecurringCharges                         |
| Sathya     | 02/26/2010 | Proj 20933 made changes for Late Fee                               |
|Sathya      | 07/16/2010  | Project 20933-PartB added the link to CurrentLateFee.cfm          |
|S Farmer    | 06/01/2011  | Project 71776 added Move Out Reason Modifications link            |
----------------------------------------------------------------------------------------------->
<cfoutput>
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<SCRIPT>
	function wait(close,url)
	{ 
		
		document.write("<CENTER><B STYLE='font-size: 24; color: red;'>Processing Please Wait....</B></CENTER>"); 
		
		if(close)
		{	
			window.location = url + '?close=1';
		}
		else
		{
			window.location = url + '?open=1';
		}
	}
</SCRIPT>
<script language="javascript">
	function updateHouseLog(obj)
	{
			
		var url = '';
		var querystring = '';
		var isChecked = false;
		
		url = 'http://#server_name#/intranet/TIPS4/Admin/CentralizeReport/ActionFiles/act_centralizereport.cfm';
		
		if (obj.checked) 
		{
		  isChecked = true;
		}
		
		querystring = '?houseid=' + #session.qselectedhouse.ihouse_id# +
					  '&checked=' + isChecked.toString() +
					  '&db=' + '#application.datasource#';
		
		responseXml = doPost(url,querystring);
		
		response = responseXml.documentElement;

		if(response.childNodes[0].nodeName == 'success')
		{
			ShowMessage('messageBox',response.childNodes[0].childNodes[0].nodeValue,true);
		}
		else
		{
			alert('false');
		}
	}
	
	//populate the message grid via ajax call
	function doPost(url,querystring)
	{		
		//if activex is available (ms browser)
		if (window.ActiveXObject) 
		{ 
			xmlhttp = new ActiveXObject("Microsoft.XMLHTTP"); 
		} 
		else if(window.XMLHttpRequest)
		{ 
			xmlhttp = new XMLHttpRequest(); 
		}
		
		//open the request
		xmlhttp.open("Get",url+querystring,false);
		xmlhttp.setRequestHeader("Content-Type","application/x-www-form-urlencoded;");
		xmlhttp.send();
		
		//display the return values
		return xmlhttp.responseXML;
	}

	function ShowMessage(divName,message,isError)
	{	
		messageArea = document.getElementsByName(divName)[0];
		
		if(isError)
		{
			messageArea.className = 'error';
		}
		else
		{
			messageArea.className = 'success';
		}
		messageArea.style.visibility = 'visible';
		messageArea.innerHTML = message;
	}
	
	function HideMessage()
	{
		messageArea = document.getElementsByName('message')[0];
		messageArea.style.display = 'none';
	}
</script>

<CFTRY>
	<!--- Retrieve data for changes to EOM since last admin viewing
	NO parameters signifying MID MONTH ROLL thus rollingback all changes and not commiting any changes. --->
	<cfstoredproc procedure="rw.sp_EOM1A" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
		<cfprocresult NAME="MidMonth" resultset="1">
        <cfprocparam type="IN" value="#SESSION.qSelectedHouse.cNumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
        <cfprocparam type="IN" value="1" DBVARNAME="@bCheckForChanges" cfsqltype="CF_SQL_BIT">
        <cfprocparam type="IN" value="0" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
        <cfprocparam type="IN" value="0" DBVARNAME="@bMonthEnd" cfsqltype="CF_SQL_BIT">
        <cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">
	</cfstoredproc>

	<CFCATCH TYPE="Lock">

		<CFSCRIPT>
			message = "***BEGIN***<BR>";
			if (IsDefined("Error.Diagnostics")) { message = message & "Diagnostics ** #Error.Diagnostics# **<BR>"; }
			message = message & "Remote Address: #REMOTE_ADDR#<BR>";
			message = message & "Referer: [#HTTP.REFERER#]<BR>";
			if (IsDefined("Error.Type")) { message = message & "Catch Type: #ERROR.Type#<BR>"; }
			if (IsDefined("SESSION.USERID") AND SESSION.USERID NEQ "" ) { message = message & "UserID : #SESSION.USERID#<BR>"; } else { message = message & "**USERID IS NULL **<BR>"; }
			if (IsDefined("SESSION.FULLNAME")) { message = message & "User: <B>#SESSION.FULLNAME#</B><BR>"; }
			if (IsDefined("SESSION.qSelectedHouse.iHouse_ID") AND SESSION.qSelectedHouse.iHouse_ID NEQ "") { message = message & "iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#<BR>"; }
			if (IsStruct("url") AND YesNoFormat(StructIsEmpty(url)) EQ 'NO') {
				message = message & "URL VARIABLES: <BR>";
				for( l=1; l LTE len(url); l=l+1){
					message = message & #l# & '==' &  #Evaluate(url[l])# & '<BR>';
				}
			}
			if (IsDefined("form.fieldnames")) {
				for( i=1; i LTE Listlen(form.fieldnames); i=i+1){
					message = message & "#ListGetAt(form.fieldnames,i,',')# == #Evaluate(ListGetAt(form.fieldnames,i,','))# <BR>";
				}
			}
			if (isDefined("iTenant_id") AND iTenant_ID NEQ "") { message = message & "TenantID = " & iTenant_ID; }
			message = message & 'Template path=' & gettemplatepath();
			message = message & 'Time=' & now() & '<BR>***END***<BR><BR>';
		</CFSCRIPT>

		<CFMAIL TYPE="html" FROM="MidMonth-Message" TO="#session.developerEmailList#" SUBJECT="Error in MidMonth">
			#SESSION.HouseName# : #SESSION.qSelectedHouse.iHouse_ID#<BR>generated by User: #SESSION.FULLNAME#<BR>
			#message#<BR>
			____________________________________________________
		</CFMAIL>

		<SCRIPT>alert("An error has occurred for the MidMonth Check. \r An email has been sent to the adminstrator."); </SCRIPT>
	</CFCATCH>
</CFTRY>

<!--- Retrieve House Month Information--->
<CFQUERY NAME = "HouseLog" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	bIsPDClosed, bIsCentralized FROM HouseLog
    WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND dtRowDeleted IS NULL
</CFQUERY>

<CFINCLUDE TEMPLATE="../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">

<CFOUTPUT>
<TABLE>
	<TR><TH COLSPAN="3"> Administration	</TH></TR>
	<TR>
		<TD> Administrators - </TD>
		<TD> Are you closing the month of #DateFormat(SESSION.TIPSMonth, "mmmm, yyyy")#? </TD>
		<TD STYLE="width: 25%;">
			<CFIF HouseLog.bIsPDclosed NEQ ""> 		
				<CFSET Checked = 'Checked'>
				<CFIF ListFindNoCase(session.CodeBlock,23) EQ 0>
					Status: Closed
				<CFELSE>
					<INPUT TYPE="checkbox" NAME="pdclose" #Variables.Checked# onClick="wait(false,'PDClose.cfm');">
				</CFIF>		
			<CFELSE>
				<CFSET Checked = ''>
				<INPUT TYPE="checkbox" NAME="pdclose" #Variables.Checked# onClick="wait(true,'PDClose.cfm');">
				Yes.
			</CFIF>	
		</TD>
	</TR>

	<CFIF listfindNocase(session.codeblock,23) GTE 1 AND HouseLog.bIsPDClosed GT 0>
		<TR>
			<TD> Accounting Close -	</TD> 
			<TD> I have reviewed and approve the closing of #DateFormat(SESSION.TIPSMonth, "mmmm, yyyy")#	</TD>
			<TD> 
				<INPUT TYPE="checkbox" NAME="OpsReview" onClick="wait(true,'RDOClose.cfm')"> </TD>
		</TR>
	<CFELSEIF listfindNocase(session.codeblock,23) EQ 0>
		<TR><TD COLSPAN="100%">Accounting Approval (available upon House Admin. Close)</TD></TR>
	</CFIF>
</TABLE>

<CFIF IsDefined("ICNT") AND ICNT GT 0>
	<FORM ACTION='ApproveChanges.cfm' METHOD='POST'>
	<TABLE STYLE="text-align: right;">
		<TR>
			<TH NOWRAP STYLE="text-align:left;"> Trx </TH>
			<TH NOWRAP STYLE="text-align:left;">Full Name</TH>
			<TH NOWRAP STYLE="text-align:left;">Sol. Key</TH>
			<TH NOWRAP STYLE="text-align:left;">Description</TH>
			<TH NOWRAP STYLE="text-align:left;">Old Amt</TH>
			<TH NOWRAP STYLE="text-align:left;">New Amt</TH>
			<TH NOWRAP STYLE="text-align:left;">Period</TH>
			<TH NOWRAP STYLE="text-align:left;">Action</TH>
		</TR>
        
		<CFLOOP QUERY="MidMonth">
			<CFQUERY NAME="MidMonthInfo" DATASOURCE="#APPLICATION.datasource#">
				SELECT cLastName, cFirstName, cSolomonkey FROM Tenant T WHERE T.dtRowDeleted IS NULL AND T.iTenant_ID = #MidMonth.iTenant_ID#
			</CFQUERY>
			<CFSCRIPT>
				backcolor='';
				if (MidMonth.RecordCount GT 2) {
					if (Evaluate(MidMonth.currentRow MOD 2) EQ 1) { backcolor="STYLE='background: white;'"; }
				}
			</CFSCRIPT>
			<INPUT TYPE='hidden' NAME='invoicemasterid_#midmonth.currentrow#' VALUE='#midmonth.iInvoiceMaster_ID#'>
			<INPUT TYPE='hidden' NAME='itenantid_#midmonth.currentrow#' VALUE='#midmonth.itenant_id#'>
			<INPUT TYPE='hidden' NAME='ichargetypeid_#midmonth.currentrow#' VALUE='#midmonth.ichargetype_id#'>
			<INPUT TYPE='hidden' NAME='description_#midmonth.currentrow#' VALUE='#midmonth.cdescription#'>
			<INPUT TYPE='hidden' NAME='action_#midmonth.currentrow#' VALUE='#midmonth.caction#'>
			<INPUT TYPE='hidden' NAME='inewquantity_#midmonth.currentrow#' VALUE='#midmonth.inewquantity#'>
			<INPUT TYPE='hidden' NAME='ioldquantity_#midmonth.currentrow#' VALUE='#midmonth.ioldquantity#'>
			<INPUT TYPE='hidden' NAME='mnewamount_#midmonth.currentrow#' VALUE='#midmonth.mnewamount#'>
			<INPUT TYPE='hidden' NAME='moldamount_#midmonth.currentrow#' VALUE='#midmonth.moldamount#'>
			<INPUT TYPE='hidden' NAME='comments_#midmonth.currentrow#' VALUE='#midmonth.ccomments#'>
			<INPUT TYPE='hidden' NAME='newdetailid_#midmonth.currentrow#' VALUE='#midmonth.newdetailid#'>
			<INPUT TYPE='hidden' NAME='olddetailid_#midmonth.currentrow#' VALUE='#midmonth.olddetailid#'>
			<INPUT TYPE='hidden' NAME='ihouseid_#midmonth.currentrow#' VALUE='#midmonth.ihouse_id#'>
			<INPUT TYPE='hidden' NAME='cappliestoacctperiod_#midmonth.currentrow#' VALUE='#midmonth.cappliestoacctperiod#'>
			<TR>
				<TD #backcolor# STYLE="text-align: left"><INPUT TYPE='checkbox' NAME='row_#midmonth.currentrow#' VALUE='#midmonth.currentrow#' checked onClick='approvebutton();'></TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonthInfo.cLastName#, #MidMonthInfo.cFirstName#</TD>
				<TD #backcolor# STYLE="text-align: left">#MidMonthInfo.cSolomonKey#</TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cDescription#</TD>
				<TD #backcolor# >#LSCurrencyFormat(MidMonth.OldAmount)#</TD>
				<TD #backcolor# >#LSCurrencyFormat(MidMonth.NewAmount)#</TD>
				<TD #backcolor# STYLE="text-align: left">#MidMonth.cAppliesToAcctPeriod#</TD>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cAction#</TD>
			</TR>
		</CFLOOP>

		<TR><TD COLSPAN=100 STYLE='text-align:center;'><INPUT TYPE='submit' NAME='SubmitChoices' VALUE='Approve Selected Changes'></TD></TR>
	</TABLE>
	</FORM>
<CFELSEIF IsDefined("ICNT") AND ICNT is not "" AND ICNT LT 0>
	<CFSET InvalidPointsCount = iCnt * -1>
	<CFSET backcolor=''>
	<TABLE STYLE="text-align: center;">
		<TR><TH COLSPAN=4>WARNING:<br>#InvalidPointsCount# residents have invalid points for their service level.<br>System charges can not be checked until these points are corrected.</TH></TR>
		<TR>
			<TH NOWRAP STYLE="text-align: left">Full Name</TH>
			<TH NOWRAP>Sol. Key</TH>
			<TH NOWRAP>Service Set</TH>
			<TH NOWRAP>Points</TH>
		</TR>
		<CFLOOP QUERY="MidMonth">
			<TR>
				<TD #backcolor# NOWRAP STYLE="text-align: left">#MidMonth.cLastName#, #MidMonth.cFirstName#</TD>
				<TD #backcolor# >#MidMonth.cSolomonKey#</TD>
				<TD #backcolor# NOWRAP>#MidMonth.CSLevelTypeSet#</TD>
				<TD #backcolor# >#MidMonth.iSPoints#</TD>
			</TR>
		</CFLOOP>
	</TABLE>
<CFELSE>
	<TABLE STYLE="text-align: center;">
		<TR><TH>System charges are up to date.</TH></TR>
	</TABLE>
</CFIF>

<BR>
<CFIF listfindNocase(session.codeblock,25) GTE 1>
	<TABLE> 
		<TR>
        	<TH COLSPAN="2" STYLE="text-align: left;">	FOR ADMINISTRATIVE USE ONLY: </TH>
        </TR>
		
		<TR>
			<TD><A HREF="../DataTableMaintenance/House/House.cfm">  House Administration </A></TD>
            <TD>
                <a href="reImportInv.cfm" target="_mimo">Re-import Move-in or Move-out</a><br>
                <a href="missedMonthlyImports.cfm" target="_month">Re-import Monthly Invoices</a>
            </TD>
		</TR>
		<TR>
			<TD><A href="../DataTableMaintenance/ActivityLog/ActivityCodes/ActivityCodes.cfm"> Activity Codes </A></TD>
			<TD><A HREF="../DataTableMaintenance/Region/Region.cfm">  Region Administration </A></TD>
		</TR>
		<TR>
			<TD><A href="../DataTableMaintenance/TenantStateCodes/TenantStateCodes.cfm"> Resident State Codes </A></TD>
			<TD><A href="../DataTableMaintenance/OPSAreas/OPSAreas.cfm"> OPS Areas Administration </A></TD>
		</TR>
		<TR>
			<TD>
            	<A href="../DataTableMaintenance/ChargeType/ChargeType.cfm"> Charge Types </A>
            </Td>
			<TD><A href="../DataTableMaintenance/InvoiceNotes/InvoiceNotes.cfm">  Invoice Notes Administration </A></TD>
		</TR>
		<TR>
			<TD><A href="../DataTableMaintenance/Charges/Charges.cfm?Insert=1&ID=general">  General Charges </A> </TD>
			<TD><A href="../DataTableMaintenance/Charges/Charges.cfm?Insert=1&ID=House">  House Specific Charges </A></TD>
		</TR>
		<TR>
			<TD><A HREF="../DataTableMaintenance/MoveOutReasons/MoveOutReasons.cfm">  Move Out Reasons Administration </A></TD>
			<TD><A HREF="../DataTableMaintenance/House/HouseApts.cfm">House AptType Assignment</A></TD>
		</TR>
		<TR>
			<TD><A HREF="ResidentCareAdministration.cfm">Resident Care Administration</A></TD>
			<TD><a href="ControlFiles\ctl_ManageGlCodes.cfm">Manage Room Type GL Code Mappings</a></TD>
		</TR>
        <TR>
            <TD><A HREF="RoomAndBoardAdministration.cfm">Room & Board Administration</A></TD>
            <TD><A HREF="TenantPromotions.cfm">Promotions </A></TD>
        </TR>
		<tr>
			<TD><A HREF="CurrentLateFee.cfm">List of Current Late Fee</A></TD>
			<td>&nbsp;</td>
		</tr>
		<TR>
			<TD>
				<CFIF ListContains(SESSION.codeblock, '19') or ListContains(SESSION.groupid, '240')> 
                    <A HREF="InvoiceAdmin.cfm">Invoice Administration</A>
                </CFIF>
			</TD>
            <TD>
				<CFIF ListContains(SESSION.groupid, '284')>
                    <A HREF="BondInfo.cfm">Bond Administration</A>
                 </CFIF>
             </TD>
		</TR>
		<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)> 
            <tr>
                <TD><A HREF="LateFeeExemptTenants.cfm">Late Fee Information</A></TD>
				<td>&nbsp;</td>
            </tr>
		</cfif> 
	 	<TR>
			<TD>&nbsp;</TD>
			<TD><a href="../MoveOut/MoveOutReasonMod.cfm">Move Out Reason Modifications</a></TD>
		</TR>
        
		<cfif listcontains(session.groupid,'285')>
		<TR>
			<TD><a href="TenantDateAdjustments.cfm">Closed Account Date Admin</a></TD>
			<TD><a href="../DataTableMaintenance/EFT/dsp_EFTFeeMaintenance.cfm">EFT Fee Maintenance</a></TD>
		</TR>
		<tr>
			<TD>&nbsp;</TD>		
			<td><A HREF="../Tenant/TenantEFTHouse.cfm">EFT's for the House</A></td>
		</tr>		
		</cfif>
		<TR>
			<TD>
				<form name="updatehouselog">
					<tr>
					<td>
						<input name="checkboxCentralized" type="checkbox" onClick="updateHouseLog(this)" <cfif HouseLog.bIsCentralized eq 1> checked </cfif>/> Centralize Invoice Report 
					</td>
					</tr>
					<tr>
					<td>
						<font color="red" size="2">
						<div name="messageBox" id="messageBox">&nbsp;</div>
						</font>
					</td>
					</tr>
				</form>			
			</TD>
		</TR>
	</TABLE>
<CFELSEIF listfindNocase(session.codeblock,23) GTE 1><!--- 23 is AR --->
	<TABLE> 
		<TH COLSPAN="2" STYLE="text-align: left;"> FOR ADMINISTRATIVE USE ONLY: </TH>
		<TR>
        	<TD><A  HREF="../DataTableMaintenance/House/House.cfm">  House Administration</A></TD>
        </TR>
		<TR>
        	<TD></TD>
        </TR>
		<!--- Proj 71776 - 06/01/11 sdf - added Move Out Rason Modificationa --->		
	 	<TR>
			<TD>&nbsp;</TD>
	
			<TD>
				<a href="../MoveOut/MoveOutReasonMod.cfm">Move Out Reason Modifications</a>
			</TD>
		</TR>

	</TABLE>
<CFELSE> 
	<TABLE>
		<TR><TH COLSPAN="2" STYLE="text-align: left;"> FOR ADMINISTRATIVE USE: </TH></TR>

		<TABLE STYLE="text-align: center; border: 1px solid gray;">
		<TR><TD colspan="2"></TD>
		<CFIF ListContains(SESSION.groupid, '284')>
			<TD colspan="2"><A HREF="BondInfo.cfm">Bond Administration</A></TD>
		 </CFIF> 
		</TR>
		</TABLE>
		<!--- Proj 71776 - 06/01/11 sdf - added Move Out Rason Modificationa --->
	<cfif 	((IsDefined("SESSION.codeblock"))  and 
	 ((ListContains(SESSION.codeblock, '49')) or
	 (ListContains(SESSION.codeblock, '23')) or
	 (ListContains(SESSION.codeblock, '24')) or
	 (ListContains(SESSION.codeblock, '25')))
	  and (listfindNocase(SESSION.houseaccesslist, SESSION.qSelectedHouse.iHouse_ID)))>	
	 	<TR>
			<TD>&nbsp;</TD>
			<TD>
                <a href="../MoveOut/MoveOutReasonMod.cfm">Move Out Reason Modifications</a>
			</TD>
		</TR>
	 	<TR>
			<TD>&nbsp;</TD>
			<TD>&nbsp;</TD>
		</TR>
	</cfif>

	</TABLE>
</CFIF>

</br>
<TABLE>
		<tr><th colspan="3" style="center"> ADMINISTRATION OVER ALL HOUSES </th></tr>
		<tr>
			<td>
				<cfif listcontains(session.groupid,'285')>
				<a href="DisplayFiles/dsp_HouseAutoApplyMIChargeSelection.cfm">House Auto-Apply MI Charge Admin </a>
				</cfif>
			</td>
			<td>
				<cfif ListContains(SESSION.groupid, '285')>
					<A HREF="../DataTableMaintenance/MoveOutLocations/MoveOutLocations.cfm">Move Out Location Admin</A>
				</cfif>
			</td>
		</tr>
        <tr>
			<td>
			<CFIF ListFindNoCase(SESSION.groupid, '1')or ListContains(SESSION.groupid, '285')> 
				<A HREF="../DataTableMaintenance/PointDifferences/TenantPointDifferences.cfm">Tenant Point Difference Admin</A>
			</cfif>
			</td>
		</tr>
</TABLE>
 
	<BR>
	<A Href="../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
</CFOUTPUT>

<SCRIPT>
function approvebutton() {
	counter=0;
	for (t=0;t<=document.forms[0].elements.length-1;t++){
		if (document.forms[0].elements[t].checked == true) { counter=counter+1; }
	}
	if (counter == 0) { document.forms[0].SubmitChoices.disabled = true; }
	else { document.forms[0].SubmitChoices.disabled = false; }
}
</SCRIPT>

<CFINCLUDE TEMPLATE='../../Footer.cfm'>
</cfoutput>