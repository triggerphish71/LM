<cfinclude template="../../../header.cfm">
<title>TIPS4 - Medicaid House Setup & Maintenance</title>
</head>
<cfquery name="qryMedicaidHouse"  DATASOURCE="#APPLICATION.datasource#">
select * 
from house h
Join StateCode st on h.cStateCode = st.cstatecode
left join  housemedicaid hm on h.ihouse_id = hm.ihouse_id
where h.ihouse_id = #ihouse_id#
</cfquery>
	<cfquery name="getHouseChargeset" datasource="#application.datasource#">
	  select cs.CName from house h
	  join chargeset cs
	  on cs.iChargeSet_ID = h.iChargeSet_ID
	  where ihouse_id = #session.qSelectedHouse.iHouse_ID#
	  and h.dtrowdeleted is null
	</cfquery>
	<cfquery name="qryCharge8" datasource="#application.datasource#">
	  select mamount from charges
	  where ichargetype_id = 8
	  and cchargeset = '#getHouseChargeset.CName#'
	  and ihouse_id = #session.qSelectedHouse.iHouse_ID#
	  and dtrowdeleted is null
	</cfquery>
	<cfquery name="qryCharge31" datasource="#application.datasource#">
	  select mamount from charges
	  where ichargetype_id = 31
	  and cchargeset = '#getHouseChargeset.CName#'
	  and ihouse_id = #session.qSelectedHouse.iHouse_ID#
	  and dtrowdeleted is null
	</cfquery>	
	<cfquery name="qryCharge1661" datasource="#application.datasource#">
	  select mamount from charges
	  where ichargetype_id = 1661
	  and cchargeset = '#getHouseChargeset.CName#'
	  and ihouse_id = #session.qSelectedHouse.iHouse_ID#
	  and dtrowdeleted is null
	</cfquery>	
<script >
function upd8recd(thisval){
housemedicaidsetup.CRmStateMedicaidAmt_BSF_Daily.value = thisval;
}
function upd31recd(thisval){
housemedicaidsetup.CRmMedicaidBSF.value = thisval;
}
function upd1661recd(thisval){
housemedicaidsetup.CRmMedicaidCopay.value = thisval;
}
</script>   
<body>
<h1 class="PageTitle"><cfoutput> Tips 4 - Medicaid House Setup - #qryMedicaidHouse.cStateName#</cfoutput></h1>
<form name="housemedicaidsetup" id="housemedicaidsetup" method="post" action="MedicaidHouseAdd.cfm"> 
<table width="100%">
<cfoutput>
<input type="hidden" name="ihouse_id" value="#ihouse_id#" id="ihouse_id">
<input type="hidden" name="cchargeset" value="#getHouseChargeset.CName#" id="cchargeset">
</cfoutput>
<cfif qryMedicaidHouse.iHouseMedicaid_ID is ''>
<input type="hidden" name="entrytype" value="new">
		<cfoutput query="qryMedicaidHouse">
			<tr style=" background-color:##FFFF99; ">
				<td colspan="5" style="text-align:center">Add Medicaid Information for #cname# - #cStateName#</td>
			</tr>
			<tr style=" background-color:##FFFF99; ">
				<td colspan="5" style="text-align:center">House Record Amounts</td>
			</tr>
			<tr style="background-color:##FFFFCC">
				<td>State Medicaid Amt BSF Daily</td>
				<td>&nbsp;<!--- State Medicaid Amt BSF Monthly ---></td>
				<td>Medicaid BSF</td>
				<td>Medicaid Copay</td>
				<td>&nbsp;</td>
	 		</tr>
			<tr>
				<td>
					$<input type="text" value="" name="mStateMedicaidAmt_BSF_Daily" id="mStateMedicaidAmt_BSF_Daily" >
				</td>
				<td>&nbsp;
				<!--- <input type="text" value="#mStateMedicaidAmt_BSF_Monthly#"  name="mStateMedicaidAmt_BSF_Monthly" id="mStateMedicaidAmt_BSF_Monthly">  --->
				</td>
				<td>
					$<input type="text" value=""  name="mMedicaidBSF" id="mMedicaidBSF">
				</td>
				<td>
					$<input type="text" value=""  name="mMedicaidCopay" id="mMedicaidCopay">
				</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td colspan="5">Charge Record Amounts</td>
			</tr>
			<tr style="background-color:##FFFFCC">
				<td>State Medicaid Amt BSF Daily</td>
				<td>&nbsp;<!--- State Medicaid Amt BSF Monthly ---></td>
				<td>Medicaid BSF</td>
				<td>Medicaid Copay</td>
				<td>&nbsp;</td>
	 		</tr>
			<tr>
				<td>
					$<input type="text" value="" name="mStateMedicaidAmt_BSF_Daily" id="mStateMedicaidAmt_BSF_Daily" >
				</td>
				<td>&nbsp;
				<!--- <input type="text" value="#mStateMedicaidAmt_BSF_Monthly#"  name="mStateMedicaidAmt_BSF_Monthly" id="mStateMedicaidAmt_BSF_Monthly">  --->
				</td>
				<td>
					$<input type="text" value=""  name="mMedicaidBSF" id="mMedicaidBSF">
				</td>
				<td>
					$<input type="text" value=""  name="mMedicaidCopay" id="mMedicaidCopay">
				</td>
				<td>&nbsp;</td>
			</tr>			
<!--- 			<tr style="background-color:##66CCCC">
				<td colspan="5"  style="text-align:center; font-weight:bold;  color:##FF0000">This section IS NOT used for all States</td>
			</tr>
			<tr style="background-color:##66CCCC">
				<td>State Acuity</td>
				<td>Medicaid Level Low</td>
				<td>Medicaid Level Medium</td>
				<td>Medicaid Level High</td>
				<td>Comments</td>			
			</tr>
			<tr style="background-color:##66CCCC">
				<td>
					<input type="text" value=""  name="cStateAcuity" id="cStateAcuity">
				</td>
				<td>
					<input type="text" value=""  name="cMedicaidLevelLow" id="cMedicaidLevelLow">
				</td>
				<td>
					<input type="text" value=""  name="cMedicaidLevelMedium" id="cMedicaidLevelMedium">
				</td>
				<td>
					<input type="text" value=""  name="cMedicaidLevelHigh" id="cMedicaidLevelHigh">
				</td>
				<td>
					<input type="text" value=""  name="cComments" id="cComments">
				</td>
			 </tr> --->			
		</cfoutput>
 
<cfelse>
<input type="hidden" name="entrytype" value="update"> 
		<cfoutput query="qryMedicaidHouse">
			<tr >
				<td colspan="5" style="text-align:center; background-color:##FFFF99;">Update Medicaid Information for #cname# - #cStateName#</td>
			</tr>
			<tr >
				<td colspan="5" style="text-align:center; background-color:##FFFF99;">House Default Amounts</td>
			</tr>
			<tr style="background-color:##FFFFCC">
				<td nowrap="nowrap">State Medicaid Amt BSF Daily</td>
				<td>&nbsp;<!--- State Medicaid Amt BSF Monthly ---></td>
				<td>Medicaid BSF</td>
				<td>Medicaid Copay</td>
				<td>&nbsp;</td>

	 		</tr>
			<tr>
				<td>
					<input type="text" value="#dollarformat(mStateMedicaidAmt_BSF_Daily)#" 
					name="mStateMedicaidAmt_BSF_Daily" 
					id="mStateMedicaidAmt_BSF_Daily" onChange="upd8recd(this.value);" >
				</td>
				<td>&nbsp;
				<!--- <input type="text" value="#mStateMedicaidAmt_BSF_Monthly#"  name="mStateMedicaidAmt_BSF_Monthly" id="mStateMedicaidAmt_BSF_Monthly">  --->
				</td>
				<td>
					<input type="text" value="#dollarformat(mMedicaidBSF)#"  name="mMedicaidBSF" id="mMedicaidBSF" 
					onChange="upd31recd(this.value);">
				</td>
				<td>
					<input type="text" value="#dollarformat(mMedicaidCopay)#"  name="mMedicaidCopay" id="mMedicaidCopay" 
					onChange="upd1661recd(this.value);">
				</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td colspan="5"  style="text-align:center">Charge Record Amounts</td>
			</tr>
			<tr style="background-color:##FFFFCC">
				<td>State Medicaid Amt BSF Daily</td>
				<td>&nbsp;<!--- State Medicaid Amt BSF Monthly ---></td>
				<td>Medicaid BSF</td>
				<td>Medicaid Copay</td>
				<td>&nbsp;</td>
	 		</tr>
			<tr>
				<td>
					<input type="text" value="#dollarformat(qryCharge8.mamount)#" name="CRmStateMedicaidAmt_BSF_Daily" 
					id="CRmStateMedicaidAmt_BSF_Daily" >
				</td>
				<td>&nbsp;
				<!--- <input type="text" value="#mStateMedicaidAmt_BSF_Monthly#"  name="mStateMedicaidAmt_BSF_Monthly"  id="mStateMedicaidAmt_BSF_Monthly">  --->
				</td>
				<td>
					<input type="text" value="#dollarformat(qryCharge31.mamount)#"  name="CRmMedicaidBSF" id="CRmMedicaidBSF"> 
				</td>
				<td>
					<input type="text" value="#dollarformat(qryCharge1661.mamount)#"  name="CRmMedicaidCopay" id="CRmMedicaidCopay">
				</td>
				<td>&nbsp;</td>
			</tr>			
<!--- 			<cfif qryMedicaidHouse.cStateCode is not 'NJ'>
			<tr style="background-color:##66CCCC">
				<td colspan="5"  style="text-align:center; font-weight:bold;  color:##FF0000">This section IS NOT used for all States</td>
			</tr>
			<tr style="background-color:##66CCCC; border-color:##66CCCC; ">
				<td>State Acuity</td>
				<td>Medicaid Level Low</td>
				<td>Medicaid Level Medium</td>
				<td>Medicaid Level High</td>
				<td>Comments</td>			
			</tr>
			<tr style="background-color:##66CCCC; border-color:##66CCCC;">
				<td>
					<input type="text" value="#cStateAcuity#"  name="cStateAcuity" id="cStateAcuity">
				</td>
				<td>
					<input type="text" value="#cMedicaidLevelLow#"  name="cMedicaidLevelLow" id="cMedicaidLevelLow">
				</td>
				<td>
					<input type="text" value="#cMedicaidLevelMedium#"  name="cMedicaidLevelMedium" id="cMedicaidLevelMedium">
				</td>
				<td>
					<input type="text" value="#cMedicaidLevelHigh#"  name="cMedicaidLevelHigh" id="cMedicaidLevelHigh">
				</td>
			 </tr>

			<tr>
				<td>
					<input type="text" value="#cComments#"  name="cComments" id="cComments">
				</td>
			 </tr>
			</cfif> --->
 		</cfoutput>	
 
</cfif>
 
	<cfoutput>
		<tr style=" background-color: ##66FF66">
			<td colspan="5" style="text-align:center"><input type="submit" name="Submit" value="Update"></td>
		</tr>
	</cfoutput>
 		<tr>
			<td><a href="MedicaidHouseSelect.cfm">Return to House Select</a></td>
		</tr>
</table>
</form>
<!---
---------------------------------------------------------------------------------
medicaid charge is being calculated by using mamount in charge table, if the rates
in charges table not updated, system will calculate the invoice based on charge 
table. updating the charges table with the set rate on admin tab will resolve that
start here------------------------------------------------------------------
--->

<!---   <cfif isdefined("form.submit")>  
	<cfquery name="getHouseChargeset" datasource="#application.datasource#">
	  select cs.CName from house h
	  join chargeset cs
	  on cs.iChargeSet_ID = h.iChargeSet_ID
	  where ihouse_id = #session.qSelectedHouse.iHouse_ID#
	  and h.dtrowdeleted is null
	</cfquery>
 	<cfif #qryMedicaidHouse.mStateMedicaidAmt_BSF_Daily# NEQ ''>
	<cfquery name="updatestatemedicaid" datasource="#APPLICATION.datasource#" result="updatestatemedicaid">
		Update charges
		set mamount= #qryMedicaidHouse.mStateMedicaidAmt_BSF_Daily#
		where cchargeset ='#getHouseChargeset.CName#'
		and dtrowdeleted is null 
		and ihouse_ID = #qryMedicaidHouse.ihouse_ID#
		and ichargetype_ID in (8)
	 </cfquery>
	<cfdump var="#updatestatemedicaid#">  
  </cfif> 
	
 <cfif #qryMedicaidHouse.mMedicaidBSF# NEQ ''>  
 	<cfquery name="updateMedicaidBSF" datasource="#APPLICATION.datasource#" result="updateMedicaidBSF">
		Update charges
		set mamount= #qryMedicaidHouse.mMedicaidBSF#
		where cchargeset ='#getHouseChargeset.CName#'
		and dtrowdeleted is null 
		and ihouse_ID = #qryMedicaidHouse.ihouse_ID#
		and ichargetype_ID in (31)
	 </cfquery> 
 	<cfdump var="#updateMedicaidBSF#">
	</cfif> 
	 
 	<cfif #qryMedicaidHouse.mMedicaidCopay# NEQ ''>
	<cfquery name="updateMedicaidcopay" datasource="#APPLICATION.datasource#" result="updateMedicaidcopay">
		Update charges
		set mamount= #qryMedicaidHouse.mMedicaidCopay#
		where cchargeset ='#getHouseChargeset.CName#'
		and dtrowdeleted is null 
		and ihouse_ID = #qryMedicaidHouse.ihouse_ID#
		and ichargetype_ID in (1661)
	 </cfquery>
	<cfdump var="#updateMedicaidcopay#">
	</cfif>  
 </cfif> --->  
 
 <!---
<cfoutput> #qryMedicaidHouse.mStateMedicaidAmt_BSF_Daily# #qryMedicaidHouse.mMedicaidBSF# #qryMedicaidHouse.mMedicaidCopay#</cfoutput>---> 
<!--- updating the charges table end--->
  <!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">