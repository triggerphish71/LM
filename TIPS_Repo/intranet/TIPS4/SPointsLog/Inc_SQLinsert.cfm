<!--- *********************************************************************************************
Name:       SPointsLog/Inc_SQLinsert.cfm

Type:       Include

Purpose:    Insert a row in the SPointsLog dataset.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
Remove extraneous spaces from character fields the user can input.
---------------------------------------------------------------------------------------------- --->

<CFSET  FORM.SPoints_dEvaluation  =  Trim(FORM.SPoints_dEvaluation)>
<CFSET  FORM.SPoints_dStart       =  Trim(FORM.SPoints_dStart)>
<CFSET  FORM.SPoints_cComments    =  Trim(FORM.SPoints_cComments)>


<!--- ---------------------------------------------------------------------------------------------
Insert the row.
---------------------------------------------------------------------------------------------- --->

<CFQUERY  DATASOURCE = "#APPLICATION.DataSource#">

    INSERT  INTO  SPointsLog
            (
             dEvaluation,
             iSPoints,
             dStart,
             dEnd,
             cComments,
             iRowStartUser_ID,
             dtRowStart,
             dtRowEnd
            )
            VALUES
            (
             <CFIF  FORM.SPoints_dEvaluation  EQ  "">  NULL,  <CFELSE>   #FORM.SPoints_dEvaluation#,  </CFIF>
             <CFIF  FORM.SPoints_iSPoints     EQ  "">  NULL,  <CFELSE>   #FORM.SPoints_iSPoints#,     </CFIF>
             <CFIF  FORM.SPoints_dStart       EQ  "">  NULL,  <CFELSE>  '#FORM.SPoints_dStart#',      </CFIF>
             <CFIF  FORM.SPoints_dEnd         EQ  "">  NULL,  <CFELSE>  '#FORM.SPoints_dEnd#',        </CFIF>
             <CFIF  FORM.SPoints_cComments    EQ  "">  NULL,  <CFELSE>  '#FORM.SPoints_cComments#',   </CFIF>
             #SESSION.User_ID#,
             #CreateODBCDateTime(NOW())#,
             #APPLICATION.dODBCmaxEndDate#
            )

</CFQUERY>

