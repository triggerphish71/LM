<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 12/14/2006 | Created                                                            |
----------------------------------------------------------------------------------------------->
<cfparam name="fuse" default="MapGlCodes">

<cfswitch expression="#fuse#">
	<cfcase value="MapGlCodes">
		<!--- Include intranet header --->
		<cfinclude template="../../../header.cfm">
		<!--- Include TIPS header for the House --->
		<cfinclude template="../../Shared/HouseHeader.cfm">
		<cfinclude template="../ActionFiles/act_GetAptTypes.cfm">
		<cfinclude template="../QueryFiles/qry_GetSecondResidentGlCodes.cfm">
		<!--- set the variables for the second resident codes from the query --->
		<cfset secondResidentGlCode = GetSecondResidentGlCodes.cSecondResidentGlCode>
		<cfset secondResidentDiscountGlCode = GetSecondResidentGlCodes.cSecondResidentDiscountGlCode>
		<cfinclude template="../DisplayFiles/dsp_MapGlCodes.cfm">
	</cfcase>
	<cfcase value="SaveGlCodeMap">
		<cfinclude template="../ActionFiles/act_SaveGlCodeMap.cfm">
		<cfset fuse = "MapGlCodes">
		<cflocation url="#CGI.SCRIPT_NAME#">
	</cfcase>
</cfswitch>