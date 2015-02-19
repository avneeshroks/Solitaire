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
   constructor: (@cardId, @suit, @rank) -> 

   printcard : () -> 
       console.log 'your card is : '+rank+' of '+ suit

   getCardId : () -> @cardId

   getSuit : () -> @suit

   getRank : () -> @rank

   makeCardMovable : (targetElem) -> 
      targetElem.draggable();

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
       cardIdCounter = 0
       for suitCounter in suits
           for rankCounter in [1..13]
               if rankCounter == 1
                   @aRankCards[@aRankCards.length] = new Card cardIdCounter, suits[suitCounter], rankCounter
               else 
                   allCards[allCards.length] = new Card cardIdCounter, suits[suitCounter], rankCounter
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

    getNumberOfCards : -> return @numberOfCards

    popCard : -> 
        if @currentPileCards && @currentPileCards.pop()
            @caculateTotalNumberOfCards()
            return true
    pushCard : (card) ->
        moved = @currentPileCards[@currentPileCards.length] = card;
        if moved
            @caculateTotalNumberOfCards();
            return true;
        return false;
    getTopCard : ->
        if !@currentPileCards
            false
        return @Helper.getLastElem @currentPileCards
    caculateTotalNumberOfCards : ->
        @numberOfCards = @currentPileCards.length
    getNextCard : ->
        nextCard = @getTopCard
        @popCard
        @caculateTotalNumberOfCards
        return nextCard

class DiscardPile extends Pile
      constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned, @currentPileCards = []) ->


class FoundationPile extends Pile 
     @startLocation
     @foundationPileId
     constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned, @foundationPileId) ->
        @currentPileCards = []
     getFoundationPileId : -> @foundationPileId



class StockPile extends Pile
     constructor : ->
          @maxNumberOfCards = 32
          @numberOfCards = 32
          @circular = false
          @fanned = false
        
class TableauPile extends Pile
     @tableauPileId
     constructor : (@maxNumberOfCards, @circular, @numberOfCards, @fanned, @tableauPileId) -> 
     getTableauPileId : -> @tableauPileId  

class FortyThieves
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
          @dealCards
          @stockPile = new StockPile()
          @discardPiles = new DiscardPile(32, false, 0, false)
          @getNextDiscardCard

      setTableauPiles : ->
          tableauPiles = []
          for counter in [0..9]
             tableauPiles[counter] = new TableauPile(13, false, 2, true, counter)
          return tableauPiles

      setFoundationPiles : ->
          foundationPiles = []
          for counter in [0..3]
              foundationPiles[counter] = new FoundationPile(13, false, 0, true, counter)
              newCard = @Helper.getLastElem(@deckPile.aRankCards)
              foundationPiles[counter].pushCard newCard
          return foundationPiles

      getShuffledDeckCards : ->
          @deckPile.shuffleDeck()
          return true

      dealCards : -> 
          for key in @tableauPiles
            for counter in [0..2]
                nextCard = @deckPile.getNextCard()
                @tableauPiles[key].pushCard nextCard

          return true
