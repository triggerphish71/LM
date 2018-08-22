

<!--- =============================================================================================
Concat. Phone Number from areacode prefix and number
============================================================================================= --->
<CFSET Phone1 = #form.areacode1# & #form.prefix1# & #form.number1#>
<CFSET Phone2 = #form.areacode2# & #form.prefix2# & #form.number2#>
<CFSET Phone3 = #form.areacode3# & #form.prefix3# & #form.number3#>



 <CFQUERY NAME = "RegionUpdate" DATASOURCE = "#APPLICATION.Datasource#">
	 	UPDATE 	Region
		SET		
			<CFIF form.cName NEQ "">
				cName 				=	'#TRIM(form.cNAME)#',
			<CFELSE>
				cName				= 	null,
			</CFIF>
			
			
			
			
			<CFIF form.cNumber NEQ "">
				cNumber				=	'#TRIM(form.CNUMBER)#',
			<CFELSE>	
				cNumber				=	NULL,
			</CFIF>
			
			
			<CFIF form.iVPUser_id NEQ "">
				iVPUser_ID		=	#TRIM(form.iVPUser_ID)#,
			<CFELSE>
				iVPUser_ID		=		NULL,
			</CFIF>
			
			
			
			<CFIF form.cAddressLine1 NEQ "">
				cAddressLine1		=	'#TRIM(form.CADDRESSLINE1)#',
			<CFELSE>	
				cAddressLine1		=	null,
			</CFIF>
			
			
				
			<CFIF form.cAddressLine2 NEQ "">
				cAddressLine2		=	'#TRIM(form.CADDRESSLINE2)#',
			<CFELSE>	
				cAddressLine2		=	NULL,
			</CFIF>
			
			
				
			<CFIF form.cCity NEQ "">
				cCity				= 	'#TRIM(form.CCITY)#',
			<CFELSE>	
				cCity				= 	NULL,
			</CFIF>
				
				
				
			<CFIF form.cStateCode NEQ "">
				cStateCode			=	'#TRIM(form.CSTATECODE)#',
			<CFELSE>	
				cStateCode			=	NULL,
			</CFIF>
			
			
			
				
			<CFIF form.cZipCode NEQ "">
				cZipCode			=	#TRIM(form.CZIPCODE)#,
			<CFELSE>
				cZipCode			=	NULL,
			</CFIF>
			
			
			
				
			<CFIF Variables.Phone1 NEQ "">
				cPhoneNumber1		=	#TRIM(variables.phone1)#,
			<CFELSE>
				cPhoneNumber1		=	null,
			</CFIF>
				
			<CFIF form.iPhoneType1_ID NEQ "">
				iPhoneType1_ID		=	#TRIM(form.IPHONETYPE1_ID)#,
			<CFELSE>
				iPhoneType1_ID		=	null,
			</CFIF>	
				
			<CFIF Variables.Phone2 NEQ "">
				cPhoneNumber2		=	#TRIM(variables.phone2)#,
			<CFELSE>
				cPhoneNumber2		=	null,
			</CFIF>	
				
			<CFIF form.iPhoneType2_ID NEQ "">
				iPhoneType2_ID		=	#TRIM(form.IPHONETYPE2_ID)#,
			<CFELSE>
				iPhoneType2_ID		=	null,
			</CFIF>
			
				
			<CFIF Variables.Phone3 NEQ "">
				cPhoneNumber3		=	#TRIM(variables.phone3)#,
			<CFELSE>
				cPhoneNumber3		= 	null,
			</CFIF>
				
				
				
			<CFIF form.iPhoneType3_ID NEQ "">
				iPhoneType3_ID		=	#TRIM(form.IPHONETYPE3_ID)#,
			<CFELSE>
				iPhoneType3_ID		=	null,
			</CFIF>
			
			
			<CFIF form.cComments NEQ "">
				cComments			=	'#TRIM(form.cCOMMENTS)#',
			<CFELSE>
				cComments			=	null,
			</CFIF>
			
				iRowStartUser_ID	=	#session.userid#,
				dtRowStart			= 	GetDate()
		WHERE	iRegion_ID 			=	#form.iRegion_ID#
</CFQUERY>


<!--- *****************************************************************************
<!--- =============================================================================================
Write Transaction Record to the History Table
============================================================================================= --->
<CFQUERY NAME = "RegionHistory" DATASOURCE = "#APPLICATION.datasource#">
	UPDATE 	P_REGION
		SET iRowEndUser_ID = #Session.UserID#
	WHERE iRegion_ID = #form.iRegion_ID#
	AND dtRowEnd = (Select Max(dtRowEnd)as MaxEnd from P_REGION WHERE iRegion_ID = #form.iRegion_ID# AND cName = '#form.cName#')
</CFQUERY>
****************************************************************************** --->


<CFLOCATION URL = "Region.cfm">
