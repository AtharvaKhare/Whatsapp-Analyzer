"
I am a class which analyzes a Whatsapp exported chat.


I store parsed chat data along with the analysis performed on it. I provide API for carrying out the analysis as well as storing it.

Public API and Key Messages

	None yet.
 
Internal Representation and Key Implementation Points.

    TODO: What will go here?
"
Class {
	#name : #ChatDataFrame,
	#superclass : #DataFrame,
	#category : #WhatsappAnalyzer
}

{ #category : #processing }
ChatDataFrame >> charNgram: n atIndex: rowIndex [
	"Given n, this message generates character n-gram at given rowIndex"

	| listOfChars ngrams lastChars |
	listOfChars := (self rowAt: rowIndex) at: #Message.
	ngrams := OrderedCollection new.
	lastChars := OrderedCollection new.
	listOfChars do: [ :word |
		(lastChars size < n)
			ifFalse: [ 
				ngrams add: ('' join: lastChars).
				lastChars removeFirst.
		 		].
				lastChars addLast: word.
		].
	ngrams add: ('' join: lastChars).
	^ ngrams
]

{ #category : #processing }
ChatDataFrame >> charNgram: n atName: rowName [
	"Given n, this message generates char n-gram at given rowName"

	^ (self charNgram: n atIndex: (rowName+1))
]

{ #category : #initialization }
ChatDataFrame >> initialize [
	"Initializes the object"

	super initialize.
]

{ #category : #cleaning }
ChatDataFrame >> messagesAsLowercase [
	"Returns a DataSeries of the message column with lowercase strings"

	^ ((self column: #Message) collect: [ :message | message asLowercase ]) asArray.
]

{ #category : #cleaning }
ChatDataFrame >> messagesKeepOnlyEmojis [
	"Returns the #Message column while removing non-emoji characters. The regex might not work perfectly"

	^ ((self column: #Message) collect: [ :message |
			message copyWithRegex: '[\w\d\s\\:.,''"-/?!()[]<>@’^“”=+_]' matchesReplacedWith: ''
			]
		) asArray.
]

{ #category : #parsing }
ChatDataFrame >> parseChat: chatFilePath [
	"Parses the exported file from Whatsapp into the DataFrame."

	| chatFileStream line hyphenIndex commaIndex colonIndex oldRow |
	chatFileStream := chatFilePath asFileReference readStream.
	chatFileStream nextLine.
	[ chatFileStream atEnd] whileFalse: [ 
		line := chatFileStream nextLine.
		(line isNotEmpty) ifTrue: [
			((line copyUpTo: $,) matchesRegex: '\d(\d)?/\d(\d)?/\d\d') 
				ifTrue: [ 
					commaIndex := line indexOf: $,.
					hyphenIndex := line indexOf: $-.
					colonIndex := line indexOf: $: startingAt: hyphenIndex.
					(colonIndex ~= 0 ) ifTrue: [ 
						self addRow: { 
							line copyUpTo: $, .
							line copyFrom: commaIndex+2 to: hyphenIndex-2 .
							line copyFrom: hyphenIndex+2 to: colonIndex-1 .
							(line copyFrom: colonIndex+1 to: line size) allButFirst
			 				} named: self numberOfRows.
							]
				 ]
				ifFalse: [
					oldRow := self row: (self size - 1).
					oldRow at: 'Message' put: ((oldRow at: 'Message') , '\n' , line).
					self removeRow: (self size - 1).
					self addRow: oldRow.
					 ]
			]
	 ]
]

{ #category : #cleaning }
ChatDataFrame >> setTypes [
	"Transforms the DataFrame columns into appropriate types"

	self do: [ :row |
	row at: #Date transform: [ :date | date asDate ].
	row at: #Time transform: [ :time | time asTime ].
	row at: #Message transform: [ :message | message asWideString ].
	 ].
]

{ #category : #cleaning }
ChatDataFrame >> stripMessagePunctuation [
	"Returns a DataSeries with removes punctuation and digits from #Message"

	^ ((self column: #Message) collect: [ :message |
			message copyWithRegex: '[^\w\s]' matchesReplacedWith: ''
			]
		) asArray.
]

{ #category : #processing }
ChatDataFrame >> wordNgram: n atIndex: rowIndex [
	"Given n, this message generates character n-gram at given rowIndex"

	| listOfWords ngrams lastWords |
	listOfWords := ((self rowAt: rowIndex) at: #Message) splitOn: Character space.
	ngrams := OrderedCollection new.
	lastWords := OrderedCollection new.
	listOfWords do: [ :word |
		(lastWords size < n)
			ifFalse: [ 
				ngrams add: (' ' join: lastWords).
				lastWords removeFirst.
		 		].
				lastWords addLast: word.
		].
	ngrams add: (' ' join: lastWords).
	^ ngrams
]

{ #category : #processing }
ChatDataFrame >> wordNgram: n atName: rowName [
	"Given n, this message generates word n-gram at given rowName"

	^ (self wordNgram: n atIndex: (rowName+1))
]
