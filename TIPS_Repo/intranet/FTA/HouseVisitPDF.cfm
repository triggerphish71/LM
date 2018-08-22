<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
		<title>Untitled Document</title>
	</head>
	<body>
		<cfif url.type is "RDSM">
			<cfheader name="Content-Disposition" value="inline; filename=report.pdf">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/pdf" file="\\fs01\ALC_IT\HouseVisit\BlankHouseVisit_Sales.pdf"> 
		<cfelseif url.type is "RDO">
			<cfheader name="Content-Disposition" value="inline; filename=report.pdf">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/pdf" file="\\fs01\ALC_IT\HouseVisit\BlankHouseVisit_Operations.pdf">
		<cfelseif url.type is "RDQCS">
			<cfheader name="Content-Disposition" value="inline; filename=report.pdf">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/pdf" file="\\fs01\ALC_IT\HouseVisit\BlankHouseVisit-Clinical.pdf">
		<cfelseif url.type is 1>
			<cfheader name="Content-Disposition" value="inline; filename=report.pdf">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/pdf" file="\\fs01\ALC_IT\HouseVisit\BlankHouseVisit_Operations.pdf"> 
		<cfelseif url.type is 2>
			<cfheader name="Content-Disposition" value="inline; filename=report.pdf">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/pdf" file="\\fs01\ALC_IT\HouseVisit\BlankHouseVisit_Sales.pdf">
		<cfelseif url.type is 3>
			<cfheader name="Content-Disposition" value="inline; filename=report.pdf">
			<cfheader name="Expires" value="#Now()#">
			<cfcontent type="application/pdf" file="\\fs01\ALC_IT\HouseVisit\BlankHouseVisit-Clinical.pdf">			
		</cfif>
	</body>
</html>
