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
| ranklam    | 10/28/2005 | Added Flowerbox                                                    |
| ranklam    | 10/28/2005 | Renamed GUM link to #server_name#                                  |
| fzahir     | 11/22/2005 | Only TIPS AR people should be able to edit Amount field            |
| mlaw       | 12/29/2005 | include house's cchargeset into the chargelist box                 |
| mlaw       | 03/02/2006 | Remove hidden mAmount value to pass the calling program            |
| mlaw       | 03/08/2006 | Remedy Call 32362 - User should allow to change all charges except |
|            |            | ChargeType - R&B rate, R&B discount                                |
|rschuette	 | 07/18/2008 | Restricted negative value input on Amount based on usergroup       |
|sfarmer     | 4/10/2012  | Project 75019 - EFT Update/NRF Deferral.                           |
|sfarmer     | 06/09/2012 | 75019 - NRF/Deferred Installation                                  |
|sfarmer     | 06/09/2012 | 92628 - alow only AR to edit NRF/Deferred entries                  |
----------------------------------------------------------------------------------------------->
<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ''> 
     <!--- rsa - 10/28/2005 - changed link from gum to #server_name# --->
     <CFLOCATION URL="http://#server_name#" ADDTOKEN="No"> 
</CFIF>
<!---  <cfdump var="#session#">  ---> 
<!--- Include Share JavaScript  --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
<SCRIPT>
    function test()
    {
	   //alert('test');
	   // another tenant_ID in room
	   //var a ='';
	   var a= document.getElementById("CoTenantFN").value;
	   //var b ='';
	   var b= document.getElementById("CoTenantLN").value;
	   //var c='';
	   var c= document.getElementById("CoTenantOP").value;
	   // var d =''
	   var d= document.getElementById("CoTenantCOP").value;
	   //alert(c);
	   //alert(d);
	   if (c!==d && d!==''){
		   //alert(c);
		   //alert(d);
	   alert ('Making this change will result in two residents are Second/Primary in the same room, please adjust');
	   /*if (x == true) {
		   document.forms[0].submit(); 
		} else {
		    return false;
		}*/
	   return;
	   }
    }
	function effectivecheck() {
		var MonthStart = (document.Recurring.MonthStart.value - 1);
		var MonthEnd = (document.Recurring.MonthEnd.value - 1);
		var	start = new Date(document.Recurring.YearStart.value, MonthStart, document.Recurring.DayStart.value);
		var	end = new Date(document.Recurring.YearEnd.value, MonthEnd, document.Recurring.DayEnd.value);
		if (start > end) { (document.Recurring.Message.value = 'The start date may not be later than the end date'); return false; }
		else{ (document.Recurring.Message.value = ''); return; }
	}
</SCRIPT>
<script language="javascript">
	function numbers(e)
  {	  //  Robert Schuette project 23853  - 7-18-08
  	 // removes House ability to enter negative values for the Amount textbox,
  	//  only AR will enter in negative values.  Added extra: only numeric values.
  	
     //alert('Javascript is hit for test.')
  	keyEntry = window.event.keyCode;
  	if((keyEntry < '46') || (keyEntry > '57') || (keyEntry == '47')) {return false;  }
  }
</script>	

<CFSCRIPT>
	if (IsDefined("form.iTenant_ID") and IsDefined("form.iCharge_ID")) { ACTION="RecurringADD.cfm"; }
	else if (IsDefined("url.typeID")) { ACTION="RecurringUpdate.cfm"; }
	else { ACTION="Recurring.cfm"; }	

	if (IsDefined("url.ID")){ form.iTenant_ID=URL.ID; }
	if (IsDefined("url.typeID")){ form.iCharge_ID=URL.typeID; }
	if (SESSION.UserID IS 3025){ writeOutPut('#Variables.Action#<BR>'); }
</CFSCRIPT>

<!--- MLAW 12/29/2005 Get the cChargeSet value from the house table based on the house id --->
<cfquery name="getHouseChargeset" datasource="tips4">
  select cs.CName from house h
  join chargeset cs
  on cs.iChargeSet_ID = h.iChargeSet_ID
  where ihouse_id = #session.qSelectedHouse.iHouse_ID#
    and h.dtrowdeleted is null
</cfquery>
<cfquery name="QRYREGION" datasource="tips4">
select h.cname as house, ops.cname as region, reg.cname as division
from house h
join opsarea ops on h.iopsarea_id = ops.iopsarea_id
join region reg on ops.iregion_id = reg.iregion_id
where h.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
</cfquery>

<!--- <cfquery name="GetComments" datasource="#Application.DataSource#">
    Select iInvoiceComments_ID, cDescription
    From InvoiceComments
    Order By cDescription
</cfquery> --->

<!--- ==============================================================================
Retrieve all Tenants who are in a status of Moved IN
=============================================================================== --->
<CFQUERY NAME="TenantList" DATASOURCE="#APPLICATION.datasource#">
	select *
	from tenant t (nolock)
	join tenantstate ts (nolock) on (t.iTenant_ID = ts.iTenant_ID and t.dtRowDeleted is null)
	and ts.iTenantStateCode_ID = 2 and ts.iResidencyType_ID <> 3
	and t.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	join AptAddress ad (nolock) on (TS.iAptAddress_ID = AD.iAptAddress_ID and AD.dtRowDeleted is null)
	where ts.iAptAddress_ID is not null
	<CFIF IsDefined("form.iTenant_ID")> and T.iTenant_ID = #form.iTenant_ID# </CFIF>
	order by T.cLastName
</CFQUERY>


<!--- logout user if trying to submit via edited url variables 5/18/05 Paul Buendia--->
<!--- <cfif (TenantList.recordcount eq 0 and isDefined("url.id") ) or (isDefined("url.id") and not isDefined("HTTP_REFERER"))>
	<cflocation url="../../logout.cfm">
</cfif> --->

<!--- ==============================================================================
Retreive all charges for Recurring purposes.
=============================================================================== --->
<!--- MLAW 12/29/2005 include House's cchargeset --->
<CFQUERY NAME="ChargeList" DATASOURCE = "#APPLICATION.datasource#">
	<CFIF NOT IsDefined("url.TypeID")>
		SELECT	C.*, CT.bIsModifiableDescription, CT.bIsModifiableAmount, CT.bIsModifiableQty, CT.cDescription as typedescription,
				CT.bIsRent, CT.bIsDaily, NULL as cComments, NULL as cInvoiceComments, CT.iChargeType_ID
		from Charges C
		join ChargeType CT on C.iChargeType_ID = CT.iChargeType_ID and CT.dtRowDeleted is null and c.dtRowDeleted is null
			and cGLAccount <> 1030 and CT.iChargeType_ID <> 23 and CT.bisRecurring is not null
            and CT.bIsDeposit is null 
            and (C.cChargeSet is null or C.cChargeset = '#getHouseChargeset.CName#')
            and (C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR C.iHouse_ID is null)
            and (c.iresidencytype_id <> 3 or c.iresidencytype_id is null)
            and ct.iChargeType_ID not in (1740,171)
		where C.dtRowDeleted is null
		and #CreateODBCDateTime(SESSION.TipsMonth)# between c.dteffectivestart and isnull(c.dteffectiveend,getdate())
		<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0 and  
			( (IsDefined("SESSION.accessrights") and SESSION.accessrights NEQ 'iDirectorUser_ID') 
					or not isDefined("SESSION.accessrights") )>
			and ((bIsRent IS NOT NULL and bisdaily is not null and isleveltype_id is null) OR bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL OR bIsRentAdjustment IS NOT NULL)
			and bisdeposit is null
			and bIsMedicaid is null and cGLACCOUNT NOT IN (3011,3012,3015,3016)
		<CFELSEIF (IsDefined("SESSION.accessrights") and SESSION.accessrights EQ 'iDirectorUser_ID')> 
			and (bIsRent is null OR cGLAccount = 3011 OR bIsDiscount IS NOT NULL or (bisrent is not null and bSlevelType_ID is null))
			and bIsMedicaid is null and cGLACCOUNT NOT IN (3011,3012,3015,3016)
			and bisrentadjustment is null
		</CFIF>
		<CFIF IsDefined("form.iCharge_ID")> and iCharge_ID = #form.iCharge_ID# </CFIF>
		ORDER BY C.cDescription, CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc
	<CFELSE>
		SELECT	RC.*, RC.bIsDaily as RCbIsDaily, CT.iChargeType_ID, CT.bIsModifiableDescription
				,CT.bIsModifiableAmount, CT.bIsModifiableQty, C.iCharge_ID,  CT.cDescription as typedescription
				,CT.bIsRent, CT.bIsDaily, NULL as cComments, NULL as cInvoiceComments
		FROM	RecurringCharge RC	
		JOIN	Charges C ON (C.icharge_ID = RC.iCharge_ID and C.dtRowDeleted is null and rc.dtRowDeleted is null)
		JOIN	ChargeType CT	ON (CT.iChargeType_ID = C.iChargeType_ID and CT.dtRowDeleted is null)
				and rc.iRecurringCharge_ID = #url.typeID#

			<CFIF ListFindNoCase(SESSION.CodeBlock, 23, ",") EQ 0>
			<!--- and ct.iChargeType_ID not in (1740,1741) --->		
			and ct.bIsMedicaid is null
			</CFIF>
		ORDER BY CT.bIsRent, CT.bIsMedicaid desc, CT.bIsDaily desc, CT.bIsRentAdjustment desc, C.cDescription
	</CFIF>
</CFQUERY>

<CFQUERY NAME='qChargeTypes' DBTYPE='QUERY'>
	SELECT	distinct typedescription, iChargeType_ID FROM ChargeList Order by typedescription
</CFQUERY>

<!--- ==============================================================================
Retreive all the Current Recurring Charges for the House ***  and C.dtEffectiveEnd > '#SESSION.TIPSMonth#'
=============================================================================== --->
<CFQUERY NAME = "CurrentRecurring" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	RC.iRecurringCharge_ID, RC.dtEffectiveStart, RC.dtEffectiveEnd, RC.iQuantity
			,RC.bIsDaily AS RCbIsDaily, RC.cDescription, RC.mAmount, RC.cComments,
			T.iTenant_ID, T.cFirstname, T.cLastName, CT.bIsDaily, CT.ichargetype_id, TS.mAdjNRF, TS.mAmtNRFPaid
	FROM	RecurringCharge RC
	JOIN	Charges C ON C.iCharge_ID = RC.iCharge_ID and C.dtRowDeleted is null
	JOIN 	ChargeType CT ON CT.ichargetype_id = C.iChargeType_ID and CT.dtrowdeleted is null
	JOIN	Tenant T ON	RC.iTenant_ID = T. iTenant_ID and T.dtRowDeleted is null and RC.dtRowDeleted is null
	JOIN	TenantState TS ON TS.iTenant_ID = T.iTenant_ID and TS.dtRowDeleted is null 
			and TS.iTenantStateCode_ID < 3 and TS.iAptAddress_ID IS NOT NULL
	JOIN	House H	ON H.iHouse_ID = T.iHouse_ID and H.dtRowDeleted is null and H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	WHERE	RC.dtEffectiveEnd >= '#SESSION.TIPSMonth#'
	ORDER BY T.cLastName
</CFQUERY>
<!---Mshah added query to find missing recurringcharge for private resident --->	
<CFQUERY NAME = "FindMissingRecurring" DATASOURCE = "#APPLICATION.datasource#">
		select t.cfirstname+', '+t.clastname as Residentname,t.csolomonkey, t.ihouse_ID from tenant t join tenantstate ts on ts.itenant_ID =t.itenant_ID 
		where ts.itenantstatecode_ID=2 
		and t.ihouse_ID= #SESSION.qSelectedHouse.iHouse_ID# 
		and t.dtrowdeleted is null and ts.dtrowdeleted is null and ts.iresidencytype_ID=1
		and t.itenant_ID not in
		(SELECT	rc.itenant_ID
		FROM	RecurringCharge RC
		JOIN	Charges C ON C.iCharge_ID = RC.iCharge_ID and C.dtRowDeleted is null
		JOIN 	ChargeType CT ON CT.ichargetype_id = C.iChargeType_ID and CT.dtrowdeleted is null and CT.ichargetype_ID in (89,1748,1682)
		JOIN	Tenant T ON	RC.iTenant_ID = T. iTenant_ID and T.dtRowDeleted is null and RC.dtRowDeleted is null
		JOIN	TenantState TS ON TS.iTenant_ID = T.iTenant_ID and TS.dtRowDeleted is null 
				and TS.iTenantStateCode_ID < 3 and TS.iAptAddress_ID IS NOT NULL and ts.iresidencytype_ID=1
		JOIN	House H	ON H.iHouse_ID = T.iHouse_ID and H.dtRowDeleted is null and H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		WHERE	RC.dtEffectiveEnd >= '#SESSION.TIPSMonth#')
</cfquery>
<!---<cfdump var="#FindMissingRecurring#">--->
	<!---Mshah added this query to see if there are two primary or two secondary in any room--->
	<CFQUERY NAME = "Findincorrectrate" DATASOURCE = "#APPLICATION.datasource#">
						Select ts.iaptaddress_ID,ad.captnumber,h.cname,ts.itenant_ID, t.clastname +', '+ t.cfirstname as Residentname,t.csolomonkey,c.ioccupancyposition
						from tenantstate ts join tenant t on t.itenant_ID= ts.itenant_ID and t.dtrowdeleted is null and ts.dtrowdeleted is null
						 join house h on h.ihouse_ID=t.ihouse_ID and h.dtrowdeleted is null and h.bissandbox=0 and h.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
						 join recurringcharge rc on rc.itenant_ID = t.itenant_ID and rc.dtrowdeleted is null and rc.dteffectiveend >= '#SESSION.TIPSMonth#'
						 join charges c on c.icharge_ID=rc.icharge_ID and c.dtrowdeleted is null and c.ichargetype_ID in (89,1748,1682) 
						 join aptaddress ad on ad.iaptaddress_ID= ts.iaptaddress_ID and ad.dtrowdeleted is null 
						 join apttype at on at.iapttype_ID=ad.iapttype_ID and (at.biscompanionsuite is null or at.biscompanionsuite = 0)
						 join  (Select ts.iaptaddress_ID,ad.captnumber,h.cname,count(ts.iaptaddress_ID) as aptcnt
								from tenantstate ts join tenant t on t.itenant_ID= ts.itenant_ID and t.dtrowdeleted is null and ts.dtrowdeleted is null
								 join house h on h.ihouse_ID=t.ihouse_ID and h.dtrowdeleted is null and h.bissandbox=0 and h.ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
								 join recurringcharge rc on rc.itenant_ID = t.itenant_ID and rc.dtrowdeleted is null and rc.dteffectiveend >= '#SESSION.TIPSMonth#'
								 join charges c on c.icharge_ID=rc.icharge_ID and c.dtrowdeleted is null and c.ichargetype_ID in (89,1748,1682) 
								 join aptaddress ad on ad.iaptaddress_ID= ts.iaptaddress_ID and ad.dtrowdeleted is null 
								 join apttype at on at.iapttype_ID=ad.iapttype_ID and (at.biscompanionsuite is null or at.biscompanionsuite = 0)
								where  ts.itenantstatecode_ID=2
								group by ts.iaptaddress_ID, ad.captnumber,h.cname
								 having count(ts.iaptaddress_id)>1 and count(distinct c.ioccupancyposition)=1) a
						on ts.iaptaddress_ID=a.iaptaddress_ID
						where ts.itenantstatecode_ID=2 
	
	
						Union
					
			 Select ts.iaptaddress_ID ,ad.captnumber,h.cname,ts.itenant_ID, t.clastname +', '+ t.cfirstname as Residentname,t.csolomonkey,c.ioccupancyposition 
			 from tenantstate ts join tenant t on t.itenant_ID= ts.itenant_ID and t.dtrowdeleted is null and ts.dtrowdeleted is null
			        			 join house h on h.ihouse_ID=t.ihouse_ID and h.dtrowdeleted is null and h.bissandbox=0 and h.ihouse_ID= #SESSION.qSelectedHouse.iHouse_ID#
								 join recurringcharge rc on rc.itenant_ID = t.itenant_ID and rc.dtrowdeleted is null and rc.dteffectiveend >= '#SESSION.TIPSMonth#'
								 join charges c on c.icharge_ID=rc.icharge_ID and c.dtrowdeleted is null and c.ichargetype_ID in (89,1748,1682) 
								 join aptaddress ad on ad.iaptaddress_ID= ts.iaptaddress_ID and ad.dtrowdeleted is null 
								 join apttype at on at.iapttype_ID=ad.iapttype_ID and (at.biscompanionsuite is null or at.biscompanionsuite = 0)
					    		 left join (Select ts.iaptaddress_ID,ad.captnumber,h.cname,ts.itenant_ID, t.cfirstname,t.clastname,c.ioccupancyposition,rc.mamount,rc.cdescription
											 from tenantstate ts join tenant t on t.itenant_ID= ts.itenant_ID and t.dtrowdeleted is null and ts.dtrowdeleted is null
						        			 join house h on h.ihouse_ID=t.ihouse_ID and h.dtrowdeleted is null and h.bissandbox=0 and h.ihouse_ID= #SESSION.qSelectedHouse.iHouse_ID#
											 join recurringcharge rc on rc.itenant_ID = t.itenant_ID and rc.dtrowdeleted is null and rc.dteffectiveend >= '#SESSION.TIPSMonth#'
											 join charges c on c.icharge_ID=rc.icharge_ID and c.dtrowdeleted is null and c.ichargetype_ID in (89,1748,1682) 
											 join aptaddress ad on ad.iaptaddress_ID= ts.iaptaddress_ID and ad.dtrowdeleted is null 
											 join apttype at on at.iapttype_ID=ad.iapttype_ID and (at.biscompanionsuite is null or at.biscompanionsuite = 0)
											 where ts.itenantstatecode_ID=2  and c.iOccupancyposition= 1 and ts.iresidencytype_ID=1) a
								on ts.iaptaddress_ID=a.iaptaddress_ID
								where  ts.itenantstatecode_ID=2 and c.iOccupancyposition= 2 and ts.iresidencytype_ID=1 and a.itenant_ID is null	
			
	</cfquery>

<cfinclude template="../Shared/Queries/HouseDetail.cfm">
<!--- include ALC Header --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- HTML head --->
<TITLE> Tips 4  - Recurring Charges/Credits </TITLE>
<BODY>

<!--- Display the page header --->
<H1 CLASS="PageTitle"> Tips 4 - Recurring Charges/Credits </H1>
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">


<CFOUTPUT>
<SCRIPT>
	clist="<SELECT NAME='iCharge_ID' onChange='submit()'>";
	clist+="<OPTION VALUE=0> None </OPTION>";
	<CFLOOP QUERY="ChargeList">clist+="<OPTION Value='#ChargeList.iCharge_ID#'> #ChargeList.cDescription# <CFIF ChargeList.bIsRent NEQ ''> #LSCurrencyFormat(ChargeList.mAmount)#</CFIF> <CFIF ChargeList.bIsDaily NEQ ''> (Daily) </CFIF></OPTION>"; </CFLOOP>
	clist+="</SELECT>";
	function showtypes(obj){ 
		if (obj.value !== ''){ document.all['chargetype'].style.display='inline'; document.all['chargetype'].innerHTML=clist; }
		else { document.all['chargetype'].style.display='none'; document.all['chargetype'].innerHTML=''; }
	}
</SCRIPT>
<!---Mshah added this to show missing recurringcharge in house for private resident---> 
<cfif #FindMissingRecurring.recordcount# GT 0>
  <table>
	 <tr>
	 	<td style="font-weight: bold;color:red;">
		  Missing/Expired BSF Recurring Charge for Resident-
		 </td>
	 </tr>
	<cfloop query="FindMissingRecurring">
	 <tr style="font-weight: bold;color:red;">
	 <td>#FindMissingRecurring.Residentname# (#FindMissingRecurring.csolomonkey#) </td>
	 </tr>
	</cfloop>
	</table>
</cfif>
<cfif #Findincorrectrate.recordcount# GT 0>
<table>
	 <tr>
	 	<td style="font-weight: bold;color:red;">
		  Please correct Recurring Charge for below residents. These are either both Primary or Second resident in same Apt or only Second Resident.
		 </td>
	 </tr>
	<cfloop query="Findincorrectrate">
	 <tr style="font-weight: bold;color:red;">
	 <td>#Findincorrectrate.Residentname# (#Findincorrectrate.csolomonkey#) </td>
	 </tr>
	</cfloop>
	</table>
</cfif>


<FORM NAME="Recurring" ACTION = "#Variables.Action#" METHOD = "POST" onSubmit="return effectivecheck();">

<INPUT NAME = "Message" TYPE = "TEXT" VALUE="" SIZE="77" STYLE = "Color: Red; Font-Weight: bold; Font-Size: 16; text-align: center;">
<CFIF IsDefined("URL.typeID")> <INPUT TYPE="Hidden" NAME="iRecurringCharge_ID" VALUE="#url.typeID#"> </CFIF>
<TABLE>
	<CFSCRIPT>if(isDefined("url.ID") and Url.ID NEQ ''){ Action='Edit'; } else{ Action='Add'; }</CFSCRIPT>
	<TR> <TH COLSPAN = "4"> #Action# Recurring Charges/Credits </TH> </TR>
	<TR STYLE = "font-weight: bold;">
		<TD STYLE="width: 25%;"> Name </TD>
		<TD STYLE="width: 25%;"> Charge/Credit </TD>
		<TD STYLE="width: 25%;text-align: center;"> Amount </TD>
		<TD STYLE="width: 25%; text-align: center;"> Quantity </TD>
	</TR>
	<CFIF NOT IsDefined("form.iTenant_ID")>
		<TR>
			<TD NOWRAP>
				<SELECT NAME="iTenant_ID" onChange="showtypes(this);">
					<OPTION VALUE="0"> None </OPTION>
					<CFLOOP QUERY="TenantList"> 
					<OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstname# </OPTION> 
					</CFLOOP>
				</SELECT>
			</TD>
			<TD><SPAN ID='chargetype'></SPAN></TD>
			<TD></TD><TD></TD>
		</TR>
	</CFIF>	
	
	<CFIF IsDefined("form.iTenant_ID") and IsDefined("form.iCharge_ID")>
		<!---project primary/secondary--->
			<!--- Retrieve Tenant Information --->
			<cfquery name="qTenant" datasource="#APPLICATION.datasource#"> <!---Mshah added aptaddress--->
			select	 ts.iaptaddress_ID from Tenant T 
			join tenantstate ts on ts.itenant_ID=t.itenant_ID and ts.dtrowdeleted is null
			join House H ON T.iHouse_ID = H.iHouse_ID and H.dtRowDeleted IS NULL 
			and  T.dtRowDeleted IS NULL and T.iTenant_ID = #form.iTenant_ID#
			</cfquery>
			<cfquery name="FindChargeType" datasource="#APPLICATION.datasource#"> 
			Select * from charges where icharge_ID=#form.iCharge_ID#
			</cfquery>
			<!---<cfdump var="#FindChargeType#" label="FindChargeType">--->
			<!---Mshah added to find if there is any one in room--->
			<cfif #trim(FindChargeType.iChargeType_ID)# NEQ '' and 
			(#trim(FindChargeType.iChargeType_ID)# eq 1748 
			or #trim(FindChargeType.iChargeType_ID)# eq 1682 
			or #trim(FindChargeType.iChargeType_ID)# eq 89)>
				<cfquery name="Findroommate" datasource="#APPLICATION.datasource#">
					select *,at.iapttype_ID as apttype
					from 
					tenantstate ts join tenant t on ts.itenant_ID=t.itenant_ID
					join aptaddress ad on ad.iaptaddress_ID=ts.iaptaddress_id
					join apttype at on at.iapttype_ID=ad.iapttype_ID
					left join recurringcharge r on r.itenant_ID=t.itenant_ID and r.dtRowDeleted is NULL
					left join charges c on c.icharge_ID=r.icharge_ID and c.dtRowDeleted is NULL  and c.ichargetype_ID in (89,1682,1748)
					where
					 ts.iaptaddress_id=#qTenant.iAptAddress_ID# 
					and ts.dtrowdeleted is null
					and ts.dtchargethrough is null
					and ts.itenantstatecode_ID=2
					and ad.dtrowdeleted is null
					and (at.biscompanionsuite = 0 or at.biscompanionsuite is null)
					and ts.itenant_id != #form.iTenant_ID#
					order by r.iRecurringCharge_ID DESC
				</cfquery>
			
				<!---<cfdump var="#Findroommate#" label="Findroommate">--->
				
				<!---find the charge which is being added--->	
				<cfquery name="findoccupancyadded" datasource="#APPLICATION.datasource#">
				 Select * from charges where icharge_ID= #form.iCharge_ID#
				</cfquery>
				<!---<cfdump var="#findoccupancyadded#" label="findoccupancyadded">--->
				
				<!---set variable for prompt--->
				<INPUT TYPE="Hidden" NAME="CoTenant_ID" ID="CoTenant_ID" VALUE="#Findroommate.iTenant_ID#">
				<INPUT TYPE="Hidden" NAME="CoTenantFN" ID="CoTenantFN" VALUE="#Findroommate.cfirstname#">
				<INPUT TYPE="Hidden" NAME="CoTenantLN" ID="CoTenantLN" VALUE="#Findroommate.cLastname#">
				<INPUT TYPE="Hidden" NAME="CoTenantRC" ID="CoTenantLN" VALUE="#Findroommate.irecurringcharge_ID#">
				<INPUT TYPE="Hidden" NAME="CoTenantAptID" ID="CoTenantaptID" VALUE="#Findroommate.apttype#">
				<cfif #Findroommate.IOCCUPANCYPOSITION# eq 1>
				   <INPUT TYPE="Hidden" NAME="CoTenantCOP" ID="CoTenantCOP" VALUE="Primary">
				<cfelseif #Findroommate.IOCCUPANCYPOSITION# eq 2>
				   <INPUT TYPE="Hidden" NAME="CoTenantCOP" ID="CoTenantCOP" VALUE="Second">
				<cfelse>
				   <INPUT TYPE="Hidden" NAME="CoTenantCOP" ID="CoTenantCOP" VALUE="">
				</cfif>
				<cfif #findoccupancyadded.IOCCUPANCYPOSITION# eq 1>
				   <INPUT TYPE="Hidden" NAME="CoTenantOP" ID="CoTenantOP" VALUE="Second">
				<cfelseif #findoccupancyadded.IOCCUPANCYPOSITION# eq 2 >
				   <INPUT TYPE="Hidden" NAME="CoTenantOP" ID="CoTenantOP" VALUE="Primary">
				 <cfelse>
				 <INPUT TYPE="Hidden" NAME="CoTenantOP" ID="CoTenantOP" VALUE="">
				</cfif>
	    	</cfif>
	    	<!---Mshah end--->
			<TR>
			<TD>#TenantList.cLastName#, #TenantList.cFirstname# 
			<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#TenantList.iTenant_ID#">
			</TD>
			<CFIF ChargeList.bIsModifiableDescription GT 0>
				<TD>
					<INPUT TYPE="text" NAME="cDescription" VALUE="#ChargeList.cDescription#" MAXLENGTH="15" 
					 onBlur="this.value=Letters(this.value);  Upper(this);">
					<INPUT TYPE="text" NAME="iCharge_ID" VALUE="#ChargeList.iCharge_ID#">
				</TD>
			<CFELSE>
				<TD>	
					#ChargeList.cDescription#
					<INPUT TYPE="text" NAME="iCharge_ID" VALUE="#ChargeList.iCharge_ID#" readonly>
					<INPUT TYPE="text" NAME="cDescription" VALUE="#ChargeList.cDescription#" readonly>
				</TD>
			</CFIF>
		
			<!--- MLAW 03/08/2006 Add condition for R&B rate and R&B discount, BisModifiableAmount is the field that determine if the charge is editable --->
			<CFIF ChargeList.bIsModifiableAmount GT 0 or listfindNocase(session.codeblock,23) GTE 1 or session.userid EQ 3025 
				or session.userid EQ 3146 or session.userid is "3271">
			<!--- Katie taking away RDO & House access to overrule modify amount rights set by chargetype administrator: 7/6/05: (isDefined("session.AccessRights") and session.AccessRights EQ 'iDirectorUser_ID') or listfindNocase(session.codeblock,21) GTE 1  --->
				<cfif ListContains(session.groupid,'192')>
				<TD STYLE="text-align: center;">	
					<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#" 
					STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);" 
					onBlur="this.value=cent(round(this.value));">
				</TD>
				<cfelse>
					<TD STYLE="text-align: center;">
						<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#"
						 STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);"
						  onBlur="this.value=cent(round(this.value));" onKeyPress="return numbers(event);">
					</TD>
				</cfif><!---End change. proj 23853--->
				
			<CFELSE>
				<td style="text-align: center;">
				<INPUT TYPE="text" NAME="mAmount" SIZE="7" VALUE="#TRIM(LSNumberFormat(ChargeList.mAmount, "99999.99"))#"
				 STYLE="text-align:right;" onKeyDown="this.value=CreditNumbers(this.value);" 
				 onBlur="this.value=cent(round(this.value));" readonly >
				</td>
			</CFIF>
			
			<CFIF ChargeList.bIsModifiableQty GT 0>
				<TD STYLE="text-align: center;">
					<cfif (isDefined("ChargeList.iCharge_ID") 
					and (ChargeList.iChargeType_ID is 8 or ChargeList.iChargeType_ID is 1664 or ChargeList.iChargeType_ID is 1749 or ChargeList.iChargeType_ID is 1750 ))
					 and (SESSION.qSelectedHouse.cStateCode NEQ 'OR')>
					 	<CFSCRIPT>
							if (isDefined("ChargeList.RCbIsDaily") and ChargeList.RCbIsDaily is 1) {checked='checked'; }
							else {checked=''; }
						</CFSCRIPT>
						<input type="checkbox" name="bIsDaily" value="1" #checked#> Daily or 
					</cfif>
					<input type="text" name="iQuantity" value="#ChargeList.iQuantity#" size="2" maxlength="2" 
					style="text-align:center;" onBlur="this.value=Numbers(this.value);">
				</TD>
			<CFELSE>
				<TD STYLE="text-align: center;"> #ChargeList.iQuantity# <INPUT TYPE="Hidden" NAME="iQuantity" 
				VALUE="#ChargeList.iQuantity#"></TD>
			</CFIF>
		</TR>
	</CFIF>
	
	<CFIF IsDefined("form.iTenant_ID") and IsDefined("form.iCharge_ID")>
		<TR>
			<TD>Effective Beginning	</TD>
			<TD>
				<CFSCRIPT>
					if (ChargeList.dtEffectiveStart NEQ "") { 
						MonthStart = Month(ChargeList.dtEffectiveStart);
						 DayStart = Day(ChargeList.dtEffectiveStart);
						  YearStart = Year(ChargeList.dtEffectiveStart); }
					else{ MonthStart = "#Month(now())#"; 
						DayStart = "#Day(Now())#";
					 	YearStart = "#Year(Now())#"; }
				</CFSCRIPT>
				<SELECT NAME="MonthStart" onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)">	
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
					<CFIF MonthStart EQ I><CFSET sel='selected'>
					<CFELSE>
					<CFSET sel=''></CFIF>
					<OPTION VALUE="#I#" #sel#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/ 
				<SELECT NAME = "DayStart" 
				onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)">
					<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1">
					<CFIF DayStart EQ I><CFSET sel='selected'>
					<CFELSE><CFSET sel=''>
					</CFIF>
						<OPTION VALUE="#I#"#sel#> #I# </OPTION>
					</CFLOOP>
				</SELECT>	
				/
				<INPUT TYPE="Text" NAME="YearStart" Value="#YearStart#" SIZE="3" MAXLENGTH=4  
				onChange="dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart)"
				 onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=Numbers(this.value);">
			</TD>
			<TD> Effective End </TD>
			<TD>
				<CFSCRIPT>
					if (ChargeList.dtEffectiveEnd NEQ ""){
						MonthEnd = Month(ChargeList.dtEffectiveEnd);
						 DayEnd = Day(ChargeList.dtEffectiveEnd); 
						 YearEnd = Year(ChargeList.dtEffectiveEnd); }
					else { MonthEnd = "#Month(now())#"; DayEnd = "#Day(Now())#"; YearEnd = "2010"; }
				</CFSCRIPT>
				<SELECT NAME = "MonthEnd" 
				onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
					<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1">
					<CFIF MonthEnd EQ I>
						<CFSET sel='selected'>
					<CFELSE>
						<CFSET sel=''>
					</CFIF>
					<OPTION VALUE="#I#"#sel#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/ 
				<SELECT NAME = "DayEnd" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
					<CFLOOP INDEX="I" FROM="1" TO="#DaysInMonth(now())#" STEP="1">
					<CFIF DayEnd EQ I>
						<CFSET sel='selected'>
					<CFELSE>
						<CFSET sel=''>
					</CFIF>
					<OPTION VALUE="#I#"#sel#> #I# </OPTION>
					</CFLOOP>
				</SELECT>
				/
				<INPUT TYPE="Text" NAME="YearEnd" Value="#YearEnd#" SIZE="3" MAXLENGTH=4 onKeyUp="this.value=Numbers(this.value);" onBlur="this.value=Numbers(this.value); dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd);" onChange="dayslist(document.forms[0].MonthEnd,document.forms[0].DayEnd,document.forms[0].YearEnd)">
			</TD>
		</TR>
<!---         <TR>
            <TD COLSPAN="4">
            	Current comment for invoice: <strong>#ChargeList.cInvoiceComments#</strong><Br />
                <br>
                 Available Comments for Invoice:<br />
                <select name="cInvoiceComments" style="size:50EOM">
                    <option value=""></option>
                    <cfloop query="GetComments">
                        <option value="#GetComments.cDescription#">#GetComments.cDescription#</option>
                    </cfloop>
                </select>  
            </TD>
        </TR> --->
		<TR>
        	<TD COLSPAN="4">
            	Internal Comments: <BR>
            	<TEXTAREA COLS="75" ROWS="2" NAME="cComments">#ChargeList.cComments#</TEXTAREA>
            </TD>
        </TR> 
  
<!--- 		<cfif ((ChargeList.iChargeType_ID is   "1737") or (ChargeList.iChargeType_ID is   "1740")
				 or (ChargeList.iChargeType_ID is   "1741") or (ChargeList.iChargeType_ID is   ""))> --->
		<cfif ((ChargeList.iChargeType_ID is   "1737") or (ChargeList.iChargeType_ID is   "1740")
				  or (ChargeList.iChargeType_ID is   ""))>				 
			<cfif (listfindNocase(session.codeblock,25) GTE 1) OR (listfindNocase(session.codeblock,23) GTE 1)>		
			 
				<TR>		
					<TD style="text-align: left;">
						<INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" onclick="return test();">
					</TD>
					<TD>&nbsp;</TD>
					<TD>&nbsp;</TD>
					<TD>
						<INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save"
						 onClick="location.href='Recurring.cfm'">
					</TD>
				</TR>
				<TR>
					<TD COLSPAN="4" style="font-weight: bold; color: red;">	
						<U>NOTE:</U> You must SAVE to keep information which you have entered! 
					</TD>
				</TR>	
			<cfelse>
				<TR>
					<TD COLSPAN="4" style="font-weight: bold; color: red;">
						<U>NOTE:</U> Contact AR to edit recurring charges for New Resident Fee changes and NRF deferrals. 
					</TD>
				</TR>			
			</cfif>
		<cfelse> 
		 	<cfif isValid("email",session.RDOEmail)>
			<TR>		
				<TD style="text-align: left;"><INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save" VALUE="Save" onclick= "return test();"></TD>
				<TD>&nbsp;</TD>
				<TD>&nbsp;</TD>
				<TD>
					<INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="location.href='Recurring.cfm'">
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="4" style="font-weight: bold; color: red;">
					<U>NOTE:</U> You must SAVE to keep information which you have entered! 
				</TD>
			</TR>	
	 	<tr>
			<td COLSPAN="4">
				The RDO email for this Region (#qryRegion.region#) is #session.RDOEmail#, Division is #qryRegion.division#.
			</td>
		</tr>	 
  	<cfelse>
		<tr>
			<td COLSPAN="4" style=" font-size:large; color:red; text-align:center">
				No RDO or RDO email available for this region  (#qryRegion.region#), contact the Support Desk to update this information to continue. Division is #qryRegion.division#.
			</td>
		</tr>  
	</cfif>					
	</cfif>	
	</CFIF>

</TABLE>
</FORM>

<TABLE>
	<TR><TH COLSPAN="7" STYLE="text-align: left;">	Existing Recurring Charges/Credits:	</TH></TR>
	<TR STYLE="font-weight: bold;">
		<TD STYLE="width: 25%;" NOWRAP>Name</TD>
		<TD STYLE="width: 25%;">Charge/Credit</TD>
		<TD STYLE="text-align: center;">Amount</TD>
		<TD STYLE="text-align: center;">Quantity</TD>
		<TD>Start Date</TD>
		<TD>End Date</TD>
		<TD>Delete</TD>
	</TR>	
	<TR><TD COLSPAN="7"> <HR> </TD></TR>
	<CFIF CurrentRecurring.RecordCount GT 0>
		<cfset bgcolor = "FFFFFF">
		<cfset prevname = "0">
		<CFLOOP QUERY="CurrentRecurring">
			<CFSCRIPT>
				if (CurrentRecurring.bisdaily NEQ '') { qty = 'daily'; } else { qty = CurrentRecurring.iquantity; }
			</CFSCRIPT>
			<cfset currname = "#CurrentRecurring.iTenant_ID#">
			<cfif prevname is not currname><cfif bgcolor is "EEEEEE"><cfset bgcolor="FFFFFF"><cfelse><cfset bgcolor="EEEEEE"></cfif>
			<cfelse></cfif>	
			<TR>
				<TD STYLE="width: 25%;" NOWRAP bgcolor="#bgcolor#"> #CurrentRecurring.cLastName#, #CurrentRecurring.cFirstName#  </TD>
				<TD NOWRAP STYLE="width: 25%;" bgcolor="#bgcolor#">	
					<A HREF="Recurring.cfm?ID=#CurrentRecurring.iTenant_ID#&typeID=#CurrentRecurring.iRecurringCharge_ID#">
					 #CurrentRecurring.cDescription# 
					 </A>		
				</TD>
				<cfif   CurrentRecurring.iChargeType_ID is   "1740" >
					<cfquery  name="qryInstallment" DATASOURCE="#APPLICATION.datasource#">
					select sum (mamount) as Accum
					from invoicedetail inv  
					join invoicemaster im on inv.iInvoiceMaster_ID = im.iInvoiceMaster_ID
					where   inv.dtrowdeleted is null  
					and	itenant_id =  #CurrentRecurring.itenant_id# 
					and inv.ichargetype_id = 1741 
					and im.bMoveOutInvoice is null
					 and im.bFinalized = 1
				</cfquery>
				
				 <cfif qryInstallment.Accum is ''>
				 	<cfset thisAccum = 0> 
				 <cfelse>
				 	<cfset thisAccum = qryInstallment.Accum>
				 </cfif>
				 
				 <cfif CurrentRecurring.mAmtNRFPaid is ''>
				 	<cfset thismAmtNRFPaid = 0> 
				 <cfelse>
				 	<cfset thismAmtNRFPaid = CurrentRecurring.mAmtNRFPaid>
				 </cfif>				 
				 
				 <cfif CurrentRecurring.mAdjNRF is ''>
				 	<cfset thismAdjNRF = 0> 
				 <cfelse>
				 	<cfset thismAdjNRF = CurrentRecurring.mAdjNRF>
				 </cfif>
				
				<cfset rembal =  (thismAdjNRF - thismAmtNRFPaid  - thisAccum)>
				<!--- 	<CFSET nbrpayments = datediff('m',dteffectivestart , dteffectiveend)>
					<cfset nbrpaymentsmade = abs(datediff('m',dteffectivestart ,HouseInfo.dtCurrentTipsMonth)) + 1>
					<cfif nbrpaymentsmade is 0 ><cfset nbrpaymentsmade = 1></cfif> 
					<cfset paymentamt= abs(CurrentRecurring.mAmount/nbrpayments)>
					<cfset ballanceamt = CurrentRecurring.mAmount + (paymentamt * nbrpaymentsmade)> --->
					<TD STYLE="text-align: right;" bgcolor="#bgcolor#">#LSCurrencyFormat(rembal)# </TD>
				<cfelse>
					<TD STYLE="text-align: right;" bgcolor="#bgcolor#">	#LSCurrencyFormat(CurrentRecurring.mAmount)#</TD>
				</cfif>
				<TD STYLE="text-align: center;" bgcolor="#bgcolor#"> <cfif RCbIsDaily is "1">daily<cfelse>#qty#</cfif>	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveStart, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#"> #DateFormat(CurrentRecurring.dtEffectiveEnd, "mm/dd/yyyy")#	</TD>
				<TD bgcolor="#bgcolor#">
				<!--- 	<cfif (CurrentRecurring.iChargeType_ID is not "1737"
				 		and CurrentRecurring.iChargeType_ID is not "1740" 
						and CurrentRecurring.iChargeType_ID is not "1741")>
				 --->
				<cfif (CurrentRecurring.iChargeType_ID is not "1737" and CurrentRecurring.iChargeType_ID is not "1740" )>
					<cfif (listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1)>
						<!--- Sr. Acct or AR --->
						<INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" 
						onClick="self.location.href='DeleteRecurring.cfm?typeID=#CurrentRecurring.iRecurringCharge_ID#'">
					</cfif>
                </cfif>
                </TD>				
			</TR>
			<cfset prevname = "#CurrentRecurring.iTenant_ID#">	
		</CFLOOP>
	<CFELSE> <TD COLSPAN=7> There are no recurring charges at this time. </TD> </TR></CFIF>
		
</TABLE>

<BR>
</CFOUTPUT>
<SCRIPT>
	try{ dayslist(document.forms[0].MonthStart,document.forms[0].DayStart,document.forms[0].YearStart); }
	catch(exception){ /*no action*/ }
</SCRIPT>
<CFINCLUDE TEMPLATE="../../footer.cfm">

