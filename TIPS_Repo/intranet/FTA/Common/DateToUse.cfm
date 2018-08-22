<!--- Sets up all of the required Date variables used by all of the Pages. --->
<cfscript>		
	// use the current Date and Time from the Month/Year variable.
	currentMonth = DateFormat(NOW(), "MM/YYYY");
	// Check if the DataToUse Query String parameter is Defined.
	if ((isDefined("url.dateToUse")) and 
	(url.dateToUse is not DateFormat(NOW(), "mmmm yyyy")))
	{
		// Assign the MONTH Number.
		currentM = DatePart("m", dateToUse);
		// Assign the YEAR Number.
		currentY = DatePart("yyyy", dateToUse);
		// Assign the MONTH and YEAR.
		currentMY = currentm & "/" & currentY;
		// Assign the number of Days in the Month.
		currentDIM = DaysInMonth(currentMY);
		// Assign the current Day Number.
		currentD = DaysInMonth(currentMY);
		// Assign the 1st day of the Month (Date Value).
		currentFullMonth = currentM & "/01/" & currentY & " 12:00:00 AM";
		// Assign the 1st day of the Month with NO TIME DATA.
		currentFullMonthNoTime = currentM & "/01/" & currentY;
		// Assign the last day of the Month.
		lastDayOfDateToUse = currentM & "/" & currentD & "/" & currentY;
		// Assign the Period (example: 200905).
		PtoPFormat = Dateformat(currentFullMonthNoTime, "YYYYMM");
		// Assign the last day of the Previous Month.
		yesterday = DateAdd("d", -1, currentFullMonthNoTime);
		// Strip the TIME DATA from the last day of the previous month.
		yesterday = DateFormat(yesterday, "M/D/YYYY");
		// Assign the last Day of the currently selected Month OR Today if its the current MONTH.
		today = currentM & "/" & currentDIM & "/" & currentY;
		// Assign the 1st day of the currently selected MONTH.
		dateToUse = DateFormat(currentFullMonthNoTime, "mmmm yyyy");
		// Assign the name of the MONTH, but just the first 3 characters (JAN, FEB, etc...).
		monthForQueries = DateFormat(today, "mmm");
		// Stores the Date To Use Year in 4 characters.
		yearForQueries = DateFormat(today, "yyyy");
		// Set the working date variables for the House Report.
		workingm = DatePart("m", DateToUse);
		workingy = DatePart("yyyy", DateToUse);
		workingmy = workingm & "/" & workingy;
		workingdim = DaysInMonth(workingmy);
		workingfullmonthEND = workingm & "/" & workingdim & "/" & workingy & " 11:59:59 PM";
	}
	else
	{
		// Assign the Month Number from the current Date and Time.
		currentM = DatePart("m", NOW());
		// Assign the Day Number from the current Date and Time.
		currentD = DatePart("d", NOW());
		// as of 10/13/2005 make current day equal to yesterday, so current day does not show up on FTA
		if (currentD is not "1")
		{
			// Set the current day number to yesterday.
			currentD = currentD - 1;
		}
		else
		{
			// If current day is the first of month, then show last month's FTA
			minusOneMonth = DateAdd("m", -1, currentMonth);
			// Set the Minus One Month variable to the previous month.  Format: (Febuary 2009, etc...).
			minusOneMonth = DateFormat(minusOneMonth, "mmmm yyyy");
			
			// Stores the query string.
			queryString = "?";
			// Build the query string.
			if (isDefined("Url.SubAccount"))
			{
				queryString = "SubAccount=" & url.SubAccount & "&";
			}
			if (isDefined("Url.iHouse_ID"))
			{
				queryString = "iHouse_ID=" & url.iHouse_ID & "&";
			}
			// Re-load the page. 
			GetPageContext().forward(cgi.SCRIPT_NAME & queryString & "dateToUse=" & minusOneMonth);
		}
		// Stores the current year.
		currentY = DatePart("yyyy", NOW());
		// Stores the name of the current month, but only the first 3 characters (JAN, FEB, etc...).
		monthForQueries = DateFormat(currentM, "mmm");
		// Stores the current Month and Year "MM/YYYY".
		currentMY = currentM & "/" & currentY;
		// Stores the number of days in the current month.
		currentDIM = DaysInMonth(currentMY);
		// Stores the first day of the current month. "MM/01/YYYY 12:00:00 AM"
		currentFullMonth = currentM & "/01/" & currentY & " 12:00:00 AM";
		// Stores the first day of the current month with NO time data.
		currentFullMonthNoTime = currentM & "/01/" & currentY;
		// Stores the last day of the current month, which is the Month-to-Date value.
		lastDayOfDateToUse = currentM & "/" & currentD & "/" & currentY;
		// If this is the first day of the NOW month, then use TODAY as the lastDayOfDateToUse, otherwise, use yesterday 
		if ((isDefined("url.dateToUse")) And (DateFormat(dateToUse, "m/yyyy") is DateFormat(NOW(), "m/yyyy")))
		{
			// Whether or not the current Month is using the current Date and Time data.
			monthNowMonth = "Yes";
		}
		else if (not isDefined("url.dateToUse")) 
		{
			// Whether or not the current Month is using the current Date and Time data.
			monthNowMonth = "Yes";
		}
		// Whether or not the MonthNowMonth variable is set to YES.
		if (isDefined("monthNowMonth"))
		{
			// Check if the current day number is 1.
			if (DatePart("d", NOW()) Is "1")
			{
				// Set the variable to the current date, with NO time data.
				lastDayOfDateToUse = DateFormat(NOW(), "M/D/YYYY");
			}
			else
			{
				// Set the variable to Yesterday, with NO time data.
				lastDayOfDateToUse = DateFormat(lastDayOfDateToUse, "M/D/YYYY");
			}
		}
		// Assign the Period (example: 200905).
		PtoPFormat = Dateformat(currentFullMonthNoTime, "YYYYMM");
		// Assign the last day of the Previous Month.
		yesterday = DateAdd("d",-1, NOW());
		// Strip the TIME DATA from the last day of the previous month.
		yesterday = DateFormat(yesterday, "M/D/YYYY");
		// Stores today's date.  No time data.
		today = DateFormat(NOW(), "M/D/YYYY");
		// Stores today's date in this format "Febuary 2009, etc...".
		dateToUse = DateFormat(NOW(), "mmmm yyyy");
		// Stores the name of the current Month, but only the month's first 3 characters.
		monthForQueries = DateFormat(today, "mmm");
		// Stores the Date To Use Year in 4 characters.
		yearForQueries = DateFormat(today, "yyyy");
		// Set the working date variables for the House Report.
		workingm = DatePart("m", Now());
		workingy = DatePart("yyyy", Now());
		workingmy = workingm & "/" & workingy;
		workingdim = DaysInMonth(workingmy);
		workingfullmonthEND = workingm & "/" & workingdim & "/" & workingy & " 11:59:59 PM";
	}
	// Stores the From Date variable, which is the first of some month.
	fromDate = currentFullMonth;
	// Stores the thru date variable, which is the MTD of some month with a time value of 11:59:59 PM.
	thruDate = DateFormat(DateAdd("d", currentD - 1, FromDate), "M/D/YYYY") & " 11:59:59 PM";
	// Assign the From Date variable to the First Day of Date to Use variable.	
	firstDayOfDateToUse = fromDate;
</cfscript>