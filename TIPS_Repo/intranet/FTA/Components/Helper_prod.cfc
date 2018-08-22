<!--- An FTA Helper class that is primarily used by the Expense Spreaddown. --->
<cfcomponent displayname="Helper" output="false">

<!--- FIELDS --->
<cfparam name="FtaDsName" type="String" default="FTA" >
<cfparam name="ComshareDsName" type="String" default="ALC" >
<cfparam name="TipsDsName" type="String" default="Tips4" >
<cfparam name="TimeCardDsName" type="String" default="TimeCard" ><!--- 11/07/2012-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->

<!--- CONSTRUCTOR - You must call this method to get an instance of the Object. --->
<cffunction access="public" name="New" displayname="New" returntype="Helper" description="Instantiates the Helper Class.">
	<cfargument name="iFtaDS" type="String" required="true">
	<cfargument name="iComshareDS" type="String" required="true">
	<cfargument name="iTipsDS" type="String" required="true">
	<cfargument name="iTimeCardDS" type="String" required="no"><!--- 11/07/2012-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->
	
	<!--- Set the Component's Data Source Name fields. --->
	<cfset FtaDsName = #iFtaDS#>
	<cfset ComshareDsName = #iComshareDS#>
	<cfset TipsDsName = #iTipsDS#>
	<cfif isDefined('iTimeCardDS')>
		<cfset TimeCardDsName = #iTimeCardDS#><!--- 11/07/2012-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->
	</cfif>
	
	<!--- Return an instance of the Helper() Component. --->
	<cfreturn this>
</cffunction>

<cffunction access="public" name="Ctor" displayname="Ctor" returntype="Helper" description="Instantiates the Helper Class.">
	<cfargument name="iFtaDS" type="String" required="true">
	<cfargument name="iComshareDS" type="String" required="true">
	<cfargument name="iTipsDS" type="String" required="true">
	<cfargument name="iTimeCardDS" type="String" required="no"><!--- 11/07/2012-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->
	
	<!--- Set the Component's Data Source Name fields. --->
	<cfset FtaDsName = #iFtaDS#>
	<cfset ComshareDsName = #iComshareDS#>
	<cfset TipsDsName = #iTipsDS#>
	<cfif isDefined('iTimeCardDS')>
		<cfset TimeCardDsName = #iTimeCardDS#><!--- 11/07/2012-Tamkeen-Added the TimeCard DataSource for UTA move from Maple. Project 61586. --->
	</cfif>
	
	<!--- Return an instance of the Helper() Component. --->
	<cfreturn this>
</cffunction>

<!--- METHODS --->
<cffunction access="public" name="FetchColumns" displayname="FetchColums" returntype="Query" description="Fetches the Expense Columns DataSet.">
	<!--- Execute a query to fetch the Expense Spending Columns.  --->
	<cfquery name="tmpFetchColumns" datasource="#FtaDsName#">
		SELECT
			iExpenseCategory_ID,
			vcDisplayName,
			iOrder
		FROM
			dbo.ExpenseCategory
		WHERE
			dtRowDeleted IS NULL
		ORDER BY
			iOrder ASC;
	</cfquery>
	
	<!--- Return the Query results object to the caller. --->
	<cfreturn tmpFetchColumns>
</cffunction>

<cffunction access="public" name="FetchColumnDisplayName" displayname="FetchColums" returntype="String"
			description="Fetches the Expense Columns Display Name.">
<cfargument name="iColumnsQuery" type="Query" required="true">
<cfargument name="iExpenseCategoryId" type="Numeric" required="true">

	<cfquery name="tmpFetchColumnDisplayName" dbtype="Query">
		SELECT
			vcDisplayName
		FROM
			iColumnsQuery
		WHERE
			iExpenseCategory_ID = #iExpenseCategoryId#;
	</cfquery>
	<cfreturn tmpFetchColumnDisplayName.vcDisplayName>
	
</cffunction>




<cffunction access="public" name="FetchBudgetDetails" displayname="FetchBudgetDetails" returntype="Query"
			description="Fetches the Budget Details DataSet.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iYear" type="numeric" required="true">
	<cfquery name="tmpFetchBudgetDetails" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			SpendDownBudgetDetails
		WHERE
			iHouseId = #iHouseId# AND
			iYear = #iYear#;
	</cfquery>
	<cfreturn tmpFetchBudgetDetails>
</cffunction>

<cffunction access="public" name="FetchActualDetails" displayname="FetchActualDetails" returntype="Query"
			description="Fetches the Actual Details DataSet.">
	<cfargument name="iHouseId" type="numeric" required="true">
	<cfargument name="iPeriod" type="string" required="true">
	<cfquery name="tmpFetchActualDetails" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			SpendDownInvoiceDetails
		WHERE
			iHouseId = #iHouseId# AND
			cPeriod = '#iPeriod#';
	</cfquery>
	<cfreturn tmpFetchActualDetails>
</cffunction>

<cffunction access="public" name="SortActualDetails" displayname="SortActualDetails" returntype="Query"
			description="Sorts the Actual Details DataSet.">
	<cfargument name="iActualDetailsQuery" type="Query" required="true">
	<cfargument name="iSortColumn" type="String" required="true">
	<cfargument name="iSortDesc" type="Boolean" required="true">
	<cfquery name="tmpSortActualDetails" dbtype="Query">
		SELECT
			*
		FROM
			iActualDetailsQuery
		ORDER BY
			#iSortColumn# <cfif iSortDesc eq true> DESC <cfelse> ASC </cfif>
	</cfquery>
	<cfreturn tmpSortActualDetails>
</cffunction>

<cffunction access="public" name="FetchBudgetSummary" displayname="FetchBudgetSummary" returntype="Query"
			description="Fetches the Budget Summary by querying the Budget Details.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iYear" type="numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchBudgetSummary" datasource="#FtaDsName#">
		SELECT
			a.iExpenseCategoryId,
			a.cExpenseCategory,
			a.iSortOrder,
			SUM(a.mAmount) AS mAmount	
		FROM
			(SELECT 
				iExpenseCategoryId,
				cExpenseCategory,
				iSortOrder,
				SUM(#iMonthCode#) AS mAmount
			FROM 
				SpendDownBudgetDetails
			WHERE
				iHouseId = #iHouseId# AND
				iYear = #iYear#
			GROUP BY
				iExpenseCategoryId,
				cExpenseCategory,
				iSortOrder
			UNION
			SELECT
				iExpenseCategory_ID AS iExpenseCategoryId,
				vcExpenseCategory AS cExpenseCategory,
				iOrder AS iSortOrder,
				(0.0) AS mAmount
			FROM
				ExpenseCategory) a
		GROUP BY
			a.iExpenseCategoryId,
			a.cExpenseCategory,
			a.iSortOrder
		ORDER BY
			a.iSortOrder;
	</cfquery>
	<cfreturn tmpFetchBudgetSummary>	
</cffunction>

<cffunction access="public" name="FetchVariableBudgetSummary" displayname="FetchVariableBudgetSummary" returntype="Query"
			description="Fetches the Variable Budget Summary by querying the Variable Budget Details.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="cPeriod" type="string" required="true">

	<cfquery name="tmpFetchVariableBudgetSummary" datasource="#FtaDsName#">
		SELECT
			bgtDtls.iHouseId,
			cat.iLaborTrackingCategoryId,
			cat.cDisplayName,
			bgtDtls.fVariableBudget
		FROM
			dbo.LaborTrackingVariableBudgetDetails bgtDtls
				LEFT JOIN dbo.LaborTrackingCategory cat
					ON bgtDtls.iLaborTrackingCategoryId = cat.iLaborTrackingCategoryId AND
					cat.dtRowDeleted IS NULL AND
					cat.bIsVisible = 1
		WHERE
			bgtDtls.iHouseId = @iHouseId AND
			bgtDtls.cPeriod = @iPeriod;
	</cfquery>
	
	<cfreturn tmpFetchVariableBudgetSummary>	
</cffunction>

<cffunction access="public" name="FetchActualSummary" displayname="FetchActualSummary" returntype="Query"
			description="Fetches the Actuals Summary DataSet.">
	<cfargument name="iHouseId" type="numeric" required="true">
	<cfargument name="iPeriod" type="string" required="true">
	<cfargument name="iFrom" type="Date" required="true">
	<cfargument name="iTo" type="Date" required="true">
	<cfargument name="iActualDetailsQuery" type="Query" required="true">
	<cfquery name="tmpFetchActualSummary" datasource="#FtaDsName#" >
		SELECT
			iDay,
			iExpenseCategoryId,
			cExpenseCategory,
			iSortOrder,
			Sum(IsNull(mAmount, 0.00)) AS mAmount
		FROM 
			SpendDownInvoiceDetails
		WHERE
			iHouseId = #iHouseId# AND
			cPeriod = '#iPeriod#'
			 and bIsProcessed = 1 <!--- new filter added for ticket 90476 on  05/04/2012. --->
		GROUP BY
			iDay,
			iExpenseCategoryId,
			cExpenseCategory,
			iSortOrder
		UNION
		SELECT
			c.iDay,
			c.iExpenseCategoryId,
			c.cExpenseCategory,
			c.iSortOrder,
			(0.0) AS mAmount
		FROM
			dbo.fn_GetExpenseCategoryDays('#iFrom#', '#iTo#') c
		WHERE
			((SELECT 
				COUNT(m1.mAmount) 
			FROM 
				SpendDownInvoiceDetails m1 
			WHERE 
				m1.iDay = c.iDay AND
				m1.iExpenseCategoryId = c.iExpenseCategoryId AND
				m1.iHouseId = #iHouseId# AND
				m1.cPeriod = '#iPeriod#') = 0)
		ORDER BY
			iDay,
			iSortOrder;
	</cfquery>	
	<cfreturn tmpFetchActualSummary>
</cffunction>

<cffunction access="public" name="FetchActualSummaryMtdDay" displayname="FetchActualSummaryMtdDay" returntype="Query"
			description="Fetches the Actuals Summary DataSet for the current day in the month.">
	<cfargument name="iActualSummaryQuery" type="query" required="true">
	<cfargument name="iMtdDay" type="Numeric" required="true">
	<cfquery name="tmpFetchActualSummaryMtdDay" dbtype="query">
		SELECT
			iDay,
			iExpenseCategoryId,
			iSortOrder,
			mAmount
		FROM
			iActualSummaryQuery
		WHERE
			iDay = #iMtdDay#;
	</cfquery>
	<cfreturn tmpFetchActualSummaryMtdDay>
</cffunction>

<cffunction access="public" name="qryHousePosition" displayname="qryHousePosition" returntype="Query"
			description="Queries the House Position for House Visits.">
	<cfquery name="qryHousePosition"  datasource="#FtaDsName#">
		SELECT
			cHousePosition
		FROM
			dbo.HouseVisitHousePosition
		WHERE
			dtRowDeleted is null
	</cfquery>
	<cfreturn qryHousePosition>
</cffunction>

<cffunction access="public" name="qryHouseTitle" displayname="qryHouseTitle" returntype="Query"
			description="Queries the House Titles for House Visits.">
	<cfquery name="qryHouseTitle"  datasource="#FtaDsName#">
		SELECT
			cHouseTitle
		FROM
			dbo.HouseVisitHouseTitle
		WHERE
			dtRowDeleted is null
	</cfquery>
	<cfreturn qryHouseTitle>
</cffunction>

<cffunction access="public" name="qryHouseTask" displayname="qryHouseTask" returntype="Query"
			description="Queries the House Task Sheet.">
	<cfquery name="qryHouseTask"  datasource="#FtaDsName#">
		SELECT
			cTaskSheetDayRange
		FROM
			dbo.HouseVisitHouseTaskSheet
		WHERE
			dtRowDeleted is null
	</cfquery>
	<cfreturn qryHouseTask>
</cffunction>

<cffunction access="public" name="FetchActualSummaryMtd" displayname="FetchActualSummaryMtdDay" returntype="Query"
			description="Fetches the Actuals Summary DataSet for the current day in the month.">
	<cfargument name="iActualSummaryQuery" type="query" required="true">
	<cfquery name="tmpFetchActualSummaryMtd" dbtype="query">
		SELECT
			iExpenseCategoryId,
			cExpenseCategory,
			iSortOrder,
			Sum(mAmount) AS mAmount
		FROM
			iActualSummaryQuery
		GROUP BY
			iExpenseCategoryId,
			cExpenseCategory,
			iSortOrder
		ORDER BY
			iSortOrder;
	</cfquery>
	<cfreturn tmpFetchActualSummaryMtd>
</cffunction>

<cffunction access="public" name="FetchFoodBudgetAccumulator" displayname="FetchFoodBudgetAccumulator" returntype="Numeric"
			description="Fetches the Food Budget Accumulator value.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iYear" type="Numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchFoodBudgetAccumulator" datasource="#ComshareDsName#">
		SELECT TOP 1
			#iMonthCode# AS fFoodBudget
		FROM 
			ALC.FINLOC_BASE
		WHERE 
			year_id = #iYear# AND 
			Line_id = 80000137 AND
			unit_id = #iHouseId# AND 
			ver_id = 1 AND
			Cust1_id = 0  AND
			Cust2_id = 0 AND
			Cust3_id = 0 AND
			Cust4_id = 0;
	</cfquery>
	<cfif tmpFetchFoodBudgetAccumulator.RecordCount is "0">
		<cfreturn 0.0>
	<cfelse>
		<cfreturn tmpFetchFoodBudgetAccumulator.fFoodBudget>			
	</cfif>
</cffunction>

<cffunction access="public" name="FetchCensusDetails" displayname="FetchOccupancyDetails" returntype="Query"
			description="Fetches the Census Details.">
	<cfargument name="iHouseId" type="numeric" required="true">
	<cfargument name="iFrom" type="Date" required="true">
	<cfargument name="iTo" type="Date" required="true">
	<cfquery name="tmpFetchCensusDetails" datasource="#FtaDsName#">
		SELECT 
			(DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,
			t.fTenants,
			Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
			(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints
		FROM 
			HouseTenantCensus t 
			LEFT JOIN vw_HouseOccupancy o
				ON t.iHouseId = o.iHouseId AND
				t.dtOccupancy = o.dtOccupancy
			LEFT JOIN HouseAcuity a
				ON t.iHouseId = a.iHouseId AND
				t.dtOccupancy = a.dtOccupancy AND
				t.cType = a.cType
		WHERE 
			t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND 
			t.cType = 'P' AND
			t.iHouseId = #iHouseId#;
	</cfquery>
	<cfreturn tmpFetchCensusDetails>
</cffunction>

<cffunction access="public" name="FetchTenantsForDay" displayname="FetchTenantsForDay" returntype="Numeric"
			description="Fetches the Tenant Count for the specified Day.">
	<cfargument name="iOccupancyDetailsQuery" type="Query" required="true">
	<cfargument name="iDay" type="Numeric" required="true">
	<cfquery name="tmpFetchTenantsForDay" dbtype="query">
		SELECT
			fTenants 
		FROM 
			iOccupancyDetailsQuery
		WHERE 
			iDay = #iDay#;
	</cfquery>
	
	<cfif tmpFetchTenantsForDay.RecordCount is not "0">
		<cfreturn tmpFetchTenantsForDay.fTenants>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchOccupancyForDay" displayname="FetchOccupancyForDay" returntype="Numeric"
			description="Fetches the Occupancy (Units) for the specified Day.">
	<cfargument name="iOccupancyDetailsQuery" type="Query" required="true">
	<cfargument name="iDay" type="Numeric" required="true">
	<cfquery name="tmpFetchOccupancyForDay" dbtype="query">
		SELECT
			fOccupancy
		FROM 
			iOccupancyDetailsQuery
		WHERE 
			iDay = #iDay#;
	</cfquery>
	
	<cfif tmpFetchOccupancyForDay.RecordCount is not "0">
		<cfreturn tmpFetchOccupancyForDay.fOccupancy>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchPointsForDay" displayname="FetchPointsForDay" returntype="Numeric"
			description="Fetches the Service Points for the specified Day.">
	<cfargument name="iOccupancyDetailsQuery" type="Query" required="true">
	<cfargument name="iDay" type="Numeric" required="true">
	<cfquery name="tmpFetchPointsForDay" dbtype="query">
		SELECT
			fPoints 
		FROM 
			iOccupancyDetailsQuery
		WHERE 
			iDay = #iDay#;
	</cfquery>
	
	<cfif tmpFetchPointsForDay.RecordCount is not "0">
		<cfreturn tmpFetchPointsForDay.fPoints>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchTenantsMTD" displayname="FetchTenantsMTD" returntype="Numeric"
			description="Fetches the total Tenants MTD.">
	<cfargument name="iOccupancyDetailsQuery" type="Query" required="true">
	<cfquery name="tmpFetchTenantsMTD" dbtype="query">
		SELECT
			Sum(fTenants) AS fTotalTenants
		FROM 
			iOccupancyDetailsQuery;
	</cfquery>
	
	<cfif tmpFetchTenantsMTD.RecordCount is not "0">
		<cfreturn tmpFetchTenantsMTD.fTotalTenants>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchDailyCensusBudget" displayname="FetchDailyCensusBudget" returntype="Numeric"
			description="Fetches the Census Budget for the specified Month.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iYear" type="Numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchDailyOccupancyBudget" datasource="#FtaDsName#">
		SELECT TOP 1
			#iMonthCode# AS fOccupancyBudget
		FROM 
			HouseCensusBudget
		WHERE 
			iYear = #iYear# AND 
			iHouseId = #iHouseId#;
	</cfquery>
<!--- 	<cfreturn tmpFetchDailyOccupancyBudget.fOccupancyBudget> --->
	<cfif tmpFetchDailyOccupancyBudget.fOccupancyBudget is ''>
		<cfreturn 1>
	<cfelse>
		<cfreturn tmpFetchDailyOccupancyBudget.fOccupancyBudget>
	</cfif>	
</cffunction>

<cffunction access="public" name="FetchTwoPersonAssists" displayname="FetchTwoPersonAssists" returntype="Query"
			description="Fetches all of the two person assist records for the specified Date Range.">
	<cfargument name="iHouseId" type="numeric" required="true">
	<cfargument name="iFrom" type="Date" required="true">
	<cfargument name="iTo" type="Date" required="true">
	
		<!--- Grab all fo the two person assist records from the specified range and for the specified house. --->
		<cfquery name="dsTmpFetchTwoPersonAssists" datasource="#FtaDsName#">
			SELECT
				(DateDiff(Day, '#iFrom#', dtCompareDate) + 1) AS iDay,
				iHouseId,
				iTwoPersonAssists,
				dtCompareDate
			FROM
				dbo.TwoPersonAssists
			WHERE
				dtDeleted IS NULL AND
				iHouseId = #iHouseId# AND
				dtCompareDate BETWEEN '#iFrom#' AND '#iTo#';
		</cfquery>
		
		<!--- Return the 2-Person Assists DataSet to the caller. --->
		<cfreturn dsTmpFetchTwoPersonAssists>
</cffunction>

<cffunction access="public" name="FetchTwoPersonAssistsForDay" displayname="FetchTwoPersonAssistsForDay" returntype="Numeric"
			description="Fetches the 2-Person Assists for the specified Day.">
	<cfargument name="iTwoPersonAssistsQuery" type="query" required="true">
	<cfargument name="iDay" type="numeric" required="true">
	
		<!--- Grab the two person assist record for the specified day. --->
		<cfquery name="dsTmpFetchTwoPersonAssistsForDay" dbtype="query">
			SELECT
				iDay,
				iHouseId,
				iTwoPersonAssists,
				dtCompareDate
			FROM
				iTwoPersonAssistsQuery
			WHERE
				iDay = #iDay#;
		</cfquery>
	
		<!--- Return the 2-Person Assists DataSet, which contains 1-record for the specified day. --->		
		<cfif dsTmpFetchTwoPersonAssistsForDay.RecordCount is not "0">
			<cfreturn dsTmpFetchTwoPersonAssistsForDay.iTwoPersonAssists>
		<cfelse>
			<cfreturn 0>
		</cfif>		
</cffunction>

<cffunction access="public" name="GetNumberFormat" displayname="GetNumberFormat" returntype="String"
			description="Returns the number formatted using the FTA specified Formatting (0 = -, commas, etc...)">
<cfargument name="iValue" type="any" required="true">
<cfargument name="iIsDollars" type="boolean" required="true">

	<cfscript>
		// Check and see if the parameter is an actual Number and display "-" if it's NOT or if it's 0.
		if (isNumeric(iValue))
		{
	 		if (iValue eq 0)
			{
				return ("-");
			}
			else 
			{
				// Determine whether the number should be formatted to a currency string or a decimal string.
				if (iIsDollars eq true)
				{
					return (dollarformat(iValue));
				}
				else
				{
					return (numberformat(iValue, "(),0.0"));
				}		
			}
		}
		else
		{
			return ("-");
		}
	</cfscript>
	
</cffunction>

<cffunction access="public" name="FetchActualsDrillDown"  displayname="FetchActualsDrillDown" returntype="Query"
			description="Returns the Actual Drill-down detail items for the specified day.">
<cfargument name="iActualDetailsQuery" type="Query" required="true">
<cfargument name="iDay" type="Numeric" required="true">
	<cfquery name="tmpFetchActualsDrillDown" dbtype="Query">
		SELECT
			*
		FROM
			iActualDetailsQuery
		WHERE
			iDay = #iDay#
		ORDER BY
			iDay,
			iSortOrder;
	</cfquery>
	<cfreturn tmpFetchActualsDrillDown>
</cffunction>

<cffunction access="public" name="FetchDssiInvoices" displayname="FetchDssiInvoices" returntype="Query"
			description="Fetches all of the DSSI Invoices with-in a +/- 3 Month period from now for the current House.">
<cfargument name="iPeriodDate" type="Date" required="true">
<cfargument name="iHouseId" type="numeric" required="true">
	<cfquery name="dsTempFetchDssiInvoices" datasource="#FtaDsName#">
		SELECT DISTINCT
			h.iHouse_ID, 
			rTrim(d.cInvoiceNumber) AS cInvoiceNumber
		FROM
			DssiInvoiceImport d
			LEFT JOIN vw_House h ON rTrim(d.cFacilityNumber) = rTrim(h.cGlSubAccount)
		WHERE
			h.iHouse_ID = #iHouseId# AND
			d.dtRowDeleted IS NULL AND
			d.dtInvoiceDate BETWEEN DateAdd(Month, -6, '#iPeriodDate#') AND DateAdd(Month, 6, '#iPeriodDate#');
	</cfquery>
	
	<cfreturn dsTempFetchDssiInvoices>
</cffunction>

<cffunction access="public" name="DoesDssiInvoiceExist" displayname="DoesDssiInvoiceExist" returntype="boolean"
			description="Returns whether or not the Dssi Invoice is available to ALC, so a Report can be generated.">
<cfargument name="iDssiInvoicesQuery" type="query" requried="true">
<cfargument name="iInvoiceNumber" type="String" required="true">
	<cfquery name="dsDoesDssiInvoiceExist" dbtype="query">
		SELECT
			cInvoiceNumber
		FROM
			iDssiInvoicesQuery
		WHERE
			cInvoiceNumber = '#iInvoiceNumber#';
	</cfquery>
	
	<cfif dsDoesDssiInvoiceExist.RecordCount gt 0>
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchAllExpenseCategoryGLCodes" displayname="FetchAllExpenseCategoryGLCodes" returntype="Query"
			description="Returns a Data Set that fetches all of the records from vw_ExpenseCategoryGLCodes.">
	<cfquery name="tmpFetchAllExpenseCategoryGLCodes" datasource="#FtaDsName#">
		SELECT     
			iExpenseCategory_ID AS iExpenseCategoryId, 
			vcDisplayName AS cDisplayName, 
			vcGLCode AS cGLCode, 
			vcGLCodeDesc AS cGLCodeDesc
		FROM         
			vw_ExpenseCategoryGLCodes;	
	</cfquery>
		
	<cfreturn tmpFetchAllExpenseCategoryGLCodes>
</cffunction>

<cffunction access="public" name="FetchSingleExpenseCategoryGLCodes" displayname="FetchSingleExpenseCategoryGLCodes" returntype="Query"
			description="Returns a Data Set that fetches all of the GL Codes belonging to the Expense Category.">
<cfargument name="iFetchCatGLCodesQuery" type="Query" required="true">
<cfargument name="iExpenseCategoryId" type="Numeric" required="true">

	<cfquery name="tmpFetchSingleExpenseCategoryGLCodes" dbtype="Query">
		SELECT     
			iExpenseCategoryId, 
			cDisplayName, 
			cGLCode, 
			cGLCodeDesc
		FROM         
			iFetchCatGLCodesQuery
		WHERE
			iExpenseCategoryId = #iExpenseCategoryId#;
	</cfquery>
		
	<cfreturn tmpFetchSingleExpenseCategoryGLCodes>
</cffunction>

<cffunction access="public" name="FetchNextLetterInAlphabet" displayname="FetchNextLetterInAlphabet" returntype="String"
			description="Fetches the next letter in the Alphabet for the Excel Spreadsheet Columns.">
<cfargument name="iLetter" type="String" required="true">

	<cfscript>
		// Try to return the next letter in the alphabet, but if there is an error, then return "A".
		try
		{
			// Stores the next letter in the alpha and gets returned to the caller.
			nextLetter = "A";
		
			// Determine the next letter in the alpha and assign it to the nextLetter variable.
			if (iLetter eq "A")
			{
				nextLetter = "B";						
			}
			else if (iLetter eq "B")
			{
				nextLetter = "C";						
			}
			else if (iLetter eq "C")
			{
				nextLetter = "D";						
			}
			else if (iLetter eq "D")
			{
				nextLetter = "E";						
			}
			else if (iLetter eq "E")
			{
				nextLetter = "F";						
			}
			else if (iLetter eq "F")
			{
				nextLetter = "G";						
			}
			else if (iLetter eq "G")
			{
				nextLetter = "H";						
			}
			else if (iLetter eq "H")
			{
				nextLetter = "I";						
			}
			else if (iLetter eq "I")
			{
				nextLetter = "J";				                     		
			}
			else if (iLetter eq "J")
			{
				nextLetter = "K";				                     		
			}
			else if (iLetter eq "K")
			{
				nextLetter = "L";				                     		
			}				
			else if (iLetter eq "L")
			{
				nextLetter = "M";				                     		
			}	
			else if (iLetter eq "M")
			{
				nextLetter = "N";				                     		
			}	
			else if (iLetter eq "N")
			{
				nextLetter = "O";				                     		
			}	
			else if (iLetter eq "O")
			{
				nextLetter = "P";				                     		
			}	
			else if (iLetter eq "P")
			{
				nextLetter = "Q";				                     		
			}	
			else if (iLetter eq "Q")
			{
				nextLetter = "R";				                     		
			}	
			else if (iLetter eq "R")
			{
				nextLetter = "S";				                     		
			}	
			else if (iLetter eq "S")
			{
				nextLetter = "T";				                     		
			}	
			else if (iLetter eq "T")
			{
				nextLetter = "U";				                     		
			}	
			else if (iLetter eq "U")
			{
				nextLetter = "V";				                     		
			}	
			else if (iLetter eq "V")
			{
				nextLetter = "W";				                     		
			}	
			else if (iLetter eq "W")
			{
				nextLetter = "X";				                     		
			}	
			else if (iLetter eq "X")
			{
				nextLetter = "Y";				                     		
			}	
			else if (iLetter eq "Y")
			{
				nextLetter = "Z";				                     		
			}	
			else if (iLetter eq "Z")
			{
				nextLetter = "AA";				                     		
			}	
			else if (iLetter eq "AA")
			{
				nextLetter = "AB";						
			}
			else if (iLetter eq "AB")
			{
				nextLetter = "AC";						
			}
			else if (iLetter eq "AC")
			{
				nextLetter = "AD";						
			}
			else if (iLetter eq "AD")
			{
				nextLetter = "AE";						
			}
			else if (iLetter eq "AE")
			{
				nextLetter = "AF";						
			}
			else if (iLetter eq "AF")
			{
				nextLetter = "AG";						
			}
			else if (iLetter eq "AG")
			{
				nextLetter = "AH";						
			}
			else if (iLetter eq "AH")
			{
				nextLetter = "AI";						
			}
			else if (iLetter eq "AI")
			{
				nextLetter = "AJ";				                     		
			}
			else if (iLetter eq "AJ")
			{
				nextLetter = "AK";				                     		
			}
			else if (iLetter eq "AK")
			{
				nextLetter = "AL";				                     		
			}				
			else if (iLetter eq "AL")
			{
				nextLetter = "AM";				                     		
			}	
			else if (iLetter eq "AM")
			{
				nextLetter = "AN";				                     		
			}	
			else if (iLetter eq "AN")
			{
				nextLetter = "AO";				                     		
			}	
			else if (iLetter eq "AO")
			{
				nextLetter = "AP";				                     		
			}	
			else if (iLetter eq "AP")
			{
				nextLetter = "AQ";				                     		
			}	
			else if (iLetter eq "AQ")
			{
				nextLetter = "AR";				                     		
			}	
			else if (iLetter eq "AR")
			{
				nextLetter = "AS";				                     		
			}	
			else if (iLetter eq "AS")
			{
				nextLetter = "AT";				                     		
			}	
			else if (iLetter eq "AT")
			{
				nextLetter = "AU";				                     		
			}	
			else if (iLetter eq "AU")
			{
				nextLetter = "AV";				                     		
			}	
			else if (iLetter eq "AV")
			{
				nextLetter = "AW";				                     		
			}	
			else if (iLetter eq "AW")
			{
				nextLetter = "AX";				                     		
			}	
			else if (iLetter eq "AX")
			{
				nextLetter = "AY";				                     		
			}	
			else if (iLetter eq "AY")
			{
				nextLetter = "AZ";				                     		
			}	
			else if (iLetter eq "AZ")
			{
				nextLetter = "BA";				                     		
			}
            else if (iLetter eq "BA")
			{
				nextLetter = "BB";				                     		
			}		
			else if (iLetter eq "BB")
			{
				nextLetter = "BC";				                     		
			}		
			else if (iLetter eq "BC")
			{
				nextLetter = "BD";				                     		
			}		
			else if (iLetter eq "BD")
			{
				nextLetter = "BE";				                     		
			}		
			else if (iLetter eq "BE")
			{
				nextLetter = "BF";			                     		
			}																
			else
			{
				nextLetter = "A";
			}
			// Return the Next Letter in the alphabet to the caller.
			return (nextLetter);
		}
		catch (Any appEx)
		{
			// Return the letter "A" to the caller, because there was an ERROR.
			return ("A");
		}
	</cfscript>                                                                                                         

</cffunction>

<cffunction access="public" name="IsValidSubAccount" displayname="IsValidSubAccount" returntype="Boolean"
			description="Returns whether or not the Sub Account exists in Comshare for the specified year." >
<cfargument name="cSubAccount" type="String" required="true">
<cfargument name="iYear" type="Numeric" required="true">
	
	<cfquery name="tmpCheckSubAccount" datasource="#ComshareDsName#">
		SELECT TOP 1
			YEAR_ID
		FROM 
			ALC.FINLOC_BASE
		WHERE 
			year_id = #Arguments.iYear# AND 
			unit_id= #RIGHT(Arguments.cSubAccount, 3)#;
	</cfquery> 
	
	<cfif tmpCheckSubAccount.RecordCount Is Not "0">
		<cfreturn true>
	<cfelse>
		<cfreturn false>
	</cfif>
</cffunction>

<cffunction name="FetchSubAccount" displayname="FetchSubAccount" access="public" returntype="query"
			description="Fetches the SubAccount record from the database using either the house id or the sub account number">
<cfargument name="iUseHouseId" type="boolean" required="true">
<cfargument name="iSubAccountOrHouseId" type="numeric" required="true">
		
	<cfif iUseHouseId eq true>
		<cfquery name="getSubAccount" datasource="#TipsDsName#">
			SELECT 
				cGLsubaccount,
				EHSIFacilityID 
			FROM 
				dbo.House 
			WHERE 
				(dtRowDeleted IS NULL) AND 
				(iHouse_ID = #iSubAccountOrHouseId#);
		</cfquery>
	<cfelse>
		<cfquery name="getSubAccount" datasource="#TipsDsName#">
			SELECT 
				 cGLsubaccount,
				EHSIFacilityID 
			FROM 
				dbo.House 
			WHERE 
				dtRowDeleted IS NULL AND 
				cGLSubAccount = '#iSubAccountOrHouseId#';
		</cfquery>
	</cfif>
	<cfreturn getSubAccount>
</cffunction>

<cffunction access="public" name="FetchHouseInfo" displayname="FetchHouseInfo" returntype="Query"
			description="Returns a DataSet containing the House Name and House id.">
<cfargument name="cSubAccount" type="String" required="true">
	
	<cfquery name="tmpFetchHouseInfo" datasource="#TipsDsName#">
		SELECT 
			iOpsArea_ID, 
			cName,
			(RIGHT(cGLSubAccount, 3)) AS unitId,
			iHouse_ID,
			cGLSubAccount,
			EHSIFacilityId
		FROM 
			House
		WHERE 
			cGLSubAccount = '#cSubAccount#'
	</cfquery>
	
	<cfreturn tmpFetchHouseInfo>
		
</cffunction>

<!--- BEGIN........New Code added for FTA-Rollup changes (05-03-2012)........BEGIN --->

<cffunction access="public" name="FetchDivisionInfo" displayname="FetchDivisionInfo" returntype="Query"
			description="Returns a Division info.">
<cfargument name="iDivisionId" type="string" required="true">

	<cfquery name="tmpFetchDivisionInfo" datasource="#FtaDsName#">
		select cName as Division, iRegion_ID as DivisionID from Maple.fta.dbo.vw_Region where iRegion_ID = cast('#iDivisionId#' as Int)
		<!---select distinct substring(n_orgLevel1, 10, len(n_OrgLevel1)) as Division, i_OrgLevel1Code as DivisionID from TimeCard.timecard.dbo.tbl_OrgLevels
		where i_OrgLevel1Code = cast('#iDivisionId#' as Int)--->
	</cfquery>
	
	<cfreturn tmpFetchDivisionInfo>
		
</cffunction>
<cffunction access="public" name="FetchRegionInfo" displayname="FetchRegionInfo" returntype="Query"
			description="Returns a Region Info.">
<cfargument name="iRegionId" type="string" required="true">

	<cfquery name="tmpFetchRegionInfo" datasource="#FtaDsName#">
		select cName as Region, iOPSArea_ID as RegionID from Maple.fta.dbo.vw_OpsArea where iOPSArea_ID = cast('#iRegionId#' as Int)
		<!---select distinct substring(n_orgLevel2, 7, len(n_OrgLevel2)) as Region, i_OrgLevel2Code as RegionID from TimeCard.timecard.dbo.tbl_OrgLevels
		where i_OrgLevel2Code = cast('#iRegionId#' as Int)--->
	</cfquery>
	
	<cfreturn tmpFetchRegionInfo>
		
</cffunction>

<cffunction access="public" name="FetchDashboardConsolidatedOccupancy" displayname="FetchDashboardConsolidatedOccupancy" returntype="Query"
			description="Returns a consolidated rollup information for the dashboard occupancy.">
<cfargument name="iPeriod" type="String" required="True">
	<cfquery name="tmpFetchDashboardConsolidatedOccupancy" datasource="#FtaDsName#">
		SELECT sum(fUnitsAvailable) as fUnitsAvailable, sum(fOccupiedUnits) as fOccupiedUnits, sum(fOccupiedUnitsBudget) as fOccupiedUnitsBudget,
			sum(fPhysicalTenants) as fPhysicalTenants, sum(fTenantsBudget) as fTenantsBudget,
			sum(fPhysicalAcuity)/count(ihouseid) as fPhysicalAcuity, count(ihouseid),
			case when (sum(fPhysicalAcuity)/count(ihouseid)) between 0 and 9 then 1
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 10 and 19 then 2
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 20 and 29 then 3
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 30 and 39 then 4
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 40 and 49 then 5
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 50 and 59 then 6
			else 7 end as cPhysicalAcuityLevel
		from (
			SELECT fUnitsAvailable, fOccupiedUnits, fOccupiedUnitsBudget,
				fPhysicalTenants, fTenantsBudget,
				fPhysicalAcuity,
				cPhysicalAcuityLevel, d.ihouseid, h.cName
			FROM dbo.DashboardOccupancyInfo d
			inner join DBProd01.Tips4.dbo.House h on d.iHouseid = h.iHouse_ID AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
			inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID and ops.iRegion_ID <> 12
			where cPeriod = '#iPeriod#' and d.fOccupiedUnits <> 0
			) a
	</cfquery>
	<cfreturn tmpFetchDashboardConsolidatedOccupancy>
</cffunction>

<cffunction access="public" name="FetchDashboardRollupOccupancy" displayname="FetchDashboardRollupOccupancy" returntype="Query"
			description="Returns a Regional rollup information for the dashboard occupancy.">
<cfargument name="iRegionIdOrDivisionId" type="string" required="true">
<cfargument name="iPeriod" type="String" required="True">
<cfargument name="rollup" type="numeric" required="True">
	<cfquery name="tmpFetchDashboardRollupOccupancy" datasource="#FtaDsName#">
		SELECT sum(fUnitsAvailable) as fUnitsAvailable, sum(fOccupiedUnits) as fOccupiedUnits, sum(fOccupiedUnitsBudget) as fOccupiedUnitsBudget,
			sum(fPhysicalTenants) as fPhysicalTenants, sum(fTenantsBudget) as fTenantsBudget,
			sum(fPhysicalAcuity)/count(ihouseid) as fPhysicalAcuity, count(ihouseid),
			case when (sum(fPhysicalAcuity)/count(ihouseid)) between 0 and 9.99999 then 1
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 10 and 19.99999 then 2
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 20 and 29.99999 then 3
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 30 and 39.99999 then 4
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 40 and 49.99999 then 5
				when (sum(fPhysicalAcuity)/count(ihouseid)) between 50 and 59.99999 then 6
			else 7 end as cPhysicalAcuityLevel 
		from (
			SELECT fUnitsAvailable, fOccupiedUnits, fOccupiedUnitsBudget,
				fPhysicalTenants, fTenantsBudget,
				fPhysicalAcuity,
				cPhysicalAcuityLevel, d.ihouseid, h.cName
			FROM dbo.DashboardOccupancyInfo d
			inner join DBProd01.Tips4.dbo.House h on d.iHouseid = h.iHouse_ID AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
			<cfif rollup is 3>
				WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
			<cfelseif rollup is 2>
				inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
			</cfif>
			and cPeriod = '#iPeriod#' and d.fOccupiedUnits <> 0
			) a
	</cfquery>
	<cfreturn tmpFetchDashboardRollupOccupancy>		
</cffunction>

<cffunction access="public" name="FetchDashboardRollupOccupancyDetails" displayname="FetchDashboardRollupOccupancyDetails" returntype="Query"
			description="Returns a Regional rollup information for the dashboard occupancy.">
<cfargument name="iRegionIdOrDivisionId" type="string" required="true">
<cfargument name="iPeriod" type="String" required="True">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="rollup" type="numeric" required="True">
	<cfquery name="tmpFetchDashboardRollupOccupancyDetails" datasource="#FtaDsName#">
		SELECT sum(fPhysicalTenants) as TotalResidents,
			fUnitsAvailable as fAvailableUnits, 
			fOccupiedUnits as fOccupancy, 
			fOccupiedUnitsBudget as fOccupancyBudget,
			fPhysicalTenants as fTenants, 
			convert(decimal(10,1), c.AvgServicePoints,101) as fPoints,
			isnull(b.iTwoPersonAssists,0) as  iTwoPersonAssists,
			c.fPoints as sumOfPoints,
			(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int)) as ccount,
			h.ihouse_id, h.cName, h.cGLSubAccount
		FROM dbo.DashboardOccupancyInfo d
		inner join DBProd01.Tips4.dbo.House h on d.iHouseid = h.iHouse_ID AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		left outer join (SELECT convert(decimal(5,1),sum(iTwoPersonAssists),101)/convert(decimal(5,1),day('#iTo#'),101) as iTwoPersonAssists, iHouseID
					FROM dbo.TwoPersonAssists t
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) and dtDeleted IS NULL AND dtCompareDate BETWEEN '#iFrom#' AND '#iTo#'
					group by iHouseID
			) b on b.ihouseid = h.iHouse_ID
		inner join (select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, sum(fPoints)/sum(fTenants) as AvgServicePoints,iopsarea_id,ihouseid
					from (
							select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, a.ihouseid,h.iopsarea_id
							from (
									SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
											(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints,t.iHouseId
									FROM HouseTenantCensus t 
									LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
									LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
									WHERE t.dtOccupancy BETWEEN '#iFrom#' AND'#iTo#' AND  t.cType = 'P' 
								)a
							inner join dbprod01.tips4.dbo.house h on a.ihouseid = h.ihouse_id and dtrowdeleted is null and bissandbox = 0
							where h.iopsarea_id = cast('#iRegionIdOrDivisionId#' as Int)
							group by a.ihouseid,h.iopsarea_id
						)b
					group by b.ihouseid,b.iopsarea_id
				)c on c.ihouseid = h.ihouse_id 
		<cfif rollup is 3>
			WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
		<cfelseif rollup is 2>
			inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
			WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
		</cfif>
		and cPeriod = '#iPeriod#' and d.fOccupiedUnits <> 0
		group by h.cName,h.iHouse_ID,h.cGLSubAccount, b.iTwoPersonAssists,c.AvgServicePoints, fUnitsAvailable, fOccupiedUnits, fOccupiedUnitsBudget,fPhysicalTenants, c.fPoints
		order by h.cName
	</cfquery>
	<cfreturn tmpFetchDashboardRollupOccupancyDetails>		
</cffunction>

<cffunction access="public" name="FetchRollupContactInfo" displayname="FetchRollupContactInfo" returntype="Query"
			description="Fetches the Contact Info of the personnels on the regional and divisional level.">
<cfargument name="cFullName" type="string" required="true">
	<cfquery name="tmpFetchRollupContactInfo" datasource="#FtaDsName#">
		<cfif cFullName is not "">
			  select distinct top 1 vc_PrimaryPhoneNumber as PhoneNumber
			  from [ALCPhoneDirectory].[dbo].[tbl_Employees] 
			  where vc_FullName like (ltrim(rtrim('#cFullName#'))) and bt_Active = 1
			  
		<cfelse>
			  select '-' as PhoneNumber
		</cfif>
	</cfquery>
	<!---<cfif tmpFetchRollupContactInfo.RecordCount is 0>
		<cfreturn "-">
	<cfelse>
		<cfreturn tmpFetchRollupContactInfo.PhoneNumber>			
	</cfif>--->
	<cfreturn tmpFetchRollupContactInfo>
</cffunction>

<cffunction access="public" name="FetchDashboardRollupInfo" displayname="FetchDashboardRollupInfo" returntype="Query"
			description="Returns a Regional rollup information for the dashboard.">
<cfargument name="iRegionIdOrDivisionId" type="string" required="true">
<cfargument name="rollup" type="numeric" required="true">
	<cfquery name="tmpFetchDashboardRollupInfo" datasource="#FtaDsName#">
		<cfif rollup is 3>
			select distinct u.iRegionID, 
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'RDO' and iRegionID = cast('#iRegionIdOrDivisionId#' as Int)) as RDOFullName,
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'RDO' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as RDOPhoneNumber,
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'RDQCS' and iRegionID = cast('#iRegionIdOrDivisionId#' as Int)) as RDQCSFullName, 
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'RDQCS' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as RDQCSPhoneNumber,
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'RDSM' and iRegionID = cast('#iRegionIdOrDivisionId#' as Int)) as RDSMFullName, 
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'RDSM' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as RDSMPhoneNumber,
			u.cScope as cRegionName, u.iDivisionID, r.cName as cDivisionName
			from [FTA].[dbo].[vw_UserAccountDetails] u
			inner join fta.dbo.vw_Region r on r.iRegion_ID = u.iDivisionID
			where u.iRegionID = cast('#iRegionIdOrDivisionId#' as Int) and cRole in ('RDO', 'RDQCS', 'RDSM') and u.cScopeType = 'Region'
		<cfelseif rollup is 2>
			select distinct  u.iDivisionID, r.cName as cDivisionName,
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DVP' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DVPFullName,
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DVP' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DVPPhoneNumber,
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DDHR' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DDHRFullName, 
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DDHR' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DDHRPhoneNumber,			
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DVPSM' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DVPSMFullName,
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DVPSM' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DVPSMPhoneNumber,
			(select distinct top 1 cFullName from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DVPQCM' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DVPQCMFullName, 
			(select distinct top 1 case when len(cPhoneNumber) < 10 and len(cPhoneNumber) = 4 then '262-257-' + cPhoneNumber else cPhoneNumber end as PhoneNumber from [FTA].[dbo].[vw_UserAccountDetails] where cRole = 'DVPQCM' and iDivisionID = cast('#iRegionIdOrDivisionId#' as Int)) as DVPQCMPhoneNumber
			from [FTA].[dbo].[vw_UserAccountDetails] u
			inner join fta.dbo.vw_Region r on r.iRegion_ID = u.iDivisionID
			where u.iDivisionID = cast('#iRegionIdOrDivisionId#' as Int) and cRole in ('DVP', 'DDHR', 'DVPSM', 'DVPQCM') and u.cScopeType = 'Division'
		</cfif>
	</cfquery>
	<cfreturn tmpFetchDashboardRollupInfo>
</cffunction>

<cffunction access="public" name="FetchLaborHoursConsolidated" displayname="FetchLaborHoursConsolidated" returntype="Query"
			description="Returns a labor hours for all Divisions.">
<cfargument name="iPeriod" type="String" required="True">
<!---<cfargument name="showDesc" type="boolean" required="true">--->
	<cfquery name="tmpFetchLaborHoursConsolidated" datasource="#FtaDsName#">
		SELECT lbrDtls.cPeriod,
			lbrDtls.iLaborTrackingCategoryId,
			lbrDtls.cLaborTrackingCategory,
			lbrDtls.cDisplayName,
			lbrDtls.iSortOrder,
			lbrDtls.bIsTraining,
			lbrDtls.bIsVisible,
			<!---<cfif showDesc is true>
				REPLACE(t.cDescription, (CHAR(13) + CHAR(10)), '<br />') AS cDescription,
			</cfif>--->
			sum(lbrDtls.fRegular) as fRegular,
			sum(lbrDtls.fOvertime) as fOvertime,
			sum(lbrDtls.fOther) as fOther,
			sum(lbrDtls.fAll) as fAll,
			sum(lbrDtls.fBudget) as fBudget,
			sum(Coalesce(bgtDtls.fVariableBudget, 0.0)) as fVariableBudget
		FROM dbo.LaborTrackingDetails lbrDtls
		LEFT JOIN dbo.LaborTrackingVariableBudgetDetailsHistory_1 bgtDtls	ON lbrDtls.iHouseId = bgtDtls.iHouseId AND
			lbrDtls.iLaborTrackingCategoryId = bgtDtls.iLaborTrackingCategoryId AND lbrDtls.cPeriod = bgtDtls.cPeriod 
				AND lbrDtls.iDay = bgtDtls.iDay 
		INNER JOIN dbprod01.tips4.dbo.house h on h.ihouse_id = lbrDtls.iHouseId
		<!---<cfif showDesc is true>
			LEFT JOIN LaborTrackingVariableBudgetDetails b ON bgtDtls.iLaborTrackingCategoryId = b.iLaborTrackingCategoryId AND
						b.iHouseId = bgtDtls.ihouseid AND	b.cPeriod = '#iPeriod#'
			LEFT JOIN LaborTrackingVariableBudgets vb ON b.iVariableBudgetId = vb.iVariableBudgetId
			LEFT JOIN ExpressionTrees t ON vb.iExpressionTree = t.iExpressionTreeId
		</cfif>--->
		INNER JOIN FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
		WHERE lbrDtls.cPeriod = '#iPeriod#' 
		Group by lbrDtls.iLaborTrackingCategoryID,lbrDtls.cPeriod,lbrDtls.cLaborTrackingCategory,
			<!---<cfif showDesc is true>t.cDescription,</cfif>--->
			lbrDtls.cDisplayName,lbrDtls.iSortOrder,lbrDtls.bisTraining,lbrDtls.bIsVisible
		ORDER BY lbrDtls.iSortOrder, lbrDtls.iLaborTrackingCategoryId;
	</cfquery>	
	<cfreturn tmpFetchLaborHoursConsolidated>		
</cffunction>

<cffunction access="public" name="FetchLaborHoursRollup" displayname="FetchLaborHoursRollup" returntype="Query"
			description="Returns a labor hours for all houses in a region.">
<cfargument name="iRegionIdORiHouseId" type="string" required="true">
<cfargument name="iPeriod" type="String" required="True">
<cfargument name="id" type="numeric" required="true">
<cfargument name="showDesc" type="boolean" required="true">
	<cfquery name="tmpFetchLaborHoursRollup" datasource="#FtaDsName#">
		SELECT lbrDtls.cPeriod,
			lbrDtls.iLaborTrackingCategoryId,
			lbrDtls.cLaborTrackingCategory,
			lbrDtls.cDisplayName,
			  lbrDtls.iSortOrder, 
 
			lbrDtls.bIsTraining,
			lbrDtls.bIsVisible,
			<cfif id is 3>
				<cfif showDesc is true>
					REPLACE(t.cDescription, (CHAR(13) + CHAR(10)), '<br />') AS cDescription,
				</cfif>
			</cfif>
			sum(lbrDtls.fRegular) as fRegular,
			sum(lbrDtls.fOvertime) as fOvertime,
			sum(lbrDtls.fOther) as fOther,
			sum(lbrDtls.fAll) as fAll,
			sum(lbrDtls.fBudget) as fBudget,
			sum(Coalesce(bgtDtls.fVariableBudget, 0.0)) as fVariableBudget
		FROM dbo.LaborTrackingDetails lbrDtls
		LEFT JOIN dbo.LaborTrackingVariableBudgetDetailsHistory_1 bgtDtls	ON lbrDtls.iHouseId = bgtDtls.iHouseId AND
			lbrDtls.iLaborTrackingCategoryId = bgtDtls.iLaborTrackingCategoryId AND lbrDtls.cPeriod = bgtDtls.cPeriod AND lbrDtls.iDay = bgtDtls.iDay 
		INNER JOIN dbprod01.tips4.dbo.house h on h.ihouse_id = lbrDtls.iHouseId
		<cfif id is 3>
			<cfif showDesc is true>
				LEFT JOIN LaborTrackingVariableBudgetDetails b ON bgtDtls.iLaborTrackingCategoryId = b.iLaborTrackingCategoryId AND
							b.iHouseId = bgtDtls.ihouseid AND	b.cPeriod = '#iPeriod#'
				LEFT JOIN LaborTrackingVariableBudgets vb ON b.iVariableBudgetId = vb.iVariableBudgetId
				LEFT JOIN ExpressionTrees t ON vb.iExpressionTree = t.iExpressionTreeId
			</cfif>
		</cfif>
		<cfif id is 2>
			INNER JOIN FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
		</cfif>
		WHERE lbrDtls.cPeriod = '#iPeriod#' AND 
		<cfif id is 1> 
			h.iOPSArea_ID = cast('#iRegionIdORiHouseId#' as Int) 
		<cfelseif id is 2> 
			ops.iRegion_ID = cast('#iRegionIdORiHouseId#' as Int) 		
		<cfelse> 
			h.iHouse_ID = cast('#iRegionIdORiHouseId#' as Int)
		</cfif>
		Group by lbrDtls.iLaborTrackingCategoryID,lbrDtls.cPeriod,lbrDtls.cLaborTrackingCategory,
			<cfif id is 3><cfif showDesc is true>t.cDescription,</cfif></cfif>
			lbrDtls.cDisplayName,		  lbrDtls.iSortOrder, 
	 
			lbrDtls.bisTraining
			,lbrDtls.bIsVisible
		ORDER BY 			   lbrDtls.iSortOrder
<!--- 						case when (lbrDtls.iSortOrder < 4 ) then lbrDtls.iSortOrder 
			  when  (lbrDtls.cDisplayName = 'Kitchen Services') then 4
			  when  (lbrDtls.cDisplayName = 'CRM') then 5
			else lbrDtls.iSortOrder +1
			end --->
			,  lbrDtls.iLaborTrackingCategoryId;
	</cfquery>	
	<cfreturn tmpFetchLaborHoursRollup>		
</cffunction>

<cffunction access="public" name="FetchActualConsolidatedSummary" displayname="FetchActualConsolidatedSummary" returntype="Query"
			description="Fetches the Actuals Summary DataSet.">
<cfargument name="iPeriod" type="string" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
	<cfquery name="tmpFetchActualConsolidatedSummary" datasource="#FtaDsName#">
		SELECT a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder, SUM(a.mAmount) AS mAmount	
		FROM (SELECT iExpenseCategoryId, cExpenseCategory, iSortOrder, Sum(IsNull(mAmount, 0.00)) AS mAmount
			FROM SpendDownInvoiceDetails s
			inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = s.ihouseid AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
			inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
			where cPeriod = '#iPeriod#' and bIsProcessed = 1 
			GROUP BY iExpenseCategoryId, cExpenseCategory, iSortOrder
			UNION
			SELECT c.iExpenseCategoryId, c.cExpenseCategory, c.iSortOrder, (0.0) AS mAmount
			FROM dbo.fn_GetExpenseCategoryDays('#iFrom#', '#iTo#') c
			WHERE ((SELECT  COUNT(m1.mAmount)  FROM  SpendDownInvoiceDetails m1
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = m1.ihouseid AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL 
					inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
					where m1.iExpenseCategoryId = c.iExpenseCategoryId 
					AND m1.cPeriod = '#iPeriod#') = 0)
			) a
		GROUP BY a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder
		ORDER BY a.iSortOrder;
	</cfquery>
	<cfreturn tmpFetchActualConsolidatedSummary>	
</cffunction>

<cffunction access="public" name="FetchActualRollupSummary" displayname="FetchActualRollupSummary" returntype="Query"
			description="Fetches the Actuals Summary DataSet.">
<cfargument name="iRegionIdOrDivisionId" type="String" required="true">
<cfargument name="iPeriod" type="string" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iRollup" type="numeric" required="true">
	<cfquery name="tmpFetchActualRollupSummary" datasource="#FtaDsName#">
		SELECT a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder, SUM(a.mAmount) AS mAmount	
		FROM (SELECT iExpenseCategoryId, cExpenseCategory, iSortOrder, Sum(IsNull(mAmount, 0.00)) AS mAmount
			FROM SpendDownInvoiceDetails s
			inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = s.ihouseid AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
			<cfif iRollup is 3>
				WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
			<cfelseif iRollup is 2>
				inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
			</cfif>
			AND cPeriod = '#iPeriod#' and bIsProcessed = 1 
			GROUP BY iExpenseCategoryId, cExpenseCategory, iSortOrder
			UNION
			SELECT c.iExpenseCategoryId, c.cExpenseCategory, c.iSortOrder, (0.0) AS mAmount
			FROM dbo.fn_GetExpenseCategoryDays('#iFrom#', '#iTo#') c
			WHERE ((SELECT  COUNT(m1.mAmount)  FROM  SpendDownInvoiceDetails m1
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = m1.ihouseid AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL 
					<cfif iRollup is 3>
						WHERE  h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
					<cfelseif iRollup is 2>
						inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
						WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 				
					</cfif>
					AND m1.iExpenseCategoryId = c.iExpenseCategoryId 
					AND m1.cPeriod = '#iPeriod#') = 0)
			) a
		GROUP BY a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder
		ORDER BY a.iSortOrder;
	</cfquery>
	<cfreturn tmpFetchActualRollupSummary>	
</cffunction>

<cffunction access="public" name="FetchBudgetConsolidatedSummary" displayname="FetchBudgetConsolidatedSummary" returntype="Query"
			description="Fetches the Budget Summary by querying the Budget Details.">
<cfargument name="iYear" type="numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchBudgetConsolidatedSummary" datasource="#FtaDsName#" >
		SELECT a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder, SUM(a.mAmount) AS mAmount	
		FROM (SELECT  iExpenseCategoryId, cExpenseCategory, iSortOrder, SUM(#iMonthCode#) AS mAmount
				FROM SpendDownBudgetDetails s
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = s.ihouseid AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				where iYear = #iYear#
				GROUP BY iExpenseCategoryId, cExpenseCategory, iSortOrder
			  UNION
			  SELECT iExpenseCategory_ID AS iExpenseCategoryId, vcExpenseCategory AS cExpenseCategory, iOrder AS iSortOrder, (0.0) AS mAmount
				FROM ExpenseCategory) a
		GROUP BY a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder
		ORDER BY a.iSortOrder;
	</cfquery>	
	<cfreturn tmpFetchBudgetConsolidatedSummary>
</cffunction>

<cffunction access="public" name="FetchBudgetRollupSummary" displayname="FetchBudgetRollupSummary" returntype="Query"
			description="Fetches the Budget Summary by querying the Budget Details.">
<cfargument name="iRegionIdOrDivisionId" type="String" required="true">
<cfargument name="iYear" type="numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
<cfargument name="iRollup" type="numeric" required="true">
	<cfquery name="tmpFetchBudgetRollupSummary" datasource="#FtaDsName#" >
		SELECT a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder, SUM(a.mAmount) AS mAmount	
		FROM (SELECT  iExpenseCategoryId, cExpenseCategory, iSortOrder, SUM(#iMonthCode#) AS mAmount
				FROM SpendDownBudgetDetails s
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = s.ihouseid AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				<cfif iRollup is 3>
					WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
				<cfelseif iRollup is 2>
					inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
					WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
				</cfif>
				AND iYear = #iYear#
				GROUP BY iExpenseCategoryId, cExpenseCategory, iSortOrder
			  UNION
			  SELECT iExpenseCategory_ID AS iExpenseCategoryId, vcExpenseCategory AS cExpenseCategory, iOrder AS iSortOrder, (0.0) AS mAmount
				FROM ExpenseCategory) a
		GROUP BY a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder
		ORDER BY a.iSortOrder;
	</cfquery>	
	<cfreturn tmpFetchBudgetRollupSummary>
</cffunction>

<cffunction access="public" name="FetchConsolidatedFoodBudgetAccumulator" displayname="FetchConsolidatedFoodBudgetAccumulator" returntype="Numeric"
			description="Fetches the Food Budget Accumulator value.">
<cfargument name="iYear" type="Numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchConsolidatedFoodBudgetAccumulator" datasource="#ComshareDsName#">
		SELECT TOP 1 #iMonthCode# AS fFoodBudget
		FROM ALC.FINLOC_BASE b
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = b.unit_id AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		inner join DBProd01.Tips4.dbo.OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
		where year_id = #iYear# AND Line_id = 80000137 AND  
			ver_id = 1 AND Cust1_id = 0  AND Cust2_id = 0 AND Cust3_id = 0 AND Cust4_id = 0;
	</cfquery>
	<cfif tmpFetchConsolidatedFoodBudgetAccumulator.RecordCount is "0">
		<cfreturn 0.0>
	<cfelse>
		<cfreturn tmpFetchConsolidatedFoodBudgetAccumulator.fFoodBudget>			
	</cfif>
</cffunction>

<cffunction access="public" name="FetchRollupFoodBudgetAccumulator" displayname="FetchRollupFoodBudgetAccumulator" returntype="Numeric"
			description="Fetches the Food Budget Accumulator value.">
<cfargument name="iRegionIdOrDivisionId" type="string" required="true">
<cfargument name="iYear" type="Numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
<cfargument name="iRollup" type="numeric" required="true">
	<cfquery name="tmpFetchRollupFoodBudgetAccumulator" datasource="#ComshareDsName#">
		SELECT TOP 1 #iMonthCode# AS fFoodBudget
		FROM ALC.FINLOC_BASE b
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = b.unit_id AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		<cfif iRollup is 3>
			WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
		<cfelseif iRollup is 2>
			inner join DBProd01.Tips4.dbo.OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
			WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
		</cfif>
			AND year_id = #iYear# AND Line_id = 80000137 AND  
			ver_id = 1 AND Cust1_id = 0  AND Cust2_id = 0 AND Cust3_id = 0 AND Cust4_id = 0;
	</cfquery>
	<cfif tmpFetchRollupFoodBudgetAccumulator.RecordCount is "0">
		<cfreturn 0.0>
	<cfelse>
		<cfreturn tmpFetchRollupFoodBudgetAccumulator.fFoodBudget>			
	</cfif>
</cffunction>

<cffunction access="public" name="FetchSumForExpenseSpenddownRollup" displayname="FetchSumForExpenseSpenddownRollup" returntype="Query"	description="Fetches the Sum for the Regions or division rollup.">
<cfargument name="iRegionIdOrDivisionId" type="String" required="true">
<cfargument name="iPeriod" type="string" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iMonthCode" type="string" required="true">
<cfargument name="iRollup" type="numeric" required="true">
<cfargument name="iFoodBudget" type="numeric" required="true">
	<cfquery name="tmpFetchSumForExpenseSpenddownRollup" datasource="#FtaDsName#">
		SELECT a.iExpenseCategoryId, a.cExpenseCategory, a.iSortOrder, 
				b.mAmount as bgtAmount, a.mAmount as actAmount, 
				case when a.iExpenseCategoryid = 1 then 
				/******* <!---	isnull(((SELECT sum(fTenants) as totalResidents FROM HouseTenantCensus t
							inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId 
								AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
							<cfif iRollup is 3>
								WHERE  h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
							<cfelseif iRollup is 2>
								inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
								WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 				
							</cfif>
							and dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND  cType = 'P' ) 
					* #iFoodBudget#) - a.mAmount,0.0) --->********/
					(SELECT isnull((Sum(fTenants) * #iFoodBudget#) - a.mAmount,0.0)
							FROM (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, 
								(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints
								FROM HouseTenantCensus t 
								LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
								LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
								inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
								<cfif iRollup is 3>
									WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
								<cfelseif iRollup is 2>
									inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
									WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
								</cfif>
								and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P')x)
				else isnull((b.mAmount - a.mAmount), 0.0) end as variance 
		FROM (SELECT a.iExpenseCategoryId,a.cExpenseCategory,a.iSortOrder,SUM(a.mAmount) AS mAmount
	    	  FROM (SELECT	iExpenseCategoryId,cExpenseCategory,iSortOrder,Sum(IsNull(mAmount, 0.00)) AS mAmount
					FROM SpendDownInvoiceDetails s
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = s.ihouseid 
									AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					<cfif iRollup is 3>
						WHERE  h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
					<cfelseif iRollup is 2>
						inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
						WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 				
					</cfif>
					AND	cPeriod = '#iPeriod#' and bIsProcessed = 1 
					GROUP BY iExpenseCategoryId,cExpenseCategory,iSortOrder
				  UNION
					SELECT	c.iExpenseCategoryId,	c.cExpenseCategory,	c.iSortOrder,(0.0) AS mAmount
					FROM	dbo.fn_GetExpenseCategoryDays('#iFrom#', '#iTo#') c
					WHERE	((SELECT COUNT(m1.mAmount) FROM SpendDownInvoiceDetails m1 
								inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = m1.ihouseid 
											AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
								<cfif iRollup is 3>
									WHERE  h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
								<cfelseif iRollup is 2>
									inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
									WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 				
								</cfif>
								 AND m1.iDay = c.iDay AND m1.iExpenseCategoryId = c.iExpenseCategoryId 
								 AND m1.cPeriod = '#iPeriod#'
							) = 0)
				)a
				GROUP BY	iExpenseCategoryId,	cExpenseCategory,	iSortOrder
			) a
		left outer join (SELECT a.iExpenseCategoryId,a.cExpenseCategory,a.iSortOrder,SUM(a.mAmount) AS mAmount
						FROM (SELECT iExpenseCategoryId,cExpenseCategory,iSortOrder,SUM(#iMonthCode#) AS mAmount
								FROM SpendDownBudgetDetails s
								inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = s.ihouseid 
													AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
								<cfif iRollup is 3>
									WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
								<cfelseif iRollup is 2>
									inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
									WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
								</cfif>
								AND iYear = year('#iFrom#')
								GROUP BY iExpenseCategoryId, cExpenseCategory, iSortOrder
							 UNION
							  SELECT iExpenseCategory_ID AS iExpenseCategoryId, vcExpenseCategory AS cExpenseCategory, 
							  			iOrder AS iSortOrder, (0.0) AS mAmount
								FROM ExpenseCategory
							) a
						GROUP BY a.iExpenseCategoryId,a.cExpenseCategory, a.iSortOrder
				) b on a.iExpenseCategoryid = b.iExpenseCategoryid
		
		
		<!---select iActualSummaryQuery.iExpenseCategoryId, 
					iActualSummaryQuery.cExpenseCategory,
					iActualSummaryQuery.iSortOrder, 
					sum(iActualSummaryQuery.mAmount) as mAmount
				from iActualSummaryQuery
			GROUP BY iActualSummaryQuery.iExpenseCategoryId,iActualSummaryQuery.cExpenseCategory,iActualSummaryQuery.iSortOrder
		) iActualSummaryQuery, iBudgetSummaryQuery
		where iBudgetSummaryQuery.iExpenseCategoryId = iActualSummaryQuery.iExpenseCategoryId--->
	</cfquery>	
	<cfreturn tmpFetchSumForExpenseSpenddownRollup>
</cffunction>

<cffunction access="public" name="FetchRollupCensusDetails" displayname="FetchRollupCensusDetails" returntype="Query"
			description="Fetches the Census Details.">
<cfargument name="iRegionId" type="String" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
	<cfquery name="tmpFetchRollupCensusDetails" datasource="#FtaDsName#">
		SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, 
				(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints
		FROM HouseTenantCensus t 
		LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
		LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P'
	</cfquery>
	
	<cfreturn tmpFetchRollupCensusDetails>
</cffunction>

<cffunction access="public" name="FetchConsolidatedCensusDetailsMTD" displayname="FetchConsolidatedCensusDetailsMTD" returntype="Numeric"
			description="Fetches the Census Details MTD.">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
	<cfquery name="tmpFetchConsolidatedCensusDetailsMTD" datasource="#FtaDsName#">
		SELECT isnull(Sum(fTenants),0) AS fTotalTenants
		FROM (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, 
		(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints
		FROM HouseTenantCensus t 
		LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
		LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
		where t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P') a
	</cfquery>
	
	<cfif tmpFetchConsolidatedCensusDetailsMTD.RecordCount is not "0">
		<cfreturn tmpFetchConsolidatedCensusDetailsMTD.fTotalTenants>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchRollupCensusDetailsMTD" displayname="FetchRollupCensusDetailsMTD" returntype="Numeric"
			description="Fetches the Census Details MTD.">
<cfargument name="iRegionIdOrDivisionId" type="String" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iRollup" type="numeric" required="true">
	<cfquery name="tmpFetchRollupCensusDetailsMTD" datasource="#FtaDsName#">
		SELECT isnull(Sum(fTenants),0) AS fTotalTenants
		FROM (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, 
		(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints
		FROM HouseTenantCensus t 
		LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
		LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		<cfif iRollup is 3>
			WHERE h.iOPSArea_ID = cast('#iRegionIdOrDivisionId#' as Int) 
		<cfelseif iRollup is 2>
			inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
			WHERE ops.iRegion_ID = cast('#iRegionIdOrDivisionId#' as Int) 
		</cfif>
		and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P') a
	</cfquery>
	
	<cfif tmpFetchRollupCensusDetailsMTD.RecordCount is not "0">
		<cfreturn tmpFetchRollupCensusDetailsMTD.fTotalTenants>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchRollupCensusDetailsPerDay" displayname="FetchRollupCensusDetailsPerDay" returntype="Numeric"
			description="Fetches the Census Details.">
<cfargument name="iRegionId" type="String" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iDay" type="Numeric" required="true">
	<cfquery name="tmpFetchRollupCensusDetailsPerDay" datasource="#FtaDsName#">
		SELECT fTenants 
		FROM (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, 
		(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints
		FROM HouseTenantCensus t 
		LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
		LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P') a
		WHERE iDay = #iDay# 
	</cfquery>
	
	<cfif tmpFetchRollupCensusDetailsPerDay.RecordCount is not "0">
		<cfreturn tmpFetchRollupCensusDetailsPerDay.fTenants>
	<cfelse>
		<cfreturn 0>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchCurrentCensusDetailsDivisionalRollup" displayname="FetchCurrentCensusDetailsDivisionalRollup" returntype="Query"
			description="Fetches the Census Details for the recent date.">
<cfargument name="iRegionId" type="String" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchCurrentCensusDetailsDivisionalRollup" datasource="#FtaDsName#">
		SELECT  sum(t.fTenants) as fTenants, sum(Coalesce(o.fOccupancy, 0.0)) AS fOccupancy, sum(o.fAvailable) as fAvailableUnits,
			(CASE WHEN sum(a.fAcuity) IS NULL THEN 0.0 
			ELSE (sum(a.fAcuity * t.fTenants)) / (select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionId#' as Int))
			END) AS fPoints,
			(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionId#' as Int)) as ccount,
			sum(ob.#iMonthCode#) as fOccupancyBudget, sum(isnull(p.iTwoPersonAssists,0)) as iTwoPersonAssists--, h.cName, h.iHouse_ID,h.cGLSubAccount
		FROM HouseTenantCensus t 
		LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
		LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
		left join HouseCensusBudget b on t.ihouseid = b.ihouseid and b.iyear = year('#iTo#')
		left join HouseOccupancyBudget ob on t.ihouseid = ob.ihouseid and ob.iyear = year('#iTo#')
		left join TwoPersonAssists p on p.ihouseid = t.iHouseId and p.dtCompareDate = '#iTo#'
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) and t.dtOccupancy = '#iTo#' AND t.cType = 'P'
--		order by cName
	</cfquery>	
	<cfreturn tmpFetchCurrentCensusDetailsDivisionalRollup>
</cffunction>

<cffunction access="public" name="FetchAverageDailyCensusDetailsRollup" displayname="FetchAverageDailyCensusDetailsRollup" returntype="Query"
			description="Fetches the Census Details.">
<cfargument name="iRegionId" type="String" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchAverageDailyCensusDetailsRollup" datasource="#FtaDsName#">
		select	a.cName, sum(a.fTenants) as TotalResidents, d.fPoints as sumOfPoints,
				c.fTenants as currTenants, c.foccupancy as currOccupancy, c.fPoints as currPoints,
				c.fAvailable as currAvailableUnits, c.fOccupancyBudget as currOccupancyBudget, c.iTwoPersonAssists as currTwoPersonAssists,
				convert(decimal(10,1), (sum(a.fTenants)/day('#iTo#')),101) as fTenants, 
				convert(decimal(10,1), (sum(a.fOccupancy)/day('#iTo#')),101) as fOccupancy, 
				<!---//convert(decimal(10,1), (sum(a.fPoints)/day('#iTo#'))/a.ccount,101) as fPoints,--->
				convert(decimal(10,1), d.AvgServicePoints,101) as fPoints,
				convert(decimal(10,1), (sum(a.fAvailable)/day('#iTo#')),101) as fAvailableUnits,
				convert(decimal(10,1), sum(a.fOccupancyBudget)/day('#iTo#'),101) as fOccupancyBudget, 	
				isnull(b.iTwoPersonAssists,0) as  iTwoPersonAssists, a.iHouse_id, a.cGLSubAccount, a.ccount
		From (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
					(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints, h.cName, h.iHouse_ID,h.cGLSubAccount,
					(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionId#' as Int)) as ccount,
					ob.#iMonthCode# as fOccupancyBudget
				FROM HouseTenantCensus t 
				LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
				LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
				left join HouseCensusBudget b on t.ihouseid = b.ihouseid and b.iyear = year('#iTo#')
				left join HouseOccupancyBudget ob on t.ihouseid = ob.ihouseid and ob.iyear = year('#iTo#')
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P'
			) a 
		left outer join (SELECT convert(decimal(5,1),sum(iTwoPersonAssists),101)/convert(decimal(5,1),day('#iTo#'),101) as iTwoPersonAssists, iHouseID
					FROM dbo.TwoPersonAssists t
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) and dtDeleted IS NULL AND dtCompareDate BETWEEN '#iFrom#' AND '#iTo#'
					group by iHouseID
			) b on b.ihouseid = a.iHouse_ID
		left outer join (SELECT  t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
						(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE ((a.fAcuity * t.fTenants) / t.fTenants) END) AS fPoints,
						(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionId#' as Int)) as ccount,
						ob.#iMonthCode# as fOccupancyBudget, isnull(p.iTwoPersonAssists,0) as iTwoPersonAssists, h.cName, h.iHouse_ID,h.cGLSubAccount
					FROM HouseTenantCensus t 
					LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
					LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
					left join HouseCensusBudget b on t.ihouseid = b.ihouseid and b.iyear = year('#iTo#')
					left join HouseOccupancyBudget ob on t.ihouseid = ob.ihouseid and ob.iyear = year('#iTo#')
					left join TwoPersonAssists p on p.ihouseid = t.iHouseId and p.dtCompareDate = '#iTo#'
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) and t.dtOccupancy = '#iTo#' AND t.cType = 'P'
			) c on c.ihouse_id = a.ihouse_id 
		inner join (select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, sum(fPoints)/sum(fTenants) as AvgServicePoints,iopsarea_id,ihouseid
					from (
							select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, a.ihouseid,h.iopsarea_id
							from (
									SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
											(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints,t.iHouseId
									FROM HouseTenantCensus t 
									LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
									LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
									WHERE t.dtOccupancy BETWEEN '#iFrom#' AND'#iTo#' AND  t.cType = 'P' 
								)a
							inner join dbprod01.tips4.dbo.house h on a.ihouseid = h.ihouse_id and dtrowdeleted is null and bissandbox = 0
							where h.iopsarea_id = cast('#iRegionId#' as Int)
							group by a.ihouseid,h.iopsarea_id
						)b
					group by b.ihouseid,b.iopsarea_id
				)d on d.ihouseid = a.ihouse_id 
		group by a.cName,b.iTwoPersonAssists,a.iHouse_ID,a.cGLSubAccount, a.ccount,d.AvgServicePoints,d.fPoints,
					c.fTenants,c.foccupancy,c.fPoints,c.fAvailable,c.fOccupancyBudget,c.iTwoPersonAssists
		order by a.cName
	</cfquery>
	
	<cfreturn tmpFetchAverageDailyCensusDetailsRollup>
</cffunction>

<cffunction access="public" name="FetchDivisionsForConsolidatedRollup" displayname="FetchDivisionsForConsolidatedRollup" returntype="Query"
			description="Fetches the Regions in the division.">
	<cfquery name="tmpFetchDivisionsForConsolidatedRollup" datasource="#FtaDsName#">
		select distinct reg.cName, reg.iRegion_ID
		from FTA.dbo.vw_Region reg
		where reg.iRegion_ID <> 12
		order by reg.cName
	</cfquery>	
	<cfreturn tmpFetchDivisionsForConsolidatedRollup>
</cffunction>

<cffunction access="public" name="FetchRegionsForDivisionalRollup" displayname="FetchRegionsForDivisionalRollup" returntype="Query"
			description="Fetches the Regions in the division.">
<cfargument name="iDivisionId" type="String" required="true">
	<cfquery name="tmpFetchRegionsForDivisionalRollup" datasource="#FtaDsName#">
		select distinct ops.cName, h.iOPSArea_ID 
		from DBProd01.Tips4.dbo.House h 
		inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
		WHERE ops.iRegion_ID = cast('#iDivisionId#' as Int) AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		order by ops.cName
	</cfquery>	
	<cfreturn tmpFetchRegionsForDivisionalRollup>
</cffunction>

<cffunction access="public" name="FetchAverageDailyCensusDetailsConsolidatedRollup" displayname="FetchAverageDailyCensusDetailsConsolidatedRollup" returntype="Query"
			description="Fetches the Census Details.">
<!---<cfargument name="iRegionIdOriDivisionID" type="String" required="true">--->
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iMonthCode" type="string" required="true">
<!---<cfargument name="islaborpage" type="boolean" required="true">--->
	<cfquery name="tmpFetchAverageDailyCensusDetailsConsolidatedRollup" datasource="#FtaDsName#">
		select x.iregion_id, r.cName,
			sum(TotalTenants) as TotalResidents,
			sum(fTenants) as fTenants, 
			sum(fOccupancy) as fOccupancy,
			sum(sumOfPoints)/sum(TotalTenants) as fPoints,
			isnull(sum(fAvailableUnits),0) as fAvailableUnits,
			isnull(sum(fOccupancyBudget),0) as fOccupancyBudget,
			sum(currTenants) as currTenants, 
			sum(currOccupancy) as currOccupancy,
			sum(currPoints)/ccount as currPoints,
			sum(currAvailableUnits) as currAvailableUnits,
			sum(currOccupancyBudget) as currOccupancyBudget,
			sum(currTwoPersonAssists) as currTwoPersonAssists,		
			sum(iTwoPersonAssists) as iTwoPersonAssists, ccount
		FROM	(select	a.cName, c.fTenants as currTenants, c.foccupancy as currOccupancy, c.fPoints as currPoints, d.fPoints as sumOfPoints, sum(a.fTenants) as TotalTenants,
				c.fAvailable as currAvailableUnits, c.fOccupancyBudget as currOccupancyBudget, c.iTwoPersonAssists as currTwoPersonAssists,
				convert(decimal(10,1), (sum(a.fTenants)/day('#iTo#')),101) as fTenants, 
				convert(decimal(10,1), (sum(a.fOccupancy)/day('#iTo#')),101) as fOccupancy, 
				convert(decimal(10,1), d.AvgServicePoints,101) as fPoints,
				convert(decimal(10,1), (sum(a.fAvailable)/day('#iTo#')),101) as fAvailableUnits,
				convert(decimal(10,1), sum(a.fOccupancyBudget)/day('#iTo#'),101) as fOccupancyBudget, 	
				isnull(b.iTwoPersonAssists,0) as  iTwoPersonAssists, a.ccount,d.iregion_id
			From (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
						(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints, h.cName, h.iHouse_ID,h.cGLSubAccount,
						(select count(distinct iHouse_ID) as ccount from DBProd01.Tips4.dbo.House) as ccount,
						#iMonthCode# as fOccupancyBudget
					FROM HouseTenantCensus t 
					LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
					LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
					left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					WHERE t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P'
				) a 
			left outer join (SELECT convert(decimal(5,1),sum(iTwoPersonAssists),101)/convert(decimal(5,1),day('#iTo#'),101) as iTwoPersonAssists, iHouseID
						FROM dbo.TwoPersonAssists t
						inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
						WHERE dtDeleted IS NULL AND dtCompareDate BETWEEN '#iFrom#' AND '#iTo#'
						group by iHouseID
				) b on b.ihouseid = a.iHouse_ID
			left outer join ( SELECT  t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
				(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE ((a.fAcuity * t.fTenants) / t.fTenants) END) AS fPoints,
				(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House) as ccount,
				#iMonthCode# as fOccupancyBudget, isnull(p.iTwoPersonAssists,0) as iTwoPersonAssists, h.cName, h.iHouse_ID,h.cGLSubAccount
			 FROM HouseTenantCensus t 
			LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
			LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
			left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
			left join TwoPersonAssists p on p.ihouseid = t.iHouseId and p.dtCompareDate = '#iTo#'
			inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
			WHERE t.dtOccupancy = '#iTo#' AND t.cType = 'P'
				) c on c.ihouse_id = a.ihouse_id 
			inner join (select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, sum(fPoints)/sum(fTenants) as AvgServicePoints,iregion_id,ihouseid
						from (
								select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, a.ihouseid,h.iopsarea_id, o.iregion_id
								from (
										SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
												(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints,t.iHouseId
										FROM HouseTenantCensus t 
										LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
										LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
										WHERE t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND  t.cType = 'P' 
									)a
								inner join dbprod01.tips4.dbo.house h on a.ihouseid = h.ihouse_id and dtrowdeleted is null and bissandbox = 0
								inner join fta.dbo.vw_OPSArea o on o.iOPSArea_ID = h.iOPSArea_ID
								group by a.ihouseid,h.iopsarea_id, o.iregion_id
							)b
						group by b.ihouseid,b.iopsarea_id,b.iregion_id
					)d on d.ihouseid = a.ihouse_id 
			group by d.iregion_id,a.cName,b.iTwoPersonAssists, a.ccount,d.AvgServicePoints,d.fPoints,
						c.fTenants,c.foccupancy,c.fPoints,c.fAvailable,c.fOccupancyBudget,c.iTwoPersonAssists
			) x
			join fta.dbo.vw_Region r on x.iregion_id = r.iregion_id and r.iregion_id <> 12
			group by x.iregion_id, r.cname, ccount

<!---/*		select sum(TotalTenants) as TotalResidents,
			sum(fTenants) as fTenants, 
			sum(fOccupancy) as fOccupancy,
			sum(sumOfPoints)/sum(TotalTenants) as fPoints,
			isnull(sum(fAvailableUnits),0) as fAvailableUnits,
			isnull(sum(fOccupancyBudget),0) as fOccupancyBudget,
			sum(currTenants) as currTenants, 
			sum(currOccupancy) as currOccupancy,
			sum(currPoints)/ccount as currPoints,
			sum(currAvailableUnits) as currAvailableUnits,
			sum(currOccupancyBudget) as currOccupancyBudget,
			sum(currTwoPersonAssists) as currTwoPersonAssists,		
			sum(iTwoPersonAssists) as iTwoPersonAssists, ccount
		FROM
			(select	a.cName, c.fTenants as currTenants, c.foccupancy as currOccupancy, c.fPoints as currPoints, d.fPoints as sumOfPoints, sum(a.fTenants) as TotalTenants,
				c.fAvailable as currAvailableUnits, c.fOccupancyBudget as currOccupancyBudget, c.iTwoPersonAssists as currTwoPersonAssists,
				convert(decimal(10,1), (sum(a.fTenants)/day('#iTo#')),101) as fTenants, 
				convert(decimal(10,1), (sum(a.fOccupancy)/day('#iTo#')),101) as fOccupancy, 
				convert(decimal(10,1), d.AvgServicePoints,101) as fPoints,
				convert(decimal(10,1), (sum(a.fAvailable)/day('#iTo#')),101) as fAvailableUnits,
				convert(decimal(10,1), sum(a.fOccupancyBudget)/day('#iTo#'),101) as fOccupancyBudget, 	
				isnull(b.iTwoPersonAssists,0) as  iTwoPersonAssists, a.ccount
			From 
				(SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
						(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints, ops.cName, h.iOPSArea_ID,
						(select count(iOPSArea_ID) as ccount from fta.dbo.vw_OPSArea where iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int)) as ccount,
						#iMonthCode# as fOccupancyBudget
				FROM HouseTenantCensus t 
				LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
				LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
				left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				inner join fta.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				WHERE ops.iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int) and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P'
				) 
			a 
			left outer join 
				(SELECT convert(decimal(5,1),sum(iTwoPersonAssists),101)/convert(decimal(5,1),day('#iTo#'),101) as iTwoPersonAssists, h.iOPSArea_ID
				FROM dbo.TwoPersonAssists t
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				inner join fta.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				WHERE ops.iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int) and dtDeleted IS NULL AND dtCompareDate BETWEEN '#iFrom#' AND '#iTo#'
				group by h.iOPSArea_ID
				) 
			b on b.iOPSArea_ID = a.iOPSArea_ID
			left outer join 
				(SELECT  t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
						CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE ((a.fAcuity * t.fTenants) / t.fTenants) END AS fPoints,
						(select count(iOPSArea_ID) as ccount from fta.dbo.vw_OPSArea where iregion_ID = 2) as ccount,
						#iMonthCode# as fOccupancyBudget, isnull(p.iTwoPersonAssists,0) as iTwoPersonAssists, ops.cName, h.iOPSArea_ID
				FROM HouseTenantCensus t 
				LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
				LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
				left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
				left join TwoPersonAssists p on p.ihouseid = t.iHouseId and p.dtCompareDate = '#iTo#'
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				inner join fta.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				WHERE ops.iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int) and t.dtOccupancy = '#iTo#' AND t.cType = 'P'
				) 
			c on c.iOPSArea_ID = a.iOPSArea_ID 
			inner join 
				(select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, sum(fPoints)/sum(fTenants) as AvgServicePoints,iopsarea_id,iregion_id
				from 
					(select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, ops.iregion_id,h.iopsarea_id
					from 
						(SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
								(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints,t.iHouseId
						FROM HouseTenantCensus t 
						LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
						LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
						WHERE t.dtOccupancy BETWEEN '#iFrom#' AND'#iTo#' AND  t.cType = 'P' 
						)
					a
					inner join dbprod01.tips4.dbo.house h on a.ihouseid = h.ihouse_id and dtrowdeleted is null and bissandbox = 0
					inner join fta.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
					where ops.iregion_id = cast('#iRegionIdOriDivisionID#' as Int)
					group by ops.iregion_id,h.iopsarea_id
					)
				b
				group by b.iregion_id,b.iopsarea_id
				)
			d on d.iopsarea_id = a.iopsarea_id 
			group by a.cName,b.iTwoPersonAssists, a.ccount,d.AvgServicePoints,d.fPoints,
						c.fTenants,c.foccupancy,c.fPoints,c.fAvailable,c.fOccupancyBudget,c.iTwoPersonAssists
			) 
		x
		group by ccount	*/--->
	</cfquery>
	
	<cfreturn tmpFetchAverageDailyCensusDetailsConsolidatedRollup>
</cffunction>

<cffunction access="public" name="FetchAverageDailyCensusDetailsDivisionalRollup" displayname="FetchAverageDailyCensusDetailsDivisionalRollup" returntype="Query"
			description="Fetches the Census Details.">
<cfargument name="iRegionIdOriDivisionID" type="String" required="true">
<cfargument name="iFrom" type="Date" required="true">
<cfargument name="iTo" type="Date" required="true">
<cfargument name="iMonthCode" type="string" required="true">
<cfargument name="islaborpage" type="boolean" required="true">
	<cfquery name="tmpFetchAverageDailyCensusDetailsDivisionalRollup" datasource="#FtaDsName#">
	<cfif islaborpage is false>
		select sum(TotalTenants) as TotalResidents,
			sum(fTenants) as fTenants, 
			sum(fOccupancy) as fOccupancy,
			sum(sumOfPoints)/sum(TotalTenants) as fPoints,
			isnull(sum(fAvailableUnits),0) as fAvailableUnits,
			isnull(sum(fOccupancyBudget),0) as fOccupancyBudget,
			sum(currTenants) as currTenants, 
			sum(currOccupancy) as currOccupancy,
			sum(currPoints)/ccount as currPoints,
			sum(currAvailableUnits) as currAvailableUnits,
			sum(currOccupancyBudget) as currOccupancyBudget,
			sum(currTwoPersonAssists) as currTwoPersonAssists,		
			sum(iTwoPersonAssists) as iTwoPersonAssists, ccount
		FROM
			(select	a.cName, c.fTenants as currTenants, c.foccupancy as currOccupancy, c.fPoints as currPoints, d.fPoints as sumOfPoints, sum(a.fTenants) as TotalTenants,
				c.fAvailable as currAvailableUnits, c.fOccupancyBudget as currOccupancyBudget, c.iTwoPersonAssists as currTwoPersonAssists,
				convert(decimal(10,1), (sum(a.fTenants)/day('#iTo#')),101) as fTenants, 
				convert(decimal(10,1), (sum(a.fOccupancy)/day('#iTo#')),101) as fOccupancy, 
				<!---convert(decimal(10,1), (sum(a.fPoints)/day('#iTo#'))/a.ccount,101) as fPoints,--->
				convert(decimal(10,1), d.AvgServicePoints,101) as fPoints,
				convert(decimal(10,1), (sum(a.fAvailable)/day('#iTo#')),101) as fAvailableUnits,
				convert(decimal(10,1), sum(a.fOccupancyBudget)/day('#iTo#'),101) as fOccupancyBudget, 	
				isnull(b.iTwoPersonAssists,0) as  iTwoPersonAssists, a.ccount
			From (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
						(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints, h.cName, h.iHouse_ID,h.cGLSubAccount,
						(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionIdOriDivisionID#' as Int)) as ccount,
						#iMonthCode# as fOccupancyBudget
					FROM HouseTenantCensus t 
					LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
					LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
					left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					WHERE h.iOPSArea_ID = cast('#iRegionIdOriDivisionID#' as Int) and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P'
				) a 
			left outer join (SELECT convert(decimal(5,1),sum(iTwoPersonAssists),101)/convert(decimal(5,1),day('#iTo#'),101) as iTwoPersonAssists, iHouseID
						FROM dbo.TwoPersonAssists t
						inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
						WHERE h.iOPSArea_ID = cast('#iRegionIdOriDivisionID#' as Int) and dtDeleted IS NULL AND dtCompareDate BETWEEN '#iFrom#' AND '#iTo#'
						group by iHouseID
				) b on b.ihouseid = a.iHouse_ID
			left outer join (SELECT  t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
							(CASE WHEN a.fAcuity IS NULL THEN 0.0 
							ELSE ((a.fAcuity * t.fTenants) / t.fTenants)
							<!---(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionIdOriDivisionID#' as Int))--->
							END) AS fPoints,
							(select count(iHouse_ID) as ccount from DBProd01.Tips4.dbo.House where iOPSArea_ID = cast('#iRegionIdOriDivisionID#' as Int)) as ccount,
							#iMonthCode# as fOccupancyBudget, isnull(p.iTwoPersonAssists,0) as iTwoPersonAssists, h.cName, h.iHouse_ID,h.cGLSubAccount
						FROM HouseTenantCensus t 
						LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
						LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
						left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
						left join TwoPersonAssists p on p.ihouseid = t.iHouseId and p.dtCompareDate = '#iTo#'
						inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
						WHERE h.iOPSArea_ID = cast('#iRegionIdOriDivisionID#' as Int) and t.dtOccupancy = '#iTo#' AND t.cType = 'P'
				) c on c.ihouse_id = a.ihouse_id 
			inner join (select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, sum(fPoints)/sum(fTenants) as AvgServicePoints,iopsarea_id,ihouseid
						from (
								select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, a.ihouseid,h.iopsarea_id
								from (
										SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
												(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints,t.iHouseId
										FROM HouseTenantCensus t 
										LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
										LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
										WHERE t.dtOccupancy BETWEEN '#iFrom#' AND'#iTo#' AND  t.cType = 'P' 
									)a
								inner join dbprod01.tips4.dbo.house h on a.ihouseid = h.ihouse_id and dtrowdeleted is null and bissandbox = 0
								where h.iopsarea_id = cast('#iRegionIdOriDivisionID#' as Int)
								group by a.ihouseid,h.iopsarea_id
							)b
						group by b.ihouseid,b.iopsarea_id
					)d on d.ihouseid = a.ihouse_id 
			group by a.cName,b.iTwoPersonAssists, a.ccount,d.AvgServicePoints,d.fPoints,
						c.fTenants,c.foccupancy,c.fPoints,c.fAvailable,c.fOccupancyBudget,c.iTwoPersonAssists
			) x
		group by ccount
		</cfif>
<cfif islaborpage is true>
		select	cName, sum(a.fTenants) as TotalResidents, d.fPoints as sumOfPoints,
				convert(decimal(10,1), (sum(a.fTenants)/day('#iTo#'))/a.ccount,101) as fTenants, 
				convert(decimal(10,1), (sum(a.fOccupancy)/day('#iTo#'))/a.ccount,101) as fOccupancy, 
				<!---convert(decimal(10,1), (sum(a.fPoints)/day('#iTo#'))/a.ccount,101) as fPoints,--->
				convert(decimal(10,1), d.AvgServicePoints,101) as fPoints,
				convert(decimal(10,1), (sum(a.fAvailable)/day('#iTo#'))/a.ccount,101) as fAvailableUnits,				
				isnull(b.iTwoPersonAssists,0) as  iTwoPersonAssists, a.iOPSArea_ID, a.ccount
		From (SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay, t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy, o.fAvailable,
						(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints, ops.cName, h.iOPSArea_ID,
						(select count(iOPSArea_ID) as ccount from FTA.dbo.vw_OPSArea where iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int)) as ccount
				FROM HouseTenantCensus t 
				LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
				LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
				left join HouseCensusBudget b on t.ihouseid = b.ihouseid and iyear = year('#iTo#')
				inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
				inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
				WHERE ops.iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int) and t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND t.cType = 'P'
			) a 
		left outer join (SELECT convert(decimal(5,1),sum(iTwoPersonAssists),101)/convert(decimal(5,1),day('#iTo#'),101) as iTwoPersonAssists, o.iopsarea_id
					FROM dbo.TwoPersonAssists t
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					inner join FTA.dbo.vw_OPSArea o on o.iOPSArea_ID = h.iOPSArea_ID
					WHERE o.iRegion_ID = cast('#iRegionIdOriDivisionID#' as Int) and dtDeleted IS NULL AND dtCompareDate BETWEEN '#iFrom#' AND '#iTo#'
					group by o.iopsarea_id
				) b on b.iOPSArea_ID = a.iOPSArea_ID
		inner join (select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fpoints, sum(fPoints)/sum(fTenants) as AvgServicePoints,iopsarea_id,iregion_id
					from (
							select sum(fTenants) as fTenants, sum(fOccupancy) as fOccupancy, sum(fPoints) as fPoints, h.iopsarea_id,ops.iregion_id
							from (
									SELECT (DateDiff(Day, '#iFrom#', t.dtOccupancy) + 1) AS iDay,t.fTenants, Coalesce(o.fOccupancy, 0.0) AS fOccupancy,
											(CASE WHEN a.fAcuity IS NULL THEN 0.0 ELSE a.fAcuity * t.fTenants END) AS fPoints,t.iHouseId
									FROM HouseTenantCensus t 
									LEFT JOIN vw_HouseOccupancy o ON t.iHouseId = o.iHouseId AND t.dtOccupancy = o.dtOccupancy
									LEFT JOIN HouseAcuity a ON t.iHouseId = a.iHouseId AND t.dtOccupancy = a.dtOccupancy AND t.cType = a.cType
									WHERE t.dtOccupancy BETWEEN '#iFrom#' AND '#iTo#' AND  t.cType = 'P' 
								)a
							inner join dbprod01.tips4.dbo.house h on a.ihouseid = h.ihouse_id and dtrowdeleted is null and bissandbox = 0
							inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
							where ops.iregion_id = cast('#iRegionIdOriDivisionID#' as Int)
							group by ops.iregion_id,h.iopsarea_id
						)b
					group by b.iregion_id,b.iopsarea_id
				)d on d.iOPSArea_ID = a.iOPSArea_ID
		group by cName,b.iTwoPersonAssists,a.iOPSArea_ID, a.ccount,d.AvgServicePoints, d.fPoints
		order by cName	
	</cfif>
	</cfquery>
	
	<cfreturn tmpFetchAverageDailyCensusDetailsDivisionalRollup>
</cffunction>

<cffunction access="public" name="FetchAverageMTDCensusDetailsRollup" displayname="FetchAverageMTDCensusDetailsRollup" returntype="Query"
			description="Returns the Labor data for the specified Day in the period.">
<cfargument name="iAverageDailyCensusDetailsQuery" type="Query" required="true">
<cfargument name="rollup" type="numeric" required="true">
<cfargument name="isCensusPage" type="boolean" required="true">
	<cfquery name="tmpFetchAverageMTDCensusDetailsRollup" dbtype="Query">
		select sum(TotalResidents) as TotalResidents,sum(fTenants) as TotalTenants, 
			sum(fOccupancy) as TotalOccupancy,
			<cfif rollup is 1>sum(fPoints)/sum(TotalResidents) as TotalPoints,<cfelse>sum(sumOfPoints)/sum(TotalResidents) as TotalPoints,</cfif>
			sum(fAvailableUnits) as TotalAvailableUnits,
			<cfif rollup is 3 and isCensusPage is true>
				sum(fOccupancyBudget) as TotalOccupancyBudget,
				sum(currTenants) as TotalCurrTenants, 
				sum(currOccupancy) as TotalCurrOccupancy,
				sum(currPoints)/ccount as TotalCurrPoints,
				sum(currAvailableUnits) as TotalCurrAvailableUnits,
				sum(currOccupancyBudget) as TotalCurrOccupancyBudget,
				sum(currTwoPersonAssists) as TotalCurrTwoPersonAssists,		
			</cfif>
			sum(iTwoPersonAssists) as TotalTwoPersonAssists
		FROM
			iAverageDailyCensusDetailsQuery
		group by ccount
	</cfquery>	
	<cfreturn tmpFetchAverageMTDCensusDetailsRollup>
</cffunction>

<!---<cffunction access="public" name="FetchWDSLaborHoursRegionalRollup" displayname="FetchWDSLaborHoursRegionalRollup" returntype="Query"
			description="Returns a labor hours for WDS in houses in a region.">
<cfargument name="iHouseId" type="string" required="true">
<cfargument name="iPeriod" type="String" required="True">
	<cfquery name="tmpFetchWDSLaborHoursRegionalRollup" datasource="#FtaDsName#">
		select top 1 (case when nStatus = 'A' then iWorkWeekHours else 0 end) as iWorkWeekHours,
				(case when nStatus = 'A' then fAllocationPercentage * 100 else 0 end) as fAllocationPercentage,
				h.iHouse_ID
		from LaborTrackingWDSDaily
		inner join DBProd01.Tips4.dbo.House h on substring(h.cGLSubAccount,7,9) = iOrglevel3Code AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		where nPeriod = '#iPeriod#' and h.iHouse_ID = cast('#iHouseId#' as Int)
		order by dDateCreated desc, dHireDate desc, dTermDate desc
	</cfquery>
	
	<cfreturn tmpFetchWDSLaborHoursRegionalRollup>
</cffunction>--->
<cffunction access="public" name="FetchMTDLaborHoursRollup" displayname="FetchMTDLaborHoursRollup" returntype="Query"
			description="Returns the total Labor data for the specified region in the period.">
<cfargument name="iLaborHoursQuery" type="Query" required="true">
<cfargument name="TypeOfTotal" type="numeric" required="true"> <!--- TypeOfTotal=1 (CtgyTotal); TypeOfTotal=2 (NursingTotal); TypeOfTotal=3 (TotalofEverything) --->

	<cfquery name="tmpFetchMTDLaborHoursRollup" dbtype="Query">
		<cfif TypeOfTotal is 1>
			select	iLaborTrackingCategoryID, iSortOrder,
				claborTrackingCategory,bIsVisible,bIsTraining,<!---cDescription,--->
				sum(fRegular) as fRegular,
				sum(fOvertime) as fOvertime,
				sum(fOther) as fOther,
				sum(fAll) as fAll,
				(sum(fRegular)+sum(fOvertime)+sum(fOther)+sum(fAll)) as fActual,
				sum(fBudget) as fBudget,
				sum(fVariableBudget) as fVariableBudget,
				(sum(fVariableBudget)- (sum(fRegular)+sum(fOvertime)+sum(fOther)+sum(fAll))) as Variance
			FROM
				iLaborHoursQuery
			where bIsVisible = 1
			Group by iLaborTrackingCategoryID,claborTrackingCategory,bIsVisible,bIsTraining,iSortOrder<!---,cDescription--->
			ORDER BY iSortOrder,iLaborTrackingCategoryId;
		<cfelseif TypeOfTotal is 2>
			select (sum(fRegular)+sum(fOvertime)+sum(fOther)) as NursingActual,
					sum(fVariableBudget) as NursingBudget,
					(sum(fVariableBudget)- (sum(fRegular)+sum(fOvertime)+sum(fOther))) as NursingVariance
			FROM
				iLaborHoursQuery
			where iLaborTrackingCategoryId in (1,2,3)
		<cfelse>
			select (sum(fRegular)+sum(fOvertime)+sum(fOther)+sum(fAll)) as TotalActual,
					sum(fVariableBudget) as TotalBudget,
					(sum(fVariableBudget)- (sum(fRegular)+sum(fOvertime)+sum(fOther)+sum(fAll))) as TotalVariance
			FROM
				iLaborHoursQuery
		</cfif>
	</cfquery>	
	<cfreturn tmpFetchMTDLaborHoursRollup>
</cffunction>

<cffunction access="public" name="FetchDivisionalCensusBudgetRollup" displayname="FetchDivisionalCensusBudgetRollup" returntype="Numeric"
			description="Fetches the Census Details.">
<cfargument name="iRegionId" type="String" required="true">
<cfargument name="iYear" type="Numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchDivisionalCensusBudgetRollup" datasource="#FtaDsName#">
		SELECT top 1 sum(#iMonthCode#) AS fOccupancyBudget FROM HouseCensusBudget t
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		WHERE h.iOPSArea_ID = cast('#iRegionId#' as Int) AND iYear = #iYear# 
	</cfquery>	
	<cfreturn tmpFetchDivisionalCensusBudgetRollup.fOccupancyBudget>
</cffunction>

<cffunction access="public" name="FetchConsolidatedCensusBudgetRollup" displayname="FetchConsolidatedCensusBudgetRollup" returntype="Numeric"
			description="Fetches the Census Details.">
<cfargument name="iDivisionId" type="String" required="true">
<cfargument name="iYear" type="Numeric" required="true">
<cfargument name="iMonthCode" type="string" required="true">
	<cfquery name="tmpFetchConsolidatedCensusBudgetRollup" datasource="#FtaDsName#">
		SELECT top 1 sum(#iMonthCode#) AS fOccupancyBudget FROM HouseCensusBudget t
		inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = t.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		inner join FTA.dbo.vw_OPSArea ops on ops.iOPSArea_ID = h.iOPSArea_ID
		WHERE ops.iRegion_ID = cast('#iDivisionId#' as Int) AND iYear = #iYear# 
	</cfquery>	
	<cfreturn tmpFetchConsolidatedCensusBudgetRollup.fOccupancyBudget>
</cffunction>

<cffunction access="public" name="FetchLaborTrackingDivisionalWDHVarBgt" displayname="FetchLaborTrackingDivisionalWDHVarBgt" returntype="query"
			description="Returns the VariableBudget of the hourly Wellness Director at divisional level.">
<cfargument name="iRegionIdOriDivisionId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">
<cfargument name="islaborpage" type="boolean" required="true">
	<cfquery name="tmpFetchLaborTrackingDivisionalWDHVarBgt" datasource="#FtaDsName#">
		select sum(varbgt) as varbgt 
		from (select case when nStatus = 'T' or nStatus is null then sum(varbgt) else '' end as varbgt
				from (select sum(fVariableBudget) as varbgt, ihouseid, fWorkWeekAllocation, nStatus, h.cName,dDateCreated 
					from LaborTrackingVariableBudgetDetailsHistory_1 vb
					inner join DBProd01.Tips4.dbo.House h on h.ihouse_id = vb.iHouseId AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
					outer apply (select top 1 * from labortrackingwdsdaily l
								inner join DBProd01.Tips4.dbo.House hh on substring(h.cGLSubAccount,7,9) = l.iorglevel3code 
										AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
								where hh.ihouse_id = h.ihouse_id and l.nPeriod = vb.cPeriod order by dDateCreated desc, dHireDate desc, dTermDate desc) s
					<cfif islaborpage is false>
						inner join DBProd01.Tips4.dbo.OPSArea ops on ops.iopsarea_id = h.iopsarea_id
						where ops.iregion_id = cast('#iRegionIdOriDivisionId#' as Int)
					<cfelse>
						where h.iopsarea_id = cast('#iRegionIdOriDivisionId#' as Int)
					</cfif>
					and cPeriod = '#iPeriod#' AND ilabortrackingcategoryid = 14
					group by ihouseid, fWorkWeekAllocation,h.cName, nStatus,dDateCreated  
					--order by h.cName,dDateCreated desc
			) a
			group by nStatus
		) b
	</cfquery>	
	<cfreturn tmpFetchLaborTrackingDivisionalWDHVarBgt>
</cffunction>

<cffunction access="public" name="Fetch12MonthPrivateCensusTrend" displayname="Fetch12MonthPrivateCensusTrend" returntype="Query"
			description="Returns the 12 month private census trend, which includes the budget.">
<cfargument name="iScopeId" type="Numeric" required="true">
<cfargument name="iMtd" type="Date" required="true" >
<cfargument name="iRollup" type="numeric" required="True">
	<cfquery name="tmpFetch12MonthPrivateCensusTrend" datasource="#FtaDsName#">
		EXECUTE dbo.usp_GetPrivateCensus12MonthTrend #iScopeId#, '#iMtd#', #iRollup#;
	</cfquery>
	<cfreturn tmpFetch12MonthPrivateCensusTrend>
</cffunction>

<cffunction access="public" name="FetchHighValOfCensusTrend" displayname="FetchHighValOfCensusTrend" returntype="numeric"
			description="Searches the 12 Month Private Census Trend query for the highest private census value.">
<cfargument name="iCensusTrendQuery" type="query" required="true">
	<cfquery name="tmpFetchHighVal" dbtype="query">
		SELECT
			Max(fPrivateCensus) AS Census,
			Max(fPrivateBudget) AS Budget
		FROM
			iCensusTrendQuery;
	</cfquery>
	<cfif tmpFetchHighVal["Census"][1] gt tmpFetchHighVal["Budget"][1]>
		<cfreturn tmpFetchHighVal["Census"][1]>
	<cfelse>
		<cfreturn tmpFetchHighVal["Budget"][1]>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchLowValOfCensusTrend" displayname="FetchLowValOfCensusTrend" returntype="numeric"
			description="Searches the 12 Month Private Census Trend query for the lowest private census value.">
<cfargument name="iCensusTrendQuery" type="query" required="true">
	<cfquery name="tmpFetchLowVal" dbtype="query">
		SELECT
			Min(fPrivateCensus) AS Census,
			Min(fPrivateBudget) AS Budget
		FROM
			iCensusTrendQuery;
	</cfquery>
	<cfif tmpFetchLowVal["Census"][1] lt tmpFetchLowVal["Budget"][1]>
		<cfreturn tmpFetchLowVal["Census"][1]>
	<cfelse>
		<cfreturn tmpFetchLowVal["Budget"][1]>
	</cfif>
</cffunction>

<cffunction access="public" name="FetchWDHVarBgt" displayname="FetchWDHVarBgt" returntype="query"
			description="Returns the VariableBudget of the hourly Wellness Director.">
<cfargument name="iRegionIdOriDivisionId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">
	<cfquery name="tmpFetchWDHVarBgt" datasource="#FtaDsName#">
		select x.ihouse_id, x.cname, x.FirstOfMonth, x.LastOfMonth, x.startdate, x.enddate, l.fVariableBudget, l.iday
		from (
				select distinct h.ihouse_id,h.cname,-- a.nPeriod, a.nemployeeid,a.dhiredate, a.dtermdate, b.nPeriod, b.nemployeeid,b.dhiredate,b.dtermdate,
							CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(
								convert(datetime, (substring('201303', 5,6)+'-01-'+substring('201303', 1,4)),101))-1),
								convert(datetime, (substring('201303', 5,6)+'-01-'+substring('201303', 1,4)),101)),101) as FirstOfMonth,
							CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,
								convert(datetime, (substring('201303', 5,6)+'-01-'+substring('201303', 1,4)),101)))),
								DATEADD(mm,1,convert(datetime, (substring('201303', 5,6)+'-01-'+substring('201303', 1,4)),101))),101) as LastOfMonth,
							case when a.dhiredate > b.dtermdate	then b.dtermdate else a.dtermdate end as startdate,
							case when a.dhiredate > b.dtermdate then a.dhiredate else b.dhiredate end as enddate
				from (select distinct nemployeeid, iorglevel3code, nStatus, dhiredate,dtermdate, nPeriod from labortrackingwdsdaily
					where (dhiredate between '03-01-2013' and '03-31-2013' or dtermdate between '03-01-2013' and '03-31-2013') and nperiod = '201303' and iorglevel3code = 25
				) a
				left outer join (select distinct nemployeeid, iorglevel3code, nStatus,dhiredate,dtermdate, nPeriod from labortrackingwdsdaily
					where (dhiredate between '03-01-2013' and '03-31-2013' or dtermdate between '03-01-2013' and '03-31-2013') and nPeriod <> '201303'  and iorglevel3code = 25
				) b on b.iorglevel3code = a.iorglevel3code 
				inner join dbprod01.tips4.dbo.house h on substring(h.cglsubaccount, 7,9) = a.iorglevel3code and substring(h.cglsubaccount, 7,9) = b.iorglevel3code
				where ihouse_id = 122 --and (a.dhiredate > b.dtermdate) or (b.dhiredate > a.dtermdate)
		) x
		inner join labortrackingvariablebudgetdetailshistory l on x.ihouse_id = l.ihouseid
		where l.cperiod = '201303' and l.iday between day(isnull(x.startdate, x.FirstOfMonth)) and day(isnull(x.enddate, x.LastOfMonth)) and l.ihouseid = 122 and l.ilabortrackingcategoryid = 14
	</cfquery>	
	<cfreturn tmpFetchWDHVarBgt>
</cffunction>

<!--- END..........New Code added for FTA-Rollup changes (05-03-2012)..........END --->


<!--- BEGIN........New Code added for FTA-CCLLC changes (04-03-2012)........BEGIN --->
<!--- Fetch all of the ccllc Houses. --->
<cffunction access="public" name="FetchCCLLCHouses" displayname="FetchCCLLCHouses" returntype="Query"
			description="Returns a DataSet containing the CCLLC House Name and House id.">
<cfargument name="iHouseId" type="numeric" required="true">
	<cfquery name="tmpFetchCCLLCHouses" datasource="#FtaDsName#">
		select 'CCLLC - ' + cName as cName
			   ,iHouse_Id as GetHousesId
			   ,cGLsubaccount 
		from fta.dbo.CCLLCHouse h
		inner join dbprod03.TimeCard.dbo.tbl_OrgLevels o on o.i_OrgLevel3Code = h.iOrgLevel3Code
		where h.iHouse_ID = #iHouseId#
	</cfquery>
	<cfreturn tmpFetchCCLLCHouses>
		
</cffunction>

<cffunction access="public" name="FetchCCLLCSalariedInfo" displayname="FetchCCLLCSalariedInfo" returntype="Query"
			description="Returns the infor for Salaried CCLLC employee.">
<cfargument name="iHouseId" type="numeric" required="true">
	<cfquery name="tmpFetchCCLLCSalariedInfo" datasource="#FtaDsName#">
		select [cEmployeeID]
			  ,[cJobTitle]
			  ,s.[iOrgLevel3Code]
			  ,[iWorkWeekHours]
			  ,[fAllocationPercentage]
			  ,[fWorkWeekAllocation]
			  ,[cStatus]
			  ,[dDateCreated]
			  ,[cPeriod]
			  ,[dHireDate]
			  ,[dTermDate]
			  ,h.ihouse_id      
		from labortrackingSalariedEmployeeInfo s
		inner join fta.dbo.CCLLCHouse h on s.iOrgLevel3Code = h.iOrgLevel3Code
        where cStatus = 'A' and h.iHouse_ID = #iHouseId#
	</cfquery>
	<cfreturn tmpFetchCCLLCSalariedInfo>
		
</cffunction>

<cffunction access="public" name="FetchSundaysOfMonth" displayname="FetchSundaysOfMonth" returntype="query"
			description="Returns all the sundays of the current month.">
<cfargument name="currentDay" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">

	<cfquery name="tmpFetchSundaysOfMonth" datasource="#FtaDsName#">
		select datename(dw, convert(datetime, (substring('#iPeriod#', 5,6)+'-'+'#currentDay#'+'-'+substring('#iPeriod#', 1,4)),101)) as name
	</cfquery>
	
	<cfreturn tmpFetchSundaysOfMonth>
</cffunction>

<!--- END........New Code added for FTA-CCLLC changes (04-03-2012)........END --->

<!--- BEGIN........New Code added for the FTA-WDS changes (01-24-2012)........BEGIN --->
<cffunction access="public" name="FetchLaborTrackingWDSDaily" displayname="FetchLaborTrackingWDSDaily" returntype="query"
			description="Returns the Actual and the Allocation Percentage, VariableBudget of the salaried Wellness Director.">
<cfargument name="iRegionIdOrHouseId" type="Numeric" required="true">
<cfargument name="currentDate" type="Date" required="true">
<cfargument name="iPeriod" type="String" required="True">
<cfargument name="iRollup" type="numeric" required="True">
	<cfquery name="tmpFetchLaborTrackingWDS" datasource="#FtaDsName#">
		SELECT top 1
				/*--new columns added based on the two WDS's in one house.--*/
			case when w.nStatus = 'L' then 0 else
				case when d.cnt > 1 then isnull(d.fWorkWeekAllocation, 0.0) else isnull(w.fWorkWeekAllocation, 0.0) end 
			end fWorkWeekAllocation, 
			case when w.nStatus = 'L' then 0 else
				case when d.cnt > 1 then isnull(d.fAllocationPercentage, 0.0) else isnull(convert(decimal(10,2), (w.fAllocationPercentage * 100)), 0.0) end
			end percentage, 
			isnull(Coalesce(t.fOccupancy, 0.0), 0.0) AS fOccupancy, 
			CASE WHEN convert(varchar(10), #iPeriod#) >= '201301' THEN 40 
			ELSE isnull((CASE WHEN o.i_OrgLevel2Code in (26,67) AND o.i_OrgLevel3Code = 141 THEN 24
						  WHEN o.i_OrgLevel2Code in (26,67) AND o.i_OrgLevel3Code not in (176,189,193,776,789,793) THEN 40
						  WHEN t.fOccupancy < 8 THEN 0.0 
						  WHEN t.fOccupancy >=8 and t.fOccupancy <=15 THEN 8
						  WHEN t.fOccupancy >=16 and t.fOccupancy <=19 THEN 16
						  WHEN t.fOccupancy >=20 and t.fOccupancy <=23 THEN 20
						  WHEN t.fOccupancy >=24 and t.fOccupancy <=29 THEN 24
						  WHEN t.fOccupancy >=30 and t.fOccupancy <=35 THEN 32
						  WHEN t.fOccupancy >=36 THEN 40
						ELSE 0.0 END), 
					0.0) 
				END AS VarBdgt,
			h.iHouse_ID,
			w.dDateCreated, 
			w.nStatus, dHireDate, dTermDate,
			CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(
				convert(datetime, (substring('#iPeriod#', 5,6)+'-01-'+substring('#iPeriod#', 1,4)),101))-1),
				convert(datetime, (substring('#iPeriod#', 5,6)+'-01-'+substring('#iPeriod#', 1,4)),101)),101) as StartDate,
			CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,
				convert(datetime, (substring('#iPeriod#', 5,6)+'-01-'+substring('#iPeriod#', 1,4)),101)))),
				DATEADD(mm,1,convert(datetime, (substring('#iPeriod#', 5,6)+'-01-'+substring('#iPeriod#', 1,4)),101))),101) as EndDate
		
			/****** isnull(i_WorkWeekHours, 0) as i_WorkWeekHours,
			isnull(f_AllocationPercentage, 0.0) as f_AllocationPercentage, 
			isnull(f_WorkWeekAllocation, 0.0) as f_WorkWeekAllocation, 
			isnull(convert(decimal(10,2), (f_AllocationPercentage * 100)), 0.0) as percentage,*******/ 
		
		FROM DBPROD01.TIPS4.dbo.House h
		INNER JOIN LaborTrackingWDSDaily w on w.iOrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
					AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL AND /*w.n_Status = 'A' and*/ w.nJobTitle = 'WD Salary'
		LEFT OUTER JOIN vw_HouseOccupancy t ON h.iHouse_ID = t.iHouseId  
		LEFT OUTER JOIN dbprod03.TimeCard.dbo.tbl_OrgLevels o on SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount)) = o.i_OrgLevel3Code
		join fta.dbo.vw_OPSArea ops on ops.iOPSArea_Id = h.iOPSArea_ID
		outer apply (select top 1  iOrgLevel3Code, count(*) as cnt,
								sum(fWorkWeekAllocation) as fWorkWeekAllocation, sum(convert(decimal(10,2), (fAllocationPercentage * 100))) as fAllocationPercentage 
						  from LaborTrackingWDSDaily d 
						  inner join DBPROD01.TIPS4.dbo.House h on d.iOrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
								AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
							join fta.dbo.vw_OPSArea ops on ops.iOPSArea_Id = h.iOPSArea_ID
						  where nStatus = 'A' AND d.dDateCreated = w.dDateCreated
							<cfif iRollup is 3>
								AND h.iHouse_ID = #iRegionIdOrHouseId#  and d.nPeriod=#iPeriod#
							<cfelseif rollup is 2>
								AND h.iOPSArea_ID = #iRegionIdOrHouseId# 
							<cfelseif rollup is 1>
								AND ops.iRegion_ID = #iRegionIdOrHouseId# 
							<cfelse>
								and h.iHouse_ID = #iRegionIdOrHouseId#
							</cfif>
						  group by iOrgLevel3Code, dDateCreated having count(*) > 1 
						  order by dDateCreated desc
						  ) d 		
<!---	/*		/*--added another left join on the subquery to get the percentage and actuals for 2 wds's in one house.--*/
		left outer join (select distinct iOrgLevel3Code, count(*) as cnt,
						sum(fWorkWeekAllocation) as fWorkWeekAllocation, sum(convert(decimal(10,2), (fAllocationPercentage * 100))) as fAllocationPercentage 
						from LaborTrackingWDSDaily where nStatus = 'A' group by iOrgLevel3Code, dDateCreated having count(*) > 1) d 
			on d.iOrgLevel3Code = w.iOrgLevel3Code */--->
		WHERE t.dtOccupancy = CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,
									convert(datetime, (substring('#iPeriod#', 5,6)+'-01-'+substring('#iPeriod#', 1,4)),101)))),
									DATEADD(mm,1,convert(datetime, (substring('#iPeriod#', 5,6)+'-01-'+substring('#iPeriod#', 1,4)),101))),101) and
		<!---WHERE t.dtOccupancy = '#currentDate#' and --->
		<cfif iRollup is 3>
			h.iHouse_ID = #iRegionIdOrHouseId# and w.nPeriod=#iPeriod#
		<cfelseif rollup is 2>
			h.iOPSArea_ID = #iRegionIdOrHouseId# --and w.nPeriod=#iPeriod#
		<cfelseif rollup is 1>
			ops.iRegion_ID = #iRegionIdOrHouseId# 
		<cfelse>
			h.iHouse_ID = #iRegionIdOrHouseId# and w.nPeriod=#iPeriod#
		</cfif>
		ORDER BY w.dDateCreated desc, dHireDate desc, dTermDate desc
	</cfquery>
	
	<cfreturn tmpFetchLaborTrackingWDS>
</cffunction>

<cffunction access="public" name="FetchHousesWithWDHAndWDS" displayname="FetchHousesWithWDHAndWDS" returntype="query"
			description="Returns the houseId that has both Salaried and Hourly Wellness Director.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">

	<cfquery name="tmpFetchHousesWithWDHAndWDS" datasource="#FtaDsName#">
		select distinct h.iHouse_Id, h.cName 
		from DBPROD01.TIPS4.dbo.House h
		INNER JOIN LaborTrackingDetails l ON l.iHouseID = h.iHouse_ID AND h.bIsSandbox = 0 
			AND h.dtrowdeleted IS NULL AND iLaborTrackingCategoryID = 14 and 
			(fRegular+fOvertime+fOther+fAll) <> 0 and cPeriod=#iPeriod#
		INNER JOIN LaborTrackingWDSDaily w ON w.iOrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
			and nPeriod = #iPeriod#
		INNER JOIN dbprod03.TimeCard.dbo.tbl_TimeCardCertification t on t.i_OrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
			and n_JobCode = 'WDH' 
		where w.nStatus = 'A' and t.n_Status = 'A' and h.iHouse_ID = #iHouseId#
	</cfquery>
	
	<cfreturn tmpFetchHousesWithWDHAndWDS>
</cffunction>

<cffunction access="public" name="FetchHousesWithWD" displayname="FetchHousesWithWD" returntype="query"
			description="Returns the houseId that has both Salaried and Hourly Wellness Director.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">

	<cfquery name="tmpFetchHousesWithWD" datasource="#FtaDsName#">
		select distinct h.iHouse_Id, h.cName, w.dHireDate as WDSStartDate, w.dTermDate as WDSEndDate, 
			t.d_HireDate as WDHStartDate, t.d_TermDate as WDHEndDate,
			case when w.dTermDate is not null and w.dTermDate < t.d_HireDate then 1 else 0 end ActiveWDH,
			case when t.d_TermDate is not null and t.d_TermDate < w.dHireDate then 1 else 0 end ActiveWDS 
		from DBPROD01.TIPS4.dbo.House h
		INNER JOIN LaborTrackingDetails l ON l.iHouseID = h.iHouse_ID AND h.bIsSandbox = 0 
			AND h.dtrowdeleted IS NULL AND iLaborTrackingCategoryID = 14 and 
			(fRegular+fOvertime+fOther+fAll) <> 0 and cPeriod=#iPeriod#
		INNER JOIN LaborTrackingWDSDaily w ON w.iOrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
			and nPeriod = #iPeriod# and ((month(w.dHireDate) = substring('#iPeriod#', 5,6) and year(w.dHireDate) = substring('#iPeriod#', 1,4)) 
									or (month(w.dTermDate) = substring('#iPeriod#', 5,6) and year(w.dTermDate) = substring('#iPeriod#', 1,4)))
		INNER JOIN dbprod03.TimeCard.dbo.tbl_TimeCardCertification t on t.i_OrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
			and n_JobCode = 'WDH' and ((month(t.d_HireDate) = substring('#iPeriod#', 5,6) and year(t.d_HireDate) = substring('#iPeriod#', 1,4)) 
									or (month(t.d_TermDate) = substring('#iPeriod#', 5,6) and year(t.d_TermDate) = substring('#iPeriod#', 1,4)))
		where h.iHouse_ID = #iHouseId#
	</cfquery>
	
	<cfreturn tmpFetchHousesWithWD>
</cffunction>

<cffunction access="public" name="FetchHouseWithOpenWDPosition" displayname="FetchHouseWithOpenWDPosition" returntype="query"
			description="Returns the houseId's with the open positions for Wellness Director.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">

	<cfquery name="tmpFetchHouseWithOpenWDPosition" datasource="#FtaDsName#">
		select distinct h.iHouse_Id
		from DBPROD01.TIPS4.dbo.House h
		where SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount)) not in (select distinct iorglevel3code from LaborTrackingWDSDaily)
		and h.iHouse_Id in (select iHouseId from LaborTrackingDetails 
							where iLaborTrackingCategoryID = 14 and (fRegular+fOvertime+fOther+fAll) = 0 and iHouseId = #iHouseId# and cPeriod=#iPeriod#)
	</cfquery>
	
	<cfreturn tmpFetchHouseWithOpenWDPosition>

</cffunction>
<cffunction access="public" name="FetchWDSHouses" displayname="FetchWDSHouses" returntype="query"
			description="Returns the houseId's for the salaried Wellness Director.">
<cfargument name="iHouseId" type="Numeric" required="true">

	<cfquery name="tmpFetchWDSHouses" datasource="#FtaDsName#">
		select iOrgLevel3Code, iHouse_ID from LaborTrackingWDSDaily w 
		LEFT JOIN DBPROD01.TIPS4.dbo.House h ON w.iOrgLevel3Code = SUBSTRING(h.cGLsubaccount, 7, LEN(h.cGLsubaccount))
									AND h.bIsSandbox = 0 AND h.dtrowdeleted IS NULL
		where  h.iHouse_ID = #iHouseId#
	</cfquery>
	
	<cfreturn tmpFetchWDSHouses>
</cffunction>

<cffunction access="public" name="FetchWDHHouses" displayname="FetchWDHHouses" returntype="query"
			description="Returns the houseId's for the HOURLY Wellness Director.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">
	<cfquery name="tmpFetchWDHHouses" datasource="#FtaDsName#">
		select distinct h.iHouse_Id, h.cName		
		from DBPROD01.TIPS4.dbo.House h
		INNER JOIN LaborTrackingDetails l ON l.iHouseID = h.iHouse_ID AND h.bIsSandbox = 0 
			AND h.dtrowdeleted IS NULL AND iLaborTrackingCategoryID = 14 and 
			(fRegular+fOvertime+fOther+fAll) <> 0 and cPeriod=#iPeriod#
		where  h.iHouse_ID = #iHouseId#
	</cfquery>	
	<cfreturn tmpFetchWDHHouses>
</cffunction>

<!--- END..........New Code added for the FTA-WDS changes (01-24-2012)..........END --->

<cffunction access="public" name="Throw" displayname="Throw" returntype="void"
			description="Throws an exception in a TRY-CATCH Block.  Use in CFML Script.">
<cfargument name="Message" type="string" required="true" >
		
	<cfthrow message="#Arguments.Message#" >

</cffunction>

<cffunction access="public" name="FetchLaborTrackingCategories" displayname="FetchLaborTrackingCategories" returntype="Query"
			description="Fetches all of the Visible and Active Labor Tracking Category Records.">
	
	<cfquery name="tmpFetchLaborTrackingCategories" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.LaborTrackingCategory
		WHERE
			bIsVisible = 1 AND
			dtRowDeleted IS NULL
		ORDER BY
			iSortOrder;
	</cfquery>
	
	<cfreturn tmpFetchLaborTrackingCategories>	
		
</cffunction>

<cffunction access="public" name="FetchLaborVariableBudgets" displayname="FetchLaborVariableBudgets" returntype="query"
			description="Returns the Variable Budget Results for the House's Visible Categories.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">

	<cfquery name="tmpFetchVariableBudgets" datasource="#FtaDsName#">
		SELECT
			c.iLaborTrackingCategoryId,
			c.cLaborTrackingCategory,
			REPLACE(t.cDescription, (CHAR(13) + CHAR(10)), '<br />') AS cDescription,
			<!--- t.cDescription,--->
			c.cDisplayName,
			c.iSortOrder,
			Coalesce(b.fVariableBudget, 0.0) AS fVariableBudget
		FROM
			LaborTrackingCategory c
			LEFT JOIN LaborTrackingVariableBudgetDetails b
				ON c.iLaborTrackingCategoryId = b.iLaborTrackingCategoryId AND
				b.iHouseId = #iHouseId# AND	b.cPeriod = '#iPeriod#'
			LEFT JOIN LaborTrackingVariableBudgets vb
				ON b.iVariableBudgetId = vb.iVariableBudgetId
			LEFT JOIN ExpressionTrees t
				ON vb.iExpressionTree = t.iExpressionTreeId
		WHERE
			c.bIsVisible = 1 AND   /*COMMENTED OUT TO BRING THE KITCHEN TRAINING HOURS FOR CCLLC.*/
			c.dtRowDeleted IS NULL AND
			c.cLaborTrackingCategory != 'PTO' and c.cLaborTrackingCategory != 'PPADJ' and cLaborTrackingCategory != 'WD Salary'
		ORDER BY
			c.iSortOrder ASC;		
	</cfquery>
	
	<cfreturn tmpFetchVariableBudgets>

</cffunction>

<cffunction access="public" name="FetchLaborVariableBudgetsWithActual" displayname="FetchLaborVariableBudgetsWithActual" returntype="query"
			description="Returns the Variable Budget Results for the House's Visible Categories.">
<cfargument name="iVariableBudgetsQuery" type="Query" required="true">
<cfargument name="iLaborActualsQuery" type="Query" required="True">

	<cfquery name="tmpFetchVariableBudgetsWithActuals" dbtype="Query">
		SELECT
			iVariableBudgetsQuery.*,
			iLaborActualsQuery.fRegular,
			iLaborActualsQuery.fOverTime,
			iLaborActualsQuery.fOther,
			iLaborActualsQuery.fAll
		FROM
			iVariableBudgetsQuery, iLaborActualsQuery
		WHERE
			iVariableBudgetsQuery.iLaborTrackingCategoryId = iLaborActualsQuery.iLaborTrackingCategoryId
		ORDER BY
			iVariableBudgetsQuery.iSortOrder ASC;
	</cfquery>
	
	<cfreturn tmpFetchVariableBudgetsWithActuals>

</cffunction>

<cffunction access="public" name="FetchLaborHours" displayname="FetchLaborHours" returntype="Query"
			description="Returns the Labor data for the specified period in a DataSet.">
<cfargument name="iHouseId" type="Numeric" required="true">
<cfargument name="iPeriod" type="String" required="True">
	
	<cfquery name="tmpFetchLaborHours" datasource="#FtaDsName#">         
		SELECT
			lbrDtls.*,
		  (case when (lbrDtls.iSortOrder <= 3) then lbrDtls.iSortOrder
			  when   (clabortrackingcategory  =  'Kitchen')then lbrDtls.iSortOrder 
			   when  (clabortrackingcategory  = 'CRM') then  5
			  when   (lbrDtls.iSortOrder >= 5) then  lbrDtls.iSortOrder +1 end)  as SortOrder
			,Coalesce(bgtDtls.fVariableBudget, 0.0) AS fVariableBudget
		FROM
			dbo.LaborTrackingDetails lbrDtls
			LEFT JOIN dbo.LaborTrackingVariableBudgetDetailsHistory_1 bgtDtls
				ON lbrDtls.iHouseId = bgtDtls.iHouseId AND
				lbrDtls.iLaborTrackingCategoryId = bgtDtls.iLaborTrackingCategoryId AND
				lbrDtls.cPeriod = bgtDtls.cPeriod AND
				lbrDtls.iDay = bgtDtls.iDay 
		WHERE
			lbrDtls.cPeriod = '#iPeriod#' AND
			lbrDtls.iHouseId = #iHouseId#
		ORDER BY
			lbrDtls.iDay,
			<!---  lbrDtls.iSortOrder, --->
			SortOrder  ,
			lbrDtls.iLaborTrackingCategoryId;
	</cfquery>
	
	<cfreturn tmpFetchLaborHours>
	
</cffunction>

<cffunction access="public" name="FetchLaborHoursForDay" displayname="FetchLaborHoursForDay" returntype="Query"
			description="Returns the Labor data for the specified Day in the period.">
<cfargument name="iLaborHoursQuery" type="Query" required="true">
<cfargument name="iDay" type="Numeric" required="true">
	
	<cfquery name="tmpFetchLaborHoursForDay" dbtype="Query">
		SELECT
			*
		FROM
			iLaborHoursQuery
		WHERE
			iDay = #iDay#
		ORDER BY
			iSortOrder, iLaborTrackingCategoryId;
	</cfquery>
	
	<cfreturn tmpFetchLaborHoursForDay>
	
</cffunction>

<cffunction access="public" name="FetchLaborHoursForMTD" displayname="FetchLaborHoursForMTD" returntype="Query">
<cfargument name="iLaborHoursQuery" type="Query" required="true">

	<cfquery name="tmpFetchLaborHoursForMTD" dbtype="Query">
		SELECT
			iLaborTrackingCategoryId,
			cLaborTrackingCategory,
			cDisplayName,
			iSortOrder,
			bIsTraining,
			bIsVisible,
			SUM(fRegular) AS fRegular,
			SUM(fOvertime) AS fOvertime,
			SUM(fOther) AS fOther,
			SUM(fAll) AS fAll,
			SUM(fBudget) AS fBudget,
			SUM(fVariableBudget) AS fVariableBudget
		FROM
			iLaborHoursQuery
		GROUP BY
			iLaborTrackingCategoryId,
			cLaborTrackingCategory,
			cDisplayName,
			iSortOrder,
			bIsTraining,
			bIsVisible
		ORDER BY
			iSortOrder;
	</cfquery>
	
	<cfreturn tmpFetchLaborHoursForMTD>
	
</cffunction>

<cffunction access="public" name="getTrainingHoursForDay" displayname="getTrainingHoursForDay" returnType="Numeric"
			description="Returns the available Training Hours for the specified day.">
<cfargument name="iCurrentDayLaborHoursQuery" type="Query" required="true">
	<!--- Set the Category Ids for the Training Categories. --->
	<cfset trainingId = 10>
	<cfset residentCareTrainingId = 13>
	<cfset kitchenTrainingId = 12>
	<!--- Fetch the Training Budget data. --->
	<cfquery name="tmpKitchenTrainingQuery" dbtype="Query">
		SELECT 
			fBudget
		FROM 
			iCurrentDayLaborHoursQuery
		WHERE
			iLaborTrackingCategoryId = #kitchenTrainingId#;
	</cfquery>
	<cfquery name="tmpResidentCareTrainingQuery" dbtype="Query">
		SELECT 
			fBudget
		FROM 
			iCurrentDayLaborHoursQuery
		WHERE
			iLaborTrackingCategoryId = #residentCareTrainingId#;
	</cfquery>
	<cfquery name="tmpTrainingQuery" dbtype="Query">
		SELECT 
			fBudget
		FROM 
			iCurrentDayLaborHoursQuery
		WHERE
			iLaborTrackingCategoryId = #trainingId#;
	</cfquery>	
	
	<cfscript>
		try
		{
			// Instantiate the Percentage Constants.
			residentCarePct = 0.86;
			kitchenPct = 0.14;
			// Set the budget data.
			kitchenTrainingBudget = tmpKitchenTrainingQuery["fBudget"];
			residentCareTrainingBudget = tmpResidentCareTrainingQuery["fBudget"];
			trainingBudget = tmpTrainingQuery["fBudget"];
			// Set the availabe Resident Care Hours from the Budget Dollars.
			residentCareHours = ((trainingBudget * residentCarePct) / residentCareTrainingBudget);
			// Set the available Kitchen Hours from the Budget Dollars.
			kitchenHours = ((trainingBudget * kitchenPct) / kitchenTrainingBudget);
			
			// Set the total available training hours for the current day.
			availableTrainingHours = (residentCareHours + kitchenHours);
	
			// Return the available Training Hours per Day.
			return (availableTrainingHours);
		}
		catch (Any exc)
		{
			return (0);
		}
	</cfscript>
	
</cffunction>

<cffunction access="public" name="LaborNumberFormat" displayname="FtaNumberFormat" returntype="String"
			description="Returns the number formatted using the FTA specified Formatting (0 = -, commas, etc...)">
<cfargument name="iValue" type="any" required="true">
<cfargument name="iDecimalFormat" type="String" required="true">

	<cfscript>
		if (isNumeric(iValue))
		{
	 		if (iValue eq 0)
			{
				return ("-");
			}
			else 
			{
				if (iDecimalFormat is not "")
				{
					return (numberformat(iValue, "()," & iDecimalFormat));
				}
				else
				{
					return (numberformat(iValue, "(),0.0"));
				}			
			}
		}
		else
		{
			return ("-");
		}
	</cfscript>
	
</cffunction>

<cffunction access="public" name="FetchDashboardHouseInfo" displayname="FetchDashboardHouseInfo" returntype="query"
			description="Fetches the specified House's general information.">
<cfargument name="iHouseId" type="numeric" required="true">

	<cfquery name="tempFetchDashboardHouseInfo" datasource="#FtaDsName#">
		SELECT TOP 1
			*
		FROM
			dbo.DashboardHouseInfo
		WHERE
			iHouseId = #iHouseId#;
	</cfquery>
	
	<cfreturn tempFetchDashboardHouseInfo>
</cffunction>

<cffunction access="public" name="qryDashboardHouseInfo" displayname="qryDashboardHouseInfo" returntype="query"
			description="Fetches Division, Region, House ID's and general information.">
 

	<cfquery name="qryFetchDashboardHouseInfo" datasource="#FtaDsName#">
		SELECT 	*
		FROM
			dbo.DashboardHouseInfo
		Order by   iRegionID, iHouseid
	 
	</cfquery>
	
	<cfreturn qryFetchDashboardHouseInfo>
</cffunction>

<cffunction access="public" name="qryDashboardRegionA" displayname="qryDashboardRegionA" returntype="query"
			description="Fetches  Region ID's.">
 <cfargument name="iDivisionId" type="numeric" required="true">

	<cfquery name="qryFetchDashboardRegionId" datasource="#FtaDsName#">
		SELECT distinct	(dhi.iRegionID) , cregionname 
		FROM
			 dbo.DashboardHouseInfo dhi
		WHERE
		dhi.iDivisionId = #iDivisionId#
		Order by    dhi.iregionid 
	 
	</cfquery>
	
	<cfreturn qryFetchDashboardRegionId>
</cffunction>

<cffunction access="public" name="qryDashboardRegion" displayname="qryDashboardRegion" returntype="query"
			description="Fetches  Region ID's.">
 

	<cfquery name="qryFetchDashboardRegionId" datasource="#FtaDsName#">
		SELECT distinct	(dhi.iRegionID) , cregionname 
		FROM
			 dbo.DashboardHouseInfo dhi
		Order by    dhi.iregionid 
	 
	</cfquery>
	
	<cfreturn qryFetchDashboardRegionId>
</cffunction>

<cffunction access="public" name="FetchDashboardHouseOccupancy" displayname="FetchDashboardHouseOccupancy" returntype="Query"
			description="Fetches the Occupancy Info for specified House and Period.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iPeriod" type="String" required="true">	
	<cfquery name="tempFetchDashboardHouseOccupancy" datasource="#FtaDsName#">
		SELECT TOP 1
			*
		FROM
			dbo.DashboardOccupancyInfo
		WHERE
			iHouseId = #iHouseId# AND
			cPeriod = '#iPeriod#'
		ORDER BY
			dtOccupancy DESC;
	</cfquery>
	
	<cfreturn tempFetchDashboardHouseOccupancy>
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntries" displayname="FetchHouseVisitEntries" returntype="query"
			description="Returns a Query Object with all of the Entry records that belong to the specified House.">
<cfargument name="iHouseId" type="numeric" required="true">
	
	<cfquery name="tmpFetchEntries" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitEntries
		WHERE
			iHouseId = #iHouseId# AND
			dtRowDeleted IS NULL
		ORDER BY
			dtHouseVisit DESC;
	</cfquery>
	
	<cfreturn tmpFetchEntries>
	
</cffunction>



<cffunction access="public" name="FetchHouseVisitReportRoleParameter" displayname="FetchHouseVisitReportRoleParameter" returntype="string"
			description="Returns the Role parameter's value required by the House Visit Report.">
<cfargument name="iRoleId" required="true" type="numeric">
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntriesInRange" displayname="FetchHouseVisitEntriesInRange" returntype="query"
			description="Returns a Query Object with all of the Entry records that belong to the specified House with-in the date range.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iFrom" type="date" required="true">
<cfargument name="iTo" type="date" required="true">

	<cfset fmtFromDate = DateFormat(iFrom, "mm/dd/yyyy") & " " & TimeFormat(iFrom, "hh:mm:ss tt")>
	<cfset fmtToDate = DateFormat(iTo, "mm/dd/yyyy") & " " & TimeFormat(iTo, "hh:mm:ss tt")>
	
	<cfquery name="tmpFetchEntries" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitEntries
		WHERE
			iHouseId = #iHouseId# AND
			dtRowDeleted IS NULL AND
			dtHouseVisit BETWEEN '#fmtFromDate#' AND '#fmtToDate#'
		ORDER BY
			dtHouseVisit DESC;
	</cfquery>
	
	<cfreturn tmpFetchEntries>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntriesInRangeByRole" displayname="FetchHouseVisitEntriesInRangeByRole" returntype="query"
			description="Returns a Query Object with all of the Entry records that belong to the specified House with-in the date range and that were created with the specified Role.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iFrom" type="date" required="true">
<cfargument name="iTo" type="date" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfset fmtFromDate = DateFormat(iFrom, "mm/dd/yyyy") & " " & TimeFormat(iFrom, "hh:mm:ss tt")>
	<cfset fmtToDate = DateFormat(iTo, "mm/dd/yyyy") & " " & TimeFormat(iTo, "hh:mm:ss tt")>
	
	<cfquery name="tmpFetchEntries" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitEntries
		WHERE
			iHouseId = #iHouseId# AND
			dtRowDeleted IS NULL AND
			dtHouseVisit BETWEEN '#fmtFromDate#' AND '#fmtToDate#' AND
			iRole = #iRoleId#
		ORDER BY
			dtHouseVisit DESC;
	</cfquery>
	
	<cfreturn tmpFetchEntries>
	
</cffunction>
<cffunction access="public" name="FetchNewestHouseVisitEntryII" displayname="FetchNewestHouseVisitEntryII" returntype="query"
			description="Returns the most recent House Visit Entry Record.  WARNING: This Method makes a trip to the database.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchEntry" datasource="#FtaDsName#">
		SELECT TOP 1
			*
		FROM
			dbo.HouseVisitEntriesII
		WHERE
			iHouseId = #iHouseId# AND
			iRole = #iRoleId# AND
			dtRowDeleted IS NULL
		ORDER BY
			dtHouseVisit DESC;
	</cfquery>
	
	<cfreturn tmpFetchEntry>
	
</cffunction>

<cffunction access="public" name="FetchNewestHouseVisitEntry" displayname="FetchNewestHouseVisitEntry" returntype="query"
			description="Returns the most recent House Visit Entry Record.  WARNING: This Method makes a trip to the database.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchEntry" datasource="#FtaDsName#">
		SELECT TOP 1
			*
		FROM
			dbo.HouseVisitEntries
		WHERE
			iHouseId = #iHouseId# AND
			iRole = #iRoleId# AND
			dtRowDeleted IS NULL
		ORDER BY
			dtHouseVisit DESC;
	</cfquery>
	
	<cfreturn tmpFetchEntry>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntriesByUser" displayname="FetchHouseVisitEntriesByUser" returntype="query"
			description="Returns a Query Object with all of the Entry records that belong to the specified House and User.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iUserName" type="string" required="true">

	<cfquery name="tmpFetchEntriesByUser" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitEntries
		WHERE
			iHouseId = #iHouseId# AND
			cUserName = '#iUserName#' AND
			dtRowDeleted IS NULL
		ORDER BY
			dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchEntriesByUser>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntriesByRole" displayname="FetchHouseVisitEntriesByRole" returntype="query"
			description="Returns a Query Object with all of the Entry records that belong to the specified House and Role.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchEntriesByRole" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitEntries
		WHERE
			iHouseId = #iHouseId# AND
			iRole = #iRoleId# AND
			dtRowDeleted IS NULL
		ORDER BY
			dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchEntriesByRole>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswersII" displayname="FetchHouseVisitAnswersII" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House per Question.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="EntryGroupId" type="numeric" required="true">
<cfargument name="QuestionId" type="numeric" required="true">
	
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		SELECT
			a.iEntryAnswerId, 
			a.iQuestionId, 
			REPLACE(a.cEntryAnswer, '<br />', CHAR(10)) AS cEntryAnswer, 
			e.cUserName, e.dtCreated,
			e.iRole,
			r.cRoleName,
			a.dtCreated, 
			a.cCreatedBy, 
			a.dtRowDeleted, 
			a.cRowDeletedBy
		FROM
			dbo.HouseVisitEntriesII e
			JOIN dbo.HouseVisitAnswersII a
				ON e.iEntryId = a.iHouseVisitEntry 
				AND a.iEntryGroupId = #EntryGroupId#
				AND a.iQuestionId = #QuestionId#				
				AND a.dtRowDeleted IS NULL
				join dbo.HouseVisitRoles r
						ON e.iRole = r.iroleid
		WHERE
			e.iHouseId = #iHouseId# AND
			e.dtRowDeleted IS NULL
		ORDER BY
			e.dtCreated DESC;
	</cfquery>
	
	<cfreturn tmpFetchAnswers>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswersDetail" displayname="FetchHouseVisitAnswersDetail" returntype="query"
			description="Returns a Query Object with all of the Detail records that belong to the specified House per Question.">
 
<cfargument name="EntryGroupId" type="numeric" required="true">
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		SELECT
			e.cUserName, 
			e.cUserDisplayName,
			e.dtCreated,
			e.iRole,
			r.cRoleName,
			e.dtHouseVisit 
		FROM
			dbo.HouseVisitEntriesII e
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
		WHERE
		e.iEntryId = #EntryGroupId#   AND
			e.dtRowDeleted IS NULL
		ORDER BY
			e.dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchAnswers>
</cffunction>
<cffunction access="public" name="FetchHouseVisitAnswersIIAquery" displayname="FetchHouseVisitAnswersIIAquery" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House per Question.">
<cfargument name="iEntryId" type="numeric" required="true">
<cfargument name="EntryGroupId" type="numeric" required="true">
<cfargument name="QuestionId" type="numeric" required="true">
<cfargument name="qryAnswers" type="query" required="true">

	<cfquery name="tmpFetchAnswers"  dbtype="Query">
		 SELECT 
				 dtCreated,				
				 cRoleName,
				 cUserDisplayName,
				 iQuestionId,
				 cEntryAnswer,
				 cQuestion,
				 iEntryAnswerId,
				 iEntryId,
				 ientryquestionsub,
				 iEntryGroupId,  
	  			iQuestionId   
 
			FROM
 					qryAnswers
			WHERE
				 iEntryId = #iEntryId#  and
				iEntryGroupId = #EntryGroupId# and
	  			iQuestionId  =  #QuestionId#  
			ORDER BY 
				 ientryquestionsub,   iQuestionId 
 
	</cfquery>
	<cfreturn tmpFetchAnswers>
</cffunction>
<cffunction access="public" name="FetchHouseVisitAnswersIIReg" displayname="FetchHouseVisitAnswersIIReg" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House per Question.">
 
<cfargument name="iRegionId" type="numeric" required="true">
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		 SELECT 
				e.dtCreated,				
				r.cRoleName,
				e.cUserDisplayName,
				a.iQuestionId,
				a.cEntryAnswer,
				q.cQuestion,
				a.iEntryAnswerId,
				e.iEntryId,
				a.ientryquestionsub,
				dbh.iDivisionId , 
				dbh.iHouseId,
				dbh.cHouseName,
				dbh.cRegionName, 
				dbh.iRegionId 
 
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
 
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
				join fta.dbo.DashboardHouseInfo dbh ON e.ihouseid = dbh.iHouseId
					and   dbh.iRegionId = #iRegionId#					
			WHERE
 
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL    
				order by 
				a.ientryquestionsub,  a.iQuestionId 
 
	</cfquery>
	<cfreturn tmpFetchAnswers>
</cffunction>
<cffunction access="public" name="FetchHouseVisitAnswersIIALL4" displayname="FetchHouseVisitAnswersIIALL4" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House per Question.">
 
<cfargument name="idivisionid" type="numeric" required="true">
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		 SELECT 
				e.dtCreated,				
				r.cRoleName,
				e.cUserDisplayName,
				a.iQuestionId,
				a.cEntryAnswer,
				q.cQuestion,
				a.iEntryAnswerId,
				e.iEntryId,
				a.ientryquestionsub,
				dbh.iDivisionId , 
				dbh.iHouseId,
				dbh.cHouseName,
				dbh.cRegionName, 
				dbh.iRegionId, 
	 			a.iEntryGroupId,  
	  			a.iQuestionId 			
 
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
 
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
				join fta.dbo.DashboardHouseInfo dbh ON e.ihouseid = dbh.iHouseId
					and   dbh.iDivisionId = #idivisionid#					
			WHERE
 
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL    
				order by 
				a.ientryquestionsub,  a.iQuestionId 
 
	</cfquery>
	<cfreturn tmpFetchAnswers>
</cffunction>
<cffunction access="public" name="FetchHouseVisitAnswersIIA" displayname="FetchHouseVisitAnswersIIA" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House per Question.">
<cfargument name="iEntryId" type="numeric" required="true">
<cfargument name="EntryGroupId" type="numeric" required="true">
<cfargument name="QuestionId" type="numeric" required="true">

	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		 SELECT 
				e.dtCreated,				
				r.cRoleName,
				e.cUserDisplayName,
				a.iQuestionId,
				a.cEntryAnswer,
				q.cQuestion,
				a.iEntryAnswerId,
				e.iEntryId,
				a.ientryquestionsub  
 
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
						AND a.iEntryGroupId = #EntryGroupId#
						AND a.iQuestionId = #QuestionId#
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
			WHERE
				e.iEntryId = #iEntryId# AND
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL    
				order by 
				a.ientryquestionsub,  a.iQuestionId 
 
	</cfquery>
	<cfreturn tmpFetchAnswers>
</cffunction>
<cffunction access="public" name="FetchHouseVisitIIQueryAnswers" displayname="FetchHouseVisitIIQueryAnswers" returntype="query"
			description="Returns a Query Object with all of the Answer records ">
<cfargument name="idivisionid" type="numeric" required="true">
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		 SELECT 
				a.iEntryGroupId,
		  		e.iEntryId,
				e.cUserName,
				e.cUserDisplayName,
				e.iRole,
				r.cRoleName,
				e.dtCreated,
				g.iGroupid,
				g.cTextHeader,
				q.cQuestion,
				g.cGroupName,
				g.iSortOrder AS groupsortorder,
				q.isortorder AS questionsortorder,
				a.iEntryAnswerId, 
				a.iHouseVisitEntry, 
				a.iQuestionId, 
				REPLACE(a.cEntryAnswer, '<br/>', CHAR(32)) AS cEntryAnswer, 
				a.cCreatedBy, 
				a.dtRowDeleted, 
				a.cRowDeletedBy,
				dbh.iDivisionId , 
				dbh.iHouseId,
				dbh.cHouseName,
				dbh.cRegionName, 
				dbh.iRegionId 
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
 
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
									join fta.dbo.DashboardHouseInfo dbh ON e.ihouseid = dbh.iHouseId
					and   dbh.iDivisionId = #idivisionid#	
			WHERE
 
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL and 
				a.cEntryAnswer is not null  
			ORDER BY
				g.iSortOrder asc,
				q.isortorder ASC, 
				a.iEntryAnswerId,
				e.iEntryId ASC
	</cfquery>
	<cfreturn tmpFetchAnswers>
</cffunction>

<cffunction access="public" name="FetchHouseVisitIIEntryAnswers" displayname="FetchHouseVisitIIEntryAnswers" returntype="query"
			description="Returns a Query Object with all of the Answer records for an Entry">
<cfargument name="iEntryId" type="numeric" required="true">
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		 SELECT 
				a.iEntryGroupId,
		  		e.iEntryId,
				e.cUserName,
				e.cUserDisplayName,
				e.iRole,
				r.cRoleName,
				e.dtCreated,
				g.iGroupid,
				g.cTextHeader,
				q.cQuestion,
				g.cGroupName,
				g.iSortOrder AS groupsortorder,
				q.isortorder AS questionsortorder,
				a.iEntryAnswerId, 
				a.iHouseVisitEntry, 
				a.iQuestionId, 
				REPLACE(a.cEntryAnswer, '<br/>', CHAR(32)) AS cEntryAnswer, 
				a.cCreatedBy, 
				a.dtRowDeleted, 
				a.cRowDeletedBy,
				dbh.iDivisionId , 
				dbh.iHouseId,
				dbh.cHouseName,
				dbh.cRegionName, 
				dbh.iRegionId,
				a.iEntryQuestionSub 
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
						
 
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
									join fta.dbo.DashboardHouseInfo dbh ON e.ihouseid = dbh.iHouseId
					 	
			WHERE
  				e.iEntryId = #iEntryId# and
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL and 
				a.cEntryAnswer is not null  
			ORDER BY
				g.iSortOrder asc,
				q.isortorder ASC, 
				a.iEntryAnswerId,
				e.iEntryId ASC
	</cfquery>
	<cfreturn tmpFetchAnswers>
</cffunction>


<cffunction name="FetchHouseVisitIIQAnswers_old2" displayname="FetchHouseVisitIIQAnswers_old2" returntype="query"
			description="Returns a Query Object with a specific Answer records ">
<cfargument name="iEntryId" type="numeric" required="true">
<cfargument name="EntryGroupId" type="numeric" required="true">
<cfargument name="QuestionId" type="numeric" required="true">
	<cfquery name="qryquestionanswer" dbtype="Query">
		SELECT 
				iEntryGroupId,
		 		iEntryId,
				cUserName,
				cUserDisplayName,
				iRole,
				cRoleName,
				dtCreated,
				iGroupid,
				cTextHeader,
				cQuestion,
				cGroupName,
				iEntryAnswerId, 
				iHouseVisitEntry, 
				iQuestionId, 
				cEntryAnswer, 
				cCreatedBy, 
				dtRowDeleted, 
				cRowDeletedBy
		FROM 
			tmpFetchAnswers
		WHERE
			iQuestionId = #QuestionId# and
			iEntryGroupId = #EntryGroupId# and
			iEntryId = #iEntryId#
	</cfquery>
	<cfreturn qryquestionanswer>
</cffunction>

<cffunction name="FetchHouseVisitIIQAnswers" displayname="FetchHouseVisitIIQAnswers" returntype="query"
			description="Returns a Query Object with a specific Answer records ">
<cfargument name="iEntryId" type="numeric" required="true">
<cfargument name="EntryGroupId" type="numeric" required="true">
<cfargument name="QuestionId" type="numeric" required="true">
<cfargument name="qryAnswers" type="query" required="true">
	<cfquery name="qryquestionanswer" dbtype="Query">
		SELECT 
				iEntryGroupId,
		 		iEntryId,
				cUserName,
				cUserDisplayName,
				iRole,
				cRoleName,
				dtCreated,
				iGroupid,
				cTextHeader,
				cQuestion,
				cGroupName,
				iEntryAnswerId, 
				iHouseVisitEntry, 
				iQuestionId, 
				cEntryAnswer, 
				cCreatedBy, 
				dtRowDeleted, 
				cRowDeletedBy
		FROM 
			qryAnswers
		WHERE
			iQuestionId = #QuestionId# and
			iEntryGroupId = #EntryGroupId# and
			iEntryId = #iEntryId#
	</cfquery>
	<cfreturn qryquestionanswer>
</cffunction>

<cffunction name="FetchHouseVisitIIQA" displayname="FetchHouseVisitIIQA" returntype="query"
			description="Returns a Query Object with a specific Answer records ">
<cfargument name="iEntryId" type="numeric" required="true">
<cfargument name="EntryGroupId" type="numeric" required="true">
<cfargument name="QuestionId" type="numeric" required="true">
<cfargument name="SubQuestionId" type="numeric" required="true">
<cfargument name="qryAnswers" type="query" required="true">
	<cfquery name="qryquestionanswer" dbtype="Query">
		SELECT 
				iEntryGroupId,
		 		iEntryId,
				cUserName,
				cUserDisplayName,
				iRole,
				cRoleName,
				dtCreated,
				iGroupid,
				cTextHeader,
				cQuestion,
				cGroupName,
				iEntryAnswerId, 
				iHouseVisitEntry, 
				iQuestionId, 
				cEntryAnswer, 
				cCreatedBy, 
				dtRowDeleted, 
				cRowDeletedBy
		FROM 
			qryAnswers
		WHERE
			iQuestionId = #QuestionId# and
			iEntryGroupId = #EntryGroupId# and
			iEntryId = #iEntryId# and
			iEntryQuestionSub = #SubQuestionId#			
	</cfquery>
	<cfreturn qryquestionanswer>
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswers" displayname="FetchHouseVisitAnswers" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House.">
<cfargument name="iHouseId" type="numeric" required="true">
	
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		SELECT
			a.iEntryAnswerId, 
			a.iEntry, 
			a.iQuestion, 
			REPLACE(a.cEntryAnswer, '<br />', CHAR(10)) AS cEntryAnswer, 
			a.dtCreated, 
			a.cCreatedBy, 
			a.dtRowDeleted, 
			a.cRowDeletedBy
		FROM
			dbo.HouseVisitEntries e
			JOIN dbo.HouseVisitAnswers a
				ON e.iEntryId = a.iEntry AND a.dtRowDeleted IS NULL
		WHERE
			e.iHouseId = #iHouseId# AND
			e.dtRowDeleted IS NULL
		ORDER BY
			e.dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchAnswers>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswersRaw" displayname="FetchHouseVisitAnswers" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House.">
<cfargument name="iHouseId" type="numeric" required="true">
	
	<cfquery name="tmpFetchAnswers" datasource="#FtaDsName#">
		SELECT
			a.iEntryAnswerId, 
			a.iEntry, 
			a.iQuestion, 
			a.cEntryAnswer,
			a.dtCreated, 
			a.cCreatedBy, 
			a.dtRowDeleted, 
			a.cRowDeletedBy
		FROM
			dbo.HouseVisitEntries e
			JOIN dbo.HouseVisitAnswers a
				ON e.iEntryId = a.iEntry AND a.dtRowDeleted IS NULL
		WHERE
			e.iHouseId = #iHouseId# AND
			e.dtRowDeleted IS NULL
		ORDER BY
			e.dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchAnswers>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswersByUser" displayname="FetchHouseVisitAnswersByUser" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House and User.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iUserName" type="string" required="true">

	<cfquery name="tmpFetchAnswersByUser" datasource="#FtaDsName#">
		SELECT
			a.iEntryAnswerId, 
			a.iEntry, 
			a.iQuestion, 
			REPLACE(a.cEntryAnswer, '<br />', CHAR(10)) AS cEntryAnswer, 
			a.dtCreated, 
			a.cCreatedBy, 
			a.dtRowDeleted, 
			a.cRowDeletedBy
		FROM
			dbo.HouseVisitEntries e
			JOIN dbo.HouseVisitAnswers a
				ON e.iEntryId = a.iEntry AND a.dtRowDeleted IS NULL
		WHERE
			e.iHouseId = #iHouseId# AND
			e.cUserName = '#iUserName#' AND
			e.dtRowDeleted IS NULL
		ORDER BY
			e.dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchAnswersByUser>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswersByRole" displayname="FetchHouseVisitAnswersByRole" returntype="query"
			description="Returns a Query Object with all of the Answer records that belong to the specified House and Role.">
<cfargument name="iHouseId" type="numeric" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchAnswersByRole" datasource="#FtaDsName#">
		SELECT
			a.iEntryAnswerId, 
			a.iEntry, 
			a.iQuestion, 
			REPLACE(a.cEntryAnswer, '<br />', CHAR(10)) AS cEntryAnswer, 
			a.dtCreated, 
			a.cCreatedBy, 
			a.dtRowDeleted, 
			a.cRowDeletedBy
		FROM
			dbo.HouseVisitEntries e
			JOIN dbo.HouseVisitAnswers a
				ON e.iEntryId = a.iEntry AND a.dtRowDeleted IS NULL
		WHERE
			e.iHouseId = #iHouseId# AND
			e.iRole = #iRoleId# AND
			e.dtRowDeleted IS NULL
		ORDER BY
			e.dtCreated ASC;
	</cfquery>
	
	<cfreturn tmpFetchAnswersByRole>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitGroups" displayname="FetchHouseVisitGroups" returntype="query"
			description="Returns a Query object that contains every Question Group that is Active (not deleted).">

	<cfquery name="tmpFetchGroups" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitGroups
		WHERE
			dtRowDeleted IS NULL;
	</cfquery>

	<cfreturn tmpFetchGroups>
</cffunction>

<cffunction access="public" name="FetchHouseVisitGroupsHouseII" displayname="FetchHouseVisitGroupsHouseII" returntype="query"
			description="Returns a Query object that contains House Visit Entries that is Active (not deleted).">
			<cfargument name="houseId" type="string" required="true">
			<cfargument name="rolename" type="string" required="true">	
			<cfargument name="iFrom" type="date" required="true">
			<cfargument name="iTo" type="date" required="true">

			<cfset fmtFromDate = DateFormat(iFrom, "yyyy-mm-dd") & " " & TimeFormat(iFrom, "hh:mm:ss tt")>
			<cfset fmtToDate = DateFormat(iTo, "yyyy-mm-dd") & " " & TimeFormat(iTo, "hh:mm:ss tt")>
			
	<cfquery name="tmpFetchHouseGroupsID" datasource="#FtaDsName#">
		SELECT
			HVE.iEntryId, HVE.cUserDisplayName, HVE.iRole,
			HVE.dtCreated, HVR.cRoleName, HVE.dtHouseVisit
		FROM
			dbo.HouseVisitEntriesII HVE,
			dbo.HouseVisitRoles  HVR
		WHERE
			HVE.iHouseId = #houseId#
			and
			HVE.dtRowDeleted IS NULL
			and
			HVE.iRole = HVR.iRoleID
			and
			HVR.cRoleCode = <cfqueryparam value="#rolename#" cfsqltype="cf_sql_char">
			and
			dtHouseVisit BETWEEN '#fmtFromDate#' AND '#fmtToDate#'		
		ORDER By HVE.dtCreated desc;
	</cfquery>

	<cfreturn tmpFetchHouseGroupsID>
</cffunction>


<cffunction access="public" name="FetchHouseVisitGroupsIIAll" displayname="FetchHouseVisitGroupsIIAll" returntype="query"
			description="Returns a Query object that contains every Question Group that is Active (not deleted).">
 
	<cfquery name="tmpFetchGroupsAllII" datasource="#FtaDsName#">
		SELECT HVR.*, HVQR.*, HVG.*
		
		FROM  dbo.HouseVisitGroupsII HVG,
		 dbo.HouseVisitQuestionRolesII HVQR,
		 dbo.HouseVisitRoles HVR
		
		WHERE   HVR.iRoleId = HVQR.iRole
		and HVG.iGroupid  = HVQR.iGroup  
		and HVG.dtRowDeleted is null
		
		ORDER By HVG.iSortOrder
		;
	</cfquery>

	<cfreturn tmpFetchGroupsAllII>
</cffunction>
<cffunction access="public" name="FetchHouseVisitGroupsIIRpt" displayname="FetchHouseVisitGroupsIIRpt" returntype="query"
			description="Returns a Query object that contains every Question Group that is Active (not deleted).">
 
	<cfquery name="tmpFetchGroupsIIRpt" datasource="#FtaDsName#">
		SELECT   HVG.*
		
		FROM  dbo.HouseVisitGroupsII HVG 
 		WHERE HVG.dtRowDeleted is null
		ORDER By HVG.iSortOrder
		;
	</cfquery>

	<cfreturn tmpFetchGroupsIIRpt>
</cffunction>

<cffunction access="public" name="FetchHouseVisitGroupRoles" displayname="FetchHouseVisitGroupRoles" returntype="query"
			description="Returns the roles for a question group.">
		<cfargument name="iGroupID" type="numeric" required="true">	
	<cfquery name="tmpFetchGroupsIIRole" datasource="#FtaDsName#">				
			SELECT  r.cRoleName
			FROM
			  dbo.HouseVisitRoles r,
			  dbo.HouseVisitQuestionRolesII qr ,
			  dbo.HouseVisitGroupsII g
			WHERE g.iGroupid = qr.IGroup 
				and qr.iRole = r.iRoleId  
				and igroupid = #iGroupID#
				and r.dtrowdeleted is null
		</cfquery>			
	<cfreturn tmpFetchGroupsIIRole>
</cffunction>



<cffunction access="public" name="FetchHouseVisitGroupsII" displayname="FetchHouseVisitGroupsII" returntype="query"
			description="Returns a Query object that contains every Question Group that is Active (not deleted).">
		<cfargument name="rolename" type="string" required="true">
	<cfquery name="tmpFetchGroupsII" datasource="#FtaDsName#">
		SELECT HVR.iRoleId, HVR.cRoleName, HVR.cRoleCode, HVR.bIsSuperUser 
		, HVQR.iRoleGroupID, HVQR.IGroup, HVQR.iRole iRoleId
		, HVG.iGroupid, HVG.cGroupName, HVG.cTextHeader, HVG.IndexMax, HVG.IndexName, HVG.AddRows, HVG.addrowname

		
		FROM  dbo.HouseVisitGroupsII HVG,
		 dbo.HouseVisitQuestionRolesII HVQR,
		 dbo.HouseVisitRoles HVR
		
		WHERE HVR.cRoleName = '#rolename#'
		and HVR.iRoleId = HVQR.iRole
		and HVG.iGroupid  = HVQR.iGroup  
		and HVG.dtRowDeleted is null
		
		ORDER By HVG.iSortOrder
		;
	</cfquery>

	<cfreturn tmpFetchGroupsII>
</cffunction>

<cffunction access="public" name="FetchHouseVisitQuestionsII" displayname="FetchHouseVisitQuestionsII" returntype="query"
			description="Returns a Query object that contains every Question that is Active (not deleted).">
		<cfargument name="iGroupID" type="numeric" required="true">
	<cfquery name="tmpFetchQuestionsII" datasource="#FtaDsName#">
		SELECT
		 IQUESTIONID 
		 ,iGroupID 
       ,iSortOrder
      ,cIncludeDate
      ,cIDName
      ,dtRowDeleted
      ,cColSize
      ,cOnChange
      ,cRowSize
      ,readonly
      ,dropdown
      ,posttitle
      ,defaultvalue		 
			,REPLACE(HVQ.cQuestion, '<br/>', ' ') AS cQuestion
		FROM
			dbo.HouseVisitQuestionsII HVQ
		WHERE
			HVQ.dtRowDeleted IS NULL
		and HVQ.igroupid = #iGroupID#
		Order by iGroupID, iSortOrder	

			;
	</cfquery>

	<cfreturn tmpFetchQuestionsII>
		
</cffunction>
<cffunction access="public" name="FetchHouseVisitIIExtractQuestion" displayname="FetchHouseVisitIIExtractQuestion" returntype="query"
			description="Returns a Query object that contains every Question that is Active (not deleted).">
		<cfargument name="QUESTIONID" type="numeric" required="true">
	<cfquery name="tmpFetchQuestionsII" datasource="#FtaDsName#">
		SELECT
		 IQUESTIONID 
		 ,iGroupID 
       ,iSortOrder
      ,cIncludeDate
      ,cIDName
      ,dtRowDeleted
      ,cColSize
      ,cOnChange
      ,cRowSize
      ,readonly
      ,dropdown
      ,posttitle
      ,defaultvalue		 
			,REPLACE(HVQ.cQuestion, '<br/>', ' ') AS cQuestion
		FROM
			dbo.HouseVisitQuestionsII HVQ
		WHERE
			HVQ.dtRowDeleted IS NULL
		and HVQ.IQUESTIONID = #QUESTIONID#
		Order by iGroupID, iSortOrder	

			;
	</cfquery>

	<cfreturn tmpFetchQuestionsII>
		
</cffunction>
<cffunction access="public" name="FetchHouseVisitQuestions" displayname="FetchHouseVisitQuestions" returntype="query"
			description="Returns a Query object that contains every Question that is Active (not deleted).">
	
	<cfquery name="tmpFetchQuestions" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitQuestions
		WHERE
			dtRowDeleted IS NULL;
	</cfquery>

	<cfreturn tmpFetchQuestions>
		
</cffunction>
<cffunction access="public" name="FetchHouseVisitRolesChg" displayname="FetchHouseVisitRolesChg" returntype="query"
			description="Returns a Query object that contains non corporate Roles that are Active (not deleted).">
	
	<cfquery name="tmpFetchRoles" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitRoles
		WHERE
			dtRowDeleted IS NULL and bIsSUperUSer = 0;
	</cfquery>

	<cfreturn tmpFetchRoles>
		
</cffunction>
<cffunction access="public" name="FetchHouseVisitRoles" displayname="FetchHouseVisitRoles" returntype="query"
			description="Returns a Query object that contains every Role that is Active (not deleted).">
	
	<cfquery name="tmpFetchRoles" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitRoles
		WHERE
			dtRowDeleted IS NULL;
	</cfquery>

	<cfreturn tmpFetchRoles>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitAuthentication" displayname="FetchHouseVisitAuthentication" returntype="query"
			description="Returns a Query object that contains every Authentication Record that is Active (not deleted).">
	
	<cfquery name="tmpFetchAuthentication" datasource="#FtaDsName#">
		SELECT
			a.iAuthenticationId,
			a.iRole,
			a.cUserTitle,
			r.cRoleName,
			r.cRoleCode,
			r.bIsSuperUser
		FROM
			dbo.HouseVisitAuthentication a
			LEFT JOIN dbo.HouseVisitRoles r ON a.iRole = r.iRoleId
		WHERE
			a.dtRowDeleted IS NULL AND 
			r.dtRowDeleted IS NULL;
	</cfquery>

	<cfreturn tmpFetchAuthentication>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitQuestionRoles" displayname="FetchHouseVisitQuestionRoles" returntype="query"
			description="Returns a Query object that contains every Question Role that is Active (not deleted).">
	
	<cfquery name="tmpFetchQuestionRoles" datasource="#FtaDsName#">
		SELECT
			*
		FROM
			dbo.HouseVisitQuestionRoles
		WHERE
			dtRowDeleted IS NULL;
	</cfquery>

	<cfreturn tmpFetchQuestionRoles>
		
</cffunction>

<cffunction access="public" name="FetchAllHouses" displayname="FetchAllHouses" returntype="Query"
			description="Returns a DataSet containing all the houses the user has access to.">
<cfargument name="RDOrestrict" type="String" required="false">
	
	<cfquery name="tmpFetchAllHouses" datasource="#FtaDsName#">
		SELECT
			cName,
			iHouse_ID AS GetHousesId,
			cGLSubAccount
		FROM
			dbo.vw_HouseWithSwan
		<cfif isDefined('RDOrestrict')>
			WHERE
				iOpsArea_ID = '#RDOrestrict#'
		</cfif>
		ORDER BY
			cName;
	</cfquery>
	
	<cfreturn tmpFetchAllHouses>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleII" displayname="FetchHouseVisitRoleII" returntype="query"
			description="Returns the Role Record of the specified Role Id.">
 
	<cfargument name="iRoleId" type="numeric" required="true">
	<cfquery name="tmpFetchRole"  datasource="#FtaDsName#">
		SELECT
			HVR.cRoleName
		FROM
			dbo.HouseVisitRoles  HVR
		WHERE
			HVR.iRoleId = #iRoleId#;
	</cfquery>
	<cfreturn tmpFetchRole>
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleID" displayname="FetchHouseVisitRoleID" returntype="query"
			description="Returns the Role Record of the specified Role Id.">
 
	<cfargument name="RoleName"  type="string" required="true">
	<cfquery name="tmpFetchRoleID"  datasource="#FtaDsName#">
		SELECT
			HVR.iRoleid
		FROM
			dbo.HouseVisitRoles  HVR
		WHERE
			HVR.cRoleName= '#RoleName#';
	</cfquery>
	<cfreturn tmpFetchRoleID>
</cffunction>


<cffunction access="public" name="FetchHouseVisitRole" displayname="FetchHouseVisitRoleName" returntype="query"
			description="Returns the Role Record of the specified Role Id.">
	<cfargument name="iRolesQuery" type="query" required="true">
	<cfargument name="iRoleId" type="numeric" required="true">
	<cfquery name="tmpFetchRole" dbtype="query">
		SELECT
			*
		FROM
			iRolesQuery
		WHERE
			iRoleId = #iRoleId#;
	</cfquery>
	
	<cfreturn tmpFetchRole>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleName" displayname="FetchHouseVisitRoleName" returntype="String"
			description="Returns the cRoleName of the specified Role Id.">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iRoleId" type="numeric" required="true">
	<cfquery name="tmpFetchRole" dbtype="query">
		SELECT
			*
		FROM
			iRolesQuery
		WHERE
			iRoleId = #iRoleId#;
	</cfquery>
	
	<cfif tmpFetchRole.RecordCount Is "0">
		<cfreturn "Unknown">
	<cfelse>
		<cfreturn tmpFetchRole.cRoleName>
	</cfif>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitGroupQuestions" displayname="FetchHouseVisitGroupQuestions" returntype="query"
			description="Returns a Query object that contains every Question that is Active (not deleted) and in the specified Group.">
<cfargument name="iQuestionsQuery" type="query" required="true">
<cfargument name="iGroupId" type="numeric" required="true">

	<cfquery name="tmpFetchGroupQuestions" dbtype="query">
		SELECT
			*
		FROM
			iQuestionsQuery
		WHERE
			dtRowDeleted IS NULL AND
			iGroup = #iGroupId#;
	</cfquery>

	<cfreturn tmpFetchGroupQuestions>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitGroupQuestionsByRole" displayname="FetchHouseVisitGroupQuestionsByRole" returntype="query"
			description="Returns a Query object that contains every Question that is in the specified Group and is associated with the specified Role.">
<cfargument name="iQuestionsQuery" type="query" required="true">
<cfargument name="iGroupId" type="numeric" required="true">
<cfargument name="iQuestionRolesQuery" type="query" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchGroupQuestions" dbtype="query">
		SELECT DISTINCT
			iQuestionsQuery.*
		FROM
			iQuestionsQuery, iQuestionRolesQuery 
		WHERE 
			iQuestionsQuery.iQuestionId = iQuestionRolesQuery.iQuestion AND
			iQuestionsQuery.dtRowDeleted IS NULL AND
			iQuestionRolesQuery.dtRowDeleted IS NULL AND
			iQuestionsQuery.iGroup = #iGroupId# AND
			iQuestionRolesQuery.iRole = #iRoleId#
		ORDER BY
			iQuestionsQuery.iSortOrder;
	</cfquery>

	
	<cfreturn tmpFetchGroupQuestions>
		
</cffunction>




<cffunction access="public" name="IsQuestionRole" displayname="IsQuestionRole" returntype="boolean"
			description="Returns whether or not the specified Role is used by the Questions, because if it's not, the Role is an Admin/Exec.">
<cfargument name="iQuestionRolesQuery" type="query" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchRoleQuestions" dbtype="query">
		SELECT
			*
		FROM
			iQuestionRolesQuery
		WHERE
			dtRowDeleted IS NULL AND
			iRole = #iRoleId#;
	</cfquery>
	
	<cfreturn IIF(tmpFetchRoleQuestions.RecordCount gt 0, true, false)>
		
</cffunction>

<cffunction access="public" name="IsValidRole" displayname="IsValidRole" returntype="boolean"
			description="Returns whether or not the Role is Valid.">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iRoleId" type="numeric" required="true">

	<cfquery name="tmpFetchMatchingRole" dbtype="query">
		SELECT
			*
		FROM
			iRolesQuery
		WHERE
			iRoleId = #iRoleId#;
	</cfquery>
	
	<cfreturn IIF(tmpFetchMatchingRole.RecordCount gt 0, true, false)>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitQuestionRoleGroupString" displayname="FetchHouseVisitQuestionRoleGroupString" returntype="String"
			description="Returns each Role Code in the specified Role Group, comma-seperated (O,S,D, etc...).">
<cfargument name="iQuestionRolesQuery" type="query" required="true">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iQuestionId" type="numeric" required="true">

	<cfquery name="tmpFetchQuestionRoles" dbtype="query">
		SELECT
			iRole
		FROM
			iQuestionRolesQuery
		WHERE
			iQuestion = #iQuestionId#;
	</cfquery>
	<cfset roleGroupString = "">
	<cfloop query="tmpFetchQuestionRoles">
		
		<cfquery name="tmpFetchRoleCode" dbtype="query">
			SELECT
				cRoleCode
			FROM
				iRolesQuery
			WHERE
				iRoleId = #tmpFetchQuestionRoles.iRole#
		</cfquery>
		
		<cfset roleGroupString = roleGroupString & tmpFetchRoleCode.cRoleCode>
		
		<cfif tmpFetchQuestionRoles.CurrentRow lt tmpFetchQuestionRoles.RecordCount>
			<cfset roleGroupString = roleGroupString & ",">
		</cfif>
	</cfloop>
	
	<cfreturn roleGroupString>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitAnswer" displayname="FetchHouseVisitAnswer" returntype="String"
			description="Returns the Answer for the specified Entry's Question.  If there is no answer, an empty string is returned.">
<cfargument name="iAnswersQuery" type="query" required="true">
<cfargument name="iEntryId" type="numeric" required="true">
<cfargument name="iQuestionId" type="numeric" required="true">

	<cfquery name="tmpFetchAnswer" dbtype="query">
		SELECT
			*
		FROM
			iAnswersQuery
		WHERE
			iEntry = #iEntryId# AND
			iQuestion = #iQuestionId#;
	</cfquery>
	
	<cfif tmpFetchAnswer.RecordCount is "0">
		<cfreturn "&##160;">
	<cfelse>
		<cfreturn tmpFetchAnswer.cEntryAnswer>
	</cfif>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleIdByName" displayname="FetchHouseVisitRoleIdByName" returntype="numeric"
			description="Returns the House Visit Role Id of the Role that matches the specified Role Name.">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iRoleName" type="string" required="true">

	<cfquery name="tmpFetchHouseVisitRole" dbtype="query">
		SELECT
			iRoleId
		FROM
			iRolesQuery
		WHERE
			cRoleName = '#iRoleName#';
	</cfquery>
	
	<cfif tmpFetchHouseVisitRole.RecordCount Is "0">
		<cfreturn -1>
	<cfelse>
		<cfreturn tmpFetchHouseVisitRole.iRoleId>	
	</cfif>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleIdByTitle" displayname="FetchHouseVisitRoleIdByTitle" returntype="numeric"
			description="Returns the House Visit Role Id that matches the specified Title.">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iAuthenticationQuery" type="query" required="true">
<cfargument name="iRoleName" type="string" required="true">

	<cfquery name="tmpFetchHouseVisitAuthentication" dbtype="query">
		SELECT
			*
		FROM
			iAuthenticationQuery
		WHERE
			cUserTitle = '#iRoleName#';
	</cfquery>
	<cfif tmpFetchHouseVisitAuthentication.RecordCount eq 0>
		<cfset tmpRoleId = 0>
	<cfelse>
		<cfset tmpRoleId = tmpFetchHouseVisitAuthentication.iRole>
	</cfif>
	<cfquery name="tmpFetchHouseVisitRole" dbtype="query">
		SELECT
			*
		FROM
			iRolesQuery
		WHERE
			iRoleId = #tmpRoleId#
		ORDER BY
			dtRowDeleted;
	</cfquery>
	
	<cfif tmpFetchHouseVisitRole.RecordCount Is "0">
		<cfreturn -1>
	<cfelse>
		<cfreturn tmpFetchHouseVisitRole.iRoleId>	
	</cfif>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleByName" displayname="FetchHouseVisitRoleByName" returntype="query"
			description="Returns the House Visit Role that matches the specified Role Name.">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iRoleName" type="string" required="true">

	<cfquery name="tmpFetchHouseVisitRole" dbtype="query">
		SELECT
			*
		FROM
			iRolesQuery
		WHERE
			cRoleName = '#iRoleName#'
		ORDER BY
			dtRowDeleted;
	</cfquery>
	
	<cfreturn tmpFetchHouseVisitRole>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitRoleByTitle" displayname="FetchHouseVisitRoleByTitle" returntype="query"
			description="Returns the House Visit Role that matches the specified Title.">
<cfargument name="iRolesQuery" type="query" required="true">
<cfargument name="iAuthenticationQuery" type="query" required="true">
<cfargument name="iRoleName" type="string" required="true">

	<cfquery name="tmpFetchHouseVisitAuthentication" dbtype="query">
		SELECT
			*
		FROM
			iAuthenticationQuery
		WHERE
			cUserTitle = '#iRoleName#';
	</cfquery>
	<cfif tmpFetchHouseVisitAuthentication.RecordCount eq 0>
		<cfset tmpRoleId = 0>
	<cfelse>
		<cfset tmpRoleId = tmpFetchHouseVisitAuthentication.iRole>
	</cfif>
	<cfquery name="tmpFetchHouseVisitRole" dbtype="query">
		SELECT
			*
		FROM
			iRolesQuery
		WHERE
			iRoleId = #tmpRoleId#
		ORDER BY
			dtRowDeleted;
	</cfquery>
	
	<cfreturn tmpFetchHouseVisitRole>
	
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntryById" displayname="FetchHouseVisitEntryById" returntype="query"
			description="Returns the House Visit Entry record that matches the specified Entry Id.">
<cfargument name="iEntriesQuery" type="query" required="true">
<cfargument name="iEntryId" type="numeric" required="true">

	<cfquery name="tmpFetchEntry" dbtype="query">
		SELECT
			*
		FROM
			iEntriesQuery
		WHERE
			iEntryId = #iEntryId#;
	</cfquery>	
		
	<cfreturn tmpFetchEntry>	

</cffunction>

<cffunction access="public" name="FetchHouseVisitDataII" displayname="FetchHouseVisitDataII" returntype="query"
			description="Returns a Query object that contains every Role that is Active (not deleted).">
	<cfargument name="iEntryId" 		type="numeric" required="true">
	<cfquery name="tempHVData" datasource="#FtaDsName#">
		SELECT HVG.cGroupName, 
			HVQ.cQuestion,
			HVE.iRole,
			HVA.cEntryAnswer
		FROM  dbo.HouseVisitGroupsII HVG,
			dbo.HouseVisitEntriesII HVE,
			dbo.HouseVisitAnswersII HVA,
			dbo.HouseVisitQuestionsII HVQ
		WHERE  HVE.iENtryId = #iEntryId#
			and HVE.iENtryId = HVA.iHouseVisitENtry		
			and HVA.iEntryGroupId = HVG.igroupid
			and HVQ.iGroupID = HVG.iGroupid  
			and HVQ.iQuestionID = HVA.iquestionID   
			and HVQ.dtRowDeleted IS NULL
		ORDER By HVG.iSortOrder,HVQ.iSortOrder,HVA.iEntryQuestionSub
			</cfquery>
	<cfreturn tempHVData>
		
</cffunction>


<cffunction access="public" name="qryHouseVisitEntryByHouseByWeek" displayname="qryHouseVisitEntryByHouseByWeek" returntype="query"
			description="Returns the House Visit Entry records by House by Week.">
 
	<cfargument name="iHouseId" 		type="numeric" required="true">
	
	<cfquery name="tmpFetchEntry" datasource="#FtaDsName#">
		SELECT 
		*
		FROM
		dbo.HouseVisitEntriesII
		WHERE
		iHouseId = #iHouseId#
		 
		;
	</cfquery>	  
 		
	<cfreturn tmpFetchEntry>	

</cffunction>

<cffunction access="public" name="qryHouseVisitEntryByHouseByRDO" displayname="qryHouseVisitEntryByHouseByRDO" returntype="query"
			description="Returns the House Visit Entry records by House by Week.">
 
	<cfargument name="iHouseId" 		type="numeric" required="true">
	
	<cfquery name="tmpFetchEntryRDO" datasource="#FtaDsName#">
		SELECT TOP 1 *
		 
		FROM
		dbo.HouseVisitEntriesII
		WHERE
		iHouseId = #iHouseId#
		and iRole  = 1
		 
		;
	</cfquery>
	<cfreturn tmpFetchEntryRDO>	

</cffunction>

<cffunction access="public" name="qryHouseVisitEntryByHouseByRDQCS" displayname="qryHouseVisitEntryByHouseByRDQCS" returntype="query"
			description="Returns the House Visit Entry records by House by Week.">
 
	<cfargument name="iHouseId" 		type="numeric" required="true">
	
	<cfquery name="tmpFetchEntryRDQCS" datasource="#FtaDsName#">
		SELECT TOP 1 *
		 
		FROM
		dbo.HouseVisitEntriesII
		WHERE
		iHouseId = #iHouseId#
		and iRole  = 3
		 
		;
	</cfquery>
	<cfreturn tmpFetchEntryRDQCS>	

</cffunction>
<cffunction access="public" name="qryHouseVisitEntryByHouseByRDSM" displayname="qryHouseVisitEntryByHouseByRDSM" returntype="query"
			description="Returns the House Visit Entry records by House by Week.">
 
	<cfargument name="iHouseId" 		type="numeric" required="true">
	
	<cfquery name="tmpFetchEntryRDSM" datasource="#FtaDsName#">
		SELECT TOP 1 *
		 
		FROM
		dbo.HouseVisitEntriesII
		WHERE
		iHouseId = #iHouseId#
		and iRole  = 2
		 
		;
	</cfquery>
	<cfreturn tmpFetchEntryRDSM>	

</cffunction>	
<cffunction access="public" name="FetchHouseVisitEntryByIdII" displayname="FetchHouseVisitEntryByIdII" returntype="query"
			description="Returns the House Visit Entry record that matches the specified Entry Id.">
 
	<cfargument name="iEntryId" 		type="numeric" required="true">
	
	<cfquery name="tmpFetchEntry" datasource="#FtaDsName#">
		SELECT
		*
		FROM
		dbo.HouseVisitEntriesII
		WHERE
		iEntryId = #iEntryId#;
	</cfquery>	  
 		
	<cfreturn tmpFetchEntry>	

</cffunction>

<cffunction access="public" name="FetchHouseVisitEntryAnswersII" displayname="FetchHouseVisitEntryAnswersII"  returntype="string"
			description="Returns the House Visit Entry Data records that matches the specified Entry Id.">
 
<cfargument name="iEntryId" 		type="numeric" required="true">
<cfargument name="iGroupId" 		type="numeric" required="true">
<cfargument name="iQuestionId" 		type="numeric" required="true">
<cfargument name="iQuestionSubId" 	type="numeric" required="true">

	<cfquery name="tempEntryAnswer" datasource="#FtaDsName#">
		SELECT HVA.cEntryAnswer entryanswer
		FROM    dbo.HouseVisitAnswersII HVA 
		WHERE  HVA.iHouseVisitEntry = #iEntryId#
		and   HVA.ientryGroupid = 		#iGroupId#
		and HVA.iQuestionId = 		#iQuestionId#
		and HVA.iEntryQuestionSub =   	#iQuestionSubId#
		</cfquery>		
	<cfreturn tempEntryAnswer.entryanswer>	

</cffunction>



<cffunction access="public" name="FetchHouseVisitAnswerCountII" displayname="FetchHouseVisitAnswerCountII"  returntype="string"
			description="Returns the House Visit Entry Data record count by question.">
 
<cfargument name="iEntryId" 		type="numeric" required="true">
<cfargument name="iGroupId" 		type="numeric" required="true">

	<cfquery name="tempEntryAnswerCount" datasource="#FtaDsName#">
		Select max(iEntryQuestionSub) as maxcount
		FROM    dbo.HouseVisitAnswersII HVA 
		WHERE  HVA.iHouseVisitEntry = #iEntryId#
		and   HVA.ientryGroupid = 		#iGroupId#
	</cfquery>		
	<cfreturn tempEntryAnswerCount.maxcount>	

</cffunction>




<cffunction access="public" name="FetchHouseVisitEntryAnswers" displayname="FetchHouseVisitEntryAnswers" returntype="query"
			description="Returns all of the Answers associated with the specified Entry.">
<cfargument name="iAnswersQuery" type="query" required="true">
<cfargument name="iEntryId" type="numeric" required="true">

	<cfquery name="tmpFetchAnswers" dbtype="query">
		SELECT
			*
		FROM
			iAnswersQuery
		WHERE
			iEntry = #iEntryId# AND
			dtRowDeleted IS NULL;	
	</cfquery>

	<cfreturn tmpFetchAnswers>
		
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntryAnswer" displayname="FetchHouseVisitEntryAnswer" returntype="String"
			description="Returns the Answer to the specified Question in String format.">
<cfargument name="iEntryAnswersQuery" type="query" required="true">
<cfargument name="iQuestionId" type="numeric" required="true">

	<cfquery name="tmpFetchAnswer" dbtype="query">
		SELECT
			*
		FROM
			iEntryAnswersQuery
		WHERE
			iQuestion = #iQuestionId# AND
			dtRowDeleted IS NULL;	
	</cfquery>

	<cfif tmpFetchAnswer.RecordCount is "0">
		<cfreturn "">
	<cfelse>
		<cfreturn tmpFetchAnswer.cEntryAnswer>
	</cfif>		
</cffunction>

<cffunction access="public" name="FetchHouseVisitEntryAnswerToolTip" displayname="FetchHouseVisitEntryAnswerToolTip" returntype="String"
			description="Returns the person the created the answer along with the date and time it was created.">
<cfargument name="iEntryAnswersQuery" type="query" required="true">
<cfargument name="iQuestionId" type="numeric" required="true">

	<cfquery name="tmpFetchAnswer" dbtype="query">
		SELECT
			*
		FROM
			iEntryAnswersQuery
		WHERE
			iQuestion = #iQuestionId# AND
			dtRowDeleted IS NULL;	
	</cfquery>

	<cfif tmpFetchAnswer.RecordCount is "0">
		<cfreturn "">
	<cfelse>
		<cfset toolTipResult = "Created By: " & tmpFetchAnswer.cCreatedBy & " at " & DateFormat(tmpFetchAnswer.dtCreated, "mm/dd/yyyy") & " " & TimeFormat(tmpFetchAnswer.dtCreated, "hh:mm tt")>
		<cfreturn toolTipResult>
	</cfif>		
</cffunction>

<cffunction access="public" name="SearchSpellCheckItems" displayname="SearchSpellCheckItems" returntype="struct"
			description="Searches through an Array of Structure and returns the item that matches the passed-in question id with there QuestionId property.">
<cfargument name="iSpellCheckItems" type="array" required="true">
<cfargument name="iQuestionId" type="string" required="true">
	
	<cfloop index="scIndex" from="1" to="#ArrayLen(iSpellCheckItems)#">
		<cfif iSpellCheckItems[scIndex].QuestionId eq iQuestionId>
			<cfreturn iSpellCheckItems[scIndex]>
		</cfif>
	</cfloop>
	<cfscript>
		returnItem = structNew();
		returnItem.DoesExist = false;
		return (returnItem);
	</cfscript>
</cffunction>

<cffunction access="public" name="qryRegonExcelFile" displayname="qryRegonExcelFile" returntype="query"
			description="Extracts and returns query result for regional house visits.">
<cfargument name="RegionId"  type="numeric" required="true">
<cfquery name="qRegHouseVisit" datasource="#FtaDsName#" >
		 SELECT e.iEntryId,
		 a.iEntryAnswerId,
 				REPLACE(REPLACE(g.cTextHeader, '<br/>', CHAR(32)) 
				 , ',', CHAR(32)) AS Header,					 
 				REPLACE(REPLACE(q.cQuestion, '<br/>', CHAR(32)) 
				 , ',', CHAR(32)) AS Question,				 
				REPLACE(REPLACE(a.cEntryAnswer, '<br/>', CHAR(32)) 
				 , ',', CHAR(32)) AS Answer
				
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
				JOIN dbo.DashboardHouseInfo h
					ON h.iHouseid = e.iHouseId
			WHERE
				h.iRegionId = #RegionId# AND
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL and 
				a.cEntryAnswer is not null AND
				g.igroupid is not null  
			GROUP by 
			 e.iEntryId,
		 a.iEntryAnswerId,
 				 g.cTextHeader,  					 
 				 q.cQuestion ,				 
				 a.cEntryAnswer, 
				 g.iSortOrder,
				 q.isortorder  
			ORDER BY
				e.iEntryId Desc,
				a.iEntryAnswerId,
				g.cTextHeader,			
				g.iSortOrder asc,
				q.isortorder ASC 

</cfquery>
<cfreturn qRegHouseVisit>
</cffunction>

<cffunction name="queryToExcel" returnType="any" output="true" hint="Given a query and an optional output file name, output the query as an Excel document using the query columns as columns in Excel.">

	<cfargument name="queryToConvert" type="query" required="true" hint="Any valid CF Query Object" />
	<cfargument name="sFileBase" type="string" required="false" default="yourfile" hint="Desired base file name. Defaults to 'yourfile'. Output filename will be the value of this variable with .xls appended." />
	<cfheader name="Content-Disposition" value="inline; filename=#sFileBase#.xls">
	<cfcontent type="application/vnd.ms-excel">
		<table border=1>
			<tr>
			<cfloop list="#arrayToList(queryToConvert.getColumnList())#" index="sColName">
				<th><cfoutput>#sColName#</cfoutput></th>
			</cfloop>
				</tr>
			<cfloop query="queryToConvert">
				<tr>
				<cfloop list="#arrayToList(queryToConvert.getColumnList())#" index="sColName">
					<td><cfoutput>#queryToConvert[sColName][queryToConvert.currentRow]#</cfoutput></td>
				</cfloop>
				</tr>
			</cfloop>
		</table>
	
	<cfreturn true>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIRegon" displayname="qryHouseVisitIIRegon" returntype="query"
			description="Extracts and returns house for a region.">
<cfargument name="RegionId"  type="numeric" required="true">
<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
		 SELECT 
 				h.iRegionid, h.iHouseId, h.cHouseName , h.cRegionName 
				
			FROM
			  dbo.DashboardHouseInfo h
					 
			WHERE
				 h.iRegionid = #RegionId#  
			ORDER BY
				cHouseName 
</cfquery>
<cfreturn qRegionHouse>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIHouseRegion" displayname="qryHouseVisitIIHouseRegion" returntype="query"
			description="Extracts and returns region info for a house.">
	<cfargument name="HouseId"  type="numeric" required="true">
	<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
		SELECT 
			h.iRegionid, h.iHouseId, h.cHouseName, h.cRegionName 
		
		FROM
			dbo.DashboardHouseInfo h
			 
		WHERE
			h.iHouseid = #HouseId#  
	</cfquery>
	<cfreturn qRegionHouse>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIHouseListA" displayname="qryHouseVisitIIHouseListA" returntype="query"
			description="Extracts and returns house list">
	<cfargument name="iDivisionId"  type="numeric" required="true"> 
	<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
		SELECT 
		h.iRegionid, h.iHouseId, h.cHouseName , h.cRegionName 
		
		FROM
		dbo.DashboardHouseInfo h
		WHERE
		h.iDivisionId = #iDivisionId#
	 
		ORDER BY cHouseName 
	</cfquery>
	<cfreturn qRegionHouse>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIHouseList2A" displayname="qryHouseVisitIIHouseList2A" returntype="query"
			description="Extracts and returns house list">
	 
	<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
		SELECT 
		h.iRegionid, h.iHouseId, h.cHouseName , h.cRegionName 
		
		FROM
		dbo.DashboardHouseInfo h
		WHERE
		h.iRegionid in (3, 6, 17)
	 
		ORDER BY h.iRegionid, h.cHouseName 
	</cfquery>
	<cfreturn qRegionHouse>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIHouseList2B" displayname="qryHouseVisitIIHouseList2B" returntype="query"
			description="Extracts and returns house list">
	 
	<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
		SELECT 
		h.iRegionid, h.iHouseId, h.cHouseName , h.cRegionName 
		
		FROM
		dbo.DashboardHouseInfo h
		WHERE
		h.iRegionid in (35, 37)
	 
		ORDER BY h.iRegionid, h.cHouseName 
	</cfquery>
	<cfreturn qRegionHouse>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIHouseList" displayname="qryHouseVisitIIHouseList" returntype="query"
			description="Extracts and returns house list">
 
	<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
		SELECT 
		h.iRegionid, h.iHouseId, h.cHouseName , h.cRegionName 
		
		FROM
		dbo.DashboardHouseInfo h
		
		ORDER BY cHouseName 
	</cfquery>
	<cfreturn qRegionHouse>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIRegonHouseEntry" displayname="qryHouseVisitIIRegonHouseEntry" returntype="query"
			description="Extracts and returns entryid's for house for a region.">
		<cfargument name="RegionId"  type="numeric" required="true">
		<cfargument name="HouseId"  type="numeric" required="true">
		<cfargument name="thisThruDateF"  type="string" required="true">
				
		<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
			 SELECT top 20 e.iEntryId,	e.iHouseid, h.cHouseName, h.iRegionid, e.dtCreated 
			FROM
				dbo.DashboardHouseInfo h,
				dbo.HouseVisitEntriesII e
			WHERE
				    h.iRegionid = #RegionId#
				and h.iHouseid = #HouseId#
				and h.iHouseid = e.iHouseId
				and e.dtCreated > #thisThruDateF#
			GROUP BY  
				h.iRegionid , e.iHouseid,e.dtCreated, e.iEntryId,   h.cHouseName
			ORDER BY
				e.dtCreated  desc,	e.iHouseId, e.iEntryId 
		</cfquery>
		<cfreturn qRegionHouse>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIRegonHouseEntryA" displayname="qryHouseVisitIIRegonHouseEntryA" returntype="query"
			description="Extracts and returns entryid's for house for a region.">
		<cfargument name="RegionId"  type="numeric" required="true">
		<cfargument name="HouseId"  type="numeric" required="true">
		 
				
		<cfquery name="qRegionHouse" datasource="#FtaDsName#" >
			 SELECT e.iEntryId,	e.iHouseid, h.cHouseName, h.iRegionid, e.dtCreated 
			FROM
				dbo.DashboardHouseInfo h,
				dbo.HouseVisitEntriesII e
			WHERE
				    h.iRegionid = #RegionId#
				and h.iHouseid = #HouseId#
				and h.iHouseid = e.iHouseId
				 
			GROUP BY  
				h.iRegionid , e.iHouseid,e.dtCreated, e.iEntryId,   h.cHouseName
			ORDER BY
				e.dtCreated  desc,	e.iHouseId, e.iEntryId 
		</cfquery>
		<cfreturn qRegionHouse>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIHousebyRegion" displayname="qryHouseVisitIIHousebyRegion" returntype="query"
			description="Extracts and returns house visits for a region.">
	 
	<cfquery name="qHouseRegion" datasource="#FtaDsName#" >
				SELECT  
			h.iRegionid,e.iHouseId,	 h.cHouseName   
					
				FROM
				  dbo.DashboardHouseInfo h,
				  dbo.HouseVisitEntriesII e
						 
				WHERE
					     h.iHouseid = e.iHouseId
				GROUP BY  h.iRegionid,  e.iHouseid,  h.cHouseName
				ORDER BY
				h.iRegionid,	e.iHouseId ;
	</cfquery>
	<cfreturn qHouseRegion>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIEntriesRegionHouse" displayname="qryHouseVisitIIEntriesRegionHouse" returntype="query"
			description="Extracts and returns entries for each house for a region.">
	<cfargument name="RegionId"  type="numeric" required="true">
	<cfquery name="qRegionHouseEntry" datasource="#FtaDsName#" >
			 SELECT 
					e.dtHouseVisit,
					e.cUserDisplayName,
					e.iRole,
					e.iEntryId,
					h.iHouseid, 
					h.cHouseName
					
				FROM
				  dbo.DashboardHouseInfo h,
				  dbo.HouseVisitEntriesII e
						 
				WHERE
					 h.iRegionid = #RegionId# 
					 and h.ihouseid = e.ihouseid 
				ORDER BY
					cHouseName 
	</cfquery>
	<cfreturn qRegionHouseEntry>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIEntriesByRegionHouse" displayname="qryHouseVisitIIEntriesByRegionHouse" returntype="query"
			description="Extracts and returns entries for each house for a region.">
	<cfargument name="RegionId"  type="numeric" required="true">
	<cfquery name="qRegionHouseEntry" datasource="#FtaDsName#" >
		 SELECT 
				h.cDivisionName + ' ' + CAST(h.iDivisionId as varchar(3)) as Division,
				h.cRegionName + ' ' + CAST(h.iRegionId as varchar(3)) as Region,
				h.cHouseName + ' ' + CAST(h.iHouseId as varchar(3)) as House,
				e.cUserDisplayName,	 
				r.cRoleName,
				e.dtCreated,
				a.iHouseVisitEntry, 
 				REPLACE(REPLACE(g.cTextHeader, '<br/>', CHAR(32)) 
				 , ',', CHAR(32)) AS cTextHeader,					 
 				REPLACE(REPLACE(q.cQuestion, '<br/>', CHAR(32)) 
				 , ',', CHAR(32)) AS cQuestion,				 
				REPLACE(REPLACE(a.cEntryAnswer, '<br/>', CHAR(32)) 
				 , ',', CHAR(32)) AS cEntryAnswer
			FROM
				 dbo.HouseVisitEntriesII e
				left outer JOIN  dbo.HouseVisitAnswersII a
					ON e.iEntryId = a.iHouseVisitEntry 
						AND a.dtRowDeleted IS NULL
				left outer join 	 dbo.HouseVisitQuestionsII q
					ON q.iqUESTIONID = a.iQuestionId
				left outer join  dbo.HouseVisitGroupsII g
					ON g.iGroupid = q.iGroupID
				join dbo.HouseVisitRoles r
					ON e.iRole = r.iroleid
				JOIN dbo.DashboardHouseInfo h
					ON h.iHouseid = e.iHouseId
			WHERE
				e.iEntryId in
		( SELECT 
 				ev.iEntryId 
			FROM
			  dbo.DashboardHouseInfo h,
			  dbo.HouseVisitEntriesII ev
					 
			WHERE
				 h.iRegionid = #RegionId# 
				 and h.ihouseid = ev.ihouseid 
			  )AND
				e.dtRowDeleted IS NULL AND
				q.dtRowDeleted IS NULL   
			GROUP  by
				g.cTextHeader,
				q.cQuestion,
				a.cEntryAnswer,
				h.iDivisionID,
				h.cDivisionName,
				h.iregionid,
				h.cRegionName ,
				h.cHouseName , 
				h.iHouseId,
				e.cUserDisplayName,	 
				r.cRoleName,
				e.iEntryId,
				e.dtCreated,
				a.iHouseVisitEntry, 
				g.iGroupid,
				a.iEntryAnswerId,
				a.iQuestionId,
				g.iSortOrder,
				q.isortorder 
	</cfquery>
	<cfreturn qRegionHouseEntry>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIMaxEntries" displayname="qryHouseVisitIIMaxEntries" returntype="query"
			description="Extracts and returns Max entries for each question group.">
		<cfquery name="qMaxEntry" datasource="#FtaDsName#" >
SELECT  iHouseVisitEntry
      ,iEntryGroupID
      ,iQuestionId
  ,    dtCreated 
     ,Count(centryanswer) as entrycount
        FROM HouseVisitAnswersII
         
       
 group by iHouseVisitEntry, iEntryGroupID, iQuestionId ,    dtCreated
  order by entrycount desc, iHouseVisitEntry, iEntryGroupID, iQuestionId ,    dtCreated
		</cfquery>  
 		 <cfreturn qMaxEntry>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIEntryMax" displayname="qryHouseVisitIIEntryMax" returntype="query"
			description="Extracts and returns Max entries for each question group for an Entry.">
	<cfargument name="iEntryID"  type="numeric" required="true">
		<cfquery name="qMaxEntry" datasource="#FtaDsName#" >
			SELECT top 1 iHouseVisitEntry
			,iEntryGroupID
			,iQuestionId
			,Count(centryanswer) as entrycount
			FROM  dbo.HouseVisitAnswersII
			WHERE iHouseVisitEntry = #iEntryID#
				and ientrygroupid <> 2
			GROUP by iHouseVisitEntry, iEntryGroupID, iQuestionId  
			ORDER by entrycount desc, iHouseVisitEntry, iEntryGroupID, iQuestionId  
		</cfquery>  
	<cfreturn qMaxEntry>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIEmpRm" displayname="qryHouseVisitIIEmpRm" returntype="query"
			description="Determines if there are empty room entries for this person.">
	<cfargument name="iEntryID"  type="numeric" required="true">
		<cfquery name="qEmptyRm" datasource="#FtaDsName#" >
			SELECT  iHouseVisitEntry
			,iEntryGroupID
			,iQuestionId
			,Count(centryanswer) as emptyroomcount
			FROM  dbo.HouseVisitAnswersII
			WHERE iHouseVisitEntry = #iEntryID#
				and ientrygroupid = 2
			GROUP by iHouseVisitEntry, iEntryGroupID, iQuestionId  
			ORDER by emptyroomcount desc, iHouseVisitEntry, iEntryGroupID, iQuestionId  
		</cfquery>  
	<cfreturn qEmptyRm>
</cffunction>

<cffunction access="public" name="qryHouseVisitIIGroupRole" displayname="qryHouseVisitIIGroupRole" returntype="query"
			description="Extracts and returns roles per group.">
	<cfargument name="igroupid"  type="numeric" required="true">

		<cfquery name="qGroupRole" datasource="#FtaDsName#" >
			SELECT g.cgroupname, r.crolename
			FROM
			 dbo.HouseVisitRoles r,
			 dbo.HouseVisitQuestionRolesII qr ,
			 dbo.HouseVisitGroupsII g
			WHERE g.iGroupid = qr.IGroup 
				and qr.[iRole] = r.iRoleId  
				and igroupid = #igroupid#
				and r.dtrowdeleted is null
		</cfquery> 
		
		<cfreturn qGroupRole>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIGroupsFields" displayname="qryHouseVisitIIGroupsFields" returntype="query"
			description="Extracts and returns roles per group.">
	<cfargument name="igroupid"  type="numeric" required="true">

		<cfquery name="qGroupRole" datasource="#FtaDsName#" >
			SELECT g.cgroupname  
				  ,g.iGroupid
				  ,g.cGroupName
				  ,g.iGroupCompletionTime
				  ,g.iSortOrder
				  ,g.cTextHeader
				  ,g.dtRowDeleted
				  ,g.IndexMax
				  ,g.IndexName
				  ,g.AddRows
				  ,g.addrowname		

			FROM

			 dbo.HouseVisitGroupsII g
			WHERE   g.igroupid = #igroupid#
				
		</cfquery> 
		
		<cfreturn qGroupRole>
</cffunction>
<cffunction access="public" name="qryHouseVisitIIRegionHouseList" displayname="qryHouseVisitIIRegionHouseList" returntype="query"
			description="Extracts and returns roles per group.">

		<cfquery name="qRegionRegionList" datasource="#FtaDsName#" >
				SELECT  h.iRegionid, 	 h.cHouseName   
				FROM  dbo.DashboardHouseInfo h 
				GROUP BY  h.iRegionid,    h.cHouseName
				ORDER BY 				h.iRegionid 
		</cfquery>		
		<cfreturn qRegionRegionList>
</cffunction>

<cffunction access="public" name="qryHouseVisitIINameEmail" displayname="qryHouseVisitIINameEmail" returntype="query"
			description="Extracts and returns emails.">
		<cfargument name="regionID"  type="numeric" required="true">
		<cfargument name="roletype"  type="string" required="true">	

		<cfquery name="qGroupRole" datasource="#FtaDsName#" >
			SELECT  cFullName
			,cEmail
			,cRole
			,cScope
			,cScopeType
			,cHouseName
			,iHouseId
			,iRegionId
			,iDivisionId
			FROM dbo.vw_UserAccountDetails uad
			where uad.iRegionId =  #regionID#
			and uad.cRole =  #roletype#
		</cfquery>
		<cfreturn qGroupRole> 
</cffunction> 
<cffunction access="public" name="qryHouseVisitIIEmptyRm" displayname="qryHouseVisitIIEmptyRm" returntype="string"
			description="Extracts and returns the empty rooms for a house visit."> 
		<cfargument name="iEntryId"  type="string" required="true">	

		<cfquery name="qGroupRole" datasource="#FtaDsName#" >
 			SELECT  cEntryAnswer , 
			iHouseVisitEntry
			,iEntryGroupID
			,iQuestionId
			FROM   dbo.HouseVisitAnswersII
			where iHouseVisitEntry = #iEntryId# and ientrygroupid = 2
		</cfquery>
		<cfset roomlist = "">
		<cfloop query="qGroupRole">
			<cfset roomlist = roomlist & " " & trim(qGroupRole.cEntryAnswer)>			
		</cfloop>
	
		<cfreturn roomlist> 
</cffunction>  
 
<cffunction access="public" name="qryHouseVisitIIEmailListDVP" displayname="qryHouseVisitIIEmailListDVP" returntype="query"
			description="Extracts and returns roles per group.">
		<cfargument name="roletype"  type="string" required="true">			
		<cfquery name="qRegionEmailList" datasource="#FtaDsName#" >
				SELECT   distinct (uad.iRegionId), uad.cFullName, uad.cEMail, uad.cRole , uad.iDivisionID  
				FROM   dbo.vw_UserAccountDetails uad 
				WHERE uad.cRole = '#roletype#'
				ORDER BY uad.cFullName, idivisionid, iregionid
		</cfquery>		
		<cfreturn qRegionEmailList>
</cffunction> 
<cffunction access="public" name="qryHouseVisitIIEmailListReg" displayname="qryHouseVisitIIEmailListReg" returntype="query"
			description="Extracts and returns roles per group.">
		<cfargument name="roletype"  type="string" required="true">			
		<cfquery name="qRegionEmailList" datasource="#FtaDsName#" >
				SELECT distinct(uad.iRegionID), uad.cFullName, uad.cEMail, uad.cRole,
				opa.cName regionName  
				FROM   dbo.vw_UserAccountDetails uad, 
					 dbo.vw_OpsArea opa
				WHERE uad.cRole = '#roletype#' and
				uad.idivisionid is not null and 
				uad.iregionid is not null  
				and opa.iOpsArea_Id = uad.iRegionID
				ORDER BY uad.cFullName
		</cfquery>		
		<cfreturn qRegionEmailList>
</cffunction> 
<cffunction access="public" name="qryHouseVisitIIEmailListHouse" displayname="qryHouseVisitIIEmailListHouse" returntype="query"
			description="Extracts and returns roles per group.">
		<cfargument name="roletype"  type="string" required="true">			
		<cfquery name="qRegionEmailList" datasource="#FtaDsName#" >
				SELECT  distinct(uad.iHouseId),   uad.cFullName, uad.cEMail,  uad.cRole, uad.cHousename   
				FROM   dbo.vw_UserAccountDetails uad 
				WHERE uad.cRole = '#roletype#'
				ORDER BY uad.cFullName
		</cfquery>		
		<cfreturn qRegionEmailList>
</cffunction> 
<cffunction access="public" name="qryHouseVisitIIEmailListVP" displayname="qryHouseVisitIIEmailListVP" returntype="query"
			description="Extracts and returns roles per group.">
 				<cfargument name="thisname"  type="string" required="true">	
		<cfquery name="qRegionEmailList" datasource="#FtaDsName#" >
				SELECT distinct(uad.iRegionID), uad.cFullName, uad.cEMail, uad.cRole,   uad.cScope, uad.cScopeType
				FROM   dbo.vw_UserAccountDetails uad 
				WHERE uad.cfullname = '#thisname#'
				ORDER BY uad.cFullName
		</cfquery>		
		<cfreturn qRegionEmailList>
</cffunction> 
<cffunction access="public" name="qryHouseVisitIIRegionList" displayname="qryHouseVisitIIRegionList" returntype="query"
			description="Extracts and returns roles per group.">
 		<cfargument name="divisionid"  type="string" required="true">
		<cfquery name="qRegionEmailRegionList" datasource="#FtaDsName#" >
			SELECT distinct reg.cname regionname , div.cname division_name, div.iRegion_ID DivisionID,
				reg.iOpsArea_ID iRegionID  
			FROM      dbo.vw_OpsArea reg,
				 dbo.vw_Region div,
				 dbo.vw_UserAccountDetails uad
			WHERE
				div.iRegion_ID = #divisionid# and
				div.iRegion_ID = reg.iRegion_id
				and div.iregion_id = uad.idivisionid  
			ORDER by division_name
		</cfquery>		
		<cfreturn qRegionEmailRegionList>
</cffunction> 
</cfcomponent>