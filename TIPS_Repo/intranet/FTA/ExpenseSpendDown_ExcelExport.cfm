<!----------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 03/23/2009 | Developed Expense Spend Down Excel Export Page.					                   |
----------------------------------------------------------------------------------------------->

<cfinclude template="Common/DateToUse.cfm">
<cfheader name='expires' value='#Now()#'> 
<cfheader name='pragma' value='no-cache'>
<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>

<cfscript>
	// Stores whether or not there was an error.
	isError = false;
	// Try to generate the string required to populate the Expense Spend Down spreadsheet.
	try
	{
		// Instantiate the Helper object.
		helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource);
		
		// Check if the SubAccount Query String parameter is Defined.
		if (isDefined("url.subAccount"))
		{
			// Assign the URL Query String variable to the SubAccount variable.
			subAccount = url.subAccount;
		}
		else
		{
			// Throw an exception, because the user needs to select a house.
			helperObj.Throw("The SubAccount Query String Parameter is NOT DEFINED!");
		}

		// Instantiate the house info.
		houseInfo = helperObj.FetchHouseInfo(subAccount);
		houseId = houseInfo["ihouse_id"][1];
		houseName = houseInfo["cName"][1];
		
		// Begin creating the Excel Data Entry String.
		excelWorkSheet = "Expense Spend Down";
		excelData = excelWorkSheet & ".A.2:" & DateFormat(FromDate, 'M/D/YYYY');
		// ---------------------------------------------------------------------------------------------
	
		// Initialize all of the required fields.
		dsColumns = helperObj.FetchColumns();
		columnCount = dsColumns.RecordCount;
		dsBudgetSummary = helperObj.FetchBudgetSummary(houseId, currentY, monthForQueries);
		dsActualDetails = helperObj.FetchActualDetails(houseId, PtoPFormat, FromDate, ThruDate);
		dsActualSummary = helperObj.FetchActualSummary(houseId, PtoPFormat, FromDate, ThruDate, dsActualDetails);
		dsCensusDetails = helperObj.FetchCensusDetails(houseId, FromDate, ThruDate);
		foodBudgetAccumulator = helperObj.FetchFoodBudgetAccumulator(houseId, currentY, monthForQueries);
		dailyCensusBudget = helperObj.FetchDailyCensusBudget(houseId, currentY, monthForQueries);
		censusBudgetDim = dailyCensusBudget * currentDIM;
		totalColCount = columncount + 5;
		dsExpenseCategoryGlCodes = helperObj.FetchAllExpenseCategoryGLCodes();
		// Assign the House Name to cell G1.
		excelData = excelData & "|" & excelWorkSheet & 
					".G.1:" & houseName; 
		// Assign the Food Budget to cell D2.
		excelData = excelData & "|" & excelWorkSheet & 
					".D.2:" & foodBudgetAccumulator; 
	
		// Occupancy and Census Accumulators.
		censusBudgetMtd = 0;
		censusMtd = 0;
					
		// CURRENT DAY'S ACTUALS (INCLUDING FOOD BUDGET)
		for (currentMtdDay = 1; currentMtdDay lte currentD; currentMtdDay = currentMtdDay + 1)
		{
			// Stores the current excel row in the loop.
			currentExcelRow = currentMtdDay + 3;
			// Fetch the MTD Actuals for the current day.
			MtdDayActuals = helperObj.FetchActualSummaryMtdDay(dsActualSummary, currentMtdDay);
			// Assign the current day's Census Budget to column B.
			excelData = excelData & "|" & excelWorkSheet & ".B." & 
						currentExcelRow & ":" & dailyCensusBudget; 
			// Update the Occupancy Budget Month to Day accumulator.
			censusBudgetMtd = censusBudgetMtd + dailyCensusBudget;
			// Fetch the Physical Census for the current day.
			currentCensus = helperObj.FetchTenantsForDay(dsCensusDetails, currentMtdDay);
			// Update the Census Month to Day accumulator.
			censusMtd = censusMtd + currentCensus;
			// Assign the current Census to column C.
			excelData = excelData & "|" & excelWorkSheet & ".C." & 
						currentExcelRow & ":" & currentCensus; 
			// Assign the current Food Budget to column D.
			excelData = excelData & "|" & excelWorkSheet & ".D." & 
						currentExcelRow & ":" & (currentCensus * foodBudgetAccumulator); 
			// Used to identifity if the Food Actuals column has been assigned.
			runOnce4Food = true;
			// Accumulatates the Actual Total for the current day.
			actualDailyTotal = 0;
			// Stores the current Excel Column in the loop's iteration.
			currentExcelColumn = "E";
			// Loop through all of the accumulated category invoice totals for the current day.
			for (index = 1; index lte MtdDayActuals.RecordCount; index = index + 1)
			{
				// Check if the Food switch has been disabled.
				if (runOnce4Food eq true)
				{
					// Add the current column's accumulated invoice total to the daily total accumulator.
					actualDailyTotal = actualDailyTotal + MtdDayActuals["mAmount"][index];
					
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & MtdDayActuals["mAmount"][index]; 
											
					runOnce4Food = false;
				}
				else
				{
					actualDailyTotal = actualDailyTotal + MtdDayActuals.mAmount;
	
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & MtdDayActuals["mAmount"][index]; 
				}
				// Get the next letter in the alphabet.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			}
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
						"." & currentExcelRow & ":" & actualDailyTotal; 
		}
		futureStartDay = currentD + 1;
		
		if (futureStartDay lte currentDIM)
		{
			for (futureDay = FutureStartDay; futureDay lte (currentDIM + 1); futureDay = futureDay + 1)
			{
				futureDay2Delete = futureDay + 3;
				excelData = excelData & "|" & excelWorkSheet & 
							".!." & futureDay2Delete & ":0"; 
			}
		}
		
			
		// MTD ACTUALS
		currentExcelRow = 35;
		MtdActuals = helperObj.FetchActualSummaryMtd(dsActualSummary);
	
		excelData = excelData & "|" & excelWorkSheet & ".C." & 
					currentExcelRow & ":" & censusMtd; 
			
		actualTotal = 0;
		actualCounter = 0;
		currentExcelColumn = "E";
		for (index = 1; index lte MtdDayActuals.RecordCount; index = index + 1)
		{
	
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
						"." & currentExcelRow & ":" & MtdActuals["mAmount"][index]; 
	
			actualTotal = actualTotal + MtdActuals["mAmount"][index];
			actualCounter = actualCounter + 1;
			// Get the next letter in the alphabet.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		}
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
					"." & currentExcelRow & ":" & actualTotal; 
						
		// MTD BUDGET
		currentExcelRow = 36;
		excelData = excelData & "|" & excelWorkSheet & ".C." & 
					currentExcelRow & ":" & censusBudgetMtd; 
		
		budgetTotal = 0;
		budgetCounter = 0;
		currentExcelColumn = "E";
		
		for (index = 1; index lte dsBudgetSummary.RecordCount; index = index + 1)
		{
			if (budgetCounter eq 0)
			{
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & (censusMtd * foodBudgetAccumulator); 
				budgetTotal = budgetTotal + (censusMtd * foodBudgetAccumulator);
			}
			else
			{
				currentBudgetMtdDay = ((dsBudgetSummary["mAmount"][index] / currentDIM) * currentD);
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 									
							"." & currentExcelRow & ":" & currentBudgetMtdDay; 
				budgetTotal = budgetTotal + currentBudgetMtdDay;
			}
			budgetCounter = budgetCounter + 1;
			// Get the next letter in the alphabet.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		}
	
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
					"." & currentExcelRow & ":" & budgetTotal; 
		// MTD VARIANCE
		currentExcelRow = 37;
		
		excelData = excelData & "|" & excelWorkSheet & ".C." & 
					currentExcelRow & ":" & (censusMtd - censusBudgetMtd); 
		
		varianceTotal = 0;
		varianceCounter = 0;
		currentExcelColumn = "E";
		for (index = 1; index lte MtdDayActuals.RecordCount; index = index + 1)
		{
			currentVarianceAmount = 0;
			for (nestedIndex = 1; nestedIndex lte dsBudgetSummary.RecordCount; nestedIndex = nestedIndex + 1)
			{
				if (MtdActuals["iSortOrder"][index] eq dsBudgetSummary["iSortOrder"][nestedIndex])
				{
					if (currentD lt currentDIM)
					{
						currentBudgetMtdDay = ((dsBudgetSummary["mAmount"][nestedIndex] / currentDIM) * currentD);
					}
					else
					{
						currentBudgetMtdDay = dsBudgetSummary["mAmount"][nestedIndex];
					}
					currentVarianceAmount = currentBudgetMtdDay - MtdActuals["mAmount"][index];
					if (varianceCounter eq 0)
					{
						currentVarianceAmount = (censusMtd * foodBudgetAccumulator) - MtdActuals["mAmount"][index];
					}
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & currentVarianceAmount; 
					break;
				}
			}
			varianceTotal = varianceTotal + currentVarianceAmount;
			varianceCounter = varianceCounter + 1;
			// Get the next letter in the alphabet.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		}
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
					"." & currentExcelRow & ":" & varianceTotal; 
	
		// only show MONTH (JAN, FEB, etc...) BUDGET & VARIANCE, if the current day is less than days in the month.
		if (currentD lt currentDIM)
		{
			currentExcelRow = 39;
		
			excelData = excelData & "|" & excelWorkSheet & ".A." & 
						currentExcelRow & ":" & UCase(monthForQueries) & " Budget"; 
	
			excelData = excelData & "|" & excelWorkSheet & ".B." & 
						currentExcelRow & ":" & censusBudgetDim; 
						
			censusDim = ((currentDIM - currentD) * (currentCensus)) + censusMtd;
	
			excelData = excelData & "|" & excelWorkSheet & ".C." & 
						currentExcelRow & ":" & censusDim; 
	
			budgetTotal = 0;
			currentExcelColumn = "E";
			for (index = 1; index lte dsBudgetSummary.RecordCount; index = index + 1)
			{
				if (index eq 1)
				{
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (censusDim * foodBudgetAccumulator); 
					budgetTotal = budgetTotal + (censusDim * foodBudgetAccumulator);
				}
				else
				{
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & dsBudgetSummary["mAmount"][index]; 
				 	budgetTotal = budgetTotal + dsBudgetSummary["mAmount"][index];
				}
				// Get the next letter in the alphabet.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			}
		
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
					"." & currentExcelRow & ":" & budgetTotal; 
		
						
								
			// MONTH Variance (example: FEB Variance))
			currentExcelRow = 40;
			
			excelData = excelData & "|" & excelWorkSheet & ".A." & 
						currentExcelRow & ":" & UCase(monthForQueries) & " Variance"; 
			
			excelData = excelData & "|" & excelWorkSheet & ".C." & 
						currentExcelRow & ":" & (censusDim - censusBudgetDim); 
				
			varianceTotal = 0;
			varianceCounter = 0;
			currentExcelColumn = "E";
			
			for (index = 1; index lte MtdDayActuals.RecordCount; index = index + 1)
			{	
				currentVarianceAmount = 0;
				for (nestedIndex = 1; nestedIndex lte dsBudgetSummary.RecordCount; nestedIndex = nestedIndex + 1)
				{
					if (MtdActuals["iSortOrder"][index] eq dsBudgetSummary["iSortOrder"][nestedIndex])
					{
						currentVarianceAmount = dsBudgetSummary["mAmount"][nestedIndex] - MtdActuals["mAmount"][index];
						if (varianceCounter eq 0)
						{
							currentVarianceAmount = (censusDim * foodBudgetAccumulator) - MtdActuals["mAmount"][index];
						}
						
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & currentVarianceAmount; 
							
						break;
					}
				}
				varianceTotal = varianceTotal + currentVarianceAmount;
				varianceCounter = varianceCounter + 1;
				// Get the next letter in the alphabet.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			}
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
						"." & currentExcelRow & ":" & varianceTotal; 

		}
		else
		{
			if (currentD lt 31)
			{
				for (index = (currentD + 1); index lte 31; index = index + 1)
				{
					// Delete the out of range row.		
					outOfRangeRow = index + 3;
					excelData = excelData & "|" & excelWorkSheet & ".!." & outOfRangeRow & ":0"; 
				}
			}
			// Delete the 3 footer rows.
			excelData = excelData & "|" & excelWorkSheet & ".!.38:0"; 
						excelData = excelData & "|" & excelWorkSheet & ".!.39:0"; 
						excelData = excelData & "|" & excelWorkSheet & ".!.40:0"; 
				
		}
		// Put the File Name together using the House Name and the current date and time.		
		destFileName = "SpendDown_" & houseName & "_";
		destFileName = destFileName & DateFormat(Now(),'M-D-YY') & "_";
		destFileName = destFileName & DatePart("h", Now());
		destFileName = destFileName & DatePart("n", Now());
		destFileName = destFileName & DatePart("s", Now());
		destFileName = destFileName & ".xls";
		destFilePath = "\\FS01.alcco.com\FTA\" & destFileName;
	}
	catch (Any appEx)
	{
		// Set is error to true.
		isError = true;
	}
</cfscript>
<cfif (isError eq true)>
	<cfoutput>
		ERROR: The Excel Data String was not fully built! <br />
	</cfoutput>
</cfif>
<!--- Try to Invoke the Excel Web Service to generate the Spend Down Spreadsheet. --->
<cftry>
	<cfinvoke webservice="http://maple.alcco.com/ExcelWebService/Service.asmx?WSDL" method="DataEntry" returnvariable="fileCreated">
		<cfinvokeargument name="iSourceFileName" value="ExpenseSpendDown.xls">
		<cfinvokeargument name="iData" value="#excelData#">
		<cfinvokeargument name="iDestinationFileName" value="#destFileName#">
	</cfinvoke>
<cfcatch type="any">
	<cfoutput>
		ERROR: The Web Service Failed! <br />
	</cfoutput>
	<cfset isError = true>
</cfcatch>
</cftry>


<cfif ((isError eq false) and (fileCreated eq true))>
	<cfoutput>
		<meta http-equiv='refresh' content='0;url=#destFilePath#' />
	</cfoutput>
	<!--- Download the file to the client and delete it off the Server. 
	<cfheader name="Content-Disposition" value="attachment; filename=#destFileName#" />
	<cfcontent type="application/msexcel"  file="#destFilePath#" deletefile="true" />
	--->
<cfelse>
	<cfoutput>
		There was a problem exporting the Expense Spend Down page to Excel.  
		Please contact the ALC Help Desk (888-342-4252) if the problem continues.
	</cfoutput>
</cfif>


