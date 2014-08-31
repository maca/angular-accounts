app = angular.module 'tabs-directives', []

app.directive "tabs", ->
  restrict: "E"
  transclude: true
  scope: {}
  controller: ($scope) ->
    panes = $scope.panes = []
    $scope.select = (pane) ->
      angular.forEach panes, (pane) ->
        pane.selected = false
      pane.selected = true

    @addPane = (pane) ->
      $scope.select pane if panes.length is 0
      panes.push pane
    this
  templateUrl: "components/tabs.html"


app.directive "pane", ->
  require: "^tabs"
  restrict: "E"
  transclude: true
  scope:
    title: "@"
  link: (scope, element, attrs, tabsCtrl) -> tabsCtrl.addPane scope
  templateUrl: "components/pane.html"
