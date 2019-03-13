var GA_TOKEN;
[{"token":"UA-133830113-1","base":["https://vmware.github.io/vic-product/"]}].forEach(function(T) {
	var L = window.location;
	var M = true
		&& (!T.host || T.host.indexOf(L.host) >= 0)
		&& (!T.hostname || T.hostname.indexOf(L.hostname) >= 0)
		&& (!T.protocol || T.protocol.indexOf(L.protocol) >= 0)
		&& (!T.port || T.port.indexOf(L.port) >= 0)
		;
	if (T.base && M) {
		M = false;
		for (var i = 0; i < T.base.length; i++) {
			M = M || L.href.startsWith(T.base[i]);
		}
	}
	if (T.path && M) {
		M = false;
		for (var i = 0; i < T.path.length; i++) {
			M = M || L.pathname.startsWith(T.path[i]);
		}
	}
	if (M) {
		GA_TOKEN = T.token;
	}
});
if (GA_TOKEN) {
	(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

	ga('create', GA_TOKEN, 'auto');
	ga('send', 'pageview');
}
