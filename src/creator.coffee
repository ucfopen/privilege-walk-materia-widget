###

Materia
It's a thing

Widget: Privilege Walk

###

# Create an angular module to house our controller
PrivilegeWalk = angular.module 'PrivilegeWalkCreator', ['ngMaterial', 'ngMessages', 'ngSanitize', 'angular-sortable-view']

PrivilegeWalk.config ($mdThemingProvider) ->
		$mdThemingProvider.theme('toolbar-dark', 'default')
			.primaryPalette('indigo')
			.dark()

PrivilegeWalk.controller 'PrivilegeWalkController', ($scope, $mdToast, $sanitize, $compile, Resource) ->

	$scope.rangeOptions = [
		{text:'Very Often', value: 5}
		{text:'Often', value: 4}
		{text:'Sometimes', value: 3}
		{text:'Rarely', value: 2}
		{text:'Never', value: 1}
	]

	$scope.yesNo = [
		{text:'Yes', value: 5, id: ''}
		{text:'No', value: 1, id: ''}
	]

	$scope.questionTypes =
		'0': "Preset: Yes / No"
		'1': "Preset: Scale"
		'2': "Custom"

	$scope.displayStyles = [
		{text:'Horizontal Scale', value: '0'}
		{text:'Dropdown Menu', value: '1'}
	]

	$scope.reversedTooltips =
		'0': "When reversed, 'Yes' will have a value of 1 and 'No' will have a value of 5"
		'1': "When reversed, 'Very Often' will have a value of 1 and 'Never' will have a value of 5"

	$scope.ready = false
	$scope.cards = []
	$scope.dragging = false
	$scope.dragOpts =
		containment: ".custom-choice"

	questionCount = 0

	$scope.initNewWidget = (widget) ->
		$scope.$apply ->
			$scope.title = "My Privilege Walk Widget"
			setup()

	$scope.initExistingWidget = (title,widget,qset) ->
		$scope.$apply ->
			$scope.title = title
			for item in qset.items
				$scope.cards.push
					question: item.questions[0].text
					questionType: item.options.questionType
					answers: item.answers
					style: item.options.style
					reversed: item.options.reversed == 'true'
				questionCount++
			$scope.ready = true
			console.log "should be ready"
			return
		console.log "actually ready"

	setup = ->
		$scope.addQuestion()
		$scope.ready = true

	$scope.addQuestion = ->
		questionCount++
		$scope.cards.push
			question: 'Question '+questionCount
			answers: $scope.rangeOptions
			questionType: '1'
			style: '0'
			reversed: false

	$scope.deleteQuestion = (index) ->
		$scope.cards.splice index, 1
		questionCount--
		if $scope.cards.length == 0
			$scope.showToast("Must have at least one question.")
			$scope.addQuestion()
			return

	$scope.addOption = (cardIndex) ->
		style = $scope.cards[cardIndex].style
		len = $scope.cards[cardIndex].answers.length
		if (style == '0' && len >= 5)
			$scope.showToast "Can only have 5 options per scale. Set Display Style to Dropdown to add more.", 10000
			return
		$scope.cards[cardIndex].answers.push {
			text:'', value: 1, id: ''
		}

	$scope.removeOption = (cardIndex, optionIndex) ->
		$scope.cards[cardIndex].answers.splice optionIndex, 1
		if $scope.cards[cardIndex].answers.length == 0
			$scope.showToast("Must have at least one option.")
			$scope.addOption(cardIndex)

	$scope.updateAnswerType = (cardIndex) ->
		$scope.cards[cardIndex].style = '0'
		switch ($scope.cards[cardIndex].questionType)
			when '0'
				$scope.cards[cardIndex].answers = $scope.yesNo
			when '1'
				$scope.cards[cardIndex].answers = $scope.rangeOptions
			when '2'
				custom = JSON.parse(JSON.stringify($scope.rangeOptions))
				$scope.cards[cardIndex].answers = custom
		$scope.cards[cardIndex].reversed = false

	$scope.reverseValues = (cardIndex) ->
		answers = $scope.cards[cardIndex].answers
		reversedArray = []
		for i in [0..answers.length-1]
			reversedArray.push(
				text: answers[i].text,
				value: answers[answers.length-i-1].value
				id: ''
			)
		$scope.cards[cardIndex].answers = reversedArray

	$scope.swapCards = (index1, index2) ->
		[$scope.cards[index1], $scope.cards[index2]] = [$scope.cards[index2], $scope.cards[index1]]

	$scope.showToast = (message, delay=3000) ->
		$mdToast.show(
			$mdToast.simple()
				.textContent(message)
				.position('top')
				.hideDelay(delay)
		)

	$scope.onSaveClicked = ->
		_isValid = validation()

		if _isValid
			qset = Resource.buildQset $scope.title, $scope.cards
			if qset then Materia.CreatorCore.save $scope.title, qset
		else
			Materia.CreatorCore.cancelSave "Please make sure every question is complete."
			return false

	validation = ->
		for card in $scope.cards
			if !card.question || !card.answers
				return false
			for answer in card.answers
				if !answer.text || ~~answer.value != answer.value
					return false
		return true

	$scope.onQuestionImportComplete = (items) ->
		for item in qset.items
			$scope.cards.push
				question: item.questions[0].text
				questionType: item.options.questionType
				answers: item.answers
				style: item.options.style
				reversed: item.options.reversed == '1'
			questionCount++

	$scope.onSaveComplete = (title, widget, qset, version) -> true

	Materia.CreatorCore.start $scope

PrivilegeWalk.factory 'Resource', ($sanitize) ->
	buildQset: (title, questions) ->
		qsetItems = []
		qset = {}

		if title is ''
			Materia.CreatorCore.cancelSave 'Please enter a title.'
			return false

		for question in questions
			item = @processQsetItem question
			if item then qsetItems.push item

		qset.items = qsetItems
		return qset

	processQsetItem: (item) ->
		question = $sanitize item.question
		questionType = $sanitize item.questionType
		style = $sanitize item.style
		reversed = $sanitize item.reversed

		# clean out previously generated IDs
		for answer in item.answers
			answer.id = ''

		materiaType: "question"
		id: null
		type: 'QA'
		options: {
			questionType: questionType
			style: style
			reversed: reversed
		}
		questions: [{ text: question }]
		answers: item.answers
