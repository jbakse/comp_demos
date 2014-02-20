# texture/materials
linenTexture = THREE.ImageUtils.loadTexture "images/linen.png"
linenTexture.wrapS = THREE.RepeatWrapping
linenTexture.wrapT = THREE.RepeatWrapping
linenTexture.repeat.set  10, 10


linen = new THREE.MeshBasicMaterial
	map: linenTexture
	transparent: true
	blending: THREE.MultiplyBlending
tile1 = new THREE.Mesh(plane, linen)
tile1.rotation.y = Math.PI



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
