<!--- *******************************************************************************
Name:			IRDPrinter.cfm
Process:		Manage Image Replacement Documents.

Called by: 		CashReceipts.cfm
Calls/Submits:		IRDPrinterUpdate.cfm
		
Modified By             Date            Reason
-------------------     -------------   --------------------------------------------
Steve Davison           11/22/2004      Initial release.
******************************************************************************** --->

<CFSET Variables.ImagePath = "\\palm\projectcash\#SESSION.HouseName#\">

<CFIF NOT IsDefined("SESSION.USERID") OR SESSION.USERID EQ ""> <CFLOCATION URL="../../Loginindex.cfm" ADDTOKEN="No"> </CFIF>

<!--- ==============================================================================
Include Shared JavaScript
=============================================================================== --->
<CFINCLUDE TEMPLATE="../Shared/JavaScript/ResrictInput.cfm">

<link href="../Shared/Style2.css" rel="stylesheet" type="text/css">
<link href="projectcash.css" rel="stylesheet" type="text/css">
<CFOUTPUT>
<!--- ==============================================================================
Include Intranet Header
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../header.cfm">

<!--- ==============================================================================
Assign Title and Heading for the Page
=============================================================================== --->
<TITLE>TIPS 4 - Image Replacement Document Management</TITLE>

<!--- ==============================================================================
List all Potential IRD Documents
=============================================================================== --->
<cfstoredproc name="Rejections" datasource="#APPLICATION.datasource#" procedure="sp_CashReceiptIRD" username="rw" password="4rwriter">
	<cfprocresult name="rsRejections">
</cfstoredproc>

<!--- ==============================================================================
IRDPrinter Object
=============================================================================== --->
<OBJECT name="IRDPrinter" classid="clsid:BBD31925-FD4F-47F4-A8BC-83C69EB0B8C2">
<FORM name="frmRejections">
	<table>
		<tr>
			<th>Resident</th>
			<th>ViewIRD</th>
		</tr>
		<cfloop query="rsRejections">
			<tr>
				<td>
					#rsRejections.iTenant_ID#
				</td>
				<td><input type="submit" name="Submit" value="Submit" onClick="ViewIRD('#rsRejections.cCheckFrontImageFileName#',#rsRejections.iCashReceiptItem_ID#)">
				</td>
			</tr>
		</cfloop>
	</table>
</FORM>
<script language="vbscript">
	sub ViewIRD(FileName, CashReceiptItem)
		IRDPrinter.ViewIRD(FileName, CashReceiptItem, "TIPS4_DEV")
	end sub
</script>
<!--- ==============================================================================
Include intranet footer
=============================================================================== --->
<CFINCLUDE TEMPLATE="../../footer.cfm">