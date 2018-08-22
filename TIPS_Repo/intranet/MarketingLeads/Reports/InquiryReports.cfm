<cfoutput>
<cfquery name="qScope" datasource="TIPS4">
select r.cname division, o.cname region, h.cname house, r.iregion_id, o.iopsarea_id, h.ihouse_id
from house h
join opsarea o on o.iopsarea_id = h.iopsarea_id and o.dtrowdeleted is null
join region r on r.iregion_id = o.iregion_id and r.dtrowdeleted is null
order by r.cname, o.cname, h.cname
</cfquery>
<script>
function init() { location.hash='##@start'; self.scrollTo(0,0); }
window.onload=init;
</script>
<link rel="StyleSheet" type="text/css" href="http://#server_name#/intranet/tips4/shared/style3.css">
<form action="" method="POST">
<table class="noborder">
	<tr><td class="topleftcap"></td><td colspan="100" CLASS="toprightcap"></td></tr>
	<tr><th class="leftrightborder" colspan="100">Inquriy Tracking Reports</th></tr>
	<tr>
	<td class="leftborder">&nbsp;<B>#SESSION.qSelectedHouse.cName#</B></td>
	<td class="rightborder" colspan="100"></td>
	</tr>
	<cfif FindNoCase("house",Session.username,1) EQ 0>
	<tr>
		<td class="leftborder">
			Report Name: 
			<select name="ReportName">
				<option value="InquiryLabels.cfm">Inquiry Labels</OPTION>
				<option value="ResidentLabels.cfm">Resident Labels</OPTION>
				<option value="ltTaskList.cfm">Task List</OPTION>
			</select>
		</td>
		<td>
			Scope of report: 
			<cfscript> houseid=''; regionid=''; divisionid=''; </cfscript>
			<select name="Scope">
				<option value="0">All Houses</option>
				<cfloop query="qScope">
					<cfif qScope.iRegion_id NEQ divisionid>
						<option value="#qScope.iregion_id#" style="background: gainsboro;">#ucase(qScope.division)# DIVISION</option>
					</cfif>
					<cfif qScope.iopsarea_id NEQ regionid>
						<option value="#qScope.iopsarea_id#" style="background: whitesmoke; color: blue;">&nbsp;#qScope.region#</option>
					</cfif>
					<option value="#qScope.house#">&nbsp;&nbsp;&nbsp;#lcase(qScope.house)#</option>
					<cfscript>
						houseid=qScope.ihouse_id; regionid=qScope.iopsarea_id; divisionid=qScope.iregion_id;
					</cfscript>
				</cfloop>
			</select>		
		</td>
		<script>
			function scopereport() {
				nUrl= document.forms[0].ReportName.value + '?' + 'scp=' + document.forms[0].Scope.value;
				document.forms[0].action=nUrl; document.forms[0].submit();
			}	
		</script>
		<td class="rightborder" colspan="100"><a><IMG SRC="../view.gif" border="0" onClick="scopereport(); return false;"></a></td>
	</tr>
	</cfif>
	<tr>
		<td class="leftborder"><a href="InquiryLabels.cfm">Inquiry Labels for #session.qselectedhouse.cname#</a></td>
		<td class="rightborder" colspan="100"></td>
	</tr>
	<tr>
		<td class="leftborder"><a href="ResidentLabels.cfm">Resident Labels for #session.qselectedhouse.cname#</a></td>
		<td class="rightborder" colspan="100"></td>
	</tr>
	<tr>
		<td class="leftborder"><a href="ltTaskList.cfm">Task List for #session.qselectedhouse.cname#</a></td>
		<td class="rightborder" colspan="100">&nbsp;</td>
	</tr>
	<tr>
	<td class="leftborder"></td>
	<td class="rightborder" colspan="100">&nbsp;</td>
	</tr>
	<tr>
	<td class="leftborder"><a style="background: 336699; color: white;" href="../leads.cfm">Back to entry Screen</a></td>
	<td class="rightborder" colspan="100"></td>
	</tr>
	<tr><td CLASS="bottomleftcap" colspan=2></td><td CLASS="bottomrightcap" colspan="100"></td></tr>
</table>
</form>
</cfoutput>
	

