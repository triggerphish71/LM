<!--- 
92526  07/12/2012  sfarmer  adjusted iOccupancyPosition and iAptType_ID so they cannot be reset to null if nothing is entered for these fields
 --->
<cfoutput>
<!--- Concat. Month Day Year for dtEffective Start/End --->
<cfset dtEffectiveStart = form.monthStart & "/" & form.dayStart & "/" & form.yearStart>
<cfset dtEffectiveEnd = form.monthEnd & "/" & form.dayEnd & "/" & form.yearEnd>

<!--- Retrieve Info about chosen level --->
<cfif isDefined("iSLevelType_ID")>
<cfquery name="SLevelType" datasource="#application.datasource#">
select * from SLevelType where dtRowDeleted is null	and iSlevelType_ID = #form.iSLevelType_ID#
</cfquery>
</cfif>

<!--- Update Chosen Charge Information --->
<cfquery name="UpdateCharge" datasource="#application.datasource#">
		update Charges
		set <cfif form.iChargeType_ID neq ""> iChargeType_ID = #trim(form.iChargeType_ID)#, <cfelse> iChargeType_ID = null, </cfif>
		<cfif form.iHouse_ID neq ""> iHouse_ID = #trim(form.iHouse_ID)#, <cfset PATH = "House"> <cfelse> iHouse_ID = null, <cfset PATH = "General"> </cfif>
		<cfif form.cDescription neq ""> cDescription = '#trim(form.cDescription)#', <cfelse> cDescription = null, </cfif>
		<cfif form.cChargeSet neq ""> cChargeSet = '#trim(form.cChargeSet)#', <cfelse> cChargeSet = null, </cfif>
		<cfif form.mAmount neq ""> mAmount = #LSNumberFormat(LSParseCurrency(form.mAmount), "99999999.99")#, <cfelse> mAmount = null,</cfif>
		<cfif form.iQuantity neq ""> iQuantity = #trim(form.iQuantity)#, <cfelse> iQuantity = 1, </cfif>
		<cfif form.iResidencyType_ID neq ""> iResidencyType_ID = #trim(form.iResidencyType_ID)#, <cfelse> iResidencyType_ID = null, </cfif>
		<cfif IsDefined("form.iAptType_ID") and form.iAptType_ID neq "">iAptType_ID = #trim(form.iAptType_ID)#,</cfif>
		<cfif IsDefined("form.iSLevelType_ID") and form.iSLevelType_ID neq "">cSLevelDescription = #trim(SLevelType.cDescription)#, <cfelse>cSLevelDescription = null,</cfif>
		<cfif IsDefined("form.iSLevelType_ID") and form.iSLevelType_ID neq "">iSLevelType_ID = #trim(form.iSLevelType_ID)#,<cfelse>iSLevelType_ID = null,</cfif>
		<cfif IsDefined("form.iOccupancyPosition") and form.iOccupancyPosition neq "">iOccupancyPosition = #trim(form.iOccupancyPosition)#,</cfif>
		<cfif variables.dtEffectiveStart neq "//">dtEffectiveStart = '#variables.dtEffectiveStart#', <cfelse>dtEffectiveStart = null,</cfif>
		<cfif variables.dtEffectiveEnd neq "//">dtEffectiveEnd = '#variables.dtEffectiveEnd#',<cfelse>dtEffectiveEnd = null,</cfif>
		dtAcctStamp =	'#session.AcctStamp#', iRowStartUser_ID = #session.UserID#, dtRowStart=getDate()
		<cfif isDefined("form.iproductline_id") and trim(form.iproductline_id) neq "">,iproductline_id=#trim(form.iproductline_id)#<cfelse>,iproductline_id=null</cfif>
		where iCharge_ID = #form.iCharge_ID#
</cfquery>

<cfif dtEffectiveEnd lt Now()> <cfset sort = 'ShowExpired'> 
<cfelseif dtEffectiveStart gt Now()> <cfset sort = 'ShowFuture'>
<cfelse> <cfset sort=''> </cfif>

<!--- Relocate to the Charges page --->	
<cfif auth_user eq "ALC\PaulB">
	<a href="Charges.cfm?ID=#variables.Path#&sort=#sort#">Continue</a>
<cfelse>
	<cflocation url="Charges.cfm?ID=#variables.Path#&sort=#sort#" ADDTOKEN = "No">
</cfif>
</cfoutput>
