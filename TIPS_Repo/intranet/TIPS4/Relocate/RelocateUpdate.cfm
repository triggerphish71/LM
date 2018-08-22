<!----------------------------------------------------------------------------------------------------------
		109153  sfarmer 07-31-2013    all 'Room & Board' statements (text) changed to 'Basic Service Fee'   
	            sfarmer 03-26-2015 allow pre-moveins to be room transferred                                 
				sfarmer 05/08/2017 prevent same room relocations
				mstriegel 11/13/2017 update bundled pricing  and added with (nolock)  and removed <cfdump>                                          
----------------------------------------------------------------------------------------------------------->

<!--- ==============================================================================
	Tpecku.....Retrieve the last date that this particular tenant changed rooms 
=============================================================================== --->
<CFQUERY NAME="ChangeRoomDate" DATASOURCE="#APPLICATION.datasource#">
	 select max (dtActualEffective) AS ActualEffectivedt 
	 from activitylog WITH (NOLOCK)
	 where itenant_id = #form.iTenant_ID#
</CFQUERY>
<cfset ChangeRoomDate1 = #DateFormat(ChangeRoomDate.ActualEffectivedt, "yyyy-mm-dd")#>




<!--- ==============================================================================
Set variable for timestamp to record corresponding times for transactions
=============================================================================== --->
<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	GetDate() as Stamp
</CFQUERY>
<CFSET TimeStamp = CREATEODBCDateTime(GetDate.Stamp)>

<!--- ==============================================================================
	Retrieve the Tenant Current Records
=============================================================================== --->
<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM Tenant T WITH (NOLOCK)
	JOIN TenantState TS WITH (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID
	WHERE T.iTenant_ID = #form.iTenant_ID#
	AND T.dtRowDeleted IS NULL AND TS.dtRowDeleted IS NULL
</CFQUERY>

<cfset renteffectivedate = #tenant.dtrenteffective#>
<!--- =============================================================================================
Concat. Month Day Year for dBirthDate
============================================================================================= --->
<CFSCRIPT>
	dtActualEffective = form.month & "/" & form.day & "/" & form.year & " " & "23:59:59";
	dtActualEffective = CreateODBCDateTime(Variables.dtActualEffective);
	//set the renteffective date as actual effective date if tenant is transferred before rent effective
	/*if (renteffectivedate > dtActualEffective)
	{
		dtActualEffective = CreateODBCDateTime(renteffectivedate) ;
	}
	else 
		dtActualEffective=dtActualEffective;*/
	//variable added to update comapnionswitch date
	dtcompanionswitchdate= form.month & "/" & form.day & "/" & form.year ;
	dtcompanionswitchdate= CreateODBCDateTime(Variables.dtcompanionswitchdate);
</CFSCRIPT>

<!--- ==============================================================================
If there was no tenant Selected Show Error Below
=============================================================================== --->
<CFIF form.iTenant_ID EQ "">
	<CFOUTPUT>	
		<CFINCLUDE TEMPLATE="/intranet/header.cfm">
		<TABLE>
			<TR><TD STYLE="font-size: 20; font-weight: bold; background: white;">You have not selected a Tenant to Relocate.</TD></TR>
		</TABLE>
		<BR><BR>
		<A HREF="/intranet/TIPS4/Relocate/RelocateTenant.cfm" STYLE="Font-size: 18;"> Click Here To Try Again. </A>
		<CFINCLUDE TEMPLATE="/intranet/footer.cfm">
		<CFABORT>
	</CFOUTPUT>	
</CFIF>

<!--- ==============================================================================
Retrieve the Move In Date
=============================================================================== --->
<CFQUERY NAME="MoveInDate" DATASOURCE="#APPLICATION.datasource#">
	SELECT	dtMoveIn 
	FROM TenantState WITH (NOLOCK) 
	WHERE dtRowDeleted IS NULL 
	AND iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<!--- Proj 26955 rschuette 2/13/2009 For bond house identification --->
<cfquery name="bondhouse" datasource="#application.datasource#">
	select * 
	from house WITH (NOLOCK)  
	where ihouse_id =  #session.qSelectedHouse.iHouse_ID#
 </cfquery>
<cfquery name="BondIncludedAptCheck" datasource="#application.datasource#">
	select ad.bBondIncluded 
	from AptAddress ad  WITH (NOLOCK)
	where ad.iAptAddress_ID = #TRIM(form.iAptAddress_ID)#
</cfquery>
	
<!--- <CFIF Variables.dtActualEffective LT MoveInDate.dtMoveIn>    allow pre-move-ins to be room transferred
		<CFINCLUDE TEMPLATE="/intranet/header.cfm">
		<TABLE>
			<TR>
				<TD STYLE = "font-size: 20; font-weight: bold; background: white;">
					You have entered a relocation date that is before <BR>
					this tenant moved into the facility.
				</TD>
			</TR>
		</TABLE>
		<BR><BR>
		<A HREF="http://#server_name/intranet/TIPS4/Relocate/RelocateTenant.cfm" STYLE="Font-size: 18;"> Click Here To Try Again. </A>
		<CFINCLUDE TEMPLATE="/intranet/footer.cfm">
		<CFABORT>
</CFIF> --->



<CFTRANSACTION>


<!--- ==============================================================================
Retrieve the Tenant Current apartment type and relocated apt type//mamta
=============================================================================== --->
<CFQUERY NAME="currentapttype" DATASOURCE="#APPLICATION.datasource#">
	Select
	 b.bIscompanionSuite
	 from 
	 aptaddress a,
	 apttype b
	 where
	 a.iAptType_ID=b.iAptType_ID
	 and a.iAPTAddress_ID= #Tenant.iaptaddress_ID#
</CFQUERY>

<CFQUERY NAME="selectedapttype" DATASOURCE="#APPLICATION.datasource#">
	Select
	 b.bIscompanionSuite
	 from 
	 aptaddress a,
	 apttype b
	 where
	 a.iAptType_ID=b.iAptType_ID
	 and a.iAPTAddress_ID= #form.iaptaddress_ID#
</CFQUERY>
<!---test mamta
<cfoutput> tenant apartment is #currentapttype.bIscompanionSuite# and 
Selected apartment is #selectedapttype.bIscompanionSuite#  timenow  #CreateODBCDateTime(now())#</cfoutput>
Test mamta--->
<!--- ==============================================================================
Update the Apartment Log for the new Apartment Address
=============================================================================== --->
<CFQUERY NAME = "AptRelocation" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	APTLOG
	SET		iAptAddress_ID = #TRIM(form.iAptAddress_ID)#,
			dtActualEffective = #TRIM(Variables.dtActualEffective)#,
			iRowStartUser_ID = #SESSION.UserID#,
			dtRowStart = #TimeStamp#
	WHERE	iTenant_ID = #form.iTenant_ID#
</CFQUERY>

<!--- ==============================================================================
Update the Address on the Tenant State Table //edited by Mamta to update comapnionswitch.
=============================================================================== --->
<!--- mstriegel:11/13/2017 ---->
<cfquery name="checkBundled" datasource="#application.datasource#">
	select bIsBundled
	FROM TenantState WITH (NOLOCK)
	where iTenant_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#form.iTenant_ID#">
</cfquery>
<cfset currentlyBundled = checkBundled.bIsBundled>
<!--- end mstriegel:11/13/2017 --->

<CFQUERY NAME = "TenantStateChange" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE	TENANTSTATE
	SET		iAptAddress_ID = #TRIM(form.iAptAddress_ID)#,
			iRowStartUser_ID = #SESSION.UserID#,
			dtRowStart = #TimeStamp#,
		<cfif isdefined("form.cBondHouseEligibleAfterRelocate") and form.cBondHouseEligibleAfterRelocate neq "">
			cBondHouseEligibleAfterRelocate = 1
			<cfelse>
			cBondHouseEligibleAfterRelocate =1</cfif>
		<cfif currentapttype.bIscompanionSuite eq 1 and selectedapttype.bIscompanionSuite eq 0>
			,dtCompanionToFullSwitch= #TRIM(Variables.dtcompanionswitchdate)# </cfif>
		<cfif currentapttype.bIscompanionSuite eq 0 and selectedapttype.bIscompanionSuite eq 1>
			,dtFulltoCompanionSwitch= #TRIM(Variables.dtcompanionswitchdate)# </cfif>
		<!--- mstriegel: 11/13/2017 --->
		<cfif isdefined("form.hasBundledPricing") and form.hasBundledPricing EQ "">
			,bIsBundled = NULL
		<cfelse>
			<cfif currentlyBundled EQ 1 and isdefined('form.hasbundlePricing') AND form.hasBundledPricing EQ 1>
			 ,bIsBundled = 1	
			<cfelse>
			,bIsBundled = 0
			</cfif>
		</cfif>
		<!--- end mstriegel:11/13/2017 --->
			WHERE	iTenant_ID = #form.iTenant_ID#
</CFQUERY>
<!---  gthota  -  added code for same day any companion room change happen  --->
	 <cfif #form.iTenant_ID# NEQ ''>
			<CFQUERY NAME='qCompanionSwitchchk' DATASOURCE='#APPLICATION.datasource#'>
				SELECT dtCompanionToFullSwitch, dtFulltoCompanionSwitch,itenantState_ID,iTenant_ID  FROM TenantState WITH (NOLOCK)				
				<!--- WHERE itenantState_ID= #qtenantstateIDofApt.itenantState_ID#  --->
				 WHERE iTenant_ID = #form.iTenant_ID#
			</cfquery>
	 	
		<cfif #DateFormat(qCompanionSwitchchk.dtCompanionToFullSwitch, 'yyyy-mm-dd')#  EQ  #DateFormat(qCompanionSwitchchk.dtFulltoCompanionSwitch, 'yyyy-mm-dd')#>
				<CFQUERY NAME='qUpdateCompanionSwitch' DATASOURCE='#APPLICATION.datasource#' result='recordcount'>
					UPDATE TenantState
					SET dtCompanionToFullSwitch = null ,  dtFulltoCompanionSwitch = null
					WHERE itenantState_ID= #qCompanionSwitchchk.itenantState_ID# 
					AND dtCompanionToFullSwitch is not null AND dtFulltoCompanionSwitch is not null
				</CFQUERY>
			</cfif>	
	  </cfif>	
	<!---
		 <cfoutput> #now()#   /  #qCompanionSwitchchk.dtCompanionToFullSwitch#   / #qCompanionSwitchchk.dtFulltoCompanionSwitch# </cfoutput> 
		<cfabort>  --->
		<!--- gthota - code end   --->	


<CFQUERY NAME="WriteActivity" DATASOURCE="#APPLICATION.datasource#">
	INSERT INTO ActivityLog
	( iActivity_ID, dtActualEffective, iTenant_ID, iHouse_ID, iAptAddress_ID, iSPoints, dtAcctStamp, iRowStartUser_ID, dtRowStart)
		VALUES
	( 4, #dtActualEffective#, #form.iTenant_ID#, #SESSION.qSelectedHouse.iHouse_ID#, #TRIM(form.iAptAddress_ID)#, #Tenant.iSPoints#, 
	#CreateODBCDateTime(SESSION.AcctStamp)#, #SESSION.UserID#, #TimeStamp# )
</CFQUERY>

<!--- ==============================================================================
	Tpecku....Retrieve the just inserted date when the tenant changed rooms today 
	in activitylog
=============================================================================== --->
<CFQUERY NAME="ChangeRoomDate2" DATASOURCE="#APPLICATION.datasource#">
	 select max (dtActualEffective) AS ActualEffectivedt 
	 from activitylog WITH (NOLOCK)
	 where itenant_id = #form.iTenant_ID#
</CFQUERY>
<cfset ChangeRoomDate2 = #DateFormat(ChangeRoomDate2.ActualEffectivedt, "yyyy-mm-dd")#>


<!---Mamta-enhancement if secondary relocated to primary--->
<cfquery name="qrelocatingtenantoccupancy" DATASOURCE="#APPLICATION.datasource#" maxrows="1">
	Select c.ioccupancyposition,r.iRecurringCharge_ID,t.dtrenteffective
	from
		tenantstate t with (NOLOCK),
		recurringcharge r with (NOLOCK),
		charges c with (NOLOCK)
	where
		t.itenant_ID=r.itenant_ID
	and r.Icharge_ID=c.Icharge_ID
	and c.ioccupancyposition is not Null
	and r.dtRowDeleted is NULL
	and c.dtRowDeleted is NULL
	and t.itenant_ID= #form.iTenant_ID#
	order by r.iRecurringCharge_ID DESC
</cfquery>
<!---<cfdump var="#qrelocatingtenantoccupancy#">--->
<!--- find new occupancy position from charges, form.newcharge--->
<cfquery name="qnewoccupancyofrelocatingtenant" DATASOURCE="#APPLICATION.datasource#">
	Select * from charges WITH (NOLOCK) where icharge_ID=#form.newcharge#
</cfquery>
test-new charge
<!---<cfdump var="#qnewoccupancyofrelocatingtenant#" label="qnewoccupancyofrelocatingtenant">--->
<!--- find if any one on that aptaddress--->
<cfquery name="qserachtenantadrressID" DATASOURCE="#APPLICATION.datasource#">
	Select *
		from 
			tenantstate WITH (NOLOCK)
				where iaptaddress_id=#form.iAptaddress_ID#
				and dtrowdeleted is null
					and dtchargethrough is null
				and itenantstatecode_ID=2
			and itenant_ID != #form.iTenant_ID#
</cfquery>

<!--- update secondaryswitchdate to null if secondary reloctaing back to the apartment where a primary is there--->
<cfif #Tenant.dtsecondaryswitchdate# NEQ '' and #qserachtenantadrressID.itenant_id# NEQ '' >
  <CFQUERY NAME="updatesecondarySwitchDatenull" DATASOURCE="#APPLICATION.datasource#" result="result1" >
		UPDATE tenantstate
		set dtsecondaryswitchdate = null
		where itenant_id = #form.iTenant_ID#
  </CFQUERY>
</cfif>

<!---update secondary switch date if tenant is secondary and transfer to another room--->
<cfif #qrelocatingtenantoccupancy.ioccupancyposition# eq 2 
		and #qnewoccupancyofrelocatingtenant.ioccupancyposition# eq 1 
			and #qserachtenantadrressID.itenant_id# eq ''
			and #selectedapttype.bIscompanionSuite# neq 1
			and #TRIM(Variables.dtcompanionswitchdate)# gt #qrelocatingtenantoccupancy.dtrenteffective#>
	<CFQUERY NAME="updatesecondarySwitchDate" DATASOURCE="#APPLICATION.datasource#" result="result">
		UPDATE tenantstate
		set dtsecondaryswitchdate = #TRIM(Variables.dtcompanionswitchdate)# 
		where itenant_id = #form.iTenant_ID#
	</CFQUERY>
	
</cfif>
<!---update secondaryswitch date for secondary if primary tranfers to another room
<cfoutput>#tenant.iAptaddress_ID##form.iAptaddress_ID#</cfoutput>--->
<cfquery name="qserachtenantpreviousadrressID" DATASOURCE="#APPLICATION.datasource#">
	Select * from 
tenantstate t with (NOLOCK),
recurringcharge r WITH (NOLOCK),
charges c WITH (NOLOCK)
where
t.itenant_ID=r.itenant_ID
and r.Icharge_ID=c.Icharge_ID
and c.ioccupancyposition=2
and r.dtRowDeleted is NULL
and c.dtRowDeleted is NULL
and t.itenant_ID != #form.iTenant_ID#
and t.iaptaddress_id=#tenant.iAptaddress_ID# 
and t.dtrowdeleted is null
and t.dtchargethrough is null
and t.itenantstatecode_ID=2
order by r.iRecurringCharge_ID DESC
</cfquery>

<!---update secondaryswitch date for Secondary, if primary tranfers to another room--->

<cfif #qrelocatingtenantoccupancy.ioccupancyposition# eq 1 
		and #Trim(qserachtenantpreviousadrressID.itenant_id)# NEQ '' 
		and #Trim(qserachtenantpreviousadrressID.ioccupancyposition)# eq 2 
		and #TRIM(Variables.dtcompanionswitchdate)# gt #qrelocatingtenantoccupancy.dtrenteffective#
		<!---MShah added 11/27/2017 for SSD--->
		and #TRIM(Variables.dtcompanionswitchdate)# gt #qserachtenantpreviousadrressID.dtrenteffective#>
	<CFQUERY NAME="updatesecondarySwitchDateforsecondary" DATASOURCE="#APPLICATION.datasource#" result="result">
		UPDATE tenantstate
		set dtsecondaryswitchdate = #TRIM(Variables.dtcompanionswitchdate)# 
		where itenant_id = #qserachtenantpreviousadrressID.itenant_id#
	</CFQUERY>	

</cfif>
<!---update secondaryswitch date if the primary is tranferring back to apt where secondary with secondaryswitch date is there--->
<cfif #qserachtenantadrressID.dtSecondarySwitchDate# neq '' and #qserachtenantadrressID.itenant_id# NEQ '' >
	<CFQUERY NAME="updatesecondarySwitchDateforsecondary" DATASOURCE="#APPLICATION.datasource#" result="result">
		UPDATE tenantstate
		set dtsecondaryswitchdate = null
		where itenant_id = #qserachtenantadrressID.itenant_id#
   </CFQUERY>

</cfif>

<!---Mamta end of enhancement---> 

<!--- ==============================================================================
	Tpecku added enhancement to check to make sure that if a tenant went from primary 
	to secondary and back to primary in one day (If he or she was moved by mistake and 
	moved back), then dtSecondarySwitchdate column in the Tenantstate database will be 
	nulled out if it is populated.
=============================================================================== --->

<cfif datecompare(ChangeRoomDate1, ChangeRoomDate2, "d") eq 0>

<cfquery name="checkSwitch" datasource="#application.datasource#">
	SELECT dtSecondarySwitchdate from Tenantstate WITH (NOLOCK)
	WHERE iTenant_ID = #form.iTenant_ID#
</cfquery>




<!--- Tpecku... query to pull ioccupancyposition of tenant before first move --->
<cfquery name="qtenantoccupancybeforefirstmove" datasource="#application.datasource#" maxrows="1">
	Select top 1  t.itenant_id , r.icharge_id , c.ioccupancyposition, r.dtRowStart 
		from
			tenantstate t with (NOLOCK),
			p_recurringcharge r with (NOLOCK),
			charges c with (NOLOCK)
		where
			t.itenant_ID=r.itenant_ID
		and r.Icharge_ID=c.Icharge_ID
		and c.ioccupancyposition is not Null
		and r.dtRowDeleted is NULL
		and c.dtRowDeleted is NULL
		and t.itenant_ID=#form.iTenant_ID#
		and r.dtRowStart NOT IN (select MAX (r.dtRowStart) from
					tenantstate t with (NOLOCK),
					p_recurringcharge r with (NOLOCK),
					charges c with (NOLOCK)
				where
					t.itenant_ID=r.itenant_ID
				and r.Icharge_ID=c.Icharge_ID
				and c.ioccupancyposition is not Null
				and r.dtRowDeleted is NULL
				and c.dtRowDeleted is NULL
				and t.itenant_ID=#form.iTenant_ID#)
		order by dtRowStart asc
</cfquery>
	

	
	
	<cfif #qtenantoccupancybeforefirstmove.ioccupancyposition# eq 1
		and #qrelocatingtenantoccupancy.ioccupancyposition# eq 2 
		and #qnewoccupancyofrelocatingtenant.ioccupancyposition# eq 1 
			and #TRIM(Variables.dtcompanionswitchdate)# EQ #TRIM(checkSwitch.dtSecondarySwitchdate)#>
	
		<cfquery name="updateSSD" datasource="#application.datasource#">
			UPDATE tenantstate
				set dtsecondaryswitchdate = null
			where itenant_id = #form.iTenant_ID#
   	</cfquery>
	</cfif>

</cfif>
<!---  end endancement  --->
<!--- ==============================================================================
Added by Katie 8/15/03
Edit most recent invoice with new qty of R&B charges.  Add new row(s) for debit or credit of remaining qty of R&B charges
=============================================================================== --->

	<!--- 8/25/03: need to remember to add some kind of second tenant check.  If second tenant, R&B rates may also change for old roomate???
			Haven't done this yet --->
	
	<!--- find out if Tenant is Medicaid or not.  This value will be used in getChargeType query. --->
	<cfif Tenant.bIsMedicaid is ""><cfset TenantbIsMedicaid = "IS NULL"><cfelse><cfset TenantbIsMedicaid = "IS NOT NULL"></cfif>
	
	<!--- get appropriate chargetype to use --->
	<cfquery name="getChargeType" datasource="#application.datasource#">
		SELECT  ct.IChargeType_ID
		FROM  InvoiceDetail inv WITH (NOLOCK)
		INNER JOIN Tenant t WITH (NOLOCK) ON t.iTenant_ID = inv.iTenant_ID AND t.dtRowDeleted IS NULL 
		INNER JOIN TenantState ts WITH (NOLOCK) ON ts.iTenant_ID = t.iTenant_ID AND ts.dtRowDeleted IS NULL 
		INNER JOIN InvoiceMaster im WITH (NOLOCK) ON im.iInvoiceMaster_ID = inv.iInvoiceMaster_ID AND im.dtRowDeleted IS NULL AND im.bMoveInInvoice IS NULL AND 
                   im.bMoveOutInvoice IS NULL AND im.bFinalized IS NULL 
        INNER JOIN ChargeType ct WITH (NOLOCK) ON ct.iChargeType_ID = inv.iChargeType_ID AND ct.dtRowDeleted IS NULL AND ct.bIsRent IS NOT NULL AND 
                      ct.bIsDiscount IS NULL AND ct.bIsRentAdjustment IS NULL AND ct.bSLevelType_ID IS NULL
		WHERE     (inv.dtRowDeleted IS NULL) AND (inv.iTenant_ID = #form.iTenant_ID#) AND (ct.bIsMedicaid #TenantbIsMedicaid#)
		ORDER BY inv.iInvoiceDetail_ID DESC
	</cfquery>

	<cfif getChargeType.iChargeType_ID is not "">
		<!--- get most recent active invoicedetail for tenant where chargetype is #getChargeType.iChargeType_ID# (usually 89) --->
		<cfquery name="getmostrecentinvoicedetail" datasource="#application.datasource#" maxrows="1">
			SELECT inv.iInvoiceDetail_ID, inv.iQuantity,inv.iInvoicemaster_ID
			FROM InvoiceDetail inv WITH (NOLOCK) 
			INNER JOIN invoicemaster im WITH (NOLOCK) on im.iinvoicemaster_ID=inv.iinvoicemaster_ID
			WHERE inv.iTenant_ID = #form.iTenant_ID# 
			AND inv.iChargeType_ID = #getChargeType.iChargeType_ID# AND inv.dtRowDeleted is NULL and im.dtrowdeleted is null
			ORDER BY iInvoiceDetail_ID DESC
		</cfquery>
	
	</cfif>
 
	<!--- if a record is returned, their records can be prorated --->
	<cfif isDefined("getmostrecentinvoicedetail.iInvoiceDetail_ID") AND getmostrecentinvoicedetail.recordcount is not 0>
		
		<!--- figure out how many days at prev room and how many days in new room --->
		<cfset CreateaDate = "#form.month#/#form.day#/#form.year# 00:00:00 AM"> 
		<cfset TotalMonthDays = #DaysInMonth(CreateaDate)#>
		<!---if  transfer done before rent effective date/mshah--->
		<cfoutput> #Tenant.dtrenteffective# CreateaDate #CreateaDate#</cfoutput>
		<cfif #Tenant.dtrenteffective# gt CreateaDate> 
			<cfset newroomqty = (#TotalMonthDays# - #day(Tenant.dtrenteffective)#) + 1>newroomqty: <cfoutput>#newroomqty#<BR></cfoutput> 
	    <cfelse>	
	    	<cfset newroomqty = (#TotalMonthDays# - #form.day#) + 1>newroomqty: <cfoutput>#newroomqty#<BR></cfoutput>
	    </cfif>
		<!---mshah end--->
		<!--- always going to be editing and adding room change info to most recent invoice master --->
		<cfquery name="GetMostRecentInvoiceMaster" datasource="#application.datasource#" Maxrows="1">
			SELECT InvoiceDetail.iInvoiceDetail_ID, InvoiceMaster.iInvoiceMaster_ID 
			FROM InvoiceDetail WITH  (NOLOCK)
			INNER JOIN InvoiceMaster WITH (NOLOCK) ON InvoiceDetail.iInvoiceMaster_ID = InvoiceMaster.iInvoiceMaster_ID
			WHERE InvoiceDetail.iTenant_ID = #form.iTenant_ID# 
			and Invoicemaster.dtrowdeleted is null
			ORDER BY InvoiceMaster.iInvoiceMaster_ID DESC
		</cfquery>
		
		<!--- can't edit old room rate in InvoiceDetail because it's for the month previous to the currently billed month (since we bill one month in advance)
				so instead, calculate a credit or debit (based on room downgrade/upgrade) and enter it as a Basic Service Fee adjustment for the prev month --->
		<!---get most recent LOC charge--->		
		
		<cfquery name="GetMostRecentLOCcharges" datasource="#application.datasource#" Maxrows="1">
			SELECT * 
			FROM InvoiceDetail WITH (NOLOCK)
			INNER JOIN InvoiceMaster WITH (NOLOCK) ON InvoiceDetail.iInvoiceMaster_ID = InvoiceMaster.iInvoiceMaster_ID
			WHERE InvoiceDetail.iTenant_ID = #form.iTenant_ID# 
			and InvoiceDetail.ichargetype_ID= 91
			ORDER BY InvoiceMaster.iInvoiceMaster_ID DESC
		</cfquery>
	
		<!---Mamta--->
		<!--- compare the OLD room rate to NEW room rate and add Basic Service Fee adjustment --->
		<cfquery name="GetOldReccuringCharge" datasource="#Application.datasource#" maxrows="1">
			SELECT RecurringCharge.iRecurringCharge_ID AS RecCharge, RecurringCharge.mAmount as RCmAmount, Charges.*
			FROM RecurringCharge WITH (NOLOCK)
			INNER JOIN Charges WITH (NOLOCK) ON RecurringCharge.iCharge_ID = Charges.iCharge_ID AND Charges.dtRowDeleted is NULL
			INNER JOIN ChargeType WITH (NOLOCK) ON Charges.iChargeType_ID = ChargeType.iChargeType_ID AND ChargeType.dtRowDeleted is NULL
			WHERE RecurringCharge.iTenant_ID = #form.iTenant_ID# 
			AND RecurringCharge.dtRowDeleted is NULL
			AND ChargeType.iChargeType_ID = #getChargeType.iChargeType_ID#
			ORDER BY iRecurringCharge_ID DESC
		</cfquery>
		
		<!--- get room description for insert into InvoiceDetail table --->
		
<!--- 		<cfquery name="getRoomDescription" datasource="#application.datasource#">
			SELECT AptAddress.iAptAddress_ID, Charges.cDescription FROM Charges
			INNER JOIN AptAddress ON Charges.iAptType_ID = AptAddress.iAptType_ID
			WHERE AptAddress.iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery> --->
		<cfquery name="getRoomDescription" datasource="#application.datasource#">
			select cDescription 
			from AptType WITH (NOLOCK) 
			inner join AptAddress WITH (NOLOCK) ON AptAddress.iAptType_ID = AptType.iAptType_ID
			where AptAddress.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# and AptAddress.iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery>
		
		<!--- calulate adjustment for relocation month --->
		
		<!--- calculate adjustment difference by DAY --->
		<!---Mshah added this for the issue of transfer before rent effective
		<cfif #tenant.dtrenteffective# GT dtActualEffective>
		<cfset dtActualEffective = tenant.dtrenteffective>
		</cfif>--->
	
		<cfset oldcharge =  Round(#GetOldReccuringCharge.RCmAmount#*100)/100>
		<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 or #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682>
			going here <cfoutput> #form.Recurring_mAmount#/#daysinmonth(dtActualEffective)#)*#newroomqty#)*100)/100 </cfoutput>
			
			<cfset newcharge = round(((#form.Recurring_mAmount#/#daysinmonth(dtActualEffective)#)*#newroomqty#)*100)/100 >
		<cfelse>
			<cfset newcharge = round(#form.Recurring_mAmount#*100)/100>
		</cfif>
		
		<cfoutput>oldcharge: '#oldCharge#'  Newcharge: '#newcharge#'</cfoutput><BR>

		<cfif oldcharge is not "" and newcharge is not "">
			<!---<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748>
			<cfset difference = #LsNumberFormat(((newcharge - oldcharge)*#newroomqty#), "0.00")#>
			<cfelse>--->	
			<cfset difference = newcharge - oldcharge>
			<!---</cfif>--->
		<cfelse>
			<center><font color="red"><strong>No valid Basic Service Fee recurring charge was found for this resident.  Cannot relocate.</strong></font></center>
			<cfabort>
		</cfif>
		
		<!--- enter Adjustment for relocation month in InvoiceDetail --->
	
		<cfif difference is not 0>
			<cfif difference GT 0><cfset IncreaseOrDecrease = "Increase"><cfelseif difference LT 0><cfset IncreaseOrDecrease = "Decrease"></cfif>
			<Cfoutput>qty: #newroomqty# #Increaseordecrease# #difference#<BR>
			Room change on #form.month#/#form.day#/#form.year# - #trim(getRoomDescription.cDescription)#. Old rate: #oldcharge#  New Rate: #newcharge#</Cfoutput><p>
			<cfset relocationdate = "#form.month#/#form.year#">
			<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 and #GetOldReccuringCharge.ichargetype_ID# eq 89> <!---transfer from AL to MC loop1--->
			insert credit back for 1748 loop 1
			    <!---mshah added query to find if there are previous invoicerecords, then only add the adjustments--->
			<cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
			Select * from invoicedetail inv join invoicemaster im on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
			and inv.itenant_ID= #form.iTenant_ID#
			and inv.cappliestoacctperiod= #DateFormat(relocationdate,'YYYYMM')#	
			and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
			</cfquery>
			
			
			<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
				<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment">
					INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart, iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						#GetOldReccuringCharge.ichargetype_ID#,		
						#DateFormat(relocationdate,'YYYYMM')#,
						NULL, 
						GETDATE(),
						#newroomqty#,		
						'credit Basic Service Fee',	
						-#Oldcharge#,
						'Room change on #form.month#/#form.day#/#form.year#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#newroomqty#)
				</cfquery>
			
			<cfquery name="CheckForPreInvoiceLOC" datasource="#application.datasource#">
			Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
			and inv.itenant_ID= #form.iTenant_ID#
			and inv.cappliestoacctperiod= #DateFormat(relocationdate,'YYYYMM')#	
			and inv.ichargetype_ID= 91
			</cfquery>
		
			
			<cfif #CheckForPreInvoiceLOC.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
			
				<cfquery name="AddNewInvoiceDetailAdjustmentLOC" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustmentLOC">
					INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						91,		
						#DateFormat(relocationdate,'YYYYMM')#,
						NULL, 
						GETDATE(),
						#newroomqty#,		
						'credit LOC charges',	
						-#GetMostRecentLOCcharges.mamount#,
						'Room change on #form.month#/#form.day#/#form.year#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#newroomqty#)
				</cfquery>
				
			</cfif> <!---Mshah end cfif--->
				<cfquery name="AddNewInvoiceDetail" datasource="#application.datasource#" result="AddNewInvoiceDetail">
					INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						#qnewoccupancyofrelocatingtenant.ichargetype_ID#,		
						#DateFormat(relocationdate,'YYYYMM')#,
						NULL, 
						GETDATE(),
						1,		
						'Basic Service Fee - #trim(getRoomDescription.cDescription)#',	
						#newcharge#,
						'AL to MC room change charge',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#newroomqty#)
				</cfquery>
				
			
		
			</cfif> <!---mshah ends here cfif--->
			<cfelseif (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 89 or #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682) 
			                and #GetOldReccuringCharge.ichargetype_ID# eq 1748> <!---Mshah MC to AL monthly/AL daily loop 1 --->
			                
			                <!---check for the previous invoice--->
			                <cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
							Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
							and inv.itenant_ID= #form.iTenant_ID#
							and inv.cappliestoacctperiod= #DateFormat(relocationdate,'YYYYMM')#	
							and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
						   </cfquery>
							
							<cfif #CheckForPreInvoice.recordcount# gt 0> <!---if record returned , insert the invoicedetail--->
							  
							<cfset oldMCcharge= (#oldcharge#/#daysinmonth(dtActualEffective)#)*#newroomqty# >
							 <cfset oldMCcharge= round(#oldMCcharge#*100)/100>
						
							<!---credit the MC charge--->
								<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment">
								INSERT INTO InvoiceDetail
									(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
									dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
									iRowStartUser_ID, dtRowStart,iDaysBilled)
									VALUES
									( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
									#form.iTenant_ID#,
									#GetOldReccuringCharge.ichargetype_ID#,		
									#DateFormat(relocationdate,'YYYYMM')#,
									NULL, 
									GETDATE(),
									1,		
									'credit #trim(GetOldReccuringCharge.cDescription)#',	
									-#oldMCcharge#,
									'Room change on #form.month#/#form.day#/#form.year#',
									#CreateODBCDateTime(SESSION.AcctStamp)#,
									#session.userid#,
									#TimeStamp#,
									#newroomqty#)
							</cfquery>
							
							<!---insert new AL daily/monthly charge--->
							<cfquery name="AddNewInvoiceDetail" datasource="#application.datasource#" result="AddNewInvoiceDetail">
							INSERT INTO InvoiceDetail
								(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
								dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
								iRowStartUser_ID, dtRowStart,iDaysBilled)
								VALUES
								( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
								#form.iTenant_ID#,
								#qnewoccupancyofrelocatingtenant.ichargetype_ID#,		
								#DateFormat(relocationdate,'YYYYMM')#,
								NULL, 
								GETDATE(),
								<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682 >1 <cfelse> #newroomqty# </cfif>,		
								'Basic Service Fee - #trim(getRoomDescription.cDescription)#',	
								#newcharge#,
								'Room change on #form.month#/#form.day#/#form.year#',
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								#session.userid#,
								#TimeStamp#,
								#newroomqty#)
						   </cfquery>
						
						</cfif>
			
			<!---mshah MC to AL daily/AL monthly end--->
			<!---transfer from AL Monthly to MC or MC to AL monthly loop 1--->
			<cfelseif (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 or #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682) 
			and (#GetOldReccuringCharge.ichargetype_ID# eq 1748 or #GetOldReccuringCharge.ichargetype_ID# eq 1682)>
			
			 <cfset oldMCcharge= (#oldcharge#/#daysinmonth(dtActualEffective)#)*#newroomqty# >
			 
			 <cfset oldMCcharge= round(#oldMCcharge#*100)/100>
			  <cfoutput>oldMCcharge=(#oldcharge#/#daysinmonth(dtActualEffective)#)*#newroomqty#</cfoutput>
			      insert credit back for 1748 loop 1-2
			      
			  	<cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
					Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
					and inv.itenant_ID= #form.iTenant_ID#
					and inv.cappliestoacctperiod= #DateFormat(relocationdate,'YYYYMM')#	
					and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
				</cfquery>
					
					
					
				<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
					test inserting charge
					<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment">
					INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						#GetOldReccuringCharge.ichargetype_ID#,		
						#DateFormat(relocationdate,'YYYYMM')#,
						NULL, 
						GETDATE(),
						1,		
						'credit #trim(GetOldReccuringCharge.cDescription)#',	
						-#oldMCcharge#,
						'Room change on #form.month#/#form.day#/#form.year#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#newroomqty#)
				</cfquery>
				
				insert new charge
				<cfquery name="AddNewInvoiceDetail" datasource="#application.datasource#" result="AddNewInvoiceDetail">
					INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						#qnewoccupancyofrelocatingtenant.ichargetype_ID#,		
						#DateFormat(relocationdate,'YYYYMM')#,
						NULL, 
						GETDATE(),
						1,		
						'Basic Service Fee - #trim(getRoomDescription.cDescription)#',	
						#newcharge#,
						'Room change on #form.month#/#form.day#/#form.year#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#newroomqty#)
				</cfquery>
				
			</cfif>  <!---Mshah cfif end check for previous invoice--->
			<cfelse>
			Test going here <!---transfer from Al daily to Al daily loop 1--->
			 <cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
				Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
				and inv.itenant_ID= #form.iTenant_ID#
				and inv.cappliestoacctperiod= #DateFormat(relocationdate,'YYYYMM')#	
				and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
			    </cfquery>
			
			
			<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
			
					<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment">
					    INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						42,		
						#DateFormat(relocationdate,'YYYYMM')#,
						NULL, 
						GETDATE(),
						#newroomqty#,
						'#IncreaseOrDecrease# Basic Service Fee',	
						#difference#,
						'Room change on #form.month#/#form.day#/#form.year# - #trim(getRoomDescription.cDescription)#. Old rate: #DollarFormat(Oldcharge)#  New Rate: #DollarFormat(Newcharge)#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#newroomqty#)
				</cfquery>
				
			</cfif> <!---Mshah added here end cfif--->
		</cfif> 	
		</cfif>
		
		<!--- get number of months back the relocation date was --->
		<cfset MoveInMonthsAgo = abs(#month(SESSION.TipsMonth)# - #form.month#)>
		<cfoutput>test mamta MoveInMonthsAgo#MoveInMonthsAgo# #month(SESSION.TipsMonth)# - #form.month#</cfoutput>
		<!--- if moveinmonths ago is GTE 1, must calculate adjustment for all months in between move in and now --->
		<cfif MoveInMonthsAgo GTE 1>
		Inserting into invoicedetail
			<cfset monthtouse = "#form.month#/#form.year#">
			<cfset newmonth = #DateAdd('m', 1, monthtouse)#>
			<cfset NewMonthDifference = 0>
			<cfloop condition="#DateFormat(newmonth, 'MM/YYYY')# LT #DateFormat(SESSION.TipsMonth, 'MM/YYYY')#">
				
				test going here
				<cfset DaysInNewMonth = #DaysInMonth(newmonth)#>DaysInNewMonth <cfoutput>#DatePart('m',newmonth)#/#DatePart('yyyy',newmonth)# is #DaysInNewMonth#</cfoutput><BR
				
				<!--- figure old and new amount by DAY --->
				<cfset OldAmount = round(#GetOldReccuringCharge.RCmAmount#*100)/100>
				<!---OldAmount for days in month: <cfoutput>#OldAmount#</cfoutput><BR>--->
				<cfset NewAmount = round(#form.Recurring_mAmount#*100)/100>
				
				NewAmount for days in month: <cfoutput>#NewAmount#</cfoutput><BR>
				<cfset DailyDifference = NewAmount - OldAmount>
				
				<!--- if entering adjustments by month (instead of one lump sum), enter Adjustment in InvoiceDetail now --->
				<cfif DailyDifference is not 0>
					<cfif DailyDifference GT 0><cfset IncreaseOrDecrease = "Increase"><cfelseif DailyDifference LT 0><cfset IncreaseOrDecrease = "Decrease"></cfif>
					<Cfoutput>qty: #daysinnewmonth# #Increaseordecrease# #DailyDifference#<BR>
					Accounting period #DateFormat(SESSION.TipsMonth,'YYYYMM')# - #trim(getRoomDescription.cDescription)#. Old rate: #OldAmount#  New Rate: #NewAmount#</Cfoutput><p>
				<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 and #GetOldReccuringCharge.ichargetype_ID# eq 89> <!--- transfer from AL to M loop 2--->
					 insert credit back for next month loop 2
					  <!---mshah added query to find if there are previous invoicerecords, then only add the adjustments--->
						<cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
						Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
						and inv.itenant_ID= #form.iTenant_ID#
						and inv.cappliestoacctperiod= #DateFormat(newmonth,'YYYYMM')#			
						</cfquery>
						
						
						<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
				
						<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment">
						INSERT INTO InvoiceDetail
							(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
							dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
							iRowStartUser_ID, dtRowStart, iDaysBilled)
							VALUES
							( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
							 89,						
							#DateFormat(newmonth,'YYYYMM')#,
							NULL, 
							GETDATE(),
							#DaysInNewMonth#,
							'credit Basic Service Fee daily',
							-#oldamount#,		
							'Room change on #form.month#/#form.day#/#form.year#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#session.userid#,
							#TimeStamp#,
							#DaysInNewMonth#)
					</cfquery>
				<!---mshah added query to find if there are previous invoicerecords, then only add the adjustments--->
			<cfquery name="CheckForPreInvoiceLOC2" datasource="#application.datasource#">
			   Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
			   and inv.itenant_ID= #form.iTenant_ID#
			   and inv.cappliestoacctperiod= #DateFormat(newmonth,'YYYYMM')#
			   and inv.ichargetype_ID =91
			</cfquery>
						
						
			<cfif #CheckForPreInvoiceLOC2.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
					
					<cfset  GetMostRecentLOCchargesmamount = round(#GetMostRecentLOCcharges.mamount#*100)/100>
					<cfquery name="AddNewLOCAdjustment" datasource="#application.datasource#" result="AddNewLOCAdjustment">
						INSERT INTO InvoiceDetail
							(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
							dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
							iRowStartUser_ID, dtRowStart,iDaysBilled)
							VALUES
							( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
							 91,						
							#DateFormat(newmonth,'YYYYMM')#,
							NULL, 
							GETDATE(),
							#DaysInNewMonth#,
							'credit LOC charges',
							- #GetMostRecentLOCchargesmamount#,		
							'Room change on #form.month#/#form.day#/#form.year#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#session.userid#,
							#TimeStamp#,
							#DaysInNewMonth#)
					</cfquery>
						
				</cfif> <!---Mshah cfif ends--->
					<cfset   formrecurringmAmount =  round(#form.recurring_mAmount#*100)/100>
					<cfquery name="AddNewInvoiceDetail" datasource="#application.datasource#" result="AddNewInvoiceDetail">
					INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,iDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						1748,		
						#DateFormat(newmonth,'YYYYMM')#,
						NULL, 
						GETDATE(),
						1,		
						'Basic Service Fee - #trim(getRoomDescription.cDescription)#',	
						 #formrecurringmAmount#,
						'AL to MC room change charge',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#daysinnewmonth#)
				</cfquery>
				</cfif> <!---mshah ends here cfif--->
				
				
				
				insert credit back for next month loop 2-a
				<!---mshah added for MC to AL transfer--->
				<cfelseif (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 89 or #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682) 
				and (#GetOldReccuringCharge.ichargetype_ID# eq 1748)>

                       <cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
							Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
							and inv.itenant_ID= #form.iTenant_ID#
							and inv.cappliestoacctperiod= #DateFormat(newmonth,'YYYYMM')#	
							and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
				       </cfquery>
							
							
				<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
				    <cfset  oldamount  = round(#oldamount#*100)/100>	   
				    <cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment"> <!---give credit for MC --->
						INSERT INTO InvoiceDetail
						(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
						dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
						iRowStartUser_ID, dtRowStart,IDaysBilled)
						VALUES
						( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
						#form.iTenant_ID#,
						 #GetOldReccuringCharge.ichargetype_ID#,						
						#DateFormat(newmonth,'YYYYMM')#,
						NULL, 
						GETDATE(),
						1,
						'credit #trim(GetOldReccuringCharge.cDescription)#',
						- #oldamount#,		
						'Room change on #form.month#/#form.day#/#form.year#',
						#CreateODBCDateTime(SESSION.AcctStamp)#,
						#session.userid#,
						#TimeStamp#,
						#daysinnewmonth#)
				      </cfquery>
						
						<!---charge credit for AL/AL monthly --->
						
						<cfquery name="AddNewInvoiceDetail" datasource="#application.datasource#" result="AddNewInvoiceDetail">
							INSERT INTO InvoiceDetail
								(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
								dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
								iRowStartUser_ID, dtRowStart,iDaysBilled)
								VALUES
								( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
								#form.iTenant_ID#,
								 #qnewoccupancyofrelocatingtenant.ichargetype_ID#,						
								#DateFormat(newmonth,'YYYYMM')#,
								NULL, 
								GETDATE(),
								<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682> 1 <cfelse>#daysinnewmonth#</cfif>,
								'Basic Service Fee - #trim(getRoomDescription.cDescription)#',
								#form.recurring_mAmount#,		
								'Room change on #form.month#/#form.day#/#form.year#',
								#CreateODBCDateTime(SESSION.AcctStamp)#,
								#session.userid#,
								#TimeStamp#,
								#daysinnewmonth#)
						</cfquery>
						
				</cfif>
				<!---mshah end--->
				<cfelseif (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748
							 or #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682)
							and (#GetOldReccuringCharge.ichargetype_ID# eq 1748
								 or #GetOldReccuringCharge.ichargetype_ID# eq 1682)> <!---Transfer from AL monthly to MC or MC to AL monthly loop 2--->
					 insert credit back for next month loop 2-a
					<cfset  oldamount  = round(#oldamount#*100)/100>
					 <!---Mshah added to check for previous period invoice--->
					 <cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
						Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
						and inv.itenant_ID= #form.iTenant_ID#
						and inv.cappliestoacctperiod= #DateFormat(newmonth,'YYYYMM')#
						and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
					</cfquery>
						
					
						
					<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
				
					<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment">
						INSERT INTO InvoiceDetail
							(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
							dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
							iRowStartUser_ID, dtRowStart,IDaysBilled)
							VALUES
							( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
							 #GetOldReccuringCharge.ichargetype_ID#,						
							#DateFormat(newmonth,'YYYYMM')#,
							NULL, 
							GETDATE(),
							1,
							'credit #trim(GetOldReccuringCharge.cDescription)#',
							- #oldamount#,		
							'Room change on #form.month#/#form.day#/#form.year#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#session.userid#,
							#TimeStamp#,
							#daysinnewmonth#)
					</cfquery>
					
					<cfquery name="AddNewInvoiceDetail" datasource="#application.datasource#" result="AddNewInvoiceDetail">
						INSERT INTO InvoiceDetail
							(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
							dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
							iRowStartUser_ID, dtRowStart,iDaysBilled)
							VALUES
							( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
							 #qnewoccupancyofrelocatingtenant.ichargetype_ID#,						
							#DateFormat(newmonth,'YYYYMM')#,
							NULL, 
							GETDATE(),
							1,
							'Basic Service Fee - #trim(getRoomDescription.cDescription)#',
							#form.recurring_mAmount#,		
							'Room change on #form.month#/#form.day#/#form.year#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#session.userid#,
							#TimeStamp#,
							#daysinnewmonth#)
					</cfquery>
					
					
				</cfif> <!---Mshah added to check for previous period invoice cfif ends--->	
				
				<cfelse>
				<!---transfer from AL daily to AL daily loop 2--->
				 <!---Mshah added to check for previous period invoice--->
				 <cfquery name="CheckForPreInvoice" datasource="#application.datasource#">
					Select * from invoicedetail inv with (NOLOCK) join invoicemaster im with (NOLOCK) on inv.iinvoicemaster_ID= im.iinvoicemaster_ID and inv.dtrowdeleted is null and im.dtrowdeleted is null
					and inv.itenant_ID= #form.iTenant_ID#
					and inv.cappliestoacctperiod= #DateFormat(newmonth,'YYYYMM')#	
					and inv.ichargetype_ID= #GetOldReccuringCharge.ichargetype_ID#
				</cfquery>
					
					
					
				<cfif #CheckForPreInvoice.recordcount# gt 0> <!---Mshah added to check for previous period invoice--->
			
				<cfquery name="AddNewInvoiceDetailAdjustment" datasource="#application.datasource#" result="AddNewInvoiceDetailAdjustment1">
						INSERT INTO InvoiceDetail
							(iInvoiceMaster_ID, iTenant_ID, iChargeType_ID, cAppliesToAcctPeriod, bIsRentAdj, 
							dtTransaction, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, 
							iRowStartUser_ID, dtRowStart,iDaysBilled)
							VALUES
							( #GetMostRecentInvoiceMaster.iInvoiceMaster_ID#,
							#form.iTenant_ID#,
								42,		
							#DateFormat(newmonth,'YYYYMM')#,
							NULL, 
							GETDATE(),
							#DaysInNewMonth#,
							'#IncreaseOrDecrease# Basic Service Fee',
							#DailyDifference#,		
							'#trim(getRoomDescription.cDescription)#. Old rate: #DollarFormat(OldAmount)#  New Rate: #DollarFormat(NewAmount)#',
							#CreateODBCDateTime(SESSION.AcctStamp)#,
							#session.userid#,
							#TimeStamp#,
							#daysinnewmonth#)
					</cfquery>
					
				  </cfif> <!---Mshah cfif ends--->
				</cfif>
				
				</cfif>
			
				<!--- increment month --->
				<cfset newmonth = #DateAdd('m', 1, newmonth)#>
			</cfloop>
			
		</cfif>
		
		<!--- edit current accounting periods' invoicedetail row with new daily amount and description// change to neq to 1748 10/20--->
		
		<!--- set old Recurring Charge to deleted and add new reoccuring charge --->
		<cfquery name="deleteOldReccuringCharge" datasource="#application.datasource#" result="deleteOldReccuringCharge">
			UPDATE RecurringCharge
			SET dtRowDeleted = #TimeStamp#, iRowDeletedUser_ID = #SESSION.UserID#, dtEffectiveEnd = getdate()
			WHERE RecurringCharge.iRecurringCharge_ID = #GetOldReccuringCharge.RecCharge#
		</cfquery>
		<!---<cfdump var="#deleteOldReccuringCharge#">--->
		<!--- setting iCharge_ID and Description to the OLD/ORIGINAL Charge_ID Mamta added #form.NEWCHARGE# to fix the charge ID update--->
		<!---mshah added this to find the description--->
		<cfquery name="FindNEwChargeDescription" datasource="#application.datasource#" >
		  SELECT * 
		  FROM charges WITH (NOLOCK) 
		  where icharge_ID= #form.NEWCHARGE#
		</cfquery>
		
		<!---Mshah end--->
		<cfquery name="insertNewRecurringCharge" datasource="#application.datasource#" result="insertNewRecurringCharge">
			INSERT INTO RecurringCharge
			( iTenant_ID, iCharge_ID, dtEffectiveStart, dtEffectiveEnd, iQuantity, cDescription, mAmount, cComments, dtAcctStamp, iRowStartUser_ID, dtRowStart)
			VALUES
			( #form.iTenant_id# ,#form.NEWCHARGE# ,getdate() ,DateAdd("yyyy",10,getdate()) ,1 , '#FindNEwChargeDescription.cdescription#' ,#Form.Recurring_mAmount#, 
			  'Recurring created upon room change' ,#CreateODBCDateTime(SESSION.AcctStamp)# ,#SESSION.USERID# ,getdate())
		</cfquery>
	
	   <cfquery name="NewRecurringCharge" datasource="#application.datasource#">
		SELECT irecurringcharge_ID 
		FROM recurringcharge WITH (NOLOCK) 
		WHERE  iTenant_ID= #form.iTenant_id#
		 and ccomments='Recurring created upon room change' 
		 and dtrowdeleted is null
		</cfquery>
		
		<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# neq 1748>
				<!---or not (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 and #GetOldReccuringCharge.ichargetype_ID# eq 89)>--->
		<cfquery name="UpdateInvoiceDetail" datasource="#application.datasource#" result="UpdateInvoiceDetail">
			UPDATE InvoiceDetail 
			SET  mAmount = #form.recurring_mAmount#,
			 cDescription = '#FindNEwChargeDescription.cdescription#',
			 irecurringcharge_id=#NewRecurringCharge.irecurringcharge_ID#,
			 iDaysBilled=#daysinmonth(session.Tipsmonth)#
			WHERE iInvoiceDetail_ID = #getmostrecentinvoicedetail.iInvoiceDetail_ID#
		</cfquery>
	
		</cfif>
		<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748>
				<!---or not (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 and #GetOldReccuringCharge.ichargetype_ID# eq 89)>--->
		<cfquery name="UpdateInvoiceDetailforMC" datasource="#application.datasource#" result="UpdateInvoiceDetailMC">
			UPDATE InvoiceDetail 
			SET ichargetype_ID=1748,
			   iquantity=1,
			  mAmount = #form.recurring_mAmount#,
			 cDescription = 'Basic Service Fee - #trim(getRoomDescription.cDescription)#',
			  irecurringcharge_id=#NewRecurringCharge.irecurringcharge_ID#,
			  iDaysBilled=#daysinmonth(session.Tipsmonth)#
			WHERE iInvoiceDetail_ID = #getmostrecentinvoicedetail.iInvoiceDetail_ID#
		</cfquery>
		
		</cfif>
	<!---update 91 which is not crediting back--->
		<cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748>
				<!---or not (#qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 and #GetOldReccuringCharge.ichargetype_ID# eq 89)>--->
		<cfquery name="UpdateInvoiceDetailforMC2" datasource="#application.datasource#" result="UpdateInvoiceDetailMC2">
			UPDATE InvoiceDetail 
			SET dtrowdeleted= getdate()
			WHERE iInvoiceMaster_ID = #getmostrecentinvoicedetail.iInvoiceMaster_ID#
			and ichargetype_ID=91
			and mamount > 0
		</cfquery>
		
		</cfif>
		
	<cfelse>
		<!--- their Invoices use a chargetype that cannot be prorated, so nothing happens --->
		
	</cfif>
	
<!--- ==============================================================================
Proj 26955 RTS 1/30/2009 - Added if and updates for Bond 
	 Decision sql updates for BOND settings. 
 		Bond_bRecert, Bond_bTenantisBond, Bond_bRoomisBond, Bond_bRoomisBondIncluded 
=============================================================================== --->
	<cfif bondhouse.ibondhouse eq 1>
		<cfquery name="UpdateTenantBondStatus" datasource="#application.datasource#">
			update tenant
			set bIsBond = '#form.cBondTenantEligibleAfterRelocate#',
			dtBondCert = '#form.txtBondReCertDate#', cRowEndUser_ID = '#SESSION.USERNAME#'
			WHERE iTenant_ID = #form.iTenant_ID#
		</cfquery>
		<cfquery name="tenantbcheck" datasource="#application.datasource#">
			SELECT bIsBond 
			FROM tenant WITH (NOLOCK) 
			WHERE iTenant_ID = #form.iTenant_ID#
		</cfquery>
		<cfquery name="roombcheck" datasource="#application.datasource#">
			SELECT bBondIncluded 
			FROM aptaddress  WITH (NOLOCK)
			WHERE iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery>
		<cfif ((tenantbcheck.bIsBond eq 1) and (roombcheck.bBondIncluded eq 1))>
			<cfquery name="TurnRoomBond" datasource="#application.datasource#">
				UPDATE APTADDRESS
				SET bIsBond = 1, cRowEndUser_ID = '#SESSION.USERNAME#'
				WHERE iAptAddress_ID = #form.iAptAddress_ID# 
			</cfquery>
		</cfif>
		
	</cfif>
	<!--- ==============================================================================
	Proj ALtoMC Switch for BI--Added by Mamta-Start
	=============================================================================== --->
		<!---check current room--->
		<cfquery name="Currentroomcheck" datasource="#application.datasource#">
			Select ad.bismemorycareeligible,ts.iproductline_ID from tenantstate ts with (NOLOCK) join aptaddress ad with (NOLOCK) on ts.iaptaddress_ID=ad.iaptaddress_ID
            where ts.itenant_ID = #form.iTenant_ID#
		</cfquery>
		
        
		<!---check new room--->
		<cfquery name="Memorycareroomcheck" datasource="#application.datasource#">
			select bismemorycareeligible 
			from aptaddress WITH (NOLOCK) 
			where iAptAddress_ID = #form.iAptAddress_ID#
		</cfquery>
		
		
		<!---Update Tenantstate--->
		<cfif #Memorycareroomcheck.bismemorycareeligible# eq 1 >
		<cfquery name="UpdateTenantstate" datasource="#application.datasource#" result="UpdateTenantstate">
			update tenantstate
			set 
			<cfif #Tenant.dtMCSwitch# eq ''>
			dtMCSwitch = #dtActualEffective#,
			</cfif>
			iProductline_ID = 2
			WHERE iTenant_ID = #form.iTenant_ID#
		</cfquery>
		
		</cfif>
		<cfquery name="UpdateTenant" datasource="#application.datasource#" result="UpdateTenant1">
			update tenant
			set 
			cBillingtype = 
            <cfif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 89>
			'D'
			<cfelseif #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1748 or #qnewoccupancyofrelocatingtenant.ichargetype_ID# eq 1682>
			'M'
			<cfelse>
			'#session.qselectedhouse.cbillingtype#'
			</cfif>
			WHERE iTenant_ID = #form.iTenant_ID#
	    </cfquery>
		
		
		<!--- ==============================================================================
		Proj ALtoMC Switch for BI--Added by Mamta--End
		=============================================================================== --->
	
	
	</CFTRANSACTION>	
	
	<!---Mshah added this for SP to send information to SL to resident subaccount put this code in cftransaction now change later--->
	
	<!---query to get gl subaccount in TIPS--->
	<cfquery name="getSubaccount" datasource="#application.datasource#">
		select hpl.cglsubaccount From Tenant t with (NOLOCK) join tenantstate ts with (NOLOCK) on t.itenant_id = ts.itenant_id and ts.dtrowdeleted is null
		join houseproductline hpl with (NOLOCK) on hpl.iproductline_id = ts.iproductline_id and hpl.dtrowdeleted is null
		and hpl.ihouse_id = t.ihouse_id
		where t.iTenant_ID = #form.iTenant_ID#
	</cfquery>
		
	
	<!---query to get subaccount and full name in SL--->
	<cfquery name="getSLDetails" datasource='HOUSES_APP'>
		SELECT name, SlsSub 
		FROM customer WITH (NOLOCK) 
		WHERE custID = '#tenant.csolomonkey#'
	</cfquery>
	
	<cfset fname= '#Trim(tenant.cfirstname)# #Trim(tenant.clastname)#'>
	<cfset subaccount= '#getSubaccount.cglsubaccount#'>
	<cfset userID= '#session.username#'>
	<cfoutput>fname #fname# subaccount #subaccount# userID #userID#</cfoutput>
	<!----if name or subaccount dont match update them, fire the procedure--->
	<cfif ('#fname#' NEQ '#trim(getSLDetails.name)#') or ('#getSubaccount.cglsubaccount#' NEQ '#getSLDetails.SlsSub#')>
		<CFQUERY NAME='qCustImport' DATASOURCE='HOUSES_APP' result="qCustImport">
			 exec [dbo].[TSP_TenantAccountUpdate]  
					 '#tenant.csolomonkey#', '#fname#', '#subaccount#', '#userID#'
		</cfquery>
	
	</cfif>	 

	<!---End--->
		
<!--- ==============================================================================
Redirect page back to the main page with the new Apartment Change
=============================================================================== --->

<CFIF SESSION.USERID IS 3025 OR SESSION.USERID is 3271>
	<a href="../MainMenu.cfm">Continue</a>
<cfelse>
	<CFLOCATION URL="../MainMenu.cfm" ADDTOKEN="No">
</cfif>