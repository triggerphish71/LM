<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>

 
<CFINCLUDE TEMPLATE="../../header.cfm">

<TITLE> Tips 4-Admin </TITLE>
</head>
<BODY>
<H1 CLASS="PageTitle"> Tips 4 - Medicaid Payment File</H1>
<CFOUTPUT>

<CFINCLUDE TEMPLATE="../Shared/HouseHeader.cfm">
<form name="Submitpayment" action="MedicaidStateExtractNJ.cfm" method="post">
	<table>
		<tr style="background-color:##CCFFFF">
			<td>Select State</td>
			<td><select  name="statecode">
				<option value="">Select State</option>
				<option value="NJ">New Jersey</option>
				</select>
			</td>
		</tr>
		<tr style="background-color:##FFFFCC">
			<td>Select Billing Period:</td>
			<td>
				<cfset j = 0>
				<select  name="actperiod" multiple="no" >
					<option value="" >Select Period for File </option>
					<option value=" #dateformat(now(),'YYYYMM')#">#dateformat(now(),'YYYYMM')#
					<cfloop  from="1" step="1" to="6" index="j"> 
						<option value=" #dateformat(dateadd('m',-j,now()),'YYYYMM')#"> #dateformat(dateadd('m',-j,now()),'YYYYMM')# </option>
						<cfset j = j + 1>
					</cfloop> 
				</select>  
			</td>
		</tr>
		<tr style=" background-color:##66FF66">
			<td colspan="2" style="text-align:center"><input  type="submit" name="Create Medicaid State Billing File" value="Submit" /> </td>
		</tr>
	</table>
</form>
<CFINCLUDE TEMPLATE='../../Footer.cfm'>
</cfoutput>
</body>
</html>
