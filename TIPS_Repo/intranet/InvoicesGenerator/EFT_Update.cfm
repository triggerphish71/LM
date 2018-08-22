<cfif isdefined("form.Period")>
		<!--- Get the form variables --->
		<cfloop list="#Period#" index="loopvar">
			<!--- create the date structure --->
			<cfset TenantStruct = StructNew()>
			<!--- set the date structure members --->
			<cfset TenantStruct.Period = "">
			<cfset TenantStruct.EFTDate = "">
			<cfif structKeyExists(form,'EFTDate_#loopvar#')>
				<cfset TenantStruct.EFTDate  = form["EFTDate_#loopvar#"]>
				<cfset TenantStruct.Period = #loopvar#>
			</cfif> 
 
			
			<!--- Get EFT Calendar for the specific Period --->
			<cfquery name="GetEFTCalendar" datasource="#application.datasource#">		
				SELECT dtEFT
				FROM EFTCalendar
				WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
			</cfquery> 
			<!--- if there is EFT calendar for the spedific period --->
			<cfif GetEFTCalendar.recordcount gt 0>
				<cfquery name="updateEFT" datasource="#APPLICATION.datasource#">
					UPDATE EFTCalendar
					SET dtEFT = '#TenantStruct.EFTDate#'
					WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
				</cfquery>
				
			<cfelse>
				<cfquery name="insertEFT" datasource="#APPLICATION.datasource#">
					insert EFTCalendar
					(cAppliesToAcctPeriod, dtEFT) 
					values 
					(#TenantStruct.Period#,'#TenantStruct.EFTDate#')
				</cfquery>
			</cfif>  
 
		</cfloop>
	</cfif>

<cflocation url="Index.cfm">
