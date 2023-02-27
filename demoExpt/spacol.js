//window.onload = startGame;
var framenum = 0;
const startTime = Date.now();
var cv = document.createElement("CANVAS");
var ctx = cv.getContext("2d");
var scrWidth = window.innerWidth - 50;
var scrHeight = window.innerHeight - 50;
var frameDur = 1000/60;
var fadeStep = 60;
var frameWait = 10;
var numDots = 1000;
var dotSize = 30;
var varMat = varGen();
var mousePosX = 0;
var mousePosY = 0;
var mouseButton = -1;

ctx.canvas.width  = scrWidth; ctx.canvas.height = scrHeight;
document.body.style.backgroundColor = "#000000"; document.body.appendChild(cv);

reset();
setInterval(mainLoop, frameDur);
  
function mainLoop() {
  framenum = framenum + 1;
  onmousemove = function(e){mousePosX = e.clientX; mousePosY = e.clientY; return (mousePosX, mousePosY);}
  onmousedown = function(e){mouseButton = e.button; return (mouseButton);}

  //draw section
  reset();
  for (let i = 0; i < varMat.length; i++) {
    fadeCircle(varMat[i][0],varMat[i][1],varMat[i][2],varMat[i][3],varMat[i][4],varMat[i][5],varMat[i][6]);
  } 
  
  if(mouseButton == 0){
	mouseButton = -1;
  }
}

function fadePrimary(c,fdel){
  f = Math.max(framenum - fdel,0)
  return(Math.round(Math.max(c - f * c/fadeStep, 0)));
}

function fadeCircle(x,y,s,r,g,b,fdel){
  if (framenum >= fdel & framenum <= fdel+fadeStep ){
	  drawCircle(x,y,s,fadePrimary(r,fdel),fadePrimary(g,fdel),fadePrimary(b,fdel));
  }
}
  
function drawCircle(x,y,rad,r,g,b){
  fcol = rgb2hex(r,g,b); 
  scol = "black"; swidth = 0;
  ctx.beginPath(); ctx.arc(x, y, rad, 0, 2 * Math.PI);
  //ctx.strokeStyle = scol; ctx.lineWidth = swidth; 
  ctx.fillStyle = fcol;
  ctx.fill(); //ctx.stroke(); 
}

function reset() {
  ctx.fillStyle = "black"; 
  ctx.fillRect(0, 0, scrWidth, scrHeight);
}

function normArray(x) {
  y = new Array(x.length);  
  const sumVal = sumArray(x);
  for (i = 0; i < x.length; i += 1) { 
	  y[i] = x[i] / sumVal;
  }
  return(y);
}

function sumArray(x) {
  sumVal = 0;
  for (i = 0; i < x.length; i += 1) { 
	  sumVal += x[i];
  }
  return(sumVal);
}

function addArray(x1,x2) {
  y = new Array(x1.length);
  for (i = 0; i < x1.length; i += 1) { 
	  y[i] = x1[i] + x2[i];
  }
  return(y);
}

function multArray(x,mult) {
  y = new Array(x.length);
  for (i = 0; i < x.length; i += 1) { 
	  y[i] = x[i] * mult;
  }
  return(y);
}

function rgb2hex(r,g,b) {
  red = rgbToHex(Math.round(r));
  green = rgbToHex(Math.round(g));
  blue = rgbToHex(Math.round(b));
  return '#'+red+green+blue;
}  

function rgbToHex(rgb) {
  hex = Number(rgb).toString(16);
  if (hex.length < 2) {
       hex = "0" + hex;
  }
  return hex;
}  

function randCol() {
	var r = Math.random()*255;
	return(Math.round(r));
}  


function varGen(){
	for (i = 0; i < numDots; i += 1) { 
		xpos = Math.round(Math.random()*scrWidth);
		ypos = Math.round(Math.random()*scrHeight);
		dsize = Math.round(Math.random()*dotSize);
		rval = Math.round(Math.random()*255);
		gval = Math.round(Math.random()*255);
		bval = Math.round(Math.random()*255);
		fdel = frameWait*(i+1);
		xrow = [xpos,ypos,dsize,rval,gval,bval,fdel];
		if(i == 0){mat = [xrow]};
		if(i > 0){mat.push(xrow)};
	}
	return(mat)
}