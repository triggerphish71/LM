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
		
		if (isDefined("url.ccllcHouse")) {
			ccllcHouse = url.ccllcHouse;	}
		else {
			ccllcHouse = 0;		}

		if (isDefined("url.Division_ID")) {
			DivisionId = url.Division_ID;	}
					
		if (isDefined("url.Region_ID")) {
			RegionId = url.Region_ID;	}

		if (isDefined("url.rollup")) {
			rollup = url.rollup;	}
		else {
			rollup = 0;		}

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

		// Begin creating the Excel Data Entry String.
		excelWorkSheet = "Labor Tracking";
		
		if (ccllcHouse is 0)
		{
			if (rollup is 0) {
				// Assign the current period to the spreadsheet.
				excelData = excelWorkSheet & ".A.3:" & DateFormat(FromDate, 'M/D/YYYY');
				// Instantiate the house info.
				houseInfo = helperObj.FetchHouseInfo(subAccount);
				houseId = houseInfo["ihouse_id"][1];
				houseName = houseInfo["cName"][1];
				// Assign the House Name to cell G1.
				excelData = excelData & "|" & excelWorkSheet & ".P.1:" & houseName; 
			} else if (rollup is 3) {
				// Assign the current period to the spreadsheet.
				excelData = excelWorkSheet & ".A.3:" & "Houses";
				regionInfo = helperObj.FetchRegionInfo(RegionId);
				name = regionInfo["Region"][1];
				name = name & " Region";
			} else if (rollup is 2) {
				// Assign the current period to the spreadsheet.
				excelData = excelWorkSheet & ".A.3:" & "Regions";
				divisioninfo = helperObj.FetchDivisionInfo(DivisionId);
				name = divisionInfo["Division"][1];
				name = name & " Division";
			} else { 
				// Assign the current period to the spreadsheet.
				excelData = excelWorkSheet & ".A.3:" & "Divisions";
				name = "ALC Consolidated"; 
			}
			
			if (rollup is not 0) {	excelData = excelData & "|" & excelWorkSheet & ".A.5:" & "As of " & DateFormat(ThruDate, "mmmm dd, yyyy");	}
			
			if(ihouse_id is 0 || ihouse_id is ""){
			     excelData = excelData & "|" & excelWorkSheet & ".P.1:" & name; 	
			  }else{ 
			   excelData = excelData & "|" & excelWorkSheet & ".P.1:" & housename;
			  }
			 						
		}
		else
		{
		excelData = excelData & "|" & excelWorkSheet & ".H.1:" & "CCLLC - " & houseName; 
		}					
		// ---------------------------------------------------------------------------------------------
		loop = 0;
		wdh = 0;
		open = 0;
		conflict = 0;
		WDStermed = 0;
		samePeriod = 0;
		currPeriod = 0;
		totalvarbgt = 0;
		totalvariance = 0;
		conditionalTrue = 0;
		conditionalFalse = 0;
		isCCLLCHouse = 0;
		isCCLLC = 0;
		kitchenTrngVarBgt = 0;
		totalKitchenTrngVarBgt = 0;
		ccllcSalEmp = 0;
		sunday = 0;
		totalRegular = 0;
		totalActual = 0;
		totalVariance = 0;

		WDSActual = 0;
		WDSVarBgt = 0;
		WDSTotalVariance = 0;
		WDHVarBgt = 0;
		WDHVariance = 0;
		TotalActualHours = 0;
		TotalBudgetHours = 0;
		TotalVariance = 0;
		NursingActualHours = 0;
		NursingBudgetHours = 0;
		NursingVariance = 0;
		NursingVarBgtDesc = "";		
		totalTenants = 0;
		totalOccupants = 0;


		
		if (rollup is 0) 
		{			
			dsCCLLCHouses = helperObj.FetchCCLLCHouses(houseId);
			if (dsCCLLCHouses.recordcount neq 0)
			{	
				if (ccllcHouse is 1) {	isCCLLCHouse = 1;	}
				else{ isCCLLCHouse = 0; 	}
	
				isCCLLC = 1;
			}
			else
			{ 
				isCCLLCHouse = 0; 	
				isCCLLC = 0;
			} 
	
	
			dsLaborTrackingWDSInfo = helperObj.FetchLaborTrackingWDSDaily(houseId, DateFormat(now()-1, "mm/dd/yyyy"),PtoPFormat, rollup);
			dsHousesWithWDHAndWDS = helperObj.FetchHousesWithWDHAndWDS(houseId, PtoPFormat);
	
			if (dsHousesWithWDHAndWDS.recordcount neq 0)
			{	 conflict = 1; }
			else 
			{	conflict = 0; }
				
			if (dsLaborTrackingWDSInfo.dTermDate neq "" and (dsLaborTrackingWDSInfo.dTermDate gte dsLaborTrackingWDSInfo.StartDate and dsLaborTrackingWDSInfo.dTermDate lt dsLaborTrackingWDSInfo.EndDate))
			{
				WDStermed = 1;  
				samePeriod = 1; 
			}
			else if (dsLaborTrackingWDSInfo.dTermDate neq "" and (dsLaborTrackingWDSInfo.dTermDate lte dsLaborTrackingWDSInfo.StartDate and dsLaborTrackingWDSInfo.dTermDate lt dsLaborTrackingWDSInfo.EndDate))
			{
				WDStermed = 1; 
				samePeriod = 0;
			}
			else if (dsLaborTrackingWDSInfo.nStatus is "L" and dsLaborTrackingWDSInfo.dTermDate is "" and (dsLaborTrackingWDSInfo.dDateCreated gte dsLaborTrackingWDSInfo.StartDate and dsLaborTrackingWDSInfo.dTermDate lte dsLaborTrackingWDSInfo.EndDate))
			{
				WDStermed = 1;  
				samePeriod = 1; 
			}
			else{	WDStermed = 0;	}
			
			dsWDSHouses = helperObj.FetchWDSHouses(houseId);
			dsOpenWD = helperObj.FetchHouseWithOpenWDPosition(houseId, PtoPFormat);
			if (dsOpenWD.recordcount neq 0)
			{	open = 1;	}
			else 
			{	open = 0;	
				if (dsWDSHouses.recordcount neq 0)
				{	wds = 1;	}
				else
				{	wds = 0;	}
			}
			
			if (DateFormat(dsLaborTrackingWDSInfo.dHireDate, "yyyymm") eq PtoPFormat)
			{	currPeriod = 1;		}
			else
			{	currPeriod = 0;		}
				
			dsHousesWithWD = helperObj.FetchHousesWithWD(houseId, PtoPFormat);
			if (dsHousesWithWD.recordcount neq 0) 
			{
				if (dsHousesWithWD.ActiveWDH eq 1 and dsHousesWithWD.ActiveWDS eq 0)
				{	WDStermed = 1; 
					samePeriod = 1;		}
				else if (dsHousesWithWD.ActiveWDH eq 0 and dsHousesWithWD.ActiveWDS eq 1)
				{	WDStermed = 0; 
					samePeriod = 1;		}
				else if ((dsHousesWithWD.ActiveWDS eq 1 and dsHousesWithWD.nStatus eq "L") and ActiveWDH eq 0)
				{	WDStermed = 1; 
					samePeriod = 1;		}
				else if (dsHousesWithWD.ActiveWDH eq 1 and dsHousesWithWD.ActiveWDS eq 1)
				{	WDStermed = 0; 
					conflict =1; 
					samePeriod = 1;		}
				else
				{	conflict = 0; 
					open = 1;	
					samePeriod = 1;		}
	
				if (dsHousesWithWD.ActiveWDH is 1 and dsHousesWithWD.ActiveWDS is 0)
				{	wdh = 1;	}
				else if (dsHousesWithWD.ActiveWDH is 0 and dsHousesWithWD.ActiveWDS is 1)
				{	wdh = 0;	}
			}
			else 
			{
				dsWDH = helperObj.FetchWDHHouses(houseId, PtoPFormat);
				if (dsWDH.recordcount neq 0) 
				{	wdh = 1;	}
				else
				{	wdh = 0;	}		
			}
		}

		dsLaborTrackingCategories = helperObj.FetchLaborTrackingCategories();

		if (rollup is 0)
		{
			// Setup the Query variables. 
			dsLaborTrackingHours = helperObj.FetchLaborHours(houseId, PtoPFormat);
			dsCensusDetails = helperObj.FetchCensusDetails(houseId, FromDate, ThruDate);
			dsLaborVariableBudgets = helperObj.FetchLaborVariableBudgets(houseId, PtoPFormat);	
			dailyCensusBudget = helperObj.FetchDailyCensusBudget(houseId, currenty, monthforqueries);
			dsTwoPersonAssists = helperObj.FetchTwoPersonAssists(houseId, FromDate, ThruDate);
		}
		
	
		if (rollup is 3)	{
			dsCensusDetails =  helperObj.FetchDashboardRollupOccupancyDetails(RegionId, PtoPFormat, FromDate, ThruDate,rollup);
			//helperObj.FetchAverageDailyCensusDetailsRollup(RegionID, FromDate, ThruDate,monthforqueries);
		}
		else if (rollup is 2)	{
			dsCensusDetails =helperObj.FetchAverageDailyCensusDetailsDivisionalRollup(DivisionID, FromDate, ThruDate,monthforqueries, true);
		}
		else if (rollup is 1)	{
			dsCensusDetails = helperObj.FetchAverageDailyCensusDetailsConsolidatedRollup(FromDate, ThruDate,monthforqueries);
		}
	
		//create variable for total bursing variance.
		totalNursingDailyVariance = 0.0;
		
		// Accumulates the MTD Training Budget. 
		trainingBudgetMtd = 0;
		// Census related variables.
		censusMtd = 0.0;
		occupancyMtd = 0.0;
		pointsMtd = 0.0;
		censusBudgetMtd = 0.0;
		twoPersonAssistsMtd = 0.0;
		

		if (rollup neq 0)
		{
			for (censusIndex = 1; censusIndex lte dsCensusDetails.RecordCount; censusIndex = censusIndex + 1)
			{
				// Set the current excel column to the "D", which is the first column to populate.
				currentExcelColumn = "A";
				// Stores the current excel row in the loop.
				currentExcelRow = censusIndex + 5;

				cName = dsCensusDetails["cName"][censusIndex];
				fTenants = dsCensusDetails["fTenants"][censusIndex];
				fOccupancy = dsCensusDetails["fOccupancy"][censusIndex];
				fPoints = dsCensusDetails["fPoints"][censusIndex];
				iTwoPersonAssists = dsCensusDetails["iTwoPersonAssists"][censusIndex];


				// Display the rollup name.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & cName; 
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				
				if (rollup is 2)	{
					//dsRegionalCensusDetails = helperObj.FetchAverageDailyCensusDetailsRollup(dsCensusDetails.iOPSArea_ID, FromDate, ThruDate,monthforqueries);
					dsRegionalCensusDetails = helperObj.FetchAverageDailyCensusDetailsRollup(dsCensusDetails["iOPSArea_ID"][censusIndex], FromDate, ThruDate,monthforqueries);
					dsTenantCensus = helperObj.FetchAverageMTDCensusDetailsRollup(dsRegionalCensusDetails, 3, false);
				}
				
				// Display the census column.
				if (rollup is 2) 	{
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsTenantCensus.TotalTenants; 
					totalTenants = totalTenants + dsTenantCensus.TotalTenants;
				}
				else	{	
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fTenants; 
				}				
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);

				// Display the occupancy column.
				if (rollup is 2) 	{
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsTenantCensus.TotalOccupancy; 
					totalOccupants = totalOccupants + dsTenantCensus.TotalOccupancy;
				}
				else	{	
					excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOccupancy; 
				}				
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					
				// Display the service points column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fPoints; 
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				// Display the 2-person assists column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & iTwoPersonAssists; 
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			

				if (rollup is 3)	{
					totalDailyHours = 0;
					totalDailyBudgetHours = 0;
					nursingTotalHours = 0;
					nursingBudgetTotalHours = 0;
					dsLaborTrackingHours = helperObj.FetchLaborHoursRollup(dsCensusDetails.iHouse_ID[censusIndex], PtoPFormat, 3, true);
				}
				else if (rollup is 2)	{
					totalDailyHours = 0;
					totalDailyBudgetHours = 0;
					nursingTotalHours = 0;
					nursingBudgetTotalHours = 0;
					dsLaborTrackingHours = helperObj.FetchLaborHoursRollup(dsCensusDetails.iOPSArea_ID[censusIndex], PtoPFormat, 1, true);
				}
				else if (rollup is 1)	{
					totalDailyHours = 0;
					totalDailyBudgetHours = 0;
					nursingTotalHours = 0;
					nursingBudgetTotalHours = 0;
					dsLaborTrackingHours = helperObj.FetchLaborHoursRollup(dsCensusDetails.iRegion_ID[censusIndex], PtoPFormat, 2, true);
				}

				// loop through labor categories.
				for (index = 1; index lte dsLaborTrackingHours.RecordCount; index = index + 1)
				{
					// Set the Hours, Category, IsVisible, and IsTraining variables for the current Record.
					fRegular = dsLaborTrackingHours["fRegular"][index];
					fOvertime = dsLaborTrackingHours["fOvertime"][index];
					fOther = dsLaborTrackingHours["fOther"][index];
					fAll = dsLaborTrackingHours["fAll"][index];	
					fBudget = dsLaborTrackingHours["fBudget"][index];			
					fVariableBudget = dsLaborTrackingHours["fVariableBudget"][index];	
					cLaborTrackingCategory = dsLaborTrackingHours["cLaborTrackingCategory"][index];
					bIsVisible = dsLaborTrackingHours["bIsVisible"][index];
					bIsTraining = dsLaborTrackingHours["bIsTraining"][index];

					if (cLaborTrackingCategory is not "Kitchen Training")
					{
						if (bIsVisible eq true)
						{
							if (rollup is 3)	{
								dsLaborTrackingWDSInfo = helperObj.FetchLaborTrackingWDSDaily(dsCensusDetails.iHouse_ID, DateFormat(ThruDate, "mm/dd/yyyy"),PtoPFormat,rollup);
							}
							else if (rollup is 2)	{
								dsLaborTrackingWDSInfo = helperObj.FetchLaborTrackingWDSDaily(dsCensusDetails.iOPSArea_ID, DateFormat(ThruDate, "mm/dd/yyyy"),PtoPFormat,rollup);
							}
							else if (rollup is 1)	{
								dsLaborTrackingWDSInfo = helperObj.FetchLaborTrackingWDSDaily(dsCensusDetails.iRegion_ID, DateFormat(ThruDate, "mm/dd/yyyy"),PtoPFormat,rollup);
							}
							
							if (cLaborTrackingCategory is "WD Hourly")
							{
								if (rollup is 2) 	{
									dsWDHVarBgt = helperObj.FetchLaborTrackingDivisionalWDHVarBgt(dsCensusDetails.iOPSArea_ID, PtoPFormat, true);
								}

								// Display the Total WD Hourly Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime);
								
								totalDailyHours = totalDailyHours + fRegular + fOvertime;
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
																
								// Display the WD Hourly Variable Budget Hours.
								if (dsLaborTrackingWDSInfo.recordcount is 0 or dsLaborTrackingWDSInfo.nStatus is "T")
								{
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget;
									
									WDHVarBgt = WDHVarBgt + fVariableBudget;
									totalDailyBudgetHours = totalDailyBudgetHours + fVariableBudget;
									nursingBudgetTotalHours = nursingBudgetTotalHours + fVariableBudget;
									nursingTotalHours = nursingTotalHours + fRegular + fOvertime;
								}
								else 
								{
									if (rollup is 2)
									{
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsWDHVarBgt.varbgt;
										
										WDHVarBgt = WDHVarBgt + dsWDHVarBgt.varbgt;
										totalDailyBudgetHours = totalDailyBudgetHours +  dsWDHVarBgt.varbgt;
										nursingBudgetTotalHours = nursingBudgetTotalHours +  fVariableBudget;
									}
									else { 
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0;										
									}
								}
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	

								// Display the WD Hourly Variance Budget Hours.
								if (rollup is 2)
								{   dsWDHVarBgt.varbgt=NumberFormat(dsWDHVarBgt.varbgt, "0.00");
									WDVariance = dsWDHVarBgt.varbgt - (fRegular + fOvertime);
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & WDVariance;
									WDHVariance = WDHVariance + WDVariance;
								}
								else 
								{ 
									WDVariance = fVariableBudget - (fRegular + fOvertime);
									if (dsLaborTrackingWDSInfo.recordcount is 0 or dsLaborTrackingWDSInfo.nStatus is "T")
									{
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & WDVariance;
										WDHVariance = WDHVariance + WDVariance;
									}
									else	{
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0;										
									}
								}
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							}
																				
							// Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total.
							else if ((cLaborTrackingCategory is "Resident Care") or 
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
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;	
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Reg column for Nursing. 
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 							
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Reg column for Nursing. 
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOther; 			
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
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 
								NursingActualHours = NursingActualHours + nursingTotalHours;				
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
								// Display the Nursing Budget Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingBudgetTotalHours; 	
								NursingBudgetHours = NursingBudgetHours + nursingBudgetTotalHours;
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Nursing Total Hours Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingDailyVariance; 
								NursingVariance = NursingVariance + nursingDailyVariance;			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								
								
								// Display the Kitchen Regular Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen OT Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total Kitchen Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Kitchen Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen Variance Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}	
									
							//mamta
							else if (cLaborTrackingCategory is "CRM")
							{	
							    nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
								
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);	
								// Display the Nursing Total Hours Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 
								kitchenVariance = fVariableBudget - (fRegular + fOvertime);	
								// Display the CRM Regular Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the CRM OT Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total CRM Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the CRM Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the CRM Variance Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}
							//mamta	end																				
							// Check if the labor category is PPADJ and PTO and do not add the budget and variance cols.
							else if ((cLaborTrackingCategory is "PPADJ") or (cLaborTrackingCategory is "PTO"))
							{
								// Display the PPADJ Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}									
							else
							{
								if (cLaborTrackingCategory is not "WD Salary")
								{
									// Add the current category's hours to the daily total.
									totalDailyHours = (totalDailyHours + fAll);
									// Add the current category's variable budget hours to the daily total.
									//totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);								
									// Display the non-Nursing Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
									// Display the non-Nursing Variable Budget Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
									// Display the non-Nursing Variance Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll); 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
									
									
									totalDailyBudgetHours = totalDailyBudgetHours + fVariableBudget;
									// Check if the current column is a Training Column.
									if (bIsTraining eq true)
									{
										trainingBudgetMtd = trainingBudgetMtd + fVariableBudget;
										currentDaysVariance = totalDailyBudgetHours - totalDailyHours;
										
										// Display the TOTAL Hours.
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyHours; 
										TotalActualHours = TotalActualHours + totalDailyHours;			
										// Increment the column by 1 letter.
										currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
										// Display the TOTAL Budget Hours.
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyBudgetHours; 			
										TotalBudgetHours = TotalBudgetHours + totalDailyBudgetHours;
										// Increment the column by 1 letter.
										currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			
																											
										// Display the Day's Variance.
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentDaysVariance; 			
										TotalVariance = TotalVariance + currentDaysVariance;
										
										// Increment the column by 1 letter.
										currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
									}
								}
							}							
						}
					}
				}
			}
			// ------------------------- MTD ACTUAL HOURS - TOTALS -------------------------
			dsCensusDetailsMTD = helperObj.FetchAverageMTDCensusDetailsRollup(dsCensusDetails, rollup, false);
			if (rollup is 3) {
				dsLaborHours = helperObj.FetchLaborHoursRollup(RegionID, PtoPFormat, 1,true);
			} else if (rollup is 2) {
				dsLaborHours = helperObj.FetchLaborHoursRollup(DivisionID, PtoPFormat, 2,true);
			}else if (rollup is 1) {
				dsLaborHours = helperObj.FetchLaborHoursConsolidated(PtoPFormat);
			}
			dsMTDLaborCtgyHours = helperObj.FetchMTDLaborHoursRollup(dsLaborHours, 1);
			dsMTDLaborNursingHours = helperObj.FetchMTDLaborHoursRollup(dsLaborHours, 2);
			dsMTDLaborHours = helperObj.FetchMTDLaborHoursRollup(dsLaborHours, 3);
	
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
			currentExcelColumn = "A";

			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & "Total " & name; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);

			// Display the MTD Census column.
			if (rollup is 2) {
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalTenants; 
			} else {
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsCensusDetailsMTD.TotalTenants; 
			}
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			// Display the MTD Occupancy column.
			if (rollup is 2) {
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalOccupants; 
			} else {
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsCensusDetailsMTD.TotalOccupancy; 
			}
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
			// Display the MTD Service Points column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsCensusDetailsMTD.TotalPoints; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			// Display the MTD two person assists column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & dsCensusDetailsMTD.TotalTwoPersonAssists; 
	
			// Clear some variables.
			nursingBudgetTotalHours = 0.0;
			nursingTotalHours = 0.0;
			totalDailyHours = 0.0;
			totalDailyBudgetHours = 0.0;					
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
			// Loop through Mtd labor categories.
			for (index = 1; index lte dsMTDLaborCtgyHours.RecordCount; index = index + 1)
			{
				// Set the Hours, Category, IsVisible, and IsTraining variables for the current Record.
				fRegular = dsMTDLaborCtgyHours["fRegular"][index];
				fOvertime = dsMTDLaborCtgyHours["fOvertime"][index];
				fOther = dsMTDLaborCtgyHours["fOther"][index];
				fAll = dsMTDLaborCtgyHours["fAll"][index];	
				fBudget = dsMTDLaborCtgyHours["fBudget"][index];			
				fVariableBudget = dsMTDLaborCtgyHours["fVariableBudget"][index];	
				cLaborTrackingCategory = dsMTDLaborCtgyHours["cLaborTrackingCategory"][index];
				bIsVisible = dsMTDLaborCtgyHours["bIsVisible"][index];
				bIsTraining = dsMTDLaborCtgyHours["bIsTraining"][index];
				// Check if the current column should be displayed. 
				if (bIsVisible eq true)
				{
					if(cLaborTrackingCategory is not "Kitchen Training")
					{
						if (cLaborTrackingCategory is "WD Hourly")
						{
							// Add the current category's hours to the daily total.
							if (open is 1 or (conditionalTrue is 1)) 
							{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);}
							else 
							{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
							// Add the current category's budget hours to the daily total.
							if (open is 1 or conditionalTrue is 1) 
							{	totalDailyBudgetHours = (totalDailyBudgetHours + totalvarbgt);		}			//fVariableBudget		
							else 
							{	totalDailyBudgetHours = (totalDailyBudgetHours + 0);	}
							nursingTotalHours = nursingTotalHours + fRegular + fOvertime;
							nursingBudgetTotalHours = nursingBudgetTotalHours + totalvarbgt;
							// Display the Total WD Hourly Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the WD Hourly Variable Budget Hours.
							if (open is 1 or conditionalTrue is 1)
							{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalvarbgt;/*fVariableBudget*/	}	
							else 
							{	//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0;
							 			}								
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the WD HOurly Variance Budget Hours.
							if (open is 1 or (conditionalTrue is 1 and conflict is 0)) {
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (totalvarbgt - (fRegular + fOvertime)); 						}
							else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (totalvarbgt - (fRegular + fOvertime)); 	}		
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}																						
						// Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total.
						else if ((cLaborTrackingCategory is "Resident Care") or (cLaborTrackingCategory is "Nurse Consultant") or (cLaborTrackingCategory is "LPN - LVN"))	
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
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;	
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Reg column for Nursing. 
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 							
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Reg column for Nursing. 
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOther; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						}
						// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is.
						else if (cLaborTrackingCategory is "Kitchen")
						{
							// Calculate the Nursing Sub-Total's variance.
							nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
							//assign nursing variance total to a global variable.
							totalNursingDailyVariance = nursingDailyVariance;					
							
							if (isCCLLC is 0)
							{	// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
							}
							else
							{
								fRegular = 0;
								fOvertime = 0;
								fVariableBudget = 0;
							}
							// Display the Nursing Total Hours Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 				
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
							// Display the Nursing Budget Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingBudgetTotalHours; 	
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Nursing Total Hours Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingDailyVariance; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen Regular Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen OT Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total Kitchen Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Kitchen Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen Variance Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}	
						//mamta start2
						else if (cLaborTrackingCategory is "CRM")
						{   
						     // Calculate the Nursing Sub-Total's variance.
								nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
								
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);	
								// Display the Nursing Total Hours Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 
								kitchenVariance = fVariableBudget - (fRegular + fOvertime);
							/* Calculate the Nursing Sub-Total's variance.
								nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
								
							// Add the current category's hours to the daily total.
							totalDailyHours = (totalDailyHours + fRegular + fOvertime);
							// Add the current category's budget hours to the daily total.
							totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);	
							// Display the Nursing Total Hours Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 
							kitchenVariance = fVariableBudget - (fRegular + fOvertime);	*/	
							// Display the CRM Regular Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the CRM OT Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total CRM Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the CRM Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the CRM Variance Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}			
						//mamta end2																					
						// Check if the labor category is PPADJ and do not add the budget and variance cols.
						else if (cLaborTrackingCategory is "PPADJ")
						{
							// Display the PPADJ Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}				
						// Check if the labor category is PTO and do not add the budget and variance cols.
						else if (cLaborTrackingCategory is "PTO")
						{
							// Display the PTO Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}				
						else
						{
							if (cLaborTrackingCategory is not "WD Salary")
							{
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fAll);
								// Add the current category's variable budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);		
								// Display the non-Nursing Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
								// Display the non-Nursing Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the non-Nursing Variance Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Check if the current column is a Training Column.
								if (bIsTraining eq true)
								{   //totalDailyHours = (totalDailyHours + fAll);
									//totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);
									
									// Display the TOTAL Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyHours; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
									// Display the TOTAL Budget Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyBudgetHours; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);													
									// Get the Day's Variance.
									currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
									
									// Display the Day's Variance.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentDaysVariance; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
								    
								}
							}
						}}
					}//ccllcHouse is 0
				}			
			// Check if the current day is less than 31, which would mean that the less days need to be deleted from the spreadsheet.
			if (censusIndex lt 31)
			{
				// Loop through the days that need to be deleted.
				for (index = (censusIndex); index lte 35; index = index + 1)
				{
					if (index is not 32) {
					// Set the Excel Spreadsheet's Row Number to Delete.
					outOfRangeRow = index + 5;
					// Delete the out of range row.
					excelData = excelData & "|" & excelWorkSheet & ".!." & outOfRangeRow & ":0"; }
				}
			}

			// Put the File Name together using the House Name and the current date and time.
			destFileName = "LaborTracking_" & name & "_";
			destFileName = destFileName & DateFormat(Now(),'M-D-YY') & "_";
			destFileName = destFileName & DatePart("h", Now());
			destFileName = destFileName & DatePart("n", Now());
			destFileName = destFileName & DatePart("s", Now());
			destFileName = destFileName & ".xls";
			destFilePath = "\\FS01.alcco.com\FTA\" & destFileName;
		}
		


		if (rollup is 0)
		{
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
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentCensus; 
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				// Display the occupancy column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentOccupancyUnits; 
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);			
				// Display the service points column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentPoints; 
				// Increment the column by 1 letter.
				currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
				// Display the 2-person assists column.
				excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & twoPersonAssists; 
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
						if (ccllcHouse is 0)
						{	if (cLaborTrackingCategory is not "Kitchen Training"){
							if (cLaborTrackingCategory is "WD Hourly")
							{
								// Add the current category's hours to the daily total.
								if (conflict is 1)
								{	totalDailyHours = (totalDailyHours + 0);	}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay))  )
								{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);		}	
								else if ( open is 1 or  ((WDStermed is 0) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))  )
								{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);		}							
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 0 and currPeriod is 0))  )
								{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);		}	
								else 
								{	totalDailyHours = 0;	}
								// Add the current category's budget hours to the daily total.
								if (conflict is 1)
								{	totalDailyBudgetHours = (totalDailyBudgetHours + 0);		}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay))  )
								{	totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);		}	
								else if ( open is 1 or  ((WDStermed is 0) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))  )
								{	totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);		}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 0 and currPeriod is 0))  )
								{	totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);		}	
								else 
								{ 	totalDailyBudgetHours = 0;	}				
		
								// Display the WD Hourly Regular Hours.
								//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
								// Increment the column by 1 letter.
								//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the WD Hourly OT Hours.
								//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total WD Hourly Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the WD Hourly Variable Budget Hours.
								if (conflict is 1)
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0;  
									conditionalFalse = 1;
									conditionalTrue = 1;									}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay))  )
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget;
									totalvarbgt = totalvarbgt + fVariableBudget; 
									conditionalTrue = 1;	
									conditionalFalse = 0;									}
								else if ( open is 1 or  ((WDStermed is 0) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))  )
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 
									totalvarbgt = totalvarbgt + fVariableBudget; 
									conditionalTrue = 1;
									conditionalFalse = 0;																	}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 0 and currPeriod is 0))  )
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget;
									totalvarbgt = totalvarbgt + fVariableBudget; 
									conditionalTrue = 1;	
									conditionalFalse = 0;									}
								else 
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 
									if (open is 0 and conditionalTrue is 1) {conditionalFalse = 0;	}
									else if (WDStermed is 0) {	conditionalFalse = 0;	}
									else {	conditionalFalse = 1;	}
								}
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the WD Hourly Variance Budget Hours.
								if (conflict is 1) 
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 		}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dTermdate, "dd") lt currentDay))  )
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));
									totalvariance = totalvariance + (fVariableBudget - (fRegular + fOvertime)); 		}
								else if ( open is 1 or  ((WDStermed is 0) and (samePeriod is 1 or currPeriod is 1) and 
																				(DateFormat(dsLaborTrackingWDSInfo.dHiredate-1, "dd") gte currentDay))  )
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));
									totalvariance = totalvariance + (fVariableBudget - (fRegular + fOvertime)); 		}
								else if ( open is 1 or  ((WDStermed is 1) and (samePeriod is 0 and currPeriod is 0))  )
								{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));
									totalvariance = totalvariance + (fVariableBudget - (fRegular + fOvertime)); 		}
								else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 		}	
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}																						
							// Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total.
							else if ((cLaborTrackingCategory is "Resident Care") or 
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
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;	
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Reg column for Nursing. 
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 							
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Reg column for Nursing. 
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOther; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							}
							// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is.
							else if (cLaborTrackingCategory is "Kitchen")
							{
								// Calculate the Nursing Sub-Total's variance.
								nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
								
								if (isCCLLCHouse is 0 or isCCLLC is 0)
								{	// Add the current category's hours to the daily total.
									totalDailyHours = (totalDailyHours + fRegular + fOvertime);
									// Add the current category's budget hours to the daily total.
									totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
								}
								else
								{
									fRegular = 0;
									fOvertime = 0;
									fVariableBudget = 0;
								}
								// Display the Nursing Total Hours Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 				
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
								// Display the Nursing Budget Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingBudgetTotalHours; 	
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Nursing Total Hours Sub-Total.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingDailyVariance; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								
								// Display the Kitchen Regular Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen OT Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total Kitchen Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the Kitchen Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen Variance Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}
							//mamta start 3
							else if (cLaborTrackingCategory is "CRM")
							{
								// Calculate the Nursing Sub-Total's variance.
								nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
								
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);	
								kitchenVariance = fVariableBudget - (fRegular + fOvertime);
								// Display the CRM Regular Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the CRM OT Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total CRM Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Display the CRM Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the CRM Variance Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}																						
							//mamta end 3																						
							// Check if the labor category is PPADJ and do not add the budget and variance cols.
							else if (cLaborTrackingCategory is "PPADJ")
							{
								// Display the PPADJ Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}									
							// Check if the labor category is PTO and do not add the budget and variance cols.
							else if (cLaborTrackingCategory is "PTO")
							{
								// Display the PTO Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}				
							else
							{
								if (cLaborTrackingCategory is not "WD Salary")
								{
									// Add the current category's hours to the daily total.
									totalDailyHours = (totalDailyHours + fAll);
									// Add the current category's variable budget hours to the daily total.
									totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);								
									// Display the non-Nursing Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
									// Display the non-Nursing Variable Budget Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
									// Display the non-Nursing Variance Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll); 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
									// Check if the current column is a Training Column.
									if (bIsTraining eq true)
									{
										// Display the TOTAL Hours.
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyHours; 			
										// Increment the column by 1 letter.
										currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
										// Display the TOTAL Budget Hours.
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyBudgetHours; 			
										// Increment the column by 1 letter.
										currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);																				
										// Get the Day's Variance.
										currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
										// Display the Day's Variance.
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentDaysVariance; 			
										// Increment the column by 1 letter.
										currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
									}
								}
							}}
						}//ccllchouse is 0
						else //ccllcHouse is 1
						{
							if (cLaborTrackingCategory is "Kitchen")
							{
								dsCCLLCSalariedEmpInfo = helperObj.FetchCCLLCSalariedInfo(houseId);
								if (dsCCLLCSalariedEmpInfo.recordcount neq 0)
								{ 
									ccllcSalEmp = 1;
									sunday = 0;
									dsSundaysOfMonth = helperObj.FetchSundaysOfMonth(currentDay, PtoPFormat);
									if (dsSundaysOfMonth.name eq "Sunday") {	sunday = 1;	}
									else {	sunday = 0;		}
								}
								else	{		ccllcSalEmp = 0;		}
									
								
								if (ccllcSalEmp is 1) 
								{	// Add the current category's hours to the daily total.
									if (sunday is 1) { totalDailyHours = (totalDailyHours + fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours);	}
									else {	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
								}
								else	{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
									
								
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
	
								// Display the Kitchen Regular Hours.
								if (ccllcSalEmp is 1) 
								{	
									if (sunday is 1) {
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular + dsCCLLCSalariedEmpInfo.iWorkWeekHours;
									totalRegular = totalRegular+ fRegular + dsCCLLCSalariedEmpInfo.iWorkWeekHours;	}
									else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;
											totalRegular = totalRegular+ fRegular; 	}
								}
								else	{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;
											totalRegular = totalRegular+ fRegular; 	}			
										
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen OT Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total Kitchen Hours.
								if (ccllcSalEmp is 1) 
								{	
									if (sunday is 1) {
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime+ dsCCLLCSalariedEmpInfo.iWorkWeekHours);
										totalActual = totalActual + fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours; 	}
									else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime);
											totalActual = totalActual + fRegular + fOvertime; 	}
								}
								else	{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime);
											totalActual = totalActual + fRegular + fOvertime; 	}				
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								
								// Display the Kitchen Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								//kitchenTrngVarBgt = (2/100 * fVariableBudget);
								//totalKitchenTrngVarBgt = totalKitchenTrngVarBgt + kitchenTrngVarBgt;
								
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen Variance Budget Hours.
								if (ccllcSalEmp is 1) 
								{	
									if (sunday is 1) {excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours)); 	}
									else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 	}
								}
								else	{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 	}		
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}
									if (cLaborTrackingCategory is "CRM")
							{
								dsCCLLCSalariedEmpInfo = helperObj.FetchCCLLCSalariedInfo(houseId);
								if (dsCCLLCSalariedEmpInfo.recordcount neq 0)
								{ 
									ccllcSalEmp = 1;
									sunday = 0;
									dsSundaysOfMonth = helperObj.FetchSundaysOfMonth(currentDay, PtoPFormat);
									if (dsSundaysOfMonth.name eq "Sunday") {	sunday = 1;	}
									else {	sunday = 0;		}
								}
								else	{		ccllcSalEmp = 0;		}
									
								
								if (ccllcSalEmp is 1) 
								{	// Add the current category's hours to the daily total.
									if (sunday is 1) { totalDailyHours = (totalDailyHours + fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours);	}
									else {	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
								}
								else	{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
									
								
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
	
								// Display the CRM Regular Hours.
								if (ccllcSalEmp is 1) 
								{	
									if (sunday is 1) {
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular + dsCCLLCSalariedEmpInfo.iWorkWeekHours;
									totalRegular = totalRegular+ fRegular + dsCCLLCSalariedEmpInfo.iWorkWeekHours;	}
									else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;
											totalRegular = totalRegular+ fRegular; 	}
								}
								else	{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;
											totalRegular = totalRegular+ fRegular; 	}			
										
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Kitchen OT Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the Total CRM Hours.
								if (ccllcSalEmp is 1) 
								{	
									if (sunday is 1) {
										excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime+ dsCCLLCSalariedEmpInfo.iWorkWeekHours);
										totalActual = totalActual + fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours; 	}
									else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime);
											totalActual = totalActual + fRegular + fOvertime; 	}
								}
								else	{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime);
											totalActual = totalActual + fRegular + fOvertime; 	}				
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								
								// Display the Kitchen Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								//kitchenTrngVarBgt = (2/100 * fVariableBudget);
								//totalKitchenTrngVarBgt = totalKitchenTrngVarBgt + kitchenTrngVarBgt;
								
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the CRM Variance Budget Hours.
								if (ccllcSalEmp is 1) 
								{	
									if (sunday is 1) {excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime + dsCCLLCSalariedEmpInfo.iWorkWeekHours)); 	}
									else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 	}
								}
								else	{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 	}		
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
							}																												
																															
							// Check if the current column is a Training Column.
							if (cLaborTrackingCategory is "Kitchen Training")
							{
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fAll);
								// Add the current category's variable budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget); //kitchenTrngVarBgt);	
															
								// Display the non-Nursing Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
								// Display the non-Nursing Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; //kitchenTrngVarBgt; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the non-Nursing Variance Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll); //(kitchenTrngVarBgt - fAll); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								
								// Display the TOTAL Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyHours; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the TOTAL Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyBudgetHours; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);																				
								// Get the Day's Variance.
								currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
								// Display the Day's Variance.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentDaysVariance; 			
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
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & censusMtd; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			// Display the MTD Occupancy column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & occupancyMtd; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
			// Display the MTD Service Points column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & pointsMtd; 
			// Increment the column by 1 letter.
			currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			// Display the MTD two person assists column.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & twoPersonAssistsMtd; 
	
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
					if (ccllcHouse is 0)
					{	if(cLaborTrackingCategory is not "Kitchen Training"){
						if (cLaborTrackingCategory is "WD Hourly")
						{
							// Add the current category's hours to the daily total.
							if (open is 1 or (conditionalTrue is 1)) 
							{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);		}
							else 
							{	totalDailyHours = (totalDailyHours + 0);	}
							// Add the current category's budget hours to the daily total.
							if (open is 1 or conditionalTrue is 1) 
							{	totalDailyBudgetHours = (totalDailyBudgetHours + totalvarbgt);		}			//fVariableBudget		
							else 
							{	totalDailyBudgetHours = (totalDailyBudgetHours + 0);	}
							//Add the current category's Actual and Variable Budget Hours to the nursing mtd totals. 
						    nursingTotalHours = nursingTotalHours + fRegular + fOvertime ;
						    nursingBudgetTotalHours = nursingBudgetTotalHours + totalvarbgt;
							// Display the WD Hourly Regular Hours.
							//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
							// Increment the column by 1 letter.
							//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the WD HOurly OT Hours.
							//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total WD Hourly Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the WD Hourly Variable Budget Hours.
							if (open is 1 or conditionalTrue is 1)
							{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalvarbgt;/*fVariableBudget*/	}	
							else 
							{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 			}								
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the WD HOurly Variance Budget Hours.
							if (open is 1 or (conditionalTrue is 1 and conflict is 0)) {
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (totalvarbgt - (fRegular + fOvertime)); 						}
							else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 	}		
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}																						
						// Check if it's a Nursing Category and then update the daily total for the Nursing Budget Sub-Total.
						else if ((cLaborTrackingCategory is "Resident Care") or (cLaborTrackingCategory is "Nurse Consultant") or (cLaborTrackingCategory is "LPN - LVN"))	
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
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular;	
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Reg column for Nursing. 
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 							
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Reg column for Nursing. 
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOther; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						}
						// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is.
						else if (cLaborTrackingCategory is "Kitchen")
						{
							// Calculate the Nursing Sub-Total's variance.
							nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
							//assign nursing variance total to a global variable.
							totalNursingDailyVariance = nursingDailyVariance;					
							
							if (isCCLLC is 0)
							{	// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
							}
							else
							{
								fRegular = 0;
								fOvertime = 0;
								fVariableBudget = 0;
							}
							// Display the Nursing Total Hours Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingTotalHours; 				
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
							// Display the Nursing Budget Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingBudgetTotalHours; 	
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Nursing Total Hours Sub-Total.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingDailyVariance; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen Regular Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen OT Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total Kitchen Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Kitchen Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen Variance Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}	
						//mamta start 4
						else if (cLaborTrackingCategory is "CRM")
						{	// Calculate the Nursing Sub-Total's variance.
							nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
							//assign nursing variance total to a global variable.
							totalNursingDailyVariance = nursingDailyVariance;					
							
							if (isCCLLC is 0)
							{	// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
							}
							else
							{
								fRegular = 0;
								fOvertime = 0;
								fVariableBudget = 0;
							}
							kitchenVariance = fVariableBudget - (fRegular + fOvertime);
						   // Display the CRM Regular Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the CRM OT Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total CRM Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the CRM Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the CRM Variance Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}
						//mamta end 4																					
						// Check if the labor category is PPADJ and do not add the budget and variance cols.
						else if (cLaborTrackingCategory is "PPADJ")
						{
							// Display the PPADJ Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}				
						// Check if the labor category is PTO and do not add the budget and variance cols.
						else if (cLaborTrackingCategory is "PTO")
						{
							// Display the PTO Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}				
						else
						{
							if (cLaborTrackingCategory is not "WD Salary")
							{
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fAll);
								// Add the current category's variable budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);								
								// Display the non-Nursing Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
								// Display the non-Nursing Variable Budget Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
								// Display the non-Nursing Variance Hours.
								excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll); 			
								// Increment the column by 1 letter.
								currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
								// Check if the current column is a Training Column.
								if (bIsTraining eq true)
								{
									// Display the TOTAL Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyHours; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
									// Display the TOTAL Budget Hours.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyBudgetHours; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);													
									// Get the Day's Variance.
									currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
									// Display the Day's Variance.
									excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentDaysVariance; 			
									// Increment the column by 1 letter.
									currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
								}
							}
						}}
					}//ccllcHouse is 0
					else //ccllcHouse is 1
					{
						dsCCLLCSalariedEmpInfo = helperObj.FetchCCLLCSalariedInfo(houseId);
						if (dsCCLLCSalariedEmpInfo.recordcount neq 0){	ccllcSalEmp = 1; }
						else {	ccllcSalEmp = 0;	}
	
						if (cLaborTrackingCategory is "Kitchen")
						{
							// Add the current category's hours to the daily total.
							if (ccllcSalEmp is 1){		totalDailyHours = (totalDailyHours + totalActual);	}
							else	{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
							// Add the current category's budget hours to the daily total.
							totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
	
							// Display the Kitchen Regular Hours.
							if (ccllcSalEmp is 1){excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalRegular;	}
							else	{		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 	}
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen OT Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total Kitchen Hours.
							if (ccllcSalEmp is 1){excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalActual; 	}
							else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 	}		
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the Kitchen Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Kitchen Variance Budget Hours.
							if (ccllcSalEmp is 1){excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - totalActual); 	}
							else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));	}		
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}		
						//mamta start 5
						if (cLaborTrackingCategory is "CRM")
						{   // Calculate the Nursing Sub-Total's variance.
								nursingDailyVariance = (nursingBudgetTotalHours - nursingTotalHours);
								
								// Add the current category's hours to the daily total.
								totalDailyHours = (totalDailyHours + fRegular + fOvertime);
								// Add the current category's budget hours to the daily total.
								totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);		
							// Add the current category's hours to the daily total.
							if (ccllcSalEmp is 1){		totalDailyHours = (totalDailyHours + totalActual);	}
							else	{	totalDailyHours = (totalDailyHours + fRegular + fOvertime);	}
							// Add the current category's budget hours to the daily total.
							totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget);					
	
							// Display the CRM Regular Hours.
							if (ccllcSalEmp is 1){excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalRegular;	}
							else	{		excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fRegular; 	}
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the CRM OT Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fOvertime; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the Total CRM Hours.
							if (ccllcSalEmp is 1){excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalActual; 	}
							else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fRegular + fOvertime); 	}		
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the CRM Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the CRM Variance Budget Hours.
							if (ccllcSalEmp is 1){excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - totalActual); 	}
							else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));	}		
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
						}			
						//mamta end 5	
																								
						// Check if the current column is a Training Column.
						if (cLaborTrackingCategory is "Kitchen Training")
						{
							// Add the current category's hours to the daily total.
							totalDailyHours = (totalDailyHours + fAll);
							// Add the current category's variable budget hours to the daily total.
							totalDailyBudgetHours = (totalDailyBudgetHours + fVariableBudget); //totalKitchenTrngVarBgt);								
							// Display the non-Nursing Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fAll; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);						
							// Display the non-Nursing Variable Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget;//totalKitchenTrngVarBgt; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
							// Display the non-Nursing Variance Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll); //(totalKitchenTrngVarBgt - fAll); 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
	
							// Display the TOTAL Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyHours; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
							// Display the TOTAL Budget Hours.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalDailyBudgetHours; 			
							// Increment the column by 1 letter.
							currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);													
							// Get the Day's Variance.
							currentDaysVariance = (totalDailyBudgetHours - totalDailyHours);
							// Display the Day's Variance.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & currentDaysVariance; 			
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
	
				if (ccllcHouse is 0)
				{	if (cLaborTrackingCategory is not "Kitchen Training"){
					// Accumulate the variable budget total.							
					if (cLaborTrackingCategory is "WD Hourly")
					{	variableBudgetTotal = variableBudgetTotal + totalvarbgt;	}
					else
					{	variableBudgetTotal = variableBudgetTotal + fVariableBudget;	}
						
					if (cLaborTrackingCategory is "WD Hourly")
					{				
						// Skip the first 2 WD Hourly cols.
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						// Display the WD Hourly Budget Hours.
						if (open is 1 or conditionalTrue is 1) {
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalvarbgt;/*fVariableBudget*/	}
						else { //variableBudgetTotal = variableBudgetTotal - fVariableBudget;
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 			}
						// Increment the column by 2 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);				
					}
					// Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total.
					else if ((cLaborTrackingCategory is "Resident Care") or	(cLaborTrackingCategory is "Nurse Consultant") or (cLaborTrackingCategory is "LPN - LVN"))
					{
						// Accumulate the current category's budget total.
						nursingVariableBudgetTotal = nursingVariableBudgetTotal + fVariableBudget;
						// Display the Reg Variable Budget column.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
						// Increment the column by 3 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					}
					// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
					else if (cLaborTrackingCategory is "Kitchen")
					{
						// Display the Nursing Variable Budget Sub-Total.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & nursingVariableBudgetTotal; 			
						// Increment the column by 2 letters to get to the next category.	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
										
						// Display the Kitchen Budget Hours.
						if (isCCLLCHouse is 0 or isCCLLC is 0)
						{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 	}
						else{	variableBudgetTotal = variableBudgetTotal - fVariableBudget;
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 	}
						// Increment the column by 2 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);				
					}
					//mamta start 6
					else if (cLaborTrackingCategory is "CRM")
					{
						// Increment the column by 2 letters to get to the next category.	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
										
						// Display the CRM Budget Hours.
						if (isCCLLCHouse is 0 or isCCLLC is 0)
						{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 	}
						else{	variableBudgetTotal = variableBudgetTotal - fVariableBudget;
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 	}
						// Increment the column by 2 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);				
					}
					//mamta end 6
					else
					{	
						// Display the Non-Nursing Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 	
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);								
					}
					}
				}//ccllcHouse is 0
				else //ccllcHouse is 1
				{
					if (cLaborTrackingCategory is "Kitchen")
					{	variableBudgetTotal = variableBudgetTotal + fVariableBudget;
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						// Display the Kitchen Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
						// Increment the column by 2 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);				
					}
					//mamta start 7
					if (cLaborTrackingCategory is "CRM")
					{	variableBudgetTotal = variableBudgetTotal + fVariableBudget;
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						// Display the CRM Budget Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 			
						// Increment the column by 2 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);				
					}
					//mamta end 7
					if (cLaborTrackingCategory is "Kitchen Training")
					{	
						//variableBudgetTotal = variableBudgetTotal + totalKitchenTrngVarBgt;
						variableBudgetTotal = variableBudgetTotal + fVariableBudget;
					
						// Display the Non-Nursing Hours.
						//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalKitchenTrngVarBgt; 	
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & fVariableBudget; 
						
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);								
					}			
				}
			}			
			// Display the total variable budget Hours.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & variableBudgetTotal; 			
						
						
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
				
				if (ccllcHouse is 0)
				{	if (cLaborTrackingCategory is not "Kitchen Training"){
					if (cLaborTrackingCategory is "WD Hourly")
					{	
						// Skip the first 2 WD Hourly cols.
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Update the Variable Budget Variance Total. 
						if (conflict is 1) {
							variableBudgetVarianceTotal = variableBudgetVarianceTotal + (0 - (fRegular + fOvertime));			//fVariableBudget			
						} else if (open is 1 or (conditionalTrue is 1 and conflict is 0)) {
							variableBudgetVarianceTotal = variableBudgetVarianceTotal + (totalvarbgt - (fRegular + fOvertime));			//fVariableBudget			
						} else {
							variableBudgetVarianceTotal = variableBudgetVarianceTotal + 0;						
						}
						// Display the WD Hourly Reg Variable Budget Variance column.
						if (open is 1 or (conditionalTrue is 1 and conflict is 0)) 
						{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (totalvarbgt - (fRegular + fOvertime)); 					}else { 	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 	}	
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}
					// Check if it's a Nursing Category and then update the mtd total for the Nursing Budget Sub-Total.
					else if ((cLaborTrackingCategory is "Resident Care") or (cLaborTrackingCategory is "Nurse Consultant") or (cLaborTrackingCategory is "LPN - LVN"))
					{
						// Accumulate the variable budget variance total using the current category.
						variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOverTime + fOther));
					
						// Display the Reg Variable Budget Variance column.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fRegular); 			
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						
						// Display the OT Variable Budget Variance column.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (-fOvertime); 			
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						// Display the Other Variable Budget Variance column.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (-fOther); 			
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
					}
					// Check if the labor category is Kitchen and insert the Nursing Sub-Total columns before Kitchen if it is. --->
					else if (cLaborTrackingCategory is "Kitchen")
					{	
						// Display the Nursing Variable Budget Variance Sub-Total.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & totalNursingDailyVariance; //variableBudgetVarianceTotal; 			
						// Increment the column by 3 letters to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			
						// Skip the first 2 kitchen cols.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						if (isCCLLC is 0)	
						{	// Update the Variable Budget Variance Total. 
							variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOvertime));								
							// Display the Kitchen Reg Variable Budget Variance column.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
						}else{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 	}	
							
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}
					//mamta start 8
					else if (cLaborTrackingCategory is "CRM")
					{	
						// Increment the column by 3 letters to get to the next category.
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						//currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
			
						// Skip the first 2 CRM cols.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						
						if (isCCLLC is 0)	
						{	// Update the Variable Budget Variance Total. 
							variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOvertime));								
							// Display the Kitchen Reg Variable Budget Variance column.
							excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime)); 			
						}else{	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & 0; 	}	
							
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}
					//mamta end 8
					else
					{	
						// Update the Variable Budget Variance Total. 
						variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - fAll);				
						// Display the Non-Nursing Hours.
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll);					
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					}
					}
				}//ccllcHouse is 0
				else//ccllcHouse is 1
				{
					dsCCLLCSalariedEmpInfo = helperObj.FetchCCLLCSalariedInfo(houseId);
					if (dsCCLLCSalariedEmpInfo.recordcount neq 0){	ccllcSalEmp = 1; }
					else {	ccllcSalEmp = 0;	}
	
					if (cLaborTrackingCategory is "Kitchen")
					{	
						// Skip the first 2 kitchen cols.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Update the Variable Budget Variance Total. 
						if (ccllcSalEmp is 1) {	variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (totalActual));	}	
						else {	variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOvertime));	}					
								
						// Display the Kitchen Reg Variable Budget Variance column.
						if (ccllcSalEmp is 1) {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - totalActual); 	}
						else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));	}		
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}
					//mamta start 9
					if (cLaborTrackingCategory is "CRM")
					{	
						// Skip the first 2 CRM cols.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
						// Update the Variable Budget Variance Total. 
						if (ccllcSalEmp is 1) {	variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (totalActual));	}	
						else {	variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - (fRegular + fOvertime));	}					
								
						// Display the CRM Reg Variable Budget Variance column.
						if (ccllcSalEmp is 1) {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - totalActual); 	}
						else {	excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - (fRegular + fOvertime));	}		
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);		
					}
					//mamta end 9
					if (loop is 0){
					if (cLaborTrackingCategory is "Kitchen Training")
					{	loop = 1;
						// Update the Variable Budget Variance Total. 
						//variableBudgetVarianceTotal = variableBudgetVarianceTotal + (totalKitchenTrngVarBgt - fAll);	
						variableBudgetVarianceTotal = variableBudgetVarianceTotal + (fVariableBudget - fAll);	
								
						// Display the Non-Nursing Hours.
						//excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (totalKitchenTrngVarBgt - fAll);
						excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & (fVariableBudget - fAll);
											
						// Increment the column by 1 letter to get to the next category.
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);					
						currentExcelColumn = helperObj.FetchNextLetterInAlphabet(currentExcelColumn);	
					}	}		
				}
			}			
			// Display the total variable budget variance Hours.
			excelData = excelData & "|" & excelWorkSheet & "." & currentExcelColumn & "." & currentExcelRow & ":" & variableBudgetVarianceTotal; 			
											
							
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
			if (ccllcHouse is 0)
			{
				// Put the File Name together using the House Name and the current date and time.
				destFileName = "LaborTracking_" & houseName & "_";
				destFileName = destFileName & DateFormat(Now(),'M-D-YY') & "_";
				destFileName = destFileName & DatePart("h", Now());
				destFileName = destFileName & DatePart("n", Now());
				destFileName = destFileName & DatePart("s", Now());
				destFileName = destFileName & ".xls";
				destFilePath = "\\FS01.alcco.com\FTA\" & destFileName;
			}
			else
			{
				// Put the File Name together using the House Name and the current date and time.
				destFileName = "LaborTracking_CCLLC_" & houseName & "_";
				destFileName = destFileName & DateFormat(Now(),'M-D-YY') & "_";
				destFileName = destFileName & DatePart("h", Now());
				destFileName = destFileName & DatePart("n", Now());
				destFileName = destFileName & DatePart("s", Now());
				destFileName = destFileName & ".xls";
				destFilePath = "\\FS01.alcco.com\FTA\" & destFileName;
			}
		}
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
	<cfif rollup is 0>
		<cfif ccllcHouse is 0>
			<cfinvoke webservice="http://Maple.alcco.com/ExcelWebService/Service.asmx?WSDL" method="DataEntry" returnvariable="fileCreated">
				<cfinvokeargument name="iSourceFileName" value="LaborTracking.xls">
				<cfinvokeargument name="iData" value="#excelData#">
				<cfinvokeargument name="iDestinationFileName" value="#destFileName#">
			</cfinvoke>
		<cfelse>
			<cfinvoke webservice="http://Maple.alcco.com/ExcelWebService/Service.asmx?WSDL" method="DataEntry" returnvariable="fileCreated">
				<cfinvokeargument name="iSourceFileName" value="LaborTracking_CCLLC.xls">
				<cfinvokeargument name="iData" value="#excelData#">
				<cfinvokeargument name="iDestinationFileName" value="#destFileName#">
			</cfinvoke>
		</cfif>
	<cfelse>
		<cfinvoke webservice="http://Maple.alcco.com/ExcelWebService/Service.asmx?WSDL" method="DataEntry" returnvariable="fileCreated">
			<cfinvokeargument name="iSourceFileName" value="LaborTracking.xls">
			<cfinvokeargument name="iData" value="#excelData#">
			<cfinvokeargument name="iDestinationFileName" value="#destFileName#">
		</cfinvoke>
	</cfif>
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

