module.exports =
class Deprecation
  @generateStack: ->
    originalPrepareStackTrace = Error.prepareStackTrace
    Error.prepareStackTrace = (error, stack) -> stack
    error = new Error()
    Error.captureStackTrace(error)
    stack = error.stack[2..] # Force prepare the stack https://code.google.com/p/v8/wiki/JavaScriptStackTraceApi
    Error.prepareStackTrace = originalPrepareStackTrace
    stack

  @getMethodName: (callsite) ->
    if callsite.getTypeName() == "Window"
      callsite.getFunctionName()
    else
      if callsite.isConstructor()
        "new #{callsite.getFunctionName()}"
      else
        "#{callsite.getTypeName()}.#{callsite.getMethodName() or callsite.getFunctionName()}"

  constructor: (@message) ->
    @count = 0
    @stacks = []

  getMethodName: ->
    @methodName

  getMessage: ->
    @message

  getStacks: ->
    @stacks

  getCount: ->
    @count

  addStack: (stack) ->
    @methodName = Deprecation.getMethodName(stack) unless @methodName?
    @parseStack(stack)
    @stacks.push(stack) if @isStackUnique(stack)
    @count++

  parseStack: (stack) ->
    stack.map (callsite) ->
      methodName: Deprecation.getMethodName(callsite)
      location: Deprecation.getMethodName(stack)

  isStackUnique: (stack) ->
    stacks = stacks.filter (s) ->
      return false if s.length == stack.length

      for {methodName, location}, i in s
        return false unless methodName != stacks[i].methodName or location != stacks[i].location
