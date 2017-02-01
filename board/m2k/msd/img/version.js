function OnTheWeb() {
	window.location.assign("https://wiki.analog.com/university/tools/pluto")
}

function versionCompare(v1, v2) {
	var v1parts = ("" + v1).replace("_", ".").replace(/[^0-9.]/g, "").split("."),
	v2parts = ("" + v2).replace("_", ".").replace(/[^0-9.]/g, "").split("."),
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

function CheckFrmVersion() {
	var req = jQuery.getJSON("https://api.github.com/repos/analogdevicesinc/plutosdr-fw/releases");
	req.done(function(response) {
		var VerOnGithub = response[0].name
		console.log(VerOnGithub)
		var res = versionCompare("#BUILD#", VerOnGithub);
		if (res < 0) {
			var message = "Newer version available online (Version " + VerOnGithub + " )";
			document.getElementById('versionsection').className = "download";
		} else  if (res > 0) {
			var message = "Wow! Your Pluto Firmware Version #BUILD# is newer than (" + VerOnGithub + ") on Github.";
			document.getElementById('versionsection').className = "";
			document.getElementById('plutsdr-fw-download').style.visibility = "hidden";
		} else if (res == 0) {
			var message = "Pluto is using the same version as latest release!";
			document.getElementById('versionsection').className = "";
			document.getElementById('plutsdr-fw-download').style.visibility = "hidden";
		} else {
			var message = "Failure in checking version, check manually";
			document.getElementById('versionsection').className = "";
		}
		document.getElementById('versiontest').innerHTML = message;
		jQuery('#plutsdr-fw-download').attr ('href', response[0].assets[0].browser_download_url);
	});
}

window.onload = CheckFrmVersion;
