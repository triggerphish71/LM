<!--- *********************************************************************************************
Name:       Tenant/Menu.cfm
Type:       Template
Purpose:    Display the Applicant Tenant menu.

Called by: MainMenu.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None


Calls: Tenant/Add.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None


Calls: Tenant/Edit.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.SelectedTenant_ID               Tenant.aTenant_ID value of the tenant the user selected.



Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->



<!--- =============================================================================================
Get the Applicant Tenants for the selected house along with other related information.
============================================================================================== --->

<CFQUERY  NAME = "qApplicantTenants"  DATASOURCE = "#APPLICATION.DataSource#">

    SELECT      Tenant.iTenant_ID,
                Tenant.cSolomonKey,
                Tenant.cFirstName,
                Tenant.cLastName

    FROM        Tenant  INNER JOIN  ActiveLog
                                ON  ActiveLog.iTenant_ID  =  Tenant.iTenant_ID

    WHERE       Tenant.iHouse_ID   =  #SESSION.qSelectedHouse.iHouse_ID#   AND
                ActiveLog.dtMoveIn  =   NULL

    <CFIF  NOT IsDefined("URL.SelectedSortOrder")  OR  URL.SelectedSortOrder EQ "Id">
        ORDER BY    Tenant.cSolomonKey
    <CFELSE>
        ORDER BY    Tenant.cLastName, Tenant.cFirstName
    </CFIF>

</CFQUERY>


<!--- *********************************************************************************************
HTML head.
********************************************************************************************** --->



<!--- *********************************************************************************************
HTML body.
********************************************************************************************** --->

<BODY>


<!--- =============================================================================================
Display any status message.
============================================================================================== --->

<CFIF  IsDefined ("URL.UrlStatusMessage")  AND  Len(URL.UrlStatusMessage)  GT  0>
    <DIV  CLASS = "UrlStatusMessage">
        <CFOUTPUT> #URL.UrlStatusMessage# </CFOUTPUT>
    </DIV>
    <BR>
</CFIF>


<!--- =============================================================================================
Display the page title.
============================================================================================== --->

<DIV  CLASS = "PageTitle">
    Tips 4 - Tenant Applicants
</DIV>

<HR>

<BR>


<!--- =============================================================================================
Display links.
============================================================================================== --->

<TABLE  BORDER = 0  CELLSPACING = 0  CELLPADDING = 5>

    <TR>
        <TD> <A  HREF = "Tenant/Menu.cfm"> New Applicant </A> </TD>
    </TR>

</TABLE>

<BR>


<!--- =============================================================================================
Display the tenant menu table.  Start with the column headers.
============================================================================================== --->

<TABLE  BORDER = 1  CELLSPACING = 0  CELLPADDING = 5>

    <TR>
        <TH> <A  HREF = "?SelectedSortOrder=Id">    Id               </A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=Name">  Name             </A> </TH>
    </TR>


<!--- ---------------------------------------------------------------------------------------------
Now display all of the rows from our query.
---------------------------------------------------------------------------------------------- --->

    <CFOUTPUT  QUERY = "qApplicantTenants">

        <CFSET  TempSolomonKey  =  qApplicantTenants.cSolomonKey>
        <CFSET  TempFullName    =  qApplicantTenants.cFirstName  &  " "  &  qApplicantTenants.cLastName>

        <TR>
            <TD  CLASS = "Color">  #TempSolomonKey#  </TD>
            <TD  CLASS = "Color">  #TempFullName#    </TD>
        </TR>

    </CFOUTPUT>

</TABLE>

</BODY> </HTML>

