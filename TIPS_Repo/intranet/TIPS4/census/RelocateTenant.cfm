<!----------------------------------------------------------------------------------------------
| DESCRIPTION - census/RelocateTenant.cfm                                                      |
|----------------------------------------------------------------------------------------------|
| CALLED BY - census/TrackTenantStatus.cfm                                                     |
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
| mlaw       | 07/26/2006 | Create an initial relocate tenant page                             |
----------------------------------------------------------------------------------------------->

<style type="text/css">
<!--
body {
	background-color: #FFFFCC;
}
-->
</style>

<CFOUTPUT>
	<CFIF FindNoCase("TIPS4",getTemplatePath(),1) GT 0>
		<LINK REL=StyleSheet TYPE="Text/css"  HREF="//#SERVER_NAME#/intranet/Tips4/Shared/Style2.css">
	<CFELSE>
		<LINK REL="STYLESHEET" TYPE="text/css" HREF="//#SERVER_NAME#/intranet/TIPS/Tip30_Style.css">
	</CFIF>
</CFOUTPUT>

<CFOUTPUT>
<!--- ==============================================================================
Retrieve database TimeStamp
=============================================================================== --->
<CFQUERY NAME="qTimeStamp" DATASOURCE="#APPLICATION.datasource#">
	SELECT getdate() as TimeStamp
</CFQUERY>
<CFSET TimeStamp = CreateODBCDateTime(qTimeStamp.TimeStamp)>

<!--- ==============================================================================
Retrieve list of Available Apartments (less than 2 people in an Apartment
=============================================================================== --->
<!--- MLAW 02/28/2006 fix relocate drop down list --->
<CFQUERY NAME="Available" DATASOURCE="#APPLICATION.datasource#">
	SELECT 	
		ad.iAptAddress_ID
		,ad.cAptNumber
		,ap.cDescription
		,c.cChargeSet
		,(select count(t.itenant_id)
			from tenantstate ts
			join tenant t 
			on t.itenant_id = ts.itenant_id 
			and ts.dtrowdeleted is null
			where t.dtrowdeleted is null 
			  and ts.iaptAddress_id = ad.iaptaddress_id 
			  and ts.itenantstatecode_id = 2) as occupancy
		,c.*
	FROM APTADDRESS AD (NOLOCK)
	join APTTYPE AP (NOLOCK) 
	ON (AP.iAptType_ID = AD.iAptType_ID 
	AND AP.dtRowDeleted IS NULL)
	join houseproductline HP
	on HP.ihouseproductline_ID = AD.ihouseproductline_ID
	and HP.ihouse_ID = AD.ihouse_ID
	join charges c 
	on c.iapttype_id = ap.iapttype_id 
	and c.iproductline_ID = HP.iproductline_ID
	and c.dtrowdeleted is null 
	and getdate() between dteffectivestart and dteffectiveend
	and c.ihouse_id = ad.ihouse_id 
	and c.iresidencytype_id = 1
	join chargetype ct 
	on ct.ichargetype_id = c.ichargetype_id 
	and ct.dtrowdeleted is null 
	and ct.bisdaily is not null
	WHERE 
		AD.dtRowDeleted IS NULL 
	AND ad.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY ad.cAptNumber
</CFQUERY>
<!--- ==============================================================================
Retrieve list of Tenants in a Moved In State
=============================================================================== --->
<CFQUERY NAME="TenantList" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	distinct  count(distinct IM.iInvoiceMaster_ID) as moveoutcount
			,T.iTenant_ID ,T.cLastName ,T.cFirstName ,T.cSolomonKey, TS.iresidencytype_id, T.cChargeSet
	FROM	Tenant	T (NOLOCK)
	JOIN	TenantState	TS (NOLOCK) ON T.iTenant_ID = TS.iTenant_ID
	LEFT JOIN InvoiceDetail INV (NOLOCK) ON (T.iTenant_ID = INV.iTenant_ID AND INV.dtRowDeleted IS NULL)
	LEFT JOIN InvoiceMaster IM (NOLOCK) ON (IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NOT NULL)
	WHERE T.dtRowDeleted IS NULL AND iTenantStateCode_ID = 2
	AND TS.dtMoveIN IS NOT NULL  AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND T.itenant_ID = #url.TenantID#
	GROUP BY T.cLastName, T.iTenant_ID, T.cFirstName, T.cSolomonKey, TS.iresidencytype_id,T.cChargeSet
	ORDER BY T.cLastName, T.iTenant_ID, T.cFirstName, T.cSolomonKey, TS.iresidencytype_id
</CFQUERY>

<CFIF TenantList.moveoutcount gt 0>
  A move out invoice for this resident has been found.
  <p>
  You may not relocate residents that are in the process of moving out.
  <p>
  Please go to the move out process and indicate that this resident is not moving out before relocating this resident.
  <CFABORT>
</CFIF>

<!--- ==============================================================================
Do Javascript that figures out the selected tenant's current room and rate
=============================================================================== --->
	<!--- ==============================================================================
	Retrieve house second tenant rate
	=============================================================================== --->
	<CFQUERY NAME='qSecondRate' DATASOURCE='#APPLICATION.datasource#'>
		select *
		from charges c
		join chargetype ct on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null
			and bisrent is not null and bisdaily is not null and c.ioccupancyposition <> 1
			and c.ihouse_id = #SESSION.qSelectedHouse.ihouse_id#
		where c.dtrowdeleted is null
		and getdate() between c.dteffectivestart and c.dteffectiveend
	</CFQUERY>

	<!--- ==============================================================================
	Retrieve any rent recurring for this tenant
	=============================================================================== --->
	<CFQUERY NAME='qRecurring' DATASOURCE='#APPLICATION.datasource#'>
		select rc.irecurringcharge_id, rc.itenant_id, rc.cdescription, rc.mamount, c.cChargeSet
		from recurringcharge rc (NOLOCK)
		join tenant t (NOLOCK) on t.itenant_id = rc.itenant_id  and t.dtrowdeleted is null
		join tenantstate ts (NOLOCK) on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null and ts.itenantstatecode_id = 2
		join charges c (NOLOCK) on c.icharge_id = rc.icharge_id
		join chargetype ct (NOLOCK) on ct.ichargetype_id = c.ichargetype_id and ct.bisrent is not null
		where rc.dtrowdeleted is null
		and t.ihouse_id = #SESSION.qSelectedHouse.ihouse_id#
		and t.itenant_ID = #url.TenantID# 
		and getdate() between rc.dteffectivestart and rc.dteffectiveend
	</CFQUERY>

	<CFSET tenanteventhandler="onBlur='recurr(this,document.forms[0].iAptAddress_ID);'">
	<CFSET apteventhandler="onClick='recurr(document.forms[0].iTenant_ID,this);'">
	
	<!--- MLAW 03/01/2006 - Only AR Admin can change the Amount --->
	<cfif ListFindNoCase(session.groupid, 240, ",") gt 0>
		<cfset read_only = "">
	<cfelse>
	    <cfset read_only = " readonly='true' ">
	</cfif>
	
	<SCRIPT>
		function recurr(obj,apt)
		{
			//set a variable equal to the selected tenants charge set
			var chargeSet = GetChargeSetForTenant();

			//holds the residency type id
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
			//this will hold the html for the reoccuring charge found for a tenant
			var z = '';
			//this will hold the html for the charge price for the room
			var c = '';

			//if there is no charge displayed hide the recurringcharge area
			if (obj.value == "")
			{
				document.all['recurringchange'].style.display="none";
				return false;
			}

			//clear the reoccuringcharge section html
			document.all['recurringchange'].innerHTML='';

			<!--- loop through the recurring charge query and show the matching charge on the page --->
			<CFLOOP QUERY='qRecurring'>
				
				//<CFIF qRecurring.currentrow eq 1>
					//if (obj.value == #qRecurring.itenant_id#)
					//{
						document.all['recurringchange'].style.display="inline";
						z="<B> <U>Recurring Charge was found for:</U> <BR> #qRecurring.cdescription# at #LSCurrencyFormat(isBlank(qRecurring.mAmount,0))# </B> <BR>";
						z+="<INPUT TYPE=hidden NAME='irecurringcharge_id' VALUE='#qRecurring.irecurringcharge_id#'>";
					//}
				//<CFELSE>
					//else if (obj.value == #qRecurring.itenant_id#)
					//{
						document.all['recurringchange'].style.display="inline";
						z="<B> <U>Recurring Charge was found for:</U> <BR> #qRecurring.cdescription# at #LSCurrencyFormat(isBlank(qRecurring.mAmount,0))# </B> <BR>";
						z+="<INPUT TYPE=hidden NAME='irecurringcharge_id' VALUE='#qRecurring.irecurringcharge_id#'>";
					//}
				//</CFIF>
			</CFLOOP>
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
							STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(rount(this.value));' #read_only#></I></B>";
						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#Available.icharge_id#'>";
					}
				<CFELSE>
					else if (apt.value == #isBlank(Available.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
					{
						document.all['recurringchange'].style.display="inline";
						c="<B><I STYLE='color: red;'>Change to #Available.cdescription# $ ";
						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(Available.mAmount,'999999.00-'))#' \
						STYLE='text-align: right; color: red; font-weight: bold; italic;' onBlur='this.value=cent(round(this.value));' #read_only#></I></B>";
						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#Available.icharge_id#'>";
					}
				</CFIF>
			</CFLOOP>
			else
			{
				document.all['recurringchange'].style.display="none";
			}

			document.all['recurringchange'].innerHTML=z+c;
		}
	</SCRIPT>
	<CFSCRIPT>
		if (session.cbillingtype eq 'd') { dailyfilter="is not null"; }
		else { dailyfilter="is null"; }
	</CFSCRIPT>
	<CFQUERY NAME="qRoomAndBoard" DATASOURCE="#APPLICATION.datasource#">
		select c.icharge_id, c.cdescription, c.mAmount, c.iresidencytype_id,
			isNull(c.isleveltype_id,0) as isleveltype_id, c.iOccupancyPosition
		from charges c
		join chargetype ct on ct.ichargetype_id = c.ichargetype_id and ct.dtrowdeleted is null
		where c.dtrowdeleted is null
		and c.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		and ct.bisrent is not null and ct.bSLevelType_ID is null and ct.bisdaily #dailyfilter#
		and getdate() between c.dteffectivestart and c.dteffectiveend
	</CFQUERY>

	<!--- <CFSCRIPT>tenanteventhandler=""; apteventhandler="";</CFSCRIPT> --->
<!--- include the new javascript to show only the correct charge sets --->
<cfinclude template="../relocate/js_ChargeMenu.cfm">

<!--- Include intranet header 
<CFINCLUDE TEMPLATE="../../header.cfm">--->

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT>
	function redirect() { window.location = "FinalizeRelocate.cfm"; }
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

<!--- Include Shared JavaScript --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<!--- Page Title --->
<TITLE> Relocate Resident </TITLE>
<!--- <body onload='PopulateChargeDropDown()' #tenanteventhandler#" #apteventhandler#>
'recurr(document.forms[0].iTenant_ID,this);' --->
<body onload='PopulateChargeDropDown()';'recurr(this,document.forms[0].iAptAddress_ID)'>
<!--- Include House Header 
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
--->

<CFFORM ACTION="../census/RelocateUpdate.cfm" METHOD="POST">
<TABLE>
	<TR><TH COLSPAN="4">Relocate Resident	</TH></TR>
	<TR>
		<TD>Please select the resident that you would like to Relocate.</TD>
		<TD COLSPAN=2></TD>
		<TD>
			<!--- 			
			<SELECT NAME="iTenant_ID" onChange='moveoutinvoicecheck(this);PopulateChargeDropDown()' #tenanteventhandler#>
				<OPTION VALUE="">Choose Resident</OPTION>
				<CFLOOP QUERY="TenantList">
					<OPTION Value="#TenantList.iTenant_ID#"> #TenantList.cLastName#, #TenantList.cFirstName# (#TenantList.cSolomonKey# )</OPTION>
				</CFLOOP>
			</SELECT> 
			--->
			<INPUT name="iTenant_ID" type="text" value="#url.TenantID#" readonly="true">
		</TD>
	</TR>
	<TR>
		<TD>Relocate resident to Room: </TD> <TD COLSPAN=2></TD>
		<TD>
			<SELECT NAME="iAptAddress_ID" #apteventhandler#>
				<option value="">Select...</option>
			</SELECT>
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
						document.forms[0].Month.value = #Month(TimeStamp)#; document.forms[0].Day.value = #Day(TimeStamp)#;
						return false;
					}
				}
			</script>
			<SELECT NAME="Month" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);" onBlur="effectivevalidate();">
				<CFLOOP INDEX="I" FROM="1" TO="12" STEP="1"><CFIF I EQ Month(Now())> <CFSET Selected='Selected'> <CFELSE> <CFSET Selected=''> </CFIF>
					<OPTION VALUE="#I#" #Selected#> #I# </OPTION>
				</CFLOOP>
			</SELECT>
			/
			<SELECT NAME="Day" onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);" onBlur="effectivevalidate();">
				<CFLOOP INDEX="I" FROM="1" TO="31" STEP="1"><CFIF I EQ Day(Now())> <CFSET Selected='Selected'> <CFELSE>	<CFSET Selected=''>	</CFIF>
					<OPTION VALUE="#I#" #SELECTED#> #I# </OPTION>
				</CFLOOP>
			</SELECT>
			/
			<INPUT TYPE=TEXT NAME='Year' VALUE="#Year(now())#" STYLE='text-align: center;' SIZE=4 MAXLENGTH=4 onKeyUP="this.value=Numbers(this.value)" onBlur="YearTest(this); effectivevalidate();" ReadOnly onChange="dayslist(document.forms[0].Month, document.forms[0].Day, document.forms[0].Year);">
		</TD>
	</TR>
	<TR>
		<TD><INPUT NAME="save" TYPE="submit" CLASS="SaveButton" onMouseOver="recurr(this,document.forms[0].iAptAddress_ID)" VALUE="Save" ></TD><TD COLSPAN=2></TD>
		<TD><INPUT TYPE="button" NAME="Don't Save" VALUE="Don't Save" CLASS="DontSaveButton" onClick="redirect()"></TD>
	</TR>
	<TR><TD COLSPAN="4" style="font-weight: bold; color: red;">	<U>NOTE:</U> You must SAVE to keep information which you have entered! </TD></TR>
</TABLE>
</CFFORM>
</body>
<CFINCLUDE TEMPLATE="../../footer.cfm">
</CFOUTPUT>