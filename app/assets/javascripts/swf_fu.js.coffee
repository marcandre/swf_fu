#= require_tree .

@SwfFu =
  setup: (object, klass, init_args) ->
    object extends klass.prototype
    object.initialize?(init_args...)
    null