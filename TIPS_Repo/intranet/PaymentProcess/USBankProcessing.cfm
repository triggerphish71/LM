<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Payment Process</title>
</head>

<body>

<cftry>
	<cffile  action = "upload" destination = "temp.txt" fileField = "form.uploadfile" nameConflict = "overwrite" accept="text/plain">

	<cfcatch type="any">
		<center>
			<h1>
				There was an issue uploading your file to the server.<br />
				It is either not in the location provided or it is being locked by yourself or another user.
			</h1>
			<br />
			<a href="Index.cfm">Try Again</a>
		</center>
		<cfabort>
	</cfcatch>
</cftry>

<cfset variables.data = 'X'>

<cftry>
	<cffile action = "read" file = "#GetTempDirectory()#\temp.txt" variable = "variables.data">

	<cfcatch type="any">
		<center>
			<h1>
				There was an issue reading the uploaded file, please contact IT Support.<br />
				<a href="Index.cfm">Back to Main Menu</a>
			</h1>
		</center>
		<cfabort>
	</cfcatch>
</cftry>	
	

<cfquery name="ClearPaymentTable" datasource="TIPS4">
	Delete from USBankPayments
</cfquery>


<cftry>
	<cfset variables.AllQueries = '' >
	<cfset counter = 0>
	<cfloop condition="variables.data neq ''">
		<cfset counter = counter + 1>
		<cfset variables.EOL = #find(chr(13),variables.data,1)#>
		<cfset variables.LINE = Mid(variables.data,1,variables.EOL)> 
		<cfset variables.data = mid(variables.data,variables.EOL+2,len(variables.data))>
		<cfset variables.Query = "Insert into USBankPayments values (">
		<cfset variables.EndOfName = find(",",line,60)>
		<cfset variables.Query = variables.Query 
			& "'" & mid(line,1,5) & "','" 
			& mid(line,7,4)   & "','" 
			& mid(line,12,4)  & "','" 
			& mid(line,17,8)  & "','" 
			& mid(line,26,10) & "','" 
			& mid(line,37,10) & "','"
			& mid(line,48,10) & "','"  
			& mid(line,59,variables.EndOfName-60) & "','"
			& mid(line,variables.EndOfName+1,10)  & "','"
			& mid(line,variables.EndOfName+12,14)  & "');">
			
		<cfset variables.AllQueries = variables.AllQueries & variables.Query>
		
		<cfif counter mod 100 eq 0 or variables.data eq ''>
			<cfquery name="AddToTable" datasource="TIPS4">
				#PreserveSingleQuotes(variables.AllQueries)#
				
			</cfquery>
			<cfset variables.AllQueries = '' >	
		</cfif>
	</cfloop>

	<cfcatch type="any">
		<center>
			<h1>
				There were Issues reading the data from your file.<br />
				Please verify that the file is in the correct format for reading.<br />
				<a href="Index.cfm">Try Again</a>
			</h1>
		</center>
		<cfabort>
	</cfcatch>
</cftry>

<cfquery name="UpdateHouseGLCode" datasource="TIPS4">
	update USBankPayments
	set HouseNumber = substring(cGLsubaccount,7,3)
	from house h
	join tenant t on t.ihouse_id = h.ihouse_id
	join USBankPayments USP on cast(USP.Solomonkey as int) = cast(t.cSolomonkey as int)
</cfquery>

<cfquery name="GetNewRecords" datasource="TIPS4">
	Select * from USBankPayments
</cfquery>

<cfset variables.MissedUpdates = 0>
<cfoutput query="GetNewRecords">
	<cfscript>
		variables.row = #Batch#
			& "," & #SequenceNumber# 
			& "," & #HouseNumber#
			& "," & #trim(Solomonkey)#
			& "," & #Tran_Amount1#
			& "," & #Tran_Amount2#
			& "," & #CheckNumber#
			& "," & #PayerName#
			& "," & #TranDate#
			& "," & #TraceParNumber#;
		
		if (len(HouseNumber) eq 4)
			variables.MissedUpdates = variables.MissedUpdates +1;
			
	</cfscript>

	<cffile action="append" destination="GetTempDirectory()" file="Final.txt" output="#variables.row#">

</cfoutput>




Your new file is ready!<br /><br />
<a href="download.cfm">Click Here</a> to retrieve your new file.<br /><br />

<cfoutput>
	<cfif variables.MissedUpdates gt 0>
		<strong>WARNING!</strong>: <br /><br />
		Please review your file, as <strong>#variables.MissedUpdates#</strong> House Number(s) did not get updated.<br />
	</cfif>

	<cfset currentPath = getCurrentTemplatePath()>
	<cfset currentDirectory = getDirectoryFromPath(currentPath)>
	<cffile action="move" destination="#currentDirectory#" source="#GetTempDirectory()#Final.txt">
	<br />
	
</cfoutput>

<cfquery name="BadRecords" datasource="TIPS4">
	Select cast(SequenceNumber as int) SequenceNumber 
	From USBankPayments
	where len(HouseNumber) = 4
</cfquery>


<cfif BadRecords.recordcount gt 0>
	The Following records did not get updated:<br />
	<br />
	<cfoutput query="BadRecords">
		#SequenceNumber#<br />
	</cfoutput>
</cfif>
   
<br /><br />
<a href="Index.cfm">Back to Main Menu</a>
 
</body>
</html>
