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