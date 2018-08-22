<cfparam name="useHouseId" default="true">
<cfparam name="id" default="0">

<cfif useHouseId>
	<cfquery name="getSubAccount" datasource="#application.datasource#">
		select 
			 cGLsubaccount
			,EHSIFacilityID 
		from 
			HOUSE 
		where 
			dtRowDeleted IS NULL 
		and 
			iHouse_ID = #iHouse_ID#
	</cfquery>
<cfelse>
	<cfquery name="getSubAccount" datasource="#application.datasource#">
		select 
			 cGLsubaccount
			,EHSIFacilityID 
		from 
			HOUSE 
		where 
			dtRowDeleted IS NULL 
		and 
			cGLSubAccount = '#SubAccountNumber#'
	</cfquery>
</cfif>


	