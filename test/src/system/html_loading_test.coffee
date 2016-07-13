{assert, test, testGroup} = Trix.TestHelpers

testGroup "HTML loading", ->
  testGroup "inline elements", template: "editor_with_styled_content", ->
    cases =
      "BR before block element styled otherwise":
        html: """a<br><figure class="attachment"><img src="#{TEST_IMAGE_URL}"></figure>"""
        expectedDocument: "a\n#{Trix.OBJECT_REPLACEMENT_CHARACTER}\n"

      "BR in text before block element styled otherwise":
        html: """<div>a<br>b<figure class="attachment"><img src="#{TEST_IMAGE_URL}"></figure></div>"""
        expectedDocument: "a\nb#{Trix.OBJECT_REPLACEMENT_CHARACTER}\n"

    for name, details of cases
      do (name, details) ->
        test name, (expectDocument) ->
          getEditor().loadHTML(details.html)
          expectDocument(details.expectedDocument)

  testGroup "bold elements", template: "editor_with_bold_styles", ->
    test "<strong> with font-weight: 500", (expectDocument) ->
      getEditor().loadHTML("<strong>a</strong>")
      assert.textAttributes([0, 1], bold: true)
      expectDocument("a\n")

    test "<span> with font-weight: 600", (expectDocument) ->
      getEditor().loadHTML("<span>a</span>")
      assert.textAttributes([0, 1], bold: true)
      expectDocument("a\n")

    test "<article> with font-weight: bold", (expectDocument) ->
      getEditor().loadHTML("<article>a</article>")
      assert.textAttributes([0, 1], bold: true)
      expectDocument("a\n")

  testGroup "underline elements", template: "editor_with_underline_styles", ->
    test "<cite> with underline decoration", (expectDocument) ->
      getEditor().loadHTML("<cite>a</cite>")
      assert.textAttributes([0, 1], underline: true)
      expectDocument("a\n")
    test "<mark> with underline & overline decoration", (expectDocument) ->
      getEditor().loadHTML("<mark>a</mark>")
      assert.textAttributes([0, 1], underline: true)
      expectDocument("a\n")
    test "ignore <a> with underline decoration", (expectDocument) ->
      getEditor().loadHTML("<a>a<u>b</u></a>")
      assert.textAttributes([0, 1], {})
      assert.textAttributes([1, 2], underline: true)
      expectDocument("ab\n")

  testGroup "styled block elements", template: "editor_with_block_styles", ->
    test "<em> in <blockquote> with font-style: italic", (expectDocument) ->
      getEditor().loadHTML("<blockquote>a<em>b</em></blockquote>")
      assert.textAttributes([0, 1], {})
      assert.textAttributes([1, 2], italic: true)
      assert.blockAttributes([0, 2], ["quote"])
      expectDocument("ab\n")

    test "<strong> in <li> with font-weight: bold", (expectDocument) ->
      getEditor().loadHTML("<ul><li>a<strong>b</strong></li></ul>")
      assert.textAttributes([0, 1], {})
      assert.textAttributes([1, 2], bold: true)
      assert.blockAttributes([0, 2], ["bulletList","bullet"])
      expectDocument("ab\n")
