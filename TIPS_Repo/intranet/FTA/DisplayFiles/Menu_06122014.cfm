

<cfoutput>
	<cfif isDefined("url.DateToUse")>
		<cfset mnuDateToUse = #url.DateToUse#>
	<cfelseif isDefined("DateToUse")>
		<cfset mnuDateToUse = #dateToUse#>
	</cfif>	
	<cfif isDefined("url.iHouse_ID")>
		<cfset mnuHouseId = #url.iHouse_ID#>
	<cfelseif isDefined("houseId")>
		<cfset mnuHouseId = #houseId#>
	<cfelseif isDefined("iHouse_ID")>
		<cfif iHouse_ID neq 0>
			<cfset mnuHouseId = #iHouse_ID#>
		</cfif>
	</cfif>	
	<cfif isDefined("url.SubAccount")>
		<cfset mnuSubAccount = #url.SubAccount#>
	<cfelseif isDefined("subAccount")>
		<cfset mnuSubAccount = #subAccount#>
	<cfelseif isDefined("SubAccountNumber")>
		<cfif SubAccountNumber neq 0>
			<cfset mnuSubAccount = #SubAccountNumber#>
		</cfif>
	</cfif>	
	<cfif isDefined("url.NumberOfMonths")>
		<cfset mnuNumberOfMonths = #url.NumberOfMonths#>
	<cfelse>
		<cfset mnuNumberOfMonths = 3>
	</cfif>
	<cfif isDefined("url.Role")>
		<cfset mnuRole = #url.Role#>
	<cfelse>
		<cfset mnuRole = 1>
	</cfif>

	<cfif isDefined("url.ccllcHouse")>
		<cfset ccllcHouse = #url.ccllcHouse#>
	<cfelse>
		<cfset ccllcHouse = 0>
	</cfif>
	<cfif isDefined("url.rollup")>
		<cfset rollup = #url.rollup#>
	<cfelse>
		<cfset rollup = 0>
	</cfif>

	<cfif isdefined("url.Division_ID") and url.Division_ID is not "">
		  <cfset DivisionID = #url.Division_ID#>
	<cfelse> <cfset DivisionID = "">
	</cfif>
	
	<cfif isdefined("url.Region_ID") and url.Region_ID is not "">
		  <cfset RegionID = #url.Region_ID#>
	<cfelse> <cfset RegionID = "">
	</cfif>

	<cfif Page is "Dashboard">
		
		<img name="setupsheet" src="images/setupsheet.jpg" alt="Home (Dashboard)" width="65" height="76" />
		
		<cfif rollup is not 0>
			<a style="color: white;" href="censustracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="censustracking" src="images/censustrackingblue.jpg" border="0" alt="Census Tracking" width="65" height="76"
				onMouseOver="src='images/censustracking-over.jpg';" onMouseOut="src='images/censustrackingblue.jpg';">--->
			</a>
		</cfif>

		<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
			onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
		</a>
	
		
		<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
			onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
		</a>
		
	<cfif rollup is 0>	
		<a style="color: white;" href="monthlyinvoices.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<!---<img name="MonthlyInvoices" src="images/MonthlyInvoicesblue.jpg" border="0" alt="Monthly Invoices" width="65" height="76"
			onMouseOver="src='images/MonthlyInvoices-over.jpg';" onMouseOut="src='images/MonthlyInvoicesblue.jpg';">--->
		</a>
		
		<!---<a style="color: white;" href="HouseVisitsII.cfm?Role=#mnuRole#&NumberOfMonths=#mnuNumberOfMonths#&ccllcHouse=#ccllcHouse#&rollup=0<cfif isDefined("mnuHouseId")>&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#</cfif><cfif isDefined("mnuDateToUse")>&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#</cfif>">
			<img name="HouseReport" src="images/HouseReportblue.jpg" border="0" alt="House Visit" width="65" height="76"
			onMouseOver="src='images/HouseReport-over.jpg';" onMouseOut="src='images/HouseReportblue.jpg';">
		</a>--->
	</cfif>	

	<cfelseif Page  is "Census Tracking">	
		<cfif (#mnuHouseId# neq 0 and #mnuSubAccount# neq 0) or (#mnuHouseId# neq "" and #mnuSubAccount# neq "") and rollup is 0>
			<cflocation url="Default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#&DateToUse=#DateFormat(mnuDateToUse,'mmmm yyyy')#">
	<cfelse>
			<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
				onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
			</a>
					
			<img name="censustracking" src="images/censustracking.jpg" border="0" alt="Census Tracking" width="65" height="76" />
			
			<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
				onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
			</a>
	
			<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
				onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
			</a>	
	</cfif>
	
	
	<cfelseif Page  is "Labor Tracking">
	
		<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
			onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
		</a>
				
		<cfif rollup is not 0>
			<a style="color: white;" href="censustracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="censustracking" src="images/censustrackingblue.jpg" border="0" alt="Census Tracking" width="65" height="76"
				onMouseOver="src='images/censustracking-over.jpg';" onMouseOut="src='images/censustrackingblue.jpg';">--->
			</a>
		</cfif>

		<img name="labortracking" src="images/labortracking.jpg" border="0" alt="Labor Tracking" width="65" height="76" />
		
		<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
			onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
		</a>
		
	<cfif rollup is 0>	
		<a style="color: white;" href="monthlyinvoices.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<!---<img name="MonthlyInvoices" src="images/MonthlyInvoicesblue.jpg" border="0" alt="Monthly Invoices" width="65" height="76"
			onMouseOver="src='images/MonthlyInvoices-over.jpg';" onMouseOut="src='images/MonthlyInvoicesblue.jpg';">--->
		</a>
		
		<!---<a style="color: white;" href="HouseVisitsII.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<img name="HouseReport" src="images/HouseReportblue.jpg" border="0" alt="House Visit" width="65" height="76"
			onMouseOver="src='images/HouseReport-over.jpg';" onMouseOut="src='images/HouseReportblue.jpg';">
		</a>--->
	</cfif>

	<cfelseif Page is "Expense Spend Down">

		<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
			onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
		</a>

		<cfif rollup is not 0>
			<a style="color: white;" href="censustracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="censustracking" src="images/censustrackingblue.jpg" border="0" alt="Census Tracking" width="65" height="76"
				onMouseOver="src='images/censustracking-over.jpg';" onMouseOut="src='images/censustrackingblue.jpg';">--->
			</a>
		</cfif>
		
		<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
			onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
		</a>
		
		<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddown.jpg" border="0" alt="Expense Spenddown" width="65" height="76" />--->
		
	<cfif rollup is 0>
		<a style="color: white;" href="monthlyinvoices.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
			
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<!---<img name="MonthlyInvoices" src="images/MonthlyInvoicesblue.jpg" border="0" alt="Monthly Invoices" width="65" height="76"
			onMouseOver="src='images/MonthlyInvoices-over.jpg';" onMouseOut="src='images/MonthlyInvoicesblue.jpg';">--->
		</a>
				
		<!---<a style="color: white;" href="HouseVisitsII.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
			<cfif isDefined("mnuHouseId")>
				&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
			</cfif>
			<cfif isDefined("mnuDateToUse")>
				&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
			</cfif>">
			<img name="HouseReport" src="images/HouseReportblue.jpg" border="0" alt="House Visit" width="65" height="76"
			onMouseOver="src='images/HouseReport-over.jpg';" onMouseOut="src='images/HouseReportblue.jpg';">
		</a>--->
	</cfif>
	</cfif>
	<cfif rollup is 0>	
	<cfif Page is "Monthly Invoices">
		<cfif (#mnuHouseId# eq 0 and #mnuSubAccount# eq 0) or (#mnuHouseId# eq "" and #mnuSubAccount# eq "") and 
			(rollup is 2 or rollup is 3)><cfdump var="#mnuHouseId#"><cfdump var="#mnuSubAccount#">
			<cflocation url="Default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#&DateToUse=#DateFormat(mnuDateToUse,'mmmm yyyy')#">
		<cfelse>
	
			<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
				onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
			</a>
	
			<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
				onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
			</a>
			
			<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
				onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
			</a>
			
			<img name="MonthlyInvoices" src="images/MonthlyInvoices.jpg" border="0" alt="Monthly Invoices" width="65" height="76" />
					
			<!---<a style="color: white;" href="HouseVisitsII.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="HouseReport" src="images/HouseReportblue.jpg" border="0" alt="House Visit" width="65" height="76"
				onMouseOver="src='images/HouseReport-over.jpg';" onMouseOut="src='images/HouseReportblue.jpg';">
			</a>--->
		</cfif>
							
	<cfelseif Page is "House Visit">
		<cfif rollup is not 0>
			<cflocation url="Default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#&DateToUse=#DateFormat(mnuDateToUse,'mmmm yyyy')#">
		<cfelse>
	
			<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
				onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
			</a>
	
	
			<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
				onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
			</a>
			
			<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
				onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
			</a>
			
			<!---<a style="color: white;" href="monthlyinvoices.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="MonthlyInvoices" src="images/MonthlyInvoicesblue.jpg" border="0" alt="Monthly Invoices" width="65" height="76"
				onMouseOver="src='images/MonthlyInvoices-over.jpg';" onMouseOut="src='images/MonthlyInvoicesblue.jpg';">
			</a>--->		
			
			<img name="HouseReport" src="images/HouseReport.jpg" border="0" alt="House Visit" width="65" height="76" />
		</cfif>
		
	<cfelseif Page is "Create House Visit">
		<cfif rollup is not 0>
			<cflocation url="Default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#&DateToUse=#DateFormat(mnuDateToUse,'mmmm yyyy')#">
		<cfelse>
	
			<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
				onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
			</a>
	
	
			<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
				onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
			</a>
			
			<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
				onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
			</a>
			
			<a style="color: white;" href="monthlyinvoices.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="MonthlyInvoices" src="images/MonthlyInvoicesblue.jpg" border="0" alt="Monthly Invoices" width="65" height="76"
				onMouseOver="src='images/MonthlyInvoices-over.jpg';" onMouseOut="src='images/MonthlyInvoicesblue.jpg';">--->
			</a>		
			
			<img name="HouseReport" src="images/HouseReport.jpg" border="0" alt="House Visit" width="65" height="76" />
		</cfif>
		
	<cfelseif Page is "Edit House Visit">
		<cfif rollup is not 0>
			<cflocation url="Default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#&Division_ID=#DivisionID#&Region_ID=#RegionID#
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#&DateToUse=#DateFormat(mnuDateToUse,'mmmm yyyy')#">
		<cfelse>
	
			<a style="color: white;" href="default.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="setupsheet" src="images/setupsheetblue.jpg" border="0" alt="Home (Dashboard)" width="65" height="76"
				onMouseOver="src='images/setupsheet-over.jpg';" onMouseOut="src='images/setupsheetblue.jpg';">
			</a>
	
			<a style="color: white;" href="labortracking.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<img name="labortracking" src="images/labortrackingblue.jpg" border="0" alt="Labor Tracking" width="65" height="76"
				onMouseOver="src='images/labortracking-over.jpg';" onMouseOut="src='images/labortrackingblue.jpg';">
			</a>
			
			<a style="color: white;" href="expensespenddown.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=#rollup#
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="ExpenseSpenddown" src="images/ExpenseSpenddownblue.jpg" border="0" alt="Expense Spenddown" width="65" height="76"
				onMouseOver="src='images/ExpenseSpenddown-over.jpg';" onMouseOut="src='images/ExpenseSpenddownblue.jpg';">--->
			</a>
			
			<a style="color: white;" href="monthlyinvoices.cfm?NumberOfMonths=#mnuNumberOfMonths#&Role=#mnuRole#&ccllcHouse=#ccllcHouse#&rollup=0
				<cfif isDefined("mnuHouseId")>
					&iHouse_ID=#mnuHouseId#&SubAccount=#mnuSubAccount#
				</cfif>
				<cfif isDefined("mnuDateToUse")>
					&DateToUse=#DateFormat(datetouse,'mmmm yyyy')#
				</cfif>">
				<!---<img name="MonthlyInvoices" src="images/MonthlyInvoicesblue.jpg" border="0" alt="Monthly Invoices" width="65" height="76"
				onMouseOver="src='images/MonthlyInvoices-over.jpg';" onMouseOut="src='images/MonthlyInvoicesblue.jpg';">--->
			</a>		
			
			<img name="HouseReport" src="images/HouseReport.jpg" border="0" alt="House Visit" width="65" height="76" />
		</cfif>
	</cfif>					
	</cfif>
</cfoutput>

