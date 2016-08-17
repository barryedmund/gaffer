$(document).ready(function() {
	var $default_opts = $('#contract_player_id').children()
	$('input[name=player_position_dropdown]').change(function() {
		$('#contract_player_id').empty().append( $default_opts.clone() );
		if($('#position_dropdown_goalkeeper').is(':checked')) {
			$('#contract_player_id option:not(:contains("(GK"))').remove();
		} else if($('#position_dropdown_defender').is(':checked')) {
			$('#contract_player_id option:not(:contains("(DF"))').remove();
		} else if($('#position_dropdown_midfielder').is(':checked')) {
			$('#contract_player_id option:not(:contains("(MD"))').remove();
		} else if($('#position_dropdown_forward').is(':checked')) {
			$('#contract_player_id option:not(:contains("(FW"))').remove();
		} else {
			$('#contract_player_id').empty().append( $default_opts.clone() );
		}
	});
});
