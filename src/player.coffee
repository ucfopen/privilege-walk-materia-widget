###

Materia
It's a thing

Widget: Privilege Walk

###

PrivilegeWalk = angular.module 'PrivilegeWalkEngine', ['ngMaterial']

PrivilegeWalk.controller 'PrivilegeWalkEngineCtrl', ($scope, $mdToast) ->
	$scope.inProgress = true

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

	$scope.rangeResponseOptions = {
		0: {text:'Yes', value: 0}
		1: {text:'Often', value: 1}
		2: {text:'Rarely', value: 2}
		3: {text:'Never', value: 3}
	}

	$scope.start = (instance, qset, version) ->
		$scope.instance = instance
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
		if $scope.responses.length < $scope.qset.items.length
			$scope.showToast "Must complete all questions."
		else
			try
				$scope.privilege = $scope.responses.reduce(((total, current) ->
					total + current), 0)
				$scope.responses.map( (response, i) ->
					Materia.Score.submitQuestionForScoring $scope.qset.items[i].id, response
				)
				$scope.completed = true
				createStorageTable("PrivilegeTable", ["Privilege"])
				insertStorageRow("PrivilegeTable", [$scope.privilege])
				Materia.Score.submitFinalScoreFromClient(0, '', $scope.privilege)
				Materia.Engine.end(false)
			catch e
				alert 'Unable to save storage data'
		return

	Materia.Engine.start($scope)
