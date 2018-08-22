<!--- *********************************************************************************************
Name:       DisplayLateFee.cfm
Type:       Template
Purpose:    Display the late fee for the particular tenant using the csolomonkey

Called by: MainMenu.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.csolomonkey                     ID is the csolomonkey which is user selected

Calls: UpdateTenantLateFeeCharge.cfm when Paid button is clicked
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None

Calls: DeleteTenantLateFeeCharges.cfm when delete button is clicked
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.SelectedTenant_ID               Tenant.aTenant_ID value of the tenant the user selected.

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
Sathya                  03/08/2010       Created this file for project 20933 Late Fee

Sathya                  07/19/2010       Made modification according to Project 20933 Part-B
										  rename the button as Waived instead of Delete.
--->
<!--- =============================================================================================
Include Intranet Header
============================================================================================= --->

<CFINCLUDE TEMPLATE="../../header.cfm">

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">

<!--- See if the #session.qselectedhouse.ihouse_id# exisits if not throw an error --->
 <cftry>
	<cfif NOT isDefined("session.qselectedhouse.ihouse_id")>
	   <!--- throw the error --->
	   <cfthrow message = "Session has expired please try again later. Try to logout and log back in to TIPS">
	</cfif>
	 <cfif NOT isDefined("URL.ID")>
	   <!--- throw the error --->
	   <cfthrow message = "Tenant ID not found.">
	</cfif>
<cfcatch type = "application">
  <cfoutput>
    <p>#cfcatch.message#</p>
	<br></br>
	<a href='../MainMenu.cfm'><p>Please click here to go back to TIPS Main Screen.</p></a>
 </cfoutput>
</cfcatch>
</cftry>
	<cfquery name="getTenantLateFeeRecords" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * 
				FROM TenantLateFee ltf
				join Tenant t 
				on t.iTenant_id = ltf.iTenant_id
				WHERE t.iTenant_id =#url.ID#
				AND ltf.dtrowdeleted is null
				AND t.dtrowdeleted is null
				AND (ltf.bPaid is null or ltf.bPaid = 0)
				AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0)
				
	</cfquery>
	<cfquery name="getPartialPayment" datasource="#APPLICATION.datasource#">
		select   tla.iInvoiceLateFee_ID , sum(mLateFeePartialPayment) as LateFeePayment
		from TenantLateFeeAdjustmentDetail tla
		join invoicedetail ind
		on tla.iinvoicedetail_id = ind.iinvoicedetail_id
		where tla.iInvoiceLateFee_ID in ( SELECT ltf.iInvoiceLateFee_ID 
										FROM TenantLateFee ltf
										join Tenant t 
										on t.iTenant_id = ltf.iTenant_id
										WHERE t.iTenant_id =#url.ID#
										AND ltf.dtrowdeleted is null
										AND t.dtrowdeleted is null
										AND (ltf.bPaid is null or ltf.bPaid = 0)
										AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0))
		and tla.dtrowdeleted is null
		and ind.dtrowdeleted is null
		Group by  iInvoiceLateFee_ID
	</cfquery>
	
	<!--- Query to get the historical data of the partial payment made --->
	 <cfquery name="PastPartialPayment" datasource="#APPLICATION.datasource#">
		select   tla.*
		from TenantLateFeeAdjustmentDetail tla
		join Tenant t
		on tla.iTenant_Id = t.iTenant_Id
		join invoicedetail ind
		on tla.iinvoicedetail_id = ind.iinvoicedetail_id
		where tla.iTenant_Id = #url.ID#
		and tla.dtrowdeleted is null
		and t.dtrowdeleted is null
		and ind.dtrowdeleted is null
	</cfquery> 
	
	<!--- Get tenantlatefee records which have been paid or deleted --->
	
	<cfquery name="getTenantLateFeePaidDeleted" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * 
				FROM TenantLateFee ltf
				join Tenant t 
				on t.iTenant_id = ltf.iTenant_id
				join invoicedetail ind
				on ltf.iinvoicedetail_id = ind.iinvoicedetail_id
				WHERE t.iTenant_id =#url.ID#
				AND ltf.dtrowdeleted is null
				AND t.dtrowdeleted is null
				AND (ltf.bPaid = 1 or ltf.bAdjustmentDelete =1)
				AND ind.dtrowdeleted is null
	</cfquery>
	<cfquery name="getTenantLateFeeException" DATASOURCE = "#APPLICATION.datasource#">
		
		 Select *
		 From Tenant t
		 join TenantState ts
		 on ts.iTenant_id = t.itenant_id
		 where t.iTenant_id =#url.ID#
				AND ts.dtrowdeleted is null
				AND t.dtrowdeleted is null
	</cfquery>
	
	<cfquery name="getHouseLateFeeinfo" DATASOURCE = "#APPLICATION.datasource#">
		Select *
		From
			HouseLateFee 
		where iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		 and dtRowDeleted is null
	</cfquery>
	

	
	<cfoutput>
<cfif getTenantLateFeeRecords.recordcount gt 0>
	<!--- Only the AR analyst can see this section --->
   <cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)> 
	 <!--- 07/28/2010 Project 20933 Part-B wrote this to give instructions --->
	<table>
		<tr><TD COLSPAN="100%" style="color:red">	<B>IMPORTANT INFORMATION:</B>	</TD> </tr>
		<tr>	
		  <td style="color:red;font-size: 8pt;">
			 **If you Click on Paid button, it will export the respective amount to Solomon upon House Close. 
		   </td>
		 </tr>
		 <tr>	
		  <td style="color:red;font-size: 8pt;">
			 **If you Click on Waived button, it will export a Credit and Debit of the respective amount to Solomon upon House Close. 
			</td>
		 </tr>
	</table>
	<!--- End of Project 20933 Part-B --->
	
	<table>
	
		<TR><TH COLSPAN=100%>List of OutStanding Late Fee for <cfoutput>#getTenantLateFeeRecords.cFirstName# #getTenantLateFeeRecords.cLastName#</cfoutput></TH></TR>
		<tr style="font-weight: bold; text-align: center; background: gainsboro;">
		<td align="center"><b>SolomonKey</b></td>
		<td align="center"><b>Late Fee</b></td>
		<td align="center"><b>Is it Paid?</b></td>
		<td align="center"> <b>Partial Payment Made?</b></td>
		<td align="center"><b>Partial Payment Amount</b></td>
		<td align="center"><b>Acct Period </b></td>
		<td align="center"><b>Paid</b></td>
		<!--- 07/19/2010 Project 20933-PartB modified it to call it as Waived instead of delete. commented and rewrote it --->
		<!--- <td align="center"><b>Delete</b></td> --->
		<td align="center"><b>Waived</b></td>
		<!--- End of code Project 20933-PartB --->
		</th>
	</tr>
	
	 <cfloop query='getTenantLateFeeRecords'>
	  	<FORM NAME="Form#getTenantLateFeeRecords.iInvoiceLateFee_ID#" Action="updateTenantLateFeeCharge.cfm"  METHOD="POST">
		<tr>
			<td style="text-align:center">#getTenantLateFeeRecords.csolomonkey#</td>
			<td align="center">
				<cfquery name="getPaidLateFeeAmount" dbtype="query">
						Select LateFeePayment from getPartialPayment where iInvoiceLateFee_ID = #getTenantLateFeeRecords.iInvoiceLateFee_ID#
					</cfquery>
				<!--- If this is a ID has a partial payment  --->
				<cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount neq 0)>
					
					<cfset PaidAmount = getPaidLateFeeAmount.LateFeePayment>
					<cfset RemainingLateFeeAmount = getTenantLateFeeRecords.mLateFeeAmount - PaidAmount>
					<input type="text" name="LateFeeAmount" value="#LSCurrencyFormat(RemainingLateFeeAmount)#"></td>
				<cfelse>
					<input type="text" name="LateFeeAmount" value="#LSCurrencyFormat(getTenantLateFeeRecords.mLateFeeAmount)#"></td>
				</cfif>
			<td align="center"><cfif getTenantLateFeeRecords.bPaid eq 1> Yes <cfelse>No </cfif></td>
			<td align="center"><cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount neq 0)> Yes <cfelse>No </cfif></td>
			<td align="center"><cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount neq 0)> #LSCurrencyFormat(PaidAmount)# <cfelse>#LSCurrencyFormat(0)# </cfif></td>
			
			
			<td align="center">#getTenantLateFeeRecords.cAppliestoAcctPeriod#</td>
			<input type="hidden" name="invoicelatefeeid" value="#getTenantLateFeeRecords.iInvoiceLateFee_ID#">
			<input type="hidden" name="tenantid" value="#getTenantLateFeeRecords.iTenant_ID#">
			<input type="hidden" name="solomonkey" value="#getTenantLateFeeRecords.csolomonkey#">
			<td>
				<cfif (#getTenantLateFeeRecords.cAppliestoAcctPeriod#) neq (#DateFormat(SESSION.TipsMonth,"yyyymm")#)>
				<input name="submit" type ="submit" value ="Paid">
			    </cfif>
			</td>
			<cfif (getTenantLateFeeRecords.bPartialPaid eq 1) and (getPaidLateFeeAmount.recordcount neq 0) >
				<!--- 08/03/2010 Project 20933 Part-B Sathya commented this out and rewrote it --->
				<!--- <td align="center"><cfoutput>You cannot Delete this Late Fee Using Tips.</cfoutput></td>
			 --->
			<td align="center"><cfoutput>You cannot Waive this Late Fee Using Tips.</cfoutput></td>
				<!--- End of code Project 20933 Part-B --->
			<cfelse>
			<td align="center">
				<cfif (#getTenantLateFeeRecords.cAppliestoAcctPeriod#) neq (#DateFormat(SESSION.TipsMonth,"yyyymm")#)>
				<!--- 07/19/2010 Project 20933 PartB Sathya modified it to call it as Waived instead of delete --->
				<!---  <INPUT TYPE="BUTTON" name="AdjustDeleteaccount" VALUE="Delete" ONCLICK="window.location.href='DeleteTenantLateFeeCharges.cfm?TenantID=#getTenantLateFeeRecords.iTenant_ID#&invoiceLatefeeID=#getTenantLateFeeRecords.iInvoiceLateFee_ID#'">
				 --->
				 <INPUT TYPE="BUTTON" name="AdjustDeleteaccount" VALUE="Waived" ONCLICK="window.location.href='DeleteTenantLateFeeCharges.cfm?TenantID=#getTenantLateFeeRecords.iTenant_ID#&invoiceLatefeeID=#getTenantLateFeeRecords.iInvoiceLateFee_ID#'">
				
				<!--- end of code project 20933 Part-B --->
				 </cfif>
				
				<!--- <a href="DeleteTenantLateFeeCharges.cfm?TenantID=#getTenantLateFeeRecords.iTenant_ID#&invoiceLatefeeID=#getTenantLateFeeRecords.iInvoiceLateFee_ID#"><b><font color="red">Click here to Delete or Adjust the Late Fee </font></b> </a>
			 --->
			</td>
			</cfif>
					
		</tr>
	</form>
	</cfloop>
	</table>
	<cfelse>
	<table>
	
		<TR><TH COLSPAN=100%>List of OutStanding Late Fee for <cfoutput>#getTenantLateFeeRecords.cFirstName# #getTenantLateFeeRecords.cLastName#</cfoutput></TH></TR>
		<tr style="font-weight: bold; text-align: center; background: gainsboro;">
		<td align="center"><b>SolomonKey</b> </td>
		<td align="center"><b>Late Fee</b> </td>
		<td align="center"><b>Is it Paid?</b> </td>
		<td align="center"><b>Acct Period </b></td>
		</tr>
	
	 <cfloop query='getTenantLateFeeRecords'>
  	<FORM NAME="Form#getTenantLateFeeRecords.iInvoiceLateFee_ID#" Action="updateTenantLateFeeCharge.cfm"  METHOD="POST">
		<tr>
			<td align="center">#getTenantLateFeeRecords.csolomonkey#</td>
			<td align="center">#LSCurrencyFormat(getTenantLateFeeRecords.mLateFeeAmount)#</td>
			<td align="center"><cfif getTenantLateFeeRecords.bPaid eq 1> Yes <cfelse>No </cfif></td>
			<td align="center">#getTenantLateFeeRecords.cAppliestoAcctPeriod#</td>
		</tr>
	</form>
	</cfloop>
	</table>
	</cfif>
</cfif>	
	
	
<cfif (getTenantLateFeePaidDeleted.recordcount eq 0) and (getTenantLateFeeRecords.recordcount eq 0)>
 <h5>	There are no Late Fee records for this Tenant. </h5>
</cfif>
<h6>** The Current Minimum Balance for a tenant to get a late fee for this house is #LSCurrencyFormat(getHouseLateFeeinfo.mMinimumBalanceForLateFee)#.
	<br></br>** The Current Minimum Charge being applied as Late Fee for this house is #LSCurrencyFormat(getHouseLateFeeinfo.mLateFeeAmount)#.
	</h6>
<!---Display historical data of late fee information  --->
<cfif getTenantLateFeePaidDeleted.recordcount gt 0>
<table>
	
		<TR><TH COLSPAN=100%>Historical records of Late Fee Payment for <cfoutput>#getTenantLateFeePaidDeleted.cFirstName# #getTenantLateFeePaidDeleted.cLastName#</cfoutput></TH></TR>
		<tr style="font-weight: bold; text-align: center; background: gainsboro;">
			<td align="center"><b>SolomonKey</b> </td>
			<td align="center"><b>Late Fee</b> </td>
			<td align="center"><b>Was it Paid?</b> </td>
			<td align="center"><b>Was it Waived?</b> </td>
			<td align="center"><b>Acct Period </b></td>
			<td align="center"><b>Associated to Invoice Number</b></td>
			<td align="center"><b>Comments</b></td>
		</tr>
		 <cfloop query='getTenantLateFeePaidDeleted'>
		 <tr>
			<td align="center"> #getTenantLateFeePaidDeleted.csolomonKey#</td>
			<td align="center"><b>#LSCurrencyFormat(getTenantLateFeePaidDeleted.mLateFeeAmount)#</b> </td>
			<td align="center"><cfif getTenantLateFeePaidDeleted.bPaid eq 1>
			                      Yes<cfelse>No </cfif></td>
			<td align="center"><cfif getTenantLateFeePaidDeleted.bAdjustmentDelete eq 1>
			                      Yes<cfelse> No</cfif></td>
			<td align="center">#getTenantLateFeePaidDeleted.cAppliesToAcctPeriod#</td>
			<td align="center">#getTenantLateFeePaidDeleted.iInvoiceNumber#</td>
			<td align="center">#getTenantLateFeePaidDeleted.cReasonForDelete#</td>
		</tr>
		 </cfloop>
	
</table>

</cfif>

<cfif PastPartialPayment.recordcount gt 0>
	<table>
	
		<TR><TH COLSPAN=100%>Historical records of Partial Late Fee Payment for <cfoutput>#PastPartialPayment.cFirstName# #PastPartialPayment.cLastName#</cfoutput></TH></TR>
		<tr style="font-weight: bold; text-align: center; background: gainsboro;">
			<td align="center"><b>SolomonKey</b> </td>
			<td align="center"><b>Partial Payment Amount</b> </td>
			<td align="center"><b>Actual Late Fee Amount</b> </td>
			<td align="center"><b>Acct Period </b></td>
			<td align="center"><b>Associated to Invoice Number</b></td>
			<td align="center"><b>Partial Payment Applied on</b></td>
		</tr>
		 <cfloop query='PastPartialPayment'>
		 <tr>
			<td align="center"> #PastPartialPayment.csolomonKey#</td>
			<td align="center"><b>#LSCurrencyFormat(PastPartialPayment.mLateFeePartialPayment)#</b> </td>
			<td align="center">#LSCurrencyFormat(PastPartialPayment.mActualLateFee)#</td>
			<td align="center">#PastPartialPayment.cAppliesToAcctPeriod#</td>
			<td align="center">#PastPartialPayment.iInvoiceNumber#</td>
			<td align="center">#DATEFORMAT(PastPartialPayment.dtLateFeePaid, "mm/dd/yyyy")#</td>
		</tr>
		 </cfloop>
	
</table>
</cfif>


	</cfoutput>
	
<!--- #url.ID#
</cfoutput> --->


<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">