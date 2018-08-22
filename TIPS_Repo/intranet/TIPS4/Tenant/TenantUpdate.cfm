<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|  Database submit for edited tenant information                                               |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|   none                                                                                       |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| pbuendia   | 02/20/2002 | Added ChargSet Submit.                                             |
| savison    | 02/21/2002 | Fixed birthdate month and day transposition.                       |
| savison    | 04/01/2002 | Added bUsesEFT field.                                              |
| ranklam    | 08/23/2005 | Changed the logic around the update statement.  It only updates    |
|            |            | the cCharges set field if it is specified in the form scope.       |
| ranklam    | 09/22/2005 | Changed the set statement logic because it was looking for the     |
|            |            | wrong form fields for city and state. I also made sure that the    |
|            |            | form doesnt error if there is a ' in the values.                   |
| ranklam    | 09/22/2005 | cSlevelTypeSet was missing a else statement so i added it.  Also   |
|            |            | changed the logic around the bIsPayer to update it even if its     |
|            |            | not in the form scope since its a checkbox.                        |
| ranklam    | 02/07/2006 | Changed query string building logic so chargeset is house default  |
|            |            | not specified in the form.                                         |
| Ssathya    | 06/02/08   | Did modification as per project 20125.      	                   |
| Ssathya    |11/10/2008  |Project 30178 modification 11/10/2008 ssathya added this Guarantor 
|                            Agreement to the LinkTenantcontact query
| Rschuette  | 2/24/2009  |Proj 26955 BOND. added update to TenantUpdate to include bond items.|
| Rschuette	 | 3/4/2009   |Proj 34593 Have Payer remain as payer after house edits contact info|
| Rschuette	 | 3/24/2009  |Proj 35313 Have guaranor chckbox display right to db data           |
| RSchuette	 | 5/14/2009  |Proj 36391 PayorCheck query update
| RSchuette	 | 7/23/2009  |Proj 36359 MICheck,Guarentor Update, DefferedPymnt updates
| RSchuette  | 8/26/2009  |Proj 42510 BondMissing Item back in use                             |
| sathya     | 09/09/2010 |Project 60038 Sathya Add the new contract management                |	
| sfarmer    | 03/21/2012 |Project 75019 changes for multiple EFT and deferred NRF             |
| sfarmer    | 09/05/2012 |Project 95010 using eft exempt from late fee                        |
| gthota     | 10/05/2012 |project 93502 Was a Move In Check received checkbox code updated    |
| sfarmer    | 11/20/2012 |tickets 97882, 95010, 95009, 95468, 97570, 97710 for  misc. updates |
| gthota     | 12/11/2012 |project 99356/99404 Was a Bond and guarantor update issue           |
| sfarmer    | 08/08/2013 |project 106456 EFT Updates                                          |
| sfarmer    | 08/19/2013 |project 109737 Correct when bIsGuarantorAgreement and               |
|            |            |when oGuarentorAgreement is used                                    |
|Mshah		 | 05/18/2016 |added MCOID and medicaid elig date at line number 325 to 330        |
| Mshah		 | 05/23/2016 |Fix issue for dtMCswitch                                            |
|MStriegel   | 11/13/2017 | Added bundled pricing logic                                        |
|mstriegel   | 04/10/2018 | fixed the logic for bMoveInSummary - FIX_                         |
|mstriegel   | 08/16/2018| Added the dtMC2ALSwitch and bMC2AL t-sql to update                  |
|mstriegel   | 08/21/2018| modified the query to NULL all military questions                   |
----------------------------------------------------------------------------------------------->

 <cfparam name="chasExecutor" default="">
 <!--- RSA - 9/22/05 - added to make sure update doesn't error if there is a ' in any of the form values --->
<!--- replace all single quotes with double single quotes in the form fields --->
<cfloop list="#FIELDNAMES#" index="loopVar" delimiters=",">
	<cfset string = "form." & loopVar & " = Replace(form." & loopVar & ",""'"",""''"",""ALL"")">
	<cfset temp = evaluate(string)>
</cfloop>
 
<!--- Set variable for timestamp to record corresponding times for transactions --->
<cfquery name="getDate" datasource="#APPLICATION.datasource#">
	select getDate() as Stamp
</cfquery>
<cfset TimeStamp = createODBCDateTime(getDate.Stamp)>
 
<!--- Check for conflicing payor checkboxes and throw an error if needed --->
<cfif isDefined("bIsPayer") and isDefined("ContactbIsPayer")>
	<cfquery name="PayorCheck" datasource="#APPLICATION.datasource#">
		select * 
		from LinkTenantContact ltc WITH (NOLOCK)
		join Contact c WITH (NOLOCK) on (ltc.iContact_id = c.iContact_id and c.dtRowDeleted is null)
		join Tenant t WITH (NOLOCK) on (t.iTenant_id = ltc.iTenant_id and t.dtrowdeleted is null)
		where ltc.dtRowDeleted is null 
		and	ltc.bIsPayer = 1 and t.bIsPayer = 1
		and t.iTenant_id = #form.iTenant_id#
	</cfquery>
	
<!--- <cfif PayorCheck.RecordCount gte 1>
		<cfoutput>
			#PayorCheck.cFirstName# #PayorCheck.cLastName# is currently the payor(s).<BR>
			The tenant may only be the payor if there is no contact as the payor.<BR>
			<a href="http://#server_name#/intranet/TIPS4/Tenant/TenantEdit.cfm?ID=#form.iTenant_id#" STYLE="font-size: 18;">Click here To Continue.</a>
		</cfoutput>
		<cfabort>
	</cfif> --->
</cfif>

<!--- Retrieve Tenant Information for Solomon Update --->
<cfquery name="Tenant" datasource="#APPLICATION.datasource#">
	select * 
	from Tenant T WITH (NOLOCK)
	join TenantState ts WITH (NOLOCK) on (T.iTenant_id = ts.iTenant_id and ts.dtRowDeleted is null)
	where T.iTenant_id = #form.iTenant_id#
</cfquery>

<!--- Fire off email to bondemail group if the tenant was bond and is switching to non bond. --->
<cfif tenant.bIsBond eq 1 and (isdefined("form.cBondTenant") and (form.cBondTenant eq 0))>
	<cfmail type="HTML" to="bondemail@alcco.com" from="TIPS4-Message@alcco.com" subject="Tenant turning non-Bond">
		#session.housename#,<BR>
		<BR>
		#tenant.cLastName#, #tenant.cFirstName# (#tenant.iTenant_ID#, #tenant.cSolomonKey#) was Bond, and has been switched to non-Bond.<BR>
		<BR>
		Change made by #session.fullname# .<BR> 
		At: #TimeStamp# 
		<BR> 
	 </cfmail> 
</cfif> 

<cfquery name="GetHouseChargeSet" datasource="#application.datasource#">
	SELECT C.cName
	FROM ChargeSet C WITH (NOLOCK)
	INNER JOIN House H WITH (NOLOCK) ON H.iChargeSet_ID = C.iChargeSet_ID
	WHERE iHouse_ID = #Tenant.iHouse_ID#
</cfquery>

<cfif GetHouseChargeSet.RecordCount eq 0>
	<cfthrow message="No house default chargeset found for house_id #Tenant.iHouse_ID#.">
</cfif>

<cfquery name="bondhouse" datasource="#application.datasource#">
	select iBondHouse from house WITH (NOLOCK) where ihouse_id = #session.qSelectedHouse.iHouse_ID#
</cfquery>

<cftransaction>

	<!---<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>--->
	<cfif isdefined('form.chasExecutor')>
		<cfset chasExecutor = #form.chasExecutor#>
	<cfelse> 
		<cfset chasExecutor = "">
	</cfif>
	
		<cfquery name="updatetenantresidenceagreement" datasource="#APPLICATION.datasource#">
			update tenant set
			cFirstName = '#form.cFirstName#',
			cMiddleInitial = '#form.cMiddleInitial#',
			cLastName = '#form.cLastName#',
			cPreviousAddressLine1 = <cfif form.cPreviousAddressLine1 neq ''> '#form.cPreviousAddressLine1#' <cfelse> null </cfif>,
			cPreviousAddressLine2 = <cfif form.cPreviousAddressLine2 neq ''> '#form.cPreviousAddressLine2#' <cfelse> null </cfif>,
			cPreviousCity = <cfif form.cPreviousCity neq ''> '#form.cPreviousCity#' <cfelse> null </cfif>,
			cPreviousState = <cfif form.cPreviousState neq ''> '#form.cPreviousState#' <cfelse> null </cfif>,
			cPreviouszipCode = <cfif cPreviouszipCode neq ''> '#cPreviouszipCode#' <cfelse> null </cfif>,
			cSSN = '#form.cSSN#',
			chasExecutor = '#chasExecutor#',
			dbirthdate = '#form.dbirthdate#',
			iOutsidePhoneType1_id = #form.iOutsidePhoneType1_id#,
			cOutsidePhoneNumber1  = '#form.areacode1##form.prefix1##form.number1#',
			iOutsidePhoneType2_id = #form.iOutsidePhoneType2_id#,
			cOutsidePhoneNumber2  = '#form.areacode2##form.prefix2##form.number2#',
			iOutsidePhoneType3_id = #form.iOutsidePhoneType1_id#,
			cOutsidePhoneNumber3  = '#form.areacode3##form.prefix3##form.number3#',
			
			cEmail = '#form.cEmail#',
			dtBondCert = <cfif isdefined("form.txtBondReCertDate")> '#form.txtBondReCertDate#' <cfelse> null </cfif>,
			bIsBond = <cfif isdefined("form.cBondTenant")> '#form.cBondTenant#' <cfelse> null </cfif>,
			<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
            	cResidenceAgreement = <cfif isdefined("form.cResidenceAgreement") and form.cResidenceAgreement neq ""> #form.cResidenceAgreement# <cfelse> null </cfif>,
                <!---<cfif  Isdefined("bDropIsPayer") and  bDropIsPayer is "X">   <!--- Added 93502 project code issue --->
				 <cfelse>   --->        
			     bIsPayer = <cfif isdefined("form.bIsPayer") and form.bIsPayer neq ""> #form.bIsPayer# <cfelse> null </cfif>,
				<!--- </cfif>--->
                cMonthRASigned = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Form.cMonthRASigned#">,
            </cfif>
            
			cResidentFee = <cfif isdefined("form.cResidentFee") and form.cResidentFee neq ""> #form.cResidentFee# <cfelse> null </cfif>,
			iRowStartUser_id = #session.UserID#,
			dtRowStart = getdate() 
			<cfif IsDefined("form.cOutsideAddressLine1") is "Yes"> 
				<cfif form.cOutsideAddressLine1 neq ''>,cOutsideAddressLine1 =  '#form.cOutsideAddressLine1#' </cfif>
			</cfif>
			<cfif IsDefined("form.cOutsideAddressLine2") is "Yes" > 
				<cfif  form.cOutsideAddressLine2 neq ''>,cOutsideAddressLine2 =  '#form.cOutsideAddressLine2#' </cfif>
			</cfif>
			<cfif IsDefined("form.cOutsideCity") is "Yes" > 
				<cfif  form.cOutsideCity neq ''>,cOutsideCity =  '#form.cOutsideCity#' </cfif>
			</cfif>
			<cfif IsDefined("form.cOutsideStateCode") is 'Yes' > 
				<cfif  form.cOutsideStateCode neq ''>,cOutsideStateCode =  '#form.cOutsideStateCode#'  </cfif>
			</cfif>
			<cfif IsDefined("form.cOutsidezipCode") is 'Yes' > 
				<cfif  form.cOutsidezipCode neq ''>,cOutsidezipCode =  '#cOutsidezipCode#'</cfif>
			</cfif>
			WHERE iTenant_id = #form.iTenant_id#
		</cfquery>
	 <!---</cfif>--->
	<cfif Isdefined("bDropIsPayer") and  bDropIsPayer is "X">
		<cfquery name="DropASPayor" datasource="#APPLICATION.datasource#">
			update	Tenant 
			set bIsPayer =   null  
			where iTenant_id = #form.iTenant_id#	
		</cfquery>	 
		<!---<cfquery name="DropASPayor" datasource="#APPLICATION.datasource#">
			update	TenantState
			set bUsesEFT =   null  
			where iTenant_id = #form.iTenant_id#	
		</cfquery>--->	
		 
	<!---Mshah added here to check if there is any EFT with payer or contact, system should not drop resident from busesEFT--->
			<cfquery name="EFTActive" datasource="#application.datasource#">
			Select iEFTAccount_ID from EFTAccount WITH (NOLOCK)
			where   cSolomonKey = '#tenantSolomonKey#'
			and dtrowdeleted is null
			</cfquery>			
				<cfif EFTActive.recordcount is 0 >
				    <cfquery name="DropASPayor" datasource="#APPLICATION.datasource#">
						update	TenantState
						set bUsesEFT =   null  
						where iTenant_id = #form.iTenant_id#	
					</cfquery>	
				</cfif>	 
	</cfif> 
		<cfif isDefined('form.cComments')>
			<cfquery name="updatetenantcoments" datasource="#APPLICATION.datasource#">
				update tenant set
				cComments = '#form.cComments#' 
				WHERE iTenant_id = #form.iTenant_id#
			</cfquery>
		</cfif>	
	<!---Mshah added this code to change the billingtype of the resident if changes the productline--->	
	<cfif IsDefined("form.iproductline_id") and #form.iproductline_id# NEQ #Tenant.iproductline_ID#>	
	   <cfif #form.iproductline_id# eq 2 and #Tenant.iproductline_ID# eq 1>
	        <cfquery name="updatetenantbillingtype" datasource="#APPLICATION.datasource#" result="updatetenantbillingtype">	
				Update tenant 
				set cBillingtype = 'M'
				WHERE iTenant_id = #form.iTenant_id#
			</cfquery>	
	    <cfelseif  #form.iproductline_id# eq 1 and #Tenant.iproductline_ID# eq 2>
		      <cfquery name="updatetenantbillingtype" datasource="#APPLICATION.datasource#" result= "updatetenantbillingtype">	
			      Update tenant 
			      set cBillingtype = '#session.qselectedhouse.cBillingType#'
			      WHERE iTenant_id = #form.iTenant_id#
		      </cfquery>
	  </cfif>
		 <!--- <cfdump var="#updatetenantbillingtype#">--->
	</cfif>  
	<!---Mshah end--->	
	<cfquery name="CheckMICheckDate"  datasource="#APPLICATION.datasource#">
		select isnull(dtMICheckReceived,'') as dtMICheckReceived from tenantstate WITH (NOLOCK) where itenant_id = #form.iTenant_id#
	</cfquery>
 <!--- 95010 late fee exempt when using eft --->
	<cfquery name="ServicePoints" datasource="#APPLICATION.datasource#">
		update	TenantState
		set	
		<!--- mstriegel 08/16/2018 ---->
		<cfif (tenant.iProductLine_ID NEQ form.iproductline_id) AND (form.iproductline_id EQ 1) AND (tenant.iProductLine_id EQ 2)>
		bMC2AL = 1,
		</cfif>
		<!--- mstriegel end 08/16/2018 ---->
		iproductline_id=#trim(form.iproductline_id)#
		


		,iresidencyType_ID =#trim(form.iresidencytype_id)#
		<cfif isDefined("form.bUsesEFT") and form.bUsesEFT neq "">,bUsesEFT =  #form.bUsesEFT#
																
		</cfif> <!---,bIsLateFeeExempt = 1   <cfelse> null 	--->
		<cfif isDefined("form.iStateDefinedCareLevel") and form.iStateDefinedCareLevel neq "">,iStateDefinedCareLevel =  #form.iStateDefinedCareLevel# <cfelse>,iStateDefinedCareLevel =   null </cfif>
		<cfif isDefined("form.PrimaryDiagnosis")>,iPrimaryDiagnosis=#isBlank(form.PrimaryDiagnosis,'null')#</cfif>
		<cfif isDefined("form.SecondaryDiagnosis")>,iSecondaryDiagnosis=#isBlank(form.SecondaryDiagnosis,'null')#</cfif>
		<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)></cfif>
		<cfif isDefined("form.PromotionUsed")>, cTenantPromotion =#isBlank(form.PromotionUsed,'null')#</cfif>	
		<cfif isdefined("form.cDeferredPayment") and form.cDeferredPayment eq 1>,bDeferredPayment =  1 <cfelse>,bDeferredPayment =  0 </cfif>
		<cfif ( isdefined("form.cMICheckReceived") and (cMICheckReceived eq 1))><!--- Checked --->	<!--- Added 93502 Project code issue --->		
				,bMICheckReceived = 1
				,dtMICheckReceived = getdate()
			<cfelse>
			<!--- Unchecked --->
					,bMICheckReceived = 0 
					,dtMICheckReceived = null			
		</cfif>
		<!---<cfif isdefined("form.cMICheckReceived")><!--- Checked --->
			<cfif (CheckMICheckDate.dtMICheckReceived is '1900-01-01 00:00:00.000')  or CheckMICheckDate.dtMICheckReceived is '' >
				,bMICheckReceived = 1
				,dtMICheckReceived = getdate()
			<cfelse><!--- Unchecked --->
					,bMICheckReceived = 0 
					,dtMICheckReceived = null
			</cfif>
		</cfif>--->
		<!---<cfif (ListContains(session.groupid,'284') gt 0)>    <!--- Bond code change--->
		   ,cBondHouseEligible = <cfif isdefined("form.cboBondCertReceived") and form.cboBondCertReceived eq 1> 1<cfelse> null</cfif>
		<cfelse>--->
		<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
		<cfif ( isdefined("form.bContractManagementAgreement") and (bContractManagementAgreement eq 1))>
			,bContractManagementAgreement = 1 <cfelse>,bContractManagementAgreement = 0 
		</cfif>
	    </cfif>
		
		<cfif (ListContains(session.groupid,'284') gt 0)>
			,cBondHouseEligible = <cfif isdefined("form.cboBondCertReceived") and form.cboBondCertReceived eq 1> 1<cfelse> null</cfif>
		</cfif>
		
		<!--- mstriegel 08/21/2018 ---->
		,cMilitaryVA = null 
		,cMilitaryStartDate = null
		,cMilitaryEndDate =null
		,VaBenefits = null
		,VaRepresentativeContacted = null
		,VaBranchOfMilitary = null
		<!---- mstriegel end 08/21/2018 --->
		
		,iRowStartUser_id=#session.UserID# 
		,dtRowStart= getdate()
		<cfif isdefined("form.dSocSec")>,dSocSec = #dSocSec# </cfif> <!--- 75019 --->
		<cfif isdefined("form.dMiscPayment")>,dMiscPayment = #dMiscPayment# </cfif> <!--- 75019 --->
		<!--- mstriegel 04/10/18 --->
		<cfif bMoveInSummaryHidden EQ 1>,bMoveInSummary = 1<cfelse>,bMoveInSummary = NULL</cfif> 
		<!--- end mstriegel 04/10/18 --->
			<cfif (IsDefined("cMedicaidAuthorizationNbr") and (cMedicaidAuthorizationNbr is not ''))>
			,cMedicaidAuthorizationNbr = '#cMedicaidAuthorizationNbr#'
		</cfif>		
		<cfif (IsDefined("dtFDOS") and (dtFDOS is not ''))>
			,dtAuthFDOS = #CreateODBCDateTime(dtFDOS)#
		</cfif>		
		<cfif (IsDefined("dtTDOS") and (dtTDOS is not ''))>
			,dtAuthTDOS = #CreateODBCDateTime(dtTDOS)#
		</cfif>
		<cfif (IsDefined("cNJHSP") and (cNJHSP is not ''))>
			,cNJHSP = '#cNJHSP#'
		</cfif>		
		<cfif (IsDefined("mMedicaidCopay") and (mMedicaidCopay is not ''))>
			,mMedicaidCopay = #mMedicaidCopay#
		</cfif>						
		<cfif (IsDefined("iPICD") and (iPICD is not ''))>
			,iPICD = '#iPICD#'
		</cfif>		
		<cfif (IsDefined("iSICD") and (iSICD is not ''))>
			,iSICD = '#iSICD#'
		</cfif>		
		<cfif (IsDefined("iTICD") and (iTICD is not ''))>
			,iTICD = '#iTICD#'
		</cfif> 			
		<cfif (IsDefined("cMCO") and (cMCO is not ''))>
			,iMCOProvider = '#cMCO#'
		</cfif>
        <cfif (IsDefined("cMCOIDNbr") and (cMCOIDNbr is not ''))>
			,cMCOIDNbr = '#cMCOIDNbr#'
		</cfif>
		<cfif (IsDefined("MedicaidEligDate") and (MedicaidEligDate is not ''))>
			,dtMedicaidEligibility = #CreateODBCDateTime(MedicaidEligDate)#
		</cfif>
        <cfif IsDefined("form.iproductline_id") and #form.iproductline_id# NEQ #Tenant.iproductline_ID#>
			<cfif #form.iproductline_id# eq 2 and #Tenant.iproductline_ID# eq 1>
			,dtMCswitch = getdate()
			</cfif>
		</cfif>	
		<!--- mstriegel:11/13/2017 --->
		<cfif isdefined("form.hasBundledPricing") and form.hasBundledPricing EQ "No">
			,bIsBundled = NULL
		<cfelseif isdefined("form.hasBundledPricing") and form.hasBundledPricing EQ "Yes" and Not isdefined("form.bundledPricing")>
			,bIsBundled = 0
		<cfelse>
			,bIsBundled = 1
		</cfif>	
		<!--- end mstriegel:11/13/2017 --->
     
		where iTenant_id = #form.iTenant_id#	
	</cfquery>
	<cfif isDefined("session.CodeBlock") and ListFindNoCase(session.CodeBlock,25) GT 0>  <!--- only AR can update --->
		<cfif isDefined("form.bUsesEFT") and form.bUsesEFT neq "">
			<!--- check to see if EFT Info exists for this resident --->
			<cfquery name="existingEFT" datasource="#application.datasource#">
				select iEFTAccount_id from EFTAccount WITH (NOLOCK) where cSolomonKey = '#trim(Tenant.cSolomonKey)#'
			</cfquery>
			
			<cfif not isDefined("form.cAccountType")><font color="red"><strong>You selected this person for EFT, you MUST check whether their account is 
			checkings or savings for the form to submit.  GO BACK.</strong></font><cfabort></cfif>
			
			<cfif existingEFT.recordcount is not 0>
				<!--- Update Resident's Info to EFT Table --->
				<cfquery name="UpdateEFTInfo" datasource="#application.datasource#">
					update EFTAccount
					set cRoutingNumber = '#form.cRoutingNumber#' ,cAccountNumber = '#form.cAccountNumber#'
					,cAccountType = '#form.cAccountType#',iRowStartUser_id = #session.Userid# ,dtRowStart = #TimeStamp#
					where iEFTAccount_id = '#existingEFT.iEFTAccount_id#'
				</cfquery>
			<cfelse>
				<!--- Add Resident's Info to EFT table --->
				<cfquery name="InsertEFTInfo" datasource="#application.datasource#">
					insert into EFTAccount (cSolomonKey, cRoutingNumber, cAccountNumber, cAccountType, iRowStartUser_id, dtRowStart)
					values ('#Tenant.cSolomonKey#', '#form.cRoutingNumber#', '#form.cAccountNumber#', '#form.cAccountType#', #session.UserID#, #TimeStamp#)
				</cfquery>
			</cfif>
		</cfif>
	</cfif>
	
	<cfif isDefined("form.iContact_id")>
		<cfscript>
			Phone1 = form.contactareacode1 & form.contactprefix1 & form.contactnumber1;
			Phone2 = form.contactareacode2 & form.contactprefix2 & form.contactnumber2;
		</cfscript>
		
		<cfif form.iContact_id neq "">
		here1
			<cfquery name= "UpdateContact" datasource ="#APPLICATION.datasource#">
				UPDATE CONTACT
				SET	cFirstName = <cfif form.ContactFirstName neq ""> '#trim(form.ContactFirstName)#', <cfelse> null, </cfif>
					cLastName = <cfif form.ContactLastName neq "">	'#trim(form.ContactLastName)#',	<cfelse> null, </cfif>
					cPhoneNumber1 =	<cfif Phone1 neq ""> '#trim(Phone1)#', <cfelse> null, </cfif>
					iPhoneType1_id = <cfif form.ContactiPhoneType1_id neq ""> #trim(form.ContactiPhoneType1_id)#, <cfelse> null, </cfif>
					cPhoneNumber2 =	<cfif Phone2 neq ""> '#trim(Phone2)#', <cfelse> null, </cfif>
					iPhoneType2_id = <cfif form.ContactiPhoneType2_id neq ""> #trim(form.ContactiPhoneType2_id)#, <cfelse> null, </cfif>
					cAddressLine1 = <cfif form.ContactAddressLine1 neq ""> '#trim(form.ContactAddressLine1)#', <cfelse> null, </cfif> 
					cAddressLine2 = <cfif form.ContactAddressLine2 neq ""> '#trim(form.ContactAddressLine2)#', <cfelse> null, </cfif> 
					cCity = <cfif form.ContactCity neq ""> '#trim(form.ContactCity)#', <cfelse> null, </cfif>
					cStateCode = <cfif form.ContactStateCode neq ""> '#trim(form.ContactStateCode)#', <cfelse> null, </cfif> 
					cZipCode = <cfif form.ContactZipCode neq ""> '#trim(form.ContactZipCode)#', <cfelse> null, </cfif> 
					iRowStartUser_id = #session.UserID#, 
					dtRowStart =  getDate(),
					 cEmail = <cfif form.ContactEmail neq ""> '#trim(form.ContactEmail)#' <cfelse> null </cfif>  
		 
					
				where iContact_id =  #form.iContact_id#
			</cfquery>
	
			<cfquery name= "UpdateLinkInformation" datasource = "#APPLICATION.datasource#">
				update LinkTenantContact
				set <cfif form.ContactRelationshipType_id neq ""> iRelationshipType_id = #form.ContactRelationshipType_id#, </cfif>
					<cfif isDefined("form.ContactbIsPayer") and form.ContactbIsPayer neq ""> bIsPayer = '#form.ContactbIsPayer#', <cfelse> bIsPayer = null, </cfif>
					<cfif isDefined("form.ContactbIsMoveOutPayer") and form.ContactbIsMoveOutPayer neq ""> bIsMoveOutPayer = '#form.ContactbIsMoveOutPayer#', <cfelse> bIsMoveOutPayer = null, </cfif>

					<cfif isDefined("form.bIsExecutorContact") and form.bIsExecutorContact neq "">bIsExecutorContact = 1, <cfelse> bIsExecutorContact = null, </cfif>
					<cfif isDefined("form.bIsPowerOfAttorney") and form.bIsPowerOfAttorney neq "">bIsPowerOfAttorney = 1, <cfelse> bIsPowerOfAttorney = null, </cfif>
					<cfif isDefined("form.bIsMedicalProvider")and form.bIsMedicalProvider neq "">bIsMedicalProvider = 1, <cfelse> bIsMedicalProvider = null, </cfif>
					<cfif isDefined("form.oGuarentorAgreement") and form.oGuarentorAgreement eq ''>bIsGuarantorAgreement = null,
					<cfelseif isDefined("form.oGuarentorAgreement")>bIsGuarantorAgreement = #form.oGuarentorAgreement#,
					</cfif>
					 <cfif IsDefined("form.cPrimaryCarePhysicianContact") and form.cPrimaryCarePhysicianContact neq "">cPrimaryCarePhysicianContact =1
					 <cfelse>cPrimaryCarePhysicianContact = null </cfif>
					,iRowStartUser_id = #session.UserID#, 
						dtRowStart =  getDate()
					where iContact_id = #form.iContact_id#
					<!---Mshah added this as we dont want the all link tenant contact with same contact ID to update --->
				 <cfif IsDefined("form.iLinkTenantContact_ID") and form.iLinkTenantContact_ID neq "">
					 and ilinktenantcontact_ID= #form.iLinkTenantContact_ID#
				 </cfif>
			</cfquery>
				
		<cfelse>
		
			<cfif form.ContactFirstName neq "" and form.ContactLastName NEQ"">		
				<cfquery name= "Contact" datasource = "#APPLICATION.datasource#">
					insert into Contact
					( cFirstName, cLastName, cPhoneNumber1, iPhoneType1_id, cPhoneNumber2, iPhoneType2_id, 
						cAddressLine1, cAddressLine2, cCity, cStateCode, cZipCode, iRowStartUser_id, dtRowStart, cEmail	)
					values
					(	<cfif form.ContactFirstName neq "">	'#form.ContactFirstName#', <cfelse> null, </cfif> 
						<cfif form.ContactLastName neq ""> '#form.ContactLastName#', <cfelse> null, </cfif>
						<cfif Phone1 neq ""> #Phone1#, <cfelse> null, </cfif>
						<cfif form.ContactiPhoneType1_id neq ""> #form.ContactiPhoneType1_id#,	<cfelse> null, </cfif>
						<cfif Phone2 neq ""> #Phone2#, <cfelse> null, </cfif>
						<cfif form.ContactiPhoneType2_id neq ""> #form.ContactiPhoneType2_id#, <cfelse> null, </cfif> 
						<cfif form.ContactAddressLine1 neq ""> '#form.ContactAddressLine1#', <cfelse> null, </cfif> 
						<cfif form.ContactAddressLine2 neq ""> '#form.ContactAddressLine2#', <cfelse> null, </cfif> 
						<cfif form.ContactCity neq ""> '#form.ContactCity#', <cfelse> null, </cfif>
						<cfif form.ContactStateCode neq ""> '#form.ContactStateCode#', <cfelse> null, </cfif> 
						<cfif form.ContactZipCode neq ""> '#form.ContactZipCode#', <cfelse> null, </cfif> 
						#session.UserID#,
						getDate(),
						<cfif form.contactEmail neq ""> '#trim(form.contactEmail)#' <cfelse> null </cfif> 
					)
				</cfquery><!--- 75019 --->
				
				<cfquery name="getCID" datasource="#APPLICATION.datasource#">
					select iContact_id 
					from Contact WITH (NOLOCK)
					where dtRowDeleted is null
					and cFirstName='#form.ContactFirstName#' and cLastName='#form.ContactLastName#'
					and cAddressLine1 <cfif form.ContactAddressLine1 neq "">='#form.ContactAddressLine1#'<cfelse>is null</cfif>
				</cfquery>
	
				<cfquery name="LinkTenantContact" datasource="#APPLICATION.datasource#">
					insert into LinkTenantContact
					(	iTenant_id, iContact_id, iRelationshipType_id, bIsPayer,bIsMoveOutPayer, bIsExecutorContact, bIsPowerOfAttorney, 
						bIsMedicalProvider,bIsGuarantorAgreement,cPrimaryCarePhysicianContact,cComments,
						iRowStartUser_id, dtRowStart)
					values
					(	<cfif form.iTenant_id neq ""> #form.iTenant_id#, <cfelse> null, </cfif>
						<cfif form.iContact_id EQ "" and GetCID.iContact_id neq "">	#GetCID.iContact_id#, <cfelse> null, </cfif> 
						<cfif form.ContactRelationshipType_id neq ""> #form.ContactRelationshipType_id#, <cfelse>	null,	</cfif>
						<cfif isDefined("form.ContactbIsPayer")> #form.ContactbIsPayer#, <cfelse> 	null,	</cfif> 
						<cfif isDefined("form.ContactbIsMoveOutPayer")> #form.ContactbIsMoveOutPayer#, <cfelse> 	null,	</cfif> 

						<cfif isDefined("form.bIsExecutorContact")> #form.bIsExecutorContact#, <cfelse> 	null,	</cfif>
						<cfif isDefined("form.bIsPowerOfAttorney")> #form.bIsPowerOfAttorney#, <cfelse> null, </cfif>  
						<cfif isDefined("form.bIsMedicalProvider")> #form.bIsMedicalProvider#, <cfelse> null, </cfif> 
						<!---<cfif isDefined("form.bIsGuarantorAgreement")> '#form.bIsGuarantorAgreement#', <cfelse> null, </cfif>---> 						
						<cfif (ListContains(session.groupid,'240') gt 0) or (ListContains(session.groupid,'192') gt 0)>
							<cfif isDefined("form.oGuarentorAgreement") and ((form.oGuarentorAgreement eq '') OR(form.oGuarentorAgreement eq ' ') OR (form.oGuarentorAgreement eq "null"))> null,
							   <cfelseif isDefined("form.oGuarentorAgreement")> #form.oGuarentorAgreement#,
							</cfif>
						<cfelseif isDefined("form.bIsGuarantorAgreement")>
							<cfif  form.bIsGuarantorAgreement is not ''> '#form.bIsGuarantorAgreement#', <cfelse> null, </cfif>
						<cfelse>
							<cfif isDefined("form.oGuarentorAgreement") and ((form.oGuarentorAgreement eq '') OR (form.oGuarentorAgreement eq "null"))> null,
							<cfelseif isDefined("form.oGuarentorAgreement")> #form.oGuarentorAgreement#,
							</cfif>
						  <!--- <cfif isDefined("form.bIsGuarantorAgreement")> '#form.bIsGuarantorAgreement#', <cfelse> null, </cfif>--->
						</cfif>
						
						<cfif IsDefined("form.cPrimaryCarePhysicianContact") and (form.cPrimaryCarePhysicianContact neq "")>1,
							<cfelse> null, 
						</cfif>
						<cfif IsDefined("form.cComments") and form.cComments neq ""> '#form.cComments#', <cfelse> null, </cfif> 
						#session.UserID#, 
						getDate()
					)
				</cfquery>	
			</cfif>
		</cfif>
		
	</cfif>
	<!---<cfoutput>cPrimaryCarePhysicianContact : #form.oGuarentorAgreement# -  user : #session.UserID#   </cfoutput> <cfabort>--->
	
<!--- BOND: If the tenant is being edited, and the tenant becomes bond then the apt becomes bond. --->
	<cfif bondhouse.iBondHouse eq 1>
		<cfquery name="TenantBondInfoCheck" datasource="#APPLICATION.datasource#">
			select t.bIsBond as TenantBond
			,aa.bIsBond as AptBond
			,aa.bBondIncluded as AptBondIncluded
			from tenant t WITH (NOLOCK)
			inner join tenantstate ts WITH (NOLOCK) on (ts.itenant_id = t.itenant_id)
			inner join aptaddress aa WITH (NOLOCK) on (aa.iaptaddress_id = ts.iaptaddress_id) 
			where t.iTenant_ID = #form.iTenant_id#
		</cfquery>
		<cfif ((TenantBondInfoCheck.TenantBond eq 1) and (TenantBondInfoCheck.AptBondIncluded eq 1))>
			<cfquery name="UpdateBondTenantApt" datasource="#APPLICATION.datasource#">
				Update AptAddress
				Set bIsBond = 1
				,cRowEndUser_ID = '#SESSION.USERNAME#'
				Where iAptAddress_ID = #Tenant.iAptAddress_id#
			</cfquery>
		</cfif>
	</cfif>

</cftransaction>

<!---<cftransaction>
	<cfquery name="qryChkPayer"  datasource="#APPLICATION.datasource#">
		Select bIsPayer
		from LinkTenantContact
		WHere itenant_id = #form.iTenant_id# and bIsPayer = 1
	</cfquery>
	
	<cfif qryChkPayer.recordcount is 0>
		<cfquery name="updPayer" datasource="#APPLICATION.datasource#">
			Update tenant
			set bIsPayer = 1
			where itenant_id = #form.iTenant_id#
		</cfquery>
	</cfif>
</cftransaction> commented this MShah--->

<!--- Update Changes in Solomon --->
<cfif Tenant.iResidencyType_id is 2> <cfset class='Medicaid'> <cfelse> <cfset class='Private'> </cfif>
<cfif session.qSelectedHouse.iHouse_id neq 200>
	<CF_NEWTenantUpdate iHouse_id = #session.qSelectedHouse.iHouse_id# iTenant_id = #form.iTenant_id# CLASS="#CLASS#">
</cfif>

  <cflocation url="TenantEdit.CFM?ID=#form.iTenant_id#&Debug=1"> 