"
I hold messages used to analyze chat data
"
Class {
	#name : #ChatAnalyzer,
	#superclass : #Object,
	#category : #WhatsappAnalyzer
}

{ #category : #analyzing }
ChatAnalyzer class >> getAuthorMessageCounts: df [
	"Generates message counts for each author"

	| messageCounts authors authorDf |
	messageCounts := Dictionary new.
	authors := (df column: #Author) asSet.
	authors do: [ :author |
		authorDf := df select: [ :row | (row at: #Author) = author].
		messageCounts add: author->(self getMessageCounts: (authorDf)).
		 ].
	^ messageCounts 
]

{ #category : #accessing }
ChatAnalyzer class >> getAuthorsFrom: df [
	"Returns an OrderedCollection of authors present in the dataframe"

	^ (df column: #Author) asSet.
]

{ #category : #analyzing }
ChatAnalyzer class >> getBasicTextAnalysis: df [
	"Returns a dictionary with following metrics:
		Most active user w/count
		Most active media user w/count
		Messages/user
	"

	| messageCounts textAnalysis|
	textAnalysis := OrderedDictionary new.
	messageCounts := self getMessageCounts: df.
	messageCounts add: 'Authors'->(self getAuthorMessageCounts: df).
	
	"Calculate most active user"
	textAnalysis add: 'Most active user'->''.
	textAnalysis add: 'Most active user messages'->0.
	textAnalysis add: 'Most active user percentage'->0.
	
	"Calculate most media messages by an user"
	textAnalysis add: 'Media user'->''.
	textAnalysis add: 'Media user count'->0.
	
	"Calculate most deleted messages by an user"
	textAnalysis add: 'Deleting user'->''.
	textAnalysis add: 'Deleting user count'->0.
	
	"Average messages per user"	
	textAnalysis add: 'Messages/user'->0.
	
	(messageCounts at: #Authors) keysAndValuesDo: [ :key :value |
		((textAnalysis at: 'Most active user messages') < (value at: 'Text')) ifTrue: [ 
				textAnalysis at: 'Most active user messages' put: (value at: 'Text').
				textAnalysis at: 'Most active user' put: key.
			 ].
		((textAnalysis at: 'Media user count') < (value at: 'Media')) ifTrue: [ 
				textAnalysis at: 'Media user count' put: (value at: 'Media').
				textAnalysis at: 'Media user' put: key.
			 ].
		((textAnalysis at: 'Deleting user count') < (value at: 'Deleted')) ifTrue: [ 
				textAnalysis at: 'Deleting user count' put: (value at: 'Deleted').
				textAnalysis at: 'Deleting user' put: key.
			 ].
		textAnalysis at: 'Messages/user' put: ((textAnalysis at: 'Messages/user') + (value at: 'Text')).
		 ].
	
	textAnalysis at: 'Messages/user' put: (textAnalysis at: 'Messages/user') asFloat / ((messageCounts at: #Authors) size).
	textAnalysis at: 'Most active user percentage' put: (textAnalysis at: 'Most active user messages') * 100.0 / (messageCounts at: #Text).
	messageCounts add: 'Basic Text Analysis'->textAnalysis.
	
	^ messageCounts 
]

{ #category : #analyzing }
ChatAnalyzer class >> getEmojiCountFrom: emojiDs [
	"Returns an DataSeries having an emoji as key and counts as values"

	| emojiCount ignoreEmoji |
	ignoreEmoji := Set withAll: #(127995 9794 8205 2640).
	emojiCount := DataSeries new name: #EmojiCount.
	emojiDs do: [ :message |
		message do: [ :emoji |
			(ignoreEmoji includes: (emoji asUnicode)) ifFalse: [ 
				emojiCount at: emoji
					transform: [ :count | count + 1 ]
					ifAbsent: [ emojiCount add: emoji->1 ].
				 ]
			]
		].
	^ emojiCount sortDescending.
]

{ #category : #analyzing }
ChatAnalyzer class >> getMemberEmojiCountFrom: df [
	"Returns a dictionory of DataSeries having emoji count of member"

	| emojiPerPerson authors authorDf authorEmojiCount |
	emojiPerPerson := Dictionary new.
	authors := (df column: #Author) uniqueValues.
	authors do: [ :author |
		authorDf := df select: [ :row | (row at: #Author) = author].
		authorEmojiCount := self getEmojiCountFrom: (ChatCleaner getEmojisFrom: authorDf).
		(authorEmojiCount isEmpty) ifFalse: [
			emojiPerPerson add: author->authorEmojiCount.
			]
		 ].
	^ emojiPerPerson
]

{ #category : #analyzing }
ChatAnalyzer class >> getMessageCounts: df [
	"Counts total messages, text messages, media and deleted messages"

	| messageCounts tempDf |
	messageCounts := Dictionary new.
	messageCounts add: 'Total'->(df size).
	[
		tempDf := df select: [ :row | (row at: #Message) = '<Media omitted>' ].
		messageCounts add: 'Media'->(tempDf size).
	]	ifError: [ 
		messageCounts add: 'Media'->0.
		 ].
	[
		tempDf := df select: [ :row | (row at: #Message) = 'This message was deleted' ].
		messageCounts add: 'Deleted'->(tempDf size).
	]	ifError: [ 
		messageCounts add: 'Deleted'->0.
		 ].
	messageCounts add: 'Text'->((df size) - (messageCounts at: 'Media') - (messageCounts at: 'Deleted')).
	
	"Calculate words and letters"
	messageCounts add: 'Words'->0.
	messageCounts add: 'Letters'->0.
	df do: [ :row |
		messageCounts at: 'Letters' put: ((messageCounts at: 'Letters') + (row at: #Message) size).
		messageCounts at: 'Words' put: ((messageCounts at: 'Words') + (((row at: #Message) splitOn: ('\s+' asRegex)) size)).
		 ].
	
	^ messageCounts
]

{ #category : #analyzing }
ChatAnalyzer class >> getNgramCount: ngrams columnName: columnName [
	"Returns a DataSeries with Ngramcount from DataSeries ngrams"

	| nGramCount |
	nGramCount := DataSeries new name: columnName.

	ngrams do: [ :ngramCollection |
		ngramCollection do: [ :ngram |
			nGramCount at: ngram
						  transform: [ :count | count + 1 ]
						  ifAbsent: [ nGramCount add: ngram->1 ].
			 ].
		 ].

	^ nGramCount sortDescending.
]
