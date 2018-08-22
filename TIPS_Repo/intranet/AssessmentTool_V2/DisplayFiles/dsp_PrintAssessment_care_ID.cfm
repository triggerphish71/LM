<!---- Ganga Thota on 04/26/2017 Care plan users need asessments with selected services   --->

<cfsavecontent variable="PDFhtml">
	<cfheader name="Content-Disposition" value="attachment;filename=Assessment-care-Summary-ID.pdf">
	<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title> Print Assessment</title>
</head>

<cfquery name="sp_assessmenttoolsummary" datasource="#application.datasource#">
			<!---	EXEC rw.sp_assessmenttoolPrintsummary --->
		 EXEC [rw].[sp_AssessmentToolPrintSummary]
				@iAssessmentMaster_ID =   #assessmentId# 
				,@summary='N'
				,@Scope=''
		</cfquery> 	
		<cfquery name="sp_PointsList" datasource="#application.datasource#">
			EXEC rw.sp_PointsList
			@cSLevelTypeSet= #sp_assessmenttoolsummary.cToolLevelTypeSet#
		</cfquery>
		<cfquery name="selectservicecategory" datasource="#application.datasource#">
			Select * 
			from Servicecategories with (nolock)
			where iAssessmenttool_ID= #sp_assessmenttoolsummary.iAssessmentTool_id#
			and dtrowdeleted is null
			order by
			CONVERT(INT, cSortOrder)
		</cfquery>

		
	<body>
	<cfoutput  >
		<div>
				<table width="50%"  cellspacing="2" cellpadding="2" style="float: left;"> 
					<tr> 
					   <td style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							 <b>Personal Information : </b>#sp_assessmenttoolsummary.csolomonkey# 
							<br> &nbsp;&nbsp;&nbsp;#sp_assessmenttoolsummary.cFirstname# #sp_assessmenttoolsummary.clastname#</br>
							<br> &nbsp;&nbsp;&nbsp;#sp_assessmenttoolsummary.caddressline1#</br> 
						<!---	<br> &nbsp;&nbsp;&nbsp;#sp_assessmenttoolsummary.cPreviousAddressLine1#</br> --->
							<br> &nbsp;&nbsp;&nbsp;#sp_assessmenttoolsummary.ccity# #sp_assessmenttoolsummary.cstatecode# #sp_assessmenttoolsummary.cZipcode#</br> 
					<!---	<br> &nbsp;&nbsp;&nbsp;  #sp_assessmenttoolsummary.cPreviousCity# #sp_assessmenttoolsummary.cPreviousState# #sp_assessmenttoolsummary.cPreviousZipCode#  </br>--->
							 
							<br> &nbsp;&nbsp;&nbsp;	(#left(sp_assessmenttoolsummary.cPhonenumber1,3)#) #mid(sp_assessmenttoolsummary.cPhonenumber1,4,3)#-#right(sp_assessmenttoolsummary.cPhonenumber1,4)# 
							</br>
							<br> &nbsp;&nbsp;&nbsp;Apartment Number#sp_assessmenttoolsummary.cAptNumber#</br>
						</td> 
					</tr> 								
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px">
						 <b>Date of Birth :</b> #DATEFORMAT(sp_assessmenttoolsummary.dBirthDate, "mm/dd/yyyy")#</td> 
					</tr>
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px ">
					 <b>Height:</b>  #sp_assessmenttoolsummary.iheightfeet# Feet #sp_assessmenttoolsummary.iheightInches# Inches</td> 
					</tr>	
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px  ">
				 <b>weight:</b> #sp_assessmenttoolsummary.iweight# </td> 
					</tr>	
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px  ">
				 <b>Review Range :</b> #DATEFORMAT(sp_assessmenttoolsummary.dtReviewstart, "mm/dd/yyyy")# - #DATEFORMAT(sp_assessmenttoolsummary.dtreviewend, "mm/dd/yyyy")#</td> 
					</tr>
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px  ">
				 <b>Active range :</b> <cfif #sp_assessmenttoolsummary.dtBillingActive# eq '' and #sp_assessmenttoolsummary.bBillingActive# eq ''> 
					           <cfelseif #sp_assessmenttoolsummary.dtBillingActive# neq '' and #sp_assessmenttoolsummary.bBillingActive# eq ''>
				                #DATEFORMAT(sp_assessmenttoolsummary.dtBillingActive, "mm/dd/yyyy")#- #DATEFORMAT(sp_assessmenttoolsummary.dtCurrentBillingActive, "mm/dd/yyyy")#
					            <cfelse> 
					             #DATEFORMAT(sp_assessmenttoolsummary.dtBillingActive, "mm/dd/yyyy")#- Present 
							    </cfif>
					    </td> 
					</tr>
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px  ">
				 <b>Review Type :</b> #sp_assessmenttoolsummary.cReviewDescription# </td> 
					</tr>	
					<tr> 
						<td   style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px  ">
				 <b>Next Review Date :</b> #DATEFORMAT(sp_assessmenttoolsummary.dtNextReview, "mm/dd/yyyy")# </td> 
					</tr>				
				</table>
				<table width="50%"  cellspacing="2" cellpadding="2" style="float: right;">
					<tr>
					<td  width="25%" style="text-align:left;font-family: Arial, Helvetica, sans-serif; font-size:12px" >
					<cfif #sp_assessmenttoolsummary.itoolpoints# eq "" >	
					Your Points: ?
					<cfelse>
				    Your Points:#sp_assessmenttoolsummary.itoolpoints#
				   </cfif> 
				   <cfif #sp_assessmenttoolsummary.cToolLevel# eq "">
				   (Level ? )   
				   <cfelse>	   
				   (Level #sp_assessmenttoolsummary.cToolLevel# )
				   </cfif>
					</td> 
				   <td width="20%">
					   &nbsp;
				   </td>
					</tr>
						
				</table>
	</div>

	<div>
		<table width="95%"  cellspacing="2" cellpadding="2" style="border-top:1px solid black;">
			<tr> 
			<td style="text-align:center; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							&nbsp;
			</td> 
			</tr> 
			<tr> 
			<td style="text-align:center; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							 <b>Service Categories</b>
			</td> 
			</tr> 
			<cfloop query="selectservicecategory">
		       <tr> 
			   		<td style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:14px">
					#selectservicecategory.cdescription#
		       		</td>
		       </tr>
			    <cfquery name="assessmentoolsummaryservicecategorynotes" dbtype="query">
				    Select ctruncatednotes from sp_assessmenttoolsummary 
					where iservicecategory_ID= #selectservicecategory.iservicecategory_ID#
				    and iservicelist_ID is null
				 </cfquery>
				
				<cfloop query="assessmentoolsummaryservicecategorynotes">
						 <cfif #assessmentoolsummaryservicecategorynotes.ctruncatednotes# neq "">
							 <tr>  <td style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; font-weight:normal;margin-left:2em">
							 <b>Notes:  #assessmentoolsummaryservicecategorynotes.ctruncatednotes#</b>
							 </td>
							 </tr>
						</cfif>
				</cfloop>	<!---<cfloop query="assessmentoolsummaryservicecategorynotes"> --->		
					<cfquery name="AssessmentToolSummaryservicelevel" dbtype="query">	
							 select Distinct cTruncatedDescription,fweight,Service_text,iselectedservice, iservicelist_ID,csortorder from sp_AssessmentToolSummary 
							 where iservicecategory_ID= #selectservicecategory.iservicecategory_ID# and service_text = 'y'
							 order by csortorder
					</cfquery>
				   <cfset service_level = ''> 
				   <cfset notes = ''> 
					<cfloop query="AssessmentToolSummaryservicelevel">
						<cfif service_level NEQ #AssessmentToolSummaryservicelevel.cTruncatedDescription#>
							<cfset service_level = #AssessmentToolSummaryservicelevel.cTruncatedDescription#>
							<tr>					     
							  <td style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; font-weight:normal;margin-left:2em">
								   <cfquery name="AssessmentToolSummaryservicelevelchekbox" dbtype="query">
									select distinct Service_text from sp_AssessmentToolSummary
									where iservicelist_ID= #AssessmentToolSummaryservicelevel.iservicelist_ID#
									and service_text is not null
									</cfquery>
								   <cfloop query="AssessmentToolSummaryservicelevelchekbox">
								   <cfif #AssessmentToolSummaryservicelevelchekbox.Service_text# eq "y">
								   [X]
								   <cfelse>
								   [ ]
								   </cfif>
								   </cfloop>
								   <cfif left(#AssessmentToolSummaryservicelevel.cTruncatedDescription#,3) eq "<b>">
									#Mid(AssessmentToolSummaryservicelevel.cTruncatedDescription,4,Len(AssessmentToolSummaryservicelevel.cTruncatedDescription)-7)# <!---(#AssessmentToolSummaryservicelevel.fweight# points)--->  
								   <cfelse>
								   #AssessmentToolSummaryservicelevel.cTruncatedDescription#  (#AssessmentToolSummaryservicelevel.fweight# points) 
								   </cfif>
								</td>
							  </tr>	
							<cfquery name="Assessmenttoolsummarycnotes" dbtype="query">
									Select distinct ctruncatednotes,isubservicelist_ID from sp_AssessmentToolSummary 
									where iservicelist_ID= #AssessmentToolSummaryservicelevel.iservicelist_ID#							
							</cfquery>
		
							<cfloop query="Assessmenttoolsummarycnotes"> 
								<cfif notes neq #Assessmenttoolsummarycnotes.ctruncatednotes#>
									<cfset notes = #Assessmenttoolsummarycnotes.ctruncatednotes#>
										<cfif  #Assessmenttoolsummarycnotes.ctruncatednotes# NEQ "">
											<tr>
												<td style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px;margin-left:2em ">
												<b>Notes: #Assessmenttoolsummarycnotes.ctruncatednotes# </b>
												</td>
											</tr> 	
										 </cfif> <!--- <cfif  #Assessmenttoolsummarycnotes.ctruncatednotes# NEQ ""> --->						                 								                 
								 </cfif> <!--- <cfif notes neq #Assessmenttoolsummarycnotes.ctruncatednotes#> --->
							</cfloop> <!--- <cfloop query="Assessmenttoolsummarycnotes">  --->
							<cfquery name="Assessmenttoolsummarycnotes2" dbtype="query">
									Select distinct isubservicelist_ID,cSubSortorder from sp_AssessmentToolSummary 
									where iservicelist_ID= #AssessmentToolSummaryservicelevel.iservicelist_ID#	<!--- and service_text = 'y'  --->
								    order by cSubSortorder				
							</cfquery>
							
							<cfloop query="Assessmenttoolsummarycnotes2"> 	
								 <cfif #Assessmenttoolsummarycnotes2.isubservicelist_ID# NEQ ''>
									<cfquery name="Assessmenttoolsummarysubdescription" dbtype="query">
									   Select distinct truncatedsubdescription,fsubweight,iselectedservice from sp_AssessmentToolSummary 
									   where isubservicelist_ID= #Assessmenttoolsummarycnotes2.isubservicelist_ID#
									   AND iselectedservice is not null
									</cfquery>
									<cfloop query="Assessmenttoolsummarysubdescription">
										<tr>
											<td style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; font-weight:normal;margin-left:5em" >
											 <!---<cfoutput> #Assessmenttoolsummarycnotes2.iSelectedService# </cfoutput>--->
											 <!---<cfscript>
												 checkbox = 'U+2610';
											 </cfscript>
											<cfset checkbox= chr(9744)>
											 <cfset checkboxchecked= chr(8855)>--->
											 <cfif #Assessmenttoolsummarysubdescription.iSelectedService# eq 1>
											 [X]
											 <cfelse>  
											 [ ]
											  </cfif>   
												 #Assessmenttoolsummarysubdescription.truncatedsubdescription#  (#Assessmenttoolsummarysubdescription.fsubweight# points) 
											</td>
										 <tr>
									</cfloop> <!--- <cfloop query="Assessmenttoolsummarysubdescription">  --->  	
								 </cfif> <!--- <cfif #Assessmenttoolsummarycnotes.isubservicelist_ID# NEQ ''> --->
							</cfloop> <!--- <cfloop query="Assessmenttoolsummarycnotes2">  --->	  
						</cfif>	<!--- <cfif service_level != #AssessmentToolSummaryservicelevel.cTruncatedDescription#>	 --->  
											
					</cfloop> <!--- <cfloop query="AssessmentToolSummaryservicelevel"> --->	
				  
			</cfloop> <!--- <cfloop query="selectservicecategory"> --->
	   	</table>
	</div>	
	</cfoutput>		
   </cfsavecontent>
 <cfsavecontent variable="PDFhtml2">
	<cfoutput>
		<table width="95%"  cellspacing="2" cellpadding="2" style="page-break-before:always">
					<tr> 
					   <td style="text-align:center; font-family: Arial, Helvetica, sans-serif; font-size:14px">
							<b>Service Plan Information</b></td> 
					</tr> 
					
			</table>
			 <div>
			<table width="75%"  cellspacing="2" cellpadding="2" style="float: left;">
					<tr> 
					   <td width="25%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px;">
							<b>Primary Diagnosis :</b>
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							#sp_assessmenttoolsummary.iPrimary#
						</td> 
					</tr> 
					<tr> 
					   <td width="25%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Secondary Diagnosis :</b>
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							#sp_assessmenttoolsummary.iSecondary#
						</td> 
					</tr> 
					<tr> 
					   <td width="25%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Third Diagnosis :</b> 
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							#sp_assessmenttoolsummary.iThird#
						</td> 
					</tr> 
			        <tr> 
					   <td width="25%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Fourth Diagnosis :
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							</b>#sp_assessmenttoolsummary.ifourth#
						</td> 
					</tr> 
			        <tr> 
					   <td width="25%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Fifth Diagnosis :</b> 
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							#sp_assessmenttoolsummary.iFifth#
						</td> 
					</tr> 
			        <tr> 
					   <td width="20%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Sixth Diagnosis : </b>
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							#sp_assessmenttoolsummary.isixth#</td> 
					</tr> 
			        <tr> 
					   <td width="20%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Seventh Diagnosis :</b> 
						</td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						#sp_assessmenttoolsummary.iSeventh#</td> 
					</tr> 
					
					 
					
					
		</table>
		<table width="25%"  cellspacing="2" cellpadding="2" style="float: right;">
					<tr> 
					   <td style="text-align:right; font-family: Arial, Helvetica, sans-serif; font-size:12px">
							<b>Status Code :</b> #sp_assessmenttoolsummary.cstatus# </td> 
					</tr> 
		</table>
		
    	</div>	
	<div>
	<table  width="95%"  cellspacing="2" cellpadding="2">
				    <tr> 
					   <td  width="20%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; vertical-align:top">
							<b>Diagnosis </b></td> 
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px"> #REReplace(sp_assessmenttoolsummary.tDiagnosis, Chr(10), "<br>", "ALL")#</td>
					</tr> 
					<tr> 
						<td width="20%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px;vertical-align:top">
							<b>Other Services </b> </td>
						<td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px"> #REReplace(sp_assessmenttoolsummary.tOtherservices, Chr(10), "<br>", "ALL")#</td> 
					</tr> 
					<tr> 
					   <td width="20%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; vertical-align:top">
							<b>Allergies </b> </td>
					  <td width="80%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">#REReplace(sp_assessmenttoolsummary.tallergies, Chr(10), "<br>", "ALL")#</td> 
					</tr> 
					<tr><td>&nbsp;</td></tr>
				    <tr><td>&nbsp;</td></tr>  
	</table>			
	</div>
	
	<div style="width:95%;clear: both">
	   	<table width="95%" >	
				  <tr><td>&nbsp;</td></tr>
				  <tr><td>&nbsp;</td></tr>
		         <tr> 
					<td style="text-align:centre; font-family: Arial, Helvetica, sans-serif; font-size:12px; ">
						<!---  <b>I understand that the above price information is based on information given at the time of assessment and may be 
						  modified based upon physician's orders and/or assessment completed at move-in</b>  --->
                    </td> 
				</tr> 
				 <tr>
					 <td  style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp; <br>&nbsp;</br> 
					</td> 
						
				</tr> 	
		</table>
		<table width="95%">	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td>
						 <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td>  
					</tr> 
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Resident or Responsible Party  </td> 
						<td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Date  </td> 
					</tr> 	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td> 
						 <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td> 
					</tr> 	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Director or Designee  </td> 
						<td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Date  </td> 
					</tr> 	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td> 
						 <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td> 
					</tr> 	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Nurse (if required by state regulations)  </td> 
						<td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Date  </td> 
					</tr> 	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td> 
						 <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px; border-bottom:1px solid black;">
						&nbsp;  </td> 
					</tr> 	
					<tr>
					   <td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Additional Staff (if required by state regulations)  </td> 
						<td width="50%" style="text-align:left; font-family: Arial, Helvetica, sans-serif; font-size:12px">
						Date  </td> 
					</tr> 	
	        </table>
	 </div>
</cfoutput> 
 	</body>
</cfsavecontent>	

<cfdocument format="PDF" orientation="portrait" margintop="1" marginbottom="1">
<!---<cfdocumentitem type="header">
 <table width="100%" >	
	<tr>
		<td>
			<div  style="text-align:left;">
				<img src="../../images/Enlivant_logo.jpg"  height="300"  width="450"  />
			</div>
		</td>
	</tr>
</table>
</cfdocumentitem>--->
<cfdocumentitem type="header" evalAtPrint="true">
	<cfif cfdocument.currentpagenumber eq 1>
		<cfoutput>
			<table width="95%"  cellspacing="0" cellpadding="0" style="border-bottom:1px solid black; margin:0px;">
						<tr> <td style="font-family: Arial, Helvetica, sans-serif; font-size:17px; text-align:center; font-weight:bolder;">
						Assessment and Negotiated Service Plan Summary </td> <tr>
						<tr> <td> &nbsp;</td></tr>

			</table>
		</cfoutput>
	<cfelseif cfdocument.currentpagenumber eq cfdocument.totalpagecount>
		<cfoutput>
			<table width="95%" style="margin:0px;" >
						<tr> <td style="font-family: Arial, Helvetica, sans-serif; font-size:17px; text-align:center; font-weight:bolder;">
						Assessment and Negotiated Service Plan Summary </td> <tr>
						<tr> <td> &nbsp;</td></tr>
			</table>
			<table  width="95%" style="border-bottom:1px solid black;margin:0px;">
				<tr>
					<td style="font-family: Arial, Helvetica, sans-serif; font-size:12px; text-align:left; font-weight:bolder;">
						#sp_assessmenttoolsummary.csolomonkey# &nbsp;&nbsp;#sp_assessmenttoolsummary.cFirstname# #sp_assessmenttoolsummary.clastname#
					</td>
					<td style="font-family: Arial, Helvetica, sans-serif; font-size:12px; text-align:right; font-weight:bolder;">	
						Review Range : #DATEFORMAT(sp_assessmenttoolsummary.dtReviewstart, "mm/dd/yyyy")# - #DATEFORMAT(sp_assessmenttoolsummary.dtreviewend, "mm/dd/yyyy")#
					</td>
				</tr>
			</table>
		</cfoutput>
	<cfelse>
		<cfoutput>
			<table width="95%" cellspacing="0" cellpadding="0" style="margin:0px;">
						<tr> <td style="font-family: Arial, Helvetica, sans-serif; font-size:17px; text-align:center; font-weight:bolder;">
						Assessment and Negotiated Service Plan Summary </td> <tr>
						<tr> <td> &nbsp;</td></tr>
			</table>
			<table  width="95%" style="border-bottom:1px solid black;margin:0px;">
				<tr>
					<td style="font-family: Arial, Helvetica, sans-serif; font-size:12px; text-align:left; font-weight:bolder;">
						#sp_assessmenttoolsummary.csolomonkey# &nbsp;&nbsp;#sp_assessmenttoolsummary.cFirstname# #sp_assessmenttoolsummary.clastname#
					</td>
					<td style="font-family: Arial, Helvetica, sans-serif; font-size:12px; text-align:right; font-weight:bolder;">	
						Review Range : #DATEFORMAT(sp_assessmenttoolsummary.dtReviewstart, "mm/dd/yyyy")# - #DATEFORMAT(sp_assessmenttoolsummary.dtreviewend, "mm/dd/yyyy")#
					</td>
				</tr>
			</table>
			<table  width="95%" style="margin:0px;" >
				<tr>
					<td style="font-family: Arial, Helvetica, sans-serif; font-size:12px; text-align:center; font-weight:bolder;">
						<b>Service Categories</b>
					</td>
				</tr>
			</table>
		</cfoutput>
	</cfif>
</cfdocumentitem>
<cfoutput>
		#variables.PDFhtml#
		<cfdocumentitem type="pagebreak"></cfdocumentitem>
		#variables.PDFhtml2#  	  	
</cfoutput>
    <cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			<div style="text-align:right;font-size:11px;">
			<br>Printed #DATEFORMAT(now(), "mm/dd/yyyy")# #TimeFormat(Now())#</br>
			<br>Page:#cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</br>
			</div>
		</cfoutput>
	</cfdocumentitem>
</cfdocument>

