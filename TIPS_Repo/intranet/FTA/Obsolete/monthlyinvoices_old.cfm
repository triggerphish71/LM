<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- Monthly Invoices</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<SCRIPT language="javascript">
<!--
function displayWindow(url, width, height) {
        var Win = window.open(url,"displayWindow",'width=' + width +
',height=' + height + ',resizable=1,scrollbars=yes,menubar=yes' );
}
//-->
				
 function doSel(obj)
 {
     for (i = 1; i < obj.length; i++)
        if (obj[i].selected == true)
           eval(obj[i].value);
}
</SCRIPT>

</head>


<cfif not isDefined("url.iHouse_ID")>
	<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
	<cfset SubAccountNumber = #FindSubAccount.company#>
<cfelse>
	<form name="whatever">
	<!--- url.iHouse_ID is defined, so this is an AP person coming in pretending to be a house --->
	<CFLDAP ACTION="query" NAME="FindSubAccount" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,company,Name" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(physicalDeliveryOfficeName=#SESSION.EID#))" USERNAME="ldap" PASSWORD="paulLDAP939">
	<!--- <strong><font face="arial">Welcome, AP Administrator, <cfoutput>#FindSubAccount.Name#</cfoutput>! </font></strong> --->
	<cfquery name="getSubAccount" datasource="TIPS4">
	select cGLsubaccount from HOUSE where dtRowDeleted IS NULL and iHouse_ID = #url.iHouse_ID#
	</cfquery>
	<cfset SubAccountNumber = #trim(getSubAccount.cGLsubaccount)#>	
</cfif>
	
<Cfif session.ADdescription contains "RDO">
	<cfset RDOposition = #Find("RDO",SESSION.ADdescription)#>
	<cfset endposition = rdoposition + 5>
	<cfset regionname = #removechars(SESSION.ADdescription,1,endposition)#>
	<cfquery name="findOpsAreaID" datasource="prodTips4">
		select iOpsArea_ID, cName from OpsArea where dtRowDeleted IS NULL and cName = '#Trim(RegionName)#'
	</cfquery>
	<cfif findOpsAreaID.recordcount is not "0">
		<cfset RDOrestrict = #findOpsAreaID.iOpsArea_ID#>
	</cfif>
</Cfif>

<!--- show house dropdown if subaccount is 0 -- FOR NOW COMMENT OUT --->
<!--- <cfif FindSubAccount.company is 0>
	<cfquery name="getHouses" datasource="TIPS4">
	select cName, iHouse_ID from HOUSE where dtRowDeleted IS NULL 
	<Cfif isDefined("RDOrestrict")>and iOpsArea_ID = #RDOrestrict#</Cfif>
	order by cName
	</cfquery>
	
	<cfoutput>
		<font face="arial">
		View invoices from: 
		<select name="iHouse_ID" onchange="doSel(this)">
		<option value=""></option>
		<cfloop query="getHouses">
		<option value="location.href='invoiceentry.cfm?iHouse_ID=#iHouse_ID#'"<cfif (isDefined("url.iHouse_ID") and url.iHouse_ID is "#getHouses.iHouse_ID#")> SELECTED</cfif>>#cName#</option>
		</cfloop>
		</select><HR align=left size=2 width=700>
	</form>
	</cfoutput>
	<cfif not isDefined("url.iHouse_ID")>
	<p><BR>
<center><font size=-1>[ <A href="/intranet/logout.cfm"><font color="##0033CC">Logout</font></A> |  <a href="doclinksearch.cfm">Search Doclink</a> | <A HREF="readscans.cfm">Key-in Invoices</A> | <a href="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</a> ]</font></center>
	<cfabort>
	</cfif>
</cfif> --->

<cfquery name="LookUpSubAcct" datasource="#SolomonHousesDS#">
		select CnyName from XBANKINFO where SubAcct = '#SubAccountNumber#'
	</cfquery>
	
<cfif not isDefined("url.datetouse")><cfset monthnowmonth = "Yes"></cfif>	
<cfparam name="datetouse" default="#NOW()#">
<cfset monthforqueries = #DateFormat(datetouse,'mmm')#>
<cfset yearforqueries = #DateFormat(datetouse,'yyyy')#>
<cfset firstdayofdatetouse = "#DateFormat(datetouse,'mm')#/01/#DateFormat(datetouse,'yyyy')# 00:00:00">
<cfset PtoPFormat = "#Dateformat(firstdayofdatetouse,'YYYYMM')#">

<cfif isDefined("monthnowmonth")>
	<cfset lastdayofdatetouse = "#DateFormat(Now(), 'M/D/YYYY')#">
	<cfset datetouse = #DateFormat(datetouse,'mmmm yyyy')#>
<cfelse>
	<cfset daysinmonth2 = #DaysInMonth(datetouse)#>
	<cfset lastdayofdatetouse = "#DatePart('m',datetouse)#/#DaysInMonth2#/#DatePart('yyyy',datetouse)#">
</cfif>

<body>
<font face="arial">
<cfoutput>
<h3>Online FTA- <font color="##C88A5B">Monthly Invoices-</font> <font color="##0066CC">#LookUpSubAcct.CnyName#-</font> <Font color="##7F7E7E">#DateFormat(datetouse,'mmmm YYYY')#</font></h3>

<cfset Page="monthlyinvoices">
<Table border=0 cellpadding=0 cellspacing=0>
<td>
<cfinclude template="menu.cfm">
</td>
<td>&##160; <font size=-1><A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A>
<p><BR>
&##160; Month to View: <cfparam default="D.Created" name="url.orderby">
<cfparam default="ASC" name="url.order">
<cfset x = DateFormat(NOW(),'mmmm yyyy')>
<cfset y = "November 2004">
<select name="datetouse2" onchange="doSel(this)"><option value=""></option><cfloop condition="#DateCompare(x,y,'m')# GTE 0"><option value="location.href='monthlyinvoices.cfm?<cfif isDefined("url.iHouse_ID")>iHouse_ID=#url.iHouse_ID#&</cfif>DateToUse=#DateFormat(x,'mmmm yyyy')#'"<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> SELECTED</cfif>>#DateFormat(x,'mmmm yyyy')#</option><cfset x = #DateAdd('m',-1,x)#></cfloop></select>
<cfset themonth = #month(datetouse)#><cfset themonth = monthAsString(#themonth#)><cfset dim = #daysinmonth(datetouse)#>
</td>
</Table>
</cfoutput>
<p>
<font size=-1>
Green rows are House Vendors, Yellow rows are Corporate Vendors.<BR>
Click on a Column Heading to sort by that column.  Clicking again orders that column the opposite way.</font>
<br>
<!--- find any PREVIOUS invoices without create dates of this month that are period to post of this month --->
<!--- <cfquery name="FindPriorPeriodx" datasource="#doclinkProd#">
	SELECT     D.Created, D.DocumentID, D.DocumentTypeID, (select count(PCV.PropertyCharValue) from PropertyCharValues PCV where PCV.ParentID = P.ParentID and PCV.PropertyID = 18) as SubAcctCount
	FROM         dbo.PropertyCharValues P
	inner join dbo.Documents D ON P.ParentID = D.DocumentID
	inner join dbo.PropertyCharValues P2 ON P.ParentID = P2.ParentID
	inner join dbo.PropertyDateValues PInvDate (NOLOCK) ON P.ParentID = PInvDate.ParentID and PInvDate.PropertyID = 20
	WHERE     (P.PropertyCharValue = '#SubAccountNumber#' AND P.PropertyID = 18)
	and D.Created < '#firstdayofdatetouse#'
	and (P2.PropertyCharValue = '#PtoPFormat#' AND P2.PropertyID = 19)
	and (D.DocumentTypeID = 8 OR D.DocumentTypeID = 37)
	and PinvDate.PropertyDateValue > '7/1/2004'
	order by D.Created
</cfquery> --->

<cfquery name="FindPriorPeriod" datasource="#doclinkProd#">
	SELECT     D.Created, D.DocumentID, D.DocumentTypeID, 
	(select count(PCV.PropertyCharValue) from PropertyCharValues PCV where PCV.ParentID = P.ParentID and PCV.PropertyID = 18) as SubAcctCount,
PInvDate.PropertyDateValue as InvoiceDate, PInvNum.PropertyCharValue as InvoiceNumber,
Max(PVendName.PropertyCharValue) as VendorName, PRefNum.PropertyCharValue as RefNumber,
PBatch.PropertyCharValue as BatchID, PComCode.PropertyCharValue as CompanyCode

FROM         dbo.PropertyCharValues P (NOLOCK)
inner join dbo.Documents D (NOLOCK) ON P.ParentID = D.DocumentID
inner join dbo.PropertyDateValues PInvDate (NOLOCK) ON P.ParentID = PInvDate.ParentID and PInvDate.PropertyID = 20
inner join dbo.PropertyCharValues PInvNum (NOLOCK) ON P.ParentID = PInvNum.ParentID and PInvNum.PropertyID = 3
inner join dbo.PropertyCharValues PVendName (NOLOCK) ON P.ParentID = PVendName.ParentID and PVendName.PropertyID = 1
left outer join dbo.PropertyCharValues PRefNum (NOLOCK) ON P.ParentID = PRefNum.ParentID and PRefNum.PropertyID = 24
left outer join dbo.PropertyCharValues PBatch (NOLOCK) ON P.ParentID = PBatch.ParentID and PBatch.PropertyID = 13
inner join dbo.PropertyCharValues PComCode (NOLOCK) ON P.ParentID = PComCode.ParentID and PComCode.PropertyID = 25
left outer join dbo.PropertyCharValues PPerToPost (NOLOCK) ON P.ParentID = PPerToPost.ParentID and PPerToPost.PropertyID = 19
	WHERE     (P.PropertyCharValue = '#SubAccountNumber#' AND P.PropertyID = 18)
	and D.Created < '#firstdayofdatetouse#'
	and (PPerToPost.PropertyCharValue = '#PtoPFormat#' AND PPerToPost.PropertyID = 19)
	and (D.DocumentTypeID = 8 OR D.DocumentTypeID = 37)
	and PinvDate.PropertyDateValue > '7/1/2004'
	group by D.Created, D.DocumentID, d.DocumentTypeID, P.ParentID, PinvDate.PropertyDateValue, PInvNum.PropertyCharValue, PRefNum.PropertyCharValue, PBatch.PropertyCharValue,PComCode.PropertyCharValue
	order by D.Created
</cfquery>

<cfquery name="findinvoices" datasource="#doclinkprod#">
SELECT     D.Created, D.DocumentID, D.DocumentTypeID,

(select count(PCV.PropertyCharValue)
from PropertyCharValues PCV (NOLOCK)
where PCV.ParentID = P.ParentID and PCV.PropertyID = 18) as SubAcctCount,

PInvDate.PropertyDateValue as InvoiceDate, PInvNum.PropertyCharValue as InvoiceNumber,
Max(PVendName.PropertyCharValue) as VendorName, PRefNum.PropertyCharValue as RefNumber,
PBatch.PropertyCharValue as BatchID, PComCode.PropertyCharValue as CompanyCode

FROM         dbo.PropertyCharValues P (NOLOCK)
inner join dbo.Documents D (NOLOCK) ON P.ParentID = D.DocumentID
inner join dbo.PropertyDateValues PInvDate (NOLOCK) ON P.ParentID = PInvDate.ParentID and PInvDate.PropertyID = 20
inner join dbo.PropertyCharValues PInvNum (NOLOCK) ON P.ParentID = PInvNum.ParentID and PInvNum.PropertyID = 3
inner join dbo.PropertyCharValues PVendName (NOLOCK) ON P.ParentID = PVendName.ParentID and PVendName.PropertyID = 1
left outer join dbo.PropertyCharValues PRefNum (NOLOCK) ON P.ParentID = PRefNum.ParentID and PRefNum.PropertyID = 24
left outer join dbo.PropertyCharValues PBatch (NOLOCK) ON P.ParentID = PBatch.ParentID and PBatch.PropertyID = 13
inner join dbo.PropertyCharValues PComCode (NOLOCK) ON P.ParentID = PComCode.ParentID and PComCode.PropertyID = 25
left outer join dbo.PropertyCharValues PPerToPost (NOLOCK) ON P.ParentID = PPerToPost.ParentID and PPerToPost.PropertyID = 19
WHERE     (PPerToPost.PropertyCharValue = '#DateFormat(DatetoUse,'YYYYMM')#' OR PPerToPost.PropertyCharValue IS NULL) and
(P.PropertyCharValue = '#SubAccountNumber#' AND P.PropertyID = 18)
and D.Created between '#firstdayofdatetouse#' and '#lastdayofdatetouse#'
and (D.DocumentTypeID = 8 <!--- IFV ---> OR D.DocumentTypeID = 37 <!--- IIP --->)
and PinvDate.PropertyDateValue > '7/1/2004'

group by D.Created, D.DocumentID, d.DocumentTypeID, P.ParentID, PinvDate.PropertyDateValue, PInvNum.PropertyCharValue, PRefNum.PropertyCharValue, PBatch.PropertyCharValue,PComCode.PropertyCharValue

order by #orderby# #order#
</cfquery>
<p>
<font size=-1 face="arial">
Invoices submitted to Accounting last month that didn't get processed until this month:<BR>
<Table border=0><td valign=top>
<table border=1 cellspacing=0 cellpadding=1>
<tr>

<cfoutput>
<th bgcolor="##0066CC"><font color="white" size=-1><font color="white">Transaction Date</font></th>
<th bgcolor="##0066CC"><font color="white" size=-1><font color="white">Date of Invoice</font></th>
<th bgcolor="##0066CC"><font color="white" size=-1><font color="white">Invoice ##</font></th>
<th bgcolor="##0066CC"><font color="white" size=-1><font color="white">Vendor</font></th>
<th bgcolor="##0066CC"><font color="white" size=-1>GL Code(s)</th>
<th bgcolor="##0066CC"><font color="white" size=-1>Amount(s)</th>
<th bgcolor="##0066CC"><font color="white" size=-1>Processed?</th>
</tr>
</cfoutput>
<cfif findpriorperiod.recordcount is "0">
	<tr>
	<td colspan=7 align=center><em><font size=-1 color="red">Sorry, no prior period invoices for the specified month were found.</font></em></td>
	</tr>
</cfif>
<cfloop query="findpriorperiod">
 	<cfif findpriorperiod.DocumentTypeID is "8">
		<cfif findpriorperiod.CompanyCode is "Corp">
			<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonCorpDS#">
					SELECT     Acct, sum(TranAmt) as TranAmtTotal
					FROM         dbo.APTran
					WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#findpriorperiod.BatchID#') AND (RefNbr = '#findpriorperiod.Refnumber#')
					group by Acct
			</cfquery>
		<cfelse>
			<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonHousesDS#">
					SELECT     Acct, sum(TranAmt) as TranAmtTotal
					FROM         dbo.APTran (NOLOCK)
					WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#findpriorperiod.BatchID#') AND (RefNbr = '#findpriorperiod.Refnumber#')
							AND crtd_prog<>'03400'
					group by Acct
			</cfquery>
		</cfif>
	<cfelse>
		<!--- get gl info from dist stamp --->
		<cfquery name="getSpecificHouseInvoiceAmount" datasource="#doclinkprod#">
			select DS.distStampid, SFV.FieldValue as Acct
			from DistributionStamp DS 
			inner join stampfieldvalue SFV ON DS.distStampID = SFV.distStampID
			where DS.DocumentID = #findpriorperiod.documentID# and SFV.StampFieldID = 10009 <!--- acct code --->
		</cfquery>
		<cfquery name="getSpecificHouseInvoiceAmount2" datasource="#doclinkprod#">
			select DS.distStampid, SFV.FieldValue as TranAmtTotal
			from DistributionStamp DS 
			inner join stampfieldvalue SFV ON DS.distStampID = SFV.distStampID
			where DS.DocumentID = #findpriorperiod.documentID# and SFV.StampFieldID = 10011 <!--- amount --->
		</cfquery>
	</cfif>
	<cfoutput>
	<cfif findpriorperiod.companycode is "corp"><cfset color = "##FFFFCC"><cfelse><cfset color="##C0DCC0"></cfif>
	<tr>
	<td align=right bgcolor="#color#"><font size=-1>#DateFormat(findpriorperiod.Created,'M/D/YY')#</td>
	<td align=right bgcolor="#color#"><font size=-1>#DateFormat(findpriorperiod.InvoiceDate,'MM/DD/YY')#</td>
	<td align=right bgcolor="#color#"><font size=-1>#findpriorperiod.InvoiceNumber#</td>
	<td bgcolor="#color#"><font size=-1>&##160;#findpriorperiod.VendorName#</td>
	<td align=right bgcolor="#color#"><font size=-1>&##160;<cfloop query="getSpecificHouseInvoiceAmount">#getSpecificHouseInvoiceAmount.Acct#<BR></cfloop></td>
	<td align=right bgcolor="#color#"><font size=-1><cfif findpriorperiod.DocumentTypeID is "8"><cfloop query="getSpecificHouseInvoiceAmount">#DecimalFormat(getSpecificHouseInvoiceAmount.TranAmtTotal)#<BR></cfloop>
	<cfelse><cfloop query="getSpecificHouseInvoiceAmount2">#DecimalFormat(getSpecificHouseInvoiceAmount2.TranAmtTotal)#<BR></cfloop></cfif></td>
	<td align=right bgcolor="#color#"><cfif findpriorperiod.DocumentTypeID is "8"><img src="/intranet/doclink/checkmark3.gif"><Cfelse>&##160;</cfif></td>
	</tr>
	</cfoutput>
</cfloop>
</table>
</td>
</table>

<p>
Current Period Invoices:<BR></font>
<Table border=0><td valign=top>
<table border=1 cellspacing=0 cellpadding=1>
<tr>
<cfif order is "ASC"><cfset ordernow="DESC"><cfelse><cfset ordernow="ASC"></cfif>

<cfoutput>
<th bgcolor="##0066CC"><font color="white" size=-1><A HREF="monthlyinvoices.cfm?iHouse_ID=#url.iHouse_ID#&datetouse=#datetouse#&orderby=D.Created&order=#ordernow#"><font color="white">Transaction Date</font></A></th>
<th bgcolor="##0066CC"><font color="white" size=-1><A HREF="monthlyinvoices.cfm?iHouse_ID=#url.iHouse_ID#&datetouse=#datetouse#&orderby=InvoiceDate&order=#ordernow#"><font color="white">Date of Invoice</font></A></th>
<th bgcolor="##0066CC"><font color="white" size=-1><A HREF="monthlyinvoices.cfm?iHouse_ID=#url.iHouse_ID#&datetouse=#datetouse#&orderby=InvoiceNumber&order=#ordernow#"><font color="white">Invoice ##</font></A></th>
<th bgcolor="##0066CC"><font color="white" size=-1><A HREF="monthlyinvoices.cfm?iHouse_ID=#url.iHouse_ID#&datetouse=#datetouse#&orderby=VendorName&order=#ordernow#"><font color="white">Vendor</font></A></th>
<th bgcolor="##0066CC"><font color="white" size=-1>GL Code(s)</th>
<th bgcolor="##0066CC"><font color="white" size=-1>Amount(s)</th>
<th bgcolor="##0066CC"><font color="white" size=-1>Processed?</th>
</tr>
</cfoutput>

<cfif findinvoices.recordcount is "0">
	<tr>
	<td colspan=7 align=center><em><font size=-1 color="red">Sorry, no invoices for the specified month were found.</font></em></td>
	</tr>
</cfif>

<cfloop query="findinvoices">
	<!--- obtain other property data --->
	<!--- <cfquery name="getInvoiceDate" datasource="#doclinkprod#">
		select PropertyID, PropertyDateValue from PropertyDateValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 20
	</cfquery> 
	<cfquery name="getInvoiceNumber" datasource="#doclinkprod#">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 3
	</cfquery>
	<cfquery name="getVendorName" datasource="#doclinkprod#">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 1
	</cfquery>
	<cfquery name="getBatchID" datasource="#doclinkprod#">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 13
	</cfquery>
	<cfquery name="getRefNumber" datasource="#doclinkprod#">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 24
	</cfquery>
	<cfquery name="getCompanyCode" datasource="#doclinkprod#">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 25
	</cfquery> --->
	<cfif findinvoices.DocumentTypeID is "8">
		<cfif findinvoices.CompanyCode is "Corp">
			<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonCorpDS#">
					SELECT     Acct, sum(TranAmt) as TranAmtTotal
					FROM         dbo.APTran
					WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#findinvoices.BatchID#') AND (RefNbr = '#findinvoices.Refnumber#')
					group by Acct
			</cfquery>
		<cfelse>
			<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonHousesDS#">
					SELECT     Acct, sum(TranAmt) as TranAmtTotal
					FROM         dbo.APTran (NOLOCK)
					WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#findinvoices.BatchID#') AND (RefNbr = '#findinvoices.Refnumber#')
							AND crtd_prog<>'03400'
					group by Acct
			</cfquery>
		</cfif>
	<cfelse>
		<!--- get gl info from dist stamp --->
		<cfquery name="getSpecificHouseInvoiceAmount" datasource="#doclinkprod#">
			select DS.distStampid, SFV.FieldValue as Acct
			from DistributionStamp DS 
			inner join stampfieldvalue SFV ON DS.distStampID = SFV.distStampID
			where DS.DocumentID = #findinvoices.documentID# and SFV.StampFieldID = 10009 <!--- acct code --->
		</cfquery>
		<cfquery name="getSpecificHouseInvoiceAmount2" datasource="#doclinkprod#">
			select DS.distStampid, SFV.FieldValue as TranAmtTotal
			from DistributionStamp DS 
			inner join stampfieldvalue SFV ON DS.distStampID = SFV.distStampID
			where DS.DocumentID = #findinvoices.documentID# and SFV.StampFieldID = 10011 <!--- amount --->
		</cfquery>
	</cfif>
	<cfoutput>
	<cfif findinvoices.companycode is "corp"><cfset color = "##FFFFCC"><cfelse><cfset color="##C0DCC0"></cfif>
	<tr>
	<td align=right bgcolor="#color#"><font size=-1>#DateFormat(findinvoices.Created,'M/D/YY')#</td>
	<td align=right bgcolor="#color#"><font size=-1>#DateFormat(findinvoices.InvoiceDate,'MM/DD/YY')#</td>
	<td align=right bgcolor="#color#"><font size=-1>#findinvoices.InvoiceNumber#</td>
	<td bgcolor="#color#"><font size=-1>&##160;#findinvoices.VendorName#</td>
	<td align=right bgcolor="#color#"><font size=-1>&##160;<cfloop query="getSpecificHouseInvoiceAmount">#getSpecificHouseInvoiceAmount.Acct#<BR></cfloop></td>
	<td align=right bgcolor="#color#"><font size=-1><cfif findinvoices.DocumentTypeID is "8"><cfloop query="getSpecificHouseInvoiceAmount">#DecimalFormat(getSpecificHouseInvoiceAmount.TranAmtTotal)#<BR></cfloop>
	<cfelse><cfloop query="getSpecificHouseInvoiceAmount2">#DecimalFormat(getSpecificHouseInvoiceAmount2.TranAmtTotal)#<BR></cfloop></cfif></td>
	<td align=right bgcolor="#color#"><cfif findinvoices.DocumentTypeID is "8"><img src="/intranet/doclink/checkmark3.gif"><Cfelse>&##160;</cfif></td>
	</tr>
	</cfoutput>
</cfloop>
</table>
</td>

</Table>

<p>
<cfoutput>
[ <A HREF="labortracking.cfm?subAccount=#SubAccountNumber#&datetouse=#DateFormat(firstdayofdatetouse,'mmmm yyyy')#">Labor Tracking Report</A> | <A HREF="expensespenddown.cfm?subAccount=#SubAccountNumber#&datetouse=#DateFormat(firstdayofdatetouse,'mmmm yyyy')#">Expense Spend-down</A> | <A HREF="housereport.cfm?subAccount=#SubAccountNumber#&workingmonth=#firstdayofdatetouse#">House Report</A> | <A HREF="default.cfm?iHouse_ID=#url.iHouse_ID#&monthtouse=#DateFormat(firstdayofdatetouse,'mmmm yyyy')#">Budget Sheet</A> ]
<!--- <p><BR>
<center><font size=-1>[ <A href="/intranet/logout.cfm"><font color="##0033CC">Logout</font></A> |  <a href="/doclink/doclinksearch.cfm">Search Doclink</a> | <A HREF="doclink/readscans.cfm">Key-in Invoices</A> | <a href="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</a> ]</font></center> --->

</cfoutput>
</body>
</html>
