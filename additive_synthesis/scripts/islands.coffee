island_demo = (element)->
	
	##
	# D3 Boilerplate

	width  = 768;
	height = 384;
	aspect = width / height 
	
	scene = new THREE.Scene()

	camera = new THREE.OrthographicCamera(-.5, .5, -.5 / aspect  , .5 / aspect , 0, 1000)
	camera.position.z = 5
	scene.add camera

	renderer = new THREE.WebGLRenderer()
	renderer.setClearColor 0xFFFFFF, 1
	renderer.setSize width, height
	element[0].appendChild renderer.domElement
	
	# needsUpdate - does the scene need to be redrawn?
	needsUpdate = true

	##
	# load texture assets
	islandRampTex = THREE.ImageUtils.loadTexture 'assets/island_ramp_256.png', {}, ()-> needsUpdate = true
	gradientTex = THREE.ImageUtils.loadTexture 'assets/gradient_64.png', {}, ()-> needsUpdate = true
	gradient128Tex  = THREE.ImageUtils.loadTexture 'assets/gradient_128.png', {}, ()-> needsUpdate = true

	##
	# setup render textures

	# base texture holds the initial dots
	baseTexture = new THREE.WebGLRenderTarget 1024 , 1024 , {
		minFilter: THREE.LinearFilter
		magFilter: THREE.NearestFilter
		format: THREE.RGBFormat
	}

	# heightMap is the result of shaping the baseTexture
	# used to control height of the island
	heightMap = new THREE.WebGLRenderTarget 1024 , 1024 , {
		minFilter: THREE.LinearFilter
		magFilter: THREE.NearestFilter
		format: THREE.RGBFormat
	}

	# colorMap is the result of applying the color ramp to the height map
	# used to color the island
	colorMap = new THREE.WebGLRenderTarget 1024 , 1024 , {
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


	vignetteMaterial = new THREE.MeshBasicMaterial
		map: gradient128Tex
		side: THREE.DoubleSide
		transparent: true
		blending: THREE.AdditiveBlending

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
			"preamp": { type:'f', value: 1.0 }
			"bias": { type:'f', value: 1.0 }
			"exponent": { type:'f', value: 1.0 }
			"minThreshold": { type:'f', value: 1.0 }
			"maxThreshold": { type:'f', value: 1.0 }
			"postamp": { type:'f', value: 1.0 }

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
			uniform float preamp;
			uniform float bias;
			uniform float exponent;
			uniform float minThreshold;
			uniform float maxThreshold;
			uniform float postamp;

			varying vec2 vUv;

			void main() {
				// read the input color
				vec4 o = texture2D( tDiffuse, vUv );

				// make sure it is in the expected range
				o = clamp(o, 0.0 , 1.0);
				

				// invert the colors, because it makes more sense for the processing for the dots to be 1.0 and the background to be 0.0
				o = vec4(1.0, 1.0, 1.0, 1.0) - o;

				// apply the preamp
				o *= preamp;

				// use pow function to shape the slope of the gradient
				o = pow( o, vec4(exponent, exponent, exponent, exponent) );
				
				// apply the bias
				o += bias;

				// apply the min/max
				o = clamp(o, minThreshold, maxThreshold);

				// apply the postamp
				o *= postamp;

				// invert the colors back
				o = vec4(1.0, 1.0, 1.0, 1.0) - o;

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
			circle = new THREE.Mesh( circleGeometry, circleMaterial )
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

	vignette = new THREE.Mesh circleGeometry, vignetteMaterial
	vignette.scale.set(.75, .75, .75)
	baseScene.add vignette

	#set up post process scene
	processScene = new THREE.Scene()
	processCamera = new THREE.OrthographicCamera(-.5, .5, -.5 , .5, 0, 1)
	processCamera.position.z = 0
	processScene.add processCamera
	processQuad = new THREE.Mesh( new THREE.PlaneGeometry( 1, 1 ), shapingMaterial );
	processQuad.rotation.x = Math.PI
	processScene.add processQuad

	# set up scene

	planeGeometry = new THREE.PlaneGeometry( 1, 1);

	#plane used to show the dots that form the base
	basePlane = new THREE.Mesh planeGeometry, 
		new THREE.MeshBasicMaterial
			map: baseTexture
			side: THREE.DoubleSide
	scene.add basePlane

	# plane used to show the heightmap
	heightPlane = new THREE.Mesh planeGeometry, 
		new THREE.MeshBasicMaterial
			map: heightMap
			side: THREE.DoubleSide
	scene.add heightPlane

	# plane used to show the colormap
	colorPlane = new THREE.Mesh planeGeometry, 
		new THREE.MeshBasicMaterial
			map: colorMap
			side: THREE.DoubleSide
	scene.add colorPlane

	# plane that shows the 3d island
	islandGeometry = new THREE.PlaneGeometry( 1, 1, 100, 100);
	islandPlane = new THREE.Mesh( islandGeometry, islandMaterial );
	islandPlane.scale.set(1.5, 1.5, 1.5)
	islandPlane.position.set(0.0,-.1,0.0)
	islandPlane.rotation.x = Math.PI * - .65
	scene.add islandPlane

	##
	# main animation loop
	
	update = ()->
		requestAnimationFrame ()=> update()
		
		if not needsUpdate then return
		
		##
		# inputs

		sliderA = $('#island-demo-slider-a').val() / 100.0
		vignetteBlend = $('#island-demo-slider-vignette').val() / 100.0
		
		preamp = $('#island-demo-slider-preamp').val() / 100.0
		bias = $('#island-demo-slider-bias').val() / 100.0
		exponent = $('#island-demo-slider-exponent').val() / 100.0
		min = $('#island-demo-slider-min').val() / 100.0
		max = $('#island-demo-slider-max').val() / 100.0
		postamp = $('#island-demo-slider-postamp').val() / 100.0

		rampLevel = $('#island-demo-slider-ramp').val() / 100.0

		show = $('#island-demo-show').val()
	

		##
		# position layers
		groupB.rotation.z = sliderA * .25;
		groupB.position.x = sliderA * .25;
		groupC.rotation.z = sliderA * -.5;
		groupC.position.y = sliderA * -.5;

		##
		# fade out edges
		vignette.material.opacity = vignetteBlend
		vignette.material.needsUpdate = true

		##
		# set shaping values
		shapingMaterial.uniforms['preamp'].value = preamp;
		shapingMaterial.uniforms['bias'].value = bias;
		shapingMaterial.uniforms['exponent'].value = exponent;
		shapingMaterial.uniforms['minThreshold'].value = min;
		shapingMaterial.uniforms['maxThreshold'].value = max;
		shapingMaterial.uniforms['postamp'].value = postamp;

		##
		# set coloring values
		coloringMaterial.uniforms['rampLevel'].value = rampLevel;

		

		##
		# hide and show 
		basePlane.visible = heightPlane.visible = colorPlane.visible = islandPlane.visible = false
		
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
		renderer.render( baseScene, baseCamera, baseTexture, true );

		# shape baseTexture, store in heightMap
		processQuad.material = shapingMaterial
		renderer.render( processScene, processCamera, heightMap, true);

		# color heightMap, store in colorMap
		processQuad.material = coloringMaterial
		renderer.render( processScene, processCamera, colorMap, true);

		# draw the screen scene
		renderer.render scene, camera

		#note that we rendered this frame 
		needsUpdate = false

		#the island view animates, so we need to draw over and over
		if show == "island"
			needsUpdate = true
		

	# start the animation update loop
	update()

	

	# redraw when user interacts
	$('#island-demo-slider-a,
		#island-demo-slider-vignette,
		#island-demo-slider-preamp,
		#island-demo-slider-bias,
		#island-demo-slider-exponent,
		#island-demo-slider-min,
		#island-demo-slider-max,
		#island-demo-slider-postamp,
		#island-demo-slider-ramp,
		#island-demo-show').change ()-> 
			needsUpdate = true


	


# start the demo
island_demo $('#island-demo')