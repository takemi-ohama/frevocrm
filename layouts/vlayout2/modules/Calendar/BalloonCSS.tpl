<style type="text/css">
html, body {
	height: 100%;
	overflow: auto;
}
#wrapper {
position: relative;
width: 100%;
height: 100%;
overflow: auto;
}
* html .balloon {
	position: absolute;
}
.balloon {
	position: fixed;
	opacity: 80;
	z-index: 9999;
	width: 300px;
	background-color: #2b2b2b;
	text-align: left;
	color:white;
	border-radius: 5px;
	padding:5px;
}
.balloon .title {
	font-size:bold;
	color:#FFC660;
}
.balloon:after {
	background: #fff;
	bottom: -20px;
	left: 50px;
	z-index: 99;
}

.balloon:before {
	background: #ccc;
	bottom: -15px;
	left: 35px;
	z-index: 99;
}
</style>
