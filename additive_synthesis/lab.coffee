timeout = null
debounce= (threshold, func) ->
	if timeout
		clearTimeout(timeout)
	timeout = setTimeout func, threshold || 100



editor = ace.edit("editor");
editor.setTheme("ace/theme/twilight");
editor.getSession().setMode("ace/mode/coffee");

$.get 'scripts/setup_threejs.coffee', (source)->
	# $(source_code).val(source)
	editor.setValue(source)
	editor.gotoLine(1);
	inject()
	editor.getSession().on 'change', (e)->
		console.log "a"
		debounce 500, ()->inject()


inject = ()->
	console.log "b"
	# source = $(source_code).val();
	source = editor.getValue()

	iframe = $('iframe')[0]

	if iframe.contentDocument
		doc = iframe.contentDocument;
	else if iframe.contentWindow
		doc = iframe.contentWindow.document;
	else 
		doc = iframe.document;
	 


	content = """
	<html>
	<head>
		<script src="lib/jquery-2.1.0.min.js"></script>
		<script src="lib/coffee-script.js"></script>
		<script src="lib/three/three.min.js"></script>
		<script data-main="main" src="lib/require.js"></script>
		
		<link type="text/css" rel = "stylesheet" href="styles/style.css">
	</head>

	<body style="background-color: #555;">
		<main>
		<div id="setup-demo" class="demo"><img src="images/2x1.png" /></div>
		<div class = "demo-controls">
			<button id="setup-demo-button-animate">Animate</button>
		</div>
		<div><script type="text/coffeescript">#{source}</script></div>
		</main>
	</body>


	</html>

	"""

	doc.open()
	doc.writeln(content)
	doc.close()


# $(source_code).keyup ()->
	# inject()

