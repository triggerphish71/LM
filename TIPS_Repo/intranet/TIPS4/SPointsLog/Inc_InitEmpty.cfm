<!--- *********************************************************************************************
Name:       SPointsLog/Inc_InitEmpty.cfm

Type:       Include

Purpose:    Initialize SPointsLog FORM fields when creating a new tenant.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
Set the SPointsLog FORM fields to their default values.
---------------------------------------------------------------------------------------------- --->

<CFSET  FORM.SPointsLog_aSPointsLog_ID        =  "">
<CFSET  FORM.SPointsLog_iTenant_ID            =  "">
<CFSET  FORM.SPointsLog_cAppliesToAcctPeriod  =  "">
<CFSET  FORM.SPointsLog_dEvaluation           =  "">
<CFSET  FORM.SPointsLog_iSPoints              =  "">
<CFSET  FORM.SPointsLog_dStart                =  "">
<CFSET  FORM.SPointsLog_dEnd                  =  "">
<CFSET  FORM.SPointsLog_cComments             =  "">

