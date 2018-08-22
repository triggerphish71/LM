<!---  -----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                               |
|------------|------------|---------------------------------------------------------------------------|
|S Farmer    | 08-1-2013  | Program to allow AR to directly edit mInvoiceTotal and mLastInvoiceTotal  |
|            |            | Ticket#109105                                                             |
|MStriegel   | 03/10/2018 | Converted the query to use a cfc                                          |
-------------------------------------------------------------------------------------------------- --->
<!--- mstriegel 3/10/2018 --->
<cfset oTenantARServices = CreateObject("component","intranet.TIPS4.CFC.components.Tenant.tenantARServices")>
<!--- end mstriegel 3/10/2018--->

<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Edit Move Out Dates</title>
</head>
	<cfinclude template="../../header.cfm">
	

<h1 class="PageTitle"> Tips 4 - Tenant Edit Invoice Amounts </h1>
	
	<cfinclude template="../Shared/HouseHeader.cfm">
	
	<cfparam  name="solomonid" default="">

	<cfif isdefined("solomonid") AND solomonid is ''>
		<form name="submitname" method="post" action="EditInvoiceAmts.cfm">
 			<table>
				<tr style="background-color:#FFFF99">
					<td>Enter Resident ID (Solomon Key):</td>
					<td  style="text-align:left; "><input type="text" name="solomonid" id="solomonid" value="" size="12" /></td>
				</tr>
				<tr>
					<td colspan="2" style="text-align:center"><input type="submit" name="submit" value="Submit" /></td>
				</tr>
			</table>
		</form>
	<cfelse>
	<!--- mstriegel 3/10/2018 --->
	<cfset qryResidentID = oTenantARServices.getResidentInvoiceInfoByKey(solomonid=solomonid)>		
	<!--- end mstriegel 3/10/2018--->

		<form name="selInvoice" method="post" action="EditInvoiceAmtsSelect.cfm">
		<table>
			<cfoutput query="qryResidentID" group="cfirstname">
			<input type="hidden" name="csolomonkey" value="#csolomonkey#" />
			<input type="hidden" name="tenantid" value="#itenant_id#"/>
			<input type="hidden" name="cfirstname" value="#cfirstname#"/>
			<input type="hidden" name="clastname" value="#clastname#"/>
			<input type="hidden" name="ihouseid" value="#ihouse_id#"/>
				<tr>
					<td colspan="4" style="text-align:left">Name: #cfirstname# #clastname# : #csolomonkey#</td>
				</tr>
				<tr>
					<td colspan="4"  style="color:##FF0000; font-weight:bold ">NOTE: Account for any Late Fees before changing Invoice Totals or Last Invoice Totals.</td>
				</tr>
				<tr style="background-color:##FFFF99">
					<td >Invoices:</td>		
					<td >&nbsp;</td>	
					<td >&nbsp;</td>
					<td >&nbsp;</td>	
				</tr>
				<tr style="background-color:##FFFF99">
					<td style="text-align:center"> Acct Period </td>
					<td style="text-align:center"> Previous Balance </td>
					<td style="text-align:center"> Invoice Amount </td>
					<td style="text-align:center">Select </td>
				</tr>
		 	<cfoutput>
				
				 <cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
					<td style="text-align:center">#cappliestoacctperiod#</td>
					<td style="text-align:center">#dollarformat(mLastInvoiceTotal)#</td>
					<td style="text-align:center">#dollarformat(mInvoiceTotal)#</td>
					<td style="text-align:center"><input type="radio" name="selinv" id="iselinv" onClick="self.location.href='EditInvoiceAmtsSelect.cfm?IMID=#iinvoicemaster_id#&iinvoicenumber=#iinvoicenumber#&csolomonkey=#csolomonkey#'" /></td>
					<input type="hidden" name="invoicenumber" id="invoicenumber" value="#iinvoicenumber#" />
					<input type="hidden" name="iinvoicemasterid" id="iinvoicemasterid" value="#iinvoicemaster_id#" />
				</tr>
				

			</cfoutput> </cfoutput>
				<!--- <tr>
					<td colspan="2" style="text-align:center"><input name="submit" type="submit" value="Submit" /></td>											
				</tr> --->
		</table>
		</form>
		<!--- mstriegel 02/3/13/2018 --->
		<!--- removed because these are old crystal reports that were not converted yet 
		<form name="Invoices"  action="../Reports/InvoiceReport.cfm" method="GET">
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
					<!--- <tr>
						<td>Comments: <input type="TEXT" name="cComments" value=""></td>
					</tr> --->

					<tr style="background-color:##CCFF99">
						<td style="text-align:center">
						<input type="Button" name="Go" value="View Invoice" style="font-size: 12; color: navy; height: 20px; width: 150px;" onClick="submit(); return false;"></td>
					</tr>
				</table>
			</cfoutput>
		</form>		--->
		<!--- end mstriegel --->
	</cfif>

<!--- mstriegel 3/10/2018 --->
	<cfif isDefined("qryResidentID.iresidencytype_ID") AND qryResidentID.iResidencyType_ID EQ 3>
		<form name="rtnEditPage" id="rtnEditPage" method="post" action="tenantAREdit.cfm" >
			<table style="background-color:#FFFF00">
				<cfoutput><input  type="hidden" name="solomonid" id="solomonid" value="#solomonid#" /></cfoutput>
				<TR>
					<TD  style="text-align:center"><input type="submit" name="SUBMIT" value="Return to Edit Selection Page" /></TD>
				</TR> 
			</table>
		</form>		
	</cfif>
	<!--- end mstriegel 3/10/2018--->
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		
	
 
