<!--------------------------------------->
<!--- Programmer: Andy Leontovich        --->
<!--- File: admin/librarycategories.cfm  --->
<!--- Company: Maxim Group/ALC           --->
<!--- Date: June                         --->
<!--------------------------------------->

<cfset datasource = "DMS">

<cfinclude template="/intranet/header.cfm">

<cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
Select name,visible
From categories
</cfquery>
<ul>
<form action="libraryaction.cfm" method="post">
<table width="400" border="0" cellspacing="0" cellpadding="2">
  <tr bgcolor="#FFFFFF"> 
    <td colspan="3" bgcolor="#006666">&nbsp;<font color="White" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif; font-size: medium;">Add 
      A Library Category</font></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td height="39" width="234"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">New 
      Category</font><font face="Arial, Helvetica, sans-serif"><br>
      <input type="text" name="name" size="40" maxlength="50">
	  <input type="hidden" name="name_required" Value="Please enter a name for the category.">
      <br>
      </font><font size="2"><b><font face="Arial, Helvetica, sans-serif"> 
      <input type="submit" name="Submit" value="Submit Category">
      </font></b></td>
    <td height="39" width="234">
      <table width="78" border="0" cellspacing="3" cellpadding="0">
        <tr align="center"> 
          <td><font size="1" face="Arial, Helvetica, sans-serif">Visible</font></td>
          <td><font size="1" face="Arial, Helvetica, sans-serif">Hidden</font></td>
        </tr>
        <tr> 
          <td align="center"> 
            <input type="radio" name="visible" value="1" checked>
          </td>
          <td align="center"> 
            <input type="radio" name="visible" value="0">
          </td>
        </tr>
      </table>
    <p>&nbsp;</p></td>
    <td width="158"> <font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">Current 
      Categories</font><font face="Arial, Helvetica, sans-serif"><br>
      <select name="currentcategories" size="10" multiple>
       <cfoutput query="getcatagories"> <option value="">#name#...<cfif visible is 1>
			   visible
		<cfelse>
		hidden
		</cfif></option></cfoutput>
      </select>
      </font></b></font></td>
  </tr>
</table>

</ul>
<input type="hidden" name="function" value="1">
<input type="hidden" name="Libselectiontype" value="1">
</form>
<cfinclude template="/intranet/Footer.cfm">
