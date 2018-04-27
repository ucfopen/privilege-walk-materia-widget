###

Materia
It's a thing

Widget: Privilege Walk

###

PrivilegeWalk = angular.module 'PrivilegeWalkScorescreen', ['ngMaterial', 'ngMessages']

PrivilegeWalk.controller 'PrivilegeWalkScoreCtrl', ($scope, $mdToast, $mdDialog) ->
	$scope.qset = null
	$scope.instance = null

	graphData = null
	maxScore = null
	$scope.distributionReady = false
	$scope.invalidGraph = false

	$scope.start = (instance, qset, scoreTable, isPreview, version = '1') ->
		console.log qset
		console.log scoreTable
		console.log "isPreview: ", isPreview
		$scope.instance = instance
		$scope.qset = qset
		$scope.scoreTable = scoreTable
		$scope.isPreview = isPreview
		generateResponses()
		calculateScore()
		calculateMaxScore()
		Materia.ScoreCore.setHeight $("#card-container").height()
		$scope.$apply()

	$scope.update = (qset, scoreTable) ->
		$scope.qset = qset
		$scope.scoreTable = scoreTable
		generateResponses()
		calculateScore()
		calculateMaxScore()
		ensureScoreInGraph() if graphData
		Materia.ScoreCore.setHeight $("#card-container").height()
		$scope.$apply()

	$scope.handleScoreDistribution = (data) ->
		console.log "got distribution data: ", data[..]
		if data
			graphData = data
			ensureScoreInGraph()
			drawGraph()
		else
			$scope.invalidGraph = true
		$scope.distributionReady = true
		$scope.$apply()

	$scope.showCompare = (ev) ->
		if !graphData
			Materia.ScoreCore.requestScoreDistribution()
		$mdDialog.show(
			contentElement: '#distribution-dialog-container'
			parent: angular.element(document.body)
			targetEvent: ev
			clickOutsideToClose: true
			openFrom: '#compare-button'
			closeTo: '#compare-button'
		)

	$scope.cancel = () ->
		$mdDialog.hide()

	calculateScore = ->
		total = 0
		for s in $scope.scoreTable
			s.score = ~~s.score
			total += s.score
		$scope.score = total
		$scope.$apply()

	drawGraph = () ->
		$LAB.script("https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.7.2/Chart.min.js")
		.wait ->
			# set the bar colors
			backgroundColors = new Array(graphData.length)
			backgroundColors.fill('rgba(50, 50, 50, 0.8)')
			scoreIndex = graphData.indexOf($scope.score)
			highlightColor = 'rgb(255, 64, 129)'
			backgroundColors[scoreIndex] = highlightColor

			# required for bar chart
			labels = new Array(graphData.length)

			# set the legend box color
			Chart.plugins.register
				beforeDraw: (c) ->
					legend = c.legend.legendItems[0];
					legend.fillStyle = highlightColor

			myChart = new Chart 'graph',
				type: 'horizontalBar'
				data:
					labels: labels
					datasets: [
							label: 'Your Privilege Score'
							data: graphData
							backgroundColor: backgroundColors
					]
				options:
					responsive: true
					maintainAspectRatio: false
					tooltips: enabled: false
					barThickness: 5
					scales:
						yAxes: [
							display: false
						]
						xAxes: [
							ticks:
								min: 0
								max: maxScore
							scaleLabel:
								display: true
								labelString: 'Privilege Score'
							categoryPercentage: 1
						]

	generateResponses = ->
		$scope.responses = []
		for score, i in $scope.scoreTable
			$scope.responses[i] = score.data[1]

	ensureScoreInGraph = ->
		for score, i in graphData
			return if score == $scope.score
			if score < $scope.score
				return graphData[i] = $scope.score
		graphData.pop()
		graphData.push $scope.score

	calculateMaxScore = ->
		max = 0
		for item in $scope.qset.items
			bestAnswer = 0
			for answer in item.answers
				bestAnswer = Math.max(bestAnswer, answer.value)
			max += bestAnswer
		maxScore = max


	Materia.ScoreCore.hideScoresOverview()
	Materia.ScoreCore.hideResultsTable()
	Materia.ScoreCore.start($scope)
