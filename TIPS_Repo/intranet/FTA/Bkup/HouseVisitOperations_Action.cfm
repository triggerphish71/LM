<cfparam name="useThisEntryID" default="">
<cftry>
		<cfif #ListLen(form.fieldnames)# gt 0>
	<cftransaction>
		<CFOUTPUT>
		<cfif IsDefined("URL.Ihouse_Id")>
			<CFSET iHouseID= URL.Ihouse_Id>
		</cfif>
		
		<cfif IsDefined("URL.subAccount")>  
			<CFSET SubAccount=URL.subAccount>
		<CFELSE >
			<CFSET SubAccount=999999>
		</cfif>
		
		<CFIF IsDefined("dateToUse")>
			<CFSET DateToUse= URL.dateToUse>
		<CFELSE>
			<CFSET DateToUse=#nOW()#>
		</cfif> 
 		</CFOUTPUT>
			<cfif IsDefined("url.Save") and (url.Save is "Yes")>
			here
				<cfset useThisEntryID = url.EntryId>
				<cfloop from="1" to="#ListLen(form.fieldnames)#" index="fieldCount">
					<cfoutput>
					here2
						<CFSET LISTFIELD = ListGetAt(form.fieldnames,fieldCount,",") >
						<CFSET LISTDATA = Evaluate(ListGetAt(form.fieldnames,fieldCount,","))>
						<CFIF FIND("NTXTANSWER", LISTFIELD)>
							<CFSET TXTPART	= GETTOKEN(LISTFIELD,1, "_")>
							<cfset GROUPPART =  GETTOKEN(LISTFIELD,2, "_")>
							<cfset QUESTIONPART =  GETTOKEN(LISTFIELD,3, "_")>	
							<cfset SUBPART =  GETTOKEN(LISTFIELD,4, "_")>
									 here3 , #listdata#, #useThisEntryID#, #grouppart#, #questionpart#, #subpart#<br />
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
										#useThisEntryID#,
										#grouppart#,
										#questionpart#,
										#subpart#,
										'#listdata#',
										#NOW()#,
										'#FORM.EntryUserId#'  
									  	);
 										</cfquery>   
						 <CFELSEIF FIND("TXTANSWER", LISTFIELD)>
						 HERE4
							<CFSET TXTPART	= GETTOKEN(LISTFIELD,1, "_")>
							<cfset GROUPPART =  GETTOKEN(LISTFIELD,2, "_")>
							<cfset QUESTIONPART =  GETTOKEN(LISTFIELD,3, "_")>	
							<cfset SUBPART =  GETTOKEN(LISTFIELD,4, "_")>	
							#listdata#, #useThisEntryID#, #grouppart#, #questionpart#, #subpart#<br />
								<cfquery name="UpdateHouseVisitAnswers" datasource="#FTAds#" >							
								update dbo.HouseVisitAnswersII
								set cEntryAnswer = '#listdata#'
								where iHouseVisitEntry = #useThisEntryID# and
								iEntryGroupID = #grouppart# and 
								iQuestionID = #questionpart# and 
								iEntryQuestionSub = #subpart#
							</cfquery> 
						</CFIF>
					</cfoutput>
				</cfloop>
			<cfelse> <cfoutput>here3:  	#userRoleID#,	#iHouseID#,	#form.EntryUserId#, '#FORM.EntryuserFullName#', #form.dtentrydate#,	#Now()#)<br/></cfoutput>	
			<cfoutput> 
				<cfquery name="EnterHouseVisit" datasource="#FTAds#">
					INSERT INTO
					dbo.HouseVisitEntriesII
					(
					iRole,
					iHouseID,
					cUserName,
					cUserDisplayName,
					dtHouseVisit,
					dtCreated
					)
					VALUES
					(#userRoleID#,
					#iHouseID#,
					'#form.EntryUserId#',
					'#FORM.EntryuserFullName#',
					'#form.dtentrydate#',
					#Now()#);
					</cfquery>  
					<cfquery name="getHouseVisitID" datasource="#FTAds#">					
					SELECT
					max(iEntryID) as thisEntryID
					FROM
					dbo.HouseVisitEntriesII
				</cfquery>	
 			
				<cfset useThisEntryID = 	getHouseVisitID.thisEntryID>			
			
		</CFOUTPUT> here4<br/>
		<cfloop from="1" to="#ListLen(form.fieldnames)#" index="fieldCount">

			<cfoutput>
				<CFSET LISTFIELD = ListGetAt(form.fieldnames,fieldCount,",") >
				<CFSET LISTDATA = Evaluate(ListGetAt(form.fieldnames,fieldCount,","))>
				<CFIF FIND("TXTANSWER", LISTFIELD)>
					<CFSET TXTPART	= GETTOKEN(LISTFIELD,1, "_")>
					<cfset GROUPPART =  GETTOKEN(LISTFIELD,2, "_")>
					<cfset QUESTIONPART =  GETTOKEN(LISTFIELD,3, "_")>	
					<cfset SUBPART =  GETTOKEN(LISTFIELD,4, "_")>	
				 	#listdata#, #useThisEntryID#, #grouppart#, #questionpart#, #subpart#<br />
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
					#useThisEntryID#,
					#grouppart#,
					#questionpart#,
					#subpart#,
					'#listdata#',
					#NOW()#,
					'#FORM.EntryUserId#'  
					);
					</cfquery> 	
					#useThisEntryID#,
					#grouppart#,
					#questionpart#,
					#subpart#,
					'#listdata#',
					#NOW()#,
					'#FORM.EntryUserId#<br/> 
				</CFIF>
			</cfoutput>
		</cfloop>
</cfif>
	 </cftransaction>
		<cfelse>
		No Entries were made!. Please reload page!
		</cfif>	 
		<cfcatch type="Database">
		  A database error has occurred. Please try again later.
		</cfcatch>
		<cfcatch type="Expression">
		  An expression error has occurred. Please try again later.
		</cfcatch>
		<cfcatch type="MissingInclude">
		  An include file has gone missing. Please try again later.
		</cfcatch>
	 
	 <cfcatch type="any">
		<cfoutput>
			There was a problem creating the new House Visit Entry record.  <br />
			Please Contact the IT Help Desk at (888) 342-4252, if the problem continues. <br />
			<a href="HouseVisits.cfm?Role=#Role#&iHouse_ID=#ihouseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">Return to the House Visits Page</a>
		</cfoutput>
	</cfcatch>

</cftry> 
        	<cfoutput><cflocation url="EditHouseVisitEntryII.cfm?Save=No&iEntryUserId=#FORM.EntryUserId#&iEntryID=#useThisEntryID#&iHouse_ID=#iHouseID#&SubAccount=#subAccount#&DateToUse=#dateToUse#&role=#role#&EntryuserFullName=#EntryuserFullName#&hdnrolename=#hdnrolename#&userRoleID=#userRoleID#&EntryuserRole=#EntryuserRole#&numberOfMonths=#numberOfMonths#"></cfoutput>
 