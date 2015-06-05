angular.module('zkbalance.collapse', [])
.directive "collapse", () ->
  restrict: "E"
  transclude: true
  replace: true
  scope:
    title: "@"
  controller: ($scope, $element) ->
    $scope.opened = false
    $scope.toggle = () ->
      $scope.opened = !$scope.opened
  template: """
    <div class="collapsible">
    <header ng-click="toggle()">
      <h5>{{title}}</h5>
    </header>
    <section ng-transclude ng-class="{opened: opened}"></section>
  </div>
  """
