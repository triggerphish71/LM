<title>Collection Letters</title>

<cfif not isDefined("form.cSolomonKeyList")>

	<form action="collectionletter.cfm" method="post">
	ENTER in the Account numbers you want to generate Collection Letters for seperated by commas:<p>
	<input type="text" name="cSolomonKeyList" size="80"> <input type="submit" value="Submit">
	</p>
	</form>

<cfelseif isDefined("Form.cSolomonKeyList")>
			
	<!------------------------------------------------------------
	Steve, these are the values from sp_GetCollectionLetterInfo that you will use to populate the Crystal Report: 
	cFirstName (this is the bill to first name), 
	cLastName (this is the bill to last name), 
	cAddressLine1 (this is the bill to addy), 
	cAddressLine2 (this is the bill to addy2), 
	cCity (this is the bill to city), 
	cStateCode (this is the bill to state), 
	cZipCode (this is the bill to zip), 
	cSolomonKey (this is the account number), 
	TFirstName (this is the Resident's first name), 
	TLastName (this is the Resident's last name), 
	cName (this is the house name), 
	dtMoveIn (this is the Resident's Move in Date), 
	dtMoveOut (this si the Resident's Move out Date)
	
	You will also need to display the Total Balance Due on the Crystal Report, which can be gotten from this query:
	
			<CFQUERY NAME = "MovedOutCurrBal" DATASOURCE="SOLOMON-HOUSES" CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
				exec tips_GetCurrBal '#TRIM(form.cSolomonKey)#'
			</CFQUERY>
	---------------------------------------------------------------->
	
	<cfloop index="cSolomonKey" list="#form.cSolomonKeyList#">
	
		<cfquery name="sp_GetCollectionLetterInfo" datasource="#application.datasource#">
			EXEC sp_GetCollectionLetterInfo
			@cSolomonKey = '#TRIM(cSolomonKey)#'
		</cfquery>
		
		<!--- <strong>Test of output for Resident with Account Number <cfoutput>#cSolomonKey#</cfoutput></strong><p> --->
		
		<CFQUERY NAME = "MovedOutCurrBal" DATASOURCE="SOLOMON-HOUSES" CACHEDWITHIN="#CreateTimeSpan(0,0,5,0)#">
			EXEC tips_GetCurrBal '#TRIM(cSolomonKey)#'
		</CFQUERY>
		
		<cfoutput query="sp_GetCollectionLetterInfo">

		<table border=0 width=600><td>
		#DateFormat(Now(),'mmmm D, YYYY')#<p>
		
		#cFirstName# #cLastName#<BR>
		#cAddressLine1#<BR>
		<cfif cAddressLine2 is not "">#cAddressLine2#<BR></cfif>
		#cCity#, #cStateCode# #cZipCode#<p>
		
		Re:  Remaining past due balance, Account ## #cSolomonKey#<p>
	
		Dear #cFirstName# #cLastName#,<p>
		
		We would like to notify you of an outstanding balance due in the amount of #LSCurrencyFormat(MovedOutCurrBal.currbal)# arising from #TFirstName# #TLastName#'s former tenancy at the #cName# from #DateFormat(dtMoveIn,'M/D/YYYY')# to #DateFormat(dtMoveOut,'M/D/YYYY')#.  Enclosed you will find a copy of the Move Out Summary, which details the amount owed at the time of move out.  Please detach the bottom portion of this letter and send it with your payment using the provided envelope.
		<p>
		Unless you notify our collections department within 30 days after receiving this notice of any disputes concerning the validity of this debt or any portion thereof, Assisted Living Concepts Inc. will assume this debt is valid.  If you have any questions, concerns or disputes regarding the amount owed, please contact our collections department at 1-800-881-0678 extension 4079. It is important to give this matter your immediate attention to avoid further correspondence.
		<p>
		This is an attempt to collect a debt.  Any information obtained will be used for that purpose. If payment has been made, thank you and please disregard this notice.
		<p>
		Respectfully,
		<p>		
		
		Carlos Jimenez<BR>
		Credit Representative<BR>
		Collections Department<p>
		
		<hr>
		<center><i><font size=-1>Please fold on the line above, detach and return this portion with payment</font></i></center>
		<p>
		<Table border=0 with=600>
		<td width=300></td>
		<td align=right width=300>Resident Name #TFirstName# #TLastName#<BR>
		Account ## #cSolomonKey#<BR>
		#cName#<BR>
		Move-Out Date: #DateFormat(dtMoveOut,'M/D/YY')#<BR>
		<strong>TOTAL AMOUNT DUE: #LSCurrencyFormat(MovedOutCurrBal.currbal)#</strong></td>
		<tr><tr><tr><tr><tr><tr>
		<td align=left width=300>Assisted Living Concepts, Inc.<BR>Attn: Collections Department<BR>1349 Empire Central, Suite 900<BR>Dallas, TX 75247</td>
		<td width=300></td>
		</Table>
		</td></table>
	<P><HR color="red" size=5></P>
		</cfoutput>
	</cfloop>
	
</cfif>