###

Materia
It's a thing

Widget: Privilege Walk

###

PrivilegeWalk = angular.module 'PrivilegeWalkEngine', ['ngMaterial']

PrivilegeWalk.controller 'PrivilegeWalkEngineCtrl', ['$scope', ($scope) ->
	$scope.inProgress = true

	$scope.qset = null
	$scope.instance = null
	$scope.binaryResponses = []
	$scope.sliderResponses = []
	$scope.data = [[]]

	$scope.start = (instance, qset, version) ->
		$scope.instance = instance
		$scope.qset = qset
		$scope.$apply()

	$scope.submit = ->
		$scope.data[0] = $scope.binaryResponses
		$scope.data[1] = $scope.sliderResponses

	Materia.Engine.start($scope)
]