{assert, clickToolbarButton, createFile, defer, expandSelection, moveCursor, pasteContent, pressKey, test, testGroup, triggerEvent, typeCharacters} = Trix.TestHelpers

testGroup "Pasting", template: "editor_empty", ->
  test "paste plain text", (expectDocument) ->
    typeCharacters "abc", ->
      moveCursor "left", ->
        pasteContent "text/plain", "!", ->
          expectDocument "ab!c\n"

  test "paste simple html", (expectDocument) ->
    typeCharacters "abc", ->
      moveCursor "left", ->
        pasteContent "text/html", "&lt;", ->
          expectDocument "ab<c\n"

  test "paste complex html", (expectDocument) ->
    typeCharacters "abc", ->
      moveCursor "left", ->
        pasteContent "text/html", "<div>Hello world<br></div><div>This is a test</div>", ->
          expectDocument "abHello world\nThis is a test\nc\n"

  test "prefers plain text when html lacks formatting", (expectDocument) ->
    pasteData =
      "text/html": "<meta charset='utf-8'>a\nb"
      "text/plain": "a\nb"

    pasteContent pasteData, ->
      expectDocument "a\nb\n"

  test "prefers formatted html", (expectDocument) ->
    pasteData =
      "text/html": "<meta charset='utf-8'>a\n<strong>b</strong>"
      "text/plain": "a\nb"

    pasteContent pasteData, ->
      expectDocument "a b\n"

  test "paste URL", (expectDocument) ->
    typeCharacters "a", ->
      pasteContent "URL", "http://example.com", ->
        assert.textAttributes([1, 18], href: "http://example.com")
        expectDocument "ahttp://example.com\n"

  test "paste complex html into formatted block", (done) ->
    typeCharacters "abc", ->
      clickToolbarButton attribute: "quote", ->
        pasteContent "text/html", "<div>Hello world<br></div><pre>This is a test</pre>", ->
          document = getDocument()
          assert.equal document.getBlockCount(), 2

          block = document.getBlockAtIndex(0)
          assert.deepEqual block.getAttributes(), ["quote"],
          assert.equal block.toString(), "abcHello world\n"

          block = document.getBlockAtIndex(1)
          assert.deepEqual block.getAttributes(), ["quote", "code"]
          assert.equal block.toString(), "This is a test\n"

          done()

  test "paste list into list", (done) ->
    clickToolbarButton attribute: "bullet", ->
      typeCharacters "abc\n", ->
        pasteContent "text/html", "<ul><li>one</li><li>two</li></ul>", ->
          document = getDocument()
          assert.equal document.getBlockCount(), 3

          block = document.getBlockAtIndex(0)
          assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
          assert.equal block.toString(), "abc\n"

          block = document.getBlockAtIndex(1)
          assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
          assert.equal block.toString(), "one\n"

          block = document.getBlockAtIndex(2)
          assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
          assert.equal block.toString(), "two\n"

          done()

  test "paste list into quote", (done) ->
    clickToolbarButton attribute: "quote", ->
      typeCharacters "abc", ->
        pasteContent "text/html", "<ul><li>one</li><li>two</li></ul>", ->
          document = getDocument()
          assert.equal document.getBlockCount(), 3

          block = document.getBlockAtIndex(0)
          assert.deepEqual block.getAttributes(), ["quote"]
          assert.equal block.toString(), "abc\n"

          block = document.getBlockAtIndex(1)
          assert.deepEqual block.getAttributes(), ["quote", "bulletList", "bullet"]
          assert.equal block.toString(), "one\n"

          block = document.getBlockAtIndex(2)
          assert.deepEqual block.getAttributes(), ["quote", "bulletList", "bullet"]
          assert.equal block.toString(), "two\n"

          done()

  test "paste list into quoted list", (done) ->
    clickToolbarButton attribute: "quote", ->
      clickToolbarButton attribute: "bullet", ->
        typeCharacters "abc\n", ->
          pasteContent "text/html", "<ul><li>one</li><li>two</li></ul>", ->
            document = getDocument()
            assert.equal document.getBlockCount(), 3

            block = document.getBlockAtIndex(0)
            assert.deepEqual block.getAttributes(), ["quote", "bulletList", "bullet"]
            assert.equal block.toString(), "abc\n"

            block = document.getBlockAtIndex(1)
            assert.deepEqual block.getAttributes(), ["quote", "bulletList", "bullet"]
            assert.equal block.toString(), "one\n"

            block = document.getBlockAtIndex(2)
            assert.deepEqual block.getAttributes(), ["quote", "bulletList", "bullet"]
            assert.equal block.toString(), "two\n"

            done()

  test "paste nested list into empty list item", (done) ->
    clickToolbarButton attribute: "bullet", ->
      typeCharacters "y\nzz", ->
        getSelectionManager().setLocationRange(index: 0, offset: 1)
        defer ->
          pressKey "backspace", ->
            pasteContent "text/html", "<ul><li>a<ul><li>b</li></ul></li></ul>", ->
            document = getDocument()
            assert.equal document.getBlockCount(), 3

            block = document.getBlockAtIndex(0)
            assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
            assert.equal block.toString(), "a\n"

            block = document.getBlockAtIndex(1)
            assert.deepEqual block.getAttributes(), ["bulletList", "bullet", "bulletList", "bullet"]
            assert.equal block.toString(), "b\n"

            block = document.getBlockAtIndex(2)
            assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
            assert.equal block.toString(), "zz\n"
            done()

  test "paste nested list over list item contents", (done) ->
    clickToolbarButton attribute: "bullet", ->
      typeCharacters "y\nzz", ->
        getSelectionManager().setLocationRange(index: 0, offset: 1)
        defer ->
          expandSelection "left", ->
            pasteContent "text/html", "<ul><li>a<ul><li>b</li></ul></li></ul>", ->
            document = getDocument()
            assert.equal document.getBlockCount(), 3

            block = document.getBlockAtIndex(0)
            assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
            assert.equal block.toString(), "a\n"

            block = document.getBlockAtIndex(1)
            assert.deepEqual block.getAttributes(), ["bulletList", "bullet", "bulletList", "bullet"]
            assert.equal block.toString(), "b\n"

            block = document.getBlockAtIndex(2)
            assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
            assert.equal block.toString(), "zz\n"
            done()

  test "paste list into empty block before list", (done) ->
    clickToolbarButton attribute: "bullet", ->
      typeCharacters "c", ->
        moveCursor "left", ->
          pressKey "return", ->
            getSelectionManager().setLocationRange(index: 0, offset: 0)
            defer ->
              pasteContent "text/html", "<ul><li>a</li><li>b</li></ul>", ->
                document = getDocument()
                assert.equal document.getBlockCount(), 3

                block = document.getBlockAtIndex(0)
                assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
                assert.equal block.toString(), "a\n"

                block = document.getBlockAtIndex(1)
                assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
                assert.equal block.toString(), "b\n"

                block = document.getBlockAtIndex(2)
                assert.deepEqual block.getAttributes(), ["bulletList", "bullet"]
                assert.equal block.toString(), "c\n"
                done()

  test "paste file", (expectDocument) ->
    typeCharacters "a", ->
      pasteContent "Files", (createFile()), ->
        expectDocument "a#{Trix.OBJECT_REPLACEMENT_CHARACTER}\n"

  test "paste event with no clipboardData", (expectDocument) ->
    typeCharacters "a", ->
      triggerEvent(document.activeElement, "paste")
      document.activeElement.insertAdjacentHTML("beforeend", "<span>bc</span>")
      requestAnimationFrame ->
        expectDocument("abc\n")
