// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$('td#toggle_fold > a').click(function(event) {
	event.preventDefault();

	if (toggle_fold) {
		alert("in cache");
		if (toggle_fold.html() == "^") {
			toggle_fold.parent().parent().next().detach();
		}
	}
});
