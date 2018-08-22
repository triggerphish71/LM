<!--- *******************************************************************************
Name:			NewApt.cfm
Process:		Create/Add New room to the house

Called by: 		HouseApts.cfm
Calls/Submits:	NewAptAction.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            02/07/2002      Original Authorship

******************************************************************************** --->

<!--- Include Intranet Header --->
<cfinclude template="../../../header.cfm">

<cfif isDefined("url.iAptAddress_ID")>
	<cfquery name="editApt" DATASOURCE="#APPLICATION.datasource#">
	select AA.*, AT.cDescription from AptAddress AA
	inner join AptType AT ON AA.iAptType_ID = AT.iAptType_ID
	where AA.iAptAddress_ID = #url.iAptAddress_ID#
	</cfquery>
</cfif>

<!--- Retrieve Available Apt Types --->
<cfquery name="qAptTypes" DATASOURCE="#APPLICATION.datasource#">
select * from AptType WHERE dtRowDeleted IS NULL ORDER BY cDescription
</cfquery>

<Cfquery name="qHouseProductLines" datasource="#APPLICATION.datasource#">
select PL.cDescription, HPL.iHouseProductLine_ID 
from HouseProductLine  HPL
inner join ProductLine PL on HPL.iProductLine_ID = PL.iProductLine_ID
where HPL.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and HPL.dtRowDeleted IS NULL  and PL.dtRowDeleted IS NULL
order by PL.cDescription
</Cfquery>
<cfoutput>
<br><br>
<FORM ACTION="NewAptAction.cfm" METHOD="POST">
 <A HREF="/intranet/tips4/DataTableMaintenance/House/HouseApts.cfm">Back to House AptType Assignment</A><BR>
<table>
	<tr><TH colspan="100%"> <cfif isDefined("url.iAptAddress_ID")>Edit Apartment #EditApt.cAptNumber#<cfelse>New Apartment</cfif>  for #SESSION.HouseName#</TH></tr>
	<tr>
		<td>Apartment Type</td>
		<td>Apartment Number</td>
		<td>Weight</td>
		<td colspan=2>Comments</td>
		<td>Product Line</td>
	</tr>	
	<tr>
		<td>
			<select name="iAptType_ID">
				<cfloop query="qAptTypes"><option value="#qAptTypes.iAptType_ID#"<Cfif isDefined("url.iAptAddress_ID") and Editapt.iAptType_ID is "#qAptTypes.iAptType_ID#"> SELECTED</Cfif>>#qAptTypes.cDescription#</option></cfloop>
			</select>
		</td>
		<td style="text-align: center;"><input type="text" NAME="cAptNumber" SIZE=10 <Cfif isDefined("url.iAptAddress_ID")>value="#EditApt.cAptNumber#"</cfif>></td>
		<td style="text-align: center;"><input type="text" NAME="fOccupancyWeight" SIZE=3 <Cfif isDefined("url.iAptAddress_ID")>value="#EditApt.fOccupancyWeight#"<cfelse> value="1.0"</cfif>></td>
		<td colspan=2><textarea COLS="20" ROWS="2" NAME="cComments"><Cfif isDefined("url.iAptAddress_ID")>#EditApt.cComments#</cfif></textarea></td>
		<td><select name="iHouseProductLine_ID"><cfloop query="qHouseProductLines"><option value="#iHouseProductLine_ID#"<Cfif isDefined("url.iAptAddress_ID") and Editapt.iHouseProductLine_ID is "#qHouseProductLines.iHouseProductLine_ID#"> SELECTED</Cfif>>#cDescription#</option></cfloop></select></td>
	</tr>
	<tr>
		<td colspan=3><Cfif isDefined("url.iAptAddress_ID")><input type="hidden" name="iAptAddress_ID" value="#url.iAptAddress_ID#"><input type="submit" NAME="Add" value="Edit"><cfelse><input type="submit" NAME="Add" value="Add"></Cfif></td>
		<td colspan=3 style="text-align:right;"><input type="button" NAME="Cancel" value="Cancel" onClick="location.href='HouseApts.cfm'"></td>
	</tr>
</table>
</form>
</cfoutput>

<!--- Include Intranet Footer --->
<cfinclude template="../../../footer.cfm">