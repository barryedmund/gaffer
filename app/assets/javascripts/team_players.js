$(document).ready(function() {
	if(getCookie() == "contract_details"){
		$('.contract_details').removeClass("hide");
		$('.performance_details').addClass("hide");
	}
	else if(getCookie() == "performance_details"){
		$('.contract_details').addClass("hide");
		$('.performance_details').removeClass("hide");
	}
	$('#contract_details_link').click(function(){
		$('.contract_details').removeClass("hide");
		$('.performance_details').addClass("hide");
		setCookie("contract_details");
	});
	$('#performance_details_link').click(function(){
		$('.contract_details').addClass("hide");
		$('.performance_details').removeClass("hide");
		setCookie("performance_details");
	});
});

function setCookie(cvalue) {
  var d = new Date();
  d.setTime(d.getTime() + (365*24*60*60*1000));
  var expires = "expires="+ d.toUTCString();
  document.cookie = "team_players_view_mode=" + cvalue + "; " + expires;
}

function getCookie() {
  var name = "team_players_view_mode=";
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
