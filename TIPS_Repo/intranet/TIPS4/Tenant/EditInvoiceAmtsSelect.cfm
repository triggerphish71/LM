<!---  -----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                               |
|------------|------------|---------------------------------------------------------------------------|
|S Farmer    | 08-1-2013  | Program to allow AR to directly edit mInvoiceTotal and mLastInvoiceTotal  |
|            |            | Ticket#109105                                                             |
-------------------------------------------------------------------------------------------------- ---><html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Edit Invoice Amount</title>
</head>
	<cfinclude template="../../header.cfm">
	<h1 class="PageTitle"> Tips 4 - Tenant EFT House </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
<cfquery name="qryInvoice" datasource="#application.datasource#">
Select t.cfirstname, t.clastname, h.cname, im.mlastinvoicetotal, im.minvoicetotal 
, t.csolomonkey, im.cappliestoacctperiod, im.iinvoicenumber, im.iinvoicemaster_id
from invoicemaster im
	join tenant t on t.csolomonkey = im.csolomonkey
	join house h on t.ihouse_id = h.ihouse_id
where iinvoicemaster_id = #IMID#
</cfquery>
<body>
 
	<cfoutput query="qryInvoice">
		<form name="editamt" action="EditInvoiceAmtAction.cfm" method="post">
			<input type="hidden" name="csolomonkey" value="#csolomonkey#" />
			<input type="hidden" name="iinvoicenumber" value="#iinvoicenumber#" />
			<input type="hidden" name="iinvoicemasterid" value="#IMID#" />	
 				
			<table>
				<tr  style="background-color:##FFFF99">
					<td>Name:<br /> #cfirstname# #clastname#</td>
					<td>House:<br /> #cname#</td>
					<td>RID:<br /> #csolomonkey#</td>
					<td>Acct. Period:<br /> #cappliestoacctperiod#</td>
					<td>Invoice Number:<br /> #iinvoicenumber#</td>
				</tr>
				<tr >
					<td>Previous Invoice Total:</td>
					<td>#dollarformat(mlastinvoicetotal)#</td>
					<td>Change To:</td>
					<td><input name="newlastinvoicetotal" value="#numberformat(mlastinvoicetotal, 99999.99)#" /></td>
					<td>&nbsp;</td>
				</tr>
				<tr style="background-color:##FFFF99">
					<td>Invoice Total:</td>
					<td>#dollarformat(minvoicetotal)#</td>
					<td>Change To:</td>
					<td><input name="newinvoicetotal" value="#numberformat(minvoicetotal, 99999.99)#" /></td>
					<td>&nbsp;</td>
				</tr>
				<tr>
					<td colspan="5" style="text-align:center"><input type="submit" name="submit" value="Submit" /></td>
				</tr>
			</table>
		
		</form>
	</cfoutput>
</body>
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		
