<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
 <!--- 
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| sfarmer    |03/20/2012  |  Added for deferred New Resident Fee/EFT project 75019             |
| sfarmer    | 9/5/2012   | Project 93488 -  corrected link.                                   |
| sfarmer    | 12/12/2012 | Project 99289 -  corrected date extract - display.                 | 
| sfarmer    | 08/08/2013 | Project 106456 -  add provision for no pull file - for $0.00       | 
|            |            | and less than $0.00 accounts                                       | 
| sfarmer    | 12/30/2013 | set calendar to pull from 2014                                     |
| tpecku     | 10/19/2016 | added code to dynamically generate the Process Pull and            |
             |            | Process No-Pull file buttons and pass the appropriate cCompanyID to| 
             |            | the next page                                                      |
|Mshah		 |01/26/2017  | Added FHLMC EFT enhancement										   |
|Mstriegel   |05/23/2018  | Cleaned up the code 											   |
----------------------------------------------------------------------------------------------->
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<title>EFT Pull Calendar</title>
		<link href="Styles/Index.css" rel="stylesheet" type="text/css" />
		<script src="../ScriptFIles/Functions.js"></script>
		<script src="../ScriptFIles/ts_picker.js"></script>
		<script>
			window.onload=createhintbox;
		</script>
	</head>
	<body>
		<cfinclude template='../../header.cfm'>
		<cfinclude template='../Shared/HouseHeader.cfm'>
		<cfparam name="Form.Period" default="">
		<cfset CurrentYear = dateformat(now(),"YYYY")>

		<cfquery name="GetHouses" datasource="#application.datasource#">
			SELECT cname, CONVERT(VARCHAR(6), dateadd(MM, -1,dtCurrentTipsMonth),112) as TipsMonth
			, dtEFT1, dtEFT2, dtEFT3, dtEFT4, dtEFT5
			FROM House h WITH (NOLOCK)
			INNER JOIN houselog hl WITH (NOLOCK) on hl.ihouse_ID = h.ihouse_ID
			LEFT JOIN EFTCalendar2 c WITH (NOLOCK) on c.cAppliesToAcctPeriod = CONVERT(VARCHAR(6), dateadd(MM, -1,dtCurrentTipsMonth),112)
			WHERE h.dtrowdeleted is  null
			AND h.bIsSandbox = 0
			ORDER BY cname 
		</cfquery>
		<cfquery name="GetEFT" datasource="#application.datasource#">
			SELECT dteft1, dteft2, dteft3, dteft4, dteft5
			FROM EFTCalendar2 WITH (NOLOCK)
			WHERE cAppliesToAcctPeriod like '#CurrentYear#%'
		</cfquery>
		<cfquery name="GetcCompanyID" datasource="#application.datasource#">
		    SELECT distinct cCompanyID 
		    FROM house WITH (NOLOCK) 
			WHERE cCompanyID IS NOT NULL
			ORDER BY cCompanyID asc
		</cfquery>

		<form name="EFTform" action="EFT_Update.cfm" method="post">	
			<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse" bordercolor="#111111" width="14%">
				<tr>
					<td width="36%" align="center"><b>Period</b></td>
					<td width="12%" align="center"><b>EFTDate Pull 1</b></td>
					<td width="12%" align="center"><b>EFTDate Pull 2</b></td>
					<td width="12%" align="center"><b>EFTDate Pull 3</b></td>
					<td width="12%" align="center"><b>EFTDate Pull 4</b></td>
					<td width="12%" align="center"><b>EFTDate Pull 5</b></td>
				</tr>		
				<cfoutput query="GetEFT">
					<tr>
						<td width="36%">
							<center>				
								<input name="Period" type="text" class="hintanchor" value="#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" size="6" maxlength="6" readonly>
							</center>
						</td>
						<td width="12%">
							<input name="EFTDate1_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" type="text" class="hintanchor" size="8" maxlength="8" VALUE='#DATEFORMAT(GetEFT.dtEFT1,"MM/DD/YYYY")#'>
							<center>
								<a href="javascript:show_calendar4('document.EFTform.EFTDate1_#CurrentYear##NumberFormat(GetEFT.currentrow,'09')#',document.EFTform.EFTDate1_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#.value);">
									<img src="../Images/cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp">
								</a>
							</center>
						</td>		
						<td width="12%">
							<input name="EFTDate2_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" type="text" class="hintanchor" size="8" maxlength="8" VALUE='#DATEFORMAT(GetEFT.dtEFT2,"MM/DD/YYYY")#'>
							<center>
								<a href="javascript:show_calendar4('document.EFTform.EFTDate2_#CurrentYear##NumberFormat(GetEFT.currentrow,'09')#',document.EFTform.EFTDate2_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#.value);">
									<img src="../Images/cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp">
								</a>
							</center>
						</td>
						<td width="12%">
							<input name="EFTDate3_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" type="text" class="hintanchor" size="8" maxlength="8" VALUE='#DATEFORMAT(GetEFT.dtEFT3,"MM/DD/YYYY")#'>
							<center>
								<a href="javascript:show_calendar4('document.EFTform.EFTDate3_#CurrentYear##NumberFormat(GetEFT.currentrow,'09')#',document.EFTform.EFTDate3_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#.value);">
									<img src="../Images/cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp">
								</a>
							</center>
						</td>
						<td width="12%">
							<input name="EFTDate4_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" type="text" class="hintanchor" size="8" maxlength="8" VALUE='#DATEFORMAT(GetEFT.dtEFT4,"MM/DD/YYYY")#'>
							<center>
								<a href="javascript:show_calendar4('document.EFTform.EFTDate4_#CurrentYear##NumberFormat(GetEFT.currentrow,'09')#',document.EFTform.EFTDate4_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#.value);">
									<img src="../Images/cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp">
								</a>
							</center>
						</td>
						<td width="12%">
							<input name="EFTDate5_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#" type="text" class="hintanchor" size="8" maxlength="8" VALUE='#DATEFORMAT(GetEFT.dtEFT5,"MM/DD/YYYY")#'>
							<center>
								<a href="javascript:show_calendar4('document.EFTform.EFTDate5_#CurrentYear##NumberFormat(GetEFT.currentrow,'09')#',document.EFTform.EFTDate5_#CurrentYear##NumberFormat(GetEFT.currentrow, '09')#.value);">
									<img src="../Images/cal.gif" width="16" height="16" border="0" alt="Click Here to Pick up the timestamp">
								</a>
							</center>
						</td>																							
					</tr>
				</cfoutput>
				<tr>
					<td height="36" colspan="6">
						<font size="1" color="FF0000">
							<div align="center">
								<input name="run" type="submit" value="Submit">        
								<input type="reset" name="Reset" value="Reset">
							</div>
						</font>
					</td>
				</tr>
			</table>		
		</form>		
		<table>
			<tr>
				<td align='center'><b><u>Process Pull</u></b></td>
			</tr>
			<tr>
				<td align='center'>Extract EFT Pull File for bank processing.&nbsp;&nbsp;Select only 1 file at a time.</td>
			</tr>
			<cfif GetcCompanyID.recordcount IS '0'>
				<tr>
					<td align='left'>There are no EFT Pull Files available.	</td>
				</tr>
			<cfelse>
				<cfloop query ="GetcCompanyID">
					<tr>
						<td align='center'>
							<cfoutput>
								<input type="submit"  name="processpullfile" id="processpullfile" value="Process Pull File-#GetcCompanyID.cCompanyID#" size="20" onClick="self.location.href='EFTprocesspullfile.cfm?requestTimeout=9000&cCompanyID=#GetcCompanyID.cCompanyID#'">
							</cfoutput>
						</td>
					</tr>
				</cfloop>
			</cfif>
				<tr>
					<td><hr></td>
				</tr>
				<tr>
					<td align='center'>
						<input type="submit"  name="processpullfile_FHLMC" id="processpullfile_FHLMC" value= "Process Pull File-FHLMC" size="20" onClick="self.location.href='EFTprocesspullfile.cfm?requestTimeout=9000'">
					</td>
				</tr>
				<tr>
					<td><hr></td>
				</tr>
				<tr>
					<td align='center'><b><u>Process No Pull</u></b></td>
				</tr>
				<tr>
					<td align='center'>Extract EFT No Pull Amount File for review.&nbsp;&nbsp;Select only 1 file at a time</td>
				</tr>
			<cfif GetcCompanyID.recordcount IS '0'>
				<tr>
					<td align='left'>There are no EFT No Pull Files available.</td>
				</tr>
			<cfelse>
				<cfloop query ="GetcCompanyID">
					<tr>
						<td align='center'>
							<cfoutput>
								<input type="submit"  name="processnopullfile" id="processnopullfile" value="Process No Pull File-#GetcCompanyID.cCompanyID#" size="20" onClick="self.location.href='EFTprocessNoDrawPullFile.cfm?requestTimeout=9000&cCompanyID=#GetcCompanyID.cCompanyID#'">
							</cfoutput>
						</td>
					</tr>
				</cfloop>
			</cfif>
			<tr>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td align='center'>
					<input type="submit"  name="processnopullfile_FHLMC" id="processnopullfile_FHLMC" value= "Process No Pull File-FHLMC" size="20" onClick="self.location.href='EFTprocessnoDrawpullfile.cfm?requestTimeout=9000'">
				</td>
			</tr>
			<tr>
				<td><hr></td>
			</tr>
		</table>
	</body>
</html>
