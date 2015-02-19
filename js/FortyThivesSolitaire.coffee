window.Game = {}


class GeneralHelper
    shuffle : (array) ->
        counter = array.length
        while counter > 0
             # Pick a random index
            index = Math.floor Math.random() * counter
            counter--
            temp = array[counter]
            array[counter] = array[index]
            array[index] = temp
        return array;
    getLastElem : (array) ->
         return array.slice(-1)[0]

class Card
   @cardId
   @suit
   @rank
   @movable
   constructor: (@cardId, @suit, @rank, @movable) -> 

   printcard : () -> 
       console.log 'your card is : '+rank+' of '+ suit

   getCardId : () -> @cardId

   getSuit : () -> @suit

   getRank : () -> @rank

   checkIsMovableOrNot : () -> @movable

   makeCardMovable : () -> 
      @movable = true

class Deck
   @maxNumberOfCards
   @deckCards
   @aRankCards
   @Helper
   constructor : () ->
       @Helper = new GeneralHelper()
       @aRankCards = []
       @maxNumberOfCards = 52
       @deckCards = @initDeck()
   
   initDeck : () -> 
       allCards = []
       suits = ['H', 'S', 'C', 'D']
       cardIdCounter = 1
       for suitCounter in suits
           for rankCounter in [1..13]
               if rankCounter == 1
                   @aRankCards.push new Card cardIdCounter, suitCounter, rankCounter, false
               else 
                   allCards.push new Card cardIdCounter, suitCounter, rankCounter, false
               cardIdCounter++
        return allCards

   shuffleDeck : ->
        @deckCards = @Helper.shuffle @deckCards
        if !@deckCards
            return false
        return true
             
   getNextCard : ->
        nextCard = @Helper.getLastElem @deckCards
        @deckCards.pop()
        return nextCard




class Pile
    @maxNumberOfCards
    @circular
    @fanned
    @numberOfCards
    @Helper
    @currentPileCards = []

    constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned) ->
        @Helper = new GeneralHelper()
        @currentPileCards = []

    getNumberOfCards : -> return @numberOfCards

    popCard : -> 
        if @currentPileCards && @currentPileCards.pop()
            @caculateTotalNumberOfCards()
            return true
    pushCard : (card) ->
        moved = @currentPileCards.push card;
        if moved
            @caculateTotalNumberOfCards();
            return true;
        return false;
    getTopCard : ->
        if !@currentPileCards
            false
        return @Helper.getLastElem(@currentPileCards)
    caculateTotalNumberOfCards : ->
        @numberOfCards = @currentPileCards.length
    getNextCard : ->
        nextCard = @getTopCard()
        @popCard()
        @caculateTotalNumberOfCards()
        return nextCard

class DiscardPile extends Pile
      constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned, @currentPileCards = []) ->
          super(@maxNumberOfCards, @circular, @numberOfCards, @fanned)

class FoundationPile extends Pile 
     @startLocation
     @foundationPileId
     constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned, @foundationPileId) ->
        super(@maxNumberOfCards, @circular, @numberOfCards, @fanned)
        @currentPileCards = []
     getFoundationPileId : -> @foundationPileId



class StockPile extends Pile
     constructor : ->
          super(52, false, 32, false)
        
class TableauPile extends Pile
     @tableauPileId
     constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned, @tableauPileId) -> 
        super(@maxNumberOfCards, @circular, @numberOfCards, @fanned)

     getTableauPileId : -> @tableauPileId  

class Game.FortyThieves
      @shuffledDeckCards
      @deckPile
      @foundationPiles
      @stockPile
      @discardPiles
      @tableauPiles
      @deckPileCards
      @Helper
      constructor : ->
          @Helper = new GeneralHelper()
          @deckPile = new Deck()
          @getShuffledDeckCards()
          @foundationPiles = @setFoundationPiles()
          @tableauPiles = @setTableauPiles()
          @dealCards()
          @stockPile = new StockPile()
          @stockPile.currentPileCards = @deckPile.deckCards
          @discardPiles = new DiscardPile(32, false, 0, false)
          @getNextDiscardCard()

      setTableauPiles : ->
          tableauPiles = []
          for counter in [0..9]
             tableauPiles[counter] = new TableauPile(13, false, 2, true, counter)
          return tableauPiles

      setFoundationPiles : ->
          foundationPiles = []
          for counter in [0..3]
              foundationPiles[counter] = new FoundationPile(13, false, 0, true, counter)
              newCard = @deckPile.aRankCards[counter]
              foundationPiles[counter].pushCard newCard
          return foundationPiles

      getShuffledDeckCards : ->
          @deckPile.shuffleDeck()
          return true

      dealCards : -> 
          for key of @tableauPiles
            for counter in [0..1]
                nextCard = @deckPile.getNextCard()
                @tableauPiles[parseInt(key)].pushCard nextCard
          return true

      getTableauPileById : (tableauPileId) ->
          key = 0
          for tableauPile in @tableauPiles
              if tableauPile.getTableauPileId() == parseInt tableauPileId
                  return key
              key++


      getFoundationPileById : (toFoundationPileId) ->
          key = 0
          for foundationPile in @foundationPiles
              if foundationPile.foundationPileId == parseInt toFoundationPileId
                  return key
              key++

      moveCardToAnotherTableauPile : (pileFromId, pileToId) ->
          pileFromKey = @getTableauPileById(pileFromId)
          pileToKey = @getTableauPileById(pileToId)
          cardToMove = @tableauPiles[pileFromKey].getTopCard()
          if @tableauPiles[pileToKey].currentPileCards.length > 0
            destinationCard = @tableauPiles[pileToKey].getTopCard()
            if(@testValidTableauMove(cardToMove, destinationCard))
                @tableauPiles[pileFromKey].popCard()
                @tableauPiles[pileToKey].pushCard(cardToMove)
                return true
            else
                return false
          else
            @tableauPiles[pileFromKey].popCard()
            @tableauPiles[pileToKey].pushCard(cardToMove)
            return true

      moveCradFromDiscardToFoundationPile : (pileToId) ->
          pileToKey = @getFoundationPileById(pileToId)
          cardToMove = @discardPiles.getTopCard()
          destinationCard = @foundationPiles[pileToKey].getTopCard()
          if @testValidFoundationMove(cardToMove, destinationCard)
            @discardPiles.popCard()
            @foundationPiles[pileToKey].pushCard(cardToMove)
            if @discardPiles.numberOfCards < 1
              @getNextDiscardCard()
            return true
          else
            return false

      moveCardFromTableauToFoundationPile : (pileFromId, pileToId) ->
          pileFromKey = @getTableauPileById(pileFromId)
          pileToKey = @getFoundationPileById(pileToId)
          cardToMove = @tableauPiles[pileFromKey].getTopCard()
          destinationCard = @foundationPiles[pileToKey].getTopCard()
          if @testValidFoundationMove(cardToMove, destinationCard)
            @tableauPiles[pileFromKey].popCard()
            @foundationPiles[pileToKey].pushCard(cardToMove)
            return true
          else
            return false

      moveCradFromDiscardToTableauPile : (pileToId) ->
          pileToKey = @getTableauPileById(pileToId)
          cardToMove = @discardPiles.getTopCard()
          if @tableauPiles[pileToKey].currentPileCards.length > 0
            destinationCard = @tableauPiles[pileToKey].getTopCard()
            if @testValidTableauMove(cardToMove, destinationCard)
              makeMove = true
            else
              return false
          else
              makeMove = true
          if makeMove
            @discardPiles.popCard()
            @tableauPiles[pileToKey].pushCard(cardToMove)
            if @discardPiles.numberOfCards < 1
                @getNextDiscardCard()
            return true

      testValidFoundationMove : (cardToMove, destinationCard) ->
          if destinationCard.getSuit() == cardToMove.getSuit() && destinationCard.getRank()+1 == cardToMove.getRank()
              return true
          else
              return false

      testValidTableauMove : (cardToMove, cardOntoMove) ->
          if cardOntoMove.getSuit() == cardToMove.getSuit() && cardToMove.getRank()+1 == cardOntoMove.getRank()
              return true
          else
              return false

      getNextDiscardCard : ->
          if parseInt(@stockPile.getNumberOfCards()) > 0
              @discardPiles.pushCard(@stockPile.getNextCard())
              @discardPiles.caculateTotalNumberOfCards()
              return true
          return false

      checkIfGameWon : ->
          wonFlag = true
          for fPile in @foundationPiles
            if fPile.currentPileCards.length < 13
              wonFlag = false
          if wonFlag
            alert "Congratulations ..!! You have won the game..."
            window.location.reload()