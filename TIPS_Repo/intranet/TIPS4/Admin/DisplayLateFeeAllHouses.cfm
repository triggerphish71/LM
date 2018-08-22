<!---
function - Display late fee for all houses 
Mshah - 02/07/2017
Script is written to get all the tenant who has late fee and credit balance in SL is equal to the amount of late fee total.
They can be paid all at once before starting the monthly close cycle.
step 1 - get all the tenant who has total late fee amount equal to credit balance in SL
step 2 - get the tenantID to update tenantlatefee and invoicemaster. 
--->

<CFINCLUDE TEMPLATE="../../header.cfm">
<!---<cfdump var="#session#">--->
<cfquery name="getAllHouseTenantLateFeeRecords" DATASOURCE = "#APPLICATION.datasource#">
		Select  u.username, d.cname 'Division', r.cname 'Region', h.cname 'House', t.clastname+', '+t.cfirstname'ResidentName', t.csolomonkey, t.itenant_ID, currbal+futurebal 'CreditBalance' 
		,sum (ltf.mlatefeeamount) 'lateFee',ltf.bpaid
		from krishna.Houses_app.dbo.ar_balances ab
		inner join tenant t on ab.custid=t.csolomonkey
		inner join tenantstate ts on t.itenant_id=ts.itenant_id
		inner join house h on t.ihouse_id=h.ihouse_id
		inner join opsarea r on h.iopsarea_id=r.iopsarea_id
		inner join region d on r.iregion_id=d.iregion_id
		inner join bigmuddy.dms.dbo.users u on h.iacctuser_id=u.employeeid
		inner join tenantlatefee ltf on ltf.itenant_ID=t.itenant_ID
		where 
		(currbal+futurebal) < 0
		and ts.itenantstatecode_ID=2
		AND ltf.dtrowdeleted is null
		AND t.dtrowdeleted is null
		and ts.dtrowdeleted is null
		AND (ltf.bPaid is null or ltf.bPaid = 0)
		AND (ltf.bAdjustmentDelete is Null or ltf.bAdjustmentDelete = 0)
		and h.dtrowdeleted is null
		and h.bissandbox=0
		<!---and t.itenant_ID= 97152--->
		group by
		t.itenant_ID
		, d.cname
		 ,r.cname
		,h.cname
		,t.clastname
		,t.cfirstname
		,u.username
		, t.csolomonkey
		, currbal+futurebal
		,ltf.bpaid
		having abs(currbal+futurebal) = abs(sum (ltf.mlatefeeamount))
		order by u.username, d.cname, r.cname, h.cname, t.clastname
</cfquery>
<!---<cfdump var="#getAllHouseTenantLateFeeRecords#">--->
<script>
//check box select all function
function checkall() {
	alert('test')
     checkboxes = document.getElementsByID('checkbox');
	   alert (checkboxes);
	  for(var i=0, n=checkboxes.length;i<n;i++) {
		  alert (i);
		  checkboxes[i].checked = selectall.checked;
		  checkboxes[i].unchecked = selectall.unchecked;
	  }
}

function approvebutton() {
	alert('test')
 	counter=0;
	for (t=0;t<=document.forms[0].elements.length-1;t++){
		if (document.forms[0].elements[t].checked == true) { counter=counter+1; }
	}
}

</script>


	<!--- Only the AR analyst can see this section --->
 <cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)> 
			<table>
				<tr><TD COLSPAN="100%" style="color:red">	<B>IMPORTANT INFORMATION:</B>	</TD> </tr>
				<tr>	
				  <td style="color:red;font-size: 8pt;">
					 **If you Click on Paid button, it will export the respective amount to Solomon upon House Close. 
				   </td>
				 </tr>
			</table>
		
		<!---table start for info--->
<cfoutput>
<FORM NAME="Form#getAllHouseTenantLateFeeRecords.itenant_ID#" Action="updateAllTenantLateFeeCharge.cfm"  METHOD="POST">
     <table>
			 <tr>
				<td COLSPAN="100%" STYLE='text-align:center;'>
				<input name="submit" type ="submit" value ="Paid">
			
				<input type ="Button" name="report" value ="Report" onclick="window.location.href='ReportLateFeePaid.cfm?SelPeriod=#dateformat(Session.TIPSmonth, 'yyyymm')#'" onmouseover="Click here to see last paid late fee">
				</td>
			</tr>

			<TR><TH COLSPAN=100%>List of OutStanding Late </TH></TR>
			<tr style="font-weight: bold; text-align: center; background: gainsboro;">
			    <td align="center"><b>Trx </b></td>
				<!---<td align="center"><b><input type="checkbox" name="SelectAll"  Onclick="checkall();"> Select All </b></td>--->
				<td align="center"><b>AR Analyst</b></td>
				<td align="center"><b>Division</b></td>
				<td align="center"><b>Region</b></td>
				<td align="center"><b>Community</b></td>
				<td align="center"><b>Resident Name</b></td>
				<td align="center"><b>Resident ID </b></td>
				<td align="center"><b>Balance in SL </b></td>
				<td align="center"><b>Total amount of late fee </b></td>
				<td align="center"><b>Paid </b></td>
				</th>
			</tr>
		
			
					<cfloop query='getAllHouseTenantLateFeeRecords'>
						<tr>
						    <td align="center"> <input type="checkbox" name="row_#getAllHouseTenantLateFeeRecords.currentrow#" value="#getAllHouseTenantLateFeeRecords.currentrow#" id="checkbox" checked> </td>
							<td style="text-align:center"> #getAllHouseTenantLateFeeRecords.username# </td>
							<td align="center">#getAllHouseTenantLateFeeRecords.Division#</td>
							<td align="center">#getAllHouseTenantLateFeeRecords.region#</td>
							<td align="center">#getAllHouseTenantLateFeeRecords.house#</td>
							<td align="center">#getAllHouseTenantLateFeeRecords.ResidentName#</td>
							<td align="center">#getAllHouseTenantLateFeeRecords.csolomonkey#</td>
							<td align="center">#LSCurrencyFormat(getAllHouseTenantLateFeeRecords.CreditBalance)#</td>
							<td align="center">#LSCurrencyFormat(getAllHouseTenantLateFeeRecords.lateFee)#</td>
							<td align="center"><cfif getAllHouseTenantLateFeeRecords.bPaid eq 1> Yes <cfelse>No </cfif></td>
							<input type="hidden" name="itenantID_#getAllHouseTenantLateFeeRecords.currentrow#" value="#getAllHouseTenantLateFeeRecords.itenant_ID#">
							<input type="hidden" name="solomonkey_#getAllHouseTenantLateFeeRecords.currentrow#" value="#getAllHouseTenantLateFeeRecords.csolomonkey#">
							<input type="hidden" name="SLbalance_#getAllHouseTenantLateFeeRecords.currentrow#" value="#getAllHouseTenantLateFeeRecords.CreditBalance#">
						</tr>
					
					</cfloop>
					
			
					<!---<tr>
					<td COLSPAN="100%" STYLE='text-align:center;'>
					<input name="submit" type ="submit" value ="Paid">
				
					<input type ="Button" name="report" value ="Report" onclick="window.location.href='ReportLateFeePaid.cfm'" onmouseover="Click here to see last paid late fee">
					</td>
				</tr>--->
		</table>
</form>
</cfoutput>		
			
			
	
</cfif>