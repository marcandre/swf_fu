@receiveFromFlash = (arg) ->
  alert("Received from Flash: #{arg}")

class @ExampleClass
  initialize: ->
    alert("We're ready to rock & roll...")

  say: (what) ->
    @sendFlash(what)
