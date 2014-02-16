#boiler plate

class World
	constructor: (@element)->
		@width  = @element.clientWidth
		@height = @element.clientHeight
		@aspect = @width / @height 
		
		@scene = new THREE.Scene()

		@camera = new THREE.OrthographicCamera(-.5, .5, -.5 / @aspect  , .5 / @aspect , 1, 1000)
		@camera.position.z = 5
		@scene.add @camera

		@renderer = new THREE.WebGLRenderer()
		# @renderer.antialias = true
		@renderer.setClearColor 0xFFFFFF, 1
		@renderer.setSize @element.clientWidth, @element.clientHeight
		@element.appendChild @renderer.domElement
		
	update: false

	_render_loop: ()->
		requestAnimationFrame ()=> @_render_loop()
		@update?()
		@renderer.render @scene, @camera

	start: ()->
		@_render_loop()
		this

class CanvasLayer
	constructor: (@world)->

		canvas = document.createElement 'canvas' 
		canvas.width = 512
		canvas.height = 256


		@_canvasTexture = new THREE.Texture(canvas) 
		@_canvasTexture.needsUpdate = true


		canvasMaterial = new THREE.MeshBasicMaterial
			map: @_canvasTexture

		planeGeometry = new THREE.PlaneGeometry 1, 1 / @world.aspect 
		mesh = new THREE.Mesh planeGeometry, canvasMaterial 
		mesh.rotation.x = Math.PI
		@world.scene.add mesh

		@context = canvas.getContext '2d'

	update: ()->
		@_canvasTexture.needsUpdate = true;

	blank: (color)->
		@context.beginPath();
		@context.rect(0, 0, 512, 512);
		@context.fillStyle = color;
		@context.fill();


sin_demo = ()->
	world = new World(document.getElementById("sin-demo")).start()
	layer = new CanvasLayer world


	plot = (context, start, end, f)->
		context.beginPath();
		context.moveTo 0, 0
		for x in [start..end]
			context.lineTo x, f(x) 
		context.stroke()


	drawWaves = ()->
		
		sliderA = document.getElementById("sin-demo-slider-A").value
		sliderB = document.getElementById("sin-demo-slider-B").value
		sliderC = document.getElementById("sin-demo-slider-C").value

		c = layer.context

		c.save()

		c.strokeStyle = 'white'

		c.translate 0, 32
		plot c, 0, 512, (x)->
			Math.sin(x/512 * Math.PI * sliderA) * 24

		c.translate 0, 64
		plot c, 0, 512, (x)->
			Math.sin(x/512 * Math.PI * sliderB) * 18

		c.translate 0, 64
		plot c, 0, 512, (x)->
			Math.sin(x/512 * Math.PI * sliderC) * 12


		c.strokeStyle = 'red'

		c.translate 0, 64
		plot c, 0, 512, (x)->
			 Math.sin(x/512 * Math.PI * sliderA) * 10 + 
			 Math.sin(x/512 * Math.PI * sliderB) * 7.5 + 
			 Math.sin(x/512 * Math.PI * sliderC) * 5

		c.restore()


	world.update = ()->
		layer.blank "black"
		drawWaves()
		layer.update()

sin_demo()


morie_demo = ()->
	world = new World(document.getElementById("morie-demo")).start()
	
	blueMaterial = new THREE.MeshBasicMaterial
		color: 0x0000ff
		side: THREE.DoubleSide

	redMaterial = new THREE.MeshBasicMaterial
		color: 0xff0000
		side: THREE.DoubleSide

	circleGeometry = new THREE.CircleGeometry( .01, 32 );				
	
	blueCircles = []
	redCircles = []
	rows = 20
	cols = 40
	
	for i in [0..(rows * cols - 1)]
		circle = new THREE.Mesh( circleGeometry, blueMaterial );
		circle.row = Math.floor(i/cols)
		circle.col = i%cols
		world.scene.add( circle );
		blueCircles.push circle

	for i in [0..(rows * cols - 1)]
		circle = new THREE.Mesh( circleGeometry, redMaterial );
		circle.row = Math.floor(i/cols)
		circle.col = i%cols
		world.scene.add( circle );
		redCircles.push circle

	spacing = .025

	world.update = ()->
		sliderA = document.getElementById("morie-demo-slider-A").value / 100.0
		
		if document.getElementById("morie-demo-color").checked
			blueMaterial.color = new THREE.Color( 0x0000FF )
			redMaterial.color = new THREE.Color( 0xFF0000 )
		else
			blueMaterial.color = new THREE.Color( 0x000000 )
			redMaterial.color = new THREE.Color( 0x000000 )

		redMaterial.needsUpdate = true
		blueMaterial.needsUpdate = true

		for circle in blueCircles
			circle.position.x = -.5 + circle.col * spacing * (sliderA + 1)
			circle.position.y = -.25 + circle.row * spacing * (sliderA + 1)

		for circle in redCircles
			circle.position.x = -.5 + circle.col * spacing * (0 + 1)
			circle.position.y = -.25 + circle.row * spacing * (0 + 1)

morie_demo()