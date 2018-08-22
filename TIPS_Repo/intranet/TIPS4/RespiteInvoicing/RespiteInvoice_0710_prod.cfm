<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInvoice.cfm                                            |
|----------------------------------------------------------------------------------------------|
| Display Invoices for a Respite Resident                                                      |
| Called by: 		MainMenu.cfm						  	                                   |
| Calls/Submits:	                                              							   |
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
|R Schuette  | 05/11/2010 | Prj 25575 - Original Authorship              					   |
----------------------------------------------------------------------------------------------->

<script language="JavaScript" src="../../global/calendar/ts_picker2.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript">
	
	function MSG(){
		alert("Please click the calendar icon to fill value.")
		CreateNewInvoice.Submit.focus();
		return false;
	}
	
  	function vDate(){
		var eDate = CreateNewInvoice.NewRRIdate.value;
		var sDate = CreateNewInvoice.Nextdate.value;
		if(eDate == ''){
			alert("Please click the calendar icon to select a date.")
			return false;}
				
		if(isDateLesser(sDate,eDate) == false){
			alert("Please click the calendar icon to select a date \nthat is after the next invoice start date.")
			return false;}
			
		return true;
  	}
	
	function DelMSG(){
		var answer = confirm("Delete this invoice?")
		if(answer)
			return true;
		else
			return false;
	}
	function isDateLesser(dt1,dt2){
		var dtCh= "/";

		var pos1=dt1.indexOf(dtCh)
		var pos2=dt1.indexOf(dtCh,pos1+1)
		var strMonth1=dt1.substring(0,pos1)
		var strDay1=dt1.substring(pos1+1,pos2)
		var strYear1=dt1.substring(pos2+1)
		
		var pos12=dt2.indexOf(dtCh)
		var pos22=dt2.indexOf(dtCh,pos12+1)
		var strMonth2=dt2.substring(0,pos12)
		var strDay2=dt2.substring(pos12+1,pos22)
		var strYear2=dt2.substring(pos22+1)
		
		strYr1=strYear1
		strYr2=strYear2

		if(strDay1.length<2){strDay1 = 0 + strDay1}
		if(strMonth1.length<2){strMonth1 = 0 + strMonth1}
		var StartDate=strYear1+strMonth1+strDay1
		StartDate = parseFloat(StartDate)
		
		if(strDay2.length<2){strDay2 = 0 + strDay2}
		if(strMonth2.length<2){strMonth2 = 0 + strMonth2}
		var EndDate=strYear2+strMonth2+strDay2
		EndDate = parseFloat(EndDate)
		
		if (StartDate>EndDate){
			return false;
		}
	return true;
}
	function isEDateGreater(dt1,dt2){
	var dtCh= "/";

		var pos1=dt1.indexOf(dtCh)
		var pos2=dt1.indexOf(dtCh,pos1+1)
		var strMonth1=dt1.substring(0,pos1)
		var strDay1=dt1.substring(pos1+1,pos2)
		var strYear1=dt1.substring(pos2+1)
		
		var pos12=dt2.indexOf(dtCh)
		var pos22=dt2.indexOf(dtCh,pos12+1)
		var strMonth2=dt2.substring(0,pos12)
		var strDay2=dt2.substring(pos12+1,pos22)
		var strYear2=dt2.substring(pos22+1)
		
		strYr1=strYear1
		strYr2=strYear2

		if(strDay1.length<2){strDay1 = 0 + strDay1}
		if(strMonth1.length<2){strMonth1 = 0 + strMonth1}
		var StartDate=strYear1+strMonth1+strDay1
		var INVEndDate = parseFloat(StartDate)
		
		if(strDay2.length<2){strDay2 = 0 + strDay2}
		if(strMonth2.length<2){strMonth2 = 0 + strMonth2}
		var EndDate=strYear2+strMonth2+strDay2
		var TestDate = parseFloat(EndDate)
		
		if (INVEndDate>TestDate){
			return false;
		}
	return true;
}
	
</script>

<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- HTML head --->
<TITLE> Tips 4  - Respite Resident Invoicing Page </TITLE>
<BODY>
<cfset variables.MovetoProd = '2011-08-31'>

<!--- Display the page header --->
<H1 CLASS="PageTitle"> Tips 4 - Respite Resident Invoicing Page </H1>

 <cfquery name="GetInvoices" datasource="#application.datasource#">
	select iInvoiceNumber, iinvoicemaster_Id ,cAppliesToAcctPeriod, dtmovein, hl.dtCurrentTipsMonth, convert(varchar(10),rim.dtRowStart,101) as dtRowStart,
	bFinalized,mInvoiceTotal,iInvoiceMaster_ID,rim.cSolomonKey,dtInvoiceEnd,
	convert(varchar(10),rim.dtInvoiceStart,101) as StartDate,
	isnull(convert(varchar(10),rim.dtInvoiceEnd,101),convert(varchar(10),rim.dtInvoiceStart,101)) as EndDate, ts.dtMoveOutProjectedDate
	from InvoiceMaster rim
	join tenant t on (t.cSolomonKey = rim.cSolomonKey)
	join tenantstate ts on (ts.itenant_id = t.itenant_id)
	join houseLog hl on (hl.ihouse_id = t.ihouse_id)
	where rim.cSolomonKey = '#URL.SolID#'
	and rim.dtrowdeleted is null
	order by iInvoiceNumber
</cfquery> 

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<CFINCLUDE TEMPLATE="RespiteInfoSummary.cfm">


<cfset UnFinalizedCount = 0>
<cfset NextStartDate = #DateFormat(now(),'MM/DD/YYYY')#>
<cfset variables.allowNewInvoice = find(nextstartdate,valuelist(getInvoices.dtrowstart,","))>


</br>
<TABLE>
	<TR>
		<TD COLSPAN="2" STYLE="background: white;">
			<B STYLE="font-size: 20;">Respite Resident Invoicing</B>
		</TD>
	</TR>
</TABLE>
	
<TABLE>
	<TR>
		<th NOWRAP>Invoice Number</th>
		<th NOWRAP>Applies To Period</th>
		<th NOWRAP>Start Date</th>
		<th NOWRAP>End Date</th>
		<th NOWRAP>Number of Days</th>
		<th NOWRAP>Amount</th>
		<th NOWRAP>Finalized</th>
		<th NOWRAP>Action</th>
		<th NOWRAP>View</th>
	</TR>	
		
		<CFOUTPUT QUERY = "GetInvoices"> 
			<TR>	
				<td style="text-align:center"  NOWRAP>
					<a href="RespiteInvoiceDetails.cfm?INVNID=#GetInvoices.iInvoiceNumber#">#GetInvoices.iInvoiceNumber#</a>
				</td>
				<td style="text-align:center"  NOWRAP>
					#GetInvoices.cAppliesToAcctPeriod#
				</td>
				<td style="text-align:center"  NOWRAP>
					#GetInvoices.StartDate#
				</td>
				
				<td style="text-align:center"  NOWRAP>
					#GetInvoices.EndDate#
				</td>
				<td style="text-align:center"  NOWRAP>
					#GetInvoices.EndDate - GetInvoices.StartDate+1#
				</td>
				<cfif GetInvoices.bFinalized eq 1>
					<td style="text-align:center"  NOWRAP>
						#dollarFormat(GetInvoices.mInvoiceTotal)#
					</td>
					<td style="text-align:center"  NOWRAP>
						Finalized
					</td> 				
					<td></td>				
				<cfelse>
					<td style="text-align:center"  NOWRAP>
						See Details
					</td>
					<cfset UnFinalizedCount = UnFinalizedCount + 1> 
					<cfif ListContains(SESSION.groupid, '240')  or session.username is "gthota">
						<td style="text-align:center"  NOWRAP>
							<form name="FinalizeInvoice#GetInvoices.currentrow#" 
							action="RespiteInvoiceFinalize.cfm?INVMSTRID=#GetInvoices.iInvoiceMaster_ID#" method="post" >
								<input type="submit" name="Submit" value="Finalize">
							</form>
						</td>
					<cfelse>
						<td style="text-align:center"  NOWRAP>
							Awaiting
						</td>
					</cfif>
					<cfif ListContains(SESSION.groupid, '240')  or session.username is "gthota">
						<td style="text-align:center"  NOWRAP>
							<form name="DeleteInvoice#GetInvoices.currentrow#" 
							action="RespiteInvoiceDeleteMSTR.cfm?INVMSTRID=#GetInvoices.iInvoiceMaster_ID#" method="post" >
								<input type="submit" name="Submit" value="Delete" onClick="return DelMSG();">
							</form>
						</td>
					<cfelse>
					<td style="text-align:center"  NOWRAP>
						
					</td>
					</cfif>				
					
				</cfif>
	
				<td>
					<cfif GetInvoices.StartDate lt variables.MovetoProd>
						<a href=
						"../Reports/LegacyRespiteInvoiceReport.cfm?SolID=#trim(GetInvoices.cSolomonKey)#&INVNBR=#GetInvoices.iInvoiceNumber#">
							Invoice
						</a>
					<cfelse>
						<a href=
						"../Reports/RespiteInvoiceReport.cfm?SolID=#trim(GetInvoices.cSolomonKey)#&INVNBR=#GetInvoices.iInvoiceNumber#">
							Invoice
						</a>					
					</cfif>
				</td>
			</TR>
			<cfif GetInvoices.currentrow eq GetInvoices.recordcount>
				<cfset NextStartDate = dateformat(GetInvoices.EndDate+1,"mm/dd/yyyy")>
				
				<!--- 25575 Below if statement can be deleted after all current respites are done being moved over to new system  ---->
				<cfif GetInvoices.dtMovein lt variables.MovetoProd and GetInvoices.EndDate lt GetInvoices.DtCurrentTipsMonth> 
					<cfset NextStartDate = dateformat(GetInvoices.dtMoveOutProjectedDate+1,"mm/dd/yyyy")>
				</cfif>
				<!--- 25575 Above if statement can be deleted after all current respites are done being moved over to new system  ---->
			</cfif>	
		</CFOUTPUT>
		<cfoutput>
			<form name="CreateNewInvoice" action="RespiteInvoiceNew.cfm?SolID=#RRInfo.cSolomonkey#" method="post">
					<TR>
						<td></td>
						<td style="text-align:center"  NOWRAP>
						#DateFormat(session.TIPSMonth, 'YYYYMM')#
							<input type="hidden" name="Period" value="#DateFormat(session.TIPSMonth, 'YYYYMM')#">
						</td>
						<td style="text-align:center"  NOWRAP>
							<input type="hidden" name="Nextdate" value="#DateFormat(NextStartDate,'MM/DD/YYYY')#">
							#NextStartDate#
						</td>
		</cfoutput>
						<td style="text-align:center"  NOWRAP>
							<input type="text" id="NewRRIdate" name="NewRRIdate" size="10" value="" onKeyPress="return MSG();" onClick="return MSG();" >
							&nbsp;
							<a onClick=
							"show_calendar2('document.CreateNewInvoice.NewRRIdate',document.getElementsByName('NewRRIdate').value);"> 
								<img src="../../global/Calendar/calendar.gif" alt="Calendar" width="16" 
								height="15" border="0" align="middle" style="" id="Cal" name="Cal">
							</a>
						</td>
						<td></td>
						<td></td>
						<td></td>
						
						<cfif (ListContains(SESSION.groupid, '240') AND UnFinalizedCount eq 0) or session.username is "gthota">
							<td style="text-align:center" colspan="2">
								<cfif variables.allowNewInvoice gt 0>
									<input type="button" name="Submit" disabled="disabled" value="Invoice already created today">
								<cfelse>
									<input type="submit" name="Submit" value="Create New" onMouseOver="return vDate();" onClick="return vDate();">
								</cfif>
							</td>
						<cfelse>
							<td></td>
						</cfif>
					</TR>
				</form>
		</TABLE>
</BODY>
