	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Tenant EFT House </h1>
<!---  
 |sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                             |
 |sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                    |
 --->  	
	<cfinclude template="../Shared/HouseHeader.cfm">
<cfquery name="qryDeferred"  datasource="#application.datasource#">
 select T.cfirstname, T.clastname,t.ihouse_id, t.csolomonkey, t.itenant_id,h.cname 'HouseName', h.ihouse_id,h.cnumber,
 Id.dtrowstart, id.dtrowend, id.mamount, 
 id.cappliestoacctperiod,ct.cDescription 'ChargeDesc', ct.iChargeType_ID ,
ts.mbaseNRF, ts.madjnrf, ts.mamtdeferred,
im.*
from dbo.Tenant t 
	left join dbo.InvoiceMaster IM on t.csolomonkey = IM.csolomonkey
		and   im.dtrowdeleted is null
	  join dbo.InvoiceDetail id on im.iInvoiceMaster_ID = id.iInvoiceMaster_ID
		and id.ichargetype_id = 1740
 	left join dbo.ChargeType  ct on ct.iChargeType_ID = id.iChargeType_ID
	join dbo.House h on t.iHouse_ID = h.iHouse_ID
	join dbo.TenantState ts on t.iTenant_ID = ts.iTenant_ID
where  ts.iTenantStateCode_ID = 2 and ts.mamtdeferred > 0
 and id.dtrowdeleted is null
 and im.bmoveininvoice is null 
 and ((getdate() > id.dtrowend) or (id.dtrowend is null))
--and t.itenant_id = 75269
order by  h.cname, t.itenant_id  desc
<!---  select T.cfirstname, T.clastname,t.ihouse_id, t.csolomonkey, t.itenant_id,h.cname 'HouseName', h.ihouse_id,h.cnumber,
Id.dtrowstart, id.dtrowend, id.mamount, id.cappliestoacctperiod,ct.cDescription 'ChargeDesc', ct.iChargeType_ID ,
ts.mbaseNRF, ts.madjnrf, ts.mamtdeferred
from dbo.Tenant t 
	join dbo.InvoiceDetail id on t.iTenant_ID = id.iTenant_ID
	<!--- 	join dbo.InvoiceMaster im on im.iInvoiceMaster_ID = id.iInvoiceMaster_ID --->	
	join dbo.ChargeType  ct on ct.iChargeType_ID = id.iChargeType_ID
	join dbo.House h on t.iHouse_ID = h.iHouse_ID
	join dbo.TenantState ts on t.iTenant_ID = ts.iTenant_ID
where <!--- ct.iChargeType_ID in ( 1741, 1740 )
and  --->ts.iTenantStateCode_ID = 2 and ts.mamtdeferred > 0
and id.dtrowdeleted is null
<!--- and im.bmoveininvoice is null --->
and ((getdate() < id.dtrowend) or (id.dtrowend is null))
order by  h.cname, t.itenant_id,iChargeType_ID, id.cappliestoacctperiod desc --->
 
</cfquery>
<body>
	<Table>
		<cfoutput query="qryDeferred" group="HouseName">
			<tr style="background-color:##99CCCC">
				<td colspan="7">#HouseName# #iHouse_id# #cnumber#</td>
			</tr>
			<tr  style="background-color:##FFFFCC">
				<td>Name</td>			
				<td>House Base NRF</td>
				<td>Adjusted NRF</td>
				<td>NRF Paid by Installments</td>
				<td>Installment Start Date</td>
				<td>Installment End Date</td>
				<td>Description</td>
				<td>Accounting Period</td>
			</tr>
			<cfoutput>
				<tr>
					<td>#cfirstname# #clastname# #csolomonkey#  #itenant_id#</td>			
					<td> #mbaseNRF#</td> <td> #madjnrf#</td> <td> #mamtdeferred#</td>
					<td>#dateformat(dtrowstart, 'mm/dd/yyyy')#</td>
					<td>#dateformat(dtrowend, 'mm/dd/yyyy/')#</td>
					<td>#chargedesc#</td>
					<td>#cappliestoacctperiod#</td>
				</tr>
			</cfoutput>
		</cfoutput>
	</Table>
</body>
		<cfinclude template="../../footer.cfm">	
