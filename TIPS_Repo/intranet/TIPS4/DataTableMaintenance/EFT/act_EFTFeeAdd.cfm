<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : Update Account dates for Tenant whose account is closed already	 	       |                                                                        |
|----------------------------------------------------------------------------------------------|
|                 Triggered from act_GetDateDetails.cfm  	                                   |
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
|S Farmer    | 01/27/2012 |  Created Page for Project 75019                                    |
----------------------------------------------------------------------------------------------->

<cfoutput>
 
	
	
	
	<cfquery name="UpdateTenantDates" datasource="#application.datasource#">
		insert into EFTFees (iFromDay, iThruDay,mFeeAmount)
		Values( #form.iFromDay#, #form.iThruDay#, #form.mFeeAmount#)
	</cfquery>
	
  	<cflocation url="dsp_EFTFeeMaintenance.cfm" ADDTOKEN="No">  
 

</cfoutput>