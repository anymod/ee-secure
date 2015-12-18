angular.module 'ee-web-colorpicker', []

angular.module('ee-web-colorpicker').directive 'eeWebColorpicker', () ->
    templateUrl: 'ee-shared/components/ee-web-colorpicker.html'
    restrict: 'EA'
    scope:
      dabPrimary: '='
      dabSecondary: '='
      dabTertiary: '='
    link: (scope, ele, attrs) ->

      scope.compress = true

      setDabFor = (rank) ->
        scope.selected = null
        for row in scope.rows
          for color in row.colors
            if rank is 1 and color is scope.dabPrimary then scope.selectColor color
            if rank is 2 and color is scope.dabSecondary then scope.selectColor color
            if rank is 3 and color is scope.dabTertiary then scope.selectColor color

      clearRank = () ->
        scope.rank = null
        scope.compress = true

      scope.setRank = (rank) ->
        if scope.rank is rank and scope.compress is false then return clearRank()
        scope.rank = rank
        setDabFor rank
        scope.compress = false

      scope.selectColor = (color) ->
        scope.selected = color
        if scope.rank is 1 then scope.dabPrimary = color
        if scope.rank is 2 then scope.dabSecondary = color
        if scope.rank is 3 then scope.dabTertiary = color

      scope.rows = [
        { offset: 3,    colors: ['#003366', '#336699', '#3366CC', '#003399', '#000099', '#0000CC', '#000066'] },
        { offset: 2.5,  colors: ['#006666', '#006699', '#0099CC', '#0066CC', '#0033CC', '#0000FF', '#3333FF', '#333399'] },
        { offset: 2,    colors: ['#669999', '#009999', '#33CCCC', '#00CCFF', '#0099FF', '#0066FF', '#3366FF', '#3333CC', '#666699'] },
        { offset: 1.5,  colors: ['#339966', '#00CC99', '#00FFCC', '#00FFFF', '#33CCFF', '#3399FF', '#6699FF', '#6666FF', '#6600FF', '#6600CC'] },
        { offset: 1,    colors: ['#339933', '#00CC66', '#00FF99', '#66FFCC', '#66FFFF', '#66CCFF', '#99CCFF', '#9999FF', '#9966FF', '#9933FF', '#9900FF'] },
        { offset: 0.5,  colors: ['#006600', '#00CC00', '#00FF00', '#66FF99', '#99FFCC', '#CCFFFF', '#CCCCFF', '#CC99FF', '#CC66FF', '#CC33FF', '#CC00FF', '#9900CC'] },
        { offset: 0,    colors: ['#003300', '#009933', '#33CC33', '#66FF66', '#99FF99', '#CCFFCC', '#FFFFFF', '#FFCCFF', '#FF99FF', '#FF66FF', '#FF00FF', '#CC00CC', '#660066'] },
        { offset: 0.5,  colors: ['#336600', '#009900', '#66FF33', '#99FF66', '#CCFF99', '#FFFFCC', '#FFCCCC', '#FF99CC', '#FF66CC', '#FF33CC', '#CC0099', '#993399'] },
        { offset: 1,    colors: ['#333300', '#669900', '#99FF33', '#CCFF66', '#FFFF99', '#FFCC99', '#FF9999', '#FF6699', '#FF3399', '#CC3399', '#990099'] },
        { offset: 1.5,  colors: ['#666633', '#99CC00', '#CCFF33', '#FFFF66', '#FFCC66', '#FF9966', '#FF6666', '#FF0066', '#CC6699', '#993366'] },
        { offset: 2,    colors: ['#999966', '#CCCC00', '#FFFF00', '#FFCC00', '#FF9933', '#FF6600', '#FF5050', '#CC0066', '#660033'] },
        { offset: 2.5,  colors: ['#996633', '#CC9900', '#FF9900', '#CC6600', '#FF3300', '#FF0000', '#CC0000', '#990033'] },
        { offset: 3,    colors: ['#663300', '#996600', '#CC3300', '#993300', '#990000', '#800000', '#993333'] },
        { colors: [] },
        { offset: 1.5,  colors: ['#E6E6E6', '#CCCCCC', '#B3B3B3', '#999999', '#808080', '#666666', '#4C4C4C', '#333333', '#191919', '#000000'] }
      ]

      return
