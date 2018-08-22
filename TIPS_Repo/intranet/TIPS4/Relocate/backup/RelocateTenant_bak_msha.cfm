<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 09/21/2005 | Added the js_chargemenu include to only show rooms and rates for   |
|		     |            | the selected tenant's charge type.                                 |
| mlaw       | 01/04/2005 | Changed the cChargeset to lower case for the matching              | 
|            |            | lcase , toLowerCase()                                              |
| mlaw       | 02/28/2006 | Fix relocate drop down list                       	               |
| mlaw       | 03/01/2006 | Only AR Admin can change the Amount                                |
| Ssathya	 | 07/30/2008 | Made modification as per project 20125                             |
| Rschuette	 | 02/27/2009 | Finished all changes made for Project 26955 & Bond Designations    |
| SFarmer    | 04-07-2017 | Added Javascript check if room being moved to is the same as the   |
|            |            | current room to flag it and stop the change                        |
|sfarmer     | 05/08/2017 | prevent same room relocations                                      |
|mstriegel   | 11/13/2017 | Added bundled pricing logic                                        |
|MShah		 | 01/19/2018 | added logic on recurr javascript function						   |
----------------------------------------------------------------------------------------------->
<CFOUTPUT>
 <!---==============================================================================
Retrieve database TimeStamp
=============================================================================== --->
<cfparam name="currentroomID" default="">
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>
<!--- Project 20125 modification. 07/30/08 Ssathya added validation --->
<script language="JavaScript" type="text/javascript">
	function hardhaltvalidation(formCheck)
	{

	if(formCheck.bondval.value==1)
		{
			<!--- Proj 26955 2/17/2009 Commented out for replacement code below. --->
			<!--- var bondhouse = false;
			for(j=0;j<RelocateTenant.cBondHouseEligibleAfterRelocate.length;j++)
			{
				if(RelocateTenant.cBondHouseEligibleAfterRelocate[j].checked)
				{
					bondhouse = true;
				}
			}
			
			if(!bondhouse)
			{
				
				alert("Please select Bond House Eligibility");
				return false;
			} --->
				
<!--- Proj 26955 2-19-2009 Rschuette Bond Validations : Start of Javascript --->
	 		var tenantname = RelocateTenant.iTenant_ID.options[RelocateTenant.iTenant_ID.selectedIndex].text;
	 		if (tenantname == 'Choose Resident'){
	 			alert("Please select a resident.")
	 			return false;}
	 		
	 		
	 		var recert;
				for(j=0;j<RelocateTenant.cBondTenantEligibleAfterRelocate.length;j++)
				{
					if(RelocateTenant.cBondTenantEligibleAfterRelocate[j].checked)
					{var recert = true;
					
						if(RelocateTenant.cBondTenantEligibleAfterRelocate[j].value == 1)
						{var recert_value = true;
						}
						else
						{var recert_value = false;
						//alert(recert_value);
						}
					}
				}
					
					if(!recert){
						alert("Please indicate if the resident certified for bond status.");
						return false;
						}
		 	//DATE
		 		<!--- if ((RelocateTenant.txtBondReCertDate.indexOf("-"))>0){
		 			alert("Please enter a re-certification date that is valid, and not in the future. \n mm/dd/yyyy format please.");
					return false;
					} --->
				if (RelocateTenant.txtBondReCertDate.value == '' || RelocateTenant.txtBondReCertDate.value == '00/00/0000')// || Dash == true)
					{alert("Please enter a re-certification date that is valid, and not in the future. \n mm/dd/yyyy.");
					return false;
					}
					
				if(ValidBondDate(RelocateTenant.txtBondReCertDate.value) == false)
					{
						RelocateTenant.txtBondReCertDate.focus();
						alert("Please enter a re-certification date that is valid, and not in the future.");
						return false;
						}		
 		//ROOM 
 				var bondroom = RelocateTenant.iAptAddress_ID.options[RelocateTenant.iAptAddress_ID.selectedIndex].text;
					var bRoomisBond = false;
					var bRoomisBondIncluded = false;
				if((bondroom.indexOf("Bond")) > 0){
					bRoomisBond = true;
					}
				if((bondroom.indexOf("Included")) > 0){
					bRoomisBondIncluded = true;}
					
		//THE CHECK
			//only 2 really matter (recert,bRoomisBond or bRoomisBondIncluded)
			//if resident certifies as bond
				//then room selected must at least be bond inlcuded
			//if resident certifies as NOT bond - then room selected cannot be bond designated
				if(recert_value == false && bRoomisBond == true){
						alert("Tenant is marked as not being eligible as bond.\n \nPlease select a room that is not bond designated.");
						return false;}
				else if(recert_value == true && bRoomisBondIncluded == false){
						alert("Tenant is marked as being eligible as bond. \n \nThe room selected is not bond applicable. \n \nPlease select a bond included room.")
						return false;}
	
		//LAST
				var alertcount; 
					if(RelocateTenant.Percent < 20){
						if(alertcount!=1){
							alertcount==1;
							alert("Bond Apartment count is under the required amount. \n \nPlease select a non-bond room to make it bond if possible.");
							return false;
						}	
					}  
			
		 return true;
		}	
	}
	
function ValidBondDate(dtbond){
		if(isDate(dtbond)==false){
			return false;}
return true;
}
//also seen on MoveInForm 
function isDate(dtStr){
		var dtCh= "/";
		var minYear=2009;
		var year=new Date();
		var now=new Date();
		var maxYear=year.getYear();
		var daysInMonth = DaysArray(12)
		var pos1=dtStr.indexOf(dtCh)
		var pos2=dtStr.indexOf(dtCh,pos1+1)
		var strMonth=dtStr.substring(0,pos1)
		var strDay=dtStr.substring(pos1+1,pos2)
		var strYear=dtStr.substring(pos2+1)
		strYr=strYear
		
		if (strDay.charAt(0)=="0" && strDay.length>1) strDay=strDay.substring(1)
		if (strMonth.charAt(0)=="0" && strMonth.length>1) strMonth=strMonth.substring(1)
		for (var i = 1; i <= 3; i++) {
			if (strYr.charAt(0)=="0" && strYr.length>1) strYr=strYr.substring(1)
		}
		month=parseInt(strMonth)
		day=parseInt(strDay) 
		year=parseInt(strYr)
		if (pos1==-1 || pos2==-1){
			//alert("The date format should be : mm/dd/yyyy")
			return false;
		}
		if (strMonth.length<1 || month<1 || month>12){
			//alert("Please enter a valid month")
			return false;
		}
		
		if (strDay.length<1 || day<1 || day>31 ||(month==02 && day>daysInFebruary(year)) || day > daysInMonth[month]){// || 
			//alert("Please enter a valid day.")
			return false;
		}
		if (strYear.length != 4 || year==0 || year<minYear || year>maxYear){
			//alert("Please enter a valid 4 digit year. \n \n(ie "+maxYear+")")
			return false;
		}
		if (dtStr.indexOf(dtCh,pos2+1)!=-1 || isInteger(stripCharsInBag(dtStr, dtCh))==false){
			//alert("Please enter a valid date")
			return false;
		}
		if(strDay.length<2){strDay = 0 + strDay}
		if(strMonth.length<2){strMonth = 0 + strMonth}
		var RearrangedInput=strYear+strMonth+strDay
		RearrangedInput = parseFloat(RearrangedInput)
		var TodayDay = parseInt(now.getDate());
		TodayDay = TodayDay +'';
		if (TodayDay.length<2){TodayDay = 0 + TodayDay;}
		
		var TodayMonth = parseInt(now.getMonth());
		TodayMonth = (TodayMonth + 1)+'';
		if (TodayMonth.length<2){TodayMonth = 0 + TodayMonth;}
		
		var TodayYear = now.getFullYear();
		var TodayRearranged = (TodayYear + ''+ TodayMonth +''+ TodayDay)
		TodayRearranged = parseFloat(TodayRearranged);
		if (RearrangedInput>TodayRearranged){
			//alert("Please no future dates.")
			return false;
		}
	return true;
}
	function isInteger(s){
	var i;
    for (i = 0; i < s.length; i++){   
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

function stripCharsInBag(s, bag){
	var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){   
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}

function daysInFebruary (year){
	// February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
    return (((year % 4 == 0) && ( (!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28 );
}

function DaysArray(n) {
	for (var i = 1; i <= n; i++) {
		this[i] = 31
		if (i==4 || i==6 || i==9 || i==11) {this[i] = 30}
		if (i==2) {this[i] = 29}
   } 
   return this
}
<!--- End 26955 Javascript --->

</script>

<!--- ==============================================================================
Retrieve list of Available Apartments (less than 2 people in an Apartment
=============================================================================== --->
<!--- <CFQUERY NAME="Available" DATASOURCE="#APPLICATION.datasource#">
SELECT 	ad.iAptAddress_ID, ad.cAptNumber, ap.cDescription, c.cChargeSet,
	(select count(t.itenant_id)
	from tenantstate ts
	join tenant t on t.itenant_id = ts.itenant_id and ts.dtrowdeleted is null
	where t.dtrowdeleted is null and ts.iaptAddress_id = ad.iaptaddress_id and ts.itenantstatecode_id = 2) as occupancy
	,c.*
FROM APTADDRESS AD (NOLOCK)
join APTTYPE AP (NOLOCK) ON (AP.iAptType_ID = AD.iAptType_ID AND AP.dtRowDeleted IS NULL)
join charges c on c.iapttype_id = ap.iapttype_id and c.dtrowdeleted is null and getdate() between dteffectivestart and dteffectiveend
and c.ihouse_id = ad.ihouse_id and c.iresidencytype_id = 1
join chargetype ct on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null and ct.bisdaily is not null
WHERE AD.dtRowDeleted IS NULL AND ad.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
ORDER BY ad.cAptNumber
</CFQUERY> --->

<!--- MLAW 02/28/2006 fix relocate drop down list --->
<CFQUERY NAME="Available" DATASOURCE="#APPLICATION.datasource#">
	SELECT 	
		ad.iAptAddress_ID
		,ad.cAptNumber
		,ap.cDescription
		,c.cChargeSet
		,(select count(t.itenant_id)
			from tenantstate ts WITH (NOLOCK)
			join tenant t  WITH (NOLOCK)
			on t.itenant_id = ts.itenant_id 
			and ts.dtrowdeleted is null
			where t.dtrowdeleted is null 
			  and ts.iaptAddress_id = ad.iaptaddress_id 
			  and ts.itenantstatecode_id = 2) as occupancy
		,c.*
		<!--- Proj 26955 2/13/2009 rschuette Bond Indentifiers addaed Medicaid mamta --->
		,AD.bIsBond
		,AD.bBondIncluded
		,AD.bIsMedicaidEligible
		,isnull(AD.bIsMemoryCareEligible,0) as bIsMemoryCareEligible
		,AP.bIscompanionsuite
	FROM APTADDRESS AD WITH (NOLOCK)
	INNER JOIN APTTYPE AP WITH (NOLOCK)	ON (AP.iAptType_ID = AD.iAptType_ID AND AP.dtRowDeleted IS NULL)
	INNER JOIN houseproductline HP WITH (NOLOCK) on HP.ihouseproductline_ID = AD.ihouseproductline_ID	and HP.ihouse_ID = AD.ihouse_ID
	INNER JOIN charges c WITH (NOLOCK) 	on c.iapttype_id = ap.iapttype_id 	and c.iproductline_ID = HP.iproductline_ID	and c.dtrowdeleted is null 	and getdate() between dteffectivestart and dteffectiveend
	and c.ihouse_id = ad.ihouse_id 
	and c.iresidencytype_id = 1
	INNER join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null 
	<!---<cfif #session.cbillingtype# eq 'D'> <!---Mshah added the condition for Pinicon relocate resident-as billing type EQ M or monthly billing type--->
	and ct.bisdaily is not null
	</cfif>---->
	WHERE 
		AD.dtRowDeleted IS NULL 
	AND ad.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY ad.cAptNumber
</CFQUERY>

	<!---Mshah added here for winthrop houses--->

<cfquery name="WinthropAptdaily" dbtype="query">
	 select * from Available where ichargetype_ID in (89,1748)
</cfquery>

<cfquery name="WinthropAptMonthly" dbtype="query">
   select * from Available where ichargetype_ID in (1682,1748)
</cfquery>
	<!---
==============================================================================
Retrieve list of Tenants in a Moved In State
=============================================================================== --->
<!--- Project 26955 - RTS - 12/15/2008 Added T.bIsBond to query. Mamta added productline to query--->
<CFQUERY NAME="TenantList" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct  count(distinct IM.iInvoiceMaster_ID) as moveoutcount
			,T.iTenant_ID ,T.cLastName ,T.cFirstName ,T.cSolomonKey, TS.iresidencytype_id
			,T.cChargeSet, T.bIsBond,TS.iproductline_ID,t.cbillingtype,t.ihouse_ID,t.bIsOriginalTenant
			,ts.iaptaddress_id <!---mshah added--->
			<!--- mstriegel 11/21/17 add below --->
			,h.bIsBundledPricing,CASE WHEN (apt.cDescription Like '%studio%') THEN 'Yes' ELSE 'No' END as isStudio  
			<!--- end mstriegel 11/21/17 --->
	FROM	Tenant	T (NOLOCK)
	JOIN	TenantState	TS (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID
	LEFT JOIN InvoiceDetail INV (NOLOCK) ON (T.iTenant_ID = INV.iTenant_ID AND INV.dtRowDeleted IS NULL)
	LEFT JOIN InvoiceMaster IM (NOLOCK) ON (IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NOT NULL)
	<!--- mstriegel 11/21/17 added lines below --->
	INNER JOIN House h WITH (NOLOCK) ON t.iHouse_ID= h.iHouse_ID
	INNER JOIN AptAddress aa WITH (NOLOCK) on ts.iAptAddress_ID = aa.iAptAddress_ID 
	INNER JOIN AptType apt WITH (NOLOCK) ON aa.iAptType_ID = apt.iAptType_ID
	<!--- end mstriegel:11/21/17 --->
	WHERE T.dtRowDeleted IS NULL AND iTenantStateCode_ID = 2
	AND TS.dtMoveIN IS NOT NULL  AND t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	GROUP BY T.cLastName, T.iTenant_ID, T.cFirstName, T.cSolomonKey, TS.iresidencytype_id,T.cChargeSet,T.bIsBond,TS.iproductline_ID,t.cbillingtype,t.ihouse_ID,t.bIsOriginalTenant,ts.iaptaddress_id
		<!--- mstriegel:11/21/17 added below --->
			,h.bIsBundledPricing ,apt.cDescription
		<!---end: mstriegel --->
	ORDER BY T.cLastName, T.iTenant_ID, T.cFirstName, T.cSolomonKey, TS.iresidencytype_id,ts.iaptaddress_id
</CFQUERY>
	

	<!--- create valuelist of all iTenant_ID pulled from the tenantlist query  --->
	 
	<!--- <cfset MyTenantList = ValueList(Tenantlist.iTenant_ID)> --->
	 	
	 		
	<!--- Query table to get --->
	
	
	
	<!---
	
	
==============================================================================
Do Javascript that figures out the selected tenant's current room and rate
=============================================================================== --->


	<!--- ==============================================================================
	Retrieve house second tenant rate// mshah added three queries instead of one second rate
	=============================================================================== --->
			<CFQUERY NAME='qSecondRate' DATASOURCE='#APPLICATION.datasource#'>
				select *
				from charges c WITH (NOLOCK)
				join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null
					and bisrent is not null 
					<!---and bisdaily is not null --->
					and c.ioccupancyposition <> 1
					and c.ihouse_id = #SESSION.qSelectedHouse.ihouse_id#
				where c.dtrowdeleted is null
				and getdate() between c.dteffectivestart and c.dteffectiveend
				and c.ichargetype_ID = 89
			</CFQUERY>
		<!---<cfdump var="#qSecondRate#" label="qSecondRate">--->
					
		<CFQUERY NAME='qSecondRateALMonthly' DATASOURCE='#APPLICATION.datasource#'>
				select *
				from charges c WITH (NOLOCK)
				join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null
					and bisrent is not null 
					<!---and bisdaily is not null --->
					and c.ioccupancyposition <> 1
					and c.ihouse_id = #SESSION.qSelectedHouse.ihouse_id#
				where c.dtrowdeleted is null
				and getdate() between c.dteffectivestart and c.dteffectiveend
				and c.ichargetype_ID = 1682
			</CFQUERY>
					
	    
		
		 <CFQUERY NAME='qSecondRateMC' DATASOURCE='#APPLICATION.datasource#'>
			       select *
					from charges c WITH (NOLOCK)
					join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null
						and bisrent is not null 
						<!---and bisdaily is not null --->
						and c.ioccupancyposition <> 1
						and c.ihouse_id = #SESSION.qSelectedHouse.ihouse_id#
					where c.dtrowdeleted is null
					and getdate() between c.dteffectivestart and c.dteffectiveend
					and c.ichargetype_ID = 1748
				</CFQUERY>
		<!--- <cfdump var="#qSecondRateMC#" label="qSecondRateMC"> --->
				
			
			
			
	<!--- ==============================================================================
	Retrieve any rent recurring for this tenant
	=============================================================================== --->
	<CFQUERY NAME='qRecurring' DATASOURCE='#APPLICATION.datasource#'>
		select rc.irecurringcharge_id, rc.itenant_id, rc.cdescription, rc.mamount, c.cChargeSet,rc.icharge_id, c.ioccupancyposition
		from recurringcharge rc (NOLOCK)
		join tenant t (NOLOCK) on t.itenant_id = rc.itenant_id  and t.dtrowdeleted is null
		join tenantstate ts (NOLOCK) on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null and ts.itenantstatecode_id = 2
		join charges c (NOLOCK) on c.icharge_id = rc.icharge_id
		join chargetype ct (NOLOCK) on ct.ichargetype_id = c.ichargetype_id <cfif #session.qselectedhouse.cstatecode# neq 'WI'>and ct.bisrent is not null</cfif>
		where rc.dtrowdeleted is null
		and t.ihouse_id = #SESSION.qSelectedHouse.ihouse_id#
		and getdate() between rc.dteffectivestart and rc.dteffectiveend
	</CFQUERY>

	<!---- mstriegel:11/13/2017 query to get a list of all the apartments that are studios ---->
	<cfquery name="getStudioList" datasource="#application.datasource#">
		SELECT iAptAddress_ID
		FROM AptAddress ad  WITH (NOLOCK)
		INNER JOIN AptType apt  WITH (NOLOCK) on ad.iAptType_ID = apt.iAptType_ID
		INNER JOIN House h WITH (NOLOCK) on ad.iHouse_ID = h.iHouse_ID
		WHERE h.iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.qSelectedHouse.ihouse_id#">
		AND apt.cDescription like '%studio%'
	</cfquery>
	<!---  end mstriegel:11/13/2017 ---->

	<CFSET tenanteventhandler="onBlur='recurr(this,document.forms[0].iAptAddress_ID);'">
	<CFSET apteventhandler="onChange='recurr(document.forms[0].iTenant_ID,this);'">
		
<!--- MLAW 03/01/2006 - Only AR Admin can change the Amount --->
<!---To give the authority to EDs to edit the rate while oing transfers, commented line 416 to 421--->
	<!---<cfif ListFindNoCase(session.groupid, 240, ",") gt 0 or ListFindNoCase(session.groupid, 289, ",") gt 0>
		<!---added 289 to memory care house EDs Mamta--->
		<cfset read_only = "">
	<cfelse>
	    <cfset read_only = " readonly='true' ">
	</cfif>--->
	
	<SCRIPT>
		function recurr(obj,apt)
		{
			//set a variable equal to the selected tenants charge set
			var chargeSet = GetChargeSetForTenant();
			
			//mstriegel 11/21/17 added line below 
			window.goingtoApt = apt.value;
			//end mstriegel 11/21/17
		   
			//holds the residency type id
			res="";
			//holds the billingtype
			billing="";
			//holds the house number
			house="";
			productline="";
			originaltenant="";
			iaptID = "";
			occupancy = "";
			
			//mstriegel 11/21/17 added below 
			window.hasbundledPricing = "";
			window.bIsStudio = "";
			// end mstriegel 11/21/17
			
			<CFLOOP QUERY='Tenantlist'>
				<CFIF tenantlist.currentrow eq 1>
					if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
						billing= "#tenantlist.cbillingtype#";
						house=#tenantlist.ihouse_ID#;
						productline=#tenantlist.iproductline_ID#;
						originaltenant="#tenantlist.bIsOriginalTenant#";
						iaptID = "#tenantlist.iAptAddress_id#";
						//mstriegel 11/21/17						
						window.hasBundledPricing="#tenantList.bIsbundledPricing#";
						window.bIsStudio = "#tenantlist.isStudio#";
						//end mstriegel

					}
				<CFELSE>
					else if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
						billing= "#tenantlist.cbillingtype#";
						house=#tenantlist.ihouse_ID#;
						productline=#tenantlist.iproductline_ID#;
						originaltenant="#tenantlist.bIsOriginalTenant#";
						iaptID = "#tenantlist.iAptAddress_id#";
						//mstriegel 11/21/17 added below 						
						window.hasBundledPricing="#tenantList.bIsbundledPricing#";
						window.bIsStudio = "#tenantlist.IsStudio#";
						// end mstriegel 11/21/17
					}
				</CFIF>
			</CFLOOP>
			document.getElementById("icurrentroomID").value = iaptID;
			//this will hold the html for the reoccuring charge found for a tenant
			var z = '';
			//this will hold the html for the charge price for the room
			var c = '';
          //  alert (res);
          //  alert (billing);
          //  alert (house);
			//alert (apt.value);
			//alert (productline);
			//alert (originaltenant);
			//if there is no charge displayed hide the recurringcharge area
			if (obj.value == "")
			{ 
				document.all['recurringchange'].style.display="none";
				return false;
			}

			//clear the reoccuringcharge section html
			//alert('test')
			//document.forms[0].iAptNum.options.length=0;
			document.all['recurringchange'].innerHTML='';
			//clear apttype section
			//document.forms[0].iAptNum.value = '';
			//Mshah document.all['recurringchange'].innerHTML='';
			<!--- loop through the recurring charge query and show the matching charge on the page --->
			<CFLOOP QUERY='qRecurring'>
				<CFIF qRecurring.currentrow eq 1>
					if (obj.value == #qRecurring.itenant_id#)
					{  //alert('test2')
						document.all['recurringchange'].style.display="inline";
						z="<B> <U>Recurring Charge was found for:</U> <BR> #qRecurring.cdescription# at #LSCurrencyFormat(isBlank(qRecurring.mAmount,0))# </B> <BR>";
						z+="<INPUT TYPE=hidden NAME='irecurringcharge_id' VALUE='#qRecurring.irecurringcharge_id#'>";
					}
				<CFELSE>
					else if (obj.value == #qRecurring.itenant_id#)
					{   //alert('test2')
						document.all['recurringchange'].style.display="inline";
						z="<B> <U>Recurring Charge was found for:</U> <BR> #qRecurring.cdescription# at #LSCurrencyFormat(isBlank(qRecurring.mAmount,0))# </B> <BR>";
						z+="<INPUT TYPE=hidden NAME='irecurringcharge_id' VALUE='#qRecurring.irecurringcharge_id#'>";
					 }
				</CFIF>
			</CFLOOP>
		   //if residency selected is 2 then display same the recurring charges, Mamta
			if (res == 2){
				// alert ('#qRecurring.mAmount#');
				 // recurringcharge=#qRecurring.mAmount#;
			    //alert(recurringcharge);
				<CFLOOP QUERY='qRecurring'>
				<CFIF qRecurring.currentrow eq 1>
					if (obj.value == #qRecurring.itenant_id#)
					{
						document.all['recurringchange'].style.display="inline";
						 c="<B><I STYLE='color: red;'>Change to #qRecurring.cdescription# $ ";
				         c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qRecurring.mAmount,'999999.00-'))#' \
						    STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));'></I></B>"; <!---mshah removed read only--->
				        c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qRecurring.icharge_id#'>";
					}
				<CFELSE>
					else if (obj.value == #qRecurring.itenant_id#)
					{
					 c="<B><I STYLE='color: red;'>Change to #qRecurring.cdescription# $ ";
				         c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qRecurring.mAmount,'999999.00-'))#' \
						    STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));'></I></B>";<!---mshah removed read only--->
				        c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qRecurring.icharge_id#'>";
					 }
				</CFIF>
			    </CFLOOP>
			    }
				//mshah start  medicaid end, private start
				//buiding have mixed AL type, monthly and daily
			else if (house >= 247) //put the condition here for bigsprings which has monthly and daily AL charges <!--- loop though the avaliable charges query and diaplay the charge in the text box --->
			{
                <cfloop QUERY='Available'>
							
				
			   <CFIF Available.currentrow eq 1>
				if (apt.value == #Available.iAptAddress_ID#)
				{  
					occupancy =#Available.Occupancy#;
					iscompanion =#Available.bIsCompanionsuite#;
					//Mshah
					ismemorycare=#Available.BISMEMORYCAREELIGIBLE#;
					//alert(ismemorycare);
				    alert(occupancy);
				    //alert(iscompanion);
				}
			    <CFELSE>
				else if (apt.value == #Available.iAptAddress_ID#)
				{
				 occupancy =#Available.Occupancy#;
				 iscompanion =#Available.bIsCompanionsuite#;
				 ismemorycare = #Available.BISMEMORYCAREELIGIBLE#;
				// alert(ismemorycare);
				lert(occupancy);
				//alert(iscompanion);
				
				}
				</cfif>
			    </cfloop>
				
			   //alert('test');
			   //alert(occupancy);	
				
			// alert (billing);
            // alert (house);
			   if (occupancy == 0||iscompanion == 1 ){   //Mshah added here primary and companion
		             if (billing == 'M'){ //monthly primary or monthly companion
		            	  <CFLOOP QUERY='WinthropAptMonthly'>
							 <cfif cChargeSet eq "">
									<cfset currentChargeSet = "null">
									<cfelse>
										<cfset currentChargeSet = lcase(cChargeSet)>
									</cfif>
								//chargetype= "";
								
							
								 <CFIF WinthropAptMonthly.currentrow eq 1>
									if (apt.value == #isBlank(WinthropAptMonthly.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
										
									{
										document.all['recurringchange'].style.display="inline";
										c="<B><I STYLE='color: red;'>Change to #WinthropAptMonthly.cdescription# $ ";
										c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptMonthly.mAmount,'999999.00-'))#' \
											STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
										c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptMonthly.icharge_id#'>";
									}
								<CFELSE>
									else if (apt.value == #isBlank(WinthropAptMonthly.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
									{
										document.all['recurringchange'].style.display="inline";
										c="<B><I STYLE='color: red;'>Change to #WinthropAptMonthly.cdescription# $ ";
										c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptMonthly.mAmount,'999999.00-'))#' \
										STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
										c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptMonthly.icharge_id#'>";
									}
								</CFIF>
							</CFLOOP>
		            	 }
            	 
			             else if (billing == 'D'){ // daily primary or daily companion
			            	 //alert('test123');
			            	      <CFLOOP QUERY='WinthropAptDaily'>
					    			 <cfif cChargeSet eq "">
					    					<cfset currentChargeSet = "null">
					    					<cfelse>
					    						<cfset currentChargeSet = lcase(cChargeSet)>
					    					</cfif>
					    				//chargetype= "";
					    				
					    			
					    				 <CFIF WinthropAptMonthly.currentrow eq 1>
					    					if (apt.value == #isBlank(WinthropAptDaily.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
					    						
					    					{
					    						document.all['recurringchange'].style.display="inline";
					    						c="<B><I STYLE='color: red;'>Change to #WinthropAptDaily.cdescription# $ ";
					    						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptDaily.mAmount,'999999.00-'))#' \
					    							STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
					    						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptDaily.icharge_id#'>";
					    					}
					    				<CFELSE>
					    					else if (apt.value == #isBlank(WinthropAptDaily.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
					    					{
					    						document.all['recurringchange'].style.display="inline";
					    						c="<B><I STYLE='color: red;'>Change to #WinthropAptDaily.cdescription# $ ";
					    						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptDaily.mAmount,'999999.00-'))#' \
					    						STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' ></I></B>";<!---mshah removed read only--->
					    						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptDaily.icharge_id#'>";
					    					}
					    				</CFIF>
					    			</CFLOOP>
			            	     }
			              }// if occupancy 0 end
		             
			              else if (occupancy == 1 && iscompanion == 0 ){ //second resident AL daily or Monthly
							  //alert ('testsecond');
							  // alert (productline);
							   //alert (billing);
							    if (productline == 1 && ismemorycare == 0){ //Mshah added here relocation to Al room
							    	if (billing == 'D'){ 
										    <CFLOOP QUERY='qSecondRate'>
											<cfif cChargeSet eq "">
												<cfset currentChargeSet = "null">
											<cfelse>
												<cfset currentChargeSet = lcase(cChargeSet)>
											</cfif>
							
											<CFIF qSecondRate.currentrow eq 1>
												if (chargeSet.toLowerCase() == '#currentChargeSet#')
												{
												//	alert('test seond')//Mshah
													document.all['recurringchange'].style.display="inline";
													c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
													c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
														STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
													c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
												}
											<CFELSE>
												else if (chargeSet.toLowerCase() == '#currentChargeSet#')
												{   
												//	alert('test seond')//Mshah
													document.all['recurringchange'].style.display="inline";
													c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
													c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
													STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' ></I></B>"; <!---mshah removed read only--->
													c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
												}
											</CFIF>
										</CFLOOP>
							          } //if close
							    	else if (billing == 'M')
							    	{	
							    	 <CFLOOP QUERY='qSecondRateALMonthly'>
										<cfif cChargeSet eq "">
											<cfset currentChargeSet = "null">
										<cfelse>
											<cfset currentChargeSet = lcase(cChargeSet)>
										</cfif>
						
										<CFIF qSecondRateALMonthly.currentrow eq 1>
											if (chargeSet.toLowerCase() == '#currentChargeSet#')
											{
											//	alert('test seond')//Mshah
												document.all['recurringchange'].style.display="inline";
												c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
												c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
													STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
												c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
											}
										<CFELSE>
											else if (chargeSet.toLowerCase() == '#currentChargeSet#')
											{   //alert('test second')//Mshah
												document.all['recurringchange'].style.display="inline";
												c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
												c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
												STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
												c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
											}
										</CFIF>
									</CFLOOP>
							    	} // else if close
							    }//if end productline
							    else if ((productline == 1 && ismemorycare == 1) || productline == 2 ) //Second resident MC Mshah added here for AL to MC room
							    { 
							    	<CFLOOP QUERY='qSecondRateMC'>
									<cfif cChargeSet eq "">
										<cfset currentChargeSet = "null">
									<cfelse>
										<cfset currentChargeSet = lcase(cChargeSet)>
									</cfif>
					
									<CFIF qSecondRateMC.currentrow eq 1>
										if (chargeSet.toLowerCase() == '#currentChargeSet#')
										{   //alert('test second')//Mshah
											document.all['recurringchange'].style.display="inline";
											c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
											c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
												STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
											c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
										}
									<CFELSE>
										else if (chargeSet.toLowerCase() == '#currentChargeSet#')
										{  // alert('test second')//Mshah
											document.all['recurringchange'].style.display="inline";
											c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
											c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
											STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' ></I></B>";<!---mshah removed read only--->
											c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
										}
									</CFIF>
								</CFLOOP>
							    }// else if close
					  	            		 
		            	 }	 //else second resident end
		   			} 
					//mshah end house 247
			
		   else{ //if not original tenant
		    	<!---loop for occupancy veriable--->
		    	<cfloop QUERY='Available'>	
				
				<CFIF Available.currentrow eq 1>
				if (apt.value == #Available.iAptAddress_ID#)
				{  
					occupancy =#Available.Occupancy#;
					iscompanion =#Available.bIsCompanionsuite#;
					//Mshah
					ismemorycare = #Available.BISMEMORYCAREELIGIBLE#;
					//alert(ismemorycare);
				 //alert(occupancy);
				 //alert('test');
				 //alert(iscompanion);
										}
			    <CFELSE>
				else if (apt.value == #Available.iAptAddress_ID#)
				{// alert (apt.value);
				 occupancy =#Available.Occupancy#;
				 //alert('test');
				//alert(occupancy);
				iscompanion =#Available.bIsCompanionsuite#;
				//alert(iscompanion);
				//Mshah
				ismemorycare = #Available.bIsmemorycareeligible#;
					//alert(ismemorycare);
				}
				</cfif>
			    </cfloop>
			   // alert('test');
			   // alert(occupancy);
			   // alert (billing);
			    
			    if (occupancy == 0||occupancy == 1 && iscompanion == 1 )
			    {	//alert('test'); // not original daily or monthly tenant
						<!--- loop though the avaliable charges query and diaplay the charge in the text box --->
						<CFLOOP QUERY='Available'>
							<cfif cChargeSet eq "">
								<cfset currentChargeSet = "null">
							<cfelse>
								<cfset currentChargeSet = lcase(cChargeSet)>
							</cfif>
		
							<CFIF Available.currentrow eq 1>
								if (apt.value == #isBlank(Available.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
								{
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #Available.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(Available.mAmount,'999999.00-'))#' \
										STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#Available.icharge_id#'>";
								}
							<CFELSE>
								else if (apt.value == #isBlank(Available.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
								{
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #Available.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(Available.mAmount,'999999.00-'))#' \
									STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' ></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#Available.icharge_id#'>";
								}
							</CFIF>
						</CFLOOP>
					
				             else
						     {
							  document.all['recurringchange'].style.display="none";
						       }//end here if apt.value
								
			     }//if ends occupancy 0
			    
			    else if (occupancy == 1 && iscompanion == 0 ){ //not original second 
					   // alert ('testsecond');
					   // alert (productline);
					  // alert (billing);
					    
					    if (productline == 1 && ismemorycare== 0){ //AL second  // AL relocate to AL second resident
					    	if (billing == 'D' ){
								    <CFLOOP QUERY='qSecondRate'>
									<cfif cChargeSet eq "">
										<cfset currentChargeSet = "null">
									<cfelse>
										<cfset currentChargeSet = lcase(cChargeSet)>
									</cfif>
					
									<CFIF qSecondRate.currentrow eq 1>
										if (chargeSet.toLowerCase() == '#currentChargeSet#')
										{
											document.all['recurringchange'].style.display="inline";
											c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
											c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
												STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
											c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
										}
									<CFELSE>
										else if (chargeSet.toLowerCase() == '#currentChargeSet#')
										{
											document.all['recurringchange'].style.display="inline";
											c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
											c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
											STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
											c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
										}
									</CFIF>
								</CFLOOP>
					          } //if close
							else if (billing == 'M')//Al monthly second
					    	{	
					    	 <CFLOOP QUERY='qSecondRateALMonthly'>
								<cfif cChargeSet eq "">
									<cfset currentChargeSet = "null">
								<cfelse>
									<cfset currentChargeSet = lcase(cChargeSet)>
								</cfif>
				
								<CFIF qSecondRateALMonthly.currentrow eq 1>
									if (chargeSet.toLowerCase() == '#currentChargeSet#')
									{
										document.all['recurringchange'].style.display="inline";
										c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
										c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
											STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
										c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
									}
								<CFELSE>
									else if (chargeSet.toLowerCase() == '#currentChargeSet#')
									{
										document.all['recurringchange'].style.display="inline";
										c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
										c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
										STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' ></I></B>";<!---mshah removed read only--->
										c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
									}
								</CFIF>
							</CFLOOP>
					    	} // else if close
					    }//if end productline
					    else if (productline == 2 || (productline == 1 && ismemorycare ==1)) //MC second //MShah added for AL daily relocate to MC second
					    {
					    	<CFLOOP QUERY='qSecondRateMC'>
							<cfif cChargeSet eq "">
								<cfset currentChargeSet = "null">
							<cfelse>
								<cfset currentChargeSet = lcase(cChargeSet)>
							</cfif>
			
							<CFIF qSecondRateMC.currentrow eq 1>
								if (chargeSet.toLowerCase() == '#currentChargeSet#')
								{
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
										STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' ></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
								}
							<CFELSE>
								else if (chargeSet.toLowerCase() == '#currentChargeSet#')
								{
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
									STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' ></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
								}
							</CFIF>
						</CFLOOP>
					    }// else if close
			    	
			    
			    } //else if close

				document.all['recurringchange'].innerHTML=z+c;
			}
			document.all['recurringchange'].innerHTML=z+c;
			}
	</SCRIPT>
 
	<!---Mshah new function for secong resident--->
	<Script>
	function 
	/*<cfloop QUERY='Available'>	
		<CFIF Available.currentrow eq 1>
		if (apt.value == #Available.iAptAddress_ID#)
		{ // alert ('test');
			occupancy =#Available.Occupancy#;
			iscompanion =#Available.bIsCompanionsuite#;
		 // alert(occupancy);
		  // alert(iscompanion);
								}
	    <CFELSE>
		else if (apt.value == #Available.iAptAddress_ID#)
		{
		 occupancy =#Available.Occupancy#;
		//alert(occupancy);
		iscompanion =#Available.bIsCompanionsuite#;
		//alert(iscompanion);
		}
		</cfif>
    </cfloop>*/
	
	
	</Script>
	<CFSCRIPT>
		if (session.cbillingtype eq 'd') { dailyfilter="is not null"; }
		else { dailyfilter="is null"; }
	</CFSCRIPT>
	<CFQUERY NAME="qRoomAndBoard" DATASOURCE="#APPLICATION.datasource#">
		select c.icharge_id, c.cdescription, c.mAmount, c.iresidencytype_id,
			isNull(c.isleveltype_id,0) as isleveltype_id, c.iOccupancyPosition
		from charges c WITH (NOLOCK)
		inner join chargetype ct WITH (NOLOCK) on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null
		where c.dtrowdeleted is null
		and c.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		and ct.bisrent is not null and ct.bSLevelType_ID is null and ct.bisdaily #dailyfilter#
		and getdate() between c.dteffectivestart and c.dteffectiveend
	</CFQUERY>

	<!--- 07/30/08 ssathya to check if this house is a bond house for project 20125.. --->
	 <cfquery name="bondhouse" datasource="#application.datasource#">
		select * from house WITH (NOLOCK)  where ihouse_id =  #session.qSelectedHouse.iHouse_ID#
    </cfquery>
	<cfif NOT isNumeric(bondhouse.iBondHouse)>
    <cfset bondhouse.iBondHouse = 0>
    </cfif>
	<!--- <CFSCRIPT>tenanteventhandler=""; apteventhandler="";</CFSCRIPT> --->
<!--- include the new javascript to show only the correct charge sets --->
<cfinclude template="js_ChargeMenu.cfm">

<!--- Include intranet header --->
<CFINCLUDE TEMPLATE="../../header.cfm">


<!--- =============================================================================================
JavaScript to hold the residency type of selected user
============================================================================================= --->
<script> 
function selectedtenantresidencytype()
		{
			//alert(test);
			/*var chargeSet = GetChargeSetForTenant();

			//holds the residency type id
			//res="";
			res="";
			<CFLOOP QUERY='Tenantlist'>
				<CFIF tenantlist.currentrow eq 1>
					if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
					}
				<CFELSE>
					else if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
					}
				</CFIF>
			</CFLOOP>
			alert (res);*/
			}
</script>

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>
	function redirect() { window.location = "../mainmenu.cfm"; }
	function moveoutinvoicecheck(obj) {
		tenantids = new Array(#ValueList(TenantList.iTenant_ID)#);
		moveoutcountpertenant = new Array(#ValueList(TenantList.moveoutcount)#);
		for (i=0;i<=(tenantids.length-1);i++){
			if ((obj.value == tenantids[i]) && (moveoutcountpertenant[i] > 0)){
				document.forms[0].save.style.visibility='hidden';
				alert('A move out invoice for this resident has been found. \
						\rYou may not relocate residents that are in the process of moving out. \
						\rPlease go to the move out process and indicate that this resident is not moving out before relocating this resident.');
				break;
			}
			else {document.forms[0].save.style.visibility='visible';}
		}
	}
</SCRIPT>

<SCRIPT>
		function Selectedtenantmedicaid(obj)
		 {
						//alert('test');
				document.forms[0].iAptNum.options.length=0;
				<CFLOOP QUERY='Tenantlist'>
				<CFIF tenantlist.currentrow eq 1>
					if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
						productline=#tenantlist.iproductline_ID#;
						iaptID = "#tenantlist.iAptAddress_id#";						
					}
				<CFELSE>
					else if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
						productline=#tenantlist.iproductline_ID#;
						iaptID = "#tenantlist.iAptAddress_id#";						
					}
				</CFIF>
			   </CFLOOP>
				//alert(res);
				//alert(productline);
				if (productline==1)
				{
					if (res==2)
						{
									//alert('thisismedicaid');
							for (var i = 0; i < document.forms[0].iAptNum2.options.length; i++)
						  {         
							//alert(i);
						document.forms[0].iAptNum.options[i] = new Option(document.forms[0].iAptNum2.options[i].text, document.forms[0].iAptNum2.options[i].value);
						
					     }
						  }
				    else{
							
						for (var j = 0; j < document.forms[0].iAptNum3.options.length; j++)
						{   //alert (j);
						document.forms[0].iAptNum.options[j] = new Option(document.forms[0].iAptNum3.options[j].text,document.forms[0].iAptNum3.options[j].value);
						}
				    }	
			   }   
				else {
						//alert('this is memorycare');
						for (var i = 0; i < document.forms[0].iAptNum4.options.length; i++)
					  {         
						//alert(i);
					document.forms[0].iAptNum.options[i] = new Option(document.forms[0].iAptNum4.options[i].text, document.forms[0].iAptNum4.options[i].value);
					
				     }
					
				}     
					
		}
</script>
<!----
<script>
 function test(obj)
 { alert('test')}
</script>
---->
<!---<script>
function DisableMedicaidMove(obj)
			 {
						alert('test');
				//document.forms[0].iAptNum.options.length=0;
				<CFLOOP QUERY='Tenantlist'>
				<CFIF tenantlist.currentrow eq 1>
					if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
					}
				<CFELSE>
					else if (obj.value == #tenantlist.itenant_id#)
					{
						res=#tenantlist.iresidencytype_id#;
					}
				</CFIF>
			   </CFLOOP>
				alert(res);
				if (res == 2){
				alert(res);	
				document.forms[0].save.style.visibility='hidden';
				alert('test');
				//break;
			}
			else
			alert('testfail');
			// {document.forms[0].save.style.visibility='visible';}*/
		}
</Script>--->
<!--- Include Shared JavaScript --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<!--- Page Title --->
<TITLE> TIPS 4 - Relocate Resident </TITLE>

<!--- Display the page Header. --->
<!---<H1 CLASS="PageTitle"> Tips 4 - Relocate Resident </H1>--->
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

<!--- Include House Header --->
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<!--- Project 20125 modification. 07/30/2008 Ssathya made modifications so that the form has a name and the bond question. --->
<CFFORM Name="RelocateTenant" ACTION="RelocateUpdate.cfm" METHOD="POST">
<TABLE>
<input  type="hidden" name="currentroomID" id="icurrentroomID" value="" />
	<TR><TH COLSPAN="4">Relocate Resident	</TH></TR>
	<TR>
		<TD>Please select the resident that you would like to Relocate.</TD>
		<TD COLSPAN=2></TD>
		<TD>
			<!--- Project 26955 - RTS - 12/15/2008 - Adjusted option display to show bond resident designations.moveoutinvoicecheck(this);PopulateChargeDropDown();--->
			<SELECT NAME="iTenant_ID" onChange="moveoutinvoicecheck(this);PopulateChargeDropDown();Selectedtenantmedicaid(this);" #tenanteventhandler# id="Ten1">
				<OPTION VALUE="">Choose Resident</OPTION>
				<CFLOOP QUERY="TenantList">
					<cfscript>
						if (TenantList.bIsBond EQ 1){ Note = '(Bond)';} else{ Note=''; }
					</cfscript>
					<!---Mamta added medicaid residency type--->
					<cfscript>
						if (TenantList.iresidencytype_id EQ 2){ Note1 = '(Medicaid)';} else{ Note1=''; }
					</cfscript>
						<!---Mamta added Memory Care residency type--->
					<cfscript>
						if (TenantList.iproductline_id EQ 2){ Note2 = '(Memory Care)';} else{ Note2=''; }
					</cfscript>
					<OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstName# (#TenantList.cSolomonKey#) #NOTE# #Note1# #Note2#</OPTION>
				</CFLOOP>
			</SELECT>
		</TD>
	</TR>
	<!---Project 20125 modification. 07/30/08 ssathya added the bond house question . --->

	 <input type="hidden" name="bondval" value="#bondhouse.ibondhouse#"> 
	 <cfif bondhouse.ibondhouse eq 1> 	   
	 <!--- <tr>  <!--- Commented out for replacement questions below from 26955 --->
		
		<td colspan="4" style="Font-weight: bold;">Has the appropriate income certification form been completed to RE-qualify the resident as eligible for the purpose of meeting the bond program occupancy requirements when the resident was relocated?
			 Yes<input type="radio" name="cBondHouseEligibleAfterRelocate" value="1"> 
			 No<input type="radio" name="cBondHouseEligibleAfterRelocate" value="0" >
				
		</td>
	</tr>  --->
	<!--- Project 26955 - RTS - 12/16/2008 - Adjusted option display to show bond resident designations. --->
	 <tr>
		 <!--- <input type="hidden" name="cBondTenantEligibleAfterRelocate" value="">  --->
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
	 	<!---  End 26955 //Mamta added apttype in Houseapts--->
	</cfif>
	<cfquery name="HouseApts" datasource="#APPLICATION.datasource#">
			select aa.iaptaddress_id,aa.cAptNumber,aa.bisbond,aa.bbondincluded,aa.bIsMedicaidEligible,at.cdescription
			from aptaddress aa WITH (NOLOCK)
			inner join apttype at WITH (NOLOCK) on aa.iapttype_ID= at.iapttype_ID
			where aa.ihouse_id = #session.qSelectedHouse.iHouse_ID#
			and aa .dtrowdeleted is null and at.dtrowdeleted is null
			order by aa.cAptNumber			
	</cfquery>
	<!--- Project 26955 1/14/2009 RTS : For new apt drop down.--->
<!---<cfdump var="#HouseApts#"> testing--->
<cfif bondhouse.ibondhouse eq 1> 
		
		<!--- All apartments currently designated as bond --->
			 <cfquery name="HouseAptBond" datasource="#APPLICATION.datasource#">
				select AA.iAptAddress_ID 
				from AptAddress AA WITH (NOLOCK)
				where AA.bIsBond = 1
				and AA.dtrowdeleted is null
				and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			</cfquery>
			<cfset bondaptids = valuelist(HouseAptBond.iAptAddress_ID)>
			<!--- All apartments currently designated as bond included--->
			 <cfquery name="HouseAptBondIncluded" datasource="#APPLICATION.datasource#">
				select AA.iAptAddress_ID 
				from AptAddress AA WITH (NOLOCK)
				where AA.bBondIncluded = 1
				and AA.dtrowdeleted is null
				and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			</cfquery>
			<cfset bondincludedaptids= valuelist(HouseAptBondIncluded.iAptAddress_ID)>
	<!--- end 26955 --->
	<!--- Project 26955 1/8/2009 - Display of bond percentage for house --->
		
			<!--- Count of current bond designated apts --->
			<cfquery name="bAptCount" datasource="#APPLICATION.datasource#">
				select count(AA.iAptAddress_ID) as B 
				from AptAddress AA WITH (NOLOCK)
				where AA.bIsBond = 1
				and AA.dtrowdeleted is null
				and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
			</cfquery>
			<!--- Count of apts that were built and apply to the bond designation --->
			<cfquery name="AptCountTot" datasource="#APPLICATION.datasource#">
				select count(AA.iAptAddress_ID) as T 
				from AptAddress AA WITH (NOLOCK)
				where AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and AA.bBondIncluded = 1
				and AA.dtrowdeleted is null
			</cfquery>
			<!--- Apartment addresses that are occupied and pertain to bond applicable --->
			<cfquery name="Occupied" datasource="#APPLICATION.datasource#">
				select distinct TS.iAptAddress_ID
				from TIPS4.dbo.AptAddress aa, TIPS4.dbo.tenant te, TIPS4.dbo.TenantState TS (NOLOCK) 
				join TIPS4.dbo.Tenant T on (T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null)
				join TIPS4.dbo.AptAddress AD on (AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null)
				where TS.dtRowDeleted is null
				and TS.iTenantStateCode_ID = 2
				and AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and TS.iAptAddress_ID = aa.iAptAddress_ID 
				and te.iTenant_ID = ts.iTenant_ID
				and aa.bBondIncluded = 1
			</cfquery>
			<cfset OccupiedRowCount = (Occupied.recordcount)>
	</cfif>	
	<!---mamta added to count percent and display medicaid
<cfoutput> bIsMedicaid #bondhouse.bIsMedicaid# </cfoutput>--->
<cfif bondhouse.bIsMedicaid eq 1>
              <!--- Apartment List of apartments set as Medicaid ---> 
				<cfquery name="MedicaidAptList" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsMedicaidEligible = 1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset MedicaidApartmentList = ValueList(MedicaidAptList.iAptAddress_ID)>
				<!--- Apartment List of apartments set as Medicaid and bond--->
				<cfquery name="MedicaidbondApt" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsMedicaidEligible = 1
					and aa.bIsbond=1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset MedicaidbondAptList= ValueList(MedicaidbondApt.iAptAddress_ID)>
				<!--- Apartment List of apartments set as Medicaid and bond incuded--->
				<cfquery name="MedicaidbondincludedApt" datasource="#APPLICATION.datasource#">
					select aa.*,at1.* 
					from AptAddress aa WITH (NOLOCK)
					join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
					where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and aa.bIsMedicaidEligible = 1
					and aa.bbondIncluded=1
					and aa.dtRowDeleted is null
				</cfquery>
				<cfset MedicaidbondIncludedAptList= ValueList(MedicaidbondincludedApt.iAptAddress_ID)>
			<!---<cfoutput> #MedicaidApartmentList#, MedicaidbondAptList #MedicaidbondAptList#,MedicaidbondIncludedAptList#MedicaidbondIncludedAptList#</cfoutput>
				 Count of current Medicaid designated apts--->
				<cfquery name="MedicaidAptCount" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as TotalMedicaidApt 
					from AptAddress AA WITH (NOLOCK)
					where AA.bIsMedicaidEligible = 1
					and AA.dtrowdeleted is null
					and AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<!--- Count of total apts --->
				<cfquery name="AptCountTotal" datasource="#APPLICATION.datasource#">
					select count(AA.iAptAddress_ID) as T 
					from AptAddress AA WITH (NOLOCK)
					where AA.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
					and AA.dtrowdeleted is null
				</cfquery>
				<!---Occupied medicaids rooms--->
				<cfquery name="OccupiedMedicaidApt" datasource="#APPLICATION.datasource#">
					select distinct TS.iAptAddress_ID 
					from TenantState TS WITH (NOLOCK)
					join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
					join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID and AD.dtRowDeleted is null
					where TS.dtRowDeleted is null 
					and	TS.iTenantStateCode_ID = 2
					and AD.Bismedicaideligible=1
					and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				</cfquery>
				<cfset OccupiedMedicaidAptList=ValueList(OccupiedMedicaidAPt.iAptAddress_ID)>
</cfif>
<!---Mamta testing



<cfoutput> #MedicaidApartmentList# and ##</cfoutput>--->
			<!---added for the memory care apt list//mamta--->	
				
		<cfquery name="MemCareAptList" datasource="#APPLICATION.datasource#">
				select aa.*,at1.* 
				from AptAddress aa WITH (NOLOCK)
				join apttype at1 WITH (NOLOCK) on at1.iAptType_ID = aa.iAptType_ID and at1.dtrowdeleted is null
				where aa.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
				and aa.bIsmemorycareeligible = 1
				and aa.dtRowDeleted is null	
		</cfquery>
		<cfset MemoryCareApartmentList = ValueList(MemcareAptList.iAptAddress_ID)>
		<!---Occupied medicaids rooms--->
		<cfquery name="OccupiedMemcareApt" datasource="#APPLICATION.datasource#">
				select distinct TS.iAptAddress_ID 
				from TenantState TS WITH (NOLOCK)
				join Tenant T WITH (NOLOCK) on T.iTenant_ID = TS.iTenant_ID and T.dtRowDeleted is null
				join AptAddress AD WITH (NOLOCK) on AD.iAptAddress_ID = TS.iAptAddress_ID 
				and AD.dtRowDeleted is null
				where TS.dtRowDeleted is null 
				and	TS.iTenantStateCode_ID = 2
				and AD.bIsMemoryCareEligible=1
		    	and	AD.iHouse_ID = #session.qSelectedHouse.iHouse_ID#
		</cfquery>
		<cfset OccupiedMemcareAptList=ValueList(OccupiedMemcareApt.iAptAddress_ID)>
	<TR>
		<TD>Relocate resident to Room: </TD> <TD COLSPAN=2></TD>
		<TD>
		<select name="iAptAddress_ID" ID="iAptNum" width="3.5in" #apteventhandler#>
		   <option value=""> Select... </option>
		</select>
		
		<select name="iAptAddress_ID2" ID="iAptNum2" style="visibility: hidden" width="3.5in" #apteventhandler#>
			
			<cfif bondhouse.iBondHouse eq 0 and bondhouse.bIsMedicaid eq 1>
				<cfloop query="MedicaidAptList">
						    <option value= "#MedicaidAptList.iAptAddress_ID#">
					     	#MedicaidAptList.cAptNumber#- #MedicaidAptList.cDescription# &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp Medicaid
						    </option>	
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
					        <option value= "#MedicaidAptList.iAptAddress_ID#">
						         #MedicaidAptList.cAptNumber#- #MedicaidAptList.cDescription# Medicaid #Note1# #Note2#
						    </option>	
				  </cfloop>	
			</cfif>     
		</SELECT> 
	<!--- <cfoutput>#bondhouse.ibondhouse#bondhouse.bIsMedicaid #bondhouse.bIsMedicaid#</cfoutput>--->
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
			         <option value= "#HouseApts.iAptAddress_ID#" >
						   #HouseApts.cAptNumber#- #HouseApts.cDescription#  #Note3# #Note4#
				     </option>	
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
							  <option value= "#HouseApts.iAptAddress_ID#" >
						        #HouseApts.cAptNumber#-#HouseApts.cDescription# #NOTE3##NOTE1##NOTE2##Note4#
						       </option>
				   </cfloop>
			</cfif>
			<cfif bondhouse.ibondhouse eq 0 and bondhouse.bIsMedicaid eq "">
			<!---<option value=""> Select addi.......</option>TPecku added this --->
			   <cfloop query="HouseApts" >
				   <cfscript>
					if (ListFindNoCase(MemoryCareApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note4 = '(Memory Care) ';} else{ Note4=''; }
					</cfscript>
				  <option value= "#HouseApts.iAptAddress_ID#" >
				   #HouseApts.cAptNumber#- #HouseApts.cDescription#  #Note4#
				  </option>	
			   </cfloop>	
			</cfif>
	    </SELECT> 
	    <SELECT name="iAptAddress_ID4" ID="iAptNum4" style="visibility: hidden" width="3.5in" #apteventhandler#>
		    <CFLOOP QUERY='MemCareAptList'>	
			<cfscript>
			   Note = '(Memory Care)';
			 	    if (IsDefined("TenantInfo.iAptAddress_ID") 
					and  TenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#
						OR (IsDefined("qSecondTenantInfo.iAptAddress_ID") 
						and qSecondTenantInfo.iAptAddress_ID eq #Available.iAptAddress_ID#)) {
						Selected = 'Selected'; }
					else { Selected = ''; }
			  
			</cfscript>	
			<option value= "#MemCareAptList.iAptAddress_ID#">
				 #MemCareAptList.cAptNumber# - #MemCareAptList.cDescription#    #Note# 
			 </option>
		</CFLOOP>
	    </SELECT>
			<!---<cfoutput>#MemoryCareApartmentList#HouseApts.iAptAddress_ID #HouseApts.iAptAddress_ID# </cfoutput>--->
			<!--- new creation for the above, show apts and bond desigs --->
			<!--- Proj 26955 RTS 1/27/2008 added if/script for bond labels --->
			<!---Mamta testing	  
			<SELECT NAME="iAptAddress_ID" #apteventhandler# width="3.5in">
				<option value="">Select ...</option>
					<cfif bondhouse.ibondhouse eq 1 and bondhouse.bIsMedicaid eq "">
						<cfloop query="HouseApts">
							<cfscript>
								if (ListFindNocase(bondaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note1 = '(Bond) ';} else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
								if (ListFindNocase(bondincludedaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note2 = ' (Included)';} else{ Note2=''; }
							</cfscript>
						
						<option value="#HouseApts.iaptaddress_id#" > #HouseApts.cAptNumber#  #Note1##Note2#  </option>
					    </cfloop>
					
					<cfelseif bondhouse.iBondHouse eq "" and bondhouse.bIsMedicaid eq 1>
					     <cfif tenantlist.iResidencyType_ID is 2>
					      <cfloop query="MedicaidAptList">
						    <option value= "#MedicaidAptList.iAptAddress_ID#" #Selected#>
					     	#MedicaidAptList.cAptNumber# -  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp Medicaid
						  </option>	
					     </cfloop>
					    <cfelse>
						   <cfloop query="HouseApts">
					     <cfscript>
							if (ListFindNoCase(MedicaidApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';} 
							else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
						 </cfscript>
						  <option value= "#HouseApts.iAptAddress_ID#" >
						   #HouseApts.cAptNumber# -  #Note3#
						   </option>	
					       </cfloop>
					 	</cfif>  
						   
				   <cfelseif bondhouse.iBondHouse eq 1 and bondhouse.bIsMedicaid eq 1>
				          <cfif tenantlist.iResidencyType_ID is 2>
					        <cfloop query="MedicaidAptList">
								<cfscript>
							     if (ListFindNoCase(MedicaidbondAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note1 = '(Bond) ';} 
							     else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
							     if (ListFindNoCase(MedicaidbondIncludedAptList,MedicaidAptList.iAptAddress_ID,",") GT 0){Note2 = '(Included)';} 
							     else{ Note2=''; } 
								</cfscript>			 
					             <option value= "#MedicaidAptList.iAptAddress_ID#">
						         #MedicaidAptList.cAptNumber# - #Note# Medicaid #Note1# #Note2#
						         </option>	
					        </cfloop>
						   <cfelse>
						     <cfloop query="HouseApts">
							  <cfscript>
							    if (ListFindNoCase(MedicaidApartmentList,HouseApts.iAptAddress_ID,",") GT 0){Note3 = '(Medicaid) ';} 
								else{ Note3='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
								if (ListFindNocase(bondaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note1 = '(Bond) ';} 
								else{ Note1='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; }
								if (ListFindNocase(bondincludedaptids,HouseApts.iAptAddress_ID,",") GT 0){ Note2 = ' (Included)';} 
								else{ Note2=''; }
							   </cfscript>
							  <option value= "#HouseApts.iAptAddress_ID#" >
						        #HouseApts.cAptNumber# - #NOTE3##NOTE1##NOTE2#
						       </option>
							   </cfloop>
							 </cfif>
				     <cfelse>
					        <cfloop query="HouseApts">  
					           <option value="#HouseApts.iaptaddress_id#" > #HouseApts.cAptNumber#</option>	
				            </cfloop>
					</cfif> 
						
					
			</SELECT>
		
		</TR><TR><td></td>
		<TD COLSPAN=2></TD>
		<TD>--->

		<cfif bondhouse.ibondhouse eq 1>
			
				<cfif bondhouse.bBondHouseType eq '1'><!--- Percent by total units --->
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
				
		
		 </cfif> <!--- End 26955 block --->
		 </TD>
		<TR><td></td>
		<TD COLSPAN=2></TD>
		<TD>

		  <cfif bondhouse.bIsMedicaid eq '1'><!--- Percent by total Medicaid units added mamta--->
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
		<TD> <script>
				function effectivevalidate(){
					today = new Date(#Year(TimeStamp)#,#Evaluate(Month(TimeStamp)-1)#,#Day(TimeStamp)#);
					effday = document.forms[0].Day.value;
					effmonth = document.forms[0].Month.value -1;
					effyear = document.forms[0].Year.value;
					effdate = new Date(effyear,effmonth,effday);
						<CFIF remote_addr eq '10.1.0.211'>
						today= new Date();
    					difference = effdate.getTime() - today.getTime();
				    	daysDifference = Math.floor(difference/1000/60/60/24) + 1;
						alert(daysDifference);
					</CFIF>
					if (effdate > today){
						alert('Relocations may not be entered for future dates..');
						document.forms[0].Month.value = #Month(TimeStamp)#; document.forms[0].Day.value = #Day(TimeStamp)#; document.forms[0].Day.value = #Day(TimeStamp)#;document.forms[0].Year.value = "";
						//Mshah
						return false;
					}
				}
					
				function backvalidate(){
					today = new Date(#Year(TimeStamp)#,#Evaluate(Month(TimeStamp)-1)#,#Day(TimeStamp)#);
					effday = document.forms[0].Day.value;
					//Mshah
						datedifference = today.getTime() - effdate.getTime();
				    	actualDiff = Math.floor(datedifference/1000/60/60/24) + 1;
						//alert(actualDiff);
				
					if (actualDiff > 60){
						alert('Relocations may not be entered more than 60 days back..');
						document.forms[0].Month.value = #Month(TimeStamp)#; document.forms[0].Day.value = #Day(TimeStamp)#;document.forms[0].Year.value = "";
						return false;
					}
				}	
				
			</script>
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
			<!---Mshah start--->
			<select NAME='Year'STYLE='text-align: center;' MAXLENGTH=4 onKeyUP="this.value=Numbers(this.value)" onBlur="effectivevalidate();backvalidate();" ReadOnly onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);">
				<OPTION VALUE=""> Select.. </OPTION>
				<OPTION VALUE="#Year(now())#"> #Year(now())# </OPTION>
				<OPTION VALUE="#Year(now())-1#"> #Year(now())-1# </OPTION>
			<select>
			<!--- end Mshah--->
			<!---<INPUT TYPE=TEXT NAME='Year' VALUE="#Year(now())#" STYLE='text-align: center;' SIZE=4 MAXLENGTH=4 onKeyUP="this.value=Numbers(this.value)" onBlur="YearTest(this); effectivevalidate();" ReadOnly onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);">--->
		</TD>
	</TR>
 
 
	<script>
		
	function secondarycheck ()	{
		//alert ('test');
	    //alert(document.all['recurringchange'].innerHTML  ); 
		s = document.all['recurringchange'].innerHTML;
		sa = "Change to Basic Service Fee - Second";
		sb = "Change to Second";
		sc="Change to Basic Service Fee - MC Second";
		sd="Change to MC Second";
		//alert (sa);
		//alert (sb);
		var a = document.getElementById("Ten1");<!---added by TPecku--->
		var b = a.options[a.selectedIndex].text;<!---added by TPecku--->
		//alert (b);
		var fname = b.split(',').pop().split('(').shift();  
		//alert (fname);
		var lname = b.substr(0, b.indexOf(','));
		//alert (lname);
		var acct= b.match(/\d/g);
		var acct = acct.join("");
		//alert (acct);
		var fullname = fname+lname+' '+'('+ acct+')'
		//alert (fullname);
		//if (s.match(/Second.*/)){
		if(s.indexOf(sa) > -1) {
			alert(fullname +' will be second occupant and occupancy will be zero');
		}
		if(s.indexOf(sb) > -1) {
			alert(fullname +' will be second occupant and occupancy will be zero');
		}
		if(s.indexOf(sc) > -1) {
			alert(fullname +' will be second occupant and occupancy will be zero');
		}
		if(s.indexOf(sd) > -1) {
		alert(fullname +' will be second occupant and occupancy will be zero');
		}
		alert (document.getelementbyID('Year').value);
	}
	
	function checkyear ()
	{
		//alert('test');
		//alert(document.forms[0].Year.value);
	    var x = document.forms[0].Year.value;
		if (x==""){
			alert('Select Year in effective date');
			return false;
		}
	 	var oldApt=(document.getElementById("icurrentroomID").value);
	 	var newApt=(document.getElementById("iAptAddress_ID").value);		

	 	//  	alert('newApt: ' + newApt   + ' oldApt: '+ oldApt);
  	  if (oldApt == newApt){
	   		alert("The \'Move To\' room number cannot be the same as the Current Room Number. Please select a different room.");
	  		 return false;
	   	}
	   	//mstriegel 11/21/17 added
		 if(window.hasBundledPricing == 1){		 	
	   		return checkBundled();
	  	}	  	
	   	//end mstriegel
	   	
	}


	//mstriegel:11/13/2017 added 
	var arrStudioList = [<cfoutput>#valueList(getStudioList.iAptAddress_ID)#</cfoutput>];

	function checkIfStudio(apt){
		for(i=0;i<=arrStudioList.length;i++){
			if(apt == arrStudioList[i]){
				return true;
				break;
			}
		}
		return false;
	}
	
	function checkBundled(){
		currentlyInstudio= window.bIsStudio;
		goingInToStudio = checkIfStudio(window.goingtoApt);
		if(currentlyInstudio == "No" && goingInToStudio == true){
			alert("Bundled pricing is available for this apartment type.");
			return true;
		}
		if(currentlyInstudio == "Yes" && goingInToStudio == false){
			var n = confirm("Bundled pricing WILL NOT be available for this apartment type.");
			if(n == true){
				document.getElementById("hasBundledPricing").value='';
				return true;
			}
			else{
				return false;
			}
		}		
	
	}

	// end mstriegel
	</script>
	

	<TR>
		<!--- Proj 26955 rschuette 2/12/2009 --->
		<!--- <cfinclude template="../Relocate/js_BondValidation.cfm"> --->
		<!--- Project 20125 modification. 07/30/2008 Ssathya Added the validation to the save button --->
		<TD><INPUT TYPE="submit" NAME="save" VALUE="Save" CLASS="SaveButton" onmouseover="return hardhaltvalidation(RelocateTenant);" 
		 <!---onfocus ="secondarycheck();return hardhaltvalidation(RelocateTenant);" --->
		onclick="return checkyear();" ></TD><TD COLSPAN=2></TD>
		<TD> <INPUT TYPE="button" NAME="Don't Save" VALUE="Don't Save" CLASS="DontSaveButton" onClick="redirect()"></TD>
	</TR>
	<TR>
		<TD  COLSPAN="4" style="font-weight: bold; color: red;">	
			 <U> NOTE:</U> You must SAVE to keep information which you have entered! 
		</TD>
	</TR>
</TABLE>
<!--- mstriegel 11/13/17 added --->
<input type="hidden" name="hasBundledPricing" id="hasBundledPricing" value="#tenantList.bIsbundledPricing#">
<!--- end mstriegel 11/13/17 --->
</CFFORM>

<CFINCLUDE TEMPLATE="../../footer.cfm">
</CFOUTPUT>

