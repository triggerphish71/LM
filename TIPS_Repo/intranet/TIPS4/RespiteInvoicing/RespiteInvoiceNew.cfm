<!----------------------------------------------------------------------------------------------
| DESCRIPTION - RespiteInvoicing/RespiteInvoiceNew.cfm                                         |
| Delete invoice detail item from the invoice                                                  |
|----------------------------------------------------------------------------------------------|
| Called by: 		RespiteInvoice      				  	                                   |
| Calls/Submits:	                                                                           |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|Developed for Project 25575 - Incremental Time Period Billing                                 |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|R Schuette  | 05/25/2010 | Prj 25575 - Original Authorship     							   |
----------------------------------------------------------------------------------------------->

<!--- INFO --->
		<cfquery name="GetTenantInfoForNewINV" datasource="#application.datasource#">
			select t.cSolomonKey,t.iTenant_ID
					,h.iHouse_ID,h.cSLevelTypeSet
					,ts.iSPoints
					,cs.cName
					,aa.iAptType_ID
			from tenant t
			join tenantstate ts on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null)
			join House h on (h.iHouse_ID = t.iHouse_ID and h.dtRowDeleted is null)
			join ChargeSet cs on (cs.iChargeSet_ID = h.iChargeSet_ID and cs.dtRowDeleted is null)
			join AptAddress aa on (aa.iAptAddress_ID = ts.iAptAddress_ID 
									and aa.iHouse_ID = t.iHouse_ID
									and aa.dtRowDeleted is null)
			where t.dtRowDeleted is null
			and t.cSolomonKey = '#URL.SolID#'
		</cfquery>
		<!--- Update tenant residencyAgreement for new invoice --->
		<CFQUERY Name="UpdateResidencyAgreement" DAtasource="#APPLICATION.datasource#">
			Update Tenant
			set cResidenceAgreement = null
			where Tenant.iTenant_ID = #GetTenantInfoForNewINV.iTenant_ID#
		</CFQUERY>

<!--- Quantity used --->
<!--- datediff will provide an answer of 1 between yesterday and today, BUT we need to charge for 2 days
HENCE the " + 1" to make it 2 --->
		<cfquery name="GetQuantityForNewINV" datasource="#application.datasource#">
			select datediff(dd,'#form.Nextdate#', '#form.NewRRIdate#') + 1 as Days
		</cfquery>
<cftry>
	<CFQUERY NAME="CreateRespiteInvoice" DATASOURCE="#APPLICATION.datasource#">
			EXEC rw.sp_CreateRespiteInvoice @cSolomonKey='#URL.SolID#', @NextRRIdate='#form.NewRRIdate#', @AcctPeriod='#Period#', @NextRRIStartdate='#form.Nextdate#', @Days=#GetQuantityForNewINV.Days#, @userid=#session.userid#
	</cfquery>
<cfcatch type="database">
	<cfoutput>
			<!--- Error executing stored procedure: rw.sp_CreateRespiteInvoice</br> --->
			Error executing stored procedure: rw.sp_CreateRespiteInvoice</br>
			</br>
			PARAMS:</br>
			@cSolomonKey=#URL.SolID#,</br>
			 @NextRRIdate='#form.NewRRIdate#',</br>
			 @AcctPeriod='#Period#',</br>
			 @NextRRIStartdate='#form.Nextdate#',</br>
			 @Days=#GetQuantityForNewINV.Days#,</br>
			 @userid=#session.userid#</br>
			</br>
			 <a href="RespiteInvoice.cfm?SolID=#URL.SolID#">back</a>
	</cfoutput>
</cfcatch>
</cftry>

<cfoutput>
  <form name="return2page" action="RespiteInvoice.cfm?SolID=#URL.SolID#" method="POST" >
</cfoutput>
	<!--- use javascript to submit and post form back to getdetailspage --->
	<script type='text/javascript'>document.return2page.submit();</script>
</form>  

