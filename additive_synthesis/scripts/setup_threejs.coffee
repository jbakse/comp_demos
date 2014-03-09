setup_demo = (element)->
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

	animate = ()->
		requestAnimationFrame ()=> animate()
		circle.rotation.x += .02

		renderer.render scene, camera


	$('#setup-demo-button-animate').one "click", animate


# inject controls
$('#setup-demo-controls, #lab-demo-controls').html """
<button id="setup-demo-button-animate">Animate</button>
"""

# kick off the demo
setup_demo $('#setup-demo, #lab-demo')