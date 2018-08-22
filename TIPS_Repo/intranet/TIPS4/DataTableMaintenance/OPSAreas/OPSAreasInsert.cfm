







<!--- =============================================================================================
Concat. Phone Number from areacode prefix and number
============================================================================================= --->
<CFSET Phone1 = #form.areacode1# & #form.prefix1# & #form.number1#>
<CFSET Phone2 = #form.areacode2# & #form.prefix2# & #form.number2#>
<CFSET Phone3 = #form.areacode3# & #form.prefix3# & #form.number3#>



<CFTRANSACTION>
<!--- ==============================================================================
Insert into OPS Area Table
=============================================================================== --->
<CFQUERY NAME = "NewOPSArea" DATASOURCE = "#APPLICATION.datasource#">
	INSERT INTO 	OpsArea
					(
					iRegion_ID, 
					iDirectorUser_ID, 
					cName, 
					cNumber, 
					cPhoneNumber1, 
					iPhoneType1_ID, 
					cPhoneNumber2, 
					iPhoneType2_ID, 
					cPhoneNumber3, 
					iPhoneType3_ID, 
					cAddressLine1, 
					cAddressLine2, 
					cCity, cStateCode, 
					cZipCode, 
					cComments, 
					iRowStartUser_ID, 
					dtRowStart
					)
					
					VALUES
					
					(
					
					#TRIM(form.iRegion_ID)#,
					
					#TRIM(iDirectorUser_ID)#,
					
					<CFIF form.cName NEQ "">		'#TRIM(form.cName)#',			<CFELSE>	NULL,	</CFIF> 
					
					#TRIM(form.cNumber)#,
					
					#TRIM(Variables.Phone1)#,
					
					#TRIM(form.iPhoneType1_ID)#,
					
					#TRIM(Variables.Phone2)#,
					
					#TRIM(form.iPhoneType2_ID)#,
					
					#TRIM(Variables.Phone3)#,
					
					#TRIM(iPhoneType3_ID)#,
					
					<CFIF form.cAddressLine1 NEQ "">'#TRIM(Form.cAddressLine1)#',	<CFELSE>	NULL,	</CFIF>
					
					<CFIF form.cAddressLine2 NEQ "">'#TRIM(Form.cAddressLine2)#',	<CFELSE>	NULL,	</CFIF>
					
					<CFIF form.cCity NEQ "">		'#TRIM(Form.cCity)#',			<CFELSE>	NULL,	</CFIF>

					<CFIF form.cStateCode NEQ "">	'#TRIM(Form.cStateCode)#',		<CFELSE>	NULL,	</CFIF>
					
					<CFIF form.cZipCode NEQ "">		#TRIM(form.cZipCode)#,			<CFELSE>	NULL,	</CFIF>
				
					<CFIF form.cComments NEQ"">		'#TRIM(form.cComments)#',		<CFELSE>	NULL,	</CFIF>
					
					#SESSION.UserID#,
					GETDATE()
					)

</CFQUERY>

</CFTRANSACTION>


<CFLOCATION URL="OPSAreas.cfm" ADDTOKEN="No">