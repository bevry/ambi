# Import
typeChecker = require('typechecker')
domain = require('domain')

# Define
ambi = (method,args...) ->
	# Prepare some defaults
	exited = false
	originalCompletionCallback = null
	wrappedCompletionCallback = null

	# If binding has occured then make sure we are introspecting the write method
	# by allowing the user to pass method as an array of two methods
	# the method to fire, and the method to introspect
	if typeChecker.isArray(method)
		[fireMethod, introspectMethod] = method
	else
		fireMethod = introspectMethod = method

	# Create the domain for catching uncaught errors
	d = domain.create()

	# Fetch the original completion callback
	originalCompletionCallback = args[args.length-1]

	# Wrap our completion callback so we can tell whether or not it has been called or not
	wrappedCompletionCallback = (args...) ->
		if exited
			# we have already exited, and this shouldn't have happend
			# so let's figure out why
			if args[0]
				# okay it could be that an uncaught error happened, but as we have already exited
				# lets just throw it instead to ensure it does somehow get caught
				# perhaps by another domain
				# as if we just called the completion callback again
				# then we could tread down a path already executed which would not be expected
				err = args[0]
				throw err
			else
				# there wasn't an error but for some reason the completion callback fired twice
				# we should make an error about this and throw it
				err = new Error("a completion callback has fired twice which is unexpected behaviour")
				throw err
		else
			# mark that we have now exited
			exited = true

			# fire our original completion callback
			originalCompletionCallback?.apply(null, args)

		# dispose of the delay eventually
		# giving us some time to detect duplicated calls to the callback
		process.nextTick ->
			if d?
				d.dispose()
				d = null

	# Update the reference to the orginal completion callback with the wrapped one
	# to ensure it gets called by asynchronous functions
	args[args.length-1] = wrappedCompletionCallback

	# Function takes in the exact arguments supplied
	# so assume it is an asynchronous function
	# e.g. `fn(opts,next)` and `fn = (opts,next) -> next()`
	# Only call the completion callback if an error occurs as the fire method should fire the completion callback itself if all goes well
	if introspectMethod.length is args.length
		# Listen for uncaught errors within the execution scopes (and child scopes) with domains
		# and if an error occurs then fire the completion callback as the fire method for whatever reason didn't catch it
		d.on('error', wrappedCompletionCallback)

		# Run the domain and thus creating the scope for its catching
		result = null
		d.run ->
			# Fire the method and still check for a returned error
			result = fireMethod.apply(null, args)

		# Deal with the result
		if typeChecker.isError(result)
			# an error was returned so fire the completion callback with the error
			err = result
			wrappedCompletionCallback(err)
		else
			# do nothing as the completion callback should be called by the fire method

	# Function does not take in the exact arguments supplied
	# so assume it is a synchronous function
	# e.g. `fn(opts,next)` and `fn = (opts) ->`
	# Always call the completion callback ourselves as the fire method does not make use of it
	else
		# Listen for uncaught errors within the execution scopes (and child scopes) with domains
		# and if an error occurs then fire the completion callback as the fire method for whatever reason didn't catch it
		d.on('error', wrappedCompletionCallback)

		# Run the domain and thus creating the scope for its catching
		result = null
		d.run ->
			# Fire the method and still check for a returned error
			result = fireMethod.apply(null, args)

		# Deal with the result
		if typeChecker.isError(result)
			# an error was returned so fire the completion callback with the error
			err = result
			wrappedCompletionCallback(err)
		else
			# everything worked, so fire the completion callback without an error and with the result
			wrappedCompletionCallback(null, result)

	# Return nothing as we expect ambi to deal with synchronous and asynchronous methods
	# so returning something will only work for synchronous methods
	# and not asynchronous ones
	# so returning anything would be inconsistent
	return null

# Export
module.exports = ambi