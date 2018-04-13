###

Materia
It's a thing

Widget: Privilege Walk

###

PrivilegeWalk = angular.module 'PrivilegeWalkEngine', ['ngMaterial']

PrivilegeWalk.controller 'PrivilegeWalkEngineCtrl', ($scope, $mdToast) ->
	$scope.qset = null
	$scope.instance = null
	$scope.responses = []
	$scope.privilege = 0

	$scope.showToast = (message) ->
		$mdToast.show(
			$mdToast.simple()
				.textContent(message)
				.position('bottom right')
				.hideDelay(3000)
		)

	$scope.start = (instance, qset, version) ->
		$scope.instance = instance
		console.log qset
		$scope.qset = qset
		$scope.privilege = 0
		$scope.completed = false
		$scope.$apply()

	createStorageTable = (tableName, columns) ->
		args = columns
		args.splice(0, 0, tableName)
		Materia.Storage.Manager.addTable.apply(this, args)

	insertStorageRow = (tableName, values) ->
		args = values
		args.splice(0, 0, tableName)
		Materia.Storage.Manager.insert.apply(this, args)

	$scope.submit = ->
		console.log $scope.qset
		console.log $scope.responses
		numResponses = $scope.responses.length
		complete = true

		if numResponses < $scope.qset.items.length
			complete = false
		for response, i in $scope.responses[0..numResponses-1]
			if not response
				complete = false
				break

		if complete
			try
				# $scope.privilege = $scope.responses.reduce(((total, current, i) ->
				#	total + $scope.qset.items[i].answers[~~current].value), 0)
				$scope.responses.map( (response, i) ->
					Materia.Score.submitQuestionForScoring $scope.qset.items[i].id, response
				)
				# $scope.completed = true
				# createStorageTable("PrivilegeTable", ["Privilege"])
				# insertStorageRow("PrivilegeTable", [$scope.privilege])
				# Materia.Score.submitFinalScoreFromClient(0, '', $scope.privilege)
				Materia.Engine.end(true)
			catch e
				alert 'Unable to save storage data'
		else
			$scope.showToast "Must complete all questions."
		return

	Materia.Engine.start($scope)
