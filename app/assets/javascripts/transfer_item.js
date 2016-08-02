$(document).ready(function() {
    $('[id^=transfer_item_sending_team_id_]').change(function() {
  		var sending_value = $(this).attr('value');
  		var other_value = $(this).siblings('input').attr('value');
  		$('#transfer_item_receiving_team_id').val(other_value);
		});
		if($('#transfer_item_transfer_item_type_cash').is(':checked')) {
			$('#transfer_item_cash_div').removeClass("hidden_div");
			$('#transfer_item_player_div').addClass("hidden_div");
		}
		$('#transfer_item_transfer_item_type_cash').change(function() {
			if($('#transfer_item_transfer_item_type_cash').is(':checked')) {
				$('#transfer_item_cash_div').removeClass("hidden_div");
				$('#transfer_item_player_div').addClass("hidden_div");
			}	
		});
		$('#transfer_item_transfer_item_type_player').change(function() {
			if($('#transfer_item_transfer_item_type_player').is(':checked')) {
				$('#transfer_item_player_div').removeClass("hidden_div");
				$('#transfer_item_cash_cents').val('');
				$('#transfer_item_cash_cents').blur();
				$('#transfer_item_cash_div').addClass("hidden_div");
			}	
		});
});
