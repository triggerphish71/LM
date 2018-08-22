<!----------------------------------------------------------------------------------------------
| DESCRIPTION: Resident Move Out Reason Code Change, Select Resident                           |
|----------------------------------------------------------------------------------------------|
| MoveOutForm.cfm                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by:        MainMenu.cfm                                                               |
| Calls/Submits:    ReasonCodeChange                                                           |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Project Nbr. |          Description                                |
|------------|------------|--------------------------------------------------------------------|
|SFarmer     |05/25/2011  | 71776        | Created                                             |
----------------------------------------------------------------------------------------------->

<style type="text/css">
tr.lightrow td {
background-color: #FFFFFF;
}
tr.darkrow td {
background-color: #EFEFEF;
}
</style>

<CFPARAM name="ShowBtn" default="True">
<CFPARAM name="dtNow" type="date" default="#now()#">
<CFSET STYLE="STYLE='color: navy;'">
<CFSET ButtonValue = "Submit">
<!--- 
<cfset thissessionhouseid = SESSION.qSelectedHouse.iHouse_ID>
--->
<!--- <cfset SESSION.groupid = SESSION.groupid & ",240"> --->

<cfif IsDefined("SESSION.qSelectedHouse.iHouse_ID")> 
	<cfset thissessionhouseid = SESSION.qSelectedHouse.iHouse_ID>
<cfelse>
	<cfset thissessionhouseid = 50 > 		
</cfif> 


<cfset dtBegThisMonth = CreateDate(Year( Now() ),Month( Now() ),1) />
<cfset dtBegLastMonth = CreateDate(Year( Now() ),Month( Now() -1),1) />

<cfset DayOfMonth = Day( Now() )/>
<cfset lastmonth = DateAdd( "m", -1, dtNow ) /> 
<cfset dtBegLastMonth = CreateDate(Year( Now() ), Month(DateAdd( "m", -1, Now())),1) /> 

<cfset yr=Year(dtBegLastMonth)>
<cfset m=Month(dtBegLastMonth)>
<cfset d=DaysInMonth(dtBegLastMonth)>
<cfset dtlastDayOfMonth=Createdate(#yr#,#m#,#d#)>

<cfif DayofMonth gt 3>
	<cfset EndDate = dtNow>
	<cfset BeginDate = dtBegThisMonth>
<cfelse>
	<cfset 	EndDate = dtlastDayOfMonth>
	<cfset BeginDate = dtBegLastMonth>
</cfif>

<CFQUERY NAME = "qTenant" DATASOURCE = "#APPLICATION.datasource#">
	SELECT  T.iTenant_ID,  T.cFirstName + ' ' + T.cLastName as FullName, TS.dtMoveOut,
	TS.dtMoveIn, TS.dtChargeThrough, 
	 TS.iMoveReasonType_ID, TS.iMoveReason2Type_ID
	FROM   Tenant T(nolock)
	Left Join TenantState TS (nolock) ON T.iTenant_ID = TS.iTenant_ID
	WHERE TS.dtMoveOut between  #BeginDate#  and #EndDate# 
	and T.iHouse_ID = #thissessionhouseid#
</CFQUERY>

<cfset itemcnt = #qTenant.recordcount#>

<CFQUERY NAME = "qReasonType" DATASOURCE = "#APPLICATION.datasource#">
	select iMoveReasonType_ID, cDescription 
	from MoveReasonType 
	Where dtRowDeleted is null 
		and bIsVoluntary = 1 
	Order by cDescription
</CFQUERY>

<CFQUERY NAME = "qHouseName" DATASOURCE = "#APPLICATION.datasource#">
	select cName
	from House 
	Where iHouse_ID =  #thissessionhouseid#
</CFQUERY>

<script>
 function trim(stringToTrim) {
	return stringToTrim.replace(/^\s+|\s+$/g,"");
	}

 function processFormData(oForm) {
 valid = true;

  	if 	(
		(trim(oForm.elements["Reason1"].value) == trim(oForm.elements["Reason2"].value)) ||
	     (trim(oForm.elements["Reason2"].value) == trim(oForm.elements["currentreason1"].value))  
		   &&  (trim(oForm.elements["Reason2"].value) == trim(oForm.elements["Reason1"].value)) ||
	     (trim(oForm.elements["currentreason2"].value) == trim(oForm.elements["Reason1"].value))	
		 )
 		{
   		alert("Move Out Reason Code 1 and  Move Out Reason Code 2 cannot be the same!"
// 		 + "\n" + "R1 " + trim(oForm.elements["Reason1"].value) + "\n"  + "R2 " + trim(oForm.elements["Reason2"].value) + "\n" +
// 		 "CR1 " + trim(oForm.elements["currentreason1"].value) + "\n" +  "CR2 " + trim(oForm.elements["currentreason2"].value) + "\n"
			);						
     	valid =  false;	
 		}
 return valid;
}

</script>

<CFIF ShowBtn>
	<CFINCLUDE TEMPLATE="../../header.cfm">	
 
    <A HREF="../MainMenu.cfm" STYLE="font-size: 14;">Click Here to Go Back To TIPS Summary.</A>
<CFELSE>
	<style type="text/css">
	<!--
	body {
		background-color: #FFFFCC;
	}
	-->
	</style>
	<CFOUTPUT>
		<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
			<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
		<CFELSE>
			<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
		</CFIF>
	</CFOUTPUT>
</CFIF>
<cfoutput>
 
	<table>
			<TR>
				<th colspan="7"   STYLE="text-align: center;">Resident Move Out Reason Code Change</TH>
			</TR>
			<TR>
				<th colspan="7"  STYLE="text-align: center;">Date Range: #LSDateFormat(BeginDate, "mm/dd/yyyy")#  through #LSDateFormat(EndDate, "mm/dd/yyyy")#<br/> House: #qHouseName.cName#</th>
			</TR>
			<TR>
				<TH>Resident</TH>
				<TH>Move In<br/>Date</TH>
				<TH>Move Out<br/>Date</TH>
				<TH>Charge Through<br/>Date</TH>
				<TH>Reason Code 1<br/>(Select to Change)</TH>
				<TH>Reason Code 2<br/>(Select to Change)</TH>
				<TH>Update</TH>
			</TR>

			<cfset formindex = 0>
			<CFLOOP QUERY='qTenant'>
				<FORM NAME="MoveOutReasonMod#formindex#"  ACTION="MoveOutResonModUpdate.cfm"   METHOD="POST" >
				<cfset formindex = formindex + 1>
					<input type="hidden" name="formindex" value="#formindex#">
 					
					<CFQUERY NAME = "qReasonCode1" DATASOURCE = "#APPLICATION.datasource#">
						select cDescription,  iMoveReasonType_ID 
						from MoveReasonType
						Where iMoveReasonType_ID = #qTenant.iMoveReasonType_ID#
					</CFQUERY>
 					
					<cfif qTenant.iMoveReason2Type_ID is not "">
						<CFQUERY NAME = "qReasonCode2" DATASOURCE = "#APPLICATION.datasource#">
						select cDescription,  iMoveReasonType_ID 
						from MoveReasonType
						Where iMoveReasonType_ID = #qTenant.iMoveReason2Type_ID#
						</CFQUERY>
					</cfif> 
					<tr class="#iif(currentrow MOD 2,DE('lightrow'),DE('darkrow'))#">
						<input type="hidden" name="tenant_id" id="tenantid" value="#qTenant.iTenant_ID#">
						<td>#qTenant.FullName#</td>
						<td>#LSDateFormat(qTenant.dtMoveIn, "mm/dd/yyyy")#</td>
						<td>#LSDateFormat(qTenant.dtMoveOut, "mm/dd/yyyy")#</td>
						<td>#LSDateFormat(qTenant.dtChargeThrough, "mm/dd/yyyy")#</td>
						
						<td><input type="hidden" name="currentreason1" value="#qTenant.iMoveReasonType_ID#" />
							<SELECT NAME="Reason1" id="MoveOutReason1">
						 		<option value="#qReasonCode1.iMoveReasonType_ID#">#qReasonCode1.cDescription#</OPTION>
								<cfloop query="qReasonType">
									<option value="#qReasonType.iMoveReasonType_ID#" >#qReasonType.cDescription#</option>
								</cfloop>  
	 						</SELECT>
						</td>
						
						<td><input type="hidden" name="currentreason2" value="#qTenant.iMoveReason2Type_ID#" />
							<SELECT NAME="Reason2"  id="MoveOutReason2">
								<cfif qTenant.iMoveReason2Type_ID is not "">
									<option value="#qReasonCode2.iMoveReasonType_ID#">#qReasonCode2.cDescription#</OPTION>
								<cfelse>
									<option value="">&nbsp; </OPTION>
								</cfif>
								<CFLOOP QUERY="qReasonType">
									<OPTION VALUE="#qReasonType.iMoveReasonType_ID#">#qReasonType.cDescription#</OPTION>
								</CFLOOP>
									<option value="9e9">Reset to unassigned </OPTION>
							</SELECT>				
						</td>
						<td ><INPUT TYPE="submit" Class="BlendedButton" Name="UpdReasonCode" VALUE="Update" #STYLE# onclick="return processFormData(this.form);" ></td>
					</tr>
				</FORM>
			</cfloop>  
 
	</table>

</cfoutput>
<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">
