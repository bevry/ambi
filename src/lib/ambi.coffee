# Import
typeChecker = require('typechecker')

# Define
ambi = (method,args...) ->
	# Prepare
	callback = args[args.length-1]
	result = null
	err = null

	# Introspect
	if typeChecker.isArray(method)
		[fireMethod, introspectMethod] = method
	else
		fireMethod = introspectMethod = method

	# Expected arguments are the same as the actual arguments
	# So assume it is an asynchronous function
	# Only call the callback if the function fails
	if introspectMethod.length is args.length
		# Fire the method
		try
			result = fireMethod.apply(null,args)
			err = result  if typeChecker.isError(result)
		catch caughtError
			err = caughtError

		# Check for error
		if err
			callback?(err)

	# We don't have the callback
	# assume it is sync
	else
		# Fire the function
		try
			result = fireMethod.apply(null,args)
			err = result  if typeChecker.isError(result)
		catch caughtError
			err = caughtError

		# Fire the callback
		if err
			callback?(err)
		else
			callback?(null,result)

	# Return the error or the result if there was no error
	return err or result

# Export
module.exports = ambi