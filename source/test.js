'use strict'

// The below eslint rules are disabled as they are more around how our tests are formatted
/* eslint no-magic-numbers:0, no-unused-vars:0, handle-callback-err:0, no-console:0, prefer-rest-params:0 */

// Import
const { equal } = require('assert-helpers')
const kava = require('kava')
const ambi = require('./')

// Prepare
function wait(delay, fn) {
	return setTimeout(fn, delay)
}
const delay = 100

// =====================================
// Tests

kava.describe('ambi', function (describe, it) {
	it('should handle result on successful synchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Perform multiply on a synchronous function
		// by return
		function multiplySync(x, y) {
			equal(arguments.length, 2, 'arguments length')
			++executedChecks
			return x * y
		}

		// Test successful call
		ambi(multiplySync, 2, 5).then(function (result) {
			equal(result, 10, 'result to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle result on successful promise returning functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Perform multiply on an asynchronous function
		// returning a promise
		function multiplyAsync(x, y) {
			return new Promise(function (resolve, reject) {
				wait(delay, function () {
					++executedChecks
					resolve(x * y)
				})
			})
		}

		// Test successful call
		ambi(multiplyAsync, 2, 5).then(function (result) {
			equal(result, 10, 'result to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle result on successful asynchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Perform multiply on an asynchronous function
		// by callback
		function multiplyAsync(x, y, next) {
			wait(delay, function () {
				next(null, x * y)
				++executedChecks
			})
			return 'async'
		}

		// Test successful call
		ambi(multiplyAsync, 2, 5).then(function (result) {
			equal(result, 10, 'result to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle result on successful asynchronous function with optional arguments', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Perform multiply on an asynchronous function
		// by callback
		function multiplyAsync(x, y, next) {
			equal(typeof x, 'undefined', 'x to be undefined')
			equal(typeof y, 'undefined', 'y to be undefined')
			x = x || 3
			y = y || 5
			wait(delay, function () {
				next(null, x * y)
				++executedChecks
			})
			return 'async'
		}

		// Test successful call
		ambi(multiplyAsync).then(function (result) {
			equal(result, 15, 'result to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle returned errors on unsuccessful synchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on a synchronous function
		// by return
		function returnErrorSync(x, y) {
			++executedChecks
			return new Error(errMessage)
		}

		// Test unsuccessful call
		ambi(returnErrorSync, 2, 5).catch(function (err) {
			equal(err.message, errMessage, 'error to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle returned errors on unsuccessful promise returning functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on a synchronous function
		// by return
		function returnErrorPromise(x, y) {
			++executedChecks
			return Promise.reject(new Error(errMessage))
		}

		// Test unsuccessful call
		ambi(returnErrorPromise, 2, 5).catch(function (err) {
			equal(err.message, errMessage, 'error to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle callbacked errors on unsuccessful asynchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on an asynchronous function
		// by callback
		function callbackErrorAsync(x, y, next) {
			wait(delay, function () {
				next(new Error(errMessage))
				++executedChecks
			})
			return 'async'
		}

		// Test unsuccessful call
		ambi(callbackErrorAsync, 2, 5).catch(function (err) {
			equal(err.message, errMessage, 'error to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should ignore returned errors on successfull asynchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on an asynchronous function
		// by return
		// and never calling the callback
		function returnErrorThenCompleteAsync(x, y, next) {
			wait(delay, function () {
				next(null, x * y)
				++executedChecks
			})
			return new Error(errMessage)
		}

		// Test successfull call
		ambi(returnErrorThenCompleteAsync, 2, 5).then(function (result) {
			equal(result, 10, 'result to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should ignore returned errors on unsuccessful asynchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2

		// Define the error to be used
		const errMessage = 'my first error'
		const errMessage2 = 'my second error'

		// Perform an error on an asynchronous function
		// by return
		// and never calling the callback
		function returnErrorThenCallbackErrorAsync(x, y, next) {
			wait(delay, function () {
				next(new Error(errMessage2))
				++executedChecks
			})
			return new Error(errMessage)
		}

		// Test unsuccessful error call
		ambi(returnErrorThenCallbackErrorAsync, 2, 5).catch(function (err) {
			equal(err.message, errMessage2, 'error to be set')
			++executedChecks
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			done()
		})
	})

	it('should handle thrown errors on unsuccessful synchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2
		let neverReached = false

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on a synchronous function
		// by throw
		function throwErrorSyncUncaught(x, y) {
			++executedChecks
			throw new Error(errMessage)
		}

		// Test unsuccessful call
		ambi(throwErrorSyncUncaught, 2, 5)
			.then(function () {
				++executedChecks
				neverReached = true
			})
			.catch(function (err) {
				equal(err.message, errMessage, 'error to be set')
				++executedChecks
			})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			equal(
				neverReached,
				false,
				'never reached section should have never been reached'
			)
			done()
		})
	})

	it('should handle thrown errors on unsuccessful asynchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2
		let neverReached = false

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on a synchronous function
		// by throw
		// and never calling the callback
		function throwErrorAsyncUncaught(x, y, next) {
			++executedChecks
			throw new Error(errMessage)
		}

		// Test unsuccessful call
		ambi(throwErrorAsyncUncaught, 2, 5)
			.then(function () {
				++executedChecks
				neverReached = true
			})
			.catch(function (err) {
				equal(err.message, errMessage, 'error to be set')
				++executedChecks
			})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			equal(
				neverReached,
				false,
				'never reached section should have never been reached'
			)
			done()
		})
	})

	it('should NOT handle asynchronous thrown errors on unsuccessful promise returning functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2
		let neverReached = false

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on an asynchronous function
		// by throw inside asynchronous function
		// and still calling the callback with the error
		function throwErrorPromiseUncaught(x, y) {
			return new Promise(function (resolve, reject) {
				wait(delay, function () {
					++executedChecks
					throw new Error(errMessage)
				})
			})
		}

		// Error callback
		function catchUncaughtException(err) {
			equal(err.message, errMessage, 'error to be set')
			++executedChecks
		}

		// Test unsuccessful call
		const d = require('domain').create()
		d.on('error', catchUncaughtException)
		d.run(function () {
			ambi(throwErrorPromiseUncaught, 2, 5)
				.then(function (result) {
					// should never reach here
					++executedChecks
					neverReached = true
				})
				.catch(function (err) {
					// should never reach here
					++executedChecks
					neverReached = true
				})
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			equal(
				neverReached,
				false,
				'never reached section should have never been reached'
			)
			done()
		})
	})

	it('should NOT handle asynchronous thrown errors on unsuccessful asynchronous functions', function (done) {
		// Define the amount of special checks
		let executedChecks = 0
		const totalChecks = 2
		let neverReached = false

		// Define the error to be used
		const errMessage = 'my first error'

		// Perform an error on an asynchronous function
		// by throw inside asynchronous function
		// and still calling the callback with the error
		function throwErrorAsyncUncaught(x, y, next) {
			wait(delay, function () {
				++executedChecks
				throw new Error(errMessage)
			})
			return 'async'
		}

		// Error callback
		function catchUncaughtException(err) {
			equal(err.message, errMessage, 'error to be set')
			++executedChecks
		}

		// Test unsuccessful call
		const d = require('domain').create()
		d.on('error', catchUncaughtException)
		d.run(function () {
			ambi(throwErrorAsyncUncaught, 2, 5)
				.then(function (result) {
					// should never reach here
					++executedChecks
					neverReached = true
				})
				.catch(function (err) {
					// should never reach here
					++executedChecks
					neverReached = true
				})
		})

		// Check all the special checks passed
		wait(delay * 2, function () {
			equal(executedChecks, totalChecks, 'special checks were as expected')
			equal(
				neverReached,
				false,
				'never reached section should have never been reached'
			)
			done()
		})
	})
})
