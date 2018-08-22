<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| RSchuette  | 01/20/2010 | Created  - Select House Charge for MI Auto Apply to Ruccuring        |
|							for all new tenants													 |
|							Created Page + code for #35227										 |
------------------------------------------------------------------------------------------------->


<cfoutput>
<CFIF NOT IsDefined("SESSION.USERID") 
		OR SESSION.UserId EQ "" 
		OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") 
		OR SESSION.qSelectedHouse.iHouse_ID EQ ""
		OR not listcontains(session.groupid,'285')> <!--- 285 ARMasterAdmin in prod --->
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>
<cfquery name="GetChargeInformation" datasource="#APPLICATION.datasource#">
	select * from chargetype where iChargeType_id = '#form.chargeselect#'
</cfquery>
<cfquery name="GetHouses" datasource="#APPLICATION.datasource#">
	select h.*,cs.cName as 'cChargeSet'
	from House h 
	join ChargeSet cs on (cs.iChargeSet_ID = h.iChargeSet_ID)  
	where h.dtRowDeleted is null and h.iHouse_id not in (200,52) order by h.cName
</cfquery>

<cfset session.cid = GetChargeInformation.iChargeType_ID>


<CFINCLUDE TEMPLATE="../../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Move-In Charge Selection </H1>

<a href="dsp_HouseAutoApplyMIChargeSelection.cfm">Choose New Charge</a></br></br>
<form name="DCStatus" action="../ActionFiles/act_UpdateAutoApplyMICharge.cfm" method="post">
	
	
<TABLE>
	<tr><th colspan="4" style="center">
		Apply Charge To All New Move In's at Selected Houses
	</th></tr>
	<tr><td colspan="4" align="center" style="border:bottom">
		<b><u>#GetChargeInformation.cdescription#</u></b>
	</td></tr>
	<tr></tr>			
		<tr>
			<td><b>CheckBox</b></td>
			<td><b>House Name</b></td>
			<td><b>House Charge Set</b></td>
			<td><b>Amount</b></td>
		</tr>
	<cfloop query="GetHouses">
		<cfquery name="GetHouseCharge" datasource="#APPLICATION.datasource#">
			Select c.*,cs.cname as 'cHouseChargeSet'
			from Charges c
			join House h on (h.iHouse_ID = c.iHouse_ID)
			join ChargeSet cs on (cs.iChargeSet_ID = h.iChargeSet_ID)
			where c.iHouse_ID = '#GetHouses.iHouse_ID#'
			and c.iChargeType_ID = '#GetChargeInformation.iChargeType_ID#'
			and c.dtRowDeleted is null
			and cs.cName = c.cChargeSet
		</cfquery>
		
		
		<cfif GetHouseCharge.RecordCount eq 0>
			<tr>
				<td></td>
				<td>#GetHouses.cName#</td>
				<td>#GetHouses.cChargeSet#</td>
				<td>No Charge</td>
			</tr>
		<cfelseif GetHouseCharge.RecordCount eq 1>
			<cfif GetHouseCharge.bIsMoveInCharge EQ 1><cfset Checked='Checked'><cfelse><cfset Checked=''></cfif>
			<tr>
				<td><input type="checkbox" name="cboInclude_#GetHouses.iHouse_ID#" value="1" #Checked#></td>
				<td>#GetHouses.cName#</td>
				<td>#GetHouses.cChargeSet#</td>
				<!--- <input type="hidden" name="hChargeset_#GetHouses.iHouse_ID#" value="#GetHouses.cChargeSet#"> --->
				<td>#GetHouseCharge.mAmount#</td>
			</tr>
		<cfelseif GetHouseCharge.RecordCount gt 1>
			<tr>
				<td></td>
				<td>#GetHouses.cName#</td>
				<td>#GetHouses.cChargeSet#</td>
				<td>More Than One</td>
			</tr>
		</cfif>
	</cfloop>
	<tr></tr>
	<tr><td><INPUT TYPE="submit" NAME="save" VALUE="Save" CLASS="SaveButton" onmouseover="" onfocus =""></td></tr>
</TABLE>
</form>


</cfoutput>