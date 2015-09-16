angular.module 'ee-cloudinaryUpload', []

angular.module('ee-cloudinaryUpload').directive "eeCloudinaryUpload", () ->
  templateUrl: 'ee-shared/components/ee-cloudinary-upload.html'
  restrict: 'E'
  replace: true
  scope:
    meta: '='
    attrTarget: '='
  link: (scope, element, attrs) ->
    form = element
    cloudinary_transform = 'storefront_home'
    if scope.attrTarget is 'logo'       then cloudinary_transform = 'storefront_logo'
    if scope.attrTarget is 'collection' then cloudinary_transform = 'banner'

    form
      .append $.cloudinary.unsigned_upload_tag cloudinary_transform, {
          cloud_name: 'eeosk',
          tags: 'browser_uploads'
        }

    assignAttr = (data) ->
      if scope.attrTarget is 'body'       then scope.meta.home.carousel[0].imgUrl = data.result.secure_url
      if scope.attrTarget is 'about'      then scope.meta.about.imgUrl = data.result.secure_url
      if scope.attrTarget is 'logo'       then scope.meta.logo = data.result.secure_url
      if scope.attrTarget is 'collection' then scope.meta.banner = data.result.secure_url

    resetProgress = () ->
      scope.progress = 0
      scope.partialProgress = 5

    bindCloudinary = () ->
      form
        .bind 'cloudinarydone', (e, data) ->
          resetProgress()
          unbindCloudinary()
          assignAttr(data)
          scope.$apply()
          bindCloudinary()
        .bind 'cloudinaryprogress', (e, data) ->
          percentage = Math.round((data.loaded * 100.0) / data.total)
          # Only scope.$apply periodically
          if percentage > scope.partialProgress
            scope.partialProgress = percentage + 5
            scope.progress = if scope.progress > 99 then 0 else percentage
            scope.$apply()

      unbindCloudinary = () ->
        form.unbind 'cloudinaryprogress'
        form.unbind 'cloudinarydone'

    resetProgress()
    bindCloudinary()
    return
