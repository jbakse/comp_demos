additive_demo = (element)->
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
		preamp = $('#shaping-demo-slider-preamp').val() / 100.0
		bias = $('#shaping-demo-slider-bias').val() / 100.0
		exponent = $('#shaping-demo-slider-exponent').val() / 100.0
		min = $('#shaping-demo-slider-min').val() / 100.0
		max = $('#shaping-demo-slider-max').val() / 100.0
		postamp = $('#shaping-demo-slider-postamp').val() / 100.0
		abs = $('#shaping-demo-slider-abs').is(":checked")

		filter = (x)->
			x = x * preamp
			x = x + bias

			sign = if (x > 0) then 1 else -1
			x = Math.pow(Math.abs(x), exponent) * sign
			
			x = Math.max(x, min)
			x = Math.min(x, max)
			x = x * postamp

			if abs then x = Math.abs(x)

			return x


		##
		# draw the shaped waves
		c.save()
		c.strokeStyle = '#333'

		# sin
		c.translate 0, 64
		plot c, 0, 768, -48, 
			(x) ->
				Math.sin(x/768 * Math.PI * 6) * 1
			filter

		# sawtooth
		c.translate 0, 128
		plot c, 0, 768, -48, 
			(x) -> 
				(x / 64) % 2 - 1
			filter
		
		# sum of sins
		c.translate 0, 128
		plot c, 0, 768, -48, 
			(x) ->
				Math.sin(x/768 * Math.PI * 20 * .5) * .65 + 
				Math.sin(x/768 * Math.PI * 27 * .5) * .3 + 
				Math.sin(x/768 * Math.PI * 51 * .5) * .15
			filter


		# restore the context attributes
		c.restore()

	#draw the waves once now, and again when the sliders' values change
	drawWaves()
	$('#shaping-demo-slider-preamp,
		#shaping-demo-slider-bias,
		#shaping-demo-slider-exponent,
		#shaping-demo-slider-min,
		#shaping-demo-slider-max,
		#shaping-demo-slider-postamp,
		#shaping-demo-slider-abs').change drawWaves


# kick off the demo
additive_demo $('#shaping-demo')