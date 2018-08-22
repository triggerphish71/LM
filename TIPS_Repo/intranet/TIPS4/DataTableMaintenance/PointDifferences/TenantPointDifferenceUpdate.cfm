<!----------------------------------------------------------------------------------------------
| DESCRIPTION - PointDifferences/TenantPointDifferencesUpdate.cfm                                |
|----------------------------------------------------------------------------------------------|
| Display database summary for saved move out information                                      |
| Called by: 		DataTableMaintenance/TenantPointDifferences.cfm						  	                                   |
| Calls/Submits:	TenantPointDifferences.cfm                                              |
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
|R Schuette  | 04/21/2010 | Original Authorship              								   |
|S Farmer    | 05/29/2013 | added  "and atm.bFinalized = '1'" to   GetPoints query   #106732   |
----------------------------------------------------------------------------------------------->


<cfoutput>

	<cfset ten_id = #form.TenantSelect#>
	<cfquery name="GetPoints" datasource="#application.datasource#">
		Select atm.iSPoints 
		from AssessmentToolMaster atm
		where atm.iTenant_id = #ten_id#
		and atm.bBillingActive = '1' 
		and atm.dtRowDeleted is null
		and atm.bFinalized = '1'		
	</cfquery>
	
	<cfquery name="UpdateTenantDates" datasource="#application.datasource#">
		update TenantState
		set iSPoints = #GetPoints.iSPoints#
		,irowstartuser_id = #session.userid#
		where iTenant_ID = #ten_id#
	</cfquery>
	
	<!--- <cfinclude template="dsp_TenantPointDifferences.cfm"> --->
	<!--- <CFLOCATION URL = "dsp_TenantPointDifferences.cfm" addtoken="NO"> --->
	<!--- <form name="return2page" action="../PointDifferences/dsp_TenantPointDifferences.cfm" method="POST" > --->
 	<form name="return2page" action="TenantPointDifferences.cfm" method="POST" >
	<!--- use javascript to submit and post form back to page --->
	<script type='text/javascript'>document.return2page.submit();</script>
	</form>  
	
</cfoutput>