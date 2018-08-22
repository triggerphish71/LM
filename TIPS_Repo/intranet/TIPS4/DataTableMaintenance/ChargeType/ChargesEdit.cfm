 <!---------------------------------------------------------------------------------------------
| DESCRIPTION:                                                                                 |
|----------------------------------------------------------------------------------------------|
| Application.cfm                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|											                                                   |  
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 01/24/2008 | added flowerbox                                                    |
|----------------------------------------------------------------------------------------------|
| ssathya    | 04/08/2008 | Added the Chargeset as a neccesary field to enter charges          |
|            |            | Added Javascript for the start and end year to be the same while   |
|            |            | entering the charges in the admin screen                           |
----------------------------------------------------------------------------------------------->

<!--- SET form path according to last action (either update or insert --->
<cfif IsDefined("url.Insert")>
	<cfset variables.Action = "ChargesInsert.cfm"> 
<cfelse> 
	<cfset variables.Action = "ChargesUpdate.cfm">
</cfif>

<cfinclude template="../../Shared/JavaScript/ResrictInput.cfm">

<!--- Retrieve All service level type sets --->
<cfquery name="SLevelSets" datasource="#APPLICATION.datasource#">
	select distinct cast(cSLevelTypeSet as int) as cSLevelTypeSet 
    from SLevelType where dtRowDeleted is null
    Order By cast(cSLevelTypeSet as int)
</cfquery>

<!--- Retrieve all the existing Charges --->
<cfquery name="charges" datasource="#APPLICATION.datasource#">
    select c.cDescription, c.iHouse_ID, c.*,
    ct.cDescription as ChargeType, ct.bSLevelType_ID,
    h.cNumber, h.cName,
    R.cDescription as Residency, R.iResidencyType_ID, R.iDisplayOrder, R.bIsPrivate, R.bIsMedicaid, R.bIsRespite, R.bIsDayRespite,
    AT.cDescription apttype,
    ST.cSLevelTypeSet as cSLevelTypeSet, c.cSLevelDescription
    from charges C
    join ChargeType CT on c.iChargeType_ID = ct.iChargeType_ID
    left join house	H on h.iHouse_ID = c.iHouse_ID
    left join residencytype R on c.iResidencyType_ID = R.iResidencyType_ID
    left join	apttype AT on c.iAptType_ID = AT.iAptType_ID
    left outer join	SLevelType ST on ST.iSLevelType_ID = c.iSLevelType_ID			
    where	c.dtRowDeleted is null
    <cfif IsDefined("url.ID")> and c.iCharge_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#URL.ID#"> <cfelse> and c.iCharge_ID = 0 </cfif>
</cfquery>

<!--- Retrieve all Entered Charge TypeS --->
<cfquery name="chargetype" datasource="#APPLICATION.datasource#">
    select * from ChargeType where dtRowDeleted is null
    
    <cfif IsDefined("form.iChargeType_ID")>
        <cfif form.iChargeType_ID neq "">
        	and iChargeType_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#form.iChargeType_ID#"></cfif>	
    <cfelseif IsDefined("url.ID")>
    	and iChargeType_ID = <cfqueryparam cfsqltype="cf_sql_bigint" value="#URL.ID#">
    </cfif>
</cfquery>

<!--- retrieve house product line info --->
<cfquery name="qproductline" datasource="#application.datasource#">
    select pl.iproductline_id, pl.cdescription
    from houseproductline hpl
    join productline pl on pl.iproductline_id = hpl.iproductline_id and pl.dtrowdeleted is null
    where hpl.dtrowdeleted is null and hpl.ihouse_id = <cfqueryparam cfsqltype="cf_sql_bigint" value="#session.qselectedhouse.ihouse_id#">
</cfquery>

<script language="JavaScript" src="../../../../cfide/scripts/wddx.js" type="text/javascript"></script>

<script>
	function initialize() { 
		if (!document.getElementById("iproductline_id") == false) {
			<cfif charges.iproductline_id neq "">
				document.getElementById("iproductline_id").value=<cfoutput>#trim(charges.iproductline_id)#</cfoutput>;
			</cfif>
		}
		if (document.getElementsByName("cDescription")[0].value !== "") { 
			document.getElementsByName("cDescription")[0].size=document.getElementsByName("cDescription")[0].value.length; 
		}
	}
	
	window.onload=initialize;
</script>

<!--- Retrieve service levels Dependent upon Set  --->
<!---<cfoutput>
	<!--- Do not include if the charge does not call for service level --->
	<cfif Charges.bSLevelType_ID neq "" or (IsDefined("Url.Insert") and ChargeType.bSLevelType_ID neq "")>
		<script>
			<cfif IsDefined("Charges.iSLevelType_ID") and Charges.iSLevelType_ID neq "">
				typeid = #Charges.iSLevelType_ID#; set = #Charges.cSLevelTypeSet#;
			<cfelse> typeid = ''; set = ''; </cfif>
			
			function sets(){
				var sets = new Array(
				<cfloop query="SLevelSets">
					<cfif SLevelSets.CurrentRow eq 1> #trim(SLevelSets.cSLevelTypeSet)#
					<cfelse> ,#trim(SLevelSets.cSLevelTypeSet)# </cfif>
				</cfloop>
				);
				
				for (i=0; i<=sets[i]; i++){
					document.ChargesEdit.cSLevelTypeSet.options[i].value = sets[i];
					document.ChargesEdit.cSLevelTypeSet.options[i].text = sets[i];
					if (set == document.ChargesEdit.cSLevelTypeSet.options[i].text){
						document.ChargesEdit.cSLevelTypeSet.options[i].selected = true;
					}
				}
				levels();
			}
			
			<cfloop query="SLevelSets">
				<cfquery name="Levels" datasource="#APPLICATION.datasource#">
					select * from SLevelType where cSLevelTypeSet = #SLevelSets.cSLevelTypeSet# and	dtRowDeleted is null
					order by cDescription
				</cfquery>
			
				levelindex#SLevelSets.cSLevelTypeSet# = new Array(
					<cfloop query="Levels">
						<cfif Levels.CurrentRow eq 1> #trim(Levels.iSLevelType_ID)#
						<cfelse> ,#trim(Levels.iSLevelType_ID)# </cfif>
					</cfloop>
				);
					
				level#SLevelSets.cSLevelTypeSet# = new Array(
					<cfloop query="Levels">
						<cfif Levels.CurrentRow eq 1> '#trim(Levels.cDescription)#'
						<cfelse> ,'#trim(Levels.cDescription)#' </cfif>
					</cfloop>		
				);	
				
				level#SLevelSets.cSLevelTypeSet#Desc = new Array (
					<cfloop query="Levels">
						<cfif Levels.CurrentRow eq 1> '#trim(Levels.cSLevelTypeSet)#'
						<cfelse> ,'#trim(Levels.cSLevelTypeSet)#' </cfif>
					</cfloop>		
				);
			</cfloop>
			
			function levels(){		
				<cfloop query="SLevelSets">
					if (document.ChargesEdit.cSLevelTypeSet.value == #trim(SLevelSets.cSLevelTypeSet)#){
						document.ChargesEdit.iSLevelType_ID.options.length = levelindex#trim(SLevelSets.cSLevelTypeSet)#.length;	
						for (i=0;i<=(levelindex#trim(SLevelSets.cSLevelTypeSet)#.length -1); i++){
							document.ChargesEdit.iSLevelType_ID.options[i].value = levelindex#trim(SLevelSets.cSLevelTypeSet)#[i];
							document.ChargesEdit.iSLevelType_ID.options[i].text =  level#trim(SLevelSets.cSLevelTypeSet)#[i];
							document.ChargesEdit.cSLevelTypeSet.value = level#SLevelSets.cSLevelTypeSet#Desc[i];
							if (typeid == document.ChargesEdit.iSLevelType_ID.options[i].text){
								document.ChargesEdit.iSLevelType_ID.options[i].selected = true;
								typeid = document.ChargesEdit.iSLevelType_ID.options[i].value;
		
							}
						}
					}
				</cfloop>
			}
		</script>
	</cfif>
</cfoutput>--->

<script>
function setenddate(enddate)
	{
		document.ChargesEdit.YearEnd.value = enddate;
	}

	function checkendyearonsave()
	{
		//42593 rts. year end & start code update
		var strStart = document.ChargesEdit.YearStart.value;
		var strEnd = document.ChargesEdit.YearEnd.value;
		Start = parseInt(strStart);
		End = parseInt(strEnd);
		if((End > Start+1) || (End < Start))
		{
			alert("The Effective End year cannot be more than \n 1 year greater than the Effective Beginning year.");
			return false;
		}
		else if(document.ChargesEdit.cChargeset.value=='')
		{
			alert("Please enter the Chargeset");
			return false;
		}
		else if(document.ChargesEdit.cDescription.value =='')
		{
			alert("Please Enter the Charge Description");
			return false;
		}
		else
		{
			return true;
		}
	}
</script>

<cfinclude template="../../Shared/Queries/Residency.cfm">
<cfinclude template="../../Shared/Queries/ApartmentTypes.cfm">

<cfinclude template="../../../header.cfm">

<cfoutput>
 
<form name="ChargesEdit" action="#variables.Action#" method="POST" onsubmit="return checkendyearonsave(); ">
<cfif IsDefined("url.ID")><input type="hidden" name="iCharge_ID" value="#Charges.iCharge_ID#"></cfif>
<table style="text-align: center;">
	<tr><th>ChargeType</th><th>Description</th><th>House</th><th width="200px">Amount</th></tr>
	<tr>
		<td style="text-align:left;">	
			<cfif IsDefined("url.ID")>
				 <input type="hidden" name="iHouse_ID" value="#session.qSelectedHouse.iHouse_ID#"> 
				<input type="hidden" name="iChargeType_ID" value="#Charges.iChargeType_ID#">	
				#Charges.ChargeType#
			<cfelse>
				<input type="hidden" name="iHouse_ID" value="#session.qSelectedHouse.iHouse_ID#"> 
				<input type="hidden" name="iChargeType_ID" value="#ChargeType.iChargeType_ID#">		
				#ChargeType.cDescription#
				
			</cfif>
		</td>	
		<td style="text-align:left;">
		<input type="text" Name="cDescription" value="#Charges.cDescription#" maxlength="35" 
		size="35" onKeyUp="this.value=LettersNumbers(this.value); this.size=this.value.length;">
		</td>	
		<cfif ChargeType.biHouse_ID neq "" or IsDefined("url.ID") >
			<td>#session.HouseName#</td>
		<cfelse>
			<td></td><input type="hidden" name="iHouse_ID" value="">
		</cfif>
		<td><input type="text" Name="mAmount" value="#LSCurrencyFormat(Charges.mAmount, "none")#" style="text-align:center;" SIZE=7 onKeyUp="this.value=CreditNumbers(this.value);" onBlur="this.value=cent(round(this.value));"></td>
	</tr>
	
	<tr>
		<td>Effective Beginning	</td>
		<td>
			<cfif Charges.dtEffectiveStart neq "">
				<cfset MonthStart = Month(Charges.dtEffectiveStart)>
				<cfset DayStart = Day(Charges.dtEffectiveStart)>
				<cfset YearStart = Year(Charges.dtEffectiveStart)>
			<cfelse>
				<cfset MonthStart = "#Month(now())#">
				<cfset DayStart = "#Day(Now())#">
				<cfset YearStart = "#Year(Now())#">
			</cfif>

				<select name="MonthStart" onBlur="dayslist(document.forms[0].MonthStart, document.forms[0].DayStart, document.forms[0].YearStart);">	
					<cfloop index="I" from ="1" to="12" step="1"> 
						<cfif MonthStart eq I> <cfset Selected = 'Selected'>
						<cfelse> <cfset Selected = ''> </cfif>					
						<option value="#I#" #selectED#> #I# </option>
					</cfloop>
				</select>
				/ 
				<select name="DayStart">
					<cfloop index="I" from ="1" to="#DaysInMonth(now())#" step="1"> 
						<cfif DayStart eq i> <cfset Selected = 'Selected'>
						<cfelse> <cfset Selected = ''> </cfif>					
						<option value="#I#"> #I# </option>
					</cfloop>
				</select>
				/
				<input type="Text" name="YearStart" value="#YearStart#" size="3" maxlength="4" onKeyUp = "this.value=Numbers(this.value);" onBlur="setenddate(this.value);">
		</td>
		
		<td>Effective End</td>
		<td>
			<cfif Charges.dtEffectiveEnd neq "">
				<cfset MonthEnd = Month(Charges.dtEffectiveEnd)>
				<cfset DayEnd = Day(Charges.dtEffectiveEnd)>
				<cfset YearEnd = Year(Charges.dtEffectiveEnd)>
				<cfset DaysInMonth = DaysInMonth(Charges.dtEffectiveEnd)>
			<cfelse>
				<cfset MonthEnd = "12">
				<cfset DayEnd = "31">
				<cfset YearEnd = "#YearStart#">
				<cfset DaysInMonth = DaysInMonth(now())>
			</cfif>

				<select name="MonthEnd" onBlur="dayslist(document.forms[0].MonthEnd, document.forms[0].DayEnd, document.forms[0].YearEnd);">	
					<cfloop index="I" from ="1" to="12" step="1"> 
						<cfif MonthEnd eq i> <cfset Selected = 'Selected'>
						<cfelse> <cfset Selected = ''> </cfif>
						<option value="#I#" #selectED#> #I# </option>
					</cfloop>
				</select>
				/
				<select name="DayEnd">
					<cfloop index="I" from ="1" to="#DaysInMonth#" step="1"> 
						<cfif DayEnd eq i> <cfset Selected = 'Selected'>
						<cfelse> <cfset Selected = ''></cfif>					
						<option value="#I#" #selectED#> #I# </option>
					</cfloop>
				</select>
				/
				<input type="Text" name="YearEnd" Value = "#YearEnd#" SIZE = "1" maxlength="4" onKeyUp = "this.value=Numbers(this.value);">
		</td>
	</tr>
	<tr>
		<td colspan="2" valign="TOP">
			<!--- Start of Nested Table --->
			<table style="width:100%; border:none;">				
					<!---<cfif chargetype.bResidencyType_ID gt 0 >--->
					<tr>
						<td> Product line </td>
						<td>
							<select id="iproductline_id" name="iproductline_id">
							<cfloop query= "qproductline">
								<option value= "#qproductline.iproductline_id#">	#qproductline.cDescription#	</option>
							</cfloop>
							</select>	
						</td>
						<td colspan="2"></td>
					</tr>
					<tr>	
						<td colspan="1">Residency Type</td>
						<td colspan="1">
							<select name="iResidencyType_ID">
								<cfloop query = "Residency">
									<cfif Charges.iResidencyType_ID eq Residency.iResidencyType_ID> <cfset Selected='selected'>
									<cfelse> <cfset Selected=''> </cfif>
									<option value = "#Residency.iResidencyType_ID#" #selectED#>	#Residency.cDescription# </option>
								</cfloop>
							</select>	
						</td>
					<!---<cfelse>
						<td> #Charges.Residency# </td>
						<input type="hidden" name="iResidencyType_ID" value="#Charges.iResidencyType_ID#">
					</tr>
					</cfif>--->
					<!--- 04/08/08 SSathya Added the chargeset column as it is conflicting as its not showing up for respite --->
					<tr>
						<td colspan="1">Chargeset (e.g. 2008Jan)</td>
						<td colspan="1">
							<input type="text" Name="cChargeset" value="#Charges.cChargeSet#">
							
						</td>
					</tr>
					<tr>	
					<cfif chargetype.bSLevelType_ID gt 0 >
						<td>	Service Level Set
								<select name="cSLevelTypeSet" onBlur="levels();">
									<cfloop query="SLevelSets">
									<cfif IsDefined("Charges.cSLevelTypeSet") or isDefined("session.qselectedhouse.csleveltypeset")>
										<cfif Charges.cSLevelTypeSet eq SLevelSets.cSLevelTypeSet or session.qselectedhouse.csleveltypeset eq SLevelSets.cSLevelTypeSet> 
											<cfset Selected='Selected'>
										<cfelse> <cfset Selected=''> </cfif>
									<cfelse> <cfset Selected=''> </cfif>
										<option value="#SLevelSets.cSLevelTypeSet#" #selectED#>	#SLevelSets.cSLevelTypeSet#	</option>
									</cfloop>
								</select>
						</td>
						<td>	
							Level	
								<cfloop index="I" from ="0" to="4" step="1">
									<cfif Charges.cSLevelDescription eq i> <cfset Selected='Selected'>
									<cfelse> <cfset Selected=''> </cfif>
									<option value="#I#" #selectED#> #I# </option>
								</cfloop>
							</select>
						</td>
					<cfelseif Charges.bSLevelType_ID gt 0>
						<td>	Level #Charges.iSLevelType_ID#	</td>
						<input type="hidden" name="iSLevelType_ID" value="#Charges.iSLevelType_ID#">
					</cfif>		
					</tr>
					<cfif IsDefined("Charges.iQuantity") and Charges.iQuantity neq ''>
                        <cfset Quantity = Charges.iQuantity>
                    <cfelse> <cfset Quantity = 1> </cfif>
                    <tr>		
                        <td style="text-align:right;"> Quantity </td>	
                        <td> <input type="text" Name="iQuantity" value="#Quantity#" SIZE="2" style="text-align: center;">	</td>
                    </tr>				
				</table>
			<!--- End of Nested Table --->
		</td>
		<td colspan = "2">
			<!--- Second Nested Table --->			
			<table style="width:100%;border:none;">
				<tr><td colspan="2"></td></tr>
				<tr><td colspan="2"></td></tr>
				<tr>	
					<cfif chargetype.bAptType_ID gt 0 >
						<td>Apartment Type</td>
						<td>	
							<select name="iAptType_ID">
								<option value="">	None </option>		
								<cfloop query="ApartmentTypes">
									<cfif Charges.iAptType_ID eq ApartmentTypes.iAptType_ID> <cfset AptSelected = 'selected'>
									<cfelse><cfset AptSelected = ''></cfif>								
									<option value = "#ApartmentTypes.iAptType_ID#" #AptSelected#> #ApartmentTypes.cDescription# </option>
								</cfloop>
							</select>
						</td>
					<cfelse> <input type="hidden" name="iAptType_ID" value=""> </cfif>	
				</tr>
				<cfif ((ChargeType.bOccupancyPosition gt 0) or ((charges.iChargeType_ID is 7) and (ChargeType.bOccupancyPosition is '')))>
					<tr>
						<td>Occupancy Position</td>
						<td>					
							<select name="iOccupancyPosition">
								<!--- Intialize variables --->
								<cfset OneSelected =''><cfset TwoSelected =''>
								<cfif Charges.iOccupancyPosition IS 1> <cfset OneSelected = "selected">
								<cfelseif Charges.iOccupancyPosition IS 2> <cfset TwoSelected = "selected"> </cfif>
								<option value = "1" #OneSelected#> One </option>
								<option value = "2" #TwoSelected#> Two </option>
							</select>
						</td>
					</tr>
				<cfelse> <input type="hidden" name="iOccupancyPosition" value=""> </cfif>
			</table>
			<!--- End of Second Nested Table --->
		</td>
	</tr>
	<tr>		
	<td colspan="2" style="text-align: left;"><input class="SaveButton" type="submit" name="Save" value="Save" onmouseover="checkendyearonsave()" ></td>	
	<td colspan="2" style="text-align: right;"><input class="DontSaveButton" type="button" name="DontSave" value="Don't Save" onClick="location.href='#CGI.HTTP_REFERER#'"></td>
	</tr>
	<tr><td colspan="4" style="font-weight: bold; color: red;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </td></tr>	
</table>
</form>
<!---#Charges.bSLevelType_ID#--->
<!---<cfif Charges.bSLevelType_ID neq "" or (IsDefined("url.Insert") and url.Insert eq 1 and ChargeType.bSLevelType_ID neq "")>
	<script>sets(); levels();</script>
</cfif>--->
</cfoutput>

<cfinclude template="../../../footer.cfm">