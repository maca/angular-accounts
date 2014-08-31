(function() {
  var accounts, app;

  app = angular.module('accounts', ['tabs-directives', 'cents-conversion']);

  accounts = [
    {
      name: 'Main',
      balance: 1000
    }, {
      name: 'Secondary',
      balance: 3000
    }
  ];

  app.controller('AccountsController', function() {
    this.items = accounts;
    this.holder = {
      balance: 0
    };
    return this;
  });

  app.directive('withdrawForm', function() {
    return {
      restrict: 'E',
      controller: function() {
        this.init = function(account, holder) {
          this.account = account;
          this.holder = holder;
        };
        this.withdraw = function() {
          if (this.amount) {
            this.holder.balance += this.amount;
            this.account.balance -= this.amount;
          }
          return delete this.amount;
        };
        return this;
      },
      controllerAs: 'form',
      templateUrl: 'withdraw-form.html'
    };
  });

}).call(this);

/*
//# sourceMappingURL=main.js.map
*/
