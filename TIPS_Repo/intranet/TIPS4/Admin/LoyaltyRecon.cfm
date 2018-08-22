<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Loyalty Recon</title>
<link rel="stylesheet" type="text/css" href="http://#server_name#/intranet/TIPS4/Shared/Style3.css">
<style>
td { white-space:nowrap; }
th { padding: 2px 2px 2px 2px;  border: 1px inset ##ffffff; }
</style>
<cfflush interval="10">
</head>

<cftry>

<cfquery name="qtest" datasource="TIPS4">
select * from ##temp
</cfquery>

<cfquery name="qdelete" datasource="TIPS4">
drop table ##temp
</cfquery>

<cfcatch type="database">
<!--- no action --->	
</cfcatch>

</cftry>

<!--- periods --->
<cfquery name="qPeriods" datasource="TIPS4">
select distinct dtCurrentTipsMonth period
from vw_houselog_history 
where dtrowdeleted is null and bispdclosed is null
and dtCurrentTipsMonth >= '2004-09-01'
order by dtCurrentTipsMonth desc
</cfquery>

<!--- set start range and month as string variable --->
<cfparam name="dtStart" default='2004-11-01'>
<cfset stPeriod=DateFormat(dtStart,"yyyymm")>
<cfset vStart=DateFormat(dtStart,"mmm")>

<!--- set end range and month as string variable --->
<cfparam name="dtEnd" default='2005-01-01'>
<cfset ePeriod=DateFormat(dtEnd,"yyyymm")>
<cfset vEnd=DateFormat(dtEnd,"mmm")>

<!--- set date for filtering out move outs --->
<cfset dtMO=dateadd('m',1,dtEnd)>

<!--- retrieve house list --->
<cfquery name="qhouses" datasource="TIPS4">
select ihouse_id, cname from house where dtrowdeleted is null
order by cname
</cfquery>

<cftransaction>

<!--- get data --->
<cfquery name="qSetUp" datasource="TIPS4">
create table ##temp ( rdo char(30) ,ihouse_id int ,itenant_id int ,resident varchar(30) ,solomonkey varchar(10) ,desc_start varchar(30) 
,end_desc varchar(30) ,slevel_start money ,qty_start int ,ext_start money ,end_amt money ,qty_end int ,ext_end money ,discount money
,qty_disc int ,ext_disc money ,diff money ,end_detail int ,end_batnbr varchar(10) ,end_tranamt money
)

insert into ##temp
select ae.lname+', '+ae.fname, h.ihouse_id, t.itenant_id, t.clastname+', '+t.cfirstname, t.csolomonkey
,inv.cdescription ,null ,inv.mamount ,inv.iquantity ,(inv.mamount * inv.iquantity) ,null ,null ,null ,null ,null ,null , null ,null ,null 
,null
from house h
join opsarea o on o.iopsarea_id = h.iopsarea_id and o.dtrowdeleted is null
join region r on r.iregion_id = o.iregion_id and r.dtrowdeleted is null
join #Application.DmsDBServer#.dms.dbo.users du on du.employeeid = o.idirectoruser_id and du.dtrowdeleted is null
join #Application.AlcWebDBServer#.alcweb.dbo.employees ae on ae.employee_ndx = du.employeeid
join tenant t on t.ihouse_id = h.ihouse_id and t.dtrowdeleted is null
join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
	and ts.iresidencytype_id = 1
	and (ts.dtmoveout is null or ts.dtmoveout >= #dtMO#)
join invoicedetail inv on inv.itenant_id = t.itenant_id and inv.dtrowdeleted is null
	and inv.irowstartuser_id = 0
join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
	and im.cappliestoacctperiod = '#stPeriod#' 
	and im.bmoveininvoice is null and im.bmoveoutinvoice is null
join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
	and ct.cgrouping = 'RD'
where h.ihouse_id <> 200 
<cfif isDefined("form.chosenhouse") and form.chosenhouse neq "all"> and h.ihouse_id = #form.chosenhouse# </cfif>
--and h.ihouse_id in (50,81)

update ##temp
set end_amt = inv.mamount, qty_end = inv.iquantity ,ext_end = (inv.mamount * inv.iquantity) ,end_desc = inv.cdescription
,end_detail = inv.iinvoicedetail_id
from ##temp tmp
join invoicedetail inv on inv.itenant_id = tmp.itenant_id and inv.dtrowdeleted is null
join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
	and im.cappliestoacctperiod='#ePeriod#' and im.bmoveininvoice is null and im.bmoveoutinvoice is null
join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
	and ct.cgrouping = 'RD'

update ##temp
set discount = inv.mamount, qty_disc = inv.iquantity , ext_disc=(inv.mamount * inv.iquantity)
from ##temp tmp
join invoicedetail inv on inv.itenant_id = tmp.itenant_id and inv.dtrowdeleted is null
join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
	and im.cappliestoacctperiod='#ePeriod#' and im.bmoveininvoice is null and im.bmoveoutinvoice is null
join chargetype ct on ct.ichargetype_id = inv.ichargetype_id and ct.dtrowdeleted is null
	and inv.ccomments = 'Loyalty discount'

update ##temp
set diff = ( 
		case 
		when (ext_disc is null) then isNull( (((ext_end + isNull(ext_disc,0))) - ext_start),0) 
		when (ext_disc > 0) then isNull( (((ext_end + isNull(ext_disc,0))) - ext_start),0) 
		else (ext_end - ext_disc)
		end )

update ##temp
set end_batnbr = batnbr, end_tranamt = tranamt
from ##temp tmp
join #Application.HOUSES_APPDBServer#.houses_app.dbo.artran art on art.custid = tmp.solomonkey 
and user3 = tmp.end_detail
</cfquery>

<cfquery name="qData" datasource="TIPS4">
select rdo, h.cname as house ,resident ,solomonkey 
,right(desc_start,1) start_level ,right(end_desc,1) end_level , slevel_start start_amt ,qty_start start_qty ,ext_start start_ext 
,end_amt ,qty_end end_qty ,ext_end end_ext ,discount ,qty_disc disc_qty ,ext_disc disc_ext ,diff
,end_batnbr Solomon_batnbr ,end_tranamt end_SolomonAmt
from ##temp tmp
join house h on h.ihouse_id = tmp.ihouse_id and h.dtrowdeleted is null
order by h.cname, resident
</cfquery>
</cftransaction>

<body>
<form action="" method="post">
House
<select name="chosenhouse">
	<option value="all">all</option>
	<cfloop query="qhouses">
	<cfif isDefined("chosenhouse") and chosenhouse neq "all" and chosenhouse eq qhouses.ihouse_id><cfset hchsn='selected'><cfelse><cfset hchsn=''></cfif> 
	<option value="#qhouses.ihouse_id#" #hchsn#>#qhouses.cname#</option>
	</cfloop>
</select>

Start 
<select name="dtStart">
	<cfloop query="qPeriods">
	<cfif dtStart eq DateFormat(qPeriods.period,"yyyy-mm-dd")><cfset schsn='selected'><cfelse><cfset schsn=''></cfif> 
	<option value="#qPeriods.period#" #schsn#>#DateFormat(qPeriods.period,"yyyymm")#</option>
	</cfloop>
</select>

End
<select name="dtEnd">
	<cfloop query="qPeriods">
	<cfif dtEnd eq DateFormat(qPeriods.period,"yyyy-mm-dd")><cfset echsn='selected'><cfelse><cfset echsn=''></cfif> 
	<option value="#qPeriods.period#" #echsn#>#DateFormat(qPeriods.period,"yyyymm")#</option>
	</cfloop>
</select>

<input type="submit" name="go" value="go">

<table border="1">
<tr>
<th>RDO</th>
<th>House</th>
<th>Resident</th>
<th>Solomonkey</th>
<th>#vStart# level</th>
<th>#vEnd# level</th>
<th>#vStart# amt</th>
<th>#vStart# qty</th>
<th>#vStart# ext</th>
<th>#vEnd# amt</th>
<th>#vEnd# qty</th>
<th>#vEnd# ext</th>
<th>Discount</th>
<th>Disc qty</th>
<th>Disc ext</th>
<th>Diff</th>
<th>Solomon batnbr</th>
<th>#vEnd# SolomonAmt</th>
</tr>
<cfloop query="qData">
<tr>
<td>#qData.rdo#</td>
<td>#qData.house#</td>
<td>#qData.resident#</td>
<td>#qData.solomonkey#</td>
<td>#qData.start_level#</td>
<td>#qData.end_level#</td>
<td>#qData.start_amt#</td>
<td>#qData.start_qty#</td>
<td>#qData.start_ext#</td>
<td>#qData.end_amt#</td>
<td>#qData.end_qty#</td>
<td>#qData.end_ext#</td>
<td>#qData.discount#</td>
<td>#qData.disc_qty#</td>
<td>#qData.disc_ext#</td>
<td>#qData.diff#</td>
<td>#qData.Solomon_batnbr#</td>
<td>#qData.end_SolomonAmt#</td>
</tr>
</cfloop>
</table>
</form>
</body>
</html>
<cfquery name="qdelete" datasource="TIPS4">
drop table ##temp
</cfquery>
</cfoutput>