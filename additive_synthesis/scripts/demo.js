var scene = new THREE.Scene();

var aspect = window.innerWidth / window.innerHeight;
var camera = new THREE.OrthographicCamera( 1, -1, 1 / aspect, -1 / aspect, 1, 1000 );
scene.add( camera );

var renderer = new THREE.WebGLRenderer();
renderer.setClearColorHex( 0xFFFFFF, 1 );
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);


var linen = THREE.ImageUtils.loadTexture( "images/linen.png" );
var linenMaterial = new THREE.SpriteMaterial( { map: linen, color: 0xffffff, fog: true } );



// var linenSprite = new THREE.Sprite( linenMaterial );
// linenSprite.position.set( 0, 0, 0 );
// scene.add(linenSprite);

var geometry = new THREE.PlaneGeometry(1,1,1);
var material = new THREE.MeshBasicMaterial({map: linen});
material.transparent = true;
material.blending = THREE.MultiplyBlending;

var plane = new THREE.Mesh(geometry, material);
plane.rotation.y = Math.PI;
scene.add(plane);

var plane2 = new THREE.Mesh(geometry, material);
plane2.rotation.y = Math.PI;
scene.add(plane2);



camera.position.z = 5;


var render = function () {
	requestAnimationFrame(render);

	plane.rotation.z += 0.01;
	plane2.rotation.z -= 0.02;
	
	renderer.render(scene, camera);
};

render();