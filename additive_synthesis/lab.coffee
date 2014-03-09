

# util funciton
timeout = null
debounce= (threshold, func) ->
	if timeout
		clearTimeout(timeout)
	timeout = setTimeout func, threshold || 100

##
# set up editor
editor = ace.edit "editor"
editor.setTheme "ace/theme/monokai"
editor.getSession().setMode "ace/mode/coffee"
editor.setShowInvisiblesfalse
editor.setShowPrintMargin false


reinject = (editor)->
	$('iframe').attr "src", ""
	debounce 0, ()->inject()

editor.commands.addCommand
    name: "Reload iFrame",
    bindKey: {win: "Ctrl-B|Ctrl-R|Ctrl-S", mac: "Command-B|Command-R|Command-S"},
    exec: reinject
        
 


script_name = window.location.search.substr(1)

$.get script_name, (source)->
	editor.setValue(source)
	editor.gotoLine(1);
	inject()

	$('#run').click reinject
		
	# editor.getSession().on 'change', (e)->
	# 	$('iframe').attr "src", ""
	# 	debounce 500, ()->inject()


inject = ()->
	source = editor.getValue()

	iframe = $('iframe')[0]
	
	if iframe.contentDocument
		doc = iframe.contentDocument
	else if iframe.contentWindow
		doc = iframe.contentWindow.document
	else 
		doc = iframe.document
	 
	


	content = """
	<html>
		<head>
			<script src="lib/jquery-2.1.0.min.js"></script>
			<script src="lib/coffee-script.js"></script>
			<script src="lib/three/three.min.js"></script>
			<link type="text/css" rel = "stylesheet" href="styles/style.css">
		</head>

		<body style="background-color: #DDD; padding-bottom: 10px;">
			<main>
				<div id="lab-demo" class="demo"><img src="images/2x1.png" /></div>
				<div id="lab-demo-controls" class="demo-controls"></div>
				<div><script type="text/coffeescript">#{source}</script></div>
			</main>
		</body>
	</html>
	"""


	resizeIframe = ()->
		h = $(iframe.contentWindow.document).height() #.offsetHeight
		$(iframe).height(h)

	$(iframe).load resizeIframe


	doc.open()
	doc.writeln(content)
	doc.close()

	

	
	# setTimeout resizeIframe, 0
	# console.log iframe.contentWindow.document.body.scrollHeight
	


