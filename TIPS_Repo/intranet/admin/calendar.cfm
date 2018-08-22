<!--- ***********************************************************************

PURPOSE:  	Build Calendar based on Start Date or if the is no data passed then based on 
			current date.
			
DEVELOPER:	Greg Farris
			greg.farris@farrisconsulting.com			
			
______________________________________________________			
Copyright 1997 - Farris Consulting
Feel free to "steal" this code provided that you leave this notice as is.			
******************************************************************************--->
<CFIF #ParameterExists(URL.startdate)#>
	<CFSET #CalendarDate# = #URL.startdate#>
<CFELSE>
	<CFSET #CalendarDate# = Now()>
</CFIF>

<CFSET #PrevMonthString# = #MonthAsString(DatePart("m",#DateAdd("m", -1,"#CalendarDate#")#))#>
<CFSET #PrevMonth# = #DateFormat(#DateAdd("m", -1,"#CalendarDate#")#, "mm/dd/yy")#>

<CFSET #NextMonthString# = #MonthAsString(DatePart("m",#DateAdd("m", 1,"#CalendarDate#")#))#>
<CFSET #NextMonth# = #DateFormat(#DateAdd("m", 1,"#CalendarDate#")#, "mm/dd/yy")#>

<CFSET #Month# = #MonthAsString(DatePart("m",#CalendarDate#))#>
<CFSET #MonthNum# = #Month(#CalendarDate#)#>
<CFSET #Year# =#DatePart("yyyy",#CalendarDate#)#>
<CFSET #NumOfDays# = #DaysInMonth(#CalendarDate#)#>
<CFSET #DayOfWeek# = #DayOfWeek(#CalendarDate#)#>
<CFSET #DayNum# = #Day(#CalendarDate#)#>
<CFSET #FirstDay# =  #DayOfWeek(#MonthNum# & "/1/" & #Year#)#> 
<CFSET #NumberOfRows# = ((#FirstDay# + #NumOfDays# )/ 7) + 1>
<CFSET #FirstRowCount# = 1>
<CFSET #count# = 1>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>

<SCRIPT LANGUAGE="JavaScript">
<!--
function adddate(thedate)
{
	var holder;
	formated_date = <CFOUTPUT>#MonthNum#</CFOUTPUT> + "/" + thedate + "/" + <CFOUTPUT>#Year#</CFOUTPUT>;
// look inside the window scope to find the defined variable.
 	if (opener.datebranch == 1)
		opener.document.resourcerec.postdate.value=formated_date;
		
	else if(opener.datebranch == 2)
		opener.document.resourcerec.expirationdate.value=formated_date;
		
		else if(opener.datebranch == 3)
		opener.document.resourcerec.userexpirationdate.value=formated_date;
	//else if (opener.datebranch == 3)
	//{
	//holder = "opener.document.resourcerec.expirationdate.value = formated_date;";
		//eval (holder);
	//}	
	
	//if(opener.datebranch == 2)
	//{
	//	daterange();
	//}
	
	self.close();
}

function daterange()
	{
	
	var datetostring = opener.document.resourcerec.datefrom.value;
	var datefromstring = opener.document.resourcerec.dateto.value;
	
	datetoArray = datetostring.split("/");
	datefromArray = datefromstring.split("/");

		if(datetoArray[1] > datefromArray[1])
		{
		alert("The DateTo entry is smaller than the DateFrom entry. Please select a date that is equal to, or larger than the DateTo entry.");
		}
	}



//-->
</SCRIPT>
	<TITLE><CFOUTPUT> #Month#</CFOUTPUT> Calendar </TITLE>

	<link rel=stylesheet type="text/css" href="alloc.css">
</HEAD>

<BODY BGCOLOR=#FFFFFF WIDTH=90%>
<CENTER>
<TABLE BORDER=0 CELLPADDING=2 CELLSPACING=2 WIDTH=294>

<TR>
<td align="CENTER" bgcolor="#eaeaea"><CFOUTPUT><FONT SIZE="2"><A HREF="calendar.cfm?startdate=#PrevMonth#">#PrevMonthString#</A></FONT></CFOUTPUT></TD>
<TD COLSPAN=5 ALIGN=center BGCOLOR="#ffffcc">
<FONT SIZE="3"><CFOUTPUT><B>#Month# #Year#</B> </CFOUTPUT></FONT>
</TD>
<td align="CENTER" bgcolor="#eaeaea"><CFOUTPUT><FONT SIZE="2"><A HREF="calendar.cfm?startdate=#NextMonth#">#NextMonthString#</A></FONT></CFOUTPUT></TD>
</TR>
<TR BGCOLOR="#336699" ALIGN=center>
<TD><B><font face="Verdana" size="2" color="White">Sun</FONT></B></TD>
<TD ><B><font face="Verdana" size="2" color="White">Mon</FONT></B></TD>
<TD><B><font face="Verdana" size="2" color="White">Tues</FONT></B></TD>
<TD><B><font face="Verdana" size="2" color="White">Wed</FONT></B></TD>
<TD><B><font face="Verdana" size="2" color="White">Thurs</FONT></B></TD>
<TD><B><font face="Verdana" size="2" color="White">Fri</FONT></B></TD>
<TD><B><font face="Verdana" size="2" color="White">Sat</FONT></B></TD>

</TR>


<CFLOOP INDEX="row" FROM="1" TO="#NumberOfRows#">
	
	<TR>
	<CFLOOP INDEX="cell" FROM="1" TO="7">

		<CFIF #count# GT #NumOfDays# >
			<CFBREAK>
		</CFIF>		
		<CFIF #FirstRowCount# LT #FirstDay#>	
				<CFOUTPUT><td width="40" align="RIGHT" valign="TOP" bgcolor="##ffffff">&nbsp;</TD></CFOUTPUT>
				<CFSET #FirstRowCount# = #IncrementValue(FirstRowCount)#>	
		<CFELSE>
			<CFOUTPUT>
			
			<CFIF #count# IS #DayNum# AND #Month(#Now()#)# IS #MonthNum# AND #Year# IS  #DatePart("yyyy",#Now()#)#>

			
				<TD WIDTH=40 VALIGN=top ALIGN=right bgcolor="##ffffcc">
				<B><A HREF=javascript:adddate(#count#)><FONT SIZE="2">#count#</FONT></A></B>
				</TD>
			
			<CFELSE>
					<TD  WIDTH=40  VALIGN=top ALIGN=right bgcolor="##eaeaea">
					<B>
					<A HREF=javascript:adddate(#count#)><FONT SIZE="2">#count#</FONT></A>
					</B>
					
						</TD>
			</CFIF>
			</CFOUTPUT>
			<CFSET #count# = #IncrementValue(count)#>
		</CFIF>
				

	</CFLOOP>
	</TR>
</CFLOOP>
</TABLE>
</CENTER>
<FORM>
<!--- <CENTER><INPUT TYPE="BUTTON" VALUE="Close" onClick=self.close()></CENTER> --->

</FORM>
<CFOUTPUT>#CalendarDate#</CFOUTPUT>
</BODY>
</HTML>
