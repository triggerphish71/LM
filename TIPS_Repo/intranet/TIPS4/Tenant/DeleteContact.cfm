
<!--- 
94541 - 08/17/2012 sfarmer allow for deleting of the contact link record only

 --->
 

<!--- 94541 --->
<cfif  Isdefined('URL.LNK') and (URL.LNK is not "")>

	<!--- ==============================================================================
	Flag link record for contact as deleted
	=============================================================================== --->
	<CFQUERY NAME = "Deletelink" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	LinkTenantContact
		SET		iRowDeletedUser_ID = #SESSION.UserID#,
				dtRowDeleted = GETDATE()
		WHERE	iLinkTenantContact_ID = #url.LNK#
	</CFQUERY>

<cfelse>
	<!--- ==============================================================================
	Flag Record for chosen Contact as Deleted
	=============================================================================== --->
	<CFQUERY NAME = "DeleteContact" DATASOURCE="#APPLICATION.datasource#">
		UPDATE 	Contact
		SET		iRowDeletedUser_ID = #SESSION.UserID#,
				dtRowDeleted =	GetDate()
		WHERE	iContact_ID = #Url.CID#
	</CFQUERY>
	
	
	<!--- ==============================================================================
	Flag link record for contact as deleted
	=============================================================================== --->
	<CFQUERY NAME = "Deletelink" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE 	LinkTenantContact
		SET		iRowDeletedUser_ID = #SESSION.UserID#,
				dtRowDeleted = GETDATE()
		WHERE	iContact_ID = #url.CID#
	</CFQUERY>
</cfif>

<!--- ==============================================================================
Return location to tenand edit screen
=============================================================================== --->
<CFLOCATION URL = "TenantEdit.cfm?ID=#url.ID#">