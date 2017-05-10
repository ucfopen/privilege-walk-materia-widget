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
		console.log $scope.instance
		$scope.qset = qset
		$scope.$apply()

	$scope.submit = ->
		console.log $scope.instance
		if $scope.responses.length < $scope.qset.items.length
			$scope.showToast "Must complete all questions."

	Materia.Engine.start($scope)