<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>HouseVisitII Update Sort Order</title>
</head>
	<cfoutput>
		<cfloop item="fname" collection="#form#">
			<cfif #fname# contains('SORTORDER')>
				<cfoutput> 
					<cfset groupid =  REReplace(#fname#,'SORTORDER', '') />
					<cfset sortnbr = #form[fname]#>
					 #groupid# - #sortnbr# - #fname#
					<br>
 				<cfquery name="updsort"  datasource="#FTAds#">
							update dbo.[HouseVisitGroupsII]
								set iSortOrder = #sortnbr#
							where iGroupid = #groupid#
					</cfquery> 
				</cfoutput>	
			</cfif>
		</cfloop>
	</cfoutput>
	<cflocation  url='HouseVisitII_DisplayGroups.cfm'/>	
</html>
