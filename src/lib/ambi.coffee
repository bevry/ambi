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

	# Function takes in the exact arguments supplied
	# so assume it is an asynchronous function
	# - e.g:   `fn(opts,next)`
	# - async: `fn = (opts,next) -> next(err,result)`
	# - sync:  `fn = (opts) -> return err or result`
	isAsynchronousMethod = introspectMethod.length is args.length

	# Extract the completion callback
	completionCallback = args[args.length-1]

	# Check the completio callback is actually a function
	unless typeChecker.isFunction(completionCallback)
		err = new Error('ambi was called without a completion callback')
		throw err

	# Asynchronous method
	# Only call the completion callback if an error occurs as the fire method should fire the completion callback itself if all goes well
	if isAsynchronousMethod
		# Fire the method and catch errors
		try
			fireMethod.apply(null, args)
		catch err
			# an error was caught so fire the completion callback with the error
			err = result
			completionCallback(err)

	# Synchronous method
	# Always call the completion callback ourselves as the fire method does not make use of it
	else
		# Fire the method and catch errors
		try
			result = fireMethod.apply(null, args)
		catch err
			result = err

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