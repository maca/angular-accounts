(function() {
  var app;

  app = angular.module('modal-directives', []);

  app.directive("modal", function() {
    return {
      restrict: "E",
      transclude: true,
      replace: true,
      scope: {
        title: '@'
      },
      controller: function($scope) {
        return this;
      },
      templateUrl: "components/modal.html"
    };
  });

  app.directive("modalBody", function() {
    return {
      restrict: "E",
      transclude: true,
      replace: true,
      template: '<div ng-transclude class="modal-body"></div>'
    };
  });

  app.directive("modalFooter", function() {
    return {
      restrict: "E",
      transclude: true,
      replace: true,
      link: function($scope, elem, attrs, ctrl, transclude) {
        return elem.append(transclude());
      },
      templateUrl: 'components/modal-footer.html'
    };
  });

}).call(this);

/*
//# sourceMappingURL=modal-directives.js.map
*/
