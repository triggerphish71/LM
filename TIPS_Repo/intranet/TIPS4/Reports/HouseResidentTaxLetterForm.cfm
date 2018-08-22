
<!--------------------------------------------------------------------------------------------------
| DESCRIPTION   HouseResidentTaxLetter.cfm                                                         |
|--------------------------------------------------------------------------------------------------|
| Provides a summary of Charges and Payments for a given year, from Reports Tab                    |
|--------------------------------------------------------------------------------------------------|
| STORED PROCEDURES: sp_housetaxinfo                                                               |
|--------------------------------------------------------------------------------------------------|
| HISTORY                                                                                          |
|--------------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                            |
|------------|------------|------------------------------------------------------------------------|
| sfarmer    | 03/02/2017 | Change Layout, sp_housetaxinfo updated                                 |
--------------------------------------------------------------------------------------------------->

		<CFQUERY NAME="HouseData" DATASOURCE="#APPLICATION.datasource#">
		SELECT	H.cNumber
		, h.caddressline1
		, h.ccity
		, h.cstatecode
		,h.czipcode
		, h.cname
		,h.cphonenumber1
		, OA.cNumber as OPS
		, R.cNumber as Region
		FROM	House H
		JOIN 	OPSArea OA ON (OA.iOPSArea_ID = H.iOPSArea_ID AND OA.dtRowDeleted IS NULL)
		JOIN 	Region R ON	(OA.iRegion_ID = R.iRegion_ID AND R.dtRowDeleted IS NULL)
		WHERE	H.dtRowDeleted IS NULL	
		AND		iHouse_ID = #SESSION.qSelectedHouse.iHouse_ID#	
	</CFQUERY>	
 
		<cfquery name="sp_housetaxinfo" datasource="#application.datasource#">
			EXEC rw.sp_houseTaxLetter
				@Scope =   '#prompt0#' ,
				@year =   #prompt1# ,
				@tenantID = #prompt2#
		</cfquery> 

<cfsavecontent variable="PDFhtml">
<cfoutput>
<cfheader name="Content-Disposition" value="attachment;filename=ResidentTaxLetter#sp_housetaxinfo.tFullName#_#HouseData.cname#.pdf">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--- <html xmlns="http://www.w3.org/1999/xhtml"> --->
</cfoutput>


<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>House Tax Letter</title>
</head>

<cfif sp_housetaxinfo.recordcount is 0>
		<cfquery name="qResident" datasource="#application.datasource#">
		Select t.clastname, t.cfirstname from tenant t where t.itenant_id = #prompt2#
		</cfquery> 
		

<body>
<table width="95%"  cellspacing="2" cellpadding="2" > 
<tr><td><cfoutput>No information found for #qResident.cfirstname# #qResident.clastname# for #prompt1# please recheck your resident ID selection and year</cfoutput></td></tr>
</table>
</body>
<cfelse> 
<body>
<table width="95%"  cellspacing="2" cellpadding="2" > 
	
	<tr>
		<cfoutput>
		<td colspan="4">#HouseData.cname#    <br />
			#HouseData.Caddressline1#    <br />
			#HouseData.cCity#, #HouseData.cstatecode#  #HouseData.czipcode#    <br />
			(#left(Housedata.cphonenumber1,3)#) #mid(Housedata.cphonenumber1,4,3)#-#right(Housedata.cphonenumber1,4)#
		</td>
		</cfoutput>
	</tr>
	<tr> 
		<div>
		<td colspan="4"><cfoutput>#Dateformat(now(),'mm/dd/yyyy')#</cfoutput></td> 
		</div>
	</tr> 
			<tr>
				<td colspan="4"  >&nbsp;</td>
			</tr>	

		<cfoutput query="sp_housetaxinfo"> 
			<cfif cPayerName is "None">
			<tr><div>
				<td colspan="4">Dear #tFullName#,</td>
				</div>
			</tr>
			<cfelse>
			<tr><div>
				<td colspan="4">Dear #cPayerName#,</td>
				</div>
			</tr>
			</cfif>
			<tr>
				<div>
				<td colspan="4"  >&nbsp;</td>
				</div>
			</tr>	
 
			<tr><div>
				<td colspan="4">The #prompt1# annual invoice total for #tFullName# is listed below:</td>
				</div>
			</tr>
			<div>
			  <p></p>
		  	</div>
			<tr>
				<td width="5%">&nbsp;</td>
				<Td style="text-align:left"><div>Private Room and Board</div></Td>
				<td style="text-align:right">#dollarformat(privateRB)#</td>
				<td width="5%">&nbsp;</td>
			</tr>
			<tr>
			<td width="5%">&nbsp;</td>
				<td style="text-align:left"><div>Private Resident Care</div></td>
				<td style="text-align:right">#dollarformat(privateCare)#</td>
				<td width="5%">&nbsp;</td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>
				<td style="text-align:left"><div>Community Fee/Ancillaries</div></td>
				<td style="text-align:right">#dollarformat(Other)#</td>
				<td width="5%">&nbsp;</td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>
				<td style="text-align:left">&nbsp;</td>
				<td style="text-align:right">____________</td>
				<td width="5%">&nbsp;</td>
			</tr>			
			<p></p>
			<cfset sumtotal =  #privateRB#+#privateCare#+#Other#>
			<tr>
				<td width="5%">&nbsp;</td>
				<td style="text-align:left">Total Charges</td>
				<td style="text-align:right">#dollarformat(sumtotal)#</td>
				<td width="5%">&nbsp;</td>
			</tr>
			<tr>
				<td width="5%">&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td width="5%">&nbsp;</td>
			</tr> 
			<tr>
				<td width="5%">&nbsp;</td>
				<td style="text-align:left; ">Total Payments</td>
				<td style="text-align:right">#dollarformat(Payment)#</td>
				<td width="5%">&nbsp;</td>
			</tr> 			
			<tr>
				<td width="5%">&nbsp;</td>
				<td>&nbsp;</td>
				<td>&nbsp;</td>
				<td width="5%">&nbsp;</td>
			</tr> 
			<tr>
				<div>
				<td colspan="2"  >&nbsp;</td>
				</div>
			</tr>
		
			<tr>
				<div>
				<td colspan="2"  >Sincerely,</td>
				</div>
			</tr>
 			<tr>
				<div>
				<td colspan="2"  >&nbsp;</td>
				</div>
			</tr>
			<tr>
				<div>
				<td colspan="2"  >&nbsp;</td>
				</div>
			</tr>
 			<tr>
				<div>
				<td colspan="2"  >&nbsp;</td>
				</div>
			</tr>  
			<tr>
				<td colspan="2" ><div>Executive Director</div></td>
			</tr>
			<tr>
				<td colspan="2" >#HouseData.cname#</td>
			</tr>
    </cfoutput> 
</table> 

<div><p></p></div>
<div><p></p></div>


</body>
</cfif>
</html>
</cfsavecontent>

<cfdocument format="PDF" orientation="portrait" margintop="1.5" marginbottom="2" >
 <cfdocumentitem type="header"> 
	<table>
	<tr>
	 <img src="../../images/Enlivant_logo.jpg"/>
	 </tr>
	 </table>
	 <table>
	 </table>
 </cfdocumentitem>
 <cfdocumentitem type="footer" > 
<div align="center"> <font color="black" size="1" face="Tahoma"> 
	<cfoutput>Enlivant provides this statement of charges invoiced in #prompt1# as a courtesy to its residents and <br />
	family members. Enlivant does not assume any responsibility, and makes no representation or<br />
	warranty with respect to accuracy of the data contained in this statement. You are responsible<br />
	for your personal tax return and should consult with your tax professional on the utilization<br />
	of any information contained within this document. </cfoutput> 
</cfdocumentitem>   
 
 
  <cfoutput>
    #variables.PDFhtml#
  </cfoutput>

</cfdocument>
 
