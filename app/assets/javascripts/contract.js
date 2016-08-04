$(document).ready(function() {
  $('input[name=player_position_dropdown]').change(function() {
  	if($('#position_dropdown_goalkeeper').is(':checked')) {
  		$('#contract_player_id').find('option').show();
			$('#contract_player_id').find('option').filter(':not(:contains("(Goalkeeper)"))').hide();
			$("#contract_player_id").val($("#contract_player_id option:first").val());
		}
		else if($('#position_dropdown_defender').is(':checked')) {
			$('#contract_player_id').find('option').show();
			$('#contract_player_id').find('option').filter(':not(:contains("(Defender)"))').hide();
			$("#contract_player_id").val($("#contract_player_id option:first").val());
		}
		else if($('#position_dropdown_midfielder').is(':checked')) {
			$('#contract_player_id').find('option').show();
			$('#contract_player_id').find('option').filter(':not(:contains("(Midfielder)"))').hide();
			$("#contract_player_id").val($("#contract_player_id option:first").val());
		}
		else if($('#position_dropdown_forward').is(':checked')) {
			$('#contract_player_id').find('option').show();
			$('#contract_player_id').find('option').filter(':not(:contains("(Forward)"))').hide();
			$("#contract_player_id").val($("#contract_player_id option:first").val());
		}
		else {
			$('#contract_player_id').find('option').show();
			$("#contract_player_id").val($("#contract_player_id option:first").val());
		}
  });
});
