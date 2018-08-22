<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
	<title>HouseVisitII-AddRoles</title>
	</head>

 
	<cfset nbritems  = listlen(form.roletype, ",")>
	<cfoutput> 
		<cfloop  from="1" to="#nbritems#" index="i"  >
			<cfquery name="qrylastentry" datasource="#FTAds#">
				Select max(iRoleGroupID) maxiRoleGroupID 
				FROM  dbo.HouseVisitQuestionRolesII
			</cfquery>
			<cfset thisRoleGroupID = qrylastentry.maxiRoleGroupID + 1>		
			<cfset thisrole = listgetat(form.roletype, i, ",")>
			<cfset groupid =  form.groupID>
			<cfquery name="EnterHouseVisitRoles" datasource="#FTAds#">							
				INSERT INTO dbo.[HouseVisitQuestionRolesII]
				( iRoleGroupID
				 ,IGroup
				,iRole )
				Values(  #thisRoleGroupID#
				 ,'#groupid#'
				,#thisrole# )
			</cfquery>  
		</cfloop>  	
	</cfoutput>	
	<cflocation  url='HouseVisitII_DisplayGroups.cfm'/>	
</html>
