# Import
{expect} = require('chai')
joe = require('joe')
ambi = require('../lib/ambi')

# Prepare
wait = (delay,fn) -> setTimeout(fn,delay)
delay = 100


# =====================================
# Tests

joe.describe 'ambi', (describe,it) ->
	it 'should handle result on successful synchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2

		# Perform multiply on a synchronous function
		# by return
		multiplySync = (x,y) ->
			++executedChecks
			return x*y

		# Test successful call
		ambi multiplySync, 2, 5, (err,result) ->
			expect(err, 'error to be null').to.eql(null)
			expect(result, 'result to be set').to.eql(10)
			++executedChecks

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			done()

	it 'should handle result on successful asynchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2

		# Perform multiply on an asynchronous function
		# by callback
		multiplyAsync = (x,y,next) ->
			wait delay, ->
				next(null, x*y)
				++executedChecks
			return 'async'

		# Test successful call
		ambi multiplyAsync, 2, 5, (err,result) ->
			expect(err, 'error to be null').to.eql(null)
			expect(result, 'result to be set').to.eql(10)
			++executedChecks

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			done()

	it 'should handle returned errors on unsuccessful synchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2

		# Define the error to be used
		errMessage = 'my first error'

		# Perform an error on a synchronous function
		# by return
		returnErrorSync = (x,y) ->
			++executedChecks
			return new Error(errMessage)

		# Test unsuccessful call
		ambi returnErrorSync, 2, 5, (err,result) ->
			expect(err.message, 'error to be set').to.eql(errMessage)
			expect(result, 'result to be undefined').to.not.exist
			++executedChecks

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			done()

	it 'should handle callbacked errors on unsuccessful asynchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2

		# Define the error to be used
		errMessage = 'my first error'

		# Perform an error on an asynchronous function
		# by callback
		callbackErrorAsync = (x,y,next) ->
			wait delay, ->
				next(new Error(errMessage))
				++executedChecks
			return 'async'

		# Test unsuccessful call
		ambi callbackErrorAsync, 2, 5, (err,result) ->
			expect(err.message, 'error to be set').to.eql(errMessage)
			expect(result, 'result to be undefined').to.not.exist
			++executedChecks

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			done()

	it 'should ignore returned errors on successfull asynchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2

		# Define the error to be used
		errMessage = 'my first error'

		# Perform an error on an asynchronous function
		# by return
		# and never calling the callback
		returnErrorThenCompleteAsync = (x,y,next) ->
			wait delay, ->
				next(null, x*y)
				++executedChecks
			return new Error(errMessage)

		# Test successfull call
		ambi returnErrorThenCompleteAsync, 2, 5, (err,result) ->
			expect(err, 'error to be null').to.eql(null)
			expect(result, 'result to be set').to.eql(10)
			++executedChecks

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			done()

	it 'should ignore returned errors on unsuccessful asynchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2

		# Define the error to be used
		errMessage = 'my first error'
		errMessage2 = 'my second error'

		# Perform an error on an asynchronous function
		# by return
		# and never calling the callback
		returnErrorThenCallbackErrorAsync = (x,y,next) ->
			wait delay, ->
				next(new Error(errMessage2))
				++executedChecks
			return new Error(errMessage)

		# Test unsuccessful error call
		ambi returnErrorThenCallbackErrorAsync, 2, 5, (err,result) ->
			expect(err.message, 'error to be set').to.eql(errMessage2)
			expect(result, 'result to be undefined').to.not.exist
			++executedChecks

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			done()

	it 'should NOT handle thrown errors on unsuccessful synchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2
		neverReached = false

		# Define the error to be used
		errMessage = 'my first error'

		# Perform an error on a synchronous function
		# by throw
		throwErrorSyncUncaught = (x,y) ->
			++executedChecks
			throw new Error(errMessage)

		# Error callback
		catchUncaughtException = (err) ->
			expect(err.message, 'error to be set').to.eql(errMessage)
			++executedChecks

		# Test unsuccessful call
		try
			ambi throwErrorSyncUncaught, 2, 5, (err,result) ->
				# should never reach here
				++executedChecks
				neverReached = true
		catch err
			catchUncaughtException(err)

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			expect(neverReached, 'never reached section should have never been reached').to.eql(false)
			done()

	it 'should NOT handle thrown errors on unsuccessful asynchronous functions', (done) ->
		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2
		neverReached = false

		# Define the error to be used
		errMessage = 'my first error'

		# Perform an error on a synchronous function
		# by throw
		# and never calling the callback
		throwErrorAsyncUncaught = (x,y,next) ->
			++executedChecks
			throw new Error(errMessage)

		# Error callback
		catchUncaughtException = (err) ->
			expect(err.message, 'error to be set').to.eql(errMessage)
			++executedChecks

		# Test unsuccessful call
		try
			ambi throwErrorAsyncUncaught, 2, 5, (err,result) ->
				# should never reach here
				++executedChecks
				neverReached = true
		catch err
			catchUncaughtException(err)

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			expect(neverReached, 'never reached section should have never been reached').to.eql(false)
			done()

	it 'should NOT handle asynchronous thrown errors on unsuccessful asynchronous functions', (done) ->
		# Check node version
		if process.versions.node.substr(0,3) is '0.8'
			console.log 'skip this test on node 0.8 because domains behave differently'
			return done()

		# Define the amount of special checks
		executedChecks = 0
		totalChecks = 2
		neverReached = false

		# Define the error to be used
		errMessage = 'my first error'

		# Perform an error on an asynchronous function
		# by throw inside asynchronous function
		# and still calling the callback with the error
		throwErrorAsyncUncaught = (x,y,next) ->
			wait delay, ->
				++executedChecks
				throw new Error(errMessage)
			return 'async'

		# Error callback
		catchUncaughtException = (err) ->
			expect(err.message, 'error to be set').to.eql(errMessage)
			++executedChecks

		# Test unsuccessful call
		d = require('domain').create()
		d.on('error', catchUncaughtException)
		d.run ->
			try
				ambi throwErrorAsyncUncaught, 2, 5, (err,result) ->
					# should never reach here
					++executedChecks
					neverReached = true
			catch err
				catchUncaughtException(err)

		# Check all the special checks passed
		wait delay*2, ->
			expect(executedChecks, 'special checks were as expected').to.eql(totalChecks)
			expect(neverReached, 'never reached section should have never been reached').to.eql(false)
			done()
