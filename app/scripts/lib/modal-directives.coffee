app = angular.module 'modal-directives', []

app.directive "modal", ->
  restrict: "E"
  transclude: true
  replace: true
  scope:
    title: '@'
  controller: ($scope) -> this
  templateUrl: "components/modal.html"

app.directive "modalBody", ->
  restrict: "E"
  transclude: true
  replace: true
  template: '<div ng-transclude class="modal-body"></div>'

app.directive "modalFooter", ->
  restrict: "E"
  transclude: true
  replace: true
  link: ($scope, elem, attrs, ctrl, transclude) ->
    elem.append transclude()
  templateUrl: 'components/modal-footer.html'
