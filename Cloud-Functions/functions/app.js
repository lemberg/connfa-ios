var express = require('express');
var app = express();

app.get('/', function (req, res) {
    res.send('Your PIN:' + generatePin());
});

app.get('/', function (req, res) {
    res.send('Hello World!');
    generatePin()
});

app.get('/pins/generate', function (req, res) {
    res.send('Hello, I am a PINS Generator! ');
    generatePinsArray()
});

app.listen(3000, function () {
    console.log('Example app listening on port 3000!');
});

function formatDigit(num, n = 4) {
    digit = '';
    if (typeof n === 'undefined' || num.toString().length === 4)
        return num.toString()
    for (i = 1; i < n; i++) {
        if (num < (1 + Array(i + 1).join("0")))
            digit += '0';
    }
    digit = digit + num;
    return digit;
}

/**
 */
function generatePinsArray() {

    var numbers = Array(20).fill().map((e,i)=>formatDigit(i+1));
    shuffleArray(numbers);

    console.log(numbers);
}

function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}


/**
 * Returns a random integer between min (inclusive) and max (inclusive)
 * Using Math.round() will give you a non-uniform distribution!
 */
function generatePin() {
    var randomPin = "";
    for (var i = 0; i < 4; i++) {
        const randomInt = getRandomInt(0, 9);
        randomPin += randomInt;
    }
    console.log(randomPin);
    return randomPin;
}

/**
 * Returns a random integer between min (inclusive) and max (inclusive)
 * Using Math.round() will give you a non-uniform distribution!
 */
function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
