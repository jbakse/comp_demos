additive_demo = (element)->
	# create a canvas and add it to the target element
	canvas = document.createElement 'canvas'
	canvas.width = 768
	canvas.height = 384
	$(element).append canvas

	# grab and store the 2d context of the canvas, this is where we do our drawing
	c = canvas.getContext '2d'


	# plot draws a plot of the function `f` over the domain `start` to `finish`
	# the plot is drawn using the current transformation 
	# https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/Canvas_tutorial/Transformations
	plot = (context, start, end, f)->
		context.beginPath();
		context.moveTo start, f(start)
		for x in [start..end]
			context.lineTo x, f(x) 
		context.stroke()

	# reads the values of the sliders and calls plot to draw three sine waves and a sum of the waves
	drawWaves = ()->
		sliderA = $('#additive-demo-slider-a').val()
		sliderB = $('#additive-demo-slider-b').val()
		sliderC = $('#additive-demo-slider-c').val()

		
		
		# clear the canvas
		c.save()
		c.fillStyle = 'white'
		c.fillRect 0, 0, 768, 384
		c.restore()

		##
		# draw the waves
		c.save()
		c.strokeStyle = 'gray'

		c.translate 0, 60
		plot c, 0, 768,
			(x)->
				Math.sin(x/768 * Math.PI * sliderA) * 24

		c.translate 0, 80
		plot c, 0, 768,
			(x)->
				Math.sin(x/768 * Math.PI * sliderB) * 18

		c.translate 0, 80
		plot c, 0, 768,
			(x)->
				Math.sin(x/768 * Math.PI * sliderC) * 12

		c.strokeStyle = 'red'
		
		c.translate 0, 80
		plot c, 0, 768,
			(x)->
				Math.sin(x/768 * Math.PI * sliderA) * 24 + 
				Math.sin(x/768 * Math.PI * sliderB) * 18 + 
				Math.sin(x/768 * Math.PI * sliderC) * 12

		c.restore()

	#draw the waves once now, and again when the sliders' values change
	drawWaves()
	$('#additive-demo-slider-a, #additive-demo-slider-b, #additive-demo-slider-c').change drawWaves


# kick off the demo
additive_demo $('#additive-demo')