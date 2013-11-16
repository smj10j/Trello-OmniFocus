
var doAuthorize = function() {
	Trello.authorize({
		type: 'popup',
		name: 'OmniFocus to Trello Sync',
		persist: true,
		interactive: true,
		scope: {
			read: true, 
			write: true,
			account: false,
		},
		expiration: 'never',
		success: onAuthorize,
		error: function() {
	
		}
	});
};

var doLogout = function() {
	Trello.deauthorize();
	onAuthorizationChange();
};

var onAuthorize = function() {
	onAuthorizationChange();

	Trello.members.get("me", function(member){
		$("#fullName").text(member.fullName);

		var $cards = $("<div>")
			.text("Loading Cards...")
			.appendTo("#output");

		// Output a list of all of the cards that the member 
		// is assigned to
		Trello.get("members/me/cards", function(cards) {
			$cards.empty();
			$.each(cards, function(ix, card) {
				$("<a>")
				.attr({href: card.url, target: "trello"})
				.addClass("card")
				.text(card.name)
				.appendTo($cards);
			});  
		});
	});
};

var onAuthorizationChange = function() {
	var isLoggedIn = Trello.authorized();
	$("#loggedout").toggle(!isLoggedIn);
	$("#loggedin").toggle(isLoggedIn); 
	$("#output").empty();
};
