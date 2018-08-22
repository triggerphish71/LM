<!--- *********************************************************************************************
Name:       MainMenu.cfm
Type:       Template
Purpose:    Set SESSION variables and display the main menu.


Called by: Index.cfm
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    URL.SelectedHouse_ID                House.aHouse_ID value of the house the user selected.


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







<!--- *********************************************************************************************
INCLUDE THE CURRENT INTRANET HEADER
********************************************************************************************** --->
<CFINCLUDE TEMPLATE="../header.cfm">





<!--- *********************************************************************************************
Retrieve list of all available apartments
********************************************************************************************** --->
<CFINCLUDE TEMPLATE="Shared/Queries/AvailableApartments.cfm">





<!--- =============================================================================================
Only Index.cfm can create URL.SelectedHouse_ID.  If it exists set SESSION variables.
============================================================================================== --->
<CFIF  IsDefined("URL.SelectedHouse_ID")>

    <CFINCLUDE  TEMPLATE = "House/Inc_SQLselectOne.cfm">

    <CFSET  SESSION.qSelectedHouse  =  qHouse>

	<CFSET	SESSION.HouseName		= #qhouse.cName#>
	
	<CFSET	SESSION.HouseNumber		= #qhouse.cNumber#>
		
<!--- ---------------------------------------------------------------------------------------------
We did NOT arrive via Index.cfm.  Verify SESSION variables still exist.
---------------------------------------------------------------------------------------------- --->
<CFELSEIF  NOT  IsDefined("SESSION.qSelectedHouse")>

    <CFSET  UrlStatusMessage  =  URLEncodedFormat("Your Intranet session has expired. Please select a house.")>

    <CFLOCATION  URL = "Index.cfm?UrlStatusMessage=#UrlStatusMessage#"  ADDTOKEN = "NO">

</CFIF>






<!--- =============================================================================================
Get the tenants for the selected house along with other related information.
============================================================================================== --->
<CFQUERY  NAME = "qResidentTenants"  DATASOURCE = "#APPLICATION.datasource#">
	SELECT	AD.cAptNumber, 
			T.iTenant_ID, 
			T.cSolomonKey, 
			T.cFirstName, 
			T.cLastName, 
			RT.cDescription as Residency, 
			TC.cDescription as State, 
			TS.dtMoveIn,
			TS.dtMoveOut,
			TS.iSPoints
	FROM	TENANT T	JOIN 	TenantState TS
				ON		T.iTenant_ID = TS.iTenant_ID
	
				JOIN 	TenantStateCodes TC
				ON		TS.iTenantStateCode_ID = TC.iTenantStateCode_ID
				
				JOIN	ResidencyType RT
				ON		TS.iResidencyType_ID = RT.iResidencyType_ID
	
				
				JOIN	APTADDRESS AD
				ON		TS.iAptAddress_ID = AD.iAptAddress_ID
	
	WHERE		TS.iTenantStateCode_ID = 2
	AND			T.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#						

    <CFIF  NOT IsDefined("URL.SelectedSortOrder")  OR  URL.SelectedSortOrder EQ "Apt">
        ORDER BY    AD.cAptNumber
    <CFELSEIF  URL.SelectedSortOrder EQ "Id">
        ORDER BY    T.cSolomonKey
    <CFELSEIF  URL.SelectedSortOrder EQ "Name">
        ORDER BY    T.cLastName, T.cFirstName
    <CFELSEIF  URL.SelectedSortOrder EQ "Type">
        ORDER BY    RT.cDescription
    <CFELSEIF  URL.SelectedSortOrder EQ "Points">
        ORDER BY    TS.iSPoints
    <CFELSEIF  URL.SelectedSortOrder EQ "MoveIn">
        ORDER BY    TS.dtMoveIn
    <CFELSEIF  URL.SelectedSortOrder EQ "MoveOut">
        ORDER BY    TS.dtMoveOut
    <CFELSEIF  URL.SelectedSortOrder EQ "LastBalance">
        ORDER BY    T.cLastName, T.cFirstName
    <CFELSEIF  URL.SelectedSortOrder EQ "PaymentsSince">
        ORDER BY    T.cLastName, T.cFirstName
    <CFELSEIF  URL.SelectedSortOrder EQ "CurrentCharges">
        ORDER BY    T.cLastName, T.cFirstName
    </CFIF>

</CFQUERY>






    <TITLE> Tips 4  - Main Menu </TITLE>


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

<H1  CLASS = "PageTitle">
    Tips 4 - TIPS Summary
</H1>

<CFINCLUDE TEMPLATE="Shared/HouseHeader.cfm">

<HR>

<BR>






<!--- =============================================================================================
Display links.
============================================================================================== --->

<TABLE>

    <TR>
        <TD CLASS = "HLINKS"> <A  HREF = "Registration/Registration.cfm">   	New Applicant/Move-In				</A> </TD>
        <TD CLASS = "HLINKS"> <A  HREF = "CashReceipts/CashReceipts.cfm">   	Enter Payments	                	</A> </TD>
        <TD CLASS = "HLINKS"> <A  HREF = "Relocate/RelocateTenant.cfm">       	Relocate Tenant                    	</A> </TD>
        <TD CLASS = "HLINKS"> <A  HREF = "Charges/Charges.cfm">			 		Charges			                   	</A> </TD>
        <TD CLASS = "HLINKS"> <A  HREF = "Reports/Menu.cfm">        			Reports                            	</A> </TD>
        <TD CLASS = "HLINKS"> <A  HREF = "Admin/Menu.cfm">           			Administration                     	</A> </TD>
    </TR>
	
	
</TABLE>







<!--- =============================================================================================
Display the tenant menu table.  Start with the column headers.
============================================================================================== --->

<TABLE>

    <TR>
        <TH> <A  HREF = "?SelectedSortOrder=Apt" 			STYLE = "COLOR: White;">	Apt              	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=Id" 			STYLE = "COLOR: White;">	TID		          	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=Name" 			STYLE = "COLOR: White;">	Name             	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=Type" 			STYLE = "COLOR: White;">	Type             	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=Points" 		STYLE = "COLOR: White;">	SPts.	           	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=MoveIn" 		STYLE = "COLOR: White;">	MoveIn          	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=MoveOut" 		STYLE = "COLOR: White;">	MoveOut         	</A> </TH>
        <TH> <A  HREF = "?SelectedSortOrder=LastBalance" 	STYLE = "COLOR: White;">	Curr. Bal.			</A> </TH>
		
		
		
		
<!--- ==============================================================================
		Adds One Month to display the Correct Charges Acct Period.
		This will be the month of the TIPS accounting period when we are up and running.
=============================================================================== --->
		<CFOUTPUT>
			
			<CFSET Month = #DateAdd("m", +1,"#Now()#")#>
			<TH> <A  HREF = "?SelectedSortOrder=PaymentsSince"  STYLE = "COLOR: White;">	#DateFormat(Session.TIPSMonth, "mmmm")# Charges   	</A> </TH>
    
	 	</CFOUTPUT>
	 
	 <!---    <TH> <A  HREF = "?SelectedSortOrder=CurrentCharges"> Current Charges  </A> </TH> --->
    </TR>

	
	
	

<!--- ==============================================================================
<!--- ---------------------------------------------------------------------------------------------
Now display all of the rows from our query.
---------------------------------------------------------------------------------------------- --->

    <CFOUTPUT  QUERY = "qResidentTenants">


=============================================================================== --->	
	
	
<CFOUTPUT QUERY = "Available">

	<CFQUERY NAME = "CurrentTenants" DATASOURCE = "#APPLICATION.datasource#">
		SELECT	T.*, TS.*, AD.*, RT.cDescription as Residency
		FROM	Tenant	T
					JOIN TenantState TS
					ON	 T.iTenant_ID = TS.iTenant_ID
					
					JOIN	AptAddress AD
					ON		AD.iAptAddress_ID = TS.iAptAddress_ID
					
					JOIN	ResidencyType RT
					ON		RT.iResidencyType_ID = TS.iResidencyType_ID
					
		WHERE	TS.iAptAddress_ID =  #Available.iAptAddress_ID#
		AND		TS.iTenantStateCode_ID = 2
	</CFQUERY>	
	
	
        <TR>
            <TD>  #Available.cAptNumber#          </TD>
            <TD>  #CurrentTenants.cSolomonKey#         </TD>
            
			
			<TD>
                <A  HREF = "Tenant/Edit.cfm?SelectedTenant_ID=#qResidentTenants.iTenant_ID#">
                	#CurrentTenants.cFirstName# #CurrentTenants.cLastName#
				</A>
			</TD>
            
			
			<TD>	#CurrentTenants.Residency#        </TD>
            <TD>	#CurrentTenants.iSPoints#         </TD>
            
			
			
			<TD>	
				<A HREF = "MoveIn/MoveInSummary.cfm?ID=#qResidentTenants.iTenant_ID#">
					#DATEFORMAT(CurrentTenants.dtMoveIn, "mm/dd/yyyy")#
				</A>
			</TD>
            
			
			
			
			<CFIF CurrentTenants.dtMoveOut NEQ "">
				<TD>	#DATEFORMAT(CurrentTenants.dtMoveOut, "mm/dd/yyyy")#            </TD>
			<CFELSEIF CurrentTenants.dtMoveOut EQ "">
				<TD>	n/a	</TD>
			</CFIF>
			
			
			
			<TD>	</TD>
		
			<CFIF CurrentTenants.iTenant_ID NEQ "">
			
			<CFQUERY NAME = "TotalCharges" DATASOURCE = "#APPLICATION.datasource#">
				SELECT	sum(mAmount) as Sum
				FROM	InvoiceDetail
				WHERE	iTenant_ID = #CurrentTenants.iTenant_ID#
				AND	dtRowDeleted IS NULL
			</CFQUERY>
			
				<CFSET TotalCharges = #TotalCharges.sum#>
			
			<CFELSE>
				
				<CFSET TotalCharges = "">
				
			</CFIF>
			
			<TD>	#LSCurrencyFormat(TotalCharges)# </TD>
       
	   
	    </TR>

    </CFOUTPUT>

</TABLE>
<BR>
<BR>







<CFOUTPUT>
		<CFIF SESSION.USERID IS 3025>
			#CurrentTenants.Recordcount# - Number of Records<BR>
		</CFIF>
		<A HREF = "Index.cfm" STYLE = "Font-size: 18;">	Click Here To Go Back and Select a Different House.	</a>
</CFOUTPUT>






<!--- *********************************************************************************************
DISPLAY THE INTRANET FOOTER
********************************************************************************************** --->
<CFINCLUDE TEMPLATE="../Footer.cfm">

