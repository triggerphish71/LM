<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>HouseVisitII Add Group Action</title>
</head>
	<cfquery name="qrylastentry" datasource="#FTAds#">
		Select max(iQuestionID) maxiQuestionID 
		FROM  dbo.HouseVisitQuestionsII
	</cfquery>
	<cfset thisQuestionID = qrylastentry.maxiQuestionID + 1>
	
	<cfquery name="qrysortorder" datasource="#FTAds#">
		Select max(iSortOrder) maxSortOrder 
		FROM  dbo.HouseVisitQuestionsII
		where iGroupID = #form.iGroupID#
	</cfquery>	
	
	<cfif IsDefined("qrysortorder.maxSortOrder") and qrysortorder.maxSortOrder is not "">
		<cfset thissortorder = qrysortorder.maxSortOrder + 1>
	<cfelse>
		<cfset thissortorder =   1>
	</cfif>
	
	<cfif #cIncludeDate# is "Y">
		<cfset thiscolsize =  1>
    <cfelseif ((IsDefined("yesno") is "Y") and ( yesno  is "Y"))>
		<cfset thiscolsize =  1>
	<cfelse>
		<cfset thiscolsize =  cColSize>	
	</cfif>
	
	<cftransaction>
		<cfoutput>
   			<cfquery name="addQuest" datasource="#FTAds#">
				INSERT INTO dbo.HouseVisitQuestionsII	   (  iQuestionID,iGroupID,cQuestion,iSortOrder ,cIDName,cColSize )   
				 VALUES 
				 (#thisQuestionID#, #iGroupID#,'#cQuestion#',#thissortorder#,'#cIDName#',#thiscolsize# )
			  </cfquery>   
				<cfif IsDefined("cIncludeDate") and   cIncludeDate is "Y">  
					<cfquery name="updcIncludeDate" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set cIncludeDate = 'Y'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>				  
				<cfif IsDefined("dropdown") and   dropdown is "Y">  
					<cfquery name="upddropdown" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set dropdown = '#dropdown#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>	
				<cfif IsDefined("readonly") and   readonly is "Y">  
					<cfquery name="updcRowSize" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set readonly = '#readonly#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>				  
				<cfif IsDefined("cRowSize") and   cRowSize gt 0>  
					<cfquery name="updcRowSize" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set cRowSize = '#cRowSize#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>				  
				<cfif IsDefined("cRowSize") and   cRowSize gt 0>  
					<cfquery name="updcRowSize" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set cRowSize = '#cRowSize#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>			  
				<cfif IsDefined("cOnChange") and   cOnChange is "Y">  
					<cfquery name="updcOnChange" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set cOnChange = '#cOnChange#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>			  
				<cfif IsDefined("posttitle") and posttitle is not "">>
					<cfquery name="updposttitle" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set posttitle = '#posttitle#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>
				<cfif IsDefined("defaultvalue") and defaultvalue is not "">>
					<cfquery name="upddefaultvalue" datasource="#FTAds#">	
						update dbo.HouseVisitQuestionsII
						set defaultvalue = '#defaultvalue#'
						where iQuestionID = #thisQuestionID#
					</cfquery>
				</cfif>
		</cfoutput>
	</cftransaction>
	<cflocation  url='HouseVisitII_DisplayGroupsQuestions.cfm'/>   	

</html>
