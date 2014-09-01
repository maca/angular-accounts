app = angular.module 'accounts', ['tabs-directives', 'modal-directives', 'cents-conversion']

accounts =
  if serializedAccounts = localStorage['accounts']
    console.log serializedAccounts
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
    []

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
    @transactions.push toCommit.splice(0, toCommit.length)...

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

