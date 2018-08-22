<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page updates if a the tenant is to be exempt from late fee from         | 
|                  late fee                                                                    |                                                                        |
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
| Sathya  	 |02/26/10    | Created this page as part of project 20933 Late Fees               |
----------------------------------------------------------------------------------------------->



<!--- <cfoutput>ITenant_id :  #form.iTenant_ID#</cfoutput>


</br>

<cfoutput>User_id who is updating: #SESSION.UserID#

</br>
SolomonKey: #form.RID#
</cfoutput>
</br> --->
<cftransaction>
	<cftry>
<cfquery name= "GetLateFeeInfoForTenant" datasource = "#APPLICATION.datasource#">
	Select bIsLateFeeExempt , iTenant_id
	from TenantState
	where iTenant_id = #form.iTenant_ID#
		and bIsLateFeeExempt is not null
</cfquery>

<cfoutput>
<cfif isdefined("form.iTenant_ID")>	
	<cfif isdefined("form.LateFeeExempt") and form.LateFeeExempt eq 1>
		<cfquery name= "UpdateLateFeeastrue" datasource = "#APPLICATION.datasource#">
				update Tenantstate
				set   bIsLateFeeExempt = 1
	                 ,iAssignedExemptStartUser_ID = #SESSION.UserID#
	                 ,dtAssignedExemptRowStart = getDate()
				where iTenant_id = #form.iTenant_ID#
		</cfquery>
	<cfelse>
		<cfif GetLateFeeInfoForTenant.RecordCount GT 0>
			<cfquery name= "UpdateLateFeeasfalse" datasource = "#APPLICATION.datasource#">
				update Tenantstate
				set   bIsLateFeeExempt = 0
	                 ,iAssignedExemptDeletedUser_ID = #SESSION.UserID#
	                 ,dtAssignedExemptRowDeleted = getDate()
				where iTenant_id = #form.iTenant_ID#
			</cfquery>
		</cfif>
	</cfif>
</cfif>


</cfoutput>

		<cfcatch type = "DATABASE">
			 <cftransaction action = "rollback"/>
				 <cfabort showerror="An error has occured when trying to update.">
		</cfcatch>
		</cftry>
</cftransaction> 



<CFLOCATION URL="LateFeeExemptTenants.cfm" ADDTOKEN="No">

