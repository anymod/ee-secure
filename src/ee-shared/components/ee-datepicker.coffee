'use strict'

module = angular.module 'ee-datepicker', []

angular.module('ee-datepicker').directive "eeDatepicker", () ->
  templateUrl: 'ee-shared/components/ee-datepicker.html'
  restrict: 'EA'
  scope:
    user: '='
    year: '='
    month: '='
    day: '='
  link: (scope, ele, attrs) ->
    today = new Date()
    calendarMonths = [ 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' ]
    scope.visibleMonths = []
    scope.dayWidth = 34

    daysInMonth = (year, month) -> new Date(year, month + 1, 0).getDate()

    addToVisibleMonths = (year, month, dayLimit) ->
      lastDay = daysInMonth(year, month)
      firstDay = 1
      entry =
        num: month
        name: calendarMonths[month]
        year: year
      if year is scope.createdYear and month is scope.createdMonth then firstDay = scope.createdDay
      if year is today.getFullYear() and month is today.getMonth() then lastDay = today.getDate()
      entry.days = [ lastDay..firstDay ]
      scope.visibleMonths.push entry

    # scope.setDate = (year, month, day) ->
    #   # year like 2016; month like 0-11; day like 1-31
    #   if !year or month is null then return
    #   scope.year  = year
    #   scope.month = month
    #   scope.day   = day

    if scope.user?.created_at?
      [ createdYear, createdMonth, createdDay ] = scope.user.created_at.split('T')[0].split('-')
      scope.createdYear   = parseInt(createdYear)
      scope.createdMonth  = parseInt(createdMonth) - 1
      scope.createdDay    = parseInt(createdDay)
      loopY = today.getFullYear()
      loopM = today.getMonth()
      while loopY > scope.createdYear or (loopY is scope.createdYear and loopM >= scope.createdMonth)
        addToVisibleMonths(loopY, loopM, scope.createdDay)
        loopM--
        if loopM < 0
          loopM = 11
          loopY--
        # Only go back to Dec 2015
        break if loopY is 2015 and loopM is 10

    # scope.setDate today.getFullYear(), today.getMonth(), today.getDate()

    return
