

<!--- =============================================================================================
Concat. Phone Number from areacode prefix and number
============================================================================================= --->
<CFSET Phone1 = #form.areacode1# & #form.prefix1# & #form.number1#>
<CFSET Phone2 = #form.areacode2# & #form.prefix2# & #form.number2#>
<CFSET Phone3 = #form.areacode3# & #form.prefix3# & #form.number3#>


<CFTRANSACTION>

	<CFQUERY NAME = "OPSUpdate" DATASOURCE = "#APPLICATION.datasource#">
		UPDATE OpsArea
		SET 	iRegion_ID		= #TRIM(form.iRegion_ID)#,
				
				iDirectorUser_ID	= #TRIM(form.iDirectorUser_ID)#,
				
				<CFIF form.cName NEQ "">
					cName			= '#TRIM(form.cName)#',
				<CFELSE>
					cName			= NULL,
				</CFIF>
				
				cNumber			= #TRIM(form.cNumber)#,
				
				<CFIF Variables.Phone1 NEQ "">
					cPhoneNumber1	= #TRIM(Variables.Phone1)#,
				<CFELSE>
					cPhoneNumber1 = NULL,
				</CFIF>
				
				iPhoneType1_ID	= #TRIM(form.iPhoneType1_ID)#,
				
				
				
				<CFIF Variables.Phone1 NEQ "">
					cPhoneNumber2	= #TRIM(Variables.Phone2)#,
				<CFELSE>
					cPhoneNumber2 = NULL,
				</CFIF>
				
				
				iPhoneType2_ID	= #TRIM(form.iPhoneType2_ID)#,
				
				
				<CFIF Variables.Phone1 NEQ "">
					cPhoneNumber3	= #TRIM(Variables.Phone3)#,
				<CFELSE>
					cPhoneNumber3 = NULL,
				</CFIF>				
				
				
				iPhoneType3_ID	= #TRIM(form.iPhoneType3_ID)#, 
				
				
				
				<CFIF form.cAddressLine1 NEQ "">
					cAddressLine1	= '#TRIM(form.cAddressLine1)#',
				<CFELSE>
					cAddressLine1	= NULL,
				</CFIF>
				
				
				
				
				<CFIF form.cAddressLine1 NEQ "">
					cAddressLine2	= '#TRIM(form.cAddressLine2)#',
				<CFELSE>
					cAddressLine2	= NULL,
				</CFIF>	
					
					
				
				<CFIF form.cCity NEQ "">
					cCity			= '#TRIM(form.cCity)#',
				<CFELSE>
					cCity			= NULL,
				</CFIF>
				
				
				
				<CFIF form.cStateCode NEQ "">
					cStateCode		= '#TRIM(form.cStateCode)#',
				<CFELSE>
					cStateCode		= NULL,
				</CFIF>
				
				
				<CFIF form.cZipCode NEQ "">		
					cZipCode		= #TRIM(form.cZipCode)#,
				<CFELSE>
					cZipCode		= NULL,	
				</CFIF>
				
				
				<CFIF form.cComments NEQ "">
					cComments			= '#TRIM(form.cComments)#',
				<CFELSE>
					cComments			= NULL,
				</CFIF>
				
				iRowStartUser_ID	= #SESSION.UserID#,
				
				dtRowStart			= GetDate()
			
		WHERE 	iOPSArea_ID = #form.iOpsArea_ID#
		
	</CFQUERY>

</CFTRANSACTION>

<CFLOCATION URL="OPSAreas.cfm" ADDTOKEN="No">