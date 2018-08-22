<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>GL Codes to FTA Expense Category Admin</title>
</head>

<body>
<font face="arial">
<font size=+2><B>GL Codes to FTA Expense Category Admin</B></font><BR>
<I>Adding/Deleting GLCodes here ONLY affects the Online FTA Expense Spenddown (it does not affect TIPS or Solomon)</I><P>
<font size=-1>[ <A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A> ]
<p>

<cfif isDefined("form.ViewDate")>
	<cfset DateToUse = "#form.DateToUseMonth#/01/#form.DateToUseYear#">
</cfif>

<cfif IsDefined("form.ToDoSubmit")>
<cfoutput>
	<Cfif form.ToDoSubmit is "Move">
		<cfset CompleteDate = "#form.month#/01/#form.year#">
		<cfquery name="getGLCode" datasource="#ftads#">
			select iGLCode_ID from ExpenseCategoryGLCode where iExpenseCategoryGLCode_ID = #form.ID#
		</cfquery>
		<cftransaction>
		<cfquery name="Expire" datasource="#ftads#">
			UPDATE ExpenseCategoryGLCode SET dtEffectiveEnd = #DateAdd('d',-1,DateFormat(CompleteDate,'MM/DD/YYYY'))# where iExpenseCategoryGLCode_ID = #form.ID#
		</cfquery>
		<cfquery name="Insert" datasource="#ftads#">
			INSERT INTO ExpenseCategoryGLCode (iGLCode_ID, iExpenseCategory_ID, dtEffectiveStart, dtEffectiveEnd) VALUES (#getGLCode.iGLCode_ID#, #form.MoveCategory#, '#CompleteDate#', '1/1/2030')
		</cfquery>
		</cftransaction>
		<font color="red"><strong>Your GLCode has been moved.</strong></font>  <p>
	<cfelseif form.todosubmit is "Add">
		<cfset CompleteDate = "#form.month#/01/#form.year#">
		<!--- first make sure GLcode doesn't already exist --->
		<cfquery name="search" datasource="#ftads#">
			SELECT * from GLCODE where vcGLCode = '#form.NewGL#' and dtRowDeleted is NULL
		</cfquery>
		<cfif search.recordcount is 0>
			<cftransaction>
			<cfquery name="addGL" datasource="#ftads#">
				INSERT INTO GLCode (vcGLCode, vcGLCodeDesc) values ('#form.NewGL#', '#form.NewGLDesc#')
			</cfquery>
			<cfquery name="getID" datasource="#ftads#">
				select iGLCode_ID from GLCode where vcGLcode = '#form.NewGL#'
			</cfquery>
			<cfquery  name="addGLExpense" datasource="#ftads#">
				INSERT INTO ExpenseCategoryGLCode (iGLCode_ID, iExpenseCategory_ID, dtEffectiveStart, dtEffectiveEnd) VALUES (#getID.iGLCode_ID#, #form.ID#, '#completeDate#', '1/1/2030')
			</cfquery>
			</cftransaction>
			<font color="red"><strong>Your New GLCode has been added.</strong></font>  <p>
		<cfelse>
			<!--- make sure it isn't in the ExpenseCategoryGLCode table --->
			<cfquery name="search2" datasource="#ftads#">
				SELECT * from ExpenseCategoryGLCode where iGLCode_ID = #search.iGLCode_id# and '#CompleteDate#' between dtEffectiveStart and dtEffectiveEnd
			</cfquery>
			<cfif search2.recordcount is "0">
				<!--- add it --->
				<cftransaction>
				<cfquery name="getCategory" datasource="#ftads#">
					select vcExpenseCategory from ExpenseCategory where iExpenseCategory_ID = #form.ID#
				</cfquery>
				<cfquery  name="addGLExpense" datasource="#ftads#">
					INSERT INTO ExpenseCategoryGLCode (iGLCode_ID, iExpenseCategory_ID, dtEffectiveStart, dtEffectiveEnd) VALUES (#search.iGLCode_ID#, #form.ID#, '#completeDate#', '1/1/2030')
				</cfquery>
				</cftransaction>
				<font color="red"><strong>Your GLCode has been added to the Category "#getCategory.vcExpenseCategory#" for the time effective as of #CompleteDate#.</strong></font>  <p>
			<cfelse>
				<cfquery name="getCategory" datasource="#ftads#">
					select vcExpenseCategory from ExpenseCategory where iExpenseCategory_ID = #search2.iExpenseCategory_ID#
				</cfquery>
				<font color="red"><b>Sorry, this code <strong>"#form.NewGL#"</strong> is already currently in the system under "#getCategory.vcExpenseCategory#" for the time effective as of #CompleteDate# and can not be added again.</b></font><p>
			</cfif>
		</cfif>
	<cfelseif form.todosubmit is "Remove">
		<cfset CompleteDate = "#form.month#/01/#form.year#">
		<!--- <cfquery name="DeleteGL" datasource="#ftads#">
			UPDATE GLCode SET dtRowDeleted = GetDate(), vcRowDeleted = '#session.username#' where iGLCode_ID = #url.ID# and DTRowDeleted IS NULL
		</cfquery> --->
		<cfquery name="getInfo" datasource="#ftads#">
			select G.vcGLCode, G.vcGLCodeDesc, EC.vcExpenseCategory
			from ExpenseCategoryGLCode E
			inner join GLCode G ON E.iGLCode_ID = G.iGLCode_ID		
			inner join ExpenseCategory EC ON E.iExpenseCategory_ID = EC.iExpenseCategory_ID	
			where E.iExpenseCategoryGLCode_ID = #form.ID# and G.dtRowDeleted IS NULL and EC.dtRowDeleted IS NULL
		</cfquery>
		<cfquery name="DeleteECGL" datasource="#ftads#">
			UPDATE ExpenseCategoryGLCode SET dtEffectiveEnd = #DateAdd('d',-1,DateFormat(CompleteDate,'MM/DD/YYYY'))# where iExpenseCategoryGLCode_ID = #form.ID#
		</cfquery>
		<font color="red"><strong>Your New GLCode has been removed from the "#getInfo.vcExpenseCategory#" Category as of #CompleteDate#.</strong></font>  <p>
	</Cfif>
</cfoutput>
</cfif>

<cfif isDefined("url.todo")>
<cfoutput>
	<cfif url.Todo is "Move">
		<cfquery name="getInfo" datasource="#ftads#">
			select G.vcGLCode, G.vcGLCodeDesc, E.iExpenseCategory_ID
			from ExpenseCategoryGLCode E
			inner join GLCode G on E.iGLCode_ID = G.iGLCode_ID
			where E.iExpenseCategoryGLCode_ID = #url.ID# and G.dtRowDeleted IS NULL
		</cfquery>
		<cfquery name="getExpenseCategories" datasource="#ftads#">
			select * from ExpenseCategory where iExpenseCategory_ID <> #getInfo.iExpenseCategory_ID# and dtRowDeleted IS NULL and iOrder is not null
			order by iOrder
		</cfquery>
		<strong><font size=+1>Move GL Code:</font></strong><p>
		<form method="post" action="glcodeadmin.cfm">
		Which Expense Category would you like to move "#getInfo.vcGLCode# #getInfo.vcGLCodeDesc#" to? 
		<select name="MoveCategory"><cfloop query="getExpenseCategories"><option value="#getExpenseCategories.iExpenseCategory_ID#">#getExpenseCategories.vcExpenseCategory#</option></cfloop></select><BR>
		<cfset currentyear = #DatePart('yyyy',NOW())#><cfset nextyear =currentyear + 1>
		Move GL Code effective as of <select name="month"><option>1<option>2<option>3<option>4<option>5<option>6<option>7<option>8<option>9<option>10<option>11<option>12</select>/01/<select name="Year"><option>#currentyear#<option>#nextyear#</select><BR>
		<input type="hidden" name="ID" value="#url.ID#"><input type="submit" name="ToDoSubmit" value="Move">
		</form><p><cfabort>
	<cfelseif url.Todo is "Add">
		<cfquery name="getInfo" datasource="#ftads#">
			select *
			from ExpenseCategory E
			where iExpenseCategory_ID = #url.ID# and dtRowDeleted IS NULL
		</cfquery>
		<strong><font size=+1>Add GL Code:</font></strong><p>
		<form method="post" action="glcodeadmin.cfm">
		Adding to the Expense Category "#getInfo.vcExpenseCategory#":<BR>

		GL Code: <input type="text" size=4 name="NewGL"><BR>
		GL Code Description: <input type="text" name="NewGLDesc" size=12><BR>
		<cfset currentyear = #DatePart('yyyy',NOW())#><cfset nextyear =currentyear + 1>
		Make GL Code effective as of <select name="month"><option>1<option>2<option>3<option>4<option>5<option>6<option>7<option>8<option>9<option>10<option>11<option>12</select>/01/<select name="Year"><option>#currentyear#<option>#nextyear#</select><BR>
		<input type="hidden" name="ID" value="#url.ID#"><input type="submit" name="ToDoSubmit" value="Add">
		</form><p><cfabort>
	<cfelseif url.Todo is "Remove">
		<cfquery name="getInfo" datasource="#ftads#">
			select G.vcGLCode, G.vcGLCodeDesc, EC.vcExpenseCategory
			from ExpenseCategoryGLCode E
			inner join GLCode G ON E.iGLCode_ID = G.iGLCode_ID		
			inner join ExpenseCategory EC ON E.iExpenseCategory_ID = EC.iExpenseCategory_ID	
			where E.iExpenseCategoryGLCode_ID = #url.ID# and G.dtRowDeleted IS NULL and EC.dtRowDeleted IS NULL
		</cfquery>
		<strong><font size=+1>Remove GL Code:</font></strong><p>
		<form method="post" action="glcodeadmin.cfm">
		<cfset currentyear = #DatePart('yyyy',NOW())#><cfset nextyear =currentyear + 1><cfset prevyear =currentyear - 1>
		Remove GLCode "#getInfo.vcGLCode# #getInfo.vcGLCodeDesc#" from "GetInfo.vcExpenseCategory" as of: <select name="month"><option>1<option>2<option>3<option>4<option>5<option>6<option>7<option>8<option>9<option>10<option>11<option>12</select>/01/<select name="Year"><option>#prevyear#<option SELECTED>#currentyear#<option>#nextyear#</select><BR>
		<input type="hidden" name="ID" value="#url.ID#"><input type="submit" name="ToDoSubmit" value="Remove">
		</form><p><cfabort>
	</cfif>
</cfoutput>
</cfif>

<cfquery name="getExpenseCategories" datasource="#ftads#">
	select * from ExpenseCategory where dtRowDeleted is null and IOrder is not null order by iOrder
</cfquery>

<cfoutput>
<cfparam default="#DateFormat(NOW(),'MM/DD/YYYY')#" name="DateToUse"><cfparam default="#DateFormat(NOW(),'MM/DD/YYYY')#" name="CurrentDate">
<cfset currentyear = #DatePart('yyyy',NOW())#><cfset nextyear =currentyear + 1><cfset prevyear =currentyear - 1>

<form action="glcodeadmin.cfm" method="post">
<font size=+1><strong>Effective for FTA month #Dateformat(DateToUse,'mmmm YYYY')#:</strong></font> &##160; &##160; &##160;  &##160; &##160; &##160;  &##160; &##160; &##160; View different Month: <select name="DateToUseMonth"><option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "1"> SELECTED</cfif>>1<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "2"> SELECTED</cfif>>2<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "3"> SELECTED</cfif>>3<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "4"> SELECTED</cfif>>4<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "5"> SELECTED</cfif>>5<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "6"> SELECTED</cfif>>6<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "7"> SELECTED</cfif>>7<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "8"> SELECTED</cfif>>8<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "9"> SELECTED</cfif>>9<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "10"> SELECTED</cfif>>10<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "11"> SELECTED</cfif>>11<option<cfif isDefined("form.DateToUseMonth") and form.DateToUseMonth is "12"> SELECTED</cfif>>12</select>/<select name="DateToUseYear"><option>#prevyear#<option SELECTED>#currentyear#<option>#nextyear#</select> <input type="submit" value="Go" name="ViewDate"></form><p>

<cfif DateFormat(currentdate,'MM/YYYY') is not DateFormat(dateTouse,'MM/YYYY')><font size=-1 color="red"><i>*Can only add/move/remove GLs within current Month's FTA view</i></font><p></cfif>
<Cfloop query = "getExpenseCategories">
	<B>#getExpenseCategories.vcExpenseCategory#</B> <cfif DateFormat(currentdate,'MM/YYYY') is DateFormat(dateTouse,'MM/YYYY')>(<A HREF="glcodeAdmin.cfm?ToDo=Add&ID=#getExpenseCategories.iExpenseCategory_ID#">Add a new GL Code to this category</A>)</cfif>
	<cfquery name="getExpenseCategoryGLCode" datasource="#ftads#">
		select G.vcGLCode, G.vcGLCodeDesc, G.iGLCode_ID, E.iExpenseCategoryGLCode_ID 
		from ExpenseCategoryGLCode E 
		inner join GLCode G ON E.iGLCode_ID = G.iGLCode_ID
		where E.iExpenseCategory_ID = #getExpenseCategories.iExpenseCategory_ID# and G.dtRowDeleted is null
		and '#DateToUse#' between E.dtEffectiveStart and E.dtEffectiveEnd
		order by G.vcGLCode
	</cfquery>
	<ul>
	<cfloop query="getExpenseCategoryGLCode">
		<LI>#getExpenseCategoryGLCode.vcGLCode# #getExpenseCategoryGLCode.vcGLCodeDesc# <cfif DateFormat(currentdate,'MM/YYYY') is DateFormat(dateTouse,'MM/YYYY')>(<A HREF="glcodeAdmin.cfm?ToDo=Move&ID=#getExpenseCategoryGLCode.iExpenseCategoryGLCode_ID#">Move GL to another Category</A> | <A HREF="glcodeAdmin.cfm?ToDo=Remove&ID=#getExpenseCategoryGLCode.iExpenseCategoryGLCode_ID#">Remove GL from this Category</A>)</cfif></LI>
	</cfloop>
	</ul>
</Cfloop>
</cfoutput>
</body>
</html>
