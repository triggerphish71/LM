 
<!--- Concat. Month Day Year for dBirthDate --->
<cfset dtEffectiveStart = form.monthStart & "/" & form.dayStart & "/" & form.yearStart>
<cfset dtEffectiveStart = CreateODBCDateTime(dtEffectiveStart)>
<cfset dtEffectiveEnd = form.monthEnd & "/" & form.dayEnd & "/" & form.yearEnd>
<cfset dtEffectiveEnd = CreateODBCDateTime(dtEffectiveEnd)>

<!--- If Selevel is needed for this charge. Retrieve Info about chosen level --->
<cfif isDefined("form.iSLevelType_ID")>
	<cfquery name="SLevelType" datasource="#application.datasource#">
	select * from SLevelType where iSlevelType_ID = #form.iSLevelType_ID# and dtRowDeleted is null
	</cfquery>
</cfif>

<!--- Insert for entry of new charge --->
<cfquery name = "ChargeInsert" datasource = "#application.datasource#">
	insert into	Charges
	( iChargeType_ID ,iHouse_ID ,cDescription ,cChargeSet ,mAmount ,iQuantity
		,iResidencyType_ID ,iAptType_ID ,cSLevelDescription ,iSLevelType_ID ,iOccupancyPosition 
		,dtEffectiveStart ,dtEffectiveEnd ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, iproductline_id )
	values
	( <cfif form.iChargeType_ID neq ""> #trim(form.iChargeType_ID)#, <cfelse> null, </cfif>
		<cfif form.iHouse_ID neq ""> #trim(form.iHouse_ID)#, <cfset PATH = "House">	<cfelse> null, <cfset PATH = "General"> </cfif>
		<cfif form.cDescription neq ""> '#trim(form.cDescription)#', <cfelse> null,	</cfif>
		<cfif form.cChargeSet neq ""> '#trim(form.cChargeSet)#', <cfelse> null,	</cfif>
		<cfif form.mAmount neq ""> #trim(form.mAmount)#, <cfelse> null, </cfif>
		<cfif form.iQuantity neq ""> #trim(form.iQuantity)#, <cfelse> 1, </cfif>
		<cfif form.iResidencyType_ID neq ""> #trim(form.iResidencyType_ID)#,	<cfelse> 	null,	</cfif>
		<cfif isDefined("form.iAptType_ID")         and  (form.iAptType_ID       neq "")> #trim(form.iAptType_ID)#, <cfelse> 	null,	</cfif>
		<cfif isDefined("form.iSLevelType_ID")     and (form.cDescription       neq "")> #trim(SLevelType.cDescription)#, <cfelse> null, </cfif>
		<cfif isDefined("form.iSLevelType_ID")     and (form.iSLevelType_ID     neq "")> #trim(form.iSLevelType_ID)#,	<cfelse> null, </cfif>
		<cfif isDefined("form.iOccupancyPosition")  and (form.iOccupancyPosition neq "")>	#trim(form.iOccupancyPosition)#,<cfelse>	null,	</cfif>
		<cfif variables.dtEffectiveStart neq "//"> #variables.dtEffectiveStart#, <cfelse>	null, </cfif>
		<cfif variables.dtEffectiveEnd neq "//"> #variables.dtEffectiveEnd#, <cfelse> null, </cfif>
		#CreateODBCDateTime(session.AcctStamp)# ,
		#session.UserID# ,
		getDate()
		<cfif isDefined("form.iproductline_id") and trim(form.iproductline_id) neq "">,#trim(form.iproductline_id)#<cfelse>,null</cfif>
	)
</cfquery>

<cfif dtEffectiveEnd LT Now()> <cfset sort = 'ShowExpired'>
<cfelseif dtEffectiveStart GT Now()> <cfset sort = 'ShowFuture'>
<cfelse> <cfset sort = ''></cfif>

<!--- Relocated to the Charges Page --->
<cfoutput>
<cfif session.UserID EQ 3025>
	<a href="Charges.cfm?ID=#variables.Path#&sort=#sort#">	Continue	</a>
<cfelse>
	<cflocation url="Charges.cfm?ID=#variables.Path#&sort=#sort#" ADDTOKEN="No">
</cfif>
</cfoutput>