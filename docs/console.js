input = "";
$(function() {
	$('html').on('click', function() {
		$('#input').focus();
	});

	$('#input').on('keydown', function search(e) {
		if (e.keyCode == 13) {
			input = $(this).val();
			
			// append your output to the history,
			// here I just append the input
			$('#history').append($('#promt').html() + $(this).val() + '<br/>');
			input_buffer = $(this).val()

			$('#promt').html('');

			// clear the input
			$('#input').val('');

		}
	});
});
