class Game.ViewHelper
	createNewCard : (card, dataPile) ->
		imgPath = @getCardImagePath(card)
		console.log imgPath
		newCard = '<div class="card" data-pile="'+dataPile+'" style="background-image: url('+imgPath+')" data-cardId="'+card.cardId+'">
				<div class="cardId" style="display:none">
					'+card.cardId+'
				</div>
				<div class="suit" style="display:none">
					'+card.suit+'
				</div>
				<div class="rank" style="display:none">
					'+card.rank+'
				</div>
				</div>';
		return newCard

	getCardImagePath : (card) ->
		path = 'img\/cards\/Cards_'+card.suit+''+card.rank+'.png'.toString()
		return path


	createStockPile : (stockPile) ->
		newStockPile = ''
		if stockPile.currentPileCards
			for pileCard in stockPile.currentPileCards
				newStockPile += @createNewCard(pileCard, 'stock-pile')
		return newStockPile

	createDiscardPile : (discardPile) ->
		newDiscardPile = ''
		if discardPile.currentPileCards
			for pileCard in discardPile.currentPileCards
				newDiscardPile += @createNewCard(pileCard, 'discard-pile')
		return newDiscardPile

	createFoundationPiles : (foundataionPiles) ->
		newFoundataionPiles = ''
		for fPile in foundataionPiles
			newFoundataionPiles += '<div class="foundationCards" data-foundation-id="'+fPile.foundationPileId+'">'
			for pileCard in fPile.currentPileCards
				newFoundataionPiles += @createNewCard(pileCard, 'foundation-pile')
			newFoundataionPiles += '</div>';	
		return newFoundataionPiles

	createTableauPiles : (tableauPiles) ->
		newTableauPiles = ''
		for tPiles in tableauPiles
			newTableauPiles += '<div class="tableauCards" data-tableau-id="'+tPiles.tableauPileId+'">'
			for pileCard in tPiles.currentPileCards
				newTableauPiles += @createNewCard(pileCard, 'tableau-pile')
			newTableauPiles += '</div>';
		return newTableauPiles
	
	getNewDiscardCard : (gameObject, discardContainerClass) ->
		$('.'+discardContainerClass).html(@createDiscardPile(gameObject.discardPiles))

	makeCardDraggable : (pileCards) ->
		if pileCards.length > 0
			# Search for the last card in the pie and make it draggable
			card = pileCards[pileCards.length - 1]
			selector = $('[data-cardId='+card.cardId+']')
			selector.css('cursor', 'move');
			selector.draggable({
				revert: 'invalid',
				containment: "document",
				start : ->
					selector.data("origPosition", selector.position());
					selector.css('z-index', 999999)
				stop : ->
					selector.css('z-index', 0)
			})
		return true

	makeTableauPileCardsDraggable : (newGame) ->
		for tPiles in newGame.tableauPiles
			@makeCardDraggable tPiles.currentPileCards

	makeCardNonMovable : (card) ->
		#Search for the card in the ui and if it is movable make it non-movable.
		$('[data-cardId='+card.cardId+']').draggable( "destroy" )
		return true

	createFoundationDropPoints : (newGame) ->
		self = @
		for fPile in newGame.foundationPiles
			targetElem = $('[data-foundation-id='+fPile.foundationPileId+']')
			targetElem.droppable({
				accept : ".card",
				drop : (event, ui) ->
					attrVal = ui.draggable.attr('data-pile')
					toPileId = $(event.target).attr('data-foundation-id')
					switch attrVal
						when 'discard-pile'
							moved = newGame.moveCradFromDiscardToFoundationPile(toPileId)
							if !moved
								ui.draggable.draggable('option','revert',true);
								returnVal = true
							else
								newGame.checkIfGameWon()
								$(ui.draggable).attr('data-pile', 'foundation-pile')
								ui.draggable.removeAttr('style')
								$('.discard').html(self.createDiscardPile(newGame.discardPiles))
								$('.foundataions').html(self.createFoundationPiles(newGame.foundationPiles));
								self.createFoundationDropPoints(newGame)
								self.makeCardDraggable(newGame.discardPiles.currentPileCards)
								returnVal = true
						when 'tableau-pile'
							pileFromId = $(ui.draggable).parent().attr('data-tableau-id')
							moved = newGame.moveCardFromTableauToFoundationPile(pileFromId, toPileId)
							if !moved
								ui.draggable.draggable('option','revert',true);
								returnVal = true
							else
								newGame.checkIfGameWon()
								$(ui.draggable).attr('data-pile', 'foundation-pile')
								ui.draggable.removeAttr('style')
								$('.tableauSection').html(self.createTableauPiles(newGame.tableauPiles));
								$('.foundataions').html(self.createFoundationPiles(newGame.foundationPiles));
								self.createFoundationDropPoints(newGame)
								self.makeTableauPileCardsDraggable(newGame)
								self.createTableauDropPoints(newGame)
								returnVal = true
					return returnVal
			})
		return true

	createTableauDropPoints : (newGame) ->
		self = @
		for tPile in newGame.tableauPiles
			pileElem = $('[data-tableau-id='+tPile.tableauPileId+']')
			targetElem = pileElem.find('.card:last')
			if targetElem.length > 0
				targetElem = targetElem
			else
				targetElem = pileElem
			targetElem.droppable({
				accept : ".card",
				drop : (event, ui) ->
					attrVal = ui.draggable.attr('data-pile')
					if $(event.target).attr('data-tableau-id')
						toPileId = $(event.target).attr('data-tableau-id')
					else
						toPileId = $(event.target).parent().attr('data-tableau-id')
					returnVal = false
					switch attrVal
						when 'discard-pile'
							moved = newGame.moveCradFromDiscardToTableauPile(toPileId)
							if !moved
								ui.draggable.draggable('option','revert',true);
								returnVal = false
							else
								$('.discard').html(self.createDiscardPile(newGame.discardPiles))
								$('.tableauSection').html(self.createTableauPiles(newGame.tableauPiles));
								self.makeCardDraggable(newGame.discardPiles.currentPileCards)
								self.makeTableauPileCardsDraggable(newGame)
								self.createTableauDropPoints(newGame)
								returnVal = true
						when 'tableau-pile'
							pileFromId = $(ui.draggable).parent().attr('data-tableau-id')
							moved = newGame.moveCardToAnotherTableauPile(pileFromId, toPileId)
							if !moved
								ui.draggable.draggable('option','revert',true);
								returnVal = false
							else
								$('.tableauSection').html(self.createTableauPiles(newGame.tableauPiles));
								self.makeTableauPileCardsDraggable(newGame)
								self.createTableauDropPoints(newGame)
								returnVal = true
					return returnVal
			
			})
		return true


