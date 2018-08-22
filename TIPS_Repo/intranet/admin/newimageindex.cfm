
<cfquery name="getcurrentindex" datasource="DMS" dbtype="ODBC">
	Select distinct path
	From acctdoc_new
	Order By path
</cfquery>
<cfset datasource = "DMS">

<cfparam name="submit" default="Index another directory">

<cfif submit is "Index another directory">

	<cfdirectory action="LIST" directory="G:\scannedimages" name="imagedirs">

	<ul>
	<form action="/intranet/documentimaging/newimageindex.cfm" method="post">
	<table width="520" cellspacing="2" cellpadding="2" border="0">
	<tr bgcolor="#008080">
	    <td colspan="2">&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Index Upload</font></td>
	</tr>
	<tr bgcolor="#f7f7f7">
	    <td>
		<ul>
		<BR>
		<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Select a directory to index.</font>
		<BR>
		<select name="dir" size="1">
			<cfoutput query="imagedirs">
			<cfif name is not "." AND name is not "..">
			<option value="#name#">#name#</option>
			</cfif>
			</cfoutput>
		</select>
		</ul>
		</td>
		<td align="center">
			<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">Currently Indexed:</font><BR>
			<cfset showindex = 0>
			<select name="" size="10">
				<cfoutput query="getcurrentindex">
				<cfset indexdir = listgetat(path,1,"\")>
				<cfif indexdir is not showindex>
					<option value="">#indexdir#</option>
				</cfif>
				<cfset showindex = indexdir>
				</cfoutput>
			</select>
		</td>
	</tr>
	<tr bgcolor="#eaeaea">
	    <td colspan="2"><input type="submit" name="Submit" value="Begin Indexing"></td>
	</tr>
	</table>
			<input type="hidden" name="page" value="1">
</form>
</ul>

<cfelseif submit is "Begin Indexing">

<cfdirectory action="LIST" directory="G:\scannedimages\#dir#" name="images">
<cfoutput query="images"><!--- the main loop --->
	<cfif name is not "." AND name is not "..">
		<cfset nhouse2 = listgetat(name,1,"-")>
		<cfset nhouse = Right(nhouse2,3)>
		<cfset file = listgetat(name,2,"-")>
		<!--- 	<cfset nhouse =nhouse> --->
		<cfset checknum = listgetat(file,1,".")>
<!---------------- data for tempdocs -------------------------------------------------->
		<!--- comment:find document-imaging and convert to documentimaging--->
		
	<cfquery name="insertrecord" datasource="DMS" dbtype="ODBC">
	Insert into tempdocs(housenum,checknum,path)
	Values(#nhouse#,'#Trim(checknum)#','#dir#\#file#')
	</cfquery>

<!---------------- end data from Solomon -------------------------------------------------->
	</cfif>
</cfoutput>

<!--- comment: update acctdocs with temp data from tempdocs table---------------------------------------->
<cfquery name="updateaccts" datasource="#datasource#" dbtype="ODBC">
	exec im_index
</cfquery>

<!--- comment: End update acctdocs with temp data from tempdocs table---------------------------------------->
<form action="/intranet/documentimaging/newimageindex.cfm" method="post">
<ul>
	<table width="400" cellspacing="2" cellpadding="2" border="0">
		<tr bgcolor="#008080">
		    <td colspan="2">&nbsp;<font color="White" style="font-family: Arial, Helvetica, sans-serif; font-size: small; font-weight: bold;">Indexing Complete</font></td>
		</tr>
		<tr bgcolor="#f7f7f7">
		    <td>
				<ul>
					<font color="#5a5a5a" style="font-family: Arial, Helvetica, sans-serif; font-size: x-small; font-weight: bold;">The records were added to the system.</font>
				</ul>
			</td>
		</tr>
		<tr bgcolor="#eaeaea">
			<input type="hidden" name="page" value="0">
		    <td>
				<input type="submit" name="Submit" value="Index Another Directory">
			</td>
		</tr>
	</table>
	</ul>
</form>
</cfif>







