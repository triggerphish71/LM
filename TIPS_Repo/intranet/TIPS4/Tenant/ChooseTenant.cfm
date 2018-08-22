
<CFINCLUDE TEMPLATE="../../header.cfm">


<!--- =============================================================================================
Only Index.cfm can create URL.SelectedHouse_ID.  If it exists set SESSION variables.
============================================================================================== --->

<CFIF  IsDefined("URL.SelectedHouse_ID")>

    <CFINCLUDE  TEMPLATE = "../House/Inc_SQLselectOne.cfm">

    <CFSET  SESSION.qSelectedHouse  =  qHouse>

	<CFSET	SESSION.HouseName		= #qhouse.cName#>
	
	
<!--- ---------------------------------------------------------------------------------------------
We did NOT arrive via Index.cfm.  Verify SESSION variables still exist.
---------------------------------------------------------------------------------------------- --->

<CFELSEIF  NOT  IsDefined("SESSION.qSelectedHouse")>

    <CFSET  UrlStatusMessage  =  URLEncodedFormat("Your Intranet session has expired. Please select a house.")>

    <CFLOCATION  URL = "Index.cfm?UrlStatusMessage=#UrlStatusMessage#"  ADDTOKEN = "NO">

</CFIF>



<!--- *********************************************************************************************
Goal:	Successfully populate the tenant table with the correct data
********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
Get House iHouse_ID from HOUSE table to obtain cNumber (house number) from new system.
This will allow us to associated the last TIPS houses with the new TIPS iHouse_ID
--------------------------------------------------------------------------------------------- --->
<CFQUERY NAME = "HOUSE" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM 	HOUSE
	WHERE	ihouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
</CFQUERY>

<CFQUERY NAME = "Tenants"	DATASOURCE = "CENSUS">
	SELECT 	*
	FROM	tenants t 
	INNER JOIN billingaddress b	ON t.ctenantid = b.ctenantid
	WHERE	t.nhouse = #House.cNumber#
			AND nUnitNumber < 997
	ORDER BY t.nUnitNumber
</CFQUERY>


<FORM ACTION="test.cfm" METHOD="post" NAME="tenant">

<TABLE BORDER="1">
	<CFOUTPUT>
	<TR>	<TH COLSPAN = "22">	#House.cName#	</TH>	</TR>
	</CFOUTPUT>
	<TR>
		<TD>	RUN				</TD>
		<TD>	Apt				</TD>	
		<TD>	cFirstName		</TD>	
		<TD>	cLastName		</TD> 	
		<TD>	cSolomonKey		</TD>	
		<TD>	dBirthDate		</TD>
		<TD>	cSSN			</TD>
		<TD>	Mediciad#		</TD>
		<TD>	Payer			</TD>
		<TD>	Phone1			</TD>
		<TD>	Type1			</TD>
		<TD>	Phone2			</TD>
		<TD>	Type2			</TD>
		<TD>	Phone3			</TD>
		<TD>	Type3			</TD>
		<TD>	AddressLine1	</TD>
		<TD>	AddressLine2	</TD>
		<TD>	City			</TD>
		<TD>	State			</TD>
		<TD>	Zip				</TD>
		<TD>	Comments		</TD>
		<TD>	RowStartUser_ID	</TD>
		<TD>	dtRowStart		</TD>
	</TR>
<CFOUTPUT QUERY = "Tenants">		
	<TR>
		<TD>	#Tenants.nUnitNumber#	</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cFirstName" 		VALUE = "#Tenants.fName#" 		SIZE = "10">	</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cLastName" 		VALUE = "#Tenants.lName#" 		SIZE = "10">	</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cSolomonKey" 		VALUE = "#Tenants.cTenantID#" 	SIZE = "10">	</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "dBirthDate" 		VALUE = "#Tenants.cBirthdate#"	SIZE = "9">		</TD>
		<TD>	<INPUT TYPE = "text" NAME = "cSSN" 				VALUE = "#Tenants.cSSN#" 		SIZE="12">		</TD>
		<TD>	<INPUT TYPE = "TEXT" Name = "cMedicaidNumber" 	VALUE = "" SIZE = "8">							</TD>	
	
		<TD>	
			<CFIF Tenants.guarantor EQ 'Yes'>
				<INPUT TYPE = "Checkbox" Name = "bIsPayer" VALUE = "1" Checked>
			<CFELSE>
				<INPUT TYPE = "Checkbox" Name = "bIsPayer" VALUE = "0">
			</CFIF>
		</TD>	
				
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSidePhoneNumber1" 	VALUE = "#Tenants.Dphone#">				</TD>
		<TD>	<INPUT TYPE = "TEXT" Name = "iOutsidePhoneType1_ID" VALUE = "" SIZE ="2">					</TD>
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSidePhoneNumber2" 	VALUE = "">								</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "iOutsidePhoneType2_ID" VALUE = "" SIZE ="2">					</TD>
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSidePhoneNumber3" 	VALUE = "">								</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "iOutsidePhoneType3_ID" VALUE = "" SIZE ="2">					</TD>

		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSideAddressLine1" 	VALUE = "#Tenants.Address#">			</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSideAddressLine2" 	VALUE = "" SIZE ="10">					</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSideCity" 			VALUE = "#Tenants.City#">				</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutSideStateCode" 	VALUE = "#Tenants.State#" SIZE = "2">	</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cOutsideZipCode" 		VALUE = "#Tenants.Zip#"	SIZE = "7">		</TD>	
		<TD>	<INPUT TYPE = "TEXT" Name = "cComments" 			VALUE = "">								</TD>	

		<TD>	#Session.UserID#					</TD>
		<TD>	#DateFormat(Now(),"mm/dd/yyyy")#	</TD>	
	</TR>
</CFOUTPUT>


</TABLE>
</FORM>
