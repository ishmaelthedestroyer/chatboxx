angular.module('bxFormatFileSize', [])

.provider 'bxFormatFileSizeFilter', ->
  $config = units: [
    size: 1000000000
    suffix: " GB"
  ,
    size: 1000000
    suffix: " MB"
  ,
    size: 1000
    suffix: " KB"
  ]
  @defaults = $config
  @$get = ->
    (bytes) ->
      return ""  unless angular.isNumber(bytes)
      unit = true
      i = 0
      prefix = undefined
      suffix = undefined
      while unit
        unit = $config.units[i]
        prefix = unit.prefix or ""
        suffix = unit.suffix or ""

        if i is $config.units.length - 1 or bytes >= unit.size
          return prefix + (bytes / unit.size).toFixed(2) + suffix

        i += 1
  return
