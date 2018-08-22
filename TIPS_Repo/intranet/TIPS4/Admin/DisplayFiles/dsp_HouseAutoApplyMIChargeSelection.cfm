<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| RSchuette  | 01/19/2010 | Created  - Select Charge for MI Auto Apply to Ruccuring              |
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

<CFINCLUDE TEMPLATE="../../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Move-In Charge Selection </H1>

<!--- ==============================================================================
Include TIPS header for the House
=============================================================================== 
NOT NEEDED:
<CFINCLUDE TEMPLATE="../../Shared/HouseHeader.cfm"></br>--->
<script language="JavaScript" type="text/javascript">
		<!--- function getdata(){
		<cfinclude template="ActionFiles/act_GetInvoiceDetails.cfm">
		} --->
			function Check(){
			var Charge = DisplayChargeTypes.ChargeSelect.options[DisplayChargeTypes.ChargeSelect.selectedIndex].text;
			if(Charge == 'ID - Description - GLCode'){
			alert("Please select a Charge.")
			return false;
			}
			return true;
			}
	
	</script> 
	<cfquery  name="GetChargesApplicable" datasource="#APPLICATION.datasource#">
		select * from ChargeType 
		where ChargeType.dtRowDeleted is null
		
	</cfquery>
	
	<form name="DisplayChargeTypes" action="dsp_HouseAutoApplyMICharge.cfm?ID=#'ChargeSelect'#" method="POST">
		<table>
			<tr><td>
			Please select a charge from the dropdown:
			</td></tr>
			<tr>
				<td>
					<select name="ChargeSelect">
					<option>ID - Description - GLCode</option>
						<cfloop query="GetChargesApplicable">
							<option value="#GetChargesApplicable.iChargeType_ID#">
								#GetChargesApplicable.iChargeType_ID# - #GetChargesApplicable.cDescription# - #GetChargesApplicable.cGLAccount#
							</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="submit" name="GetInfo" value="Get Info" onclick="return Check();"> 
				</td>
			</tr>
		</table>
	
	
	
	</form>
	
	</cfoutput>
