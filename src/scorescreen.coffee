###

Materia
It's a thing

Widget: Privilege Walk

###

PrivilegeWalk = angular.module 'PrivilegeWalkScorescreen', ['ngMaterial']

PrivilegeWalk.controller 'PrivilegeWalkScoreCtrl', ($scope, $mdToast) ->
	$scope.qset = null
	$scope.instance = null

	$scope.start = (instance, qset, scoreTable, version = '1') ->
		console.log qset
		console.log scoreTable
		$scope.instance = instance
		$scope.qset = qset
		$scope.scoreTable = scoreTable
		calculateScore()
		generateResponses()
		$scope.$apply()
		Materia.ScoreCore.setHeight $("#card-container").height()

	calculateScore = ->
		score = 0
		$scope.selectedAnswers = []
		for i in [0..$scope.scoreTable.length-1]
			s = ~~$scope.scoreTable[i].data[1]
			$scope.selectedAnswers.push s
			score += $scope.qset.items[i].answers[s].value
		console.log "total score", score
		$scope.score = score
		$scope.$apply()

	generateResponses = ->
		$scope.responses = []
		for score, i in $scope.scoreTable
			$scope.responses[i] = ~~score.data[1]

	Materia.ScoreCore.hideScoresOverview();
	Materia.ScoreCore.hideResultsTable();
	Materia.ScoreCore.start($scope)
