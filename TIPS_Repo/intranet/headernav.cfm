<!--- Header, global navigation --->
<cfset datasource = "DMS">
<cfset maxchars = 25>

<TABLE STYLE="width:1%;border:none;background-color:transparent;">
	<TR>
	<TD STYLE="background-color:transparent;border:none;width:1%;">
	<INPUT TYPE="button" NAME="UserShow" VALUE="User Administration" onClick="javascript: location.href='http://<cfoutput>#server_name#</cfoutput>/intranet/admin/index2.cfm?id=13';">
	<!--- 
	Changes to filter the other menu options
	Throw directly to the user administration screens.
	showadmin(this); 
	Paul Buendia 03/16/2005
	--->
	</TD>
	</TR>
</TABLE>
<script language="JavaScript" src="/intranet/coolmenus.js">
	/*******************************************************************************
	Copyright (c) 1999 Thomas Brattli (www.bratta.com)
	
	eXperience DHTML coolMenus - Get it at www.bratta.com
	Version 2.0
	This script can be used freely as long as all copyright messages are
	intact. Visit www.bratta.com/dhtml for the latest version of the script.
	
	These are the varibles you have to set to customize the menu.
	*******************************************************************************/
</script>

<script>
/********************************************************************************
Variables to set.

Remember that to set fontsize and fonttype you set that in the stylesheet
above!
********************************************************************************/

//Making a menu object
oMenu=new menuObj('oMenu') //Place a name for the menu in there. Must be uniqe for each menu

//Setting menu object variables

//Style variables NOTE: The stylesheet have been removed. Use this instead! (some styles are there by default, like position:absolute ++)
oMenu.clMain='padding:0px; font-family:Verdana; font-size:xx-small; font-weight:bold' //The style for the main menus
oMenu.clSub='padding:4px; font-family:Arial; font-size:xx-small' //The style for the submenus
oMenu.clSubSub='padding:4px; font-family:Arial; font-size:xx-small' //The style for the subsubmenus
oMenu.clAMain='text-decoration:none; color:#666699' //The style for the main links
oMenu.clASub='text-decoration:none; color:red' //The style for the sub links
oMenu.clASubSub='text-decoration:none; color:red' //The style for the subsub links

//Background bar properties
oMenu.backgroundbar=1 //Set to 0 if no backgroundbar

oMenu.backgroundbarfromleft=48//The left placement of the backgroundbar in pixel or %
oMenu.backgroundbarfromtop=51 //The top placement of the backgroundbar  in pixel or %

//oMenu.backgroundbarsize="704" //The size of the bar in pixel or %
oMenu.backgroundbarsize="100" //The size of the bar in pixel or %
		
oMenu.backgroundbarcolor="Blue" //The backgroundcolor of the bar #ff9933

oMenu.mainheight=13 //The height of the main menuitems in pixel or %
oMenu.mainwidth=100 //The width of the main menuitems  in pixel or %

/*These are new variables. In this example they are set like the previous version*/
oMenu.subwidth=130 // ** NEW ** The width of the submenus
oMenu.subheight=20 //The height if the subitems in pixel or % 

oMenu.subsubwidth=130 // ** NEW ** The width of the subsubmenus in pixel or % 
oMenu.subsubheight=oMenu.subheight //** NEW ** The height if the subsubitems in pixel or % 


//Writing out the style for the menu (leave this line!)
oMenu.makeStyle()

oMenu.subplacement=oMenu.mainheight //** NEW ** Relative to the main item
oMenu.subsubXplacement=oMenu.subwidth*.95 //** NEW ** The X placement of the subsubmenus, relative to the sub item
oMenu.subsubYplacement=0 //** NEW ** The Y placement of the subsubmenus, relative to the sub item

oMenu.mainbgcoloroff='#ffffff' //The backgroundcolor of the main menuitems
oMenu.mainbgcoloron='#d8d8d8' //The backgroundcolor on mouseover of the main menuitems
oMenu.subbgcoloroff='#f7f7f7' //The backgroundcolor of the sub menuitems
oMenu.subbgcoloron='#d8d8d8' //The backgroundcolor on mouseover of the sub menuitems
oMenu.subsubbgcoloroff='#eaeaea' //The backgroundcolor of the subsub menuitems
oMenu.subsubbgcoloron='#d8d8d8' //The backgroundcolor on mouseover of the subsub menuitems
oMenu.stayoncolor=1 //Do you want the menus to stay on the mouseovered color when clicked?

oMenu.menuspeed=70 //The speed of the clipping in px
oMenu.menusubspeed=75 //The speed of the submenus clipping in px

oMenu.menurows=1 //Set to 0 if you want rows and to 1 if you want columns

oMenu.menueventon="mouse" //Set this to "mouse" if you want the menus to appear onmouseover, set it to "click" if you want it to appear onclick
oMenu.menueventoff="mouse" //Set this to "mouse" if you them to disappear onmouseout, if not set it to "click"

//Placement of the menuitems

//Example in %:
//oMenu.menuplacement=new Array("20%","40%","60%","50%","65%") //Remember to make the arrays contain as many values as you have main menuitems

//Example in px: (remember to use the ' ' around the numbers)
//oMenu.menuplacement=new Array(10,200,300,400,500)

//Example right beside eachother (only adding the pxbetween variable)
oMenu.menuplacement=0

//If you use the "right beside eachother" you cant how many pixel there should be between each here
oMenu.pxbetween=0 //in pixel or %

//And you can set where it should start from the left here
oMenu.fromleft=50 //in pixel or %

//This is how much from the top the menu should be.
oMenu.fromtop=49 //in pixel or %

/********************************************************************************
Construct your menus below
********************************************************************************/
		<cfquery name='getsections' datasource='#datasource#' dbtype='ODBC'>
			Select distinct uniqueid,codeblockid,sectionname From codeblocks Where sectionname <> 'admin' AND appearmenu = 1
		</cfquery><!--- codeblockid IN (#session.codeblock#)  AND--->
		oMenu.makeMain(0,'&nbsp;Admin',0)
		<cfset counter2 = 0>
		<cfloop query='getsections'>
			<cfoutput>oMenu.makeSub(0,#counter2#,'#getsections.Sectionname#','/intranet/admin/index2.cfm?id=#codeblockid#',#getsections.recordcount#);</cfoutput>
			<cfset counter2 = counter2+1>
		</cfloop>
		
<!---
/*
//MAIN 0

//Main items:
// makeMain(MAIN_NUM,'TEXT','LINK','FRAME_TARGET') (set link to 0 if you want submenus of this menu item)

oMenu.makeMain(0,'&nbsp;Home',0)
	//Sub items:
	// makeSub(MAIN_NUM,SUB_NUM,'TEXT','LINK',TOTAL,'FRAME_TARGET') (set link to 0 if you want submenus of this menu item)
	oMenu.makeSub(0,0,'Return to Home &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;','/intranet/index.cfm',4)
	oMenu.makeSub(0,2,'Help &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;','/intranet/help/helplaunch3.cfm',4)
	//oMenu.makeSub(0,1,'Main Bulletin &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;','/intranet/DG_List.cfm?RegionNumber=0',5)
	oMenu.makeSub(0,1,'Search Page &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',0,4)
	oMenu.makeSub(0,3,'Logout &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;','/intranet/logout.cfm',4)
	
	oMenu.makeSubSub(0,2,0,'Simple Search','/intranet/basicsearch.cfm',2)
	oMenu.makeSubSub(0,2,1,'Advanced Search','/intranet/advancedsearch.cfm',2)
		
oMenu.makeMain(1,'&nbsp;Departments',0)
	//Sub items:
	
	<cfquery name='getdeptsA' datasource='#datasource#' dbtype='ODBC' cachedwithin='#CreateTimeSpan(1, 1, 0, 0)#'>
		SELECT department_ndx,Department
		FROM vw_departments
	</cfquery>
	
	<cfset regcounter2 = 0>
	<cfloop query='getdeptsA'>
		<cfoutput>oMenu.makeSub(1,#regcounter2#,'#getdeptsA.department#','/intranet/Departments/Department_Apps.cfm?Index=#getdeptsA.department_ndx#',#getdeptsA.recordcount#);</cfoutput>
		<cfset regcounter2 = regcounter2+1>
	</cfloop>

		oMenu.makeSubSub(1,13,0,'Contract Services Mgmt','/intranet/ContractMgt/entry.cfm',1)
		oMenu.makeSubSub(1,11,0,'External Training','http://www.newhorizons.com',1)

		oMenu.makeMain(2,'&nbsp;Regions',0)
	//Sub items:
	// makeSub(MAIN_NUM,SUB_NUM,'TEXT','LINK',TOTAL,'FRAME_TARGET') (set link to 0 if you want submenus of this menu item)

	<cfquery name='getregionsA' datasource='#datasource#' dbtype='ODBC' CACHEDWITHIN='#CreateTimeSpan(0,0,10,0)#'>
		SELECT region_ndx, regionname	FROM vw_regions
	</cfquery>
	
	<cfset regcounter = 0>
	
	<cfloop query='getregionsA'>
		<cfoutput>oMenu.makeSub(2,#regcounter#,'#getregionsA.regionname#',0,#getregionsA.recordcount#);</cfoutput>
		<cfset regcounter = regcounter+1>
	</cfloop>


		//SubSub items:
		// makeSubSub(MAIN_NUM,SUB_NUM,SUBSUB_NUM,'TEXT','LINK',TOTAL,'FRAME_TARGET')
		
		// HOME
		oMenu.makeSubSub(2,0,0,'See Whats New!','/intranet/regions/home_template.cfm?Index=0',3)
		oMenu.makeSubSub(2,0,1,'Employment Listing','/intranet/employment/heading_template.cfm?Index=0',3)
		//oMenu.makeSubSub(2,0,2,'ALC Bulletin Board','/intranet/DG_List.cfm?RegionNumber=6',4)
		oMenu.makeSubSub(2,0,2,'Training','/intranet/regions/training_template.cfm?Index=0',3)
		
		//WESTERN
		oMenu.makeSubSub(2,1,0,'See Whats New!','/intranet/regions/home_template.cfm?Index=1',3)
		oMenu.makeSubSub(2,1,1,'Employment Listing','/intranet/employment/heading_template.cfm?Index=1',3)
		//oMenu.makeSubSub(2,1,2,'ALC Bulletin Board','/intranet/DG_List.cfm?RegionNumber=1',4)
		oMenu.makeSubSub(2,1,2,'Training','/intranet/regions/training_template.cfm?Index=1',3)
		
		//CENTRAL
		oMenu.makeSubSub(2,2,0,'See Whats New!','/intranet/regions/home_template.cfm?Index=2',3)
		oMenu.makeSubSub(2,2,1,'Employment Listing','/intranet/employment/heading_template.cfm?Index=2',3)
		//oMenu.makeSubSub(2,2,2,'ALC Bulletin Board','/intranet/DG_List.cfm?RegionNumber=4',4)
		oMenu.makeSubSub(2,2,2,'Training','/intranet/regions/training_template.cfm?Index=2',3)
		
		//SOUTH EAST
		oMenu.makeSubSub(2,3,0,'See Whats New!','/intranet/regions/home_template.cfm?Index=3',3)
		oMenu.makeSubSub(2,3,1,'Employment Listing','/intranet/employment/heading_template.cfm?Index=3',3)
		//oMenu.makeSubSub(2,3,2,'ALC Bulletin Board','/intranet/DG_List.cfm?RegionNumber=5',4)
		oMenu.makeSubSub(2,3,2,'Training','/intranet/regions/training_template.cfm?Index=3',3)
		
		//EASTERN
		oMenu.makeSubSub(2,4,0,'See Whats New!','/intranet/regions/home_template.cfm?Index=4',3)
		oMenu.makeSubSub(2,4,1,'Employment Listing','/intranet/employment/heading_template.cfm?Index=4',3)
		//oMenu.makeSubSub(2,4,2,'ALC Bulletin Board','/intranet/DG_List.cfm?RegionNumber=3',4)
		oMenu.makeSubSub(2,4,2,'Training','/intranet/regions/training_template.cfm?Index=4',3)
		
		//oMenu.makeSubSub(2,5,0,'See Whats New!','/regions/home_template.cfm?Index=2',4)
		//oMenu.makeSubSub(2,5,1,'Employment Listing','/employment/heading_template.cfm?Index=2',4)
		//oMenu.makeSubSub(2,5,2,'ALC Bulletin Board','/DG_List.cfm?RegionNumber=5',4)
		

//MAIN 1

oMenu.makeMain(3,'&nbsp;Library',0)
	oMenu.makeSub(3,0,'Alpha Listing',0,2)
	oMenu.makeSub(3,1,'Search Pages',0,2)
	//oMenu.makeSub(5,1,'Edit','/documentmgt/admin/Edit.cfm',2)
	
	oMenu.makeSubSub(3,1,0,'Search','/intranet/advancedsearch.cfm',1)
<!---Comment: medialocation.locationtypeid is looking for the library categories--->
 <cfquery name='getcategories' datasource='#datasource#' dbtype='ODBC'>
	Select distinct categories.name,cattopicassgn.uniqueid
	From cattopicassgn,categories,medialocation
	Where cattopicassgn.categoryid = categories.uniqueid AND medialocation.mediacontent = 1 AND medialocation.locationtypeid = 5 AND medialocation.locationid = cattopicassgn.uniqueid
</cfquery> 



<cfset counter = 0>
<cfloop query="getcategories">
<cfoutput>oMenu.makeSubSub(3,0,#counter#,'#getcategories.name#','/intranet/documentmgt/document_template.cfm?Index=#getcategories.uniqueid#',#getcategories.recordcount#);</cfoutput>
<cfset counter = counter+1>
</cfloop>

//MAIN 2		
oMenu.makeMain(4,'&nbsp;Applications',0)
	oMenu.makeSub(4,0,'View House Level Utlities','#',10)
	oMenu.makeSub(4,1,'TIPS 3.0','/intranet/tips/selectpanel.cfm',10)
	//oMenu.makeSub(4,2,'Credit Card Input','/intranet/tips/Wizards/CreditCard.cfm',6)
	oMenu.makeSub(4,2,'Vendor Services Mgt.','/intranet/ContractMgt/entry.cfm',10)
	oMenu.makeSub(4,3,'Indicators Scorecard','/intranet/scorecard/menu.cfm',10)
	oMenu.makeSub(4,4,'Seagate Info','/ciweb/main.html',10)
	oMenu.makeSub(4,5,'Petty checks','/intranet/pettychecks/checkpetty.cfm',10)
	oMenu.makeSub(4,6,'Day Respite','/intranet/dayrespite/checkinout.cfm',10)
	oMenu.makeSub(4,7,'Document Imaging','/intranet/documentimaging/docsearch.cfm',10)
	oMenu.makeSub(4,8,'Dictionary','http://www.m-w.com/dictionary.htm',10)
	oMenu.makeSub(4,9,'Thesaurus','http://www.m-w.com/thesaurus.htm',10)
	
		oMenu.makeSubSub(4,0,0,'House Info','/intranet/tips/Wizards/HouseAdminPanel.cfm',1)
		//oMenu.makeSubSub(4,0,1,'New Reservation','/intranet/tips/Wizards/NewReservation.cfm?process=new',2)
		
		oMenu.makeSubSub(4,1,0,'TIPS Help','/intranet/TIPS/Help/Helplaunch2.html',1)
		//oMenu.makeSubSub(4,1,1,'Policy Manual','#',2)

		oMenu.makeSubSub(4,7,0,'No Image report','/intranet/documentimaging/noimagereport.cfm',2)
		oMenu.makeSubSub(4,7,1,'Singel Update','/intranet/documentimaging/singleupdate.cfm',2)
		
oMenu.makeMain(5,'&nbsp;Outlook',0)
	oMenu.makeSub(5,0,'Log In','http://guava/exchange/usa/logon.asp',1)


		<cfquery name='getsections' datasource='#datasource#' dbtype='ODBC'>
			Select distinct uniqueid,codeblockid,sectionname
			From codeblocks
			Where  sectionname <> 'admin' AND appearmenu = 1
		</cfquery><!--- codeblockid IN (#session.codeblock#)  AND--->
		
		oMenu.makeMain(6,'&nbsp;Admin',0)
		<cfset counter2 = 0>
		<cfloop query='getsections'>
			<cfoutput>oMenu.makeSub(6,#counter2#,'#getsections.Sectionname#','/intranet/admin/index2.cfm?id=#codeblockid#',#getsections.recordcount#);</cfoutput>
			<cfset counter2 = counter2+1>
		</cfloop>
*/
--->
/********************************************************************************
End menu construction
********************************************************************************/
//When all the menus are written out we initiates the menu
function showadmin(obj){ oMenu.construct();	obj.style.visibility='hidden'; }
</script>
