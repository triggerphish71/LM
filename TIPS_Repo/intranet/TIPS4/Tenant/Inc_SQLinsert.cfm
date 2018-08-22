<!--- *********************************************************************************************
Name:       Tenant/Inc_SQLinsert.cfm

Type:       Include

Purpose:    Insert a row in the Tenant dataset.


Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
S. Knox                 20 Mar 01       Original Authorship


********************************************************************************************** --->


<!--- ---------------------------------------------------------------------------------------------
If another tenant's Solomon Key was NOT selected we must create a new unique one.
---------------------------------------------------------------------------------------------- --->

<CFIF  FORM.SelectedSolomonKey  =  "">

    <CFTRANSACTION>

        <CFQUERY  NAME = "qSolomonKey"  DATASOURCE = "#APPLICATION.DataSource#">
            SELECT  iNextSolomonKey
            FROM    SolomonKey
            WHERE   iHouse_ID        =  #SESSION.SelectedHouse_ID#
        </CFQUERY>

        <CFSET  CurrentSolomonKey    =  qSolomonKey.iNextSolomonKey
        <CFSET  NextSolomonKey       =  CurrentSolomonKey  +  1>

        <CFQUERY  DATASOURCE = "#APPLICATION.DataSource#">
            UPDATE  SolomonKey
               SET  iNextSolomonKey  =  #NextSolomonKey#
            WHERE   iHouse_ID        =  #SESSION.SelectedHouse_ID#
        </CFQUERY>

    </CFTRANSACTION>

    <CFSET  FORM.Tenant_cSolomonKey  =  CurrentSolomonKey>

<CFELSE>

    <CFSET  FORM.Tenant_cSolomonKey  =  FORM.SelectedSolomonKey>

</CFIF>


<!--- ---------------------------------------------------------------------------------------------
Insert the row.
---------------------------------------------------------------------------------------------- --->

<CFQUERY  DATASOURCE = "#APPLICATION.DataSource#">

    INSERT  INTO  Tenant
            (
             iHouse_ID,
             cSolomonKey,
             cFirstName,
             cLastName,
             dBirthDate,
             cSSN,
             cMedicaidNumber,
             cOutsidePhoneNumber1,
             iOutsidePhoneType1_ID,
             cOutsidePhoneNumber2,
             iOutsidePhoneType2_ID,
             cOutsidePhoneNumber3,
             iOutsidePhoneType3_ID,
             cOutsideAddressLine1,
             cOutsideAddressLine2,
             cOutsideCity,
             cOutsideStateCode,
             cOutsideZipCode,
             cComments,
             iRowStartUser_ID,
             dtRowStart,
             dtRowEnd
            )
            VALUES
            (
             #FORM.Tenant_iHouse_ID#,
            '#FORM.Tenant_cSolomonKey#',
             <CFIF  FORM.Tenant_cFirstName             EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cFirstName#',             </CFIF>
             <CFIF  FORM.Tenant_cLastName              EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cLastName#',              </CFIF>
             <CFIF  FORM.Tenant_dBirthDate             EQ  "">  NULL,  <CFELSE>   #FORM.Tenant_dBirthDate#,              </CFIF>
             <CFIF  FORM.Tenant_cSSN                   EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_ccSSN#',                  </CFIF>
             <CFIF  FORM.Tenant_cMedicaidNumber        EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cMedicaidNumber#',        </CFIF>
             <CFIF  FORM.Tenant_cSSN                   EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cSSN#',                   </CFIF>
             <CFIF  FORM.Tenant_cOutsidePhoneNumber1   EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsidePhoneNumber1#',   </CFIF>
             <CFIF  FORM.Tenant_iOutsidePhoneType1_ID  EQ  0>   NULL,  <CFELSE>   #FORM.Tenant_iOutsidePhoneType1_ID#,   </CFIF>
             <CFIF  FORM.Tenant_cOutsidePhoneNumber2   EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsidePhoneNumber2#',   </CFIF>
             <CFIF  FORM.Tenant_iOutsidePhoneType2_ID  EQ  0>   NULL,  <CFELSE>   #FORM.Tenant_iOutsidePhoneType2_ID#,   </CFIF>
             <CFIF  FORM.Tenant_cOutsidePhoneNumber    EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsidePhoneNumber#',    </CFIF>
             <CFIF  FORM.Tenant_iOutsidePhoneType3_ID  EQ  0>   NULL,  <CFELSE>   #FORM.Tenant_iOutsidePhoneType3_ID#,   </CFIF>
             <CFIF  FORM.Tenant_cOutsideAddressLine1   EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsideAddressLine1#',   </CFIF>
             <CFIF  FORM.Tenant_cOutsideAddressLine2   EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsideAddressLine2#',   </CFIF>
             <CFIF  FORM.Tenant_cOutsideCity           EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsideCity#',           </CFIF>
             <CFIF  FORM.Tenant_cOutsideStateCode      EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsideStateCode#',      </CFIF>
             <CFIF  FORM.Tenant_cOutsideZipCode        EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cOutsideZipCode#',        </CFIF>
             <CFIF  FORM.Tenant_cComments              EQ  "">  NULL,  <CFELSE>  '#FORM.Tenant_cComments#',              </CFIF>
             #SESSION.User_ID#,
             #CreateODBCDateTime(NOW())#,
             #APPLICATION.dODBCmaxEndDate#
            )

</CFQUERY>

