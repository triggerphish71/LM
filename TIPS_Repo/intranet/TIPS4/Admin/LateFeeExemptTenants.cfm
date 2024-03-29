<!---------------------------------------------------------------------------------------------------
|Name:       LateFeeExemptTenants.cfm                                                                      |
|Type:       Template                                                                                |
|Purpose:    This page is for AR Admin to assign the tenant to be exempt from late fee with          |
|            late fee. AR Admin can Go and set the minimum Amount for applying the late fee.         |
|			AR ADmin will have the ablity to set the late fee for the particular house.              |
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
|Calls: UpdateTenantLateFeeUpdate.cfm																 |
|    Parameter Name                      Description                                                 |
|    ------------------------------      ------------------------------------------------------------|
|    None
|																									 |
|Calls: UpdateHouseLateFee.cfm																		 |
|    Parameter Name                      Description
|    ------------------------------      -----------------------------------------------------------
|                   
|
|----------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                              |
|------------|------------|--------------------------------------------------------------------------|
| Sathya  	 |02/26/10    | Created this page as part of project 20933 Late Fees                     |
------------------------------------------------------------------------------------------------------>

<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<!--- Gets the tenant in the house --->
<CFQUERY NAME = "GetTenantListinHouse" DATASOURCE = "#APPLICATION.datasource#">
select CASE LEN(ad.cAptNumber) 
				WHEN 1 THEN ('00' + ad.cAptNumber)
				WHEN 2 THEN ('0' + ad.cAptNumber) 
				ELSE ad.cAptNumber
			END as cAptNumber,
			ts.bIsLateFeeExempt as LateFeeExempt
			,apt.cDescription as cAptType 
			,t.iTenant_ID ,t.cSolomonKey as RID
			,t.cFirstName as firstname ,t.cLastName as lastname ,rt.cDescription as Residency
			,ts.dtMoveIn as movein ,ts.dtMoveOut as moveout ,h.cName			
	from AptAddress AD (nolock)
	left join houseproductline hpl (nolock) on hpl.ihouseproductline_id = ad.ihouseproductline_id and hpl.dtrowdeleted is null
	left join productline pl (nolock) on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
	join	TenantState ts (nolock) on ad.iAptAddress_ID = ts.iAptAddress_ID and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID = 2 and ts.dtRowDeleted is null)		
	left outer join	AptType APT	(nolock) on (apt.iAptType_ID = ad.iAptType_ID and apt.dtRowDeleted is null)
	left join Tenant t (nolock) on (t.iTenant_ID = ts.iTenant_ID)
	join	ResidencyType RT (nolock) on (rt.iResidencyType_ID = ts.iResidencyType_ID)
	left join SLevelType ST	(nolock) on (t.cSlevelTypeSet = st.cSlevelTypeSet and ts.iSPoints <= iSPointsMax and ts.iSPoints >= iSPointsMin)
	left join house h (nolock) on ad.iHouse_id = h.iHouse_id 
	where	ad.dtRowDeleted is null
			and ad.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			and t.dtRowDeleted is null
			and t.itenant_ID is not null
			<!---  Exclude Medicades --->
			and ts.iResidencyType_ID <> 2
			<!---  Excludes VA deferred payment who are eligible for the VA benefits --->
			and (ts.bDeferredPayment is NULL or ts.bDeferredPayment  = 0)
	and (ts.iTenantStateCode_ID is null or ts.iTenantStateCode_ID IN (2))
	order by ad.cAptNumber 
</CFQUERY>

<!--- Get the late fee information from the house --->
<CFQUERY NAME = "GetLateFeeInfoForHouse" DATASOURCE = "#APPLICATION.datasource#">
	Select *
	From
	HouseLateFee where iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and dtRowDeleted is null
</CFQUERY>
<CFINCLUDE TEMPLATE="../../header.cfm">
<!--- Include shared javascript --->
<CFINCLUDE TEMPLATE='../Shared/HouseHeader.cfm'>
<cfoutput>


<table class="noborder">
<tr><td class="transparent" align="center"><P class="PAGETITLE"> Late Fee Information For <cfoutput>	#session.HouseName#	</cfoutput></P></td></tr>
</table>
<!--- Only the AR Master Admin can edit the late fee information for house--->
<!--- DEvelopment its 1381 ListContains(SESSION.groupid, '1381') --->
<!--- Production its 285 is AR MASTER ADMIN so please the below code and skip the code after that --->
<!--- Please UNComment the below cfIF line code when moving to Production --->
<cfif (ListContains(SESSION.groupid, '285') gt 0)> 
<!--- Please Comment the below cfIF line code when moving to Production --->
<!--- <cfif (ListContains(SESSION.groupid, '1381') gt 0)>  --->
	<TABLE>
		
		<TR><TH COLSPAN=100%>Late Fee Information</TH></TR>
		<TR style="font-weight: bold; text-align: center; background: gainsboro;">
			<TD><b>HOUSE</b></TD>
			<TD align="center"><b>LATE LEE APPLIED</b></TD>
			<TD align="center"><b>MINIMUM BALANCE FOR LATE FEE BEING APPLIED</b></TD>
			<td><b>Applied in which Year</b><br>(e.g, 200909)</br></td>
			<TD><b>CHANGE</b></TD>
		</TR>
		
		<cfif GetLateFeeInfoForHouse.recordcount gt 0>
		<FORM NAME="UPDATEHOUSELATEFEE" ACTION="UpdateHouseLateFeeInfo.cfm" METHOD="POST">	
		<TR>
			<TD><b>#GetTenantListinHouse.cName#</b></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" NAME="LateFeeAmount" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mLateFeeAmount)#"></TD>
			<TD><INPUT TYPE="Text" disabled="disabled" NAME="MinimumBalanceForLateFee" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mMinimumBalanceForLateFee)#"></TD>
			<TD><INPUT TYPE="Text" disabled="disabled" NAME="AppliesToAcctYear" VALUE="#GetLateFeeInfoForHouse.cAppliesToAcctYear#"></TD>
			<input type="hidden" value="delete" name="forDelete">
			<TD><input name="Delete" type ="submit" value ="Delete"></TD>
		</TR>
		</FORM>
		<cfelse>
		 <FORM NAME="UPDATEHOUSELATEFEE" ACTION="UpdateHouseLateFeeInfo.cfm" METHOD="POST">	
		<TR>
			<TD><b>#GetTenantListinHouse.cName#</b></TD>
			<TD><INPUT TYPE="Text" NAME="LateFeeAmount" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mLateFeeAmount)#"></TD>
			<TD><INPUT TYPE="Text" NAME="MinimumBalanceForLateFee" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mMinimumBalanceForLateFee)#"></TD>
			<TD><INPUT TYPE="Text" NAME="AppliesToAcctYear" VALUE="#GetLateFeeInfoForHouse.cAppliesToAcctYear#"></TD>
			<input name="forInsert" type="hidden" value="forinsert">
			<TD><input name="Save" type ="submit" value ="Save"></TD>
		</TR>
		</FORM>
	</cfif>
	</TABLE>
<!--- If not Ar Admin then can just see the data but not edit it --->
<cfelse>
<TABLE>
		<TR><TH COLSPAN=100%>Late Fee Information</TH></TR>
		<TR style="font-weight: bold; text-align: center; background: gainsboro;">
			<TD><b>HOUSE</b></TD>
			<TD align="center"><b>LATE LEE APPLIED</b></TD>
			<TD align="center"><b>MINIMUM BALANCE FOR LATE FEE BEING APPLIED</b></TD>
			<td><b>Applied in which Year</b><br>(e.g, 200909)</br></td>
		</TR>
		<cfif GetLateFeeInfoForHouse.recordcount gt 0>
		<TR>
			<TD><b>#GetTenantListinHouse.cName#</b></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mLateFeeAmount)#"></TD>
			<TD><INPUT TYPE="Text" disabled="disabled"  VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mMinimumBalanceForLateFee)#"></TD>
			<TD><INPUT TYPE="Text" disabled="disabled"  VALUE="#GetLateFeeInfoForHouse.cAppliesToAcctYear#"></TD>
			
		</TR>
		<cfelse>
		
		<TR>
			<TD><b>#GetTenantListinHouse.cName#</b></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mLateFeeAmount)#"></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" VALUE="#LSCurrencyFormat(GetLateFeeInfoForHouse.mMinimumBalanceForLateFee)#"></TD>
			<TD><INPUT TYPE="Text"  disabled="disabled" VALUE="#GetLateFeeInfoForHouse.cAppliesToAcctYear#"></TD>
			
		</TR>
		
	</cfif>
</TABLE>

</cfif>

<br></br>
<A HREF='menu.cfm' style="Font-size: 14;"><B>Click Here to Go Back to the Administration Screen.</B></A>
<br ></br>

<table class="noborder">
<tr><td class="transparent"><P class="PAGETITLE"><B STYLE="color: red;">Please note each change for Residents listed below must be submitted seperately.</B></P></td></tr>
</table>
<!--- <B STYLE="color: red;">Please note each change for Residents listed below must be submitted seperately.</B>
 --->	
<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)> 
    <TABLE>
	
	<TR><TH COLSPAN=100%>List of Tenant in <cfoutput>#SESSION.HouseName#</cfoutput></TH></TR>
	<TR style="font-weight: bold; text-align: center; background: gainsboro;">
		<TD><b>Apartment</b></TD>
		<TD><b>Type</b></TD>
		<TD><b>RID</b></TD>
		<TD><b>Name</b></TD>
		<TD><b>Residency</b></TD>
		<td align="center"><b>MoveIn</b></td>
		<TD align="center"><b>Exempt from Late Fee</b></TD>
		<TD align="center"><b>Update</b></td>
	
	</TR>
	<CFLOOP QUERY='GetTenantListinHouse'>
	<FORM NAME="Form#GetTenantListinHouse.iTenant_ID#" ACTION="UpdateTenantLateFeeExempt.cfm" METHOD="POST">
		
		<tr>
			<td>
				#GetTenantListinHouse.cAptNumber#
			</td>
			<td>
				#GetTenantListinHouse.cAptType#
			</td>
			<td>
				#GetTenantListinHouse.RID# 
				<INPUT TYPE="Hidden" NAME="RID" VALUE="#GetTenantListinHouse.RID#">
				
			</td>
			<td>
				#GetTenantListinHouse.lastname# #GetTenantListinHouse.firstname#
			</td>
			<td>
				#GetTenantListinHouse.Residency#
			</td>
			<td>
				#DATEFORMAT(GetTenantListinHouse.movein, "mm/dd/yyyy")#
			</td>
			<td align="center">
			    <cfset bit= iif(GetTenantListinHouse.LateFeeExempt IS 1, DE('Checked'), DE('Unchecked'))>
                <input type= "CheckBox" name= "LateFeeExempt" Value = "1" #Variables.bit#>	
			</td>
			<td>
				
			<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#GetTenantListinHouse.iTenant_ID#">
			<!--- <INPUT TYPE="Button" value="Change" onClick="submit();"> --->
			<cfif GetTenantListinHouse.LateFeeExempt eq 1>
			<input name="submit" type ="submit" value ="Change">
			<cfelse>
			<input name="submit" type ="submit" value ="Update ">
			</cfif>
			</td>
			
			<!--- Current row:  #GetTenantListinHouse.currentrow# --->
			<!--- <td>
				<input name="submit" TYPE='submit' onClick="href='UpdateTenantLateFeeExempt.cfm?TenantID=#GetTenantListinHouse.iTenant_ID#'">
			</td> --->
		</tr>
		</FORM>
	</CFLOOP>
</TABLE>
</cfif>
<h6>**The List excludes the tenant who fall in the category of Medicaid and VA Deferred Payment(VA Benefit Eligible) </h6>
</cfoutput>
<h6 STYLE="color: red;">**Please note any change you make now will show up when you run the next invoice.</h6>
<BR>
<A HREF='menu.cfm'>Click Here to Go Back to the Administration Screen.</A>

<CFINCLUDE TEMPLATE='../../Footer.cfm'>






