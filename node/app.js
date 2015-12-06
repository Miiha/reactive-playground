var express = require('express');
var app = express();
var fs = require('fs');

// returns the path to the word list which is separated by `\n`
var wordListPath = require('word-list');
var wordArray = fs.readFileSync(wordListPath, 'utf8').split('\n');
String.prototype.startsWith = function(needle)
{
    return(this.indexOf(needle) == 0);
};

app.get('/', function (req, res) {
	if (req.query['username'] === 'micha.kao@gmail.com' && req.query['password'] === '1234') {
		res.status(200).json({'message': 'logged in'});
	} else {
		res.status(404).json({'message': 'unknown username or password'});
	}
});

app.get('/words', function (req, res) {
	var q = req.query['q'] || '';
	var max = req.query['max'];

	var words = wordArray.filter(function(word) {
		if (word.startsWith(q)) {
			return true;
		} else {
			return false;
		}
	});
	
	if (max) {
		words = words.slice(0, max);
	}

	res.status(200).json(words); 
});

var server = app.listen(3000, function () {
	var host = server.address().address;
	var port = server.address().port;

	console.log('Example app listening at http://%s:%s', host, port);
});


