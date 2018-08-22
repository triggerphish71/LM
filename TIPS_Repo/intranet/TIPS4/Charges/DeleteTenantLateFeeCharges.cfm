<!--- *********************************************************************************************
Name:       DeleteTenantLateFeeCharges.cfm
Type:       Template
Purpose:    Displays the late fee that need to be deleted. 
			 

Called by: DisplayLateFee.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
                      

Calls: 
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    url.TenantID                           Paramaters are passed by the DisplayLateFee.cfm
	url.invoiceLatefeeID

   
Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
Sathya                  03/12/2010       Created this file for project 20933 Late Fee

sathya                   07/19/2010     Made modification according to Project 20933 Part-B
										  rename the button as Waived instead of Delete.
--->

<!--- =============================================================================================
Include Intranet Header
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../header.cfm">
<!--- See if the required variables exisits if not throw an error --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	 <cfif NOT isDefined("url.tenantid")>
	   <!--- throw the error --->
	   <cfthrow message = "Tenant ID not found.">
	</cfif>
	<cfif NOT isDefined("url.invoicelatefeeid")>
	   <!--- throw the error --->
	   <cfthrow message = "Invoice late fee id not found.">
	</cfif>
	
<cfcatch type = "application">
  <cfoutput>
    <p>#cfcatch.message#</p>
	<br></br>
	<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
 </cfoutput>
</cfcatch>
</cftry>


<cfoutput>
<cfquery name="getTenantLateFeeRecordsforDelete" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * 
				FROM TenantLateFee ltf
				Where iinvoicelateFee_ID = #url.invoiceLatefeeID#
                     and iTenant_id =#url.TenantID#
                    and dtrowdeleted is null
</cfquery>
<!--- Commented this as the req changed there will be no adjustments in partial payments.
<cfquery name="getPartialPayment" datasource="#APPLICATION.datasource#">
		select   iInvoiceLateFee_ID , sum(mLateFeePartialPayment) as LateFeePayment
		from TenantLateFeeAdjustmentDetail 
		where iInvoiceLateFee_ID in ( SELECT ltf.iInvoiceLateFee_ID
										FROM TenantLateFee ltf
										Where iinvoicelateFee_ID = #url.invoiceLatefeeID#
						                     and ltf.iTenant_id =#url.TenantID#
						                    and ltf.dtrowdeleted is null
									)
		and dtrowdeleted is null
		Group by  iInvoiceLateFee_ID
	</cfquery> --->
	
<cfquery name="getTenantinfo" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * 
				FROM Tenant
				Where iTenant_id =#url.TenantID#
                    and dtrowdeleted is null
</cfquery>

 <cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0) or (ListContains(SESSION.groupid, '284') gt 0)> 
	<table>
	
		<TR><TH COLSPAN=100%>List of Late Fee for <cfoutput>#getTenantinfo.cFirstName# #getTenantinfo.cLastName#</cfoutput></TH></TR>
		<tr>
		<td align="center"><b>SolomonKey</b> </td>
		<td align="center"><b>Late Fee</b> </td>
		<td align="center"><b>Acct Period</b> </td>
		<!--- 07/19/2010 Project 20933 Part-B modified it to call it as Waived instead of delete. commented and rewrote it --->
		<!--- <td align="center"><b>Reason for Delete </b></td>
		<td align="center"><b>Delete</b></td> --->
		<td align="center"><b>Reason for Waived </b></td>
		<td align="center"><b>Waived</b></td>
		<!---Project 20933 Part-B end of code ---> 
	</tr>
	<cfloop query='getTenantLateFeeRecordsforDelete'>
<FORM NAME="Form#getTenantLateFeeRecordsforDelete.iInvoiceLateFee_ID#" Action="updateDeleteTenantLateFeeCharge.cfm"  METHOD="POST">
	<tr>
		<td align="center">#getTenantLateFeeRecordsforDelete.cSolomonKey# </td>
			<input type="hidden" name="SolomonKey" value="#getTenantLateFeeRecordsforDelete.cSolomonKey#">
			<input type="hidden" name="tenantid" value="#getTenantLateFeeRecordsforDelete.iTenant_ID#">
			<input type="hidden" name="invoicelatefeeid" value="#getTenantLateFeeRecordsforDelete.iInvoiceLateFee_ID#">
			<!--- If there was a partial payment --->
			<!--- <cfif getTenantLateFeeRecordsforDelete.bPartialPaid eq 1>
					<cfquery name="getPaidLateFeeAmount" dbtype="query">
						Select LateFeePayment from getPartialPayment where iInvoiceLateFee_ID = #getTenantLateFeeRecordsforDelete.iInvoiceLateFee_ID#
					</cfquery>
					<cfset PaidAmount = getPaidLateFeeAmount.LateFeePayment>
					<cfset RemainingLateFeeAmount = getTenantLateFeeRecordsforDelete.mLateFeeAmount - PaidAmount>
					<td align="center"><input type="text" disabled="disabled" name="InvoiceLateFeeAmount" value="#LSCurrencyFormat(RemainingLateFeeAmount)#"></td>
			<cfelse> </cfif>--->
		<td align="center">#LSCurrencyFormat(getTenantLateFeeRecordsforDelete.mLateFeeAmount)#</td>
		<input type="hidden" name="AppliesToAcctPeriod" value="#getTenantLateFeeRecordsforDelete.cAppliesToAcctPeriod#">
		<td align="center">#getTenantLateFeeRecordsforDelete.cAppliesToAcctPeriod#</td>
		<td align="center"><input type="text" name="Reasonfordelete" value=""></td>
		<!--- 07/19/2010 Project 20933-PartB modified it to call it as Waived instead of delete --->
			 <!---  <td align="center"><input name="submit" type ="submit" value ="Delete"></td> --->
			<td align="center"><input name="submit" type ="submit" value ="Waived"></td>
			 <!--- end of code project 20933 Part-B --->
	</tr>
	</form>
	</cfloop>
	</table>
	
</cfif>
<!--- 07/28/2010 Project 20933 Part-B sathya commented this out and rewrote it as now its not delete but waived --->
<!--- <h6 STYLE="color: red;">** If you Delete the late fee it will show up in Solomon as a Credit and a Debit of the specified amount.</h6>
 --->
<h6 STYLE="color: red;">** If you Waive the late fee it will show up in Solomon as a Credit and a Debit of the specified amount.</h6>
<!--- end of code project 20933 Part-B --->
</cfoutput>
<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">