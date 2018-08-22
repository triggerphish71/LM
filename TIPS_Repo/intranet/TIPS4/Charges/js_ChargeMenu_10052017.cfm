<!------------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                    |
|------------------------------------------------------------------------------------------------|
|  This is the main file for the application.                                                    |
|------------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                              |
|------------------------------------------------------------------------------------------------|
|  none                                                                                          |
|------------------------------------------------------------------------------------------------|
| INCLUDES                                                                                       |
|------------------------------------------------------------------------------------------------|
|   none                                                                                         |
|------------------------------------------------------------------------------------------------|
| HISTORY                                                                                        |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| ranklam    | 08/26/2005 | Created                                                              |
| ranklam    | 08/31/2005 | Changed the cfoutput code that added chargetypes and charges to the  |
|                         | javascript to replace ' with /' so single quotes done break the code |
| ranklam    | 09/06/2005 | Changed the script to display options for a alternate charge set, if |
|                         | no alternate chargeset is found, it will display options for 'null'. |
| ranklam    | 01/10/2006 | Changed the script to match chargeset in all lower case.             |
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
		var chargeDropDown = document.getElementsByName('icharge_id')[0];
		//select the default option of the drop down
		
		//first clear the contents of the drop down, since we are removing options do a reverse for loop
		for(i = chargeDropDown.length - 1; i >= 0; i-- )
		{
			chargeDropDown.remove(i);
		}
		
		//if the charge drop down is hidden, show it
		if(document.getElementsByName('charge')[0].style.visibility == 'hidden')
		{
			show('charge');
		}
		
		//create a variable to hold the tenants charge type
		var chargeType = document.getElementsByName('iChargeType_ID')[0].options[document.getElementsByName('iChargeType_ID')[0].selectedIndex].value;
		//used to determine if the charge type is 'private resident care', this should be fixed into something more dynamic
		var chargeTypeText = document.getElementsByName('iChargeType_ID')[0].options[document.getElementsByName('iChargeType_ID')[0].selectedIndex].text;
		//set a variable equal to the selected tenants charge set
		var chargeSet = GetChargeSetForTenant();
		//alert(chargeSet);
		//create a nwe option to add to the drop down list
		var newOption
		
		<cfoutput>
		//create a array to hold the charge set information
		var chargeSetArray = new Array(#Additional.RecordCount#);
		</cfoutput>
		<!--- Loop through the charges query and create an multi-dimension array holding the chargeid and chargeset --->
		<cfset i = 0>
		<cfset chargeSetValue = "">
		<cfoutput query="Additional">
		
		<cfif Additional.cChargeSet eq "">
			<cfset chargeSetValue  = "null">
		<cfelse>
			<cfset chargeSetValue  = Additional.cChargeSet>
		</cfif>
		
		chargeInfoArray = new Array();
		chargeInfoArray[0] = '#iCharge_ID#';	//chargeSetId
		chargeInfoArray[1] = '#Replace(chargeSetValue,"'","\'")#'; //ChargeSetName
		<cfif cSet eq "">
			chargeInfoArray[2] = '#Replace(cDescription,"'","\'")#'; //ChargeSetName
		<cfelse>
			chargeInfoArray[2] = '#Replace(cDescription,"'","\'")# (Set #cSet#)'; //ChargeSetName
		</cfif>
		chargeInfoArray[3] = '#iChargeType_ID#'; //ChargeTypeId
		//add the current charge to the chargesetarray
		chargeSetArray[#i#] = chargeInfoArray;
		<cfset i = i + 1>
		</cfoutput>
		
		//create a var to see if any charges were found
		var chargesFound = false;
				
		for(i = 0; i < chargeSetArray.length; i++)
		{
			//only show the charges for the currently selected charge
			if(chargeType == chargeSetArray[i][3])
			{
				//make sure we are only adding the chargeset for the selected tenant
				if(chargeSetArray[i][1].toLowerCase() == chargeSet.toLowerCase())
				{
					newOption = document.createElement('option');
					newOption.text = chargeSetArray[i][2];
					newOption.value = chargeSetArray[i][0];
					chargeDropDown.options.add(newOption);
					chargesFound = true;
				}
			}
		}
		
		//if no charges were found for the current chargeset and the chargeset is a custom chargeset, set
		//the chargeset to null and try to add options again
		if(!chargesFound && chargeSet != 'null')
		{
			chargeSet = 'null';
			
			for(i = 0; i < chargeSetArray.length; i++)
			{
				//only show the charges for the currently selected charge
				if(chargeType == chargeSetArray[i][3])
				{
					//make sure we are only adding the chargeset for the selected tenant
					//rsa - 1/10/06 - changed to lowercase
					if(chargeSetArray[i][1].toLowerCase() == chargeSet.toLowerCase())
					{
						newOption = document.createElement('option');
						newOption.text = chargeSetArray[i][2];
						newOption.value = chargeSetArray[i][0];
						chargeDropDown.options.add(newOption);
					}
				}
			}
		}
	}
</script>