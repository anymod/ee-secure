module = angular.module 'ee-save', []

angular.module('ee-save').directive "eeSave", ($state, eeDefiner, eeUser) ->
  templateUrl: 'ee-shared/components/ee-save.html'
  restrict: 'E'
  scope: {}
  link: (scope, ele, attr) ->
    scope.ee = eeDefiner.exports

    setBtnText    = (txt) -> scope.btnText = txt
    resetBtnText  = ()    -> setBtnText 'Save'
    resetBtnText()

    scope.$watch 'ee.User.user', (newVal, oldVal) ->
      if oldVal and oldVal.email and !angular.equals(newVal, oldVal)
        scope.ee.unsaved = true
        resetBtnText()
    , true

    scope.save = () ->
      setBtnText 'Saving'
      eeUser.fns.updateUser()
      .then () ->
        scope.ee.unsaved = false
        setBtnText 'Saved'
        # $state.go 'dashboard'
      .catch () ->
        scope.ee.unsaved = true
        setBtnText 'Error'

    return
