<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RDOClose_Mainpage.cfm                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| Gthota     | 10/02/2017 | Create Multiple House closing                                      |
----------------------------------------------------------------------------------------------->
<CFINCLUDE TEMPLATE="../../header.cfm">
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">



<CFOUTPUT>
<!--- Retrieve House Month Information--->
<CFQUERY NAME = "HouseLog" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	bIsPDClosed, bIsCentralized,dtActualEffective,dtAcctStamp,dtCurrentTipsMonth FROM HouseLog
    WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND dtRowDeleted IS NULL
</CFQUERY>
<!--- display houses --->
<CFQUERY NAME="qRegion" DATASOURCE="#APPLICATION.datasource#">
	select iOpsArea_id, cName,iRegion_id from OPSAREA where dtrowdeleted is null
</CFQUERY>
<CFQUERY NAME="qtipsmonth" DATASOURCE="#APPLICATION.datasource#">
	select * from dbo.TIPSInvoiceMonth 
</CFQUERY>


<cfset now = #now()#>
<cfset month = #MonthAsString(Month(Now()))#>
<cfset housemonth = #MonthAsString(Month(qtipsmonth.dtacctstamp))# >
<!---<cfset month1 = #MonthAsString(Month(Now())+1)#>  --->

<cfif #Month(qtipsmonth.dtCurrentTipsMonth)# EQ 1>
<cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)+11)# >
<cfelse>
<cfset month1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)-1)# >
</cfif>
<!---<cfset housemonth1 = #MonthAsString(Month(qtipsmonth.dtCurrentTipsMonth)-1)# > --->

<TABLE border ="1">
	<TR><TH COLSPAN="3"> TIPS Current Invoice Month	</TH></TR>
	<TR>		  
			
		<cfset  TIclosedate = #DateFormat(DateAdd('m', +1, form.dtCurrentTipsMonth),'yyyy-mm-dd')#>
		<cfset  TImonth = #MonthAsString(Month(TIclosedate))#>	
			
		<CFQUERY NAME="qtipsmonth" DATASOURCE="#APPLICATION.datasource#">
			UPDATE dbo.TIPSInvoiceMonth set dtRowdeleted = getdate() where dtrowdeleted is null			
		</CFQUERY>
		
		<CFQUERY NAME="qmonthvalid" DATASOURCE="#APPLICATION.datasource#">
			SELECT * FROM TIPSInvoiceMonth WHERE dtRowDeleted= (SELECT MAX(dtRowDeleted) FROM TIPSInvoiceMonth)
		</CFQUERY>
		
		<cfset monthtoday = #MonthAsString(Month(Now()))#>
		<cfset monthofInvoice = #MonthAsString(Month(qmonthvalid.DtAcctStamp))#>
		<cfif #monthtoday# NEQ #monthofInvoice#>
		 <CFQUERY NAME="qtipsmonth" DATASOURCE="#APPLICATION.datasource#">
			Insert INTO dbo.TIPSInvoiceMonth(cName,dtCurrentTipsMonth,dtAcctStamp,iRowStartUser)
			  Values('#TImonth#','#TIclosedate#',getdate(),'#SESSION.Username#')			
		</CFQUERY>
		</cfif>
	
		
	</TR>
</TABLE>

<CFLOCATION URL='http://#server_name#/intranet/TIPS4/admin/RDOClose_Mainpage.cfm' addtoken="no">

</CFOUTPUT>


