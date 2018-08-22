<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<cftransaction>
<cfset iEntryId = url.EntryId>
<cfloop item="fname" collection="#form#" >

<cfset updatethis = "no">
<cfif FindNoCase("TXTANSWER_20", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_21", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_22", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_23", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_24", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_25", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_26", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_27", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput>	 --->
<cfelseif FindNoCase("TXTANSWER_28", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_29", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_10", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput>	 --->
<cfelseif FindNoCase("TXTANSWER_11", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_12", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	

<cfelseif FindNoCase("TXTANSWER_13", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_14", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_15", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_16", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfif #form[fname]# is "">
		<cfset updatethis = "no">	
	<cfelse>	
		<cfset updatethis = "yes">	
	</cfif> 
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput>	 --->
<cfelseif FindNoCase("TXTANSWER_17", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_18", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_19", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_1", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_2", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput>	 --->
<cfelseif FindNoCase("TXTANSWER_3", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_4", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_5", fname )>
 
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfif #form[fname]# is "">
		<cfset updatethis = "no">	
	<cfelse>	
		<cfset updatethis = "yes">	
	</cfif> 
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_6", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_7", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_8", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
<cfelseif FindNoCase("TXTANSWER_9", fname )>
	<cfset mytext  = gettoken(fname, 1 ,"_")>
	<cfset grouppart = gettoken(fname, 2 ,"_")>
	<cfset questionpart = gettoken(fname, 3 ,"_")>
	<cfset subpart = gettoken(fname, 4 ,"_")>
	<cfset updatethis = "yes">	
<!--- 	<cfoutput>#grouppart# - #questionpart# - #subpart# - #form[fname]#<br></cfoutput> --->	
</cfif>

<cfif updatethis is "yes">	
	<cfquery name="findentry" datasource="#FTAds#">
		select cEntryANswer 
		from dbo.HouseVisitAnswersII
				where 
					iHouseVisitEntry = #iEntryId#
				and ientrygroupid  = #grouppart#
				and iquestionid = #questionpart#
				and ientryquestionsub = #subpart#
	</cfquery>
	<cfif findentry.recordcount gt 0>
		<cfif findentry.centryanswer neq '#form[fname]#'>
			<cfquery name="updatevisit" datasource="#FTAds#">
				update dbo.HouseVisitAnswersII
				set cEntryANswer = '#trim(form[fname])#'
				where 
					iHouseVisitEntry = #iEntryId#
				and ientrygroupid  = #grouppart#
				and iquestionid = #questionpart#
				and ientryquestionsub = #subpart#
			</cfquery> 
		</cfif>
	<cfelse>
		<cfquery name="EnterHouseVisitAnswers" datasource="#FTAds#">
			INSERT INTO
			dbo.HouseVisitAnswersII
			(
			iHouseVisitEntry,
			iEntryGroupID,
			iQuestionID,
			iEntryQuestionSub,
			cEntryANswer,
			dtCreated,
			cCreatedBy
			)
			VALUES
			(
			#iEntryId#,
			#trim(grouppart)#,
			#trim(questionpart)#,
			#trim(subpart)#,
			'#trim(form[fname])#',
			#trim(NOW())#,
			'#trim(IEntryUserId)#'  
			);
		</cfquery>
	</cfif>
</cfif>	 
</cfloop>
			<cfquery name="updatevisit" datasource="#FTAds#">
				update dbo.HouseVisitEntriesII
				set dtLastUpdate = #NOW()#
				where iEntryId = #iEntryId#
			</cfquery> 
</cftransaction> 
<!--- <br/><cfoutput>entryid: #iEntryId#</cfoutput> --->

			<cfif isDefined("url.ccllcHouse")>
				<cfset ccllcHouse = #url.ccllcHouse#>
			<cfelse> <cfset ccllcHouse = 0>
			</cfif>
						

<cfoutput>
	<table width="100%"  border="1">
		<tr>
			<td bgcolor="##CCFFFF" bordercolor="##FF9900">Your House Visit Report changes have been saved. It can be viewed  <a href="HouseVisitIIEntryEdit.cfm?Save=No&iEntryUserId=#FORM.iEntryUserId#&iEntryID=#iEntryID#&ccllcHouse=#ccllcHouse#&iHouse_ID=#iHouse_ID#&SubAccount=#subAccount#&DateToUse=#dateToUse#&role=#role#&EntryuserFullName=#EntryuserFullName#&hdnrolename=#hdnrolename#&userRoleID=#userRoleID#&EntryuserRole=#EntryuserRole#&numberofmonths=#numberofmonths#">here</a> for reviewing and corrections</td>
		</tr>
		<tr>
			<td bgcolor="##CCFFFF" bordercolor="##FF9900">Return to House Visits Main Page  <a href="HouseVisitsII.cfm?iHouse_ID=#iHouse_ID#&SubAccount=#subAccount#&DateToUse=#dateToUse#&role=#role#&EntryuserFullName=#EntryuserFullName#&hdnrolename=#hdnrolename#&userRoleID=#userRoleID#&EntryuserRole=#EntryuserRole#&numberofmonths=#numberofmonths#">here</a>.</td>
		</tr>		
	</table>
</cfoutput>	
<body>
</body>
</html>
