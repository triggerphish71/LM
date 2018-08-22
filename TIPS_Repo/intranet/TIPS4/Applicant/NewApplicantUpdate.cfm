

<CFSCRIPT>
	//Concat. First, Middle, Last for Social Security Number
	cSSN = form.First & "-" & form.middle & "-" & form.last;
	
	//Concat. Month Day Year for dBirthDate
	dBirthDate = form.month & "/" & form.day & "/" & form.year;
	
	<!--- =============================================================================================
	Concat. Phone Number from areacode prefix and number
	============================================================================================= --->
	Phone1 = form.areacode1 & form.prefix1 & form.number1;
	Phone2 = form.areacode2 & form.prefix2 & form.number2;
	Phone3 = form.areacode3 & form.prefix3 & form.number3;
</CFSCRIPT>

<CFTRANSACTION>
	
	<CFQUERY NAME = "UpdateApplicant"	DATASOURCE = "#APPLICATION.datasource#">
		Update TENANT
		SET	(
			<CFIF form.iResidencyType_ID NEQ ""> iResidencyType_ID = #TRIM(form.iResidencyType_ID)#, <CFELSE> iResidencyType_ID = NULL,	</CFIF>
			bIsPayer = 1,
			<CFIF form.cFirstName NEQ ""> cFirstName = '#TRIM(form.cFirstName)#', <CFELSE> cFirstName = NULL, </CFIF>
			<CFIF form.cLastName NEQ ""> cLastName = '#TRIM(form.cLastName)#', <CFELSE>	cLastName = NULL, </CFIF>
			<CFIF dBirthDate NEQ "//"> dBirthDate = '#Variables.dBirthDate#', <CFELSE> dBirthDate = NULL, </CFIF>
			<!--- ==============================================================================
			As Per Report Writers Request (Cray) If the SSN is Blank we will use "" empty rather than NULL
			=============================================================================== --->
			<CFIF cSSN NEQ ""> cSSN = '#Variables.cSSN#', <CFELSE> cSSN = '', </CFIF>
			<CFIF form.cOutsideAddressLine1 NEQ "">	cOutsidePhoneNumber1 = #Variables.Phone1#, <CFELSE>	cOutsidePhoneNumber1 = NULL, </CFIF>	
			iOutsidePhoneType1_ID = #form.iOutSidePhoneType1_ID#,
			<CFIF form.cOutsideAddressLine1 NEQ ""> cOutsidePhoneNumber2 = #Variables.Phone2#, <CFELSE>	cOutsidePhoneNumber2 = NULL, </CFIF>
			iOutsidePhoneType2_ID  = #form.iOutSidePhoneType2_ID#,	
			<CFIF form.cOutsideAddressLine1 NEQ ""> cOutsidePhoneNumber3 = #Variables.Phone3#, <CFELSE>	cOutsidePhoneNumber3 = NULL, </CFIF>
			iOutsidePhoneType3_ID = #form.iOutSidePhoneType3_ID#,	
			<CFIF form.cOutsideAddressLine1 NEQ "">	cOutsideAddressLine1 = '#form.cOutsideAddressLine1#', <CFELSE> cOutsideAddressLine1 = NULL,	</CFIF>
			<CFIF form.cOutsideAddressLine2 NEQ "">	cOutsideAddressLine2 = '#form.cOutsideAddressLine2#', <CFELSE> cOutsideAddressLine2 = NULL, </CFIF>
			<CFIF form.cOutsideCity NEQ "">	cOutsideCity = '#form.cOutsideCity#', <CFELSE> 	cOutsideCity = NULL, </CFIF>
			<CFIF form.cOUtsideStateCode NEQ ""> cOutsideStateCode = '#form.cOutsideStateCode#', <CFELSE> cOutsideStateCode = NULL,	</CFIF>
			<CFIF form.cOutsideZipCode NEQ ""> cOutsideZipCode = '#form.cOutsideZipCode#', <CFELSE> cOutsideZipCode = NULL, </CFIF>
			<CFIF form.cComments NEQ ""> cComments = '#form.cComments#', <CFELSE> cComments = NULL,	</CFIF>
			cBillingType = '#TRIM(SESSION.cBillingType)#',
			iRowStartUser_ID = #SESSION.UserID#,
			dtRowStart = GETDATE(),
			<CFIF form.cEmail NEQ "">	cEmail = '#form.cEmail#' <CFELSE> cEmail = NULL </CFIF>
			)
	</CFQUERY>

</CFTRANSACTION>

<CFLOCATION URL="../Registration/Registration.cfm" ADDTOKEN="No">
