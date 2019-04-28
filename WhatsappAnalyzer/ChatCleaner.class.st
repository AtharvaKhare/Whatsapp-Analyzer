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

{ #category : #constants }
ChatCleaner class >> getStopwords [
	"Returns array of stopwords"

	^ Set withAll: #(
	'its' 'it''s'
	'while' 'him' 'take' 'former' 'hundred' 'whence' 'others' 'nobody' 'same' 'throughout' 'seemed' 'an' 'first'
	'made' 'it' 'please' 'otherwise' 'side' 'de' 'against' 'amount' 'her' 'however' 'must' 'somewhere' 'often'
	'very' 'will' 'full' 'yours' 'back' 'something' 'from' 'call' 'than' 'are' 'across'	 'which' 'name' 'of' 'two'
	'upon' 'you' 'enough' 'once' 'amoungst' 'bill' 'latterly' 'rather' 'together' 'below' 'alone' 'elsewhere' 'in'
	'last' 'mostly' 'any' 'forty' 'himself' 'as' 'nowhere' 'further' 'somehow' 'your' 'each' 'ever' 'them' 'many'
	'either' 'because' 'down' 'whatever' 'formerly' 'besides' 'around' 'its' 'anywhere' 'keep' 'one' 'someone'
	'thereupon' 'sincere' 'herein' 'sometimes' 'sixty' 'go' 'nine' 'everyone' 'ie' 'becoming' 'hereby' 'out' 'that'
	'the' 'thence' 'eleven' 'mill' 'anything' 'couldnt' 'us' 'ours' 'thereby' 'within' 'being' 'so' 'above' 'can'
	'my' 'before' 'may' 'yet' 'thereafter' 'nor' 'until' 'if' 'whenever' 'hers' 'none' 'this' 'during' 'yourselves'
	'ltd' 'became' 'everything' 'three' 'all' 'find' 'un' 'whereupon' 'never' 'hereafter' 'less' 'whoever'
	'therefore' 'wherein' 'anyhow' 'then' 'fifteen' 'five' 'much' 'been' 'hence' 'be' 'cry' 'both' 'noone' 'some'
	'ourselves' 'almost' 'neither' 'these' 'third' 'else' 'through' 'whereafter' 'too' 'get' 'whose' 'whereas'
	'would' 'though' 'their' 'several' 'system' 'again' 'or' 'at' 'do' 'detail' 'done' 'few' 'i' 'into' 'only'
	'along' 'already' 'about' 'could' 'interest' 'nothing' 'see' 'bottom' 'such' 'whither' 'ten' 'perhaps' 'those'
	'thru' 'everywhere' 'itself' 'might' 'she' 'me' 'for' 'therein' 'per' 'fire' 'by' 'here' 'with' 'how'
	'afterwards' 'hereupon' 'our' 'although' 'is' 'part' 'herself' 'thick' 'well' 'namely' 'beforehand' 'over' 'now'
	'were' 'thin' 'toward' 'con' 'fifty' 'up' 'sometime' 'we' 'even' 'seems' 'twelve' 'give' 'off' 'was' 'show'
	'without' 'am' 'whole' 're' 'themselves' 'whom' 'who' 'front' 'should' 'becomes' 'whether' 'meanwhile' 'cant'
	'become' 'among' 'amongst' 'have' 'why' 'still' 'after' 'between' 'eight' 'etc' 'indeed' 'mine' 'own' 'latter'
	'nevertheless' 'they' 'where' 'least' 'moreover' 'move' 'thus' 'serious' 'most' 'when' 'top' 'also' 'to'
	'cannot' 'another' 'but' 'describe' 'co' 'found' 'hasnt' 'seeming' 'no' 'whereby' 'other' 'empty' 'he' 'there'
	'beyond' 'via' 'onto' 'every' 'his' 'more' 'a' 'not' 'towards' 'what' 'due' 'behind' 'had' 'four' 'seem' 'six'
	'beside' 'since' 'under' 'and' 'anyone' 'put' 'wherever' 'next' 'has' 'except' 'twenty' 'yourself' 'always'
	'inc' 'eg' 'myself' 'on' 'anyway' 'fill'
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

{ #category : #removing }
ChatCleaner class >> removeStopwordsFrom: df [
	"Removes stop words and returns Message dataseries"

	| stopWords words |
	stopWords := self getStopwords.
	^ (df column: #Message) collect: [ :message |
		words := ((message trimBoth) splitOn: ('\s+' asRegex)).
		words := words reject: [ :word |
			 (stopWords includes: (word asLowercase))
			 ].
		' ' join: words
		 ]
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
