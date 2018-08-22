<!--- if AD title contains RDO and url.iOpsArea_ID is not defined, just redirect to their Region automatically --->
<cfif not isDefined("url.iOpsArea_ID") and SESSION.ADdescription contains "RDO">
<cfoutput>
	<cfset RDOposition = #Find("RDO",SESSION.ADdescription)#>
	<cfset endposition = rdoposition + 5>
	<cfset regionname = #removechars(SESSION.ADdescription,1,endposition)#>
	<cfquery name="findOpsAreaID" datasource="prodTips4">
		select iOpsArea_ID, cName from OpsArea where dtRowDeleted IS NULL and cName = '#Trim(RegionName)#'
	</cfquery>
	<cfif findOpsAreaID.recordcount is not "0">
		<cflocation url="housereportAdmin.cfm?iOpsArea_ID=#findOpsAreaID.iOpsArea_ID#&RDOrestrict=#findOpsAreaID.iOpsArea_ID#">
	</cfif>
</cfoutput>
</cfif>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>RDO House Report Admin</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<SCRIPT language="javascript">
<!--
function displayWindow(url, width, height) {
        var Win = window.open(url,"displayWindow",'width=' + width +
',height=' + height + ',resizable=1,scrollbars=yes,menubar=yes' );
}
//-->
				
 function doSel(obj)
 {
     for (i = 1; i < obj.length; i++)
        if (obj[i].selected == true)
           eval(obj[i].value);
}
</SCRIPT>

<cfset currentm = "#DatePart('m',NOW())#">
<cfset currenty = "#DatePart('yyyy',NOW())#">
<cfset currentmy = "#currentm#/#currenty#">
<cfset currentdim = "#DaysInMonth(currentmy)#">
<cfset currentmonth = "#currentm#/#currentdim#/#currenty# 11:59:00pm">
<cfset nextm = "#dateadd('m',1,currentmy)#">
<cfset nextmonth = "#datepart('m',nextm)#/01/#datepart('yyyy',nextm)# 12:00:00am">
	
<body>
<font face="arial">
<cfoutput>
<form action="housereportAdmin.cfm<cfif isDefined("url.iOpsArea_ID")>?iOpsArea_ID=#url.iOpsArea_ID#</cfif>" method="post" name="ftahousereportAdmin">
<cfset Page="housereportadmin">
<h3>Online FTA- <font color="##C88A5B">House Report Admin</font></h3>

<Table border=0 cellpadding=0 cellspacing=0>
<td>
<cfinclude template="menu.cfm">
</td>
<td>&##160; <font size=-1><A HREF="/intranet/applicationlist.cfm?adsi=1?adsi=1">Network ALC Apps</A> | <A HREF="/intranet/logout.cfm">Logout</A>
<p><BR>
&##160; Region to Administer for next month (#DateFormat(nextmonth,'MM/YYYY')#): <cfquery name="getRegions" datasource="prodtips4">
	select iOpsArea_ID, cName from OpsArea 
	where dtRowDeleted IS NULL 
	<Cfif isDefined("url.RDOrestrict")>and iOpsArea_ID = #url.RDOrestrict#</Cfif>
	order by cName
</cfquery>
<select name="region" onchange="doSel(this)"><option value="">Select One</option>
<cfloop query="getRegions">
<option value="location.href='housereportAdmin.cfm?iOpsArea_ID=#iOpsArea_ID#'" <cfif isDefined("url.iOpsArea_ID") and #url.iOpsArea_ID# is #getRegions.iOpsArea_ID#>SELECTED</cfif>>#cName#</option>
</cfloop>
</select>
</td>
</Table>

</cfoutput>

<cfif isDefined("form.AddNewQuestion")>
	<cfquery name="InsertNewQuestion" datasource="#ftaDS#">
		INSERT into FTAQuestions (vcQuestion) VALUES ('#form.newQuestion#')
	</cfquery>
	<font color="red">Your new Question has been added.</font><p>
</cfif>

<cfif isDefined("form.MakeChanges")>
	
	<cfoutput>
	<cfloop from = "1" to="#Form.additionalquestionend#" index="x">
		<CFSET ques = "form.question"&#x#>
		<CFSET oldques = "form.Oldquestion"&#x#>
		<cfif isDefined("#ques#")>
			<CFSET quesValue = #Evaluate(ques)#>
			<cfif isDefined("#oldques#")><CFSET OldquesValue = #Evaluate(oldques)#></cfif>
			<cfif quesValue is not "" AND (isDefined("#oldques#") and #oldquesValue# is not #QuesValue#)>
						<!--- put in dtEffective end for old record at this Order position and OpsArea --->
						<cfquery name="updateDtEffectiveEndRegionQuestion" datasource="#FTAds#">
							update FTARegionQuestions SET dtEffectiveEnd= '#currentmonth#' WHERE iorder = #x# and iOpsArea_ID = #url.iOpsArea_ID# and dtEffectiveEnd is NULL and dtRowDeleted IS NULL
						</cfquery>
						<!--- insert new record for this Order position and OpsArea --->
						<cfquery name="InsertRegionQuestion#x#" datasource="#ftads#">
							insert into FTARegionQuestions (iOpsArea_ID, iOrder, iFTAQuestion_ID, dtEffectiveStart, dtEffectiveEnd) VALUES (#url.iOpsArea_ID#, #x#, '#quesValue#', '#nextmonth#', NULL)
						</cfquery>
			<cfelseif quesValue is not "" and not isDefined("#oldques#")>
				<!--- this is new additional question, just add --->
						<cfquery name="InsertRegionQuestion#x#" datasource="#ftads#">
							insert into FTARegionQuestions (iOpsArea_ID, iOrder, iFTAQuestion_ID, dtEffectiveStart, dtEffectiveEnd) VALUES (#url.iOpsArea_ID#, #x#, '#quesValue#', '#nextmonth#', NULL)
						</cfquery>
			<cfelseif quesValue is not "" and isDefined("#oldques#")>
			<cfelseif quesValue is "">
					<!--- delete this record for this Order position and OpsArea --->
					<cfquery name="DeleteRegionQuestion#x#" datasource="#ftads#">
						UPDATE FTARegionQuestions SET dtEffectiveEnd = '#currentmonth#' WHERE iorder = #x# and iOpsArea_ID = #url.iOpsArea_ID# and dtEffectiveEnd is NULL and dtRowDeleted IS NULL
					</cfquery>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- check to see if any questions are repeated in the same OpsArea --->
	<cfquery name="duplicateQuestions" datasource="#ftads#">
		Select count(FRQ.iFTAQuestion_ID), FQ.vcQuestion
		from FTARegionQuestions FRQ
		inner join FTAQuestions FQ ON FRQ.iFTAQuestion_ID = FQ.iFTAQuestion_ID
		where FRQ.iOpsArea_ID = #url.iOpsArea_ID# and FRQ.dtRowDeleted IS NULL and FRQ.dtEffectiveEnd is NULL
		group by FRQ.iFTAQuestion_ID, FQ.vcQuestion having count(FRQ.iFTAQuestion_ID) > 1
	</cfquery>
	
	<cfif duplicateQuestions.recordcount is not "0">
		<font color="Red" size=-1><p><B>You have duplicate questions assigned to this Region:  
		<cfloop query="duplicatequestions"><LI>#vcQuestion#<BR></cfloop>
		Please delete one of the questions by putting its dropdown to the blank option and hitting the 'Make Changes' button.</B></font><BR>
	</cfif>
	</cfoutput>
</cfif>

<cfif isDefined("url.iOpsArea_ID")>
	<cfquery name="getRegionName" datasource="prodtips4">
		select cName from OpsArea where iOpsArea_ID = #url.iOpsArea_ID#
	</cfquery>
	
	<cfoutput>
	<p>
	<strong>Questions in Order of Appearance on #getRegionName.cName# Region's FTA:</strong><BR>
	<em><font size=-1>Choose the blank option within the dropdown to delete a question.<BR>
	All changes will apply to next month's FTA since this month may already be partially filled out.</font></em>
	<BR>
	<cfquery name="getQuestions" datasource="#ftaDS#">
		select FRQ.iFTAQuestion_ID, FRQ.iOrder, FQ.vcQuestion from FTARegionQuestions FRQ
		inner join FTAQuestions FQ ON FRQ.iFTAQuestion_ID = FQ.iFTAQuestion_ID
		where FRQ.iOpsArea_ID = #url.iOpsArea_ID# 
		and <!--- FRQ.dtEffectiveStart < #NOW()# and  --->FRQ.dtEffectiveEnd IS NULL  and FRQ.dtRowDeleted IS NULL
		ORDER BY FRQ.iOrder
	</cfquery>
		
	<OL>
	<cfloop query="GetQuestions">
 		<cfquery name="GetAllQuestions" datasource="#ftaDS#">
			select * from FTAQuestions where dtRowDeleted IS NULL ORDER BY vcQuestion
		</cfquery>
		<LI><!--- #GetQuestions.iOrder#.) ---> <cfset CurrentQuestionID = #getQuestions.iFtaQuestion_ID#>
		<select name="Question#GetQuestions.iOrder#"><option value=""></option>
		<cfloop query="GetAllQuestions">
			<option value="#GetAllQuestions.iFTAQuestion_ID#" <cfif #GetAllQuestions.iFTAQuestion_ID# is #currentquestionID#>SELECTED</cfif>>#GetAllQuestions.vcQuestion#
		</cfloop>
		</select><input type="hidden" name="OldQuestion#GetQuestions.iOrder#" value="#currentquestionID#"><BR>
		<Cfset highestOrder = #getQuestions.iOrder#>
	</cfloop>
	<BR>
	Add additional existing questions:<BR>
	<cfset additionalquestionstart = #highestorder# +1>
	<cfset additionalquestionend = #highestorder# +5>
	<cfloop from = "#additionalquestionstart#" to= "#additionalquestionend#" index="n">
		<LI><!--- #n#.)  --->
		<select name="Question#n#"><option value=""></option>
		<cfloop query="GetAllQuestions">
			<option value="#GetAllQuestions.iFTAQuestion_ID#">#GetAllQuestions.vcQuestion#
		</cfloop>
		</select><BR>
	</cfloop>
	</OL>
	<p>
	<input type="hidden" name="additionalquestionend" value="#additionalquestionend#">
	<input type="submit" value="Make Changes" name="MakeChanges">
	<p>
<!--- 	<form method="post" action="HouseReportAdmin.cfm?iOpsArea_ID=#url.iOpsArea_ID#"> --->
	Want a new question to show up in the Question dropdowns?  Type it here:<BR>
	<input type="text" name="newquestion" size=50><BR>
	<input type="submit" value="Add New Question" name="AddNewQuestion">
	</form>
	</cfoutput>
</cfif>
</body>
</html>
