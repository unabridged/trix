Trix.config.textAttributes =
  bold:
    tagName: "strong"
    inheritable: true
    parser: (element) ->
      style = window.getComputedStyle(element)
      style["fontWeight"] is "bold" or style["fontWeight"] >= 600
  italic:
    tagName: "em"
    inheritable: true
    parser: (element) ->
      style = window.getComputedStyle(element)
      style["fontStyle"] is "italic"
  underline:
    tagName: "u"
    inheritable: true
    parser: (element) ->
      return false if element.tagName is "A"
      style = window.getComputedStyle(element)
      /underline/.test style["textDecoration"]
  href:
    groupTagName: "a"
    parser: (element) ->
      {attachmentSelector} = Trix.AttachmentView
      matchingSelector = "a:not(#{attachmentSelector})"
      if link = Trix.findClosestElementFromNode(element, {matchingSelector})
        link.getAttribute("href")
  strike:
    tagName: "del"
    inheritable: true
  frozen:
    style: { "backgroundColor": "highlight" }
