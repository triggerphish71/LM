<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>TenantCharges</title>
	
	<style>
	.headings {
	border-bottom: .5px solid black;
	 text-align:center; 
	 font-size:9px;
	 font-weight:bold;
	}
	</style>
</head>
<!--- TenantCharges<br />
 #prompt1#  ,  #prompt2#<br /> --->
<cfoutput>
	<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
		SELECT	H.iHouse_ID, H.cNumber, OA.cNumber as OPS, R.cNumber as Region, h.cName
		,h.caddressline1, h.caddressline2, h.cstatecode, h.ccity, h.czipcode, h.cphonenumber1
		,oa.cname as OpsName, r.cname as RegionName
		FROM	House H
				JOIN	OPSArea OA
				ON	OA.iOPSArea_ID = H.iOPSArea_ID
				JOIN	Region R
				ON	OA.iRegion_ID = R.iRegion_ID
		WHERE	iHouse_ID = #prompt1#	
	</CFQUERY>
	<cfset thisScopeName = #HouseData.cname#>
	<cfset thisAcctPeriod = '#prompt2#' >
	<cfset thisShowResidents = 'Y' >
	<cfset thischargetype = ''>
	<cfSET	thisChargeTypeDesc = 'All Charge Types'>
<!--- 		EXEC rw.sp_TenantCharge
		thisScope = N'Allen Place',
		thisAcctPeriod = N'201510',
		thisShowResidents = N'Y' --->
	<cfquery name="sp_TenantCharge" datasource="#application.datasource#"> 
		Select Distinct	ten.cLastName, ten.cFirstName, ten.iTenant_ID, ten.cSolomonKey, hse.cNumber, hse.cName, 
				inm.cAppliesToAcctPeriod, inm.iInvoiceNumber, inm.iInvoiceMaster_ID, inm.dtInvoiceEnd,
				ind.iQuantity, ind.cDescription, ind.mAmount, ind.cComments, ind.dtRowStart
				, ind.cAppliesToAcctPeriod detailAppliesToAcctPeriod,
				aa.cAptNumber, ct.cGLAccount, RegionNumber, RegionName, OpsNumber, OpsName,
				hse.cAddressLine1, hse.cCity, hse.cStateCode, hse.cZIPCode, hse.cPhoneNumber1, ind.iRowStartUser_ID,
				case when ind.iRowStartUser_ID = 0 then 'System' when u.username is null then 'Unknown' 
				else u.username end UserName,
				'All' ChargeTypeDesc
		
		From 		rw.vw_Tenant_History ten 
		
		Join 		rw.vw_reg_ops_House hse 
		ON		ten.iHouse_ID = hse.HouseID
		and 		hse.dtHouseDeleted Is NULL
		and 		hse.dtOpsAreaDeleted Is NULL
		and 		hse.dtRegionDeleted Is NULL
		
		Join 		InvoiceMaster inm 
		ON		ten.cSolomonKey = inm.cSolomonKey
		and		inm.cAppliesToAcctPeriod = '#prompt2#'
		and 		inm.dtRowDeleted Is NULL
		and 		inm.bMoveInInvoice Is NULL
		and		inm.bMoveOutInvoice Is NULL
		and		isNULL(inm.dtInvoiceEnd, GetDate()) between ten.dtRowStart and IsNULL(ten.dtRowEnd,GetDate()) 	
		
		Join 		rw.vw_TenantState_History tens 
		ON		ten.iTenant_ID = tens.iTenant_ID
		and		isNULL(inm.dtInvoiceEnd, GetDate()) between tens.dtRowStart and IsNULL(tens.dtRowEnd,GetDate())
		
		Join 		AptAddress aa 
		ON		tens.iAptAddress_ID = aa.iAptAddress_ID
		
		Join 		InvoiceDetail ind 
		ON		ten.iTenant_ID = ind.iTenant_ID		
		and 		inm.iInvoiceMaster_ID = ind.iInvoiceMaster_ID
		and 		ind.dtRowDeleted Is NULL	
		 
		LEFT Join	ChargeType ct
		ON		ind.iChargeType_ID = ct.iChargeType_ID
		AND 		isnull(ct.dtRowDeleted, inm.dtRowStart) >= inm.dtRowStart
		
		LEFT JOIN ChargeType ct2
		ON		ind.iChargeType_ID = ct2.iChargeType_ID
		AND		ct2.cgrouping in ('P','R','MR','MC','S','PD','RD')
		
		 
		LEFT JOIN	 DMS.dbo.Users u
		ON		ind.iRowStartUser_ID = u.employeeid
		 
		Join		 House h2
		on		h2.iHouse_ID = ten.iHouse_ID
		
		Where 		ten.dtRowDeleted Is NULL
		AND		ct2.iChargeType_ID is NULL
		 and h2.ihouse_id = #prompt1#
		
		Order BY 	aa.cAptNumber
	</cfquery> 
<!--- #sp_TenantCharge.recordcount#<br /> --->	
 
</cfoutput>
<body>
	<cfsavecontent variable="PDFhtml">
		<cfheader name="Content-Disposition" 
		value="attachment;filename=ResidentChargeSummary-#HouseData.cname#-#prompt2#.pdf">
<!--- 	<table width="100%">
		<cfoutput>
			<tr>
				<td style="font-size:9px" >#HouseData.RegionName#<br />
					&nbsp;&nbsp;#HouseData.OpsName#<br />
					&nbsp;&nbsp;&nbsp&nbsp;&nbsp;&nbsp;#HouseData.cName#
				</td>
			</tr>		
		</cfoutput>		
	</table> --->
	<table width="100%">
			<cfoutput >	
		<tr>
			<td style="font-size:9px" >#HouseData.RegionName#<br />
			&nbsp;&nbsp;#HouseData.OpsName#<br />
			&nbsp;&nbsp;&nbsp&nbsp;#HouseData.cName#
			</td>
			<td colspan="10"></td>		
		</tr>
		<tr>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Resident Name</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Resident ID</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Transaction<br /> Date</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Description</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			GL<br />Acct</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Period</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Units</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Unit Price</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Transaction<br />Amount</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Username</td>
			<td  style="border-bottom: .5px solid black;text-align:center;font-size:9px;font-weight:bold;">
			Item Comments</td>
		</tr>
 <cfset regiontotal = 0>
 <cfset divisiontotal = 0>
 <cfset housetotal = 0>
 <cfset grandtotal = 0>

			<cfset netamount = 0>
			<cfloop  query="sp_TenantCharge">
				<tr>
					<td style="font-size:10px">#cFirstName# #cLastName# </td>
					<td style="font-size:10px">#cSolomonKey#</td>  
					<td style="font-size:10px"> #dateformat(dtRowStart,'mm/dd/yyyy')#</td>
					<td style="font-size:10px">#cDescription#</td> 
					<td style="font-size:10px">#cGLAccount#</td>			
					<td style="font-size:10px">#cAppliesToAcctPeriod#</td>
					<td style="text-align:center; font-size:10px">#iQuantity#</td>
					<td style="font-size:10px">#dollarformat(mAmount)#</td>
					<cfset netamount = #iQuantity# * #mAmount#>
					<cfset regiontotal = regiontotal + netamount>
					<cfset divisiontotal = divisiontotal + netamount>
					<cfset housetotal = housetotal + netamount>
					<cfset grandtotal = grandtotal + netamount>					
					<td style="font-size:10px">#dollarformat(netamount)#</td> 
					<td style="font-size:10px">#UserName#</td>
					<td style="font-size:10px">#cComments#</td>
				</tr>
			</cfloop>
			<tr>
				<td colspan="3" nowrap="nowrap" style="font-size:10px">&nbsp;&nbsp;&nbsp;&nbsp;#HouseData.Cname#</td>
				<td colspan="5">&nbsp;</td>
				<td style="border-top: .5px solid black;font-size:10px">#Dollarformat(housetotal)#</td>
			</tr>
			<tr>
				<td style="font-size:10px">&nbsp;&nbsp;#HouseData.OpsName#</td>
				<td colspan="7">&nbsp;</td>
				<td style="border-top: .5px solid black;font-size:10px">#Dollarformat(regiontotal)#</td>
			</tr>	
			<tr>
				<td style="font-size:10px">#HouseData.RegionName#</td>
				<td colspan="7">&nbsp;</td>
				<td style="border-top: .5px solid black;font-size:10px">#Dollarformat(divisiontotal)#</td>
			</tr>	
			<tr>
				<td style="font-size:10px">Grand Total</td>
				<td colspan="7">&nbsp;</td>
				<td style="border-top: .5px solid black; font-size:10px">#Dollarformat(grandtotal)#</td>
			</tr>	
			</cfoutput> 							
		</table>
	</cfsavecontent> 	
	<cfdocument format="PDF" orientation="portrait" margintop="1" >	
	<cfdocumentsection>
		<cfdocumentitem type="header" >  
		<cfoutput>
			<table width="100%">
  			<tr>
				<td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
			</tr> 
			<tr>
				<td colspan="5">
					<h1 style="text-decoration:underline; text-align:center">Resident Charge Summary</h1>
				</td>
			</tr>
			<tr>
				<td> <img src="../../images/Enlivant_logo.jpg"  height="750"  width="1000" /></td>
				<td style="text-align:left"><h2>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#</h2>
				</td>
				<td colspan="2" style="text-align:left">
				<td style="font-size:12px;"> <h2>Invoice Month:
					<cfif right(#prompt2#,2) is 01>
					January, #left(prompt2,4)#
					<cfelseif right(#prompt2#,2) is 02>
					February, #left(prompt2,4)#				
					<cfelseif right(#prompt2#,2) is 03>
					March, #left(prompt2,4)#
					<cfelseif right(#prompt2#,2) is 04>
					April, #left(prompt2,4)#				
					<cfelseif right(#prompt2#,2) is 05>
					May, #left(prompt2,4)#				
					<cfelseif right(#prompt2#,2) is 06>
					June, #left(prompt2,4)#
					<cfelseif right(#prompt2#,2) is 07>
					July, #left(prompt2,4)#
					<cfelseif right(#prompt2#,2) is 08>
					August, #left(prompt2,4)#				
					<cfelseif right(#prompt2#,2) is 09>
					September, #left(prompt2,4)#
					<cfelseif right(#prompt2#,2) is 10>
					October, #left(prompt2,4)#				
					<cfelseif right(#prompt2#,2) is 11>
					November, #left(prompt2,4)#
					<cfelseif right(#prompt2#,2) is 12>
					December, #left(prompt2,4)#
					</cfif>
			<br />Charge Type: All Charge Types<br />
							Sort By: Resident Name</h2>
				</td>
			</tr>
			
		</table>

		</cfoutput>		
		</cfdocumentitem> 
		<cfoutput>
			#variables.PDFhtml#
		</cfoutput>		
			<cfdocumentitem  type="footer"  evalAtPrint="true">
				<cfoutput>
					<table  width="95%">
						<tr>
							<td colspan="3" style="font-size:small;text-align:right">
							Page: #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#
							</td>
						</tr>
						<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>
							<tr>
								<td style="font-size:small; text-align:left" >
								ResidentChargeSummary.rpt
								</td>
								<td style="font-size:small; text-align:center">
								Use only as authorized by Enlivant&trade;
								</td>
								<td style="font-size:small; text-align:right">
								Printed: #dateformat(now(), 'mm/dd/yyyy')#
								</td>
							</tr> 
						</cfif>			
					</table>		
				</cfoutput>
			</cfdocumentitem>
	</cfdocumentsection>
</cfdocument>	
</body>
</html>
