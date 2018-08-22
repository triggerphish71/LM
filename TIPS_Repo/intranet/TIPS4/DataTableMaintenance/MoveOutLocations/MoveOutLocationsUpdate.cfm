<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MO Location Update                               							   |
|----------------------------------------------------------------------------------------------|
| MoveOutLocationsUpdate.cfm                                                        		       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		Datamaintenance/MoveOutLocations/MoveOutLocationsEdit.cfm     			   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|RSchuette   |03/31/2010  |Created for Project 51267 - MO Codes								   |
|---------------------------------------------------------------------------------------------->

<cfoutput>
<!--- <cfquery name="getInfo" datasource="#application.datasource#">
	select * from TenantMOLocation where iTenantMOLocation_ID = #URL.ID#
</cfquery> --->
<cfquery name="UpdateLocation" datasource="#application.datasource#">
	Update TenantMOLocation
	set cDescription = '#form.MOLdesc#',
	cNotes = <cfif form.MOLnotes neq ''>
				'#form.MOLnotes#'
		<cfelse>
				null
		</cfif>
	where iTenantMOLocation_ID = '#URL.ID#'
</cfquery>

<form name="return2page" action="MoveOutLocations.cfm" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<script type='text/javascript'>document.return2page.submit();</script>
	</form>

</cfoutput>