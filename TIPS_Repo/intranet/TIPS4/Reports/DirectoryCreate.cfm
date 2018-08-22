<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>

<body>
<cfset createDirectory = "\\fs01\ALC_IT\Invoices\Allen Place\">
<cfif DirectoryExists(createDirectory)>
OK
<cfelse>
         <cftry> 
           <cfdirectory  action="create" directory="#createDirectory#" >  
            <cfoutput><b>Directory #createDirectory# successfully created.</b></cfoutput> 
         <cfcatch> 
             <b>Error Message:</b><cfoutput>#cfcatch.message#</cfoutput><br/> 
            <b>Error Detail:</b><cfoutput>#cfcatch.Detail#</cfoutput> 
         </cfcatch> 
        </cftry> 
</cfif>
</body>
</html>
