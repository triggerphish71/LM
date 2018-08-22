
<CFSCRIPT>
	if (session.cbillingtype eq 'd') { dailyfilter="is not null"; }
	else { dailyfilter="is null"; }
</CFSCRIPT>
<CFOUTPUT>
<cfparam name="currentroomID" default="">
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>
<cfset available = session.oRelocateServices.getAvailable(houseid=session.qSelectedHouse.iHouse_id)>
<cfquery name="WinthropAptdaily" dbtype="query">
	 select * from Available where ichargetype_ID in (89,1748)
</cfquery>
<cfquery name="WinthropAptMonthly" dbtype="query">
   select * from Available where ichargetype_ID in (1682,1748)
</cfquery>
<cfset tenantList = session.oRelocateServices.getTenantList(houseid=session.qSelectedHouse.iHouse_id)>
<cfset tenantIDList = valuelist(tenantList.iTenant_ID)>
<cfset tenantMoveOutCnt = valuelist(tenantList.moveoutcount)>
<cfset qSecondRate = session.oRelocateServices.getSecondRate(houseid=session.qSelectedHouse.iHouse_ID)>
<cfset qSecondRateAlMonthly = session.oRelocateServices.getSecondRateALMonthly(houseid=session.qSelectedHouse.iHouse_id)>
<cfset qSecondRateMC = session.oRelocateServices.getSecondRateMC(houseid=session.qSelectedHouse.iHouse_ID)>
<cfset qRecurring = session.oRelocateServices.getRecurring(houseid=session.qSelectedHouse.iHouse_ID,statecode=session.qselectedhouse.cstatecode)>
<cfset getStudioList = session.oRelocateServices.getStudioList(houseid=SESSION.qSelectedHouse.ihouse_id)>
<cfset studioListIds = valueList(getStudioList.iAptAddress_ID)>
<CFSET tenanteventhandler="onBlur='recurr(this,document.forms[0].iAptAddress_ID);'">
<cfset apteventhandler="onChange='recurr(document.forms[0].iTenant_ID,this);'">
<cfset qRoomAndBoard = session.oRelocateServices.getRoomAndBoard(houseid=session.qSelectedHouse.iHouse_ID,dailyfilter=dailyfilter)>
<cfset HouseApts = session.oRelocateServices.getHouseApts(houseid=session.qSelectedHouse.iHouse_ID)>
<cfset bondhouse = session.oRelocateServices.getBondHouse(houseid=session.qSelectedHouse.iHouse_id)>
<cfif NOT isNumeric(bondhouse.iBondHouse)>
	<cfset bondhouse.iBondHouse = 0>
</cfif>
<cfif bondhouse.ibondhouse eq 1>
	<cfset HouseAptBond = session.oRelocateServices.getHouseAptBond(houseid=session.qSelectedHouse.iHouse_ID)>
	<cfset bondaptids = valuelist(HouseAptBond.iAptAddress_ID)>
	<cfset HouseAptBondIncluded = session.oRelocateServices.getHouseAptBondIncluded(houseID=session.qSelectedHouse.iHouse_ID)>
	<cfset bondincludedaptids= valuelist(HouseAptBondIncluded.iAptAddress_ID)>
	<cfset bAptCount = session.oRelocateServices.getBAptCount(houseid=session.qSelectedHouse.iHouse_ID)>
	<cfset AptCountTot = session.oRelocateServices.getBondAptCountTot(houseid=session.qSelectedHouse.iHouse_ID)>
	<!--- Apartment addresses that are occupied and pertain to bond applicable --->
	<cfset Occupied = session.oRelocateServices.getOccupied(houseid=session.qSelected.iHouse_ID)>
	<cfset OccupiedRowCount = (Occupied.recordcount)>
</cfif>	
<cfif bondhouse.bIsMedicaid eq 1>
<!--- Apartment List of apartments set as Medicaid --->
	<cfset MedicaidAptList = session.oRelocateServices.getMedicaidAptList(houseid=session.qSelectedHouse.iHouse_id)>?
	<cfset MedicaidApartmentList = ValueList(MedicaidAptList.iAptAddress_ID)>
	<!--- Apartment List of apartments set as Medicaid and bond--->
	<cfset MedicaidbondApt = session.oRelocateServices.getMedicaidbondApt(houseid=session.qSelectedHouse.iHouse_ID)>
	<cfset MedicaidbondAptList= ValueList(MedicaidbondApt.iAptAddress_ID)>
	<!--- Apartment List of apartments set as Medicaid and bond incuded--->
	<cfset MedicaidbondincludedApt = session.oRelocateServices.getMedicaidbondincludedApt(houseid=session.qSelectedHouse.iHouse_ID)>
	<cfset MedicaidbondIncludedAptList= ValueList(MedicaidbondincludedApt.iAptAddress_ID)>
	<cfset MedicaidAptCount = session.oRelocateServices.getMedicaidAptCount(houseid=session.qSelectedHouse.iHouse_ID)>
	<!--- Count of total apts --->
	<cfset AptCountTotal = session.oRelocateServices.getMedicaidAptCountTotal(houseid=session.qSelectedHouse.iHouse_ID)>
	<!---Occupied medicaids rooms--->
	<cfset OccupiedMedicaidApt = session.oRelocateServices.getOccupiedMedicaidApt(houseid=session.qSelectedHouse.iHouse_ID)>	
	<cfset OccupiedMedicaidAptList=ValueList(OccupiedMedicaidAPt.iAptAddress_ID)>
</cfif>
<cfset MemCareAptList = session.oRelocateServices.getMemCareAptList(houseid=session.qSelectedHouse.iHouse_ID)>
<cfset MemoryCareApartmentList = ValueList(MemcareAptList.iAptAddress_ID)>
<!---Occupied medicaids rooms--->
<cfset OccupiedMemcareApt= session.oRelocateServices.getOccupiedMemcareApt(houseid=session.qSelectedHouse.ihouse_id)>
<cfset OccupiedMemcareAptList=ValueList(OccupiedMemcareApt.iAptAddress_ID)>	

<script language="JavaScript" src="../Shared/JavaScript/global.js" type="text/javascript"></script>
<script language="javascript" src="../Assets/Javascript/Relocate/relocateTenant.js" type="text/javascript"></script>
<cfinclude template="js_ChargeMenu.cfm">
<CFINCLUDE TEMPLATE="../../header.cfm">
<cfinclude template="../Assets/Javascript/Relocate/RelocateTenantJS.cfm">
<!--- Include Shared JavaScript --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">


<TITLE> TIPS 4 - Relocate Resident </TITLE>
<table style="border:none;">
	<tr>
		<td>
			<h1 class="PageTitle"> Tips 4 - Relocate Resident </h1>
		</td>
		<td colspan="2">
			Second Resident information:&nbsp;&nbsp; <a href="Second Resident.pdf" target="new"> <img src="../../images/Move-In-Help.jpg" width="25" height="25"/> <a/>
		</td>
	</tr>
</table>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">

<form Name="RelocateTenant" ACTION="RelocateUpdate.cfm" METHOD="POST">
<input type="hidden" id="tenantidlist" value="#tenantIDList#">
<input type="hidden" id="tenantmoveoutcnt" value="#tenantMoveOutCnt#">
<input type="hidden" id="studiolistid" value="#studioListIDs#">
<input type="hidden" name="currentroomID" id="icurrentroomID" value="">
<input type="hidden" name="hasBundledPricing" id="hasBundledPricing" value="#tenantList.bIsbundledPricing#">
<input type="hidden" name="bondval" value="#bondhouse.ibondhouse#">
	<TABLE>
		<TR><TH COLSPAN="4">Relocate Resident</TH></TR>
		<TR>
			<TD>Please select the resident that you would like to Relocate.</TD>
			<TD COLSPAN=2></TD>
			<TD>
				<SELECT NAME="iTenant_ID" onChange="moveoutinvoicecheck(this);PopulateChargeDropDown();Selectedtenantmedicaid(this);" #tenanteventhandler# id="Ten1">
					<OPTION VALUE="">Choose Resident</OPTION>
					<CFLOOP QUERY="TenantList">
						<cfscript>
							if (TenantList.bIsBond EQ 1){ Note = '(Bond)';} else{ Note=''; }					
							if (TenantList.iresidencytype_id EQ 2){ Note1 = '(Medicaid)';} else{ Note1=''; }					
							if (TenantList.iproductline_id EQ 2){ Note2 = '(Memory Care)';} else{ Note2=''; }
						</cfscript>
						<OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstName# (#TenantList.cSolomonKey#) #NOTE# #Note1# #Note2#</OPTION>
					</CFLOOP>
				</SELECT>
			</TD>
		</TR>	 
		<cfif bondhouse.ibondhouse eq 1>
			<tr>	
				<td colspan="4" style="Font-weight: bold;">Has the appropriate income certification form been completed to RE-qualify the resident as eligible for the purpose of meeting the bond program occupancy requirements when the resident was relocated?
					 Yes<input type="radio" name="cBondHouseEligibleAfterRelocate" value="1">
					 No<input type="radio" name="cBondHouseEligibleAfterRelocate" value="0">
				</td>
			</tr> 
			<tr>
				<td colspan="4" style="Font-weight: bold;">Resident�s Bond status after qualification paperwork was filled out for relocation:
					 Yes<input type="radio" name="cBondTenantEligibleAfterRelocate" value="1" onclick="document.RelocateTenant.cBondTenantEligibleAfterRelocate.value=this.value">
					 No<input type="radio"  name="cBondTenantEligibleAfterRelocate" value="0" onclick="document.RelocateTenant.cBondTenantEligibleAfterRelocate.value=this.value">
				</td>
			</tr>
			 <tr>
				<td colspan="4" style="Font-weight: bold;">Date the income re-certification was faxed or emailed to the Corporate Office:
					 <input type="textbox" id="txtBondReCertDate" name="txtBondReCertDate" value="00/00/0000">&nbsp;&nbsp;<span style="font-weight: normal;color: red;">(mm/dd/yyyy)</span>
				</td>
			</tr>
		</cfif>
		<TR>
			<TD>Relocate resident to Room: </TD> <TD COLSPAN=2></TD>
			<TD>
			<select name="iAptAddress_ID" ID="iAptNum" width="3.5in" #apteventhandler#>
			   <option value=""> Select... </option>
			</select>
			<select name="iAptAddress_ID2" ID="iAptNum2" style="visibility: hidden" width="3.5in" #apteventhandler#>
				<cfif bondhouse.iBondHouse eq 0 and bondhouse.bIsMedicaid eq 1>
					<cfloop query="MedicaidAptList">
					    <option value= "#MedicaidAptList.iAptAddress_ID#">#MedicaidAptList.cAptNumber#- #MedicaidAptList.cDescription# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp Medicaid</option>
				     </cfloop>
				</cfif>
				<cfif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq 1>
		    		<cfloop query="MedicaidAptList">
						<cfscript>
						    if (ListFindNoCase(MedicaidbondAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';}
						    else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						    if (ListFindNoCase(MedicaidbondIncludedAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note2 = '(Included)';}
						    else{ Note2=''; }
						</cfscript>
						<option value= "#MedicaidAptList.iAptAddress_ID#">#MedicaidAptList.cAptNumber#- #MedicaidAptList.cDescription# Medicaid #Note1# #Note2#</option>
					  </cfloop>
				</cfif>
			</SELECT>
			<select name="iAptAddress_ID3" ID="iAptNum3" style="visibility: hidden" width="3.5in" #apteventhandler#>
				<cfif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq "">
					<cfloop query="HouseApts">
						<cfscript>
							if (ListFindNocase(bondaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note1 = '(Bond) ';} else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNocase(bondincludedaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note2 = ' (Included)';} else{ Note2=''; }
							if (ListFindNoCase(MemoryCareApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} else{ Note4=''; }
						</cfscript>
				   		<option value="#HouseApts.iAptAddress_ID#" > #HouseApts.cAptNumber#- #HouseApts.cDescription# #Note1##Note2# #Note4# </option>
				    </cfloop>
				</cfif>
				<cfif bondhouse.ibondhouse eq 0 and bondhouse.bIsMedicaid eq 1>
		            <cfloop query="HouseApts">
				    	<cfscript>
							if (ListFindNoCase(MedicaidApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';}
							else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNoCase(MemoryCareApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} else{ Note4=''; }
						</cfscript>
		         		<option value= "#HouseApts.iAptAddress_ID#" >#HouseApts.cAptNumber#- #HouseApts.cDescription#  #Note3# #Note4#</option>
				       </cfloop>
				</cfif>
				<cfif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq 1>
					<cfloop query="HouseApts">
						<cfscript>
							if (ListFindNoCase(MedicaidApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';}
							else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNocase(bondaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note1 = '(Bond) ';}
							else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							if (ListFindNocase(bondincludedaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note2 = ' (Included)';}
							else{ Note2=''; }
							if (ListFindNoCase(MemoryCareApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} else{ Note4=''; }
						</cfscript>
						<option value= "#HouseApts.iAptAddress_ID#" >#HouseApts.cAptNumber#-#HouseApts.cDescription# #NOTE3##NOTE1##NOTE2##Note4#</option>
					</cfloop>
				</cfif>
				<cfif bondhouse.ibondhouse eq 0 and bondhouse.bIsMedicaid eq "">		
				    <cfloop query="HouseApts" >
						<cfscript>
							if (ListFindNoCase(MemoryCareApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} else{ Note4=''; }
						</cfscript>
					  	<option value= "#HouseApts.iAptAddress_ID#" >#HouseApts.cAptNumber#- #HouseApts.cDescription#  #Note4#</option>
				    </cfloop>
				</cfif>
		    </SELECT>
		    <SELECT name="iAptAddress_ID4" ID="iAptNum4" style="visibility: hidden" width="3.5in" #apteventhandler#>
			    <CFLOOP QUERY='MemCareAptList'>
					<cfscript>
				   		Note = '(Memory Care)';
						if (IsDefined("TenantInfo.iAptAddress_ID")	and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID# OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)){
							Selected = 'Selected';
						}
						else { Selected = ''; }
					</cfscript>
					<option value= "#MemCareAptList.iAptAddress_ID#"> #MemCareAptList.cAptNumber# - #MemCareAptList.cDescription#    #Note# </option>
				</CFLOOP>
		    </SELECT>
			<cfif bondhouse.ibondhouse eq 1>
				<cfif bondhouse.bBondHouseType eq '1'>
					<cfset Percent = ((#bAptCount.B# / #AptCountTot.T#) * 100)>
					<cfif Percent LT 20>
						Bond&nbsp;Apartment&nbsp;Percentage:&nbsp;<b><font color="red">#NumberFormat(Percent, '__.__')#%</font></b>
					<cfelse>
						Bond&nbsp;Apartment&nbsp;Percentage:&nbsp;#NumberFormat(Percent, '__.__')#%
					</cfif>
				<cfelse><!--- Percent by occupied --->
					<cfset Percent = ((#bAptCount.B# / OccupiedRowCount) * 100)>
					<cfif Percent LT 20>
						Bond&nbsp;Apartment&nbsp;Percentage:&nbsp;<b><font color="red">#NumberFormat(Percent, '__.__')#%</font></b>
					<cfelse>
						Bond&nbsp;Apartment&nbsp;Percentage:&nbsp;#NumberFormat(Percent, '__.__')#%
					</cfif>
				</cfif>
			</cfif>
			</TD>
		</tr>
		<TR>
			<td></td>
			<TD COLSPAN=2></TD>
			<TD>
				<cfif bondhouse.bIsMedicaid eq '1'>
					<cfset MedicaidPercent = ((#MedicaidAptCount.TotalMedicaidApt# / #AptCountTotal.T#) * 100)>
					<cfif MedicaidPercent LT 20>
						Medicaid&nbsp;Apartment&nbsp;Percentage:&nbsp;<b><font color="red">#NumberFormat(MedicaidPercent, '__.__')#%</font></b>
					<cfelse>
						Medicaid&nbsp;Apartment&nbsp;Percentage:&nbsp;#NumberFormat(MedicaidPercent, '__.__')#%
					</cfif>
				</cfif>
			 </TD>
		</TR>
		<TR><TD COLSPAN=100% STYLE='vertical-align:top;'><SPAN ID='recurringchange'></SPAN></TD></TR>
		<TR>
			<TD>When did this change take Effect?</TD> <TD COLSPAN=2></TD>
			<TD> 
				<SELECT NAME="Month" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);" > <!---onBlur="effectivevalidate();"--->
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"><CFIF I EQ Month(Now())> <CFSET Selected='Selected'> <CFELSE> <CFSET Selected=''> </CFIF>
						<OPTION VALUE="#I#" #Selected#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/
				<SELECT NAME="Day" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);" > <!---onBlur="effectivevalidate();backvalidate();"--->
					<CFLOOP INDEX="I" FROM="1" TO="31" STEP="1"><CFIF I EQ Day(Now())> <CFSET Selected='Selected'> <CFELSE>	<CFSET Selected=''>	</CFIF>
						<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/		
				<select NAME='Year'STYLE='text-align: center;' MAXLENGTH=4 onKeyUP="this.value=Numbers(this.value)" onBlur="effectivevalidate();backvalidate();" ReadOnly onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);">
					<OPTION VALUE=""> Select.. </OPTION>
					<OPTION VALUE="#Year(now())#"> #Year(now())# </OPTION>
					<OPTION VALUE="#Year(now())-1#"> #Year(now())-1# </OPTION>
				<select>
			</TD>
		</TR>
		<TR>
			<TD><INPUT TYPE="submit" NAME="save" VALUE="Save" CLASS="SaveButton" onmouseover="return hardhaltvalidation(RelocateTenant);" onclick="return checkyear();" ></TD><TD COLSPAN=2></TD>
			<TD> <INPUT TYPE="button" NAME="Don't Save" VALUE="Don't Save" CLASS="DontSaveButton" onClick="redirect()"></TD>
		</TR>
		<TR>
			<TD  COLSPAN="4" style="font-weight: bold; color: red;"><U> NOTE:</U> You must SAVE to keep information which you have entered!</TD>
		</TR>
	</TABLE>
<form>
<CFINCLUDE TEMPLATE="../../footer.cfm">
</CFOUTPUT>
