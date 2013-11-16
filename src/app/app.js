
window.OFTrello = function(opts) {

	/* Member Variables */

	this.isAuthorized = false;
	this.member = null;
	this.boardsToSync = [];
	this.outputContainer = opts.outputContainer || $("<div>").appendTo($('body'));

	/* Closure debunker */
	var me = this;

	/* Options & Callback */
	this.onAuthorizationChange = function(member) {
		this.isAuthorized = Trello.authorized();
		this.member = member;
		if(opts.onAuthorizationChange) {
			opts.onAuthorizationChange.apply(opts, arguments);
		}
	};
	
	
	
	
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
	
		// Create some containers for displaying results 
		$syncedBoardsHeader = $("<div>")
			.addClass("h-divider")
			.text("Synced Boards")
			.appendTo(this.outputContainer);
		$syncedBoards = $("<div>")
			.attr('id', 'available-boards')
			.appendTo(this.outputContainer);
				
		$availableBoardsHeader = $("<div>")
			.addClass("h-divider")
			.text("Available Boards")
			.appendTo(this.outputContainer);
		$availableBoards = $("<div>")
			.attr('id', 'available-boards')
			.appendTo(this.outputContainer);	
	
		var onClickSyncedBoard = function() {
			var board = $(this).data('board');
			console.log("Removing board \"" + board.name + "\" (id: "+board.id+") from the list of boards to be synced");
			var newBoardsToSync = [];
			for(var i in me.boardsToSync) {
				var aBoard = me.boardsToSync[i];
				if(aBoard.id != board.id) {
					newBoardsToSync.push(aBoard);
				}
			}
			me.boardsToSync = newBoardsToSync;
			window.localStorage.setItem('boardsToSync', JSON.stringify(me.boardsToSync));
			
			$(this).remove();
			$("#board-"+board.id).toggle();
		};
		
		var onClickAvailableBoard = function() {
			var board = $(this).data('board');
			console.log("Adding board \"" + board.name + "\" (id: "+board.id+") to list of boards to be synced");
			me.boardsToSync.push(board);
			window.localStorage.setItem('boardsToSync', JSON.stringify(me.boardsToSync));
			
			$(this).clone()
				.attr('id', "synced-board-"+board.id)
				.data('board', board)
				.click(onClickSyncedBoard)
				.appendTo($syncedBoards);
			$(this).toggle();
		};
	
	
		// List out the boards that are currently being synced
		this.boardsToSync = window.localStorage.getItem('boardsToSync');
		this.boardsToSync = this.boardsToSync ? JSON.parse(this.boardsToSync) : [];
		if(this.boardsToSync.length > 0) {

			$.each(this.boardsToSync, function(ix, board) {
				$("<div>")
					.addClass("board")
					.text(board.name)
					.data('board', board)
					.appendTo($syncedBoards)
					.click(onClickSyncedBoard)
				;
			});	
			
		}else {
			$("<div>")
				.addClass("board")
				.text("No boards currently syncing - add some below!")
				.appendTo($syncedBoards)
			;
		}
		
		
		// List out the boards that are available
		$availableBoards.text("Loading Boards...");
		Trello.get("members/me/boards", {
				filter: 'open'
			},
			function(boards) {
				$availableBoards.empty();
				$.each(boards, function(ix, board) {	
					$board = $("<div>")
						.attr('id','board-'+board.id)
						.addClass("board")
						.text(board.name)
						.data('board', board)
						.appendTo($availableBoards)
						.click(onClickAvailableBoard)
					;
					
					$.each(me.boardsToSync, function(ix, boardToSync) {
						if(boardToSync.id == board.id) {
							$board.toggle();
						}
					});
					
				});
			},
			function(err) {
				console.error("Failed to load boards...");
				console.error(err);
			}  
		);
	};
	
	this.getListFromBoardByName = function(opts) {
		var lowerListName = opts.listName.toLowerCase();
		Trello.get("boards/"+opts.board.id+"/lists", {
				cards: 'open',
				filter: 'open'
			},
			function(lists) {
				opts.board.lists = lists;
				var targetList = null;
				$.each(lists, function(ix, list) {	
					if(list.name.toLowerCase() == lowerListName) {
						targetList = list;
					}else if(!targetList && opts.onFailureReturnFirstList) {
						targetList = list;					
					}
				});
				
				if(targetList) {
					if(opts.success) {
						opts.success(targetList);
					}
				}else {
					if(opts.error) {
						opts.error({
							message: "No list with name '"+opts.listName+"' was found in board '"+opts.board.name+"'"
						});
					}
				}
			},
			function(err) {
				console.error("Failed to load board lists...");
				console.error(err);
				if(opts.error) {
					opts.error(err);
				}
			}  
		);
	};
	
	this.createCard = function(opts) {

		if(!opts || !opts.name || !opts.description || !opts.board) {
			console.warn("OFTrello.createCard(opts) must be provided with opts in form {name:description:due:board}");
			return;
		}
		opts.due = opts.due || null;
		
		
		// Grab the ToDo list
		var list = this.getListFromBoardByName({
			board: opts.board, 
			listName: 'To Do',
			onFailureReturnFirstList: true,
			success: function(list) {
				Trello.post("cards", {
						name: opts.name,
						description: opts.description,
						idList: list.id,
						due: opts.due,
						idMembers: me.member.id,
						pos: 'bottom'
					},
					function(response) {
						console.log("Card created!");
						console.log(response);
					},
					function(err) {
						console.error("Failed to create card...");
						console.error(err);
					}  
				);			
			},
			error: function(err) {
				console.error(err);
			}
		});

	};
	
	this.addOmniFocusTask = function(task) {   	 
   	 	$iframe = $("<iframe>")
			.attr("id", "task-frame")
			.attr("src", "createOmniFocusTask://"+
						encodeURIComponent(task.name)+"/"+
						encodeURIComponent(task.note)+"/"+
						encodeURIComponent(task.project)
			)
			.appendTo(this.outputContainer)			
		;
	}
	


	/* Private Methods */

	this._onAuthorize = function() {
		Trello.members.get("me", function(member){
			me.onAuthorizationChange(member);
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