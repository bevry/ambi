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
	it 'should handle success on synchronous functions', (done) ->
		# Perform multiply on a synchronous function
		# by returning the result
		multiplySync = (x,y) ->
			return x*y

		# Test successful call
		ambi multiplySync, 2, 5, (err,result) ->
			expect(err, 'error to be empty').to.eql(null)
			expect(result, 'result to to be as expected').to.eql(10)
			done()

	it 'should handle success on asynchronous functions', (done) ->
		# Perform multiply on an asynchronous function
		# by callbacking the result
		multiplyAsync = (x,y,next) ->
			wait delay, -> next(null, x*y)
			return 'async'

		# Test successful call
		ambi multiplyAsync, 2, 5, (err,result) ->
			expect(err, 'error to be empty').to.eql(null)
			expect(result, 'result to to be as expected').to.eql(10)
			done()

	it 'should handle errord callbacks on asynchronous functions', (done) ->
		# Prepare that we have special checks
		checks = 0

		# Perform an error on an asynchronous function
		# by callbacking the error
		callbackErrorAsync = (x,y,next) ->
			wait delay, ->
				err = new Error('my first error')
				next(err)
				++checks
			return 'async'

		# Test successful error call
		ambi callbackErrorAsync, 2, 5, (err,result) ->
			expect(err.message, 'error to be set').to.eql('my first error')
			expect(result, 'result to not exist').to.not.exist
			++checks

		# Check that all special checks passed
		wait delay*2, ->
			expect(checks, "all our special checks ran in the correct timeframe").to.eql(2)
			done()

	it 'should handle duplicated callbacks on asynchronous functions', ->
		# Prepare that we have special checks
		checks = 0

		# Perform multiply on an asynchronous function
		# by callbacking the result
		# twice
		multiplyAsyncDupe = (x,y,next) ->
			next(null, x*y)
			++checks

			next(null, x*y)
			++checks  # will never hit due to the throw in the above line due to ambi

			return 'async'

		# Prepare
		errorHandler = (err) ->
			expect(err.message, 'ambi detected the duplicate call to the callback and threw the correct error message').to.eql("a completion callback has fired twice which is unexpected behaviour")
			++checks
		execHandler = ->
			try
				ambi multiplyAsyncDupe, 2, 5, (err,result) ->
					expect(err, 'error to be empty').to.eql(null)
					expect(result, 'result to to be as expected').to.eql(10)
					++checks
			catch err
				errorHandler(err)

		# Test unsuccessful call
		d = require('domain').create()
		d.on('error', errorHandler)
		d.run(execHandler)

		# Check that all special checks passed
		expect(checks, "all our special checks ran in the correct timeframe").to.eql(3)

	# Perform an error on an asynchronous function
	# by callbacking the error
	callbackErrorAsyncDupe = (x,y,next) ->
		result = x*y
		setTimeout(
			->
				err = new Error('my first error')
				return next?(err)
			10
		)
		return next(x*y)

	# Perform an error on a synchronous function
	# by returning the result
	returnErrorSync = (x,y) ->
		err = new Error('my first error')
		return err

	# Perform an error on an asynchronous function
	# by returning the result
	# and never calling the callback
	returnErrorAsync = (x,y,next) ->
		err = new Error('my first error')
		return err

	# Perform an error on an asynchronous function
	# by returning the result
	# and still calling the callback with the error
	returnErrorAsyncDupe = (x,y,next) ->
		err = new Error('my first error')
		setTimeout(
			-> return next(err)
			10
		)
		return err

	# Perform an error on an asynchronous function
	# by returning the result
	# and still calling the callback with a result
	returnErrorAsyncDupeSuccess = (x,y,next) ->
		err = new Error('my first error')
		setTimeout(
			-> return next(null, x*y)
			10
		)
		return err

	# Perform an error on a synchronous function
	# by returning the result
	returnErrorSync = (x,y) ->
		err = new Error('my first error')
		return err

	# Perform an error on an asynchronous function
	# by returning the result
	# and never calling the callback
	returnErrorAsync = (x,y,next) ->
		err = new Error('my first error')
		return err

	# Perform an error on an asynchronous function
	# by returning the result
	# and still calling the callback with the error
	returnErrorAsyncDupe = (x,y,next) ->
		err = new Error('my first error')
		setTimeout(
			-> return next(err)
			10
		)
		return err

	# Perform an error on an asynchronous function
	# by returning the result
	# and still calling the callback with a result
	returnErrorAsyncDupeSuccess = (x,y,next) ->
		err = new Error('my first error')
		setTimeout(
			-> return next(null, x*y)
			10
		)
		return err
