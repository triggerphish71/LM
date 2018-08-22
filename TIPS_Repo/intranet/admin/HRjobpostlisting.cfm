<!--------------------------------------->
<!--- Programmer: Andy Leontovich     --->
<!--- File: HRjobpostlisting         --->
<!--- Company: Maxim Group/ALC        --->
<!--- Date: July                       --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfquery name="getlisting" datasource="#datasource#" dbtype="ODBC">
Select distinct joblistings.Form_Ndx,jobtoc.heading,joblistings.jobtitle,vw_houses.housename,vw_regions.regionname,joblistings.activedate,joblistings.closedate
From joblistings,jobtoc,vw_regions,vw_houses
Where joblistings.nregionnumber = vw_regions.nregionnumber
AND joblistings.nhouse = vw_houses.nhouse
AND joblistings.tocid = jobtoc.toc_ndx
AND joblistings.nregionnumber = #url.region#
AND hractive = #url.locat#
</cfquery>
<cfinclude template="/intranet/header.cfm">
<ul>
<form action="HRreview.cfm" method="post">
<table width="658" cellspacing="2" cellpadding="2" border="0">
<tr bgcolor="#336699">
    <td colspan="7"><font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Posting Queue</font></td>
</tr>
<tr>
    <td height="5" colspan="7"></td>
</tr>
<cfif getlisting.recordcount is 0>
<tr bgcolor="#f7f7f7">
    <td height="5" colspan="7"><BR><ul><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">There are no postings in the queue for this region.</font></ul></td>
</tr>
<tr bgcolor="#eaeaea">
    <td height="5" colspan="7"><input type="button" name="back" value="Back" onFocus="history.back();"></td>
</tr>
<cfelse>

<tr bgcolor="#eaeaea">
	<td align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">View</font></td>
    <td align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Region</font></td>
    <td align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Category</font></td>
    <td align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Position</font></td>
    <td align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">House</font></td>
    <td width="60" align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Active Date</font></td>
    <td width="60"  align="center"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Close Date</font></td>
</tr>
<cfset rowcolorcounter = 1>
<cfoutput query="getlisting">
	
	<cfset linecount = rowcolorcounter mod 2>
			<cfif linecount is 0>
	          	<TR bgcolor="##f7f7f7"> 
			<cfelse>
				<TR bgcolor="##ffffff"> 
			</cfif>
	<cfset rowcolorcounter = rowcolorcounter+1>

	<td align="center"><A HREF="HRreview.cfm?index=#Form_Ndx#&locat=#url.locat#"><img src="/intranet/pix/view.gif" width="23" height="22" alt="" border="0"></A></td>
	<td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">#regionname#</font></td>
    <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">#heading#</font></td>
    <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">#jobtitle#</font></td>
    <td><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">#housename#</font></td>
    <td width="60" ><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">#DateFormat(activedate)#</font></td>
    <td width="60"><font style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: xx-small;">#DateFormat(closedate)#</font></td>
</tr>
</cfoutput>
<tr bgcolor="#eaeaea">
	<td colspan="7"><input type="button" name="back" value="Back" onClick="history.back();"></td>
</tr>
</cfif>
</table>

</form>

</ul>




<cfinclude template="/intranet/Footer.cfm">
</body>
</html>
