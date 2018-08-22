<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| Ganga    | 04/27/2012 | Created                                                              |
------------------------------------------------------------------------------------------------->

<cfparam name="url.added" default="">

<cfinclude template="js_ChargeMenu.cfm">
<td>
	<!--- Create a list of Diagnosis for the New Assessment --->
	Choose Diagnosis_1:<br>
	<span name="Diagnosis1" id="Diagnosis1" style="visibility:visible">
	<select name="iTenant_ID" onChange="show('charges');" onFocus="hide('charge')">
		<option value="">Please Choose Diagnosis...</option>
		<cfoutput query="TenantList"> 
		
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
		
		</cfoutput>
	</select>
	</span>
</td>	
<td>
	<!--- Create a list of Diagnosis_2 types --->
	<span name="Diagnosis2" id="Diagnosis2" style="visibility:hidden">
	Choose Diagnosis_2:<br>
	<select name="iChargeType_ID" onChange="PopulateChargeDropDown()" onFocus="PopulateChargeDropDown()">
		<cfoutput query="ChargeTypes">
		<option value="#iChargeType_ID#">#cDescription#</option> 
		</cfoutput>
	</select>
	</span>		
</td>
<td>
	<!--- Create a list of Diagnosis_3, this is dynamically built based on the Diagnosis_2 type selected --->
	<span name="Diagnosis3" id="Diagnosis3" style="visibility:hidden">
	Choose Diagnosis_3:<br>
	<select name="icharge_id">
	</select>
	</span>
</td>
<td>
	<!--- Create a list of Diagnosis_4, this is dynamically built based on the Diagnosis_3 type selected--->
	<span name="Diagnosis4" id="Diagnosis4" style="visibility:hidden">
	Choose Diagnosis_4:<br>
	<select name="icharge_id">
	</select>
	</span>
</td>
<td>
	<!--- Create a list of Diagnosis_5, this is dynamically built based on the Diagnosis_4 type selected --->
	<span name="Diagnosis5" id="Diagnosis5" style="visibility:hidden">
	Choose Diagnosis_5:<br>
	<select name="icharge_id">
	</select>
	</span>
</td>
<td>
	<!--- Create a list of Diagnosis_6, this is dynamically built based on the Diagnosis_5 type selected --->
	<span name="Diagnosis6" id="Diagnosis6" style="visibility:hidden">
	Choose Diagnosis_6:<br>
	<select name="icharge_id">
	</select>
	</span>
</td>
<td>
	<!--- Create a list of Diagnosis_7, this is dynamically built based on the Diagnosis_6 type selected --->
	<span name="Diagnosis7" id="Diagnosis7" style="visibility:hidden">
	Choose Diagnosis_7:<br>
	<select name="icharge_id">
	</select>
	<br>
	<input type="submit" value="Continue" onClick="return validatecharge();">
	</span>
</td>

<!--- if url.added is not an empty string call the scripts to show the charge type drop down menu and
      set the getchargesetfortenant --->
<cfif url.added neq "">
	<script language="javascript">
		show('dsp_NewAssessment');
	</script>
</cfif>




