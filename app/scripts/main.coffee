app = angular.module 'accounts', ['tabs-directives', 'modal-directives', 'cents-conversion']

## Retrieve from localstore or use fake data
accounts =
  if serializedAccounts = localStorage['accounts']
    JSON.parse serializedAccounts
  else
    [
      {name: 'Corriente',  balance: 1000 * 100}
      {name: 'Ahorros',  balance: 3000 * 100}
    ]
transactions =
  if serializedTransactions = localStorage['transactions']
    JSON.parse serializedTransactions
  else
    {account: acc.name, amount: acc.balance, balance: acc.balance, time: new Date} for acc in accounts


app.controller 'AccountsController', ->
  @items        = accounts
  @transactions = transactions
  @holder       = {balance: 0, transactions: []}

  @isReadyToCommit = ->
    @holder.balance is 0 and @holder.transactions.length

  @isHolderVisible = ->
    @holder.balance or @holder.transactions.length

  @canDeposit = -> @holder.balance

  @commit = ->
    toCommit = @holder.transactions
    @transactions = @transactions.concat toCommit.splice(0, toCommit.length)

    localStorage['transactions'] = JSON.stringify @transactions
    localStorage['accounts']     = JSON.stringify @items

  this
  

app.directive 'withdrawForm', ->
  restrict: 'E'
  controller: ($scope) ->
    @init     = (@account, @holder) ->
    @withdraw = ->
      @holder.balance  += @amount
      @account.balance -= @amount

      @holder.transactions.push
        account: @account.name
        balance: @account.balance
        amount: -@amount
        time: new Date

      delete @amount
      $scope.withdrawForm.$setPristine()
    this
  controllerAs: 'formCtrl'
  templateUrl: 'withdraw-form.html'

 
app.directive 'depositForm', ->
  restrict: 'E'
  controller: ($scope) ->
    @deposit   = {accIndex: 0}
    @init      = (@holder, @accounts) ->
    @isNewAcc  = -> @deposit.accIndex is 'new-account'

    @createAcc = ->
      account = {name: @deposit.newAccName, balance: 0}
      @accounts.push account
      account

    @makeDeposit = (account) ->
      @holder.balance -= @deposit.amount
      account.balance += @deposit.amount

      @holder.transactions.push
        account: account.name
        amount: @deposit.amount
        balance: account.balance
        time: new Date

      @deposit = {accIndex: 0}

    @submit = ->
      account = if @isNewAcc() then @createAcc() else @accounts[@deposit.accIndex]
      @makeDeposit account
      $scope.depositForm.$setPristine()
        
    this
  controllerAs: 'formCtrl'
  templateUrl: 'deposit-form.html'


app.directive 'transactionHistoryGraph', ['$filter', ($filter) ->
  restrict: 'E'
  replace: true
  controller: ($scope) ->
    @xFun      = (d) -> Date.parse d['time']
    @yFun      = (d) -> d['balance']
    @xTickFmt  = (d) -> d3.time.format('%d/%m/%Y %H:%m') new Date(d)
    @yTickFmt  = (d) -> $filter('currency')(d / 100)
    @drawGraph = =>
      account            = $scope.account
      transactions       = $scope.accounts.transactions
      $scope.accountName = account.name
      data = ({time: tr.time, balance: tr.balance} for tr in transactions when tr.account is account.name)
      nv.addGraph =>
        chart = nv.models.sparklinePlus().width(600).height(100).x(@xFun).y(@yFun).xTickFormat(@xTickFmt).yTickFormat(@yTickFmt)
        d3.select("##{@elemId} svg").datum(data).transition().duration(500).call chart
        nv.utils.windowResize chart.update

    $scope.$watch 'accounts.transactions', @drawGraph

    this

  link: ($scope, elem, attrs, ctrl) ->
    ctrl.elemId = attrs.id
    ctrl.drawGraph(attrs.id)

  controllerAs: 'graphCtrl'
  template: '<div><h3>Historial "{{accountName}}"</h3><svg></svg></div>'
]
