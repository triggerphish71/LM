<CFINCLUDE TEMPLATE="../../header.cfm">
<!--- 11/20/2013 Sfarmer 102505 c:\ chg to e:\ for move to CF01 --->
<CFOUTPUT>

<!--- <CFREPORT REPORT="c:\Inetpub\wwwroot\intranet\TIPS4\Reports\validation.rpt" --->
<CFREPORT REPORT="e:\Inetpub\wwwroot\intranet\TIPS4\Reports\validation.rpt"
DATASOURCE="F_TIPS4"
USERNAME="rw"  
PASSWORD="4rwriter"
>  
</CFREPORT>  

</CFOUTPUT>

<CFINCLUDE TEMPLATE="../../footer.cfm">
