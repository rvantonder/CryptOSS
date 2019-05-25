$(document).ready(function() {

    // check url for hash to sort by
    sortby = window.location.hash.substr(1);

    switch (sortby) {
    case "changes-additions-7d":
	$("#table").tablesorter({
	    sortList: [[2,1]]
	});
	break;
    case "changes-deletions-7d":
		$("#table").tablesorter({
	    sortList: [[3,1]]
	});
	break;
    case "commits-24h":
	$("#table").tablesorter({
	    sortList: [[4,1]]
	});
	break;
    case "commits-7d":
	$("#table").tablesorter({
	    sortList: [[5,1]]
	});
	break;
    case "commits-1y":
	$("#table").tablesorter({
	    sortList: [[6,1]]
	});
	break;
    case "devs-7d":
	$("#table").tablesorter({
	    sortList: [[7,1]]
	});
	break;
    case "devs-all":
	$("#table").tablesorter({
	    sortList: [[8,1]]
	});
	break;
    case "stars":
	$("#table").tablesorter({
	    sortList: [[9,1]]
	});	break;
    case "forks":
	$("#table").tablesorter({
	    sortList: [[10,1]]
	});	break;
    case "watchers":
	$("#table").tablesorter({
	    sortList: [[11,1]]
	});	break;
    default:
	break;
    }

    // callback for when someone clicks on the table to sort. we'll change the
    // anchor to match if it is one of the sortable things in the second row
    $(function () {

	$('table')
            .on('click', 'thead th', function(){
		var col = $(this).parent().children().index($(this));
		var row = $(this).parent().parent().children().index($(this).parent());

		if (row == 1) {
		    if (col == 2) {
			window.location.hash = '#changes-additions-7d';
		    } else if (col == 3) {
			window.location.hash = '#changes-deletions-7d';
		    } else if (col == 4) {
			window.location.hash = '#commits-24h';
		    } else if (col == 5) {
			window.location.hash = '#commits-7d';
		    } else if (col == 6) {
			window.location.hash = '#commits-1y';
		    } else if (col == 7) {
			window.location.hash = '#devs-7d';
		    } else if (col == 8) {
			window.location.hash = '#devs-all';
		    } else if (col == 9) {
			window.location.hash = '#stars';
		    } else if (col == 10) {
			window.location.hash = '#forks';
		    } else if (col == 11) {
			window.location.hash = '#watchers';
		    }
		}
	});

    });

});

var toggled = false;

function toggle_hide_empty() {
    if (toggled) {
	toggled = false;
	$("#table tr td").each(function() {
		$(this).parent().show();
	});
	$("#toggleEmptyButton").html('HIDE EMPTY');
    } else {
	toggled = true;
	$("#table tr td").each(function() {
	    var cellText = $.trim($(this).text());
	    if (cellText.length == 0) {
		$(this).parent().hide();
	    }
	$("#toggleEmptyButton").html('SHOW EMPTY');
	});
    }
}
