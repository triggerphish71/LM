
<cfset datasource = "DMS">

<cfinclude template="/header.cfm">
<cfquery name="gettopics" datasource="#datasource#" dbtype="ODBC">
Select name,visible
From topics
</cfquery>

<cfquery name="getcatagories" datasource="#datasource#" dbtype="ODBC">
Select name,visible,uniqueid
From categories
</cfquery>
<form action="libraryaction.cfm" method="post">
<ul><table width="400" border="0" cellspacing="0" cellpadding="2">
  <tr  bgcolor="#006666"> 
    <td colspan="3"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#FFFFFF">&nbsp;<font size="4">Add A Library 
      Topic</font></font></b></font></td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td width="283"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">New 
      Topic</font><font face="Arial, Helvetica, sans-serif"><br>
      <input type="text" name="name" size="40" maxlength="50">
	   <input type="hidden" name="name_required" Value="Please enter a name for the topic.">
      </font></b></font></td>
    <td height="39" width="283">
      <BR><table width="78" border="0" cellspacing="3" cellpadding="0">
        <tr> 
          <td align="center"><font face="Arial, Helvetica, sans-serif" size="1">Visible</font></td>
          <td align="center"><font face="Arial, Helvetica, sans-serif" size="1">Hidden</font></td>
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
    </td>
    <td rowspan="3"> <font color="#666666" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Current Topics</font> <font face="Arial, Helvetica, sans-serif"><br>
      <select name="currentTopics" size="10" multiple>
	  <cfif gettopics.recordcount is 0>
	   <option value="">None available</option>
	<cfelse>
        <cfoutput query="gettopics"><option value="">#name#...<cfif visible is 1>
			   visible
		<cfelse>
		hidden
		</cfif></option>
		</cfoutput>
		
		</cfif> 
      </select>
      </font></b></font>
	 
	 </td>
  </tr>
  <tr> 
    <td width="566" bgcolor="#eaeaea" colspan="2"><font size="2"><b><font face="Arial, Helvetica, sans-serif" color="#666666">Assign 
      to Category</font><font face="Arial, Helvetica, sans-serif"><br>
      <select name="categoryid">
       <cfoutput query="getcatagories"> <option value="#uniqueid#">#name#</option></cfoutput>
      </select>
      </font></b></font></td>
  </tr>
  <tr> 
    <td width="566" bgcolor="#eaeaea" colspan="2"> <font size="2"><b><font face="Arial, Helvetica, sans-serif"> 
      <input type="submit" name="Submit" value="Submit Topic">
      </font></b></font></td>
  </tr>
</table></ul>
<input type="hidden" name="function" value="1">
<input type="hidden" name="Libselectiontype" value="2">
</form>
<cfinclude template="/intranet/Footer.cfm">