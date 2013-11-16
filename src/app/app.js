
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
			error: function() {
				me.onAuthorizationChange();
				console.log("Trello authorization failed");
				alert("Trello authorization failed");
			}
		});
	};

	this.logout = function() {
		Trello.deauthorize();
		me.onAuthorizationChange();
	};
	
	this.getBoards = function() {
	
		var $boards = $("<div>")
			.text("Loading Boards...")
			.appendTo("#output");


		Trello.get("members/me/boards", {
				filter: 'open'
			},
			function(cards) {
				$boards.empty();
				$.each(cards, function(ix, board) {
					console.log(board);
					$("<a>")
						.attr({href: board.url, target: "trello"})
						.addClass("board")
						.text(board.name)
						.appendTo($boards);
				});
			},
			function() {
				console.log("Failed to load boards...");
			}  
		);
	};
	
	this.getCards = function() {
		//Trello.post("cards/" + card.id + "/actions/comments", { text: "Hello from jsfiddle.net!" })
		// Output a list of all of the cards that the member 
		// is assigned to
		Trello.get("members/me/cards", {
				filter: 'open'
			},
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
	};


	/* Private Methods */

	this._onAuthorize = function() {
		me.onAuthorizationChange();

		Trello.members.get("me", function(member){
			$("#fullName").text(member.fullName);
			me.getBoards();			
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