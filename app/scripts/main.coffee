app = angular.module 'accounts', ['tabs-directives', 'cents-conversion']

accounts = [
  {name: 'Main',  balance: 1000}
  {name: 'Secondary',  balance: 3000}
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
        @holder.balance += @amount
        @account.balance -= @amount
      delete @amount
    this
  controllerAs: 'form'
  templateUrl: 'withdraw-form.html'

