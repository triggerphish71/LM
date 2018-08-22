
<CFOUTPUT>
	<CFLOOP INDEX='field' LIST='#form.fieldnames#' DELIMITERS=",">
		<!--- #field# #evaluate('form.' & field)#  --->
		<CFSET pos = FindNoCase('_',field,1)>
		<CFSET num = MID(field, pos+1, (len(field) - pos) )>
		<CFIF isNumeric(num) EQ 'true'> 
			<CFIF Evaluate('form.CHARGE_' & num) NEQ Evaluate('form.OLD_' & num)> 
				#field# #evaluate('form.' & field)# <BR>
			</CFIF>
		</CFIF>
	</CFLOOP>
</CFOUTPUT>