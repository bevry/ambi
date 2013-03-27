# Import
{expect} = require('chai')
joe = require('joe')
ambi = require('../lib/ambi')


# =====================================
# Tests

joe.describe 'ambi', (describe,it) ->
	# Prepare
	syncMethod = (x,y) ->
		return x*y
	asyncMethod = (x,y,next) ->
		setTimeout(
			-> return next?(null,x*y)
			0
		)
		return 'async'
	syncErrorMethod = (x,y) ->
		throw new Error('my error')
	asyncErrorMethod = (x,y,next) ->
		setTimeout(
			-> next?(new Error('my error'))
			0
		)
		return 'async'

	describe 'async normalization', (describe,it) ->
		it 'should work with the sync method', (done) ->
			r = ambi syncMethod, 5, 2, (err,result) ->
				expect(err).to.not.exist
				expect(result).to.eql(10)
				done()
			expect(r).to.eql(10)

		it 'should work with the async method', (done) ->
			r = ambi asyncMethod, 5, 2, (err,result) ->
				expect(err).to.not.exist
				expect(result).to.eql(10)
				done()
			expect(r).to.eql('async')

	describe 'sync normalization', (describe,it) ->
		it 'should work with the sync method', ->
			r = ambi syncMethod, 5, 2
			expect(r).to.eql(10)

		it 'should work with the async method', ->
			r = ambi asyncMethod, 5, 2
			expect(r).to.eql('async')

	describe 'error async normalization', (describe,it) ->
		it 'should work with the sync error method', (done) ->
			r = ambi syncErrorMethod, 5, 2, (err,result) ->
				expect(err.message).to.eql('my error')
				expect(result).to.not.exist
				done()
			expect(r.message).to.eql('my error')

		it 'should work with the async error method', (done) ->
			r = ambi asyncErrorMethod, 5, 2, (err,result) ->
				expect(err.message).to.eql('my error')
				expect(result).to.not.exist
				done()
			expect(r).to.eql('async')

	describe 'error sync normalization', (describe,it) ->
		it 'should work with the sync error method', ->
			r = ambi syncErrorMethod, 5, 2
			expect(r.message).to.eql('my error')

		it 'should work with the async error method', ->
			r = ambi asyncErrorMethod, 5, 2
			expect(r).to.eql('async')
			# no way to catch this error
