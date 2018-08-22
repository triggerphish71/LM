<cfinclude template="/intranet/header.cfm">
<UL>
<table width="400" border="0" cellspacing="2" cellpadding="4">
  <tr bgcolor="#993333"> 
    <td><font color="#FFFFFF" size="4" face="Arial, Helvetica, sans-serif">&nbsp;Alert!</font></td>
  </tr>
  <tr bgcolor="#f7f7f7"> 
    <td> 
      <blockquote>
        <p><font size="2" face="Arial, Helvetica, sans-serif"><b>Are you sure 
          you want to remove the file: #filename#, from #heading# in #location#? 
          </b></font></p>
        <p><font size="2" face="Arial, Helvetica, sans-serif">The file will be 
          archived in the system and will still be accessible but it will not 
          show up as part of the intranet content</font><font face="Arial, Helvetica, sans-serif">.</font></p>
      </blockquote>
    </td>
  </tr>
  <tr bgcolor="#eaeaea"> 
    <td>&nbsp; 
      <input type="submit" name="Submit" value="Archive the Document">
    </td>
  </tr>
</table>
</UL>
</body>
</html>
<cfinclude template="/intranet/Footer.cfm">