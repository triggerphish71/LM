<!----------------------------------------------------------------------------------------------
| DESCRIPTION   : This page is all Bond related administration                                 |
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
| RTS        |11/10/08    | Created Page + code for project 26955 BOND Designations House      |
| SFarmer    |08/21/2014  | 119716, 119717, 119720 changed query from                          |
|            |            | AvailableUnoccupiedApartments.cfm to                               |
|            |            |AvailableBondApartments.cfm                                         |
----------------------------------------------------------------------------------------------->
<cfoutput>

<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.UserId EQ "" OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") OR SESSION.qSelectedHouse.iHouse_ID EQ "">
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<CFQUERY NAME = "House" DATASOURCE = "#APPLICATION.datasource#">
SELECT	* FROM House WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND dtRowDeleted IS NULL
</CFQUERY>

<CFQUERY NAME = "TenantvsApt" DATASOURCE = "#APPLICATION.datasource#">
Select aa.iAptAddress_ID
,aa.cAptNumber
, aa.bIsBond 
from tenant t
join House h on (h.iHouse_ID = t.iHouse_ID and h.dtRowDeleted is null)
join TenantState ts on (ts.iTenant_ID = t.iTenant_ID and ts.dtRowDeleted is null and ts.iTenantStateCode_ID = 2)
join AptAddress aa on (aa.iAptAddress_ID = ts.iAptAddress_ID and aa.dtRowDeleted is null)
where h.iBondHouse = 1 
and aa.bIsBond = 1
and ((t.bIsBond = 0) or (t.bIsBond is null))
and h.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
order by aa.cAptNumber asc
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
	function NewBondHouse(){
		for(j=0;j<BondHouse.iBondHouse.length;j++)
				{
					if(BondHouse.iBondHouse[j].checked)
					{var dcheck = true;						
					}
				}
				if(!dcheck){
					alert("Please select Yes/No before clicking Save.")
					return false;	
				}
	}
	function BondType(){
		for(j=0;j<BondHouseType.bBondHouseType.length;j++)
				{
					if(BondHouseType.bBondHouseType[j].checked)
					{var tcheck = true;						
					}
				}
				if(!tcheck){
					alert("Please select bond house type before clicking Save.")
					return false;	
				}
	}
	
	function Save1(){
		var apt1 = BondApt.iAptAddress_ID.options[BondApt.iAptAddress_ID.selectedIndex].text;
		if(apt1 == 'Select Apartment'){
		alert("Please select an apartment.")
		return false;
		}
	return true;
	}
	
	function Save2(){
		var apt2 = BondApt2.iAptAddress_ID2.options[BondApt2.iAptAddress_ID2.selectedIndex].text;
		if(apt2 == 'Select Apartment'){
		alert("Please select an apartment.")
		return false;
		}
	return true;
	}

</script>
<!---Moved all from admin/menu.cfm into this page  --->
<!---Project 20125 modification. 06/10/08 Ssathya Only the AR analyst can declare the house as bond house  --->
<cfif (ListContains(session.groupid,'284') gt 0)> <!--- or (ListContains(session.groupid,'192') gt 0)> --->
		<form name="BondHouse" action = "BondHouseUpdate.cfm?ID=#House.iHouse_ID#" method="POST"> 
		<TABLE>
			<TR ><TH COLSPAN="3" STYLE="CENTER"> BOND HOUSE </TH></TR>
			
			<tr><td> 
				<cfif house.ibondhouse eq '1'>
				<b>#house.cName# is a Bond House.</b></br></br>
				<cfelse>
				<b>#house.cName# is not a Bond House.</b></br></br>
				</cfif>
			</td></tr>
			<!--- <table> --->
			<tr><th><b>You can Edit if this is a Bond House</b></th></tr>
			<TD > Is this house a Bond House ? &nbsp;&nbsp;
				<cfif house.ibondhouse eq '0'>
			           Yes<input type="radio" name="iBondHouse" value="1" onClick="document.BondInfo.iBondHouse.value=this.value">&nbsp;&nbsp;&nbsp;&nbsp;
			           No<input type="radio" name="iBondHouse" value="0" disabled="true" >
			    <cfelseif house.ibondhouse eq '1'>
			           Yes<input type="radio" name="iBondHouse" value="1" disabled="true">&nbsp;&nbsp;&nbsp;&nbsp;
			           No<input type="radio" name="iBondHouse" value="0" onClick="document.BondInfo.iBondHouse.value=this.value">
			    <cfelseif len(house.ibondhouse) eq 0><!--- null value --->
			           Yes<input type="radio" name="iBondHouse" value="1" onClick="document.BondInfo.iBondHouse.value=this.value">&nbsp;&nbsp;&nbsp;&nbsp;
			           No<input type="radio" name="iBondHouse" value="0" disabled="true" >
				</cfif>
					&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Save"  onclick="return NewBondHouse();"></br></br>	
			<!--- <A Href="AddBondHouse.cfm" style="Font-size: 12;">Click Here to Change the Bond House</a> --->
			 </td>
		</form>	

<!---
		Following: 1) Decide what type of Bond House it is (Total Units or Occupied)
		and 2) Allow for direct changing of the type of bond house the house is and
		 the changing of an apartment's bond designation
1) Bond House TYPE. 																			--->
	<cfif (house.ibondhouse eq '1')> 
		<form name="BondHouseType" action="BondHouseTypeUpdate.cfm?ID=#House.iHouse_ID#" method="POST">
			<TR ><TH COLSPAN="3" STYLE="CENTER"> Bond House Type </TH></TR>
			
				<tr><td> <cfif house.bBondHouseType eq '1'>
				<b>#house.cName# is currently a Bond House by TOTAL UNITS.</b>
				<cfelse>
				<b>#house.cName# is currently a Bond House by OCCUPIED UNITS.</b>
				</cfif>
			</td></tr>
			<!--- <table> --->
			<!--- <tr><b>You can Edit the House for Bond House Type Below</b></tr> --->
			<TD > How should Bond Apartment Percentage be calculated ? &nbsp;&nbsp;
				<cfif house.bBondHouseType eq '0'>
			           Total Units<input type="radio" name="bBondHouseType" value="1">
			           Occupied Units<input type="radio" name="bBondHouseType" value="0" disabled="true">
			    <cfelse>
			          Total Units<input type="radio" name="bBondHouseType" value="1"disabled="true">
			          Occupied Units<input type="radio" name="bBondHouseType" value="0" > 
			    </cfif>
					&nbsp;&nbsp;<input type="submit" name="Submit" value="Save" onClick="return BondType();"></td>
			
		</form>
	
	<!--- 2) Bond Apartments for the House. --->
			<!--- <cfif ((house.ibondhouse eq '1') and (ListContains(session.groupid,'240') gt 0))> --->
			<!---  <cfinclude template="../Shared/Queries/AvailableUnoccupiedApartments.cfm"> --->
			 <cfinclude template="../Shared/Queries/AvailableBondApartments.cfm">
			<form name="BondApt" action = "BondAptUpdate.cfm?ID=#'AptOptionSelect'#" method="POST" > 
			<TR ><th> Bond Apartments </th></TR>
				<!--- All apartments currently designated as bond --->
				<cfquery name="HouseAptBond" datasource="#APPLICATION.datasource#">
					select AA.iAptAddress_ID from AptAddress AA 
					where AA.bIsBond = 1
					and AA.dtrowdeleted is null
					and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<!--- Count of current bond designated apts --->
				<cfquery name="bAptCount" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as B 
					from AptAddress AA 
					where AA.bIsBond = 1
					and AA.dtrowdeleted is null
					and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<!--- Count of apts that were built and apply to the bond designation --->
				<cfquery name="AptCountTot" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as T 
					from AptAddress AA 
					where AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and AA.bBondIncluded = 1
					and AA.dtrowdeleted is null
				</cfquery>
				<!--- Apartment addresses that are occupied and pertain to bond applicable --->
				<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
					select distinct TS.iAptAddress_ID
					from TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS (NOLOCK) 
					join TIPS4.dbo.Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
					join TIPS4.dbo.AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null)
					where TS.dtRowDeleted is null
					and TS.iTenantStateCode_ID = 2
					and AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and TS.iAptAddress_ID = aa.iAptAddress_ID 
					and te.iTenant_ID = ts.iTenant_ID
					and aa.bBondIncluded = 1
				</cfquery>
				<cfset OccupiedRowCount = (Occupied.recordcount)>
	
				<!--- Decision set: percentage display based on bondhouse type --->
				<cfif house.bBondHouseType eq '1'>  <!--- Percent by total units --->
						<cfset Percent = ((#bAptCount.B# / #AptCountTot.T#) * 100)>
						<cfif Percent LT 20>
							<tr><td align="center">Bond Apartments : #bAptCount.B# / #AptCountTot.T# = <b><font color="red">#NumberFormat(Percent, '__.__')#%</font></b></td></tr>
						<cfelse>
							<tr><td align="center">Bond Apartments : #bAptCount.B# / #AptCountTot.T# = #NumberFormat(Percent, '__.__')#%</td></tr>
						</cfif>
				<cfelse>  <!--- Percent by occupied --->
						<cfset Percent = ((#bAptCount.B# / OccupiedRowCount) * 100)>
						<cfif Percent LT 20>
							<tr><td align="center">Bond Apartments : #bAptCount.B# / #OccupiedRowCount# = <b><font color="red">#NumberFormat(Percent, '__.__')#%</font></b></td></tr>
						<cfelse>
							<tr><td align="center">Bond Apartments : #bAptCount.B# / #OccupiedRowCount# = #NumberFormat(Percent, '__.__')#%</td></tr>
						</cfif>
				</cfif>
				<tr><td style="text-decoration:underline"> Apartment Listing</td></tr>
				<tr><td>
				<cfset BondList=ValueList(HouseAptBond.iAptAddress_ID)>
				&nbsp;&nbsp;<select name="iAptAddress_ID"> 
				  <option >Select Apartment</option>
					<!--- <cfloop query="AvailableUO"> --->
					<cfloop query="AvailableBondRooms"><!--- <cfloop query="Available"> Not using total house apts--->
						<cfscript>
							
							if (ListFindNocase(BondList,AvailableBondRooms.iAptAddress_ID,",") GT 0){ Note1 = '(Bond)';} else{ Note1=''; }
							if (IsDefined("TenantInfo.iAptAddress_ID") and  TenantInfo.iAptAddress_ID eq #AvailableBondRooms.iAptAddress_ID#
								OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") and qSecondTenantInfo.iAptAddress_ID eq #AvailableBondRooms.iAptAddress_ID#)) {
								Selected = 'Selected'; }
							else { Selected = ''; }
						</cfscript>
						<!--- if (ListFindNoCase(OccupiedList,AvailableUO.iAptAddress_ID,",") GT 0){ Note = '(Occupied)';} else{ Note=''; }  --->
						<option value="#AvailableBondRooms.iAptAddress_ID#" #Selected#> #AvailableBondRooms.cAptNumber# - #AvailableBondRooms.cDescription# #NOTE1#</option> 					
					</cfloop>
				</select>
			
			 
				 &nbsp;&nbsp;&nbsp;Change Bond Apartment Status ? &nbsp;&nbsp;
		        Bond:<input type="radio" name="iBondApt" value="1">&nbsp;&nbsp;&nbsp;&nbsp;
				Not Bond:<input type="radio" name="iBondApt" value="0">
				&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Save" onClick="return Save1();"> 
			</form>
			</td></tr>
			<form name="BondApt2" action = "BondAptUpdate2.cfm?ID=#'AptOptionSelect'#" method="POST" > 
			<tr><td style="text-decoration:underline">Bond Apartment with Non Bond Tenant Apartment Listing</td></tr>
				<tr><td>
				&nbsp;&nbsp;<select name="iAptAddress_ID2" > 
				  <option >Select Apartment</option>
					<cfloop query="TenantvsApt">
						<option value="#TenantvsApt.iAptAddress_ID#"> #TenantvsApt.cAptNumber#</option> 					
					</cfloop>
				</select>
				Clicking save will make the apartment non bond.
				<input type="submit" name="Submit" value="Save" onClick="return Save2();"> 
			</form>
			</td></tr>
	</cfif>
</cfif>
	
 



</TABLE>
</br></br>
<BR>
<A Href="../../../intranet/Tips4/MainMenu.cfm" style="Font-size: 18;">Click Here to Go Back To Main Screen</a>
<CFINCLUDE TEMPLATE='../../Footer.cfm'>
</cfoutput>