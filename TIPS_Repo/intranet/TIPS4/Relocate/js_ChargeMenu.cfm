<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| ranklam    | 08/25/2005 | Created                                                              |
| ranklam    | 08/31/2005 | Changed the cfoutput code that added chargetypes and charges to the  |
|            |            | javascript to replace ' with /' so single quotes done break the code |
| ranklam    | 01/04/2005 | Changed line 110 to use the .tolowercase in case the chargesets have |
|            |            | different cases.
|rschuette	 | 02/13/2009 | Updated 2 code blocks for Proj 26955
------------------------------------------------------------------------------------------------->

<!--- First get the rates for the chargeType of 91 from the additional query--->
<script language="javascript">
	//this function sets a span's class to visible if the user is not on the default value
	function show(objectName)
	{
			document.getElementsByName(objectName)[0].style.visibility = 'visible';
	}
	//this function sets a span's class to hidden if the user is not on the default value
	function hide(objectName)
	{
		document.getElementsByName(objectName)[0].style.visibility = 'hidden';
	}
	
	//this function returns the chargeset for the selected tennant
	function GetChargeSetForTenant()
	{
		//set a variable to the selected tenants id
		var tenantId = document.getElementsByName('iTenant_ID')[0].value;
		<cfoutput>
		//create a new array to hold the tennant information
		var tenantArray = new Array(#TenantList.RecordCount#);
		</cfoutput>
		<!--- Loop through the tenants and create an multi-dimension array holding the tenant id and charge type --->
		<cfset i = 0>
		<!--- this holds the charge set value for an tenant --->
		<cfset chargeSetValue = "">
		<cfoutput query="TenantList">
		<cfif TenantList.cChargeSet eq "">
			<!--- If the chargeset is null, set the charge set value to a null string --->
			<cfset chargeSetValue  = "null">
		<cfelse>
			<!--- If the chargeset value is anything but null set the chargesetvalue to that --->
			<cfset chargeSetValue  = TenantList.cChargeSet>
		</cfif>
		var tenantInfoArray = new Array(2);
		tenantInfoArray[0] = '#TenantList.iTenant_ID#';	//position 0 is the tenant id
		tenantInfoArray[1] = '#chargeSetValue#'; //position 1 is the chargeset
		tenantArray[#i#] = tenantInfoArray; //add the tennant info array to the tenant array
		<cfset i = i + 1>
		</cfoutput>
		
		//get the selected tenants chargeset by looping through the tenant array and comparing the selectedvalue
		//of the tenant drop down with the tenant id of the tenant array
		for(i = 0; i < tenantArray.length; i++)
		{
			if(tenantArray[i][0] == tenantId)
			{
				chargeType = tenantArray[i][1];
				break;
			}
		}
		return chargeType;
	}
	
	//this function will add options to the drop down based on the type chosen AND the charge set
	//of the tenant if the type is Resident Care
	function PopulateChargeDropDown()
	{
		var chargeDropDown = document.getElementsByName('iAptAddress_ID')[0];
		//select the default option of the drop down
		
		//first clear the contents of the drop down, since we are removing options do a reverse for loop
		for(i = chargeDropDown.length - 1; i >= 0; i-- )
		{
			chargeDropDown.remove(i);
		}
		
		//set a variable equal to the selected tenants charge set
		var chargeSet = GetChargeSetForTenant();
		//create a nwe option to add to the drop down list
		var newOption
		
		<cfoutput>
		//create a array to hold the charge set information
		var chargeSetArray = new Array(#Available.RecordCount#);
		</cfoutput>
		<!--- Loop through the charges query and create an multi-dimension array holding the chargeid and chargeset --->
		<cfset i = 0>
		<cfset chargeSetValue = "">
		<cfoutput query="Available">
		
		<cfif Available.cChargeSet eq "">
			<cfset chargeSetValue  = "null">
		<cfelse>
			<cfset chargeSetValue  = Available.cChargeSet>
		</cfif>
		<!--- Proj 26955 rschuette 2/13/2009 for Bond indications mamta start--->
			<cfif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq '' >
				<cfif Available.bIsBond eq 1>
					<cfset Bond = "(Bond)">
				<cfelse>
					<cfset Bond = "          ">
				</cfif>
				<cfif Available.bBondIncluded eq 1>
					<cfset Included = "(Included)">
				<cfelse>
					<cfset Included = "">
				</cfif>
			</cfif>
			<!--- end 26955 --->
		
			<cfif bondhouse.ibondhouse eq '' and bondhouse.bIsMedicaid eq 1>
				<cfif Available.bIsMedicaidEligible eq 1>
					<cfset Medicaid = "(Medicaid)">
				<cfelse>
					<cfset Medicaid = "          ">
				</cfif>
				
			</cfif>
			<cfif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq 1>
			    <cfif Available.bIsBond eq 1>
					<cfset Bond = "(Bond)">
				<cfelse>
					<cfset Bond = "          ">
				</cfif>
				<cfif Available.bBondIncluded eq 1>
					<cfset Included = "(Included)">
				<cfelse>
					<cfset Included = "">
				</cfif>
				<cfif Available.bIsMedicaidEligible eq 1>
					<cfset Medicaid = "(Medicaid)">
				<cfelse>
					<cfset Medicaid = "          ">
				</cfif>
				
			</cfif>
		chargeInfoArray = new Array();
		chargeInfoArray[0] = '#iAptAddress_ID#';	//chargeSetId
		chargeInfoArray[1] = '#chargeSetValue#'; //ChargeSetName
		<!--- Proj 26955 rschuette 2/13/2009 for Bond indications mamta added--->
		<cfif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq ''>
		chargeInfoArray[2] = '#trim(Available.cAptNumber)# - #trim(Available.cDescription)# #Bond# #Included#'; //ChargeSetName
		<cfelseif bondhouse.ibondhouse eq '' and bondhouse.bIsMedicaid eq 1>
		chargeInfoArray[2] = '#trim(Available.cAptNumber)# - #trim(Available.cDescription)# #Medicaid#'; //ChargeSetName
		<cfelseif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq 1>
		chargeInfoArray[2] = '#trim(Available.cAptNumber)# - #trim(Available.cDescription)# #Medicaid# #Bond# #Included#'; //ChargeSetName
		<cfelse> 	
		chargeInfoArray[2] = '#trim(Available.cAptNumber)# - #trim(Available.cDescription)#'; //ChargeSetName
		</cfif>
		//add the current charge to the chargesetarray
		chargeSetArray[#i#] = chargeInfoArray;
		<cfset i = i + 1>
		</cfoutput>
		
		for(i = 0; i < chargeSetArray.length; i++)
		{
			//make sure we are only adding the chargeset for the selected tenant
			if(chargeSetArray[i][1].toLowerCase() == chargeSet.toLowerCase())
			{
				newOption = document.createElement('option');
				newOption.text = chargeSetArray[i][2];
				newOption.value = chargeSetArray[i][0];
				chargeDropDown.options.add(newOption);
			}
		}
	}
</script>