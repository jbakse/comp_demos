
island_demo = (el)->
	world = new World(el[0]).start()
	
	##
	# load texture assets
	
	islandRampTex = THREE.ImageUtils.loadTexture 'images/island_ramp_256.png'
	gradientTex = THREE.ImageUtils.loadTexture 'images/gradient_64.png'


	##
	# setup render textures

	# base texture holds the initial dots
	baseTexture = new THREE.WebGLRenderTarget 512, 512, {
		minFilter: THREE.LinearFilter
		magFilter: THREE.NearestFilter
		format: THREE.RGBFormat
	}

	# heightMap is the result of shaping the baseTexture
	# used to control height of the island
	heightMap = new THREE.WebGLRenderTarget 512, 512, {
		minFilter: THREE.LinearFilter
		magFilter: THREE.NearestFilter
		format: THREE.RGBFormat
	}

	# colorMap is the result of applying the color ramp to the height map
	# used to color the island
	colorMap = new THREE.WebGLRenderTarget 512, 512, {
		minFilter: THREE.LinearFilter
		magFilter: THREE.NearestFilter
		format: THREE.RGBFormat
	}


	##
	# setup materials

	#draws the initial circles
	circleMaterial = new THREE.MeshBasicMaterial
		map: gradientTex
		side: THREE.DoubleSide
		transparent: true
		blending: THREE.MultiplyBlending

	#used to displace and color the island plane
	islandMaterial = new THREE.ShaderMaterial
		side: THREE.DoubleSide
		uniforms:
			"heightMap": { type: "t", value: heightMap }
			"colorMap": { type: "t", value: colorMap }

		vertexShader:
			"""
			uniform sampler2D heightMap;
			varying vec2 vUv;

			void main() {
				vUv = uv;
				vec4 texel = texture2D( heightMap, vUv );

				vec3 p = position;
				p.z += texel.r * .1;

				gl_Position = projectionMatrix * modelViewMatrix * vec4( p, 1.0 );
			}
			"""

		fragmentShader:
			"""
			uniform sampler2D colorMap;
			uniform sampler2D heightMap;
			varying vec2 vUv;

			void main() {
				vec4 texel = texture2D( colorMap, vUv );
				texel.a = 1.0;

				//expiremental lighting
				vec4 here = texture2D( heightMap, vec2(vUv.x, vUv.y) );
				vec4 up = texture2D( heightMap, vec2(vUv.x, vUv.y-.01) );
				texel.rgb += (here.rgb - up.rgb) * 2.0;

				gl_FragColor = texel;
			}
			"""

	shapingMaterial = new THREE.ShaderMaterial
		side: THREE.DoubleSide
		transparent: false
		uniforms: 
			"tDiffuse": { type: "t", value: baseTexture }
			"exponent": { type:"f", value: 1.0 }
			"thresholdMin": { type:"f", value: 0.0 }
			"thresholdMax": { type:"f", value: 1.0 }
			"modLevel": { type:"f", value: 1.01 }
			# "ramp": { type: "t", value: null }
			# "rampLevel": { type:"f", value: 1.01 }

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
			uniform float exponent;
			uniform float thresholdMin;
			uniform float thresholdMax;
			uniform float modLevel;
			//uniform float rampLevel;
			//uniform sampler2D ramp;

			varying vec2 vUv;

			void main() {
				// read the input color
				vec4 o = texture2D( tDiffuse, vUv );

				// make sure it is in the expected range
				o = clamp(o, 0.0 , 1.0);
				
				// use pow function to shape the slope of the gradient
				o = pow( o, vec4(exponent, exponent, exponent, exponent) );
				
				// apply the mod
				o = mod( o, vec4(modLevel, modLevel, modLevel, modLevel)) / modLevel;

				//make anything under thresholdMin 0.0
				o = step(vec4(thresholdMin, thresholdMin, thresholdMin, thresholdMin), o) * o;
				o += vec4(.1, .1, .1, .1);

				// make anything over threshold max 1.0
				o = o + step(  vec4(thresholdMax, thresholdMax, thresholdMax, thresholdMax), o );
				o = min( vec4(1.0, 1.0, 1.0, 1.0), o );
			
				// use the color lookup table to colorize the result
				// o = texture2D( ramp, vec2(o.r, .95 - rampLevel));
				// o = clamp(o, 0.0 , 1.0);
				
				// set the alpha to 1.0 as we don't intend on any plending
				o.a = 1.0;
				

				// set the output color
				gl_FragColor = o;
			}
			"""

	coloringMaterial = new THREE.ShaderMaterial
		side: THREE.DoubleSide
		transparent: false
		uniforms: 
			"tDiffuse": { type: "t", value: heightMap }
			"tRamp": { type: "t", value: islandRampTex }
			"rampLevel": { type:"f", value: 0.0 }

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
			uniform sampler2D tRamp;
			uniform float rampLevel;

			varying vec2 vUv;

			void main() {
				// read the input color
				vec4 o = texture2D( tDiffuse, vUv );
			
				//use the color lookup table to colorize the result
				o = texture2D( tRamp, vec2(o.r, 1.0 - rampLevel));
				
				

				// set the output color
				gl_FragColor = o;
			}
			"""


	##
	# setup scenes

	# set up base scene
	baseScene = new THREE.Scene()
	baseCamera = new THREE.OrthographicCamera(-.5, .5, -.5  , .5  , 1, 1000)
	baseCamera.position.z = 5
	baseScene.add baseCamera

	circleGeometry = new THREE.CircleGeometry( 1, 32 );				
	
	setUpCircleGroup = (group, rows, cols, spacing, scaleX = 1, scaleY = 1)->
		group.scale.set(.1, .1, .1);
		for i in [0..(rows * cols - 1)]
			circle = new THREE.Mesh( circleGeometry, circleMaterial );
			row = Math.floor(i/cols)
			col = i%cols
			circle.scale.x = scaleX
			circle.scale.y = scaleY
			circle.position.x = col * spacing - (cols - 1) * spacing * .5
			circle.position.y = row * spacing - (rows - 1) * spacing * .5
			group.add circle

	groupA = new THREE.Object3D()
	setUpCircleGroup groupA, 4, 4, 2.0
	baseScene.add groupA

	groupB = new THREE.Object3D()
	setUpCircleGroup groupB, 4, 4, 1.5
	baseScene.add groupB

	groupC = new THREE.Object3D()
	setUpCircleGroup groupC, 4, 4, 1.5, .5, .5
	baseScene.add groupC

	#set up post process scene
	processScene = new THREE.Scene()
	processCamera = new THREE.OrthographicCamera(-.5, .5, -.5 , .5, 0, 1)
	processCamera.position.z = 0
	processScene.add processCamera
	processQuad = new THREE.Mesh( new THREE.PlaneGeometry( 1, 1 ), shapingMaterial );
	processQuad.rotation.x = Math.PI
	processScene.add processQuad

	# set up world scene

	planeGeometry = new THREE.PlaneGeometry( 1, 1);
	basePlane = new THREE.Mesh planeGeometry, 
		new THREE.MeshBasicMaterial
			map: baseTexture
			side: THREE.DoubleSide
	# basePlane.position.set(-.4,-.15,-20)
	# basePlane.scale.set(.25,.25,.25);
	world.scene.add basePlane

	# plane used to show the heightmap
	heightPlane = new THREE.Mesh planeGeometry, 
		new THREE.MeshBasicMaterial
			map: heightMap
			side: THREE.DoubleSide
	# heightPlane.position.set(-.1,-.15,-20)
	# heightPlane.scale.set(.25,.25,.25);
	world.scene.add heightPlane

	# plane used to show the colormap
	colorPlane = new THREE.Mesh planeGeometry, 
		new THREE.MeshBasicMaterial
			map: colorMap
			side: THREE.DoubleSide
	# colorPlane.position.set(.2,-.15,-20)
	# colorPlane.scale.set(.25,.25,.25);
	world.scene.add colorPlane

	# plane that shows the 3d island
	islandGeometry = new THREE.PlaneGeometry( 1, 1, 100, 100);
	islandPlane = new THREE.Mesh( islandGeometry, islandMaterial );
	islandPlane.scale.set(1.5, 1.5, 1.5)
	islandPlane.position.set(0.0,-.1,0.0)
	islandPlane.rotation.x = Math.PI * - .65
	world.scene.add islandPlane

	##
	# main animation loop

	world.update = ()->
		
		##
		# inputs

		sliderA = $('#island-demo-slider-a').val() / 100.0
		groupB.rotation.z = sliderA * .25;
		groupB.position.x = sliderA * .25;

		groupC.rotation.z = sliderA * -.5;
		groupC.position.y = sliderA * -.5;

		exponent = $('#island-demo-slider-exponent').val() / 100.0
		shapingMaterial.uniforms[ 'exponent' ].value = exponent;

		min = $('#island-demo-slider-min').val() / 100.0
		shapingMaterial.uniforms[ 'thresholdMin' ].value = min;

		max = $('#island-demo-slider-max').val() / 100.0
		shapingMaterial.uniforms[ 'thresholdMax' ].value = max;

		mod = $('#island-demo-slider-mod').val() / 100.0
		shapingMaterial.uniforms[ 'modLevel' ].value = mod;

		ramp = $('#island-demo-slider-ramp').val() / 100.0
		coloringMaterial.uniforms[ 'rampLevel' ].value = ramp;



		basePlane.visible = heightPlane.visible = colorPlane.visible = islandPlane.visible = false
		show = $('#island-demo-show').val()
		switch show
			when "base"
				basePlane.visible = true

			when "shaped"
				heightPlane.visible = true

			when "colored"
				colorPlane.visible = true

			when "island"
				islandPlane.visible = true

		##
		# animation

		islandPlane.rotation.z += .0025;


		##
		# render sequence
		
		# render the circles into baseTexture
		world.renderer.render( baseScene, baseCamera, baseTexture, true );

		# shape baseTexture, store in heightMap
		processQuad.material = shapingMaterial
		world.renderer.render( processScene, processCamera, heightMap, true);

		# color heightMap, store in colorMap
		processQuad.material = coloringMaterial
		world.renderer.render( processScene, processCamera, colorMap, true);


class World

	update: false

	constructor: (@element)->
		@width  = 512; #@element.clientWidth
		@height = 256; #@element.clientHeight
		@aspect = @width / @height 
		
		@scene = new THREE.Scene()

		@camera = new THREE.OrthographicCamera(-.5, .5, -.5 / @aspect  , .5 / @aspect , 0, 1000)
		@camera.position.z = 5
		@scene.add @camera

		@renderer = new THREE.WebGLRenderer()
		@renderer.setClearColor 0xFFFFFF, 1
		@renderer.setSize @width, @height
		@element.appendChild @renderer.domElement
		


	_render_loop: ()->
		requestAnimationFrame ()=> @_render_loop()
		@update?()
		@renderer.render @scene, @camera


	start: ()->
		@_render_loop()
		this


island_demo $('#island-demo')