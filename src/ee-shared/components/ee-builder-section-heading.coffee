angular.module 'ee-builder-section-heading', []

angular.module('ee-builder-section-heading').directive "eeBuilderSectionHeading", () ->
  templateUrl: 'ee-shared/components/ee-builder-section-heading.html'
  restrict: 'E'
  scope:
    heading:      '@'
    headingClass: '@'
    subheading:   '@'
