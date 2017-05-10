###

Materia
It's a thing

Widget: Privilege Walk

###

# Create an angular module to house our controller
PrivilegeWalk = angular.module 'PrivilegeWalkCreator', ['ngMaterial', 'ngSanitize']

PrivilegeWalk.config ($mdThemingProvider) ->
		$mdThemingProvider.theme('toolbar-dark', 'default')
			.primaryPalette('indigo')
			.dark()

PrivilegeWalk.controller 'PrivilegeWalkController', ($scope, $mdToast, $sanitize, $compile, Resource) ->

	$scope.title = "My Privilege Walk Widget"

	$scope.rangeResponseOptions = {
		0: {text:'Yes', value: 0}
		1: {text:'Often', value: 1}
		2: {text:'Rarely', value: 2}
		3: {text:'Never', value: 3}
	}

	$scope.data = []

	$scope.fillColor = 'rgba(255,64,129, 0.5)'

	$scope.cards = []

	questionCount = 0

	$scope.initNewWidget = (widget) ->
		$scope.$apply ->
			setup()

	$scope.initExistingWidget = (title,widget,qset) ->

		$scope.$apply ->
			$scope.title = title
			for item in qset.items
				$scope.cards.push
					question: item.questions[0].text
					isRange: item.options.isRange

				questionCount++

			populateData()

	setup = ->
		$scope.addQuestion()

	populateData = ->
		for card in $scope.cards
			$scope.data.push 0

		$scope.invalid = false

	$scope.addQuestion = ->
		questionCount++
		$scope.cards.push {
			'question': 'Question '+questionCount
			'isRange': 'false'
		}
		$scope.data.push 0

	$scope.toggleRange = (index) ->
		if $scope.cards[index].isRange == 'false'
			$scope.cards[index].isRange = 'true'
		else
			$scope.cards[index].isRange = 'false'

	$scope.deleteQuestion = (index) ->
		if $scope.cards.length <= 1
			$scope.showToast("Must have at least one question.")
			return
		$scope.cards.splice index, 1
		$scope.data.splice index, 1

	$scope.showToast = (message) ->
		$mdToast.show(
			$mdToast.simple()
				.textContent(message)
				.position('bottom right')
				.hideDelay(3000)
		)

	$scope.onSaveClicked = ->
		_isValid = $scope.validation()

		if _isValid
			qset = Resource.buildQset $sanitize($scope.title), $scope.cards
			if qset then Materia.CreatorCore.save $sanitize($scope.title), qset
		else
			Materia.CreatorCore.cancelSave "Please make sure every question is complete"
			return false

	$scope.validation = ->
		$scope.invalid = false

		for card in $scope.cards
			if !card.question
				$scope.invalid = true
				return false
		return true

	$scope.onQuestionImportComplete = (items) ->
		for i in [0...items.length]
			$scope.cards.push
				question: items[i].questions[0].text
				isRange: items[i].options.isRange

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

	processQsetItem: (item, index) ->
		question = $sanitize item.question
		isRange = $sanitize item.isRange

		materiaType: "question"
		id: null
		type: 'MC'
		options: {
			isRange: isRange
		}
		questions: [{ text: question }]
		answers: [
			text: '[No Answer]'
			value: 0
		]