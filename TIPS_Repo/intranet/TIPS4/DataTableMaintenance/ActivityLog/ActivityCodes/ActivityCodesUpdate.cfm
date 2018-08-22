

<!--- ==============================================================================
08/02/2017  Ganga Thota - Updating existing record of  Activity type codes

=============================================================================== --->

<cfset cDescription = '#TRIM(form.cDescription)#'>
<CFQUERY NAME = "ActivityCodesUpdate" DATASOURCE = "#APPLICATION.datasource#">
   Update ActivityTypeCodes
         SET  cDescription = '#form.cDescription#'                            
       Where   
             iActivity_ID = #form.aid#          
	
</CFQUERY>

<CFLOCATION URL = "ActivityCodes.CFM">
