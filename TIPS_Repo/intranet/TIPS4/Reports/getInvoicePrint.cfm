<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
		<cfquery name="qryResidentID" datasource="#application.datasource#">
			Select h.cname   'House',h.ihouse_id, t.cfirstname, t.clastname,t.csolomonkey
			, t.itenant_id,
				 ts.dtMoveOutProjectedDate ,ts.dtMoveOut
				 ,ts.dtNoticeDate ,ts.dtChargeThrough
				 ,im.cAppliesToAcctPeriod
				 ,im.mInvoiceTotal, im.mLastInvoiceTotal, iinvoicemaster_id, iinvoicenumber
				 ,im.bMoveInInvoice
			from tenant t 
				join tenantstate ts on t.itenant_id = ts.itenant_id
				join house h on h.ihouse_id = t.ihouse_id
				join invoicemaster im on im.csolomonkey = t.csolomonkey and im.dtrowdeleted is null
			where t.csolomonkey = #prompt0#	
			and  im.cAppliesToAcctPeriod = #prompt2#
			and im.dtrowdeleted is null
			order by im.cappliestoacctperiod desc, im.dtinvoicestart desc
		</cfquery>
<body>
#prompt0# :: #prompt2#
<cfif qryResidentID.bMoveInInvoice is 1>
	<cflocation url="../Reports/InvoiceReport.cfm?prompt0=#qryResidentID.iTenant_ID#&prompt2=#prompt2#">
		<form name="MoveInSummary" action="MoveInSummary.cfm" method="POST">
 
			<!--- (#Tenants.cSolomonKey#) --->
			<input type="hidden" name="prompt0" value="#Tenants.iTenant_ID#">  
 
		
		<td style="width: 25%;"><input type="Button" name="Go" value="GO" style="font-size: 12; color: navy; height: 20px; width: 30px;" onClick="submit(); return false;"></td>
		</form>	
<cfelse>
	<cflocation url="../Reports/InvoiceReport.cfm?prompt0=#prompt0#&prompt2=#prompt2#">
</cfif>

	<cflocation url="EditInvoiceAmts.cfm?solomonid=#prompt0#">
<!--- 		<form name="Invoices"  action="../Reports/InvoiceReport.cfm" method="GET">
			<cfoutput>
				<table>
					<tr>
						<td style="text-align:center" style="background-color:##CCFF99">View Invoice</td>
						<input type="hidden" name="prompt0" value="#solomonid#">
					</tr>
					<tr>
						<td>Select Period:
							<select name="prompt2">
								<cfloop query="qryResidentID">
									<cfscript>
										TIPSPeriod = Year(session.TIPSMonth) & DateFormat(session.TIPSMonth,"mm");
										if (TIPSPeriod EQ qryResidentID.cAppliesToAcctPeriod) { Selected = 'Selected'; } else { Selected = ''; }
									</cfscript>
									<option value="#qryResidentID.cAppliesToAcctPeriod#" #SELECTED#> #qryResidentID.cAppliesToAcctPeriod# </option>
								</cfloop>
							</select>	
						</td>
					</tr>
					<tr style="background-color:##CCFF99">
						<td style="text-align:center"><input type="Button" name="Go" value="View Invoice" style="font-size: 12; color: navy; height: 20px; width: 150px;" onClick="submit(); return false;"></td>
					</tr>
				</table>
			</cfoutput>
		</form> --->
</body>
</html>
