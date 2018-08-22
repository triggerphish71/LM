<cfoutput>

<cfscript>
	function PhoneNumber(string){
		if (string neq "" and LEN(string) EQ 10)
			zip = LEFT(string,3);
			pre = MID(string, 4, 3);
			last = RIGHT(string,4);
			full = '(' & zip & ')' & pre & '-' & last;
		return full;
	}
</cfscript>
<cfif not isDefined("SESSION.qSelectedHouse.iHouse_ID")><cfset form.iHouse_ID = 200></cfif>
<cfquery name="qGetHouseData" datasource="#APPLICATION.datasource#">
	select	Du.EMail as AREmail
			,DU.WorkPhone ,H.cAddressLine1 ,cCity ,cStateCode ,cZipCode ,cPhoneNumber1
			,iPhoneType1_ID ,cPhoneNumber2 ,iPhoneType2_ID ,cPhoneNumber3 ,iPhoneType3_ID
			,H.cName ,H.cNumber ,H.iHouse_ID ,DU.FName ,DU.LName ,PT.cDescription as PhoneDescription
	from	House H
	join PhoneType PT ON (H.iPhoneType1_ID = PT.iPhoneType_ID or H.iPhoneType2_ID = PT.iPhoneType_ID or H.iPhoneType3_ID = PT.iPhoneType_ID and PT.dtRowDeleted is null)
	join #Application.AlcWebDBServer#.ALCWEB.dbo.employees DU	ON H.iAcctUser_ID = DU.Employee_ndx
	where	H.iHouse_ID = <cfif IsDefined("form.iHouse_ID")>#form.iHouse_ID#<cfelse>#SESSION.qSelectedHouse.iHouse_ID#</cfif>
	ORDER BY cName
</cfquery>

<script>
function initialize() { document.forms[0].iHouse_ID.value=#qGetHouseData.iHouse_ID# }
window.onload=initialize;
</script>

<cfquery name="qGetHouses" datasource="#APPLICATION.datasource#">
select * from House where dtRowDeleted is null ORDER BY cName
</cfquery>
<link rel="stylesheet" type="text/css" href="http://#server_name#/intranet/tips4/shared/style3.css">
<form action="HouseInfo.cfm" method="POST">
	<select name="iHouse_ID" onChange="submit();">
		<cfloop query="qGetHouses">
			<cfif IsDefined("form.iHouse_ID") and form.iHouse_ID EQ qGetHouses.iHouse_ID><cfset Var='selectED'><cfelse><cfset Var=''></cfif>
			<option value="#qGetHouses.iHouse_ID#" #VAR#> #qGetHouses.cName# </option>
		</cfloop>
	</select>

	<table style="width:50%;">
		<tr><td class="topleftcap"></td><td class="toprightcap"></td></tr>
		<tr><th colspan=100%>#trim(qGetHouseData.cName)# #qGetHouseData.cNumber# (#qGetHouseData.iHouse_ID#)</th></tr>
		<tr><td class="leftrightborder" colspan="2">
			#trim(qGetHouseData.cAddressLine1)# <br/>
			#trim(qGetHouseData.cCity)#, #qGetHouseData.cStateCode# #trim(qGetHouseData.cZipCode)# <br/>
		<cfif qGetHouseData.cPhoneNumber1 neq "">
			<cfquery name="qPhoneType" datasource="#APPLICATION.datasource#">
				select cDescription from PhoneType where dtRowDeleted is null
				and	iPhoneType_ID = #qGetHouseData.iPhoneType1_ID#
			</cfquery>
			#qPhoneType.cDescription# #PhoneNumber(trim(qGetHouseData.cPhoneNumber1))# <br/>
		</cfif>
		<cfif qGetHouseData.cPhoneNumber2 neq "">
			<cfquery name="qPhoneType" datasource="#APPLICATION.datasource#">
				select cDescription from PhoneType
				where dtRowDeleted is null and iPhoneType_ID = #qGetHouseData.iPhoneType2_ID#
			</cfquery>
			#qPhoneType.cDescription# #PhoneNumber(trim(qGetHouseData.cPhoneNumber2))#
		</cfif>
		<cfif qGetHouseData.cPhoneNumber3 neq "">
			<cfquery name="qPhoneType" datasource="#APPLICATION.datasource#">
				select cDescription from PhoneType where	dtRowDeleted is null
				and	iPhoneType_ID = #qGetHouseData.iPhoneType3_ID#
			</cfquery>
			#qPhoneType.cDescription# #PhoneNumber(trim(qGetHouseData.cPhoneNumber3))# <br/>
		</cfif>
		</td></tr> 
		<tr><td class="leftrightborder" colspan="2">AR Specialist : #trim(qGetHouseData.FName)# #trim(qGetHouseData.LName)#</td></tr> 
		<tr><td class="leftrightborder" colspan="2">Email : #trim(qGetHouseData.AREmail)#</td></tr> 
		<tr><td class="leftrightborder" colspan="2">Phone: #trim(qGetHouseData.WorkPhone)# ext.#RIGHT(qGetHouseData.WorkPhone,3)#</td></tr>
		<tr><td class="bottomleftcap"></td><td class="bottomrightcap"></td></tr>
	</table>
</form>
</cfoutput>
