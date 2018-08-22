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
| ranklam    | 10/28/2005 | Renamed GUM link to #server_name#                                  |
| S Farmer   | 09/19/2011 |Project 12352 Added SLevelType.cDescription to the output to show   |
             |            | the text differences                                               |
----------------------------------------------------------------------------------------------->

<cfoutput>

<!--- Retrieve all resident care information for this house--->
<cfquery name="qCareCharges" datasource="#APPLICATION.datasource#">
select c.*, sl.iSPointsMin, sl.IsPointsMax, sl.cDescription sldesc
from charges c
join chargetype ct on (ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null)
and ct.bSLevelType_ID is not null and ct.bisdaily is not null
<!--- 2/23/05: katie: Make it so bond houses can see april charges --->
<cfif ListFindNoCase('40,36,179,155,152,185,134,129,124,80,71',#session.qSelectedHouse.iHouse_ID#,",") neq 0>
and ('#SESSION.TipsMonth#' between c.dteffectivestart and c.dteffectiveend OR '4/1/2005' between c.dteffectivestart and c.dteffectiveend)
<cfelse>
and '#SESSION.TipsMonth#' between c.dteffectivestart and c.dteffectiveend
</cfif>
--and getdate() between c.dteffectivestart and c.dteffectiveend
join sleveltype sl on sl.isleveltype_id = c.isleveltype_id and sl.dtrowdeleted is null
join house h on h.ihouse_id = c.ihouse_id and h.csleveltypeset = sl.csleveltypeset
and c.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
where c.dtrowdeleted is null
order by c.cchargeset, c.mamount
<!--- order by c.cchargeset, c.cdescription --->
</cfquery>
<!--- order by c.cchargeset, c.cdescription --->
<!--- retrieve last set changed "from" --->
<cfquery name="qlastset" datasource="#APPLICATION.datasource#">
select top 1 * from rw.vw_house_history where dtrowdeleted is null
and ihouse_id = #SESSION.qSelectedHouse.iHouse_ID# and csleveltypeset <> '#session.qselectedhouse.csleveltypeset#'
order by dtrowend desc
</cfquery>

<!--- Retrieve last resident care information for this house --->
<cfquery name="qLastCareCharges" datasource="#APPLICATION.datasource#">
select c.*, sl.cdescription caredesc
from charges c
join chargetype ct on (ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null)
and ct.bSLevelType_ID is not null and ct.bisdaily is not null
and '#SESSION.TipsMonth#' between c.dteffectivestart and c.dteffectiveend
--and getdate() between c.dteffectivestart and c.dteffectiveend
join sleveltype sl on sl.isleveltype_id = c.isleveltype_id and sl.dtrowdeleted is null
join house h on h.ihouse_id = c.ihouse_id 
and c.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
where c.dtrowdeleted is null and sl.csleveltypeset = '#qlastset.csleveltypeset#'
order by c.cchargeset, c.cdescription
</cfquery>


<cfif qcarecharges.recordcount eq 0>
	<!--- retrieve house default set levels --->
	<cfquery name="qHouseSet" datasource="#APPLICATION.datasource#">
	select * from sleveltype sl
	join house h on h.csleveltypeset = sl.csleveltypeset and h.dtrowdeleted is null
	and h.ihouse_id = #session.qselectedhouse.ihouse_id# and sl.cdescription <> '0'
	where sl.dtrowdeleted is null order by sl.cdescription
	</cfquery>
	
	<!--- list of type ids --->
	<cfquery name="qtypeids" datasource="#APPLICATION.datasource#">
	select distinct isleveltype_id from sleveltype sl
	join house h on h.csleveltypeset = sl.csleveltypeset and h.dtrowdeleted is null
	and h.ihouse_id = #session.qselectedhouse.ihouse_id# and sl.cdescription <> '0'
	where sl.dtrowdeleted is null order by sl.isleveltype_id
	</cfquery>
	<cfset typeids=valuelist(qtypeids.isleveltype_id)>
</cfif>

<!--- rsa - 10/28/2005 - changed link from gum to #server_name# --->
<link rel='Stylesheet' type='text/css' href='http://#server_name#/intranet/tips4/shared/style2.css'>
<!--- Include shared javascript 
<cfinclude template='../Shared/JavaScript/ResrictInput.cfm'>
--->
<script language="JavaScript" src="../Shared/JavaScript/global.js" type="text/javascript"></script>
<script>
function initialize() { self.scrollTo(0,0); }
changesmade=0; 
function savecheck(){ if (changesmade > 0) { document.forms[0].submit(); } else { alert('No Changes Detected'); } }
function cancelform() { if (changesmade > 0) { location.reload(); } else { alert('No Changes Detected'); } }
</script>

<!--- Include header file --->
<cfinclude template='../../header.cfm'>
<cfinclude template='../Shared/HouseHeader.cfm'>

<BR> <a href='menu.cfm'>Click Here to Go Back to the Administration Screen.</a> <br>
<form action='ResidentCareAdministrationUpdate.cfm' method='POST'>
<table width="100%">
	<tr><th colspan="7">#SESSION.HouseName# Resident Care Charges Administration</th></tr>
	<tr>
		<td>Description</td>
		<td>Amount</td>
		<td style='text-align:center;'>Effective Start Date</td>
		<td style='text-align:center;'>Effective End Date</td>
		<cfif session.userid is 3271><td>Charge ID</td></cfif>
		<td style='text-align:center;'>Points Min.</td>
		<td style='text-align:center;'>Points Max.</td>			
		<!---<td style='text-align:center;'>SLevel Description</td>  12352 --->	
	</tr>
	<cfif qcarecharges.recordcount gt 0>
		<cfloop query='qCareCharges'>
			<cfif qCareCharges.currentrow neq 1 and  lastchargeset NEQ qCareCharges.cChargeSet>
				<tr><th colspan=100%>This Section is for the #qCareCharges.cChargeSet# ChargeSet </th></tr>
			</cfif>
			<tr>
				<td nowrap="nowrap">#qCareCharges.cDescription#</td>
				<td><input type="text" name="Amount_#qCareCharges.iCharge_ID#" VALUE="#NumberFormat(qCareCharges.mAmount,'9999999.99-')#" SIZE="7" style="text-align:right;' onBlur='this.value=cent(round(this.value))"></td>
				<td style='text-align:center;'>#DateFormat(qCareCharges.dteffectivestart,"mm/dd/yyyy")#</td>
				<td style='text-align:center;'>#DateFormat(qCareCharges.dteffectiveend,"mm/dd/yyyy")#</td>
				<cfif session.userid is 3271><td>#qCareCharges.iCharge_ID#</td></cfif>
				<td style='text-align:center;'>#iSPointsMin#</td>
				<td style='text-align:center;'>#iSPointsMax#</td>
				<!---<td style='text-align:center;'> #sldesc#</td>  12352 --->
			</tr>
			<cfset lastchargeset='#qCareCharges.cChargeSet#'>
		</cfloop>
	<cfelse>
		<script>document.forms[0].action="ResidentCareInsert.cfm"</script>
		<input type="hidden" name="typeids" value="#typeids#">
		<cfloop query="qhouseset">
			<cfquery name="qoldamount" dbtype="query">
			select caredesc, mamount from qLastCareCharges where caredesc = '#trim(qhouseset.cdescription)#'
			</cfquery>
			<cfif qhouseset.currentrow eq 1>
				<tr>
				<td colspan="2" style="background:##eaeaea;color:navy;text-align:center;">
				<b style="color:red;">Create Care Charges for the #qhouseset.csleveltypeset# level set </b> <br /> 
				<dd style="font-size:xx-small;"> <b>** pre-populated with 'last' assigned rates</b> </dd>
				</td>
				<td colspan="2" style="background:##eaeaea;color:navy;">
				Charge Set <input type="text" name="cChargeSet" size="10" value="">
				</td>
				</tr>
			</cfif>
			<tr>
				<td><input type="text" name="cdescription_#qhouseset.isleveltype_id#" value="Resident Care - Level #qhouseset.cDescription#" style="border:none;" readonly ></td>
				<td><input type="text" name="amount_#qhouseset.isleveltype_id#" value="#numberformat(qoldamount.mamount,'999.99')#" size="7" style="text-align:right;" onBlur="this.value=cent(round(this.value))"></td>
				<td style='text-align:center;'><input type="text" name="dteffectivestart_#qhouseset.isleveltype_id#" size="10" value="#DateFormat(now(),'mm/dd/yyyy')#" style="text-align:center;" onBlur="Dates(this);"></td>
				<td style='text-align:center;'><input type="text" name="dteffectiveend_#qhouseset.isleveltype_id#" size="10" value="#DateFormat(dateadd('yyyy',20,now()),'mm/dd/yyyy')#" style="text-align:center;" onBlur="Dates(this);"></td>
			</tr>
		</cfloop>
	</cfif>
	<tr>
		<td colspan="2" style='text-align: left;'><INPUT TYPE=button CLASS='SaveButton' NAME='Save' VALUE='Save' onClick='savecheck();'></td>
		<td colspan="2" style='text-align: right;'><INPUT TYPE=button CLASS='dontsavebutton' NAME='Cancel' VALUE='Cancel' onClick='cancelform();'></td>
	</tr>
</table>
<br>
<a href='menu.cfm'>Click Here to Go Back to the Administration Screen.</a>
</form>

<script>
	//set default values
	n = new Array(); v = new Array();
	for (i=0;i<=document.forms[0].elements.length-1;i++){ n[i] = document.forms[0].elements[i].name; v[i] = document.forms[0].elements[i].value;} 
	function detectchanges(){
		changesmade=0; 
		for (t=0;t<=document.forms[0].elements.length-1;t++){ if (n[t] == document.forms[0].elements[t].name && v[t] !== document.forms[0].elements[t].value) { changesmade = changesmade + 1; } }
		setTimeout("detectchanges()",200);
	}	
	detectchanges();
	window.onload=initialize;
</script>

</cfoutput>