
window.OFTrello = function(opts) {

	/* Member Variables */
	this.onAuthorizationChange = opts.onAuthorizationChange || function() {};
	var me = this;
	
	
	/* Public Methods */
	
	this.authorize = function() {
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
			success: me._onAuthorize,
			error: function(err) {
				me.onAuthorizationChange();
				console.log("Failed to authorize with Trello");
				console.log(err);
				alert("Failed to authorize for Trello access");
			}
		});
	};

	this.logout = function() {
		Trello.deauthorize();
		me.onAuthorizationChange();
	};
	
	this.getBoards = function() {
		Trello.boards.get("me", function(member) {
			$("#fullName").text(member.fullName);

			var $cards = $("<div>")
				.text("Loading Cards...")
				.appendTo("#output");

			// Output a list of all of the cards that the member 
			// is assigned to
			Trello.get("members/me/cards/open", 
				{},
				function(cards) {
					$cards.empty();
					$.each(cards, function(ix, card) {
						$("<a>")
							.attr({href: card.url, target: "trello"})
							.addClass("card")
							.text(card.name)
							.appendTo($cards);
					});
				},
				function() {
			
				}  
			);
		});
	};


	/* Private Methods */
	//Trello.post("cards/" + card.id + "/actions/comments", { text: "Hello from jsfiddle.net!" })
	this._onAuthorize = function() {
		me.onAuthorizationChange();

		Trello.members.get("me", function(member){
			$("#fullName").text(member.fullName);

			var $cards = $("<div>")
				.text("Loading Cards...")
				.appendTo("#output");

			// Output a list of all of the cards that the member 
			// is assigned to
			Trello.get("members/me/cards/open", 
				{},
				function(cards) {
					$cards.empty();
					$.each(cards, function(ix, card) {
						$("<a>")
							.attr({href: card.url, target: "trello"})
							.addClass("card")
							.text(card.name)
							.appendTo($cards);
					});
				},
				function() {
			
				}
			);
		});
	};


	/* Instantiation */
	
	// Auto-login for already authorized clients
	Trello.authorize({
		interactive:false,
		success: me._onAuthorize,
		error: me.onAuthorizationChange
	});
};