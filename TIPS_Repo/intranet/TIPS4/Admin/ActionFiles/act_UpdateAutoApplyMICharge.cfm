<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| RSchuette  | 01/21/2010 | Created  - Update House Charge for MI Auto Apply to Ruccuring        |
|							for all new tenants													 |
|							Created Page + code for #35227										 |
------------------------------------------------------------------------------------------------->


<cfoutput>
<CFIF NOT IsDefined("SESSION.USERID") 
		OR SESSION.UserId EQ "" 
		OR NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") 
		OR SESSION.qSelectedHouse.iHouse_ID EQ ""
		OR not listcontains(session.groupid,'285')> <!--- 285 ARMasterAdmin in prod --->
	<CFOUTPUT><CFLOCATION URL="http://#server_name#/alc"></CFOUTPUT>
</CFIF>

<cfquery name="GetAllHousesandCS" datasource="#APPLICATION.datasource#">
	select h.iHouse_ID,cs.cName from House h
	join ChargeSet cs on (cs.iChargeSet_ID = h.iChargeSet_ID)
	where h.iHouse_ID <> 52 
	and h.dtRowDeleted is null 
</cfquery>

<cfloop query="GetAllHousesandCS">
	<cfquery name="GetHouseChargeForChargeType" datasource="#APPLICATION.datasource#">
		Select c.iCharge_ID from Charges c
		where c.iHouse_ID = #GetAllHousesandCS.iHouse_ID#
		and c.cChargeSet = '#GetAllHousesandCS.cName#'
		and c.iChargeType_ID = #session.cid#
		and c.bIsMoveInCharge = 1
		and c.dtRowDeleted is null
	</cfquery>
		<cfif GetHouseChargeForChargeType.RecordCount gt 0>
			<cfif isdefined('dbCidList') is TRUE>
				<cfset dbCidList = dbCidList & ',' & GetHouseChargeForChargeType.iCharge_ID>
			<cfelse>
				<cfset dbCidList = GetHouseChargeForChargeType.iCharge_ID>
			</cfif>
		</cfif>
</cfloop>

<cfloop list="#FORM.FieldNames#" delimiters="," index="loopVar">
	<cfif loopvar neq 'SAVE'>
	<!--- <cfloop list="#cboInlcude#" index="loopVar"> --->
		<cfif Find("_",loopVar) gt 0>
		<!--- <cfset chargeSetForHouse = FORM["hChargeset_#loopVar#"]> --->
			<cfset hid = RIGHT(loopVar,Find("_",Reverse(loopVar)) - 1)>
			<cfif isdefined('hidList') is TRUE>
				<cfset hidList = hidList & ',' & hid>
			<cfelse>
				<cfset hidList = hid>
			</cfif>
		</cfif>
		<!--- Get House's' CS --->
		<cfquery name="GetHouseCC" datasource="#APPLICATION.datasource#">
			Select cs.cname from ChargeSet cs join House h on (h.iChargeSet_ID = cs.iChargeSet_ID and h.iHouse_ID = #hid#)
		</cfquery>
		<!--- get charges based off the screen --->
		<cfquery name="GetChargesFromScreen" datasource="#APPLICATION.datasource#">
			Select c.iCharge_id from Charges c
			where c.iHouse_ID = #hid#
			and c.cChargeSet = '#GetHouseCC.cName#'
			and c.iChargeType_ID = #session.cid#
			and c.dtRowDeleted is null
		</cfquery>
		<cfif GetChargesFromScreen.RecordCount gt 0>
			<cfif isdefined('uiCidList') is TRUE>
				<cfset uiCidList = uiCidList & ',' & GetChargesFromScreen.iCharge_ID>
			<cfelse>
				<cfset uiCidList = GetChargesFromScreen.iCharge_ID>
			</cfif>
		</cfif>
		<!---  #loopVar#,#hid#,#session.cid#</br>  --->
	</cfif>
</cfloop>
	<cfif isdefined('uiCidList') is TRUE>
		<!--- new houses set to '1' that were newly selected --->
	 	<cfquery name="UpdateNewChanges" datasource="#APPLICATION.datasource#">
			Update Charges
			set bIsMoveInCharge = 1,iRowStartUser_ID = #session.userid#
			where charges.iCharge_ID in (#uiCidList#)
			<cfif isdefined('dbCidList') is TRUE>and charges.iCharge_ID not in (#dbCidList#)</cfif>
		</cfquery>
	</cfif>
	<cfif isdefined('dbCidList') is TRUE>
	<!--- houses set to '0' that were newly unchecked --->
		<cfquery name="UpdateNewChanges" datasource="#APPLICATION.datasource#">
			Update Charges
			set bIsMoveInCharge = null,iRowStartUser_ID = #session.userid#
			where charges.iCharge_ID in (#dbCidList#)
			<cfif isdefined('uiCidList') is TRUE>and charges.iCharge_ID not in (#uiCidList#)</cfif>
		</cfquery> 
	</cfif>
<!--- #uiCidList# </br></br>
 #dbCidList# </br></br>
 #hidList# </br></br> --->

 <form name="return2page" action="../DisplayFiles/dsp_HouseAutoApplyMICharge.cfm?ID=#'ChargeSelect'#" method="POST" >
	<!--- use javascript t osubmit and post form back to getdetailspage --->
	<input name="ChargeSelect" type="hidden" value="#session.cid#">
	<script type='text/javascript'>document.return2page.submit();</script>
</form> 
</cfoutput>


