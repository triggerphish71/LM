<!--- *********************************************************************************************
Name:       Tenant/Inc_InitEmpty.cfm

Type:       Include

Purpose:    Initialize as empty the Tenant dataset FORM fields.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
Set the FORM fields to their default values.
---------------------------------------------------------------------------------------------- --->

<CFSET  FORM.Tenant_aTenant_ID             =  "">
<CFSET  FORM.Tenant_iHouse_ID              =  SESSION.qSelectedHouse.aHouse_ID>
<CFSET  FORM.Tenant_cSolomonKey            =  "">
<CFSET  FORM.Tenant_cFirstName             =  "">
<CFSET  FORM.Tenant_cLastName              =  "">
<CFSET  FORM.Tenant_dBirthDate             =  "">
<CFSET  FORM.Tenant_cSSN                   =  "">
<CFSET  FORM.Tenant_cMedicaidNumber        =  "">
<CFSET  FORM.Tenant_bIsPayer               =  "">
<CFSET  FORM.Tenant_cOutsidePhoneNumber1   =  "">
<CFSET  FORM.Tenant_iOutsidePhoneType1_ID  =  "">
<CFSET  FORM.Tenant_cOutsidePhoneNumber2   =  "">
<CFSET  FORM.Tenant_iOutsidePhoneType2_ID  =  "">
<CFSET  FORM.Tenant_cOutsidePhoneNumber3   =  "">
<CFSET  FORM.Tenant_iOutsidePhoneType3_ID  =  "">
<CFSET  FORM.Tenant_cOutsideAddressLine1   =  "">
<CFSET  FORM.Tenant_cOutsideAddressLine2   =  "">
<CFSET  FORM.Tenant_cOutsideCity           =  "">
<CFSET  FORM.Tenant_cOutsideStateCode      =  SESSION.qSelectedHouse.cStateCode>
<CFSET  FORM.Tenant_cOutsideZipCode        =  "">
<CFSET  FORM.Tenant_cComments              =  "">
<CFSET  FORM.Tenant_iRowStartUser_ID       =  "">
<CFSET  FORM.Tenant_dtRowStart             =  "">
<CFSET  FORM.Tenant_iRowEndUser_ID         =  "">
<CFSET  FORM.Tenant_dtRowEnd               =  "">
<CFSET  FORM.Tenant_iRowDeletedUser_ID     =  "">
<CFSET  FORM.Tenant_dtRowDeleted           =  "">

