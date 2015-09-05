# Import
typeChecker = require('typechecker')

# Define
ambi = (method, args...) ->
	# If binding has occured then make sure we are introspecting the write method
	# by allowing the user to pass method as an array of two methods
	# the method to fire, and the method to introspect
	if typeChecker.isArray(method)
		[fireMethod, introspectMethod] = method
	else
		fireMethod = introspectMethod = method

	# Extract the preceeding arguments and the completion callback
	[simpleArguments..., completionCallback] = args

	# Check the completion callback is actually a function
	unless typeChecker.isFunction(completionCallback)
		err = new Error('ambi was called without a completion callback')
		throw err

	###
	Different ways functions can be called:
	ambi(function(a,next){return next()}, a, next)
		> VALID: execute asynchronously
		> given arguments are SAME as the accepted arguments
		> method will be fired with (a, next)
	ambi(function(a,next){return next()}, next)
		> VALID: execute asynchronously
		> given arguments are LESS than the accepted arguments
		> method will be fired with (undefined, next)
	ambi(function(a){}, a, next)
		> VALID: execute synchronously
		> given arguments are MORE than expected arguments
		> method will be fired with (a)
	ambi(function(a){}, next)
		> INVALID: execute asynchronously
		> given arguments are SAME as the accepted arguments
		> method will be fired with (next)
		> if they want to use optional args, the function must accept a completion callback
	###
	givenArgumentsLength = args.length
	acceptedArgumentsLength = introspectMethod.length

	# Given arguments are SAME as the expected arguments
	# This will execute asynchronously
	# Don't have to do anything with the arguments
	if givenArgumentsLength is acceptedArgumentsLength
		executeAsynchronously = true

	# Given arguments are LESS than the expected arguments
	# This will execute asynchronously
	# We will need to supplement any missing expected arguments with undefined
	# to ensure the compeltion callback is in the right place in the arguments listing
	else if givenArgumentsLength < acceptedArgumentsLength
		executeAsynchronously = true
		argumentsDifferenceLength = acceptedArgumentsLength - givenArgumentsLength
		args = simpleArguments.slice().concat(new Array(argumentsDifferenceLength)).concat([completionCallback])

	# Given arguments are MORE than the expected arguments
	# This will execute synchronously
	# We should to trim off the completion callback from the arguments
	# as the synchronous function won't care for it
	# while this isn't essential
	# it will provide some expectation for the user as to which mode their function was executed in
	else
		executeAsynchronously = false
		args = simpleArguments.slice()

	# Execute with the exceptation that the method will fire the completion callback itself
	if executeAsynchronously
		# Fire the method
		fireMethod.apply(null, args)

	# Execute with the expectation that we will need to fire the completion callback ourselves
	# Always call the completion callback ourselves as the fire method does not make use of it
	else
		# Fire the method and check for returned errors
		result = fireMethod.apply(null, args)

		# Check the result for a returned error
		if typeChecker.isError(result)
			# An error was returned so fire the completion callback with the error
			err = result
			completionCallback(err)
		else
			# Everything worked, so fire the completion callback without an error and with the result
			completionCallback(null, result)

	# Return nothing as we expect ambi to deal with synchronous and asynchronous methods
	# so returning something will only work for synchronous methods
	# and not asynchronous ones
	# so returning anything would be inconsistent
	return null

# Export
module.exports = ambi