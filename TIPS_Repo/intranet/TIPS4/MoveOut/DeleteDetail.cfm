<!----------------------------------------------------------------------------------------------
| DESCRIPTION - MoveOut/DeleteDetail.cfm                                                       |
|----------------------------------------------------------------------------------------------|
| 													                                           |
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
| mlaw       | 08/07/2006 | Create an initial DeleteDetail page                     	       |
|MLAW		 | 10/12/2006 | Set up a ShowBtn paramater which will determine when to show the   |
|		     |            | menu button.  Add url parament ShowBtn=#ShowBtn# to all the links  |
----------------------------------------------------------------------------------------------->
<!--- 08/07/2006 MLAW show menu button --->
<CFPARAM name="ShowBtn" default="True">

<cftransaction>

<cftry>
	<!--- delete chosen detail --->
	<CFQUERY NAME="DeleteDetail" DATASOURCE = "#APPLICATION.datasource#">
		update InvoiceDetail
		set dtRowDeleted = getDate(), iRowDeletedUser_ID = #SESSION.UserID#
		where dtrowdeleted is null and iInvoiceDetail_ID = #url.DID#
	</CFQUERY>
	
	<cfcatch type="any">
		<!--- look for deadlocks --->
		<cfif isDefined("Error.Diagnostics") and (FIND("dead",Error.Diagnostics,1) gt 0 or FIND("Serialization",Error.Diagnostics,1) gt 0)>
			<!--- re-submit if deadlock --->
			<cfquery name="DeleteDetail" datasource="#APPLICATION.datasource#">
				update InvoiceDetail
				set dtRowDeleted = getDate(), iRowDeletedUser_ID = #SESSION.UserID#
				where dtrowdeleted is null and iInvoiceDetail_ID = #url.DID#
			</cfquery>
		</cfif>
	</cfcatch>

</cftry>

</cftransaction>


<CFIF SESSION.USERID IS 3025>
	<CFOUTPUT>
		<A HREF="Moveoutform.cfm?ID=#url.ID#&edit=1&Rsn=#url.rsn#&stp=#url.stp#&ShowBtn=#ShowBtn#">Continue</A>
	</CFOUTPUT>
<CFELSE>
	<CFLOCATION URL="MoveOutForm.cfm?ID=#URL.ID#&edit=1&Rsn=#url.rsn#&stp=#url.stp#&ShowBtn=#ShowBtn#">
</CFIF>	

