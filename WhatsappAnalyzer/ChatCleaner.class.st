"
I provide messages used to clean chat.

Currently I provide following messages: 
- 
"
Class {
	#name : #ChatCleaner,
	#superclass : #Object,
	#category : #WhatsappAnalyzer
}

{ #category : #cleaning }
ChatCleaner class >> getEmojisFrom: df [
   "Returns the #Message column while removing non-emoji characters. The regex might not work perfectly"

   ^ ((df column: #Message) collect: [ :message |
         message copyWithRegex: '[\w\d\s\\:.,''"-/?!()[]<>@’^“”=+_]' matchesReplacedWith: ''
         ]
      )
]

{ #category : #cleaning }
ChatCleaner class >> getWordsFrom: df [
   "Returns a DataSeries with removes punctuation and digits from #Message"

   ^ ((df column: #Message) collect: [ :message |
         message copyWithRegex: '[^\w\s]' matchesReplacedWith: ''
         ]
      )
]

{ #category : #cleaning }
ChatCleaner class >> messagesAsLowercase: df [
   "Returns a DataSeries of the message column with lowercase strings"

   ^ ((df column: #Message) collect: [ :message | message asLowercase ])
]

{ #category : #cleaning }
ChatCleaner class >> setTypesFor: df [
	"Converts df's columns to appropriate types"

	df do: [ :row |
		row at: #Date transform: [ :date | date asDate ].
		row at: #Time transform: [ :time | time asTime ].
		row at: #Message transform: [ :message | message asWideString ].
		 ]
]
