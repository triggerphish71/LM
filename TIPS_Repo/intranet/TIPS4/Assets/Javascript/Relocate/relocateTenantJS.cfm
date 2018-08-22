<!--- this document contains a mixture of Coldfusion and Javascript. Need to spearate the two languages
		and make the functions pure javascript
---->

<cfoutput>
<SCRIPT>

function recurr(obj,apt){
		//set a variable equal to the selected tenants charge set
		var chargeSet = GetChargeSetForTenant();

		//mstriegel 11/21/17 added line below
		window.goingtoApt = apt.value;
		//end mstriegel 11/21/17

		//holds the residency type id
		res="";
		//holds the billingtype
		billing="";
		//holds the house number
		house="";
		productline="";
		originaltenant="";
		iaptID = "";
		occupancy = "";

		//mstriegel 11/21/17 added below
		window.hasbundledPricing = "";
		window.bIsStudio = "";
		// end mstriegel 11/21/17

		<CFLOOP QUERY='Tenantlist'>
			<CFIF tenantlist.currentrow eq 1>
				if (obj.value == #tenantlist.itenant_id#)
				{
					res=#tenantlist.iresidencytype_id#;
					billing= "#tenantlist.cbillingtype#";
					house=#tenantlist.ihouse_ID#;
					productline=#tenantlist.iproductline_ID#;
					originaltenant="#tenantlist.bIsOriginalTenant#";
					iaptID = "#tenantlist.iAptAddress_id#";
					//mstriegel 11/21/17
					window.hasBundledPricing="#tenantList.bIsbundledPricing#";
					window.bIsStudio = "#tenantlist.isStudio#";
					//end mstriegel

				}
			<CFELSE>
				else if (obj.value == #tenantlist.itenant_id#)
				{
					res=#tenantlist.iresidencytype_id#;
					billing= "#tenantlist.cbillingtype#";
					house=#tenantlist.ihouse_ID#;
					productline=#tenantlist.iproductline_ID#;
					originaltenant="#tenantlist.bIsOriginalTenant#";
					iaptID = "#tenantlist.iAptAddress_id#";
					//mstriegel 11/21/17 added below
					window.hasBundledPricing="#tenantList.bIsbundledPricing#";
					window.bIsStudio = "#tenantlist.IsStudio#";
					// end mstriegel 11/21/17
				}
			</CFIF>
		</CFLOOP>

		document.getElementById("icurrentroomID").value = iaptID;
		//this will hold the html for the reoccuring charge found for a tenant
		var z = '';
		//this will hold the html for the charge price for the room
		var c = '';
       //if there is no charge displayed hide the recurringcharge area
		if (obj.value == "")
		{
			document.all['recurringchange'].style.display="none";
			return false;
		}

		//clear the reoccuringcharge section html
		//alert('test')
		//document.forms[0].iAptNum.options.length=0;
		document.all['recurringchange'].innerHTML='';
		//clear apttype section
		//document.forms[0].iAptNum.value = '';
		//Mshah document.all['recurringchange'].innerHTML='';
		<!--- loop through the recurring charge query and show the matching charge on the page --->
		<CFLOOP QUERY='qRecurring'>
			<CFIF qRecurring.currentrow eq 1>
				if (obj.value == #qRecurring.itenant_id#)
				{  //alert('test2')
					document.all['recurringchange'].style.display="inline";
					z="<B> <U>Recurring Charge was found for:</U> <BR> #qRecurring.cdescription# at #LSCurrencyFormat(isBlank(qRecurring.mAmount,0))# </B> <BR>";
					z+="<INPUT TYPE=hidden NAME='irecurringcharge_id' VALUE='#qRecurring.irecurringcharge_id#'>";
				}
			<CFELSE>
				else if (obj.value == #qRecurring.itenant_id#)
				{   //alert('test2')
					document.all['recurringchange'].style.display="inline";
					z="<B> <U>Recurring Charge was found for:</U> <BR> #qRecurring.cdescription# at #LSCurrencyFormat(isBlank(qRecurring.mAmount,0))# </B> <BR>";
					z+="<INPUT TYPE=hidden NAME='irecurringcharge_id' VALUE='#qRecurring.irecurringcharge_id#'>";
				 }
			</CFIF>
		</CFLOOP>
	   //if residency selected is 2 then display same the recurring charges, Mamta

		if (res == 2){
			<CFLOOP QUERY='qRecurring'>
				<CFIF qRecurring.currentrow eq 1>
					if (obj.value == #qRecurring.itenant_id#)
					{
						document.all['recurringchange'].style.display="inline";
						 c="<B><I STYLE='color: red;'>Change to #qRecurring.cdescription# $ ";
				         c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qRecurring.mAmount,'999999.00-'))#' \
						    STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>"; <!---mshah removed read only--->
				        c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qRecurring.icharge_id#'>";
					}
				<CFELSE>
					else if (obj.value == #qRecurring.itenant_id#)
					{
					 c="<B><I STYLE='color: red;'>Change to #qRecurring.cdescription# $ ";
				         c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qRecurring.mAmount,'999999.00-'))#' \
						    STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
				        c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qRecurring.icharge_id#'>";
					 }
				</CFIF>
		    </CFLOOP>
		}
		//mshah start  medicaid end, private start
		//buiding have mixed AL type, monthly and daily
		//put the condition here for bigsprings which has monthly and daily AL charges <!--- loop though the avaliable charges query and diaplay the charge in the text box --->
		else if (house >= 247) {
            <cfloop QUERY='Available'>
			   	<CFIF Available.currentrow eq 1>
					if (apt.value == #Available.iAptAddress_ID#){
						occupancy =#Available.Occupancy#;
						iscompanion =#Available.bIsCompanionsuite#;
				    	ismemorycare=#Available.BISMEMORYCAREELIGIBLE#;
				    }
			    <CFELSE>
					else if (apt.value == #Available.iAptAddress_ID#){
					 	occupancy =#Available.Occupancy#;
				 		iscompanion =#Available.bIsCompanionsuite#;
						ismemorycare=#Available.BISMEMORYCAREELIGIBLE#;
					}
				</cfif>
		    </cfloop>

		    if (occupancy == 0||iscompanion == 1 ){   //Mshah added here primary and companion

	            if (billing == 'M'){ //monthly primary or monthly companion
            	    <CFLOOP QUERY='WinthropAptMonthly'>
						<cfif cChargeSet eq "">
							<cfset currentChargeSet = "null">
						<cfelse>
							<cfset currentChargeSet = lcase(cChargeSet)>
						</cfif>
						<CFIF WinthropAptMonthly.currentrow eq 1>
							if (apt.value == #isBlank(WinthropAptMonthly.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')

							{
								document.all['recurringchange'].style.display="inline";
								c="<B><I STYLE='color: red;'>Change to #WinthropAptMonthly.cdescription# $ ";
								c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptMonthly.mAmount,'999999.00-'))#' \
									STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
								c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptMonthly.icharge_id#'>";
							}
						<CFELSE>
							else if (apt.value == #isBlank(WinthropAptMonthly.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
							{
								document.all['recurringchange'].style.display="inline";
								c="<B><I STYLE='color: red;'>Change to #WinthropAptMonthly.cdescription# $ ";
								c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptMonthly.mAmount,'999999.00-'))#' \
								STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
								c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptMonthly.icharge_id#'>";
							}
						</CFIF>
					</CFLOOP>
	            }
		        else if (billing == 'D'){ // daily primary or daily companion

        	        <CFLOOP QUERY='WinthropAptDaily'>
	    				<cfif cChargeSet eq "">
	    					<cfset currentChargeSet = "null">
	    				<cfelse>
	    					<cfset currentChargeSet = lcase(cChargeSet)>
	    				</cfif>
	    				//chargetype= "";


	    				<CFIF WinthropAptMonthly.currentrow eq 1>
	    					if (apt.value == #isBlank(WinthropAptDaily.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#'){
	    						document.all['recurringchange'].style.display="inline";
	    						c="<B><I STYLE='color: red;'>Change to #WinthropAptDaily.cdescription# $ ";
	    						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptDaily.mAmount,'999999.00-'))#' \
	    							STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
	    						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptDaily.icharge_id#'>";
	    					}
	    				<CFELSE>
	    					else if (apt.value == #isBlank(WinthropAptDaily.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#'){
	    						document.all['recurringchange'].style.display="inline";
	    						c="<B><I STYLE='color: red;'>Change to #WinthropAptDaily.cdescription# $ ";
	    						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(WinthropAptDaily.mAmount,'999999.00-'))#' \
	    						STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
	    						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#WinthropAptDaily.icharge_id#'>";
	    					}
	    				</CFIF>

	    			</CFLOOP>
		        }
		    }// if occupancy 0 end
	        else if (occupancy == 1 && iscompanion == 0 ){ //second resident AL daily or Monthly
				if (productline == 1 && ismemorycare == 0){
					if (billing == 'D'){
						<CFLOOP QUERY='qSecondRate'>
							<cfif cChargeSet eq "">
								<cfset currentChargeSet = "null">
							<cfelse>
								<cfset currentChargeSet = lcase(cChargeSet)>
							</cfif>
							<CFIF qSecondRate.currentrow eq 1>
								if (chargeSet.toLowerCase() == '#currentChargeSet#')
								{
								//	alert('test seond')//Mshah
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
										STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
								}
							<CFELSE>
								else if (chargeSet.toLowerCase() == '#currentChargeSet#')
								{
								//	alert('test seond')//Mshah
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
									STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>"; <!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
								}
							</CFIF>
						</CFLOOP>
					} //if close
					else if (billing == 'M'){
				    	<CFLOOP QUERY='qSecondRateALMonthly'>
							<cfif cChargeSet eq "">
								<cfset currentChargeSet = "null">
							<cfelse>
								<cfset currentChargeSet = lcase(cChargeSet)>
							</cfif>
							<CFIF qSecondRateALMonthly.currentrow eq 1>
								if (chargeSet.toLowerCase() == '#currentChargeSet#')
								{
									//	alert('test seond')//Mshah
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
										STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
								}
							<CFELSE>
								else if (chargeSet.toLowerCase() == '#currentChargeSet#')
								{   //alert('test second')//Mshah
									document.all['recurringchange'].style.display="inline";
									c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
									c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
									STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
									c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
								}
							</CFIF>
						</CFLOOP>
			    	} // else if close
			}//if end productline
			else if ((productline == 1 && ismemorycare == 1) || productline == 2 ){ //Second resident MC Mshah added here for AL to MC room //Second resident MC
			    <CFLOOP QUERY='qSecondRateMC'>
					<cfif cChargeSet eq "">
						<cfset currentChargeSet = "null">
					<cfelse>
						<cfset currentChargeSet = lcase(cChargeSet)>
					</cfif>
					<CFIF qSecondRateMC.currentrow eq 1>
						if (chargeSet.toLowerCase() == '#currentChargeSet#'){
							document.all['recurringchange'].style.display="inline";
							c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
							c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
								STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
							c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
						}
					<CFELSE>
						else if (chargeSet.toLowerCase() == '#currentChargeSet#'){
							document.all['recurringchange'].style.display="inline";
							c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
							c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
							STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
							c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
						}
					</CFIF>
				</CFLOOP>
			}// else if close
    	}//else second resident end
	} //mshah end house 247
	else{ //if not original tenant
	   	<!---loop for occupancy veriable--->
	    <cfloop QUERY='Available'>
			<CFIF Available.currentrow eq 1>
				if (apt.value == #Available.iAptAddress_ID#){
					occupancy =#Available.Occupancy#;
					iscompanion =#Available.bIsCompanionsuite#;
					ismemorycare = #Available.BISMEMORYCAREELIGIBLE#;
				}
		    <CFELSE>
				else if (apt.value == #Available.iAptAddress_ID#){// alert (apt.value);
					occupancy =#Available.Occupancy#;
					//alert(occupancy);
					iscompanion =#Available.bIsCompanionsuite#;
					//alert(iscompanion);
					ismemorycare = #Available.BISMEMORYCAREELIGIBLE#;
				}
			</cfif>
		</cfloop>
    if (occupancy == 0||occupancy == 1  && iscompanion == 1 ){
    	//alert('test'); // not original daily or monthly tenant
		<!--- loop though the avaliable charges query and diaplay the charge in the text box --->
		<CFLOOP QUERY='Available'>
			<cfif cChargeSet eq "">
				<cfset currentChargeSet = "null">
			<cfelse>
				<cfset currentChargeSet = lcase(cChargeSet)>
			</cfif>

			<CFIF Available.currentrow eq 1>
				if (apt.value == #isBlank(Available.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
				{
					document.all['recurringchange'].style.display="inline";
					c="<B><I STYLE='color: red;'>Change to #Available.cdescription# $ ";
					c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(Available.mAmount,'999999.00-'))#' \
						STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
					c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#Available.icharge_id#'>";
				}
			<CFELSE>
				else if (apt.value == #isBlank(Available.iAptAddress_ID,0)# && chargeSet.toLowerCase() == '#currentChargeSet#')
				{
					document.all['recurringchange'].style.display="inline";
					c="<B><I STYLE='color: red;'>Change to #Available.cdescription# $ ";
					c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(Available.mAmount,'999999.00-'))#' \
					STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
					c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#Available.icharge_id#'>";
				}
			</CFIF>
		</CFLOOP>

    else {
		document.all['recurringchange'].style.display="none";
	}//end here if apt.value
 }//if ends occupancy 0

else if (occupancy == 1 && iscompanion == 0 ){ //not original second
	if (productline == 1 && ismemorycare== 0){ //AL second  // AL relocate to AL second resident
    	if (billing == 'D'){
		    <CFLOOP QUERY='qSecondRate'>
				<cfif cChargeSet eq "">
					<cfset currentChargeSet = "null">
				<cfelse>
					<cfset currentChargeSet = lcase(cChargeSet)>
				</cfif>
				<CFIF qSecondRate.currentrow eq 1>
					if (chargeSet.toLowerCase() == '#currentChargeSet#'){
						//alert(b +' will be second occupant and occupancy will be zero test 1')<!--- alert added by Tpecku --->
						document.all['recurringchange'].style.display="inline";
						c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
							STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
					}
				<CFELSE>
				// var tenantvalue = document.getElementById("Ten1").value;
					else if (chargeSet.toLowerCase() == '#currentChargeSet#'){
						//alert(b +' will be second occupant and occupancy will be zero test2 ')<!--- alert added by Tpecku --->
						document.all['recurringchange'].style.display="inline";
						c="<B><I STYLE='color: red;'>Change to #qSecondRate.cdescription# $ ";
						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRate.mAmount,'999999.00-'))#' \
						STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRate.icharge_id#'>";
					}
				</CFIF>
			</CFLOOP>
        } //if close
    	else if (billing == 'M'){//Al monthly second
    	   	<CFLOOP QUERY='qSecondRateALMonthly'>
				<cfif cChargeSet eq "">
					<cfset currentChargeSet = "null">
				<cfelse>
					<cfset currentChargeSet = lcase(cChargeSet)>
				</cfif>

				<CFIF qSecondRateALMonthly.currentrow eq 1>
					if (chargeSet.toLowerCase() == '#currentChargeSet#')
					{
						document.all['recurringchange'].style.display="inline";
						c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
							STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
					}
				<CFELSE>
					else if (chargeSet.toLowerCase() == '#currentChargeSet#')
					{
						document.all['recurringchange'].style.display="inline";
						c="<B><I STYLE='color: red;'>Change to #qSecondRateALMonthly.cdescription# $ ";
						c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateALMonthly.mAmount,'999999.00-'))#' \
						STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
						c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateALMonthly.icharge_id#'>";
					}
				</CFIF>
			</CFLOOP>
    	} // else if close
    }//if end productline
    else if (productline == 2){ //MC second
    	<CFLOOP QUERY='qSecondRateMC'>
			<cfif cChargeSet eq "">
				<cfset currentChargeSet = "null">
			<cfelse>
				<cfset currentChargeSet = lcase(cChargeSet)>
			</cfif>

			<CFIF qSecondRateMC.currentrow eq 1>
				if (chargeSet.toLowerCase() == '#currentChargeSet#'){
					document.all['recurringchange'].style.display="inline";
					c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
					c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
						STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
					c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
				}
			<CFELSE>
				else if (chargeSet.toLowerCase() == '#currentChargeSet#'){
					document.all['recurringchange'].style.display="inline";
					c="<B><I STYLE='color: red;'>Change to #qSecondRateMC.cdescription# $ ";
					c+="<INPUT TYPE=text NAME='Recurring_mAmount' SIZE=8 VALUE='#trim(LSNumberFormat(qSecondRateMC.mAmount,'999999.00-'))#' \
					STYLE='text-align: right; color: red; font-weight: bold; italic;' onkeypress='return numbers(event)' onBlur='this.value=Money(this.value); this.value=cent(round(this.value));'></I></B>";<!---mshah removed read only--->
					c+="<INPUT TYPE=hidden NAME='newcharge' VALUE='#qSecondRateMC.icharge_id#'>";
				}
			</CFIF>
		</CFLOOP>
    }// else if close
}//else if close
	document.all['recurringchange'].innerHTML=z+c;
}
document.all['recurringchange'].innerHTML=z+c;
}

function Selectedtenantmedicaid(obj)
 {
		
	document.forms[0].iAptNum.options.length=0;
	<CFLOOP QUERY='Tenantlist'>
	<CFIF tenantlist.currentrow eq 1>
		if (obj.value == #tenantlist.itenant_id#)
		{
			res=#tenantlist.iresidencytype_id#;
			productline=#tenantlist.iproductline_ID#;
			iaptID = "#tenantlist.iAptAddress_id#";
		}
	<CFELSE>
		else if (obj.value == #tenantlist.itenant_id#)
		{
			res=#tenantlist.iresidencytype_id#;
			productline=#tenantlist.iproductline_ID#;
			iaptID = "#tenantlist.iAptAddress_id#";
		}
	</CFIF>
	</CFLOOP>
	
		if (productline==1){
			if (res==2){
				for (var i = 0; i < document.forms[0].iAptNum2.options.length; i++) {
					document.forms[0].iAptNum.options[i] = new Option(document.forms[0].iAptNum2.options[i].text, document.forms[0].iAptNum2.options[i].value);
			    }
			}
		    else{
				for (var j = 0; j < document.forms[0].iAptNum3.options.length; j++)	{  
					document.forms[0].iAptNum.options[j] = new Option(document.forms[0].iAptNum3.options[j].text,document.forms[0].iAptNum3.options[j].value);
				}
		    }
	    }
		else {
			for (var i = 0; i < document.forms[0].iAptNum4.options.length; i++){
				document.forms[0].iAptNum.options[i] = new Option(document.forms[0].iAptNum4.options[i].text, document.forms[0].iAptNum4.options[i].value);
	     	}
		}
}

function effectivevalidate(){
	today = new Date(#Year(TimeStamp)#,#Evaluate(Month(TimeStamp)-1)#,#Day(TimeStamp)#);
	effday = document.forms[0].Day.value;
	effmonth = document.forms[0].Month.value -1;
	effyear = document.forms[0].Year.value;
	effdate = new Date(effyear,effmonth,effday);
	<!---	<CFIF remote_addr eq '10.1.0.211'>--->
		today= new Date();
		difference = effdate.getTime() - today.getTime();
    	daysDifference = Math.floor(difference/1000/60/60/24) + 1;
	//	alert(daysDifference);
	<!--- </CFIF> --->
	if (effdate > today){
		alert('Relocations may not be entered for future dates..');
		document.forms[0].Month.value = #Month(TimeStamp)#; document.forms[0].Day.value = #Day(TimeStamp)#; document.forms[0].Year.value = "";
		//Mshah
		return false;
	}
}

function backvalidate(){
	today = new Date(#Year(TimeStamp)#,#Evaluate(Month(TimeStamp)-1)#,#Day(TimeStamp)#);
	effday = document.forms[0].Day.value;
	//Mshah
		datedifference = today.getTime() - effdate.getTime();
    	actualDiff = Math.floor(datedifference/1000/60/60/24) + 1;
		//alert(actualDiff);

	if (actualDiff > 60){
		alert('Relocations may not be entered more than 60 days back..');
		document.forms[0].Month.value = #Month(TimeStamp)#; document.forms[0].Day.value = #Day(TimeStamp)#;document.forms[0].Year.value = "";
		return false;
	}
}




</script>
</cfoutput>