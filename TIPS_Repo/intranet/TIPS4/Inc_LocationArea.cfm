<!--- *******************************************************************************
Name:			ApplicationList.cfm
Process:		Create SESSION Appliction variable for different applications

Called by: 		SharePoint Portal
Calls/Submits:	Several Applications
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            08/1/2002      Original Authorship
******************************************************************************** --->
<CFOUTPUT>

<CFIF IsDefined("url.app")>
	
	<CFSWITCH EXPRESSION="#url.app#">
		<CFCASE VALUE='TIPS4'>	<CFSET SESSION.APPLICATION='TIPS4'><CFSET LocationArea='MainMenu.cfm'> </CFCASE>		
		<CFCASE VALUE='capex'>	<CFSET SESSION.APPLICATION='CapitalExpenditure'><CFSET LocationArea='../CapitalExpenditure/CapitalExpenditure.cfm'> </CFCASE>
		<CFCASE VALUE='keyinitiatives'>	<CFSET SESSION.APPLICATION='KeyInitiatives'><CFSET LocationArea='../KeyInitiatives/KeyInitiatives.cfm'> </CFCASE>
		<CFCASE VALUE='AssessmentReview'><CFSET SESSION.APPLICATION='AssessmentReview'><CFSET LocationArea='../AssessmentReview/AssessmentReview.cfm'> </CFCASE>
		<CFCASE VALUE='EmployeeTraining'> <CFSET SESSION.APPLICATION='EmployeeTraining'><CFSET LocationArea='../EmployeeTraining/EmployeeTraining.cfm'> </CFCASE>
		<CFCASE VALUE='InquiryTracking'> <CFSET SESSION.APPLICATION='InquiryTracking'><CFSET LocationArea='../MarketingLeads/Leads.cfm'> </CFCASE>
		<CFCASE VALUE='FocalReview'> <CFSET SESSION.APPLICATION='FocalReview'><CFSET LocationArea='../FocalReview/Facility/FacilityReview.cfm'> </CFCASE>
		<CFCASE VALUE='CorporateFocalReview'> <CFSET SESSION.APPLICATION='CorporateFocalReview'><CFSET LocationArea='../FocalReview/Company/CorporateReview.cfm'> </CFCASE>
		<CFDEFAULTCASE>	<CFSET SESSION.APPLICATION = 'TIPS4'><CFSET LocationArea='MainMenu.cfm'></CFDEFAULTCASE>
	</CFSWITCH>

<CFELSEIF IsDefined("SESSION.APPLICATION")>

	<CFSWITCH EXPRESSION="#SESSION.APPLICATION#">
		<CFCASE VALUE='TIPS4'> <CFSET SESSION.APPLICATION='TIPS4'><CFSET LocationArea='MainMenu.cfm'> </CFCASE>		
		<CFCASE VALUE='CapitalExpenditure'> <CFSET SESSION.APPLICATION='CapitalExpenditure'><CFSET LocationArea='../CapitalExpenditure/CapitalExpenditure.cfm'> </CFCASE>
		<CFCASE VALUE='keyinitiatives'>	<CFSET SESSION.APPLICATION='KeyInitiatives'><CFSET LocationArea='../KeyInitiatives/KeyInitiatives.cfm'> </CFCASE>
		<CFCASE VALUE='AssessmentReview'> <CFSET SESSION.APPLICATION='AssessmentReview'><CFSET LocationArea='../AssessmentReview/AssessmentReview.cfm'> </CFCASE>
		<CFCASE VALUE='EmployeeTraining'> <CFSET SESSION.APPLICATION='EmployeeTraining'><CFSET LocationArea='../EmployeeTraining/EmployeeTraining.cfm'> </CFCASE>
		<CFCASE VALUE='InquiryTracking'> <CFSET SESSION.APPLICATION='InquiryTracking'><CFSET LocationArea='../MarketingLeads/Leads.cfm'> </CFCASE>
		<CFCASE VALUE='FocalReview'> <CFSET SESSION.APPLICATION='FocalReview'><CFSET LocationArea='../FocalReview/Facility/FacilityReview.cfm'> </CFCASE>
		<CFCASE VALUE='CorporateFocalReview'> <CFSET SESSION.APPLICATION='CorporateFocalReview'><CFSET LocationArea='../FocalReview/Company/CorporateReview.cfm'> </CFCASE>
		<CFDEFAULTCASE>	<CFSET SESSION.APPLICATION = 'TIPS4'><CFSET LocationArea='MainMenu.cfm'></CFDEFAULTCASE>
	</CFSWITCH>
	
<CFELSE>
	<CFSET SESSION.APPLICATION='TIPS4'><CFSET LocationArea='MainMenu.cfm'>
</CFIF>


</CFOUTPUT>