shaping_two_demo = (element)->
	# create a canvas and add it to the target element
	canvas = document.createElement 'canvas'
	canvas.width = 768
	canvas.height = 384
	$(element).append canvas

	# grab and store the 2d context of the canvas, this is where we do our drawing
	c = canvas.getContext '2d'


	# plot
	# draws a plot of the function `f` over the domain `start` to `finish`
	# draws a plot of the function `f` filtered by the funciton `shapeF`
	# draws rules at 0, -1, and 1
	plot = (context, start, end, scale, f, shapeF = (x)->x)->
		c.save()
		try
			# center line
			c.strokeStyle = '#DDD'
			context.beginPath();
			context.moveTo start, 0
			context.lineTo end, 0
			context.stroke()

			# high line
			c.strokeStyle = '#DDF'
			context.beginPath();
			context.moveTo start, -scale
			context.lineTo end, -scale
			context.stroke()

			# low line
			c.strokeStyle = '#DDF'
			context.beginPath();
			context.moveTo start, scale
			context.lineTo end, scale
			context.stroke()

			# unfiltered
			c.strokeStyle = '#DDD'
			context.beginPath();
			context.moveTo start, f(start)
			for x in [start..end]
				context.lineTo x, f(x) * scale
			context.stroke()

			#filtered
			c.strokeStyle = '#333'
			context.beginPath();
			context.moveTo start, f(start)
			for x in [start..end]
				context.lineTo x, shapeF(f(x)) * scale
			context.stroke()
		catch error
			console.log error
		finally
			c.restore()

	

	# drawWaves
	# reads the values of the sliders, builds the filter function, and calls plot to draw three filtered signals
	drawWaves = ()->
			
		# clear the canvas
		c.save()
		c.fillStyle = 'white'
		c.fillRect 0, 0, 768, 768
		c.restore()


		##
		# create the shaping filter
		generatorInput = $('#shaping-two-demo-generator').val()
		filterInput = $('#shaping-two-demo-filter').val()

		generatorWorks = true
		fitlerWorks = true
		try
			eval """generator = function(x){return (#{generatorInput});}"""
			generator(1)
		catch error
			generatorWorks = false
			console.log error

		try
			eval """filter = function(x){return (#{filterInput});}"""
			filter(1)
		catch error
			fitlerWorks = false
			console.log error	

		$('#shaping-two-demo-generator').toggleClass "error", !generatorWorks
		$('#shaping-two-demo-filter').toggleClass "error", !fitlerWorks


		##
		# draw the shaped waves
		c.save()
		c.strokeStyle = '#333'

		# sin
		c.translate 0, 192
		plot c, 0, 768, -150, generator, filter
		


		# restore the context attributes
		c.restore()

	#draw the waves once now, and again when the sliders' values change
	drawWaves()
	$('#shaping-two-demo-generator, #shaping-two-demo-filter').keyup drawWaves


# kick off the demo
shaping_two_demo $('#shaping-two-demo')