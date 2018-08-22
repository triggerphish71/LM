
<CFOUTPUT>
	#form.fieldnames#<BR>
	#form.iAptAddress_ID#<BR>
</CFOUTPUT>


<CFTRANSACTION>
	<!--- ==============================================================================
	Flag the chosen record as deleted
	=============================================================================== --->
	<CFQUERY NAME="qDeleteApt" DATASOURCE="#APPLICATION.datasource#">
		UPDATE	AptAddress
		SET		dtRowDeleted = GetDate(),
				iRowDeletedUser_ID = #SESSION.USERID#
		WHERE	iAptAddress_ID = #form.iAptAddress_ID#
	</CFQUERY>
</CFTRANSACTION>

<CFLOCATION URL="HouseApts.cfm">
