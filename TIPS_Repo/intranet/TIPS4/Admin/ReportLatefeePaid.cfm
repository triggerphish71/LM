
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<!--- <html xmlns="http://www.w3.org/1999/xhtml"> ---><head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>Resident Invoice</title>
	 <style>
		table{ 
			font-size:0em;
			border-collapse: collapse;
		}
	</style>
</head>
<cfparam default="" name="SelPeriod">
<cfif SelPeriod is ''>
Please select a TIPS period for the report<br />
<a href="../Reports/Menu.cfm">Return to Reports Menu</a>
<cfabort>
</cfif>

<cfquery name="getAllHouseTenantLateFeeRecords" DATASOURCE = "#APPLICATION.datasource#">
Select  u.username, d.cname 'Division', r.cname 'Region', h.cname 'House', t.clastname+', '+t.cfirstname'ResidentName', t.csolomonkey, t.itenant_ID, rpt.SLbalance 'CreditBalance' 
,sum (ltf.mlatefeeamount) 'lateFee',ltf.bpaid,rpt.acctperiod,DATEADD (dd, DATEDIFF(dd, 0, rpt.dtrowstart), 0) 'approvaldate'
from krishna.Houses_app.dbo.ar_balances ab
 join tenant t on ab.custid=t.csolomonkey
 join tenantstate ts on t.itenant_id=ts.itenant_id
 join house h on t.ihouse_id=h.ihouse_id
 join opsarea r on h.iopsarea_id=r.iopsarea_id
 join region d on r.iregion_id=d.iregion_id
 join  dms.dbo.users u on h.iacctuser_id=u.employeeid
 join tenantlatefee ltf on ltf.itenant_ID=t.itenant_ID
 join ReportLateFeePaidAllHouse rpt on rpt.iinvoicelatefee_ID=ltf.iinvoicelatefee_ID and rpt.Itenant_ID=t.itenant_ID

where 
 ts.itenantstatecode_ID=2
AND ltf.dtrowdeleted is null
AND t.dtrowdeleted is null
and ts.dtrowdeleted is null
and h.dtrowdeleted is null
and h.bissandbox=0
AND (ltf.bPaid =1)
and rpt.dtrowdeleted is null
and rpt.ApprovalPeriod= '#SelPeriod#'
group by
t.itenant_ID
, d.cname
 ,r.cname
,h.cname
,t.clastname
,t.cfirstname
,u.username
, t.csolomonkey
, rpt.SLbalance
,ltf.bpaid
,DATEADD (dd, DATEDIFF(dd, 0, rpt.dtrowstart), 0)
,rpt.acctperiod
order by u.username, d.cname, r.cname, h.cname, t.clastname+', '+t.cfirstname
</cfquery>
<cfdump var="#getAllHouseTenantLateFeeRecords#">

<cfquery name="getapprovaldate" DATASOURCE = "#APPLICATION.datasource#">
Select top 1 * from ReportLateFeePaidAllHouse where dtrowdeleted is null
</cfquery>
<cfdocument  format="PDF" orientation="Landscape" margintop="2" marginbottom="1">
	<cfdocumentitem type="header" >  
		<cfoutput>
			<table width="100%"  cellspacing="0" cellpadding="0" >
				<tr>
					<td> <img src="../../images/Enlivant_logo.jpg"/></td>
				</tr>
				<tr>
				<td colspan="2"><h1 style="font-weight: bold; text-align:center" >List of Late Fee Paid to Acct Period #dateformat(Session.TIPSmonth, 'mmm, yyyy')# </h1> </td>
			</table>
			 <table width="100%"  cellspacing="3" cellpadding="3"  > 
			 <tbody>
		<colgroup>
			<col span="1" style="width: 10%;text-align:left;">
			<col span="1" style="width: 5%;text-align:center;">
			<col span="1" style="width: 10%;text-align:center;">
			<col span="1" style="width: 15%;text-align::left;">	
			<col span="1" style="width: 12%;text-align::left;">
			<col span="1" style="width: 10%;text-align::left;">
			<col span="1" style="width: 8%;text-align::center;">
			<col span="1" style="width: 7%;text-align::center;">
			<col span="1" style="width: 8%;text-align::center;">
			<col span="1" style="width: 8%;text-align::center;">
			<col span="1" style="width: 7%;text-align::center;">
		</colgroup>
				<tr>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>AR Analyst</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Division</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Region</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Community</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Resident Name</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Resident ID</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Balance in SL</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Total amount of late feee</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Paid</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Approval date</h1></td>
					<td style="border-bottom: 1px solid black;font-size:12px;"><h1>Invoice Month</h1></td>
				</tr>
			</tbody>
			</table>
		
			
		</cfoutput>	
	</cfdocumentitem>	
	<cfheader name="Content-Disposition" value="attachment;filename=latefeeApproveAll-#dateformat(now(), 'mmddyyyy')#.pdf">
	
	<cfoutput>
	<table width="100%"  cellspacing="3" cellpadding="3">
		<tbody>
			<colgroup>
					<col span="1" style="width: 8%;text-align:left;">
					<col span="1" style="width: 7%;text-align:left;">
					<col span="1" style="width: 10%;text-align:left;">
					<col span="1" style="width: 15%;text-align:left;">	
					<col span="1" style="width: 15%;text-align:left;">
					<col span="1" style="width: 10%;text-align:left;">
					<col span="1" style="width: 7%;text-align:left;">
					<col span="1" style="width: 8%;text-align:left;">
					<col span="1" style="width: 6%;text-align:left;">
					<col span="1" style="width: 6%;text-align:left;">
					<col span="1" style="width: 8%;text-align:left;">
			</colgroup>

			<cfloop query='getAllHouseTenantLateFeeRecords'>
				<tr>
				    <td style="font-size:12px"> #getAllHouseTenantLateFeeRecords.username# </td>
					<td style="font-size:12px">#getAllHouseTenantLateFeeRecords.Division#</td>
					<td style="font-size:12px">#getAllHouseTenantLateFeeRecords.region#</td>
					<td style="font-size:12px">#getAllHouseTenantLateFeeRecords.house#</td>
					<td style="font-size:12px">#getAllHouseTenantLateFeeRecords.ResidentName#</td>
					<td style="font-size:12px">#getAllHouseTenantLateFeeRecords.csolomonkey#</td>
					<td style="font-size:12px">#LSCurrencyFormat(getAllHouseTenantLateFeeRecords.CreditBalance)#</td>
					<td style="font-size:12px">#LSCurrencyFormat(getAllHouseTenantLateFeeRecords.lateFee)#</td>
					<td style="font-size:12px"><cfif getAllHouseTenantLateFeeRecords.bPaid eq 1> Yes <cfelse>No </cfif></td>
					<td style="font-size:12px">#dateformat(getAllHouseTenantLateFeeRecords.approvaldate,'mm/dd/yyyy')#</td>
					<td style="font-size:12px">#getAllHouseTenantLateFeeRecords.Acctperiod#</td>
				</tr>
		    </cfloop>
		    </tbody> 
		</table>
	</cfoutput>
	
	<cfdocumentitem  type="footer" evalAtPrint="true" >
	<cfoutput>
		<table width="95%">
				<tr>
					<td colspan="3" style="font-size:small;text-align:right">
					Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
					</td>
				</tr>
				 <tr>
					<td style="font-size:small; text-align:right">
					Printed: #dateformat(now(), 'mm/dd/yyyy')#
					</td>
				</tr>
			</table>
	</cfoutput>
	</cfdocumentitem>
</cfdocument>