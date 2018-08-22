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
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 10/28/2005 | Added Flowerbox                                                    |
| fzahir     | 11/08/2005 | Added Daily Census Report, Monthly Census Report and Validate      | 
|            |            | Daily Census Form                                                  |
| ranklam    | 03/08/2006 | Added Resident Statment Report                                     |
| ranklam    | 03/08/2006 | Changed date formats for the census reports                        |
| mlaw       | 05/02/2006 | Moved the Daily Census Stuff to Census Button/Dir.                 |
| ranklam    | 12/04/2007 | Added excel rate export link                                       |
|Sathya      | 08/12/2010 | Project 50227 added Tips Resident Promotion Only AR Analyst has access |
|sfarmer     | 03/11/2013 | Project 103125 Removed Validation Report link                      |
| Sfarmer    | 05/30/2013 | ResidentTaxLetter removed.   # 103928                              |
| Sfarmer    | 07/17/2013 | Resident Care Summary Report removed #108474                       |
| SFarmer    | 09/08/2014 | Project 120077  - Added Aging Report                               |
|Sfarmer     | 01/14/2016 | Updated reports for Birthday Summary, Print Invoices,              |
|            |            | Resident Charge Summary and Move In/Move Out Activity Summary by   |
|            |            | House to Coldfusion CFDocument (PDF) reports from Cyrstal Reports  |
|TPecku	     | 10/10/2016 | Made the Birthday Summary report available to everyone.            |
| Sfarmer    | 02/16/2017 | Added AccountingPeriodReport                                       |
|---------------------------------------------------------------------------------------------->
<!---<cfdump var="#session#"> --->	

<cfif NOT isDefined("session.UserID")><cflocation url="../../Loginindex.cfm" addtoken="yes"></cfif>
<cfinclude template="../../header.cfm">
<script language="javascript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>
<script>
function res_care(obj,targ) { if (obj.value == targ) { obj.name='Scope'; } else { obj.name='TenantID'; } }

/* Project 36359 Date validation */
function DateCheck(){
if (MoveInCheckInformantion.MICheckInfoStart.value == '')
	{alert("Please enter a start date for the Move In Check report. \n mm/dd/yyyy.");
	return false;
	}
if (MoveInCheckInformantion.MICheckInfoEnd.value == '')
	{alert("Please enter a end date for the Move In Check report. \n mm/dd/yyyy.");
	return false;
	}

if(ValidDate(MoveInCheckInformantion.MICheckInfoStart.value) == false)
	{
		MoveInCheckInformantion.MICheckInfoStart.focus();
		alert("Please enter a start date that is valid, and not in the future.");
		return false;
		}
if(ValidDate(MoveInCheckInformantion.MICheckInfoEnd.value) == false)
	{
		MoveInCheckInformantion.MICheckInfoEnd.focus();
		alert("Please enter a end date that is valid, and not in the future.");
		return false;
		}
if(DateOrder() == false)
{
	MoveInCheckInformantion.MICheckInfoStart.focus();
		alert("Please enter a start and end date that are \nin chronological order.");
		return false;
}
function DateOrder()
{
		var dtStr1 = MoveInCheckInformantion.MICheckInfoStart.value;
		var dtCh = "/";
		var pos1=dtStr1.indexOf(dtCh)
		var pos2=dtStr1.indexOf(dtCh,pos1+1)
		var strMonth1=dtStr1.substring(0,pos1)
		var strDay1=dtStr1.substring(pos1+1,pos2)
		var strYear1=dtStr1.substring(pos2+1)
		if(strDay1.length<2){strDay1 = 0 + strDay1}
		if(strMonth1.length<2){strMonth1 = 0 + strMonth1}
		
		var RearrangedInput1=strYear1+strMonth1+strDay1
		RearrangedInput1 = parseFloat(RearrangedInput1)
		
		var dtStr2 = MoveInCheckInformantion.MICheckInfoEnd.value;
		pos1=dtStr2.indexOf(dtCh)
		pos2=dtStr2.indexOf(dtCh,pos1+1)
		var strMonth2=dtStr2.substring(0,pos1)
		var strDay2=dtStr2.substring(pos1+1,pos2)
		var strYear2=dtStr2.substring(pos2+1)
		if(strDay2.length<2){strDay2 = 0 + strDay2}
		if(strMonth2.length<2){strMonth2 = 0 + strMonth2}
		
		var RearrangedInput2=strYear2+strMonth2+strDay2
		RearrangedInput2 = parseFloat(RearrangedInput2)
		
		if(RearrangedInput1>RearrangedInput2)
		{
			return false;
		}
}
function ValidDate(dtstart)
	{
			if(isDate(dtstart)==false){
				return false;}
	return true;
	}

function isDate(dtStr){
		var dtCh= "/";
		var minYear=2003;
		var year=new Date();
		var now=new Date();
		var maxYear=year.getYear();
		var daysInMonth = DaysArray(12)
		var pos1=dtStr.indexOf(dtCh)
		var pos2=dtStr.indexOf(dtCh,pos1+1)
		var strMonth=dtStr.substring(0,pos1)
		var strDay=dtStr.substring(pos1+1,pos2)
		var strYear=dtStr.substring(pos2+1)
		strYr=strYear
		
		if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
		if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
		for (var i = 1; i <= 3; i++) {
			if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
		}
		month=parseInt(strMonth)
		day=parseInt(strDay) 
		year=parseInt(strYr)
		if (pos1==-1 || pos2==-1){
			//alert("The date format should be : mm/dd/yyyy")
			return false;
		}
		if (strMonth.length<1 || month<1 || month>12){
			//alert("Please enter a valid month")
			return false;
		}
		
		if (strDay.length<1 || day<1 || day>31 ||(month==02 && day>daysInFebruary(year)) || day > daysInMonth[month]){// || 
			//alert("Please enter a valid day.")
			return false;
		}
		if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
			//alert("Please enter a valid 4 digit year. \n \n(ie "+maxYear+")")
			return false;
		}
		if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
			//alert("Please enter a valid date")
			return false;
		}
		if(strDay.length<2){strDay = 0 + strDay}
		if(strMonth.length<2){strMonth = 0 + strMonth}
		var RearrangedInput=strYear+strMonth+strDay
		RearrangedInput = parseFloat(RearrangedInput)
		var TodayDay = parseInt(now.getDate());
		TodayDay = TodayDay +'';
		if (TodayDay.length<2){TodayDay = 0 + TodayDay;}
		
		var TodayMonth = parseInt(now.getMonth());
		TodayMonth = (TodayMonth + 1)+'';
		if (TodayMonth.length<2){TodayMonth = 0 + TodayMonth;}
		
		var TodayYear = now.getFullYear();
		var TodayRearranged = (TodayYear + ''+ TodayMonth +''+ TodayDay)
		TodayRearranged = parseFloat(TodayRearranged);
		if (RearrangedInput>TodayRearranged){
			//alert("Please no future dates.")
			return false;
		}
	return true;
}
	function isInteger(s){
	var i;
    for (i = 0; i < s.length; i++){   
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

function stripCharsInBag(s, bag){
	var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){   
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}

function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}

function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
		if (i==2) {this[i] = 29}
   		} 
   return this
	}

}
/* end 36359 code */

</script>
<cfif isDefined("DeletediHouse_ID")>
	<cfquery name="qDeletedHouse" datasource="#application.datasource#">
		select * from House H
		join HouseLog HL on (HL.iHouse_ID = H.iHouse_ID and HL.dtRowDeleted is null)
		where H.iHouse_ID = #url.DeletediHouse_ID#	
	</cfquery>
	<cfset session.qSelectedHouse = qDeletedHouse>
	<cfset session.HouseName = qDeletedHouse.cName>
	<cfset session.nHouse = qDeletedHouse.cNumber>
	<cfset session.TipsMonth = qDeletedHouse.dtCurrentTipsMonth>
</cfif>

<cfquery name="Period" datasource="#application.datasource#">
	select distinct cAppliesToAcctPeriod
	from InvoiceMaster im (nolock)
	where cAppliesToAcctPeriod is not null
	and im.dtRowDeleted is null and (left(im.cSolomonKey, 3) + 1800) = #session.nHouse#
	and cast(right(cAppliesToAcctPeriod, 2) + '/1/' + left(cAppliesToAcctPeriod, 4) as datetime) <=
		cast(cast(datepart(month, getdate()) as varchar(2)) + '/1/' + cast(datepart(year, getdate()) as varchar(4)) as datetime)
	order by cAppliesToAcctPeriod desc
</cfquery>
<!---<cfdump var="#period#" label="period">--->
<cfquery name="JustYear" datasource="#application.datasource#">
	select distinct left(cAppliesToAcctPeriod,4) as TheYear
	from InvoiceMaster im (nolock)
	where cAppliesToAcctPeriod is not null
	and im.dtRowDeleted is null and (left(im.cSolomonKey, 3) + 1800) = #session.nHouse#
	and cast(right(cAppliesToAcctPeriod, 2) + '/1/' + left(cAppliesToAcctPeriod, 4) as datetime) <=
		cast(cast(datepart(month, getdate()) as varchar(2)) + '/1/' + cast(datepart(year, getdate()) as varchar(4)) as datetime)
	order by TheYear desc
</cfquery>

<cfquery name="Tenants" datasource="#application.datasource#">
	select *, (T.cLastName + ', ' + T.cFirstName) as FullName 
	from Tenant T
	join TenantState TS  on T.iTenant_ID = TS.iTenant_ID
	where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID between 2 and 4
	order by cLastName
</cfquery>

<cfquery name="MovedOutTenants" datasource="#application.datasource#">
	select T.cSolomonkey, (T.cLastName + ', ' + T.cFirstName) as FullName 
	from Tenant T
	join TenantState TS  on T.iTenant_ID = TS.iTenant_ID
	where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID = 4
	order by cLastName
</cfquery>

<cfquery name="TenantsNoRespite" datasource="#application.datasource#">
	select *, (T.cLastName + ', ' + T.cFirstName) as FullName 
	from Tenant T 
	join TenantState TS on T.iTenant_ID = TS.iTenant_ID
	where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID between 2 and 4
	and ts.iresidencyType_id <> 3
	order by cLastName
</cfquery>

<cfif tenants.recordcount eq 0>
	<cfoutput>
	<b>There are no residents currently moved into #session.housename#</b>
	</cfoutput>
	<cfabort>
</cfif>

<!---08/12/2010 Project 50227 Tips Promotion Sathya added this --->
<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
	<cfquery name="Houses" datasource="#application.datasource#">
	SELECT ihouse_id, cName
	FROM HOUSE (nolock)
	WHERE dtrowdeleted is null
	ORDER By cName
	</cfquery>
</cfif>
<!--- End of Project 50227 --->
<cfquery name="qryAccountingPeriodReport" datasource="#APPLICATION.datasource#">
   SELECT  distinct(iAccountingPeriod) as AcctPeriod
  FROM TIPS4.dbo.AccountingApprovalChanges
</cfquery>
<cfoutput>
<!--- Include House Header for TIPS --->
<cfinclude template="../Shared/HouseHeader.cfm">
<br>

<!--- Non Converted Houses Check START --->
<cfif isDefined("URL.ActiveX") and 	URL.ActiveX EQ 1 and listfindNocase(session.codeblock,23) EQ 0>
	<table>
	<tr><td colspan="4" style="font-size: 18; background: slateblue; color: white; text-align: center;">Related Reports for #session.HouseName#</td></tr>	
	<tr>
		<form name="ValidationReport" action="ValidationReport.cfm" method="POST">									
			<td style="width: 25%;"> <a href="" onClick="submit(); return false">Validation Report (Pre-Resident Care)</A> </td>
			<td style="width: 50%;" colspan=2>Effective On: <input type="TEXT" name="dtEffective" value="#DateFormat(Now(),'m/d/yyyy')#"><input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;"></td>
			<td style="width: 25%;"></td>
		</form>
	</tr>
	</table>
	<CFABORT>
</cfif>
<!--- END Non Converted Houses Catch --->
<table>


	<tr>
		<th colspan="100%" style="font-size: 18;">Related Reports for #session.HouseName#</th>
	</tr>
	
	
	<tr>
		<td  nowrap="nowrap" colspan=100%>
	 		<a href="HouseAgingReport.cfm?prompt0=#session.qselectedhouse.ihouse_id#">House Aging Report</A> 
	 	</td>
	</tr>



	<!---<cfif ListFindNoCase(session.codeblock,21) GT 0>--->
		<tr>
			<td nowrap="nowrap" colspan=100%><a href="BirthdaySummaryReport.cfm">Birthday Summary</A></td>
		</tr>
	<!---</cfif>--->
	

	<tr>
	  <cfset Selected = ''>
		<form name="MoveInMoveOutActivitySummaryByHouseReport" 
		action="MoveInMoveOutActivitySummaryByHouseReportA.cfm" method="POST">									
			<td nowrap="nowrap" style="width: 25%;">
				<a href="" onClick="submit(); return false">
				MoveIn/Out Activity Summary By House Report</A>
			</td>
			<td style="width: 25%;">
				<select name="pPeriod">
					<cfloop query="Period">
						<cfscript>
							TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm");
							if (TIPSPeriod EQ Period.cAppliesToAcctPeriod) { Selected = 'Selected';} else { Selected = ''; }
						</cfscript>
						<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#>
						 #Period.cAppliesToAcctPeriod# 
						 </option>
					</cfloop>
				</select>
				<select name="pResidencyType">
					<option value="A" #SELECTED#> All Resident Types</option>
					<option value="P"> Private Only </option>
					<option value="M"> Medicaid Only </option>
					<option value="R"> Respite Only </option>
				</select>
			</td>
			<td style="width:25%;">
				<select name="pActivityType">
					<option value="B" #SELECTED#> MoveIns and MoveOuts </option>
					<option value="I"> MoveIns only </option>
					<option value="O"> MoveOut only </option>
				</select>
			</td>
			<td style="width:25%;">
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
		</form>
	</tr>
	

	

	<tr>
		<td colspan="2"><a href="HouseMailingLabels.cfm">Mailing Labels Print (PDF)</a></td>
		<td style="width: 25%;">&nbsp;</td>
		<td style="width: 25%;">&nbsp;</td>
	</tr>	
	<tr>
 		<td colspan="2">		
			<form name="labelfile" method="post" action="HouseResidentsMailingLabelFIle.cfm">
	 			<a href ="" onClick="submit(); return false">Mailing Labels File Download (Excel)</A>
			</form>	
		</td> 
		<td style="width: 25%;">&nbsp;</td>
		<td style="width: 25%;">&nbsp;</td>
	</tr>	
	<tr>
		<form name="OccupiedUnitSummaryReport" action="OccupiedUnitSummaryReport.cfm" method="POST">									
			<td nowrap="nowrap"> <a href ="" onClick="submit(); return false">Occupied Unit Summary</A>	 </td>
			<td style="width: 25%;">
		
				<select name="prompt1">
					<cfloop query="Period">
						<cfset TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm")>
						<cfif TIPSPeriod EQ Period.cAppliesToAcctPeriod> <cfset Selected = 'Selected'> <CFELSE> <cfset Selected = ''> </cfif>
						<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#> #Period.cAppliesToAcctPeriod#	</option>
					</cfloop>
				</select>	
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
			<td style="width: 25%;"></td><td style="width: 25%;"></td>
		</form>
	</tr>		

	<tr>
<!--- 		<form name="TenantRoster" action="TenantRosterReport.cfm" method="POST"> --->		
		<form name="TenantRoster" action="ResidentRoster.cfm" method="POST">							
			<td nowrap="nowrap"> <a href="" onClick="submit(); return false">Resident Roster</A>	 </td>
			<td style="width: 25%;">
		
				<select name="prompt1">
					<cfloop query="Period">
						<cfset TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm")>
						<cfif TIPSPeriod EQ Period.cAppliesToAcctPeriod> 
							<cfset Selected = 'Selected'> 
						<CFELSE> 
							<cfset Selected = ''> 
						</cfif>
						<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#> #Period.cAppliesToAcctPeriod# </option>
					</cfloop>
				</select>	
					
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
			<td style="width: 25%;"></td>
			<td style="width: 25%;"></td>
		</form>
	</tr>		
	<tr>
		<form name="MoveInSummary"  action="MoveInReportA.cfm"method="POST">
<!--- 						action="MoveInSummary.cfm" 			<a href="Reports/MoveInReportA.cfm?prompt0=#qResidentTenants.iTenant_ID#">#DATEFORMAT(qResidentTenants.dtRentEffective, "mm/dd/yyyy")#</a> --->
		<td nowrap="nowrap"> <a href="" onClick="submit(); return false;"> Move In Summary </A> </td>
		<td style="width: 25%;">
			<!--- (#Tenants.cSolomonKey#) --->
			<select name="prompt0">
				<cfloop query="Tenants">
					<option value="#Tenants.iTenant_ID#"> #Tenants.FullName# (#Tenants.cSolomonKey#)</option>	
				</cfloop>
			</select>
		</td>
		
		<td style="width: 25%;"><input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;"></td>
		</form>
		<td style="width: 25%;"></td>
	</tr>


	<tr>
		<form name="AccountingActivity" action="AccountingActivityReport.cfm" method="POST">
		<td nowrap="nowrap"> <a href="" onClick="submit(); return false;"> Customer Accounting Activity </A> </td>
		<td style="width: 25%;">
			<select name="prompt0">
			<cfloop query="Tenants"><option value="#Tenants.cSolomonKey#"> #Tenants.FullName# (#Tenants.cSolomonKey#)</option>	</cfloop>
			</select>
		</td>
		
		<td style="width: 25%;"><input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;"  onClick="submit(); return false;"></td>
		</form>
		<td style="width: 25%;"></td>
	</tr>

	<tr>
		<!--- <form name="EOM" action="EOMReport.cfm" method="POST"> --->			
		<form name="EOM" action="EOMSummary.cfm" method="POST">							
			<td nowrap="nowrap"> <a href="" onClick="submit();return false">End of Month Summary</A></td>
			<td style="width: 25%;">
				<cfquery name = "Period" datasource="#application.datasource#">
					select distinct cAppliesToAcctPeriod
					from InvoiceMaster im (nolock)
					where cAppliesToAcctPeriod is not null
					and im.dtRowDeleted is null and (left(im.cSolomonKey, 3) + 1800) = #session.nHouse#
					order by cAppliesToAcctPeriod desc
				</cfquery>		
					
				<select name="prompt1">
					<cfloop query="Period">
						<cfscript>
							TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm");
							if (TIPSPeriod EQ Period.cAppliesToAcctPeriod){ Selected = 'Selected'; } else {Selected = '';}
						</cfscript>
						<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#> #Period.cAppliesToAcctPeriod# </option>
					</cfloop>
				</select>	
					
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
			<td style="width: 25%;"></td><td style="width: 25%;"></td>
		</form>
	</tr>
<tr>
		<form name="TenantCharge" action="TenantChargeReport.cfm" method="POST">									
			<td nowrap="nowrap"> <a href ="" onClick="submit();return false">Resident Charge Summary</A> </td>
			<td style="width: 25%;">		
				<select name="prompt1">
					<cfloop query="Period">
						<cfscript>
							TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm");
							if (TIPSPeriod EQ Period.cAppliesToAcctPeriod){ Selected = 'Selected';} else {Selected = '';}
						</cfscript>
						<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#> #Period.cAppliesToAcctPeriod# </option>
					</cfloop>
				</select>
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
			</td>
			<td style="width: 25%;"></td><td style="width: 25%;"></td>
		</form>
	</tr>	

	<tr>
		<form name="Invoices" action="InvoiceReportB.cfm"  method="post">
		<td nowrap="nowrap"> <a href="" onClick="submit(); return false;"> Print Invoices </A><br>(EFT Only: 
          <INPUT name="bUsesEFT" TYPE="checkbox" value="1">
          )</td>
		
		<td style="width: 25%;">
			
			<cfquery name="Tenants" datasource="#application.datasource#">
				select *, (T.cLastName + ', ' + T.cFirstName) as FullName 
				from Tenant T (nolock)
				join TenantState TS (nolock)	ON T.iTenant_ID = TS.iTenant_ID
				where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID between 2 and 4
				order by cLastName
			</cfquery>
			
			<select name="prompt0">
				<option value="ALL"> For All Residents </option>
				<cfloop query="TenantsNoRespite">
					<option value="#TenantsNoRespite.cSolomonKey#">#TenantsNoRespite.FullName# (#TenantsNoRespite.cSolomonKey#)</option>
				</cfloop>
			</select>
		</td>
	
		<td style="width: 25%;">
			<select name="prompt2">
				<cfloop query="Period">
					<cfscript>
						TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm");
						if (TIPSPeriod EQ Period.cAppliesToAcctPeriod) { Selected = 'Selected'; } else { Selected = ''; }
					</cfscript>
					<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#> #Period.cAppliesToAcctPeriod# </option>
				</cfloop>
			</select>	
			<input  type="hidden" name="prompt4" value="#session.nhouse#" />
			<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
		</td>
		<td style="width: 25%;">Comments: <input type="TEXT" name="cComments" value=""></td>
		</form>
	</tr>
<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
    <tr>
	<form name="Invoices" action="InvoiceReportB_test.cfm"  method="post">
	<td nowrap="nowrap"> <a href="" onClick="submit(); return false;"> Print Invoices (test) </A><br>(EFT Only: 
      <INPUT name="bUsesEFT" TYPE="checkbox" value="1">
      )</td>
	
	<td style="width: 25%;">
		
		<cfquery name="Tenants" datasource="#application.datasource#">
			select *, (T.cLastName + ', ' + T.cFirstName) as FullName 
			from Tenant T (nolock)
			join TenantState TS (nolock)	ON T.iTenant_ID = TS.iTenant_ID
			where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID between 2 and 4
			order by cLastName
		</cfquery>
		
		<select name="prompt0">
			<option value="ALL"> For All Residents </option>
			<cfloop query="TenantsNoRespite">
				<option value="#TenantsNoRespite.cSolomonKey#">#TenantsNoRespite.FullName# (#TenantsNoRespite.cSolomonKey#)</option>
			</cfloop>
		</select>
	</td>

	<td style="width: 25%;">
		<select name="prompt2">
			<cfloop query="Period">
				<cfscript>
					TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm");
					if (TIPSPeriod EQ Period.cAppliesToAcctPeriod) { Selected = 'Selected'; } else { Selected = ''; }
				</cfscript>
				<option value="#Period.cAppliesToAcctPeriod#" #SELECTED#> #Period.cAppliesToAcctPeriod# </option>
			</cfloop>
		</select>	
		<input  type="hidden" name="prompt4" value="#session.nhouse#" />
		<input type="Button" name="Go" value="GO (test)" style="font-size: 12; color: navy; height: 20px; width: 60px;" onClick="submit(); return false;">
	</td>
	<td style="width: 25%;">Comments: <input type="TEXT" name="cComments" value=""></td>
	</form>
</tr>
</cfif>
	<form name="ClosedAcctRespiteInvoices" action="..\RespiteInvoicing\HistRespiteInvoices.cfm" method="get">
		<!--- 25575 - 8/2/2010 - RTS - New Respite Invoice Interface since invoices are no longer monthly --->
		<cfquery name="HistRespiteTenants" datasource="#application.datasource#">
			select t.cSolomonKey, (T.cLastName + ', ' + T.cFirstName) as FullName 
			from Tenant T
			join TenantState TS  ON (T.iTenant_ID = TS.iTenant_ID
							and TS.iResidencyType_ID = 3
							and TS.iTenantStateCode_ID in (3,4)
							and TS.dtRowDeleted is null)
			where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			and T.dtRowDeleted is null 
			and TS.dtMoveIn > ''
			order by cLastName
		</cfquery>
		<TR>
			<td nowrap="nowrap">Respite Moved Out Invoices:</td>	
			<td>
				<select name="SolID">
					<option>...Select Resident</option>
					<cfloop query="HistRespiteTenants">
						<option value="#HistRespiteTenants.cSolomonKey#">
						#HistRespiteTenants.FullName# (#HistRespiteTenants.cSolomonKey#)
						</option>
					</cfloop>
				</select>
			</td>
			<td>
				<input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" 
				onClick="submit();">
			</td>	
		</TR>
		</form>


		<tr>
<!--- 		<form name="ResidentTaxLetter" action="ResidentTaxLetter.cfm" method="POST"> --->
			<form name="ResidentTaxLetter" action="HouseResidentTaxLetterForm.cfm" method="POST">

		<input type="hidden" name="prompt0" value="#trim(session.qSelectedHouse.cName)#">
		<td nowrap="nowrap"> <a href="" onClick="submit(); return false;"> Resident Tax Letter </A> </td>
		<td style="width: 25%;" colspan=2>
			<select name="prompt1">
				<cfloop query="JustYear">
					<option value="#TheYear#">#TheYear#</option>
				</cfloop>
			</select>	

			<cfquery name="Tenants" datasource="#application.datasource#">
				select *, (T.cLastName + ', ' + T.cFirstName) as FullName 
				from Tenant T (nolock)
				join TenantState TS	(nolock) on T.iTenant_ID = TS.iTenant_ID
				where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and T.dtRowDeleted is null and TS.dtRowDeleted is null and TS.iTenantStateCode_ID between 2 and 4
				order by cLastName
			</cfquery>
			
			<select name="prompt2"><option value="">Select A Resident</option>
			<cfloop query="Tenants"><option value="#Tenants.iTenant_ID#">#Tenants.FullName# (#Tenants.cSolomonKey#)</option></cfloop>
			</select>
		</td>
		<td style="width: 25%;"><input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;"></td>
		<td style="width: 25%;"></td>
		</form>
	</tr>
<tr>
	<form name="TIPSApproval" action="../Admin/AdminApprovalPrint.cfm" method="post">
		<td>LOC/BSF Admin Approvals Report</td> 
<!--- 	<cfif qryAccountingPeriodReport.recordcount gt 0> --->
		<td>
			<select name="SelPeriod">
				<option value="">Select TIPS Period </option>
				<cfloop query="qryAccountingPeriodReport">
					<option value="#AcctPeriod#">#AcctPeriod#</option>
				</cfloop>
			</select>&nbsp;
			<input type="Button" name="Go" value="GO" 
			style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
		</td>
<!--- 	<cfelse>
	<td>No records to view</td>		
	</cfif>	 --->	
	</form>
</tr>

<cfif ((ListContains(session.groupid,'353') gt 0) or (session.username is 'sfarmer'))>
	<tr>
		<form method="post" name="MonthlyCensusRpt" action="../census/CensusMonthlyReportXLSSel.cfm" >
		<td>Monthly Census Excel Report:<br />Enter Selection Criteria</td>
		<td><input type="Button" name="Go" value="GO" 
			style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;"></td>
		</form>
	</tr>
</cfif>
<cfquery name="qryPeriodLatefeeReport" datasource="#APPLICATION.datasource#">
   SELECT  distinct(ApprovalPeriod) as AcctPeriod
  FROM TIPS4.dbo.ReportLateFeePaidAllHouse
</cfquery>
<!---Mshah added here--->
<tr>
<form name="TIPSApproval" action="../Admin/Reportlatefeepaid.cfm" method="post">
	<td>List of Late Fee Paid </td> 
	<td>
		<select name="SelPeriod">
			<option value="">Select TIPS Period </option>
			<cfloop query="qryPeriodLatefeeReport">
				<option value="#AcctPeriod#">#AcctPeriod#</option>
			</cfloop>
		</select>&nbsp;
		<input type="Button" name="Go" value="GO" 
		style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;">
	</td>			
</form>
</tr>
<!---Mshah end--->


</table>
</cfoutput>
<cfif (session.username eq 'paulb' or session.username eq 'stephend' or session.username eq 'kdeborde') and isDefined("session.qSelectedHouse.iHouse_ID")>
	<cfinclude template="../InvDuplicateCheck.cfm">
</cfif>
<!--- Include Intranet footer --->
<cfinclude template="../../footer.cfm">
