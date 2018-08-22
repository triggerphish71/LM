<!----------------------------------------------------------------------------------------------
| DESCRIPTION - PointDifferences/dsp_TenantPointDifferences.cfm                                |
|----------------------------------------------------------------------------------------------|
| Display database summary for tenant point differences                                        |
| Called by: 		Admin/Menu.cfm						  	                                   |
| Calls/Submits:	TenantPointDifferenceUpdate.cfm                                              |
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
|R Schuette  | 04/21/2010 | Original Authorship              								   |
|S Farmer    | 05/29/2013 | added  "and atm.bFinalized = '1'" to   PointDiff query #106732     |
----------------------------------------------------------------------------------------------->


<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<!--- ==============================================================================
QUERIES:
1)Retrieve all point differences
=============================================================================== --->
<CFQUERY NAME = "PointDiff" DATASOURCE = "#APPLICATION.datasource#">
	select h.cname as 'HouseName',aa.cAptNumber as 'AptNumber'
		,t.iTenant_ID
		,t.cSolomonKey
		,(t.cFirstName + ' ' + t.cLastName) as 'TenantName'
		,convert(varchar(10),ts.dtMoveIn,101) as 'dtMoveIn'
		,rt.cDescription
		,ts.iSPoints as 'BillingPoints'
		,atm.iSPoints as 'AssessmentPoints'
	from tenant t
		join TenantState ts on (ts.iTenant_ID = t.iTenant_ID and ts.iTenantStateCode_ID = '2' and ts.dtRowDeleted is null)
		join AptAddress aa on (aa.iAptAddress_ID = ts.iAptAddress_ID and aa.dtRowDeleted is null)
		join AssessmentToolMaster atm on (atm.iTenant_id = t.iTenant_ID and atm.bBillingActive = '1' and atm.dtRowDeleted is null)
		join House h on (h.iHouse_ID = t.iHouse_ID and h.iHouse_ID <> '161' and h.dtRowDeleted is null)
		join ResidencyType rt on (rt.iResidencyType_ID= ts.iResidencyType_ID)	
	where 
		ts.iSPoints <> atm.iSPoints
		and atm.bFinalized = '1'
	order by h.cname,aa.cAptNumber
</CFQUERY>
<!--- ==============================================================================
SCRIPTS:
1)Make sure 'Select Resident' is not the chosen name
=============================================================================== --->
<script language="JavaScript" type="text/javascript">

		function Update(){
		var Tenant = TenantPointSelect.TenantSelect.options[TenantPointSelect.TenantSelect.selectedIndex].text;
		if(Tenant == 'Select Resident'){
			alert("Please select a resident.")
			return false;
			}
		return true;
		}

</script>
<!--- ==============================================================================
PAGE:
=============================================================================== --->
<CFOUTPUT>

<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 14;">
	<B>Exit to the Administration Menu</B>
</A>
<BR>
<BR>


<TABLE>
	<TR>
		<TD COLSPAN="2" STYLE="background: white;">
			<B STYLE="font-size: 20;">Tenant Point Difference Administration</B>
		</TD>
	</TR>

</TABLE>

	<cfif PointDiff.RecordCount gt 0>
	<TABLE>
		<TR>
		<th NOWRAP>House Name</th>
			<th>Apartment Number</th>
			<th>Solomon Key</th>
			<th NOWRAP>Tenant Name</th>
			<th>Moved In</th>
			<th>Residency Type</th>
			<th NOWRAP>Billing Points</th>
			<th>|</th>
			<th NOWRAP>Activated Points</th>
		</TR>
		
		<CFLOOP QUERY = "PointDiff"> 
			<TR>		
				<td style="text-align:center"  NOWRAP>
					#PointDiff.HouseName#
				</td>
				<td style="text-align:center">
					#PointDiff.AptNumber#
				</td>
				<td style="text-align:center" NOWRAP>
					#PointDiff.cSolomonKey#
				</td>
				<td style="text-align:center" NOWRAP>
					#PointDiff.TenantName#
				</td>
				<td style="text-align:center" >
					#PointDiff.dtMoveIn#
				</td>
				<td style="text-align:center" >	
					#PointDiff.cDescription#
				</td>
				<td style="text-align:center" >
					#PointDiff.BillingPoints#
				</td>
				<td>|</td>
				<td style="text-align:center">
					#PointDiff.AssessmentPoints#
				</td>
			</TR>
		</CFLOOP>
	</TABLE>
	<cfelse>
		All Tenant Billing Points Currently Match Active Assessment Points
	</cfif>
	
	<!--- IT(1) &/or AR Master Admin(dev1381, prod 285) --->
	<CFIF ListFindNoCase(SESSION.groupid, '1') gt 0>
		<form name="TenantPointSelect" action="TenantPointDifferenceUpdate.cfm" method="POST">	
		<TABLE>
			<tr>
				<td>
				Update Resident:			
				</td>
				<td>
					<select name="TenantSelect"> 
					  <option>Select Resident</option>
						<cfloop query="PointDiff">
							<option value="#PointDiff.iTenant_ID#" > #PointDiff.TenantName# - (#PointDiff.cSolomonKey#)</option> 					
						</cfloop>
					</select>
				</td>
				<td>
						<input type="submit" name="MakeUpdate" value="Make Update" onmouseover="return Update();"onclick="return Update();">
				</td>
			</tr>
		</TABLE>
		</form>
	<cfelse>
		<br/>
		<TABLE>
			<TR>
				<TD style="text-align:center">Please Call IT-Support To Fix a Tenant</TD>
			</TR>
		</TABLE>
	</cfif>

</CFOUTPUT>

<br/><br/>
<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 18;">
	<B>Exit to the Administration Menu</B>
</A>




<!--- ==============================================================================
Include Intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE = "../../../footer.cfm">