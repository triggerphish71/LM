<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Re-Import Outstanding Invoices</title>
<link rel="stylesheet" type="text/css" href="../Shared/Style3.css">
</head>
<cfquery name="qOutstandingInvoices" datasource="TIPS4">
select distinct im.iinvoicemaster_id, im.iinvoicenumber, h.ihouse_id, t.clastname, t.cfirstname, t.csolomonkey
from invoicemaster im (nolock)
join invoicedetail inv (nolock) on inv.iinvoicemaster_id = im.iinvoicemaster_id and inv.dtrowdeleted is null
and im.dtrowdeleted is null and im.bfinalized is not null and (im.bmoveininvoice is not null or im.bmoveoutinvoice is not null)
and im.cappliestoacctperiod >= '#year(now())#01'
join tenant t (nolock) on t.itenant_id = inv.itenant_id and t.dtrowdeleted is null 
join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null and ts.itenantstatecode_id <> 1
and ts.itenantstatecode_id <> 4
and (ts.dtmoveout is null or ts.dtnoticedate > '#year(now())#-01-01')
join house h (nolock) on h.ihouse_id = t.ihouse_id and h.dtrowdeleted is null and t.ihouse_id <> 200 and t.ihouse_id <> 52
where 0 =( select count(refnbr) from #Application.HOUSES_APPDBServer#.houses_app.dbo.ardoc fa 
where fa.custid = ltrim(rtrim(t.csolomonkey))
and user1 is not null and len(user1) <> 0 and user1 <> ''
and ltrim(rtrim(fa.user1)) = ltrim(rtrim(im.iInvoiceNumber)) )
</cfquery>
<!---
where im.dtrowstart between dateadd(d,-10,getdate()) and dateadd(d,10,getdate())
--->
<body>
<div style="color:blue;font-size:medium;"> Import Invoices (Move In or Move Out)</div>
<cfif qOutstandingInvoices.recordcount eq 0>
<div style="color:orange;font-size:medium;"> There are no outstanding invoices to import </div>
<cfabort>
</cfif>
<table style="width:1%;">
<tr><td class="topleftcap" colspan="2"></td><td class="toprightcap" colspan="2"></td></tr>
<tr>
<th>Solomon key</th>
<th colspan="2">Resident</th>
<th>Invoice</th>
</tr>
<cfloop query="qOutstandingInvoices">
<tr>
<td class="leftborder">#qOutstandingInvoices.csolomonkey#</td>
<td colspan="2" nowrap>#qOutstandingInvoices.clastname#, #qOutstandingInvoices.cfirstname#</td>
<td class="rightborder">
<a href="reImportSQL.cfm?ihouse_id=#qOutstandingInvoices.ihouse_id#&invoice=#qOutstandingInvoices.iinvoicenumber#&name='#qOutstandingInvoices.cfirstname# #qOutstandingInvoices.clastname#'"
target="_#qOutstandingInvoices.iinvoicenumber#">
#qOutstandingInvoices.iinvoicenumber#
</a>
</td>
</tr>
</cfloop>
<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
</body>
</html>
</cfoutput>