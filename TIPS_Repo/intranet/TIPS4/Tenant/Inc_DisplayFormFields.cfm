<!--- *********************************************************************************************
Name:       Tenant/Inc_DisplayFormFields.cfm

Type:       Include

Purpose:    Display the user modifiable Tenant, StatusLog, UnitLog, and ServiceLog dataset FORM
            fields in a table.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- =============================================================================================
These HIDDEN FORM fields are used to save values which are not displayed.
============================================================================================== --->

<CFOUTPUT>

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_aTenant_ID"
            VALUE   =  "#FORM.Tenant_aTenant_ID#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_iHouse_ID"
            VALUE   =  "#FORM.Tenant_iHouse_ID#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_iRowStartUser_ID"
            VALUE   =  "#FORM.Tenant_iRowStartUser_ID#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_dtRowStart"
            VALUE   =  "#FORM.Tenant_dtRowStart#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_iRowEndUser_ID"
            VALUE   =  "#FORM.Tenant_iRowEndUser_ID#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_dtRowEnd"
            VALUE   =  "#FORM.Tenant_dtRowEnd#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_iRowDeletedUser_ID"
            VALUE   =  "#FORM.Tenant_iRowDeletedUser_ID#"
    >

    <INPUT  TYPE    =  "HIDDEN"
            NAME    =        "Tenant_dtRowDeleted"
            VALUE   =  "#FORM.Tenant_dtRowDeleted#"
    >

</CFOUTPUT>


<!--- =============================================================================================
Change the color of a FORM field text label when the associated FORM field has the focus.
============================================================================================== --->

<SCRIPT>

    function  HasFocus (FieldLabelName) {
        FieldLabelNameProperty  =  FieldLabelName  +  ".style.color"
        FieldLabelNameChange = FieldLabelNameProperty + " = 'Green'";
        eval(FieldLabelNameChange)
    }

    function  LostFocus (FieldLabelName) {
        FieldLabelNameProperty  =  FieldLabelName  +  ".style.color"
        FieldLabelNameChange = FieldLabelNameProperty + " = 'Navy'";
        eval(FieldLabelNameChange)
    }

</SCRIPT>


<!--- =============================================================================================
Display StatusLog information in an HTML table.
============================================================================================== --->

<TABLE  WIDTH = "100%"  BORDER = 0  CELLSPACING = 0  CELLPADDING = 0>
    <CAPTION  ALIGN = "LEFT">
        Type
    </CAPTION>


<!--- ---------------------------------------------------------------------------------------------
Display the TenantLog dataset iResidencyType_ID FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT"  WIDTH = "35%">
            <CFIF  ListFindNoCase(gFormErrorList, "TenantLog_iResidencyType_ID")  EQ  0>
                <SPAN  ID = Label_TenantLog_iResidencyType_ID  CLASS = "FormLabelGood">
                    Residency &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_TenantLog_iResidencyType_ID  CLASS = "FormLabelBad">
                    Residency &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <CFQUERY  NAME         = "qResidencyType"
                      DATASOURCE   = "#APPLICATION.DataSource#"
                      CACHEDWITHIN = "#CreateTimeSpan(0, 8, 0, 0)#"
            >
                SELECT      aResidencyType_ID, cDescription
                FROM        ResidencyType
                ORDER BY    iDisplayOrder

            </CFQUERY>

            <CFIF  FORM.TenantLog_iResidencyType_ID  EQ  "">
                <CFSET  FORM.TenantLog_iResidencyType_ID =  1>
            </CFIF>

            <SELECT  NAME     =  "TenantLog_iResidencyType_ID"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_TenantLog_iResidencyType_ID')"
                     onBlur   =  "LostFocus('Label_TenantLog_iResidencyType_ID')"
            >

                <CFOUTPUT        QUERY =  "qResidencyType">
                    <CFIF                  qResidencyType.aResidencyType_ID  EQ  FORM.TenantLog_iResidencyType_ID>
                        <OPTION  VALUE = "#qResidencyType.aResidencyType_ID#"    SELECTED>
                                          #qResidencyType.cDescription#
                    <CFELSE>
                        <OPTION  VALUE = "#qResidencyType.aResidencyType_ID#">
                                          #qResidencyType.cDescription#
                    </CFIF>
                </CFOUTPUT>

            </SELECT>
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the TenantLog dataset dtStart FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "TenantLog_dtStart")  EQ  0>
                <SPAN  ID = Label_TenantLog_dtStart  CLASS = "FormLabelGood">
                    Effective Date &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_TenantLog_dtStart  CLASS = "FormLabelBad">
                    Effective Date &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "TenantLog_dtStart"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.TenantLog_dtStart#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_TenantLog_dtStart')"
                    onBlur      =  "LostFocus('Label_TenantLog_dtStart')"
            >
        </TD>

    </TR>

</TABLE>

<BR> <BR>


<!--- =============================================================================================
Display Tenant dataset personal information in an HTML table.
============================================================================================== --->

<TABLE  WIDTH = "100%"  BORDER = 0  CELLSPACING = 0  CELLPADDING = 0>
    <CAPTION  ALIGN = "LEFT">
        Personal
    </CAPTION>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cSolomonKey FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cSolomonKey")  EQ  0>
                <SPAN  ID = Label_Tenant_cSolomonKey  CLASS = "FormLabelGood">
                    Tenant ID &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cSolomonKey  CLASS = "FormLabelBad">
                    Tenant ID &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <CFQUERY  NAME = "qTenantSolomonKeys"  DATASOURCE  = "#APPLICATION.DataSource#">

                SELECT      cFirstName, cLastName, cSolomonKey
                FROM        Tenant
                WHERE       iHouse_ID  =  #SESSION.qSelectedHouse.aHouse_ID#
                ORDER BY    cLastName, cFirstName

            </CFQUERY>

            <SELECT  NAME     =  "Tenant_cSolomonKey"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_Tenant_cSolomonKey')"
                     onBlur   =  "LostFocus('Label_Tenant_cSolomonKey')"
            >

                <OPTION  VALUE = ""> Create New

                <CFOUTPUT    QUERY  =  "qTenantSolomonKeys">

                    <CFSET   Name   =   qTenantSolomonKeys.cFirstName & " " & qTenantSolomonKeys.cLastName>

                    <OPTION  VALUE  = "#qTenantSolomonKeys.cSolomonKey#"> #Name#

                </CFOUTPUT>

            </SELECT>

            <SPAN  STYLE = "font-size: xx-small;">
                &nbsp; Confirm: Use Another Tenant ID
            </SPAN>

            <INPUT      TYPE  =  "CHECKBOX"
                        NAME  =  "SolomonConfirmBox"
                        onFocus  =  "HasFocus ('Label_Tenant_cSolomonKey')"
                        onBlur   =  "LostFocus('Label_Tenant_cSolomonKey')"
            >

        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cFirstName FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT"  WIDTH = "35%">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cFirstName")  EQ  0>
                <SPAN  ID = Label_Tenant_cFirstName  CLASS = "FormLabelGood">
                    First Name &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cFirstName  CLASS = "FormLabelBad">
                    First Name &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cFirstName"
                    SIZE        =  "20"
                    MAXLENGTH   =  "20"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cFirstName#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cFirstName')"
                    onBlur      =  "LostFocus('Label_Tenant_cFirstName')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cLastName FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cLastName")  EQ  0>
                <SPAN  ID = Label_Tenant_cLastName  CLASS = "FormLabelGood">
                    Last Name &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cLastName  CLASS = "FormLabelBad">
                    Last Name &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cLastName"
                    SIZE        =  "20"
                    MAXLENGTH   =  "20"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cLastName#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cLastName')"
                    onBlur      =  "LostFocus('Label_Tenant_cLastName')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset dBirthDate FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_dBirthDate")  EQ  0>
                <SPAN  ID = Label_Tenant_dBirthDate  CLASS = "FormLabelGood">
                    Birth Date &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_dBirthDate  CLASS = "FormLabelBad">
                    Birth Date &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_dBirthDate"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_dBirthDate#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_dBirthDate')"
                    onBlur      =  "LostFocus('Label_Tenant_dBirthDate')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cSSN FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cSSN")  EQ  0>
                <SPAN  ID = Label_Tenant_cSSN  CLASS = "FormLabelGood">
                    SSN &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cSSN  CLASS = "FormLabelBad">
                    SSN &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cSSN"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cSSN#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cSSN')"
                    onBlur      =  "LostFocus('Label_Tenant_cSSN')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cMedicaidNumber FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cMedicaidNumber")  EQ  0>
                <SPAN  ID = Label_Tenant_cMedicaidNumber  CLASS = "FormLabelGood">
                    Medicaid Number &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cMedicaidNumber  CLASS = "FormLabelBad">
                    Medicaid Number &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cMedicaidNumber"
                    SIZE        =  "15"
                    MAXLENGTH   =  "15"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cMedicaidNumber#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cMedicaidNumber')"
                    onBlur      =  "LostFocus('Label_Tenant_cMedicaidNumber')"
            >
        </TD>

    </TR>

</TABLE>

<BR><BR>


<!--- =============================================================================================
Display TenantLog information in an HTML table.
============================================================================================== --->

<TABLE  WIDTH = "100%"  BORDER = 0  CELLSPACING = 0  CELLPADDING = 0>
    <CAPTION  ALIGN = "LEFT">
        Apt
    </CAPTION>


<!--- ---------------------------------------------------------------------------------------------
Display the TenantLog dataset iAptAddress_ID FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT"  WIDTH = "35%">
            <CFIF  ListFindNoCase(gFormErrorList, "TenantLog_iAptAddress_ID")  EQ  0>
                <SPAN  ID = Label_TenantLog_iAptAddress_ID  CLASS = "FormLabelGood">
                    Apt Number &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_TenantLog_iAptAddress_ID  CLASS = "FormLabelBad">
                    Apt Number &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <CFQUERY  NAME         = "qAptAddress"
                      DATASOURCE   = "#APPLICATION.DataSource#"
                      CACHEDWITHIN = "#CreateTimeSpan(0, 8, 0, 0)#"
            >
                SELECT      aAptAddress_ID, cAptAddress
                FROM        AptAddress
                WHERE       iHouse_ID  =  #SESSION.qSelectedHouse.aHouse_ID#
                ORDER BY    cAptAddress

            </CFQUERY>

            <SELECT  NAME     =  "TenantLog_iAptAddress_ID"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_TenantLog_iAptAddress_ID')"
                     onBlur   =  "LostFocus('Label_TenantLog_iAptAddress_ID')"
            >

                <OPTION  VALUE = ""> None

                <CFOUTPUT        QUERY =  "qAptAddress">
                    <CFIF                  qAptAddress.aAptAddress_ID  EQ  FORM.TenantLog_iAptAddress_ID>
                        <OPTION  VALUE = "#qAptAddress.aAptAddress_ID#"    SELECTED>
                                          #qAptAddress.cAptAddress#
                    <CFELSE>
                        <OPTION  VALUE = "#qAptAddress.aAptAddress_ID#">
                                          #qAptAddress.cAptAddress#
                    </CFIF>
                </CFOUTPUT>

            </SELECT>
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the TenantLog dataset dtStart FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "TenantLog_dtStart")  EQ  0>
                <SPAN  ID = Label_TenantLog_dtStart  CLASS = "FormLabelGood">
                    Effective Date &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_TenantLog_dtStart  CLASS = "FormLabelBad">
                    Effective Date &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "TenantLog_dtStart"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.TenantLog_dtStart#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_TenantLog_dtStart')"
                    onBlur      =  "LostFocus('Label_TenantLog_dtStart')"
            >
        </TD>

    </TR>

</TABLE>

<BR> <BR>


<!--- =============================================================================================
Display SPoints Log information in an HTML table.
============================================================================================== --->

<TABLE  WIDTH = "100%"  BORDER = 0  CELLSPACING = 0  CELLPADDING = 0>
    <CAPTION  ALIGN = "LEFT">
        Service Points
    </CAPTION>


<!--- ---------------------------------------------------------------------------------------------
Display the SPointsLog dataset iSPoints FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT"  WIDTH = "35%">
            <CFIF  ListFindNoCase(gFormErrorList, "SPointsLog_iSPoints")  EQ  0>
                <SPAN  ID = Label_SPointsLog_iSPoints  CLASS = "FormLabelGood">
                    Service Points &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_SPointsLog_iSPoints  CLASS = "FormLabelBad">
                    Service Points &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "SPointsLog_iSPoints"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.SPointsLog_iSPoints#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_SPointsLog_iSPoints')"
                    onBlur      =  "LostFocus('Label_SPointsLog_iSPoints')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the SPointsLog dataset dEvaluation FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "SPointsLog_dEvaluation")  EQ  0>
                <SPAN  ID = Label_SPointsLog_dEvaluation  CLASS = "FormLabelGood">
                    Evaluation  Date &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_SPointsLog_dEvaluation  CLASS = "FormLabelBad">
                    Evaluation  Date &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "SPointsLog_dEvaluation"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.SPointsLog_dEvaluation#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_SPointsLog_dEvaluation')"
                    onBlur      =  "LostFocus('Label_SPointsLog_dEvaluation')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the SPointsLog dataset dStart FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "SPointsLog_dStart")  EQ  0>
                <SPAN  ID = Label_SPointsLog_dStart  CLASS = "FormLabelGood">
                    Effective Date &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_SPointsLog_dStart  CLASS = "FormLabelBad">
                    Effective Date &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "SPointsLog_dStart"
                    SIZE        =  "11"
                    MAXLENGTH   =  "11"
                    VALUE       =  "<CFOUTPUT>#FORM.SPointsLog_dStart#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_SPointsLog_dStart')"
                    onBlur      =  "LostFocus('Label_SPointsLog_dStart')"
            >
        </TD>

    </TR>

</TABLE>

<BR> <BR>


<!--- =============================================================================================
Display Tenant comments in an HTML table.
============================================================================================== --->

<TABLE  WIDTH = "100%"  BORDER = 0  CELLSPACING = 0  CELLPADDING = 0>
    <CAPTION  ALIGN = "LEFT">
        Comments
    </CAPTION>

<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cComments FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT"  WIDTH = "35%">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cComments")  EQ  0>
                <SPAN  ID = Label_Tenant_cComments  CLASS = "FormLabelGood">
                    Comments &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cComments  CLASS = "FormLabelBad">
                    Comments &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <TEXTAREA   NAME     =  "Tenant_cComments"
                        onFocus  =  "HasFocus ('Label_Tenant_cComments')"
                        onBlur   =  "LostFocus('Label_Tenant_cComments')"
                        ROWS     =  "4"
                        COLS     =  "40"><CFOUTPUT>#Trim(FORM.Tenant_cComments)#</CFOUTPUT></TEXTAREA>
        </TD>

    </TR>

</TABLE>

<BR> <BR>


<!--- =============================================================================================
Display Tenant outside address information in an HTML table.
============================================================================================== --->

<TABLE  WIDTH = "100%"  BORDER = 0  CELLSPACING = 0  CELLPADDING = 0>
    <CAPTION  ALIGN = "LEFT">
        Outside Address (input only if Day Respite or Moved Out).
    </CAPTION>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsidePhoneNumber1 FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT"  WIDTH = "35%">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsidePhoneNumber1")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsidePhoneNumber1  CLASS = "FormLabelGood">
                    Phone 1 &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsidePhoneNumber1  CLASS = "FormLabelBad">
                    Phone 1 &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsidePhoneNumber1"
                    SIZE        =  "14"
                    MAXLENGTH   =  "14"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsidePhoneNumber1#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsidePhoneNumber1')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsidePhoneNumber1')"
            >

            <CFQUERY  NAME         = "qPhoneType"
                      DATASOURCE   = "#APPLICATION.DataSource#"
                      CACHEDWITHIN = "#CreateTimeSpan(0, 8, 0, 0)#"
            >
                SELECT      aPhoneType_ID, cDescription
                FROM        PhoneType
                ORDER BY    iDisplayOrder

            </CFQUERY>

            <SELECT  NAME     =  "Tenant_iOutsidePhoneType1_ID"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_Tenant_cOutsidePhoneNumber1')"
                     onBlur   =  "LostFocus('Label_Tenant_cOutsidePhoneNumber1')"
            >

                <OPTION  VALUE = "">

                <CFOUTPUT        QUERY =  "qPhoneType">
                    <CFIF                  qPhoneType.aPhoneType_ID  EQ  FORM.Tenant_iOutsidePhoneType1_ID>
                        <OPTION  VALUE = "#qPhoneType.aPhoneType_ID#"    SELECTED>
                                          #qPhoneType.cDescription#
                    <CFELSE>
                        <OPTION  VALUE = "#qPhoneType.aPhoneType_ID#">
                                          #qPhoneType.cDescription#
                    </CFIF>
                </CFOUTPUT>

            </SELECT>
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsidePhoneNumber2 FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsidePhoneNumber2")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsidePhoneNumber2  CLASS = "FormLabelGood">
                    Phone 2 &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsidePhoneNumber2  CLASS = "FormLabelBad">
                    Phone 2 &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsidePhoneNumber2"
                    SIZE        =  "14"
                    MAXLENGTH   =  "14"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsidePhoneNumber2#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsidePhoneNumber2')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsidePhoneNumber2')"
            >

            <SELECT  NAME     =  "Tenant_iOutsidePhoneType2_ID"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_Tenant_cOutsidePhoneNumber2')"
                     onBlur   =  "LostFocus('Label_Tenant_cOutsidePhoneNumber2')"
            >

                <OPTION  VALUE = "">

                <CFOUTPUT        QUERY =  "qPhoneType">
                    <CFIF                  qPhoneType.aPhoneType_ID  EQ  FORM.Tenant_iOutsidePhoneType2_ID>
                        <OPTION  VALUE = "#qPhoneType.aPhoneType_ID#"    SELECTED>
                                          #qPhoneType.cDescription#
                    <CFELSE>
                        <OPTION  VALUE = "#qPhoneType.aPhoneType_ID#">
                                          #qPhoneType.cDescription#
                    </CFIF>
                </CFOUTPUT>

            </SELECT>
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsidePhoneNumber3 FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsidePhoneNumber3")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsidePhoneNumber3  CLASS = "FormLabelGood">
                    Phone 3 &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsidePhoneNumber3  CLASS = "FormLabelBad">
                    Phone 3 &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsidePhoneNumber3"
                    SIZE        =  "14"
                    MAXLENGTH   =  "14"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsidePhoneNumber3#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsidePhoneNumber3')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsidePhoneNumber3')"
            >

            <SELECT  NAME     =  "Tenant_iOutsidePhoneType3_ID"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_Tenant_cOutsidePhoneNumber3')"
                     onBlur   =  "LostFocus('Label_Tenant_cOutsidePhoneNumber3')"
            >

                <OPTION  VALUE = "">

                <CFOUTPUT        QUERY =  "qPhoneType">
                    <CFIF                  qPhoneType.aPhoneType_ID  EQ  FORM.Tenant_iOutsidePhoneType3_ID>
                        <OPTION  VALUE = "#qPhoneType.aPhoneType_ID#"    SELECTED>
                                          #qPhoneType.cDescription#
                    <CFELSE>
                        <OPTION  VALUE = "#qPhoneType.aPhoneType_ID#">
                                          #qPhoneType.cDescription#
                    </CFIF>
                </CFOUTPUT>

            </SELECT>
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsideAddressLine1 FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsideAddressLine1")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsideAddressLine1  CLASS = "FormLabelGood">
                    Address Line 1 &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsideAddressLine1  CLASS = "FormLabelBad">
                    Address Line 1 &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsideAddressLine1"
                    SIZE        =  "50"
                    MAXLENGTH   =  "50"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsideAddressLine1#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsideAddressLine1')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsideAddressLine1')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsideAddressLine2 FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsideAddressLine2")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsideAddressLine2  CLASS = "FormLabelGood">
                    Address Line 2 &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsideAddressLine2  CLASS = "FormLabelBad">
                    Address Line 2 &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsideAddressLine2"
                    SIZE        =  "50"
                    MAXLENGTH   =  "50"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsideAddressLine2#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsideAddressLine2')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsideAddressLine2')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsideCity FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsideCity")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsideCity  CLASS = "FormLabelGood">
                    City &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsideCity  CLASS = "FormLabelBad">
                    City &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsideCity"
                    SIZE        =  "30"
                    MAXLENGTH   =  "30"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsideCity#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsideCity')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsideCity')"
            >
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsideStateCode FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsideStateCode")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsideStateCode  CLASS = "FormLabelGood">
                    State &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsideStateCode  CLASS = "FormLabelBad">
                    State &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <CFQUERY  NAME         = "qStateCode"
                      DATASOURCE   = "#APPLICATION.DataSource#"
                      CACHEDWITHIN = "#CreateTimeSpan(0, 8, 0, 0)#"
            >
                SELECT      cStateCode, cStateName
                FROM        StateCode
                ORDER BY    cStateName

            </CFQUERY>

            <SELECT  NAME     =  "Tenant_cOutsideStateCode"
                     SIZE     =  "1"
                     onFocus  =  "HasFocus ('Label_Tenant_cOutsideStateCode')"
                     onBlur   =  "LostFocus('Label_Tenant_cOutsideStateCode')"
            >

                <CFOUTPUT        QUERY =  "qStateCode">
                    <CFIF                  qStateCode.cStateCode  EQ  FORM.Tenant_cOutsideStateCode>
                        <OPTION  VALUE = "#qStateCode.cStateCode#"    SELECTED>
                                          #qStateCode.cStateName#
                    <CFELSE>
                        <OPTION  VALUE = "#qStateCode.cStateCode#">
                                          #qStateCode.cStateName#
                    </CFIF>
                </CFOUTPUT>

            </SELECT>
        </TD>

    </TR>


<!--- ---------------------------------------------------------------------------------------------
Display the Tenant dataset cOutsideZipCode FORM field.
---------------------------------------------------------------------------------------------- --->

    <TR>

        <TD  ALIGN = "RIGHT">
            <CFIF  ListFindNoCase(gFormErrorList, "Tenant_cOutsideZipCode")  EQ  0>
                <SPAN  ID = Label_Tenant_cOutsideZipCode  CLASS = "FormLabelGood">
                    ZipCode &nbsp;
                </SPAN>
            <CFELSE>
                <SPAN  ID = Label_Tenant_cOutsideZipCode  CLASS = "FormLabelBad">
                    ZipCode &nbsp;
                </SPAN>
            </CFIF>
        </TD>

        <TD>
            <INPUT  TYPE        =  "TEXT"
                    NAME        =  "Tenant_cOutsideZipCode"
                    SIZE        =  "10"
                    MAXLENGTH   =  "10"
                    VALUE       =  "<CFOUTPUT>#FORM.Tenant_cOutsideZipCode#</CFOUTPUT>"
                    onFocus     =  "HasFocus ('Label_Tenant_cOutsideZipCode')"
                    onBlur      =  "LostFocus('Label_Tenant_cOutsideZipCode')"
            >
        </TD>

    </TR>

</TABLE>

