<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer    |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports  |
|sfarmer    | 2017-05-09 | 'move out date' changed to 'physical move out date'              |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>MoveOutInvoiceReport</title>
</head>
<cfoutput>
	<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
		SELECT	H.cNumber
		, h.caddressline1
		, h.ccity
		, h.cstatecode
		,h.czipcode
		, h.cname
		,h.cphonenumber1
		, OA.cNumber as OPS
		, R.cNumber as Region
		FROM	House H
		JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
		JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
		WHERE	H.dtRowDeleted IS NULL	
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	</CFQUERY>
<CFQUERY NAME="MoveOutInfo" DATASOURCE = "#APPLICATION.datasource#">
	select distinct IM.iInvoiceMaster_ID
	,im.csolomonkey
	,IM.cComments as InvoiceComments
	,case when IM.dtInvoiceEnd is null then NULL else dateadd(second, 1, IM.dtInvoiceEnd) end dtInvoiceEnd
	,IM.dtInvoiceStart
	,IM.iInvoiceNumber, mLastInvoiceTotal as PastDue
	,IM.cAppliesToAcctPeriod, IM.cSolomonKey
	from InvoiceMaster IM
	join InvoiceDetail INV	ON (INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID AND INV.dtRowDeleted IS NULL)
	where INV.iTenant_ID = #ID#
	and bMoveOutInvoice IS NOT NULL and IM.bFinalized is null and IM.dtRowDeleted IS NULL

</CFQUERY>	

	<cfquery name="qryTenant"  datasource="#application.datasource#">
	select t.itenant_id, t.cfirstname, t.clastname, t.bisPayer , t.csolomonkey
	,ts.dtmovein, ts.dtrenteffective, ts.dtmoveout,ts.dtNoticeDate,ts.dtChargeThrough
	, t.cbillingtype, t.cchargeset
	,t.cfirstname + ' ' + t.clastname as Residentname, ts.bUsesEFT
	,apt.cAptNumber
	,atyp.cdescription as 'ApartmentType'
	 from tenant t
	 join tenantstate ts on t.itenant_id = ts.itenant_id
	 Join AptAddress apt on ts.iAptAddress_ID = apt.iAptAddress_ID
	 join AptType atyp on apt.iAptType_ID = atyp.iAptType_ID
		where t.csolomonkey = '#MoveOutInfo.csolomonkey#'
	</cfquery>
	<cfquery name="sp_MoveOutInvoice" datasource="#application.datasource#">
		EXEC rw.sp_MoveOutInvoice
			@TenantID = #qryTenant.itenant_id#,
		@iInvoiceMaster_ID = #MoveOutInfo.iInvoiceMaster_ID#  
	</cfquery> 	


	<cfquery name="qryTenantContact"  datasource="#application.datasource#">
	select top 1 *
	from linktenantcontact ltc
	join contact cont on  ltc.icontact_id = cont.icontact_id
	and ltc.bispayer = 1
	where ltc.itenant_id = #qrytenant.itenant_id#
	and cont.dtrowdeleted is null and ltc.dtrowdeleted is null
	order by ltc.dtrowstart
	</cfquery>	
</CFOUTPUT>

<body> 
	<cfdocument  format="PDF" orientation="portrait" margintop="1" marginbottom="2" marginleft="1" marginright="1">
 
	<cfdocumentitem type="header" >  
		<cfoutput>
			<table width="100%">
				<tr>
					<td width="30%" > <img src="../../images/Enlivant_logo.jpg"/></td>
					<td  width="50%" style="font-weight:bold; text-decoration:underline; text-align:center">
					<h1>MOVE OUT SUMMARY</h1>
					</td>
					<TD>&nbsp;</TD>
				</tr>
				<tr>	
					<td>
					<h2>#HouseData.cname#    <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
					</h2>
					</td>
					<TD>&nbsp;</TD>
					<TD>
					<h2>For questions regarding this account, please contact us at (888) 252-5001, extension 8992.</h2>
					</td>
				</tr>
			</table>
		</cfoutput>	
	</cfdocumentitem> 
	

	<cfoutput>
 	<cfset paymnttotal = 0>
 	<cfset chargestotal = 0>
 
 
<table  width="95%" style="border-bottom:thin">
 
 
		<tr>
		<td style="font-size:12px;">Account Number:</td>
		<td style="font-size:12px;">#qryTenant.csolomonkey#</td>
		<td style="font-size:12px;">Unit Number:</td>
		<td style="font-size:12px;">#qryTenant.cAPtNumber#</td>
		<td style="font-size:12px;">Notice Date:</td>
		<td style="font-size:12px; text-align:right;">#dateformat(qryTenant.dtnoticedate,'m/d/yyyy')#</td>
		</tr>
 
		<tr>
		<td style="font-size:12px;">Tenant Name:</td>
		<td style="font-size:12px; font-weight:bold;">#qryTenantContact.cfirstname#  #qryTenantContact.clastname#</td>
 		<td style="font-size:12px;">Apartment Size:</td>
		<td style="font-size:12px;">#qryTenant.ApartmentType# </td> 
		<td style="font-size:12px;">Physical Move Out Date:</td>
		<td style="font-size:12px; text-align:right;">#dateformat(qryTenant.dtMoveout,'m/d/yyyy')#</td>
		</tr>
		<tr>
		<td style="font-size:12px;">Rent Effective Date::</td>
		<td style="font-size:12px;">#dateformat(qryTenant.dtrenteffective,'m/d/yyyy')#</td>
 		<td style="font-size:12px;">Payment Method:</td>
		<td style="font-size:12px;">#sp_MoveOutInvoice.PaymentMethod#</td> 
		<td style="font-size:12px;">Charge Through Date:</td>
		<td style="font-size:12px; text-align:right;">#dateformat(qryTenant.dtchargethrough,'m/d/yyyy')#</td>
		</tr>		
		<cfif qryTenantContact.bIsPayer is 1>
			<cfif IsNumeric(qryTenantContact.cphonenumber1)>
			<tr>
				<td>Contact Phone Number:</td>
				<td style="font-size:12px;">(#left(qryTenantContact.cphonenumber1,3)#) #mid(qryTenantContact.cphonenumber1,4,3)# - #right(qryTenantContact.cphonenumber1,4)#</td> 
			</tr>
			<cfelse>
			<tr>
				<td>Contact Phone Number:</td>
				<td style="font-size:12px;">#qryTenantContact.cphonenumber1# </td> 
			</tr>
			</cfif>			
		</cfif>
		<tr>
			<td  colspan="6"><hr></td>
		</tr>
</table>
</table>
	</cfoutput>	

	<cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			<table width="100%">
<cfif #cfdocument.currentpagenumber# is #cfdocument.totalpagecount#>				

 					<tr>
						<td colspan="2"  style="text-align:center; font-weight:bold" >
<h1>Please provide your payment for the total amount stated above to the Executive Director. You may also contact the Corporate Billing Department for other payment options at (888) 252-5001, extension 8760.<br />Thank You!</h1></td>
					</tr>

					<tr>
						<td colspan="2"  style="text-align:center; font-style:italic; font-size:xx-large;">
 Help us be the very best! If you have a compliment to share or a concern that needs to be resolved, we want to know about it. <br />Please call our Enlivant Cares toll free line at 1-888-777-4780. <br />Prompt attention will be given to your call.</td>
					</tr>
					<tr>					
						<td colspan="2"  style="text-align:center; font-style:italic; font-size:xx-large;"> 
By  providing your payment you are authorizing Enlivant&trade; to convert your payment from a paper check to an electronic transaction that will be processed via the ACH network. <br /> Note: There will be a fee for returned checks and late payments.</td>
				</tr>
				<tr>
					<td colspan="2"  style="font-style:italic;text-align:center; font-weight:bold" >
						<h1>Thank you for choosing Enlivant&trade;</h1>
					</td>
				</tr>
				<tr>
				<tr>
						<td align="right" width="50%">
						  <h2>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</h2> 
						</td>						
						<td  style="text-align:right;">
						<h2>Printed: #dateformat(now(), 'mm/dd/yyyy')#</h2>						
						</td>
					</tr>		
				<cfelse>	
					<tr>
						<td colspan="2" align="center">
						  <h2>Page #cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</h2> 
						</td>
					</tr>	
				</cfif>									
			</table>
		</cfoutput>
	</cfdocumentitem>	

	<cfoutput>  	
		<cfheader name="Content-Disposition"   
 		value="attachment;filename=InvoiceReport-#qryTenant.Residentname#.pdf"> 
	</cfoutput> 			

</cfdocument>
</body>
</html>
