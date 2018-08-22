<!----------------------------------------------------------------------------------------------
| DESCRIPTION: approval page of discounted NRF by regional or higher                           |
|----------------------------------------------------------------------------------------------|
| FinalizeMoveInPend.cfm                                                                       |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by:                                                                                   |
| Calls/Submits:                                                                               |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|sfarmer     |03/20/2012  |  Added for deferred New Resident Fee project 75019                 |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 06/09/2012 | 75019 - Adjustments for 2nd opp, respite, Idaho                    | 
|sfarmer     | 04/17/2013 | 102919 - Adjustments discounted NRF approvals                      | 
|Sfarmer     | 09/18/2013 | 102919 - Revise NRF approval process                               |
----------------------------------------------------------------------------------------------->
<cfquery name="qryTenantPending" datasource="#application.datasource#">
	Select T.cLastName, T.cFirstName, TS.mBaseNRF, TS.mAdjNRF, TS.iNRFMid, T.itenant_id
	from Tenant T
		join tenantState TS on T.itenant_id = TS.itenant_id
	where T.itenant_id = #URL.ID#
</cfquery>
<cfquery name="qryRecurringNRF" datasource="#application.datasource#">
SELECT   
                      ind.iInvoiceMaster_ID, ind.iTenant_ID, ind.iChargeType_ID, ind.bIsRentAdj, ind.dtTransaction, ind.iQuantity, ind.cDescription AS InvoiceDescription, 
                      ind.mAmount, ind.dtRowDeleted, inm.cAppliesToAcctPeriod, inm.iInvoiceNumber, inm.cSolomonKey, inm.bMoveInInvoice, inm.dtInvoiceStart, 
                      inm.dtInvoiceEnd, inm.bMoveOutInvoice, chg.cDescription AS ChargeDescription, chg.bOccupancyPosition, chg.bIsMedicaid, chg.bIsRent, 
                      ind.cAppliesToAcctPeriod AS detailAppliesToAcctPeriod, inm.bFinalized, ind.cComments, inm.dtRowStart AS masterDtRowStart, 
                      inm.dtRowDeleted AS masterDtRowDeleted, ind.iInvoiceDetail_ID, ind.bNoInvoiceDisplay
FROM         dbo.InvoiceDetail ind INNER JOIN
                      dbo.InvoiceMaster inm ON ind.iInvoiceMaster_ID = inm.iInvoiceMaster_ID INNER JOIN
                      dbo.ChargeType chg ON ind.iChargeType_ID = chg.iChargeType_ID AND ISNULL(chg.dtRowDeleted, ISNULL(inm.dtInvoiceEnd, GETDATE())) 
                      >= ISNULL(inm.dtInvoiceEnd, GETDATE())
WHERE     (ind.dtRowDeleted IS NULL) AND (inm.dtRowDeleted IS NULL) and ind.ichargetype_id in (1740, 1741)
and ind.iTenant_ID = #URL.ID#
ORDER BY ind.ichargetype_id
</cfquery>
<cfparam name="defamount" default="0">
<title> TIPS 4 Finalize Move In Pending Approval </title>
<script>
	function confirmReject(str) {
		if ( confirm("Rejecting the NRF requires that you MUST contact your AR Analyst to manually enter the adjustment to the account") == true) {
		tenantid = document.getElementById('iTenantID').value;
		mid = document.getElementById('MID').value;		
	 
		loc="ResetMoveIn.cfm?iTenant_ID="+tenantid+"&MID="+mid;
		self.location.href=loc;
		}
		//else if (confirm("Continue the move in process?") == true) { loc="../MoveIn/MoveInForm.CFM?ID="+str; self.location.href=loc; }
	}
</script>
<cfinclude template="../../header.cfm">
<cfinclude template="../Shared/HouseHeader.cfm">
	<h1 class="PageTitle"> TIPS 4 -  Approve NRF Adjustment </h1>

	<form name="processpending"   method="post"> 
		<cfoutput  query="qryTenantPending">
			<input type="hidden" name="iTenantID" value="#iTenant_ID#" />
			<input type="hidden" name="MID" value="#iNRFMid#" />	

			<table>
				<tr >
					<td>Tenant Name: #cFirstName# #cLastName# </td>
				</tr>
				<tr style="background-color:##CCFFCC">
					<td>House New Resident Fee: #dollarformat(mBaseNRF)# </td>
				</tr>
				<tr >
					<td>Adjusted New Resident Fee:  #dollarformat(mAdjNRF)#</td>
				</tr>		
				<!--- <cfloop query="qryRecurringNRF">
					<cfif ichargetype_id is 1740>
						<cfset defamount = mamount>
							<tr style="background-color:##CCFFCC">
								<td>Installment Terms: Amount Deferred: #dollarformat(abs(mamount))#</td>
							</tr>
					<cfelseif  ichargetype_id is 1741>
						<cfset payamount = mamount>
						<tr>
							<td>Installment Terms: Monthly Payment: #dollarformat(abs(mamount))#</td>
						</tr>				
					</cfif>
				</cfloop> --->
				<cfif isDefined('DEFAMOUNT') and isDefined('payamount') and  (payamount gt 0)> 
					<cfset nbrmonths = abs(defamount)/ abs(payamount)>
				<cfelse>
					<cfset nbrmonths = 0>				
				</cfif>
				<!--- <tr style="background-color:##CCFFCC">
					<td>Instalment Terms: Number of payments: #round(nbrmonths)#</td>
				</tr> --->

				<tr style="background-color:##66FF99">
					<td style="text-align:center;  color:##006600"><!--- Accepting to Confrim the Discounted NRF. ---><br>
					<input type="button" name="Approve" value="Approve Adjusted NRF" onClick="self.location.href='FinalizeAdjNRF.cfm?iTenant_ID=#qryTenantPending.iTenant_ID#&MID=#iNRFMid#&Approval=Yes'"> </td>
				</tr>
				<tr  style="background-color:##FFCCFF">
					<td style="text-align:center; color:red  ; font-weight:800"   >Rejecting the Adjusted NRF requires that you MUST contact your AR Analyst<br /> to manually enter the adjustment to the account.<br>
						<input type="button" name="Reject" value="Reject Adjusted NRF" onClick="confirmReject()"> </td>			
						<!--- <input type="button" name="Reject" value="Reject Adjusted NRF" onClick="self.location.href='ResetMoveIn.cfm?iTenant_ID=#qryTenantPending.iTenant_ID#&MID=#iNRFMid#'"> </td> --->			

				</tr>		
<!---   				<tr  style="background-color:##FFCC0F">
					<td style="text-align:center; color:red" >Revise the Adjusted NRF<br>
						<input type="button" name="Revise" value="Revise Adjusted NRF" onClick="self.location.href='ReviseMoveIn.cfm?ID=#qryTenantPending.iTenant_ID#&MID=#iNRFMid#'"> </td>			
				</tr>  --->
			</table>
		</cfoutput>
	</form>
 

<cfinclude template="../../footer.cfm">