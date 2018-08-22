<!--- *******************************************************************************
Name:			HouseApts.cfm
Process:		Display Houses current apartments and re-assign the apt type

Called by: 		Admin/Menu.cfm
Calls/Submits:	HouseAptTypeChange.cfm, DeleteApt.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Paul Buendia            02/08/2002      Original Authorship
******************************************************************************** --->

<!--- ==============================================================================
Retrieve list of apartments and their types//mamta-added biscomapnion suite
//mamta added AD.bIsMedicaidEligible//mamta added AD.bIsMemoryCareEligible//
//mstriegel:11/13/2017 added logic for bundled pricing and no lock to all queries //
//mstriegel:12/20/2017 added fix for medicaid checkbox                            //
=============================================================================== --->
<CFQUERY NAME="qGetHouseApts" DATASOURCE="#APPLICATION.datasource#">
	SELECT	AD.iAptAddress_ID, AD.iAptType_ID, AD.cAptNumber, AD.dtRowStart,
			 AP.cDescription,AP.bIsCompanionSuite,AD.bIsMedicaidEligible,AD.bIsMemoryCareEligible
	FROM	AptAddress AD WITH (NOLOCK)
	JOIN	AptType AP WITH (NOLOCK) ON	(AP.iAptType_ID = AD.iAptType_ID AND AP.dtRowDeleted IS NULL)
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		AD. dtRowDeleted IS NULL
	ORDER BY cAptNumber
</CFQUERY>
<!--- ==============================================================================
Retrieve if house is medicaid mamta-added BisMemoryCare
=============================================================================== --->
<CFQUERY NAME="qGetHouseMedicaid" DATASOURCE="#APPLICATION.datasource#">
	SELECT	bIsMedicaid,bIsMemorycare
	FROM	house WITH (NOLOCK)
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
	AND		dtRowDeleted IS NULL
</CFQUERY>

<!--- ==============================================================================
RetrieveList of possible ApartmentTypes
=============================================================================== --->
<CFQUERY NAME="qAptTypes" DATASOURCE="#APPLICATION.datasource#">
	SELECT	*
	FROM	AptType WITH (NOLOCK)
	WHERE	dtRowDeleted IS NULL
	ORDER BY iDisplayOrder
</CFQUERY>
<!--- mstriegel 11/13/17 added --->
<cfquery name="qHasBundledPricing" datasource="#application.datasource#">
	SELECT bIsBundledPricing
	FROM house with (NOLOCK)
	WHERE iHouse_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#SESSION.qSelectedHouse.iHouse_ID#">
</cfquery>

<cfquery name="qGetStudioList" datasource="#application.datasource#">
	SELECT apt.iAptType_ID
	FROM AptType apt WITH (NOLOCK)
	WHERE cDescription like '%studio%'
</cfquery>
<!--- end mstriegel --->

<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../header.cfm">

<CFOUTPUT>
<DIV>
<TABLE>
	<TR><TD COLSPAN=100% STYLE="background: white;"><A HREF="../../Admin/Menu.cfm" STYLE="font-size: 18;">	Return to Administration Page. </A></TD></TR>
	<TR><TD COLSPAN=100% STYLE="background: white;"><B STYLE="font-size: 20;">#SESSION.HouseName#</BR></TD></TR>
	<TR><TD COLSPAN=100% STYLE="background: white;"><BR><A HREF="NewApt.cfm" STYLE="font-size: 16;"> <B>Add New Apartment</B> </A></TD></TR>	
	<TR><TD COLSPAN=100% STYLE="background: white; font-size: 16;"><B STYLE="color: red;">Please, note each change must be submitted seperately.</B><BR><font size=-1><i>Click on Apt Number to edit that apartment's details.</i></font></TD></TR>
	<TR>
		<TH>Number	</TH>
		<TH NOWRAP>Current Type</TH>
		<cfif qGetHouseMedicaid.bIsMedicaid eq 1>
		<TH>Medicaid Eligible</TH>
		</cfif>
		<cfif qGetHouseMedicaid.bIsMemoryCare eq 1>
		<TH>Memory Care Eligible</TH>
		</cfif>
		<TH>New Type </TH>
		<TH>Last Changed</TH>
		<TH NOWRAP>Submit Change</TH>
		<TH>Delete Apartment</TH>
	</TR>
	<!--- mstriegel:11/13/2017 bundled pricing --->
	<script type="text/javascript">      
        var convertToList = [<cfoutput>#valueList(qGetStudioList.iAptType_ID)#</cfoutput>];       
	</script>
	<!---- end mstriegel:11/13/2017 --->

	<CFLOOP QUERY='qGetHouseApts'>
		<FORM NAME="Form#qGetHouseApts.iAptAddress_ID#" ACTION="HouseAptTypeChange.cfm" METHOD="POST">
			<!--- mstriegel:11/14/2017 ---->
			<input type="hidden" id="hasBundledPricing#qGetHouseApts.currentRow#" name="hasBundledPricing" value="#qHasBundledPricing.bIsBundledPricing#">
			<!--- end mstreigel:11/14/2017 ---->
        	<SCRIPT> 
        		<!--- mstriegel:11/13//2017 --->
        		function checkifStudio(id){
        			for(i=0; i <= convertToList.length; i++){
        				if(id == convertToList[i]){
        					return true;
        				}
        			}        			
        			return false;        			
        		}
        		<!---end: mstriegel:11/13/2017 --->
				
				function activatebutton#qGetHouseApts.currentrow#(string){ 
					<!--- mstriegel:11/13//2017 --->
					nval = "getCurrent#qGetHouseApts.currentrow#";
					isStudio = document.getElementById(nval).value;
					
						elem = 'hasBundledPricing#qGetHouseApts.currentrow#';
						theElem = document.getElementById(elem);
						currentType = isStudio.indexOf("Studio");
						
        			
						<cfif qHasBundledPricing.bIsbundledPricing EQ 1>
							if(currentType == -1 && checkifStudio(string.value) == true){
								theElem.value=1;
								alert("Bundled Pricing is available for this apartment type.");
							}
							if(currentType != -1 && checkifStudio(string.value) == false){
								theElem.value='0';
								alert("Bundled pricing WILL NOT be available for this apartment type.");
							}					
						</cfif>
					<!--- end mstriegel:11/13/2017 --->

					if (string.value !== 'none')  {
						document.all['Layer#qGetHouseApts.currentrow#'].style.visibility = 'visible';
						document.Form#qGetHouseApts.iAptAddress_ID#.Delete#qGetHouseApts.iAptAddress_ID#.style.visibility = 'hidden';
					}
					else {
						document.all['Layer#qGetHouseApts.currentrow#'].style.visibility = 'hidden';
						document.Form#qGetHouseApts.iAptAddress_ID#.Delete#qGetHouseApts.iAptAddress_ID#.style.visibility = 'visible';	
					}
				}
				//mamta added for medicaid project
				function activatebuttonChk#qGetHouseApts.currentrow#(string){ 				
					
					if (document.all['Layer#qGetHouseApts.currentrow#'].style.visibility == 'visible')
					{
						document.all['Layer#qGetHouseApts.currentrow#'].style.visibility = 'hidden';
						document.Form#qGetHouseApts.iAptAddress_ID#.Delete#qGetHouseApts.iAptAddress_ID#.style.visibility = 'visible';	
					}
					else{
						document.all['Layer#qGetHouseApts.currentrow#'].style.visibility = 'visible';
						document.Form#qGetHouseApts.iAptAddress_ID#.Delete#qGetHouseApts.iAptAddress_ID#.style.visibility = 'hidden';
					}
					}					
			</SCRIPT>
			<!---<cfoutput> #qGetHouseApts.currentrow# </cfoutput>--->
			<!---mamta- added variable to submit form for companionswitch enhancement--->
			<INPUT TYPE="Hidden" NAME="bIsCompanionSuite" VALUE="#qGethouseApts.bIsCompanionSuite#">
			<!---end--->
			<INPUT TYPE="Hidden" NAME="iAptAddress_ID" VALUE="#qGethouseApts.iAptAddress_ID#">
			<input type="hidden" id="getCurrent#qGetHouseApts.currentRow#" value="#cDescription#">
			
			<TR>
				<TD><A HREF="newapt.cfm?iAptAddress_ID=#qGetHouseApts.iAptAddress_ID#">#qGetHouseApts.cAptNumber#</A></TD>
				<TD NOWRAP>#qGetHouseApts.cDescription#</TD>
				   <!---mamta added for Medicaid project--->
				<cfif #Trim(qGetHouseMedicaid.bIsMedicaid)# eq 1>
				<TD NOWRAP>
					<cfif #Trim(qGetHouseApts.bIsMedicaidEligible)# eq 1>
				        <label>
				        <DIV ID="Chk#qGetHouseApts.currentrow#">
				        <!--- mstriegel 12/20/2017 fixed the typo for the field name --->	
						<INPUT TYPE="checkbox" NAME="bIsMedicaideligible" id="bIsMedicaideligible#qGetHouseApts.currentrow#" VALUE="#Trim(qGetHouseApts.bIsMedicaidEligible)#" checked="checked" onclick="activatebuttonChk#qGetHouseApts.currentrow#(this);">
						<!--- end mstriegel --->
						</DIV>
						</label>	
					<cfelse>
					    <label>
					    <DIV ID="Chk#qGetHouseApts.currentrow#">
						<INPUT TYPE="checkbox" NAME="bIsMedicaideligible" id="bIsMedicaideligible#qGetHouseApts.currentrow#" VALUE="#Trim(qGetHouseApts.bIsMedicaidEligible)#" onclick="activatebuttonChk#qGetHouseApts.currentrow#(this);"></label>
						</DIV>
					</cfif>
				</TD>
				</cfif>
				 <!---mamta added for MemoryCare project--->
				<cfif #Trim(qGetHouseMedicaid.bIsMemoryCare)# eq 1>
				<TD NOWRAP>
					<cfif #Trim(qGetHouseApts.bIsMemoryCareEligible)# eq 1>
				        <label>
				        <DIV ID="Chk#qGetHouseApts.currentrow#">
						<INPUT TYPE="checkbox" NAME="bIsMemoryCareEligible" VALUE="#Trim(qGetHouseApts.bIsMemoryCareEligible)#" checked="checked" onclick="activatebuttonChk#qGetHouseApts.currentrow#(this);">
						</DIV>
						</label>	
					<cfelse>
					    <label>
					    <DIV ID="Chk#qGetHouseApts.currentrow#">
						<INPUT TYPE="checkbox" NAME="bIsMemoryCareEligible" VALUE="#Trim(qGetHouseApts.bIsMemoryCareEligible)#" onclick="activatebuttonChk#qGetHouseApts.currentrow#(this);"></label>
						</DIV>
					</cfif>
				</TD>
				</cfif>
					<!---mamta end--->
				<TD NOWRAP>
					<SELECT NAME="NewAptType" STYLE="background: whitesmoke;" onChange="activatebutton#qGetHouseApts.currentrow#(this);">
						<OPTION VALUE="none">Choose Type</OPTION>
						<CFLOOP QUERY="qAptTypes">
							<CFIF Evaluate(qAptTypes.CurrentRow MOD 2) EQ 1><CFSET STYLE="Style='background: white;'"><CFELSE><CFSET STYLE=''></CFIF>
							<OPTION VALUE="#qAptTypes.iAptType_ID#" #STYLE#>#qAptTypes.cDescription#</OPTION>
						</CFLOOP>
					</SELECT>
				</TD>
				<TD NOWRAP>#DateFormat(qGetHouseApts.dtRowStart,"mm/dd/yyyy")# #TimeFormat(qGetHouseApts.dtRowStart,"hh:mm:ss tt")#</TD>
				<TD STYLE="text-align: center;">
					<DIV ID="Layer#qGetHouseApts.currentrow#">
						<INPUT TYPE="Button" NAME="Submitbutton#qGetHouseApts.currentrow#" Value="Change" onClick="submit();">
					</DIV>
				</TD>
				<SCRIPT>
					function RuSure#qGetHouseApts.iAptAddress_ID#(){
						//alert('running#qGetHouseApts.iAptAddress_ID#');
						if (confirm('Are you sure you want to permanently delete room number #qGetHouseApts.cAptNumber#?')){
							document.Form#qGetHouseApts.iAptAddress_ID#.action='DeleteApt.cfm';
							document.Form#qGetHouseApts.iAptAddress_ID#.submit();
						}
					}
				</SCRIPT>			
				<TD>
					<INPUT CLASS="BlendedButton" TYPE="Button" NAME="Delete#qGetHouseApts.iAptAddress_ID#" VALUE="Delete" onClick="RuSure#qGetHouseApts.iAptAddress_ID#();">
				</TD>
			</TR>
			<SCRIPT>document.all['Layer#qGetHouseApts.currentrow#'].style.visibility = 'hidden';</SCRIPT>
		</FORM>
	</CFLOOP>
</TABLE>

<A HREF="../../Admin/Menu.cfm" STYLE="font-size: 18;">	Return to Administration Page. </A>

<!--- ==============================================================================
Include Intranet Footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../../footer.cfm">
	
</CFOUTPUT>



