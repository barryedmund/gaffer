$(document).ready(function() {
	if(getCookie() == "detailed_stats"){
		$('.detailed_stats').removeClass("hide");
		$('#detailed_stats_link').addClass("selected-tab");
		
		$('.summary_stats').addClass("hide");
		$('#summary_stats_link').removeClass("selected-tab");
	}
	else if(getCookie() == "summary_stats"){
		$('.summary_stats').removeClass("hide");
		$('#summary_stats_link').addClass("selected-tab");
		
		$('.detailed_stats').addClass("hide");
		$('#detailed_stats_link').removeClass("selected-tab");
	}
	$('#detailed_stats_link').click(function(){
		$('.detailed_stats').removeClass("hide");
		$('#detailed_stats_link').addClass("selected-tab");
		
		$('.summary_stats').addClass("hide");
		$('#summary_stats_link').removeClass("selected-tab");
		
		setCookie("detailed_stats");
	});
	$('#summary_stats_link').click(function(){
		$('.summary_stats').removeClass("hide");
		$('#summary_stats_link').addClass("selected-tab");
		
		$('.detailed_stats').addClass("hide");
		$('#detailed_stats_link').removeClass("selected-tab");

		setCookie("summary_stats");
	});
});

function setCookie(cvalue) {
  var d = new Date();
  d.setTime(d.getTime() + (365*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = "game_view_mode=" + cvalue + "; " + expires;
}

function getCookie() {
  var name = "game_view_mode=";
  var ca = document.cookie.split(';');
  for(var i = 0; i <ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0)==' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length,c.length);
    }
  }
  return "";
}
