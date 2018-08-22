<!--- *********************************************************************************************
Name:       Tenant/Inc_SQLtrimSpaces.cfm

Type:       Include

Purpose:    Trim spaces from Tenant dataset character fields.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
Remove extraneous spaces from character fields the user can input.
---------------------------------------------------------------------------------------------- --->

<CFSET  FORM.Tenant_cFirstName            =  Trim(FORM.Tenant_cFirstName)>
<CFSET  FORM.Tenant_cLastName             =  Trim(FORM.Tenant_cLastName)>
<CFSET  FORM.Tenant_cSSN                  =  Trim(FORM.Tenant_cSSN)>
<CFSET  FORM.Tenant_cMedicaidNumber       =  Trim(FORM.Tenant_cMedicaidNumber)>
<CFSET  FORM.Tenant_cOutsidePhoneNumber1  =  Trim(FORM.Tenant_cOutsidePhoneNumber1)>
<CFSET  FORM.Tenant_cOutsidePhoneNumber2  =  Trim(FORM.Tenant_cOutsidePhoneNumber2)>
<CFSET  FORM.Tenant_cOutsidePhoneNumber3  =  Trim(FORM.Tenant_cOutsidePhoneNumber3)>
<CFSET  FORM.Tenant_cOutsideAddressLine1  =  Trim(FORM.Tenant_cOutsideAddressLine1)>
<CFSET  FORM.Tenant_cOutsideAddressLine2  =  Trim(FORM.Tenant_cOutsideAddressLine2)>
<CFSET  FORM.Tenant_cOutsideCity          =  Trim(FORM.Tenant_cOutsideCity)>
<CFSET  FORM.Tenant_cOutsideStateCode     =  Trim(FORM.Tenant_cOutsideStateCode)>
<CFSET  FORM.Tenant_cOutsideZipCode       =  Trim(FORM.Tenant_cOutsideZipCode)>
<CFSET  FORM.Tenant_cComments             =  Trim(FORM.Tenant_cComments)>
