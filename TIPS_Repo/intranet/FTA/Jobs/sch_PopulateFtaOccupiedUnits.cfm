<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
| Gets all of the Apartments and there associated Type (private, mediciad, etc...) Weights for |
| the specified Compare Date and Updates that data to the FTA Dashboard Occupancy table.  If   |
| no CompareDate is specified in the URL Query String, then the Job will Update the previous   |
| Period's Occupancy, which has a dtOccupancy Date of the last day of the previous period.     |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| bkubly     | 05/04/2009 | Created                                             			   |
----------------------------------------------------------------------------------------------->


<cfset dsn = "TIPS4">

<cfif isDefined("url.compareDate")>
	<cfset compareDate = #url.compareDate#>
<cfelse>
	<!--- Stores the last day of the previous month. --->
	<cfset compareDate = DateFormat(DateAdd("d", -1, DateFormat(DateAdd("d", -1, Now()),"mm/01/yyyy") & " 12:00:00 AM"), "mm/dd/yyyy") & " 12:00:00 AM">
</cfif>

<cfif isDefined("url.houseName")>
	<cfset houseName = #url.houseName#>
<cfelse>
	<cfset houseName = "*">
</cfif>

<cftry>
	<!--- Get a list of every moved in tenant for the specified day. --->
	<cfquery name="GetTenants" datasource="#dsn#">
		select distinct
			 g.cName as Region
			,o.cName as Division
			,h.cStateCode
			,h.iHouse_ID As iHouseId
			,h.cNumber - 1800 AS houseNumber
			,h.cName
			,y.cdescription
			,a.cAptNumber
			,e.cdescription AS roomType
			,count(y.cDescription) as numPayer
		from
			ResidentOccupancy r
		inner join
			house h on h.ihouse_id = r.ihouse_id
		and
			h.bissandbox = 0
		inner join
			opsarea o on o.iopsarea_id = h.iopsarea_id
		inner join
			region g on g.iregion_id = o.iregion_id
		inner join
			tenant t on t.itenant_id = r.itenant_id
		inner join
			tenantstate s on s.itenant_id = t.itenant_id
		inner join
			residencytype y on y.iresidencytype_id = r.iresidencytype_id
		inner join
			aptaddress a on a.iaptaddress_id = r.iaptaddress_id
		inner join
			apttype e on e.iapttype_id = a.iapttype_id
		where
			dtOccupancy = '#DateFormat(compareDate,"mm/dd/yyyy")#'
		and
			ideletedactivitylog_id is null
		and
			cType = 'B'
		<cfif houseName neq "*">
			and
				h.cName = '#houseName#'
		</cfif>
			group by
				 a.cAptNumber
				,e.cdescription
				,y.cdescription
				,h.cName
				,h.cStateCode
				,h.iHouse_ID
				,h.cNumber
				,o.cName
				,g.cName
			order by
				 g.cname
				,o.cname
				,h.cname
				,a.captnumber
	</cfquery>
	
	<!--- Build the Occupancy Array. --->
	<cfscript>
		// Instantiate the array used to store the house number and occupancy.
		houseOccupancyList = ArrayNew(1);
		
		// Stores the House Totals.
		houseMedicaid = 0;
		houseMedicaidDouble = 0;
		housePrivate = 0;
		housePrivateDouble = 0;
		houseRespite = 0;
		houseAptTotal = 0;
	
		// Stores the Report Totals.	
		reportMedicaid = 0;
		reportMedicaidDouble = 0;
		reportPrivate = 0;
		reportPrivateDouble = 0;
		reportRespite = 0;
		reportAptTotal = 0;				
	
		//loop through the get tenants query
		for(i = 1; i lte GetTenants.RecordCount; i = i + 1)
		{
			dtlMedicaid = 0;
			dtlMedicaidDouble = 0;
			dtlPrivate = 0;
			dtlPrivateDouble = 0;
			dtlRespite = 0;
			dtlAptTotal = 0;
			dtlAptNumber = "?";
			
				
			//set the apartment number
			dtlAptNumber = GetTenants["cAptNumber"][i];
			
			//check the next apartment number
			if(i lt GetTenants.RecordCount)
			{
				nextApt = GetTenants["cAptNumber"][i + 1];
			}
			else
			{
				nextApt = 0;
			}
			
			//if the next apartment then its a mixed payer type apartment, this is considered a private unit
			if(dtlAptNumber eq nextApt)
			{
				dtlPrivateDouble = dtlPrivateDouble + 1;
				i = i + 1;
			}
			//double medicaid
			else if(GetTenants["numPayer"][i] gt 1 AND FindNoCase("medicaid",GetTenants["cDescription"][i]) neq 0)
			{
				dtlMedicaidDouble = dtlMedicaidDouble + 1;
			}
			//double private
			else if(GetTenants["numPayer"][i] gt 1 AND FindNoCase("private",GetTenants["cDescription"][i]) neq 0)
			{
				dtlPrivateDouble = dtlPrivateDouble + 1;
			}
			//medicaid
			else if(FindNoCase("medicaid",GetTenants["cDescription"][i]) neq 0)
			{
				//check if this is a companion studio, only.5 since there is only 1 person in this studio
				if(FindNoCase("companion",GetTenants["roomType"][i]) neq 0)
				{
					dtlMedicaid = dtlMedicaid + .5;
				}
				else
				{
					dtlMedicaid = dtlMedicaid + 1;
				}
			}
			//private
			else if(FindNoCase("private",GetTenants["cDescription"][i]) neq 0)
			{
				//check if this is a companion studio, only.5 since there is only 1 person in this studio
				if(FindNoCase("companion",GetTenants["roomType"][i]) neq 0)
				{
					dtlPrivate = dtlPrivate + .5;
				}
				else
				{
					dtlPrivate = dtlPrivate + 1;
				}
			}
			//respite
			else if(FindNoCase("respite",GetTenants["cDescription"][i]) neq 0)
			{
				dtlRespite = dtlRespite + 1;
			}
		
			isLastHouseRow = false;
			isLastReportRow = false;
			// Check if this is the last row for the house.
			if (i lt GetTenants.recordCount)
			{
				if (GetTenants["cName"][i] neq GetTenants["cName"][i + 1])	
				{
					isLastHouseRow = true;
				}
			}
			else
			{
				isLastHouseRow = true;
				isLastReportRow = true;	
			}
			dtlAptTotal = dtlMedicaidDouble + dtlPrivateDouble + dtlMedicaid + dtlPrivate + dtlRespite;
			
			// Increment the house totals.
			houseMedicaid = houseMedicaid + dtlMedicaid;
			houseMedicaidDouble = houseMedicaidDouble + dtlMedicaidDouble;
			housePrivate = housePrivate + dtlPrivate;
			housePrivateDouble = housePrivateDouble + dtlPrivateDouble;
			houseRespite = houseRespite + dtlRespite;
			houseAptTotal = houseAptTotal + dtlAptTotal;
			
			// Check if the house totals should be output.
			if (isLastHouseRow eq true)
			{
				// Create the house occupancy strucutre
				houseOccupancy = StructNew();
				// Set the structure's House Id field.
				houseOccupancy.HouseId = GetTenants["iHouseId"][i];
				// Set the structure's Occupancy field.
				houseOccupancy.Occupancy = houseAptTotal;
				// Add the current House Occupancy Structure to the House Occupancy List.
				AddIt = ArrayAppend(houseOccupancyList, houseOccupancy);
				
				// Increment the grand totals.
				reportMedicaid =  reportMedicaid + houseMedicaid;
				reportMedicaidDouble = reportMedicaidDouble + houseMedicaidDouble;
				reportPrivate = reportPrivate + housePrivate;
				reportPrivateDouble = reportPrivateDouble + housePrivateDouble;
				reportRespite = reportRespite + houseRespite;
				reportAptTotal = reportAptTotal + houseAptTotal;
				// Clear the House Totals.
				houseMedicaid = 0;
				houseMedicaidDouble = 0;
				housePrivate = 0;
				housePrivateDouble = 0;
				houseRespite = 0;
				houseAptTotal = 0;	
			}		
		}
	</cfscript>
	<!--- Used to set the Last Updated field in the database. --->
	<cfset timeStamp = DateFormat(Now(), "mm/dd/yyyy") & " " & TimeFormat(Now(), "medium")>
	<!--- Loop through all of the Occupancy Elements in the Array. --->
	<cfloop from="1" to="#ArrayLen(houseOccupancyList)#" index="currentHouse">
		<!--- Update the DashboardOccupancyInfo Table's fOccupiedUnits field. --->
		<cfquery name="updDashboardOccupancy" datasource="#ftaDs#">
			UPDATE
				DashboardOccupancyInfo
			SET
				fOccupiedUnits = #houseOccupancyList[currentHouse].Occupancy#,
				dtLastUpdate = '#timeStamp#'
			WHERE
				iHouseID = #houseOccupancyList[currentHouse].HouseId# AND
				dtOccupancy = '#compareDate#';
		</cfquery>
	</cfloop>
	<!--- Notify the User that the UPDATE Operation succeeded. --->
	<cfoutput>
		The DashboardOccupancyInfo Table was successfully updated with the requested Occupancy Data.
	</cfoutput>
<cfcatch type="any">
	<!--- Notify the User that the UPDATE Operation failed.  There was an exception thrown. --->
	<cfoutput>
		There was an issue calculating the Occupancy and Updating the DashboardOccupancyInfo Table.
	</cfoutput>	
</cfcatch>
</cftry>

