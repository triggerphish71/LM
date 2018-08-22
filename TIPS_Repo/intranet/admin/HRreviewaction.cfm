<!--- HRreview action --->
<cfset datasource = "DMS">

<cfif show is 0>

	<cfif functioncheckforshow is 3>
		<cfquery name="dellist" datasource="#datasource#" dbtype="ODBC">
		Delete from joblistings
		Where form_ndx = #form_ndx#
		</cfquery>
		
		<cfquery name="deleteskills" datasource="#datasource#" dbtype="ODBC">
		Delete from jobcriteria
		Where listingid = #form_ndx#
		</cfquery>
		<cflocation url="confirm.cfm?previewcode=3" addtoken="No">
	</cfif>
	<cfquery name="updatehr" datasource="#datasource#" dbtype="ODBC">
	Update joblistings
	Set reviewedby = '#reviewedby#',
	hractive = #show#
	Where form_ndx = #form_ndx#
	</cfquery>
	<cflocation url="confirm.cfm?previewcode=4&HRID=1" addtoken="No">
	
<cfelseif show is 1>
	<cfquery name="updatehr" datasource="#datasource#" dbtype="ODBC">
	Update joblistings
	Set reviewedby = '#reviewedby#',
	hractive = 1
	Where form_ndx = #form_ndx#
	</cfquery>
	
	<cflocation url="confirm.cfm?previewcode=4&HRID=3&submitter=#submitter#" addtoken="No">
	
<cfelseif show is 2>
	<cfquery name="updatehr" datasource="#datasource#" dbtype="ODBC">
	Update joblistings
	Set reviewedby = '#reviewedby#',
	hractive = 2
	Where form_ndx = #form_ndx#
	</cfquery>
	<cflocation url="confirm.cfm?previewcode=4&HRID=3&submitter=#submitter#" addtoken="No">
<cfelseif show is 3>
		<cflocation url="confirm.cfm?previewcode=4&HRID=3&submitter=#submitter#" addtoken="No">
		
		<!---  --->
		
		<!--- <cfquery name="delcriteria" datasource="#datasource#" dbtype="ODBC">
		Delete from jobcriteria
		Where listingid = #listingindex#
		</cfquery> --->
		
		
</cfif>
