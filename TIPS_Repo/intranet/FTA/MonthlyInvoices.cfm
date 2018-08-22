<cfset page = "Monthly Invoices">
<cfoutput>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
		<head>
			<title>
				Online FTA- #page#
			</title>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
		<cfheader name='expires' value='#Now()#'> 
		<cfheader name='pragma' value='no-cache'>
		<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>
		<link rel="Stylesheet" href="CSS/MonthlyInvoices.css" type="text/css">
</cfoutput>

<cfinclude template="ScriptFiles/FTACommonScript.cfm">

<!--- Instantiate the Helper object. --->
<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
<cfif isDefined("url.ccllcHouse")>
	<cfset ccllcHouse = #url.ccllcHouse#>
<cfelse> <cfset ccllcHouse = 0>
</cfif>
			
<cfif isDefined("url.iHouse_ID")>
	<cfset houseId = #url.iHouse_ID#>
</cfif>

<cfif isDefined("url.SubAccount")>
	<cfset subAccount = #url.SubAccount#>
	<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
	<cfset unitId = #dsHouseInfo.unitId#>
	<cfset houseId = #dsHouseInfo.iHouse_ID#>			
	<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
</cfif>

<cfif isDefined("url.OrderBy")>
	<cfset orderByColumn = #url.OrderBy#>
<cfelse>
	<cfset orderByColumn = "dtTransaction">
</cfif>

<cfif isDefined("url.IsDesc")>
	<cfset IsDesc = #url.IsDesc#>
<cfelse>
	<cfset IsDesc = false>
</cfif>

<!--- Instantiate the Helper object. --->
<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>


<cfinclude template="Common/DateToUse.cfm">

</head>

<!--- ------------------------------------------------------------ --->

<!--- Initialize the cell color variables. --->
<cfset columnHeaderCellColor = "##0066CC">
<cfset corpCellColor = "##ffff99">
<cfset houseCellColor = "d1fbd0">

<!--- Display the toolbar and month selection. --->
<cfoutput>
	<body>
		<cfinclude template="DisplayFiles/Header.cfm">

		<cfif ccllcHouse is 1>
			<BR>
			<BR>
			There are no Monthly Invoices to display.
			<cfexit method="exittemplate">
		<cfelse>
			<!--- Initialize all of the required fields. --->
			<cfset tmpActualDetails = #helperObj.FetchActualDetails(houseId, PtoPFormat, FromDate, ThruDate)#>
			<cfset dsActualDetails = #helperObj.SortActualDetails(tmpActualDetails, orderByColumn, isDesc)#>
			<cfset dsDssiInvoices = #helperObj.FetchDssiInvoices(ThruDate, houseId)#>
	
			<p>
			<font size=-1>
				Green rows are House Vendors, Yellow rows are Corporate Vendors.<br />
				Click on a Column Heading to sort by that column.  Clicking again orders that column the opposite way.
			</font>
			<BR>
			<BR>
		</cfif>
</cfoutput>

<cfif ccllcHouse is 0>
<cfoutput>
	<table id="tblMonthlyInvoices" width="1110px" cellpadding="0" cellspacing="0" border="1px" style="border-style:solid; border-color:black; border-size: 1px;">
		<tr>
			<th class="gridCell" width="60px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=cDocLinkId&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "cDocLinkId")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Doc ID
					</font>
				</A>
			</th>
			<th class="gridCell" width="60px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=cCheckNumber&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "cCheckNumber")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Check
					</font>
				</A>
			</th>		
			<th class="gridCell" width="70px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=dtTransaction&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "dtTransaction")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Tran Date
					</font>
				</A>
			</th>
			<th class="gridCell" width="70px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=dtInvoice&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "dtInvoice")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Inv Date
					</font>
				</A>
			</th>
			<th class="gridCell" width="100px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=cInvoiceNumber&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "cInvoiceNumber")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Invoice
					</font>
				</A>
			</th>
			<th class="gridCell" width="220px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=cVendorName&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "cVendorName")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Vendor
					</font>
				</A>
			</th>
			<th class="gridCell" width="140px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=cExpenseCategory&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "cExpenseCategory")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Category
					</font>
				</A>
			</th>
			<th class="gridCell" width="190px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=cGLCode&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "cGLCode")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						GL Code
					</font>
				</A>
			</th>
			<th class="gridCell" width="75px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<A href="MonthlyInvoices.cfm?iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#DateToUse#&OrderBy=mAmount&IsDesc=#iif(((IsDesc eq false) and (orderByColumn eq "mAmount")), "True", "False")#">				
					<font size="-1" Title="Click to Sort" color="White" style="text-decoration: underline; font-weight: bold;">
						Amount(s)
					</font>
				</A>
			</th>
			<th class="gridCell" width="80px" align="middle" bgcolor="#columnHeaderCellColor#"> 
				<font size="-1" color="White" style="font-weight: bold;">
					Processed?
				</font>
			</th>
		</tr>
		<cfloop query="dsActualDetails">
			<cfif dsActualDetails.cSource eq "C">
				<cfset cellColor = #corpCellColor#>
			<cfelse>
				<cfset cellColor = #houseCellColor#>
			</cfif>
			
			<tr>
				<!--- DOC ID --->
				<td class="gridCell" align="Middle" bgcolor="#cellColor#">
					<cfif dsActualDetails.cDocLinkImage neq "">
						<cfset docLinkImagePath = #dsActualDetails.cDocLinkRoot# & "\" & 
													#mid(dsActualDetails.cDocLinkImage, 1, 3)# & "\" &
													#mid(dsActualDetails.cDocLinkImage, 4, 3)# & "\" &
													#dsActualDetails.cDocLinkImage#>
						<cfset docLinkImagePath = Replace(docLinkImagePath, "\", "%5C", "all")>
						<label style="cursor: hand;" onClick="window.open('http://cf01/intranet/doclink/Image.cfm?ImagePath=#docLinkImagePath#')">
							<font style="text-decoration: underline; color: blue" size=-1>
								<cfif dsActualDetails.cDocLinkId eq "">
									&##160;
								<cfelse>
									#dsActualDetails.cDocLinkId#
								</cfif>
							</font>
						</label>
					<cfelseif dsActualDetails.bIsDSSI eq true>
						<cfif helperObj.DoesDssiInvoiceExist(dsDssiInvoices, Trim(dsActualDetails.cInvoiceNumber)) eq true>
							<!--- Display the DSSI link to open the DSSI Invoice. --->
							<label style="cursor: hand;" onClick="window.open('DssiInvoiceViewer.cfm?Invoice=#rTrim(dsActualDetails.cInvoiceNumber)#&HouseId=#houseId#');">
								<font title="Click to display DSSI Invoice." style="text-decoration: underline; color: blue" size=-1>
									DSSI
								</font>
							</label>
						</cfif>
					<cfelse>
						<label>
							<font size=-1>
								&##160;
							</font>
						</label>
					</cfif>
				</td>					
	
				<!--- CHECK --->
				<td class="gridCell" align="Middle" bgcolor="#cellColor#">
					<cfif dsActualDetails.cCheckImage neq "">
						<cfset checkImagePath = #dsActualDetails.cDocLinkRoot# & "\" & 
												#mid(dsActualDetails.cCheckImage, 1, 3)# & "\" &
												#mid(dsActualDetails.cCheckImage, 4, 3)# & "\" &
												#dsActualDetails.cCheckImage#>
						<cfset checkImagePath = Replace(checkImagePath, "\", "%5C", "all")>
						<label style="cursor: hand;" onClick="window.open('http://cf01/intranet/doclink/Image.cfm?ImagePath=#checkImagePath#')">
							<font style="text-decoration: underline; color: blue" size=-1>
								<cfif dsActualDetails.cCheckNumber eq "">
									&##160;
								<cfelse>	
									#dsActualDetails.cCheckNumber#
								</cfif>
							</font>
						</label>
					<cfelse>
						<label>
							<font style="color: blue" size=-1>
								<cfif dsActualDetails.cCheckNumber eq "">
									&##160;
								<cfelse>	
									#dsActualDetails.cCheckNumber#
								</cfif>
							</font>
						</label>
					</cfif>
				</td>
									
				<!--- TRAN DATE --->
				<td class="gridCell" align="Right" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#DateFormat(dsActualDetails.dtTransaction, "MM/DD/YYYY")#
					</font>
				</td>
	
				<!--- INV DATE --->
				<td class="gridCell" align="Right" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#DateFormat(dsActualDetails.dtInvoice, "MM/DD/YYYY")#
					</font>
				</td>
	
				<!--- INVOICE --->
				<td class="gridCell" align="Left" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#dsActualDetails.cInvoiceNumber#
					</font>
				</td>
	
				<!--- VENDOR --->
				<td class="gridCell" align="Left" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#dsActualDetails.cVendorName#
					</font>
				</td>
		
				<!--- CATEGORY --->
				<td class="gridCell" align="Left" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#dsActualDetails.cExpenseCategory#
					</font>
				</td>
	
				<!--- GL CODE --->
				<td class="gridCell" align="Left" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#dsActualDetails.cGLCode & " " & dsActualDetails.cGLCodeDesc#
					</font>
				</td>
	
				<!--- AMOUNT --->
				<td class="gridCell" align="Right" bgcolor="#cellColor#">
					<font color="Black" size=-1>
						#helperObj.GetNumberFormat(dsActualDetails.mAmount, true)#
					</font>
				</td>
				
				<!--- PROCESSED --->
				<td class="gridCell" align="Middle" bgcolor="#cellColor#">
					<font size=-1>
						<cfif dsActualDetails.bIsProcessed eq true>
							<img src="Images/checkmark3.gif" alt="Yes">
						<cfelse>
							&##160;
						</cfif>
					</font>
				</td>	
			</tr>					
		</cfloop>
	</table>
</cfoutput>
</cfif>