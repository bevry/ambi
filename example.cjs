'use strict'

// Import
const ambi = require('./').default

async function main() {
	// Execute a method that performs synchronously
	function syncMethod(x, y) {
		return x * y
	}
	await ambi(syncMethod, 5, 2).then(console.log) // 10

	// Execute a method that returns a synchronous promise
	function syncPromiseMethod(x, y) {
		return Promise.resolve(x * y)
	}
	await ambi(syncPromiseMethod, 5, 2).then(console.log) // 10

	// Execute a method that returns the result via a competion callback
	function asyncMethod(x, y, next) {
		setTimeout(function () {
			next(null, x * y)
		}, 0)
	}
	await ambi(asyncMethod, 5, 2).then(console.log) // 10

	// Execute a method that returns the promise that resolves asynchronously
	function asyncPromiseMethod(x, y) {
		return new Promise(function (resolve) {
			setTimeout(function () {
				resolve(x * y)
			}, 0)
		})
	}
	await ambi(asyncPromiseMethod, 5, 2).then(console.log) // 10

	// Handle errors that throw
	function throwErrorMethod() {
		throw new Error('thrown error')
	}
	await ambi(throwErrorMethod).catch(console.log) // thrown error

	// Handle errors that return
	function returnErrorMethod() {
		return new Error('return error')
	}
	await ambi(returnErrorMethod).catch(console.log) // return error

	// Handle errors that are first argument to completion callback
	function callbackErrorMethod(next) {
		next(new Error('callback error'))
	}
	await ambi(callbackErrorMethod).catch(console.log) // callback error
}

main()
