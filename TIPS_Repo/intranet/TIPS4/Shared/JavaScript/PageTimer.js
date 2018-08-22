<cfif FileExists(ExpandPath("../logout.cfm"))>
	<script type="text/javascript">
		var nbrMinutes = 30;
		var theReset = nbrMinutes * 60000;
		var theTime = nbrMinutes * 60000;
		function idleLogout() {
			var t;
			window.onload = resetTimer;
			window.onmousemove = resetTimer;
			window.onmousedown = resetTimer; // catches touchscreen presses
			window.onclick = resetTimer;     // catches touchpad clicks
			window.onscroll = resetTimer;    // catches scrolling with arrow keys
			window.onkeypress = resetTimer;
			document.onkeydown=resetTimer ;    
			document.onkeyup=resetTimer ;   
			document.onmouseup=resetTimer ;  
			document.ondblclick=resetTimer;
		
			function logout() {
				window.location.href = '../logout.cfm';
			}
		
			function resetTimer() {
				clearTimeout(t);
				t = setTimeout(logout, theReset); 
		 //       t = setTimeout(logout, 120000); 		
				 // time is in milliseconds
			}
		}
		idleLogout();
	</script> 
<cfelseif  FileExists(ExpandPath("../../logout.cfm"))>
	<script type="text/javascript">
		var nbrMinutes = 30;
		var theReset = nbrMinutes * 60000;
		var theTime = nbrMinutes * 60000;
		function idleLogout() {
			var t;
			window.onload = resetTimer;
			window.onmousemove = resetTimer;
			window.onmousedown = resetTimer; // catches touchscreen presses
			window.onclick = resetTimer;     // catches touchpad clicks
			window.onscroll = resetTimer;    // catches scrolling with arrow keys
			window.onkeypress = resetTimer;
			document.onkeydown=resetTimer ;    
			document.onkeyup=resetTimer ;   
			document.onmouseup=resetTimer ;  
			document.ondblclick=resetTimer;
		
			function logout() {
				window.location.href = '../../logout.cfm';
			}
		
			function resetTimer() {
				clearTimeout(t);
				t = setTimeout(logout, theReset); 
		 //       t = setTimeout(logout, 120000); 		
				 // time is in milliseconds
			}
		}
		idleLogout();
	</script> 
<cfelse>
	<script type="text/javascript">
		var nbrMinutes = 30;
		var theReset = nbrMinutes * 60000;
		var theTime = nbrMinutes * 60000;
		function idleLogout() {
			var t;
			window.onload = resetTimer;
			window.onmousemove = resetTimer;
			window.onmousedown = resetTimer; // catches touchscreen presses
			window.onclick = resetTimer;     // catches touchpad clicks
			window.onscroll = resetTimer;    // catches scrolling with arrow keys
			window.onkeypress = resetTimer;
			document.onkeydown=resetTimer ;    
			document.onkeyup=resetTimer ;   
			document.onmouseup=resetTimer ;  
			document.ondblclick=resetTimer;
		
			function logout() {
				window.location.href = 'logout.cfm';
			}
		
			function resetTimer() {
				clearTimeout(t);
				t = setTimeout(logout, theReset); 
		 //       t = setTimeout(logout, 120000); 		
				 // time is in milliseconds
			}
		}
		idleLogout();
	</script> 
</cfif>
