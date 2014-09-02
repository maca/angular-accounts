(function() {
  var acc, accounts, app, serializedAccounts, serializedTransactions, transactions;

  app = angular.module('accounts', ['tabs-directives', 'modal-directives', 'cents-conversion']);

  accounts = (serializedAccounts = localStorage['accounts']) ? JSON.parse(serializedAccounts) : [
    {
      name: 'Corriente',
      balance: 1000 * 100
    }, {
      name: 'Ahorros',
      balance: 3000 * 100
    }
  ];

  transactions = (function() {
    var _i, _len, _results;
    if (serializedTransactions = localStorage['transactions']) {
      return JSON.parse(serializedTransactions);
    } else {
      _results = [];
      for (_i = 0, _len = accounts.length; _i < _len; _i++) {
        acc = accounts[_i];
        _results.push({
          account: acc.name,
          amount: acc.balance,
          balance: acc.balance,
          time: new Date
        });
      }
      return _results;
    }
  })();

  app.controller('AccountsController', function() {
    this.items = accounts;
    this.transactions = transactions;
    this.holder = {
      balance: 0,
      transactions: []
    };
    this.isReadyToCommit = function() {
      return this.holder.balance === 0 && this.holder.transactions.length;
    };
    this.isHolderVisible = function() {
      return this.holder.balance || this.holder.transactions.length;
    };
    this.canDeposit = function() {
      return this.holder.balance;
    };
    this.commit = function() {
      var toCommit;
      toCommit = this.holder.transactions;
      this.transactions = this.transactions.concat(toCommit.splice(0, toCommit.length));
      localStorage['transactions'] = JSON.stringify(this.transactions);
      return localStorage['accounts'] = JSON.stringify(this.items);
    };
    return this;
  });

  app.directive('withdrawForm', function() {
    return {
      restrict: 'E',
      controller: function($scope) {
        this.init = function(account, holder) {
          this.account = account;
          this.holder = holder;
        };
        this.withdraw = function() {
          this.holder.balance += this.amount;
          this.account.balance -= this.amount;
          this.holder.transactions.push({
            account: this.account.name,
            balance: this.account.balance,
            amount: -this.amount,
            time: new Date
          });
          delete this.amount;
          return $scope.withdrawForm.$setPristine();
        };
        return this;
      },
      controllerAs: 'formCtrl',
      templateUrl: 'withdraw-form.html'
    };
  });

  app.directive('depositForm', function() {
    return {
      restrict: 'E',
      controller: function($scope) {
        this.deposit = {
          accIndex: 0
        };
        this.init = function(holder, accounts) {
          this.holder = holder;
          this.accounts = accounts;
        };
        this.isNewAcc = function() {
          return this.deposit.accIndex === 'new-account';
        };
        this.createAcc = function() {
          var account;
          account = {
            name: this.deposit.newAccName,
            balance: 0
          };
          this.accounts.push(account);
          return account;
        };
        this.makeDeposit = function(account) {
          this.holder.balance -= this.deposit.amount;
          account.balance += this.deposit.amount;
          this.holder.transactions.push({
            account: account.name,
            amount: this.deposit.amount,
            balance: account.balance,
            time: new Date
          });
          return this.deposit = {
            accIndex: 0
          };
        };
        this.submit = function() {
          var account;
          account = this.isNewAcc() ? this.createAcc() : this.accounts[this.deposit.accIndex];
          this.makeDeposit(account);
          return $scope.depositForm.$setPristine();
        };
        return this;
      },
      controllerAs: 'formCtrl',
      templateUrl: 'deposit-form.html'
    };
  });

  app.directive('transactionHistoryGraph', [
    '$filter', function($filter) {
      return {
        restrict: 'E',
        replace: true,
        controller: function($scope) {
          this.xFun = function(d) {
            return Date.parse(d['time']);
          };
          this.yFun = function(d) {
            return d['balance'];
          };
          this.xTickFmt = function(d) {
            return d3.time.format('%d/%m/%Y %H:%m')(new Date(d));
          };
          this.yTickFmt = function(d) {
            return $filter('currency')(d / 100);
          };
          this.drawGraph = (function(_this) {
            return function() {
              var account, data, tr;
              account = $scope.account;
              transactions = $scope.accounts.transactions;
              $scope.accountName = account.name;
              data = (function() {
                var _i, _len, _results;
                _results = [];
                for (_i = 0, _len = transactions.length; _i < _len; _i++) {
                  tr = transactions[_i];
                  if (tr.account === account.name) {
                    _results.push({
                      time: tr.time,
                      balance: tr.balance
                    });
                  }
                }
                return _results;
              })();
              return nv.addGraph(function() {
                var chart;
                chart = nv.models.sparklinePlus().width(600).height(100).x(_this.xFun).y(_this.yFun).xTickFormat(_this.xTickFmt).yTickFormat(_this.yTickFmt);
                d3.select("#" + _this.elemId + " svg").datum(data).transition().duration(500).call(chart);
                return nv.utils.windowResize(chart.update);
              });
            };
          })(this);
          $scope.$watch('accounts.transactions', this.drawGraph);
          return this;
        },
        link: function($scope, elem, attrs, ctrl) {
          ctrl.elemId = attrs.id;
          return ctrl.drawGraph(attrs.id);
        },
        controllerAs: 'graphCtrl',
        template: '<div><h3>Historial "{{accountName}}"</h3><svg></svg></div>'
      };
    }
  ]);

}).call(this);

/*
//# sourceMappingURL=main.js.map
*/
