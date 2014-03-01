morie_demo = (element)->
	

	##
	# boiler plate
	width  = 768; 
	height = 384; 
	aspect = width / height 
	
	# create a 3D render using three.js
	renderer = new THREE.WebGLRenderer()
	renderer.setClearColor 0xFFFFFF, 1
	renderer.setSize width, height
	element[0].appendChild renderer.domElement

	# create the scene
	scene = new THREE.Scene()

	# add a camera to the scene
	camera = new THREE.OrthographicCamera(-.5, .5, -.5 / aspect  , .5 / aspect , -1000, 1000)
	camera.position.z = 0
	scene.add camera


	##
	# load textures
	circleBlur = THREE.ImageUtils.loadTexture 'images/circle_blur_64.png'
	white = THREE.ImageUtils.loadTexture 'images/white_64.png'


	##
	# setup materials
	blackMaterial = new THREE.MeshBasicMaterial
		map: white
		color: 0x000000
		side: THREE.DoubleSide

	blurMaterial = new THREE.MeshBasicMaterial
		map: circleBlur
		side: THREE.DoubleSide
		transparent: true
		blending: THREE.MultiplyBlending

	blueMaterial = new THREE.MeshBasicMaterial
		map: white
		color: 0x0000ff
		side: THREE.DoubleSide
		transparent: true
		blending: THREE.MultiplyBlending

	redMaterial = new THREE.MeshBasicMaterial
		map: white
		color: 0xff0000
		side: THREE.DoubleSide
		transparent: true
		blending: THREE.MultiplyBlending

	##
	# create the models
	circleGeometry = new THREE.CircleGeometry( 1, 32 );		

	##
	# create the scene content
	content = new THREE.Object3D()
	scene.add content

	groupA = new THREE.Object3D()
	content.add groupA

	groupB = new THREE.Object3D()
	content.add groupB

	populate = (parent, rows, cols, spacing)->
		for i in [0..(rows * cols - 1)]
			circle = new THREE.Mesh( circleGeometry, blackMaterial );
			row = Math.floor(i/cols) - rows * .5
			col = i%cols - cols * .5
			circle.position.x = col * spacing 
			circle.position.y = row * spacing 
			parent.add circle

	populate groupA, 30, 50, 2.5
	populate groupB, 30, 50, 2.5


	##
	# update and the scene
	update = ()->
		sliderA = $('#morie-demo-slider-a').val() / 100.0
		sliderZoom = $('#morie-demo-slider-zoom').val() / 100.0
		material = $('#morie-demo-menu-material').val()
		
		#apply the material
		switch material
			when 'black'
				for circle in groupA.children
					circle.material = blackMaterial
				for circle in groupB.children
					circle.material = blackMaterial

			when 'color'
				for circle in groupA.children
					circle.material = redMaterial
				for circle in groupB.children
					circle.material = blueMaterial

			when 'blur'
				for circle in groupA.children
					circle.material = blurMaterial
				for circle in groupB.children
					circle.material = blurMaterial

		# slide group A around
		groupA.rotation.z = sliderA * .35;
		aScale = .35 * sliderA + 1.0
		groupA.scale.set(aScale, aScale, aScale);
		
		#zoom in on the content
		scale = .01 * sliderZoom
		content.scale.set(scale, scale, scale)
		content.position.x = (sliderZoom - .5) * .25

		renderer.render scene, camera


	# draw once now, and again when the controls are used
	update()
	$('#morie-demo-slider-a,
		#morie-demo-slider-zoom,
		#morie-demo-menu-material').change update

	
# kick off the demo
morie_demo $('#morie-demo')