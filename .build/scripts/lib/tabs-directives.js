(function() {
  var app;

  app = angular.module('tabs-directives', []);

  app.directive("tabs", function() {
    return {
      restrict: "E",
      transclude: true,
      scope: {},
      controller: function($scope) {
        var panes;
        panes = $scope.panes = [];
        $scope.select = function(pane) {
          angular.forEach(panes, function(pane) {
            return pane.selected = false;
          });
          return pane.selected = true;
        };
        this.addPane = function(pane) {
          if (panes.length === 0) {
            $scope.select(pane);
          }
          return panes.push(pane);
        };
        return this;
      },
      templateUrl: "components/tabs.html"
    };
  });

  app.directive("pane", function() {
    return {
      require: "^tabs",
      restrict: "E",
      transclude: true,
      scope: {
        title: "@"
      },
      link: function(scope, element, attrs, tabsCtrl) {
        return tabsCtrl.addPane(scope);
      },
      templateUrl: "components/pane.html"
    };
  });

}).call(this);

/*
//# sourceMappingURL=tabs-directives.js.map
*/
