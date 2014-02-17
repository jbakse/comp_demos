#boiler plate

class World
	constructor: (@element)->
		@width  = @element.clientWidth
		@height = @element.clientHeight
		@aspect = @width / @height 
		
		@scene = new THREE.Scene()

		@camera = new THREE.OrthographicCamera(-.5, .5, -.5 / @aspect  , .5 / @aspect , 1, 1000)
		# @camera = new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.1, 1000 );

		@camera.position.z = 5
		@scene.add @camera

		@renderer = new THREE.WebGLRenderer()
		# @renderer.antialias = true
		@renderer.setClearColor 0xFFFFFF, 1
		@renderer.setSize @element.clientWidth, @element.clientHeight
		@element.appendChild @renderer.domElement
		
	update: false

	composer: false

	_render_loop: ()->
		requestAnimationFrame ()=> @_render_loop()
		@update?()
		# console.log @composer
		if @composer != false
			# console.log "c"
			@composer.render()
		else
			# console.log "r"
			# @renderer.clear();
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


# sin_demo = ()->
# 	world = new World(document.getElementById('sin-demo')).start()
# 	layer = new CanvasLayer world


# 	plot = (context, start, end, f)->
# 		context.beginPath();
# 		context.moveTo 0, 0
# 		for x in [start..end]
# 			context.lineTo x, f(x) 
# 		context.stroke()


# 	drawWaves = ()->
		
# 		sliderA = document.getElementById('sin-demo-slider-A').value
# 		sliderB = document.getElementById('sin-demo-slider-B').value
# 		sliderC = document.getElementById('sin-demo-slider-C').value

# 		c = layer.context

# 		c.save()

# 		c.strokeStyle = 'white'

# 		c.translate 0, 32
# 		plot c, 0, 512, (x)->
# 			Math.sin(x/512 * Math.PI * sliderA) * 24

# 		c.translate 0, 64
# 		plot c, 0, 512, (x)->
# 			Math.sin(x/512 * Math.PI * sliderB) * 18

# 		c.translate 0, 64
# 		plot c, 0, 512, (x)->
# 			Math.sin(x/512 * Math.PI * sliderC) * 12


# 		c.strokeStyle = 'red'

# 		c.translate 0, 64
# 		plot c, 0, 512, (x)->
# 			 Math.sin(x/512 * Math.PI * sliderA) * 10 + 
# 			 Math.sin(x/512 * Math.PI * sliderB) * 7.5 + 
# 			 Math.sin(x/512 * Math.PI * sliderC) * 5

# 		c.restore()


# 	world.update = ()->
# 		layer.blank 'black'
# 		drawWaves()
# 		layer.update()

# sin_demo()


# morie_demo = ()->
# 	world = new World(document.getElementById('morie-demo')).start()
	
# 	circleBlur = THREE.ImageUtils.loadTexture 'images/circle_blur_64.png'
# 	white = THREE.ImageUtils.loadTexture 'images/white_64.png'

# 	blurMaterial = new THREE.MeshBasicMaterial
# 		map: circleBlur
# 		side: THREE.DoubleSide
# 		transparent: true
# 		blending: THREE.MultiplyBlending

# 	blueMaterial = new THREE.MeshBasicMaterial
# 		map: white
# 		color: 0x0000ff
# 		side: THREE.DoubleSide
# 		transparent: true
# 		blending: THREE.MultiplyBlending

# 	redMaterial = new THREE.MeshBasicMaterial
# 		map: white
# 		color: 0xff0000
# 		side: THREE.DoubleSide
# 		transparent: true
# 		blending: THREE.MultiplyBlending

# 	blackMaterial = new THREE.MeshBasicMaterial
# 		map: white
# 		color: 0x000000
# 		side: THREE.DoubleSide

# 	circleGeometry = new THREE.CircleGeometry( 1, 32 );				
	
# 	groupA = new THREE.Object3D()
# 	groupA.scale.set(.01, .01, .01);
# 	world.scene.add groupA

# 	groupB = new THREE.Object3D()
# 	groupB.scale.set(.01, .01, .01);
# 	world.scene.add groupB


	


# 	rows = 30
# 	cols = 50
# 	spacing = 2.5
	
# 	for i in [0..(rows * cols - 1)]
# 		circle = new THREE.Mesh( circleGeometry, blurMaterial );
# 		row = Math.floor(i/cols) - rows * .5
# 		col = i%cols - cols * .5
# 		circle.position.x = col * spacing 
# 		circle.position.y = row * spacing 
# 		groupA.add circle

# 	for i in [0..(rows * cols - 1)]
# 		circle = new THREE.Mesh( circleGeometry, blurMaterial );
# 		row = Math.floor(i/cols) - rows * .5
# 		col = i%cols - cols * .5
# 		circle.position.x = col * spacing 
# 		circle.position.y = row * spacing
# 		circle.position.z = 1;
# 		groupB.add circle

	

# 	world.update = ()->
# 		sliderA = document.getElementById('morie-demo-slider-A').value / 100.0
# 		sliderZoom = 1 + (document.getElementById('morie-demo-slider-Zoom').value / 100.0) * 6
# 		material = document.getElementById('morie-demo-material').value
# 		switch material
# 			when "black"
# 				for circle in groupA.children
# 					circle.material = blackMaterial
# 				for circle in groupB.children
# 					circle.material = blackMaterial

# 			when "color"
# 				for circle in groupA.children
# 					circle.material = redMaterial
# 				for circle in groupB.children
# 					circle.material = blueMaterial

# 			when "blur"
# 				for circle in groupA.children
# 					circle.material = blurMaterial
# 				for circle in groupB.children
# 					circle.material = blurMaterial

# 		groupA.rotation.z = sliderA * .25;
# 		scale = (.01 + sliderA * .005) * sliderZoom
# 		groupA.scale.set(scale, scale, scale)
# 		groupA.position.set(sliderZoom * .1, sliderZoom * .1, 0)

# 		scale = .01 * sliderZoom
# 		groupB.scale.set(scale, scale, scale)
# 		groupB.position.set(sliderZoom * .1, sliderZoom * .1, 0)



# morie_demo()



# noise_demo = ()->
# 	world = new World(document.getElementById('noise-demo')).start()
# 	layer = new CanvasLayer world
# 	imageData = layer.context.createImageData(512,256);
# 	pixels = imageData.data;
# 	simplex = new SimplexNoise()
# 	octaves = 1;
# 	falloff = 1;

# 	$('#noise-demo-slider-octaves').mouseup ()->
# 		octaves = $('#noise-demo-slider-octaves').val()
# 		drawNoise(octaves, falloff)

# 	$('#noise-demo-slider-falloff').mouseup ()->
# 		falloff = $('#noise-demo-slider-falloff').val() / 100
# 		drawNoise(octaves, falloff)

# 	noise = (x, y, octaves = 1, falloff = 1)->
# 		n = 0
# 		for octave in [1..octaves]
# 			n += simplex.noise(x * octave, y * octave) * Math.pow(falloff, octave)
# 		return Math.max(Math.min(1, n), 0)

	
# 	drawNoise = (octaves, falloff)->
# 		scale = 5 / 255
# 		for y in [0..255]
# 			for x in [0..511]
# 				pixels[(y * 512 + x) * 4 + 0]   = noise(x * scale, y * scale, octaves, falloff) * 255;
# 				pixels[(y * 512 + x) * 4 + 1]   = noise(x * scale, y * scale, octaves, falloff) * 255;
# 				pixels[(y * 512 + x) * 4 + 2]   = noise(x * scale, y * scale, octaves, falloff) * 255;
# 				pixels[(y * 512 + x) * 4 + 3]   = 255;

# 		layer.context.putImageData( imageData, 0, 0 );  
# 		layer.update()

# 	world.update = ()->
		

# 	drawNoise(octaves, falloff);
# noise_demo()




# three_demo = ()->
# 	element = document.getElementById('three-demo')
# 	width  = element.clientWidth
# 	height = element.clientHeight
# 	aspect = width / height 
	
# 	scene = new THREE.Scene()

# 	camera = new THREE.OrthographicCamera(-.5, .5, -.5 / aspect  , .5 / aspect , 1, 1000)
# 	camera.position.z = 5
# 	scene.add camera

# 	renderer = new THREE.WebGLRenderer()
# 	renderer.setClearColor 0xFFFFFF, 1
# 	renderer.setSize element.clientWidth, element.clientHeight
# 	element.appendChild renderer.domElement



# 	rtScene = new THREE.Scene()
# 	rtCamera = new THREE.OrthographicCamera(-.5, .5, -.5 / aspect  , .5 / aspect , 1, 1000)
# 	rtCamera.position.z = 5
# 	rtScene.add rtCamera
# 	rtTexture = new THREE.WebGLRenderTarget 512, 256, {
# 		minFilter: THREE.LinearFilter
# 		magFilter: THREE.NearestFilter
# 		format: THREE.RGBFormat
# 	}


# 	rtCubeTexture = THREE.ImageUtils.loadTexture 'images/circle_64.png'
# 	rtCubeMaterial = new THREE.MeshBasicMaterial
# 		map: rtCubeTexture
# 		color: 0xffffff
# 		side: THREE.DoubleSide
	
# 	rtCubeGeometry = new THREE.CubeGeometry(1, 1, 1);
# 	rtCube = new THREE.Mesh rtCubeGeometry, rtCubeMaterial
# 	rtCube.position.x = .25
# 	rtCube.rotation.x = 1
# 	rtCube.rotation.y = 1
# 	rtCube.scale.x = .1
# 	rtCube.scale.y = .1
# 	rtCube.scale.z = .1
# 	rtScene.add rtCube







# 	cubeTexture = THREE.ImageUtils.loadTexture 'images/circle_64.png'
# 	cubeMaterial = new THREE.MeshBasicMaterial
# 		map: rtTexture
# 		color: 0xffffff
# 		side: THREE.DoubleSide
	
# 	cubeGeometry = new THREE.CubeGeometry(1, 1, 1);
# 	cube = new THREE.Mesh cubeGeometry, cubeMaterial
# 	cube.position.x = -.25
# 	cube.rotation.x = 1
# 	cube.rotation.y = 1
# 	cube.scale.x = .1
# 	cube.scale.y = .1
# 	cube.scale.z = .1
# 	scene.add cube


	





# 	_render_loop = ()->
# 		requestAnimationFrame ()=> _render_loop()
		
# 		cube.rotation.x += .01
# 		rtCube.rotation.x += .01

# 		renderer.clear();
# 		renderer.render( rtScene, rtCamera, rtTexture, true );
# 		renderer.render scene, camera

# 	_render_loop()



# three_demo()

shaping_demo = ()->
	world = new World(document.getElementById('shaping-demo')).start()
	
	# setup render texture (rt) 
	rtScene = new THREE.Scene()
	rtCamera = new THREE.OrthographicCamera(-.5, .5, -.5  , .5  , 1, 1000)
	rtCamera.position.z = 5
	rtScene.add rtCamera
	rtTexture = new THREE.WebGLRenderTarget 512, 512, {
		minFilter: THREE.LinearFilter
		magFilter: THREE.NearestFilter
		format: THREE.RGBFormat
	}


	# set up world geom
	colorRamp = THREE.ImageUtils.loadTexture 'images/island_ramp_256.png'
	

	material2 = new THREE.MeshBasicMaterial
		color: 0xffffff
		side: THREE.DoubleSide
		map: rtTexture

	islandMaterial = new THREE.ShaderMaterial

		side: THREE.DoubleSide

		uniforms:
			"tex": { type: "t", value: null }

		vertexShader:
			"""
			uniform sampler2D tex;
			varying vec2 vUv;
			void main() {
				vUv = uv;
				vec4 texel = texture2D( tex, vUv );

				vec3 p = position;
				p.z += texel.r * .1;

				gl_Position = projectionMatrix * modelViewMatrix * vec4( p, 1.0 );
			}
			"""

		fragmentShader:
			"""
			uniform sampler2D tex;

			varying vec2 vUv;

			void main() {
				vec4 texel = texture2D( tex, vUv );
				
				texel.a = 1.0;
				gl_FragColor = texel;
			}
			"""

	islandMaterial.uniforms.tex.value = rtTexture;

	planeGeometry = new THREE.PlaneGeometry( 1, 1, 100, 100);
	plane = new THREE.Mesh( planeGeometry, islandMaterial );
	plane.scale.set(.5, .5, .5)
	plane.position.x = .25
	plane.rotation.x = Math.PI * -.6
	# plane.rotation.z = Math.PI * -.4;
	# plane.rotation.x = Math.PI * -.6;
	world.scene.add plane


	



	


	ExponentShader = 
		uniforms: 
			"tDiffuse": { type: "t", value: null }
			"ramp": { type: "t", value: null }
			"exponent": { type:"f", value: 1.0 }
			"thresholdMin": { type:"f", value: 0.0 }
			"thresholdMax": { type:"f", value: 1.0 }
			"modLevel": { type:"f", value: 1.01 }
			"rampLevel": { type:"f", value: 1.01 }

		vertexShader:
			"""
			varying vec2 vUv;
			void main() {
				vUv = uv;
				gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
			}
			"""

		fragmentShader:
			"""
			uniform sampler2D tDiffuse;
			uniform sampler2D ramp;
			uniform float exponent;
			uniform float thresholdMin;
			uniform float thresholdMax;
			uniform float modLevel;
			uniform float rampLevel;

			varying vec2 vUv;

			void main() {
				vec4 texel = texture2D( tDiffuse, vUv );
				vec4 o = pow( clamp(texel, 0.0 , 1.0), vec4(exponent, exponent, exponent, exponent) );
  				o = mod( o, vec4(modLevel, modLevel, modLevel, modLevel)) / modLevel;
  				//o = sin( o * vec4(3.14159 * rings, 3.14159 * rings, 3.14159 * rings, 3.14159 * rings)) * .5 + .5;
				
  				//make anything under thresholdMin 0.0
				o = step(vec4(thresholdMin, thresholdMin, thresholdMin, thresholdMin), o) * o;
				o += vec4(.1, .1, .1, .1);

				// make anything over threshold max 1.0
				o = o + step(  vec4(thresholdMax, thresholdMax, thresholdMax, thresholdMax), o );
  				o = min( vec4(1.0, 1.0, 1.0, 1.0), o );
  				

  				

  				// use the color lookup table to colorize the result
				o = texture2D( ramp, vec2(o.r, .95 - rampLevel));

				o = clamp(o, 0.0 , 1.0);
				o.a = 1.0;
				
				gl_FragColor = o;
			}
			"""

	# composer = new THREE.EffectComposer( world.renderer, rtTexture );
	# composer.addPass( new THREE.RenderPass( world.scene, world.camera ) );

	# effect = new THREE.ShaderPass( ExponentShader );
	# effect.uniforms['ramp'].value = colorRamp
	# # effect.renderToScreen = true
	# composer.addPass( effect )
	# world.composer = composer

	

	circleBlur = THREE.ImageUtils.loadTexture 'images/gradient_64.png'
	circleMaterial = new THREE.MeshBasicMaterial
		map: circleBlur
		side: THREE.DoubleSide
		transparent: true
		blending: THREE.MultiplyBlending

	circleGeometry = new THREE.CircleGeometry( 1, 32 );				
	
	populate = (group, rows, cols, spacing)->
		for i in [0..(rows * cols - 1)]
			circle = new THREE.Mesh( circleGeometry, circleMaterial );
			row = Math.floor(i/cols) - rows * .5
			col = i%cols - cols * .5
			circle.position.x = col * spacing 
			circle.position.y = row * spacing 
			group.add circle

	groupA = new THREE.Object3D()
	groupA.scale.set(.1, .1, .1);
	groupA.position.setX(.5);
	rtScene.add groupA
	populate groupA, 10, 10, 2.0

	groupB = new THREE.Object3D()
	groupB.scale.set(.1, .1, .1);
	groupB.position.setX(.5);
	rtScene.add groupB
	populate groupB, 10, 10, 1.5

	



	
	world.update = ()->
		sliderA = document.getElementById('shaping-demo-slider-A').value / 100.0
		groupA.rotation.z = sliderA * .25;

		# exponent = document.getElementById('shaping-demo-slider-exponent').value / 100.0
		# effect.uniforms[ 'exponent' ].value = exponent;

		# min = document.getElementById('shaping-demo-slider-min').value / 100.0
		# effect.uniforms[ 'thresholdMin' ].value = min;

		# max = document.getElementById('shaping-demo-slider-max').value / 100.0
		# effect.uniforms[ 'thresholdMax' ].value = max;

		# mod = document.getElementById('shaping-demo-slider-mod').value / 100.0
		# effect.uniforms[ 'modLevel' ].value = mod;

		# ramp = document.getElementById('shaping-demo-slider-ramp').value / 100.0
		# effect.uniforms[ 'rampLevel' ].value = ramp;

		
		# plane.rotation.z += .01;
		# composer.render()
		world.renderer.render( rtScene, rtCamera, rtTexture, true );




shaping_demo();





