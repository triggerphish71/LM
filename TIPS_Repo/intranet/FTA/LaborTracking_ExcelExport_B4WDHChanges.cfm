<!----------------------------------------------------------------------------------------------
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 03/29/2009 | Developed Labor Tracking Excel Export Page.					                   |
----------------------------------------------------------------------------------------------->
<cfheader name='expires' value='#Now()#'> 
<cfheader name='pragma' value='no-cache'>
<cfheader name='cache-control' value='no-cache,no-store, must-revalidate'>

<cfinclude template="Common/DateToUse.cfm">
<cfscript>
	// Stores whether or not there was an error.
	isError = false;
	// Try to generate the string required to populate the Labor Tracking spreadsheet.
	//try
	//{
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
		excelWorkSheet = "Labor Tracking";
		// Assign the current period to the spreadsheet.
		excelData = excelWorkSheet & ".A.3:" & DateFormat(FromDate, 'M/D/YYYY');
		// Assign the House Name to cell G1.
		excelData = excelData & "|" & excelWorkSheet & 
					".K.1:" & houseName; 
		// ---------------------------------------------------------------------------------------------
		
		// Setup the Query variables. 
		dsLaborTrackingHours = helperObj.FetchLaborHours(houseId, PtoPFormat);
		dsLaborTrackingCategories = helperObj.FetchLaborTrackingCategories();
		dsCensusDetails = helperObj.FetchCensusDetails(houseId, FromDate, ThruDate);
		dsLaborVariableBudgets = helperObj.FetchLaborVariableBudgets(houseId, PtoPFormat);	
		dailyCensusBudget = helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries);
		dsTwoPersonAssists = helperObj.FetchTwoPersonAssists(houseId, FromDate, ThruDate);
		
		// Accumulates the MTD Training Budget. 
		trainingBudgetMtd = 0;
		// Census related variables.
		censusMtd = 0.0;
		occupancyMtd = 0.0;
		pointsMtd = 0.0;
		censusBudgetMtd = 0.0;
		twoPersonAssistsMtd = 0.0;
		// SHOW DETAILS - ALL DAYS UP TO THE CURRENT DAY OR THE END OF THE MONTH 
		for (currentDay = 1; currentDay lte currentD; currentDay = currentDay + 1)
		{
			// Set the current excel column to the "D", which is the first column to populate.
			currentExcelColumn = "B";
			// Fetch the labor data for the current day. 
			dsCurrentLaborTrackingData = helperObj.FetchLaborHoursForDay(dsLaborTrackingHours, currentDay);
			// Stores the current excel row in the loop.
			currentExcelRow = currentDay + 5;
			// Stores the Census for the current day.
			currentCensus = helperObj.FetchTenantsForDay(dsCensusDetails, currentDay);
			// Stores the Occupancy in Units for the current day.
			currentOccupancyUnits = helperObj.FetchOccupancyForDay(dsCensusDetails, currentDay);			
			// Accumulate the MTD Census.
			censusMtd = censusMtd + currentCensus;
			// Accumulate the MTD Occupancy.
			occupancyMtd = occupancyMtd + currentOccupancyUnits;
			// Accumulate the MTD Census Budget.
			censusBudgetMtd = censusBudgetMtd + dailyCensusBudget;
			// Stores the Service Points for the current day.
			currentPoints = helperObj.FetchPointsForDay(dsCensusDetails, currentDay);
			// Stores the number of two person assists for the current day.
			twoPersonAssists = helperObj.FetchTwoPersonAssistsForDay(dsTwoPersonAssists, currentDay);		
			// Update the total Two Person Assists MTD value.
			twoPersonAssistsMtd = twoPersonAssistsMtd + twoPersonAssists;	
			// Accumulates the MTD Service Points.
			pointsMtd = pointsMtd + currentPoints;
			// Stores the total number of hours worked for all Nursing categories, which includes reg, ot, and other.
			nursingTotalHours = 0;
			// Accumulates the current days budget for all Nursing Categories. 
			nursingBudgetTotalHours = 0;	
			// Stores the total number of hours for the current day.
			totalDailyHours = 0;
			// Stores te total budget hours for the current day. 
			totalDailyBudgetHours = 0;
			// Display the census column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & currentCensus; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			// Display the occupancy column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & currentOccupancyUnits; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			
			// Display the service points column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & currentPoints; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			// Display the 2-person assists column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & twoPersonAssists; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			
			// loop through labor categories.
			for (index = 1; index lte dsCurrentLaborTrackingData.RecordCount; index = index + 1)
			{
				// Set the Hours, Category, IsVisible, and IsTraining variables for the current Record.
				fRegular = dsCurrentLaborTrackingData["fRegular"][index];
				fOvertime = dsCurrentLaborTrackingData["fOvertime"][index];
				fOther = dsCurrentLaborTrackingData["fOther"][index];
				fAll = dsCurrentLaborTrackingData["fAll"][index];	
				fBudget = dsCurrentLaborTrackingData["fBudget"][index];			
				fVariableBudget = dsCurrentLaborTrackingData["fVariableBudget"][index];	
				cLaborTrackingCategory = dsCurrentLaborTrackingData["cLaborTrackingCategory"][index];
				bIsVisible = dsCurrentLaborTrackingData["bIsVisible"][index];
				bIsTraining = dsCurrentLaborTrackingData["bIsTraining"][index];
				// Check if the current column should be displayed. 
				if (bIsVisible eq true)
				{
					// Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total.
					if ((cLaborTrackingCategory is "Resident Care") or 
					(cLaborTrackingCategory is "Nurse Consultant") or 
					(cLaborTrackingCategory is "LPN - LVN"))	
					{
						// Add the current category's budget total. 
						nursingBudgetTotalHours = (nursingBudgetTotalHours + fVariableBudget);
						// Add the current category's hours to the nursing daily total. 
						nursingTotalHours = (nursingTotalHours + fRegular + fOvertime + fOther);
						// Add the current category's hours to the daily total. --->
						totalDailyHours = (totalDailyHours + fRegular + fOvertime + fOther);
						// Add the current category's budget hours to the daily total.
						totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
						// Display the Reg column for Nursing. 
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fRegular;	
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						// Display the Reg column for Nursing. 
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fOvertime; 							
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						// Display the Reg column for Nursing. 
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fOther; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					}
					// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is.
					else if (cLaborTrackingCategory is "Kitchen")
					{
						// Calculate the Nursing Sub-Total's variance.
						nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
						// Add the current category's hours to the daily total.
						totalDailyHours = (totalDailyHours + fRegular + fOvertime);
						// Add the current category's budget hours to the daily total.
						totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
						// Display the Nursing Total Hours Sub-Total.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & nursingTotalHours; 				
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						// Display the Nursing Budget Sub-Total.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & nursingBudgetTotalHours; 	
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						// Display the Nursing Total Hours Sub-Total.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & nursingDailyVariance; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Display the Kitchen Regular Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fRegular; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Display the Kitchen OT Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fOvertime; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Display the Total Kitchen Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & (fRegular + fOvertime); 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						// Display the Kitchen Variable Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fVariableBudget; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Display the Kitchen Variance Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}																						
					// Check if the labor category is PTO and do not add the budget and variance cols.
					else if (cLaborTrackingCategory is "PTO")
					{
						// Display the PTO Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fAll; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}				
					else
					{
						// Add the current category's hours to the daily total.
						totalDailyHours = (totalDailyHours + fAll);
						// Add the current category's variable budget hours to the daily total.
						totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);								
						// Display the non-Nursing Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fAll; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
						// Display the non-Nursing Variable Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fVariableBudget; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Display the non-Nursing Variance Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & (fVariableBudget - fAll); 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						// Check if the current column is a Training Column.
						if (bIsTraining eq true)
						{
							// Display the TOTAL Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
										"." & currentExcelRow & ":" & totalDailyHours; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the TOTAL Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
										"." & currentExcelRow & ":" & totalDailyBudgetHours; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);																				
							// Get the Day's Variance.
							currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
							// Display the Day's Variance.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
										"." & currentExcelRow & ":" & currentDaysVariance; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
						}
					}
				}
			}
		}
		// ------------------------- MTD ACTUAL HOURS - TOTALS -------------------------
		// Fetch the labor data totals for the current month.
		dsTotalLaborTrackingData = helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours);
		// Stores the total number of hours worked for all Nursing categories, which includes Regular, Overtime, and Other.
		nursingMtdTotalHours = 0;
		// Stores the total number of hours for the current mtd. 
		totalMtdHours = 0;
		// Stores te total budget hours for the current mtd.
		totalMtdBudgetHours = 0;
		// Stores the current excel row, which is row 37.
		currentExcelRow = 37;	
		// Set the current excel column to "B", which is the first column to populate.
		currentExcelColumn = "B";
		// Display the MTD Census column.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & censusMtd; 
		// Increment the column by 1 letter.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		// Display the MTD Occupancy column.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & occupancyMtd; 
		// Increment the column by 1 letter.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
		// Display the MTD Service Points column.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & pointsMtd; 
		// Increment the column by 1 letter.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		// Display the MTD two person assists column.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & twoPersonAssistsMtd; 
		// Clear some variables.
		nursingBudgetTotalHours = 0.0;
		nursingTotalHours = 0.0;
		totalDailyHours = 0.0;
		totalDailyBudgetHours = 0.0;					
		// Increment the column by 1 letter.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
		// Loop through Mtd labor categories.
		for (index = 1; index lte dsTotalLaborTrackingData.RecordCount; index = index + 1)
		{
			// Set the Hours, Category, IsVisible, and IsTraining variables for the current Record.
			fRegular = dsTotalLaborTrackingData["fRegular"][index];
			fOvertime = dsTotalLaborTrackingData["fOvertime"][index];
			fOther = dsTotalLaborTrackingData["fOther"][index];
			fAll = dsTotalLaborTrackingData["fAll"][index];	
			fBudget = dsTotalLaborTrackingData["fBudget"][index];			
			fVariableBudget = dsTotalLaborTrackingData["fVariableBudget"][index];	
			cLaborTrackingCategory = dsTotalLaborTrackingData["cLaborTrackingCategory"][index];
			bIsVisible = dsTotalLaborTrackingData["bIsVisible"][index];
			bIsTraining = dsTotalLaborTrackingData["bIsTraining"][index];
			// Check if the current column should be displayed. 
			if (bIsVisible eq true)
			{
				// Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total.
				if ((cLaborTrackingCategory is "Resident Care") or 
				(cLaborTrackingCategory is "Nurse Consultant") or 
				(cLaborTrackingCategory is "LPN - LVN"))	
				{
					// Add the current category's budget total. 
					nursingBudgetTotalHours = (nursingBudgetTotalHours + fVariableBudget);
					// Add the current category's hours to the nursing daily total. 
					nursingTotalHours = (nursingTotalHours + fRegular + fOvertime + fOther);
					// Add the current category's hours to the daily total. --->
					totalDailyHours = (totalDailyHours + fRegular + fOvertime + fOther);
					// Add the current category's budget hours to the daily total.
					totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
					// Display the Reg column for Nursing. 
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fRegular;	
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					// Display the Reg column for Nursing. 
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fOvertime; 							
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					// Display the Reg column for Nursing. 
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fOther; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				}
				// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is.
				else if (cLaborTrackingCategory is "Kitchen")
				{
					// Calculate the Nursing Sub-Total's variance.
					nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
					// Add the current category's hours to the daily total.
					totalDailyHours = (totalDailyHours + fRegular + fOvertime);
					// Add the current category's budget hours to the daily total.
					totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
					// Display the Nursing Total Hours Sub-Total.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & nursingTotalHours; 				
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
					// Display the Nursing Budget Sub-Total.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & nursingBudgetTotalHours; 	
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					// Display the Nursing Total Hours Sub-Total.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & nursingDailyVariance; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					// Display the Kitchen Regular Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fRegular; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					// Display the Kitchen OT Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fOvertime; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					// Display the Total Kitchen Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (fRegular + fOvertime); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					// Display the Kitchen Variable Budget Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fVariableBudget; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					// Display the Kitchen Variance Budget Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
				}																						
				// Check if the labor category is PTO and do not add the budget and variance cols.
				else if (cLaborTrackingCategory is "PTO")
				{
					// Display the PTO Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fAll; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
				}				
				else
				{
					// Add the current category's hours to the daily total.
					totalDailyHours = (totalDailyHours + fAll);
					// Add the current category's variable budget hours to the daily total.
					totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);								
					// Display the non-Nursing Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fAll; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
					// Display the non-Nursing Variable Budget Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fVariableBudget; 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					// Display the non-Nursing Variance Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (fVariableBudget - fAll); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					// Check if the current column is a Training Column.
					if (bIsTraining eq true)
					{
						// Display the TOTAL Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & totalDailyHours; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						// Display the TOTAL Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & totalDailyBudgetHours; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);													
						// Get the Day's Variance.
						currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
						// Display the Day's Variance.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & currentDaysVariance; 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
					}
				}
			}
		}
		
		/**
		// ------------------------- MTD BUDGET TOTALS -------------------------
		// Fetch the labor data totals for the current month.
		dsTotalLaborTrackingData = helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours);
		// Accumulates the current mtd's budget for all Nursing Categories.
		nursingBudgetMtdTotalHours = 0;
		// Stores te total budget hours for the current mtd.
		totalMtdBudgetHours = 0;
		// Stores the current excel row, which is row 38.
		currentExcelRow = 38;	
		// Set the current excel column to "B", which is the first column to populate.
		currentExcelColumn = "B";
		// Display the MTD Census Budget column.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & censusBudgetMtd; 
		// Increment the column by 1 letter.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		// Increment the column by 1 more letter, because the service points does NOT have a budget.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
		// Increment the column by 1 letter, because the 2-person assists does NOT have a budget.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			
		// Loop through Mtd labor categories.
		for (index = 1; index lte dsTotalLaborTrackingData.RecordCount; index = index + 1)
		{
			// Set the Hours, Category, IsVisible, and IsTraining variables for the current MTD Record.
			fRegular = dsTotalLaborTrackingData["fRegular"][index];
			fOvertime = dsTotalLaborTrackingData["fOvertime"][index];
			fOther = dsTotalLaborTrackingData["fOther"][index];
			fAll = dsTotalLaborTrackingData["fAll"][index];	
			fBudget = dsTotalLaborTrackingData["fBudget"][index];			
			cLaborTrackingCategory = dsTotalLaborTrackingData["cLaborTrackingCategory"][index];
			bIsVisible = dsTotalLaborTrackingData["bIsVisible"][index];
			bIsTraining = dsTotalLaborTrackingData["bIsTraining"][index];
	
			// Check if the current column should be displayed. 
			if (bIsVisible eq true)
			{
				// Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total.
				if ((cLaborTrackingCategory is "Resident Care") or 
				(cLaborTrackingCategory is "Nurse Consultant") or 
				(cLaborTrackingCategory is "LPN - LVN"))
				{
					// Add the current category's budget total.
					nursingBudgetMtdTotalHours = nursingBudgetMtdTotalHours + fBudget;
				
					// Add the current category's budget hours to the mtd total.
					totalMtdBudgetHours = (totalMtdBudgetHours + fBudget);
					
					// Display the Reg Budget column.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fBudget; 			
					// Increment the column by 3 letters to get to the next category.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				}
				// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
				else if (cLaborTrackingCategory is "Kitchen")
				{
					// Add the current category's budget hours to the mtd total.
					totalMtdBudgetHours = (totalMtdBudgetHours + fBudget);							
					
					// Display the Nursing Budget Sub-Total.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & nursingBudgetMtdTotalHours; 			
					// Increment the column by 3 letters to get to the next category.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	

					// Display the Kitchen Budget Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & fBudget; 			
					// Increment the column by 2 letters to get to the next category.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				}
				else
				{
					if (bIsTraining eq true)
					{
						// Add the current category's budget hours to the mtd total.
						totalMtdBudgetHours = (totalMtdBudgetHours + trainingBudgetMtd);	
					
						// Display the Training Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & trainingBudgetMtd; 			
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						
						// Display the TOTAL Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & totalMtdBudgetHours; 	
									
						// Leave the LOOP.
						break;
					}
					else
					{
						// Display the Non-Nursing Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & fBudget; 			
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Add the current category's budget hours to the daily total.
						totalMtdBudgetHours = (totalMtdBudgetHours + fBudget);		
					}
				}
			}
		}	
		
		//------------------------- MTD VARIANCE TOTALS (BUDGET - ACTUAL) -------------------------
		// Fetch the labor data totals for the current month.
		dsTotalLaborTrackingData = helperObj.FetchLaborHoursForMTD(dsLaborTrackingHours);
		// Stores the total accumulated variance for Nursing.
		nursingMtdVariance = 0;
		// Stores the total accumulated variance for all of the visible categories.
		totalMtdVariance = 0;
		// Stores the current excel row, which is row 39.
		currentExcelRow = 39;	
		// Set the current excel column to "B", which is the first column to populate.
		currentExcelColumn = "B";
		// Display the MTD Census/Budget Variance column.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & censusMtd - censusBudgetMtd; 
		// Increment the column by 1 letter.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		// Increment the column by 1 more letter, because the service points does NOT have a budget, which means NO variance.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
		// Increment the column by 1 letter, because the 2-person assists does NOT have a budget, which means NO variance.
		currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			
		// Loop through Mtd labor categories.
		for (index = 1; index lte dsTotalLaborTrackingData.RecordCount; index = index + 1)
		{
			// Set the Hours, Category, IsVisible, and IsTraining variables for the current MTD Record.
			fRegular = dsTotalLaborTrackingData["fRegular"][index];
			fOvertime = dsTotalLaborTrackingData["fOvertime"][index];
			fOther = dsTotalLaborTrackingData["fOther"][index];
			fAll = dsTotalLaborTrackingData["fAll"][index];	
			fBudget = dsTotalLaborTrackingData["fBudget"][index];			
			cLaborTrackingCategory = dsTotalLaborTrackingData["cLaborTrackingCategory"][index];
			bIsVisible = dsTotalLaborTrackingData["bIsVisible"][index];
			bIsTraining = dsTotalLaborTrackingData["bIsTraining"][index];
	
			// Check if the current column should be displayed. 
			if (bIsVisible eq true)
			{
				// Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total.
				if ((cLaborTrackingCategory is "Resident Care") or 
				(cLaborTrackingCategory is "Nurse Consultant") or 
				(cLaborTrackingCategory is "LPN - LVN"))
				{
								
					// Display the Nursing Category's Regular Hour's Variance.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (fBudget - fRegular); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);							
					
					// Add to the variance accumulators (Total Nursing and Total)
					nursingMtdVariance = (nursingMtdVariance + (fBudget - fRegular));
					totalMtdVariance = (totalMtdVariance + (fBudget - fRegular));
					
					// Display the Nursing Category's OT Hour's Variance.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (-fOvertime); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					
					// Add to the variance accumulators (Total Nursing and Total) --->
					nursingMtdVariance = (nursingMtdVariance - fOvertime);
					totalMtdVariance = (totalMtdVariance - fOvertime);
					
					// Display the Nursing Category's Other Hour's Variance.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (-fOther); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
					// Add to the variance accumulators (Total Nursing and Total).
					nursingMtdVariance = (nursingMtdVariance - fOther);
					totalMtdVariance = (totalMtdVariance - fOther);			
				}
				// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is.
				else if (cLaborTrackingCategory is "Kitchen")
				{
					// Increment the column by 2 letters to get to the Variance column in the Nursing Sub-Totals Category.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);							
					// Display the Nursing Variance Sub-Total.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (nursingMtdVariance); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
					
					// Display the Kitchen's Reg Variance Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (fBudget - fRegular); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
									
											
					// Add to the variance accumulators (Total)
					totalMtdVariance = (totalMtdVariance + (fBudget - fRegular));		
					// Display the Kitchen's OT Variance Hours.
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
								"." & currentExcelRow & ":" & (-fOvertime); 			
					// Increment the column by 1 letter.
					currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
							
					// Add to the variance accumulators (Total)
					totalMtdVariance = (totalMtdVariance - fOvertime);		
	
				}
				else
				{
					if (bIsTraining eq true)
					{
						// Display the Training Hours Variance.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & (trainingBudgetMtd - fAll); 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						// Add to the variance accumulators (Total)
						totalMtdVariance = (totalMtdVariance + (trainingBudgetMtd - fAll));

						// Display the TOTAL Variance Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & (totalMtdVariance); 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						// Leave.
						break;
		
					}
					else
					{

						// Display the Non-Nursing Variance Hours. 
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
									"." & currentExcelRow & ":" & (fBudget - fAll); 			
						// Increment the column by 1 letter.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						// Add to the variance accumulators (Total)
						totalMtdVariance = (totalMtdVariance + (fBudget - fAll));
					}
				}
			}
		}
		*/
		// ------------------------- MTD VARIABLE BUDGET TOTALS -------------------------
		// Stores the current excel row, which is row 40.
		currentExcelRow = 38;	
		// Set the current excel column to "E", which is the first column to populate.
		currentExcelColumn = "F";
		// Stores the accumulated variable budget total, which is displayed last.
		variableBudgetTotal = 0.0;
		// Stores the accumulated nursing variable budget total.
		nursingVariableBudgetTotal = 0.0;			
		// Loop through Mtd labor categories.
		for (index = 1; index lte dsLaborVariableBudgets.RecordCount; index = index + 1)
		{
			// Set the Hours, Category, IsVisible, and IsTraining variables for the current MTD Record.
			fVariableBudget = dsLaborVariableBudgets["fVariableBudget"][index];			
			cLaborTrackingCategory = dsLaborVariableBudgets["cLaborTrackingCategory"][index];

			// Accumulate the variable budget total.
			variableBudgetTotal = variableBudgetTotal + fVariableBudget;
				
				// Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total.
			if ((cLaborTrackingCategory is "Resident Care") or 
				(cLaborTrackingCategory is "Nurse Consultant") or 
				(cLaborTrackingCategory is "LPN - LVN"))
			{
				// Accumulate the current category's budget total.
				nursingVariableBudgetTotal = nursingVariableBudgetTotal + fVariableBudget;
				// Display the Reg Variable Budget column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & fVariableBudget; 			
				// Increment the column by 3 letters to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
			}
			// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
			else if (cLaborTrackingCategory is "Kitchen")
			{
				// Display the Nursing Variable Budget Sub-Total.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & nursingVariableBudgetTotal; 			
				// Increment the column by 2 letters to get to the next category.	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
				// Display the Kitchen Budget Hours.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & fVariableBudget; 			
				// Increment the column by 2 letters to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);				
			}
			else
			{
				// Display the Non-Nursing Hours.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & fVariableBudget; 			
				// Increment the column by 1 letter to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);								
			}
		}			
		// Display the total variable budget Hours.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
					"." & currentExcelRow & ":" & variableBudgetTotal; 			
					
					
		// ------------------------- MTD VARIABLE BUDGET VARIANCE -------------------------
		// Fetch the Variable Budgets with the associated actuals.
		dsVariableBudgetsWithActual = helperObj.FetchLaborVariableBudgetsWithActual(dsLaborVariableBudgets, dsTotalLaborTrackingData);
		// Stores the current excel row, which is row 41.
		currentExcelRow = 39;	
		// Set the current excel column to "D", which is the first column to populate.
		currentExcelColumn = "F";
		// Stores the accumulated variable budget variance total.
		variableBudgetVarianceTotal = 0.0;	
		// Loop through Mtd labor categories.
		for (index = 1; index lte dsVariableBudgetsWithActual.RecordCount; index = index + 1)
		{
			// Set the Hours, Category, and Budget variables for the current MTD Record.
			fRegular = dsVariableBudgetsWithActual["fRegular"][index];
			fOvertime = dsVariableBudgetsWithActual["fOvertime"][index];
			fOther = dsVariableBudgetsWithActual["fOther"][index];
			fAll = dsVariableBudgetsWithActual["fAll"][index];	
			fVariableBudget = dsVariableBudgetsWithActual["fVariableBudget"][index];			
			cLaborTrackingCategory = dsVariableBudgetsWithActual["cLaborTrackingCategory"][index];
			
			// Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total.
			if ((cLaborTrackingCategory is "Resident Care") or 
				(cLaborTrackingCategory is "Nurse Consultant") or 
				(cLaborTrackingCategory is "LPN - LVN"))
			{
				// Accumulate the variable budget variance total using the current category.
				variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOverTime + fOther));
			
				// Display the Reg Variable Budget Variance column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & (fVariableBudget - fRegular); 			
				// Increment the column by 1 letter to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				
				// Display the OT Variable Budget Variance column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & (-fOvertime); 			
				// Increment the column by 1 letter to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				
				// Display the Other Variable Budget Variance column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & (-fOther); 			
				// Increment the column by 1 letter to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
			}
			// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
			else if (cLaborTrackingCategory is "Kitchen")
			{	
				// Display the Nursing Variable Budget Variance Sub-Total.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & variableBudgetVarianceTotal; 			
				// Increment the column by 3 letters to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
	
				// Skip the first 2 kitchen cols.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
				// Update the Variable Budget Variance Total. 
				variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOvertime));						
						
				// Display the Kitchen Reg Variable Budget Variance column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
				// Increment the column by 1 letter to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
			}
			else
			{
				// Update the Variable Budget Variance Total. 
				variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - fAll);				
				// Display the Non-Nursing Hours.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
							"." & currentExcelRow & ":" & (fVariableBudget - fAll);					
				// Increment the column by 1 letter to get to the next category.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
			}
		}			
		// Display the total variable budget variance Hours.
		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & 
					"." & currentExcelRow & ":" & variableBudgetVarianceTotal; 			
										
						
		// Check if the current day is less than 31, which would mean that the less days need to be deleted from the spreadsheet.
		if (currentD lt 31)
		{
			// Loop through the days that need to be deleted.
			for (index = (currentD + 1); index lte 31; index = index + 1)
			{
				// Set the Excel Spreadsheet's Row Number to Delete.
				outOfRangeRow = index + 5;
				// Delete the out of range row.
				excelData = excelData & "|" & excelWorkSheet & ".!." & outOfRangeRow & ":0"; 
			}
		}
		// Put the File Name together using the House Name and the current date and time.
		destFileName = "LaborTracking_" & houseName & "_";
		destFileName = destFileName & DateFormat(Now(),'M-D-YY') & "_";
		destFileName = destFileName & DatePart("h", Now());
		destFileName = destFileName & DatePart("n", Now());
		destFileName = destFileName & DatePart("s", Now());
		destFileName = destFileName & ".xls";
		destFilePath = "\\FS01.alcco.com\FTA\" & destFileName;
	//}
	//catch (Any appEx)
	//{
	 	// Turn ON the Error indicator switch (ON = TRUE).
		//isError = true;
	//}
</cfscript>
<cfif (isError eq true)>
	<cfoutput>
		- The Excel Data String was not fully built. <br />
	</cfoutput>
</cfif>
<!--- Try to Invoke the Excel Web Service to generate the Labor Tracking Spreadsheet. --->
<cftry>
	<cfinvoke webservice="http://Maple.alcco.com/ExcelWebService/Service.asmx?WSDL" method="DataEntry" returnvariable="fileCreated">
		<cfinvokeargument name="iSourceFileName" value="LaborTracking.xls">
		<cfinvokeargument name="iData" value="#excelData#">
		<cfinvokeargument name="iDestinationFileName" value="#destFileName#">
	</cfinvoke>
<cfcatch>
	<cfoutput>
		- The Web Service Failed! <br />
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
		There was a problem exporting the Labor Tracking page to Excel.  
		Please contact the ALC Help Desk (888-342-4252) if the problem continues.
	</cfoutput>
</cfif>

