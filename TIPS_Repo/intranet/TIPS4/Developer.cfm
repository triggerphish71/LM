
<cfoutput>
<div id='area'>
<!--- include Intrante Header --->
<cfinclude template="../header.cfm">
<link rel=StyleSheet type="Text/css" href="//#server_name#/intranet/Tips4/Shared/Style2.css">
<style>td {font-size:xx-small;}</style>

<cfif isDefined("url.Sol_ID")> <cfset form.InvoicecSolomonKey = url.Sol_ID> </cfif>
<cfif isDefined("form.cSolomonKey")><cfset form.InvoicecSolomonKey = form.cSolomonKey></cfif>
<cfif isDefined("form.InvoicecSolomonKey")><cfset form.cSolomonKey = form.InvoicecSolomonKey></cfif>

<cfif isDefined("iTenant_ID")>
	<cfquery name="qBalances" datasource="TIPS4">
		select	distinct im.iInvoiceMaster_ID, im.cAppliesToAcctPeriod, im.mLastInvoiceTotal, im.mInvoiceTotal, im.bMoveInInvoice, im.bMoveOutInvoice, 
			im.bFinalized, im.dtInvoiceStart, im.dtInvoiceEnd, im.dtRowStart, im.dtRowEnd, im.cComments, im.iinvoicenumber, im.cSolomonKey, im.iRowStartUser_id
			,im.dtrowstart
		from InvoiceMaster im
		join InvoiceDetail inv on (inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID and inv.dtRowDeleted is null)
		where	im.dtRowDeleted is null and inv.iTenant_ID = #iTenant_ID#
		order by  im.cAppliesToAcctPeriod
	</cfquery>
	<cfquery name="qDetails" datasource="TIPS4">
		select isNull(inv.iinvoicemaster_id,0) as iinvoicemaster_id, ct.cglaccount, inv.*
		from InvoiceDetail inv
		join invoicemaster im on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID and im.dtRowDeleted is null
		join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and isnull(ct.dtrowdeleted, isnull(im.dtInvoiceEnd, getDate())) >= isnull(im.dtInvoiceEnd, getDate())
		where inv.dtRowDeleted is null and iTenant_ID = #iTenant_ID#
		and inv.mamount is not null and inv.iquantity is not null
		order by inv.iInvoiceMaster_ID
	</cfquery>
</cfif>

<cfif isDefined("form.InvoicecSolomonKey") or isDefined("form.InvoiceLikeSolomonKey")>
	<cfquery name="qBalances" datasource="TIPS4">
		select	iInvoiceMaster_ID, cAppliesToAcctPeriod, mLastInvoiceTotal, mInvoiceTotal, bMoveInInvoice, bMoveOutInvoice, 
				bFinalized, dtInvoiceStart, dtInvoiceEnd, dtRowStart, dtRowEnd, cComments, iinvoicenumber, cSolomonKey, iRowStartUser_id
		from	InvoiceMaster
		where	dtRowDeleted is null
		<cfif isDefined("form.InvoicecSolomonKey")>and cSolomonKey = '#form.InvoicecSolomonKey#'</cfif>
		<cfif isDefined("form.InvoiceLikeSolomonKey")>and cSolomonKey like '#form.InvoiceLikeSolomonKey#'</cfif>
		order by cAppliesToAcctPeriod, 
				isnull(bMoveInInvoice, 0) desc, 
				cast(isnull(bMoveInInvoice,0) as int) + cast(isnull(bMoveOutInvoice, 0) as int) desc, 
				isnull(bMoveOutInvoice, 2) desc, dtinvoicestart
	</cfquery>	
	<cfset form.cSolomonKey = '#trim(qBalances.cSolomonKey)#'>
	
	<cfquery name="qDetails" datasource="TIPS4">
		select ct.cGLAccount, inv.*
		from InvoiceDetail inv
		join invoicemaster im on im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID and im.dtRowDeleted is null
		join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and isnull(ct.dtrowdeleted, isnull(im.dtInvoiceEnd, getDate())) >= isnull(im.dtInvoiceEnd, getDate())
		where inv.dtRowDeleted is null and im.cSolomonKey = '#trim(qBalances.cSolomonKey)#' order by inv.iInvoiceMaster_ID
	</cfquery>	
</cfif>

<cfif isDefined("qDetails")>
	<script>
		function showdetails(string){
<cfloop query="qDetails"> qd#qDetails.iInvoiceMaster_ID#="<table><tr><th>Detail</th><th>Master</th><th>TID</th><th>CType</th><th>GL</th><th>Per</th><th>Adj</th><th>dtTrx</th><th>Qty</th><th>Descr</th><th>Amt</th><th>extended</th><th>comm.</th><th>AcctStmp</th><th>stUser</th><th>dtStart</th></tr>"; </cfloop>
<cfloop query="qDetails">
		qd#qDetails.iInvoiceMaster_ID#+="<tr><td>#qDetails.iInvoiceDetail_ID#</td><td>#qDetails.iInvoiceMaster_ID#</td><td style='font-size:10;'>#qDetails.iTenant_ID#</td><td>#qDetails.iChargeType_ID#</td><td>#qDetails.cglaccount#</td>";
		qd#qDetails.iInvoiceMaster_ID#+="<td>#qDetails.cAppliesToAcctPeriod#</td><td>#qDetails.bIsRentAdj#</td><td>#qDetails.dtTransaction#</td><td>#qDetails.iQuantity#</td><td>#qDetails.cDescription#</td><td>#LSCurrencyFormat(qDetails.mAmount)#</td><td><cfif qDetails.mAmount EQ "" or qDetails.iQuantity EQ "">NULL<cfelse>#LSCurrencyFormat(evaluate(qDetails.mAmount*qDetails.iquantity))#</cfif></td><td>#JSStringFormat(trim(qDetails.cComments))#</td><td>#qDetails.dtAcctStamp#</td><td>#qDetails.iRowStartUser_ID#</td><td>#qDetails.dtRowStart#</td></tr>"; 
</cfloop>
<cfloop query="qDetails"> qd#qDetails.iInvoiceMaster_ID#+="</table>"; </cfloop>			
			<cfloop query="qBalances">
				if (string == #qBalances.iInvoiceMaster_ID#){ 
					if ( document.all['detailsarea#qBalances.iInvoiceMaster_ID#'].style.display == "none" ) { 
						document.all['detailsarea#qBalances.iInvoiceMaster_ID#'].innerHTML=qd#qBalances.iInvoiceMaster_ID#; 
						document.all['detailsarea#qBalances.iInvoiceMaster_ID#'].style.display="inline";
					}
					else { document.all['detailsarea#qBalances.iInvoiceMaster_ID#'].style.display="none"; }
				}
			</cfloop>
			resizewindow();
		}
	</script>
</cfif>


<cfif isDefined("LastName") or isDefined("iTenant_ID") or isDefined("cSolomonKey")>
	<cfquery name="qTenant" datasource="TIPS4">
	select *, t.cbillingtype
	from Tenant T (NOLOCK)
	join TenantState TS (NOLOCK) on (TS.iTenant_ID = T.iTenant_ID and TS.dtrowdeleted is null)
	join house H on (T.iHouse_ID = H.iHouse_ID and H.dtRowDeleted is null)
	where T.dtRowDeleted is null
	<cfif isDefined("form.iTenant_ID")>and t.iTenant_ID = #form.iTenant_ID#</cfif>
	<cfif isDefined("form.cSolomonKey")>and t.cSolomonkey = '#trim(form.cSolomonKey)#'</cfif>
	<cfif isDefined("form.LastName")>and t.cLastName like '%#form.LastName#%'</cfif>
	<cfif isDefined("form.LastName")>and t.cLastName like '%#form.LastName#%'</cfif>
	</cfquery>
</cfif>

<cfif isDefined("form.HouseName") or isDefined("form.iHouse_ID") or isDefined("form.HouseNumber")>
	<cfquery name="qHouse" datasource="TIPS4">
		select iHouse_ID, cName, cNumber from House (NOLOCK) where dtRowDeleted is null
		<cfif isDefined("form.iHouse_ID")>and iHouse_ID = #form.iHouse_ID#</cfif>
		<cfif isDefined("form.HouseNumber")>and cNumber like '%#form.HouseNumber#%'</cfif>
		<cfif isDefined("form.HouseName")>and cName like '%#form.HouseName#%'</cfif>
	</cfquery>
</cfif>

<style>td{white-space:nowrap;}</style>
<table>
	<tr><th colspan=100%>Tenant & House Lookup</th></tr>
	<tr>
		<form action="Developer.cfm" method="post">
			<td>LastName</td>
			<td><input type="Text" name="LastName" value=""><input class=BlendedButton type="Submit" name="LastNameRun" value="Run"></td>
		</form>
		<form action="Developer.cfm" method="post">
			<td>HouseName</td>
			<td><input type="Text" name="HouseName" value=""><input class=BlendedButton type="Submit" name="HouseNameRun" value="Run"></td>
		</form>
	</tr>
	<tr>
		<form action="Developer.cfm" method="post">
			<td>iTenant_ID</td>
			<td><input type="Text" name="iTenant_ID" value=""><input class=BlendedButton type="Submit" name="iTenant_IDRun" value="Run"></td>
		</form>
		<form action="Developer.cfm" method="post">
			<td>iHouse_ID</td>
			<td><input type="Text" name="iHouse_ID" value=""><input class=BlendedButton type="Submit" name="iHouse_IDRun" value="Run"></td>
		</form>
	</tr>
	<tr>
		<form action="Developer.cfm" method="post">
			<td>cSolomonKey</td>
			<td><input type="Text" name="cSolomonKey" value=""><input class=BlendedButton type="Submit" name="cSolomonKeyRun" value="Run"></td>		
		</form>	
		<form action="Developer.cfm" method="post">
			<td>HouseNumber</td>
			<td><input type="Text" name="HouseNumber" value=""><input class=BlendedButton type="Submit" name="HouseNumber" value="Run"></td>		
		</form>
	</tr>	
</table>

<!--- table NUMBER 2 --->
<table>
	<tr><th colspan="100%">Invoice Balances</th></tr>
	<tr>
		<form action="Developer.cfm" method="post">
			<td>cSolomonKey</td>
			<td><input type="Text" name="InvoicecSolomonKey" value=""><input class=BlendedButton type="Submit" name="cSolomonKeyRun" value="Run"></td>		
		</form>	
		<form action="Developer.cfm" method="post">
			<td>Solomon Key Like</td>
			<td><input type="Text" name="InvoiceLikeSolomonKey" value=""><input class=BlendedButton type="Submit" name="HouseNumber" value="Run"></td>		
		</form>
	</tr>	
</table>

<cfif isDefined("qHouse.RecordCount") and qHouse.RecordCount gt 0>
	<br/>
	<table style="font-weight: bold;">
		<cfloop query="qHouse">
			<tr><td>#qHouse.cName#</td><td>#qHouse.cNumber# (#qHouse.iHouse_ID#)</td></tr>
		</cfloop>
	</table>
</cfif>

<cfif isDefined("qTenant.RecordCount") and qTenant.RecordCount gt 0><br/>
	<table style="font-weight: bold;">
		<cfloop query="qTenant">
			<tr>
			<th>#qTenant.cLastName#, #qTenant.cFirstName#</th>
			<td style="color:blue;"><a href="javascript:;" title="product line">#qTenant.iproductline_id#</a> <a href="javascript:;" title="residencytype">#qTenant.iResidencyType_ID#</a></td>
			<td>#qTenant.cBillingType# #DateFormat(qtenant.dtspevaluation,"mm/dd/yyyy")#</td>
			<td>#qTenant.cSolomonKey# (#qTenant.iTenant_ID#)</td>
			<td>#qTenant.cName#</td>
			<td>#qTenant.iHouse_ID#</td>
			<td>#qTenant.dtRowStart#</td>
			</tr>
		</cfloop>
	</table>
</cfif>

<cfif isDefined("qBalances.RecordCount") and qBalances.RecordCount gt 0><br/>
	<table ID='results' style="font-weight: bold;">
		<cfloop query="qBalances">
			<cfif qBalances.CurrentRow EQ 1>
				<tr><td colspan=100% style="background: gainsboro;">SolomonKey #qBalances.cSolomonKey#</td></tr>
				<tr><th>Ndx</th><th>InvoiceNumber</th><th>Per.</th><th>Last</th><th>Current</th><th>InvStart</th><th>InvEnd</th><th>UserID</th><th>dtRowStart</th><th>Type</th></tr>
			</cfif>
			<tr>
				<td>
				<a onClick="showdetails(#qBalances.iInvoiceMaster_ID#);" onMouseOver="this.style.cursor='hand';">
				<u>#qBalances.iInvoiceMaster_ID#</u>
				</a>
				</td>
				<td>#qBalances.iInvoiceNumber#</td>
				<td>#qBalances.cAppliesToAcctPeriod#</td>
				<td>#qBalances.mLastInvoiceTotal#</td>
				<td>#qBalances.mInvoiceTotal#</td>
				<td>#qBalances.dtInvoiceStart#</td>
				<td>#qBalances.dtInvoiceEnd#</td>
				<td>#qBalances.iRowStartUser_id#</td>
				<td>#qBalances.dtRowstart#</td>
				<td><cfif isDefined("qBalances.bMoveInInvoice") and qBalances.bMoveInInvoice EQ 1>MI<cfelseif isDefined("qBalances.bMoveOutInvoice") and qBalances.bMoveOutInvoice EQ 1>MO<CFELSE>Norm.</cfif></td>
			</tr>
			<tr><td colspan="100%"><div id="detailsarea#qBalances.iInvoiceMaster_ID#" style="display='none';"></div></td></tr>
		</cfloop>
	</table>
</cfif>

<!--- INLCUDE Intrante footer --->
<cfinclude template="../footer.cfm">
</div>
<script>
	if (!document.all['results'] == false){
		function resizewindow(){ 
			if (document.all['results'].clientWidth + 50 < document.all['results'].screenWidth) { 
				self.resizeTo(document.all['results'].clientWidth + 50,document.all['area'].scrollHeight); self.moveTo(0,0); 
			}
			else { self.resizeTo(screen.Width,screen.Height); self.moveTo(0,0);	} 
		}
		resizewindow();
	}
</script>
</cfoutput>