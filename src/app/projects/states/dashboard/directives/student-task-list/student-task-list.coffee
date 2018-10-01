angular.module('doubtfire.projects.states.dashboard.directives.student-task-list', [])
#
# View a list of tasks
#
.directive('studentTaskList', ->
  restrict: 'E'
  templateUrl: 'projects/states/dashboard/directives/student-task-list/student-task-list.tpl.html'
  scope:
    project: '='
    # Function to invoke to refresh tasks
    refreshTasks: '=?'
    # Special taskData object (wraps the selectedTask)
    taskData: '='
  controller: ($scope, $timeout, $filter, gradeService) ->
    # Check taskSource exists
    unless $scope.taskData?
      throw Error "Invalid taskData provided. Must wrap the selectedTask and selectedTaskAbbr"
    # Set up initial filtered tasks
    $scope.filteredTasks = []
    # Set up filters
    $scope.filters = {
      taskName: null

      #Added by Manish
      hideCompleted: true
      topTask: true
      #
    }
    # Sets new filteredTasks variable
    applyFilters = ->
      filteredTasks = $filter('tasksWithName')($scope.project.activeTasks(), $scope.filters.taskName)
      filteredTasks = $filter('orderBy')(filteredTasks, 'definition.seq')
      #Added by Manish
      ###
      if($scope.filters.hideCompleted)
        filteredTasks = $filter('tasksWithStatusesNot')(filteredTasks, 'complete')
      
      if($scope.filters.hideCompleted)
        comTasks = $filter('tasksWithStatuses')(filteredTasks, 'complete')
        filteredTasks = $filter('filter')(filteredTasks,comTasks)
      ###
      if($scope.filters.hideCompleted)
        filteredTasks = filteredTasks.filter (task) -> task.status != 'complete'
      #
      $scope.filteredTasks = filteredTasks
    # Apply filters first-time
    applyFilters()

    #Added by Manish
    $scope.hideCompletedTask = applyFilters

    $scope.project.calcTopTasks()

    $scope.getOrderBy = () ->
      if $scope.filters.topTask
        'topWeight'
      else
        'definition.seq'

    #End Here

    # When refreshing tasks, we are just reloading the active tasks
    $scope.refreshTasks = applyFilters
    # Expose grade service names
    $scope.gradeNames = gradeService.grades
    # On task name change, reapply filters
    $scope.taskNameChanged = applyFilters
    # UI call to change currently selected task
    $scope.setSelectedTask = (task) ->
      # Clicking on already selected task will disable that selection
      task = null if $scope.isSelectedTask(task)
      $scope.taskData.selectedTask = task
      $scope.taskData.onSelectedTaskChange?(task)
      scrollToTaskInList(task) if task?
    scrollToTaskInList = (task) ->
      taskEl = document.querySelector("student-task-list ##{task.taskKeyToIdString()}")
      return unless taskEl?
      funcName = if taskEl.scrollIntoViewIfNeeded? then 'scrollIntoViewIfNeeded' else if taskEl.scrollIntoView? then 'scrollIntoView'
      return unless funcName?
      taskEl[funcName]({behavior: 'smooth', block: 'top'})
    $timeout ->
      scrollToTaskInList($scope.taskData.selectedTask) if $scope.taskData.selectedTask?
    $scope.isSelectedTask = (task) ->
      # Compare by definition
      task.definition.id == $scope.taskData?.selectedTask?.definition.id

)
