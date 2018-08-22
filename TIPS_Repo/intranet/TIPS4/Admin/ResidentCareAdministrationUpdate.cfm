<!----------------------------------------------------------------------------------------------
| DESCRIPTION   ResidentCareAdministrationUpdate.cfm                                           |
|----------------------------------------------------------------------------------------------|
|  File used to update resident care rates entered through resident care admin                 |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
| sp_UpdateResidentCareDetails   															   |
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
| J Cruz     | 06/12/2008 | Removed hard coded user id references                              |
----------------------------------------------------------------------------------------------->
<CFSET chargelist=''>
<CFLOOP INDEX=fields LIST="#form.fieldnames#"> 
	<CFSCRIPT>
		//#fields# == #evaluate('form.' & fields)#<BR> // collect record set numbers
		if (chargelist eq '') { chargelist = chargelist & listgetat(fields,2,'_'); } 
		else { chargelist = chargelist & ',' & listgetat(fields,2,'_'); } 
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
	
		<!--- added by Katie 1/14/04: must also update the cChargeSet of NULL Care record effective as of 3/1/04.  Will be identical to this (cChargeSet of 2004) record, but with cChargeSet of NULL.--->
		<cfquery name="FindNullCareCharge" datasource="#application.datasource#">
			select * from charges
			WHERE     (iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#) AND (iChargeType_ID = 91) AND (dtRowDeleted IS NULL) AND (cDescription = '#qCurrent.cDescription#') AND (cChargeSet IS NULL) AND (dtEffectiveStart = '3/1/2004')
		</cfquery>
		<cfif FindNullCareCharge.recordcount is not 0>
			<CFQUERY NAME='qUpdateCareRecord' DATASOURCE="#APPLICATION.datasource#">
				update charges
				set	dtrowstart = getdate() ,irowstartuser_id = #SESSION.userid# ,mAmount = #evaluate('form.Amount_' & I)# 
				where icharge_id = #FindNullCareCharge.iCharge_ID#
			</CFQUERY>
		</cfif>
		
		<CFIF isDefined("SESSION.RDOEmail")>
			<CFSCRIPT>
				if (SESSION.qSelectedHouse.ihouse_id EQ 200) { email='#session.developerEmailList#'; }
				else { email=SESSION.RDOEmail; } 
				message= qCurrent.cdescription & " has changed for " & SESSION.HouseName & ' ' & "<BR>";
				message= message & "The rate has changed from " & LSCurrencyFormat(qCurrent.mAmount) & " to " & LSCurrencyFormat(evaluate('form.Amount_' & I));
			</CFSCRIPT>
			<CFMAIL TYPE ="html" FROM="Resident_Care_Change_TIPS4@alcco.com" TO="#email#" SUBJECT="Resident Care Rate Change for #SESSION.HouseName#">#message#</CFMAIL>
		</CFIF>	
	</CFIF> 
</CFLOOP>

<!--- add Stephen's new stored procedure when he's finished right here to call the procedure to update resident care charges --->
<cfstoredproc procedure="rw.sp_UpdateResidentCareDetails" datasource="#APPLICATION.datasource#" RETURNCODE="YES" debug="Yes">
	<cfprocparam type="IN" value="#SESSION.qSelectedHouse.cNumber#" DBVARNAME="@HouseNumber" cfsqltype="CF_SQL_VARCHAR">
	<cfprocparam type="IN" value="1" DBVARNAME="@bCommitChanges" cfsqltype="CF_SQL_BIT">
</cfstoredproc>
	
	<CFLOCATION URL='ResidentCareAdministration.cfm'>
