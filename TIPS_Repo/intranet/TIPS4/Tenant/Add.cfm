<!--- *********************************************************************************************
Name:       Tenant/Add.cfm

Type:       Template

Purpose:    Create a new Tenant.


Called by: MainMenu.cfm

    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None


Calls: Itself

    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    FORM.[Tenant dataset fields]        All of the user modifiable Tenant dataset fields created by
                                        the include Inc_DisplayFormFields.cfm.

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<CFINCLUDE  TEMPLATE = "../Shared/Inc_FormErrMsgInit.cfm">


<!--- *********************************************************************************************
Verify and insert the new row if this template is calling itself.
********************************************************************************************** --->

<CFIF  IsDefined("FORM.Tenant_cLastName")>

    <CFINCLUDE  TEMPLATE = "#gTipsRootPath#/StatusLog/Inc_VerifyInput.cfm">
    <CFINCLUDE  TEMPLATE = "#gTipsRootPath#/UnitLog/Inc_VerifyInput.cfm">
    <CFINCLUDE  TEMPLATE = "#gTipsRootPath#/SPointsLog/Inc_VerifyInput.cfm">
    <CFINCLUDE  TEMPLATE = "Inc_VerifyInput.cfm">

    <CFIF  Len(gFormErrorList)  EQ  0>

<!---

        <CFTRANSACTION>

            <CFINCLUDE  TEMPLATE = "Inc_SQLinsert.cfm">


<!--- ---------------------------------------------------------------------------------------------
Get the Tenant_ID of the person we just inserted into the Tenant dataset.
---------------------------------------------------------------------------------------------- --->

            <CFQUERY  NAME = "qLastTenant_ID"  DATASOURCE = "#APPLICATION.DataSource#">
                SELECT  MAX(aTenant_ID)  AS  NewTenant_ID
                FROM    Tenant
            </CFQUERY>


<!--- ---------------------------------------------------------------------------------------------
Create the associated StatusLog record.
---------------------------------------------------------------------------------------------- --->

            <CFINCLUDE  TEMPLATE = "#gTipsRootPath#/StatusLog/Inc_SQLinsert.cfm">


<!--- ---------------------------------------------------------------------------------------------
Only create the associated SPointsLog record if a service points amount was input.
---------------------------------------------------------------------------------------------- --->

            <CFIF  FORM.SPointsLog_iSPoints  GT  0>

                <CFINCLUDE  TEMPLATE = "#gTipsRootPath#/SPointsLog/Inc_SQLinsert.cfm">

            </CFIF>


<!--- ---------------------------------------------------------------------------------------------
Only create the associated UnitLog record if a unit was selected.
---------------------------------------------------------------------------------------------- --->

            <CFIF  FORM.UnitLog_iUnitList_ID  GT  0>

                <CFINCLUDE  TEMPLATE = "#gTipsRootPath#/UnitLog/Inc_SQLinsert.cfm">

            </CFIF>

        </CFTRANSACTION>

--->


<!--- ---------------------------------------------------------------------------------------------
Set the success message and return to the Main Menu.
---------------------------------------------------------------------------------------------- --->

        <CFSET  UrlStatusMessage  =  URLEncodedFormat("New Applicant save was successful.")>

        <CFLOCATION  URL = "../MainMenu.cfm?UrlStatusMessage=#UrlStatusMessage#">

    </CFIF>

<CFELSE>


<!--- =============================================================================================
This template is NOT calling itself.  Initialize the following FORM variables to empty.
============================================================================================== --->

    <!--- ---------------------------------------------------------------------------------------------
<CFINCLUDE  TEMPLATE = "../TenantLog/Inc_InitEmpty.cfm">
--------------------------------------------------------------------------------------------- --->
    <CFINCLUDE  TEMPLATE = "Inc_InitEmpty.cfm">
    <CFINCLUDE  TEMPLATE = "../SPointsLog/Inc_InitEmpty.cfm">

</CFIF>


<!--- *********************************************************************************************
HTML head.
********************************************************************************************** --->

<HEAD>

    <LINK  REL  =  StyleSheet
           TYPE = "Text/css"  
           HREF = "../Shared/Style.css"
    >

    <TITLE> Tips 4 - New Applicant </TITLE>

</HEAD>


<!--- *********************************************************************************************
HTML body.  Set focus in the FORM depending on the existance of any fields with input errors.
********************************************************************************************** --->


<CFIF  Len(gFormErrorList)  EQ  0>

    <BODY>

<CFELSE>

    <CFOUTPUT>
    <BODY  onLoad = "document.MainForm.#ListFirst(gFormErrorList)#.focus()">
    </CFOUTPUT>

</CFIF>


<!--- =============================================================================================
Display the page title.
============================================================================================== --->

<DIV  CLASS = "PageTitle">
    Tips 4 - New Applicant
</DIV>

<HR>

<BR>


<!--- ---------------------------------------------------------------------------------------------
Display any user FORM input error message.
---------------------------------------------------------------------------------------------- --->

<CFIF  Len(gFormErrorMessage)  GT  0>

    <DIV CLASS = "FormErrorMessage">
        <CFOUTPUT>
            #gFormErrorMessage#
        </CFOUTPUT>
    </DIV>

    <BR>

</CFIF>


<!--- ---------------------------------------------------------------------------------------------
Display the user input FORM.  Upon SUBMIT this FORM calls itself.
---------------------------------------------------------------------------------------------- --->

<FORM   CLASS   =  "Center"
        NAME    =  "MainForm"
        METHOD  =  "POST"
>


<!--- ---------------------------------------------------------------------------------------------
Display the save and cancel buttons.
---------------------------------------------------------------------------------------------- --->

    <TABLE  BORDER = 0  CELLSPACING = 0  CELLPADDING = 20>

        <TR>
            <TD>
                <INPUT  CLASS   =  "DontSaveButton"
                        TYPE    =  "BUTTON"
                        VALUE   =  "Don't Save"
                        onClick =  "location = '../MainMenu.cfm'"
                >
            </TD>

            <TD>
                <INPUT  CLASS   =  "SaveButton"
                        TYPE    =  "BUTTON"
                        VALUE   =  "  Save  "
                        onClick =  "this.form.submit()"
                >
            </TD>
        </TR>

    </TABLE>


<!--- ---------------------------------------------------------------------------------------------
Display the FORM fields.
---------------------------------------------------------------------------------------------- --->

    <CFINCLUDE  TEMPLATE = "Inc_DisplayFormFields.cfm">

<BR> <BR>


<!--- ---------------------------------------------------------------------------------------------
Display the save and cancel buttons.
---------------------------------------------------------------------------------------------- --->

    <TABLE  BORDER = 0  CELLSPACING = 0  CELLPADDING = 20>

        <TR>
            <TD>
                <INPUT  CLASS   =  "DontSaveButton"
                        TYPE    =  "BUTTON"
                        VALUE   =  "Don't Save"
                        onClick =  "location = '../MainMenu.cfm'"
                >
            </TD>

            <TD>
                <INPUT  CLASS   =  "SaveButton"
                        TYPE    =  "BUTTON"
                        VALUE   =  "  Save  "
                        onClick =  "this.form.submit()"
                >
            </TD>
        </TR>

    </TABLE>

</FORM>

</BODY> </HTML>

