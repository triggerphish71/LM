<cfdump var="#form#">
<!--<cfdump var="#session#">--->


<CFSET rowlist=''>
<CFLOOP INDEX=A LIST='#form.fieldnames#'>
	<CFSCRIPT>
		if (findnocase("censusdate_",A,1) gt 0) { rowlist=listappend(rowlist,gettoken(A,2,"_"),","); }
	</CFSCRIPT>
</CFLOOP>
	
<cftransaction>	
	<cfoutput>
	<!---#rowlist# ,findnocase #findnocase("row_",A,1)#, A #A# ,form.fieldnames #form.fieldnames#<BR>--->
		<CFLOOP INDEX=B LIST='#rowlist#'>
		<!--- #B# </br> ---> 
			 <CFLOOP INDEX=C LIST='#form.fieldnames#'>
				<CFIF(gettoken(C,2,"_") eq B)> 
				         <CFIF(gettoken(C,1,"_") eq 'censusdate')>
				          	loop #B#  c #c# #form.fieldnames# </br>
				          	<cfset censusdate = #isblank(evaluate("censusdate_" & B),'NULL')# > 
				          	<cfset CURRENTSTATUS = #isblank(evaluate("CURRENTSTATUS_" & B),'NULL')# > 
				          	<cfset NEWSTATUS = #isblank(evaluate("NEWSTATUS_" & B),'NULL')# >
				          	<cfset REASONTOCHANGE = #isblank(evaluate("REASONTOCHANGE_" & B),'NULL')# >
				          	<cfset LEAVESTATUS = #isblank(evaluate("LEAVESTATUS_" & B),'NULL')# >
				          	<cfset LEAVETYPE = #isblank(evaluate("LEAVETYPE_" & B),'NULL')# >
				          	<cfset EXPECTEDDATEOFRETURN = #isblank(evaluate("EXPECTEDDATEOFRETURN_" & B),'NULL')# >
				          	<cfset EXPECTEDDATEOFMOVEOUT = #isblank(evaluate("EXPECTEDDATEOFMOVEOUT_" & B),'NULL')# >
				          	<!---get leave description--->
				          	<cfquery NAME="getLeaveDescription" DATASOURCE="#APPLICATION.DataSource#" >
				          		select cleavestatus from leaveStatus where ileavestatus_ID = #LEAVESTATUS#
				          	</cfquery>
				          		
				          	<!--- <cfif #EXPECTEDDATEOFRETURN# NEQ 'NULL'>test123  </cfif> --->
				          	<cfoutput> EXPECTEDDATEOFRETURN #EXPECTEDDATEOFRETURN# length #len(EXPECTEDDATEOFRETURN)# </cfoutput>
					          	<!---<cfif #CURRENTSTATUS# NEQ #NEWSTATUS#>--->
						          	 <cfset tenantID= #form.TenantID#>	
						          		<cfif #NEWSTATUS# EQ 'N'>  
							          	  		<CFQUERY  NAME="UpdateCensusAtGivenDatetoN" DATASOURCE="#APPLICATION.DataSource#" result="UpdateCensusAtGivenDate">
								          	  		Update dailycensustrack 
								          	  		Set CURRENTSTATUSINBEDATMIDNIGHT= '#NEWSTATUS#'
								          	  		 ,iLeaveStatus_ID=#LEAVESTATUS#
								          	  		,NoticeOfDischarge=  'Y' <!---it Is always Y when resident is out--->
								          	  		,TempStatusOutDate= '#censusdate#'
								          	  		 ,TempStatusInDate = <cfif '#EXPECTEDDATEOFRETURN#' NEQ 'NULL'>  '#dateformat(EXPECTEDDATEOFRETURN,'mm/dd/yyyy')#' <cfelse>'1900-01-01 00:00:00.000' </cfif>
								          	  		,TempWhere= '#getLeaveDescription.cleavestatus#'
								          	  		,REASONCENSUSCHANGE = <cfif '#REASONTOCHANGE#' EQ 'NULL'> '' <cfelse> '#REASONTOCHANGE#' </cfif>
								          	  	     <cfif '#EXPECTEDDATEOFMOVEOUT#' NEQ 'NULL'> ,DischargeDate =  '#dateformat(EXPECTEDDATEOFMOVEOUT,'mm/dd/yyyy')#' </cfif>
								          	  		,IROWSTARTUSER_ID ='#SESSION.UserID#'
								          	  		,DTROWSTART = getdate()
								          	  		,cRowStartUser_ID='EditDailyCensus'
								          	  		where itenant_ID= #tenantID# 
								          	  		and census_date= '#dateformat(censusdate,'mm/dd/yyyy')#'
							          	  		</CFQUERY>
							          	  	
							          	  		<cfdump var="#UpdateCensusAtGivenDate#">
							         	<cfelse>
									          	<CFQUERY  NAME="UpdateCensusAtGivenDatetoY" DATASOURCE="#APPLICATION.DataSource#" result="UpdateCensusAtGivenDate">
								          	  			Update dailycensustrack 
								          	  			Set CURRENTSTATUSINBEDATMIDNIGHT= '#NEWSTATUS#'
								          	  			 ,iLeaveStatus_ID= 0
										          	  	,NoticeOfDischarge=  NULL <!--- it Is always null when resident is in--->
										          	  	,TempStatusOutDate= '1900-01-01 00:00:00.000'
										          	  	,TempStatusInDate =  NULL 
										          	  	,TempWhere= NULL
										          	  	,REASONCENSUSCHANGE = <cfif '#REASONTOCHANGE#' EQ 'NULL'> NULL <cfelse> '#REASONTOCHANGE#' </cfif>
										          	  	,DischargeDate =  '1900-01-01 00:00:00.000' 
										          	  	,IROWSTARTUSER_ID ='#SESSION.UserID#'
										          	  	,DTROWSTART = getdate()
										          	  	,cRowStartUser_ID='EditDailyCensus'
										          	  	where itenant_ID= #tenantID# 
										          	  	and census_date= '#dateformat(censusdate,'mm/dd/yyyy')#'
							          	  		</CFQUERY>  
							          	  	    <cfdump var="#UpdateCensusAtGivenDate#">
							          	</cfif> <!---cfif currentstatus Y /N --->
						       <!--- </cfif>   change in current status --->
				         </cfif> <!---cfif get token c--->
			     </cfif> <!---cfif get token B --->
			  </cfloop>
		     
		</CFLOOP>
	</cfoutput>

</cftransaction>	

<!--- ==============================================================================
	Relocate the page to original screen
	=============================================================================== --->
<CFLOCATION URL="Census.cfm">