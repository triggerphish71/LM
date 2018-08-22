<!--- *********************************************************************************************
Name:       Shared/Inc_FormErrMsgInit.cfm
Type:       Include
Purpose:    Initialize the variables used to report FORM field user input errors.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship
********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
gFormErrorList contains the names of all the FORM variables which have user input errors.
---------------------------------------------------------------------------------------------- --->

<CFSET  gFormErrorList  =  "">


<!--- ---------------------------------------------------------------------------------------------
gFormErrorMessage has the error message for the user describing what is wrong with the user's input.
---------------------------------------------------------------------------------------------- --->

<CFSET  gFormErrorMessage  =  "">

