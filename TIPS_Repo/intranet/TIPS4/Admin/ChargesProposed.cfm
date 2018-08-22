<!--- *******************************************************************************
Name:			ChargesProposed.cfm
Process:		Adjust new rates to match budget amounts

Called by: 		Menu.cfm
Calls/Submits:		
		
Modified By         Date        Reason
-------------     	----------  --------------------------------------------
Steve Davison		12/10/2002	Initial release.
Paul Buendia		12/23/2002	Changed onblur for discount field to 'CreditNumbers()'
								to allow for negative numbers.
"					"			set ImpactPct in a condictional such that if the 
								divisor is 0 set the variable to 0 to avoid a
								divide by 0 error that was being experienced
"					12/30/02	changed current total to subtract discounts
								as per steve arndt
"					"			changed period to pull from last completed tips month
								instead of 200212 (theory is that the last tips month
								will include all correct data including corect mi and mo 
								data														
******************************************************************************** --->
<!--- =============================================================================================
Include Javascript code for only allowing:
Numbers	:	USE onKeyUp = "this.value=Numbers(this.value)"
Letters:	USE onKeyUp = "this.value=Letters(this.value)"
============================================================================================= --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
<!--- =============================================================================================
Include Intranet Header
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<CFSET tmpLastPeriod = DateAdd('m', -1, SESSION.TipsMonth)>
<CFSET LastPeriod = DateFormat(tmpLastPeriod,'yyyymm')>

<H1 CLASS="PageTitle"> Tips 4 - Proposed Rates </H1>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<cfstoredproc procedure="sp_ChargesProposed" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
  <cfprocresult NAME="RoomCharges" resultset="1">
  <cfprocresult NAME="CareCharges" resultset="2">
  <cfprocparam type="IN" value="#SESSION.qSelectedHouse.iHouse_ID#" DBVARNAME="@iHouse_ID" cfsqltype="CF_SQL_INTEGER">
  <cfprocparam type="IN" value="#LastPeriod#" DBVARNAME="@cPeriod" cfsqltype="CF_SQL_CHAR">
</cfstoredproc>
<cfstoredproc procedure="sp_ChargesProposedTenants" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
  <cfprocresult NAME="TenantCharges" resultset="1">
  <cfprocresult NAME="TenantChargeTotals" resultset="2">
  <cfprocparam type="IN" value="#SESSION.HouseName#" DBVARNAME="@Scope" cfsqltype="CF_SQL_VARCHAR">
  <cfprocparam type="IN" value="#LastPeriod#" DBVARNAME="@cPeriod" cfsqltype="CF_SQL_CHAR">
</cfstoredproc>

<CFOUTPUT> 
  <LINK REL=StyleSheet TYPE="Text/css" HREF="//gum/intranet/Tips4/Shared/Style3.css">
 
  <A HREF='Menu.cfm' STYLE='font-size:small;font-weight:bold;'>Click Here to go Back to the Admin page.</A>
  <FORM NAME = "CareCharges" ACTION="ChargesProposedUpdate.cfm" METHOD="POST" onKeyPress="CancelEnter();">
<CFSET VPList = 'steveV,matthewp,lindam,gloryc,stevea'>

<!--- ==================================================================================================
	OR ( (SESSION.USERID EQ 3122 OR SESSION.USERID EQ 1949 OR SESSION.USERID EQ 3179) AND SESSION.qSelectedHouse.iHouse_ID EQ 69 AND DateFormat(now(),'mm/dd/yyyy') LT '01/18/2003')
	OR ( (SESSION.USERID EQ 1942) AND SESSION.qSelectedHouse.iHouse_ID EQ 56 AND DateFormat(now(),'mm/dd/yyyy') LT '01/18/2003' )
	OR ( (SESSION.USERID EQ 1942) AND SESSION.qSelectedHouse.iHouse_ID EQ 56 AND DateFormat(now(),'mm/dd/yyyy') LT '01/21/2003' )
	OR (SESSION.USERID EQ 3179 AND DateFormat(now(),'mm/dd/yyyy') LT '01/22/2003')
================================================================================================== --->
<CFIF SESSION.USERID EQ 3025 OR SESSION.USERID EQ 3146 OR SESSION.USERID EQ 36 OR SESSION.USERID EQ 3074 
	OR listfindNocase(session.codeblock,23) GTE 1
	OR ListFindNoCase(VPList, SESSION.USERNAME, ",") GT 0
	OR ( (SESSION.USERID EQ 3009) AND SESSION.qSelectedHouse.iHouse_ID EQ 167 AND DateFormat(now(),'mm/dd/yyyy') LT '01/30/2003' )
>
	<CFSET Readonly=0>
<CFELSE>
	<CFSET Readonly=1>
</CFIF>

    <TABLE>
		<CFIF readonly EQ 0>
		<TR><TD STYLE="text-align:center;color:red"> To save any rates you have entered or to recalculate, you must press the Save button </TD></TR>
		</CFIF>
	  <TR>
	    <TD STYLE="text-align:center;"><CFIF Readonly EQ 0><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save"	VALUE="Save"></CFIF></TD>
	  </TR>
      <TR>
		<TD STYLE="text-align:center;"><A HREF="ChargesProposedReport.cfm"> PRINT PROPOSED CHARGES SUMMARY </A></TD>
      </TR>
	</TABLE>
    <TABLE>
      <TH colspan="2"> House Charges </TH>
      <TR> 
        <TD width> <TABLE>
            <TD colspan="5" STYLE='background:gainsboro;font-weight:bold;font-size:small;text-align:center;'> Room and Board </TD>
            <TR> 
              <TD STYLE="text-align:center;">Apt Type</TD>
              <TD STYLE="text-align:right;">Monthly</TD>
              <TD STYLE="text-align:right;">Daily</TD>
              <TD STYLE="text-align:center;">New Monthly</TD>
              <TD STYLE="text-align:right;">New Daily</TD>
            </TR>
            <CFLOOP QUERY="RoomCharges">
              <TR> 
                <TD STYLE="text-align:center;">#RoomCharges.cRoomType#</TD>
                <TD STYLE="text-align:right;">#LSCurrencyFormat(RoomCharges.mMonthlyRent)#</TD>
                <TD STYLE="text-align:right;">#LSCurrencyFormat(RoomCharges.mDailyRent)#</TD>
                <TD STYLE="text-align:center;"><input name="ROOM_#RoomCharges.iAptType_ID#" STYLE="text-align:right;" SIZE="7" value="#TRIM(LSNumberFormat(RoomCharges.mMonthlyRentProposed, '99999.99'))#" onKeyUp='this.value=CreditNumbers(this.value);' onBlur='this.value=cent(round(CreditNumbers(this.value)));'></TD>
                <TD STYLE="text-align:right;">#LSCurrencyFormat(RoomCharges.mDailyRentProposed)#</TD>
              </TR>
            </CFLOOP>
          </TABLE></TD>
      </TR>
      <TR> 
        <TD> <TABLE>
            <TD colspan="5" STYLE='background:gainsboro;font-weight:bold;font-size:small;text-align:center;'> Care </TD>
            <TR> 
              <TD width="138" STYLE="text-align:center;">Level</TD>
              <TD width="190" STYLE="text-align:right;">Monthly</TD>
              <TD width="171" STYLE="text-align:right;">Daily</TD>
              <TD width="84" STYLE="text-align:center;">New Monthly</TD>
              <TD width="230" STYLE="text-align:right;">New Daily</TD>
            </TR>
            <CFLOOP QUERY="CareCharges">
              <TR> 
                <TD STYLE="text-align:center;">#CareCharges.Acuity#</TD>
                <TD STYLE="text-align:right;">#LSCurrencyFormat(CareCharges.mMonthlyCare)#</TD>
                <TD STYLE="text-align:right;">#LSCurrencyFormat(CareCharges.mDailyCare)#</TD>
                <TD STYLE="text-align:center;"><input name="CARE_#CareCharges.iSLevelType_ID#" STYLE="text-align:right;" SIZE="7" value="#TRIM(LSNumberFormat(CareCharges.mMonthlyCareProposed, '99999.99'))#" onKeyUp='this.value=CreditNumbers(this.value);' onBlur='this.value=cent(round(CreditNumbers(this.value)));'></TD>
                <TD STYLE="text-align:right;">#LSCurrencyFormat(CareCharges.mDailyCareProposed)#</TD>
              </TR>
            </CFLOOP>
          </TABLE></TD>
      </TR>
    </TABLE>
    <BR>
    <TABLE>
	  <TR>
        <TH colspan="14"> Residents </TH>
      </TR>
	  <TR>
        <TH colspan="7"> Medicaid Residents are shown in <font style="color:red";>RED</font><BR>Respite Residents are shown in <font style="color:green";>GREEN</font></TH>
        <TH colspan="7"> Positive discounts reduce revenue </font> 
        </TH>
      </TR>
      <TR> 
        <TD COLSPAN="4" STYLE='background:gainsboro;font-weight:bold;font-size:small;text-align:center;'> Resident Info </TD>
        <TD COLSPAN="4" STYLE='background:gainsboro;font-weight:bold;font-size:small;text-align:center;text-align:center;'> Current Charges </TD>
        <TD COLSPAN="4" STYLE='background:gainsboro;font-weight:bold;font-size:small;text-align:center;'> Proposed Charges </TD>
        <TD COLSPAN="2" STYLE='background:gainsboro;font-weight:bold;font-size:small;text-align:center;'> Impact </TD>
      </TR>
      <TR> 
        <TD>Apt</TD>
        <TD>Apt Type</TD>
        <TD>Name</TD>
        <TD>Acuity</TD>
        <TD>Room/Board</TD>
        <TD>Care</TD>
        <TD>Discounts</TD>
        <TD>Net Charges</TD>
        <TD>Room/Board</TD>
        <TD>Care</TD>
        <TD>Discounts</TD>
        <TD>Net Charges</TD>
        <TD>Dollars</TD>
        <TD>Percent</TD>
      </TR>
      <CFLOOP QUERY="TenantCharges">
        <TR> 
          <TD><input name="#TenantCharges.TenantID#" type="hidden" value="#TenantCharges.TenantID#"> 
            #TenantCharges.AptNumber#</TD>
          <TD STYLE="text-align:center;">#TenantCharges.Descript#</TD>
          <TD NOWRAP <CFIF TenantCharges.ResidencyType_ID EQ "2">STYLE="color:Red;"<CFELSEIF TenantCharges.ResidencyType_ID EQ "3"> STYLE='color:green;'</CFIF>>#TenantCharges.FirstName# #TenantCharges.LastName# #ResidencyType_ID#</TD>
          <TD STYLE="text-align:center;">#TenantCharges.Acuity#</TD>
          <TD STYLE="text-align:right;">#LSCurrencyFormat(TenantCharges.RoomRent)#</TD>
          <TD STYLE="text-align:right;">#LSCurrencyFormat(TenantCharges.ResidentCare)#</TD>
          <TD STYLE="text-align:right;"><CFIF TenantCharges.Discount NEQ "">
              <CFSET CurrentDiscount = TenantCharges.Discount>
              <CFELSE>
              <CFSET CurrentDiscount = 0.00>
            </CFIF> #LSCurrencyFormat(CurrentDiscount)#</TD>
          <TD STYLE="text-align:right;font-weight:bold;"><CFSET CurrentTotal = TenantCharges.RoomRent + TenantCharges.ResidentCare - CurrentDiscount> 
            #LSCurrencyFormat(CurrentTotal)#</TD>
          <TD STYLE="text-align:right;">#LSCurrencyFormat(TenantCharges.RoomRentProposed)#</TD>
          <TD STYLE="text-align:right;">#LSCurrencyFormat(TenantCharges.ResidentCareProposed)#</TD>
          <TD STYLE="text-align:right;"><CFIF TenantCharges.DiscountProposed NEQ "">
              <CFSET ProposedDiscount = TenantCharges.DiscountProposed>
              <CFELSE>
              <CFSET ProposedDiscount = 0.00>
            </CFIF><CFIF trim(TenantCharges.FirstName) EQ "Vacant">0.00<CFELSE><input name="Discount_#TenantCharges.TenantID#" STYLE="text-align:right;" SIZE="7" value="#LSNumberFormat(TRIM(ProposedDiscount), '99999.99-')#" onChange="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(CreditNumbers(this.value)));"></CFIF></TD>
          <TD STYLE="text-align:right;font-weight:bold;"><CFSET ProposedTotal = TenantCharges.RoomRentProposed + TenantCharges.ResidentCareProposed - ProposedDiscount> 
            #LSCurrencyFormat(ProposedTotal)#</TD>
          <TD STYLE="text-align:right;"><CFSET ImpactAmount = ProposedTotal - CurrentTotal> 
            #LSCurrencyFormat(ImpactAmount)#</TD>
          <TD STYLE="text-align:right;"><CFIF ProposedTotal EQ 0>
              <CFSET ImpactPct = 0>
              <CFELSE>
	          	<CFSCRIPT>if(CurrentTotal NEQ 0){ImpactPct = (100 * (ProposedTotal - CurrentTotal) / CurrentTotal);} else {ImpactPct = 0;}</CFSCRIPT>
            </CFIF> #LSNumberFormat(ImpactPct, "(9,999.00)")#%</TD>
        </TR>
      </CFLOOP>
      <TR> 
        <TD colspan="4" STYLE="text-align:center;font-weight:bold;">Totals:</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFSET CurrentRent = #TenantChargeTotals.RoomRent#> 
          #LSCurrencyFormat(CurrentRent)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFIF TenantChargeTotals.ResidentCare NEQ "">
            <CFSET CurrentCare = #TenantChargeTotals.ResidentCare#>
            <CFELSE>
            <CFSET CurrentCare = 0.00>
          </CFIF> #LSCurrencyFormat(CurrentCare)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFIF TenantChargeTotals.Discount NEQ "">
            <CFSET CurrentDiscount = #TenantChargeTotals.Discount#>
            <CFELSE>
            <CFSET CurrentDiscount = 0.00>
          </CFIF> #LSCurrencyFormat(CurrentDiscount)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFSET CurrentTotal = CurrentRent + CurrentCare - CurrentDiscount> 
          #LSCurrencyFormat(CurrentTotal)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFSET ProposedRent = #TenantChargeTotals.RoomRentProposed#> 
          #LSCurrencyFormat(ProposedRent)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFIF TenantChargeTotals.ResidentCareProposed NEQ "">
            <CFSET ProposedCare = #TenantChargeTotals.ResidentCareProposed#>
            <CFELSE>
            <CFSET ProposedCare = 0.00>
          </CFIF> #LSCurrencyFormat(ProposedCare)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFIF TenantChargeTotals.DiscountProposed NEQ "">
            <CFSET ProposedDiscount = #TenantChargeTotals.DiscountProposed#>
            <CFELSE>
            <CFSET ProposedDiscount = 0.00>
          </CFIF> #LSCurrencyFormat(ProposedDiscount)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFSET ProposedTotal = ProposedRent + ProposedCare - ProposedDiscount> 
          #LSCurrencyFormat(ProposedTotal)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFSET ImpactAmount = ProposedTotal - CurrentTotal> 
          #LSCurrencyFormat(ImpactAmount)#</TD>
        <TD STYLE="text-align:right;font-weight:bold;"><CFIF ProposedTotal EQ 0>
            <CFSET ImpactPct = 0>
            <CFELSE>
            <CFSET ImpactPct = 100 * (ProposedTotal - CurrentTotal) / CurrentTotal><!--- ProposedTotal --->
          </CFIF> #LSNumberFormat(ImpactPct, "(9,999.00)")#% </TD>
      </TR>
    </TABLE>
  </FORM>

<CFIF readonly EQ 1>
	<SCRIPT>
		for (i=0;i<=(document.forms[0].elements.length-1);i++){
			if (document.forms[0].elements[i].type == "text"){ document.forms[0].elements[i].readOnly = 'true'; document.forms[0].elements[i].style.background = 'whitesmoke'; }
		}
	</SCRIPT>
 </CFIF>

</CFOUTPUT> 
<CFINCLUDE TEMPLATE="../../footer.cfm">
