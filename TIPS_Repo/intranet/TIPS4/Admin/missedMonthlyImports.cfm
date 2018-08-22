<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Montly re-import</title>
<link rel="stylesheet" type="text/css" href="../Shared/Style3.css">
</head>
<cfoutput>#Application.HOUSES_APPDBServer#</cfoutput><cfabort>

<!--- find MONTHLY missed imports --->
<cfquery name="qmissed" datasource="TIPS4">
select distinct h.cname ,h.ihouse_id ,dateadd(m,-1,hl.dtcurrenttipsmonth) tmonth
from houselog hl (nolock) 
join house h (nolock) on h.ihouse_id = hl.ihouse_id and h.dtrowdeleted is null
and hl.dtrowdeleted is null and hl.dtcurrenttipsmonth = (select max(distinct dtcurrenttipsmonth) from houselog where dtrowdeleted is null)
and h.ihouse_id <> 200
join tenant t (nolock) on t.ihouse_id = h.ihouse_id and t.dtrowdeleted is null
and t.bismedicaid is null and t.bismisc is null
join tenantstate ts (nolock) on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
and ts.itenantstatecode_id = 2
join invoicemaster im (nolock) on im.csolomonkey = t.csolomonkey
and im.dtrowdeleted is null and im.bfinalized is not null
and im.bmoveininvoice is null and im.bmoveoutinvoice is null
and im.cappliestoacctperiod='#dateformat(dateadd('m',-1,session.tipsmonth),"yyyymm")#'
join invoicedetail inv (nolock) on inv.iinvoicemaster_id = im.iinvoicemaster_id and inv.dtrowdeleted is null
and inv.itenant_id = t.itenant_id
join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
and ct.cgrouping <> 'S'
left join #Application.HOUSES_APPDBServer#.houses_app.dbo.ardoc fa on rtrim(fa.custid) = rtrim(t.csolomonkey) 
and fa.user1 is not null and fa.user1 <> '' 
and (fa.perpost='#dateformat(dateadd('m',-1,session.tipsmonth),"yyyymm")#'
	or (rtrim(fa.user1) = rtrim(im.iinvoicenumber) and fa.perpost<=im.cappliestoacctperiod)
)
and rtrim(fa.user1) = rtrim(im.iinvoicenumber) 
where fa.custid is null
order by h.cname
</cfquery>


<body>
<cfif qmissed.recordcount gt 0>
<table style="width:1%;">
<tr><td class="topleftcap" colspan="2"></td><td class="toprightcap" colspan="2"></td></tr>
<tr>
<th>row</th>
<th colspan="2">house</th>
<th>re-import</th>
</tr>
<cfloop query="qmissed">
<tr>
<td class="leftborder">#qmissed.currentrow#</td>
<td nowrap colspan="2">
<a href="reImportSQL.cfm?ihouse_id=#qmissed.ihouse_id#&period=#dateformat(qmissed.tmonth,'yyyymm')#&name='#qmissed.cname#'" target="_blank">
#qmissed.cname#
</a>
</td>
<td class="rightborder">#dateformat(qmissed.tmonth,'yyyymm')#</td>
</tr>
</cfloop>
<tr><td class="bottomleftcap" colspan="2"></td><td class="bottomrightcap" colspan="2"></td></tr>
</table>
<cfelse>
<div style="color:blue;text-align:center;color:blue;"> no monthly imports have been missed </div>
</cfif>
</body>
</html>
</cfoutput>