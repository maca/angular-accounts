app = angular.module 'cents-conversion', []

app.filter 'fromCents',  -> (val) -> val / 100

app.directive 'toCents', ->
  require: 'ngModel'
  link: (scope, elem, attrs, ctrl) ->
    ctrl.$parsers.unshift (val) -> parseInt(val * 100) if val
    ctrl.$formatters.unshift (val) -> val / 100 if val
    this

app.filter "customCurrency", ["$filter", ($filter) ->
  (amount, currencySymbol) ->
    currency = $filter("currency")
    return currency(amount, currencySymbol).replace("(", "-").replace(")", "")  if amount < 0
    currency amount, currencySymbol
]
