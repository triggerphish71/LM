
<cftry>
	<cfquery name="CollectionNotes" datasource="HOUSES_APP">
		SELECT CUSTID, ActionDesc, ActionStatus
		  , CRTD_DATETIME, CRTD_USER
		  , LUPD_DATETIME, LUPD_USER
		  , NEXTACTIONDTE
		  , NOTETEXT1 + NOTETEXT2 + NOTETEXT3 + NOTETEXT4 + NOTETEXT5 + NOTETEXT6 + NOTETEXT7 + NOTETEXT8 as Notes
		FROM XCOLLECTORNOTES
		WHERE CUSTID = '#URL.SolID#'
		ORDER BY CRTD_DATETIME desc
	</cfquery>
	
	<cfquery name="TenantInfo" datasource="#Application.datasource#">
		select distinct cfirstname, clastname
		From tenant
		where csolomonkey = '#URL.SolID#' and dtrowdeleted is null
	</cfquery>

	<cfcatch type="database">
		<h2><center>Looks like you tried using a bad Solomonkey.  Close this window and Try Again</center></h2>
	</cfcatch>
</cftry>

<cfif CollectionNotes.recordCount eq 0>

	<h2><center>No Collection notes were found for this Tenant.</center></h2>
	
<cfelse>
	<cfoutput query="TenantInfo">
		<h2>Collection Notes for: #cFirstname# #cLastName#</h2>
	</cfoutput>
	<table cellspacing="0" cellpadding="3">
		<tr>
			<th>Note Created</th>
			<th>Created By</th>
			<th>Last Updated</th>
			<th>Updated By</th>
			<th>Next Action</th>
		</tr>
		<cfoutput query="CollectionNotes">
			<cfif CollectionNotes.Recordcount mod 2 neq 0> 
				<tr bgcolor="##999999">
			<cfelse>
				<tr>
			</cfif>
				<td align="center">#dateformat(CRTD_DATETIME,"MM/DD/YYYY")#</td>
				<td align="center">#CRTD_USER#</td>
				<td align="center">#dateformat(LUPD_DATETIME,"MM/DD/YYYY")#</td>
				<td align="center">#LUPD_USER#</td>
				<td align="center">#dateformat(NEXTACTIONDTE,"MM/DD/YYYY")#</td>
			</tr>
			<tr>
				<td colspan="5">#Notes#</td>
			</tr>
		</cfoutput>
	</table>
</cfif>
<br /><br />
<cftry>
	<cfquery name="CustMaintNotes" datasource="HOUSES_APP">
		Select C.CustId, SN.dtRevisedDate, SN.sNoteText
		From Snote SN
		Join Customer C on C.NoteID = SN.nID
		where C.CustId = '#URL.SolID#'
	</cfquery>
    
	<cfcatch type="database">
		<h2><center>Looks like you tried using a bad Solomonkey.  Close this window and Try Again</center></h2>
	</cfcatch>
</cftry>

<cfif CustMaintNotes.recordCount eq 0>

	<h2><center>No Customer Maintenance notes were found for this Tenant.</center></h2>
	
<cfelse>
	<cfoutput query="TenantInfo">
		<h2>Maintenance Notes for: #cFirstname# #cLastName#</h2>
	</cfoutput>
	<table cellspacing="0" cellpadding="3">
		<tr >
			<th>Last Updated</th>
			<th>Notes</th>
		</tr>
		<cfoutput query="CustMaintNotes">
			<tr bgcolor="##999999">
				<td align="center">#dateformat(dtRevisedDate,"MM/DD/YYYY")#</td>
				<td colspan="5" width="80%">#sNoteText#</td>
			</tr>
		</cfoutput>
	</table>
</cfif>


<br /><br />
<center><input type="button" value="Close Window" onclick="window.close();" /></center>