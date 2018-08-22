<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--- 
|Sfarmer     |02/17/2017  | Create report of items being updated in Invoices   |
 --->
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>AdminApprovalPrint</title>
</head>
 
	<cfparam default="" name="SelPeriod">
	<cfif SelPeriod is ''>
	Please select a TIPS period for the report<br />
	<a href="../Reports/Menu.cfm">Return to Reports Menu</a>
	<cfabort>
	</cfif>
	<cfquery name="qryAdminApproval"  datasource="#APPLICATION.datasource#">
		SELECT  iAccountingApproval_id,iAccountingPeriod,cDivision,cRegion,cCommunityName,cTenantName
		,iTenant_id,cSolomonkey,iInvoicemaster_ID,iChargetype_id,cDescription,cAction,iNewQuantity,iOldQuantity 
		,mNewAmount,mOldAmount ,mNewAmtTotal,cComments,iNewDetailID,iOldDetailID
		,iHouse_id,cAppliestoacctperiod ,dtRowStart,dtRowEnd, dtEntered
		FROM TIPS4.dbo.AccountingApprovalChanges
		where iAccountingPeriod = #SelPeriod#
	</cfquery>
	<body>
		<cfoutput>	 
		<cfdocument  format="PDF" orientation="landscape" margintop="1" marginbottom="1" marginleft=".5" marginright=".5">
			<cfdocumentitem type="header"  evalAtPrint="true">   
				<table width="100%">
					<tr>
						<td style="text-align:left;"> <img src="../images/Enlivant_logo.jpg" width="115" height="75" ></td>
						<td align="center">
								<h3 style="text-align:center;">Approved Selected BSF and Care Changes<br />
								TIPS Accounting Period: #qryAdminApproval.cappliestoacctperiod#</h3>
						</td>
						<td  nowrap="nowrap" style="text-align:right;">Date: <br />#dateformat(now(),'mm/dd/yyyy')#</td>
					</tr>
				</table>
				<table width="100%" >
					<tr> 
						<th style="width:6%; text-align:left;" >Division</th>
						<th style="width:19%; text-align:center;">Region</th>
						<th style="width:14%; text-align:left;">Community</th>
						<th style="width:14%; text-align:left;">Resident</th>
						<th style="width:8%; text-align:left;" >SolomonID</th>
						<th style="width:15%;">Description</th>
						<th style="width:7%;" >Action</th>
						<th style="width:9%; text-align:right;">New Amount</th>
						<th style="width:8%; text-align:right;" >Acct Period</th>
					</tr>
				</table>
			 </cfdocumentitem>  
				<table width="100%" >
		 			<CFLOOP  query="qryAdminApproval">
						<tr>	 
							<td style="text-align:center; font-size:10px;width:6%;" >#cDivision#</td>
							<td style="text-align:center; font-size:10px;width:19%;">#cRegion#</td>
							<td style="text-align:left; font-size:10px;width:14%;"  >#cCommunityName#</td>
							<td style="text-align:left; font-size:10px;width:14%;"  >#cTenantName#</td>
							<td style="text-align:left; font-size:10px;width:8%;"   >#cSolomonKey#</td>
							<td style="text-align:left; font-size:10px;width:15%;"   >#cdescription#</td>
							<td style="text-align:center; font-size:10px;width:7%;" >#cAction#</td>
							<td style="text-align:right;font-size:10px;width:9%;"   >#LSCurrencyFormat(mNewAmtTotal)#</td>
							<td style="text-align:right; font-size:10px;width:8%;"  >#cappliestoacctperiod#</td>
						</tr>
				  	</CFLOOP> 
				</table>	
			 	<cfdocumentitem type="footer"  evalAtPrint="true">  
			 		<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>  
						<table width="100%">
						<tr>
							<td>Approved Selected BSF and Care Changes</td>
							<td style="text-align:center">Enlivant</td>
							<td style="text-align:right">
								Page  #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#  
							</td>
						</tr>
						</table>
 					<cfelse>
						<table width="100%">
						<tr>
							<td>Approved Selected BSF and Care Changes</td>
							<td a style="text-align:center">Enlivant</td>
							<td style="text-align:right">
							Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
							</td>
						</tr>
						</table>		
					</cfif>  
 				</cfdocumentitem>
				<cfheader name="Content-Disposition"   
					value="attachment;filename=ApprovedSelectedBSFandCareChanges-#qryAdminApproval.cappliestoacctperiod#.pdf"> 
			</cfdocument>  
		</CFOUTPUT>
	</body>
</html>
