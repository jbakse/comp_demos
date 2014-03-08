console.log("main.js");
require(["lib/marked"], function(marked) {
	
	marked.setOptions({
		gfm: true,
		tables: true,
		breaks: false,
		pedantic: false,
		sanitize: false,
		smartLists: true,
		smartypants: true
	});



	//find the .markdown sections
	$(".markdown").each( function() {
		
		//load the markdown source
		el = this;
		$.get($(this).data("src"), function(markdown_source) {

			//parse markdown and insert it
			el.innerHTML = marked(markdown_source);

			//find coffeescript tags in inserted markdown and run it
			$(el).find('script[type="text/coffeescript"]').each(function() {
				CoffeeScript.load(this.src, function(source) {
					console.log(source);
					CoffeeScript.run.apply(null, source);
				});
			});
		});
	});
});

