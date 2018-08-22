




<!--- =============================================================================================
Intranet Header
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../Header.cfm">



<!--- =============================================================================================
Check for duplicate region entry
============================================================================================= --->
<CFQUERY NAME = "DuplicateCheck" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM	REGION
	WHERE	cName 	like	'%#form.cName#%'
	
	<CFIF form.cNumber NEQ "">
		OR		cNumber = 		#form.cNumber#
	</CFIF>
	
</CFQUERY>


<!--- =============================================================================================
Conditional to skip insert if the region or LIKE Region exists
============================================================================================= --->
<CFIF DuplicateCheck.RecordCount IS 0>



<!--- =============================================================================================
Concat. Phone Number from areacode prefix and number
============================================================================================= --->
<CFSET Phone1 = #form.areacode1# & #form.prefix1# & #form.number1#>
<CFSET Phone2 = #form.areacode2# & #form.prefix2# & #form.number2#>
<CFSET Phone3 = #form.areacode3# & #form.prefix3# & #form.number3#>



	 <CFQUERY NAME = "RegionInsert" DATASOURCE = "#APPLICATION.Datasource#">
		 	INSERT INTO 	Region
				(
				<CFIF form.cName NEQ "">
					cName,
				</CFIF>
				
			
				<CFIF form.cNumber NEQ "">
					cNumber,
				</CFIF>
				
				
				<CFIF form.cAddressLine1 NEQ "">
					cAddressLine1,
				</CFIF>
				
				
					
				<CFIF form.cAddressLine2 NEQ "">
					cAddressLine2,
				</CFIF>
				
				
					
				<CFIF form.cCity NEQ "">
					cCity,
				</CFIF>
					
					
					
				<CFIF form.cStateCode NEQ "">
					cStateCode,
				</CFIF>
				
				
				
					
				<CFIF form.cZipCode NEQ "">
					cZipCode,
				</CFIF>
				
				
				
					
				<CFIF Variables.Phone1 NEQ "">
					cPhoneNumber1,
				</CFIF>
					
				<CFIF form.iPhoneType1_ID NEQ "">
					iPhoneType1_ID,
				</CFIF>	
					
				<CFIF Variables.Phone2 NEQ "">
					cPhoneNumber2,
				</CFIF>	
					
				<CFIF form.iPhoneType2_ID NEQ "">
					iPhoneType2_ID,
				</CFIF>
				
					
				<CFIF Variables.Phone3 NEQ "">
					cPhoneNumber3,
				</CFIF>
					
					
					
				<CFIF form.iPhoneType3_ID NEQ "">
					iPhoneType3_ID,
				</CFIF>
				
				
				<CFIF form.cComments NEQ "">
					cComments,
				</CFIF>
				
					iRowStartUser_ID,
					dtRowStart,
					iVPUser_ID
				)
				Values
				(
					
					<CFIF form.cName NEQ "">
						'#form.cNAME#',
					</CFIF>
					
					<CFIF form.cNumber NEQ "">
						#form.CNUMBER#,
					</CFIF>	
					
					
					<CFIF form.cAddressLine1 NEQ "">
						'#form.CADDRESSLINE1#',
					</CFIF>
					
					
					<CFIF form.cAddressLine2 NEQ "">
						'#form.CADDRESSLINE2#',
					</CFIF>
					
					
					<CFIF form.CCITY NEQ "">
						'#form.CCITY#',
					</CFIF>
					
					
					<CFIF form.cStateCode NEQ "">
						'#form.CSTATECODE#',
					</CFIF>
					
					
					<CFIF form.cZipCode NEQ "">
						#form.CZIPCODE#,
					</CFIF>
					
					
					<CFIF Variables.Phone1 NEQ "">
						#Variables.Phone1#,
					</CFIF>
					
					
					<CFIF form.IPHONETYPE1_ID NEQ "">
						#form.IPHONETYPE1_ID#,
					</CFIF>
					
					
					<CFIF Variables.Phone2 NEQ "">
						#Variables.Phone2#,
					</CFIF>
					
					
					
					<CFIF form.IPHONETYPE2_ID NEQ "">
						#form.IPHONETYPE2_ID#,
					</CFIF>
				
				
				
					<CFIF Variables.Phone3 NEQ "">
						#Variables.Phone3#,
					</CFIF>	
						
				
				
					<CFIF form.IPHONETYPE3_ID NEQ "">
						#form.IPHONETYPE3_ID#,
					</CFIF>	
						
				
				
					<CFIF form.cCOMMENTS NEQ "">
						'#form.cCOMMENTS#',
					</CFIF>	
					
						#session.userid#,
						GetDate(),
						#Session.UserID#
				)
	</CFQUERY>

<CFLOCATION URL = "Region.cfm">
	
<CFELSE>

	<CFOUTPUT>
		<H2 Class = "PageTitle">
			THIS REGION ALREADY EXISTS!
		</H2>
		
		<A HREF = "Region.cfm" STYLE = "Font-size: 18;">	Click Here to Exit This Page.</A>
		
	</CFOUTPUT>

	
</CFIF>

<!--- =============================================================================================
Intranet Footer
============================================================================================= --->
<CFINCLUDE TEMPLATE = "../../../Footer.cfm">
