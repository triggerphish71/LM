<!---  ----------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
|S Farmer    | 08-1-2013  | Program to allow AR to directly change move out dates Ticket#109102|
|sfarmer     | 2017-05-09 | 'move out date' changed to 'physical move out date'                |
|MStriegel   | 03/10/2018 | Added logic to use the cfc to get the query data                   |
----------------------------------------------------------------------------------------------->
<!--- mstriegel 3/10/2018 --->
<cfset oTenantARServices = CreateObject("component","intranet.TIPS4.CFC.components.Tenant.tenantARServices")>
<!--- end mstriegel 3/10/2018 --->

<!--- Include Intranet Header --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Edit Move Out Dates</title>
</head>

<cfinclude template="../../header.cfm">
  
	<script >	
	 <cfinclude template="../../global/Calendar/ts_picker2.js">
	</script>  
	<script language="javascript">
/*mstriegel 03/10/2018*/
		function isDate(sDate){
			var scratch = new Date(sDate);
			if(scratch.toString() == "NaN"){
				return false;
			}
			else{
				return true;
			}
		}

		function verifyDate(){

			if(document.updDates.moveoutdate.value == ''){
				alert("Moveout date is required.");
				return false;
			}			
			if(isDate(document.updDates.moveoutdate.value) == false){
				alert("Moveout date is invalid.");
				return false;
			}

			if(document.updDates.chargedate.value == ''){
				alert("Charge through date is required.");
				return false;
			}			
			if(isDate(document.updDates.chargedate.value) == false){
				alert("Charg  through date is invalid.");
				return false;
			}


			if(document.updDates.projectmoveoutdate.value == ''){
				alert("Projected move out date is required.");
				return false;
			}			
			if(isDate(document.updDates.projectmoveoutdate.value) == false){
				alert("Projected move out date is invalid.");
				return false;
			}
			
			if(document.updDates.chargedate.value < document.updDates.moveoutdate.value){
				alert("Charge Through Date cannot be less than the Physical moveoutdateMove Out Date");
		 		return false;
			}	
			return true;		 
		}
/* end mstriegel 03/10/2018*/
	</script>  

	<h1 class="PageTitle"> Tips 4 - Tenant Edit Move Out </h1>
   	<cfinclude template="../Shared/HouseHeader.cfm">
	<cfparam  name="solomonid" default="">

	<!--- mstriegel 3/10/2018 --->
			<cfset qryResidentID = oTenantARServices.getResidentInfoByKey(solomonid=solomonid)>		
	<!--- end mstriegel 03/10/2018 --->

		<form name="updDates" method="post"  id="updDates" action="updMoveOutDates.cfm"   onsubmit="return verifyDate();">
		<table>
			<cfif qryResidentID.csolomonkey is not ""> 
			<cfoutput query="qryResidentID">

			<input type="hidden" name="csolomonkey" value="#csolomonkey#" />
			<input type="hidden" name="tenantid" value="#itenant_id#"/>
			<input type="hidden" name="cfirstname" value="#cfirstname#"/>
			<input type="hidden" name="clastname" value="#clastname#"/>
			<input type="hidden" name="ihouseid" value="#ihouse_id#"/>
				<tr>
					<td colspan="2" style="text-align:left">Name: #cfirstname# #clastname#</td>
				</tr>
				<tr>
					<td colspan="2" style="text-align:left">House: #House#</td>
				</tr>
				<cfif dtmoveout is "" and iResidencyType_ID is not 3>
					<tr>
					<!--- mstriegel 03/10/2018 --->
						<td style="color:##FF0000; font-weight:bold"><!--- This resident does not have Move-Out dates established. <br />Use the established Move-Out process.--->
							This is not a respite resident.
						</td>
					<!--- end mstriegel 03/10/2018 --->
					</tr>
				<cfelseif  dtmoveout is not "" >
					<tr>
						<td>&nbsp;</td>
						<td style="text-align:center">Enter or Select Correct Date for the appropriate field</td>
					</tr>
					<tr style="background-color:##FFFF99">
						<td>Physical Move Out Date:</td>
						<td style="text-align:center"><input name="moveoutdate" id="moveoutdate" value="#dateformat(dtMoveOut,'mm/dd/yyyy')#"  size="12"/>
							 <a onClick="show_calendar2('document.updDates.moveoutdate',document.getElementById('moveoutdate').value,'moveoutdate');"> &nbsp;
							 <img src="../../global/Calendar/calendar.gif" alt="Select Physical Move Out Date" width="25" height="25" border="0" align="middle" style="" id="Cal" name="Cal"></a>
						</td>
					</tr>
					<tr>
						<td>Charge Through Date:</td>
						<td style="text-align:center"><input name="chargedate" id="chargedate" value="#dateformat(dtChargeThrough,'mm/dd/yyyy')#" size="12" />
							<a onClick="show_calendar2('document.updDates.chargedate',document.getElementById('chargedate').value,'chargedate');">&nbsp; 
							<img src="../../global/Calendar/calendar.gif" alt="Select Charge Through Date, Charge Through Date CANNOT be earlier than the Physical Move Out Date" width="25" height="25" border="0" align="middle" style="" id="Cal" name="Cal"></a>
						</td>
					</tr>	
					<cfelse>
					<tr><td>No Move-Out Dates found to edit, return to selection page and re-check entries.</td></tr>
				</cfif>
					<cfif iResidencyType_ID is 3>
						<tr  style="background-color:##FFFF99">
							<td>Projected Physical Move Out Date:</td>
							<td style="text-align:center"><input name="projectmoveoutdate" id="projectmoveoutdate" value="#dateformat(dtMoveOutProjectedDate,'mm/dd/yyyy')#" size="12" />
								<a onClick="show_calendar2('document.updDates.projectmoveoutdate',document.getElementById('projectmoveoutdate').value,'projectmoveoutdate');">&nbsp; 
								<img src="../../global/Calendar/calendar.gif" alt="Select Projected Physical Move Out Date" width="25" height="25" border="0" align="middle" style="" id="Cal" name="Cal"></a>
							</td>
						</tr>
				
						<tr>
							<td colspan="2" style="text-align:center"><input name="submit" type="submit" value="Submit" /></td>	
						</tr>	
					</cfif>				
				</cfoutput> 
				<cfelse> 
					<tr><td style="color:red; text-align:center; font-weight:bold" >No Resident found for <cfoutput>#solomonid#</cfoutput>, return to selection page and re-check entry.</td></tr>
				</cfif>			
		</table>
		</form>
		<cfif qryResidentID.iresidencyType_ID EQ 3>
			<form name="rtnEditPage" id="rtnEditPage" method="post" action="tenantAREdit.cfm" >
				<table>
					<cfoutput><input  type="hidden" name="solomonid" id="solomonid" value="#solomonid#" /></cfoutput>
					<table style="background-color:#FFFF00">
						<TD  style="text-align:center"><input type="submit" name="SUBMIT" value="Return to Edit Selection Page" /></TD>
					</TR> 
				</table>
			</form>
		</cfif>
	
		<!--- Include intranet footer --->
		<cfinclude template="../../footer.cfm">		
	
 
