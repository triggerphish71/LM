<cfoutput>Running month end procedure...</cfoutput>

<cfstoredproc procedure="rw.sp_EOM1" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">

<cfprocresult name="rsChangedInvoices">

<cfprocparam type="IN" value="2000" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
<cfprocparam type="IN" value="1" DBVARNAME="@bCheckForChanges" cfsqltype="CF_SQL_BIT">
<cfprocparam type="IN" value="0" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
<cfprocparam type="IN" value="0" DBVARNAME="@bMonthEnd" cfsqltype="CF_SQL_BIT">
<cfprocparam type="OUT" variable=iCnt DBVARNAME="@iChangeCount" cfsqltype="CF_SQL_INTEGER">

</cfstoredproc>

<cfoutput><BR>Changed Invoices: #iCnt#<BR></cfoutput>

<cfoutput query="rsChangedInvoices">
#iHouse_ID# #iInvoiceMaster_ID# #iInvoiceDetail_ID# #mAmount#<br>
</cfoutput>



