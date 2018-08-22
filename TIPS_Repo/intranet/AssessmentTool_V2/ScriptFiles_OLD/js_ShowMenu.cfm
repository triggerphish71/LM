<script language="javascript">
	
	subActive = false;
	var timerSet = null;
	var theLayer = null;
	
	function TimeoutOver()
	{
		setTimeout("ShowOut()",600);
	}
	
	function ShowOut()
	{
		if(!subActive)
		{
			HideMenu(theLayer);
		}
	}
	
	function SubOver(obj)
	{
		clearTimeout(timerSet);
		obj.childNodes[0].className = 'subNavigationOver';
		subActive = true;	
	}
	
	function SubOut(obj)
	{
		subActive = false;
		obj.childNodes[0].className = 'subNavigation';
		timerSet = setTimeout("HideMenu(theLayer)",100);
	}
	
	function ShowMenu(mainMenu,subMenu)
	{	
		
		if(timerSet != null)
		{
			clearTimeout(timerSet);
		}
		
		theMenu = document.getElementsByName(mainMenu)[0];
		theSubMenu = document.getElementsByName(subMenu)[0];
		
		x = findX(theMenu);
		y = findY(theMenu);
		
		w = theMenu.offsetWidth;
		
		theSubMenu.style.left = x;
		theSubMenu.style.top =  y + 20;
		theSubMenu.setAttribute("width",w);
		
		theSubMenu.style.visibility = 'visible';
		theLayer = theSubMenu;
	}
	
	function HideMenu(obj)
	{	        
		if(!subActive)
		{
			obj.style.visibility = 'hidden';
		}
	}
	
	function findX(obj)
	{
		var curleft = 0;
		
		if (obj.offsetParent)
		{
			while (obj.offsetParent)
			{
				curleft += obj.offsetLeft
				obj = obj.offsetParent;
			}
		}
		else if (obj.x)
		{
			curleft += obj.x;
		}
		
		return curleft;
	}

	function findY(obj)
	{
		var curtop = 0;
		
		if (obj.offsetParent)
		{
			while (obj.offsetParent)
			{
			curtop += obj.offsetTop
			obj = obj.offsetParent;
			}
		}
		else if (obj.y)
		{
			curtop += obj.y;
		}
		return curtop;
	}
</script>