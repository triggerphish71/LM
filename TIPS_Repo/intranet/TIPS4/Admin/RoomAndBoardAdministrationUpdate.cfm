<!----------------------------------------------------------------------------------------------
| DESCRIPTION   RoomAndBoardAdministrationUpdate.cfm                                           |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| Parameter Name   																			   |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                     												   |                                                                        
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| mlaw       | 03/21/2006 | Create Flower Box                                                  | 
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
----------------------------------------------------------------------------------------------->

<CFSET chargelist=''>
<CFLOOP INDEX=fields LIST="#form.fieldnames#"> 
	<CFSCRIPT>
		//#fields# == #evaluate('form.' & fields)#<BR>
		// collect record set numbers
		if (chargelist eq '') { chargelist = chargelist & listgetat(fields,2,'_'); } else { chargelist = chargelist & ',' & listgetat(fields,2,'_'); } 
	</CFSCRIPT>
</CFLOOP>

<CFQUERY NAME='qCurrentValues' DATASOURCE='#APPLICATION.datasource#'>
	SELECT iCharge_id, mAmount, cdescription FROM Charges WHERE dtRowDeleted IS NULL AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID# AND iCharge_id in (#chargelist#)
</CFQUERY>

<CFLOOP INDEX=I LIST='#Chargelist#'>
	<CFQUERY NAME='qCurrent' DBTYPE='query'>
		select * from qCurrentValues where icharge_id = #I#
	</CFQUERY>
	
	<CFIF evaluate('form.Amount_' & I) neq qCurrent.mAmount>
		<CFQUERY NAME='qUpdateRecord' DATASOURCE="#APPLICATION.datasource#">
			update charges
			set	dtrowstart = getdate() ,irowstartuser_id = #SESSION.userid# ,mAmount = #evaluate('form.Amount_' & I)# 
			where icharge_id = #I#
		</CFQUERY>
		
		<!--- added by Katie 1/6/04: must also update the cChargeSet of '2004' R&B record.  Will be identical to this (cChargeSet of NULL) record, but with cChargeSet of 2004.--->
		<cfquery name="Find2004RentCharge" datasource="#application.datasource#">
			select * from charges
			WHERE     (iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#) AND (iChargeType_ID = 89) AND (dtRowDeleted IS NULL) AND (cDescription = '#qCurrent.cDescription#') AND (cChargeSet = '2004') AND (dtEffectiveEnd > #Now()#)
		</cfquery>
		<cfif Find2004RentCharge.recordcount is not 0>
			<CFQUERY NAME='qUpdateRecord' DATASOURCE="#APPLICATION.datasource#">
				update charges
				set	dtrowstart = getdate() ,irowstartuser_id = #SESSION.userid# ,mAmount = #evaluate('form.Amount_' & I)# 
				where icharge_id = #Find2004RentCharge.iCharge_ID#
			</CFQUERY>
		</cfif>
		 
		<CFIF isDefined("SESSION.RDOEmail")>
			<CFSCRIPT>
				if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='#session.developerEmailList#'; }
				else { email=SESSION.RDOEmail; } 
				message= qCurrent.cdescription & " has changed for " & SESSION.HouseName & ' ' & "<BR>";
				message= message & "The rate has changed from " & LSCurrencyFormat(qCurrent.mAmount) & " to " & LSCurrencyFormat(evaluate('form.Amount_' & I));
			</CFSCRIPT>
			<CFMAIL TYPE ="html" FROM="TIPS4_R&B_Change@alcco.com" TO="#email#" SUBJECT="Room & Board Rate Change for #SESSION.HouseName#">#message#</CFMAIL>
		</CFIF>
	</CFIF> 
	
</CFLOOP>

<CFIF (isDefined("AUTH_USER") AND AUTH_USER eq 'ALC\PaulB')>
	<CFOUTPUT><A HREF='#HTTP.Referer#'>Continue</A></CFOUTPUT>
<CFELSE>
	<CFLOCATION URL='RoomAndBoardAdministration.cfm'>
</CFIF>
