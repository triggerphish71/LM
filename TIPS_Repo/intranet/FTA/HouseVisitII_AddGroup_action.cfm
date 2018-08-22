<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>HouseVisitII Add Group Action</title>
</head>
	<cfquery name="qrylastentry" datasource="#FTAds#">
		Select max(iGroupid) maxGroupID 
		FROM  dbo.HouseVisitGroupsII
	</cfquery>
	<cfset thisgroupid = qrylastentry.maxGroupID + 1>
	
	<cfquery name="qrysortorder" datasource="#FTAds#">
		Select max(iSortOrder) maxSortOrder 
		FROM  dbo.HouseVisitGroupsII
	</cfquery>	
	<cfset thissortorder = qrysortorder.maxSortOrder + 1>

	<cfset thisgroupname = Replace(form.groupname, " ", "", "ALL")>	

	<cftransaction>
		<cfquery name="EnterHouseVisitGroups" datasource="#FTAds#">							
			INSERT INTO dbo.[HouseVisitGroupsII]
			(
			 iGroupid
		   ,cGroupName
		  ,iGroupCompletionTime
		  ,iSortOrder
		  ,cTextHeader
		  ,IndexMax
		  ,IndexName
		  ,AddRows
			)
		Values(  #thisgroupid#
		 ,'#trim(thisgroupname)#'
		,#form.compltime#
		,#thissortorder#
		,'#form.headtext#'
		,#form.indexmax#
		,'#form.indexname#'
		,'#form.addrows#'
 				)
		</cfquery>
		
		<cfif trim(form.addrows) is "Y">
			<cfset thisaddrowname = left('addRowTo' & Replace(form.groupname, " ", "", "ALL"),18)>
			<cfquery name="updaddrowname" datasource="#FTAds#">	
			update dbo.[HouseVisitGroupsII]
				set addrowname = '#thisaddrowname#'
			where iGroupid = #thisgroupid#
			</cfquery>
		</cfif>
	</cftransaction>
	<cflocation  url='HouseVisitII_AddRoles.cfm?groupid=#thisgroupid#'/>		

</html>
