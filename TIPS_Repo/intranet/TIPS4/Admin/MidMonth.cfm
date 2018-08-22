<!--- ==============================================================================
Commit Changes shown in Mid month as directed by the User
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation   -  sp was rw.sp_EOM1
=============================================================================== --->
<cfoutput>Running month end procedure...</cfoutput>
<CFIF SESSION.qSelectedHouse.iHouse_ID EQ 200><CFSET Procname='sp_EOM1'><CFELSE><CFSET Procname='sp_EOM1'></CFIF>
<cfstoredproc procedure="#Procname#" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">

<cfprocresult name="rsChangedInvoices">

<cfprocparam type="IN" value="#SESSION.qSelectedHouse.cNumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
<cfprocparam type="IN" value="1" DBVARNAME="@bCheckForChanges" cfsqltype="CF_SQL_BIT">
<cfprocparam type="IN" value="1" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
<cfprocparam type="IN" value="0" DBVARNAME="@bMonthEnd" cfsqltype="CF_SQL_BIT">
<cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">

</cfstoredproc>

<!--- ==============================================================================
<cfoutput><BR>Changed Invoices: #iCnt#<BR></cfoutput>

<cfoutput query="rsChangedInvoices">
#iHouse_ID# #iInvoiceMaster_ID# #iInvoiceDetail_ID# #OldAmount# #NewAmount#<br>
</cfoutput>
=============================================================================== --->

<CFIF SESSION.UserID IS 3025>
	<A HREF="../Charges/Charges.cfm">	Continue	</A>
<CFELSE>
	<CFLOCATION URL="../Charges/Charges.cfm">
</CFIF>
