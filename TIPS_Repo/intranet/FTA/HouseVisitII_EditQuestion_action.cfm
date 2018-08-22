<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
	<cfset timeStamp = #Now()#>
	<cfset entryCreateDate = DateFormat(timeStamp, "mm/dd/yyyy") & " " & TimeFormat(timeStamp, "hh:mm:ss tt")>

	<cftransaction>
 		<cfif (IsDefined("DelGroup") and (DelGroup is "Y"))>
 			<cfquery name="updgroupname" datasource="#FTAds#">	
					update dbo.HouseVisitQuestionsII
						set dtRowDeleted = '#entryCreateDate#'
					where iQuestionID = #IQUESTIONID#
					</cfquery>  
		<cfelse>
 		<cfif IsDefined("iSortOrder")>
				<cfquery name="updSortOrder" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set iSortOrder = '#iSortOrder#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>
 			<cfif IsDefined("cIncludeDate")>
				<cfquery name="updcompltime" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set cIncludeDate = '#cIncludeDate#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>			
 			<cfif IsDefined("cIDName")>
				<cfquery name="updheadtext" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set cIDName = '#cIDName#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>
 			<cfif (IsDefined("cColSize") and (cColSize is not ""))>
				<cfquery name="updindexmax" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set cColSize =  <cfqueryparam  value="#form.cColSize#"  cfsqltype="cf_sql_numeric"> 
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>
 			<cfif IsDefined("cOnChange")>
				<cfquery name="updindexname" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set cOnChange = '#cOnChange#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>
 			<cfif (IsDefined("cRowSize") and (cRowSize is not "")) >
				<cfquery name="updAddRows" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set cRowSize =  <cfqueryparam  value="#form.cRowSize#" cfsqltype="cf_sql_numeric">
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>
 			<cfif IsDefined("readonly")>
				<cfquery name="updreadonlys" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set readonly = '#readonly#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>			
 			<cfif IsDefined("dropdown")>
				<cfquery name="upddropdown" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set dropdown = '#dropdown#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>			
 			<cfif IsDefined("posttitle")>
				<cfquery name="updposttitle" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set posttitle = '#posttitle#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>	
 			<cfif IsDefined("defaultvalue")>
				<cfquery name="upddefaultvalue" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set defaultvalue = '#defaultvalue#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>		
 			<cfif IsDefined("cQuestion")>
				<cfquery name="updcQuestion" datasource="#FTAds#">	
				update dbo.HouseVisitQuestionsII
					set cQuestion = '#cQuestion#'
				where iQuestionID = #IQUESTIONID#
				</cfquery>
			</cfif>										
 
 		</cfif>
	</cftransaction> 
	<cflocation  url='HouseVisitII_DisplayGroupsQuestions.cfm'/> 
</html>
