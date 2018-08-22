<!----------------------------------------------------------------------------------------------
| DESCRIPTION  RoomAndBoardAdministration.cfm                                                  |
|----------------------------------------------------------------------------------------------|
|  File is entry point for administration of room and board rates                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   ResrictInput.cfm, header.cfm, househeader.cfm                                              |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 10/28/2005 | Added Flowerbox                                                    |
| ranklam    | 10/28/2005 | Renamed GUM link to #server_name#                                  |
| MLAW       | 12/08/2005 | Get cchargeset from house.cchargeset and replace the hard coded    |
| J Cruz     | 06/11/2008 | Removed several hard coded user id tests                           | 
----------------------------------------------------------------------------------------------->

<CFOUTPUT>

<!--- MLAW 12/08/2005 Get the cChargeSet value from the house table based on the house id --->
 <cfquery name="getHouseChargeset" datasource="tips4">
  select cs.CName from house h
  join chargeset cs
  on cs.iChargeSet_ID = h.iChargeSet_ID
  where ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
    and h.dtrowdeleted is null
</cfquery> 

<!--- Retrieve all resident care information for this house--->
<!--- J Cruz - 6/12/2008 - Removed hard coded user id references. --->
<CFQUERY NAME='qRBCharges' DATASOURCE='#APPLICATION.datasource#'>
	select C.*
	from charges c
	join chargetype ct on (ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null)
	where c.dtrowdeleted is null
	and c.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
	and ct.bSLevelType_ID is null  and bisrent is not null
	and c.iresidencytype_id <> 3
	and '#SESSION.TipsMonth#' < c.dteffectiveend 
	 and c.cchargeset = '#getHouseChargeset.CName#' 
	order by c.cchargeset, c.iresidencytype_id
</CFQUERY> <!--- and ct.bisdaily is not null --->

<!--- rsa - 10/28/2005 - chanegd link from gum to #server_name# --->
<LINK REL='Stylesheet' type='text/css' HREF='http://gum/intranet/tips4/shared/style2.css'>

<!--- Include shared javascript --->
<CFINCLUDE TEMPLATE='../Shared/JavaScript/ResrictInput.cfm'>

<SCRIPT>
	changesmade=0; 
	function savecheck(){ if (changesmade > 0) { document.forms[0].submit(); } else { alert('No Changes Detected'); } }
	function cancelform() { if (changesmade > 0) { location.reload(); } else { alert('No Changes Detected'); } }
</SCRIPT>

<!--- Include header file --->
<CFINCLUDE TEMPLATE='../../header.cfm'>

<!--- Include shared javascript --->
<CFINCLUDE TEMPLATE='../Shared/HouseHeader.cfm'>

<BR> <A HREF='menu.cfm'>Click Here to Go Back to the Administration Screen.</A> <BR>
<FORM ACTION='RoomAndBoardAdministrationUpdate.cfm' METHOD='POST'>
<TABLE>
	<TR><TH COLSPAN=100%>#SESSION.HouseName# Room & Board Administration #SESSION.TipsMonth#</TH></TR>
	<TR>
		<TD>Description</TD>
		<TD>Amount</TD>
		<TD STYLE='text-align:center;'>Effective Start Date</TD>
		<TD STYLE='text-align:center;'>Effective End Date</TD>
	</TR>
	<CFLOOP QUERY='qRBCharges'>
		<CFIF qRBCharges.currentrow neq 1 and  lastchargeset NEQ qRBCharges.cChargeSet>
			<TR><TH COLSPAN=100%>This Section is for the #qRBCharges.cChargeSet# ChargeSet </TH></TR>
		</CFIF>
		<TR>
			<TD>#qRBCharges.cDescription#</TD>
			<TD><INPUT TYPE=text NAME='Amount_#qRBCharges.iCharge_ID#' VALUE='#NumberFormat(qRBCharges.mAmount,'9999999.99-')#' SIZE=7 style='text-align:right;' onBlur='this.value=cent(round(this.value))'></TD>
			<TD STYLE='text-align:center;'>#DateFormat(qRBCharges.dteffectivestart,"mm/dd/yyyy")#</TD>
			<TD STYLE='text-align:center;'>#DateFormat(qRBCharges.dteffectiveend,"mm/dd/yyyy")#</TD>
		</TR>
		<CFSET lastchargeset='#qRBCharges.cChargeSet#'>
	</CFLOOP>
	<TR>
		<TD COLSPAN=2 STYLE='text-align: left;'><INPUT TYPE=button CLASS='SaveButton' NAME='Save' VALUE='Save' onClick='savecheck();'></TD>
		<TD COLSPAN=2 STYLE='text-align: right;'><INPUT TYPE=button CLASS='dontsavebutton' NAME='Cancel' VALUE='Cancel' onClick='cancelform();'></TD>
	</TR>
</TABLE>
<BR>
<A HREF='menu.cfm'>Click Here to Go Back to the Administration Screen.</A>
</FORM>

<SCRIPT>
	//set default values
	n = new Array(); v = new Array();
	for (i=0;i<=document.forms[0].elements.length-1;i++){ n[i] = document.forms[0].elements[i].name; v[i] = document.forms[0].elements[i].value;} 
	function detectchanges(){
		changesmade=0; 
		for (t=0;t<=document.forms[0].elements.length-1;t++){ if (n[t] == document.forms[0].elements[t].name && v[t] !== document.forms[0].elements[t].value) { changesmade = changesmade + 1; } }
		setTimeout("detectchanges()",200);
	}	
	detectchanges();
</SCRIPT>

</CFOUTPUT>