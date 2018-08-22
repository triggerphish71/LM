<cfoutput>	
	 
	<input type="hidden"  name="EntryUserId" 			id="hdnEntryUserId" 		value="#EntryUserId#" />
	<input type="hidden"  name="UserId" 				id="UserId" 				value="#EntryUserId#" />	
	<input type="hidden"  name="Role" 					id="hdnRole" 				value="#role#" />
	<input type="hidden"  name="EntryuserFullName" 		id="hdnEntryuserFullName" 	value="#EntryuserFullName#" />
	<input type="hidden"  name="hdnrolename" 			id="hdnrolename" 			value="#hdnrolename#" />
	<input type="hidden"  name="userRoleID" 			id="hdnuserRoleID" 			value="#userRoleID#" />
	<cfif IsDefined("url.EntryuserRole")>
		<input type="hidden"  name="EntryuserRole" 			id="idEntryuserRole" 		value="#EntryuserRole#"/>
	<cfelse>
		<input type="hidden"  name="EntryuserRole" 			id="idEntryuserRole" 		value="#thisuserrole#"/>				
	</cfif>
	<input type="hidden"  name="numberOfMonths" 		id="idnumberOfMonths" 		value="#numberOfMonths#"/>
	<input type="hidden"  name="thisbasedate"	 		id="idthisbasedate" 		value="#dateFORMAT(Now(),"MM/DD/YYYY")#"/>
	<input type="hidden"  name="thishouseid"	 		id="idthishouseid" 			value="#url.iHouse_ID#" />	
	<input type="hidden"  name="thisdatetouse"	 		id="idthisdatetouse" 		value="#url.datetouse#" />
	<input type="hidden"  name="thissubaccount"	 		id="idthissubaccount" 		value="#form.thisSubAccount#" />	
	<input type="hidden"  name="thisuserrole"	 		id="idthisuserole" 			value="#thisuserrole#"/>

</cfoutput>
<cftry>
		<cfif #ListLen(form.fieldnames)# gt 0>
	<cftransaction>
		<CFOUTPUT>
			<cfif isDefined("url.ccllcHouse")>
				<cfset ccllcHouse = #url.ccllcHouse#>
			<cfelse> <cfset ccllcHouse = 0>
			</cfif>
						
		<cfif IsDefined("URL.Ihouse_Id")>
			<CFSET iHouseID= URL.Ihouse_Id>
		<CFELSE> 
			<CFSET iHouseID=50>
		</cfif>
		
		<cfif IsDefined("URL.subAccount")>  
			<CFSET SubAccount=URL.subAccount>
		<CFELSE >
			<CFSET SubAccount=form.thissubaccount>
		</cfif>
		
		<CFIF IsDefined("dateToUse")>
			<CFSET DateToUse= URL.dateToUse>
		<CFELSE>
			<CFSET DateToUse=#nOW()#>
		</cfif> 

 

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
		</CFOUTPUT>
		
		<cfloop from="1" to="#ListLen(form.fieldnames)#" index="fieldCount">
			<cfoutput>
				<CFSET LISTFIELD = ListGetAt(form.fieldnames,fieldCount,",") >
				<CFSET LISTDATA = Evaluate(ListGetAt(form.fieldnames,fieldCount,","))>
				<CFIF FIND("TXTANSWER", LISTFIELD)>
					<CFSET TXTPART	= GETTOKEN(LISTFIELD,1, "_")>
					<cfset GROUPPART =  GETTOKEN(LISTFIELD,2, "_")>
					<cfset QUESTIONPART =  GETTOKEN(LISTFIELD,3, "_")>	
					<cfset SUBPART =  GETTOKEN(LISTFIELD,4, "_")>	
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
					#getHouseVisitID.thisEntryID#,
					#trim(grouppart)#,
					#trim(questionpart)#,
					#trim(subpart)#,
					'#trim(listdata)#',
					#trim(NOW())#,
					'#trim(FORM.EntryUserId)#'  
					);
					</cfquery> 	 
				</CFIF>
			</cfoutput>
		</cfloop>

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
			<a href="HouseVisits.cfm?ccllcHouse=#ccllcHouse#&Role=#Role#&iHouse_ID=#ihouseId#&SubAccount=#subAccount#&DateToUse=#dateToUse#">Return to the House Visits Page</a>
		</cfoutput>
	</cfcatch>

</cftry> 
	<cfoutput>
	<table width="100%"  border="1">
		<tr>
			<td bgcolor="##CCFFFF" bordercolor="##FF9900">Your House Visit Report has been saved. It can be viewed  <a href="HouseVisitIIEntryEdit.cfm?Save=No&iEntryUserId=#FORM.EntryUserId#&iEntryID=#getHouseVisitID.thisEntryID#&ccllcHouse=#ccllcHouse#&iHouse_ID=#iHouseID#&SubAccount=#subAccount#&DateToUse=#dateToUse#&role=#role#&EntryuserFullName=#EntryuserFullName#&hdnrolename=#hdnrolename#&userRoleID=#userRoleID#&EntryuserRole=#EntryuserRole#&numberofmonths=#numberofmonths#">here</a> for reviewing and corrections</td>
		</tr>
		<tr>
			<td bgcolor="##CCFFFF" bordercolor="##FF9900">Return to House Visits Main Page  <a href="HouseVisitsII.cfm?iHouse_ID=#iHouseID#&SubAccount=#subAccount#&DateToUse=#dateToUse#&role=#role#&EntryuserFullName=#EntryuserFullName#&hdnrolename=#hdnrolename#&userRoleID=#userRoleID#&EntryuserRole=#EntryuserRole#&numberofmonths=#numberofmonths#">here</a>.</td>
		</tr>		
	</table>
 <!--- <cflocation url="EditHouseVisitEntryII.cfm?Save=No&iEntryUserId=#FORM.EntryUserId#&iEntryID=#getHouseVisitID.thisEntryID#&iHouse_ID=#iHouseID#&SubAccount=#subAccount#&DateToUse=#dateToUse#&role=#role#&EntryuserFullName=#EntryuserFullName#&hdnrolename=#hdnrolename#&userRoleID=#userRoleID#&EntryuserRole=#url.EntryuserRole#&numberofmonths=#url.numberofmonths#"> --->
 </cfoutput>