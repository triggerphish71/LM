<!--- *********************************************************************************************
Name:       Tenant/Inc_VerifyInput.cfm

Type:       Include

Purpose:    Verify the Tenant dataset FORM fields.  Set gFormErrorList to the name(s) of all FORM
            fields with errors, and set gFormErrorMessage to a descriptive error message.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
This dummy loop gives us the option of jumping to the end of this include via a CFBREAK.
---------------------------------------------------------------------------------------------- --->

<CFLOOP  CONDITION = "1 EQ 1">


<!--- ---------------------------------------------------------------------------------------------
Verify the Confirm Check Box was checked if the user selected a tenant name for the cSolomonKey.
---------------------------------------------------------------------------------------------- --->

    <CFIF                  FORM.Tenant_cSolomonKey  EQ  ""  AND
                IsDefined("FORM.SolomonConfirmBox")>

        <CFSET  TempMsg  =  "You do NOT need to check the 'Confirm: Use Another Tenant ID' box unless you ">
        <CFSET  TempMsg  =  TempMsg & "want to assign this New Applicant the ID of another current Tenant. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "Tenant_cSolomonKey")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

    </CFIF>


<!--- ---------------------------------------------------------------------------------------------
Verify the Confirm Check Box was checked if the user selected a tenant name for the cSolomonKey.
---------------------------------------------------------------------------------------------- --->

    <CFIF                  FORM.Tenant_cSolomonKey  NEQ  ""  AND
           NOT  IsDefined("FORM.SolomonConfirmBox")>

        <CFSET  TempMsg  =  "You must check the 'Confirm: Use Another Tenant ID' box if you want ">
        <CFSET  TempMsg  =  TempMsg & "to assign this New Applicant the ID of another current Tenant. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "Tenant_cSolomonKey")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

    </CFIF>


<!--- ---------------------------------------------------------------------------------------------
Tenant_cFirstName is a required field.
---------------------------------------------------------------------------------------------- --->

    <CFIF  FORM.Tenant_cFirstName  EQ  "">

        <CFSET  TempMsg  =  "Tenant First Name is a required field. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "Tenant_cFirstName")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

    </CFIF>


<!--- ---------------------------------------------------------------------------------------------
Tenant.cLastName is a required field.
---------------------------------------------------------------------------------------------- --->

    <CFIF  FORM.Tenant_cLastName  EQ  "">

        <CFSET  TempMsg  =  "Tenant Last Name is a required field. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "Tenant_cLastName")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

    </CFIF>

<CFBREAK> </CFLOOP>

