<!----------------------------------------------------------------------------------------------
| DESCRIPTION                                                                                  |
|----------------------------------------------------------------------------------------------|
|                                                                                              |
|----------------------------------------------------------------------------------------------|
| STORED PROCEDURES                                                                            |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| INCLUDES                                                                                     |
|----------------------------------------------------------------------------------------------|
|  none                                                                                        |
|----------------------------------------------------------------------------------------------|
| HISTORY                                                                                      |
|----------------------------------------------------------------------------------------------|
| Author     | Date       | Description                                                        |
|------------|------------|--------------------------------------------------------------------|
| ranklam    | 11/16/2005 | Added flowerbox                                                    |
| ranklam    | 01/15/2008 | Took report off intranet page becuase of a problem with linked     |
             |            | server.                                                            |
----------------------------------------------------------------------------------------------->

<div style="color:ff0000;font-size:18px;font-weight:bold">Assessment tool reports is down for maintenance.  It will be available soon! </div>
<cfabort>

<cfoutput>
	<!--- fzahir changed the condition to include Moved Out Residents --->
<!--- retrieve current resident list and information --->
<cfquery name="qResidents" datasource="#application.datasource#">
select distinct ad.captnumber, t.csolomonkey ,t.clastname ,t.cfirstname ,t.itenant_id ,ts.ispoints ,st.cdescription as level
,ts.dtmovein ,ts.dtmoveout ,ts.itenantstatecode_id, ts.iresidencytype_id, ts.ispoints, rs.iresident_id
from tenant t
join tenantstate ts on ts.itenant_id = t.itenant_id and t.dtrowdeleted is null and ts.dtrowdeleted is null
<cfif isDefined("url.mo")>
	and ts.itenantstatecode_id IN (3,4) 	
<cfelse>
	and ts.itenantstatecode_id <= 2
</cfif> 
and t.bIsMedicaid is null and t.bIsMisc is null
join house h on h.ihouse_id = t.ihouse_id and h.dtrowdeleted is null
left join aptaddress ad on ad.ihouse_id = h.ihouse_id and ad.iaptaddress_id = ts.iaptaddress_id
and ad.dtrowdeleted is null
left join sleveltype st on st.csleveltypeset = t.csleveltypeset and st.dtrowdeleted is null
and ts.ispoints between st.ispointsmin and st.ispointsmax
left join #Application.LeadTrackingDBServer#.leadtracking.dbo.residentstate rs on rs.itenant_id = t.itenant_id and rs.dtrowdeleted is null
where t.ihouse_id = #session.House.GetId()#
order by ts.itenantstatecode_id ,ad.captnumber,clastname
</cfquery>


<!--- retrieve current inquiry list and information --->
<cfquery name="qInquiryResidents" datasource="#application.datasource#">
	select distinct r.clastname, r.cfirstname, r.iresident_id
	from #application.leadtrackingdbserver#.leadtracking.dbo.resident r
	join #application.leadtrackingdbserver#.leadtracking.dbo.residentstate rs on rs.iresident_id = r.iresident_id and rs.dtrowdeleted is null
	join #application.leadtrackingdbserver#.leadtracking.dbo.status s on s.istatus_id = rs.istatus_id and s.dtrowdeleted is null
	join house h on h.ihouse_id = rs.ihouse_id and h.dtrowdeleted is null
	join sleveltype st on st.csleveltypeset = h.csleveltypeset and st.dtrowdeleted is null
	and s.istatus_id not in (5,6)
	where r.dtrowdeleted is null
	<cfif not isDefined("url.mo")> and rs.ihouse_id = #session.House.GetId()# <cfelse> and rs.ihouse_id = '' </cfif>	
	order by clastname
</cfquery>

<!--- retrieve current tools --->
<cfquery name="qtools" datasource="#application.datasource#">
	select 
		 iassessmenttool_id 
		,cdescription 
	from 
		assessmenttool 
	where 
		dtrowdeleted is null
	order by 
		cdescription
</cfquery>
<cfabort>
<!--- retrieve all current valid assessments --->
<cfquery name="qvalid" datasource="#application.datasource#">
	select distinct isNull(t.clastname,r.clastname) clastname
		,isNull(t.cfirstname,r.cfirstname) cfirstname
		,t.itenant_id
		,r.iresident_id
		,convert(char(10), dtreviewstart, 101) dtreviewstart
		,rtrim(isNull(convert(char(10), dtreviewend, 101),'Open')) dtreviewend
		,am.iassessmenttoolmaster_id
		,am.bbillingactive
		,am.dtbillingactive
		,am.bfinalized
		,isNull(sum(isNull(sl.fweight,sb.fweight)),0) as totalpoints
	from assessmenttoolmaster am
	join assessmenttooldetail ad on ad.iassessmenttoolmaster_id = am.iassessmenttoolmaster_id and ad.dtrowdeleted is null
	left join servicelist sl on sl.iservicelist_id = ad.iservicelist_id and sl.dtrowdeleted is null
	left join subservicelist sb on sb.isubservicelist_id = ad.isubservicelist_id and sb.dtrowdeleted is null
	join assessmenttool att on att.iassessmenttool_id = am.iassessmenttool_id and att.dtrowdeleted is null
	left join tenant t on t.itenant_id = am.itenant_id and t.dtrowdeleted is null
	left join tenantstate ts on ts.itenant_id = t.itenant_id and ts.dtrowdeleted is null
	and ts.itenantstatecode_id  in (1,2)
	left join #Application.LeadTrackingDBServer#.LeadTracking.dbo.resident r on r.iresident_id = am.iresident_id and r.dtrowdeleted is null
	left join #Application.LeadTrackingDBServer#.LeadTracking.dbo.residentstate rs on rs.iresident_id = r.iresident_id and rs.dtrowdeleted is null
	left join #Application.LeadTrackingDBServer#.LeadTracking.dbo.status s on s.istatus_id = rs.istatus_id and s.dtrowdeleted is null
	where am.dtrowdeleted is null and (t.itenant_id is not null or r.iresident_id is not null)
	and (t.ihouse_id = #session.House.GetId()# or rs.ihouse_id = #session.House.GetId()#)
	group by 
		isNull(t.clastname,r.clastname) 
		,isNull(t.cfirstname,r.cfirstname) 
		,t.itenant_id
		,r.iresident_id
		,convert(char(10), dtreviewstart, 101) 
		,rtrim(isNull(convert(char(10), dtreviewend, 101),'Open'))
		,am.iassessmenttoolmaster_id
		,am.bbillingactive
		,am.dtbillingactive
		,am.bfinalized
	order by isNull(t.clastname,r.clastname) 
		,isNull(t.cfirstname,r.cfirstname) 
		,am.bbillingactive desc
		,am.bfinalized desc
</cfquery>

<script type="text/javascript" src="/CFIDE/scripts/wddx.js"></script>
<script>
<cfwddx action="cfml2js" input="#qvalid#" topLevelVariable="qvalidJS">
<cfwddx action="cfml2js" input="#qResidents#" topLevelVariable="qResidentsJS">
<cfwddx action="cfml2js" input="#qInquiryResidents#" topLevelVariable="qInquiryResidentsJS">

//this function initalizes all the variables used for this pages scripts
function initial()
{ 
	//df0 is a variable that holds the form on this page
	df0 = document.getElementsByName('reportsForm')[0];
	//call the populate residents function
	popresidents(); 
	//set the a variable to the house name
	hname='#session.qselectedhouse.cname#';
	//call the alist function with residents 
	alist(df0.residents); 
	//call the test opener function
	testopener(); 
}

//makes sure there is a qResidentsJs variable (i guess)
function testopener() 
{ 
	try 
	{ 
		//set a variable equal to the qresidentsjs from the cfwddx
		residents=qResidentsJS; 
	} 
	catch (exception) 
	{ 
		window.close(); 
		return true; 
	}
	//tells this function to time out afer 5 seconds
	setTimeout("testopener()",500); 
}

//populate the residents variable of df0
function popresidents()
{
	try 
	{ 
		//set some variables equal to the resutls of the queries
		residents=qResidentsJS;
		inquiries=qInquiryResidentsJS; 
	}
	catch (exception) 
	{ 
		window.close(); 
		return true; 
	}

	ai=0;
	
	//rsa - 11/16/05 - changed the contitional statement  for this loop, previously was i=0; i <= residents['itenant_id'].length-1; i++
	for (i=0; i < residents['itenant_id'].length; i++)
	{
		if (qvalidJS['itenant_id'].toString().indexOf(residents['itenant_id'][i]) !== -1 ) 
		{
			df0.residents.options[ai] = new Option(residents['clastname'][i]+', '+residents['cfirstname'][i], 't_'+residents['itenant_id'][i]);
			df0.residents.options[ai].style.color='black';
			ai++;
		}
	}
	
	//rsa - 11/16/05 - this is where the problem might be, he had count = 0 then was creating a new option there.
     //			    the count should have started where the previous loop left off so no options were overwritten
	count=ai;

	//rsa - 11/16/05 - changed the contitional statement  for this loop, previously was i=0;i <= inquiries['iresident_id'].length-1; i++
	//                 but this way does same thing much cleaner
	for (i=0;i < inquiries['iresident_id'].length; i++)
	{
		if (qvalidJS['iresident_id'].toString().indexOf(inquiries['iresident_id'][i]) !== -1 ) 
		{
			df0.residents.options[count] = new Option(inquiries['clastname'][i]+', '+inquiries['cfirstname'][i], 'r_'+inquiries['iresident_id'][i]);
			df0.residents.options[count].style.color='blue';
			count++;
		}
	}
}

function alist(obj)
{ 
	v = obj.value.split('_');
	val = v[1];
	ind = obj.value.indexOf("t_");
	cnt = 0;
	df0.iassessmenttoolmaster_id.options.length=qvalidJS['iassessmenttoolmaster_id'].length;

	for(a = 0; a <= df0.iassessmenttoolmaster_id.options.length-1; a++)
	{
		df0.iassessmenttoolmaster_id.options[a].text='';
		df0.iassessmenttoolmaster_id.options[a].value='';
	}
	
	for(i=0;i<=qvalidJS['iassessmenttoolmaster_id'].length-1;i++)
	{
		if(ind == 0) 
		{ 
			type='t'; 
		} 
		else 
		{ 
			type='r';  
		}
		if (type == 't') 
		{
			if (val == qvalidJS['itenant_id'][i]) 
			{ 
				df0.iassessmenttoolmaster_id.options.length=cnt+1;
				df0.iassessmenttoolmaster_id.options[cnt].value=qvalidJS['iassessmenttoolmaster_id'][i];
				
				if (qvalidJS['bbillingactive'][i]==1 && qvalidJS['dtbillingactive'][i] !== '') 
				{ 
					b='Active '; 
				} 
				else 
				{ 
					b=''; 
				}
				desc=b+qvalidJS['dtreviewstart'][i]+'-'+qvalidJS['dtreviewend'][i]+' '+qvalidJS['totalpoints'][i]+' points';
				df0.iassessmenttoolmaster_id.options[cnt].text=desc;
				cnt+=1;
			} 
		}
		else if (type == 'r') 
		{ 
			if (val == qvalidJS['iresident_id'][i]) 
			{ 
				df0.iassessmenttoolmaster_id.options.length=cnt+1;
				df0.iassessmenttoolmaster_id.options[cnt].value=qvalidJS['iassessmenttoolmaster_id'][i];
				desc=qvalidJS['dtreviewstart'][i]+'-'+qvalidJS['dtreviewend'][i]+' '+qvalidJS['totalpoints'][i]+' points';
				df0.iassessmenttoolmaster_id.options[cnt].text=desc; 
				cnt+=1;
			}
		}
	}
	
	dl=document.all['indload'];
	if ( df0.iassessmenttoolmaster_id.options[0].value !== '') 
	{ 
		dl.style.visibility='visible'; 
	}
	else 
	{ 
		dl.style.visibility='hidden'; 
	}
}

function hgo(str,val){
	if (str=='b') 
	{ 
		ind=window.open('..\\AssessmentTool\\assessmenttoolform.cfm?h=#session.qselectedhouse.ihouse_id#&set=#session.qselectedhouse.csleveltypeset#',"new");  
	}
	else if (str=='i') 
	{ 
		if (document.forms[0].allquestions[0].checked == true) 
		{ 
			allq='N';  
		}
		else 
		{ 
			allq='Y'; 
		}
	
		ind=window.open('..\\AssessmentTool\\assessmenttoolsummary.cfm?a='+document.forms[0].iassessmenttoolmaster_id.value+'&s=N&allques='+allq,"new"); 
	}
	else if (str='allactive') 
	{
		dfa=document.forms[0].iassessmenttoolmaster_id;
		if (df0.allactive_allquestions[0].checked == true) 
		{ 
			allq2='N';  
		} 
		else 
		{ 
			allq2='Y'; 
		}
		
		allactive=window.open('..\\AssessmentTool\\assessmenttoolsummary.cfm?a='+dfa.value+'&s=N&allques='+allq2+'&scope='+hname,"new"); 
	}
	else if (str=='l') 
	{ 
		if (df0.admin.value.length == 0) 
		{ 
			alert('Please enter the name to print on the letter.'), df0.admin.focus(); 
		}
		else 
		{ 
			ltr=window.open('..\\AssessmentTool\\assessmenttoolletter.cfm?H=#session.qselectedhouse.ihouse_id#&tot=N&A='+df0.iassessmenttoolmaster_id.value+'&an='+df0.admin.value+'&title='+df0.title.value+'&d=',"new"); 
		}
	}
	else if (str='all') 
	{
		if (df0.admin.value.length == 0) 
		{ 
			alert('Please enter the name to print on the letter.'), df0.admin.focus(); 
		}
		else 
		{ 
			ltr=window.open('..\\AssessmentTool\\assessmenttoolletter.cfm?H=#session.qselectedhouse.ihouse_id#&tot=Y&A='+df0.iassessmenttoolmaster_id.value+'&an='+df0.admin.value+'&title='+df0.title.value+'&d=',"new"); 
		}	
	}
}

function closer()
{ 
	opener.focus(), self.close(); 
}

window.onload=initial;
</script>

<body>

<form action="" method="post" name="reportsForm" id="reportsForm">
<table bgcolor="##CCCCCC" cellspacing="1" cellpadding="2">
	<tr>
		<td class="administration" nowrap>Blank Assessment Tool</td>
		<td class="assessmentMain">
			<cfif qtools.recordcount eq 1>
				#trim(qtools.cdescription)# <input type="hidden" name="iassessmenttool_id" value="#qtools.iassessmenttool_id#" class="assessmentMain">
			<cfelse>
				<select name="iassessmenttool_id" class="assessmentMain">
					<cfloop query="qtools">
						<option value="#qtools.iassessmenttool_id#">
							#trim(qtools.cdescription)#
						</option>
					</cfloop>
				</select>
			</cfif>
		</td>
		<td class="assessmentMain">
			<a href="javascript:;" onclick="hgo('b',df0.iassessmenttool_id.value)" class="abutton"><b>Create Report</b></a>
		</td>
	</tr>
	<tr>
		<td class="administration">Individual Assessment</td>
		<td class="assessmentMain">
			<select name="residents" onchange="alist(this)" class="assessmentMain"></select><br>
			<select name="iassessmenttoolmaster_id" class="assessmentMain"></select><br>
			Include ALL questions in Report? <input type="radio" name="allquestions" value="Y" CHECKED class="assessmentMain">Yes <input type="radio" name="allquestions" value="N" class="assessmentMain">No</td>
		<td  class="assessmentMain">
			<a id="indload" href="javascript:;" onclick="hgo('i',0)" class="abutton"><b>Create Report</b></a>
		</td>
	</tr>
	<tr>
		<td class="administration">Print All Active Assessments</td>
		<td class="assessmentMain">
			Include ALL questions in Report? <input type="radio" name="allactive_allquestions" value="Y" CHECKED class="assessmentMain">Yes <input type="radio" name="allactive_allquestions" value="N" class="assessmentMain">No
		</td>
		<td class="assessmentMain">
			<a id="activeload" href="javascript:;" onclick="hgo('allactive',0)" class="abutton"><b>Create Report</b></a>
		</td>
	</tr>
	<tr>
		<td colspan=3 class="bottomleftcap"></td><td colspan=3 class="bottomrightcap"></td>
	</tr>
</table>

</form>
</body>
</html>
</cfoutput>