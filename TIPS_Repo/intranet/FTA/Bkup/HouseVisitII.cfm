
<cfparam name="dtMarAuditDate" default="">
<cfparam name="thisgroup" default="">
<cfparam name="roleaccessok" default="0"> 
<cfparam name="Page" default="">

<cfif IsDefined("url.userRole") >
	<cfif (url.userRole is "RDO")   >
		<cfset userrole = "OPS">
		<cfset roleaccessok = "True">
	<cfelseif (url.userRole is "OPS")   >
		<cfset userrole = "OPS">
		<cfset roleaccessok = "True">		
	<cfelseif 	url.userRole is "RDSM"   >
		<cfset userrole = "SLS">
		<cfset roleaccessok = "True">	
	<cfelseif 	url.userRole is "CSS"   >
		<cfset userrole = "SLS">
		<cfset roleaccessok = "True">		
	<cfelseif 	url.userRole is "RDQCS" >
		<cfset userrole = "CLN">
		<cfset roleaccessok = "True">
	<cfelseif 	url.userRole is "DVP" >
		<cfset userrole = "DVP">
	<cfelseif 	url.userRole is "Corporate" >	
		<cfset userrole = "Corporate">	
	<cfelseif 	url.userRole contains( "VP Quality") >	
		<cfset userrole = "VP Quality & Clinical Services">
	<cfelseif 	url.userRole contains( "VP Sales") >	
		<cfset userrole = "VP Sales and Marketing">
	<cfelseif 	url.userRole contains( "President") >	
		<cfset userrole = "President & CEO">
 	<cfelse>
	You do not have access to create House Visit Reports. 
	<cfabort>
	</cfif>  
	<cfset rolename = url.userRole>		
<!--- <cfelseif IsDefined("rolename")>
	<cfif (rolename  is "RDO") or (rolename is "OPS") >
		<cfset userrole = "OPS">
	<cfelseif 	 (rolename  is "RDSM") or (rolename is "CSS") >
		<cfset userrole = "SLS">	
	<cfelseif 	 (rolename  is "RDQCS") >
		<cfset userrole = "CLN">
	</cfif> --->
<cfelse>
You do not have access for creating House Visit Reports. 
<cfabort>
</cfif> 

<cfif Isdefined("getUserADInfo.Title")>
  <cfif getUserADInfo.Title is not "">
		<cfset userRole = getUserADInfo.Title>
	<cfelse>
		<cfset Role = 1>
	</cfif>	  
<cfelse>
	<cfset Role = 1>	
</cfif>	
<cfset Page = "Create House Visit">

<head>

	<style type="text/css">
		.visible {display:inline}
		.hidden {display:none}
	</style>
	<script language="Javascript">
		function addRowToHFFamMem(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_8_' + iteration;
				 el.id = 'residentfname' + iteration;
		//  		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
			  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_52_' + iteration;
				 el.id = 'residentlname' + iteration;
		 //		 el.value = el.name;
				 el.size = colsize;
				 cell1.appendChild(el);
			  // 3rd cell
				 var cell3 = row.insertCell(3);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_9_' + iteration;
				 el.id = 'RPName' + iteration;
		 // 		 el.value = el.name;
				 el.size = colsize;
				 cell3.appendChild(el);
		// reset row count	
				 document.getElementById(maxid).value = iteration;
			}
			
		 
		function addRowToNewRes(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
			  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_53_' + iteration;
				 el.id = 'newresidentfn' + iteration;
		 //		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
			  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_27_' + iteration;
				 el.id = 'newresidentln' + iteration;
		 //		 el.value = el.name;
				 el.size = colsize;
				 cell1.appendChild(el); 
		// reset row count	
				 document.getElementById(maxid).value = iteration;
			}
		 
		function addRowToVacantRm(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = document.getElementById(tableid).rows.length;	
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
		
		// var rowCount = document.getElementById(thistableid).getElementsByTagName("tr").length;
		// alert("rowCount: " + rowCount); 	 
			  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_7_' + iteration;
				 el.id = 'roomnbr' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
		// reset row count	
				 document.getElementById(maxid).value = iteration;
			} 
		function addRowToProfRef(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_35_' + iteration;
				 el.id = 'profrefname' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
				  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_36_' + iteration;
				 el.id = 'profreftitle' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell1.appendChild(el); 		
				  // 3rd cell
				 var cell2 = row.insertCell(2);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_65_' + iteration;
				 el.id = 'profreforg' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell2.appendChild(el); 		  
		// reset row count	
				 document.getElementById(maxid).value = iteration;
			}	
			
		function addRowToOutOfComm(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_39_' + iteration;
				 el.id = 'oocommresidentfn' + iteration;
		 //		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
				  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_59_' + iteration;
				 el.id = 'oocommresidentln' + iteration;
		 //		 el.value = el.name;
				 el.size = colsize;
				 cell1.appendChild(el); 
			  // 2nd cell
				 var cell2 = row.insertCell(2);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_40_' + iteration;
				 el.id = 'oocommlocn' + iteration;
		// 		 el.value = el.name;
				 el.size = colsize;
				 cell2.appendChild(el);
		 
			  // 3rd cell
				 var cell3 = row.insertCell(3);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_41_' + iteration;
				 el.id = 'oocommedprof' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell3.appendChild(el);
		 
			  // 4th cell
				 var cell4 = row.insertCell(4);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_42_' + iteration;
				 el.id = 'oocommtitle' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell4.appendChild(el);
		// reset row count	
				 document.getElementById(maxid).value = iteration;		 		 
			}	
			
		function addRowToHotLeads(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_24_' + iteration;
				 el.id = 'hotleadfn' + iteration;
		//		 el.value = el.name;
				 el.size = 35;
				 cell0.appendChild(el); 
				  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_60_' + iteration;
				 el.id = 'hotleadln' + iteration;
		//		 el.value = el.name;
				 el.size = 35;
				 cell1.appendChild(el); 
			  // 3rd cell
				 var cell2 = row.insertCell(2);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_25_' + iteration;
				 el.id = 'hotleadsstrat1' + iteration;
		//		 el.value = el.name;
				 el.size = 50;
				 cell2.appendChild(el);
		 
			  // 4th cell
				 var cell3 = row.insertCell(3);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_26_' + iteration;
				 el.id = 'hotleadsstrat2' + iteration;
		//		 el.value = el.name;
				 el.size = 50;
				 cell3.appendChild(el);
		// reset row count	
				 document.getElementById(maxid).value = iteration;		 		 
			}
		 
		function addRowToPrefProv(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_10_' + iteration;
				 el.id = 'hotleads' + iteration;
		// 		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
			  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_11_' + iteration;
				 el.id = 'hotleadsstrat1' + iteration;
		// 		 el.value = el.name;
				 el.size = colsize;
				 cell1.appendChild(el);
		 
			  // 3rd cell
				 var cell2 = row.insertCell(2);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_12_' + iteration;
				 el.id = 'hotleadsstrat2' + iteration;
		// 		 el.value = el.name;
				 el.size = 12;
				 cell2.appendChild(el);
			  // 4th cell
				 var cell3 = row.insertCell(3);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_13_' + iteration;
				 el.id = 'hotleadsstrat2' + iteration;
		// 		 el.value = el.name;
				 el.size = 12;
				 cell3.appendChild(el);
		// reset row count		 
				 document.getElementById(maxid).value = iteration;		 		 
			}
		
		function addRowToMentoring(tableid, name, maxrows, colsize, maxid){
		// alert(tableid + " : " + name  + " : " +  maxrows  + " : " +  colsize  + " : " +  maxid);
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
		
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_1_' + iteration;
				 el.id = 'houseteammem' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
				 
			  // 2nd cell
				 var cell1 = row.insertCell(1);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_2_' + iteration;
				 el.id = 'referalsrcname' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell1.appendChild(el);
		
			  // 3rd cell
				 var cell2 = row.insertCell(2);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_3_' + iteration;
				 el.id = 'refersrctitle' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell2.appendChild(el);
			
			  // 4th cell
				 var cell3 = row.insertCell(3);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_4_' + iteration;
				 el.id = 'referorg' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell3.appendChild(el);
			
			  // 5th cell
				 var cell4 = row.insertCell(4);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_5_' + iteration;
				 el.id = 'salescalleval' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell4.appendChild(el);
		// reset row count	
				 document.getElementById(maxid).value = iteration;	
			}
		 
			
		function addRowEmpNoTaskSht(tableid, name, maxrows, colsize, maxid){
		 
			var thistableid = tableid;
			var thiscellname = name;	
			var table = document.getElementById(tableid); 
			var rowCount = table.rows.length;	 
			var itemcount = document.getElementById(maxid).value; 
			var iteration = (itemcount*1) + 1;	
			var row = table.insertRow(rowCount);
			 
				  // 1st cell
				 var cell0 = row.insertCell(0);
				 var el = document.createElement('input');   
				 el.type = 'text';
				 el.name = thiscellname + '_1_' + iteration;
				 el.id = 'tasksheetempname' + iteration;
		//		 el.value = el.name;
				 el.size = colsize;
				 cell0.appendChild(el); 
		// reset row count			 
				 document.getElementById(maxid).value = iteration;
			}
		// end of add row functions	
		function chkEntryDate(){
			var theEntryDate = new Date(document.getElementById('dtEntryDate').value);
			var theBaseDate = new Date(document.getElementById('idthisbasedate').value);
			var oneDay= (1000*60*60*24);
			var daysDiff = ((  theBaseDate.getTime() - theEntryDate.getTime())/oneDay);
			if (daysDiff > 5){
				document.getElementById('dtEntryDate').value =  document.getElementById('idthisbasedate').value;
				alert("WARNING: The Report Date CANNOT be more than 5 days back from today");
			}
		 }
		
		function showAuditDate(){
		var MarAuditDate = document.getElementById('dtMarAuditDate');
		var mySplitResult = MarAuditDate.value.split("/");
		 if (mySplitResult[1] == 1){
		 { document.getElementById('dtMarAuditDate').value =  document.getElementById('idorigdate').value;
		 alert("WARNING: Day of the month is 1 , use the last day of the month of the previous month.");
				}
			}
		 }
		 
		function calcMARErrorRate (){
		var monthday = 0;
		var MarAuditDate = document.getElementById('dtMarAuditDate');
		var mySplitResult = MarAuditDate.value.split("/");
		//     alert("You entered: " + mySplitResult[1]);
		 document.getElementById('dtDayOfMonth').value = mySplitResult[1];
		 if   ((document.getElementById('dtDayOfMonth').value  - 1)  == 0 )
			{ monthday = 1  }
		else {	
			 monthday = (document.getElementById('dtDayOfMonth').value  - 1) }
			var subTotal = ((document.getElementById('maromissions1').value - 0) + (document.getElementById('marprn1').value - 0)  );
			var subTotalA = (monthday *  (document.frmHouseVisitOpEntry.marroutineord1.value));
		
			var MarErrorTotal = subTotal/ subTotalA;
		//     alert( subTotal + " : " + subTotalA + " : " + monthday + " : " + MarErrorTotal);
			if (isNaN(MarErrorTotal))
				{ document.getElementById('marerrorrate1').value = 0;
				 alert("WARNING: MAR values are missing, please re-enter or enter 0");
				  }
			else if (!isFinite(MarErrorTotal))
				{ document.getElementById('marerrorrate1').value = 0;	
				 alert("WARNING: MAR values are missing, please re-enter or enter 0");	}	
			else if (document.frmHouseVisitOpEntry.DayOfMonth.value  == 1)
				{ document.getElementById('marerrorrate1').value = 0;	
				 alert("WARNING: Day of the month is 1 , use the last day of the month of the previous month.");	}		  	
			else
			document.getElementById('marerrorrate1').value = 100*(Math.round(MarErrorTotal * 100)/100);		
		}   
		
		function chkScore(score){
		 
		 if (score.value > 11) 
		 {
			alert("Score range is 0 - 11");
			score.focus();
			}
		 if (isNaN(score.value)) 
		 {
			alert("Score must be numeric and range is 0 - 11");
			score.focus();
			}
		}
		
		function reloadthispage(){
			var currentLocation = location.href; //Current Page URL
			var urlParameter = "";
			currentLocation = currentLocation.toLowerCase();
			currentLocation = currentLocation.substring(0,currentLocation.indexOf('?')+1) ;
			var renumofmonths = document.getElementById('idnumberOfMonths').value;
			var rerole = document.getElementById('hdnRole').value;
			var rethishouseid = document.getElementById('idthishouseid').value;		
			var resubaccount = document.getElementById('idthissubaccount').value;		
			var redatetouse = document.getElementById('idthisdatetouse').value;		
			var reentryuserrole = document.getElementById('idEntryuserRole').value;	
			var reuserrole = document.getElementById('idthisuserole').value;
			var newuserroleid = document.getElementById('hdnuserRoleID').value;
			var reihouseid = document.getElementById('idthishouseid').value;
			var newroleA = "";		
			var newroleB = "";	
			var select_list_field = document.getElementById('idchgRole');
			var select_list_selected_index = select_list_field.selectedIndex;
		
			var newroleA = select_list_field.options[select_list_selected_index].text;
			var newroleB = select_list_field.value;
			len = newroleA.length;
			newRole   = newroleA;
			urlParameter = 	currentLocation + "numberofmonths=" + renumofmonths + "&role=" + rerole + "&house_id=" + rethishouseid + "&subaccount=" + resubaccount + "&datetouse=" + redatetouse + "&userRole=" + newRole + "&EntryUserRole=" + newRole + "&ihouse_id=" + reihouseid;
 			window.location.href = urlParameter;
		}

	<cfinclude template="../global/Calendar/ts_picker2.js">
	
	</script>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
			
	<!--- Instantiate the Helper object. --->
	<cfset helperObj = createObject("component","Components/Helper").New(FTAds, ComshareDS, application.DataSource)>
 
</head>
	<body>
	<cfinclude template="ScriptFiles/FTACommonScript.cfm">  
	<cfinclude template="DisplayFiles/Header.cfm">  
  	<CFLDAP ACTION="query" NAME="getUserADInfo" START="DC=alcco,DC=com" SCOPE="subtree" ATTRIBUTES="sAMAccountName,Title,DisplayName" SERVER="#ADserver#" PORT="389"  FILTER="(&(objectCategory=CN=Person,CN=Schema,CN=Configuration,DC=alcco,DC=com)(sAMAccountName=#SESSION.UserName#))" USERNAME="ldap" PASSWORD="paulLDAP939">	 	
	<CFIF getUserADInfo.sAMAccountName IS NOT "">
		<cfset userId = getUserADInfo.sAMAccountName>
  	<CFELSE>
		<cfset userId = 'sfarmer'>  
	</CFIF>
	<CFIF getUserADInfo.DisplayName IS NOT "">
		<cfset userFullName = getUserADInfo.DisplayName>
  	<CFELSE>
		<cfset userFullName = "Farmer, Steven"	> 
	</CFIF>	
	<!--- COLORS --->	
	<cfset groupColor = "cdcdcd">
	<cfset freezeColor = "f5f5f5">
	<cfset toolbarColor = "d6d6ab">
	<cfset dsGroups = helperObj.FetchHouseVisitGroupsII(rolename)>
	<cfset dsRoles = helperObj.FetchHouseVisitRoles()>
	<cfset dsRolesChg = helperObj.FetchHouseVisitRolesChg()>	
	<cfset dsAuthentication = helperObj.FetchHouseVisitAuthentication()>
	<cfset dsQuestionRoles = helperObj.FetchHouseVisitQuestionRoles()>  
	<cfset dsUserRole = helperObj.FetchHouseVisitRoleByTitle(dsRoles, dsAuthentication, userRole)> 
	<form id="frmHouseVisitOpEntry" name="frmHouseVisitOpEntry" method="post" <cfoutput> action="HouseVisitOperations_Action.cfm?iHouse_ID=#url.iHouse_ID#&url_SubAccount=#url.SubAccount#&DateToUse=#url.DateToUse#"</cfoutput> />
		<table width="80%">
			<cfoutput>
				<cfset dsRoleID = helperObj.FetchHouseVisitRoleID(rolename)>
				<input type="hidden"  name="EntryUserId" 			id="hdnEntryUserId" 		value="#userId#" />
				<input type="hidden"  name="Role" 					id="hdnRole" 				value="#url.role#" />
				<input type="hidden"  name="EntryuserFullName" 		id="hdnEntryuserFullName" 	value="#userFullName#" />
				<input type="hidden"  name="hdnrolename" 			id="hdnrolename" 			value="#rolename#" />
				<input type="hidden"  name="userRoleID" 			id="hdnuserRoleID" 			value="#dsRoleID.iRoleID#" />
				<input type="hidden"  name="EntryuserRole" 			id="idEntryuserRole" 		value="#url.EntryuserRole#"/>
				<input type="hidden"  name="numberOfMonths" 		id="idnumberOfMonths" 		value="#url.numberOfMonths#"/>
				<input type="hidden"  name="thisbasedate"	 		id="idthisbasedate" 		value="#dateFORMAT(Now(),"MM/DD/YYYY")#"/>
				<input type="hidden"  name="thishouseid"	 		id="idthishouseid" 			value="#url.iHouse_ID#" />	
				<input type="hidden"  name="thisdatetouse"	 		id="idthisdatetouse" 		value="#url.datetouse#" />
				<input type="hidden"  name="thissubaccount"	 		id="idthissubaccount" 		value="#url.SubAccount#" />	
				<input type="hidden"  name="thisuserrole"	 		id="idthisuserole" 			value="#url.userrole#"/>
							
				<tr>
					<td     align="center" bgcolor="#groupColor#" style="font-family: Tahoma; font-weight: bold;">
						<cfswitch expression="#userrole#"> 
							<cfcase value="OPS">Create New House Visit - Operations</cfcase> 
							<cfcase value="RDO">Create New House Visit - Operations</cfcase>
							<cfcase value="RDQCS">Create New House Visit - Clinical</cfcase>		
							<cfcase value="RDSM">Create New House Visit - Sales</cfcase>																			
							<cfcase value="SLS">Create New House Visit - Sales</cfcase> 
							<cfcase value="CLN">Create New House Visit - Clinical</cfcase> 
							<cfdefaultcase>Create New House Visit #userrole#  -  ROLE: #rolename#</cfdefaultcase> 
						</cfswitch>
					</td>
				</tr>
				<input type="hidden" id="hdnIsSuperUser" name="hdnIsSuperUser" value="<cfif dsUserRole.bIsSuperUser eq true>True<cfelse>False</cfif>">
				<cfif (dsUserRole.bIsSuperUser eq true)   or (session.username eq "sfarmer") >
					<tr>
						<td align="left"   style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" >
							<label for="chgRole">
								<font size=-1>
									Select to Change Role:
								</font>
							</label>
							<select name="chgRole" id="idchgRole"  onChange="reloadthispage(this);" style="color: black; background-color: white; width: 150px;">
								<option value="">Select</option>
								<cfloop query="dsRolesChg">	
									<option value="#dsRolesChg.iRoleId#">
										#dsRolesChg.cRoleName#  
									</option> 
								</cfloop>
							</select>			
						</td>
					</tr>
				</cfif>				
				<tr>
					<td  align="left" style="font-family: verdana; font-weight: bold;" bgcolor="#freezeColor#" >
							<label >
								<font size=-1>
									Name:
								</font>
							</label> #userFullName#</td>
				</tr>
	<cfif roleaccessok>
				<tr>
					<td  align="center"    nowrap="nowrap" style="font-family: verdana; font-weight: bold; text-align:left;" bgcolor="#freezeColor#" >
						 	<label for="dtEntryDate">
								<font size=-1>
									Date:
								</font>
							</label> 	<input type="text" name="dtEntryDate"   id="dtEntryDate" class="date-pick" style="text-align: CENTER;" value="#DateFormat(Now(), 'mm/dd/yyyy')#"  onBlur="chkEntryDate(this)" />	
						 <a onClick="show_calendar2('document.frmHouseVisitOpEntry.dtEntryDate',document.getElementById('dtEntryDate').value,'dtEntryDate');"> 
						 <img src="../global/Calendar/calendar.gif" alt="Calendar" width="20" height="20" border="0" align="middle" style="" id="Cal" name="Cal"></a>
						 	<label for="dtEntryDate">
								<font size=-1>
									Select the date the audit was performed.
								</font>
							</label>
						
					</td>
				</tr>			
				<cfloop query="dsGroups" >
					<cfset thisgroup = dsGroups.iGroupId>
					<cfset maxrep = #dsGroups.indexmax#> 
					<cfset indexname  = #Trim("dsGroups.indexname")# >
					<tr><td> <input type="hidden" name="#trim(indexname)#" value="#maxrep#" id="id#Trim(dsGroups.indexname)#"></td></tr>
					<tr>
						<td>
							<table  id="#trim(dsGroups.cGroupName)#" width="90%" >
								<TR style=" background-color: #groupcolor#;">
									<th colspan="5" style="text-align:left"; font-weight:"100"; width="800px";> #dsGroups.iGroupId#. #dsGroups.cTextHeader#</th>
								</TR>
								<cfset dsGroupQuestionsHdr = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
								<tr>
									<cfloop query="dsGroupQuestionsHdr">
										<th style="text-align:left"  >#dsGroupQuestionsHdr.cQuestion#</th>
									</cfloop>					
								</tr>
 								<cfif dsGroups.AddRows is "Y">
									<TR>
										<td colspan="5" ><input type="button" value="Add Row" onClick="#Trim(dsGroups.addrowname)#('#trim(dsGroups.cGroupName)#', 'txtanswer_#thisgroup#',#maxrep#,#dsGroupQuestionsHdr.cColSize#, 'id#Trim(dsGroups.indexname)#');" /></td>
									</TR>
								</cfif>								
								<cfif dsGroups.IGROUPID is 18 >
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#"> </textarea>
										</td>	
									</TR>
								<cfelseif dsGroups.IGROUPID is 1>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
												<cfloop query="dsGroupQuestions">
												 <cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseposition = helperObj.qryHousePosition()>
													<td><select name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" >
														<option value="">Select</option>
															<cfloop query="dshouseposition">
															 <option value="#cHousePosition#">#cHousePosition#</option>
															</cfloop>
														</select>
													</td>
													<cfelse>
													<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
													</cfif>
												</cfloop>
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 5>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
												<cfloop query="dsGroupQuestions">
												 <cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseTitle = helperObj.qryHouseTitle()>
													<td><select name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" >
														<option value="" >Select</option>
														<cfloop query="dshouseTitle" >
															<option value="#cHousetitle#">#cHousetitle#</option>
														</cfloop>
														</select>
													</td>
												
													<cfelse>
													<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
													</cfif>
												</cfloop>
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 16>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
												<cfloop query="dsGroupQuestions">
												<cfif dsGroupQuestions.dropdown is not "">
								 					<cfset dshouseTask = helperObj.qryHouseTask()>
													<td><select name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" >
														<option value="">Select</option>
														<cfloop query="dshouseTask" >
															<option value="#ctasksheetdayrange#">#ctasksheetdayrange#</option>
														</cfloop>
														</select>
													</td>
												<cfelse>
														<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#"   style="text-align:left"; /></td>
												</cfif>
												</cfloop>
										</tr>
									</cfloop>
								<cfELSEif dsGroups.IGROUPID is 6>
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<textarea name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" rows="#dsGroupQuestions.cRowSize#" cols="#dsGroupQuestions.cColSize#"> </textarea>
										</td>	
									</TR>
									</cfloop>									
								<cfelseif  dsGroups.IGROUPID is 7>
									<cfset i = 1>
									<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>
									<TR>
										<td style="text-align:left"><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
											<input  type="radio"	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="Y" size="#dsGroupQuestions.cColSize#"     style="text-align:left"; />YES<br/> 									
											<input  type="radio"	name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="N" size="#dsGroupQuestions.cColSize#"    style="text-align:left"; />No
										</td>										
									</TR>	 
								<CFELSE>	
									<cfset i = 0>
									<cfloop index="#indexname#" from="1" to="#maxrep#" step="1">
										<cfset i = i + 1>
										<tr  style=" background-color: ##ffffff;" >
											<cfset dsGroupQuestions = helperObj.FetchHouseVisitQuestionsII(dsGroups.iGroupId)>  
											<cfif dsGroupQuestions.cIncludeDate is "Y">
												<td><!--- #dsGroups.iGroupId# #dsGroupQuestions.iQuestionId# #i# --->
													<input type="hidden" name="origdate" id="idorigdate" value="#Now()#"> 
													<input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="dtMarAuditDate" value="#DateFormat(Now(), 'mm/dd/yyyy')#" onBlur="showAuditDate()" >
													<a onClick="show_calendar2('document.frmHouseVisitOpEntry.dtMarAuditDate',document.getElementById('dtMarAuditDate').value,'dtMarAuditDate');"> 
													<img src="../global/Calendar/calendar.gif" alt="Calendar" width="20" height="20" border="0" align="middle" style="" id="Cal" name="Cal"></a>
													<input type="hidden" name="DayOfMonth" id="dtDayOfMonth" value=""> 
												</td>
											<cfelse>
												<cfloop query="dsGroupQuestions">
													<td style="text-align:left" title="#dsGroupQuestions.cQuestion#" ><input type="text" name="txtanswer_#thisgroup#_#dsGroupQuestions.iQuestionId#_#i#" id="#trim(dsGroupQuestions.cIDName)##i#" value="#trim(defaultvalue)#" size="#dsGroupQuestions.cColSize#"  onBlur="#trim(dsGroupQuestions.cOnChange)#" <cfif dsGroupQuestions.readonly is "Y">readonly="readonly" </cfif>   style="text-align:left"; /> #dsGroupQuestions.posttitle#</td>
												</cfloop>
											</cfif>
										</tr>
									</cfloop>		
								</cfif>
							</table>
						</td>
				</tr>			
			</cfloop>

			<tr>
				<td   align="center"   bgcolor="#toolbarColor#">
					<input type="submit" value="Submit" style="width: 120px;" />
				</td>
			</tr>		
		</cfif>
			</cfoutput>		
		</table>
	</form>
</body>
