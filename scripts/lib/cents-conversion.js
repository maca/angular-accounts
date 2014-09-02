(function() {
  var app;

  app = angular.module('cents-conversion', []);

  app.filter('fromCents', function() {
    return function(val) {
      return val / 100;
    };
  });

  app.directive('toCents', function() {
    return {
      require: 'ngModel',
      link: function(scope, elem, attrs, ctrl) {
        ctrl.$parsers.unshift(function(val) {
          if (val) {
            return parseInt(val * 100);
          }
        });
        ctrl.$formatters.unshift(function(val) {
          if (val) {
            return val / 100;
          }
        });
        return this;
      }
    };
  });

  app.filter("customCurrency", [
    "$filter", function($filter) {
      return function(amount, currencySymbol) {
        var currency;
        currency = $filter("currency");
        if (amount < 0) {
          return currency(amount, currencySymbol).replace("(", "-").replace(")", "");
        }
        return currency(amount, currencySymbol);
      };
    }
  ]);

}).call(this);

/*
//# sourceMappingURL=cents-conversion.js.map
*/
