class Header
	constructor: (@glued) ->
		@switchGlue()

		$("#set-header").click () => 
			@switchGlue()
			@updateDatabaseGlue()

	switchGlue: () ->
		if @glued
			@unglue()
		else @glue()
		
	updateDatabaseGlue: () ->
		$.ajax
			url:  "/users/glue",
			type: "POST",
			data: "glued=" + (@glued + 0)

	/* Glue the header to the top of the page */
	glue: () -> 
		@glued=true
		
		/* Old Header Style. This doesn't stretch across the page */
		/* headerCSS = "position":"relative","top":"auto","left":"auto","right":"auto","margin":"5px 15px 4px 15px" */
		/* navCSS ="margin":"0px 15px 4px 15px" */
		/* $("#header").addClass("roundBox") */

		/* New Header Style. This stetches all the was across the page */
		headerCSS = 
			"position":"absolute",
			"top":"5px","left":"0px","right":"0px",
			"margin":"auto"
		navCSS =
			"margin":"83px 15px 4px 15px"

		$("#header").css headerCSS
		$("#navigation").css navCSS

		$("#set-header").html "↓"

	/* Unglue the header from the top of the page */
	unglue: () -> 
		@glued=false
		headerCSS = 
			"position":"fixed",
			"top":"5px","left":"0px","right":"0px",
			"margin":"auto"
		navCSS =
			"margin":"83px 15px 4px 15px"

		$("#header").css headerCSS
		$("#navigation").css navCSS

		/* Old Header Style fix. Only required for old header */
		/* $("#header").removeClass("roundBox") */

		$("#set-header").html "↑"

class Notice
	constructor: (@title,@content) ->
		$("#notice").slideDown "slow"
		
		$("#notice").html "<span class='close'></span><h4>" + @title + "</h4><p>" + @content + "</p>"

		$("#notice .close").click @die

	die: () ->
		$("#notice").slideUp "fast", () =>
			$("#notice").hide()

class Modal
	constructor: (@title,@content) ->
		$("#modal div").html "<span class='close'></span><h4>" + @title + "</h4><p>" + @content + "</p>"

		$("#modal .close").click @die

		@show()
	show: () ->
		@visible=true
		$("#modal").css("visibility","visible")
	die: () ->
		@visible=false
		$("#modal").css("visibility","hidden")
$(document).ready ->
	/* Keeps the copyright up to date on the current year */
	date = new Date()
	$("#copyright-date").html date.getFullYear()

	/* Set up the header */
	header = new Header false
	if $("#glued").attr("data-glued") == "0"
		header.switchGlue()

	/* Registration */
	$("#register-button").click () =>
		signupModal = new Modal "CREATE A NEW ACCOUNT", $("#register-form").html()
		
		$("#modal button").click () =>
			$.ajax 
				url:  "/users/signup",
				type: "POST",
				data: $("#modal form").serialize(),
				success: (data) =>
					if data == "1"
						window.location.assign "/users/welcome"

	/* Login */
	$("#login-button").click () =>
		loginModal = new Modal "LOGIN", $("#login-form").html()

		$("#modal button").click () =>
			$.ajax
				url:  "/users/login",
				type: "POST",
				data: $("#modal form").serialize(),
				success: (data) =>
					if data == "1"
						location.reload()
					else
						new Notice "Incorrect Login Combo", "The username and password didn't match any in our records. Try again! "

	/* Logout */
	$("#logout-button").click () =>
		$.ajax
			url:  "/users/logout",
			type: "POST",
			success: (data) =>
				if data == "1"
					window.location = "/"
