<!----------------------------------------------------------------------------------------------->
<!---  mstriegel 12/27/2017  added the call to object                                         --->
<!----------------------------------------------------------------------------------------------->

<cfparam name="fuse" default="">

<cfswitch expression="#fuse#">
	<!--- fix duplicate keys --->
	<cfcase value="duplicateKeys">
		<cfstoredproc datasource="TIPS4" procedure="sp_fixduplicatekeys">
			<cfprocparam cfsqltype="CF_SQL_BIT" value="1">
			<cfprocresult name="theResult" resultset="1">
		</cfstoredproc>
		<cfif theResult.RecordCount gt 0>
			<cfset message = "The process has found data that may cause this error and fixed it. (#theResult.RecordCount#)">
		<cfelse>
			<cfset message = '<span style="color:##ff0000;font-weight:bold;">The process has not found data that may cause this error please forward the ticket to developers. (#theResult.RecordCount#)</span>'>
		</cfif>
	</cfcase>
	<!--- export a batch to solomon --->
	<cfcase value="missingSolomonBatchForHouse">
		<cfparam  name="period" default="">
		<cfparam name="housename" default="">

		<cfif period eq "" or housename eq "">
			<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error.  Please make sure you enter a value in the period and house name fields.</span>'>
		<cfelse>
			<!--- get house id --->
			<cfquery name="GetHouseId" datasource="TIPS4">
				SELECT iHouse_ID
				FROM House WITH (NOLOCK)
				WHERE cName = '#housename#'
			</cfquery>

			<cfif GetHouseId.RecordCount eq 0>
				<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. Please enter a valid house name into the house name field.</span>'>
			<cfelse>
				<!--- mstriegel 01/18/2017 Added so the same stored proc is called ---->
				<cfset oAutoRelease = CreateObject("component","intranet.TIPS4.CFC.components.export2Solomon")>		
				<cfdump var="#oAutoRelease#" abort>		
				<cfset argsCollection = {iHouseID=#GetHouseId.iHouse_ID#,period=#period#,invoice="",batchType="QFHouse"}>				<!--- <cftry> ---->
					<cfset qAutoImport = oAutoRelease.sp_ExportInv2Solomon(argumentCollection=argsCollection)>
				
					<cfif qAutoImport.success EQ "true">
						<cfset message="Batch has been imported into solomon.  Please have user check again.  If batch still is not in solomon please forward this ticket to the developers.">
					<cfelse>
						<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. The process did not find any data to export into solomon.  Please forward ticket to developers.</span>'>
					</cfif>
				<!----	<cfcatch type="any">
						<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. ' & cfcatch.message & ' ' & cfcatch.Detail & '</span>'>
					</cfcatch>
				</cftry>---->
			
				<!----  replaced by code above
				<cftry>
					
						<cfstoredproc datasource="TIPS4" procedure="rw.sp_ExportInv2Solomon">
							<cfprocparam cfsqltype="cf_sql_integer" value="#GetHouseId.iHouse_ID#" dbVarName="@house">
							<cfprocparam cfsqltype="cf_sql_char" value="#period#" dbVarName="@period">
							<cfprocparam cfsqltype="cf_sql_varchar" null="true" dbVarName="@invoice">
							
							<cfprocparam cfsqltype="cf_sql_integer" type="out" null="true" variable="ExportStatus" dbVarName="@Status">
							<!---<cfprocresult name="theRecordSet" resultset="1"> --->
						</cfstoredproc>
				
					<cfif isDefined("theRecordSet")>
						<cfset message="Batch has been imported into solomon.  Please have user check again.  If batch still is not in solomon please forward this ticket to the developers.">
					<cfelse>
						<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. The process did not find any data to export into solomon.  Please forward ticket to developers.</span>'>
					</cfif>

				<cfcatch>
					<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. ' & cfcatch.message & ' ' & cfcatch.Detail & '</span>'>
				</cfcatch>
				</cftry>--->
				<!--- end mstriegel 01/18/2018 --->
			</cfif>
		</cfif>
	</cfcase>
	<!--- export a batch to solomon part 2 --->
	<cfcase value="missingSolomonBatchForMoveIn">
		<cfparam  name="key" default="">

		<cfif key eq "">
			<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error.  Please make sure you enter a value in the solomon key field.</span>'>
		<cfelse>
			<!--- get move out invoice number --->
			<cfquery name="GetInvoice" datasource="TIPS4">
				SELECT
					 m.iInvoiceNumber
					,t.iHouse_id
				FROM
					InvoiceMaster m WITH (NOLOCK)
				INNER JOIN
					Tenant t WITH (NOLOCK) on t.csolomonkey = m.csolomonkey
						AND
					t.dtrowdeleted is null
				WHERE
					m.cSolomonkey = '#Trim(key)#'
				AND
					m.dtRowDeleted IS NULL
				AND
					m.bMoveOutInvoice = 1
			</cfquery>
			
			<!--- no move out invoice found, look for move in --->
			<cfif GetInvoice.RecordCount eq 0>
				<cfquery name="GetInvoice" datasource="TIPS4">
					SELECT
						 m.iInvoiceNumber
						,t.iHouse_id
					FROM
						InvoiceMaster m WITH (NOLOCK)
					INNER JOIN
						Tenant t WITH (NOLOCK) on t.csolomonkey = m.csolomonkey
							AND
						t.dtrowdeleted is null
					WHERE
						m.cSolomonkey = '#Trim(key)#'
					AND
						m.dtRowDeleted IS NULL
					AND
						bMoveInInvoice = 1
				</cfquery>
			</cfif>
			
			<cfif GetInvoice.RecordCount neq 1>
				<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. Move In or Move Out invoice not found for tenant. Forward ticket to developers.</span>'>
			<cfelse>
				
					<!--- mstriegel 01/18/2018 added so it calls the same proc everywhere --->
					<cfset oAutoRelease = CreateObject("component","intranet.TIPS4.CFC.components.export2Solomon")>
					<cfset argsCollection = {iHouseID=#GetInvoice.iHouse_ID#,period="",invoice="#getInvoice.iInvoiceNumber#",batchType="QFmovein"}>
					<cftry>
						<cfset qAutoImport = oAutoRelease.sp_ExportInv2Solomon(argumentCollection=argsCollection)>
						<cfif qAutoImport.success EQ "true">
							<cfset message="Batch has been imported into solomon.  Please have user check again.  If batch still is not in solomon please forward this ticket to the developers.">
						<cfelse>
							<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. The process did not find any data to export into solomon.  Please forward ticket to developers.</span>'>
						</cfif>
						<cfcatch type="any">
							<cfif qAutoImport.success NEQ true>
								<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. ' & cfcatch.message & ' ' & cfcatch.Detail & '</span>'>						
							</cfif>							
						</cfcatch>
					</cftry>
					<!---Replaced by code above 
					<cftry>					
						<cfstoredproc datasource="TIPS4" procedure="rw.sp_ExportInv2Solomon">
							<cfprocparam cfsqltype="cf_sql_integer" value="#GetInvoice.iHouse_ID#" dbVarname="@house">
							<cfprocparam cfsqltype="cf_sql_char" null="true" dbVarName="@period">
							<cfprocparam cfsqltype="cf_sql_varchar" value="#GetInvoice.iInvoiceNumber#" dbVarName="@invoice">
						
							<cfprocparam cfsqltype="cf_sql_integer" type="out" null="true" variable="ExportStatus" dbVarName="@status">
							<cfprocresult name="theRecordSet" resultset="1">
						</cfstoredproc>
				
					<cfif isDefined("theRecordSet")>
						<cfset message="Batch has been imported into solomon.  Please have user check again.  If batch still is not in solomon please forward this ticket to the developers.">
					<cfelse>
						<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. The process did not find any data to export into solomon.  Please forward ticket to developers.</span>'>
					</cfif>

					<cfcatch>
						<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. ' & cfcatch.message & ' ' & cfcatch.Detail & '</span>'>
					</cfcatch>
					</cftry> --->
					<!--- end mstriegel 01/18/2018 --->
			</cfif>
			
		</cfif>
	</cfcase>
	<!--- batch not releasing in olomon part--->
	<cfcase value="batchNotReleasing">
		<cfparam  name="batch" default="">

		<cfif batch eq "">
			<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error.  Please make sure you enter a value in batch number field.</span>'>
		<cfelse>
			<cftry>
<!---				<cfstoredproc datasource="Support" procedure="sp_SolomonBatchNotReleasing">
					<cfprocparam cfsqltype="cf_sql_varchar" value="#batch#">
					<cfprocparam cfsqltype="cf_sql_bit" value="1">

					<cfprocresult name="theRecordSet" resultset="1">
				</cfstoredproc>--->

				
				<cfquery name="theRecordSet" datasource="houses_app">
					SET NOCOUNT ON
					
					update batch 
					set basecuryid = '0000', 
						cpnyid = '0000', 
						curyid = '0000', 
						rlsed = 0, 
						status = 'B' 
					where 
						batnbr = #batch#
						and module = 'AR'				
				
					SELECT rowsEffected=@@ROWCOUNT
					
					SET NOCOUNT OFF
				</cfquery>

				<cfset message="Batch has been updated.  Please have the user try to release the batch again.">

			<cfcatch>
				<cfset message = '<span style="color:##ff0000;font-weight:bold;">Error. ' & cfcatch.message & ' ' & cfcatch.Detail & '</span>'>
			</cfcatch>
			</cftry>
		</cfif>
	</cfcase>
</cfswitch>
<cfoutput>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!-- DW6 -->
<head>
<!-- Copyright 2005 Macromedia, Inc. All rights reserved. -->
<title>Quick Fixes</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" href="mm_lodging1.css" type="text/css" />
</head>
<body bgcolor="##999966">
<form id="form1" name="form1" method="post" action="index.cfm" enctype="multipart/form-data">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	<td width="15" nowrap="nowrap">&nbsp;</td>
	<td height="60" colspan="3" class="logo" nowrap="nowrap"><br />
	Quick Fixes</td>
	<td width="100%">&nbsp;</td>
	</tr>
	<tr bgcolor="##ffffff">
	<td colspan="5"><img src="mm_spacer.gif" alt="" width="1" height="1" border="0" /></td>
	</tr>

	<tr bgcolor="##a4c2c2">
	<td width="15" nowrap="nowrap">&nbsp;</td>
	<td height="36" colspan="2" id="navigation" class="navText"><a href="javascript:;"></a></td>
	<td>&nbsp;</td>
	<td width="100%">&nbsp;</td>
	</tr>

	<tr bgcolor="##ffffff">
	<td colspan="5"><img src="mm_spacer.gif" alt="" width="1" height="1" border="0" /></td>
	</tr>

	<tr bgcolor="##ffffff">
	<td valign="top" width="15"><img src="mm_spacer.gif" alt="" width="15" height="1" border="0" /></td>
	<td valign="top" width="140"><img src="mm_spacer.gif" alt="" width="140" height="1" border="0" /></td>
	<td width="505" valign="top"><br />
	<table border="0" cellspacing="0" cellpadding="2" width="440">
	<cfif isDefined("message")>
		<tr bgcolor="##ffffff">
			<td colspan="2" class="bodyText">
				<table cellspacing="1" cellpadding="0" bgcolor="##999999">
					<tr>
						<td bgcolor="##999999">
							<table cellspacing="2" cellpadding="2">
								<tr>
									<td bgcolor="##e3e3e3"><strong>#message#</strong><br><br></td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
		</td>
	</tr>
	</cfif>

	<!--- INSERT NEW LINKS HERE --->

	<tr>
		<td class="bodyText">
			<table width="85%" border="0" cellspacing="0" cellpadding="0">
			       <tr>
	            <td><a href="index.cfm?fuse=duplicateKeys">Saving a move in form generates an error screen (run once)</a></td>
	          </tr>
	        </table>
		</td>
	</tr>
 		<tr>
		<td class="bodyText">
			<form action="index.cfm" method="post" name="form1" id="form1">
			<table width="75%" border="0" cellspacing="0" cellpadding="0">
			   <tr>
	            <td><a href="javascript:document.getElementsByName('form1')[0].submit()">Missing Batch For House Close In Solomon</a></td>
	          </tr>
	          <tr>
					<td>
						<table>
							<tr>
								<td>House Name</td><td><input type="text" name="housename" size="10" <cfif IsDefined("form.housename") AND IsDefined("Message")  AND fuse eq "missingSolomonBatchForHouse">value="#housename#"</cfif>></td>
							</tr>
							<tr>
								<td>Period</td><td><input type="text" name="period" size="10" <cfif IsDefined("form.period") AND IsDefined("Message")  AND fuse eq "missingSolomonBatchForHouse">value="#period#"</cfif>></td>
							</tr>
						</table>
					</td>
				</tr>
	        </table>
	        <input type="hidden" name="fuse" value="missingSolomonBatchForHouse">
	        </form>
		</td>
	</tr>
	<tr>
		<td class="bodyText">
			<form action="index.cfm" method="post" name="form2" id="form2">
			<table width="75%" border="0" cellspacing="0" cellpadding="0">
			   <tr>
	            <td><a href="javascript:document.getElementsByName('form2')[0].submit()">Missing Batch For Move In/Out In Solomon</a></td>
	          </tr>
	          <tr>
					<td>
						<table>
							<tr>
								<td>Solomon Key</td><td><input type="text" name="key" size="10" <cfif IsDefined("form.key") AND IsDefined("Message") AND fuse eq "missingSolomonBatchForMoveIn">value="#key#"</cfif>></td>
							</tr>
						</table>
					</td>
				</tr>
	        </table>
	        <input type="hidden" name="fuse" value="missingSolomonBatchForMoveIn">
	        </form>
		</td>
	</tr>
	<tr>
		<td class="bodyText">
			<form action="index.cfm" method="post" name="form3" id="form3">
			<table width="75%" border="0" cellspacing="0" cellpadding="0">
			   <tr>
	            <td><a href="javascript:document.getElementsByName('form3')[0].submit()">Batch Not Releasing In Solomon</a></td>
	          </tr>
	          <tr>
					<td>
						<table>
							<tr>
								<td>Batch Number</td><td><input type="text" name="batch" size="10" <cfif IsDefined("form.batch") AND IsDefined("Message") AND fuse eq "batchNotReleasing">value="#batch#"</cfif>></td>
							</tr>
						</table>
					</td>
				</tr>
	        </table>
	        <input type="hidden" name="fuse" value="batchNotReleasing">
	        </form>
		</td>
	</tr>
	<!--- END INSERT NEW LINKS HERE --->


	</table>

	 <br />
	&nbsp;<br />	</td>
	<td valign="top">&nbsp;</td>
	<td width="100%">&nbsp;</td>
	</tr>

	<tr>
	<td width="15">&nbsp;</td>
    <td width="140">&nbsp;</td>
    <td width="505">&nbsp;</td>
    <td width="100">&nbsp;</td>
    <td width="100%">&nbsp;</td>
  </tr>
</table>
</form>
</body>
</html>
</cfoutput>

