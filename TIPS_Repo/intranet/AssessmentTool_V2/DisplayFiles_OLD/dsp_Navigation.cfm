<!----------------------------------------------------------------------------------------------|
| HISTORY                                                                                       |
|-----------------------------------------------------------------------------------------------|
| Author    | Date       | 	Description                                                         |
|-----------|------------|----------------------------------------------------------------------|
| DESCRIPTION                                                                                   |
| Sfarmer   | 03/23/2012 | Removed link to Assessment Tool Report which is inactive             |
------------------------------------------------------------------------------------------------>
<cfoutput>
<table class="navigation" cellspacing="1" cellpadding="3" id="menu" name="menu">
	<tr>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'" onclick="window.location = 'http://#cgi.SERVER_NAME#/intranet/tips4/mainmenu.cfm?selectedhouse_id=#session.house.getid()#'">
			Tips Home
		</td>
		<td class="navigationNoLink" name="newResidentMenu" id="newResidentMenu" onmouseover="ShowMenu('newResidentMenu','newResidentSubMenu')" onmouseout="TimeoutOver()">
			New Residents <img src="Images/downArrow.gif">
		</td>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'" onclick="window.location='http://#cgi.server_name#/intranet/tips4/census/census.cfm?selectedhouse_id=#session.house.getid()#'">
			Census
		</td>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'" onclick="window.location='http://#cgi.server_name#/intranet/tips4/cashreceipts/cashreceipts.cfm?selectedhouse_id=#session.house.getid()#'">
			Payments
		</td>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'" onclick="window.location='http://#cgi.server_name#/intranet/tips4/cashreceipts/historiccashreceipts.cfm?selectedhouse_id=#session.house.getid()#'">
			Deposits
		</td>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'" onclick="window.location='http://#cgi.server_name#/intranet/tips4/relocate/relocatetenant.cfm?selectedhouse_id=#session.house.getid()#'">
			Relocate
		</td>
		<td class="navigationNoLink" name="newChargesMenu" id="newChargesMenu" onmouseover="ShowMenu('newChargesMenu','newChargesSubMenu')" onmouseout="TimeoutOver()">
			Charges <img src="Images/downArrow.gif">
		</td>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'" onclick="window.location='http://#cgi.server_name#/intranet/tips4/reports/menu.cfm?selectedhouse_id=#session.house.getid()#'">
			Reports
		</td>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'"onclick="window.location='http://#cgi.server_name#/intranet/tips4/admin/menu.cfm?selectedhouse_id=#session.house.getid()#'">
			Admin
		</td>
		<cfif isDefined("fuse") AND FindNoCase("Assessment",fuse) eq 0>
		<td class="navigation" onmouseover="this.className='navigationOver';this.childNodes[0].className='navigationOver'" onmouseout="this.className='navigation'"onclick="window.location='http://#cgi.server_name#/intranet/assessmenttool_v2/index.cfm'">
		<cfelse>
		<td class="navigationOver">
		</cfif>
			Assessments
		</td>
	</tr>
</table>
<!--- <div class="administrationLink"><a href="index.cfm?fuse=reports" class="header">Assessment Tool Reports</a></div> 87968 --->
<cfif ListFind(session.grouplist,adminGroupId) neq 0>
	<div class="administrationLink"><a href="index.cfm?fuse=assessmentToolAdministration" class="header">Assessment Tool Administration</a></div>
</cfif>

<table class="subNavigation" cellspacing="1" cellpadding="3" name="newResidentSubMenu" id="newResidentSubMenu">
	<tr onmouseover="SubOver(this)" onmouseout="SubOut(this)">
		<td class="subNavigation" onclick="window.location='http://#cgi.server_name#/intranet/MarketingLeads/Leads.cfm?selectedhouse_id=#session.house.getid()#'">
			Inquiry
		</td>
	</tr>
	<tr onmouseover="SubOver(this)" onmouseout="SubOut(this)">
		<td class="subNavigation" onclick="window.location='http://#cgi.server_name#/intranet/tips4/registration/registration.cfm?selectedhouse_id=#session.house.getid()#'">
			Move In
		</td>
	</tr>
</table>
<table class="subNavigation" cellspacing="1" cellpadding="3" name="newChargesSubMenu" id="newChargesSubMenu">
	<tr onmouseover="SubOver(this)" onmouseout="SubOut(this)">
		<td class="subNavigation" onclick="window.location='http://#cgi.server_name#/intranet/tips4/charges/charges.cfm?selectedhouse_id=#session.house.getid()#'">
			Charges / Credits Entered
		</td>
	</tr>
	<tr onmouseover="SubOver(this)" onmouseout="SubOut(this)">
		<td class="subNavigation" onclick="window.location='http://#cgi.server_name#/intranet/tips4/recurringcharges/recurring.cfm?selectedhouse_id=#session.house.getid()#'">
			Recurring Charges
		</td>
	</tr>
	<tr onmouseover="SubOver(this)" onmouseout="SubOut(this)">
		<td class="subNavigation" onclick="window.location='http://#cgi.server_name#/intranet/tips4/charges/adjustmentrequest.cfm?selectedhouse_id=#session.house.getid()#'">
			Adjustments
		</td>
	</tr>
</table>
<br>
<div class="header"><a href="http://#cgi.SERVER_NAME#/intranet/tips4/mainmenu.cfm" class="breadcrumbs">#session.House.GetFormattedName()#</a> : #session.breadcrumbs#</div>
<br>
</cfoutput>