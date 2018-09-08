var _get = function(opt){
	return new Promise(function(resolve,reject){
		$.get(opt.url,opt.data||{})
			.done(function(resp){
				if(resp.error) reject(resp.error);
				resolve(resp);
			}).fail(function(err){reject(err);});
	});
};
var _post = function(opt){
	return new Promise(function(resolve,reject){
		$.post(opt.url,opt.data||{})
			.done(function(resp){
				if(resp.error) reject(resp.error);
				resolve(resp);
			}).fail(function(err){reject(err);});
	});
};
var _request = function(opt){
	return new Promise(function(resolve,reject){
		$.ajax({
			url: opt.url,
			type: opt.method || 'POST',
			dataType: opt.dataType || 'json',
			data: opt.data || {}
		}).done(function(resp){
			if(resp.error) reject(resp.error);
			resolve(resp);
		}).fail(function(err){reject(err);});
	});
};
