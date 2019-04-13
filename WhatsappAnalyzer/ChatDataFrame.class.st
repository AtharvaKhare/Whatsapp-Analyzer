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

{ #category : #initialization }
ChatDataFrame >> initialize [
	"Initializes the object"

	super initialize.
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
					self addRow: { 
						line copyUpTo: $, .
						line copyFrom: commaIndex+2 to: hyphenIndex-2 .
						line copyFrom: hyphenIndex+2 to: colonIndex-1 .
						(line copyFrom: colonIndex+1 to: line size) allButFirst
			 			} named: self numberOfRows.
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
