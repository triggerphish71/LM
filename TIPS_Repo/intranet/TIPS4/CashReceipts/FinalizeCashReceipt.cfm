<!----------------------------------------------------------------------------------------------
| DESCRIPTION   FinalizeCashReceipt.cfm                                                        |
|----------------------------------------------------------------------------------------------|
| Process:		Close Receipt and send email to AR.											   |
| Called by: 		CashReceipt.cfm															   |
| Calls/Submits:	CashReceipt.cfm															   |
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
|Paul Buendia| 02/07/2002 | Original Authorship												   |
|            | 04/19/2002	Changed email to me from cc to bcc                                 |
|Paul Buendia| 07/30/2002 |	Changed report call to open its own window						   |
|			 |			  |	with the login parameters in form fields						   |
| MLAW		 | 08/02/2006 |	Add jblaylock to the cash email                                    |
| mlaw       | 03/21/2006 | Create Flower Box                                                  | 
| mlaw       | 01/24/2007 | Remove mlaw@alcco.com                                              |
| mlaw       | 04/10/2007 | Add Demetrie Woods (dwoods@alcco.com), Remove jblaylock            |
----------------------------------------------------------------------------------------------->

<CFOUTPUT>
	#URL.CRID#
	<!--- ==============================================================================
	Set variable for timestamp to record corresponding times for transactions
	=============================================================================== --->
	<CFQUERY NAME="GetDate" DATASOURCE="#APPLICATION.datasource#">
		SELECT getDate() as Stamp
	</CFQUERY>
	<CFSET TimeStamp = CREATEODBCDateTime(GetDate.Stamp)>
</CFOUTPUT>

<CFTRY>
	<CFTRANSACTION>
		<CFQUERY NAME="UpdateReceipt" DATASOURCE = "#APPLICATION.datasource#">
			UPDATE	CashReceiptMaster
			SET		bFinalized = 1, iRowStartUser_ID = #SESSION.UserID#, dtRowStart = #TimeStamp#
			WHERE	iCashReceipt_ID = #url.CRID#
		</CFQUERY>
	
		<CFQUERY NAME="qOtherOpen" DATASOURCE="#APPLICATION.datasource#">
			SELECT	*
			FROM CashReceiptMaster
			WHERE dtRowDeleted IS NULL AND bFinalized IS NULL
			AND	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#		
		</CFQUERY>
		
		<CFIF qOtherOpen.Recordcount EQ 0>
			<CFQUERY NAME = "NextCashReceipt" DATASOURCE = "#APPLICATION.datasource#">
				SELECT iNextCashReceipt FROM HouseNumberControl 
				WHERE dtRowDeleted IS NULL AND iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</CFQUERY>
						
			<CFQUERY NAME = "NewReceipt" DATASOURCE = "#APPLICATION.datasource#">
				INSERT INTO CashReceiptMaster
				( iCashReceiptNumber, iHouse_ID, bFinalized, dtAcctStamp, iRowStartUser_ID, dtRowStart )
					VALUES
				( #NextCashReceipt.iNextCashReceipt#, #SESSION.qSelectedHouse.iHouse_ID#, NULL, '#SESSION.AcctStamp#', #SESSION.UserID#, getDate() )		
			</CFQUERY>
		
			<CFSET NewReceipt = NextCashReceipt.iNextCashReceipt + 1>
				
			<CFQUERY NAME="NextNumber" DATASOURCE="#APPLICATION.datasource#">
				UPDATE	HouseNumberControl
				SET		iNextCashReceipt = #NewReceipt#, dtRowStart = getDate(), iRowStartUser_ID = #SESSION.UserID#
				WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</CFQUERY>
		</CFIF>
		
	</CFTRANSACTION>
	
	<CFCATCH TYPE="Any">	
		<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="Error CashReciepts">
			Error in Finalize CashReceipts (CFTRANSACTION)
			<P>#cfcatch.message#</P>
		    <P>Caught an exception, type = #cfcatch.TYPE# </P>
		    <P>The contents of the tag stack are:</P>
		    <CFLOOP index=i from=1 to = #ArrayLen(cfcatch.TAGCONTEXT)#>
		          <CFSET sCurrent = #cfcatch.TAGCONTEXT[i]#>
		              <BR>#i# #sCurrent["ID"]# (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
		    </CFLOOP>
		</CFMAIL>			
		<CFSET ERROR =1>	
	</CFCATCH>
</CFTRY>

<CFIF IsDefined("Variables.error") AND Variables.error EQ 1>
	An error has occurred the Web Administrator has been contacted.<BR>
	<A HREF="../MainMenu.cfm">
		Continue
	</A>
<CFELSE>
	
	<CFSCRIPT>
		//Set Variables for the custom tag to pass back information
		CSVFile = ''; SlipNumber = ''; FileTotal= '';
	</CFSCRIPT>
	
	<CFIF SESSION.qSelectedHouse.ihouse_id NEQ 200>
		<CFTRY>
		<!--- ==============================================================================
		AutoImport payments to Solomon
		=============================================================================== --->
		<CFQUERY NAME='qAutoImport' DATASOURCE='#APPLICATION.datasource#'>
			Declare @Status int
			exec rw.sp_ExportPmt2Solomon  #trim(SESSION.qSelectedHouse.ihouse_id)#, #trim(url.Num)#, @Status OUTPUT
			Select @Status
		</CFQUERY>
		<CFCATCH TYPE="Any">

			<CFSCRIPT>
				message='debug == ';
				if (isDefined("error.details")) { message = message & ' ' & error.details;}
				if (isDefined("cfcatch.message")) { message = message & ' ' & cfcatch.message;}
				if (isDefined("cfcatch.ExtendedInfo")) { message = message & ' ' & cfcatch.ExtendedInfo;}
			</CFSCRIPT>
			<CFQUERY NAME="GetEmail" DATASOURCE="#APPLICATION.datasource#">
				SELECT	Du.EMail as AREmail
				FROM House	H
				JOIN #application.alcwebdbserver#.ALCWEB.dbo.employees DU ON H.iAcctUser_ID = DU.Employee_ndx
				WHERE H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
			</CFQUERY>

			<CFQUERY NAME="qDuplicates" DATASOURCE="#APPLICATION.datasource#">
				select h.cname as house, t.csolomonkey as custid, cd.cchecknumber as checknumber, cd.mamount as amount
				from cashreceiptmaster cm
				join cashreceiptdetail cd on cd.icashreceipt_id = cm.icashreceipt_id and cd.dtrowdeleted is null
				and cm.bfinalized is not null
				join tenant t on t.itenant_id = cd.itenant_id and t.dtrowdeleted is null
				join house h on h.ihouse_id = t.ihouse_id and h.dtrowdeleted is null
				where cm.ihouse_id = #trim(SESSION.qSelectedHouse.ihouse_id)# and cm.icashreceiptnumber = #trim(url.Num)# 
				and 0 <> (select count(refnbr) from #Application.HOUSES_APPDBServer#.Houses_app.dbo.ardoc
					where custid=t.csolomonkey and refnbr=cd.cchecknumber)			
			</CFQUERY>			
			
			<!--- 08/02/2006 MLAW Add jblaylock@alcco.com and remove #trim(GetEmail.AREmail)# --->
			<CFMAIL TYPE="html" FROM="TIPS4-Message@alcco.com" TO="dwoods@alcco.com" SUBJECT="Cash Receipt Import for #SESSION.HouseName# unsuccessfull">
				#SESSION.qSelectedHouse.cname# cash receipt #trim(url.Num)# unsuccessfull.<BR>
				<CFIF qDuplicates.recordcount gt 0><CFDUMP VAR="#qDuplicates#"></CFIF>
			</CFMAIL>
				
			<CFMAIL TYPE="HTML" FROM="TIPS4@alcco.com" TO="#session.developerEmailList#" SUBJECT="Import CashReceipts Catch">
				Declare @Status int <BR>
				exec rw.sp_ExportPmt2Solomon #trim(SESSION.qSelectedHouse.ihouse_id)#, #trim(url.Num)#, @Status OUTPUT <BR>
				Select @Status <BR>
				#message#
				<CFDUMP VAR="#cfcatch#">
				<CFIF qDuplicates.recordcount gt 0><CFDUMP VAR="#qDuplicates#"></CFIF>
			</CFMAIL>			
			
		</CFCATCH>
		</CFTRY>
	</CFIF>
		
	
	<!--- ==============================================================================
	Create CSV File for this Cash Receipt
	=============================================================================== --->
	<CF_CashReceiptsCSV iHouse_ID=#SESSION.qSelectedHouse.iHouse_ID# iCashReceipt_ID=#url.CRID#>
	
	<CFTRY>
		<!--- ==============================================================================
		Retrieve the corresponding AREmail
		=============================================================================== --->
		<CFQUERY NAME = "GetEmail" DATASOURCE="#APPLICATION.datasource#">
			SELECT	Du.EMail as AREmail
			FROM House	H
			JOIN #Application.AlcWebDBServer#.ALCWEB.dbo.employees DU ON H.iAcctUser_ID = DU.Employee_ndx
			WHERE H.iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#
		</CFQUERY>
		
		<CFSCRIPT>
			message = "A new Deposit Slip/Cash Receipt has been finalized for #SESSION.HouseName#.<BR>";
			//message = message & "CSV File Name: #Variables.CSVFile#<BR>";
			message = message & "Deposit slip: #Variables.SlipNumber#<BR>";
			message = message & "Deposit Amount: #Variables.FileTotal#<BR>";
			message = message & "The Deposit Slip was finalized by #SESSION.FullName#.<BR>";
			message = message & "Server Time #Now()#<BR>";
			message = message & "____________________________________________________";
		</CFSCRIPT>
		
		<!--- #GetEmail.AREmail# ---> 
		<!--- 08/02/2006 MLAW Add jblaylock@alcco.com and remove #trim(GetEmail.AREmail)# --->
		<CFMAIL TYPE="html" FROM="TIPS4-Message@alcco.com" TO="dwoods@alcco.com" BCC="cfdevelopers@alcco.com" SUBJECT="New Cash Receipt for #SESSION.HouseName#">
			#message#
		</CFMAIL>
	
		<CFDIRECTORY DIRECTORY="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\" ACTION="list" NAME="qDirList" FILTER="CashReceiptsMail.txt">
		<CFIF qDirList.RecordCount GT 0>
			<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\CashReceiptsMail.txt" OUTPUT="#message#">
		<CFELSE>
			<CFFILE ACTION="append" FILE="C:\Inetpub\wwwroot\intranet\TIPS4\MailLog\CashReceiptsMail.txt" OUTPUT="#message#">
		</CFIF>
		
		<CFCATCH TYPE="Any">
			<CFMAIL TYPE="HTML" FROM="TIPS4-Message@alcco.com" TO="#session.developerEmailList#" SUBJECT="Email Failed For CashReceipt">
				
				Email Failed For CashReceipt<BR>
				A new Deposit Slip/Cash Receipt has been finalized for #SESSION.HouseName#.<BR>
				<!--- CSV File Name:		#Variables.CSVFile#<BR> --->
				Deposit slip:   	#Variables.SlipNumber#<BR>
				Deposit Amount:		#Variables.FileTotal#<BR>
				The Deposit Slip was finalized by #SESSION.FullName#.<BR>
				____________________________________________________				
			    <P>#cfcatch.message#</P>
			    <P>Caught an exception, type = #cfcatch.TYPE# </P>
			    <P>The contents of the tag stack are:</P>
			    <CFLOOP index=i from=1 to = #ArrayLen(cfcatch.TAGCONTEXT)#>
			          <CFSET sCurrent = #cfcatch.TAGCONTEXT[i]#>
			              <BR>#i# #sCurrent["ID"]# (#sCurrent["LINE"]#,#sCurrent["COLUMN"]#) #sCurrent["TEMPLATE"]#
			    </CFLOOP>
			</CFMAIL>
			
		</CFCATCH>
	</CFTRY>	
	<CFOUTPUT> <SCRIPT> location.href='CashReceiptsReport.cfm?ID=#url.num#&ref=1'; </SCRIPT> </CFOUTPUT>	
</CFIF>	

