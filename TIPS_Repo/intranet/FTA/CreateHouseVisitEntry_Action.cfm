<!--- Instantiate the Helper object. --->
<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
	
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

<cfif isDefined("url.NumberOfMonths")>
	<cfset numberOfMonths = #url.NumberOfMonths#>
<cfelse>
	<cfset numberOfMonths = 3>
</cfif>
		
<cfif isDefined("url.Role")>
	<cfset roleFilter = #url.Role#>
<cfelse>
	<cfset roleFilter = 0>
</cfif>	

<cfinclude template="Common/DateToUse.cfm">

<cftry>
	<cfset dsRoles = #helperObj.FetchHouseVisitRoles()#>
	<cfset entryDate = #Form.txtEntryDate#>
	<cfif Form.hdnIsSuperUser eq "False">
		<cfset entryUserRoleId = #helperObj.FetchHouseVisitRoleIdByName(dsRoles, Form.txtEntryUserRole)#>
	<cfelse>
		<cfset entryUserRoleId = #Form.ddlEntryUserRole#>
	</cfif>
	<cfset entryUserId = #Form.hdnEntryUserId#>
	<cfset entryUserFullName = #Form.txtEntryUserFullName#>
	<cfset entryHouseId = #url.iHouse_ID#>
	
	<cfset timeStamp = #Now()#>
	<cfset entryCreateDate = DateFormat(timeStamp, "mm/dd/yyyy") & " " & TimeFormat(timeStamp, "hh:mm:ss tt")>
	
	<cfif entryDate eq "">
		<cfset entryDate = entryCreateDate>
	</cfif>
	
	<cfset entryDate = DateFormat(entryDate, "mm/dd/yyyy") & " 12:00:00 AM">
	
	<cfquery name="CloseExistingEntries" datasource="#FTAds#">
		UPDATE
			dbo.HouseVisitEntries
		SET
			dtClosed = '#DateFormat(timeStamp, "mm/dd/yyyy") & " " & TimeFormat(timeStamp, "hh:mm:ss tt")#'
		WHERE
			dtClosed IS NULL AND
			iHouseId = #houseId# AND
			iRole = #entryUserRoleId#;
	</cfquery>
	
	<cfquery name="InsertNewEntry" datasource="#FTAds#">
		INSERT INTO
			dbo.HouseVisitEntries
			(
				iRole,
				iHouseId,
				cUserName,
				cUserDisplayName,
				dtHouseVisit,
				dtCreated
			)
			VALUES
			(
				#entryUserRoleId#,
				#entryHouseId#,
				'#entryUserId#',
				'#entryUserFullName#',
				'#entryDate#',
				'#entryCreateDate#'
			);
	</cfquery>
	
	<cfquery name="FetchNewEntry" datasource="#FTAds#">
		SELECT
			iEntryId
		FROM
			dbo.HouseVisitEntries
		WHERE
			iRole = #entryUserRoleId# AND
			iHouseId = #entryHouseId# AND
			cUserName = '#entryUserId#' AND
			cUserDisplayName = '#entryUserFullName#' AND
			dtHouseVisit = '#entryDate#' AND
			dtCreated = '#entryCreateDate#';
	</cfquery>
	
	<cfif FetchNewEntry.RecordCount Is "0">
		<cfoutput>
			There was a problem locating the newly created House Visit Entry record.  <br />
			Please Contact the IT Help Desk at (888) 342-4252, if the problem continues. <br />
			<a href="HouseVisits.cfm?NumberOfMonths=#numberOfMonths#&Role=#roleFilter#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
				Return to the House Visits Page
			</a>
		</cfoutput>
	<cfelse>
		<cflocation url="EditHouseVisitEntry.cfm?NumberOfMonths=#numberOfMonths#&Role=#roleFilter#&Save=No&EntryId=#FetchNewEntry.iEntryId#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
	</cfif>
<cfcatch type="any">
	<cfoutput>
		There was a problem creating the new House Visit Entry record.  <br />
		Please Contact the IT Help Desk at (888) 342-4252, if the problem continues. <br />
		<a href="HouseVisits.cfm?NumberOfMonths=#numberOfMonths#&Role=#roleFilter#&iHouse_ID=#houseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">
			Return to the House Visits Page
		</a>
	</cfoutput>
</cfcatch>
</cftry>
