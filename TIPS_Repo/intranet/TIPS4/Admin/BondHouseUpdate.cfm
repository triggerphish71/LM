<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is to Update the House with Bond House option as per Project 20125 |                                                                        |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| RTS		 |11/10/08    | Created	code			                                           |
----------------------------------------------------------------------------------------------->



<cfoutput >

<cfquery name="BondHouse" datasource="#APPLICATION.datasource#">
select * from House where dtRowDeleted is null
<cfif IsDefined("form.iHouse_ID")>
	<cfif form.iHouse_ID neq "">
		and iHouse_ID = #form.iHouse_ID# 
	<cfelseif IsDefined("url.ID")> and iHouse_ID = #form.iHouse_ID# 
	</cfif>
</cfif>		
</cfquery> 

	<!--- 26955  RTS - 11/10/08 Changed to drop all bond designations for apts
								and tenants if house goes to nonbond. 
	--->
	<cfquery name="BondHouseUpdate" datasource="#application.datasource#">
		<cfif #form.iBondhouse# eq 1>
			update House
			set  iBondHouse = '#form.iBondhouse#'	
			where iHouse_ID = #url.id#
			
			update AptAddress
			set bBondIncluded = 1 
			where iHouse_ID = #url.id#
			and dtRowDeleted is null
		<cfelse> 
			update House
			set  iBondHouse = '#form.iBondHouse#'
			where iHouse_ID = #url.id#
			
			<!--- update AptAddress
			set bIsBond = 0
			where iHouse_ID= #session.qSelectedHouse.iHouse_ID#
			
			update tenant
			set bIsBond = 0
			where iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			and iTenant_ID in (select itenant_id from TenantState 
								where iTenantStateCode_ID = 2 
								and iAptAddress_ID in (select iaptaddress_id 
															from AptAddress  
															where iHouse_ID = #session.qSelectedHouse.iHouse_ID#) 
								and dtRowDeleted is null)
			and dtRowDeleted is null --->
		</cfif> 
	</cfquery>

<cflocation url="BondInfo.cfm" ADDTOKEN="No">
</cfoutput>
