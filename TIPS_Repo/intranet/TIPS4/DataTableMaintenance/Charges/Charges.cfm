<!--- ==============================================================================
Modifications:
Date	Author	Description
01/09/02 SBD	Added effective dates to "Charges" query (General)
=============================================================================== --->

<cfif IsDefined("url.sort") and url.sort eq 'ShowExpired'><cfset form.ShowExpired = 1></cfif>
<cfif IsDefined("url.sort") and url.sort eq 'ShowFuture'><cfset form.ShowFuture = 1></cfif>
<cfparam name="URL.SelectedSortOrder" default="X">

<!--- ==============================================================================
Retrieve all the existing Charges.
This query is dependent upon if the user has selected general or house specific 
charges from the administration panel
=============================================================================== --->
<!--- <cfquery name="charges" datasource="#application.datasource#">
	<cfif URL.ID eq "General">
		select C.cDescription, C.iHouse_ID, C.mAmount, C.iChargeType_ID, C.iCharge_ID, C.iQuantity,
				CT.cDescription As ChargeType, CT.cGLAccount, CT.biHouse_ID,
				C.dtEffectiveStart, C.dtEffectiveEnd, pl.cdescription pline
		from charges C	
		join ChargeType CT on (C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null)
		left join productline pl on pl.iproductline_id = c.iproductline_id and pl.dtrowdeleted is null
		where C.dtRowDeleted is null and C.iHouse_ID is null 
		<cfif IsDefined("form.ShowExpired")> and	C.dtEffectiveEnd <= getDate()
		<cfelseif IsDefined("form.ShowFuture")> and	C.dtEffectiveStart >= getDate()
		<cfelse> and	C.dtEffectiveStart <= getDate() and C.dtEffectiveEnd >= getDate() </cfif>
	<cfelseif URL.ID eq "House">
		select	distinct C.cDescription, C.mAmount, C.iCharge_ID, C.iQuantity, C.iChargeType_ID,
				C.cSLevelDescription, C.iSLevelType_ID, CT.cDescription As ChargeType,
				C.dtEffectiveStart, C.dtEffectiveEnd,  pl.cdescription pline, 
				CASE WHEN CT.bSLevelType_ID is null THEN 'n/a' ELSE ST.cSlevelTypeSet END as cSlevelTypeSet
		from	charges C	
		left join productline pl on pl.iproductline_id = c.iproductline_id and pl.dtrowdeleted is null
		join 	ChargeType CT on C.iChargeType_ID = CT.iChargeType_ID
		left join	SLevelType ST on ST.iSLevelType_ID = C.iSLevelType_ID
		where	C.dtRowDeleted is null and C.iHouse_ID is not null
		and		C.iHouse_ID = #session.qSelectedHouse.iHouse_ID# 
		<cfif IsDefined("form.ShowExpired")>
        	and C.dtEffectiveEnd <= getDate()
		<cfelseif IsDefined("form.ShowFuture")>
        	and C.dtEffectiveStart >= getDate()
		<cfelse> 
        	and C.dtEffectiveStart <= getDate() and C.dtEffectiveEnd >= getDate()
        </cfif>
    </cfif>
     Order By 
    <cfswitch expression="#URL.SelectedSortOrder#">
    	<cfcase value="Charge">
        	CT.cDescription
        </cfcase>
        <cfcase value="Level">
        	C.cSLevelDescription, C.iSLevelType_ID
        </cfcase>
        <cfcase value="Amount">
        	C.mAmount
        </cfcase>
    	<cfdefaultcase>
        	cSLevelTypeSet desc, CT.cDescription
        </cfdefaultcase>
    </cfswitch>
</cfquery> --->
<!--- I corrected the above query 04-25-2012 SDF --->
<cfquery name="charges" datasource="#application.datasource#">
	<cfif URL.ID eq "General">
		select C.cDescription, C.iHouse_ID, C.mAmount, C.iChargeType_ID, C.iCharge_ID, C.iQuantity,
				CT.cDescription As ChargeType, CT.cGLAccount, CT.biHouse_ID,
				C.dtEffectiveStart, C.dtEffectiveEnd, pl.cdescription pline,
				ST.cSLevelTypeSet as cSLevelTypeSet,
				C.CSLEVELDESCRIPTION 
		from charges C	
		join ChargeType CT on (C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null)
		left join productline pl on pl.iproductline_id = c.iproductline_id and pl.dtrowdeleted is null
				left join	SLevelType ST on ST.iSLevelType_ID = C.iSLevelType_ID
		where C.dtRowDeleted is null and C.iHouse_ID is null 
		<cfif IsDefined("form.ShowExpired")> and	C.dtEffectiveEnd <= getDate()
		<cfelseif IsDefined("form.ShowFuture")> and	C.dtEffectiveStart >= getDate()
		<cfelse> and	C.dtEffectiveStart <= getDate() and C.dtEffectiveEnd >= getDate() </cfif>
	<cfelseif URL.ID eq "House">
		select	distinct C.cDescription, C.mAmount, C.iCharge_ID, C.iQuantity, C.iChargeType_ID,
				C.cSLevelDescription, C.iSLevelType_ID, CT.cDescription As ChargeType,
				C.dtEffectiveStart, C.dtEffectiveEnd,  pl.cdescription pline, 
				CASE WHEN CT.bSLevelType_ID is null THEN 'n/a' ELSE ST.cSlevelTypeSet END as cSlevelTypeSet
		from	charges C	
		left join productline pl on pl.iproductline_id = c.iproductline_id and pl.dtrowdeleted is null
		join 	ChargeType CT on C.iChargeType_ID = CT.iChargeType_ID
		left join	SLevelType ST on ST.iSLevelType_ID = C.iSLevelType_ID
		where	C.dtRowDeleted is null and C.iHouse_ID is not null
		and		C.iHouse_ID = #session.qSelectedHouse.iHouse_ID# 
		<cfif IsDefined("form.ShowExpired")>
        	and C.dtEffectiveEnd <= getDate()
		<cfelseif IsDefined("form.ShowFuture")>
        	and C.dtEffectiveStart >= getDate()
		<cfelse> 
        	and C.dtEffectiveStart <= getDate() and C.dtEffectiveEnd >= getDate()
        </cfif>
    </cfif>
     Order By 
    <cfswitch expression="#URL.SelectedSortOrder#">
    	<cfcase value="Charge">
        	CT.cDescription
        </cfcase>
        <cfcase value="Level">
        	C.cSLevelDescription, C.iSLevelType_ID
        </cfcase>
        <cfcase value="Amount">
        	C.mAmount
        </cfcase>
    	<cfdefaultcase>
        	cSLevelTypeSet desc, CT.cDescription
        </cfdefaultcase>
    </cfswitch>
</cfquery>
<!--- ==============================================================================
Retrieve list of charge types dependent upon if we are dealing with
General or House Specific Charges
=============================================================================== --->
<cfscript>
	if (url.ID eq "General") { filter='and biHouse_ID is null'; }
	if (url.ID eq "House") { filter='and biHouse_ID is not null'; }
</cfscript>

<cfquery name="ChargeTypes" datasource="#application.datasource#">
	select * from ChargeType 
	where dtRowDeleted is null 
	<cfif ListContains(session.groupid,'285') gt 0> <cfelse> #filter#</cfif> 
	order by cDescription
</cfquery>

<cfinclude template="../../../header.cfm">
<style>td{font-size:10px;}</style>
<table class="noborder">
<tr><td class="transparent"><P class="PAGETITLE"> Charges Administration For <cfoutput>	#session.HouseName#	</cfoutput></P></td></tr>
</table>

<form action = "ChargesEdit.cfm?Insert=1" method="POST">
	<A Href="../../Admin/Menu.cfm" style="Font-size: 14;"><B>Click Here to Go Back To Administration Screen.</B></a>
	<br/><br/>
	<table class="noborder">
		<tr><td style="background: white; font-size: 20;">Choose Charge Type for New Charge</td></tr>
		<tr>	
			<td style="background: white;">
				<select name="iChargeType_ID">
					<cfoutput query="ChargeTypes"><OPTION value="#ChargeTypes.iChargeType_ID#">	#ChargeTypes.cDescription# </OPTION></cfoutput>
				</select>
				<input type="Submit" name="EditType" value="Submit">
			</td>
		</tr>	
	</table>	
</form>
<cfoutput>
<table style="text-align: center;">
	<tr>
		<cfif NOT IsDefined("form.ShowExpired")>
			<form action="Charges.cfm?ID=#Url.ID#" method="Post">
			<td style="background: gainsboro;">
				<input type="Submit" name="ShowExpired" value="View Expired Charges">
			</td>
			</form>
		<cfelse>
			<form action="Charges.cfm?ID=#url.ID#" method="Post">
			<td style="background: gainsboro;">
				<input type="Submit" name="DoNotShowExpired" value="Show Non-Expired Charges">
			</td>
			</form>
		</cfif>
		<form action="Charges.cfm?ID=#url.ID#" method="Post">
			<td style="background: gainsboro;"><input type="Submit" name="DoNotShowExpired" value="View Current Charges"></td>
		</form>	
		<cfif NOT IsDefined("form.ShowFuture")>
			<form action="Charges.cfm?ID=#Url.ID#" method="Post">
				<td style="background: gainsboro;"><input type="Submit" name="ShowFuture" value="View Future Charges"></td>
			</form>
		<cfelse>
			<form action="Charges.cfm?ID=#url.ID#" method="Post">
				<td style="background: gainsboro;"><input type="Submit" name="DoNotShowFuture" value="Show Non-Future Charges"></td>
			</form>
		</cfif>			
	</tr>
</table>

<table>
	<tr>
		<cfif IsDefined("url.id") and url.ID neq ""><cfset ID="house"><cfelse><cfset ID="General"></cfif>
		<th><a href="Charges.Cfm?SelectedSortOrder=description&ID=#Variables.ID#" style="color: White;">Description</A></th>
		<th><a href="Charges.Cfm?SelectedSortOrder=description&ID=#Variables.ID#" style="color: White;">Product</A></th>
		<cfif IsDefined("Charges.cSLevelTypeSet")>
			<th><a href="Charges.Cfm?SelectedSortOrder=level&ID=#Variables.ID#" STYLE = "color: White;">Set/Lvl</A></th>
		</cfif>
		<th><a href="Charges.Cfm?SelectedSortOrder=Charge&ID=#Variables.ID#" style="color: White;">Charge Type</A></th>
		<th><a href="Charges.Cfm?SelectedSortOrder=Amount&ID=#Variables.ID#" style="color: White;">Amount</A></th>
		<th><a href="Charges.Cfm?SelectedSortOrder=Quantity&ID=#Variables.ID#" style="color: White;">Qty</A></th>
		<th> Started </th>
		<th> Expires</th>
		<th> Delete	</th>
	</tr>
 </cfoutput>   
	<cfoutput query="Charges">	
		<tr>
			<td style="text-align: left;" nowrap>
            	<input type="hidden" name="iChargeType_ID" value="#Charges.iChargeType_ID#" />
            	<a href="ChargesEdit.cfm?ID=#Charges.iCharge_ID#">#charges.cDescription#</A></td>
			<td>#charges.pline#</td>
			<td style="text-align: center;" nowrap>#Charges.cSLevelTypeSet#/#Charges.cSLevelDescription#</td>
			<td nowrap> #charges.ChargeType# </td>
			<td style="text-align: right;"> #LSCurrencyFormat(charges.mAmount)# </td>
			<td style="text-align: center;"> #charges.iQuantity# </td>
			<cfset startcolor= "">
            <cfset Endcolor= "">
			<cfif Charges.dtEffectiveStart GT Now()>
				<cfset startcolor= "color: red;">
			</cfif>
			<cfif Charges.dtEffectiveEnd LT Now()>
				<cfset Endcolor= "color: red;">
            </cfif>	
			<td style="text-align: center; #StartColor#">#DateFormat(Charges.dtEffectiveStart,"mm/dd/yyyy")#</td>		
			<td style="text-align: center; #EndColor#">#DateFormat(Charges.dtEffectiveEnd,"mm/dd/yyyy")#</td>
			<td nowrap style="text-align: center;">
                <cfif Now() GTE Charges.dtEffectiveStart and Now() LTE Charges.dtEffectiveEnd>
					<input class = "BlendedButton" TYPE="button" name="Delete" value="Delete Now" 
                    onClick="self.location.href='DeleteCharge.cfm?typeID=#Charges.iCharge_ID#&Process=#url.ID#'">
				<cfelse> 
                	In use 
                </cfif>
			</td>	
		</tr>
        <cfflush interval="500">
	</cfoutput>
</table>

<A Href="../../Admin/Menu.cfm" style="Font-size: 18;">Click Here to Go Back To Administration Screen.</a>

<cfinclude template="../../../footer.cfm">
