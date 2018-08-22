<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is for AR to change dates on accounts that are closed              |
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
| RTS    	 |09/28/09    | Created Page + code for #42573		       |
----------------------------------------------------------------------------------------------->
<cfoutput>

<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<CFQUERY NAME = "Tenants" DATASOURCE = "#APPLICATION.datasource#">
	select t.itenant_id,t.cSolomonKey,(t.cLastName + ', '+ t.cFirstName) as TName
	from tenant t
	join tenantstate ts on (ts.itenant_id = t.itenant_id and ts.iTenantStateCode_ID in (3,4) and ts.dtRowDeleted is null)
	where t.dtRowDeleted is null
	and ts.dtMoveOut > dateadd(m,-2,getdate())
	and t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	order by t.cLastName

</CFQUERY>



<CFINCLUDE TEMPLATE="../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Administrative Tasks </H1>

<!--- ==============================================================================
Include TIPS header for the House
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm"></br></br>

<script language="JavaScript" type="text/javascript">
	<!--- function getdata(){
	<cfinclude template="ActionFiles/act_GetInvoiceDetails.cfm">
	} --->
		function Check(){
		var Tenant = DateAdmin.TenantSelect.options[DateAdmin.TenantSelect.selectedIndex].text;
		if(Tenant == 'Select Resident'){
		alert("Please select an resident.")
		return false;
		}
		return true;
		}

</script> 

<cfif (ListContains(session.groupid,'240') gt 0)> 
	<form name="DateAdmin" action="ActionFiles/act_GetDateDetails.cfm?ID=#'TenantSelect'#" method="POST"> 
		<TABLE>
			<TR ><TH COLSPAN="3" STYLE="CENTER"> DATE ADMINISTRATION </TH></TR>
			<TR>
				<TD>Account Closed Residents : 
				</TD>
				<td>
				<select name="TenantSelect"> 
				  <option>Select Resident</option>
					<cfloop query="Tenants"><!--- <cfloop query="Available"> Not using total house apts--->
						<option value="#Tenants.itenant_id#" > #Tenants.TName# - (#Tenants.cSolomonKey#)</option> 					
					</cfloop>
				</select>
				</td>
				<td>
					<input type="submit" name="GetInfo" value="Get Info" onclick="return Check();"> 
				</td>
			</TR>
			<TR></TR>
			<TR></TR>
			
		</TABLE>
	</form>	
</cfif>
</br></br>
<BR>
<A Href="../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
<CFINCLUDE TEMPLATE='../../Footer.cfm'>
</cfoutput>