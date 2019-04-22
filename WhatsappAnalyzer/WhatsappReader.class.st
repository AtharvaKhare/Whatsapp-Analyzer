"
I am a class responsible for parsing Whatsapp chat and loading it into a DataFrame.
"
Class {
	#name : #WhatsappReader,
	#superclass : #DataFrameReader,
	#category : #WhatsappAnalyzer
}

{ #category : #utilities }
WhatsappReader >> createDataFrame [ 
	"Creates an empty dataframe with four columns parsed from Whatsapp chat"

	^ DataFrame withColumnNames: #('Date' 'Time' 'Author' 'Message')
]

{ #category : #utilities }
WhatsappReader >> insert: line into: df [
  "Parses given line and inserts it as a row in dataframe. An utility method."

  | commaIndex hyphenIndex colonIndex oldRow |
  (line isNotEmpty) ifTrue: [
    ((line copyUpTo: $,) matchesRegex: '\d(\d)?/\d(\d)?/\d\d') 
      ifTrue: [ 
        commaIndex := line indexOf: $,.
        hyphenIndex := line indexOf: $-.
        colonIndex := line indexOf: $: startingAt: hyphenIndex.
        (colonIndex ~= 0 ) ifTrue: [
          df addRow: { 
            line copyUpTo: $, .
            line copyFrom: commaIndex+2 to: hyphenIndex-2 .
            line copyFrom: hyphenIndex+2 to: colonIndex-1 .
            (line copyFrom: colonIndex+1 to: line size) allButFirst
          } named: df numberOfRows + 1.
        ]
      ]
      ifFalse: [
        oldRow := df row: df numberOfRows.
        oldRow at: 'Message' put: ((oldRow at: 'Message') , '\n' , line).
        df removeRow: df numberOfRows.
        df addRow: oldRow.
      ]
  ]
]

{ #category : #reading }
WhatsappReader >> readFrom: chatFileReference [
	"Read Whatsapp chat and add it into the dataframe. Takes FileRefernce as it's argument"
	
	| df line |
	df := self createDataFrame.
	chatFileReference readStreamDo: [ :inputStream |
		[ inputStream atEnd ] whileFalse: [ 
			line := inputStream nextLine.
			self insert: line into: df.
			]
		 ].
	^ df
]
