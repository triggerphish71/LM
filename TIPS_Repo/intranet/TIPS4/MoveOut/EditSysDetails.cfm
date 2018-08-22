
<CFOUTPUT>
	#url.MasterID#<BR>
	#HTTP.REFERER#<BR>
	
	<!--- ==============================================================================
	Retrieve System Time
	=============================================================================== --->
	<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
		SELECT	getdate() as TimeStamp
	</CFQUERY>
	<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>
	
	<CFQUERY NAME="qSetSysEdit" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	InvoiceMaster
		SET		bEditSysDetails = <CFIF IsDefined("form.OverRideSystem") AND form.OverRideSystem EQ 'Activate'> 1, <CFELSE> NULL, </CFIF>
				iRowStartUser_ID = #SESSION.UserID#,
				dtRowStart = #TimeStamp#
		WHERE	iInvoiceMaster_ID = #url.MasterID#
	</CFQUERY>
	
<CFIF SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146>
	<A HREF="#HTTP.REFERER#">Return</A>
<CFELSE>
	<CFLOCATION URL="#HTTP.REFERER#">
</CFIF>	


</CFOUTPUT>
