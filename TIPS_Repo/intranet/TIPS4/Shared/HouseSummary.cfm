<!----------------------------------------------------------------------------------------------
| DESCRIPTION:   Display a short House summary to be on the Tips main screen of a house        |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
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
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| rschuette  | 04/16/2009 | Authored                                                           |
| rschuette  | 07/02/2010 | 25575 - added code about Respites being within invoice time period |
| gthota  | 10/04/2017 |  added code about unapproved assessments record count notification    |
|---------------------------------------------------------------------------------------------->

<cfset qApprovalCount = session.oApprovalServices.getApprovalCount(houseid=session.qSelectedHouse.iHouse_ID,acctPeriod=session.tipsmonth)>

<style>
	.flash {background: url(/intranet/tips4/shared/Flash.gif);}
</style>

<cfquery name="HouseSummaryTotal" DATASOURCE="#APPLICATION.datasource#">
	select 
		isnull(count(t.iTenant_ID),0) Tot_Tenants
		,isnull(sum(ts.iSPoints),0) Tot_Points
	from tenant t
	join TenantState ts on (ts.iTenant_ID = t.iTenant_ID 
							and ts.iTenantStateCode_ID = 2
							and ts.dtRowDeleted is null)
	where t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and t.dtRowDeleted is null
</cfquery>

<cfif HouseSummaryTotal.Tot_Tenants neq 0>
	<cfset AveTotTenantPnt = HouseSummaryTotal.Tot_Points / HouseSummaryTotal.Tot_Tenants>
<cfelse>
	<cfset AveTotTenantPnt = 0>
</cfif>

<cfquery name="HouseSummaryPR" DATASOURCE="#APPLICATION.datasource#">
	select 
		isnull(count(t.iTenant_ID),0) PR_Tenants
		,isnull(sum(ts.iSPoints),0) PR_Points
	from tenant t
	join TenantState ts on (ts.iTenant_ID = t.iTenant_ID 
							and ts.iTenantStateCode_ID = 2
							and ts.iResidencyType_ID in (1,3)
							and ts.dtRowDeleted is null)
	where t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and t.dtRowDeleted is null
</cfquery>

<cfif HouseSummaryPR.PR_Tenants neq 0>
	<cfset AvePRTenantPnt = #HouseSummaryPR.PR_Points# / #HouseSummaryPR.PR_Tenants#>
<cfelse>
	<cfset AvePRTenantPnt = 0>
</cfif>

<cfquery name="HouseSummaryM" DATASOURCE="#APPLICATION.datasource#">
	select 
		isnull(count(t.iTenant_ID), 0) M_Tenants
		,isnull(sum(ts.iSPoints), 0)  M_Points
	from tenant t
	join TenantState ts on (ts.iTenant_ID = t.iTenant_ID 
							and ts.iTenantStateCode_ID = 2
							and ts.iResidencyType_ID = 2
							and ts.dtRowDeleted is null)
	where t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
	and t.dtRowDeleted is null
</cfquery>

<cfif HouseSummaryM.M_Tenants neq 0>
	<cfset AveMTenantPnt = HouseSummaryM.M_Points / HouseSummaryM.M_Tenants>
<cfelse>
	<cfset AveMTenantPnt = 0>
</cfif>

<!--- 25575 - rts - 7/2/2010 - Respite Code --->
	<cfquery name="HouseSummaryR" DATASOURCE="#APPLICATION.datasource#">
		select t.iTenant_ID
		from tenant t
		join TenantState ts on (ts.iTenant_ID = t.iTenant_ID and ts.iTenantStateCode_ID = 2
								and ts.iResidencyType_ID = 3 and ts.dtRowDeleted is null)
		where t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
		and t.dtRowDeleted is null
	</cfquery>
	<cfset RespiteCount = HouseSummaryR.RecordCount>
	<cfset RespiteOInvCount = 0>
	
	<cfquery name="GetRespiteINVStatus" datasource="#application.datasource#">
		Select distinct im.csolomonkey
		from InvoiceMaster im
		join tenant t on t.csolomonkey = im.csolomonkey and t.dtrowdeleted is null
		join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
		where im.dtrowdeleted is null
		and im.bFinalized is not null
		and ts.iTenantStateCode_ID = 2
		and ts.iResidencyType_ID  = 3
		and t.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
		and getdate() between im.dtInvoiceStart and im.dtInvoiceEnd
	</cfquery>

	<cfset RespiteOInvCount = RespiteCount - GetRespiteINVStatus.recordCount>
	
	<cfif RespiteOInvCount gt 0>
		<cfset color = 'Red'>
	<cfelse>
		<cfset color = ''>
	</cfif>
<!--- 25575 end --->

<table border="1" cellspacing="0" cellpadding="0" style='border-collapse: collapse;border: none;'>
        <tr>
            <td valign="top" style="border: solid windowtext .5pt;background: D9D9D9; padding: ''0in 5.4pt 0in 5.4pt">
                <p>
                   <span style="font-weight:bold">House Summary</span> 
				</p>
            </td>
        </tr>
        <tr>
	<table style="">
		<tr>
            <td valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt">
                <p>
                    <span>Total Residents:</span><br />
					<span>Total House Points:</span><br />
					<cfif HouseSummaryTotal.Tot_Tenants neq HouseSummaryPR.PR_Tenants>
	                    <span>Number of Private & Respite Residents:</span><br />
	                    <span>Total Private & Respite Points:</span><br />
					</cfif>
					<cfif HouseSummaryM.M_Tenants gt 0>
						<span>Number of Medicaid Residents:</span><br />
						<span>Total Medicaid Points:</span><br />
					</cfif>
					<!--- 25575 rts - 7/2/2010 --->
					<cfif RespiteCount neq 0>
						<span>Number of Respite Residents:</span><br />
					</cfif>
					<!--- end 25575 --->
				</p>
            </td>
	<CFOUTPUT>
	
			 <td valign="top" style="width: 35px;border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>  
                    <span>#HouseSummaryTotal.Tot_Tenants#</span><br />
					<span>#HouseSummaryTotal.Tot_Points#</span><br />
					<cfif HouseSummaryTotal.Tot_Tenants neq HouseSummaryPR.PR_Tenants>
	                    <span>#HouseSummaryPR.PR_Tenants#</span><br />
	                    <span>#HouseSummaryPR.PR_Points#</span><br />
	                </cfif>
					<cfif HouseSummaryM.M_Tenants gt 0>
						<span>#HouseSummaryM.M_Tenants#</span><br />
						<span>#HouseSummaryM.M_Points#</span><br />
					</cfif>
					<!--- 25575 rts - 7/2/2010 --->
					<cfif RespiteCount neq 0>
						<span>#RespiteCount#</span><br />
					</cfif>
					<!--- end 25575 --->
			    </p>  
            </td>
            <td valign="top" style=" border: solid windowtext .5pt; border-top: none; padding: 0in 5.4pt 0in 5.4pt">
                <p>
                    <span></span><br />
					<span>Average Points Per Resident:</span><br />
					<cfif HouseSummaryTotal.Tot_Tenants neq HouseSummaryPR.PR_Tenants>
	                    <span></span><br />
	                    <span>Average Points Per Private & Respite Resident:</span><br />
	                </cfif>
					<cfif HouseSummaryM.M_Tenants gt 0>
						<span></span><br />
                    	<span>Average Points Per Medicaid Resident:</span><br />
					</cfif>
					<!--- 25575 rts - 7/2/2010 --->
					<cfif RespiteCount neq 0>
						<cfif RespiteOInvCount neq 0>
							<span class="flash">Number of Respite out of Invoice:</span><br />
						<cfelse>
							<span>Number of Respite out of Invoice:</span><br />
						</cfif>
                    	
					</cfif>
					<!--- end 25575 --->
				</p>
            </td>
			
			 <td valign="top" style="width: 35px;border-color:green; border-top: none; padding: 0in 5.4pt 0in 5.4pt"> 
				<p>  
                    <span></span><br />
					<span>#NumberFormat(AveTotTenantPnt, '__.__')#</span><br />
					<cfif HouseSummaryTotal.Tot_Tenants neq HouseSummaryPR.PR_Tenants>
                    	<span></span><br />
                    	<span>#NumberFormat(AvePRTenantPnt, '__.__')#</span><br />
					</cfif>
					<cfif HouseSummaryM.M_Tenants gt 0>
						<span></span><br />
                    	<span>#NumberFormat(AveMTenantPnt, '__.__')#</span><br />
					</cfif>
					<!--- 25575 rts - 7/2/2010 --->
					<cfif RespiteCount neq 0> 
						<cfif RespiteOInvCount neq 0>
							<span class="flash"><strong>#RespiteOInvCount#</strong></span><br />
						<cfelse>
							<span><strong><font color="#color#">#RespiteOInvCount#</font></strong></span><br />
						</cfif>
					</cfif>
					<!--- end 25575 --->
				</p> 
	          </td>
        </tr>
        <!--- Ganga Thota 10/04/2017   - Start code for unApproved assessments record count notification  --->
        <tr> 
	
	
		<td align="center">
		<cfif #qapprovalcount.recordCount# GT 0>
			<A HREF="../tips4/admin/menu.cfm"><span class="flash"><strong>Un-Approved Assessments in Admin Screen: #qapprovalcount.recordCount#</strong></span> </A><br />		
		</cfif>
		</td>
        </tr>   
        <!--- Ganga Thota END code  --->
	</table>
</table>
</CFOUTPUT>
