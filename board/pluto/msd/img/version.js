function OnTheWeb() {
	window.location.assign("https://wiki.analog.com/university/tools/pluto");
}

function versionCompare(v1, v2) {
	var v1parts = ("" + v1).replace(/[a-zA-Z]/g, "").replace("-", ".").split("."),
	v2parts = ("" + v2).replace(/[a-zA-Z]/g, "").replace("-", ".").split("."),
	minLength = Math.min(v1parts.length, v2parts.length),
	p1, p2, i;
	console.log(v1parts + " || " + v2parts);
	for(i = 0; i < minLength; i++) {
		p1 = parseInt(v1parts[i], 10);
		p2 = parseInt(v2parts[i], 10);
		if (isNaN(p1)){ p1 = v1parts[i]; }
		if (isNaN(p2)){ p2 = v2parts[i]; }
		if (p1 == p2) {
			continue;
		}else if (p1 > p2) {
			return 1;
		}else if (p1 < p2) {
			return -1;
		}
		return NaN;
	}
	if (v1parts.length === v2parts.length) {
		return 0;
	}
	return (v1parts.length < v2parts.length) ? -1 : 1;
}

var latest_libiio;
var mac = false;

function GetDriverurl() {
	mac = navigator.platform.match(/Mac/i) ? true : false;
	if (mac) {
		var uAgent = navigator.userAgent.toLowerCase();
		//uAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.90 Safari/537.36".toLowerCase();
		var test = uAgent.match(/mac os x 10_[0-9]*/);
		if (test) {
			mac = "darwin-" + test[0].match(/10_[0-9]*/)[0].replace("_", ".");
		}
		document.getElementById('prompt0').innerHTML = "adi-mm:tests analogdevices$";
		document.getElementById('prompt1').innerHTML = "adi-mm:tests analogdevices$";
	} else {
		document.getElementById('hidehorndis').style.display = "none";
	}
	var win = navigator.platform.indexOf('Win') > -1 ? true : false;
	if (win) {
		document.getElementById('prompt0').innerHTML = "C:";
		document.getElementById('prompt1').innerHTML = "C:";
	} else
		document.getElementById('hidedriver').style.display = "none";
	var linux = navigator.platform.indexOf('Linux') > -1 ? true : false;
	if (mac || win || linux)
		document.getElementById('hidelib').style.display = "inline";
	else {
		if (navigator.platform.match(/(Linux|iPhone|iPod|iPad|Android)/i)) {
			document.getElementById('libtest').innerHTML = "Sorry, we don't support " + navigator.platform + " yet. Please ask.";
			jQuery('#libtest').attr ('href', "https://ez.analog.com/university-program");
		} else
			document.getElementById('libtest').innerHTML = "Unsupported host \"" + navigator.platform + "\". Please check, and report an issue";
		return;
	}

	var i; var j;

	var req = jQuery.getJSON("https://api.github.com/repos/analogdevicesinc/libiio/releases/latest");
	req.fail(function() {
		document.getElementById('hidelib').style.display = "none";
		latest_libiio = null;
	});
	req.done(function(response) {
		latest_libiio = response;
		var select = document.getElementById("os-select");
		var suffix = "";
		for (i = 0; i < latest_libiio.assets.length; i++) {
			os = latest_libiio.assets[i].name.split('-')[2];
			suffix = os.slice(-4);
			if (suffix == ".zip" ) {
				os = os.slice(0, os.length-4);
			}
			for (j = 0; j < select.length; j++) {
				if (os.match(select[j].value))
					break;
			}
			if (j == select.length) {
				select.options[select.options.length] = new Option(os);
				if ((win && os == "Windows") || (mac && os == "darwin") || (linux && os == "ubuntu")) {
					select.value = os;
					libiio_type();
				}
			}
		}
	});
	if (win) {
		req = jQuery.getJSON("https://api.github.com/repos/analogdevicesinc/plutosdr-m2k-drivers-win/releases/latest");
		req.done(function(response) {
			for (i = 0; i < response.assets.length; i++) {
				if (response.assets[i].content_type == "application/x-msdownload") {
					jQuery('#drivertest').attr ('href', response.assets[i].browser_download_url);
					document.getElementById('drivertest').innerHTML = response.name;
				}
			}
		});
	} else if (mac) {
		req = jQuery.getJSON("https://api.github.com/repos/jwise/HoRNDIS/releases/latest");
		req.done(function(response) {
			for (i = 0; i < response.assets.length; i++) {
				if (response.assets[i].content_type == "application/octet-stream" &&
						response.assets[i].browser_download_url.slice(-4) == ".pkg") {
					jQuery('#horndistest').attr ('href', response.assets[i].browser_download_url);
					document.getElementById('horndistest').innerHTML = response.name;
				}
			}
		});
	} else {
		document.getElementById('hidedriver').style.display = "none";

	}
}

function libiio_type() {
	var select = document.getElementById("type-select");
	var os = document.getElementById("os-select").value;
	select.onchange = null;
	var i;
	for (i = select.options.length - 1 ; i >= 0 ; i--) {
		select.remove(i);
	}
	var suffix = "";
	for (i = 0; i < latest_libiio.assets.length; i++) {
		if (latest_libiio.assets[i].browser_download_url.match(os)) {
			suffix = latest_libiio.assets[i].browser_download_url.slice(-4);
			if (suffix == "r.gz" ) {
				suffix = ".tar.gz";
			}
			for (j = 0; j < select.length; j++) {
				if (suffix.match(select[j].value))
					break;
				}
				if (j == select.length) {
					select.options[select.options.length] = new Option(suffix);
					if (os.match('centos') && suffix.match('.rpm')) {
						select.value = suffix;
					}
			}
		}
	}
	select.onchange = libiio_ver;
	libiio_ver();
}

function libiio_ver() {
	var select = document.getElementById("ver-select");
	var os = document.getElementById("os-select").value;
	var suffix = document.getElementById("type-select").value;
	select.onchange = null;
	var i;
	for (i = select.options.length - 1 ; i >= 0 ; i--) {
		select.remove(i);
	}
	for (i = 0; i < latest_libiio.assets.length; i++) {
		if (latest_libiio.assets[i].browser_download_url.match(os) && latest_libiio.assets[i].browser_download_url.match(suffix)) {
			var file = latest_libiio.assets[i].name.replace(/libiio-[0-9]*\.[0-9]*.[a-z0-9]*-/, '');
			file = file.slice(0, file.length - suffix.length);
			select.options[select.options.length] = new Option(file);
			if (mac && (file.match(mac) ||
					file.match(/darwin-10.[0-9]*/) < mac)) {
				select.value = file;
				console.log('hit');
			}
		}
	}
	select.onchange = libiio_url;
	libiio_url();
}

function libiio_url() {
	var os = document.getElementById("os-select").value;
	var suffix = document.getElementById("type-select").value;
	var ver = document.getElementById("ver-select").value;
	var i, url;
	for (i = 0; i < latest_libiio.assets.length; i++) {
		url = latest_libiio.assets[i].browser_download_url;
		if (url.match(ver) && url.match(os) && url.match(suffix)) {
			jQuery('#libtest').attr ('href', url);
			document.getElementById('libtest').innerHTML = latest_libiio.assets[i].name;
		}
	}
}

function CheckFrmVersion() {
	GetDriverurl();
	var req = jQuery.getJSON("https://api.github.com/repos/analogdevicesinc/plutosdr-fw/releases/latest");
	req.fail(function() {
		document.getElementById('versiontest').innerHTML = "Can't check right now, try manually";
	});
	req.done(function(response) {
		var VerOnGithub = response.name;
		var res = versionCompare("#BUILD#", VerOnGithub);
		var message;
		if (res < 0) {
			message = "Newer version available online (Version " + VerOnGithub + " )";
			document.getElementById('versionsection').className = "download";
		} else  if (res > 0) {
			message = "Wow! Your Pluto Firmware Version #BUILD# is newer than (" + VerOnGithub + ") on Github.";
			document.getElementById('versionsection').className = "";
			document.getElementById('plutsdr-fw-download').style.visibility = "hidden";
			document.getElementById('hideupgrade').style.display = "none";
		} else if (res == 0) {
			message = "Pluto is using the same version as latest release!";
			document.getElementById('versionsection').className = "";
			document.getElementById('plutsdr-fw-download').style.visibility = "hidden";
			document.getElementById('hideupgrade').style.display = "none";
		} else {
			message = "Failure in comparing version, latest upstream is " + VerOnGithub;
			document.getElementById('versionsection').className = "";
		}
		document.getElementById('versiontest').innerHTML = message;
		document.getElementById('plutsdr-fw-download').innerHTML = "Download version " + VerOnGithub;
		jQuery('#plutsdr-fw-download').attr ('href', response.assets[0].browser_download_url);
	});
}

window.onload = CheckFrmVersion;
