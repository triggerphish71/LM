<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| RSchuette  | 08/26/2009 | Created                                                              |

------------------------------------------------------------------------------------------------->
<cfoutput>
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<CFINCLUDE TEMPLATE="../../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<!--- ==============================================================================
Include TIPS header for the House
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../Shared/HouseHeader.cfm"></br>
<script language="JavaScript" type="text/javascript">
	
		function Check1(){
		var Item = ChargesDisp.ChargeSelect.options[ChargesDisp.ChargeSelect.selectedIndex].text;
		if(Item == 'Select Item'){
		alert("Please select an invoice item.")
		return false;
		}
		return true;
		}
		
		function Check2(){
		var Item = DelChargesDisp.DelChargeSelect.options[DelChargesDisp.DelChargeSelect.selectedIndex].text;
		if(Item == 'Select Item'){
		alert("Please select an invoice item.")
		return false;
		}
		return true;
		}

</script>
	<cfquery name="GetResidentInfo" datasource="#APPLICATION.datasource#">
		select (t.cfirstname + ' ' + t.clastname) as Tenant from tenant t
		where t.cSolomonkey = '#form.TenantSelect#'
	</cfquery>
	<cfquery name="GetCharges" datasource="#APPLICATION.datasource#">
		select InvoiceDetail.iInvoiceDetail_id as 'Item_ID'
		,InvoiceDetail.iChargeType_id as 'Type_ID'
		,chargetype.cDescription as 'ct_Description'
		,InvoiceDetail.cAppliesToAcctPeriod As 'Period'
		,InvoiceDetail.iQuantity as 'Quantity'
		,InvoiceDetail.cDescription as 'Description'
		,InvoiceDetail.mAmount as 'Amount'
		from InvoiceDetail 
		join ChargeType on (chargetype.iChargeType_ID = invoicedetail.iChargeType_ID)
		where InvoiceDetail.iInvoiceMaster_ID in (
			select max(iinvoicemaster_id)
			from InvoiceMaster 
			where InvoiceMaster.cSolomonKey = '#form.TenantSelect#'
			and InvoiceMaster.bFinalized is null
			and InvoiceMaster.dtRowDeleted is null
			and InvoiceMaster.iInvoiceMaster_ID > (
				select max(iinvoicemaster_id)
				from InvoiceMaster 
				where InvoiceMaster.cSolomonKey = '#form.TenantSelect#'
				and InvoiceMaster.bFinalized = 1
				and InvoiceMaster.dtRowDeleted is null
				)
			)
		and InvoiceDetail.dtRowDeleted is null
	</cfquery>
	<cfset Ccount = GetCharges.recordcount>
	
	<cfquery name="GetDelCharges" datasource="#APPLICATION.datasource#">
		select InvoiceDetail.iInvoiceDetail_id as 'Item_ID'
		,InvoiceDetail.iChargeType_id as 'Type_ID'
		,chargetype.cDescription as 'ct_Description'
		,InvoiceDetail.cAppliesToAcctPeriod As 'Period'
		,InvoiceDetail.iQuantity as 'Quantity'
		,InvoiceDetail.cDescription as 'Description'
		,InvoiceDetail.mAmount as 'Amount'
		from InvoiceDetail 
		join ChargeType on (chargetype.iChargeType_ID = invoicedetail.iChargeType_ID)
		where InvoiceDetail.iInvoiceMaster_ID in (
			select max(iinvoicemaster_id) as Iid 
			from InvoiceMaster 
			where InvoiceMaster.cSolomonKey = '#form.TenantSelect#'
			and InvoiceMaster.bFinalized is null
			and InvoiceMaster.dtRowDeleted is null
			and InvoiceMaster.iInvoiceMaster_ID > (
				select max(iinvoicemaster_id) as Iid 
				from InvoiceMaster 
				where InvoiceMaster.cSolomonKey = '#form.TenantSelect#'
				and InvoiceMaster.bFinalized = 1
				and InvoiceMaster.dtRowDeleted is null
				)
			)
		and InvoiceDetail.dtRowDeleted is not null
	</cfquery>
	<cfset DCcount = GetDelCharges.recordcount>


<A Href="../InvoiceAdmin.cfm" style="Font-size: 18;">Choose New Resident</a>
</br></br>
#GetResidentInfo.Tenant# - Invoice Details
	<form name="ChargesDisp" action="act_DelInvoiceCharge.cfm?ID=#'ChargeSelect'#" method="POST">
	<cfif Ccount eq 0>
		There is no charge active on this invoice.
	<cfelse>
		<cftable query="GetCharges" colheaders="yes" border="yes" maxrows="#Ccount#" startrow="1" htmltable="yes" >
			<cfcol header="<b>Item ID</b>" align="center" width=15 text="#Item_ID#">
			<cfcol header="<b>Type ID</b>" align="center" width=12 text="#Type_ID#">
			<cfcol header="<b>Period</b>" align="center" width=13 text="#Period#">
			<cfcol header="<b>Description</b>" align="center" width=45 text="#Description#">
			<cfcol header="<b>Quantity</b>" align="center" width=15 text="#Quantity#">
			<cfcol header="<b>Amount</b>" align="right" width=40 text="#dollarFormat(Amount)#">
		</cftable></br>
		<table><tr>
				<td>
				<select name="ChargeSelect"> 
				  <option>Select Item</option>
					<cfloop query="GetCharges">
						<option value="#GetCharges.Item_ID#" > #GetCharges.Item_ID# - #GetCharges.Description#</option> 					
					</cfloop>
				</select>
				</td>
				<td>
					<CFIF ListContains(SESSION.groupid, '1')>
					<input type="submit" name="Delete" value="Delete" onclick="return Check1();">
					</cfif> 
				</td>
		</tr></table>
	</cfif>
	</form>
	</br></br>
#GetResidentInfo.Tenant# - Invoice Details Deleted Items
<form name="DelChargesDisp" action="act_UnDelInvoiceCharge.cfm?ID=#'ChargeSelect'#" method="POST">
	<cfif DCcount eq 0>
		There are no deleted items with this invoice.
	<cfelse>
		<cftable query="GetDelCharges" colheaders="yes" border="yes" maxrows="#DCcount#" startrow="1" htmltable="yes" >
			<cfcol header="<b>Item ID</b>" align="center" width=15 text="#Item_ID#">
			<cfcol header="<b>Type ID</b>" align="center" width=12 text="#Type_ID#">
			<cfcol header="<b>Period</b>" align="center" width=13 text="#Period#">
			<cfcol header="<b>Description</b>" align="center" width=45 text="#Description#">
			<cfcol header="<b>Quantity</b>" align="center" width=15 text="#Quantity#">
			<cfcol header="<b>Amount</b>" align="right" width=40 text="#dollarFormat(Amount)#">
		</cftable></br>
		<table><tr>
				<td>
				<select name="DelChargeSelect"> 
				  <option>Select Item</option>
					<cfloop query="GetDelCharges"><!--- <cfloop query="Available"> Not using total house apts--->
						<option value="#GetDelCharges.Item_ID#" > #GetDelCharges.Item_ID# - #GetDelCharges.Description#</option> 					
					</cfloop>
				</select>
				</td>
				<td>
					<CFIF ListContains(SESSION.groupid, '1')>
					<input type="submit" name="UnDelete" value="UnDelete" onclick="return Check2();">
					</cfif> 
				</td>
		</tr></table>
	</cfif>
</form>
</br></br>
<A Href="../../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
<CFINCLUDE TEMPLATE='../../../Footer.cfm'>
</cfoutput>