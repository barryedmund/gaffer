$(document).ready(function() {
	var $default_opts = $('#contract_player_id').children()
	$('input[name=player_position_dropdown]').change(function() {
		$('#contract_player_id').empty().append( $default_opts.clone() );
		if($('#position_dropdown_goalkeeper').is(':checked')) {
			$('#contract_player_id option:not(:contains("(Goalkeeper)"))').remove();
		} else if($('#position_dropdown_defender').is(':checked')) {
			$('#contract_player_id option:not(:contains("(Defender)"))').remove();
		} else if($('#position_dropdown_midfielder').is(':checked')) {
			$('#contract_player_id option:not(:contains("(Midfielder)"))').remove();
		} else if($('#position_dropdown_forward').is(':checked')) {
			$('#contract_player_id option:not(:contains("(Forward)"))').remove();
		} else {
			$('#contract_player_id').empty().append( $default_opts.clone() );
		}
	});
});
