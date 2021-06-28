!classDefinition: #WordsClientWindow category: 'WordsClientDemo'!
Panel subclass: #WordsClientWindow
	instanceVariableNames: 'sentenceTextBoxMorph wordsListMorph'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WordsClientDemo'!

!WordsClientWindow methodsFor: 'initialization' stamp: 'NR 6/22/2021 08:25:04'!
defaultExtent

	^ 1035@485
	! !

!WordsClientWindow methodsFor: 'initialization' stamp: 'NR 6/23/2021 06:54:42'!
initializeWith: aTitle

	self titleMorph showButtonsNamed: #( close collapse ).
	self setLabel: aTitle.
	self model: (WordsClientWindowModel new).
	self morphExtent: (self defaultExtent).
	self buildMorphicWindow.
	self openInWorld.
	self yourself.
			
	self model when: #newWordsArrived send: #refreshListOfWords to: self.! !


!WordsClientWindow methodsFor: 'access' stamp: 'NR 6/23/2021 06:58:02'!
refreshListOfWords
	
	wordsListMorph updateList.
	wordsListMorph setSelectionIndex: 0.
	! !


!WordsClientWindow methodsFor: 'GUI building' stamp: 'NR 6/28/2021 19:01:09'!
build1stColumn2ndRow
	| firstColumnLayoutMorphOfSecondRow |
	
	wordsListMorph := PluggableListMorph model: self model listGetter: #words indexGetter: #wordsListIndex indexSetter: #wordsListIndex:.
	wordsListMorph  borderColor: Color skyBlue; borderWidth: 1; morphWidth:300.
		
	firstColumnLayoutMorphOfSecondRow := LayoutMorph newColumn.
	firstColumnLayoutMorphOfSecondRow separation: 5; 
	axisEdgeWeight: 0.5;
	addMorph: (LabelMorph contents:'Results');
	addMorph: wordsListMorph.
	
	"Dos opciones para jugar con los layouts... ¿Qué diferencia hay?"
	firstColumnLayoutMorphOfSecondRow layoutSpec fixedWidth: 390.
	"wordsListMorph layoutSpec proportionalWidth: 100.
	wordsListMorph layoutSpec proportionalHeight: 100."
		
	^firstColumnLayoutMorphOfSecondRow.
	! !

!WordsClientWindow methodsFor: 'GUI building' stamp: 'NR 6/28/2021 18:34:12'!
build1stRow
	| sendRequestButtonMorph firstRowLayoutMorph |
	
	sendRequestButtonMorph := PluggableButtonMorph model: self model stateGetter: nil action: #sendWordsFromSentenceRequest  label: 'Send Request To Server'.
	
	sentenceTextBoxMorph := TextModelMorph textProvider: self model textGetter: #sentenceText textSetter: #sentenceText:. 
	sentenceTextBoxMorph textMorph setProperty: #keyStroke: toValue: [ :key | sentenceTextBoxMorph textMorph acceptContents ] .
	sentenceTextBoxMorph  borderWidth: 1; borderColor: Color skyBlue; morphWidth: 300. 
		
	firstRowLayoutMorph := LayoutMorph newRow.
	firstRowLayoutMorph separation: 25;
	axisEdgeWeight: 0.5;
	addMorph: (LabelMorph contents:'Enter sentence:');
	addMorph: sentenceTextBoxMorph;
 	addMorph: sendRequestButtonMorph.
	
	^firstRowLayoutMorph.! !

!WordsClientWindow methodsFor: 'GUI building' stamp: 'NR 6/23/2021 06:37:31'!
build2ndRow
	| showInTranscriptButtonMorph secondRowLayoutMorph |
	
	showInTranscriptButtonMorph := PluggableButtonMorph model: self model stateGetter: nil  action: #showWordInTranscript label: 'Show Selected Word In Transcript'.	
	
	secondRowLayoutMorph := LayoutMorph newRow.
	secondRowLayoutMorph separation: 25;
	axisEdgeWeight: 0.5;
	addMorph: self build1stColumn2ndRow;
	addMorph: showInTranscriptButtonMorph.
	
	^secondRowLayoutMorph.
	! !

!WordsClientWindow methodsFor: 'GUI building' stamp: 'NR 6/22/2021 05:23:32'!
buildMorphicWindow
		
	self layoutMorph beColumn;
	separation: 15;
	axisEdgeWeight: 0;
	addMorph: self build1stRow;
	addMorph: self build2ndRow.
	! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'WordsClientWindow class' category: 'WordsClientDemo'!
WordsClientWindow class
	instanceVariableNames: ''!

!WordsClientWindow class methodsFor: 'instance creation' stamp: 'NR 6/23/2021 06:32:18'!
open
	
	^self new initializeWith: 'Words-Service Client Window'.! !


!classDefinition: #WordsClientWindowModel category: 'WordsClientDemo'!
Object subclass: #WordsClientWindowModel
	instanceVariableNames: 'sentence words selectedIndex restInterface'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WordsClientDemo'!

!WordsClientWindowModel methodsFor: 'PluggableListSelectors' stamp: 'NR 6/23/2021 06:56:13'!
words
	
	^words.
! !

!WordsClientWindowModel methodsFor: 'PluggableListSelectors' stamp: 'NR 6/23/2021 06:56:37'!
wordsListIndex
	
	^selectedIndex.! !

!WordsClientWindowModel methodsFor: 'PluggableListSelectors' stamp: 'NR 6/23/2021 06:56:49'!
wordsListIndex: anIndex
	
	selectedIndex := anIndex.! !


!WordsClientWindowModel methodsFor: 'initialization' stamp: 'NR 6/23/2021 07:56:07'!
initialize

	words := OrderedCollection new.
	sentence := ''.
	selectedIndex := 0.
	restInterface := WordsRestInterface new.! !


!WordsClientWindowModel methodsFor: 'TextModelMorphSelectors' stamp: 'NR 6/25/2019 21:43:32'!
sentenceText
	
	^sentence.! !

!WordsClientWindowModel methodsFor: 'TextModelMorphSelectors' stamp: 'NR 6/23/2021 07:08:56'!
sentenceText: aSentence

	sentence := aSentence.
	^true.! !


!WordsClientWindowModel methodsFor: 'PluggableButtonSelectors' stamp: 'NR 6/23/2021 07:56:07'!
sendWordsFromSentenceRequest
		
	words := restInterface sendRequest: sentence.
	
	self triggerEvent: #newWordsArrived with: self.
	! !

!WordsClientWindowModel methodsFor: 'PluggableButtonSelectors' stamp: 'NR 6/23/2021 06:51:02'!
showWordInTranscript
	
	(selectedIndex = 0) ifFalse: 
		[TranscriptWindow openTranscript.
		Transcript clear.
		Transcript show: 'The word selected is: '.
		Transcript show: (words at: selectedIndex).
		Transcript show: ' '.].
! !


!classDefinition: #WordsRestInterface category: 'WordsClientDemo'!
Object subclass: #WordsRestInterface
	instanceVariableNames: 'port'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'WordsClientDemo'!

!WordsRestInterface methodsFor: 'sending requests' stamp: 'NR 6/25/2019 22:25:36'!
correctlyEncodeSpacesForUrlRequestParameter: aParameter
	
	^ aParameter copyReplaceAll: ' ' with: '%20'. ! !

!WordsRestInterface methodsFor: 'sending requests' stamp: 'NR 6/23/2021 07:54:44'!
sendRequest: sentence

	| fieldDict resp urlEncodedSentence |

	urlEncodedSentence := self correctlyEncodeSpacesForUrlRequestParameter: sentence.	
	fieldDict := Dictionary newFromPairs: {'sentence'. urlEncodedSentence.}.		
	
	resp:= WebClient htmlSubmit: (self url,'/words') fields: fieldDict.
	
	resp isSuccess 
		ifTrue:[^(WebUtils jsonDecode: ((resp content) readStream)) asOrderedCollection .] 
		ifFalse:[^self error: resp content].! !


!WordsRestInterface methodsFor: 'initialization' stamp: 'NR 6/25/2019 22:15:16'!
port
	
	^port ifNil: [port:=8080].! !

!WordsRestInterface methodsFor: 'initialization' stamp: 'NR 6/24/2019 06:52:37'!
url
	
	^'http://localhost:', self port asString! !
