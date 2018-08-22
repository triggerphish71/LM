<!--- *********************************************************************************************
Name:      	PhoneTypeQuery.cfm
Type:       Template
Purpose:    Set SESSION variables and display the main menu.


Called by: 
    Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------

  	
Calls: 
	Parameter Name                      Description
    ------------------------------      -----------------------------------------------------------
    None

Modified By             Date            Reason
-------------------     -------------   -----------------------------------------------------------
P .Buendia              16 Apr 01       Original Authorship
********************************************************************************************** --->


<!--- =============================================================================================
Get Phone Type Information List
============================================================================================= --->
<CFQUERY NAME = "PhoneType" DATASOURCE = "#APPLICATION.datasource#">
	SELECT	*
	FROM 	PhoneType
	ORDER BY	iDisplayOrder
</CFQUERY>



