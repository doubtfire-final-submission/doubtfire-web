angular.module('doubtfire.units.states.analytics.directives.task-ready-to-be-marked-stats',[])


.directive('taskReadyToBeMarkedStats', ->
  replace: true
  restrict: 'E'
  templateUrl: 'units/states/analytics/directives/task-ready-to-be-marked-stats/task-ready-to-be-marked-stats.tpl.html'
  scope:
    unit: '='
    unitRole: '='

  controller: ($scope, Unit) ->
    
    unless $scope.unit.analytics?.taskReadyToMarkStats?
      Unit.taskReadyToMarkStats.query {id: $scope.unit.id}, (response,err) ->
        $scope.unit.analytics.taskReadyToMarkStats = response

        # Fetching Number of Students in each tutorials
        # Output Array -> (tutorial_id,Count(tutorial_id) as total_students)
        $scope.tempArray = _.chain($scope.unit.students)
          .groupBy('tutorial_id')
          .map (items,tutorial_id) ->
            return tutorial_id: tutorial_id, total_students: items.length
          .value()
          
        _.merge(_.keyBy($scope.unit.analytics.taskReadyToMarkStats,'tutorial_id'),_.keyBy($scope.tempArray,'tutorial_id'))
    else
      $scope.data = $scope.unit.analytics.taskReadyToMarkStats.unit
)