<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| ranklam    | 08/25/2005 | Created                                                              |
------------------------------------------------------------------------------------------------->

<cfparam name="url.added" default="">

<cfinclude template="js_ChargeMenu.cfm">
<td>
	<!--- Create a list of tenants for this house --->
	Choose Resident:<br>
	<span name="residents" id="residents" style="visibility:visible">
	<select name="iTenant_ID" onChange="show('charges');" onFocus="hide('charge')">
		<option value="">Please Choose Resident...</option>
		<cfoutput query="TenantList"> 
		<!--- 25575 - RTS - If respite resident does not have an active unfinalized invoice, do not show. --->
		<cfif TenantList.iResidencyType_ID eq 3>
			<cfquery name="RespiteInvoiceCheck" DATASOURCE="#APPLICATION.datasource#">
				select iInvoiceMaster_ID from InvoiceMaster
				where iInvoiceMaster_ID in (
					select max(im.iInvoiceMaster_ID) 
					from InvoiceMaster im
					join tenant t on (t.cSolomonKey = im.cSolomonKey and t.cSolomonKey =  #TenantList.cSolomonKey#)
					where im.dtRowDeleted is null
					and t.iTenant_ID = #TenantList.iTenant_ID# 
					and im.bFinalized is null
					and IM.dtRowDeleted is null	)			 
			</cfquery>
			<cfif RespiteInvoiceCheck.RecordCount gt 0>
				<option value="#iTenant_ID#" <cfif url.added eq iTenant_ID>SELECTED</cfif>>#TenantList.cLastName#, #TenantList.cFirstname# (#TenantList.cSolomonkey#)	</option>
			</cfif>
		<cfelse>
		<option value="#iTenant_ID#" <cfif url.added eq iTenant_ID>SELECTED</cfif>>#TenantList.cLastName#, #TenantList.cFirstname# (#TenantList.cSolomonkey#)	</option> 
		</cfif>
		<!--- end 25575 --->
		</cfoutput>
	</select>
	</span>
</td>	
<td>
	<!--- Create a list of charge types --->
	<span name="charges" id="charges" >
	Please choose a transaction type:<br>
	<select name="iChargeType_ID" onChange="PopulateChargeDropDown()" onFocus="PopulateChargeDropDown()">
		<cfoutput query="ChargeTypes">
		<option value="#iChargeType_ID#">#cDescription#</option> 
		</cfoutput>
	</select>
	</span>		
</td>

<td>
	<!--- Create a list of charges, this is dynamically built based on the charge type selected --->
	<span name="charge" id="charge" >
	Choose Charge:<br>
	<select name="icharge_id">
	test
	</select>
	<br>
	<input type="submit" value="Continue" onClick="return validatecharge();">
	</span>
</td>


<!--- if url.added is not an empty string call the scripts to show the charge type drop down menu and
      set the getchargesetfortenant --->
<cfif url.added neq "">
	<script language="javascript">
		show('charges');
	</script>
</cfif>




