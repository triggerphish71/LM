<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<!--- 
|Sfarmer     |02/16/2016  | Report change to Coldfusion CFDocument PDF from Crystal Reports    |
 --->
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>MoveInMoveOutActivitySummaryByHouse </title> 
</head>

<!---<CFOUTPUT>
	<CFIF isDefined("SESSION.UserID") AND SESSION.UserID IS 3025>
		<CFIF IsDefined("form.fieldnames")> #form.fieldnames#<BR> </CFIF>
	</CFIF>
	
	<CENTER><B STYLE="font-size: 30;"> Please, wait while the report is loading.... </B></CENTER>
</CFOUTPUT>


<SCRIPT>
	window.open("loading.htm","OccupiedUnitSummaryReport","toolbar=no,resizable=yes");
</SCRIPT>--->

<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
	SELECT	H.iHouse_ID, h.cName, H.cNumber
	    , h.caddressline1
		, h.ccity
		, h.cstatecode
		,h.czipcode
		, h.cname
		,h.cphonenumber1
		,OA.cNumber as OPS, R.cNumber as Region
	FROM	House H
	JOIN	OPSArea OA	ON	OA.iOPSArea_ID = H.iOPSArea_ID
	JOIN	Region R	ON	OA.iRegion_ID = R.iRegion_ID
	WHERE	iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
</CFQUERY>	

<!---<CFOUTPUT>

<CFSET User="rw">
<CFSET Password="4rwriter">

		<FORM NAME="OccupiedUnitSummaryReport" action="//#crserver#/reports/tips/tips4/OccupiedUnitSummary.rpt" method="POST" TARGET="OccupiedUnitSummaryReport">
			<input type=hidden name="init" value="actx">  <!-- actx uses ActiveX viewer, Java uses JVM Java viewer, html_page uses straight HTML -->
			<input type=hidden name="user0" value="#User#">
			<input type=hidden name="password0" value="#Password#">
				
			<INPUT TYPE="Hidden" name="prompt0" value="#HouseData.cName#">
			<INPUT TYPE="Hidden" NAME="prompt1" VALUE="#form.prompt1#">


			<SCRIPT>
				location.href='#HTTP_REFERER#'
				document.OccupiedUnitSummaryReport.submit();
			</SCRIPT>
			#HouseData.cNumber#<BR>
		</form>
</CFOUTPUT>--->
<cfquery NAME="OccupiedUnitSummary" DATASOURCE="#APPLICATION.datasource#">
Exec rw.sp_OccupiedUnitSummary @scope='#HouseData.cName#', @Period='#form.prompt1#'
</cfquery>

<cfdump var="#OccupiedUnitSummary#">
<cfsavecontent variable ="pdfhtml">
<cfheader name="Content-Disposition" 
value="attachment;filename=OccupiedUnitSummary-#HouseData.cname#.pdf">


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
	<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Occupied Unit Summary</title>
		<!--- <style>
			table{ 
				font-size:0em;
				border-collapse: collapse;
			}
		</style>--->
	</head>	
	
<body>
<cfoutput>		
<cfif #OccupiedUnitSummary.sortorder# Eq ''>
No record were found.
<cfelse>

		<table width="50%" cellpadding="2";  cellspacing="2" style="margin-left:auto; margin-right:auto;" > <!---beginning occupancy--->
			<tr> <!---heading of the table--->
				<td style="text-align:left; font-size:12px; border-bottom: .5px solid black; ">
					Beginning Occupancy
				</td>
				<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
					Physical
				</td>
				<td style="text-align:center; font-size:12px; border-bottom: .5px solid black; ">
					Billing
				</td>
			</tr>
			<tr> <!---First row--->
				<td style="text-align:left; font-size:12px; ">
					Number of Available Units:
				</td>
				<td style="text-align:center; font-size:12px; ">
					#OccupiedUnitSummary.iAptsAvailableStart#
				</td>
				<td style="text-align:center; font-size:12px;">
					#OccupiedUnitSummary.iAptsAvailableStartBilling#
				</td>
			</tr>
			<tr> <!---second row--->
				<td style="text-align:left; font-size:12px; ">
					Number of Private Pay Residents:
				</td>
				<td style="text-align:center; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsPrivateStart#
				</td>
				<td style="text-align:center; font-size:12px;  ">
					#OccupiedUnitSummary.iTenantsPrivateStartBilling#
				</td>
			</tr>
			<tr> <!---third row--->
				<td style="text-align:left; font-size:12px;">
					Number of Medicaid Residents:
				</td>
				<td style="text-align:center; font-size:12px;">
					#OccupiedUnitSummary.iTenantsMedicaidStart#
				</td>
				<td style="text-align:center; font-size:12px;"> 
					#OccupiedUnitSummary.iTenantsMedicaidStartBilling#
				</td>
			</tr>
			<tr> <!---fourth row--->
				<td style="text-align:left; font-size:12px;">
					Number of Respite Residents:
				</td>
				<td style="text-align:center; font-size:12px;">
					#OccupiedUnitSummary.iTenantsRespiteStart#
				</td>
				<td style="text-align:center; font-size:12px;"> 
					#OccupiedUnitSummary.iTenantsRespiteStartBilling#
				</td>
			</tr>
			<tr> <!---Fifth row--->
				<td style="text-align:left; font-size:12px;">
					Number of Occupied Units:
				</td>
				<td style="text-align:center; font-size:12px;">
					#OccupiedUnitSummary.iAptsAvailableStart - OccupiedUnitSummary.iAptsEmptyStart#
				</td>
				<td style="text-align:center; font-size:12px;">
					#OccupiedUnitSummary.iAptsAvailableStartBilling - OccupiedUnitSummary.iAptsEmptyStartBilling#
				</td>
			</tr>
			<tr>
				<td> </td>
			</tr>
			<tr>
				<td> </td>
			</tr>
			<tr>
				<td> </td>
			</tr>
		</table>
				 
		<table width="100%" cellpadding="2"  cellspacing="2" style="border:1px solid black;" bgcolor="beige"> <!---Occupancy Detail Table Starts here--->
		 <tr style="line-height:100%">
			 <td colspan="7" style="text-align:center; font-size:14px; border-bottom: .5px solid black;  width:100%">
			 Occupancy Detail
			 </td>
		 </tr>
		  <tr style="line-height:100%">
			  <td colspan="7" style="text-align:left; font-size:12px;">
			 	 Reservations:
			   </td>
		  </tr>
		  <tr> 
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
				  Resident
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Type
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	 
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Transaction Date
			  </td>
		  </tr>
		    <cfloop query="OccupiedUnitSummary">
			 <tr> 
			  <cfif #OccupiedUnitSummary.sortorder# eq 0 >
			  <td colspan="1" style="text-align:center; font-size:12px;">
				 <cfif #OccupiedUnitSummary.itenant_ID# eq ''>
					  None
				  <cfelse>
				   #OccupiedUnitSummary.cFirstName# #OccupiedUnitSummary.cLastName#
				   </cfif> 
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px;">
			  		#OccupiedUnitSummary.cResidency#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	   #dateformat((OccupiedUnitSummary.statedtRowstart),'MM/dd/yyyy')#
			  </td>
			  </cfif>
		  </tr>	
		   </cfloop>
		  <tr>
			  <td colspan="7" style="text-align:left; font-size:12px;">
			 	 Projected Move Ins:
			   </td>
		  </tr>
		  <tr> 
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
				  Resident
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Type
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Move-In
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Apt
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Transaction Date
			  </td>
		  </tr>	
		  <cfloop query="OccupiedUnitSummary">
		  <tr> 
			  
			  <cfif #OccupiedUnitSummary.sortorder# eq 1 >
			  <td colspan="1" style="text-align:center; font-size:12px;">
				  <cfif #OccupiedUnitSummary.itenant_ID# eq ''>
					  None
				  <cfelse>
				   #OccupiedUnitSummary.cFirstName# #OccupiedUnitSummary.cLastName# 
				   </cfif>
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px;">
			  	#OccupiedUnitSummary.cResidency#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			       #dateformat((OccupiedUnitSummary.dtActualEffective),'MM/dd/yyyy')#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			   #dateformat((OccupiedUnitSummary.statedtRowstart),'MM/dd/yyyy')#
			 </td>
			  </cfif> 
			
		  </tr>	
		    </cfloop>
		   <tr>
			  <td colspan="7" style="text-align:left; font-size:12px;">
			 	 Move Ins:
			   </td>
		  </tr>
		  <tr> 
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
				 Resident
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Type
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Move-In
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Apt
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Transaction Date
			  </td>
		  </tr>	
		 <cfloop query="OccupiedUnitSummary">
		  <tr> 
			   <cfif #OccupiedUnitSummary.sortorder# eq 2 >
			  <td colspan="1" style="text-align:center; font-size:12px;">
				  <cfif #OccupiedUnitSummary.itenant_ID# eq ''>
					  None
				  <cfelse>
				   #OccupiedUnitSummary.cFirstName# #OccupiedUnitSummary.cLastName# 
				   </cfif>
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cResidency#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  <cfif isdefined("OccupiedUnitSummary.dtActualEffective") and #OccupiedUnitSummary.dtActualEffective# NEQ ''>
				   <cfif #OccupiedUnitSummary.dtActualEffective# GT #OccupiedUnitSummary.dtRangeEnd# or
	                     #OccupiedUnitSummary.dtActualEffective# LT #OccupiedUnitSummary.dtRangeStart#>
				  	<b> #dateformat((OccupiedUnitSummary.dtActualEffective),'MM/dd/yyyy')# </b>
				  <cfelse>
				     #dateformat((OccupiedUnitSummary.dtActualEffective),'MM/dd/yyyy')#
				  </cfif>
			</cfif>
			   <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cAptNumber#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	   #dateformat((OccupiedUnitSummary.statedtRowstart),'MM/dd/yyyy')#
			  </td>
			   </cfif>
			  </tr>	
		  </cfloop>
		  <tr>
			  <td colspan="7" style="text-align:left; font-size:12px;">
			 	Move Outs:
			   </td>
		  </tr>
		  <tr> 
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
				 Resident
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Type
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Move-Out
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Apt
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Transaction Date
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Reason
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Charge Through
			  </td>
		  </tr>	 
		<cfloop query="OccupiedUnitSummary">
		  <tr> 
			    <cfif #OccupiedUnitSummary.sortorder# eq 3 >
			  <td colspan="1" style="text-align:center; font-size:12px;">
				  <cfif #OccupiedUnitSummary.itenant_ID# eq ''>
					  None
				  <cfelse>
				   #OccupiedUnitSummary.cFirstName# #OccupiedUnitSummary.cLastName# 
				  </cfif>
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cResidency#
			  </td>
			  
			  <td colspan="1" style="text-align:center; font-size:12px;">
				<cfif isdefined("OccupiedUnitSummary.dtActualEffective") and #OccupiedUnitSummary.dtActualEffective# NEQ ''>
					  <cfif #dateadd('d', 1, (OccupiedUnitSummary.dtMoveout))# GT #OccupiedUnitSummary.dtRangeEnd# or
		                     #dateadd('d', 1, (OccupiedUnitSummary.dtMoveout))# LT #OccupiedUnitSummary.dtRangeStart#>
					  	<b> #dateformat((OccupiedUnitSummary.dtMoveout),'MM/dd/yyyy')# </b>
					  <cfelse>
					     #dateformat((OccupiedUnitSummary.dtMoveout),'MM/dd/yyyy')#
					  </cfif>
				</cfif>
			  </td>
			
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cAptNumber#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	  #dateformat((OccupiedUnitSummary.statedtRowstart),'MM/dd/yyyy')#
			  </td>
			   <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cReason#
			  </td>
			   <td colspan="1" style="text-align:center; font-size:12px;">
				<cfif isdefined("OccupiedUnitSummary.dtActualEffective") and #OccupiedUnitSummary.dtActualEffective# NEQ ''>
					<cfif #dateadd('d', 1, (OccupiedUnitSummary.dtChargethrough))# GT #OccupiedUnitSummary.dtRangeEnd# or
	                     #dateadd('d', 1, (OccupiedUnitSummary.dtChargethrough))# LT #OccupiedUnitSummary.dtRangeStart#>
				  		<b> #dateformat((OccupiedUnitSummary.dtChargethrough),'MM/dd/yyyy')# </b>
				 	 <cfelse>
				     	#dateformat((OccupiedUnitSummary.dtChargethrough),'MM/dd/yyyy')#
					</cfif>
				</cfif>
			  </td>
			  </cfif> 
		  </tr>	
		 </cfloop>
		  <tr>
			  <td colspan="7" style="text-align:left; font-size:12px;">
			 	Projected Move Outs:
			   </td>
		  </tr>
		  <tr> 
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
				  Resident
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Type
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Move-Out
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Apt
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Transaction Date
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Reason
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px; border-bottom: .5px solid black;">
			  	 Charge Through
			  </td>
		<cfloop query="OccupiedUnitSummary">
		  <tr> 
			    <cfif #OccupiedUnitSummary.sortorder# eq 4 >
			  <td colspan="1" style="text-align:center; font-size:12px;">
				 	<cfif #OccupiedUnitSummary.itenant_ID# eq ''>
					  None
				 	 <cfelse>
				   #OccupiedUnitSummary.cFirstName# #OccupiedUnitSummary.cLastName# 
				  </cfif>
			  </td>
		  	  <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cResidency#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	#dateformat((OccupiedUnitSummary.dtmoveout),'MM/dd/yyyy')#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cAptNumber#
			  </td>
			  <td colspan="1" style="text-align:center; font-size:12px;">
			  	   #dateformat((OccupiedUnitSummary.statedtRowstart),'MM/dd/yyyy')#
			  </td>
			   <td colspan="1" style="text-align:center; font-size:12px;">
			  	 #OccupiedUnitSummary.cReason#
			  </td>
			   <td colspan="1" style="text-align:center; font-size:12px;">
			<cfif isdefined("OccupiedUnitSummary.dtChargethrough")and #OccupiedUnitSummary.dtChargethrough# NEQ ''>   
				<cfif #OccupiedUnitSummary.dtChargethrough# GT #OccupiedUnitSummary.dtRangeEnd# or
                     #OccupiedUnitSummary.dtChargethrough# LT #OccupiedUnitSummary.dtRangeStart#>
			  		<b> #dateformat((OccupiedUnitSummary.dtChargethrough),'MM/dd/yyyy')# </b>
			 	 <cfelse>
			     	#dateformat((OccupiedUnitSummary.dtChargethrough),'MM/dd/yyyy')#
				</cfif>
		  </cfif>
			 </td>
			  </cfif>
			 </tr>	
		   </cfloop>
		  </tr>	
		</table><!---Occupancy Detail Table ends here--->
		
		<table width="50%" cellpadding="2";  cellspacing="2" style="margin-left:auto; margin-right:auto;">
			 <!---Ending occupancy--->
			 <tr>
				<td> </td>
			</tr>
			<tr>
				<td> </td>
			</tr>
			<tr>
				<td> </td>
			</tr>
			<tr> <!---heading of the table--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; border-bottom: .5px solid black;">
					Ending Occupancy
				</td>
				<td  Colspan="1" width="25%" style="text-align:left; font-size:12px; border-bottom: .5px solid black;">
					Physical
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; border-bottom: .5px solid black;">
					Billing
				</td>
			</tr>
			<tr> <!---First row--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
					Number of Available Units:
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iAptsAvailableEnd#
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iAptsAvailableEndBilling#
				</td>
			</tr>
			<tr> <!---second row--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
					Number of Private Pay Residents:
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsPrivateEnd#
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsPrivateEndBilling#
				</td>
			</tr>
			<tr> <!---third row--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
					Number of Medicaid Residents:
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsMedicaidEnd#
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsMedicaidEndBilling#
				</td>
			</tr>
			<tr> <!---fourth row--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
					Number of Respite Residents:
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsRespiteEnd#
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iTenantsRespiteEndBilling#
				</td>
			</tr>
			<tr> <!---Fifth row--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
					Number of Occupied Units:
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iAptsAvailableEnd - OccupiedUnitSummary.iAptsEmptyEnd#
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					#OccupiedUnitSummary.iAptsAvailableEndBilling - OccupiedUnitSummary.iAptsEmptyEndBilling#
				</td>
			</tr>
			<tr> <!---Fifth row--->
				<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
					Occupancy % :
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					<cfif #OccupiedUnitSummary.iAptsAvailableEnd# eq 0>
					    0
					<cfelse>
					   #round( 100 * (OccupiedUnitSummary.iAptsAvailableEnd - OccupiedUnitSummary.iAptsEmptyEnd) / (OccupiedUnitSummary.iAptsAvailableEnd))#%
					</cfif>
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
					<cfif #OccupiedUnitSummary.iAptsAvailableEndBilling# Eq 0 >
					    0
					<cfelse>
					   # round(100 * (OccupiedUnitSummary.iAptsAvailableEndBilling - OccupiedUnitSummary.iAptsEmptyEndBilling) / (OccupiedUnitSummary.iAptsAvailableEndBilling))#%
					</cfif>
				</td>
			</tr>
			<tr>
				<td Colspan="3" width="100%" style="text-align:left; font-size:10px;">
				<br>Notes: 1. Move Ins and Move Outs for second residents do not affect occupancy totals. </br>
				<br>   2. Out of period transactions will not appear in the occupancy detail but may affect occupancy totals.</br>
				</td>
			</tr>
			 <tr>
				<td> </td>
			</tr>
			<tr>
				<td> </td>
			</tr>
			<tr>
				<td> </td>
			</tr>
		</table> <!---Ending Occupancy Ends Here--->
	    <table width="50%" cellpadding="2";  cellspacing="2" style="margin-left:auto; margin-right:auto;"> <!---Accounting Summary --->
		   <tr>
			   <td Colspan="1" width="50%" style="text-align:left; font-size:12px; border-bottom: .5px solid black;">
			  		 Accounting Summary
			   </td>
			   <td Colspan="1" width="25%" style="text-align:left; font-size:12px; border-bottom: .5px solid black;">
					Physical
				</td>
				<td Colspan="1" width="25%" style="text-align:left; font-size:12px; border-bottom: .5px solid black;">
					Billing
				</td>
		  </tr> 
		  		<td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
			  		Number Of Occupied Units (Start):
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iAptsAvailableStart - OccupiedUnitSummary.iAptsEmptyStart#
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iAptsAvailableStartBilling - OccupiedUnitSummary.iAptsEmptyStartBilling#
		  		</td>
		   <tr>
			   <td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
			  		Number Of Move Ins:
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iMoveIns#
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iMoveInsBilling#
		  		</td>
		   </tr>
		   <tr>
			   <td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
			  		Number Of MOve Outs:
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iMoveOuts#
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iMoveOutsBilling#
		  		</td>
		   </tr>
		   <tr>
			   <td Colspan="1" width="50%" style="text-align:left; font-size:12px; ">
			  		Number Of Occupied Units (End):
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iAptsAvailableEnd - OccupiedUnitSummary.iAptsEmptyEnd#
		  		</td>
		  		<td Colspan="1" width="25%" style="text-align:left; font-size:12px; ">
			  		#OccupiedUnitSummary.iAptsAvailableEndBilling - OccupiedUnitSummary.iAptsEmptyEndBilling#
		  		</td>
		   </tr>
	    </table>
	</cfif>
</cfoutput>
</cfsavecontent>
<cfsavecontent variable="PDFHDR">
			<cfoutput>
			 <table width="100%"  cellspacing="0" cellpadding="0" > 
				<tr>
					<td colspan="1" width="40%"> <img src="../../images/Enlivant_logo.jpg"/ > <br />
					#HouseData.cname# <br />
					#HouseData.Caddressline1#    <br />
					#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
					(#left(Housedata.cphonenumber1,3)#) 					#mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
					</td>
					 <td colspan="1" width="60%" style="text-align:left;font-size:20px; "> <b>Occupied Unit Summary </b> <br/>
					 <cfoutput> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#dateformat((OccupiedUnitSummary.dtRangeStart),'MMMM yyyy')#</cfoutput> <br />
					 <cfoutput>(#dateformat((OccupiedUnitSummary.dtRangeStart),'MM/dd/yyyy')#-#dateformat((OccupiedUnitSummary.dtRangeEnd),'MM/dd/yyyy')#)</cfoutput>
					</td>
				</tr>
				 <!----<tr>
					 <td colspan="1" width="5%">&nbsp;</td>
					 <td colspan="1" width="20%">&nbsp;</td>
					 <td colspan="2"  width="75%" style="text-align:center" >
						<cfoutput> #dateformat((OccupiedUnitSummary.dtRangeStart),'MMMM yyyy')#</cfoutput> <br />
						  <cfoutput>(#dateformat((OccupiedUnitSummary.dtRangeStart),'MM/dd/yyyy')#-#dateformat((OccupiedUnitSummary.dtRangeEnd),'MM/dd/yyyy')#)</cfoutput>
					 </td>
				 </tr>
				 <tr>
					 <td colspan="1" width="5%">&nbsp;</td>
					 <td colspan="1" width="5%">&nbsp;</td>
					 <td colspan="2"  width="80%" style="text-align:left">
						 <cfoutput>(#dateformat((OccupiedUnitSummary.dtRangeStart),'MM/dd/yyyy')#-#dateformat((OccupiedUnitSummary.dtRangeEnd),'MM/dd/yyyy')#)</cfoutput>
						</td>
				</tr>--->
			 </table> 
			  </cfoutput>
		</cfsavecontent>	
		
<cfdocument format="PDF" orientation="portrait" margintop="2">
<cfdocumentsection>
		<cfdocumentitem type="header" evalAtPrint="true">
			<cfoutput>
				#variables.PDFHDR#
			</cfoutput>
		</cfdocumentitem>
		<cfoutput>
			#variables.PDFhtml#
		</cfoutput>
		 <cfdocumentitem  type="footer" evalAtPrint="true">
		<cfoutput>
			<div style="text-align:right;font-size:11px;">
			<br>Printed #DATEFORMAT(now(), "mm/dd/yyyy")# #TimeFormat(Now())#</br>
			<br>Page:#cfdocument.currentpagenumber# of #cfdocument.totalpagecount#</br>
			</div>
		</cfoutput>
	</cfdocumentitem>
		
	</cfdocumentsection>
</cfdocument>
</body>
</html>
	

