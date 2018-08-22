<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
	<cfset timeStamp = #Now()#>
	<cfset entryCreateDate = DateFormat(timeStamp, "mm/dd/yyyy") & " " & TimeFormat(timeStamp, "hh:mm:ss tt")>

	<cftransaction>
 		<cfif IsDefined("DelGroup")>
 			<cfquery name="updgroupname" datasource="#FTAds#">	
					update dbo.[HouseVisitGroupsII]
						set dtRowDeleted = <cfqueryparam value="#entryCreateDate#"  cfsqltype="cf_sql_timestamp" >  
					where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
					</cfquery>  
		<cfelse>
 		<cfif IsDefined("groupname")>
				<cfquery name="updgroupname" datasource="#FTAds#">	
				update dbo.[HouseVisitGroupsII]
					set cGroupName = <cfqueryparam value="#groupname#" cfsqltype="cf_sql_char"> 
				where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
				</cfquery>
			</cfif>
 			<cfif IsDefined("compltime")>
				<cfquery name="updcompltime" datasource="#FTAds#">	
				update dbo.[HouseVisitGroupsII]
					set iGroupCompletionTime = <cfqueryparam value="#compltime#" cfsqltype="cf_sql_char"> 
				where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
				</cfquery>
			</cfif>			
 			<cfif IsDefined("headtext")>
				<cfquery name="updheadtext" datasource="#FTAds#">	
				update dbo.[HouseVisitGroupsII]
					set cTextHeader =  <cfqueryparam value="#headtext#" cfsqltype="cf_sql_char"> 
				where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
				</cfquery>
			</cfif>
 			<cfif IsDefined("indexmax")>
				<cfquery name="updindexmax" datasource="#FTAds#">	
				update dbo.[HouseVisitGroupsII]
					set IndexMax =  #indexmax# 
				where iGroupid = <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric"> 
				</cfquery>
			</cfif>
 			<cfif IsDefined("indexname")>
				<cfquery name="updindexname" datasource="#FTAds#">	
				update dbo.[HouseVisitGroupsII]
					set IndexName = <cfqueryparam value="#indexname#" cfsqltype="cf_sql_char">
				where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
				</cfquery>
			</cfif>
 			<cfif IsDefined("AddRows")>
				<cfquery name="updAddRows" datasource="#FTAds#">	
				update dbo.[HouseVisitGroupsII]
					set AddRows = <cfqueryparam value="#trim(ucase(AddRows))#" cfsqltype="cf_sql_char"> 
				where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
				</cfquery>

				<cfif trim(form.AddRows) is "Y">
					<cfset thisaddrowname = left('addRowTo' & Replace(form.groupname, " ", "", "ALL"),18)>
					<cfquery name="updaddrowname" datasource="#FTAds#">	
					update dbo.[HouseVisitGroupsII]
						set addrowname = <cfqueryparam value="#thisaddrowname#" cfsqltype="cf_sql_char"> 
					where iGroupid =  <cfqueryparam value="#GroupID#"  cfsqltype="cf_sql_numeric">
					</cfquery>
				</cfif>
			</cfif>			
 		</cfif>
	</cftransaction> 
	<cflocation  url='HouseVisitII_DisplayGroups.cfm'/> 
</html>
