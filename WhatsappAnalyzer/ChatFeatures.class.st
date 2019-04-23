"
I provide messages to extract features from the chat.

Currently I provide following messages: 
- 
"
Class {
	#name : #ChatFeatures,
	#superclass : #Object,
	#category : #WhatsappAnalyzer
}

{ #category : #extraction }
ChatFeatures class >> getCharNgramsFromDataFrame: df withN: n [
	"Returns a DataFrame of word ngrams with n = parameter n."

	| outputDf ngrams |
	
	outputDf := DataFrame withColumnNames: #('Author' 'Ngrams').
	df do: [ :row |
		ngrams := self getCharNgramsFromLine: (row at: #Message) withN: n.
		outputDf addRow: { row at: #Author . ngrams } named: (row name).
	].

	^ outputDf
]

{ #category : #extraction }
ChatFeatures class >> getCharNgramsFromLine: line withN: n [
	"Returns an OrderedCollection of character ngrams with n = parameter n."

	| ngrams lastChars |
	ngrams := OrderedCollection new.
	lastChars := OrderedCollection new.
	
	line do: [ :word |
	   (lastChars size < n) ifFalse: [
	      ngrams add: ('' join: lastChars).
	      lastChars removeFirst.
       ].
       lastChars addLast: word.
   ].
	ngrams add: ('' join: lastChars).
	
	^ ngrams
]

{ #category : #extraction }
ChatFeatures class >> getNgramsFromDataFrame: df withN: n [
	"Returns a DataFrame of word ngrams with n = parameter n."

	| outputDf ngrams |
	
	outputDf := DataFrame withColumnNames: #('Author' 'Ngrams').
	df do: [ :row |
		ngrams := self getNgramsFromLine: (row at: #Message) withN: n.
		outputDf addRow: { row at: #Author . ngrams } named: (row name).
	].

	^ outputDf
]

{ #category : #extraction }
ChatFeatures class >> getNgramsFromLine: line withN: n [
	"Returns an OrderedCollection of word ngrams with n = parameter n."

	| ngrams lastWords listOfWords |
	ngrams := OrderedCollection new.
	lastWords := OrderedCollection new.
	listOfWords := line splitOn: Character space.
	
	listOfWords do: [ :word |
	   (lastWords size < n) ifFalse: [
	      ngrams add: (' ' join: lastWords).
	      lastWords removeFirst.
       ].
       lastWords addLast: word.
   ].
	ngrams add: (' ' join: lastWords).
	
	^ ngrams
]
