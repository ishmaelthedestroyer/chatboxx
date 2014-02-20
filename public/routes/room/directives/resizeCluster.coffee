app.directive 'resizecluster', ($window) ->
  (scope, element, attr) ->
    getSiblings = () ->
      all = element.parent().children()
      siblings = []

      for a in all
        if a.attributes['resizecluster'] and a isnt element[0]
          siblings.push a

      return siblings

    getStyleAttr = (_e, attr) ->
      strValue = ""
      if document.defaultView and document.defaultView.getComputedStyle
        strValue = document.defaultView.getComputedStyle(_e, "")
        .getPropertyValue(attr)
      else if _e.currentStyle
        attr = attr.replace(/\-(\w)/g, (strMatch, p1) ->
          p1.toUpperCase()
        )
        strValue = _e.currentStyle[attr]
      return parseInt(strValue.replace(/[^0-9]/g, ''))

    resizeFn = (e, _e) ->
      _e = element[0] if !_e
      return false if _e.getAttribute('resizecluster') is 'disabled'
      e.preventDefault() if e

      # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # #

      # computations

      parent = element.parent()[0]

      parentPaddingLeft = getStyleAttr parent, 'padding-left'
      parentPaddingRight = getStyleAttr parent, 'padding-right'
      parentPaddingTop = getStyleAttr parent, 'padding-top'
      parentPaddingBottom = getStyleAttr parent, 'padding-bottom'

      parentWidth = parent.offsetWidth
      parentHeight = parent.offsetHeight

      elementMarginLeft = getStyleAttr _e, 'margin-left'
      elementMarginRight = getStyleAttr _e, 'margin-right'
      elementMarginTop = getStyleAttr _e, 'margin-top'
      elementMarginBottom = getStyleAttr _e, 'margin-bottom'

      computedParentWidth = parentWidth - parentPaddingLeft -
        parentPaddingRight
      computedParentHeight = parentHeight - parentPaddingTop -
        parentPaddingBottom

      console.log 'parent...',
        parent: parent
        computedParentWidth: computedParentWidth
        computedParentHeight: computedParentHeight
        parentWidth: parentWidth
        parentHeight: parentHeight
        parentPaddingLeft: parentPaddingLeft
        parentPaddingRight: parentPaddingRight
        parentPaddingTop: parentPaddingTop
        parentPaddingBottom: parentPaddingBottom

      # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # #

      # basic declarations

      numElements = getSiblings().length + 1

      padding = _e.getAttribute('resizeclusterpadding') || 25
      ratio = _e.getAttribute('resizeclusterratio') || 0.8

      padding = parseInt padding
      ratio = parseFloat ratio

      newWidth = 0
      newHeight = 0

      rows = 0
      cols = 0

      # # # # # # # # # # # # # # # # # # # #
      # # # # # # # # # # # # # # # # # # # #

      # algorithm

      if numElements <= 1
        rows = 1
        cols = 1
      else if numElements is 2
        rows = 1
        cols = 2
      else if numElements is 3 || numElements is 4
        rows = 2
        cols = 2
      else if numElements is 5 || numElements is 6
        rows = 2
        cols = 3
      else if numElements is 7 || numElements is 8
        rows = 2
        cols = 4
      else
        rows = 2
        cols = Math.ceil numElements / 2

      ###
      if computedParentWidth > computedParentHeight # swap
        temp = cols
        cols = rows
        rows = temp
      ###

      calculate = () ->
        ###
        newWidth = (computedParentWidth / cols) -
          ((elementMarginLeft + elementMarginRight) * cols) - padding
        newHeight = (computedParentHeight / rows)  -
          ((elementMarginTop + elementMarginBottom) * rows) - padding
        ###

        ###
        newWidth = computedParentWidth /
          (((elementMarginLeft + elementMarginRight) * cols) + padding)
        newHeight = computedParentHeight /
          (((elementMarginTop + elementMarginBottom) * rows) + padding)
        ###

        ###
        newWidth = computedParentWidth /
          ((elementMarginLeft + elementMarginRight + padding) * cols)
        newHeight = computedParentHeight /
          ((elementMarginTop + elementMarginBottom + padding) * rows)
        ###
        newWidth = (computedParentWidth / cols) -
          ((elementMarginLeft + elementMarginRight + padding) * cols)
        newHeight = (computedParentHeight / rows) -
          ((elementMarginTop + elementMarginBottom + padding) * rows)

      adjust = () ->
        if newWidth > newHeight
          newWidth = Math.floor newHeight / ratio
        else
          newHeight = Math.floor newWidth * ratio

      calculate()
      adjust()

      if newWidth < 200 || newHeight < 200
        cols = 1
        rows = 1
        calculate()
        adjust()

      if newWidth > 800 and newHeight > 800
        newWidth = 800
        newHeight = 800
        adjust()
      else if newWidth > 800 and newHeight < 800
        newHeight = 800
        adjust()
      else if newHeight > 800 and newWidth < 800
        newWidth = 800
        adjust()

      console.log 'Got dimensions.',
        cols: cols
        rows: rows
        padding: padding
        ratio: ratio
        newWidth: newWidth
        newHeight: newHeight

      _e.style.width = newWidth + 'px'
      _e.style.height = newHeight + 'px'

    resizeFn null, element[0] # fire on initializiation
    resizeFn null, s for s in getSiblings() # resize all siblings


    angular.element($window).bind 'resize', resizeFn # bind to window resize