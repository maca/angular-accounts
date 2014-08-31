app = angular.module 'accounts', ['tabs-directives', 'cents-conversion']

accounts = [
  {name: 'Corriente',  balance: 1000 * 100}
  {name: 'Ahorros',  balance: 3000 * 100}
]

app.controller 'AccountsController', ->
  @items  = accounts
  @holder = {balance: 0}
  this
  
app.directive 'withdrawForm', ->
  restrict: 'E'
  controller: ->
    @init     = (@account, @holder) ->
    @withdraw = ->
      if @amount
        @holder.balance  += @amount
        @account.balance -= @amount
      delete @amount
    this
  controllerAs: 'form'
  templateUrl: 'withdraw-form.html'

app.directive 'depositForm', ->
  restrict: 'E'
  controller: ->
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
      @deposit = {}

    @submit = ->
      account = if @isNewAcc() then @createAcc() else @accounts[@accIndex]
      console.log account
      @makeDeposit account
    this
  controllerAs: 'formCtrl'
  templateUrl: 'deposit-form.html'
