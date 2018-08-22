<!--- *********************************************************************************************
Name:       SPointsLog/Inc_VerifyInput.cfm

Type:       Include

Purpose:    Verify the SPointsLog dataset FORM fields.  Set gFormErrorList to the name(s) of all FORM
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
If SPointsLog_iSPoints was entered SPointsLog_dStart must also have been entered.
---------------------------------------------------------------------------------------------- --->

    <CFIF  FORM.SPointsLog_iSPoints  NEQ  ""    AND
           FORM.SPointsLog_dStart     EQ  "">

        <CFSET  TempMsg  =  "When you input Service Points you must also input a Service Points Effective Date. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "SPointsLog_dStart")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

        <CFBREAK>

    </CFIF>


<!--- ---------------------------------------------------------------------------------------------
If SPointsLog_dStart was entered SPointsLog_iSPoints must also have been entered.
---------------------------------------------------------------------------------------------- --->

    <CFIF  FORM.SPointsLog_iSPoints   EQ  ""    AND
           FORM.SPointsLog_dStart    NEQ  "">

        <CFSET  TempMsg  =  "When you input a Service Points Effective Date you must also input Service Points. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "SPointsLog_iSPoints")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

        <CFBREAK>

    </CFIF>


<!--- ---------------------------------------------------------------------------------------------
If SPointsLog_iSPoints was input verify it is a valid service points number.
---------------------------------------------------------------------------------------------- --->

    <CFIF                 FORM.SPointsLog_iSPoints  NEQ  ""    AND
          (NOT  IsNumeric(FORM.SPointsLog_iSPoints)             OR
                          FORM.SPointsLog_iSPoints  LE  0       OR
                          FORM.SPointsLog_iSPoints  GT  99)>

        <CFSET  TempMsg  =  "Service Points is not a valid number. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "SPointsLog_iSPoints")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

        <CFBREAK>

    </CFIF>


<!--- ---------------------------------------------------------------------------------------------
If SPointsLog_dStart was input verify it is a valid date.
---------------------------------------------------------------------------------------------- --->

    <CFIF              FORM.SPointsLog_dStart  NEQ  ""      AND
           NOT  IsDate(FORM.SPointsLog_dStart)>

        <CFSET  TempMsg  =  "Service Points Effective Date is not in a valid date format. ">

        <CFSET  gFormErrorList     =  ListAppend(gFormErrorList, "SPointsLog_dStart")>
        <CFSET  gFormErrorMessage  =  gFormErrorMessage  &  TempMsg>

    </CFIF>

<CFBREAK> </CFLOOP>

