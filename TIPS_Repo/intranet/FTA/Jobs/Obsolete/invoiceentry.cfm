<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>FTA Invoice Entry</title>
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
	
<!--- show house dropdown if subaccount is 0 --->
<cfif FindSubAccount.company is 0>
	<cfquery name="getHouses" datasource="TIPS4">
	select cName, iHouse_ID from HOUSE where dtRowDeleted IS NULL order by cName
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
</cfif>

<cfquery name="LookUpSubAcct" datasource="#SolomonHousesDS#">
		select CnyName from XBANKINFO where SubAcct = '#SubAccountNumber#'
	</cfquery>
	
<cfif not isDefined("url.datetouse")><cfset monthnowmonth = "Yes"></cfif>	
<cfparam name="datetouse" default="#NOW()#">
<cfset monthforqueries = #DateFormat(datetouse,'mmm')#>
<cfset yearforqueries = #DateFormat(datetouse,'yyyy')#>
<cfset firstdayofdatetouse = "#DateFormat(datetouse,'mm')#/01/#DateFormat(datetouse,'yyyy')# 00:00:00">
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
<h3>FTA Invoice Entry- #LookUpSubAcct.CnyName#</h3>

What month would you like to view approved/processed invoices for?<BR>
<font size=-1><i>It takes a minute or two for a new month to come up, please be patient.<BR></i></font>

<cfset x = DateFormat(NOW(),'mmmm yyyy')>
<cfset y = "March 2004">
<select name="datetouse2" onchange="doSel(this)"><option value=""></option><cfloop condition="#DateCompare(x,y,'m')# GTE 0"><option value="location.href='invoiceentry.cfm?<cfif isDefined("url.iHouse_ID")>iHouse_ID=#url.iHouse_ID#&</cfif>DateToUse=#DateFormat(x,'mmmm yyyy')#'"<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> SELECTED</cfif>>#DateFormat(x,'mmmm yyyy')#</option><cfset x = #DateAdd('m',-1,x)#></cfloop></select>
<cfset themonth = #month(datetouse)#><cfset themonth = monthAsString(#themonth#)><cfset dim = #daysinmonth(datetouse)#>
</cfoutput>
<p>
<font size=-1>
You can use this table as a helper to fill out your Excel FTA. It may not be perfect, but it should contain most everything you need to get an accurate representation of your invoice expendature for your FTA.  Note that this only contains Processed/Approved AP Invoices.  Just print out this page and use it as a guideline.  You can type into your Excel FTA exactly as the data is shown below.   Do NOT attempt to copy and paste because it won't work.
<p>
<!--- Or if you prefer, you can copy and paste this info from the table below into the table in your "Invoice Entry" worksheet of your Excel FTA.  You'll have to take care that you select the proper number of rows to highlight and paste into on your excel worksheet. Look underneath the table below to see how many rows you will need to cut and paste into.  To begin cutting and pasting, put your mouse right before the first row's first day of the month (column A) and click (holding the click) and drag your mouse down to the last row's GL Code (column E).  Then let go of the click and hit Control-C on your keyboard.  Do not cut and paste the white header row that contains the column descriptions.  Then go to the "Invoice Entry" excel worksheet in your FTA and highlight (click and drag) the same 5 columns and the appropriate number of rows.  You can then hit Control-V on your keyboard to paste.  If you get a pop up box that says: <em>"Data on the clipboard is not the same size and shape, do you want to paste anyway?"</em>  Hit yes.  Confirm that you cut and pasted all rows from this web page onto your excel FTA worksheet.  You will then have to cut and paste the last column for "Invoice Amount" into the "I" column of your excel worksheet.  The reason they have to be cut and pasted seperately is because there are hidden F, G & H columns in the Excel worksheet that can't be pasted into.  --->
<p>
Green rows are House Vendors, Yellow rows are Corporate Vendors.</font>
<P>
<cfquery name="findinvoices" datasource="doclink2">
SELECT     D.Created, D.DocumentID, (select count(PCV.PropertyCharValue) from PropertyCharValues PCV where PCV.ParentID = P.ParentID and PCV.PropertyID = 18) as SubAcctCount
FROM         dbo.PropertyCharValues P
inner join dbo.Documents D ON P.ParentID = D.DocumentID
WHERE     (P.PropertyCharValue = '#SubAccountNumber#' AND P.PropertyID = 18)
and D.Created between '#firstdayofdatetouse#' and '#lastdayofdatetouse#'
and D.DocumentTypeID = 8
order by D.Created
</cfquery>

<Table border=0><td valign=top>
<table border=1 cellspacing=0 cellpadding=3>
<tr>
<th>Day of Month<!--- <cfoutput>#themonth#</cfoutput> ---></th><th>Date of Invoice</th><th>Invoice #</th><th>Vendor</th><th>GL Code</th><th>Invoice Amount</th>
</tr>
<cfif findinvoices.recordcount is "0">
	<tr>
	<td colspan=6 align=center><em><font size=-1 color="red">Sorry, no invoices for the specified month were found.</font></em></td>
	</tr>
</cfif>
<cfloop query="findinvoices">
	<!--- obtain other property data --->
	<cfquery name="getInvoiceDate" datasource="doclink2">
		select PropertyID, PropertyDateValue from PropertyDateValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 20
	</cfquery>
	<cfquery name="getInvoiceNumber" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 3
	</cfquery>
	<cfquery name="getVendorName" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 1
	</cfquery>
	<cfquery name="getBatchID" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 13
	</cfquery>
	<cfquery name="getRefNumber" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 24
	</cfquery>
	<cfquery name="getCompanyCode" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 25
	</cfquery>
	<cfif getCompanyCode.propertyCharValue is "Corp">
		<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonCorpDS#">
				SELECT     Acct, sum(TranAmt) as TranAmtTotal
				FROM         dbo.APTran
				WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
				group by Acct
		</cfquery>
	<cfelse>
		<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonHousesDS#">
				SELECT     Acct, sum(TranAmt) as TranAmtTotal
				FROM         dbo.APTran (NOLOCK)
				WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
						AND crtd_prog<>'03400'
				group by Acct
		</cfquery>
	</cfif>
	<cfoutput>
	<cfif getCompanyCode.propertycharvalue is "corp"><cfset color = "##FFFFCC"><cfelse><cfset color="##C0DCC0"></cfif>
	<tr>
	<td align=right bgcolor="#color#"><font size=-1>#DatePart('d',findinvoices.Created)#</td><td align=right bgcolor="#color#"><font size=-1>#DateFormat(getInvoiceDate.PropertyDateValue,'MM/DD/YY')#</td><td align=right bgcolor="#color#"><font size=-1>#getInvoiceNumber.PropertyCharValue#</td><td bgcolor="#color#"><font size=-1>&##160;#getVendorName.PropertyCharValue#</td><td align=right bgcolor="#color#"><font size=-1>&##160;<cfloop query="getSpecificHouseInvoiceAmount">#getSpecificHouseInvoiceAmount.Acct#<BR></cfloop></td><td align=right bgcolor="#color#"><font size=-1><cfloop query="getSpecificHouseInvoiceAmount">#DecimalFormat(getSpecificHouseInvoiceAmount.TranAmtTotal)#<BR></cfloop></td>
	</tr>
	</cfoutput>
</cfloop>
</table>
</td>
<!--- <td>&#160; &#160; &#160; &#160; &#160; &#160; &#160; &#160; </td>
<td valign=top>
<table border=1 cellspacing=0 cellpadding=3>
<tr>
<th>Invoice Amount</th>
</tr>
<cfset invoicecount = "0">
<cfloop query="findinvoices">
	<cfquery name="getBatchID" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 13
	</cfquery>
	<cfquery name="getRefNumber" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 24
	</cfquery>
	<cfquery name="getCompanyCode" datasource="doclink2">
		select PropertyID, PropertyCharValue from PropertyCharValues
		WHERE     ParentId = #findinvoices.documentID# and PropertyID = 25
	</cfquery>
	<cfif getCompanyCode.propertyCharValue is "Corp">
		<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonCorpDS#">
				SELECT     Acct, sum(TranAmt) as TranAmtTotal
				FROM         dbo.APTran
				WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
				group by Acct
		</cfquery>
	<cfelse>
		<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonHousesDS#">
				SELECT     Acct, sum(TranAmt) as TranAmtTotal
				FROM         dbo.APTran
				WHERE     (Sub = '#SubAccountNumber#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
				group by Acct
		</cfquery>
	</cfif>
	<cfoutput>
	<cfif getCompanyCode.propertycharvalue is "corp"><cfset color = "##FFFFCC"><cfelse><cfset color="##99CCFF"></cfif>
	<tr>
	<td align=right bgcolor="#color#"><font size=-1>&##160;<cfloop query="getSpecificHouseInvoiceAmount">#DecimalFormat(getSpecificHouseInvoiceAmount.TranAmtTotal)#<cfset invoicecount = #invoicecount# + 1><BR></cfloop></td>
	</tr>
	</cfoutput>
</cfloop>
</table>
</td> --->
<!--- <tr>
<td align=center colspan=3><BR>
<strong>You will need to cut and paste into<cfoutput> #invoicecount#</cfoutput> rows on your Excel Worksheet.</strong>
</td>
</tr> --->
</Table>


<p><BR>
<center><font size=-1>[ <A href="/intranet/logout.cfm"><font color="##0033CC">Logout</font></A> |  <a href="/doclink/doclinksearch.cfm">Search Doclink</a> | <A HREF="doclink/readscans.cfm">Key-in Invoices</A> | <a href="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</a> ]</font></center>

</body>
</html>
