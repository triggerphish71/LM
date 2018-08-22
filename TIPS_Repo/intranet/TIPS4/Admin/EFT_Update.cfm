
 <!--- 
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|            |            |                                                                    |
----------------------------------------------------------------------------------------------->
<cfif isdefined("form.Period")>
		<!--- Get the form variables --->
		<cfloop list="#Period#" index="loopvar">
			<!--- create the date structure --->
			<cfset TenantStruct = StructNew()>
			<!--- set the date structure members --->
			<cfset TenantStruct.Period = "">
			<cfset TenantStruct.EFTDate1 = "">
			<cfset TenantStruct.EFTDate2 = "">
			<cfset TenantStruct.EFTDate3 = "">
			<cfset TenantStruct.EFTDate4 = "">
			<cfset TenantStruct.EFTDate5 = "">												
			<cfif structKeyExists(form,'EFTDate1_#loopvar#')>
				<cfset TenantStruct.EFTDate1 = form["EFTDate1_#loopvar#"]>
				<cfset TenantStruct.EFTDate2 = form["EFTDate2_#loopvar#"]>
				<cfset TenantStruct.EFTDate3 = form["EFTDate3_#loopvar#"]>
				<cfset TenantStruct.EFTDate4 = form["EFTDate4_#loopvar#"]>
				<cfset TenantStruct.EFTDate5 = form["EFTDate5_#loopvar#"]>																
				<cfset TenantStruct.Period = #loopvar#>
			</cfif> 
<cfoutput> 				#tenantStruct.EFTDate1#<BR/>
				#TenantStruct.EFTDate2#<BR/>
				#TenantStruct.EFTDate3#<BR/>
				#TenantStruct.EFTDate4#<BR/>
				#TenantStruct.EFTDate5#	<BR/>															
				 #loopvar# </cfoutput>
			
			  Get EFT Calendar for the specific Period 
			<cfquery name="GetEFTCalendar" datasource="#application.datasource#">		
				SELECT dtEFT1, dtEFT2,dtEFT3,dtEFT4,dtEFT5
				FROM EFTCalendar2
				WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
			</cfquery>  
			<!--- if there is EFT calendar for the spedific period   --->
			<cfif GetEFTCalendar.recordcount gt 0>
			<CFIF tenantStruct.EFTDate1 IS NOT "">
				<cfquery name="updateEFT" datasource="#APPLICATION.datasource#">
					UPDATE EFTCalendar2
					SET dtEFT1 = '#TenantStruct.EFTDate1#'
					WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
				</cfquery>
			</CFIF>	
			<CFIF tenantStruct.EFTDate2 IS NOT "">
				<cfquery name="updateEFT2" datasource="#APPLICATION.datasource#">
					UPDATE EFTCalendar2
					SET dtEFT2 = '#TenantStruct.EFTDate2#'
					WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
				</cfquery>
			</CFIF>	
			<CFIF tenantStruct.EFTDate3 IS NOT "">
				<cfquery name="updateEFT3" datasource="#APPLICATION.datasource#">
					UPDATE EFTCalendar2
					SET dtEFT3 = '#TenantStruct.EFTDate3#'
					WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
				</cfquery>	
			</CFIF>	
			<CFIF tenantStruct.EFTDate4 IS NOT "">
				<cfquery name="updateEFT4" datasource="#APPLICATION.datasource#">
					UPDATE EFTCalendar2
					SET dtEFT4 = '#TenantStruct.EFTDate4#'
					WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
				</cfquery>
			</CFIF>	
			<CFIF tenantStruct.EFTDate5 IS NOT "">
				<cfquery name="updateEFT5" datasource="#APPLICATION.datasource#">
					UPDATE EFTCalendar2
					SET dtEFT5 = '#TenantStruct.EFTDate5#'
					WHERE cAppliesToAcctPeriod = #TenantStruct.Period#
				</cfquery>							
			</CFIF>	
				
			<cfelse>
				<cfquery name="insertEFT" datasource="#APPLICATION.datasource#">
					insert EFTCalendar2
					(cAppliesToAcctPeriod, dtEFT) 
					values 
					(#TenantStruct.Period#,'#TenantStruct.EFTDate#')
				</cfquery>
			</cfif>
			 
		</cfloop>
	</cfif>
<cflocation url="Generate_payer_email_notification.cfm">
<!--- <cflocation url="Index2.cfm"> --->
