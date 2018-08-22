<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
</body>
</html>
		<tr>
			<td COLSPAN="4">
				The RDO email for this Region (#qryRegion.region#) is #session.RDOEmail#, Division is #qryRegion.division#.

			</td>
		</tr>	
	<cfelse>
	<tr>
		<td COLSPAN="4" style=" font-size:large; color:##FF0000#;">
			No RDO email available for this region, contact the support desk to update this information to continue.
		</td>
	</tr>
	</cfif>	
