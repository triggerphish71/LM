<!---------------------------------------------------------------------------------------------------
|Name:       CurrentLateFee.cfm                                                                      |
|Type:       Template                                                                                |
|Purpose:    This page will list the current late fee which was generated in the current TIPS month  |
|----------------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                                  |
|----------------------------------------------------------------------------------------------------|
|  none                                                                                              |
|----------------------------------------------------------------------------------------------------|
|Called by: Menu.cfm                                                                                 |
|    Parameter Name                      Description                                                 |
|----------------------------------------------------------------------------------------------------|
   #SESSION.qSelectedHouse.iHouse_ID#   The house id is being used to pull data for all the queries  |
|																									 |
|Calls: DeletecurrentLateFee.cfm																 |
|    Parameter Name                      Description                                                 |
|    ------------------------------      ------------------------------------------------------------|
|    None
|																									 |
|----------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                              |
|------------|------------|--------------------------------------------------------------------------|
| Sathya  	 |07/16/10    | Created this page as part of project 20933 Part-B Late Fees              |
------------------------------------------------------------------------------------------------------>
<CFIF NOT IsDefined("session.tipsMonth") OR NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

	<cfoutput>
	<CFSET LatefeeAppliesToAcctPeriod = #DateFormat(session.tipsMonth,"yyyymm")#>
	</cfoutput>
<!--- Gets the current late fee for the tenant in this particular house --->
	<CFQUERY NAME = "GetListCurrentLateFeeForHouse" DATASOURCE = "#APPLICATION.datasource#">
	select CASE LEN(ad.cAptNumber) 
					WHEN 1 THEN ('00' + ad.cAptNumber)
					WHEN 2 THEN ('0' + ad.cAptNumber) 
					ELSE ad.cAptNumber
				END as cAptNumber
				,t.iTenant_ID ,t.cSolomonKey 
				,t.cFirstName as firstname ,t.cLastName as lastname 
	            ,LTF.mLateFeeAmount
				,LTF.iInvoiceLateFee_ID
				,LTF.cAppliesToAcctPeriod
		from AptAddress AD (nolock)
		left join houseproductline hpl (nolock) on hpl.ihouseproductline_id = ad.ihouseproductline_id and hpl.dtrowdeleted is null
		left join productline pl (nolock) on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
		join	TenantState ts (nolock) on ad.iAptAddress_ID = ts.iAptAddress_ID and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID = 2 and ts.dtRowDeleted is null)		
	    join TenantLateFee LTF on ts.itenant_id = LTF.itenant_id
		left outer join	AptType APT	(nolock) on (apt.iAptType_ID = ad.iAptType_ID and apt.dtRowDeleted is null)
		left join Tenant t (nolock) on (t.iTenant_ID = ts.iTenant_ID)
		left join SLevelType ST	(nolock) on (t.cSlevelTypeSet = st.cSlevelTypeSet and ts.iSPoints <= iSPointsMax and ts.iSPoints >= iSPointsMin)
		left join house h (nolock) on ad.iHouse_id = h.iHouse_id 
		where	ad.dtRowDeleted is null
				and ad.iHouse_ID =  #SESSION.qSelectedHouse.iHouse_ID#
				and t.dtRowDeleted is null
				and t.itenant_ID is not null
				and ts.iResidencyType_ID <> 2
				and (ts.bDeferredPayment is NULL or ts.bDeferredPayment  = 0)
		and LTF.cAppliesToAcctPeriod = '#LatefeeAppliesToAcctPeriod#'
		and LTF.dtrowdeleted is null
		order by ad.cAptNumber 
	</CFQUERY>
<CFINCLUDE TEMPLATE="../../header.cfm">
<!--- Include shared javascript --->
<CFINCLUDE TEMPLATE='../Shared/HouseHeader.cfm'>
<A HREF='menu.cfm'>Click Here to Go Back to the Administration Screen.</A>
<br></br>

<script language="JavaScript" type="text/javascript">
	function hardhaltvalidation(formCheck)
	{	
		if(formCheck.ReasonOfDelete.value =="")
		{
			formCheck.ReasonOfDelete.focus();
			alert("Please Enter a Valid reason for deletion of the late fee.");
			return false;
		}
}
</script>



<cfoutput>

	

<cfif GetListCurrentLateFeeForHouse.recordcount GT 0>
	<table>
		  <tr>	
		  	<td style="color:red;font-size: 8pt;">
			**IMPORTANT INFORMATION: If you Click on Delete button, it will delete the Late Fee record permanently and will not show up in the invoice.
			  The respective late fee for the tenant will not export to Solomon once it's deleted upon House Close.  
			  Below is the List of Current Late fee for #SESSION.HouseName# for the Period of #DateFormat(Session.TIPSMonth,"yyyymm")#.
			  It is mandatory to enter the reason for the deleting of late fee for the respective tenant.
		  </td>	
		 </tr>
	</table>
<table class="noborder">
<tr><td class="transparent"><P class="PAGETITLE"><B STYLE="color: red;">Please note each change for Residents listed below must be submitted separately.</B></P></td></tr>
</table>
  <TABLE>
	
		<TR><TH COLSPAN=100%>List of Current Late Fee for Tenants in <cfoutput>#SESSION.HouseName#</cfoutput></TH></TR>
		<TR style="font-weight: bold; text-align: center; background: gainsboro;">
				<TD align="center"><b>Apartment</b></TD>
				<td></td>
				<TD align="center"><b>Tenant Name</b></TD>
				<TD align="center"><b>LATE LEE AMOUNT</b></TD>
				<TD align="center"><b>Applied in which Year</b></TD>
				<td><b>Reason for Delete</b></td>
				<TD><b>DELETE</b></TD>
		</TR>
		
	
		<CFLOOP QUERY='GetListCurrentLateFeeForHouse'>
			<FORM NAME="Form#GetListCurrentLateFeeForHouse.iInvoiceLateFee_ID#" ACTION="UpdateCurrentLateFeeDelete.cfm" METHOD="POST">
				<tr>
					<TD><b>#GetListCurrentLateFeeForHouse.cAptNumber#</b></TD>
					<td></td>
					<TD NOWRAP ><b>#GetListCurrentLateFeeForHouse.lastname# #GetListCurrentLateFeeForHouse.firstname# </b></TD>
					<TD align="center"><b>#LSCurrencyFormat(GetListCurrentLateFeeForHouse.mLateFeeAmount)#</b></TD>
					<TD align="center"><b>#GetListCurrentLateFeeForHouse.cAppliesToAcctPeriod#</b></TD>
					
					<TD><INPUT TYPE="Text" NAME="ReasonOfDelete" VALUE=""></TD>
					<INPUT TYPE="Hidden" NAME="iInvoiceLateFee_ID" VALUE="#GetListCurrentLateFeeForHouse.iInvoiceLateFee_ID#">
					
					<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#GetListCurrentLateFeeForHouse.iTenant_ID#">
					<!--- onmouseover="return hardhaltvalidation(Form#GetListCurrentLateFeeForHouse.iInvoiceLateFee_ID#);" --->
					<TD><input name="submit" type ="submit" value ="Delete" onclick="return hardhaltvalidation(Form#GetListCurrentLateFeeForHouse.iInvoiceLateFee_ID#);" onfocus ="return hardhaltvalidation(Form#GetListCurrentLateFeeForHouse.iInvoiceLateFee_ID#);"></TD>
				</tr>
			</FORM>
		</CFLOOP>
	</table>
	<cfelse>
	<h3 STYLE="color: red;">There are no late fee being generated for '#LatefeeAppliesToAcctPeriod#' Period.</h3>
	
	</cfif>
</cfoutput>

