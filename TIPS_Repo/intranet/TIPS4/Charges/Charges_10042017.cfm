<!------------------------------------------------------------------------------------------------
|                                    HISOTRY                                                     |
|------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                          |
|------------|------------|----------------------------------------------------------------------|
| ranklam    | 08/25/2005 | Changed menu system for adding a transaction by removing old code.   |
|                         | and inserting a new menu system from dsp_ChargeMenu.cfm because      |
|                         | charge sets were not being set properly.  I also removed a line of   |
|                         | code at the bottom of the page that showed the charge type dropdown  |
|                         | if there is a url.added variable.                                    |
| MLAW       | 07/03/2006 | Change the Applies to Peiod Year field to be a drop down box with    |
|            |            | last 2 years & current year.  User cannot enter future date          |
| MLAW       | 09/21/2006 | Add "WI" state code into Additional Query, we allow WI to enter      |
|            |            | security deposit                                                     |
| MLAW       | 10/16/2006 | Remove DATASOURCE="QUERY"  - upgrade to ColdFusion MX                |
| ranklam    | 10/16/2006 | Changed qqTenants to order by fullname                               |
| MLAW       | 07/17/2006 | Add "MI" state code into Additional Query, we allow MI to enter      |
|            |            | security deposit                                                     |
|rschuette   | 07/14/2008 | Restricted input on the Amount to just 0-9, eliminating negative     |
|                         | value input (-,(),etc). Negative values will only be input by AR     |
| Jaime Cruz | 06/08/2009 | Modified to fix Medicaid billing issue. 						   	 |
| Sathya     | 05/25/2010 | Project 20933 changed the query not to display the late fee that was |
|            |            |  added                                                               |
| Sathya     | 09/09/2010 | Project 20933 Part-D restricted the late fee chargetype_id to be     |
|            |            | from being modified.                                                 |
| SFarmer    | 03/04/2016 | added 'and CT.iChargeType_ID <> 1740 ' to Additional query           |
|            |            | 'AND	CT.iChargeType_ID <> 1740' added to chargetypes query        |
------------------------------------------------------------------------------------------------->
<CFOUTPUT>

<!--- Try to catch any shortcuts (no user session variables) send them to portsl --->
<CFIF NOT IsDefined("SESSION.qSelectedHouse.iHouse_ID") AND (IsDefined("SESSION.UserID") AND SESSION.USERID EQ "") OR NOT IsDefined("SESSION.UserID")>
	<CFLOCATION URL="http://#server_name#/ALC-home/Portal/ALC%20Apps/">
</CFIF>

<CFSET TemplateName='Charges.cfm'>

<!--- =============================================================================================
JavaScript to redirect user to specified template if the Don't save button is pressed
============================================================================================= --->
<SCRIPT> function redirect() { window.location = "#TemplateName#";} </SCRIPT>

<!--- ==============================================================================
Include Shared JavaScript
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">
=============================================================================== --->
<script language="javascript" type="text/javascript" src="../Shared/JavaScript/global.js"></script>

<CFSET TIPSPeriod = Year(SESSION.TIPSMonth) & DateFormat(SESSION.TIPSMonth,"mm")>
<!--- MLAW 06/29/06 Set TIPSDATE --->
<CFSET TIPSYEAR = Year(SESSION.TIPSMonth)>
<CFSET TIPSMONTH = DateFormat(SESSION.TIPSMonth,"mm") - 1>
<CFSET TIPSDAY = 1>

<SCRIPT LANGUAGE="JavaScript">
  function validatedate()
  {
	   var monthDropDown = document.getElementsByName('AppliesToMonth')[0];  
	   var AppliesMonth = monthDropDown.options[monthDropDown.selectedIndex].value;
	   var AppliesMonth = AppliesMonth - 1;
	   
	   var yearDropDown = document.getElementsByName('AppliesToYear')[0];  
	   var AppliesYear = yearDropDown.options[yearDropDown.selectedIndex].value;
	   
	   var AppliesDay = 1;
	
	   var AppliesDate = new Date(AppliesYear, AppliesMonth, AppliesDay);
	   
	   var TipsDate = new Date(#TIPSYEAR#, #TIPSMONTH#, #TIPSDAY#);
	   
	   if (AppliesDate > TipsDate)
	   {
	    	alert ('The Apply to Period cannot be greater than Current Tips Month!');
	  		return false;
	   }
		//alert (AppliesDate);
	    //alert (TipsDate);
        return true;
  }
  
  function numbers(e)
  {		//  Robert Schuette project 23853  - 7-14-08
  	  // removes House ability to enter negative values for the Amount textbox,
  	//  only AR will enter in negative values.  Added extra: only numeric values.
   //alert('Javascript is hit for test.')
  	keyEntry = window.event.keyCode;
  		if((keyEntry < '46') || (keyEntry > '57') ||( keyEntry == '47')) {return false;  }
  }
</script>

<!--- ==============================================================================
Retrieve all Tenants who are in a status of Moved IN
=============================================================================== --->
<CFQUERY NAME="TenantList" DATASOURCE="#APPLICATION.datasource#" DBTYPE="ODBC" CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
	SELECT 
		*
	FROM 
		Tenant T (NOLOCK)
	JOIN 
		TenantState TS (NOLOCK) ON (T.iTenant_ID = TS.iTenant_ID 
			AND 
		TS.dtRowDeleted IS NULL 
			AND 
		TS.iTenantStateCode_ID = 2)
	JOIN 
		AptAddress AD (NOLOCK) ON (TS.iAptAddress_ID = AD.iAptAddress_ID 
			AND 
		AD.dtRowDeleted IS NULL)
	WHERE 
		T.dtRowDeleted IS NULL 
	AND 
		TS.iAptAddress_ID IS NOT NULL
	AND 
		T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	ORDER BY 
		T.cLastName, 
		T.cFirstName, 
		AD.cAptNumber
</CFQUERY>

<!--- ==============================================================================
Retrive this months charge types and totals
=============================================================================== --->
<CFQUERY NAME="qTypesTotals" DATASOURCE="#APPLICATION.datasource#">
<!---
	SELECT	INV.iChargeType_ID, SUM(iQuantity * mAmount) as Total
	FROM InvoiceDetail INV  (NOLOCK)
	JOIN Tenant T (NOLOCK) ON T.iTenant_ID = INV.iTenant_ID AND T.dtRowDeleted IS NULL AND T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		AND INV.dtRowDeleted IS NULL
	JOIN InvoiceMaster IM (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		AND IM.dtRowDeleted IS NULL
		AND im.bfinalized is null and IM.cAppliesToAcctPeriod = '#DateFormat(SESSION.TIPSMonth,"yyyymm")#'
		AND IM.bMoveInInvoice IS NULL AND im.bMoveOutInvoice IS NULL
	GROUP BY iChargeType_ID
--->

SELECT	INV.iChargeType_ID, SUM(iQuantity * mAmount) as Total
FROM invoicemaster im (NOLOCK)
join invoicedetail inv on inv.iinvoicemaster_id = im.iinvoicemaster_id
	and inv.dtrowdeleted is null
	and im.dtrowdeleted is null
	AND im.bfinalized is null and IM.cAppliesToAcctPeriod = '200507'
	AND IM.bMoveInInvoice IS NULL AND im.bMoveOutInvoice IS NULL
	and left(im.csolomonkey,3) = '#session.housenumber#'
GROUP BY iChargeType_ID

</CFQUERY>

<!--- MLAW 10/16/2006 Remove DATASOURCE="QUERY"  - upgrade to ColdFusion MX --->
<CFQUERY NAME="TotalRev" DBTYPE="Query">
SELECT SUM(total) as TotalRevenue FROM qTypesTotals
</CFQUERY>

<!--- ==============================================================================
Retrieve all current charges for this house
=============================================================================== --->
<CFQUERY NAME="qCurrentCharges" DATASOURCE="#APPLICATION.datasource#">
	SELECT	inv.cdescription, inv.ichargetype_id
	FROM Tenant T (NOLOCK)
	JOIN TenantState TS (NOLOCK) ON ts.iTenant_ID = t.iTenant_ID AND TS.dtRowDeleted IS NULL
		and t.dtrowdeleted is null and t.ihouse_id = #SESSION.qSelectedHouse.iHouse_ID#
		AND TS.iTenantStateCode_ID = 2
	join 	InvoiceDetail INV (NOLOCK) on inv.itenant_id = t.itenant_id and inv.dtrowdeleted is null
	JOIN	InvoiceMaster IM (NOLOCK) ON INV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		AND IM.dtRowDeleted is null and im.bfinalized is null
		AND IM.bMoveInInvoice IS NULL AND IM.bMoveOutInvoice IS NULL
		AND IM.cAppliesToAcctPeriod = '#DateFormat(SESSION.TipsMonth,"yyyymm")#'
		and left(im.csolomonkey,3) = '#session.housenumber#'
</CFQUERY>


<CFQUERY NAME="qCurrentChargeTypes" DBTYPE="Query">
	SELECT	Distinct cDescription, iChargeType_ID FROM qCurrentCharges
</CFQUERY>
<CFSCRIPT>
	QueryColList = ValueList(qCurrentChargeTypes.cDescription);
	QuotedColList = QuotedValueList(qCurrentChargeTypes.cDescription);
	QueryChargeTypeIDList = ValueList(qCurrentChargeTypes.iChargeType_ID);
</CFSCRIPT>

<CFIF IsDefined("form.iTenant_ID") OR IsDefined("url.ID")>
	<!--- ==============================================================================
	If iTenant_ID is passed as a form field retrieve Chosen Persons Information
	=============================================================================== --->
<!--- 	25575 - rts - 6/4/2010 - respite info --->
	<CFQUERY NAME="Tenant" DATASOURCE="#APPLICATION.datasource#">
		SELECT t.*, ts.iResidencyType_ID 
		FROM Tenant t
		Join TenantState ts on (ts.iTenant_ID = t.iTenant_ID)
		WHERE t.iTenant_ID = <CFIF IsDefined("url.ID")> #url.ID# <CFELSEIF IsDefined("form.iTenant_ID")> #form.iTenant_ID# </CFIF>
	</CFQUERY>
	<cfset resType = Tenant.iResidencyType_ID>
<!--- end 25575 --->
	<!--- ==============================================================================
	Retrieve current involve (if it exists)
	=============================================================================== --->
<!--- 	25575 - rts - 6/4/2010 - respite billing, get hte right data for respites --->
	<cfif resType neq 3>
		<CFQUERY NAME="InvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	*
			FROM InvoiceMaster IM (NOLOCK)
			WHERE cSolomonKey = '#Tenant.cSolomonKey#'
			AND IM.dtRowDeleted IS NULL AND bMoveInInvoice IS NULL AND bMoveOutInvoice IS NULL AND bFinalized IS NULL
			AND cAppliesToAcctPeriod = '#TIPSPeriod#'
		</CFQUERY>
	<cfelse>
		<CFQUERY NAME="InvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
			SELECT	IM.iInvoiceMaster_ID, IM.iInvoiceNumber
			FROM InvoiceMaster IM 
			WHERE IM.cSolomonKey = '#Tenant.cSolomonKey#'
			and IM.iInvoiceMaster_ID = (select max(im2.iInvoiceMaster_ID) 
									from InvoiceMaster im2
									where im2.dtRowDeleted is null
									AND im2.bFinalized IS NULL
									and im2.cSolomonKey = '#Tenant.cSolomonKey#')
			AND IM.dtRowDeleted IS NULL AND IM.bMoveInInvoice IS NULL AND IM.bFinalized IS NULL
			<!--- AND IM.cAppliesToAcctPeriod = '#TIPSPeriod#' --->
		</CFQUERY>
		<cfset RespiteInvoiceMSTRID = InvoiceNumber.iInvoiceMaster_ID>
		<cfquery NAME="RespInvoiceInfo" DATASOURCE="#APPLICATION.datasource#">
				select datediff(dd,im.dtInvoiceStart,im.dtInvoiceEnd)+ 1 as Days
				from InvoiceMaster im
				where im.iInvoiceMaster_ID = #InvoiceNumber.iInvoiceMaster_ID#
		</cfquery>
	</cfif>

<!--- ==============================================================================
Create Invoice if on does not exists
=============================================================================== --->
	<!--- 25575 - RTS - do not add invoice this way for respites --->
	<CFIF InvoiceNumber.RecordCount EQ 0 and resType neq 3>
		<CFTRANSACTION>

			<CFQUERY NAME = "GetNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	iNextInvoice FROM HouseNumberControl WHERE iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</CFQUERY>

			<CFSET iInvoiceNumber = '#SESSION.HouseNumber#' & #GetNextInvoice.iNextInvoice#>
			<CFSET NextInvoice = GetNextInvoice.iNextInvoice + 1>

			<CFQUERY NAME = "UpdateNextInvoice" DATASOURCE = "#APPLICATION.datasource#">
				UPDATE 	HouseNumberControl
				SET		iNextInvoice = #Variables.NextInvoice#
				WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</CFQUERY>

			<CFQUERY NAME = "LastInvoiceMaster" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	Max(iInvoiceMaster_ID) as iInvoiceMaster_ID
				FROM 	InvoiceMaster
				WHERE	cSolomonKey = '#Tenant.cSolomonKey#'
				AND 	bFinalized IS NOT NULL
			</CFQUERY>

			<!---
				SELECT	SUM(mAmount) as InvoiceTotal FROM InvoiceDetail
			--->
			<CFQUERY NAME = "LastTotal" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	mInvoiceTotal as InvoiceTotal FROM InvoiceMaster
				<CFIF LastInvoiceMaster.iInvoiceMaster_ID NEQ "">
					WHERE iInvoiceMaster_ID = #LastInvoiceMaster.iInvoiceMaster_ID#
				<CFELSE>
					WHERE iInvoiceMaster_ID = 0
				</CFIF>
				AND	dtRowDeleted IS NULL
			</CFQUERY>

			<CFQUERY NAME = "WriteInvoiceMaster" DATASOURCE ="#APPLICATION.datasource#">
				declare @lastend datetime

				select @lastend = im.dtInvoiceEnd
				from invoicedetail inv
				join invoicemaster im on im.iinvoicemaster_id = inv.iinvoicemaster_id and im.dtrowdeleted is null
					and inv.dtrowdeleted is null
				where inv.itenant_id = #Tenant.iTenant_id#
				and im.bfinalized is not null
				and im.cappliestoacctperiod =
				( 	select max(cappliestoacctperiod)
					from invoicemaster
					where csolomonkey = im.csolomonkey
					and bfinalized is not null
				)

				INSERT INTO InvoiceMaster
				(	iInvoiceNumber, cSolomonKey, bMoveInInvoice, bMoveOutInvoice, bFinalized, cAppliesToAcctPeriod,
					cComments, mInvoiceTotal, mLastInvoiceTotal, dtInvoiceStart, dtInvoiceEnd, dtAcctStamp,
					iRowStartUser_ID, dtRowStart
				)VALUES(
					'#Variables.iInvoiceNumber#', '#Tenant.cSolomonKey#',
					NULL, NULL,
					NULL,
					<CFSET cAppliesToAcctPeriod = #Year(SESSION.TIPSMonth)# & #DateFormat((SESSION.TipsMonth),"mm")#>
					'#Variables.cAppliesToAcctPeriod#',
					NULL, NULL,
					<CFIF LastTotal.InvoiceTotal NEQ "">	#isBlank(LastTotal.InvoiceTotal,0)#,	<CFELSE> 0,	</CFIF>
					isNull(@lastend,getdate()),	NULL,
					#CreateODBCDate(SESSION.AcctStamp)#,
					-2,
					GetDate()
				)
			</CFQUERY>
			<!--- #SESSION.UserID#, --->
			
			<CFQUERY NAME = "InvoiceNumber" DATASOURCE = "#APPLICATION.datasource#">
				SELECT * FROM InvoiceMaster IM WHERE cSolomonKey = '#Tenant.cSolomonKey#'
				AND	IM.dtRowDeleted IS NULL AND bMoveInInvoice IS NULL AND bMoveOutInvoice IS NULL AND bFinalized IS NULL
			</CFQUERY>
		</CFTRANSACTION>
	<CFELSE>
		<CFSET iInvoiceNumber = InvoiceNumber.iInvoiceNumber>
		<CFSET iInvoiceMaster_ID = InvoiceNumber.iInvoiceMaster_ID>
	</CFIF>

	<!--- ==============================================================================
	Retrieve information from Invoice Detail that exists
	=============================================================================== --->
	<CFQUERY NAME="TenantDetail" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	Inv.*, INV.cDescription AS cDescription,
				CT.cDescription AS TypeDescription, CT.bIsModifiableDescription,
				CT.bIsModifiableAmount, CT.bIsModifiableQty, CT.bIsMedicaid, CT.bIsRent, CT.bisDaily, CT.bSLevelType_id
		FROM InvoiceDetail INV (NOLOCK)
		JOIN InvoiceMaster IM  (NOLOCK) ON (IM.iInvoiceMaster_ID = INV.iInvoiceMaster_ID AND IM.dtRowDeleted IS NULL AND IM.bFinalized IS NULL)
		LEFT JOIN	ChargeType CT (NOLOCK) ON CT.iChargeType_ID = INV.iChargeType_ID
		WHERE INV.dtRowDeleted IS NULL
		AND IM.cAppliesToAcctPeriod = '#DateFormat(SESSION.TIPSMonth,"yyyymm")#'
		<CFIF IsDefined("url.ID") OR (IsDefined("url.Detail") AND url.Detail NEQ "")>
			AND INV.iTenant_ID = #url.ID#
		<CFELSEIF IsDefined("form.iTenant_ID")>
			AND INV.iTenant_ID = #form.iTenant_ID#
		</CFIF>

		<CFIF IsDefined("url.Detail") AND url.Detail NEQ "">
			AND	INV.iInvoiceDetail_ID = #url.Detail#
		<CFELSEIF IsDefined("url.Detail") AND url.Detail EQ "">
			AND CT.iChargeType_ID = #url.TypeID#
		</CFIF>
	</CFQUERY>
</CFIF>

<!--- ==============================================================================
Retrieve specific Charge information
=============================================================================== --->
<CFQUERY NAME = "Charge" DATASOURCE =  "#APPLICATION.datasource#">
	SELECT	C.*, CT.*, C.cDescription as ChargeDescription
	FROM Charges C (NOLOCK)
	JOIN ChargeType CT (NOLOCK)	ON	CT.iChargeType_ID = C.iChargeType_ID
	<CFIF IsDefined("form.iCharge_ID")>
		WHERE C.iCharge_ID = #form.iCharge_ID#
	<CFELSEIF isDefined("url.Detail") AND url.Detail NEQ "">
		WHERE C.iCharge_ID = #url.detail#
	<CFELSE>
		WHERE C.iCharge_ID = 0
	</CFIF>
</CFQUERY>


<!--- ==============================================================================
Retrieve list of all available credits (discounts)
=============================================================================== --->

#SESSION.qSelectedHouse.cstatecode#

<CFQUERY NAME="Additional" DATASOURCE="#APPLICATION.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 0, 2, 0)#">
	SELECT	SLT.cDescription as Level, SLT.cSLevelTypeSet as cSet, C.cDescription as cDescription, C.iCharge_ID, C.iChargeType_ID, C.mAmount, C.iQuantity,
			CT.cDescription as TypeDescription, CT.iChargeType_ID, C.iHouse_ID, CT.bIsDeposit, CT.bIsDaily, C.cChargeSet
	FROM ChargeType CT (NOLOCK)
	LEFT JOIN Charges C	(NOLOCK) ON (C.iChargeType_ID = CT.iChargeType_ID AND C.dtRowDeleted IS NULL
		AND C.dtEffectiveStart <= getDate() AND C.dtEffectiveEnd >= getDate() )
		and (	(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR (C.iHouse_ID IS NULL AND CT.bIsDeposit IS NULL AND (0=(SELECT count(iCharge_ID) FROM Charges WHERE dtRowDeleted IS NULL AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND iChargeType_ID = CT.iChargeType_ID and getdate() between dteffectivestart and dteffectiveend) AND CT.bIsDeposit IS NULL)))
				OR (C.iHouse_ID IS NULL AND (0=(SELECT count(iCharge_ID) FROM Charges WHERE dtRowDeleted IS NULL AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND cdescription = c.cdescription AND iChargeType_ID = CT.iChargeType_ID and getdate() between dteffectivestart and dteffectiveend and CT.bisdeposit is null)))
			)
	LEFT JOIN SLevelType SLT (NOLOCK) ON (SLT.iSLevelType_ID = C.iSLevelType_ID AND SLT.dtRowDeleted IS NULL)
	WHERE	ct.dtrowdeleted is null
		AND	C.iCharge_ID IS NOT NULL AND CT.bIsCharges is not null 
 		and CT.iChargeType_ID <> 1740 
<!--- Following lines commented by Jaime Cruz to allow other houses to see Deposit Type charges --->
<!---	<CFIF SESSION.qSelectedHouse.cstatecode neq 'OR' AND  SESSION.qSelectedHouse.cstatecode neq 'WI' AND SESSION.qSelectedHouse.cstatecode neq 'MI'> and ct.bisdeposit is null </CFIF>
--->
<!--- End of Comment by Jaime Cruz --->
<!---	<CFIF SESSION.qSelectedHouse.cstatecode eq 'OR' OR SESSION.qSelectedHouse.cstatecode eq 'WI'>
		AND CT.bisdeposit is not null
	<CFELSE>
		AND CT.bisdeposit is null
	</CFIF>
--->
	<CFIF	IsDefined("form.iChargeType_ID")>
		AND	CT.iChargeType_ID = #form.iChargeType_ID#
	<CFELSEIF IsDefined("url.typeID") AND Url.TypeID NEQ "">
		AND	CT.iChargeType_ID = #url.typeID#
	</CFIF>
	ORDER BY C.cDescription
</CFQUERY>

<SCRIPT>
	function validatecharge(){
		if (document.forms[0].icharge_id.value == "0"){ alert('Please choose a charge from the list'); return false; }
	}
</SCRIPT>


<CFIF IsDefined("form.iCharge_ID") OR IsDefined("url.detail")>
	<!--- ==============================================================================
	Retrieve specific Charge information
	=============================================================================== --->
	<CFQUERY NAME="Charge" DATASOURCE =  "#APPLICATION.datasource#">
		SELECT	C.*, CT.*, C.cDescription as ChargeDescription
		FROM 	Charges C (NOLOCK)
		JOIN 	ChargeType CT (NOLOCK)	ON CT.iChargeType_ID = C.iChargeType_ID
		WHERE	C.iCharge_ID = <CFIF IsDefined("form.iCharge_ID")>	#form.iCharge_ID# <CFELSEIF url.Detail NEQ ""> #url.detail# <CFELSE> 0 </CFIF>
	</CFQUERY>
</CFIF>


<!--- ==============================================================================
Retrieve list of Charge Types
=============================================================================== --->
<CFQUERY NAME="ChargeTypes" DATASOURCE = "#APPLICATION.datasource#" CACHEDWITHIN="#CreateTimeSpan(0, 0, 0, 30)#">
	SELECT	distinct CT.*
	FROM ChargeType CT (NOLOCK)
	JOIN Charges C (NOLOCK)	ON	(C.iChargeType_ID = CT.iChargeType_ID AND C.dtRowDeleted IS NULL
	AND (	(C.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR C.iHouse_ID IS NULL)
				OR (C.iHouse_ID IS NULL AND (0=(SELECT count(iCharge_ID) FROM Charges WHERE dtRowDeleted IS NULL AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#) AND CT.bIsDeposit IS NOT NULL))
			)
	)
	WHERE CT.dtRowDeleted IS NULL AND CT.bIsCharges is not null
	AND CT.cGLAccount <> 1030 AND	CT.iChargeType_ID <> 1740
	<CFIF ListFindNoCase(SESSION.codeblock,23) EQ 0>
	AND	CT.bIsRent IS NULL AND CT.bIsMedicaid IS NULL
	AND	(CT.bIsRentAdjustment IS NULL OR (CT.bIsRentAdjustment IS NOT NULL AND CT.bIsDiscount IS NOT NULL))
	AND	CT.iChargeType_ID <> 23 AND CT.bAcctOnly IS NULL
	</CFIF>

	<CFIF IsDefined("form.iChargeType_ID")>
		AND	CT.iChargeType_ID = #form.iChargeType_ID#
	<CFELSEIF IsDefined("url.TypeID")>
		AND CT.iChargeType_ID = #url.TypeID#
	<CFELSEIF IsDefined("form.iCharge_ID")>
		AND	CT.iChargeType_ID = #Charge.iChargeType_ID#
	</CFIF>
	ORDER BY CT.cDescription
</CFQUERY>

<!--- ==============================================================================
Check for associated Charges
=============================================================================== --->
<CFQUERY NAME = "ChargesToTypeCheck" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	iCharge_id
	FROM	CHARGES (NOLOCK)
	WHERE	(iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# OR iHouse_ID = NULL)
	<CFIF IsDefined("form.iChargeType_ID")> AND	iChargeType_ID = #form.iChargeType_ID# <CFELSEIF IsDefined("url.ID")> AND iChargeType_ID = #url.ID# </CFIF>
</CFQUERY>


<!--- ==============================================================================
Set Submision location dependent upon the current state of the form
=============================================================================== --->
<CFIF IsDefined("form.iCharge_ID")
	OR (IsDefined("form.iChargeType_ID") AND Additional.RecordCount EQ 0)
	OR (IsDefined("url.TypeID") AND Additional.RecordCount EQ 0)
	AND	NOT IsDefined("url.Detail")>
	<CFSET Action = 'ChargeADD.cfm'>
<CFELSEIF (IsDefined("url.detail") AND url.Detail NEQ "")>
	<CFSET Action = 'ChargeUpdate.cfm'>
<CFELSE>
	<CFSET Action = '#TemplateName#'>
</CFIF>

<!--- ==============================================================================
Get all NJ houses so they can't see the Adjustment Request button
=============================================================================== --->
<CFQUERY NAME = "GetNJHouses" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	iHouse_ID
	FROM	House (NOLOCK)
	WHERE	cStateCode = 'NJ' AND dtRowDeleted IS NULL
</CFQUERY>
<cfset NJHouseList = #ValueList(GetNJHouses.iHouse_ID)#>

<!--- =============================================================================================
Include Intranet Header
============================================================================================= --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- =============================================================================================
Set Title and Header for the page.
Include house header for name of the house and the TIPS Month
============================================================================================= --->
<TITLE>TIPS 4 - Charges</TITLE><BR>
<B CLASS="PageTitle"> TIPS 4 - Charges/Credits Entered </B>
<BR><BR>

<cfif tenantlist.recordcount eq 0>
	<b>There are no residents currently moved into #session.housename#</b>
	<cfabort>
</cfif>

<STYLE>
	td { vertical-align: top; }
</STYLE>
<FORM ACTION="#Variables.Action#" METHOD="POST">
<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<TABLE CLASS="noborder" STYLE="TEXT-ALIGN: Left; font-weight: bold; background: transparent;">
	<TR>
		<TD COLSPAN=1 STYLE="background: transparent;"> <cfif #ListFind(NJHouseList,SESSION.qSelectedHouse.iHouse_ID)# is "0"><INPUT TYPE="button" NAME="AdjRequest" VALUE="Adjustment Request" onClick="location.href='AdjustmentRequest.cfm'"></cfif> </TD>
		<TD COLSPAN=4 STYLE="background: transparent; font-size: 18; text-align: right;"> <INPUT TYPE="button" NAME="Recurring" VALUE="Recurring Charges" onClick="location.href='../RecurringCharges/Recurring.cfm'"> </TD>
	</TR>
</TABLE>
<CFIF IsDefined("form.iTenant_ID") OR IsDefined("url.ID")>
	<INPUT TYPE="Hidden" NAME="iInvoiceNumber" VALUE="#Variables.iInvoiceNumber#">
	<INPUT TYPE="Hidden" NAME="iInvoiceMaster_ID" VALUE="#InvoiceNumber.iInvoiceMaster_ID#">
</CFIF>

<TABLE>
	<TR> <TH COLSPAN = "4">	Charges/Credits Administration & Entry	</TH> </TR>
	<TR STYLE = "font-weight: bold;">
		<TD STYLE="width: 25%;">Add a transaction:</TD>
		<TD STYLE="width: 25%;"></TD>
		<!--- 25575 - rts - 6/4/2010 - respite info --->
		<cfif not isDefined("resType") or (isDefined("resType") and resType neq 3)>
			<TD STYLE="width: 25%;"></TD>
			<TD STYLE="width: 25%;"></TD>
		<cfelse>
			<TD STYLE="width: 5%;"></TD>
			<TD STYLE="width: 25%;">Days In Current Invoice: <cfoutput>#RespInvoiceInfo.Days#</cfoutput></TD>
		</cfif>
		<!--- end 25575 --->
	</TR>

	<TR STYLE = "font-weight: bold;">
		<CFIF NOT IsDefined("form.iTenant_ID") AND NOT IsDefined("form.iChargeType_ID") AND NOT IsDefined("form.iCharge_ID") AND NOT isDefined("url.id")>
			<!--- ranklam - 08/25/2005 - removed old menu and added a new one from an include file --->
			<cfinclude template="dsp_ChargeMenu.cfm">
			<TD ID="Cell4" NOWRAP></TD>
		<CFELSEIF NOT IsDefined("url.id")>
			<INPUT TYPE="Hidden" NAME="iChargeType_ID" VALUE="#Charge.iChargeType_ID#">
			<TD STYLE="width: 25%;">#Tenant.cLastName#, #Tenant.cFirstname#<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#Tenant.iTenant_ID#"></TD>
				<CFIF Charge.bIsModifiableDescription GT 0>
					<TD NOWRAP>#ChargeTypes.cDescription#: <INPUT TYPE="text" NAME="cDescription" VALUE="#Charge.ChargeDescription#" MAXLENGTH="15"  onBlur="this.value=Letters(this.value);  Upper(this);"></TD>
				<CFELSE>
					<TD NOWRAP>
						<U>Description:</U> #Charge.ChargeDescription#
						<INPUT TYPE="Hidden" NAME="cDescription" VALUE="#Charge.ChargeDescription#">
					</TD>
				</CFIF>
				<!---Robert Schuette, project 23853   07-14-2008
					begin: If user is NOT AR then javascript for keyboard restriction
					 on input (only numbers).  '192' is usergroup 'AR'--->
				<cfif ListContains(session.groupid,'192')>
					<CFIF Charge.bIsModifiableAmount GT 0 OR (listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1)><!--- Sr. Acct or AR --->
						<TD>Amount
						<INPUT TYPE="text" NAME="mAmount" SIZE="7" STYLE="text-align:center;" VALUE="#TRIM(LSNumberFormat(Charge.mAmount, "99999.99"))#"  onBlur="this.value=Money(this.value); this.value=cent(round(this.value));" ></TD>
					<CFELSE>
						<TD><U>Amount:</U> <BR> #LSCurrencyFormat(Charge.mAmount)# <INPUT TYPE="Hidden" NAME="mAmount" VALUE="#Charge.mAmount#"></TD>
					</CFIF>
				<cfelse>
					<CFIF Charge.bIsModifiableAmount GT 0 OR (listfindNocase(session.codeblock,25) GTE 1 OR listfindNocase(session.codeblock,23) GTE 1)><!--- Sr. Acct or AR --->
						<TD>Amount
						<INPUT TYPE="text" NAME="mAmount" SIZE="7" STYLE="text-align:center;" VALUE="#TRIM(LSNumberFormat(Charge.mAmount, "99999.99"))#"  onBlur="this.value=Money(this.value); this.value=cent(round(this.value));" onkeypress="return numbers(event)"></TD>
					<CFELSE>
						<TD><U>Amount:</U> <BR> #LSCurrencyFormat(Charge.mAmount)# <INPUT TYPE="Hidden" NAME="mAmount" VALUE="#Charge.mAmount#"></TD>
					</CFIF>
				</cfif><!--- end changes of project 23853--->

				<CFIF Charge.bIsModifiableQty GT 0>
					<TD>
					<cfif Charge.iChargeType_ID is 8>
						<!--- If showdailyflag exsits, then this is a State Medicaid Daily charge, so show checkbox --->
						<input type="checkbox" name="bIsDaily" value="1"> Daily or
					</cfif> Qty <INPUT TYPE="text" NAME="iQuantity" VALUE="#Charge.iQuantity#" SIZE="2" STYLE="text-align:center;" MAXLENGHT="2" onBlur="this.value=Math.abs(Money(this.value));"></TD>
				<CFELSE>
					<TD><U>Quantity</U> <BR> #Charge.iQuantity# <INPUT TYPE="Hidden" NAME="iQuantity" VALUE="#Charge.iQuantity#"></TD>
				</CFIF>
			</CFIF>
	</TR>
	<CFIF IsDefined("url.ID")>
		<TR STYLE = "font-weight: bold;">
			<TD>
				#Tenant.cLastName#, #Tenant.cFirstname#
				<INPUT TYPE="Hidden" NAME="iTenant_ID" VALUE="#Tenant.iTenant_ID#">
				<INPUT TYPE="Hidden" NAME="iInvoiceDetail_ID" VALUE="#url.Detail#">
			</TD>

			<CFIF 	(Additional.RecordCount GT 0 AND NOT IsDefined("url.Detail")) OR (IsDefined("url.detail")
						AND url.detail EQ "" AND Additional.RecordCount GT 0)>
				<TD>
					Choose Charge: <BR>
					<SELECT NAME="iCharge_ID" onChange="submit()">
						<OPTION VALUE=""> None </OPTION>
						<CFLOOP QUERY="Additional">	<OPTION VALUE = "#Additional.iCharge_ID#">	#Additional.cDescription# </OPTION>	</CFLOOP>
					</SELECT>
				</TD>
				<TD></TD>
				<TD></TD>
			<CFELSEIF 	((IsDefined("TenantDetail.bIsModifiableDescription") AND TenantDetail.bIsModifiableDescription GT 0) OR TenantDetail.bIsMedicaid NEQ "")
						OR Additional.RecordCount EQ 0>
				<TD NOWRAP>
					#ChargeTypes.cDescription#:  Description <BR> <INPUT TYPE = "text" NAME = "cDescription" VALUE = "#TenantDetail.cDescription#" MAXLENGTH = "15"  onBlur="this.value=Letters(this.value);  Upper(this);">
				</TD>
			<CFELSE>
				<TD NOWRAP>
					<U>Description</U> <BR>	#TenantDetail.cDescription#
					<INPUT TYPE="Hidden" NAME="cDescription" VALUE="#TenantDetail.cDescription#">
					<INPUT TYPE="Hidden" NAME="iChargeType_ID" VALUE="#TenantDetail.iChargeType_ID#">
				</TD>
			</CFIF>

			<CFIF Additional.RecordCount EQ 0 OR (IsDefined("Url.Detail") AND url.Detail NEQ "" AND Additional.RecordCount EQ 0) OR IsDefined("form.iChargeType_ID")
				OR (IsDefined("Url.Detail") AND url.Detail NEQ "" AND Additional.RecordCount GT 0 AND IsDefined("form.iCharge_ID"))
				OR	(IsDefined("url.ID") AND IsDefined("url.typeID") AND IsDefined("url.Detail") AND url.detail NEQ "")>

				<CFIF (IsDefined("Charge.bISModifiableAmount") AND Charge.bISModifiableAmount GT 0) OR TenantDetail.bIsMedicaid GT 0>
					<TD>
						<U>Amount</U> <BR>
						<!--- if State Medicaid, get recurring charge to find correct amount to display --->
						<Cfquery name="getRecurring" datasource="#application.datasource#">
							SELECT bIsDaily, mAmount from recurringcharge WHERE iTenant_ID = #Tenant.iTenant_ID# AND iCharge_ID = 86 AND dtRowDeleted IS NULL
						</Cfquery><!--- Chargetypeid: #TenantDetail.iChargeType_ID# recordcount: #getREcurring.recordcount# --->
						
							<cfif TenantDetail.iChargeType_ID is 8 AND getRecurring.recordcount is not 0 AND getRecurring.bIsDaily is 1>
								<!---Enable negative inputs for chrages by AR --->	
								<INPUT TYPE = "text" NAME = "mAmount" SIZE = "7" VALUE = "#TRIM(LSNumberFormat(getRecurring.mAmount, "99999.99"))#"  onBlur="this.value=Money(this.value);">
								<!--- also set flag to display daily checkbox --->
								<cfset ShowDailyCheckbox = "yes">
							<cfelse>
								<INPUT TYPE = "text" NAME = "mAmount" SIZE = "7" VALUE = "#TRIM(LSNumberFormat(TenantDetail.mAmount, "99999.99"))#"  onBlur="this.value=Money(this.value);">
							</cfif>
						
					</TD>
				<CFELSE>
					<TD>
						<U>Amount</U> <BR>
						#LSCurrencyFormat(TenantDetail.mAmount)#
						<INPUT TYPE = "Hidden" NAME = "mAmount" VALUE = "#TenantDetail.mAmount#">
					</TD>
				</CFIF>
				<CFIF (IsDefined("Charge.bIsModifiableQuantity") AND Charge.bIsModifiableQuantity GT 0)
					OR TenantDetail.bIsMedicaid GT 0
					OR (SESSION.USERID EQ 3025 AND listfindNocase(session.codeblock,23) GTE 1 AND TenantDetail.bIsRent NEQ '' AND TenantDetail.bIsDaily NEQ '' AND TenantDetail.bIsMedicaid EQ '' AND TenantDetail.bSLevelType_id EQ '')>
					<TD>
					<cfif isDefined("ShowDailyCheckbox")>
						<!--- If showdailyflag exsits, then this is a State Medicaid Daily charge, so show checkbox --->
						<input type="checkbox" name="bIsDaily" value="1" CHECKED> Daily or
					</cfif>
					Qty

					<INPUT TYPE = "text" NAME = "iQuantity" VALUE = "#TenantDetail.iQuantity#" SIZE = "2" MAXLENGHT = "2" onBlur="this.value=Money(this.value);"></TD>
				<CFELSE>
					<TD>
						<U>Quantity</U> <BR>
						<CFIF Charge.iQuantity NEQ "">
							#Charge.iQuantity# <INPUT TYPE = "Hidden" NAME = "iQuantity" VALUE = "#Charge.iQuantity#" SIZE = "2">
						<CFELSEIF IsDefined("url.Detail")>
							#TenantDetail.iQuantity# <INPUT TYPE = "Hidden" NAME = "iQuantity" VALUE = "#TenantDetail.iQuantity#" SIZE = "2">
						<CFELSE>
							1 <INPUT TYPE = "Hidden" NAME = "iQuantity" VALUE = "1" SIZE = "2">
						</CFIF>
					</TD>
				</CFIF>
			</CFIF>
		</TR>
<!-- ==================================================================================================
		<TR><TD COLSPAN=100% STYLE="text-align:right;"><INPUT CLASS = "DontSaveButton"	TYPE="BUTTON" NAME="Cancel" VALUE="Cancel" onClick = "redirect()"></TD></TR>
================================================================================================== -->
	</CFIF>

<!--- ==============================================================================
Show or hide Save, Delete, and Don't Save Button depending on current action
=============================================================================== --->
	<CFIF 	(
				(IsDefined("url.ID") OR IsDefined("form.iTenant_ID")) AND (IsDefined("form.iCharge_ID") OR IsDefined("url.detail") AND Additional.RecordCount EQ 0) OR
				(IsDefined("form.iChargeType_ID") AND Additional.RecordCount EQ 0) OR	(IsDefined("url.ID") AND IsDefined("url.typeID") AND IsDefined("url.Detail") AND url.detail NEQ "")
			)>
		<TR>
			<TD STYLE="text-align: left; font-weight: bold;">Apply to Period of:</TD>
			<TD STYLE="text-align: left;">
				<SELECT NAME="AppliesToMonth">
					<CFLOOP INDEX=I FROM=1 TO=12 STEP=1>
						<CFSET NUMBER = RIGHT(TenantDetail.cAppliesToAcctPeriod,2)>
						<CFIF IsDefined("url.Detail") AND RIGHT(TenantDetail.cAppliesToAcctPeriod,2) EQ I>
							<CFSET Selected = 'Selected'>
						<CFELSEIF NOT IsDefined("url.Detail") AND Month(SESSION.TIPSMonth) IS I AND RIGHT(TenantDetail.cAppliesToAcctPeriod,2) LTE Month(SESSION.TIPSMonth)>
							<CFSET Selected = 'Selected'>
						<CFELSEIF (NOT IsDefined("url.Detail") AND IsDefined("Additional.RecordCount") AND Additional.RecordCount EQ 1) AND Month(SESSION.TIPSMonth) IS I>
							<CFSET Selected = 'Selected'>
						<CFELSE>
							<CFSET Selected = ''>
						</CFIF>
						<OPTION VALUE ="#NumberFormat(I, '09')#" #SELECTED#> #NumberFormat(I, "09")# </OPTION>
					</CFLOOP>
				</SELECT>
				/
				<CFIF IsDefined("TenantDetail.cAppliesToAcctPeriod") AND TenantDetail.cAppliesToAcctPeriod NEQ "" AND Action EQ "ChargeUpdate.cfm">
					<CFSET AppliesYear = LEFT(TenantDetail.cAppliesToAcctPeriod,4)>
				<CFELSE>
					<CFSET AppliesYear = YEAR(SESSION.TipsMonth)>
				</CFIF>
				<!--- MLAW 06/29/2006 Add a Year Drop down box to replace the text field.  This Year drop down box will only display 3 period years --->
				<CFSET Applies1Year = #Evaluate(AppliesYear)# - 1>
				<CFSET Applies2Year = #Evaluate(AppliesYear)# - 2>
				<SELECT NAME ="AppliesToYear">
				  <OPTION value="#AppliesYear#">#AppliesYear#</OPTION>
				  <OPTION value="#Applies1Year#">#Applies1Year#</OPTION>
				  <OPTION value="#Applies2Year#">#Applies2Year#</OPTION>
				</SELECT>
				<!--- <INPUT TYPE="Text" NAME="AppliesToYear" VALUE="#AppliesYear#" SIZE="4" MAXLENGTH="4" STYLE="text-align: center;"> --->
			</TD>	
			<TD></TD>
			<TD></TD>
		</TR>
		<CFSCRIPT> if(TenantDetail.RecordCount EQ 1){ varComments=TenantDetail.cComments; } else{ varComments=''; }</CFSCRIPT>
		<TR><TD COLSPAN="4"> <TEXTAREA COLS="75" ROWS="2" NAME="cComments" VALUE="#varComments#">#varComments#</TEXTAREA> </TD></TR>
		<TR>
			<CFIF 	TenantDetail.bIsModifiableDescription NEQ "" OR TenantDetail.bIsModifiableAmount NEQ ""
					OR TenantDetail.bIsModifiableQty NEQ "" OR Additional.RecordCount EQ 0 OR IsDefined("form.iCharge_ID")
					OR	(IsDefined("url.Detail") AND url.Detail NEQ "")>
				<CFSET Option = 'Save'>
			<CFELSE>
				<CFSET Option = 'NoSave'>
			</CFIF>
				
			<!--- MLAW 07/03/2006 add validatedate() validation --->
			<CFIF option EQ 'Save'>
				<TD bordercolor="linen" style="text-align: left;"> 
					<INPUT CLASS="SaveButton" TYPE="SUBMIT" NAME="Save"	VALUE="Save" onclick="return validatedate()"> 
				</TD>
			<CFELSE>
				<TD></TD>
			</CFIF>

			<CFIF IsDefined("url.detail") AND trim(url.detail) NEQ "">
				<TD COLSPAN=2 STYLE="text-align: center;"><INPUT CLASS = "BlendedButton" TYPE="button" NAME="Delete" VALUE="Delete Now" onClick="self.location.href='DeleteCharge.cfm?ID=#url.ID#&detail=#url.detail#'"></TD>
			<CFELSE>
				<TD></TD><TD></TD>
			</CFIF>

			<CFIF option EQ 'Save'>
				<TD><INPUT CLASS="DontSaveButton" TYPE="BUTTON" NAME="DontSave" VALUE="Don't Save" onClick="redirect()"></TD>
			<CFELSE>
				<TD></TD>
			</CFIF>
		</TR>
		<TR> <TD COLSPAN="4" style="font-weight: bold; color: red; bordercolor: linen;"> <U>NOTE:</U> You must SAVE to keep information which you have entered! </TD> </TR>
	</CFIF>

</TABLE>

</FORM>

<CFQUERY NAME="qRecords" DATASOURCE="#APPLICATION.datasource#">
	SELECT	(T.cLastName + ', ' + T.cFirstName) as fullname
		,T.iTenant_ID
		,AD.cAptNumber
		,CT.cDescription as typedescription
		,CT.iChargeType_ID
		,CT.cGLAccount
		,isNull(INV.mAMount,0.00) as mAmount
		,isNull(INV.iQuantity,1) as iQuantity
		,Sum(isNull(INV.mAMount,0.00) * isNull(INV.iQuantity,1)) as ExtendedPrice
		<!--- ,isNull((Select currbal+futurebal from #SolomonDBServer#.houses_app.dbo.ar_balances where custid=T.cSolomonKey),0) + --->
		,(SELECT sum(IINV.mAmount * IINV.iQuantity)
		FROM InvoiceDetail IINV (nolock)
		JOIN ChargeType CTT (nolock) on CTT.iChargeType_ID = IINV.iChargeType_ID
			and CTT.dtRowDeleted IS NULL and IINV.dtRowDeleted IS NULL
			and IINV.iInvoiceMaster_ID = IM.iInvoiceMaster_ID
		AND (
			(CTT.bIsRent IS NOT NULL AND CTT.bIsMedicaid IS NULL)
			OR (CTT.bIsMedicaid IS NOT NULL AND CTT.bIsRent IS NOT NULL OR CTT.bIsDiscount IS NOT NULL)
			OR (CTT.bIsRent IS NULL AND CTT.bIsMedicaid IS NULL)
		)
		WHERE IINV.dtRowDeleted IS NULL
		and IINV.iTenant_ID = T.iTenant_ID
		<!--- 06/23/2010 Project 20933 Code change start --->
		<!--- 05/25/2010 Project 20933 Sathya Added this condition to exclude the late fee to be displayed --->
		AND (IINV.bNoInvoiceDisplay is null OR IINV.bNoInvoiceDisplay = 0)
		<!---06/23/2010 End of Code Project 20933  --->
		) as TenantTotal
		,count(iInvoiceDetail_ID) as reccount
		,INV.iInvoiceDetail_ID
		<cfif session.qselectedhouse.ihouse_id neq 200>
		,(Select currbal+futurebal from #application.houses_appdbserver#.houses_app.dbo.ar_balances where custid=T.cSolomonKey)
		<cfelse> ,0 </cfif> as currbal
	FROM	Tenant T (NOLOCK)
	JOIN	TenantState TS (NOLOCK) ON TS.iTenant_ID = T.iTenant_ID AND T.dtRowDeleted IS NULL
		and TS.dtRowDeleted IS NULL AND TS.iTenantStateCode_ID = 2
		and T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	JOIN	Invoicedetail INV (NOLOCK) ON INV.iTenant_ID = T.iTenant_ID AND INV.dtRowDeleted IS NULL
	<!--- 06/23/2010 Project 20933 Sathya Code change start --->
	<!--- 05/25/2010 Project 20933 Sathya Added this condition to exclude the late fee to be displayed --->
			AND (INV.bNoInvoiceDisplay is null OR INV.bNoInvoiceDisplay = 0)
	<!---06/23/2010 End of Code Project 20933  --->
	JOIN	Invoicemaster IM (NOLOCK) ON (IM.iInvoiceMaster_ID = INV.iInvoicemaster_ID AND IM.dtRowDeleted IS NULL AND IM.bMoveOutInvoice IS NULL AND IM.bMoveInInvoice IS NULL AND IM.bFinalized IS NULL
			AND IM.cAppliesToAcctPeriod='#DateFormat(SESSION.TIPSMonth,"yyyymm")#'
			and left(im.csolomonkey,3) = '#session.housenumber#')
	JOIN	AptAddress AD (NOLOCK) ON (AD.iAptAddress_ID = TS.iAptAddress_ID AND AD.dtRowDeleted IS NULL)
	JOIN ChargeType CT (NOLOCK) ON CT.iChargeType_ID = INV.iChargeType_ID AND CT.dtRowDeleted IS NULL
	<!--- WHERE	T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# --->
	GROUP BY T.cLastName
		,T.cFirstName ,T.iTenant_ID ,AD.cAptNumber ,CT.cDescription ,CT.iChargeType_ID ,CT.cGLAccount
		,INV.mAmount ,INV.iQuantity ,IM.iInvoiceMaster_ID ,INV.iInvoiceDetail_ID ,T.cSolomonKey
	ORDER BY T.clastName, cAptNumber
</CFQUERY>

<!--- ==============================================================================
Retrieve List of Tenants
=============================================================================== --->
<CFQUERY NAME="qqTenants" DBTYPE="QUERY">
	SELECT DISTINCT
		 iTenant_ID
		,fullname
		,cAptNumber
		,currbal 
	FROM	
		qRecords
	ORDER BY
		fullname
</CFQUERY>

<!--- ==============================================================================
Retrieve all charge types
=============================================================================== --->
<CFQUERY NAME="qqCTypes" DBTYPE="QUERY">
	SELECT	distinct iChargeType_ID, typedescription, cGLAccount FROM qRecords ORDER BY cGLAccount, typedescription
</CFQUERY>

<TABLE>
<TR>
	<TH NOWRAP>Full Name</TH>
	<TH>Apt##</TH>
	<CFSET SolBalNote = 'Current accounting system balance.'>
	<TH onMouseOver="hoverdesc('#SolBalNote#');" onMouseOut="resetdesc();">AcctBal</TH>
	<CFLOOP QUERY="qqCTypes"><TH><INPUT CLASS="TH" TYPE="text" NAME="#TRIM(qqCTypes.typedescription)#" VALUE="#LEFT(qqCTypes.typedescription,5)#" SIZE="4" STYLE="text-align: center; border: none; background: transparent; color: white; font-weight: bold;" onMouseOver="hoverdesc(this.name);" onMouseOut="resetdesc(this);"></TH></CFLOOP>
	<TH NOWRAP onMouseOver="hoverdesc('Excludes State Medicaid');" onMouseOut="resetdesc();">Resident Total</TH>
</TR>
	<CFLOOP QUERY="qqTenants">
		<CFSET ThisTenantID = qqTenants.iTenant_ID>
		<CFQUERY NAME="qTenantRecords" DBTYPE="QUERY">
			SELECT	Sum(ExtendedPrice) as extendedprice, iTenant_ID, TenantTotal, count(iInvoiceDetail_ID) as reccount, Max(iInvoiceDetail_ID) as iInvoiceDetail_ID, iChargeType_ID
			FROM qRecords
			WHERE iTenant_ID = #ThisTenantID#
			GROUP BY iTenant_ID, TenantTotal, reccount, iChargeType_ID
		</CFQUERY>
		<CFQUERY NAME="qqTenantChargeTypes" DBTYPE="QUERY">
			select distinct iChargeType_ID from qTenantRecords where extendedprice <> 0
		</CFQUERY>
		<CFSET aTenantCTypes=Valuelist(qqTenantChargeTypes.iChargeType_ID,",")>
		<cf_cttr colorOne="FFFFFF" colorTwo="EEEEEE">
			<TD NOWRAP><A HREF="ChargesDetail.cfm?ID=#qqTenants.iTenant_ID#">#qqTenants.fullname#</A></TD>
			<TD STYLE="text-align:center;">#qqTenants.cAptNumber#</TD>
			<TD STYLE="text-align:right;width:1%;" onMouseOver="hoverdesc('#solbalnote#');" onMouseOut="resetdesc();">#LSCurrencyFormat(qqTenants.currbal)#</TD>
			<CFLOOP QUERY="qqCTypes">
				<CFIF ListFindNoCase(aTenantCTypes,qqCTypes.iChargetype_ID,",") GT 0>
					<!--- ==============================================================================
					Retrieve numbers for this tenant and this charge type
					=============================================================================== --->

					<!--- Katie 10/24/03: commenting out the original query because it is not returning the proper RecCount value, and therefore chargetype ExtendedPrice amounts with more than ONE invoice detail record are only returning one RecCount, so therefore the Amount is linking to only ONE of the invoice detail records, rather than linking to the charge summary screen for that Tenant OR rather than linking to a page that lets the user edit ALL invoice detail records for that charge type --->
					<!--- <CFQUERY NAME="qTenantDetails" DATASOURCE="QUERY" DBTYPE="QUERY">
						SELECT	Sum(ExtendedPrice) as extendedprice, iTenant_ID, TenantTotal, count(iInvoiceDetail_ID) as reccount, Max(iInvoiceDetail_ID) as iInvoiceDetail_ID
						FROM qTenantRecords WHERE iChargeType_ID = #qqCTypes.iChargeType_ID# GROUP BY iTenant_ID, TenantTotal, reccount
					</CFQUERY> --->
					<CFQUERY NAME="qTenantDetails" DBTYPE="QUERY">
						SELECT	Sum(ExtendedPrice) as extendedprice, iTenant_ID, TenantTotal, count(iInvoiceDetail_ID) as reccount, Max(iInvoiceDetail_ID) as iInvoiceDetail_ID
						FROM qRecords WHERE iTenant_ID = #ThisTenantID# AND iChargeType_ID = #isBlank(qqCTypes.iChargeType_ID,0)# GROUP BY iTenant_ID, TenantTotal, reccount
					</CFQUERY>
					<CFSET amtcolor= IIF(qTenantDetails.Reccount GT 1,DE('color:red;'),DE(''))>
					<TD STYLE="text-align:right;">
						<CFIF qTenantDetails.ExtendedPrice NEQ "">
							<CFIF (ListFindNoCase(session.CodeBlock,23) GT 1 OR ListFindNoCase(session.CodeBlock,25) GT 1) AND qTenantDetails.RecCount EQ 1>
								<!--- 09/09/2010 Project 20933 Part-D modified this --->
								<cfif qqCTypes.iChargeType_ID neq 1697>
								<A STYLE="#amtcolor#" HREF ="Charges.cfm?ID=#ThisTenantID#&TypeID=#qqCTypes.iChargeType_ID#&Detail=#qTenantDetails.iInvoiceDetail_ID#">
									#LSCurrencyFormat(qTenantDetails.ExtendedPrice)#
								</A>
								<cfelse>
								#LSCurrencyFormat(qTenantDetails.ExtendedPrice)#
								</cfif>
								<!--- 09/09/2010 Project 20933 end of code --->
							<CFELSE>
								<A HREF="ChargesDetail.cfm?ID=#ThisTenantID#" STYLE="#amtcolor#">#LSCurrencyFormat(qTenantDetails.ExtendedPrice)#</A>
							</CFIF>
						<CFELSE>
							<A HREF="#TemplateName#?ID=#ThisTenantID#&TypeID=#qqCTypes.iChargeType_ID#&Detail=">0.00</A>
						</CFIF>
					</TD>
				<CFELSE>
					<TD STYLE="text-align:right;">
						<CFIF (ListFindNoCase(session.CodeBlock,23) GT 1)>
							<A HREF="#TemplateName#?ID=#ThisTenantID#&TypeID=#qqCTypes.iChargeType_ID#&Detail=">0.00</A>
						<CFELSE> 0.00 </CFIF>
					</TD>
				</CFIF>
			</CFLOOP>
			<CFQUERY NAME="qTenantTotal" DBTYPE="QUERY">
				SELECT	TenantTotal FROM qTenantRecords WHERE iTenant_ID = #ThisTenantID#
			</CFQUERY>
			<TD STYLE="text-align:right;">#LSCurrencyFormat(qTenantTotal.TenantTotal)#</TD>
		</cf_ctTR>
	</CFLOOP>
	<!---- ======================================================================================
		Show totals by Revenue Category
	====================================================================================== ---->
	<TR>
		<TD COLSPAN=3 STYLE="background:gainsboro;"><B>Revenue by Type Total</B></TD>
		<CFLOOP QUERY="qqCTypes">
			<!--- ==============================================================================
			Retrieve all charge types with totals
			=============================================================================== --->
			<CFQUERY NAME="qqCTypeSum" DBTYPE="QUERY">
				SELECT	sum(extendedprice) as total, typedescription FROM qRecords WHERE iChargeType_ID = #isBlank(qqCTypes.iChargeType_ID,0)# GROUP BY typedescription
			</CFQUERY>
			<TD STYLE="text-align:right; background:gainsboro;"><B>#LSCurrencyFormat(qqCTypeSum.total)#</B></TD>
		</CFLOOP>
		<CFQUERY NAME="qTotalTypeSum" DBTYPE="QUERY"> SELECT	Sum(ExtendedPrice) as TotalSum FROM	qRecords </CFQUERY>
		<TD STYLE="text-align:right; background:gainsboro;"><B><Cfif qRecords.recordcount is not "0">#LSCurrencyFormat(qTotalTypeSum.TotalSum)#<cfelse>N/A</Cfif> </B></TD>
	</TR>
</TABLE>
<BR>

</CFOUTPUT>

<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">
