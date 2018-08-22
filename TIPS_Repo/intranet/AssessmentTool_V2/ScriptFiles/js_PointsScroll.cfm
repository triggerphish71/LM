<script language="javascript">
	window.onscroll = PointsScroll;
	var pointsObj = document.getElementsByName('pointsSpan')[0];
	var pointsTop = pointsObj.offsetTop;
	
	function PointsScroll()
	{
		//get the points div
		var theY =  GetScrollY();
		
		if(pointsTop - theY < 0)
		{
			pointsObj.style.top = theY - pointsTop;
		}
		else
		{
			pointsObj.style.top = 0;
		}
		
	}
	
	function GetScrollY() 
	{
	  var scrOfY = 0;
	  
	  if( typeof( window.pageYOffset ) == 'number' ) 
	  {
	    //Netscape compliant
	    scrOfY = window.pageYOffset;
	  } 
	  else if( document.body && document.body.scrollTop) 
	  {
	    //DOM compliant
	    scrOfY = document.body.scrollTop;
	  } 
	  else if( document.documentElement && document.documentElement.scrollTop)
	  {
	    //IE6 standards compliant mode
	    scrOfY = document.documentElement.scrollTop;
	  }
	  return scrOfY;
	}
	
</script>