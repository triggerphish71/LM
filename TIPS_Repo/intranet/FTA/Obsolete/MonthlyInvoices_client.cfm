<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- Labor Tracking Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<script type="text/javascript" src="ScriptFiles/jquery-1.3.2.js"></script> 
<script type="text/javascript" src="ScriptFiles/jquery.tablesorter.js"></script> 
<SCRIPT language="javascript">
 	function doSel(obj)
 	{
 	    for (i = 1; i < obj.length; i++)
   	    	if (obj[i].selected == true)
           		eval(obj[i].value);
 	}
 	$(document).ready(function()     
 	{         
 		$("#tblMonthlyInvoices").tablesorter();  
 	}); 
 </SCRIPT>
<style type="text/css">
	.gridCell
	{
		border-width: 1px;
		border-style: solid;
		border-color: black;
	}
</style>

<cfif isDefined("url.iHouse_ID")>
	<cfset houseId = #url.iHouse_ID#>
<cfelse>
	<cfabort showerror="The House ID parameter is not defined.">
</cfif>

<cfquery name="LookUpSubAcct" datasource="#application.datasource#">
	select 
		 iOpsArea_ID
		,cName
		,cGLSubAccount
	from 
		House
	where 
		iHouse_ID = #houseId#;
</cfquery>
<cfset SubAccountNumber = #LookUpSubAcct.cGLSubAccount#>
<cfif isDefined("url.datetoUse") and url.datetouse is not #DateFormat(NOW(),'mmmm yyyy')#>
	<!--- use the month/year given --->
	<cfset currentmonth = "#DateFormat(datetouse,'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',datetouse)#">
	<cfset currenty = "#DatePart('yyyy',datetouse)#">

	<cfset currentmy = "#currentm#/#currenty#">
	<cfset currentdim = "#DaysInMonth(currentmy)#">
	<cfset currentd = "#DaysInMonth(currentmy)#">
	<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
	<cfset currentfullmonthNoTime = "#currentm#/01/#currenty#">
	<cfset lastdayofDateToUse = "#currentm#/#currentd#/#currenty#">
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,currentfullmonthNoTime)#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(currentfullmonthNoTime,'M/D/YYYY')#">
	<!--- ??? --->
	<cfset today = "#currentm#/#currentdim#/#currenty#">
	<cfset datetouse = "#DateFormat(currentfullmonthNoTime,'mmmm yyyy')#">
	
	<cfset monthforqueries = #DateFormat(today,'mmm')#>
<cfelse>
	<!--- use this month --->
	<cfset currentmonth = "#DateFormat(NOW(),'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',NOW())#">
	<cfset currentd = "#DatePart('d',NOW())#">
	<!--- as of 10/13/2005 make current day equal to yesterday, so current day does not show up on FTA --->
	<Cfif currentd is not "1">
		<cfset currentd = currentd - 1>
	<cfelse>
		<!--- if current day is first of month, must show last month's FTA --->
		<cfset minusonemonth = #DateAdd('m',-1,currentmonth)#>
		<cfset minusonemonth = #DateFormat(minusonemonth,'mmmm yyyy')#>
		<cfoutput>
			<cflocation url="expensespenddown.cfm?subaccount=#SubAccountNumber#&iHouse_ID=#url.iHouse_ID#&DatetoUse=#minusonemonth#">
		</cfoutput>
	</Cfif>
	<cfset currenty = "#DatePart('yyyy',NOW())#">
	<cfset monthforqueries = #DateFormat(currentm,'mmm')#>
	<cfset currentmy = "#currentm#/#currenty#">
	<cfset currentdim = "#DaysInMonth(currentmy)#">
	<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
	<cfset currentfullmonthNoTime = "#currentm#/01/#currenty#">
	<cfset lastdayofDateToUse = "#currentm#/#currentd#/#currenty#">
	<!--- if this is the first day of the NOW month, then use TODAY as the lastdayofdatetouse, otherwise, use yesterday --->
	<cfif isDefined("url.datetouse") and DateFormat(datetouse,'m/yyyy') is DateFormat(NOW(),'m/yyyy')><cfset monthnowmonth = "Yes"></cfif>
	<cfif not isDefined("url.datetouse")><cfset monthnowmonth = "Yes"></cfif>
	<cfif isDefined("monthnowmonth")>
		<cfif DatePart('d',NOW()) is "1">
			<cfset lastdayofdatetouse = "#DateFormat(NOW(),'M/D/YYYY')#">
		<cfelse>
			<!--- use yesterday --->
			<cfset lastdayofdatetouse = "#DateFormat(lastdayofdatetouse,'M/D/YYYY')#">
		</cfif>
	</cfif>
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,NOW())#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(NOW(),'M/D/YYYY')#">
	<cfset datetouse = "#DateFormat(NOW(),'mmmm yyyy')#">
	
	<cfset monthforqueries = #DateFormat(today,'mmm')#>
</cfif>

<cfset FromDate = #currentFullMonth#>
<cfset ThruDate = "#DateFormat(DateAdd('d', currentd - 1, FromDate), 'M/D/YYYY')# 11:59:59 PM">

<cfset FirstDayOfDateToUse = #FromDate#>
</head>
<!--- For Testing ONLY - Remove the FTSds Set block after testing. --->
	<cfset FTAds = "FTA_TEST">
<!--- ------------------------------------------------------------ --->
<!--- Instantiate the Helper object. --->
<cfset helperObj = createObject("component","Helper").New(FTAds, ComshareDS, application.DataSource)>
<!--- Initialize all of the required fields. --->
<cfset dsActualDetails = #helperObj.FetchActualDetails(houseId, PtoPFormat, FromDate, ThruDate)#>
<!--- Initialize the cell color variables. --->
<cfset columnHeaderCellColor = "##0066CC">
<cfset corpCellColor = "##ffff99">
<cfset houseCellColor = "d1fbd0">

<!--- Display the toolbar and month selection. --->
<cfoutput>
	<body>
		<font face="arial">
			<h3>Online FTA- <font color="##C88A5B">Monthly Invoices-</font> <font color="##0066CC">#Lookupsubacct.cName#-</font> <Font color="##7F7E7E">#DateFormat(currentfullmonthnotime,'mmmm yyyy')#</font></h3>
			<form method="post" action="MonthlyInvoices.cfm">

			<cfset Page="monthlyinvoices">
			<Table border=0 cellpadding=0 cellspacing=0>
				<td>
					<cfinclude template="menu.cfm">
				</td>
				<td>&##160; <font size=-1>
				<A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">
					Network ALC Apps
				</A> 
				| 
				<A HREF="/intranet/logout.cfm">
					Logout
				</A>
				<p>
				<BR>
				&##160; Month to View: 
				<cfset x = DateFormat(NOW(),'mmmm yyyy')>
				<cfset y = "November 2004">
				<select name="datetouse" onchange="doSel(this)">
					<option value="" />
						<cfloop condition="#DateCompare(x,y,'m')# GTE 0">
							<option value="location.href='MonthlyInvoices.cfm?iHouse_ID=#houseId#&DateToUse=#DateFormat(x,'mmmm yyyy')#'"
								<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> 
									SELECTED
								</cfif>>
								#DateFormat(x,'mmmm yyyy')#
							</option>
							<cfset x = #DateAdd('m',-1,x)#>
						</cfloop>
					</select>
				</td>
			</Table>
			<p>
			<font size=-1>
				Green rows are House Vendors, Yellow rows are Corporate Vendors.<br />
				Click on a Column Heading to sort by that column.  Clicking again orders that column the opposite way.
			</font>
			<BR>
			<BR>
</cfoutput>

<cfoutput>
	<table id="tblMonthlyInvoices" width="1110px" cellpadding="0" cellspacing="0" border="1px" style="border-style:solid; border-color:black; border-size: 1px;">
		<thead>
			<tr>
				<th class="gridCell" width="60px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Doc ID
					</font>
				</th>
				<th class="gridCell" width="60px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Check
					</font>
				</th>		
				<th class="gridCell" width="70px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Tran Date
					</font>
				</th>
				<th class="gridCell" width="70px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Inv Date
					</font>
				</th>
				<th class="gridCell" width="100px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Invoice
					</font>
				</th>
				<th class="gridCell" width="220px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Vendor
					</font>
				</th>
				<th class="gridCell" width="140px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Category
					</font>
				</th>
				<th class="gridCell" width="190px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						GL Code
					</font>
				</th>
				<th class="gridCell" width="75px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" title="Click to Sort" color="White" style="cursor: hand; text-decoration: underline; font-weight: bold;">
						Amount(s)
					</font>
				</th>
				<th class="gridCell" width="80px" align="middle" bgcolor="#columnHeaderCellColor#"> 
					<font size="-1" color="White" style="font-weight: bold;">
						Processed?
					</font>
				</th>
			</tr>
		</thead>
		<tbody>
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
						<label style="cursor: hand;" onclick="window.open('http://gum/intranet/doclink/Image.cfm?ImagePath=#docLinkImagePath#')">
							<font style="text-decoration: underline; color: blue" size=-1>
								<cfif dsActualDetails.cDocLinkId eq "">
									&##160;
								<cfelse>
									#dsActualDetails.cDocLinkId#
								</cfif>
							</font>
						</label>
					<cfelseif dsActualDetails.bIsDSSI eq true>
						<label title="Reference DSSI for Invoice Details">
							<font style="color: blue" size=-1>
								DSSI
							</font>
						</label>
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
						<label style="cursor: hand;" onclick="window.open('http://gum/intranet/doclink/Image.cfm?ImagePath=#checkImagePath#')">
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
							<img src="checkmark3.gif" alt="Yes">
						<cfelse>
							&##160;
						</cfif>
					</font>
				</td>	
			</tr>					
		</cfloop>
		</tbody>
	</table>
</cfoutput>