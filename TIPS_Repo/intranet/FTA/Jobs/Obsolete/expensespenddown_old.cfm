<!----------------------------------------------------------------------------------------------
| DESCRIPTION: 												                    |
|----------------------------------------------------------------------------------------------|
| expensespenddown.cfm                                                                         |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
| Called by: 															          |
| Calls/Submits:																|
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| MLAW       | 01/04/2006 | Fix Cust_ID3                                                       |
| ranklam    | 01/20/2006 | changed math function to make sure it evaluates nueric values      |
| ranklam    | 01/23/2006 | added else statment to the logic that set TrueMTDRawFoodBudget and |
|            |            | TrueMTDKitchenSuppliesBudget.                                      |
| ranklam    | 01/31/2006 | changed the old comshare queries to the new versions by adding     |
|            |            | includes.                                                          |
| ranklam    | 08/08/2006 | month for queries to P0 for kitchen supplies                       |
----------------------------------------------------------------------------------------------->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- Expense Spend-down</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">

<SCRIPT language="javascript">

 function doSel(obj)
 {
     for (i = 1; i < obj.length; i++)
        if (obj[i].selected == true)
           eval(obj[i].value);
 }
</SCRIPT>

</head>

<!--- rsa - 2/7/06 - check for the subaccount (see flowerbox)--->
<cfquery name="CheckSubAccount" datasource="#ComshareDS#">
	select top 1
		YEAR_ID
	from 
		ALC.FINLOC_BASE
	where 
		year_id= 2006 
	and 
		unit_id= #RIGHT(url.SubAccount,3)#
</cfquery> 

<cfquery name="LookUpSubAcct" datasource="#application.datasource#">
	select 
		 iOpsArea_ID
		,cName
		<cfif CheckSubAccount.RecordCount eq 1>
		,RIGHT(cGLSubAccount,3) AS unitId
		,iHouse_ID
		<cfelse>
		,iHouse_ID
		,iHouse_ID as unitId
		</cfif>
	from 
		House
	where 
		cGLSubAccount = '#url.SubAccount#'
</cfquery>

<cfset unitId = LookUpSubAcct.unitId>
<cfset houseId = LookUpSubAcct.ihouse_id>


<cfif isDefined("url.datetoUse") and url.datetouse is not #DateFormat(NOW(),'mmmm yyyy')#>
	<!--- use the month/year given --->
	<cfset currentmonth = "#DateFormat(datetouse,'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',datetouse)#">
	<cfset currenty = "#DatePart('yyyy',datetouse)#">
	<cfset monthforqueries = #DateFormat(currentm,'mmm')#>
	<cfset currentmy = "#currentm#/#currenty#">
	<cfset yearforqueries = currenty>
	<cfset currentdim = "#DaysInMonth(currentmy)#">
	<cfset currentd = "#DaysInMonth(currentmy)#">
	<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
	<cfset currentfullmonthNoTime = "#currentm#/01/#currenty#">
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,currentfullmonthNoTime)#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(currentfullmonthNoTime,'M/D/YYYY')#">
	<cfset datetouse = "#DateFormat(currentfullmonthNoTime,'mmmm yyyy')#">
<cfelse>
	<!--- use this month --->
	<cfset currentmonth = "#DateFormat(NOW(),'MM/YYYY')#">
	<cfset currentm = "#DatePart('m',NOW())#">
	<cfset currentd = "#DatePart('d',NOW())#">
	<cfset currenty = "#DatePart('yyyy',NOW())#">
	<cfset yearforqueries = currenty>
	<cfset monthforqueries = #DateFormat(NOW(),'mmm')#>
	<cfset currentmy = "#currentm#/#currenty#">
	<cfset currentdim = "#DaysInMonth(currentmy)#">
	<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
	<cfset currentfullmonthNoTime = "#currentm#/01/#currenty#">
	<cfset PtoPFormat = "#Dateformat(currentfullmonthNoTime,'YYYYMM')#">
	<cfset yesterday = "#DateAdd('d',-1,NOW())#">
	<cfset yesterday = "#DateFormat(yesterday,'M/D/YYYY')#">
	<cfset today = "#DateFormat(NOW(),'M/D/YYYY')#">
	<cfset datetouse = "#DateFormat(NOW(),'mmmm yyyy')#">
</cfif>


	<cfset FTAds = "FTA_TEST">
<body>
<cfoutput>
<font face="arial">
<h3>Online FTA- <font color="##C88A5B">Expense Spend-down-</font> <font color="##0066CC">#Lookupsubacct.cName#-</font> <Font color="##7F7E7E">#DateFormat(currentfullmonthnotime,'mmmm yyyy')#</font></h3>
<form method="post" action="expensespenddown.cfm">

<cfset Page="expensespenddown">
<Table border=0 cellpadding=0 cellspacing=0>
<td>
<cfinclude template="menu.cfm">
</td>
<td>&##160; <font size=-1><A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A>
<p><BR>
&##160; Month to View: <cfset x = DateFormat(NOW(),'mmmm yyyy')><cfset y = "November 2004"><select name="datetouse" onchange="doSel(this)"><option value=""></option><cfloop condition="#DateCompare(x,y,'m')# GTE 0"><option value="location.href='expensespenddown.cfm?subAccount=#url.subAccount#&DateToUse=#DateFormat(x,'mmmm yyyy')#'"<cfif isDefined("datetouse") and datetouse is DateFormat(x,'mmmm yyyy')> SELECTED</cfif>>#DateFormat(x,'mmmm yyyy')#</option><cfset x = #DateAdd('m',-1,x)#></cfloop></select>
</td>
</Table>

<p>
<font size=-1>Click on any Day's blue arrow to view Invoice Details for that Day.</font><BR>

<cfquery name="getColumns" datasource="#ftads#">
	select * from ExpenseCategory where dtRowDeleted IS NULL and iOrder is not null ORDER BY iOrder
</cfquery>
<cfquery name="getCategoriesNormal" datasource="#ftads#">
	select * from ExpenseCategory where dtRowDeleted IS NULL and iOrder is not null and iOrder > 2 ORDER BY iOrder
</cfquery>

<!--- calculate budgeted food expense PRD --->
<!--- rsa - 1/31/2006 - changed to new comshare query include --->
<cfinclude template="QueryFiles\qry_GetBudgetedFoodExpense.cfm">
<!--- keep the same query name --->
<cfset getFoodPRD = GetBudgetedFoodExpense>

<cfset monthforqueryFood = "getFoodPRD.#monthforqueries#">

<!--- find budgeted kitchen supplies per resident day --->
<!--- rsa - 1/31/06 - changed to use new comshare query include --->
<cfinclude template="QueryFiles\qry_GetBudgetedKitchenSupplies.cfm">
<!--- keep the query name the same --->
<cfset getSuppliesPRD = GetBudgetedKitchenSupplies>

<!--- rsa - 8/8/06 - changed this to P0 instead of monthforqueries --->
<cfset monthforqueryKitchenSupplies = "getSuppliesPRD.P0">

<!--- set up QueryNew for totalling Category totals and finding variance --->
<cfset QueryForCategoryTotals = #QueryNew("Day,Category,Amount")#>
<cfset QueryForCategoryGrandTotal = #QueryNew("Category,Amount,BudgetOrActual")#>
<cfset QueryForCategoryGLCodes = #QueryNew("Category,GLList")#>

<!--- calculate budgeted food total for entire month ( budgeted occ for month * DIM) --->
<!--- MLAW 01/04/2006 FTA error Cust3_id=	80000024  --->

<!--- rsa - 1/31/06 - changed to use new comshare query include --->
<cfinclude template="QueryFiles\qry_GetBudgetedOccupiedUnits.cfm">
<!--- keep the query name the same --->
<cfset getOccUnits = GetBudgetedOccupiedUnits>


<cfset monthforquery = "getOccUnits.#monthforqueries#">
<Cfset budgetedOccupiedUnits = "#NumberFormat(Evaluate(monthforquery),'__._')#">
<Cfset BudgetedRDM = #budgetedOccupiedUnits# * #currentdim# >

<!--- rsa - 1/17/06 - changed to check for numeric values --->
<cfif isNumeric(BudgetedRDM) AND isNumeric(#evaluate(monthforqueryFood)#)>
	<cfset budgetedFoodTotalForEntireMonth = #BudgetedRDM# * #evaluate(monthforqueryFood)#>
<cfelse>
	<cfset budgetedFoodTotalForEntireMonth = 0>
</cfif>

<!--- calculate actual daily occupancy for each day of this month so far --->
<cfset MTDoccupancy = 0>
<cfloop from=1 to="#currentd#" index="dayx">
	<Cfset todaysdate = "#currentm#/#dayx#/#currenty#">
	<cfquery name="getoccupancy" datasource="prodtips4">
		select iUnitsOccupied, iTenants from HouseOccupancy where dtOccupancy = '#todaysdate#' and cType = 'B' and iHouse_ID = #lookupsubacct.iHouse_ID#
	</cfquery>
	<cfif getoccupancy.recordcount is not "0">
		<cfset MTDoccupancy = #getOccupancy.iUnitsOccupied# + #MTDoccupancy#>
	</cfif>
</cfloop>

<!--- rsa - 1/3/06 - added the else condition --->
<cfif evaluate(monthforqueryFood) is not "">
	<cfset TrueMTDRawFoodBudget = #MTDoccupancy# * #evaluate(monthforqueryFood)#>
<cfelse>
	<cfset TrueMTDRawFoodBudget = 0>
</cfif>

<!--- rsa - 1/3/06 - added the else condition --->
<cfif evaluate(monthforqueryKitchenSupplies) is not "">
	<cfset TrueMTDKitchenSuppliesBudget = #MTDoccupancy# * #evaluate(monthforqueryKitchenSupplies)#>
<cfelse>
	<cfset TrueMTDKitchenSuppliesBudget = 0>
</cfif>


<cfset budgetcellcolor = "##ffff99">
<cfset dailybudgetcellcolor = "##DADADA">

<table border=1 cellpadding=1 cellspacing=0>
<tr>
<td colspan=2 align=right bgcolor="#budgetcellcolor#"><font size=-2>Estimated Total Food<BR>Budget for the Month:</td><td align=right bgcolor="#budgetcellcolor#"><font size=-1>
#DollarFormat(budgetedFoodTotalForEntireMonth)#</font></td>
</tr>
<tr>
<th colspan=2 bgcolor="##0066CC">&##160;</th>
<cfloop query="getColumns">
	<cfif vcExpenseCategory is "Supplies"><Th colspan = 2 bgcolor="##0066CC">
	<cfelse><th bgcolor="##0066CC">
	</cfif><font size=-1 color="white">#vcExpenseCategory#</th>
	<!--- while looping here, might as well find the expense category GL Codes and put in a querynew --->
	<cfquery name="getExpenseCategoryGLCode" datasource="#ftads#">
		select G.vcGLCode from ExpenseCategoryGLCode E
		inner join GLCode G ON E.iGLCode_ID = G.iGLCode_ID
		where E.iExpenseCategory_ID = #getColumns.iExpenseCategory_ID# and G.dtRowDeleted is null and '#currentfullmonthNoTime#' between E.dtEffectiveStart and E.dtEffectiveEnd
	</cfquery>
	<cfset GLsForThisCategory = #ValueList(getExpenseCategoryGLCode.vcGLCode)#>
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGLCodes,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGLCodes,"Category",getColumns.vcExpenseCategory)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGLCodes,"GLList",GLsForThisCategory)#>
</cfloop>
	<th bgcolor="##0066CC"><font size=-1 color="white">Total</th>
</tr>

<!--- display category budget totals for month --->
<tr>
<cfset budgettotal = 0>

<td bgcolor="#budgetcellcolor#" align=right><font size=-1>MTD Budget</td>
<td rowspan=2 align=right bgcolor="#dailybudgetcellcolor#"><font size=-1>Food Daily<BR>Budget</td>
<td align=right bgcolor="#budgetcellcolor#"><font size=-1><cfif MTDoccupancy is not "0">#DollarFormat(TrueMTDRawFoodBudget)#<cfelse>N/A</cfif></td>
	<cfif MTDoccupancy is not "0">
		<cfset budgettotal = #budgettotal# + #TrueMTDRawFoodBudget#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Raw Food")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",TrueMTDRawFoodBudget)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>
<td bgcolor="#budgetcellcolor#"><font size=-1>MTD Budget</td>
<td align=right bgcolor="#budgetcellcolor#"><font size=-1><cfif isDefined("TrueMTDKitchenSuppliesBudget")>#DollarFormat(TrueMTDKitchenSuppliesBudget)#<cfelse>N/A</cfif></td>
	<cfif isDefined("TrueMTDKitchenSuppliesBudget")>
		<cfset budgettotal = #budgettotal# + #TrueMTDKitchenSuppliesBudget#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Supplies")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",TrueMTDKitchenSuppliesBudget)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>

<cfset daytotalaccrue = 0>
<cfloop query="getCategoriesNormal">
	<td align=right bgcolor="#budgetcellcolor#">
	<cfif vcComshareLine_ID is 0><font size=-1>$0.00
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getCategoriesNormal.vcExpenseCategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount","0")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	<cfelse>
		<cfquery name="getCategoryMonthlyBudget" datasource="#ComshareDS#">
		select *
		from ALC.FINLOC_BASE
		where
		year_id=	#currenty# 		and
		Line_id=	#vcComshareLine_ID# 	and
		unit_id=	#lookupsubacct.iHouse_ID#		and
		ver_id=		1		and
		Cust1_id=	0		and
		Cust2_id=	0		and
		Cust3_id=	0		and
		Cust4_id=	0
		</cfquery>
		<cfset monthforquery2 = "getCategoryMonthlyBudget.#monthforqueries#">
		<cfif evaluate(monthforquery2) is ""><cfset monthforquery2Eval = "0"><cfelse><Cfset monthforquery2Eval = #evaluate(monthforquery2)#></cfif>
		<font size=-1>#DollarFormat(monthforquery2Eval)#
		<cfset budgettotal = #budgettotal# + #monthforquery2Eval#>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",getCategoriesNormal.vcExpenseCategory)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",monthforquery2Eval)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
	</cfif>
	</td>
</cfloop>
<TD valign=right bgcolor="#budgetcellcolor#"><font size=-1>#dollarformat(budgettotal)#</font></TD>
	<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",budgettotal)#>
	<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Budget")#>
</tr>
<tr>
<cfset colspannumber = #getColumns.recordcount# + 2>
<td align=center><font size=-1>DAY</td><td colspan=#colspannumber# align=center><font size=-1>ACTUAL EXPENSE INCURRED</td>
</tr>

<!--- find any PREVIOUS invoices without create dates of this month that are period to post of this month --->
<cfquery name="FindPriorPeriod" datasource="#doclinkProd#">
	SELECT     D.Created, D.DocumentID, (select count(PCV.PropertyCharValue) from PropertyCharValues PCV where PCV.ParentID = P.ParentID and PCV.PropertyID = 18) as SubAcctCount
	FROM         dbo.PropertyCharValues P
	inner join dbo.Documents D ON P.ParentID = D.DocumentID
	inner join dbo.PropertyCharValues P2 ON P.ParentID = P2.ParentID
	inner join dbo.PropertyDateValues PInvDate (NOLOCK) ON P.ParentID = PInvDate.ParentID and PInvDate.PropertyID = 20
	WHERE     (P.PropertyCharValue = '#url.SubAccount#' AND P.PropertyID = 18)
	and D.Created < '#currentfullmonth#'
	and (P2.PropertyCharValue = '#PtoPFormat#' AND P2.PropertyID = 19)
	and (D.DocumentTypeID = 8 OR D.DocumentTypeID = 37)
	and PinvDate.PropertyDateValue > '7/1/2004'
	order by D.Created
</cfquery>
<cfif FindPriorPeriod.recordcount is not 0>
		<tr>

		<td align=center><font size=-1>Previous<cfif not isdefined("url.day") OR (isDefined("url.day") and url.day is not "Prev")> <A HREF="expensespenddown.cfm?SubAccount=#url.subaccount#&datetouse=#datetouse#&Day=prev"><img src="caretlightblue.gif" border=0></A></cfif><!--- <BR>#FindPriorPeriod.DocumentID# ---></td>
		<td>&##160;</td>
	<cfloop from=1 to="#FindPriorPeriod.recordcount#" index="dayx">
	<!--- for previous periods, find the occupancy of the first day of this month and calculate RDM based off of that --->
	<Cfset todaysdate = "#currentm#/1/#currenty#">
	<cfquery name="getoccupancy" datasource="prodtips4">
		select iUnitsOccupied, iTenants from HouseOccupancy where dtOccupancy = '#todaysdate#' and cType = 'B' and iHouse_ID = #lookupsubacct.iHouse_ID#
	</cfquery>
	<!--- find Resident Day Months (daily occupancy for each day in month) --->
	<cfset RDM = #getoccupancy.iUnitsOccupied# * #currentdim#>

	<cfset EstFoodBudget4Month = #DecimalFormat(evaluate(monthforqueryFood))# * RDM>
	<cfset EstKitchenSuppliesBudget4Month = #DecimalFormat(evaluate(monthforqueryKitchenSupplies))# * RDM>
	<cfset EstKitchSuppliesBudgetPerDay = #EstKitchenSuppliesBudget4month# / #currentdim#>

		<cfset NewQueryDay = #QueryNew("DayofMonth,DocumentID,BatchID,RefNumber,CompanyCode,Type,PeriodToPost")#>
		<cfset NewQueryGL = #QueryNew("DocumentID,GL,Amount")#>
		<cfset theGLrow = 1><cfset theDayrow = 1>
		<cfset newrows= #queryaddrow(NewQueryDay,FindPriorPeriod.recordcount)#>
		<Cfloop query="FindPriorPeriod">
			<cfquery name="getCompanyCode" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #FindPriorPeriod.documentID# and PropertyID = 25
			</cfquery>
			<!--- if getBatchID and getRefNumber and getPeriodToPost return 0 records, it's an IIP, look at Dist Stamp for info --->
			<cfquery name="getBatchID" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #FindPriorPeriod.documentID# and PropertyID = 13
			</cfquery>
			<cfquery name="getRefNumber" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #FindPriorPeriod.documentID# and PropertyID = 24
			</cfquery>
			<cfquery name="getPeriodtoPost" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #FindPriorPeriod.documentID# and PropertyID = 19
			</cfquery>
			<cfif getBatchID.recordcount is not "0">
				<cfif getCompanyCode.propertyCharValue is "Corp">
					<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonCorpDS#">
							SELECT     Acct, sum(TranAmt) as TranAmtTotal
							FROM         dbo.APTran
							WHERE     (Sub = '#SubAccount#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
							group by Acct
					</cfquery>
				<cfelse>
					<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonHousesDS#">
							SELECT     Acct, sum(TranAmt) as TranAmtTotal
							FROM         dbo.APTran (NOLOCK)
							WHERE     (Sub = '#SubAccount#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
									AND crtd_prog<>'03400'
							group by Acct
					</cfquery>
				</cfif>
			<cfelse>
				<!--- get gl info from dist stamp --->
				<cfquery name="getSpecificHouseInvoiceAmount" datasource="#doclinkprod#">
					select DS.distStampid, SFV.FieldValue as Acct, SFV2.FieldValue as TranAmtTotal
					from DistributionStamp DS
					inner join stampfieldvalue SFV ON DS.distStampID = SFV.distStampID and SFV.StampFieldID = 10009
					inner join stampfieldvalue SFV2 ON DS.distStampID = SFV2.DistSTampID and SFV2.StampFieldID = 10011
					where DS.DocumentID = #findinvoices.documentID# and SFV."sequence" = SFV2."Sequence"
				</cfquery>
			</cfif>
			<cfset currentDocID = #FindPriorPeriod.documentID#>
			<cfset adddata = #querysetcell(NewQueryDay,"DayOfMonth","prev",currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"DocumentID",FindPriorPeriod.documentID,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"BatchID",#getBatchID.PropertyCharValue#,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"RefNumber",getRefNumber.PropertyCharValue,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"CompanyCode",#getCompanyCode.PropertyCharValue#,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"PeriodToPost",#getPeriodtoPost.PropertyCharValue#,currentrow)#>
			<Cfif getSpecificHouseInvoiceAmount.recordcount is not "0">
				<cfloop query="getSpecificHouseInvoiceAmount">
					<!--- only add GL info if Period To Post isn't written or if it's the current month --->
					<cfif getPeriodtoPost.recordcount is "0" OR (getPeriodtoPost.recordcount is not "0" AND #trim(getPeriodtoPost.PropertyCharValue)# is #trim(PtoPFormat)#)>
						<cfset newrowsGL= #queryaddrow(NewQueryGL,1)#>
						<cfset adddataGL = #querysetcell(NewQueryGL,"DocumentID",currentDocID)#>
						<cfset adddataGL = #querysetcell(NewQueryGL,"GL",getSpecificHouseInvoiceAmount.Acct)#>
						<cfset adddataGL = #querysetcell(NewQueryGL,"Amount",getSpecificHouseInvoiceAmount.TranAmtTotal)#>
						<cfif getBatchID.recordcount is not "0">
							<cfset adddataGL = #querysetcell(NewQueryDay,"Type","IFV",thedayrow)#>
						<cfelse>
							<cfset adddataGL = #querysetcell(NewQueryDay,"Type","IIP",thedayrow)#>
						</cfif>
						<cfset theGLRow = TheGLrow + 1>
					</cfif>
				</cfloop>
				<cfset GLAccountsForThisDay = ValueList(NewQueryGL.GL)>
			</Cfif>
			<cfset theDayRow = TheDayrow + 1>
		</Cfloop>
	<!--- 	<cfif isDefined("newQueryDay")><Cfdump var="#NewQueryDay#"></cfif>
		<cfif isDefined("NewQueryGL")><cfdump var="#NewQueryGL#"></cfif> --->
		<!--- </td> --->
		<cfset daytotal = 0>

	</cfloop>
	<!--- since this is previous, we don't want to display a row for each previous record, we want them all consolidated together after the prev loop --->
		<!--- loop through expense categories for display--->
		<Cfloop query="getColumns">
			<!--- <cfquery name="getExpenseCategoryGLCode" datasource="#ftads#">
				select G.vcGLCode from ExpenseCategoryGLCode E
				inner join GLCode G ON E.iGLCode_ID = G.iGLCode_ID
				where E.iExpenseCategory_ID = #getColumns.iExpenseCategory_ID#
			</cfquery>
			<cfset GLsForThisCategory = #ValueList(getExpenseCategoryGLCode.vcGLCode)#> --->
			<cfquery name="getExpenseCategoryGLCode2" dbtype="query">
				select GLList from QueryForCategoryGLCodes
				where Category = '#getColumns.vcExpenseCategory#'
			</cfquery>
			<!--- see if this category's GL accounts match any GL's actually billed to --->
			<cfset TotalAmountDayCategory = 0>

			<cfif FindPriorPeriod.recordcount is not "0">
				<cfif isDefined("NewQueryGL")>
					<cfloop query="NewQueryGL">
						<cfif ListFind(trim(getExpenseCategoryGLCode2.GLList),trim(NewQueryGL.GL)) GT 0><cfset TotalAmountDayCategory = #TotalAmountDayCategory# + #NewQueryGL.Amount#></cfif>
					</cfloop>
					<cfset daytotal = #daytotal# + #TotalAmountDayCategory#>
					<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day","Prev")#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcExpenseCategory))#>
					<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",TotalAmountDayCategory)#>
					<!--- <BR><cfif isDefined("queryforCategoryTotals")><cfdump var="#queryforCategoryTotals#"></cfif> --->
				</cfif>
			</cfif>
			<cfif getColumns.vcExpenseCategory is "Supplies">
			<!--- supplies daily budget (RDM *  Budgeted Supplies per Resident Day)/ DIM --->
			<!--- <cfset SDB = #EstKitchenSuppliesBudget4Month# / #currentdim#> --->
			<td align=right><font size=-1>&##160;<!--- #DollarFormat(SDB)# ---></td>
			</cfif>
			<td align=right><font size=-1>
				<cfquery name="findprevcategoryamount" dbtype="query">
					select 
						Amount 
					from 
						QueryForCategoryTotals 
					where 
						[Day] = 'Prev' 
					and 
						Category = '#getColumns.vcExpenseCategory#'
				</cfquery>
				<cfif findprevcategoryamount.recordcount is not "0" and findprevcategoryamount.Amount is not "">#DollarFormat(findprevcategoryamount.Amount)#<cfelse>$0.00</cfif>
			</td>
		</cfloop>
		<td align=right><font size=-1><strong>#DollarFormat(daytotal)#</strong></td>
		<cfset DayTotalAccrue = #DayTotalAccrue# + #daytotal#>
		</tr>
		<!--- if url.day is defined, then display invoice info for this day --->
		<cfif isDefined("url.day") and Url.day is "prev">
			<cfset columna = "##FFE7CE"><cfset columnb = "##FFFFE8">
			<tr>
			<td colspan=2 align=right><A HREF="/intranet/fta/expensespenddown.cfm?SubAccount=#url.subaccount#&datetouse=#datetouse#"><img src="caretpeach.gif" border=0></A>&##160;&##160;</td><td colspan=15>
			<cfif isDefined("NewQueryDay")>
			<Table border=0 cellspacing=0 cellpadding=1>
			<tr>
			<th bgcolor="#columna#"><font size=-1><u>DocID</u></th><th bgcolor="#columnb#"><font size=-1><u>Vendor Name</u></th><th bgcolor="#columna#"><font size=-1><u>Vendor ID</u></th><th bgcolor="#columnb#"><font size=-1><u>Invoice ##</u></th><th bgcolor="#columna#"><font size=-1><u>Inv. Date</u></th><th bgcolor="#columnb#"><font size=-1><u>Amount</u></th><th bgcolor="#columna#"><font size=-1><u>GL(s) & Amount(s)</u></th><th bgcolor="#columnb#"><font size=-1><u>Processed?</u></th>
			</tr>
			<cfloop query="NewQueryDay">
				<!--- only display if Period to Post isn't defined or it's the current month --->
				<cfif NewQueryDay.PeriodToPost is '' OR NewQueryDay.PeriodToPost is #PtoPFormat#>
					<cfquery name="getdataoninvoice" datasource="#doclinkprod#">
						select   w.DocumentID
						,Vendor.PropertyCharValue as Vendor
						,VendorID.PropertyCharValue as VendorID
						,InvoiceNo.PropertyCharValue as InvoiceNo
						,InvoiceDate.PropertyDateValue as InvoiceDate
						,InvoiceAmount.PropertyCharValue as InvoiceAmount
						,GLAccount.PropertyCharValue as GLAccount
						,SubAccount.PropertyCharValue as SubAccount
						from doclink2.dbo.documents w
						Left Outer Join doclink2.dbo.PropertyCharValues vendor on vendor.parentID = w.documentID and Vendor.PropertyID = 1
						Left Outer Join doclink2.dbo.PropertyCharValues vendorID on vendorID.parentID = w.documentID and VendorID.PropertyID = 2
						Left Outer Join doclink2.dbo.PropertyCharValues InvoiceNo on InvoiceNo.parentID = w.documentID and InvoiceNo.PropertyID = 3
						Left Outer Join doclink2.dbo.PropertyDateValues InvoiceDate on InvoiceDate.parentID = w.documentID and InvoiceDate.PropertyID = 20
						Left Outer Join PropertyCharValues InvoiceAmount on InvoiceAmount.parentID = w.documentID and InvoiceAmount.PropertyID = 21
						Left Outer Join PropertyCharValues GLAccount on GLAccount.parentID = w.documentID and GLAccount.PropertyID = 9
						Left Outer Join PropertyCharValues SubAccount on SubAccount.parentID = w.documentID and SubAccount.PropertyID = 18
						where w.DocumentID = #NewQueryDay.documentID#
					</cfquery>
					<tr>
					<cfif NewQueryDay.Type is "IFV"><cfset doctype= "8"><cfelse><cfset doctype="37"></cfif>
					<td bgcolor="#columna#"><font size=-1><a href="javascript:void(window.open('http://gum/intranet/doclink/doclinksearchresults2.cfm?doctype=#doctype#&pid13=#NewQueryDay.BatchID#&pid24=#NewQueryDay.RefNumber#&entity=ALL&propertyidlist=13,24&entityidlist=1,3', 'example2', 'width=800,height=300,left=0,top=0, location=no, menubar=no, status=no, toolbar=no, scrollbars=yes, resizable=yes'))">#NewQueryDay.documentID#</A></td>
					<td bgcolor="#columnb#"><font size=-1>#getDataOnInvoice.Vendor#</td>
					<td bgcolor="#columna#"><font size=-1>#getDataOnInvoice.VendorID#</td>
					<td bgcolor="#columnb#"><font size=-1>#getDataOnInvoice.InvoiceNo#</td>
					<td bgcolor="#columna#"><font size=-1>#DateFormat(getDataOnInvoice.InvoiceDate,'M/D/YY')#</td>
					<td bgcolor="#columnb#" align=right><font size=-1>#DollarFormat(getDataOnInvoice.InvoiceAmount)#</td>
					<cfquery name="FindGLs" dbtype="query">
						select * from NewQueryGL where DocumentID= #NewQueryDay.documentID#
					</cfquery>
					<td bgcolor="#columna#"><font size=-1>
					<cfloop query="FindGLs">
						(#GL#: #DollarFormat(Amount)#)
					</cfloop>
					</td>
					<td bgcolor="#columnb#" align=center><Cfif NewQueryDay.Type is "IFV"><img src="/intranet/doclink/checkmark3.gif"><cfelse>&##160;</Cfif></td>
					</tr>
				</cfif>
			</cfloop>
			</Table>
			<cfelse>
				<font size=-1 color="red"><i>Sorry, no invoices were found for this day.</i></font>
			</cfif>
			</td>
			</tr>
		</cfif>
		</tr>
</cfif>

<!--- loop through all days up through today --->
<cfloop from=1 to="#currentd#" index="dayx">
	<!--- find todays's occupancy and calculate RDM based off of that --->
	<cfset theAMdateforQuery = "#currentm#/#dayx#/#currenty# 12:00:00AM">
	<cfset onedaylater = "#DateAdd('d',1,theAMdateforQuery)#">
	<cfset onedaylater = "#DateFormat(onedaylater,'M/D/YYYY')#">
	<cfset onedaylater = "#onedaylater# 12:00:00AM">
	<!--- <cfset thePMdateforQuery = "#currentm#/#dayx#/#currenty# 12:59:59PM"> --->
	<Cfset todaysdate = "#currentm#/#dayx#/#currenty#">
	<cfquery name="getoccupancy" datasource="prodtips4">
		select iUnitsOccupied, iTenants from HouseOccupancy where dtOccupancy = '#todaysdate#' and cType = 'B' and iHouse_ID = #lookupsubacct.iHouse_ID#
	</cfquery>
	<!--- find Resident Day Months (daily occupancy for each day in month) --->
	<cfif getoccupancy.recordcount is not "0">
		<cfset RDM = #getoccupancy.iUnitsOccupied# * #currentdim#>

		<cfset EstFoodBudget4Month = #DecimalFormat(evaluate(monthforqueryFood))# * RDM>
		<cfset EstKitchenSuppliesBudget4Month = #DecimalFormat(evaluate(monthforqueryKitchenSupplies))# * RDM>
		<cfset EstKitchSuppliesBudgetPerDay = #EstKitchenSuppliesBudget4month# / #currentdim#>
	</cfif>

	<tr>

	<td align=center><font size=-1>#dayx#<cfif not isdefined("url.day") OR (isDefined("url.day") and url.day is not "#dayx#")> <A HREF="expensespenddown.cfm?SubAccount=#url.subaccount#&datetouse=#datetouse#&Day=#dayx#"><img src="caretlightblue.gif" border=0></cfif></A>


	<cfquery name="findinvoices" datasource="#doclinkProd#">
		SELECT     D.Created, D.DocumentID, (select count(PCV.PropertyCharValue) from PropertyCharValues PCV where PCV.ParentID = P.ParentID and PCV.PropertyID = 18) as SubAcctCount
		FROM         dbo.PropertyCharValues P
		inner join dbo.Documents D ON P.ParentID = D.DocumentID
		inner join dbo.PropertyDateValues PInvDate (NOLOCK) ON P.ParentID = PInvDate.ParentID and PInvDate.PropertyID = 20
		WHERE     (P.PropertyCharValue = '#url.SubAccount#' AND P.PropertyID = 18)
		and D.Created between '#theAMdateforQuery#' and '#onedaylater#'
		and (D.DocumentTypeID = 8 OR D.DocumentTypeID = 37)
		and PinvDate.PropertyDateValue > '7/1/2004'
		order by D.Created
	</cfquery>
	<!--- rc: #findinvoices.recordcount# --->
	<cfif findinvoices.recordcount is not "0">
		<!--- for this day, find all invoices and put the invoice data into a QueryNew --->
		<cfset NewQueryDay = #QueryNew("DayofMonth,DocumentID,BatchID,RefNumber,CompanyCode,Type,PeriodToPost")#>
		<cfset NewQueryGL = #QueryNew("DocumentID,GL,Amount")#>
		<cfset theGLrow = 1><cfset theDayrow = 1>
		<cfset newrows= #queryaddrow(NewQueryDay,findinvoices.recordcount)#>
		<Cfloop query="findinvoices">
			<cfquery name="getCompanyCode" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #findinvoices.documentID# and PropertyID = 25
			</cfquery>
			<!--- if getBatchID and getRefNumber and getPeriodToPost return 0 records, it's an IIP, look at Dist Stamp for info --->
			<cfquery name="getBatchID" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #findinvoices.documentID# and PropertyID = 13
			</cfquery>
			<cfquery name="getRefNumber" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #findinvoices.documentID# and PropertyID = 24
			</cfquery>
			<cfquery name="getPeriodtoPost" datasource="#doclinkProd#">
				select PropertyID, PropertyCharValue from PropertyCharValues
				WHERE     ParentId = #findinvoices.documentID# and PropertyID = 19
			</cfquery>
			<cfif getBatchID.recordcount is not "0">
				<cfif getCompanyCode.propertyCharValue is "Corp">
					<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonCorpDS#">
							SELECT     Acct, sum(TranAmt) as TranAmtTotal
							FROM         dbo.APTran
							WHERE     (Sub = '#SubAccount#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
							group by Acct
					</cfquery>
				<cfelse>
					<cfquery name="getSpecificHouseInvoiceAmount" datasource="#SolomonHousesDS#">
							SELECT     Acct, sum(TranAmt) as TranAmtTotal
							FROM         dbo.APTran (NOLOCK)
							WHERE     (Sub = '#SubAccount#') AND (BatNbr = '#getBatchID.PropertyCharValue#') AND (RefNbr = '#getRefNumber.PropertyCharValue#')
									AND crtd_prog<>'03400'
							group by Acct
					</cfquery>
				</cfif>
			<cfelse>
				<!--- get gl info from dist stamp --->
				<cfquery name="getSpecificHouseInvoiceAmount" datasource="#doclinkprod#">
					select DS.distStampid, SFV.FieldValue as Acct, SFV2.FieldValue as TranAmtTotal
					from DistributionStamp DS
					inner join stampfieldvalue SFV ON DS.distStampID = SFV.distStampID and SFV.StampFieldID = 10009
					inner join stampfieldvalue SFV2 ON DS.distStampID = SFV2.DistSTampID and SFV2.StampFieldID = 10011
					where DS.DocumentID = #findinvoices.documentID# and SFV."sequence" = SFV2."Sequence"
				</cfquery>
			</cfif>
			<cfset currentDocID = #findinvoices.documentID#>
			<cfset adddata = #querysetcell(NewQueryDay,"DayOfMonth",dayx,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"DocumentID",findinvoices.documentID,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"BatchID",#getBatchID.PropertyCharValue#,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"RefNumber",getRefNumber.PropertyCharValue,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"CompanyCode",#getCompanyCode.PropertyCharValue#,currentrow)#>
			<cfset adddata = #querysetcell(NewQueryDay,"PeriodToPost",#getPeriodtoPost.PropertyCharValue#,currentrow)#>
			<Cfif getSpecificHouseInvoiceAmount.recordcount is not "0">
				<cfloop query="getSpecificHouseInvoiceAmount">
					<!--- only add GL info if Period To Post isn't written or if it's the current month --->
					<cfif getPeriodtoPost.recordcount is "0" OR (getPeriodtoPost.recordcount is not "0" AND #trim(getPeriodtoPost.PropertyCharValue)# is #trim(PtoPFormat)#)>
						<cfset newrowsGL= #queryaddrow(NewQueryGL,1)#>
						<cfset adddataGL = #querysetcell(NewQueryGL,"DocumentID",currentDocID)#>
						<cfset adddataGL = #querysetcell(NewQueryGL,"GL",getSpecificHouseInvoiceAmount.Acct)#>
						<cfset adddataGL = #querysetcell(NewQueryGL,"Amount",getSpecificHouseInvoiceAmount.TranAmtTotal)#>
						<cfif getBatchID.recordcount is not "0">
							<cfset adddataGL = #querysetcell(NewQueryDay,"Type","IFV",thedayrow)#>
						<cfelse>
							<cfset adddataGL = #querysetcell(NewQueryDay,"Type","IIP",thedayrow)#>
						</cfif>
						<cfset theGLRow = TheGLrow + 1>
					</cfif>
				</cfloop>
				<cfset GLAccountsForThisDay = ValueList(NewQueryGL.GL)>
			</Cfif>
			<cfset theDayRow = TheDayrow + 1>
		</Cfloop>
	</cfif>
	<!--- <cfif isDefined("newQueryDay") and session.username is "kdeborde"><Cfdump var="#NewQueryDay#"></cfif> --->
	<!--- <cfif isDefined("NewQueryGL") and session.username is "kdeborde"><cfdump var="#NewQueryGL#"></cfif>  --->
	</td>
	<!--- get today's occupancy and multiply it by the budgeted food expense per resident day --->
	<td align=right bgcolor="#dailybudgetcellcolor#"><cfif getoccupancy.recordcount is not "0"><cfset FoodDailyBudget = #getoccupancy.iUnitsOccupied# * #DecimalFormat(evaluate(monthforqueryFood))#><font size=-1>#DollarFormat(FoodDailyBudget)#<cfelse>N/A</cfif></td>
	<cfset daytotal = 0>

	<!--- loop through expense categories --->
	<Cfloop query="getColumns">
		<cfif getColumns.vcExpenseCategory is "Supplies">
		<!--- supplies daily budget (RDM *  Budgeted Supplies per Resident Day)/ DIM --->
		<cfif getoccupancy.recordcount is not "0">
			<cfset SDB = #EstKitchenSuppliesBudget4Month# / #currentdim#>
		</cfif>
		<td align=right bgcolor="##DADADA"><font size=-1><cfif getoccupancy.recordcount is not "0">#DollarFormat(SDB)#<cfelse>N/A</cfif></td>
		</cfif>
		<td align=right>
		<!--- <cfquery name="getExpenseCategoryGLCode" datasource="#ftads#">
			select G.vcGLCode from ExpenseCategoryGLCode E
			inner join GLCode G ON E.iGLCode_ID = G.iGLCode_ID
			where E.iExpenseCategory_ID = #getColumns.iExpenseCategory_ID#
		</cfquery>
		<cfset GLsForThisCategory = #ValueList(getExpenseCategoryGLCode.vcGLCode)#> --->
		<cfquery name="getExpenseCategoryGLCode2" dbtype="query">
			select GLList from QueryForCategoryGLCodes
			where Category = '#getColumns.vcExpenseCategory#'
		</cfquery>
		<!--- see if this category's GL accounts match any GL's actually billed to --->
		<cfset TotalAmountDayCategory = 0>

		<cfif findinvoices.recordcount is not "0">
			<cfif isDefined("NewQueryGL")>
				<cfloop query="NewQueryGL">
					<cfif ListFind(trim(getExpenseCategoryGLCode2.GLList),trim(NewQueryGL.GL)) GT 0><cfset TotalAmountDayCategory = #TotalAmountDayCategory# + #NewQueryGL.Amount#></cfif>
				</cfloop>
				<font size=-1>#DollarFormat(TotalAmountDayCategory)#</td>
				<cfset daytotal = #daytotal# + #TotalAmountDayCategory#>
				<cfset addrowTota = #QueryAddRow(QueryForCategoryTotals,1)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Day",dayx)#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Category",Trim(getColumns.vcExpenseCategory))#>
				<cfset adddataTotal = #querysetcell(QueryForCategoryTotals,"Amount",TotalAmountDayCategory)#>
				<!--- <BR><cfif isDefined("queryforCategoryTotals")><cfdump var="#queryforCategoryTotals#"></cfif> --->
			<cfelse>
				<font size=-1>$0.00</td>
			</cfif>
		<cfelse>
			<font size=-1>$0.00</td>
		</cfif>
	</Cfloop>
	<td align=right><font size=-1><strong>#DollarFormat(daytotal)#</strong></td>
	<cfset DayTotalAccrue = #DayTotalAccrue# + #daytotal#>
	</tr>
	<!--- if url.day is defined, then display invoice info for this day --->
	<cfif isDefined("url.day") and #Url.day# is #dayx# and isDefined("NewqueryDay")>
		<cfset columna = "##FFE7CE"><cfset columnb = "##FFFFE8">
		<tr>
		<td colspan=2 align=right><A HREF="/intranet/fta/expensespenddown.cfm?SubAccount=#url.subaccount#&datetouse=#datetouse#"><img src="caretpeach.gif" border=0></A>&##160;&##160;</td><td colspan=15>
		<cfquery name="finddatafortoday" dbtype="query">
			select * from NewQueryDay where DayOfMonth = #dayx#
		</cfquery>
		<cfif isDefined("NewQueryDay") and finddatafortoday.recordcount is not 0>
		<Table border=0 cellspacing=0 cellpadding=1>
		<tr>
		<th bgcolor="#columna#"><font size=-1><u>DocID</u></th><th bgcolor="#columnb#"><font size=-1><u>Vendor Name</u></th><th bgcolor="#columna#"><font size=-1><u>Vendor ID</u></th><th bgcolor="#columnb#"><font size=-1><u>Invoice ##</u></th><th bgcolor="#columna#"><font size=-1><u>Inv. Date</u></th><th bgcolor="#columnb#"><font size=-1><u>Amount</u></th><th bgcolor="#columna#"><font size=-1><u>GL(s) & Amount(s)</u></th><th bgcolor="#columnb#"><font size=-1><u>Processed?</u></th>
		</tr>
		<cfloop query="NewQueryDay">
			<!--- only display if Period to Post isn't defined or it's the current month --->
			<cfif NewQueryDay.PeriodToPost is '' OR NewQueryDay.PeriodToPost is #PtoPFormat#>
				<cfquery name="getdataoninvoice" datasource="#doclinkprod#">
					select   w.DocumentID
					,Vendor.PropertyCharValue as Vendor
					,VendorID.PropertyCharValue as VendorID
					,InvoiceNo.PropertyCharValue as InvoiceNo
					,InvoiceDate.PropertyDateValue as InvoiceDate
					,InvoiceAmount.PropertyCharValue as InvoiceAmount
					,GLAccount.PropertyCharValue as GLAccount
					,SubAccount.PropertyCharValue as SubAccount
					from doclink2.dbo.documents w
					Left Outer Join doclink2.dbo.PropertyCharValues vendor on vendor.parentID = w.documentID and Vendor.PropertyID = 1
					Left Outer Join doclink2.dbo.PropertyCharValues vendorID on vendorID.parentID = w.documentID and VendorID.PropertyID = 2
					Left Outer Join doclink2.dbo.PropertyCharValues InvoiceNo on InvoiceNo.parentID = w.documentID and InvoiceNo.PropertyID = 3
					Left Outer Join doclink2.dbo.PropertyDateValues InvoiceDate on InvoiceDate.parentID = w.documentID and InvoiceDate.PropertyID = 20
					Left Outer Join PropertyCharValues InvoiceAmount on InvoiceAmount.parentID = w.documentID and InvoiceAmount.PropertyID = 21
					Left Outer Join PropertyCharValues GLAccount on GLAccount.parentID = w.documentID and GLAccount.PropertyID = 9
					Left Outer Join PropertyCharValues SubAccount on SubAccount.parentID = w.documentID and SubAccount.PropertyID = 18
					where w.DocumentID = #NewQueryDay.documentID#
				</cfquery>
				<tr>
				<cfif NewQueryDay.Type is "IFV"><cfset doctype= "8"><cfelse><cfset doctype="37"></cfif>
				<td bgcolor="#columna#"><font size=-1><a href="javascript:void(window.open('http://gum/intranet/doclink/doclinksearchresults2.cfm?doctype=#doctype#&pid13=#NewQueryDay.BatchID#&pid24=#NewQueryDay.RefNumber#&entity=ALL&propertyidlist=13,24&entityidlist=1,3', 'example2', 'width=800,height=300,left=0,top=0, location=no, menubar=no, status=no, toolbar=no, scrollbars=yes, resizable=yes'))">#NewQueryDay.documentID#</A></td>
				<td bgcolor="#columnb#"><font size=-1>#getDataOnInvoice.Vendor#</td>
				<td bgcolor="#columna#"><font size=-1>#getDataOnInvoice.VendorID#</td>
				<td bgcolor="#columnb#"><font size=-1>#getDataOnInvoice.InvoiceNo#</td>
				<td bgcolor="#columna#"><font size=-1>#DateFormat(getDataOnInvoice.InvoiceDate,'M/D/YY')#</td>
				<td bgcolor="#columnb#" align=right><font size=-1>#DollarFormat(getDataOnInvoice.InvoiceAmount)#</td>
				<cfquery name="FindGLs" dbtype="query">
					select * from NewQueryGL where DocumentID= #NewQueryDay.documentID#
				</cfquery>
				<td bgcolor="#columna#"><font size=-1>
				<cfloop query="FindGLs">
					(#GL#: #DollarFormat(Amount)#)
				</cfloop>
				</td>
				<td bgcolor="#columnb#" align=center><Cfif NewQueryDay.Type is "IFV"><img src="/intranet/doclink/checkmark3.gif"><cfelse>&##160;</Cfif></td>
				</tr>
			</cfif>
		</cfloop>
		</Table>
		<cfelse>
			<font size=-1 color="red"><i>Sorry, no invoices were found for this day.</i></font>
		</cfif>
		</td>
		</tr>
	</cfif>
	<!--- Optionally, if querynewday is defined, delete it --->
	<cfif isDefined("querynewday")></cfif>
</cfloop>

<!--- month-to-date totals --->
<cfif QueryForCategoryTotals.recordcount is not "0">
	<tr>
	<cfset totalcellcolor="##9CCDCD">

	<td align=right bgcolor="#totalcellcolor#"><font size=-1><strong>Total</strong></td>
	<td align=right bgcolor="#dailybudgetcellcolor#"><font size=-1><strong><cfif getoccupancy.recordcount is not "0">#DollarFormat(EstFoodBudget4Month)#<cfelse>N/A</cfif></strong></td>
	<cfloop query="getColumns">
		<cfquery name="GetCategoryTotal" dbtype="query">
			select Sum(Amount) as TotalAmount from QueryForCategoryTotals where Category = '#trim(getColumns.vcExpenseCategory)#' GROUP BY Category
		</cfquery>
		<cfif vcExpenseCategory is "Supplies"><Td align=right bgcolor="##DADADA"><Font size=-1><B><cfif getoccupancy.recordcount is not "0">#DollarFormat(EstKitchenSuppliesBudget4Month)#<cfelse>N/A</cfif></B></Font></td><td align=right bgcolor="#totalcellcolor#">
		<cfelse><td align=right bgcolor="#totalcellcolor#">
		</cfif>
		<font size=-1><strong>#DollarFormat(GetCategoryTotal.TotalAmount)#</strong>
		<!--- add this amount to the QueryNew() called QueryForCategoryGrandTotal (so can easily determine variance) --->
			<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category",Trim(getColumns.vcExpenseCategory))#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",GetCategoryTotal.TotalAmount)#>
			<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
		</td>
	</cfloop>
	<!--- the actual daily total of all categories so far this month --->
	<td align=right bgcolor="#totalcellcolor#"><B><font size=-1>#DollarFormat(DayTotalAccrue)#</font></B></td>
		<cfset addrowTota = #QueryAddRow(QueryForCategoryGrandTotal,1)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Category","Total")#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"Amount",DayTotalAccrue)#>
		<cfset adddataTotal = #querysetcell(QueryForCategoryGrandTotal,"BudgetOrActual","Actual")#>
	</tr>
	<!--- MTD Variance --->
	<tr>
	<cfset colspannumber2 = #getColumns.recordcount# + 4>
	<td colspan=#colspannumber2#>&##160;</td>
	</tr>
	<tr>
	<cfset variancecellcolor = "##ccffff">
	<TD colspan=2 align=right bgcolor="#variancecellcolor#"><font size=-1><b>MTD Variance</b></font></TD>
	<cfloop query="getColumns">
		<cfif vcExpenseCategory is "Supplies"><Td colspan=2 align=right bgcolor="#variancecellcolor#">
		<cfelse><td align=right bgcolor="#variancecellcolor#">
		</cfif>
		<cfquery name="GetCategoryGrandTotalBudget" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcExpenseCategory)#' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActual" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = '#trim(getColumns.vcExpenseCategory)#' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfif GetCategoryGrandTotalBudget.BudgetAmount is not "" and GetCategoryGrandTotalActual.ActualAmount is not "">
			<cfset variance = GetCategoryGrandTotalBudget.BudgetAmount - GetCategoryGrandTotalActual.ActualAmount>
		<cfelse>
			<cfset variance = "N/A">
		</cfif>
		<font size=-1><strong><cfif GetCategoryGrandTotalBudget.BudgetAmount is not "" and GetCategoryGrandTotalActual.ActualAmount is not ""><cfif variance LT 0><font color="red"></cfif>#DollarFormat(variance)#<cfelse>N/A</cfif></strong></td>
	</cfloop>
	<td align=right bgcolor="#variancecellcolor#">
		<cfquery name="GetCategoryGrandTotalBudgetTotal" dbtype="query">
			select Amount as BudgetAmount from QueryForCategoryGrandTotal where Category = 'Total' and BudgetOrActual = 'Budget'
		</cfquery>
		<cfquery name="GetCategoryGrandTotalActualTotal" dbtype="query">
			select Amount as ActualAmount from QueryForCategoryGrandTotal where Category = 'Total' and BudgetOrActual = 'Actual'
		</cfquery>
		<cfset varianceTotal = GetCategoryGrandTotalBudgetTotal.BudgetAmount - GetCategoryGrandTotalActualTotal.ActualAmount>
		<font size=-1><strong><cfif getoccupancy.recordcount is not "0"><cfif variance LT 0><font color="red"></cfif>#DollarFormat(varianceTotal)#<cfelse>N/A</cfif></strong>
	</td>
	</tr>
</cfif>
</table>
<!--- <cfdump var="#queryforCategoryTotals#">
<cfdump var="#QueryForCategoryGrandTotal#"> --->

<p>
[ <A HREF="/intranet/fta/labortracking.cfm?subAccount=#url.SubAccount#&DateToUse=#DateToUse#">Labor Tracking Report</A> | <A HREF="/intranet/fta/monthlyinvoices.cfm?iHouse_ID=#lookupSubAcct.iHouse_ID#&DateToUse=#DateToUse#">Monthly Invoices</A> | <A HREF="housereport.cfm?subAccount=#url.subaccount#&workingmonth=#currentfullmonthnotime#">House Report</A> | <A HREF="default.cfm?iHouse_ID=#lookupSubAcct.iHouse_ID#&monthtouse=#DateFormat(currentfullmonthnotime,'mmmm yyyy')#">Budget Sheet</A> ]


<!--- <cfif session.username is "kdeborde">
<p>
QueryForCategoryTotals:<BR>
<cfdump var="#QueryForCategoryTotals#"><BR>
QueryForCategoryGrandTotal:<BR>
<cfdump var="#QueryForCategoryGrandTotal#"><BR>
QueryForCategoryGLCodes:<BR>
<cfdump var="#QueryForCategoryGLCodes#"><BR>
NewQueryGL:<BR>
<cfif isDefined("NewQueryGL")><cfdump var="#NewQueryGL#"></cfif>

</cfif> --->

</cfoutput>
</body>
</html>

