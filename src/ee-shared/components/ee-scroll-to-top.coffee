'use strict'

angular.module 'ee-scroll-to-top', []

angular.module('ee-scroll-to-top').directive "eeScrollToTop", ($location, $anchorScroll) ->
  scope: {}
  link: (scope, ele, attrs) ->

    ele.on 'click', () -> scrollTo 'body-top'

    scrollTo = (eID) ->
      # This scrolling function
      # is from http://www.itnewb.com/tutorial/Creating-the-Smooth-Scroll-Effect-with-JavaScript
      i = null
      stopY = 0
      startY = currentYPosition()
      distance = if stopY > startY then stopY - startY else startY - stopY
      if distance < 100 then return window.scrollTo(0,0)
      speed = Math.round(distance / 100)
      if speed >= 20 then speed = 20
      step = Math.round(distance / 25)
      leapY = if stopY > startY then startY + step else startY - step
      timer = 0
      if stopY > startY
        i = startY
        while i <= stopY
          setTimeout('window.scrollTo(0, ' + leapY + ')', timer * speed)
          leapY += step
          if leapY > stopY then leapY = stopY
          timer++
          i += step
        return
      i = startY
      while i >= stopY
        setTimeout('window.scrollTo(0, ' + leapY + ')', timer * speed)
        leapY -= step
        if leapY < stopY then leapY = stopY
        timer++
        i -= step

    currentYPosition = () ->
      if window.pageYOffset then return window.pageYOffset # Firefox, Chrome, Opera, Safari
      if document.documentElement && document.documentElement.scrollTop then return document.documentElement.scrollTop # Internet Explorer 6 - standards mode
      if document.body.scrollTop then return document.body.scrollTop # Internet Explorer 6, 7 and 8
      0
