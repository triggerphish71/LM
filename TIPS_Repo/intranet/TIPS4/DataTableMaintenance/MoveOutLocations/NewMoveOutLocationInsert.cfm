<!----------------------------------------------------------------------------------------------
| DESCRIPTION: MO Location Insert                               							   |
|----------------------------------------------------------------------------------------------|
| NewMoveOutLocation.cfm                                                            		       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 		Datamaintenance/MoveOutLocations/dsp_NewMoveOutLocation.cfm          			   |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|RSchuette   |03/30/2010  |Created for Project 51267 - MO Codes								   |
|---------------------------------------------------------------------------------------------->

<cfoutput>
<cfquery name="doInsertLocaction" datasource="#application.datasource#">
	Insert into TenantMOLocation (   cDescription
									,cNotes
									,dtrowstart
									,irowstartuser_id)
	values('#form.MOLdesc#',
			<cfif form.MOLnotes neq ''>
				'#form.MOLnotes#',
			<cfelse>
				null,
			</cfif>
			 getdate(),
			 #session.userid#
		)
</cfquery>

<form name="return2page" action="MoveOutLocations.cfm" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<script type='text/javascript'>document.return2page.submit();</script>
	</form>

</cfoutput>