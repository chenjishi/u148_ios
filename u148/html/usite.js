

function initImages() {
	var images = document.getElementsByTagName('img');
	for(var i=0; i<images.length; i++) {
        var img = images[i];
		
		img.removeAttribute('class');
		img.removeAttribute('style');
		img.removeAttribute('width');
		img.removeAttribute('height');
		img.style.display = "block";
		img.onerror=function()
		{
			this.style.display="none";
		}
		if(img.parentNode && img.parentNode.tagName == "A") {
			img.parentNode.setAttribute("href", 'javascript:void(0);');
            img.onclick = function(obj) {
                return function() {
                    imageClick(obj);
                }
            }(img);
            
			if(img.parentNode.parentNode.tagName=="P" && img.parentNode.parentNode.childNodes.length==1){
				img.parentNode.parentNode.style.textIndent ='0em';
			}
		} else {
		    if(img.src.indexOf('android_asset') != -1) {
		        img.parentNode.setAttribute('onclick','U148.onVideoClick("'+ img.title +'")');
		    } else {
     			img.setAttribute('onclick','U148.onImageClick("'+ img.src +'")');
		    }
			if(img.parentNode.tagName=="P" && images[i].parentNode.childNodes.length==1){
				img.parentNode.style.textIndent ='0em';
			}
		}
        
	}
}

function imageClick(obj){
    window.location = 'ios:webToNativeCall&' + obj.src;
}

function loadData(){
    init();
	window.onChange = init;
}

function init() {
    initImages();
}
