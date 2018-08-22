<!----------------------------------------------------------------------------------------------------------
| DESCRIPTION - MoveIn/MoveInRespiteProcess.cfm                                                            |
|----------------------------------------------------------------------------------------------------------|
| Display Invoice Details for a Respite Resident that is MOVED OUT (state 4)                               |
| Called by: MoveInUpdate/MoveInInsert                                                                     |
| Calls/Submits:                                                                                           |
|----------------------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                                        |
|----------------------------------------------------------------------------------------------------------|
|  none                                                                                                    |
|----------------------------------------------------------------------------------------------------------|
| INCLUDES                                                                                                 |
|------------------------------------------------------------------------------------------------- --------|
|   none                                                                                                   |
|----------------------------------------------------------------------------------------------------------|
| HISTORY                                                                                                  |
|----------------------------------------------------------------------------------------------------------|
| Author     | Date       | Ticket      | Description                                                      |
|            |            | Project     |                                                                  |
|------------|------------|--------------------------------------------------------------------------------|
|R Schuette  | 08/05/2010 | Prj 25575   |Original Authorship                                               |
|Sfarmer     | 09/18/2013 | 102919      |Revise NRF approval process                                       |
|Sfarmer     | 11/05/2013 | 111520      |Revise so respites do not get auto cable charges                  |
|Sfarmer     | 06/04/2014 | 116824      |Replace dtRentEffective with dtMoveIn for use of deferred moveins |
|S Farmer    | 09/08/2014 | 116824      | Allow all houses edit BSF and Community Fee Rates                |
|S Farmer    | 2015-01-12 | 116824      | Final Move-in Enhancements                                       |
|S Farmer    | 2017-05-17 |             | included error process and check for $1.00 room rates            |
----------------------------------------------------------------------------------------------------------->
<!--- <cfdump var="#form#"> --->
<cfparam name="ConvertedDays" default="1">
<cfparam name="totaldays" default="0">
<cfoutput>
	<cfquery name="RespiteBSFCharge" datasource="#application.datasource#">
		select c.* from Charges c
		where c.iHouse_ID = #TenantInfo.iHouse_ID#
		and c.cChargeSet = '#getHouseChargeset.CName#'
		<cfif Occupancy eq 1>  <!--- 2nd resident charges are not setup by a room type so we don't want to look at it --->
			and c.iAptType_ID = #TenantInfo.iAptType_ID#
		</cfif>
		and c.iOccupancyPosition = #Occupancy#
	<!---MShah added for MC respite--->
		<cfif #form.iproductline_ID# eq 2>
		and c.iChargeType_ID = 1748	
		<cfelse>
		and c.iChargeType_ID = 7
		</cfif>
		and c.dtRowDeleted is null
	</cfquery>
    
    <!---  If no respite BSF rate, kick them back to the Move in Screen  ---->
    <cfif RespiteBSFCharge.RecordCount lt 1>
		<cfoutput>
		<cfquery name="qryRoomType" datasource="#application.datasource#">
			Select * from AptType where iAptType_ID = #TenantInfo.iAptType_ID#
		</cfquery>
		<cfquery name="qryARRep"  datasource="#application.datasource#">
	SELECT reg.cname 'Division', ops.cname 'Region',	h.cname 'Community',du.fname + ' ' +  du.lname as 'ArRep', Du.EMail as 'AREmail'
	,NU.fname + ' ' +  NU.lname 'Nurse', NU.EMail as NurseEmail
	FROM	House H
left	JOIN 	 ALCWEB.dbo.employees DU
		ON H.iAcctUser_ID = DU.Employee_ndx
left join  ALCWEB.dbo.employees Nu
		ON H.[cNurseUser_ID]= NU.Employee_ndx
join opsarea ops on h.iopsarea_id = ops.iopsarea_id
join region reg on ops.iregion_id = reg.iregion_id
	WHERE	  h.ihouse_id		=  #TenantInfo.iHouse_ID#
		</cfquery>
			 
				<cfset processname = "Respite Move In" >
				<cfset residentname = #resident#>
				<cfset residentID = #form.iTenant_ID#>
				<cfset Formname = "MoveInRespiteProcess.cfm">
			<CFSCRIPT>
				Msg1 = "No Respite BSF rates are setup for this Room Type and Occupancy.<BR>";
				Msg1 = Msg1 & "Occupancy: #Occupancy#<BR>";
				Msg1 = Msg1 & "Apartment Type: #qryRoomType.cdescription#<BR>";
			</CFSCRIPT>			
 				<cfset wherefrom = 'MoveIn'>
    	 <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">

		</cfoutput>
 
    </cfif>
        <!--- This check added per T.Bates 03/28/2017 --->
        <cfif RespiteBSFCharge.mamount   less than 10.00>
          <cfset processname = "Resident Move In" >
          <cfset residentname = #resident#>
          <cfset residentID = #form.iTenant_ID#>
          <cfset Formname = "MoveInFormInsert.cfm">
          <cfif IsSecondOccupant is 'yes'>
            <cfset Is2ndOccupant = "Second Occupant">
           <cfelse>
            <cfset Is2ndOccupant = "Single Occupant">
          </cfif>
          <CFSCRIPT>
					Msg1 = "The Street Rate for this room is below $10.00.<BR>";
					Msg1 = Msg1 & "Contact AR or Support to have the correct Street Rate entered for this room.<br>";					
					Msg1 = Msg1 & "Residency: #GetDescriptions.ResidencyType#<br>";
					Msg1 = Msg1 & "Apartment Type: #GetDescriptions.AptType#<BR>";
					Msg1 = Msg1 & "Occupancy: #Is2ndOccupant#<br>";
					Msg1 = Msg1 & "Product Line: #GetDescriptions.ProductLine#";
				</CFSCRIPT>
          <cfset wherefrom = 'MoveIn'>
          <cflocation url="../Shared/ErrorTemplate.cfm?processname=#processname#&Formname=#Formname#&wherefrom=#wherefrom#&residentID=#residentID#&residentname=#residentname#&Msg1=#Msg1#">
        </cfif>	
	<cfquery name="RespiteLOCCharge" datasource="#application.datasource#">
		select c.iChargeType_ID, c.cDescription, c.mAmount
		from Charges c
		Join SLevelType s on s.iSLevelType_ID = c.iSLevelType_ID and s.dtRowDeleted is null
		Where c.iHouse_ID = #TenantInfo.iHouse_ID#
            and c.cChargeSet = '#getHouseChargeset.CName#'
            and c.iChargeType_ID = 91
            and c.dtRowDeleted is null
            and #TenantInfo.iSPoints# between s.iSPointsMin and s.iSPointsMax		
	</cfquery>
	
	<cfif Month(TenantInfo.dtMoveIn) eq Month(TenantInfo.dtMoveOutProjectedDate)>
<!--- ===>BEGIN<BR />	 --->	
		<cfif Len(Month(TenantInfo.dtMoveIn)) lt 2>
			<cfset AcctMnth = "0"& Month(TenantInfo.dtMoveIn)>
		<cfelse>
			<cfset AcctMnth = Month(TenantInfo.dtMoveIn)>
		</cfif>
		<cfset APeriod = Year(TenantInfo.dtMoveIn)& AcctMnth>
		
			<cfquery name="InsertRespiteBSF" datasource="#application.datasource#" result="InsertRespiteBSF">
				insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
					,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart,cRowStartUser_ID,iDaysBilled )
				values
					(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteBSFCharge.iChargeType_ID#, '#APeriod#',getdate()
					,<cfif TenantInfo.iproductline_ID eq 2>
					1
					<cfelse>
					#GetQuantityForNewINV.Days#
					</cfif>
					, '#RespiteBSFCharge.cDescription#', 
					<cfif TenantInfo.iproductline_ID eq 2>
					#round((RespiteBSFCharge.mAmount*(GetQuantityForNewINV.Days)/30)*100)/100#
		            <cfelse>
					#RespiteBSFCharge.mAmount#
					</cfif>,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),'1solo period insert'
					,#GetQuantityForNewINV.Days#)
			</cfquery>
		<!--- 	<cfdump var="#InsertRespiteBSF#"> --->
<!--- 			<cfoutput>
			InsertRespiteBSF GetQuantityForNewINV.Days:#GetQuantityForNewINV.Days# ***. #RespiteBSFCharge.iChargeType_ID#<br />
			InsertRespiteCare GetQuantityForNewINVCare.Days:#GetQuantityForNewINVCare.CareDays# ***. #RespiteBSFCharge.iChargeType_ID#<br />
			</cfoutput> --->
			<cfif TenantInfo.iSPoints neq 0 and TenantInfo.iproductline_ID neq 2> <!---Mshah added here for LOC charge FOR MC respite--->
			<cfquery name="InsertRespiteLOC" datasource="#application.datasource#" result="InsertRespiteLOC">
				insert into InvoiceDetail(iInvoiceMaster_ID 
				,iTenant_ID 
				,iChargeType_ID 
				,cAppliesToAcctPeriod 
				,dtTransaction 
				,iQuantity 
				,cDescription 
				,mAmount 
				,dtAcctStamp 
				,iRowStartUser_ID 
				,dtRowStart )
				values
					(#variables.iInvoiceMaster_ID#
					,#TenantInfo.iTenant_ID#
					,#RespiteLOCCharge.iChargeType_ID#
					,'#APeriod#'
					,getdate()
					,#GetQuantityForNewINVCare.CareDays#
					,'#RespiteLOCCharge.cDescription#'
					,#RespiteLOCCharge.mAmount#
					,#CreateODBCDateTime(session.AcctStamp)#
					,#session.userid#,getdate()
					)
			</cfquery><!--- InsertRespiteLOC ***> #RespiteLOCCharge.iChargeType_ID#<br /> --->
			<!--- <cfdump var="#InsertRespiteLOC#"> --->
			</cfif>
	<cfelse>
		<!---<cfscript> MPeriods = DateDiff("m",TenantInfo.dtRentEffective,TenantInfo.dtMoveOutProjectedDate);</cfscript>--->
		
			<cfset startMonth = datepart('m',TenantInfo.dtMoveIn)>
			<cfset endMonth = datepart('m',TenantInfo.dtMoveOutProjectedDate)>
			<cfif endMonth lt startMonth>
				<cfset endMonth = endMonth + 12>
			</cfif>
			<cfset MPeriods = (endMonth - StartMonth)>

<!--- ==>Loop	MPeriods #MPeriods#<br /> --->	
		<cfloop from="0" to="#MPeriods#" step="1" index="i">
			<cfif i eq 0><!--- Beginning Period --->
				<cfscript> 
				// BSF
				FirstDayOfBillingMonth = dateadd("m",i+1,TenantInfo.dtRentEffective);
				FirstDayOfBillingMonth = MONTH(FirstDayOfBillingMonth)&'/01/'&YEAR(FirstDayOfBillingMonth);
				QuantityDays=datediff("d",TenantInfo.dtRentEffective,FirstDayOfBillingMonth);
				//CareQuantityDays=datediff("d",TenantInfo.dtMoveIn,FirstDayOfBillingMonth);				
				if(Len(Month(TenantInfo.dtRentEffective)) lt 2) 
					{AcctMnth = "0"&Month(TenantInfo.dtRentEffective);}
				else{AcctMnth = Month(TenantInfo.dtRentEffective);}
				// Care
				FirstDayOfBillingMonthCare = dateadd("m",i+1,TenantInfo.dtMoveIn);
				FirstDayOfBillingMonthCare = MONTH(FirstDayOfBillingMonthCare)&'/01/'&YEAR(FirstDayOfBillingMonthCare);				
				//QuantityDaysCare=datediff("d",TenantInfo.dtMoveIn,FirstDayOfBillingMonthCare);
				CareQuantityDays=datediff("d",TenantInfo.dtMoveIn,FirstDayOfBillingMonthCare);				
				if(Len(Month(TenantInfo.dtMoveIn)) lt 2) 
					{AcctMnth = "0"&Month(TenantInfo.dtMoveIn);}
				else{AcctMnth = Month(TenantInfo.dtMoveIn);}				
				</cfscript>
				<!--- #quantityDays#<br> --->
				<cfset APeriod = Year(TenantInfo.dtMoveIn)& AcctMnth>
					<!--- #quantityDays#<br> --->
					<cfquery name="InsertRespiteBSF" datasource="#application.datasource#" result="InsertRespiteBSF">
						insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
							,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, cRowStartUser_ID,iDaysBilled )
						values
							(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteBSFCharge.iChargeType_ID#, '#APeriod#',getdate()
							,<cfif TenantInfo.iproductline_ID eq 2>
								1
							<cfelse>
							#QuantityDays#
							</cfif>
						    , '#RespiteBSFCharge.cDescription#', 
					       <cfif TenantInfo.iproductline_ID eq 2>
					           #round((RespiteBSFCharge.mAmount*QuantityDays/30)*100)/100#
		           		   <cfelse>
								#RespiteBSFCharge.mAmount#
							</cfif>
							, #CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),'beginning period'
							,#QuantityDays#)
					</cfquery>InsertRespiteBSF ***>#RespiteBSFCharge.iChargeType_ID# <br />
					<!--- <cfdump var="#InsertRespiteBSF#"> --->
					<cfif TenantInfo.iSPoints neq 0 and TenantInfo.iproductline_ID neq 2> <!---Mshah added for MC respite--->
										<!--- #quantityDays#<br> --->
						<cfquery name="InsertRespiteLOC" datasource="#application.datasource#">
							insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
								,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart,ccomments, cRowStartUser_ID  )
							values
								(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteLOCCharge.iChargeType_ID#, '#APeriod#',getdate()
								,#CareQuantityDays#, '#RespiteLOCCharge.cDescription#', 
								#RespiteLOCCharge.mAmount#,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),null,'beginning period'
								)
						</cfquery>
						<!--- <br />InsertRespiteLOC ***> #RespiteLOCCharge.iChargeType_ID# ::  #TenantInfo.dtMoveIn# ' :: '  #FirstDayOfBillingMonthCare# --->
					</cfif>
			<!--- respite   CC meal charge 	<br />	--->
			<cfif GetMIAutoApplyCharges.RecordCount gt 0>
				<!--- A -#quantityDays#<br> --->
					<cfloop query="GetMIAutoApplyCharges">
					<!--- B - #quantityDays#<br> --->
					<cfif ((GetMIAutoApplyCharges.iChargeType_ID neq 69) 
					and (GetMIAutoApplyCharges.iChargeType_ID neq 14)
					and (GetMIAutoApplyCharges.iChargeType_ID neq 53))>
			<!--- ChargeTypeID ::	<cfoutput>#GetMIAutoApplyCharges.iChargeType_ID#</cfoutput> --->
				<!--- RECURRING PART --->
							<cfquery name="CheckforRecurringCharge" 
							datasource="#application.datasource#">
								select * from RecurringCharge rc
								where rc.iTenant_ID = #TenantInfo.iTenant_ID#
								and rc.iCharge_ID = #GetMIAutoApplyCharges.iCharge_ID#
								and rc.dtRowDeleted is null
							</cfquery>
						<!--- <cfdump var="#GetMIAutoApplyCharges#"	>
						<cfdump var="#CheckforRecurringCharge#"> --->
							<cfif CheckforRecurringCharge.RecordCount lt 1>
							<!--- C	- #quantityDays#<br>  --->
								<cfquery name="AddAutoApplyRecurringCharge" datasource="#application.datasource#">
									insert into RecurringCharge
									(iTenant_ID,iCharge_ID,dtEffectiveStart
									,dtEffectiveEnd
									,iQuantity,cDescription,mAmount,cComments
									,dtAcctStamp,iRowStartUser_ID,dtRowStart,bIsDaily)
									values
									(#TenantInfo.iTenant_ID#,#GetMIAutoApplyCharges.iCharge_ID#,getdate()
 
									,'12/31/2020'
							 
									,'1','#GetMIAutoApplyCharges.cDescription#',#GetMIAutoApplyCharges.mAmount#,'Created During MoveIn - AutoApply'
									,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),#GetMIAutoApplyCharges.bIsDaily#
									)
								</cfquery>
							</cfif>
								<!--- Then get info on what was just inserted for invoice  --->
							<!--- D - #quantityDays#<br> --->	
								<cfquery name="GetNewRecurringforInvoice" datasource="#application.datasource#">
									Select rc.* from RecurringCharge rc
									where rc.iTenant_ID = #TenantInfo.iTenant_ID#
									and rc.iCharge_ID = #GetMIAutoApplyCharges.iCharge_ID#
									and rc.dtRowDeleted is null 
								</cfquery>

					<!--- INVOICE PART --->
						<!--- E - #quantityDays#, #GetNewRecurringforInvoice.iRecurringCharge_ID#<br> --->
							<cfquery name="CheckforInvDtlRecord" datasource="#application.datasource#">
								select id.* from invoicedetail id 
								where id.iTenant_ID = #TenantInfo.iTenant_ID#
								and id.iChargeType_ID = #GetMIAutoApplyCharges.iChargeType_ID#
								and id.cAppliesToAcctPeriod = '#APeriod#' <!--- '#DateFormat(MonthList[i],'yyyymm')#' --->
								and id.iInvoiceMaster_ID = #variables.iInvoiceMaster_ID#
								<cfif CheckforRecurringCharge.RecordCount gt 0>
								and id.iRecurringCharge_ID = '#CheckforRecurringCharge.iRecurringCharge_ID#' 
								<cfelse>	
								and id.iRecurringCharge_ID = '#GetNewRecurringforInvoice.iRecurringCharge_ID#'
								</cfif>
								and id.dtRowDeleted is null
							</cfquery>
							<!--- <cfif CheckforInvDtlRecord.RecordCount lt 1> --->
							<!--- F - 	#quantityDays#, #GetNewRecurringforInvoice.iRecurringCharge_ID#<br> ---> 	
							<cfquery name="InsertAutoApplyCharge" datasource="#application.datasource#">
									insert into InvoiceDetail
									(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID 
									,cAppliesToAcctPeriod ,dtTransaction 
									,iQuantity 
									,cDescription
									, mAmount ,cComments ,dtAcctStamp 
									,iRowStartUser_ID ,dtRowStart,iRecurringCharge_ID )
									values
									(#variables.iInvoiceMaster_ID# ,#TenantInfo.iTenant_ID# ,#GetMIAutoApplyCharges.iChargeType_ID#
									,'#APeriod#'<!--- '#DateFormat(MonthList[i],'yyyymm')#' --->,getdate()
									,#QuantityDays#
									,'#GetMIAutoApplyCharges.cDescription#'
									,#GetMIAutoApplyCharges.mAmount#,'1Recurring Created at MoveIn',#CreateODBCDateTime(session.AcctStamp)#
									,0,getdate(),#GetNewRecurringforInvoice.iRecurringCharge_ID#
									)
								</cfquery>
				<!--- InsertAutoApplyCharge 1 #GetNewRecurringforInvoice.iRecurringCharge_ID# ***> #GetMIAutoApplyCharges.iChargeType_ID#<br /> --->
							<!--- </cfif>	 --->
						<!--- </cfif> --->
					</cfif>                    
					</cfloop>
					</cfif>
		<!--- END  respite   CC meal charge --->		
			<cfelseif i eq MPeriods> <!--- Ending Period --->
			<!--- i --  #i# MPeriods #MPeriods#<BR /> --->
			<!--- AA	- #quantityDays#<br> --->	
			<!--- #TenantInfo.dtRentEffective# - #TenantInfo.dtMoveOutProjectedDate#  #FirstdayOfBillingMonth#<BR /> --->
			<cfscript>
			//BSF
					FirstDayOfBillingMonth = DateAdd("m",i,TenantInfo.dtRentEffective);
					FirstdayOfBillingMonth = MONTH(	FirstdayOfBillingMonth)&"/01/"&YEAR(FirstdayOfBillingMonth);
					QuantityDays = DateDiff("d",FirstdayOfBillingMonth,TenantInfo.dtMoveOutProjectedDate)+1;
					if (Len(Month(dateadd("m",i,TenantInfo.dtRentEffective))) lt 2)
						{AcctMnth = "0"& Month(dateadd("m",i,TenantInfo.dtRentEffective));}
					else{AcctMnth = Month(dateadd("m",i,TenantInfo.dtRentEffective));}
					APeriod = Year(dateadd("m",i,TenantInfo.dtRentEffective))& AcctMnth;
			// Care		
					FirstDayOfBillingMonthCare = DateAdd("m",i,TenantInfo.dtMoveIn);
					FirstDayOfBillingMonthCare = MONTH(	FirstDayOfBillingMonthCare)&"/01/"&YEAR(FirstDayOfBillingMonthCare);
					CareQuantityDays = DateDiff("d",FirstdayOfBillingMonth,TenantInfo.dtMoveOutProjectedDate)+1;
					if (Len(Month(dateadd("m",i,TenantInfo.dtMoveIn))) lt 2)
						{AcctMnth = "0"& Month(dateadd("m",i,TenantInfo.dtMoveIn));}
					else{AcctMnth = Month(dateadd("m",i,TenantInfo.dtMoveIn));}
					APeriodCare = Year(dateadd("m",i,TenantInfo.dtMoveIn))& AcctMnth;					
				</cfscript>
			<!--- BB	--	#quantityDays#<br>	 --->
			 		<cfquery name="InsertRespiteBSF" datasource="#application.datasource#" result="InsertRespiteBSF">
						insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
							,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, cRowStartUser_ID,iDaysBilled )
						values
							(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteBSFCharge.iChargeType_ID#, '#APeriod#',getdate()
							,<cfif TenantInfo.iproductline_ID eq 2>
								1
							<cfelse>
							#QuantityDays#
							</cfif>
						    , '#RespiteBSFCharge.cDescription#', 
					       <cfif TenantInfo.iproductline_ID eq 2>
					           #round((RespiteBSFCharge.mAmount*QuantityDays/30)*100)/100#
		           		   <cfelse>
								#RespiteBSFCharge.mAmount#
							</cfif>
							, #CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),'ending period4'
							,#QuantityDays#)
					</cfquery>
					<!--- <cfdump var="#InsertRespiteBSF#"> --->
					<cfif TenantInfo.iSPoints neq 0 and TenantInfo.iproductline_ID neq 2>
				<!--- CC	-#quantityDays#<br>	 --->
						<cfquery name="InsertRespiteLOC" datasource="#application.datasource#">
							insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
								,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart, ccomments , cRowStartUser_ID )
							values
								(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteLOCCharge.iChargeType_ID#, '#APeriodCare#',getdate()
								,#CareQuantityDays#, '#RespiteLOCCharge.cDescription#',
								 #RespiteLOCCharge.mAmount#,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(), null,'ending period4'
								)
						</cfquery>
						<!--- InsertRespiteLOC  ***> #RespiteLOCCharge.iChargeType_ID#<br /> --->
						 
					</cfif>
			 <!---  respite   CC meal charge<BR /> --->
				<cfif GetMIAutoApplyCharges.RecordCount gt 0>
				<!--- DD	#quantityDays#<br> --->
				<cfloop query="GetMIAutoApplyCharges">
					<cfif ((GetMIAutoApplyCharges.iChargeType_ID neq 69) 
					and (GetMIAutoApplyCharges.iChargeType_ID neq 14)
					and(GetMIAutoApplyCharges.iChargeType_ID neq 53))>
						  <!--- RECURRING PART <BR /> --->
						<!--- EE - #quantityDays#<br>	 --->
							<cfquery name="CheckforRecurringCharge" datasource="#application.datasource#">
								select * from RecurringCharge rc
								where rc.iTenant_ID = #TenantInfo.iTenant_ID#
								and rc.iCharge_ID = #GetMIAutoApplyCharges.iCharge_ID#
								and rc.dtRowDeleted is null
							</cfquery>
							<cfif CheckforRecurringCharge.RecordCount lt 1>
						<!--- 	EE2	 - #quantityDays#<br> --->
								<cfquery name="AddAutoApplyRecurringCharge" datasource="#application.datasource#">
									insert into RecurringCharge
									(iTenant_ID,iCharge_ID,dtEffectiveStart
									,dtEffectiveEnd
									,iQuantity,cDescription,mAmount,cComments
									,dtAcctStamp,iRowStartUser_ID,dtRowStart,bIsDaily)
									values
									(#TenantInfo.iTenant_ID#,#GetMIAutoApplyCharges.iCharge_ID#,getdate()
 
									,'12/31/2020'
							 
									,'1','#GetMIAutoApplyCharges.cDescription#',#GetMIAutoApplyCharges.mAmount#,'Created During MoveIn - AutoApply'
									,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),#GetMIAutoApplyCharges.bIsDaily#
									)
								</cfquery>
							</cfif>
								<!--- Then get info on what was just inserted for invoice  --->
								<cfquery name="GetNewRecurringforInvoice" datasource="#application.datasource#">
									Select rc.* from RecurringCharge rc
									where rc.iTenant_ID = #TenantInfo.iTenant_ID#
									and rc.iCharge_ID = #GetMIAutoApplyCharges.iCharge_ID#
									and rc.dtRowDeleted is null 
								</cfquery>

					<!--- INVOICE PART --->
							<cfquery name="CheckforInvDtlRecord" datasource="#application.datasource#">
								select id.* from invoicedetail id 
								where id.iTenant_ID = #TenantInfo.iTenant_ID#
								and id.iChargeType_ID = #GetMIAutoApplyCharges.iChargeType_ID#
								and id.cAppliesToAcctPeriod = '#APeriod#' <!--- '#DateFormat(MonthList[i],'yyyymm')#' --->
								and id.iInvoiceMaster_ID = #variables.iInvoiceMaster_ID#
								<cfif CheckforRecurringCharge.RecordCount gt 0>
								and id.iRecurringCharge_ID = '#CheckforRecurringCharge.iRecurringCharge_ID#' 
								<cfelse>	
								and id.iRecurringCharge_ID = '#GetNewRecurringforInvoice.iRecurringCharge_ID#'
								</cfif>
								and id.dtRowDeleted is null
							</cfquery>
							<!--- #CheckforInvDtlRecord.RecordCount#<br /> --->
							<cfif CheckforInvDtlRecord.RecordCount lt 1>
						<!--- FF	#quantityDays#, #GetNewRecurringforInvoice.iRecurringCharge_ID#<br>	 --->
								<cfquery name="InsertAutoApplyCharge" datasource="#application.datasource#">
					 				insert into InvoiceDetail
									(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID 
									,cAppliesToAcctPeriod ,dtTransaction 
									,iQuantity 
									,cDescription
									, mAmount ,cComments ,dtAcctStamp 
									,iRowStartUser_ID ,dtRowStart,iRecurringCharge_ID )
									values
									(#variables.iInvoiceMaster_ID# ,#TenantInfo.iTenant_ID# ,#GetMIAutoApplyCharges.iChargeType_ID#
									,'#APeriod#'<!--- '#DateFormat(MonthList[i],'yyyymm')#' --->,getdate()
									,#QuantityDays#
									,'#GetMIAutoApplyCharges.cDescription#'
									,#GetMIAutoApplyCharges.mAmount#,'Recurring Created at MoveIn',#CreateODBCDateTime(session.AcctStamp)#
									,0,getdate(),#GetNewRecurringforInvoice.iRecurringCharge_ID#
									)
								</cfquery>
							<!--- InsertAutoApplyCharge 2 ***> #GetMIAutoApplyCharges.iChargeType_ID#<br /> --->
							</cfif>	 
						<!--- </cfif> --->
					</cfif>
					</cfloop>
					</cfif>
		<!---  END  respite   CC meal charge  --->		
			<cfelse> <!--- Middle Period --->
			<!--- AAA	- #quantityDays#<br> --->
				<cfscript>
				//  LOC
					QuantityDays = DaysInMonth(DateAdd("m",i,TenantInfo.dtRentEffective));
					if(Len(Month(dateadd("m",i,TenantInfo.dtRentEffective))) lt 2)
						{AcctMnth = "0"& Month(dateadd("m",i,TenantInfo.dtRentEffective));}
					else{AcctMnth = Month(dateadd("m",i,TenantInfo.dtRentEffective));}
					APeriod = Year(dateadd("m",i,TenantInfo.dtRentEffective))& AcctMnth;
				//  Care
					CareQuantityDays = DaysInMonth(DateAdd("m",i,TenantInfo.dtMoveIn));
					if(Len(Month(dateadd("m",i,TenantInfo.dtMoveIn))) lt 2)
						{AcctMnth = "0"& Month(dateadd("m",i,TenantInfo.dtMoveIn));}
					else{AcctMnth = Month(dateadd("m",i,TenantInfo.dtMoveIn));}
					APeriodCare = Year(dateadd("m",i,TenantInfo.dtMoveIn))& AcctMnth;					
				</cfscript>
			<!--- reset	- #quantityDays#<br> --->
				<cfquery name="InsertRespiteBSF" datasource="#application.datasource#">
					insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
						,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart,cRowStartUser_ID,iDaysBilled )
					values
						(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteBSFCharge.iChargeType_ID#, '#APeriod#',getdate()
						   ,<cfif TenantInfo.iproductline_ID eq 2>
								1
							<cfelse>
							#QuantityDays#
							</cfif>
						    , '#RespiteBSFCharge.cDescription#', 
					       <cfif TenantInfo.iproductline_ID eq 2>
					           #round((RespiteBSFCharge.mAmount*QuantityDays/30)*100)/100#
		           		   <cfelse>
								#RespiteBSFCharge.mAmount#
							</cfif>
							,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(),'middle period 5'
							,#QuantityDays#
						)
					</cfquery>
				<!--- ==> InsertRespiteBSF  ***> #RespiteBSFCharge.iChargeType_ID#<br /> --->
					<cfif TenantInfo.iSPoints neq 0 and TenantInfo.iproductline_ID neq 2>
				<!--- BBB	#quantityDays#<br> --->	
					<cfquery name="InsertRespiteLOC" datasource="#application.datasource#">
						insert into InvoiceDetail(iInvoiceMaster_ID ,iTenant_ID ,iChargeType_ID ,cAppliesToAcctPeriod ,dtTransaction 
							,iQuantity ,cDescription ,mAmount ,dtAcctStamp ,iRowStartUser_ID ,dtRowStart,ccomments ,cRowStartUser_ID )
						values
							(#variables.iInvoiceMaster_ID#, #TenantInfo.iTenant_ID#, #RespiteLOCCharge.iChargeType_ID#, '#APeriodCare#',getdate()
							,#CareQuantityDays#, '#RespiteLOCCharge.cDescription#', 
							#RespiteLOCCharge.mAmount#,#CreateODBCDateTime(session.AcctStamp)#,#session.userid#,getdate(), 'C','middle period 5'
							)
					</cfquery>
					<!--- InsertRespiteLOC ***> #RespiteLOCCharge.iChargeType_ID#<br /> --->
					</cfif>
				<!--- respite   CC meal charge --->
				<cfif GetMIAutoApplyCharges.RecordCount gt 0>
			<!--- ===>	CCC	- #quantityDays# respite   CC meal charge <br> --->
					<cfloop query="GetMIAutoApplyCharges">
					<!--- DDD - #quantityDays#<br>	 --->
					<cfif ((GetMIAutoApplyCharges.iChargeType_ID neq 69) 
					and (GetMIAutoApplyCharges.iChargeType_ID neq 14)
					and(GetMIAutoApplyCharges.iChargeType_ID neq 53))>
						<!--- RECURRING PART --->
					<!--- EEE	 - #quantityDays#<br>	 --->
						<cfquery name="CheckforRecurringCharge" datasource="#application.datasource#">
								select * from RecurringCharge rc
								where rc.iTenant_ID = #TenantInfo.iTenant_ID#
								and rc.iCharge_ID = #GetMIAutoApplyCharges.iCharge_ID#
								and rc.dtRowDeleted is null
							</cfquery>
					<!--- CheckforRecurringCharge.RecordCount::	#CheckforRecurringCharge.RecordCount#<br /> --->
							<cfif CheckforRecurringCharge.RecordCount lt 1>
						<!--- FFF	 - #quantityDays#, #GetNewRecurringforInvoice.iRecurringCharge_ID#<br>	 --->
								<cfquery name="AddAutoApplyRecurringCharge" datasource="#application.datasource#">
						 		insert into RecurringCharge
									(iTenant_ID
									,iCharge_ID
									,dtEffectiveStart
									,dtEffectiveEnd
									,iQuantity
									,cDescription
									,mAmount
									,cComments
									,dtAcctStamp
									,iRowStartUser_ID
									,dtRowStart
									,bIsDaily)
									values
									(#TenantInfo.iTenant_ID#
									,#GetMIAutoApplyCharges.iCharge_ID#
									,getdate() 
									,'12/31/2020'							 
									,'1'
									,'#GetMIAutoApplyCharges.cDescription#'
									,#GetMIAutoApplyCharges.mAmount#
									,'Created During MoveIn - AutoApply'
									,#CreateODBCDateTime(session.AcctStamp)#
									,#session.userid#
									,getdate()
									,#GetMIAutoApplyCharges.bIsDaily#
									)
								</cfquery>
							</cfif>
								<!--- Then get info on what was just inserted for invoice  --->
								<cfquery name="GetNewRecurringforInvoice" datasource="#application.datasource#">
									Select rc.* from RecurringCharge rc
									where rc.iTenant_ID = #TenantInfo.iTenant_ID#
									and rc.iCharge_ID = #GetMIAutoApplyCharges.iCharge_ID#
									and rc.dtRowDeleted is null 
								</cfquery>

					<!--- INVOICE PART --->
							<cfquery name="CheckforInvDtlRecord" datasource="#application.datasource#">
								select id.* from invoicedetail id 
								where id.iTenant_ID = #TenantInfo.iTenant_ID#
								and id.iChargeType_ID = #GetMIAutoApplyCharges.iChargeType_ID#
								and id.cAppliesToAcctPeriod = '#APeriod#' <!--- '#DateFormat(MonthList[i],'yyyymm')#' --->
								and id.iInvoiceMaster_ID = #variables.iInvoiceMaster_ID#
								<cfif CheckforRecurringCharge.RecordCount gt 0>
								and id.iRecurringCharge_ID = '#CheckforRecurringCharge.iRecurringCharge_ID#' 
								<cfelse>	
								and id.iRecurringCharge_ID = '#GetNewRecurringforInvoice.iRecurringCharge_ID#'
								</cfif>
								and id.dtRowDeleted is null
							</cfquery>
							<cfif CheckforInvDtlRecord.RecordCount lt 1>
							<!--- GGG -	quantityDays::#quantityDays#, GetNewRecurringforInvoice.iRecurringCharge_ID:: #GetNewRecurringforInvoice.iRecurringCharge_ID# CheckforInvDtlRecord.RecordCount ::#CheckforInvDtlRecord.RecordCount# <br> --->
								<cfquery name="InsertAutoApplyCharge" datasource="#application.datasource#">
									insert into InvoiceDetail
										(iInvoiceMaster_ID 
										,iTenant_ID 
										,iChargeType_ID 
										,cAppliesToAcctPeriod 
										,dtTransaction 
										,iQuantity 
										,cDescription
										, mAmount
										,cComments 
										,dtAcctStamp 
										,iRowStartUser_ID
										,dtRowStart
										,iRecurringCharge_ID )
									values
										(#variables.iInvoiceMaster_ID# 
										,#TenantInfo.iTenant_ID# 
										,#GetMIAutoApplyCharges.iChargeType_ID#
										,'#APeriod#'<!--- '#DateFormat(MonthList[i],'yyyymm')#' --->
										,getdate()
										,#QuantityDays#
										,'#GetMIAutoApplyCharges.cDescription#'
										,#GetMIAutoApplyCharges.mAmount#
										,'Recurring Created at MoveIn'
										,#CreateODBCDateTime(session.AcctStamp)#
										,0
										,getdate()
										,#GetNewRecurringforInvoice.iRecurringCharge_ID#
									)
								</cfquery>
								<!--- InsertAutoApplyCharge 3 #GetNewRecurringforInvoice.iRecurringCharge_ID# ***> #GetMIAutoApplyCharges.iChargeType_ID#<br /> --->
							</cfif>	
						<!--- </cfif> --->
					</cfif>
					</cfloop>
					</cfif>
		<!---  END  respite   CC meal charge  --->		
			</cfif>
		</cfloop>
	</cfif>
	 
 
			    
</cfoutput>
  