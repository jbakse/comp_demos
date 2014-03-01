setup_demo = (element)->
	width  = 512; 
	height = 256; 
	aspect = width / height 
	
	# create a 3D render using three.js
	renderer = new THREE.WebGLRenderer()
	renderer.setClearColor 0xFFFFFF, 1
	renderer.setSize width, height
	element.appendChild renderer.domElement

	# create the scene
	scene = new THREE.Scene()

	# add a camera to the scene
	camera = new THREE.OrthographicCamera(-.5, .5, -.5 / aspect  , .5 / aspect , 0, 1000)
	camera.position.z = 5
	scene.add camera

	# create a material that will be when the circle is drawn
	blueMaterial = new THREE.MeshBasicMaterial
		color: 0x0000FF
		side: THREE.DoubleSide

	# create the circle geometry
	circleGeometry = new THREE.CircleGeometry( .1, 32 );

	# create the circle				
	circle = new THREE.Mesh( circleGeometry, blueMaterial );
	scene.add circle



	renderer.render scene, camera