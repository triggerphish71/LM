<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Online FTA- House Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<cfset Page = "House Report">
<cfoutput>
<script language="VBScript" src="http://#server_name#/intranet/global/spell/p72spell_checker.vbs" type="text/vbscript"></script>
</cfoutput>

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

</head>

<font face="arial">
<!--- Instantiate the Helper object. --->
<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
			
<cfif isDefined("url.iHouse_ID")>
	<cfset houseId = #url.iHouse_ID#>
</cfif>
	
<cfif isDefined("url.SubAccount")>
	<cfset subAccount = #url.SubAccount#>
	<cfset dsHouseInfo = #helperObj.FetchHouseInfo(subAccount)#>
	<cfset unitId = #dsHouseInfo.unitId#>
	<cfset houseId = #dsHouseInfo.iHouse_ID#>			
	<cfset HouseNumber = #trim(dsHouseInfo.EHSIFacilityID)#>
</cfif>



<cfinclude template="Common/DateToUse.cfm">
<cfinclude template="DisplayFiles/Header.cfm">

<cfif isdefined("form.closemonth") OR isDefined("url.AutoClose")>
	<!--- 
	<cfquery name="closemonth" datasource="#ftads#">
		update FTAHouseReportMonth set bClosed = 1, dtClosed = #NOW()# where iFTAHouseReportMOnth_ID = #idToClose#
	</cfquery>

	<cfquery name="getinfo" datasource="#ftads#">
		select * from FTAHouseReportMOnth where iFTAHouseReportMOnth_ID = #idToClose#
	</cfquery>
	<!--- find proper smtp address from AD using custom tag --->
	<cfquery name="lookupihouse_ID" datasource="tips4">
		select H.cGLSubAccount, H.iHouse_ID, O.iDirectorUser_ID, O.cName as RegionName
		from HOUSE H
		inner join OpsArea O on H.iOpsArea_ID = O.iOpsArea_ID 
		where H.cName = '#getinfo.vcHouseName#'
	</cfquery>
	<cf_houseemail ihouse_id="#lookupihouse_ID.ihouse_id#">
	<cfset fromhouseemail = "#variables.houseemail#">
	
	<!--- get the RDO email --->
	<CFLDAP ACTION="query" NAME="FindRDO" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="physicalDeliveryOfficeName,dn,Description,mail" SERVER="#ADserver#" PORT="389" FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(objectClass=user)(Description=*RDO*#lookupihouse_ID.regionname#*))" USERNAME="ldap" PASSWORD="paulLDAP939">

	<cfmail to="#FindRDO.mail#" bcc="#session.developerEmailList#" from="#fromhouseemail#" subject="#getinfo.vcHouseName# has closed the House Report  for #DateFormat(getinfo.dtmonth,'mmm yyyy')#" type="HTML">
	<H3>#getinfo.vcHouseName# has closed the House Report  for #DateFormat(getinfo.dtmonth,'mmm yyyy')#</H3>
	
	If you are logged into ALC Apps with your NETWORK name and password, you may view it by <A HREF="http://#server_name#/intranet/fta/housereport.cfm?subAccount=#lookupihouse_ID.cGLSubAccount#&DateToUse=#getINfo.dtMonth#">clicking here</A>.
	</cfmail>
	<font size=-1 color="red">
	<cfif isDefined("url.AutoClose")>Because the month you selected was more than 2 months old and had not yet been closed,<BR></cfif>
	The month of <cfoutput>#DateFormat(getinfo.dtmonth,'mmm yyyy')#</cfoutput> has been <cfif isDefined("url.AutoClose")>automatically </cfif>closed.  An email has been sent to your RDO.</font><p>
	--->
</cfif>

<cfif isDefined("form.submitQuestions")>
	<!--- find FTAHouseReportMOnth --->
	<Cfquery name="FindFTAHouseReportMonth" datasource="#ftads#">
		select * from FTAHouseReportMonth where vcHouseName = '#form.housename#' and dtmonth = '#form.DateToUse#' and dtRowDeleted IS NULL
	</Cfquery>
	
	<cfloop list="#form.IDlist#" index="x">
		<CFSET ques = "form.question"&#x#>
		<CFSET update = "form.update"&#x#>
		<cfif isDefined("#ques#")>
			<CFSET quesValue = #Evaluate(ques)#>
			<cfif quesValue is not "">
				<Cfif isDefined("#update#")><cfif session.username is "mlaw">UPDATE<BR></cfif>
					<!--- update is defined, so update --->
						<cfquery name="updateReportQuestion#x#" datasource="#FTAds#">
							update FTAHouseReport SET vcComments= '#quesValue#' WHERE iFTARegionQuestions_ID = #x# and iFTAHouseReportMonth_ID = #findFTAHouseReportMonth.iFTAHouseREportMonth_ID# and dtRowDeleted IS NULL
						</cfquery>
				<cfelse><cfif session.username is "mlaw">INSERT<BR></cfif>
					<!--- update is not defined, so insert --->
						<cfquery name="insertReportQuestion#x#" datasource="#ftads#">
							insert into FTAHouseReport (iFTARegionQuestions_ID, vcComments, iFTAHouseReportMonth_ID) VALUES (#x#,'#quesValue#', #findFTAHouseReportMonth.iFTAHouseREportMonth_ID#)
						</cfquery>
				</Cfif>
			</cfif>
		</cfif>
	</cfloop>
</cfif>

<body>
<!--- based on House Name, get the Ops Area they're in --->
<cfquery name="LookUpSubAcct" datasource="TIPS4">
	select iOpsArea_ID, cName, iHouse_ID from House
	 where cGLSubAccount = '#subAccountNumber#'
</cfquery>

<!--- get all months to view/work on --->
<cfquery name="getMonthsHouseReport" datasource="#ftads#">
	select * from FTAHouseReportMonth where vcHouseName = '#LookUpSubAcct.CName#' and dtRowDeleted IS NULL order by dtMonth DESC
</cfquery>

<!--- have to loop through list instead of doing a valuelist because we need the date in a certain format --->
<cfset monthlist = "xxdfd">
<cfloop query="getMonthsHouseReport">
	<cfset themonth = DateFormat(getMonthsHouseReport.dtMonth,'MM/DD/YYYY')>
	<cfset monthlist = ListAppend(monthlist,themonth)>
</cfloop>

<cfoutput>

<cfif ListContains(monthlist, currentfullmonthNoTime) is 0>
	<!--- current month is not in table, so add it --->
	<cfquery name="insertnewmonth" datasource="#ftads#">
		insert into FTAHouseREPORTMonth (vcHouseName, dtMonth, dtTransaction) VALUES ('#LookUpSubAcct.cName#', '#currentfullmonth#', GetDate())
	</cfquery>
	
	<!--- get all months to view/work on once again --->
	<cfquery name="getMonthsHouseReport" datasource="#ftads#">
		select * from FTAHouseReportMonth where vcHouseName = '#LookUpSubAcct.CName#' and dtRowDeleted IS NULL order by dtMonth DESC
	</cfquery>
</cfif>

<cfif isDefined("url.DateToUse")>
	<!--- determine FTAHouseReportMonth_ID for this House and Month --->
	<cfquery name="getFTAHouseReportMonth_ID" datasource="#ftads#">
		select iFTAHouseReportMOnth_ID, bClosed from FTAHouseReportMOnth where vcHouseName = '#LookUpSubAcct.cName#' and dtMonth = '#DateToUse#'
	</cfquery>
<cfelse>
	<cfabort>
</cfif>


<!---
<cfset currentmonth = "#DateFormat(NOW(),'MM/YYYY')#">
<cfset currentm = "#DatePart('m',NOW())#">
<cfset currenty = "#DatePart('yyyy',NOW())#">
<cfset currentmy = "#currentm#/#currenty#">
<cfset currentdim = "#DaysInMonth(currentmy)#">
<cfset currentfullmonth = "#currentm#/01/#currenty# 12:00:00AM">
<cfset currentfullmonthEND = "#currentm#/#currentdim#/#currenty# 11:59:00pm">
<cfset nextm = "#dateadd('m',1,currentfullmonth)#">
<cfset nextm = "#DateFormat(nextm,'mm/dd/yyyy')# #TimeFormat(nextm,'hh:mm:sstt')#">
<!--- <cfset nextmonth = "#DateFormat(nextm,'MM/YYYY')#"> --->
<cfif not isdefined("url.DateToUse")>
	<cfset DateToUse = "#currentmonth#">
	<Cfset DateToUse = "#currentfullmonth#">
	<Cfset workingfullmonthEND = "#currentfullmonthEND#">
</cfif>
 --->
<cfquery name="getQuestions" datasource="#ftaDS#">
	select FRQ.iFTAQuestion_ID, FRQ.iFTARegionQuestions_ID, FRQ.iOrder, FQ.vcQuestion 
	from FTARegionQuestions FRQ
	inner join FTAQuestions FQ ON FRQ.iFTAQuestion_ID = FQ.iFTAQuestion_ID
	where FRQ.iOpsArea_ID = #LookUpSubAcct.iOpsArea_ID# 
	and FRQ.dtEffectiveStart <= '#DateToUse#' and (FRQ.dtEffectiveEND >= '#workingfullmonthEND#' OR FRQ.dtEffectiveEnd IS NULL) and FRQ.dtRowDeleted IS NULL
	ORDER BY FRQ.iOrder
</cfquery>
<cfset idList = #ValueList(getQuestions.iFTARegionQuestions_ID)#>


<!--- if this working month is TWO months LATER than the current month, and the working month isn't yet closed, auto close it --->
<Cfif getFTAHouseReportMonth_ID.bClosed IS NOT "1" AND DateDiff('m',DateToUse,currentmonth) GT "1" AND (isDefined("getFTAHouseReportMonth_ID") and getFTAHouseReportMonth_ID.recordcount is not 0)>
	<Cflocation url="housereport.cfm?AutoClose=Yes&idToClose=#getFTAHouseReportMonth_ID.iFTAHouseReportMonth_ID#&subaccount=#url.subAccount#&DateToUse=#url.DateToUse#">
</cfif>

<!--- only show close button if the current month is LATER than the working month --->
<Cfif getFTAHouseReportMonth_ID.bClosed IS NOT "1" AND DateDiff('m',DateToUse,currentmonth) GT "0" AND getFTAHouseReportMonth_ID.recordcount is not 0>
	<form action="housereport.cfm?subaccount=#url.subAccount#&DateToUse=#url.DateToUse#" method="post">
	<font size=-1>This month has not yet been closed.  Would you like to close it?  
	<input type="hidden" value="#getFTAHouseReportMonth_ID.iFTAHouseReportMonth_ID#" name="idToClose">
	<input type="submit" value="Close" name="closemonth"></font>
	</form>
</Cfif>

<cfif isDefined("getFTAHouseReportMonth_ID") and getFTAHouseReportMonth_ID.recordcount is 0>
	Sorry, there is no House Report for #DateFormat(DateToUse,'mmmm YYYY')#.
</cfif>

<form action="housereport.cfm?iHouse_ID=#url.iHouse_ID#&subAccount=#url.subaccount#&DateToUse=#DateToUse#" method="post" name="ftahousereport">



<cfset count ="1">
<cfif getFTAHouseReportMonth_ID.recordcount is not 0>
<Table border=0>
<cfloop query="getQuestions">
	<!--- check to see if there is already data for this working month --->
	<cfquery name="getHouseReportWorkingMonth" datasource="#ftaDS#">
		select * from FTAHouseReport where iFTAHouseReportMonth_ID = #getFTAHouseReportMonth_ID.iFTAHouseReportMonth_ID# and dtRowDeleted IS NULL
		and iFTARegionQuestions_ID = #GetQuestions.iFTARegionQuestions_ID#
	</cfquery>
	<Tr>
	<td><strong>#count#.) #vcQuestion#</strong></td>
	</Tr>
	<tr>
	<Td>
	<Cfif getFTAHouseReportMonth_ID.bClosed is not "1"><textarea cols=80 rows=4 name="question#getQuestions.iFTARegionQuestions_ID#"></cfif><cfif getHouseReportWorkingMonth.recordcount is not 0>#getHouseReportWorkingMonth.vcComments#</cfif><Cfif getFTAHouseReportMonth_ID.bClosed is not "1"></textarea>
	<input type="button" value="Spell Check" onClick='vbscript:question#getQuestions.iFTARegionQuestions_ID#.value=p72spellCheck(question#getQuestions.iFTARegionQuestions_ID#.value)'>
	</cfif><cfif getHouseReportWorkingMonth.recordcount is not 0><input type="hidden" name="Update#getQuestions.iFTARegionQuestions_ID#" value="Update"><cfif session.username is "mlaw">UPDATE</cfif><cfelse><cfif session.username is "mlaw">INSERT</cfif></cfif>
	</Td>
	</tr>
	<cfset count = #count# + 1>
</cfloop>
</Table>
</cfif>

<cfif isDefined("getFTAHouseReportMonth_ID") and getFTAHouseReportMonth_ID.recordcount is not 0>
<input type="hidden" name="idList" value="#idlist#">
<input type="hidden" name="DateToUse" value="#DateToUse#">
<input type="hidden" name="housename" value="#LookupSubAcct.cName#">
<Cfif getFTAHouseReportMonth_ID.bClosed is not "1"><input type="submit" name="submitquestions" value="Save House Report"></cfif>
</cfif>
</cfoutput>
</body></font>

</html>
