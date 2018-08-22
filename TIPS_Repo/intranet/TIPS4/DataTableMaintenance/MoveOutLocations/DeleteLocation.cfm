<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MO Location Delete                               							   |
|----------------------------------------------------------------------------------------------|
| DeleteLocation.cfm                                                            		       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		Datamaintenance/MoveOutLocations/MoveOutLocations.cfm          			   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|RSchuette   |03/30/2010  |Created for Project 51267 - MO Codes								   |
|---------------------------------------------------------------------------------------------->

<cfoutput>
<cfquery name="doDeleteLocaction" datasource="#application.datasource#">
	Update TenantMOLocation
	set dtRowDeleted = getdate(),
		iRowDeletedUser_ID = #session.userid#
	where  iTenantMOLocation_ID = #URL.ID#
</cfquery>

<form name="return2page" action="MoveOutLocations.cfm" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<script type='text/javascript'>document.return2page.submit();</script>
	</form>

</cfoutput>